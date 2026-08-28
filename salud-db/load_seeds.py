#!/usr/bin/env python3
"""load_seeds.py — deployment job de seeds SALUD v4.0.1 (seedsGenerales + seedsProd).

Carga cada paquete en el store que corresponde (stack Docker `mantra-redesa`):
  1. seedsGenerales boot 03_terminology (value sets del sistema — todo *_concept_id apunta acá)
  2. resto de boot por módulo 00→63 (PG; el boot del 57 va a OpenSearch)
  3. seedsProd: 15 recs inline + 30 shards MeSH (1 shard = 1 transacción, batch 5000)
  4. mock (hard-fail si NODE_ENV=production): PG 00→63, 55→Mongo, 56→Redis, 57→OpenSearch
  5. post-load: verify counts declarados, verify FKs (huérfanos), ANALYZE (load-plan.json)

Idempotente: ON CONFLICT (pk) DO NOTHING (uuid5 determinista); hypertables sin PK van
por INSERT ... WHERE NOT EXISTS. Re-ejecutar produce 0 filas nuevas.

Uso:  python load_seeds.py [--skip-prod] [--skip-mock] [--only NN]
"""
import argparse
import hashlib
import json
import re
import sys
import urllib.request
from pathlib import Path

import psycopg
from psycopg.types.json import Jsonb

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

import paths

# `ROOT` es el repositorio del modelo; la API es hermana suya. Ver `paths.py`.
ROOT = paths.MODEL_ROOT
GENERALES_DIR = paths.SEEDS_MODULES_DIR
PROD_DIR = paths.SEEDS_PROD_DIR
API_ENV_FILE = paths.API_ENV_FILE

BATCH_SIZE = 5000          # seedsProd/load-plan.json batch_size
MAX_TX_ATTEMPTS = 3        # seedsProd/load-plan.json retry_policy.max_attempts
RETRYABLE_SQLSTATES = {"40001", "40P01"}
VECTOR_DIMENSIONS = 1536   # vector_rag.vector_embeddings.embedding vector(1536)

MONGO_MODULE, REDIS_MODULE, OPENSEARCH_MODULE = "55", "56", "57"
ANALYZE_AFTER_LOAD = [     # seedsProd/load-plan.json post_load
    "terminology.catalog_concepts", "terminology.concept_designations",
    "terminology.concept_relationships", "terminology.concept_maps",
]


# ----------------------------------------------------------------- config (.env de la API)
def load_config():
    cfg = {}
    for line in API_ENV_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        cfg[key.strip()] = value.split(" #")[0].strip()
    return cfg


# ----------------------------------------------------------------- reporte
class Report:
    def __init__(self):
        self.rows = []          # (destino, entidad, insertados, ya_existian, nota)
        self.warnings = []
        self.touched_tables = set()   # (schema, table) tocadas en PG

    def add(self, target, entity, inserted, existing, note=""):
        self.rows.append((target, entity, inserted, existing, note))

    def warn(self, message):
        self.warnings.append(message)
        print(f"    AVISO: {message}")

    def print_summary(self):
        print("\n══ Resumen de carga ══")
        total_ins = total_old = 0
        for target, entity, inserted, existing, note in self.rows:
            if inserted or existing or note:
                suffix = f"  [{note}]" if note else ""
                print(f"  {target:<12} {entity:<42} +{inserted:<7} ya:{existing:<7}{suffix}")
            total_ins += inserted
            total_old += existing
        print(f"  TOTAL insertados: {total_ins} · ya existentes: {total_old}")
        if self.warnings:
            print(f"\n  Avisos ({len(self.warnings)}):")
            for w in self.warnings:
                print(f"    - {w}")


# ----------------------------------------------------------------- PostgreSQL
def connect_pg(cfg):
    conn = psycopg.connect(
        host=cfg["POSTGRES_HOST"], port=cfg["POSTGRES_PORT"], user=cfg["POSTGRES_USER"],
        password=cfg["POSTGRES_PASSWORD"], dbname=cfg["POSTGRES_DB"],
    )
    # Las 6k FKs cross-módulo impiden un orden topológico entre módulos: se carga con
    # enforcement deshabilitado y se verifican huérfanos al final (load-plan: verify_foreign_keys).
    conn.execute("SET session_replication_role = replica")
    conn.commit()
    return conn


def resolve_table(conn, schema_hint, entity):
    """Destino real de una entidad: schema del módulo, o match único global, o None."""
    if conn.execute("SELECT to_regclass(%s)", (f'"{schema_hint}"."{entity}"',)).fetchone()[0]:
        return schema_hint, entity
    rows = conn.execute(
        "SELECT table_schema FROM information_schema.tables"
        " WHERE table_name = %s AND table_schema NOT IN ('pg_catalog', 'information_schema')",
        (entity,),
    ).fetchall()
    if len(rows) == 1:
        return rows[0][0], entity
    return None


def primary_key_columns(conn, schema, table):
    rows = conn.execute(
        "SELECT a.attname FROM pg_index i"
        " JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)"
        " WHERE i.indrelid = %s::regclass AND i.indisprimary",
        (f'"{schema}"."{table}"',),
    ).fetchall()
    return [r[0] for r in rows]


def adapt_value(column, value, column_type=""):
    if column == "embedding" and isinstance(value, list):
        padded = value + [0.0] * (VECTOR_DIMENSIONS - len(value))
        return str(padded)
    if isinstance(value, list) and column_type.endswith("[]"):
        return value  # psycopg lo adapta a array PG (el placeholder castea al tipo real)
    if isinstance(value, (dict, list)):
        return Jsonb(value)  # el resto de columnas JSON del DDL son jsonb
    return value


def column_types(conn, schema, table):
    rows = conn.execute(
        "SELECT a.attname, format_type(a.atttypid, a.atttypmod) FROM pg_attribute a"
        " WHERE a.attrelid = %s::regclass AND a.attnum > 0 AND NOT a.attisdropped",
        (f'"{schema}"."{table}"',),
    ).fetchall()
    return dict(rows)


def not_null_without_default(conn, schema, table):
    rows = conn.execute(
        "SELECT column_name FROM information_schema.columns"
        " WHERE table_schema = %s AND table_name = %s"
        "   AND is_nullable = 'NO' AND column_default IS NULL",
        (schema, table),
    ).fetchall()
    return {r[0] for r in rows}


def upsert_sql(target, col_list, placeholders, columns, pk, refresh):
    """INSERT idempotente. Con `refresh`, el conflicto de PK actualiza la fila.

    Sin target de conflicto se absorben también los uniques naturales (los seeds traen
    duplicados de clave natural con id distinto); con target solo cuenta la PK."""
    head = f"INSERT INTO {target} ({col_list}) VALUES ({placeholders})"
    sets = ", ".join(f'"{c}" = EXCLUDED."{c}"' for c in columns if c not in pk)
    if refresh and sets:
        pk_list = ", ".join(f'"{c}"' for c in sorted(pk))
        return f"{head} ON CONFLICT ({pk_list}) DO UPDATE SET {sets}"
    return f"{head} ON CONFLICT DO NOTHING"


def insert_records(conn, schema, table, records, report, refresh=False):
    """Inserta un lote de forma idempotente. Devuelve (insertados, ya_existían, saltados).

    Se agrupa por conjunto de columnas presentes: las ausentes toman el DEFAULT de la
    tabla en vez de NULL explícito. Records sin una columna NOT NULL sin default son
    defecto del paquete → se saltan con aviso (no se inventan valores).

    Con `refresh=True` el conflicto de PK actualiza la fila en vez de ignorarla: el
    paquete de seeds pasa a ser la autoridad y una corrección del generador llega a
    una base ya cargada. Sin él (por defecto) una fila ya insertada nunca se toca."""
    target = f'"{schema}"."{table}"'
    pk = primary_key_columns(conn, schema, table)
    required = not_null_without_default(conn, schema, table)
    types = column_types(conn, schema, table)

    groups = {}
    for rec in records:
        groups.setdefault(frozenset(rec), []).append(rec)

    inserted = skipped = 0
    with conn.cursor() as cur:
        for key_set, group in groups.items():
            missing = required - key_set
            if missing:
                skipped += len(group)
                report.warn(f"{schema}.{table}: {len(group)} recs sin NOT NULL {sorted(missing)}"
                            " — saltados (TODO: defecto del paquete de seeds)")
                continue
            columns = sorted(key_set)
            col_list = ", ".join(f'"{c}"' for c in columns)
            # Las columnas array llevan cast explícito: los seeds traen listas JSON y
            # psycopg las envía como text[] (ej. text[] → uuid[]).
            placeholders = ", ".join(
                f"%s::{types[c]}" if types.get(c, "").endswith("[]") else "%s" for c in columns)
            params = [tuple(adapt_value(c, rec[c], types.get(c, "")) for c in columns)
                      for rec in group]
            if pk:
                sql = upsert_sql(target, col_list, placeholders, columns, pk,
                                 refresh and set(pk) <= key_set)
            else:
                # Hypertables (time_series) no tienen PK: identidad = columnas provistas.
                # El cast al tipo real de la columna hace que la comparación vea lo que la
                # tabla almacenaría (ej. float 335.25 → integer 335), o el re-run duplica.
                match = " AND ".join(f'"{c}" IS NOT DISTINCT FROM %s::{types[c]}' for c in columns)
                sql = (f"INSERT INTO {target} ({col_list}) SELECT {placeholders}"
                       f" WHERE NOT EXISTS (SELECT 1 FROM {target} WHERE {match})")
                params = [p * 2 for p in params]
            for start in range(0, len(params), BATCH_SIZE):
                cur.executemany(sql, params[start:start + BATCH_SIZE])
                inserted += cur.rowcount
    report.touched_tables.add((schema, table))
    return inserted, len(records) - inserted - skipped, skipped


def run_module_transaction(conn, action):
    """Un módulo/shard = una transacción; retry solo ante SQLSTATE transitorios."""
    for attempt in range(1, MAX_TX_ATTEMPTS + 1):
        try:
            with conn.transaction():
                return action()
        except psycopg.errors.Error as exc:
            transient = exc.sqlstate in RETRYABLE_SQLSTATES
            if not transient or attempt == MAX_TX_ATTEMPTS:
                raise
            print(f"    reintento {attempt} tras {exc.sqlstate}")


# ----------------------------------------------------------------- enum technical_data_type
def ensure_enum_values(conn, report, only=None):
    """El único enum nativo del modelo quedó vacío en el DDL (valores TODO, no estaban en el
    contexto); los seeds traen valores → se agregan aditiva e idempotentemente antes de cargar."""
    enum_columns = conn.execute(
        "SELECT table_name, column_name FROM information_schema.columns"
        " WHERE udt_schema = 'terminology' AND udt_name = 'technical_data_type'").fetchall()
    targets = {}
    for table, column in enum_columns:
        targets.setdefault(table, set()).add(column)

    needed = set()
    for path in module_files(only):
        data = json.loads(path.read_text(encoding="utf-8"))
        for phase in ("boot", "mock"):
            for entity, records in data[phase]["records"].items():
                for column in targets.get(entity, ()):
                    needed.update(r[column] for r in records if isinstance(r.get(column), str))

    existing = {label for (label,) in conn.execute(
        "SELECT e.enumlabel FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid"
        " JOIN pg_namespace n ON n.oid = t.typnamespace"
        " WHERE n.nspname = 'terminology' AND t.typname = 'technical_data_type'")}
    missing = sorted(needed - existing)
    for value in missing:
        escaped = value.replace("'", "''")
        conn.execute(f"ALTER TYPE \"terminology\".\"technical_data_type\" ADD VALUE IF NOT EXISTS '{escaped}'")
    conn.commit()
    if missing:
        report.warn(f"technical_data_type: {len(missing)} valores agregados desde los seeds"
                    " (placeholders sintéticos — vocabulario canónico §3.2 sigue TODO)")


# ----------------------------------------------------------------- seedsGenerales (PG)
def module_files(only=None):
    files = sorted(GENERALES_DIR.glob("*.seeds.json"))
    if only:
        files = [f for f in files if f.name.startswith(f"{only}_")]
    return files


def module_number_and_schema(path):
    number, code = re.match(r"(\d+)_(.+)\.seeds\.json", path.name).groups()
    return number, code


def load_module_phase(conn, path, phase, report, refresh=False):
    """Carga la fase boot|mock de un módulo de seedsGenerales en PG."""
    _, schema_hint = module_number_and_schema(path)
    data = json.loads(path.read_text(encoding="utf-8"))
    section = data[phase]
    if not section["record_count"]:
        return
    print(f">>> {path.stem} · {phase} ({section['record_count']} recs)")

    def load_entities():
        entities = list(section["load_order"])
        entities += [e for e in section["records"] if e not in entities]
        for entity in entities:
            records = section["records"].get(entity, [])
            if not records:
                continue
            resolved = resolve_table(conn, schema_hint, entity)
            if not resolved:
                report.warn(f"{path.stem}/{phase}: '{entity}' sin tabla PG destino — saltada"
                            f" ({len(records)} recs)")
                continue
            try:
                with conn.transaction():  # savepoint: un defecto puntual no tumba el módulo
                    inserted, existing, skipped = insert_records(
                        conn, *resolved, records, report, refresh)
            except psycopg.errors.Error as exc:
                report.warn(f"{resolved[0]}.{entity}: {exc.sqlstate} {exc}".splitlines()[0])
                continue
            report.add("pg", f"{resolved[0]}.{entity}", inserted, existing,
                       f"saltados:{skipped}" if skipped else "")

    run_module_transaction(conn, load_entities)


def load_generales_pg(conn, phase, report, only=None, refresh=False):
    files = module_files(only)
    skip_pg = {MONGO_MODULE, REDIS_MODULE, OPENSEARCH_MODULE}
    ordered = [f for f in files if f.name.startswith("03_")] + \
              [f for f in files if not f.name.startswith("03_")]
    for path in ordered:
        number, _ = module_number_and_schema(path)
        if number not in skip_pg:
            load_module_phase(conn, path, phase, report, refresh)


# ----------------------------------------------------------------- seedsProd (PG, módulo 03)
def sha256_of(path):
    digest = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_seeds_prod(conn, report):
    plan = json.loads((PROD_DIR / "modules" / "03_terminology.seeds.json").read_text(encoding="utf-8"))
    boot = plan["boot"]
    print(f">>> seedsProd 03_terminology · inline ({boot.get('inline_record_count', 0)} recs)")

    def load_inline():
        for entity in boot["load_order"]:
            records = boot["records"].get(entity, [])
            if records:
                inserted, existing, skipped = insert_records(conn, "terminology", entity, records, report)
                report.add("pg", f"terminology.{entity} (prod inline)", inserted, existing,
                           f"saltados:{skipped}" if skipped else "")

    run_module_transaction(conn, load_inline)

    expected_by_entity = {}
    for shard in boot["bulk_files"]:
        expected_by_entity[shard["entity"]] = expected_by_entity.get(shard["entity"], 0) + shard["record_count"]

    for entity, expected in expected_by_entity.items():
        actual = conn.execute(f'SELECT count(*) FROM "terminology"."{entity}"').fetchone()[0]
        if actual >= expected:
            report.add("pg", f"terminology.{entity} (bulk)", 0, expected, "ya cargada — skip shards")
            continue
        for shard in (s for s in boot["bulk_files"] if s["entity"] == entity):
            load_bulk_shard(conn, shard, report)


def load_bulk_shard(conn, shard, report):
    path = PROD_DIR / shard["path"]
    digest = sha256_of(path)
    if digest != shard["sha256"]:
        raise RuntimeError(f"sha256 no coincide en {shard['path']}: {digest}")
    payload = json.loads(path.read_text(encoding="utf-8"))
    entity, records = payload["entity"], payload["records"]
    print(f">>> shard {entity} part-{shard['part']:04d} ({len(records)} recs)")
    inserted, existing, skipped = run_module_transaction(
        conn, lambda: insert_records(conn, "terminology", entity, records, report))
    report.add("pg", f"terminology.{entity} p{shard['part']:04d}", inserted, existing,
               f"saltados:{skipped}" if skipped else "")


# ----------------------------------------------------------------- Mongo (55) / Redis (56)
def load_mongo(cfg, report, only=None):
    files = module_files(only)
    path = next((f for f in files if f.name.startswith(f"{MONGO_MODULE}_")), None)
    if not path:
        return
    from pymongo import MongoClient, ReplaceOne
    db = MongoClient(cfg["MONGODB_URI"]).get_default_database()
    data = json.loads(path.read_text(encoding="utf-8"))
    # Los mock traen strings donde los validadores $jsonSchema exigen binData/date/array:
    # se insertan con bypass (los validadores quedan activos para la API).
    report.warn("55_document_store mock: tipos string vs validadores $jsonSchema (binData/date/"
                "array) — insertados con bypass_document_validation (TODO: regenerar mock con tipos BSON)")
    from pymongo.errors import BulkWriteError
    DUPLICATE_KEY = 11000
    for entity in data["mock"]["load_order"]:
        docs = data["mock"]["records"].get(entity, [])
        if not docs:
            continue
        operations = [ReplaceOne({"_id": d["_id"]}, d, upsert=True) for d in docs]
        try:
            result = db[entity].bulk_write(operations, ordered=False,
                                           bypass_document_validation=True)
            upserted, duplicated = result.upserted_count, 0
        except BulkWriteError as exc:
            hard = [e for e in exc.details["writeErrors"] if e["code"] != DUPLICATE_KEY]
            if hard:
                raise
            duplicated = len(exc.details["writeErrors"])
            upserted = exc.details["nUpserted"]
            report.warn(f"mongo {entity}: {duplicated} docs con clave natural duplicada"
                        " en el paquete — saltados (equivalente a ON CONFLICT DO NOTHING)")
        report.add("mongo", entity, upserted, len(docs) - upserted - duplicated,
                   f"dup:{duplicated}" if duplicated else "")
    print(f">>> 55_document_store · mock → Mongo {db.name}")


def load_redis(cfg, report, only=None):
    files = module_files(only)
    path = next((f for f in files if f.name.startswith(f"{REDIS_MODULE}_")), None)
    if not path:
        return
    import redis
    client = redis.Redis(host=cfg["REDIS_HOST"], port=int(cfg["REDIS_PORT"]))
    data = json.loads(path.read_text(encoding="utf-8"))
    for entity, records in data["mock"]["records"].items():
        stored = 0
        for rec in records:
            body = {k: v for k, v in rec.items() if k != "key"}
            ttl = rec.get("ttl_seconds")
            client.set(rec["key"], json.dumps(body, ensure_ascii=False), ex=ttl or None)
            stored += 1
        report.add("redis", entity, stored, 0, "SET con TTL declarado" if records else "")
    print(">>> 56_redis_runtime · mock → Redis")


# ----------------------------------------------------------------- OpenSearch (57)
def opensearch_bulk(base_url, index, docs, id_field, report):
    lines = []
    for doc in docs:
        doc = dict(doc)
        doc_id = doc.pop("_id", None) or doc.get(id_field)
        action = {"index": {"_index": index}}
        if doc_id:
            action["index"]["_id"] = doc_id
        lines.append(json.dumps(action, ensure_ascii=False))
        lines.append(json.dumps(doc, ensure_ascii=False))
    body = ("\n".join(lines) + "\n").encode("utf-8")
    request = urllib.request.Request(f"{base_url}/_bulk", data=body, method="POST",
                                     headers={"Content-Type": "application/x-ndjson"})
    with urllib.request.urlopen(request, timeout=60) as response:
        result = json.loads(response.read())
    errors = [i["index"].get("error") for i in result.get("items", []) if i["index"].get("error")]
    if errors:
        report.warn(f"OpenSearch {index}: {len(errors)} docs con error — 1º: {errors[0]}")
    return len(docs) - len(errors)


def load_opensearch(cfg, report, include_mock, only=None):
    files = module_files(only)
    path = next((f for f in files if f.name.startswith(f"{OPENSEARCH_MODULE}_")), None)
    if not path:
        return
    base_url = cfg["OPENSEARCH_NODE"]
    data = json.loads(path.read_text(encoding="utf-8"))
    phases = ["boot"] + (["mock"] if include_mock else [])
    for phase in phases:
        for entity in data[phase]["load_order"]:
            docs = data[phase]["records"].get(entity, [])
            if docs:
                indexed = opensearch_bulk(base_url, entity, docs, "template_code", report)
                report.add("opensearch", f"{entity} ({phase})", indexed, len(docs) - indexed)
    print(">>> 57_search_platform → OpenSearch")


# ----------------------------------------------------------------- post-load (load-plan.json)
def verify_foreign_keys(conn, report):
    """Scan de huérfanos sobre las FKs de las tablas cargadas (se cargó con replica mode)."""
    if not report.touched_tables:
        return
    oids = [oid for (oid,) in (conn.execute("SELECT to_regclass(%s)::oid", (f'"{s}"."{t}"',)).fetchone()
            for s, t in report.touched_tables) if oid]
    fks = conn.execute(
        "SELECT sn.nspname, cl.relname, fn.nspname, fcl.relname,"
        " (SELECT array_agg(a.attname ORDER BY x.ord) FROM unnest(c.conkey) WITH ORDINALITY x(attnum, ord)"
        "   JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = x.attnum),"
        " (SELECT array_agg(a.attname ORDER BY x.ord) FROM unnest(c.confkey) WITH ORDINALITY x(attnum, ord)"
        "   JOIN pg_attribute a ON a.attrelid = c.confrelid AND a.attnum = x.attnum)"
        " FROM pg_constraint c"
        " JOIN pg_class cl ON cl.oid = c.conrelid JOIN pg_namespace sn ON sn.oid = cl.relnamespace"
        " JOIN pg_class fcl ON fcl.oid = c.confrelid JOIN pg_namespace fn ON fn.oid = fcl.relnamespace"
        " WHERE c.contype = 'f' AND c.conrelid = ANY(%s::oid[])", (oids,),
    ).fetchall()
    print(f">>> verificando {len(fks)} FKs de {len(report.touched_tables)} tablas cargadas")
    orphaned = 0
    for child_schema, child, parent_schema, parent, child_cols, parent_cols in fks:
        join = " AND ".join(f'c."{a}" = p."{b}"' for a, b in zip(child_cols, parent_cols))
        not_null = " AND ".join(f'c."{a}" IS NOT NULL' for a in child_cols)
        count = conn.execute(
            f'SELECT count(*) FROM "{child_schema}"."{child}" c'
            f' LEFT JOIN "{parent_schema}"."{parent}" p ON {join}'
            f' WHERE {not_null} AND p."{parent_cols[0]}" IS NULL').fetchone()[0]
        if count:
            orphaned += count
            report.warn(f"FK huérfana: {child_schema}.{child} → {parent_schema}.{parent} ({count} filas)")
    print(f"    huérfanos totales: {orphaned}")


def analyze_tables(conn):
    for table in ANALYZE_AFTER_LOAD:
        schema, name = table.split(".")
        conn.execute(f'ANALYZE "{schema}"."{name}"')
    conn.commit()


# ----------------------------------------------------------------- main
def parse_args():
    parser = argparse.ArgumentParser(description="Carga seedsGenerales + seedsProd")
    parser.add_argument("--skip-prod", action="store_true", help="omite el corpus MeSH")
    parser.add_argument("--skip-mock", action="store_true", help="solo boot")
    parser.add_argument("--only", metavar="NN", help="limita seedsGenerales a un módulo")
    parser.add_argument("--refresh", action="store_true",
                        help="el paquete manda: actualiza por PK las filas ya cargadas "
                             "(sirve para propagar correcciones del generador de seeds)")
    return parser.parse_args()


def ensure_mock_allowed(cfg):
    if cfg.get("NODE_ENV") == "production":
        raise SystemExit("HARD-FAIL: NODE_ENV=production — los seeds mock están prohibidos en producción")


def main():
    args = parse_args()
    cfg = load_config()
    report = Report()
    if not args.skip_mock:
        ensure_mock_allowed(cfg)

    conn = connect_pg(cfg)
    try:
        ensure_enum_values(conn, report, args.only)
        load_generales_pg(conn, "boot", report, args.only, args.refresh)
        if not args.skip_prod:
            load_seeds_prod(conn, report)
        load_opensearch(cfg, report, include_mock=not args.skip_mock, only=args.only)
        if not args.skip_mock:
            load_generales_pg(conn, "mock", report, args.only, args.refresh)
            load_mongo(cfg, report, args.only)
            load_redis(cfg, report, args.only)
        verify_foreign_keys(conn, report)
        analyze_tables(conn)
    finally:
        conn.close()
    report.print_summary()


if __name__ == "__main__":
    main()
