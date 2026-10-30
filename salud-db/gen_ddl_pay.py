#!/usr/bin/env python3
"""
gen_ddl_pay.py — DDL de las bases `pay_*` de PasarelaPago (D-18) desde sus .puml.

Es el PERFIL PAY de `gen_ddl.py`: reutiliza su parser y su emisión (tablas, PK, FK de una columna, índices
con nombre explícito y predicado parcial) sin tocar una línea suya, y le suma lo que el DDL de la pasarela
necesita y el generador base no expresa. Todo sale del .puml, nada se inventa (temperatura-0).

Diferencias con SALUD, y por qué:

  * UNA BASE POR SERVICIO. SALUD es una base con ~70 schemas; la pasarela son 11 bases (regla de separación #1
    de su plan maestro). Cada módulo `diagram_<NN>_pay_<svc>.puml` es una BASE, y su `(schema: pay_<svc>)` es solo
    el nombre lógico (registro de FK, carpeta de salida). Por eso el SQL sale SIN calificar: los objetos se crean
    en el esquema de la conexión (`search_path`), igual que el DDL de referencia que reemplaza. Aplicar con
    `PAY_DB_SCHEMA`/`options=-c search_path=…` de cada servicio, o en `public` de su base.
  * Lo que el generador base no expresa va en una entidad `<<PAY_EXTRAS>>` por módulo (parseada acá):
        DEFAULT <tabla>.<col> : <expr>              default no booleano (los booleanos usan <<DEFAULT_TRUE|FALSE>>)
        IDENTITY <tabla>.<col>                      GENERATED ALWAYS AS IDENTITY
        CHECK_SQL <tabla> : <nombre> | <expr>       CHECK con la expresión literal (como el CHECK_SQL del módulo 33)
        FK_SQL <tabla> : <nombre> | (a, b) -> <tabla> (x, y)     FK compuesta
        FUNCTION <nombre>  + líneas `| …`           función (CREATE OR REPLACE)
        TRIGGER <nombre> : <BEFORE … ON t …>        trigger
        SEED_SQL <tabla>   + líneas `| …`           fila de configuración idempotente
  * `bigserial` se admite como tipo (el modelo de SALUD no lo usa).

Salida, en SQL/pay/<NN>_pay_<svc>/ (idempotente, fases en orden):
    01_schema.sql  (solo comentario: sin CREATE SCHEMA)   02_tables.sql   03_fk_intra.sql   04_indexes.sql
    05_constraints.sql (funciones, CHECK, FK compuestas, triggers)   06_seed.sql (si hay)   90_fk_deferred.sql (vacío)
    ddl.sql  = todo lo anterior en orden, en un solo archivo SQL plano (para `pool.query(readFileSync(...))`).
Y SQL/pay/_generation_report.md.

Uso:  python salud-db/gen_ddl_pay.py            # regenera SQL/pay/
      python salud-db/gen_ddl_pay.py --check    # falla (1) si SQL/pay/ difiere de lo que generan los .puml
"""
from __future__ import annotations

import argparse
import re
import shutil
import sys
import tempfile
from pathlib import Path

import gen_ddl
import paths

PUML_DIR = paths.PAY_PUML_DIR
OUT_DIR = paths.PAY_SQL_DIR

ID = r"[a-z_][a-z0-9_]*"
EXTRAS_HEAD_RE = re.compile(r'^\s*entity\s+"PAY EXTRAS[^"]*"\s+as\s+\w+\s+<<PAY_EXTRAS>>\s*\{\s*$')


class Extras:
    """Lo declarado en la entidad <<PAY_EXTRAS>> de un módulo."""

    def __init__(self):
        self.defaults: dict[tuple[str, str], str] = {}
        self.identities: set[tuple[str, str]] = set()
        self.checks: list[tuple[str, str, str, list[str]]] = []          # tabla, nombre, expr, comentarios
        self.fks: list[tuple[str, str, list[str], str, list[str], list[str]]] = []
        self.functions: list[tuple[str, str, list[str]]] = []            # nombre, sql, comentarios
        self.triggers: list[tuple[str, str, str, list[str]]] = []        # nombre, tabla, cuerpo, comentarios
        self.seeds: list[tuple[str, str, list[str]]] = []                # tabla, sql, comentarios


def _cols(s: str) -> list[str]:
    return [c.strip() for c in s.split(",") if c.strip()]


def parse_extras(text: str) -> Extras:
    ex = Extras()
    lines = text.splitlines()
    i, n = 0, len(lines)
    while i < n and not EXTRAS_HEAD_RE.match(lines[i]):
        i += 1
    if i == n:
        return ex
    i += 1
    pending: list[str] = []          # comentarios `'` que preceden al siguiente ítem
    while i < n and lines[i].strip() != "}":
        line = lines[i].strip()
        i += 1
        if not line:
            continue
        if line.startswith("'"):
            pending.append(line[1:].strip())
            continue
        comments, pending = pending, []

        def block() -> str:
            nonlocal i
            buf = []
            while i < n and lines[i].lstrip().startswith("|"):
                buf.append(lines[i].lstrip()[1:].removeprefix(" ").rstrip())
                i += 1
            return "\n".join(buf)

        if m := re.match(rf"^DEFAULT\s+({ID})\.({ID})\s*:\s*(.+)$", line):
            ex.defaults[(m.group(1), m.group(2))] = m.group(3).strip()
        elif m := re.match(rf"^IDENTITY\s+({ID})\.({ID})$", line):
            ex.identities.add((m.group(1), m.group(2)))
        elif m := re.match(rf"^CHECK_SQL\s+({ID})\s*:\s*({ID})\s*\|\s*(.+)$", line):
            if len(m.group(2).encode()) > 63:
                raise ValueError(f"nombre de constraint > 63 bytes: {m.group(2)}")
            ex.checks.append((m.group(1), m.group(2), m.group(3).strip(), comments))
        elif m := re.match(rf"^FK_SQL\s+({ID})\s*:\s*({ID})\s*\|\s*\(([^)]*)\)\s*->\s*({ID})\s*\(([^)]*)\)\s*$", line):
            ex.fks.append((m.group(1), m.group(2), _cols(m.group(3)), m.group(4), _cols(m.group(5)), comments))
        elif m := re.match(rf"^FUNCTION\s+({ID})$", line):
            ex.functions.append((m.group(1), block(), comments))
        elif m := re.match(rf"^TRIGGER\s+({ID})\s*:\s*(.+)$", line):
            body = m.group(2).strip()
            on = re.search(rf"\bON\s+({ID})\b", body)
            if not on:
                raise ValueError(f"TRIGGER sin `ON <tabla>`: {line}")
            ex.triggers.append((m.group(1), on.group(1), body, comments))
        elif m := re.match(rf"^SEED_SQL\s+({ID})$", line):
            ex.seeds.append((m.group(1), block(), comments))
        else:
            raise ValueError(f"línea de PAY_EXTRAS no reconocida: {line!r}")
    return ex


# ---- enganches al generador base (sin editarlo) ---------------------------------------------------
EXTRAS_BY_SCHEMA: dict[str, Extras] = {}
_orig_parse_module = gen_ddl.parse_module
_orig_column_default = gen_ddl.column_default


def parse_module_with_extras(puml: Path):
    schema, entities, idx_by_table, skipped, warnings = _orig_parse_module(puml)
    ex = parse_extras(puml.read_text(encoding="utf-8"))
    EXTRAS_BY_SCHEMA[schema] = ex
    by_name = {e.name: e for e in entities}

    def column(table: str, col: str):
        e = by_name.get(table)
        found = next((c for c in e.columns if c.name == col), None) if e else None
        if found is None:
            raise ValueError(f"{puml.name}: PAY_EXTRAS cita {table}.{col}, que no existe")
        return found

    for (table, col), expr in ex.defaults.items():
        c = column(table, col)
        if c.default is not None:
            raise ValueError(f"{puml.name}: {table}.{col} ya tiene default (booleano) y PAY_EXTRAS declara otro")
        c.default = expr
    for table, col in ex.identities:
        c = column(table, col)
        if c.default is not None or not c.not_null:
            raise ValueError(f"{puml.name}: IDENTITY {table}.{col} exige columna NOT NULL sin default")
        c.identity = True
    for table, name, _expr, _ in ex.checks:
        if table not in by_name:
            raise ValueError(f"{puml.name}: CHECK_SQL {name} cita la tabla {table}, que no existe")
    for table, name, cols, rtable, rcols, _ in ex.fks:
        for t, cs in ((table, cols), (rtable, rcols)):
            for c in cs:
                column(t, c)
    for name, table, _body, _ in ex.triggers:
        if table not in by_name:
            raise ValueError(f"{puml.name}: TRIGGER {name} cita la tabla {table}, que no existe")
    for table, _sql, _ in ex.seeds:
        if table not in by_name:
            raise ValueError(f"{puml.name}: SEED_SQL cita la tabla {table}, que no existe")
    return schema, entities, idx_by_table, skipped, warnings


def column_default_with_identity(col) -> str:
    if getattr(col, "identity", False):
        return " GENERATED ALWAYS AS IDENTITY"
    return _orig_column_default(col)


def install_profile(puml_dir: Path, out_dir: Path) -> None:
    gen_ddl.PUML_DIR = puml_dir
    gen_ddl.OUT_DIR = out_dir
    gen_ddl.FK_DIR = out_dir / "_sin_notas_de_boveda"       # no existe: las FK salen solo de las aristas del .puml
    gen_ddl.q = lambda schema, table: f'"{table}"'          # sin calificar (ver docstring)
    gen_ddl.SKIP_STEREOTYPES["PAY_EXTRAS"] = "complemento del perfil pay (lo materializa gen_ddl_pay.py)"
    gen_ddl.KNOWN_TYPES.add("bigserial")
    gen_ddl.parse_module = parse_module_with_extras
    gen_ddl.column_default = column_default_with_identity


# ---- complementos ---------------------------------------------------------------------------------
def sql_comments(comments: list[str]) -> str:
    return "".join(f"-- {c}\n" if c else "--\n" for c in comments)


def write_constraints(mod_dir: Path, hdr: str, ex: Extras) -> int:
    parts = [hdr + "-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.\n"
             "-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.\n"]
    n = 0
    for name, sql, comments in ex.functions:
        parts.append(f"\n{sql_comments(comments)}{sql.rstrip().rstrip(';')};\n")
        n += 1
    for table, name, expr, comments in ex.checks:
        parts.append(f"\n{sql_comments(comments)}"
                     f'ALTER TABLE "{table}" DROP CONSTRAINT IF EXISTS "{name}";\n'
                     f'ALTER TABLE "{table}" ADD CONSTRAINT "{name}" CHECK ({expr});\n')
        n += 1
    for table, name, cols, rtable, rcols, comments in ex.fks:
        q = lambda cs: ", ".join(f'"{c}"' for c in cs)
        parts.append(f"\n{sql_comments(comments)}"
                     f"DO $$ BEGIN\n"
                     f'    ALTER TABLE "{table}"\n'
                     f'        ADD CONSTRAINT "{name}" FOREIGN KEY ({q(cols)})\n'
                     f'        REFERENCES "{rtable}" ({q(rcols)});\n'
                     f"EXCEPTION WHEN duplicate_object THEN NULL; END $$;\n")
        n += 1
    for name, table, body, comments in ex.triggers:
        parts.append(f"\n{sql_comments(comments)}"
                     f'DROP TRIGGER IF EXISTS "{name}" ON "{table}";\n'
                     f"CREATE TRIGGER {name} {body};\n")
        n += 1
    (mod_dir / "05_constraints.sql").write_text("".join(parts), encoding="utf-8")
    return n


def write_seed(mod_dir: Path, hdr: str, ex: Extras) -> int:
    path = mod_dir / "06_seed.sql"
    if not ex.seeds:
        path.unlink(missing_ok=True)
        return 0
    body = [hdr + "-- Filas de configuración declaradas por el modelo (SEED_SQL). Idempotentes.\n"]
    for table, sql, comments in ex.seeds:
        body.append(f"\n{sql_comments(comments)}{sql.rstrip().rstrip(';')};\n")
    path.write_text("".join(body), encoding="utf-8")
    return len(ex.seeds)


PHASES = ["01_schema.sql", "02_tables.sql", "03_fk_intra.sql", "04_indexes.sql", "05_constraints.sql", "06_seed.sql"]


def generate(puml_dir: Path, out_dir: Path) -> list[str]:
    """Genera todo en `out_dir`. Devuelve los errores de fidelidad (vacío = bien)."""
    install_profile(puml_dir, out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    errors: list[str] = []
    codes = sorted({p.stem.split("_")[1] for p in puml_dir.glob("diagram_*.puml")})
    if not codes:
        return [f"no hay módulos en {puml_dir}"]
    registry = gen_ddl.build_registry(codes)
    pk_map = gen_ddl.build_pk_map(codes)
    report: list = []
    stats: dict[str, dict] = {}
    for code in codes:
        gen_ddl.emit(code, report, registry, pk_map)
        _, schema, nt, nfk, nidx, skipped, warnings, ninf = report[-1]
        mod_dir = out_dir / f"{code}_{schema}"
        puml = next(puml_dir.glob(f"diagram_{code}_*.puml"))
        hdr = (f"-- SALUD {gen_ddl.VERSION} · perfil pay · módulo {code} · base {schema}\n"
               f"-- Generado de {puml.name} — NO editar a mano.\n\n")
        # fidelidad: nada inferido, nada sin resolver, nada ignorado en silencio
        if ninf:
            errors.append(f"{schema}: {ninf} FK inferidas por convención (deben declararse con una arista `hijo }}o--|| padre : columna`)")
        for w in warnings:
            errors.append(f"{schema}: aviso del generador base: {w}")
        deferred = (mod_dir / "90_fk_deferred.sql").read_text(encoding="utf-8")
        if "FK sin destino" in deferred or "REFERENCES" in deferred:
            errors.append(f"{schema}: FK sin resolver o entre schemas en 90_fk_deferred.sql (una base pay no cruza schemas)")
        (mod_dir / "01_schema.sql").write_text(
            hdr + "-- Sin CREATE SCHEMA a propósito: el módulo es una BASE (una por servicio) y sus objetos van sin calificar,\n"
                  "-- en el esquema de la conexión (search_path). Ver gen_ddl_pay.py.\n", encoding="utf-8")
        ex = EXTRAS_BY_SCHEMA[schema]
        n_extra = write_constraints(mod_dir, hdr, ex)
        n_seed = write_seed(mod_dir, hdr, ex)
        ddl = [f"-- SALUD {gen_ddl.VERSION} · perfil pay · base {schema} · DDL completo en orden (generado de {puml.name})\n"
               "-- Archivo SQL plano, apto para `pool.query(readFileSync(...))`. NO editar a mano.\n"]
        for ph in PHASES[1:]:                       # 01_schema.sql es solo un comentario
            f = mod_dir / ph
            if f.exists():
                ddl.append(f"\n-- >>> {ph}\n" + f.read_text(encoding="utf-8"))
        (mod_dir / "ddl.sql").write_text("".join(ddl), encoding="utf-8")
        ex_counts = dict(checks=len(ex.checks), fks_compuestas=len(ex.fks), funciones=len(ex.functions),
                         triggers=len(ex.triggers), semillas=n_seed, defaults=len(ex.defaults), identidades=len(ex.identities))
        stats[schema] = dict(code=code, tablas=nt, fk=nfk, indices=nidx, **ex_counts)
    write_report(out_dir, stats)
    return errors


def write_report(out_dir: Path, stats: dict[str, dict]) -> None:
    lines = [f"# Reporte de generación — perfil pay (SALUD {gen_ddl.VERSION})\n",
             "Generado de `Mantra Core Health Context/pay-modules/*.puml` por `salud-db/gen_ddl_pay.py`. "
             "Una BASE por módulo; objetos sin calificar. Las FK de una columna salen del generador base "
             "(`fk_<tabla>_<col>`); las compuestas, los CHECK, las funciones y los triggers salen de `PAY_EXTRAS`.\n",
             "| Mód | Base | Tablas | FK (1 col) | FK compuestas | Índices (no PK) | CHECK | Defaults no bool. | Identidades | Funciones | Triggers | Semillas |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    tot = dict.fromkeys(["tablas", "fk", "fks_compuestas", "indices", "checks", "defaults", "identidades", "funciones", "triggers", "semillas"], 0)
    for schema, s in sorted(stats.items(), key=lambda kv: kv[1]["code"]):
        lines.append(f"| {s['code']} | {schema} | {s['tablas']} | {s['fk']} | {s['fks_compuestas']} | {s['indices']} | {s['checks']} | "
                     f"{s['defaults']} | {s['identidades']} | {s['funciones']} | {s['triggers']} | {s['semillas']} |")
        for k in tot:
            tot[k] += s[k]
    lines.append(f"| **Σ** | **{len(stats)}** | **{tot['tablas']}** | **{tot['fk']}** | **{tot['fks_compuestas']}** | **{tot['indices']}** | "
                 f"**{tot['checks']}** | **{tot['defaults']}** | **{tot['identidades']}** | **{tot['funciones']}** | **{tot['triggers']}** | **{tot['semillas']}** |\n")
    (out_dir / "_generation_report.md").write_text("\n".join(lines), encoding="utf-8")


def tree(root: Path) -> dict[str, bytes]:
    return {str(p.relative_to(root)): p.read_bytes() for p in sorted(root.rglob("*")) if p.is_file()}


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="no escribe: falla si SQL/pay/ difiere de lo que generan los .puml")
    args = ap.parse_args()

    if args.check:
        with tempfile.TemporaryDirectory() as tmp:
            errors = generate(PUML_DIR, Path(tmp) / "pay")
            fresh, current = tree(Path(tmp) / "pay"), (tree(OUT_DIR) if OUT_DIR.exists() else {})
        diff = sorted(k for k in set(fresh) | set(current) if fresh.get(k) != current.get(k))
        for e in errors:
            print(f"[XX] {e}")
        for k in diff:
            print(f"[XX] SQL/pay/{k}: {'falta' if k not in current else 'sobra' if k not in fresh else 'difiere'}")
        print("SQL/pay/ coincide con los .puml" if not diff and not errors else "SQL/pay/ DESFASADO: regenerar con gen_ddl_pay.py")
        return 1 if diff or errors else 0

    if OUT_DIR.exists():
        shutil.rmtree(OUT_DIR)          # solo el árbol de pay: SQL/ de SALUD no se toca
    errors = generate(PUML_DIR, OUT_DIR)
    for e in errors:
        print(f"[XX] {e}")
    print(f"→ {len(list(OUT_DIR.glob('[0-9][0-9]_*')))} bases en {OUT_DIR.relative_to(paths.MODEL_ROOT)}")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
