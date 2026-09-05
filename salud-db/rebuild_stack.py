# -*- coding: utf-8 -*-
"""rebuild_stack.py — ciclo limpio del stack dev `mantra-redesa` con veredicto.

Reconstruye el entorno de referencia desde cero y lo deja en el estado canónico
documentado (CLAUDE.md / materializacion-fisica-bd.md):

  down -v  →  up SOLO infra  →  init (con reintento de la carrera del primer
  arranque)  →  load_seeds.py --refresh --skip-prod  →  verificación contra lo
  que declara SQL/  →  VEREDICTO: PASS | FAIL (exit 0 | 1).

El corpus MeSH de `seedsProd/` YA NO se carga por defecto: son 1 441 367 filas
(98,3 % del total) que nadie consulta. Con `--con-mesh` vuelve.

Es el ÚNICO camino de recuperación tras un `yarn smoke`: el smoke trunca los
esquemas de negocio y crea datos por API cuyos restos chocan por clave natural
con los seeds — una recarga con `--refresh` a solas deja huérfanos.

Trampas que este script codifica (observadas el 2026-08-05, tarea M2):
  - `docker compose up -d` pelado construye la imagen de la API + 17 workers:
    acá se levanta solo la lista fija de infraestructura.
  - `postgres-init` puede morir con exit 2 en el primer arranque del volumen
    (timescaledb-ha reinicia Postgres tras inicializar y el healthcheck pasa
    durante la ventana del servidor temporal): el init es idempotente y se
    reintenta una vez.
  - El propio `up -d` puede fallar en esa misma ventana con `dependency failed
    to start: container postgres is unhealthy` (defecto 3 del PR #28 del
    vault): se reintenta el `up` —idempotente, no re-baja imágenes— tras
    esperar a que postgres quede `healthy` ESTABLE, nunca el ciclo entero.
  - Los conteos esperados NO van hardcodeados: las igualdades tablas/FKs se
    derivan de SQL/ en el momento (db-fidelity: `BD == SQL/` es la invariante).

No correrlo con una API local escribiendo contra la base. La app se arranca
aparte, siempre con ORM_SCHEMA_SYNC=off o dry-run — jamás safe.

Valores de referencia al escribir esto (informativos, no se asertan): 1 180
tablas · 6 661 FKs · 9 107 índices · ~1 465 927 filas · 7 avisos · tablas
ALOVIDA v4.0.8 en 8/8/27/8/8. Las dos tablas de v4.0.9 (iam.email_verifications,
iam.password_resets) quedan VACÍAS a propósito: son tokens de runtime.

Uso:  python salud-db/rebuild_stack.py [--yes]
      --yes  omite la confirmación (obligatorio sin terminal interactiva)
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def ensure_python_deps() -> None:
    """Falla ANTES de tocar Docker si falta un cliente de Python del ciclo.

    Sin esta guarda cada dependencia rompía por separado y tarde (defecto 2 del
    PR #28 del vault): psycopg en el import de load_seeds (traceback crudo), y
    pymongo/redis recién en su fase de carga — con los 63 módulos ya insertados
    en Postgres. Va antes de `import load_seeds` porque ese import ya exige
    psycopg; los otros dos son perezosos y fallarían al final del ciclo.
    """
    import importlib.util
    faltantes = [m for m in ("psycopg", "pymongo", "redis")
                 if importlib.util.find_spec(m) is None]
    if faltantes:
        raise SystemExit(
            "Faltan dependencias de Python: {}.\n"
            "Instalalas con:  pip install -r salud-db/requirements.txt".format(
                ", ".join(faltantes)))


ensure_python_deps()

import load_seeds
from check_ddl_sources import reportar as reportar_fuentes_ddl, revisar as revisar_fuentes_ddl
from gen_seeds import CREATE_RE, FK_RE, backend_id, ddl_files

import paths

# `ROOT` es el repositorio del modelo; el compose vive en la API, hermana suya.
ROOT = paths.MODEL_ROOT
COMPOSE_FILE = paths.COMPOSE_FILE
LOAD_SEEDS = Path(__file__).resolve().parent / "load_seeds.py"

# Lista fija: SOLO infraestructura + servicios one-shot de init. Nunca `up -d`
# pelado (construiría la imagen de la API y los 17 workers).
INFRA_SERVICES = ["postgres", "postgres-init", "mongodb", "mongo-init",
                  "redis", "opensearch", "opensearch-init", "minio"]
ONE_SHOTS = ["postgres-init", "mongo-init", "opensearch-init"]

HUERFANOS_RE = re.compile(r"huérfanos totales:\s*(\d+)")
INSERTADOS_RE = re.compile(r"TOTAL insertados:\s*([\d\s.,]+?)\s*·")
AVISOS_RE = re.compile(r"Avisos \((\d+)\)")


# ----------------------------------------------------------------- subprocesos

def run(cmd: list, capture: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, text=True, encoding="utf-8", errors="replace",
                          capture_output=capture)


def compose(*args: str, capture: bool = False) -> subprocess.CompletedProcess:
    return run(["docker", "compose", "-f", str(COMPOSE_FILE), *args], capture)


# ----------------------------------------------------------------- guardas

def ensure_not_production() -> None:
    """Aborta ANTES de tocar Docker: `down -v` destruye los volúmenes y el
    hard-fail de load_seeds llegaría tarde. Mira el entorno del proceso y el
    .env de la API (load_config no lee os.environ)."""
    de_donde = None
    if os.environ.get("NODE_ENV") == "production":
        de_donde = "el entorno del proceso"
    elif load_seeds.load_config().get("NODE_ENV") == "production":
        de_donde = "mantra-core-health-api/.env"
    if de_donde:
        raise SystemExit(f"HARD-FAIL: NODE_ENV=production ({de_donde}) — "
                         "el ciclo limpio destruye y repuebla la base; prohibido en producción")


def confirm_or_die(assume_yes: bool) -> None:
    if assume_yes:
        return
    sin_tty = ("Sin confirmación interactiva: este comando destruye los volúmenes "
               "del stack dev. Repetilo con --yes para confirmar.")
    if not sys.stdin.isatty():
        raise SystemExit(sin_tty)
    try:
        respuesta = input("Esto BORRA los volúmenes del stack `mantra-redesa` y lo repuebla "
                          "desde cero (~20-25 min). ¿Continuar? [s/N] ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        # isatty() puede mentir (stdin al dispositivo nulo en Windows): un EOF
        # en el prompt equivale a no poder confirmar.
        raise SystemExit(sin_tty) from None
    if respuesta not in ("s", "si", "sí"):
        raise SystemExit("Cancelado.")


def preflight() -> None:
    result = compose("config", "--services", capture=True)
    if result.returncode != 0:
        raise SystemExit(f"docker compose no responde:\n{result.stderr.strip()}")
    declared = set(result.stdout.split())
    missing = [s for s in INFRA_SERVICES if s not in declared]
    if missing:
        raise SystemExit(f"el compose no declara los servicios {missing} — "
                         "¿cambió docker-compose.yml?")


# ----------------------------------------------------------------- ciclo

def postgres_health() -> str:
    """Estado del healthcheck del contenedor postgres ('' si aún no existe)."""
    cid = compose("ps", "-aq", "postgres", capture=True).stdout.strip()
    if not cid:
        return ""
    estado = run(["docker", "inspect", "-f", "{{.State.Health.Status}}", cid],
                 capture=True).stdout.strip()
    return estado


def wait_postgres_stable(lecturas: int = 3, intervalo_s: int = 5,
                         plazo_s: int = 240) -> bool:
    """Espera a que postgres reporte `healthy` en N lecturas CONSECUTIVAS.

    Una sola lectura no alcanza: en el primer arranque sobre volumen nuevo,
    timescaledb-ha levanta un servidor temporal que pasa pg_isready, hace
    initdb y REINICIA — la ventana en la que el compose declaraba unhealthy a
    postgres-init y abortaba el ciclo (defecto 3 del PR #28 del vault). Exigir
    estabilidad evita dar por sano justo ese servidor temporal.
    """
    import time
    consecutivas, inicio = 0, time.monotonic()
    while time.monotonic() - inicio < plazo_s:
        estado = postgres_health()
        consecutivas = consecutivas + 1 if estado == "healthy" else 0
        if consecutivas >= lecturas:
            return True
        time.sleep(intervalo_s)
    return False


def up_infra_with_retry(intentos: int = 3) -> None:
    """`up -d` de la infraestructura tolerando el reinicio del initdb.

    Reintentar el `up` es barato e idempotente: no re-crea lo que ya corre ni
    re-baja imágenes — el dolor que había que evitar era reintentar el CICLO
    entero (down -v y ~2 GB de descarga de nuevo). Tras cada intento fallido se
    espera a que postgres quede `healthy` estable, porque la causa típica del
    fallo es su reinicio de initdb y el resto de la infra depende de él.
    """
    for intento in range(1, intentos + 1):
        if compose("up", "-d", *INFRA_SERVICES).returncode == 0:
            return
        print(f"  up -d falló (intento {intento}/{intentos}) — típica carrera del "
              "initdb del primer arranque; esperando a postgres estable…")
        if not wait_postgres_stable():
            print("  postgres no llegó a `healthy` estable en el plazo")
    raise SystemExit("docker compose up falló tras {} intentos".format(intentos))


def wait_one_shot(service: str) -> int:
    """Espera el exit del contenedor one-shot; ante fallo reintenta UNA vez
    (la carrera del primer arranque de timescaledb-ha). Devuelve el exit code."""
    cid = compose("ps", "-aq", service, capture=True).stdout.strip()
    if not cid:
        print(f"    {service}: sin contenedor (¿no arrancó?)")
        return 1
    code = int(run(["docker", "wait", cid], capture=True).stdout.strip() or 1)
    if code != 0:
        print(f"    {service}: exit {code} — reintento (carrera del primer arranque)")
        run(["docker", "start", cid], capture=True)
        code = int(run(["docker", "wait", cid], capture=True).stdout.strip() or 1)
    if code != 0:
        print(f"    {service}: exit {code} tras el reintento; últimas líneas:")
        logs = run(["docker", "logs", "--tail", "8", cid], capture=True)
        for line in (logs.stdout + logs.stderr).splitlines()[-8:]:
            print(f"      {line}")
    else:
        print(f"    {service}: exit 0")
    return code


def run_load(con_mesh: bool = False) -> dict:
    """Ejecuta load_seeds.py --refresh en streaming y captura las métricas
    del resumen (huérfanos / insertados / avisos).

    Por defecto NO carga el corpus MeSH de `seedsProd/`: son 1 441 367 filas
    (el 98,3 % del total) y 501 MiB que ninguna parte del sistema consulta —
    ningún `*_concept_id` del modelo lo referencia, ningún servicio, test ni
    smoke lo nombra. Cargarlo se lleva el grueso de los ~10 min de la fase 4.
    Con `--con-mesh` se vuelve al comportamiento anterior.
    """
    cmd = [sys.executable, str(LOAD_SEEDS), "--refresh"]
    if not con_mesh:
        cmd.append("--skip-prod")
    proc = subprocess.Popen(cmd,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True, encoding="utf-8", errors="replace")
    lines = []
    assert proc.stdout is not None
    for line in proc.stdout:
        print(line, end="")
        lines.append(line)
    proc.wait()
    text = "".join(lines)
    grab = lambda rx: (rx.search(text).group(1).strip() if rx.search(text) else None)
    return {
        "returncode": proc.returncode,
        "huerfanos": int(grab(HUERFANOS_RE)) if grab(HUERFANOS_RE) is not None else None,
        "insertados": grab(INSERTADOS_RE),
        "avisos": int(grab(AVISOS_RE)) if grab(AVISOS_RE) is not None else 0,
    }


# ----------------------------------------------------------------- verificación

def expected_from_sql() -> tuple:
    """Lo que SQL/ (y los stores PG de NoSQL/) declaran hoy — sin números fijos."""
    tables = sum(len(CREATE_RE.findall(f.read_text(encoding="utf-8"))) for f in ddl_files())
    fks = 0
    for pattern in ("[0-9][0-9]_*/03_fk_intra.sql", "[0-9][0-9]_*/90_fk_deferred.sql"):
        for f in sorted((ROOT / "SQL").glob(pattern)):
            fks += len(FK_RE.findall(f.read_text(encoding="utf-8")))
    return tables, fks


def observed_from_db(conn) -> dict:
    q = lambda sql, *params: conn.execute(sql, params or None).fetchone()[0]
    obs = {
        "tablas": q("""SELECT count(*) FROM information_schema.tables
                        WHERE table_type='BASE TABLE' AND table_schema NOT LIKE 'pg_%%'
                          AND table_schema NOT LIKE '\\_timescaledb%%'
                          AND table_schema NOT IN ('information_schema',
                              'timescaledb_information','timescaledb_experimental')"""),
        "fks": q("""SELECT count(*) FROM pg_constraint c
                     JOIN pg_class cl ON cl.oid=c.conrelid
                     JOIN pg_namespace n ON n.oid=cl.relnamespace
                    WHERE c.contype='f' AND n.nspname NOT LIKE '\\_timescaledb%%'"""),
        "indices": q("""SELECT count(*) FROM pg_indexes
                         WHERE schemaname NOT IN ('pg_catalog','information_schema')
                           AND schemaname NOT LIKE '\\_timescaledb%%'"""),
        "ux_token_hash": q("""SELECT count(*) FROM pg_indexes WHERE schemaname='iam'
                               AND indexname='ux_account_activations_token_hash'"""),
        # v4.0.9: las dos tablas promovidas nacen VACÍAS —son tokens de runtime, no
        # llevan seeds—, así que lo que se verifica es que existan, no que tengan
        # filas. Que falten es justo el bloqueador que cerró esta versión: sin ellas
        # los registros de paciente respondían 500 en base limpia.
        "tablas_v409": q("""SELECT count(*) FROM information_schema.tables
                             WHERE table_schema='iam'
                               AND table_name IN ('email_verifications','password_resets')"""),
        # Los dos índices únicos PARCIALES. Se exige el predicado en la definición:
        # sin él serían índices únicos TOTALES, que no es un matiz sino otra regla
        # —un UNIQUE llano sobre external_subject bloquea un alta legítima cuando el
        # sujeto tiene una credencial revocada—. Es el modo de fallo que introduciría
        # perder el WHERE en cualquier punto de la cadena .puml → SQL/ → catálogo.
        "ux_credentials_parcial": q("""SELECT count(*) FROM pg_indexes WHERE schemaname='iam'
                                        AND indexname='ux_authentication_credentials_live_password_subject'
                                        AND indexdef LIKE '%%WHERE%%'"""),
        "uq_rx_idempotency_parcial": q("""SELECT count(*) FROM pg_indexes WHERE schemaname='clinical'
                                           AND indexname='uq_medication_requests_issue_idempotency_key'
                                           AND indexdef LIKE '%%WHERE%%'"""),
        # v4.0.10: ningún identificador del modelo debe ser un truncado silencioso.
        # Un nombre de exactamente 63 bytes es legal SI termina en el sufijo hash
        # `_hex8` de pg_ident() o si el nombre lógico mide exactamente 63; lo que
        # delata el truncado es un nombre de 63 que NO está declarado en SQL/ —
        # pero esa igualdad ya la cubren los checks tablas/FKs == SQL/. Acá se
        # verifica lo barato y suficiente: los triggers WORM existen (el 05 de
        # audit se aplicó) y las FKs con hash son exactamente las esperadas.
        "fks_con_hash": q("""SELECT count(*) FROM pg_constraint c
                              JOIN pg_namespace n ON n.oid=c.connamespace
                             WHERE c.contype='f' AND n.nspname NOT LIKE '\\_timescaledb%%'
                               AND c.conname ~ '_[0-9a-f]{8}$'"""),
        "worm_triggers": q("""SELECT count(*) FROM pg_trigger t
                               JOIN pg_class c ON c.oid=t.tgrelid
                               JOIN pg_namespace n ON n.oid=c.relnamespace
                              WHERE n.nspname='audit' AND NOT t.tgisinternal
                                AND t.tgname IN ('trg_forbid_mutation','trg_forbid_update')"""),
    }
    for key, table in (("care_relationships", "authz.care_relationships"),
                       ("patient_legal_representations", "authz.patient_legal_representations"),
                       ("prescription_signature_policies", "clinical.prescription_signature_policies"),
                       ("booking_confirmation_rules", "scheduling.booking_confirmation_rules"),
                       ("account_activations", "iam.account_activations")):
        obs[key] = q(f"SELECT count(*) FROM {table}")  # noqa: S608 — tablas fijas de la tupla
    # El cierre de D-05: la comodín del tenant DEFAULT del backend, tal como la
    # siembra canonical_signature_policies (gen_seeds).
    obs["politica_d05_default"] = q(
        """SELECT count(*) FROM clinical.prescription_signature_policies
            WHERE tenant_id = %s AND signature_required
              AND jurisdiction_code IS NULL AND medication_type_concept_id IS NULL
              AND channel_concept_id IS NULL AND effective_to IS NULL""",
        backend_id("seed:tenant:default"))
    return obs


def build_checks(expected_tables: int, expected_fks: int, obs: dict, load: dict) -> list:
    """(nombre, esperado, observado, ok) — la tabla del veredicto."""
    checks = [
        ("tablas BD == SQL/", expected_tables, obs["tablas"], obs["tablas"] == expected_tables),
        ("FKs BD == SQL/", expected_fks, obs["fks"], obs["fks"] == expected_fks),
        ("ux_account_activations_token_hash", 1, obs["ux_token_hash"], obs["ux_token_hash"] == 1),
        ("tablas v4.0.9 (email_verifications, password_resets)", 2, obs["tablas_v409"],
         obs["tablas_v409"] == 2),
        ("ux_..._live_password_subject es PARCIAL", 1, obs["ux_credentials_parcial"],
         obs["ux_credentials_parcial"] == 1),
        ("uq_..._issue_idempotency_key es PARCIAL", 1, obs["uq_rx_idempotency_parcial"],
         obs["uq_rx_idempotency_parcial"] == 1),
        ("FKs acortadas con hash (pg_ident)", 58, obs["fks_con_hash"],
         obs["fks_con_hash"] == 58),
        ("triggers WORM de audit (v4.0.10)", 2, obs["worm_triggers"],
         obs["worm_triggers"] == 2),
        ("huérfanos de la carga", 0, load["huerfanos"], load["huerfanos"] == 0),
        ("política D-05 comodín (tenant DEFAULT)", ">=1", obs["politica_d05_default"],
         obs["politica_d05_default"] >= 1),
    ]
    for key in ("care_relationships", "patient_legal_representations",
                "prescription_signature_policies", "booking_confirmation_rules",
                "account_activations"):
        checks.append((f"filas {key}", ">0", obs[key], obs[key] > 0))
    return checks


def print_verdict(checks: list, obs: dict, load: dict) -> bool:
    print("\n══ Verificación del estado canónico ══")
    for name, expected, observed, ok in checks:
        print("  [{}] {:<42} esperado {:>7}  observado {:>9}".format(
            "OK" if ok else "XX", name, str(expected), str(observed)))
    print(f"  (informativo) índices: {obs['indices']} · filas insertadas: "
          f"{load['insertados']} · avisos de carga: {load['avisos']}")
    passed = all(ok for *_, ok in checks)
    print(f"\nVEREDICTO: {'PASS' if passed else 'FAIL'}")
    if passed:
        print("Recordatorio: la app se arranca aparte y con ORM_SCHEMA_SYNC=off o "
              "dry-run — jamás safe.")
    return passed


# ----------------------------------------------------------------- main

def check_ddl_sources() -> None:
    """Aborta si hay DDL compitiendo con `SQL/`.

    Va antes del `down -v` a propósito: reconstruir desde una fuente equivocada
    produce una base que parece correcta y no lo es, y el error solo aparecería
    tras la carga completa —varios minutos y el corpus MeSH más tarde—.
    """
    print("\n══ 0/4 · fuentes de DDL ══")
    if reportar_fuentes_ddl(revisar_fuentes_ddl()) != 0:
        raise SystemExit(
            "Hay DDL fuera de SQL/: reconstruir ahora materializaría una fuente "
            "que no es el modelo. Resolvé los hallazgos y reintentá.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Ciclo limpio del stack dev mantra-redesa (down -v → up infra → "
                    "init → carga completa → veredicto)")
    parser.add_argument("--yes", action="store_true",
                        help="omite la confirmación (obligatorio sin TTY)")
    parser.add_argument("--con-mesh", action="store_true",
                        help="carga también el corpus MeSH de seedsProd/ "
                             "(1 441 367 filas, ~501 MiB); por defecto se omite")
    args = parser.parse_args()

    ensure_not_production()
    confirm_or_die(args.yes)
    check_ddl_sources()
    preflight()

    print("\n══ 1/4 · down -v ══")
    if compose("down", "-v").returncode != 0:
        raise SystemExit("docker compose down -v falló")

    print("\n══ 2/4 · up (solo infraestructura) ══")
    up_infra_with_retry()
    print("  esperando los servicios de init:")
    exits = {service: wait_one_shot(service) for service in ONE_SHOTS}
    if exits["postgres-init"] != 0:
        raise SystemExit("postgres-init no aplicó el DDL — sin esquema no hay carga")

    etiqueta = "con MeSH" if args.con_mesh else "sin MeSH"
    print(f"\n══ 3/4 · carga de seeds ({etiqueta}) ══")
    load = run_load(con_mesh=args.con_mesh)
    if load["returncode"] != 0:
        raise SystemExit(f"load_seeds.py terminó con exit {load['returncode']}")
    if load["huerfanos"] is None:
        raise SystemExit("no se encontró 'huérfanos totales' en la salida de la carga — "
                         "¿cambió el formato del resumen de load_seeds.py?")

    print("\n══ 4/4 · verificación ══")
    expected_tables, expected_fks = expected_from_sql()
    conn = load_seeds.connect_pg(load_seeds.load_config())
    try:
        obs = observed_from_db(conn)
    finally:
        conn.close()

    checks = build_checks(expected_tables, expected_fks, obs, load)
    for service, code in exits.items():
        checks.append((f"init {service}", 0, code, code == 0))
    sys.exit(0 if print_verdict(checks, obs, load) else 1)


if __name__ == "__main__":
    main()
