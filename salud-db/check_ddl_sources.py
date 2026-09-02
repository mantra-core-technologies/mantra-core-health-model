# -*- coding: utf-8 -*-
"""check_ddl_sources.py — que `SQL/` siga siendo la única fuente del esquema.

El esquema PostgreSQL se deriva de los `.puml` y se materializa en `SQL/`. Cuando
aparece DDL fuera de esa cadena, no falla nada: sencillamente hay dos verdades, y
la que gana es la que alguien aplicó último. Es un fallo silencioso que solo se
nota cuando una base limpia no tiene una tabla que el código da por hecha.

Esto ya ocurrió dos veces con `mantra-core-health-api/database/`:

  * v4.0.8 (2026-07-30) — un merge de `dev` trajo 6 migraciones sueltas. Se
    promovieron al modelo y se eliminó el directorio.
  * v4.0.9 (2026-08-05) — otro merge lo devolvió, con los montajes del compose
    apuntando de nuevo a esa copia, y encima se escribieron 5 migraciones más.
    Esta vez el efecto sí se consumó: `iam.email_verifications` no existía en base
    limpia y los 27 casos de registro del smoke respondían 500.

La regla no se sostiene sola —lo demuestra la segunda vez—, así que este script la
convierte en un fallo ruidoso. No es un lint de estilo: cada hallazgo describe una
fuente de DDL que compite con `SQL/`.

LA EXCEPCIÓN: `database/SQL` y `database/NoSQL` como copia de despliegue
--------------------------------------------------------------------------
Desde el 2026-09-02 esos dos árboles vuelven a existir, y esta vez a propósito:
Coolify clona UN repositorio, así que el contenedor de init no puede montar
`../mantra-core-health-model/SQL`. La copia viaja versionada dentro del repo de la
API, la escribe `scripts/db/vendor-ddl.sh` desde el modelo y CI la comprueba con
`yarn db:vendor:check`.

Una copia GENERADA y verificada no es una segunda verdad: es un artefacto de build.
Lo que sí sería una segunda verdad es esa copia DESFASADA, que es precisamente el
fallo silencioso que este script persigue. Por eso no se la exime en bloque: se la
compara contra `SQL/` y `NoSQL/`, y solo se reporta cuando difiere de verdad.

La comparación ignora el fin de línea. En Windows el repositorio del modelo se
descarga con CRLF y la copia se escribe con LF, así que un `diff` byte a byte da
~300 archivos «distintos» que son el mismo texto. (`vendor-ddl.sh --check` usa
`rsync`, que sí compara bytes: en Windows su salida es ruidosa por este motivo.)

Uso:  python salud-db/check_ddl_sources.py [--quiet]
Sale con 1 si encuentra algo. Lo invoca `rebuild_stack.py` antes de destruir el
volumen, para que el fallo aparezca antes de una recarga larga.

Política completa: `Mantra Core Health Context/docs/architecture/ddl-sources.md`
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

import paths

# `ROOT` es el repositorio del modelo, pero el barrido en busca de DDL suelto va
# sobre el WORKSPACE entero: lo que este chequeo persigue —una copia del toolkit
# dentro del repo de la API— vive fuera de este repositorio. Ver `paths.py`.
ROOT = paths.MODEL_ROOT
BARRIDO = paths.WORKSPACE
API = paths.API_DIR
COMPOSE = paths.COMPOSE_FILE

# Directorios donde el DDL es legítimo. `SQL/patches/` incluido: son ALTERs sobre
# bases vivas y lo que no se deriva de los `.puml` (RLS, seeds de desarrollo).
FUENTES_LEGITIMAS = (paths.SQL_DIR, paths.NOSQL_DIR)

# Copias del toolkit dentro del repo de la API. Nadie las genera ni las verifica:
# si aparecen, es un merge que arrastró lo que ya se retiró dos veces.
ARBOLES_PROHIBIDOS = (
    API / "database" / "Mantra Core Health Context",
    API / "database" / "salud-db",
)

# La copia de despliegue: cada árbol versionado con el canónico del que sale.
# La escribe `scripts/db/vendor-ddl.sh` y la comprueba `yarn db:vendor:check`.
COPIA_DE_DESPLIEGUE = (
    (API / "database" / "SQL", paths.SQL_DIR),
    (API / "database" / "NoSQL", paths.NOSQL_DIR),
)

# Artefactos que no son contenido: los excluye también `vendor-ddl.sh`.
COPIA_IGNORA = (".DS_Store",)

CREATE_TABLE_RE = re.compile(r"^\s*CREATE\s+TABLE", re.IGNORECASE | re.MULTILINE)
MONTAJE_LOCAL_RE = re.compile(r"^\s*-\s*\./database/(SQL|NoSQL)\b", re.MULTILINE)

# Ruido conocido: dependencias y artefactos que no son fuente de nada.
EXCLUIDOS = ("node_modules", ".git", "dist", "coverage", "graphify-out")


def _relativa(path: Path) -> str:
    for base in (ROOT, BARRIDO):
        try:
            return str(path.relative_to(base))
        except ValueError:
            continue
    return str(path)


def arboles_prohibidos() -> list[str]:
    """Copias del toolkit dentro del repo de la API."""
    return [
        f"existe `{_relativa(d)}` — es una copia, no una fuente. Su DDL no lo "
        f"aplica nadie y se desfasa en silencio."
        for d in ARBOLES_PROHIBIDOS
        if d.is_dir()
    ]


def _contenido(base: Path) -> dict[str, bytes]:
    """Los archivos de un árbol, con el fin de línea normalizado.

    Ver el encabezado: en Windows las dos copias difieren en CRLF sin diferir en
    contenido, y comparar bytes daría ~300 falsos desfases.
    """
    archivos: dict[str, bytes] = {}
    for f in base.rglob("*"):
        if not f.is_file():
            continue
        if f.name in COPIA_IGNORA or f.suffix == ".pyc":
            continue
        if any(parte in EXCLUIDOS for parte in f.parts):
            continue
        try:
            archivos[f.relative_to(base).as_posix()] = f.read_bytes().replace(b"\r\n", b"\n")
        except OSError:
            continue
    return archivos


def copia_de_despliegue_desfasada() -> list[str]:
    """La copia versionada del DDL, comparada con la fuente de la que sale.

    No se exime por existir: se exime por coincidir. Una copia desfasada llevaría
    al servidor un esquema que el modelo ya cambió, que es el fallo que este
    script persigue.
    """
    hallazgos = []
    for copia, fuente in COPIA_DE_DESPLIEGUE:
        if not copia.is_dir() or not fuente.is_dir():
            continue
        actual, canonico = _contenido(copia), _contenido(fuente)
        faltan = sorted(set(canonico) - set(actual))
        sobran = sorted(set(actual) - set(canonico))
        distintos = sorted(k for k in set(actual) & set(canonico) if actual[k] != canonico[k])
        if not (faltan or sobran or distintos):
            continue

        detalle = ", ".join(
            f"{rotulo} {len(items)} ({', '.join(items[:3])}{'…' if len(items) > 3 else ''})"
            for rotulo, items in (
                ("faltan", faltan), ("sobran", sobran), ("difieren", distintos),
            )
            if items
        )
        hallazgos.append(
            f"`{_relativa(copia)}` está desfasada respecto de `{_relativa(fuente)}`: "
            f"{detalle}. Es la copia que se despliega: así llevaría al servidor un "
            f"esquema que el modelo ya cambió. Ejecutar `yarn db:vendor` en "
            f"`mantra-core-health-api/`."
        )
    return hallazgos


def montajes_del_compose() -> list[str]:
    """El compose debe montar los directorios canónicos de la raíz."""
    if not COMPOSE.is_file():
        return []
    texto = COMPOSE.read_text(encoding="utf-8", errors="replace")
    if not MONTAJE_LOCAL_RE.search(texto):
        return []
    return [
        f"`{_relativa(COMPOSE)}` monta `./database/...` en un servicio de init: "
        f"la base se inicializaría desde la copia del repo y no desde `SQL/`. "
        f"Los montajes canónicos son `../mantra-core-health-model/SQL` y "
        f"`../mantra-core-health-model/NoSQL`."
    ]


def ddl_fuera_de_lugar() -> list[str]:
    """Archivos con CREATE TABLE fuera de las fuentes legítimas."""
    hallazgos = []
    vendidas = tuple(copia for copia, _ in COPIA_DE_DESPLIEGUE)
    for sql in BARRIDO.rglob("*.sql"):
        if any(parte in EXCLUIDOS for parte in sql.parts):
            continue
        if any(_esta_dentro(sql, base) for base in FUENTES_LEGITIMAS):
            continue
        # La copia de despliegue no se enumera archivo por archivo: es el mismo
        # DDL legítimo, y si se desfasa lo dice `copia_de_despliegue_desfasada()`
        # en un solo hallazgo accionable en vez de en 66.
        if any(_esta_dentro(sql, base) for base in vendidas):
            continue
        try:
            texto = sql.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if CREATE_TABLE_RE.search(texto):
            hallazgos.append(
                f"`{_relativa(sql)}` declara CREATE TABLE fuera de `SQL/` y "
                f"`NoSQL/` — si la tabla es del modelo va en su `.puml`; si no se "
                f"deriva de los `.puml`, en `SQL/patches/`."
            )
    return hallazgos


def _esta_dentro(path: Path, base: Path) -> bool:
    try:
        path.relative_to(base)
        return True
    except ValueError:
        return False


def revisar() -> list[str]:
    """Todas las fuentes de DDL que compiten con `SQL/`. Vacía = todo en orden."""
    return (
        arboles_prohibidos()
        + copia_de_despliegue_desfasada()
        + montajes_del_compose()
        + ddl_fuera_de_lugar()
    )


def reportar(hallazgos: list[str], quiet: bool = False) -> int:
    """Imprime el resultado y devuelve el código de salida."""
    if not hallazgos:
        if not quiet:
            print("Fuentes de DDL OK: `SQL/` y `NoSQL/` de la raíz son las únicas.")
        return 0

    print(f"\n══ Fuentes de DDL en conflicto con SQL/ ({len(hallazgos)}) ══")
    for hallazgo in hallazgos:
        print(f"  [XX] {hallazgo}")
    print(
        "\nEl esquema se declara en los `.puml` y se materializa en `SQL/` con "
        "gen_ddl.py.\nVer `Mantra Core Health Context/docs/architecture/"
        "ddl-sources.md`."
    )
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--quiet", action="store_true",
                        help="no imprime nada si todo está bien")
    args = parser.parse_args()
    return reportar(revisar(), quiet=args.quiet)


if __name__ == "__main__":
    raise SystemExit(main())
