#!/usr/bin/env python3
"""
gen_entities.py — Genera entidades MikroORM (TypeScript) desde el modelo canónico .puml,
para el backend NestJS `mantra-core-health-api`.

Reutiliza el parseo de gen_ddl (misma fuente de verdad que el SQL). Aplica orm-mapping-guide.md:
  - id uuid <<PK>>        → @PrimaryKey
  - row_version : integer → @Version (locking optimista)
  - *_concept_id / FK     → columna uuid @Property + comentario del destino (las relaciones
                            @ManyToOne se agregan luego / por introspección, §2.3)
  - multi-schema          → @Entity({ schema, tableName })
Solo la capa relacional PostgreSQL (los stores NoSQL no se mapean como entidades, §4).

Uso:  python gen_entities.py 01 | all
"""
from __future__ import annotations
import re
import sys

import gen_ddl  # reutiliza parse_module / resolve_fk / build_registry
import paths

REPO = gen_ddl.REPO
PUML_DIR = gen_ddl.PUML_DIR
# Las entidades se escriben en el repositorio de la API, que es hermano de este.
OUT_DIR = paths.API_ENTITIES_DIR


def pascal(name: str) -> str:
    return "".join(p.capitalize() for p in name.split("_"))


def camel(name: str) -> str:
    parts = name.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def class_name(schema: str, table: str, registry: dict) -> str:
    """Nombre de clase único global. MikroORM exige unicidad entre todos los schemas;
    si una tabla existe en más de un schema, se cualifica con el schema para evitar la
    colisión (determinista y estable entre regeneraciones)."""
    homonyms = registry.get(table)
    if homonyms and len(homonyms) > 1:
        return pascal(schema) + pascal(table)
    return pascal(table)


def is_uuid(dtype: str) -> bool:
    return dtype.strip().lower().startswith("uuid")


def map_type(dtype: str):
    """PG type → (tsType, opts:dict) para el decorador de MikroORM."""
    d = dtype.strip()
    if d.endswith("[]"):
        return "string[]", {"type": "'array'"}
    if d.startswith('"terminology"'):
        return "string", {"columnType": "'\"terminology\".\"technical_data_type\"'"}
    base = re.match(r"[a-z_]+", d)
    base = base.group(0) if base else d
    table = {
        "uuid": ("string", {"type": "'uuid'"}),
        # El tipo declarado se conserva entero: `varchar(200)` NO es `varchar`.
        # Descartar la longitud hacía que el ORM viera un tipo más ancho que el de
        # la base y propusiera un ALTER de ensanche en cada dry-run (deriva nueva
        # destapada en v4.0.10 con authz.patient_legal_representations.document_ref).
        "varchar": ("string", {"columnType": f"'{d}'"}),
        "text": ("string", {"columnType": "'text'"}),
        "char": ("string", {"columnType": f"'{d}'"}),
        "boolean": ("boolean", {"type": "'boolean'"}),
        "timestamptz": ("Date", {"columnType": "'timestamptz'"}),
        "timestamp": ("Date", {"columnType": "'timestamp'"}),
        "date": ("Date", {"columnType": "'date'"}),
        "time": ("string", {"columnType": "'time'"}),
        "integer": ("number", {"columnType": "'int'"}),
        "smallint": ("number", {"columnType": "'smallint'"}),
        "bigint": ("string", {"type": "'bigint'"}),
        "numeric": ("string", {"columnType": f"'{d}'"}),
        "double": ("number", {"columnType": "'double precision'"}),
        "jsonb": ("unknown", {"type": "'json'", "columnType": "'jsonb'"}),
        "json": ("unknown", {"type": "'json'"}),
        "inet": ("string", {"columnType": "'inet'"}),
        "vector": ("number[]", {"type": "'array'"}),
    }
    return table.get(base, ("string", {"columnType": f"'{d}'"}))


def render_opts(opts: dict) -> str:
    return "{ " + ", ".join(f"{k}: {v}" for k, v in opts.items()) + " }" if opts else ""


def fk_comment(schema, table, col, registry):
    tgt = gen_ddl.resolve_fk(schema, table, col)
    inferred = False
    if tgt is None:
        tgt = gen_ddl.resolve_fk_convention(schema, table, col, registry)
        inferred = tgt is not None
    if tgt is None:
        return "  // FK (destino no resuelto)"
    return f"  // FK → {tgt[0]}.{tgt[1]}{' (inferida)' if inferred else ''}"


def emit_property(schema, table, c, registry) -> list[str]:
    """Líneas de una propiedad: prop camelCase + fieldName a la columna snake_case."""
    ts, opts = map_type(c.dtype)
    prop = camel(c.name)
    if prop != c.name:
        opts = {"fieldName": f"'{c.name}'", **opts}
    if not c.not_null:
        opts = {**opts, "nullable": "true"}
    bang = "!" if c.not_null else "?"

    if c.is_pk and is_uuid(c.dtype):
        return [f"  @PrimaryKey({render_opts(opts)})", f"  {prop}: {ts} = randomUUID();"]
    if c.is_pk:
        return [f"  @PrimaryKey({render_opts(opts)})", f"  {prop}{bang}: {ts};"]
    if c.name == "row_version":
        opts = {**opts, "version": "true"}
        return [f"  @Property({render_opts(opts)})", f"  {prop}{bang}: {ts};"]
    cmt = fk_comment(schema, table, c.name, registry) if c.is_fk else ""
    return [f"  @Property({render_opts(opts)}){cmt}", f"  {prop}{bang}: {ts};"]


CLASS_DOC_KEY = "__class__"


def extract_jsdoc(text: str) -> dict[str, str]:
    """Bloques `/** … */` de una entidad existente, por nombre de propiedad.

    El cuerpo de las entidades lo produce este generador, pero su documentación
    no: el JSDoc templado lo inyecta `tools/documentation/generate-documentation.mjs`
    y hay entidades con prosa escrita a mano (invariantes de seguridad incluidas).
    Reescribir sin preservarla la borra — y ese fue el motivo por el que la
    regeneración estuvo vetada entre v4.0.8 y v4.0.10. La clave es el nombre de
    la propiedad documentada (o CLASS_DOC_KEY para el bloque de la clase), así el
    bloque sobrevive aunque cambien el tipo o las opciones del decorador.
    """
    docs: dict[str, str] = {}
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        if lines[i].lstrip().startswith("/**"):
            start = i
            while "*/" not in lines[i]:
                i += 1
            block = "\n".join(lines[start:i + 1])
            key = _documented_name(lines, i + 1)
            if key:
                docs[key] = block
        i += 1
    return docs


def _documented_name(lines: list[str], j: int) -> str | None:
    """Nombre de la propiedad (o clase) que sigue a un bloque JSDoc.

    Salta los decoradores balanceando paréntesis: un decorador partido por
    Prettier contiene líneas como `fieldName: 'user_id',` que, sin el balance,
    se confundirían con una propiedad.
    """
    depth = 0
    while j < len(lines):
        s = lines[j].strip()
        if not s:
            j += 1
            continue
        if depth > 0 or s.startswith("@"):
            depth += s.count("(") - s.count(")")
            j += 1
            continue
        m = re.match(r"export (?:abstract )?class \w+", s)
        if m:
            return CLASS_DOC_KEY
        m = re.match(r"(\w+)[!?]?\s*[:=]", s)
        return m.group(1) if m else None
    return None


def emit_entity(schema, ent, registry, docs: dict[str, str] | None = None) -> str:
    docs = docs or {}
    has_uuid_pk = any(c.is_pk and is_uuid(c.dtype) for c in ent.columns)
    decorators = ["Entity"]
    if any(c.is_pk for c in ent.columns):
        decorators.append("PrimaryKey")
    if any(not c.is_pk for c in ent.columns):
        decorators.append("Property")
    lines = [f"import {{ {', '.join(decorators)} }} from '@mikro-orm/decorators/legacy';"]
    if has_uuid_pk:
        lines.append("import { randomUUID } from 'node:crypto';")
    lines.append("")
    if CLASS_DOC_KEY in docs:
        lines.append(docs[CLASS_DOC_KEY])
    lines.append(f"@Entity({{ schema: '{schema}', tableName: '{ent.name}' }})")
    lines.append(f"export class {class_name(schema, ent.name, registry)} {{")
    for c in ent.columns:
        doc = docs.get(camel(c.name))
        if doc:
            lines.append(doc)
        lines += emit_property(schema, ent.name, c, registry)
        lines.append("")
    lines.append("}")
    return "\n".join(lines) + "\n"


def emit_module(code, registry):
    puml = next(PUML_DIR.glob(f"diagram_{code}_*.puml"), None)
    if not puml:
        print(f"!! no encontrado diagram_{code}_*.puml")
        return
    schema, entities, *_ = gen_ddl.parse_module(puml)
    if not entities:
        print(f"[{code}] sin entidades relacionales (especializado/no-SQL) — omitido")
        return
    d = OUT_DIR / schema / "entities"
    d.mkdir(parents=True, exist_ok=True)
    barrel = []
    preserved = 0
    for e in entities:
        target = d / f"{e.name}.entity.ts"
        docs = {}
        if target.exists():
            docs = extract_jsdoc(target.read_text(encoding="utf-8"))
            preserved += len(docs)
        out = emit_entity(schema, e, registry, docs)
        # No reescribir lo idéntico: conserva mtimes y deja `git status` limpio.
        if not target.exists() or target.read_text(encoding="utf-8") != out:
            target.write_text(out, encoding="utf-8")
        barrel.append(f"export * from './{e.name}.entity';")
    index = d / "index.ts"
    # El barrel es la UNIÓN de lo generado y lo ya exportado cuyo archivo siga
    # existiendo. Cubre dos casos que este generador no produce: entidades que el
    # .puml no materializa (las 6 tablas fantasma de la deriva conocida, creadas
    # por `orm:entities:missing` desde la bóveda) y los `.types.ts` a mano con los
    # contratos de columnas jsonb (ADR-0022) — descartar unos saca entidades del
    # ORM en silencio; descartar los otros rompe los imports de '../entities'.
    if index.exists():
        for line in index.read_text(encoding="utf-8").splitlines():
            m = re.match(r"export \* from '\./(.+)';", line.strip())
            if m and line.strip() not in barrel and (d / f"{m.group(1)}.ts").exists():
                barrel.append(line.strip())
    index_out = "\n".join(sorted(barrel)) + "\n"
    if not index.exists() or index.read_text(encoding="utf-8") != index_out:
        index.write_text(index_out, encoding="utf-8")
    print(f"[{code}/{schema}] {len(entities)} entidades · {preserved} bloques JSDoc preservados")


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    arg = sys.argv[1] if len(sys.argv) > 1 else "01"
    all_codes = sorted({p.stem.split("_")[1] for p in PUML_DIR.glob("diagram_*.puml")})
    registry = gen_ddl.build_registry(all_codes)
    codes = all_codes if arg == "all" else [f"{int(arg):02d}"]
    for c in codes:
        emit_module(c, registry)


if __name__ == "__main__":
    main()
