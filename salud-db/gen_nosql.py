#!/usr/bin/env python3
"""
gen_nosql.py — Materializa los stores NO relacionales de SALUD v4.0.1 en su formato NATIVO.

Regla temperatura-0: se traduce lo que el .puml declara; lo que no es traducible 1:1 se
documenta (comentario / sidecar), nunca se descarta en silencio.

  55 document_store  → MongoDB    (mongosh: createCollection + $jsonSchema + createIndex)  → .js
  56 redis_runtime   → Redis      (spec de keyspaces: patrón, tipo, TTL, estructuras)       → .md
  57 search_platform → OpenSearch (mappings/settings por índice)                            → .json
  58 time_series     → TimescaleDB(SQL: create_hypertable + retención + BRIN)               → .sql
  59 vector_rag      → pgvector   (SQL: EXTENSION vector + columnas vector + HNSW)           → .sql

Salida en NoSQL/<NN>_<modulo>_<motor>/.  Uso: python gen_nosql.py [all|55|56|57|58|59]
"""
from __future__ import annotations
import json
import re
import sys
from pathlib import Path

import paths

ROOT = paths.MODEL_ROOT / "salud-db"
REPO = paths.MODEL_ROOT
PUML_DIR = paths.PUML_DIR
OUT_DIR = paths.NOSQL_DIR

STORES = {
    "55": ("document_store", "mongodb"),
    "56": ("redis_runtime", "redis"),
    "57": ("search_platform", "opensearch"),
    "58": ("time_series", "timescaledb"),
    "59": ("vector_rag", "pgvector"),
}

COL_RE = re.compile(r"^\s*(\*)?\s*([a-z_][a-z0-9_]*)\s*:\s*(.+?)\s*(<<[^>]+>>)?\s*$", re.IGNORECASE)
ENT_RE = re.compile(r"^entity\s+([a-z_][a-z0-9_]*)\s*(<<[^>]+>>)?\s*\{", re.IGNORECASE)
IDXSET_RE = re.compile(r'^entity\s+"[^"]*"\s+as\s+idxset_([a-z0-9_]+)\s+<<INDEX_SET>>\s*\{', re.IGNORECASE)


class Ent:
    def __init__(self, name, stereos):
        self.name = name
        self.stereos = stereos      # set de estereotipos de la entidad
        self.cols = []              # (name, type, required, colstereos)


def stset(raw):
    return {s.strip().upper() for s in (raw or "").strip("<>").split(",") if s.strip()}


def parse_store(puml: Path):
    lines = puml.read_text(encoding="utf-8").splitlines()
    ents, idx = [], {}
    i, n = 0, len(lines)
    store_stereos = {"MONGODB_COLLECTION", "REDIS_KEYSPACE", "OPENSEARCH_INDEX",
                     "TIMESERIES_MEASUREMENT", "VECTOR_STORE"}
    while i < n:
        line = lines[i]
        ism = IDXSET_RE.match(line.strip())
        if ism:
            table, raw = ism.group(1), []
            i += 1
            while i < n and lines[i].strip() != "}":
                if lines[i].strip():
                    raw.append(lines[i].strip())
                i += 1
            idx[table] = raw
            i += 1
            continue
        em = ENT_RE.match(line.strip())
        if em and (stset(em.group(2)) & store_stereos):
            e = Ent(em.group(1), stset(em.group(2)))
            i += 1
            while i < n and lines[i].strip() != "}":
                cl = lines[i].strip()
                if cl and cl != "--" and not cl.startswith("'"):
                    cm = COL_RE.match(lines[i])
                    if cm:
                        e.cols.append((cm.group(2), cm.group(3).strip(),
                                       cm.group(1) == "*", stset(cm.group(4))))
                i += 1
            ents.append(e)
            i += 1
            continue
        i += 1
    return ents, idx


def module_dir(code):
    name, engine = STORES[code]
    d = OUT_DIR / f"{code}_{name}_{engine}"
    d.mkdir(parents=True, exist_ok=True)
    return d, name, engine


def parse_idx(raw):
    """Divide 'KIND name : spec' → (KIND, name, spec)."""
    m = re.match(r"^([A-Z_]+)\s+([a-z_][a-z0-9_]*)\s*:\s*(.*)$", raw)
    return (m.group(1), m.group(2), m.group(3).strip()) if m else (None, None, raw)


def split_cols(spec):
    """'(a ASC, b DESC)' o 'a, b' o 'a + b' → [('a','ASC'),('b','DESC')].
    Si la spec trae sufijo de método ('(metadata) GIN'), se toma solo el grupo
    entre paréntesis — antes el ')' interno contaminaba el nombre de columna."""
    spec = spec.strip()
    m = re.match(r"\(([^)]*)\)", spec)
    spec = m.group(1) if m else spec.lstrip("(").rstrip(")")
    parts = re.split(r"\s*[,+]\s*", spec)
    out = []
    for p in parts:
        t = p.split()
        if not t:
            continue
        d = t[1].upper() if len(t) > 1 and t[1].upper() in ("ASC", "DESC") else None
        out.append((t[0], d))
    return out


# ----------------------------------------------------------------- MongoDB (55)
BSON = {"objectid": "objectId", "uuid": "binData", "varchar": "string", "char": "string",
        "text": "string", "datetime": "date", "date": "date", "boolean": "bool",
        "integer": "int", "bigint": "long", "long": "long", "double": "double",
        "object": "object", "array": "array", "nested": "array", "flattened": "object",
        "jsonb": "object"}


def emit_mongo(code):
    d, name, _ = module_dir(code)
    ents, idx = parse_store(next(PUML_DIR.glob(f"diagram_{code}_*.puml")))
    out = [f"// SALUD v4.0.1 · módulo {code} {name} · MongoDB (mongosh) — generado de los .puml\n"]
    for e in ents:
        required = [c[0] for c in e.cols if c[2] and c[0] != "_id"]
        props = {}
        for cname, ctype, _req, _st in e.cols:
            base = re.match(r"[a-z_]+", ctype.lower())
            props[cname] = {"bsonType": BSON.get(base.group(0) if base else "", "string")}
        validator = {"$jsonSchema": {"bsonType": "object", "required": required, "properties": props}}
        out.append(f'db.createCollection("{e.name}", ' + json.dumps({"validator": validator}, ensure_ascii=False, indent=2) + ");\n")
        for raw in idx.get(e.name, []):
            kind, iname, spec = parse_idx(raw)
            if kind is None:
                continue
            unique = "UNIQUE" in spec.upper()
            keys = {}
            for col, dir_ in split_cols(re.sub(r"\b(UNIQUE|PARTIAL|exists)\b.*", "", spec)):
                keys[col] = -1 if dir_ == "DESC" else ("text" if kind == "TEXT" else 1)
            opts = {"name": iname}
            if unique:
                opts["unique"] = True
            pm = re.search(r"PARTIAL\s+([a-z_]+)\s+exists", spec, re.IGNORECASE)
            if pm:
                opts["partialFilterExpression"] = {pm.group(1): {"$exists": True}}
            em2 = re.search(r"expireAfterSeconds\s*=\s*(\d+)", spec)
            if em2 or kind == "TTL":
                opts["expireAfterSeconds"] = int(em2.group(1)) if em2 else 0
            if not keys:
                continue
            out.append(f"db.{e.name}.createIndex(" + json.dumps(keys, ensure_ascii=False)
                       + ", " + json.dumps(opts, ensure_ascii=False) + ");")
        out.append("")
    (d / f"{name}.mongodb.js").write_text("\n".join(out), encoding="utf-8")
    print(f"[{code}/{name}] MongoDB · {len(ents)} colecciones")


# ----------------------------------------------------------------- Redis (56)
def emit_redis(code):
    d, name, _ = module_dir(code)
    ents, idx = parse_store(next(PUML_DIR.glob(f"diagram_{code}_*.puml")))
    out = [f"# SALUD v4.0.1 · módulo {code} {name} · Redis keyspaces (spec)\n",
           "Redis es schemaless: esto documenta el **diseño de claves** (patrón, tipo, TTL, "
           "estructuras y políticas) tal como lo declara el modelo. No es DDL ejecutable.\n"]
    for e in ents:
        out.append(f"## `{e.name}`\n")
        out.append("| campo | definición |\n|---|---|")
        for cname, ctype, req, _st in e.cols:
            out.append(f"| {'**'+cname+'**' if req else cname} | {ctype} |")
        struct = idx.get(e.name, [])
        if struct:
            out.append("\n**Estructuras y políticas:**")
            for raw in struct:
                kind, iname, spec = parse_idx(raw)
                out.append(f"- `{kind or ''}` {iname or ''}: {spec}")
        out.append("")
    (d / f"{name}.keyspaces.md").write_text("\n".join(out), encoding="utf-8")
    print(f"[{code}/{name}] Redis · {len(ents)} keyspaces")


# ----------------------------------------------------------------- OpenSearch (57)
ES = {"keyword": "keyword", "text": "text", "date": "date", "long": "long",
      "integer": "integer", "short": "short", "boolean": "boolean", "double": "double",
      # "flattened" es vocabulario Elasticsearch; el tipo nativo OpenSearch es flat_object
      "float": "float", "nested": "nested", "flattened": "flat_object", "object": "object",
      "geo_point": "geo_point", "uuid": "keyword", "varchar": "keyword"}


def emit_opensearch(code):
    d, name, _ = module_dir(code)
    ents, idx = parse_store(next(PUML_DIR.glob(f"diagram_{code}_*.puml")))
    notes = [f"# SALUD v4.0.1 · módulo {code} {name} · OpenSearch\n",
             "Un `.json` por índice con `mappings`. Config extra (routing/alias/pattern/"
             "lifecycle) documentada aquí por índice.\n"]
    for e in ents:
        props = {}
        for cname, ctype, _req, _st in e.cols:
            if cname == "_id":  # metadato reservado: OpenSearch rechaza mapearlo
                continue
            base = re.match(r"[a-z_]+", ctype.lower())
            props[cname] = {"type": ES.get(base.group(0) if base else "", "keyword")}
        body = {"mappings": {"properties": props}}
        (d / f"{e.name}.mapping.json").write_text(json.dumps(body, ensure_ascii=False, indent=2), encoding="utf-8")
        extra = [parse_idx(r) for r in idx.get(e.name, [])]
        extra = [(k, iname, s) for (k, iname, s) in extra if k in
                 ("ROUTING", "ALIAS", "PATTERN", "PREFIX", "SORT", "FILTER", "LIFECYCLE", "POLICY")]
        if extra:
            notes.append(f"## `{e.name}`")
            for k, iname, s in extra:
                notes.append(f"- **{k}** {iname}: {s}")
            notes.append("")
    (d / f"{name}.index-config.md").write_text("\n".join(notes), encoding="utf-8")
    print(f"[{code}/{name}] OpenSearch · {len(ents)} índices")


# ----------------------------------------------------------------- PG types (58/59)
PG = {"double": "double precision", "map": "jsonb"}
PG_KNOWN = {"uuid", "varchar", "text", "timestamptz", "timestamp", "date", "time", "boolean",
            "integer", "bigint", "smallint", "numeric", "jsonb", "json", "char", "inet",
            "double precision", "vector"}


# Dimensión física de los embeddings cuando el modelo declara `vector` sin dimensión.
# Decisión de materialización documentada (physical-materialization.md / BD viva):
# HNSW exige dimensión fija; el build usa 1536.
VECTOR_DIM_DEFAULT = 1536


def pg_type(ctype):
    rt = ctype.lower().replace(" ", "")
    base = re.match(r"[a-z_]+", rt).group(0)
    suffix = rt[len(base):]
    base = PG.get(base, base)
    if base == "vector" and not suffix:
        suffix = f"({VECTOR_DIM_DEFAULT})"
    return (base + suffix) if base in PG_KNOWN else None


def emit_pg_table(schema, e, warnings):
    cols = []
    for cname, ctype, req, _st in e.cols:
        t = pg_type(ctype)
        if t is None:
            warnings.append(f"{e.name}.{cname}: tipo '{ctype}' no mapeable (omitido)")
            continue
        cols.append(f'    "{cname}" {t}{" NOT NULL" if req else ""}')
    pk = [c[0] for c in e.cols if "PK" in c[3]]
    body = ",\n".join(cols)
    if pk:
        body += f',\n    CONSTRAINT "pk_{e.name}" PRIMARY KEY ({", ".join(chr(34)+c+chr(34) for c in pk)})'
    return f'CREATE TABLE IF NOT EXISTS "{schema}"."{e.name}" (\n{body}\n);\n'


# ----------------------------------------------------------------- TimescaleDB (58)
def emit_timescale(code):
    d, name, _ = module_dir(code)
    ents, idx = parse_store(next(PUML_DIR.glob(f"diagram_{code}_*.puml")))
    warnings = []
    sql = [f"-- SALUD v4.0.1 · módulo {code} {name} · TimescaleDB — generado de los .puml\n",
           'CREATE EXTENSION IF NOT EXISTS timescaledb;\n',
           f'CREATE SCHEMA IF NOT EXISTS "{name}";\n']
    idx_sql, adv = [], []
    for e in ents:
        sql.append(emit_pg_table(name, e, warnings))
        for raw in idx.get(e.name, []):
            kind, iname, spec = parse_idx(raw)
            t = f'"{name}"."{e.name}"'
            if kind == "PARTITION":
                cm = re.search(r"chunk\s*=\s*([0-9]+)\s*([a-z]+)", spec)
                iv = f"{cm.group(1)} {cm.group(2)}" if cm else "1 day"
                idx_sql.append(f"SELECT create_hypertable('{name}.{e.name}', 'time', "
                               f"chunk_time_interval => INTERVAL '{iv}', if_not_exists => TRUE);")
                sp = re.search(r"space\s*=\s*([a-z_]+)", spec)
                if sp:
                    idx_sql.append(f"SELECT add_dimension('{name}.{e.name}', '{sp.group(1)}', "
                                   f"number_partitions => 4, if_not_exists => TRUE);")
            elif kind in ("ORDER", "IX"):
                cols = ", ".join(f'"{c}"' + (f" {dd}" if dd else "") for c, dd in split_cols(spec))
                idx_sql.append(f'CREATE INDEX IF NOT EXISTS "{iname}" ON {t} ({cols});')
            elif kind == "UK":
                # TimescaleDB: todo índice UNIQUE de una hypertable debe incluir la
                # columna de particionado ('time', la misma que usa create_hypertable).
                names = [c for c, _ in split_cols(spec)]
                if "time" not in names:
                    names.append("time")
                cols = ", ".join(f'"{c}"' for c in names)
                idx_sql.append(f'CREATE UNIQUE INDEX IF NOT EXISTS "{iname}" ON {t} ({cols});')
            elif kind == "BRIN":
                cols = ", ".join(f'"{c}"' for c, _ in split_cols(spec))
                idx_sql.append(f'CREATE INDEX IF NOT EXISTS "{iname}" ON {t} USING brin ({cols});')
            else:   # RETENTION / COMPRESSION / ROLLUP / SKIP / POLICY / GEO → documentado
                adv.append(f"-- {kind} {iname} en {e.name}: {spec}")
    body = sql + ["\n-- Hypertables e índices\n"] + idx_sql
    if adv:
        body += ["\n-- Políticas avanzadas (definir intervalos/config concretos):\n"] + adv
    if warnings:
        body += ["\n-- Avisos:"] + [f"--   {w}" for w in warnings]
    (d / f"{name}.timescaledb.sql").write_text("\n".join(body) + "\n", encoding="utf-8")
    print(f"[{code}/{name}] TimescaleDB · {len(ents)} measurements"
          + (f" · {len(warnings)} avisos" if warnings else ""))


# ----------------------------------------------------------------- pgvector (59)
def emit_pgvector(code):
    d, name, _ = module_dir(code)
    ents, idx = parse_store(next(PUML_DIR.glob(f"diagram_{code}_*.puml")))
    warnings = []
    sql = [f"-- SALUD v4.0.1 · módulo {code} {name} · pgvector — generado de los .puml\n",
           'CREATE EXTENSION IF NOT EXISTS vector;\n',
           f'CREATE SCHEMA IF NOT EXISTS "{name}";\n']
    idx_sql = []
    for e in ents:
        sql.append(emit_pg_table(name, e, warnings))
        for raw in idx.get(e.name, []):
            kind, iname, spec = parse_idx(raw)
            t = f'"{name}"."{e.name}"'
            cols = ", ".join(f'"{c}"' for c, _ in split_cols(spec))
            if kind == "PK":
                continue
            elif kind == "UK":
                idx_sql.append(f'CREATE UNIQUE INDEX IF NOT EXISTS "{iname}" ON {t} ({cols});')
            elif kind == "IX":
                idx_sql.append(f'CREATE INDEX IF NOT EXISTS "{iname}" ON {t} ({cols});')
            elif kind == "GIN":
                idx_sql.append(f'CREATE INDEX IF NOT EXISTS "{iname}" ON {t} USING gin ({cols});')
            elif kind == "HNSW":
                col = split_cols(spec)[0][0]
                idx_sql.append(f'CREATE INDEX IF NOT EXISTS "{iname}" ON {t} '
                               f'USING hnsw ("{col}" vector_cosine_ops);  -- ajustar ops según distance_metric')
    body = sql + ["\n-- Índices\n"] + idx_sql
    if warnings:
        body += ["\n-- Avisos:"] + [f"--   {w}" for w in warnings]
    (d / f"{name}.pgvector.sql").write_text("\n".join(body) + "\n", encoding="utf-8")
    print(f"[{code}/{name}] pgvector · {len(ents)} tablas"
          + (f" · {len(warnings)} avisos" if warnings else ""))


EMIT = {"55": emit_mongo, "56": emit_redis, "57": emit_opensearch,
        "58": emit_timescale, "59": emit_pgvector}


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    arg = sys.argv[1] if len(sys.argv) > 1 else "all"
    codes = list(STORES) if arg == "all" else [arg]
    for c in codes:
        EMIT[c](c)


if __name__ == "__main__":
    main()
