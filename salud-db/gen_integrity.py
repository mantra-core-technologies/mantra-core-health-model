#!/usr/bin/env python3
"""
gen_integrity.py — Extrae la MATRIZ DE INTEGRIDAD del módulo 33 (schema integrity) y la
materializa en:

  SQL/_integrity/00_integrity_functions.sql   schema integrity + función guarda de inmutabilidad
  SQL/_integrity/integrity-matrix.md          documento accionable (política + matriz por dueño)
  SQL/<NN>_<schema>/05_constraints.sql         scaffold por módulo DUEÑO con las reglas del 33

Temperatura-0: el módulo 33 declara las reglas de forma SEMI-concreta (columnas lógicas y
CHECK/EXCLUDE en prosa). Se genera concreto SOLO lo mecánico (guardas de inmutabilidad para
UPDATE_DELETE: forbidden). CHECK_SQL y EXCLUDE_SQL materializan expresiones concretas
declaradas por el modelo; UK/CHECK/EXCLUDE en prosa salen como comentario con la regla
textual, porque el modelo no declara su expresión SQL y completarla sería adivinar.
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

import gen_ddl

import paths

REPO = gen_ddl.REPO
PUML_DIR = gen_ddl.PUML_DIR
SQL_DIR = paths.SQL_DIR
OUT = SQL_DIR / "_integrity"


def parse_module33():
    puml = next(PUML_DIR.glob("diagram_33_*.puml"))
    lines = puml.read_text(encoding="utf-8").splitlines()
    ents, rels, notes = [], [], {}
    i, n = 0, len(lines)
    while i < n:
        line = lines[i]
        em = re.match(r'^entity\s+(?:"([a-z_][a-z0-9_]*\.[a-z_][a-z0-9_]*)"\s+as\s+[a-z_][a-z0-9_]*|([a-z_][a-z0-9_]*))\s*<<([^>]+)>>', line)
        if em:
            name, stereo, rules = em.group(1) or em.group(2), em.group(3), []
            i += 1
            while i < n and lines[i].strip() != "}":
                rm = re.match(r"^\s*([A-Z_]+)\s*:\s*(.+?)\s*$", lines[i])
                if rm:
                    rules.append((rm.group(1), rm.group(2).strip()))
                i += 1
            ents.append({"name": name, "stereo": stereo, "rules": rules})
        elif "-->" in line and ":" in line:
            rm = re.match(r"^\s*([a-z_]+)\s*-->\s*([a-z_]+)\s*:\s*(.+?)\s*$", line)
            if rm:
                rels.append((rm.group(1), rm.group(2), rm.group(3)))
        elif line.startswith("note as"):
            key = line.split()[2]
            buf = []
            i += 1
            while i < n and not lines[i].strip().startswith("end note"):
                buf.append(lines[i].rstrip())
                i += 1
            notes[key] = "\n".join(buf)
        i += 1
    return ents, rels, notes


def resolve_owners(ents, registry):
    for e in ents:
        name = e["name"]
        if "." in name:
            schema, table = name.split(".", 1)
            owner = (schema, table)
            if owner not in registry.get(table, []):
                raise ValueError(f"Dueño de integridad no declarado: {name}")
            e["owner"] = owner
        else:
            hits = registry.get(name)
            e["owner"] = hits[0] if hits and len(hits) == 1 else None
    return ents


def owner_folder(schema):
    hits = sorted(SQL_DIR.glob(f"[0-9][0-9]_{schema}"))
    return hits[0] if hits else None


# ------------------------------------------------------------------ funciones guarda
def write_functions():
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "00_integrity_functions.sql").write_text(
        f"-- SALUD {gen_ddl.VERSION} · guardas de integridad (aplicar antes de los 05_constraints)\n"
        '-- Deriva del módulo 33 (Concurrency, Constraints and Integrity Matrix).\n\n'
        'CREATE SCHEMA IF NOT EXISTS "integrity";\n\n'
        "-- Barrera física de inmutabilidad (UPDATE_DELETE: forbidden / <<IMMUTABLE>> / <<APPEND_ONLY>>).\n"
        'CREATE OR REPLACE FUNCTION "integrity"."forbid_mutation"() RETURNS trigger\n'
        "LANGUAGE plpgsql AS $$\n"
        "BEGIN\n"
        "    RAISE EXCEPTION 'append-only/immutable: % no permitido en %.%',\n"
        "        TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';\n"
        "END $$;\n", encoding="utf-8")


def immutability_guard(schema, table, ops=("UPDATE", "DELETE")):
    """Barrera física de inmutabilidad sobre las operaciones indicadas.

    `forbid_mutation()` es neutral a la operación (rechaza lo que el trigger le
    enganche vía TG_OP): la asimetría vive enteramente en la cláusula BEFORE.
    El caso parcial existe por `audit.data_access_log` (v4.0.10): prohíbe UPDATE
    pero conserva el DELETE para la purga de retención de UC-10-09.

    El nombre del trigger es distinto por caso (`trg_forbid_mutation` para el
    total, `trg_forbid_update` para el parcial) para que puedan convivir y para
    que el nombre diga qué prohíbe.
    """
    t = f'"{schema}"."{table}"'
    ops_sql = ", ".join(ops)
    before = " OR ".join(ops)
    trigger = "trg_forbid_mutation" if "DELETE" in ops else "trg_forbid_update"
    label = "UPDATE_DELETE: forbidden → barrera física (append-only)" if "DELETE" in ops \
        else "UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)"
    return (f"-- {label}\n"
            f"REVOKE {ops_sql} ON {t} FROM PUBLIC;\n"
            f'DROP TRIGGER IF EXISTS {trigger} ON {t};\n'
            f"CREATE TRIGGER {trigger} BEFORE {before} ON {t}\n"
            f'    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();\n')


# ------------------------------------------------------------------ 05_constraints por dueño
PROSA = "en prosa; el módulo 33 no declara su expresión SQL"


def unique_indexes(sch, tbl):
    """Nombres de los índices UNIQUE que `04_indexes.sql` ya crea sobre la tabla.

    Sólo se listan: emparejarlos con una regla en prosa sería adivinar columnas.
    Le dicen al lector qué unicidad física existe al lado de la regla textual."""
    folder = owner_folder(sch)
    path = folder / "04_indexes.sql" if folder else None
    if not path or not path.exists():
        return []
    pat = re.compile(r'^CREATE UNIQUE INDEX IF NOT EXISTS "([^"]+)" ON "'
                     + re.escape(sch) + r'"\."' + re.escape(tbl) + r'"', re.MULTILINE)
    return pat.findall(path.read_text(encoding="utf-8"))


def rule_line(sch, tbl, k, v, concrete=()):
    """Una regla de la matriz como línea de 05_constraints (comentario o SQL concreto)."""
    if k in ("PK", "VERSION"):
        return f"--   {k}: {v}  (ya en 02_tables/04_indexes)"
    if k == "UK":
        return f"--   UK: {v}  ({PROSA})"
    if k in ("CHECK", "EXCLUDE"):
        extra = f"; ver {k}_SQL abajo" if f"{k}_SQL" in concrete else ""
        return f"--   {k}: {v}  ({PROSA}{extra})"
    if k == "CHECK_SQL":
        return concrete_check(sch, tbl, v)
    if k == "EXCLUDE_SQL":
        return exclude_concreto(sch, tbl, v)
    return f"--   {k}: {v}"


def concrete_check(schema, table, declaration):
    """Materializa un CHECK cuya expresión exacta ya declara el modelo."""
    parts = [part.strip() for part in declaration.split("|", 1)]
    if len(parts) != 2 or not parts[1]:
        raise ValueError(f"CHECK_SQL inválido en {schema}.{table}: nombre | expresión requerido")
    name, expression = parts
    if not re.fullmatch(r"[a-z_][a-z0-9_]*", name) or len(name.encode("utf-8")) > 63:
        raise ValueError(f"CHECK_SQL inválido en {schema}.{table}: nombre de constraint {name!r}")
    target = f'"{schema}"."{table}"'
    return (f"-- CHECK concreto declarado por el modelo (CHECK_SQL).\n"
            f'ALTER TABLE {target} DROP CONSTRAINT IF EXISTS "{name}";\n'
            f'ALTER TABLE {target} ADD CONSTRAINT "{name}" CHECK ({expression});\n')


def escape_table_cell(value):
    return value.replace("|", r"\|")


EXCLUDE_DEFERRABILITY = frozenset({
    "DEFERRABLE", "DEFERRABLE INITIALLY IMMEDIATE", "DEFERRABLE INITIALLY DEFERRED", "NOT DEFERRABLE",
})


def exclude_concreto(schema, table, decl):
    """Un EXCLUDE con la expresión que el MODELO declara, no una inventada.

    `EXCLUDE : <prosa>` sale como comentario con la regla textual, porque el modelo
    la declara en palabras y completarla sería adivinar columnas. `EXCLUDE_SQL` es
    la otra mitad: el modelo ya trae la expresión exacta y acá sólo se la
    envuelve. Temperatura-0 intacta — este generador no compone ningún predicado.

    Formato de la declaración, separado por `|`:

        <nombre> | <elementos gist> | <predicado> | <diferibilidad>

    El predicado es opcional: sin él sale un EXCLUDE total (`<nombre> | <elementos>` o, si hace
    falta la cuarta parte, con el predicado vacío: `<nombre> | <elementos> | | DEFERRABLE`).
    La diferibilidad también es opcional y es una de `DEFERRABLE`,
    `DEFERRABLE INITIALLY IMMEDIATE`, `DEFERRABLE INITIALLY DEFERRED` o `NOT DEFERRABLE`
    (por omisión, la de PostgreSQL: no diferible). Hace falta cuando un traslado debe cerrar un
    período y abrir otro dentro de una misma transacción en cualquier orden
    (`SET CONSTRAINTS … DEFERRED`), caso de `clinical.encounter_locations` (F3). Una tabla con
    restricciones diferibles no admite `INSERT … ON CONFLICT DO NOTHING` sin objetivo.

    Los `concept_id` van como UUID literales y no como llamada a función, porque el predicado de
    un EXCLUDE tiene que ser inmutable. Es la lección de
    `gist_appointments_practitioner_time`, que quedó comentado justamente por
    llamar a funciones que nunca se definieron.
    """
    partes = [p.strip() for p in decl.split("|")]
    if len(partes) < 2:
        return f"--   EXCLUDE_SQL mal declarado (faltan partes): {decl}"
    if len(partes) > 4:
        return f"--   EXCLUDE_SQL mal declarado (sobran partes; un `|` dentro de la expresión): {decl}"
    nombre, elementos = partes[0], partes[1]
    predicado = partes[2] if len(partes) > 2 and partes[2] else None
    diferible = partes[3].upper() if len(partes) > 3 and partes[3] else None
    if diferible is not None and diferible not in EXCLUDE_DEFERRABILITY:
        return (f"--   EXCLUDE_SQL con diferibilidad desconocida ({partes[3]!r}); "
                f"admitidas: {', '.join(sorted(EXCLUDE_DEFERRABILITY))}: {decl}")
    where = f" WHERE ({predicado})" if predicado else ""
    defer = f" {diferible}" if diferible else ""
    t = f'"{schema}"."{table}"'
    return (f"-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).\n"
            f"ALTER TABLE {t} DROP CONSTRAINT IF EXISTS \"{nombre}\";\n"
            f"ALTER TABLE {t} ADD CONSTRAINT \"{nombre}\"\n"
            f"    EXCLUDE USING gist ({elementos}){where}{defer};\n")


def entity_block(e):
    """Las líneas de 05_constraints de una entidad de la matriz, guard incluido."""
    sch, tbl = e["owner"]
    lines = [f"\n-- ═══ {tbl} ═══"]
    concrete = {k for k, _ in e["rules"] if k.endswith("_SQL")}
    lines += [rule_line(sch, tbl, k, v, concrete) for k, v in e["rules"]]
    uniques = unique_indexes(sch, tbl) if any(k == "UK" for k, _ in e["rules"]) else []
    if uniques:
        lines.append(f"--   índices únicos que la tabla ya tiene en 04_indexes: {', '.join(uniques)}")
    forbidden = any(k == "UPDATE_DELETE" and "forbid" in v.lower() for k, v in e["rules"])
    # Caso parcial (v4.0.10): `UPDATE : forbidden` sin prohibir DELETE.
    update_only = not forbidden and any(
        k == "UPDATE" and "forbid" in v.lower() for k, v in e["rules"])
    if forbidden:
        lines.append(immutability_guard(sch, tbl))
    elif update_only:
        lines.append(immutability_guard(sch, tbl, ops=("UPDATE",)))
    return lines


def write_constraints(ents):
    by_schema: dict[str, list] = {}
    for e in ents:
        if e["owner"]:
            by_schema.setdefault(e["owner"][0], []).append(e)

    for schema, group in sorted(by_schema.items()):
        folder = owner_folder(schema)
        if not folder:
            print(f"!! sin carpeta SQL para schema {schema}")
            continue
        has_exclude = any(k == "EXCLUDE" for e in group for k, _ in e["rules"])
        out = [f"-- SALUD {gen_ddl.VERSION} · schema {schema} · constraints de integridad (módulo 33)\n"
               "-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.\n"
               "-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:\n"
               "-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).\n"
               "-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.\n"]
        if has_exclude:
            out.append("CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE\n")
        for e in group:
            out.extend(entity_block(e))
        (folder / "05_constraints.sql").write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
        print(f"[{folder.name}] 05_constraints.sql · {len(group)} entidades"
              + (" · btree_gist" if has_exclude else ""))


# ------------------------------------------------------------------ documento matriz
def write_matrix_doc(ents, rels, notes):
    L = [f"# Matriz de integridad y concurrencia — SALUD {gen_ddl.VERSION} (módulo 33)\n",
         "El módulo 33 (`integrity`) **no posee tablas**: es una matriz de verificación "
         "cross-dominio. Cada regla se implementa en la **migración de la tabla dueña** "
         "(su módulo) y se repite aquí como referencia. Extraído fielmente del `.puml`.\n"]
    if "TX_diagram_33_concurrency_and_integrity" in notes:
        L += ["## Política transaccional\n", "```",
              notes["TX_diagram_33_concurrency_and_integrity"], "```\n"]
    if "DB_diagram_33_concurrency_and_integrity" in notes:
        L += ["## Compuertas físicas de base de datos\n", "```",
              notes["DB_diagram_33_concurrency_and_integrity"], "```\n"]

    L.append("## Matriz por módulo dueño\n")
    by_owner: dict[str, list] = {}
    for e in ents:
        key = f"{e['owner'][0]}" if e["owner"] else "(sin resolver)"
        by_owner.setdefault(key, []).append(e)
    for schema, group in sorted(by_owner.items()):
        folder = owner_folder(schema)
        mod = folder.name.split("_")[0] if folder else "??"
        L.append(f"### Módulo {mod} · `{schema}`\n")
        L.append("| Tabla | Estereotipo | Reglas declaradas |")
        L.append("|-------|-------------|-------------------|")
        for e in group:
            rules = "; ".join(f"**{k}** {escape_table_cell(v)}" for k, v in e["rules"])
            L.append(f"| `{e['name']}` | `{e['stereo']}` | {rules} |")
        L.append("")

    if rels:
        L.append("## Relaciones de integridad declaradas\n")
        for a, b, lab in rels:
            L.append(f"- `{a}` → `{b}` — {lab}")
        L.append("")
    L += ["## Cómo se materializa\n",
          "- **`SQL/_integrity/00_integrity_functions.sql`** — schema `integrity` + "
          "`forbid_mutation()` (guarda de inmutabilidad).",
          "- **`SQL/<NN>_<schema>/05_constraints.sql`** — por módulo dueño: guarda concreta "
          "para `UPDATE_DELETE: forbidden`, `CHECK_SQL` y `EXCLUDE_SQL`; las UK/CHECK/EXCLUDE en "
          "prosa quedan como comentario con la regla textual (el modelo no declara su "
          "expresión SQL) y la lista de índices únicos que la tabla ya tiene.",
          "- **Concurrencia** (`LOCK`/`SERIALIZABLE`/`SKIP LOCKED`/outbox) → capa de servicio "
          "(MikroORM Unit of Work + retry en `SQLSTATE 40001`), ver orm-mapping-guide §0.\n"]
    (OUT / "integrity-matrix.md").write_text("\n".join(L), encoding="utf-8")
    print(f"→ integrity-matrix.md · {len(ents)} entidades · {len(rels)} relaciones")


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    codes = sorted({p.stem.split("_")[1] for p in PUML_DIR.glob("diagram_*.puml")})
    registry = gen_ddl.build_registry(codes)
    ents, rels, notes = parse_module33()
    resolve_owners(ents, registry)
    write_functions()
    write_constraints(ents)
    write_matrix_doc(ents, rels, notes)


if __name__ == "__main__":
    main()
