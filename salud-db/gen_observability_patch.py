#!/usr/bin/env python3
"""
gen_observability_patch.py — Arma el parche para BASE VIVA de la franja F1 del portal de observabilidad
(v4.2.80) a partir del DDL que `gen_ddl.py` y `gen_integrity.py` YA generaron. No escribe DDL: lo copia.

Fuentes (todas generadas; correr antes `gen_ddl.py all`, `gen_integrity.py`):
  SQL/70_observability/{01_schema,02_tables,03_fk_intra,04_indexes,05_constraints,90_fk_deferred}.sql   (módulo 70, entero)
  SQL/28_telemetry/*  sólo lo que es de `client_error_events` y los dos índices nuevos de `user_activity_events`

Lo único que NO sale de los `.puml` y vive acá (como en los parches v4275/v4278): los conceptos (ids deterministas,
los mismos que deriva la API con `deterministicId(key)` = UUIDv5 sobre HEALTH_UUID_NAMESPACE), los permisos de
`mantra_app` sobre el schema nuevo y las comprobaciones finales.

Salida: SQL/patches/2026-10-31_v4280_observabilidad_sistema.sql (idempotente, una transacción).
Uso:    python salud-db/gen_observability_patch.py
"""
from __future__ import annotations

import re
import uuid

from paths import SQL_DIR

VERSION = "v4.2.80"
TARGET = SQL_DIR / "patches" / "2026-10-31_v4280_observabilidad_sistema.sql"

# Mismo namespace que `HEALTH_UUID_NAMESPACE` de la API (src/common/constants/concepts.ts).
HEALTH_UUID_NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")
# Anclas del catálogo (mismos ids que los parches v4275/v4278): no-op si ya existen.
CODE_SYSTEM_VERSION_ID = "ffda3cef-e77a-5002-8709-e79f32e62fb4"

CONCEPTS = [
    # observability.error_groups.state_concept_id
    ("observability:ERROR_GROUP_STATE_NEW", "Error group state: new"),
    ("observability:ERROR_GROUP_STATE_SEEN", "Error group state: seen"),
    ("observability:ERROR_GROUP_STATE_RESOLVED", "Error group state: resolved"),
    ("observability:ERROR_GROUP_STATE_IGNORED", "Error group state: ignored"),
    # telemetry.client_error_events.error_class_concept_id
    ("telemetry:ERROR_CLASS_JS", "Client error class: uncaught JavaScript error"),
    ("telemetry:ERROR_CLASS_PROMISE", "Client error class: unhandled promise rejection"),
    ("telemetry:ERROR_CLASS_HTTP", "Client error class: failed HTTP request"),
    ("telemetry:ERROR_CLASS_ROUTE", "Client error class: route not found or navigation failure"),
    ("telemetry:ERROR_CLASS_CHUNK", "Client error class: lazy chunk failed to load"),
    ("telemetry:ERROR_CLASS_HYDRATION", "Client error class: hydration mismatch"),
    ("telemetry:ERROR_CLASS_TEMPLATE", "Client error class: template rendering error"),
    ("telemetry:ERROR_CLASS_NATIVE", "Client error class: native (mobile) error"),
]

# Tablas de historia (UPDATE prohibido por disparador): la aplicación no recibe UPDATE.
LOG_TABLES = [
    ("observability", t) for t in (
        "error_events", "http_request_minute_series", "sql_statement_minute_series",
        "worker_tick_minute_series", "slow_request_samples", "dependency_probe_runs", "alert_evaluations")
] + [("telemetry", "client_error_events")]
MUTABLE_TABLES = [("observability", t) for t in (
    "instances", "error_groups", "sql_statements", "rollup_watermarks", "alert_rules")]


def read(rel: str) -> str:
    return (SQL_DIR / rel).read_text(encoding="utf-8")


def body(text: str) -> str:
    """Quita la cabecera de comentarios del archivo generado (hasta la primera línea en blanco)."""
    lines = text.splitlines()
    while lines and lines[0].strip():
        lines.pop(0)
    return "\n".join(lines).strip("\n")


def blocks(text: str) -> list[str]:
    """Bloques separados por línea en blanco (cada DO $$ … $$, CREATE TABLE o CREATE INDEX es uno)."""
    return [b for b in re.split(r"\n\s*\n", body(text)) if b.strip()]


def only(text: str, needle: str) -> str:
    return "\n\n".join(b for b in blocks(text) if needle in b)


def constraint_tail(text: str, table: str) -> str:
    marker = f"-- ═══ {table} ═══"
    idx = text.index(marker)
    return text[idx:].strip("\n")


def concept_values() -> str:
    rows = []
    for key, display in CONCEPTS:
        cid = uuid.uuid5(HEALTH_UUID_NAMESPACE, key)
        rows.append(f"  ('{cid}', '{CODE_SYSTEM_VERSION_ID}', '{key}', '{display}', false, true, now(), now(), 1)")
    return ",\n".join(rows)


def grants() -> str:
    out = []
    for schema, table in LOG_TABLES:
        out.append(f'        GRANT SELECT, INSERT, DELETE ON "{schema}"."{table}" TO mantra_app;')
        out.append(f'        REVOKE UPDATE, TRUNCATE ON "{schema}"."{table}" FROM mantra_app;')
    for schema, table in MUTABLE_TABLES:
        out.append(f'        GRANT SELECT, INSERT, UPDATE, DELETE ON "{schema}"."{table}" TO mantra_app;')
    return "\n".join(out)


def main() -> None:
    n_tables70 = read("70_observability/02_tables.sql").count("CREATE TABLE IF NOT EXISTS")
    n_fk70 = read("70_observability/03_fk_intra.sql").count("ADD CONSTRAINT") + \
        read("70_observability/90_fk_deferred.sql").count("ADD CONSTRAINT")
    n_idx70 = read("70_observability/04_indexes.sql").count("CREATE ")
    n_fk28 = only(read("28_telemetry/90_fk_deferred.sql"), '"client_error_events"').count("ADD CONSTRAINT")
    n_idx28 = only(read("28_telemetry/04_indexes.sql"), '"client_error_events"').count("CREATE ") + 2
    table28 = only(read("28_telemetry/02_tables.sql"), '"telemetry"."client_error_events"')
    uae_idx = "\n\n".join(
        b for b in blocks(read("28_telemetry/04_indexes.sql"))
        if '"ix_user_activity_events_occurred_at"' in b or '"ix_user_activity_events_route_template_occurred_at"' in b)
    assert uae_idx.count("CREATE INDEX") == 2, "faltan los índices nuevos de user_activity_events: regenerar con gen_ddl.py 28"

    parts = []
    parts.append(f"""-- ============================================================================
-- SALUD · patch {VERSION} (franja F1 del portal de observabilidad: módulo 70 `observability` + `telemetry.client_error_events`) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_observability_patch.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a
-- mano. Idempotente (CREATE ... IF NOT EXISTS, FKs con duplicate_object, CHECK con DROP IF EXISTS + ADD, triggers con DROP IF EXISTS + CREATE,
-- conceptos con ON CONFLICT DO NOTHING). UNA sola transaccion; se puede volver a correr. En un rebuild desde cero apply_all.sql +
-- apply_deferred.sql ya traen todo salvo las secciones 7 y 8 (conceptos y permisos de `mantra_app`), que solo viven aqui.
--
-- Contexto: 02-observabilidad-sistema.md §4 y 03-uso-errores-heatmap.md §4.3 del plan
-- docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo del front).
--
-- PREREQUISITOS: integrity.forbid_mutation() (SQL/_integrity/00_integrity_functions.sql), y los schemas iam, terminology, platform_ops y telemetry.
-- Se comprueban al principio; si falta alguno el parche aborta sin tocar nada.
--
-- QUE AGREGA
--   schema `observability` (modulo 70): {n_tables70} tablas = instances, error_groups, error_events, http_request_minute_series, sql_statements,
--                   sql_statement_minute_series, worker_tick_minute_series, slow_request_samples, dependency_probe_runs, rollup_watermarks,
--                   alert_rules, alert_evaluations
--   telemetry       +1 tabla (client_error_events, append-only, retencion 90 dias) y +2 indices en user_activity_events
--                   (occurred_at; route_template + occurred_at)
--   conceptos       +{len(CONCEPTS)}: observability:ERROR_GROUP_STATE_{{NEW,SEEN,RESOLVED,IGNORED}} y telemetry:ERROR_CLASS_{{JS,PROMISE,HTTP,ROUTE,CHUNK,HYDRATION,TEMPLATE,NATIVE}}
--                   (ids = UUIDv5 de la clave, los mismos que deriva la API: si ya arranco con ellos, es un no-op)
--   RLS             6 politicas (3 en error_events y 3 en client_error_events) sobre actor_tenant_id; RLS forzada
--   permisos        mantra_app: USAGE en observability; en las tablas de historia SELECT/INSERT/DELETE y sin UPDATE/TRUNCATE; en las mutables DML completo
--
-- DELTAS ESPERADOS sobre una base con v4.2.79 y sin este parche:
--   tablas {n_tables70 + 1} (12 + 1) · FKs {n_fk70 + n_fk28} ({n_fk70} del modulo 70 + {n_fk28} de client_error_events) · indices {n_idx70 + n_idx28} (secundarios y unicos; los PK nacen con las tablas)
--   CHECK +6 (modulo 70) · disparadores trg_forbid_update +8 (7 historias del modulo 70 + client_error_events) · conceptos +{len(CONCEPTS)}
--
-- RLS: ninguna tabla nueva tiene columna `tenant_id`, asi que 2026-08-05_tenant_rls.sql no las alcanza. Las dos que llevan el tenant del
-- ACTOR (observability.error_events y telemetry.client_error_events, columna `actor_tenant_id`) reciben aqui, a mano, el mismo patron de
-- ese parche (GUC app.current_tenant_id / app.system_context, FORCE RLS), con una diferencia: la ingesta es publica y no conoce el tenant, asi
-- que el INSERT no lo exige. SELECT: solo el tenant del contexto, o el contexto de sistema (runSystemSweep). DELETE (retencion): solo sistema.
-- Las filas con actor_tenant_id nulo solo las ve el contexto de sistema. Seccion 6b; la 9 lo comprueba.
--
-- TIMESCALEDB: no se requiere. Las 6 series con hypertable declarada (ver nota HYPERTABLE POLICY del .puml 70) llevan la columna de tiempo en la
-- clave primaria; la API las convierte al arrancar (physical.catalog.ts) si la extension esta presente. Este parche NO llama create_hypertable.
--
-- REVERSA (el parche solo agrega; un rollback de la API deja datos inertes):
--   DROP TABLE IF EXISTS "telemetry"."client_error_events";
--   DROP INDEX IF EXISTS "telemetry"."ix_user_activity_events_occurred_at", "telemetry"."ix_user_activity_events_route_template_occurred_at";
--   DROP POLICY IF EXISTS actor_tenant_select, public_ingest_insert, system_retention_delete ON <las dos tablas>; ALTER TABLE ... NO FORCE / DISABLE ROW LEVEL SECURITY;
--   DROP SCHEMA IF EXISTS "observability" CASCADE;
--   DELETE FROM terminology.catalog_concepts WHERE code LIKE 'observability:ERROR_GROUP_STATE_%' OR code LIKE 'telemetry:ERROR_CLASS_%';
-- ============================================================================

BEGIN;

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regprocedure('integrity.forbid_mutation()') IS NULL THEN
        RAISE EXCEPTION 'falta integrity.forbid_mutation(): aplicar antes SQL/_integrity/00_integrity_functions.sql';
    END IF;
    IF to_regclass('iam.users') IS NULL OR to_regclass('iam.sessions') IS NULL
       OR to_regclass('terminology.catalog_concepts') IS NULL
       OR to_regclass('platform_ops.service_components') IS NULL OR to_regclass('platform_ops.health_incidents') IS NULL
       OR to_regclass('telemetry.user_activity_events') IS NULL THEN
        RAISE EXCEPTION 'faltan tablas base (iam.users, iam.sessions, terminology.catalog_concepts, platform_ops.service_components/health_incidents, telemetry.user_activity_events): aplicar antes apply_all.sql';
    END IF;
END $$;
""")
    parts.append("-- ---- 1. modulo 70: schema y tablas (SQL/70_observability/01_schema.sql, 02_tables.sql) ----\n"
                 + body(read("70_observability/01_schema.sql")) + "\n\n" + body(read("70_observability/02_tables.sql")) + "\n")
    parts.append("-- ---- 2. telemetry.client_error_events (SQL/28_telemetry/02_tables.sql) ----\n" + table28 + "\n")
    parts.append("-- ---- 3. FK dentro del schema observability (SQL/70_observability/03_fk_intra.sql) ----\n"
                 + body(read("70_observability/03_fk_intra.sql")) + "\n")
    parts.append("-- ---- 4. indices (SQL/70_observability/04_indexes.sql; SQL/28_telemetry/04_indexes.sql: client_error_events y user_activity_events) ----\n"
                 + body(read("70_observability/04_indexes.sql")) + "\n\n"
                 + only(read("28_telemetry/04_indexes.sql"), '"client_error_events"') + "\n\n" + uae_idx + "\n")
    parts.append("-- ---- 5. FK entre schemas (SQL/70_observability/90_fk_deferred.sql; SQL/28_telemetry/90_fk_deferred.sql: client_error_events) ----\n"
                 + body(read("70_observability/90_fk_deferred.sql")) + "\n\n"
                 + only(read("28_telemetry/90_fk_deferred.sql"), '"client_error_events"') + "\n")
    parts.append("-- ---- 6. integridad: CHECK de vocabularios cerrados y UPDATE prohibido (SQL/70_observability/05_constraints.sql; 28_telemetry: client_error_events) ----\n"
                 + body(read("70_observability/05_constraints.sql")) + "\n\n"
                 + constraint_tail(read("28_telemetry/05_constraints.sql"), "client_error_events") + "\n")
    parts.append("""-- ---- 6b. RLS por tenant del actor (error_events, client_error_events): mismo patron que 2026-08-05_tenant_rls.sql ----
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN SELECT * FROM (VALUES ('observability', 'error_events'), ('telemetry', 'client_error_events')) AS v(s, t) LOOP
        EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('DROP POLICY IF EXISTS actor_tenant_select ON %I.%I', r.s, r.t);
        EXECUTE format('DROP POLICY IF EXISTS public_ingest_insert ON %I.%I', r.s, r.t);
        EXECUTE format('DROP POLICY IF EXISTS system_retention_delete ON %I.%I', r.s, r.t);
        -- lectura: solo las filas del tenant del contexto, o el contexto de sistema (runSystemSweep). Fila sin tenant: solo sistema.
        EXECUTE format($pol$
        CREATE POLICY actor_tenant_select ON %I.%I FOR SELECT
          USING (
            actor_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, r.s, r.t);
        -- alta: la ingesta publica no conoce el tenant; el WITH CHECK no puede exigirlo (el servicio lo rellena desde el actor, nunca del cuerpo)
        EXECUTE format('CREATE POLICY public_ingest_insert ON %I.%I FOR INSERT WITH CHECK (true)', r.s, r.t);
        -- retencion (DELETE por ventana): solo contexto de sistema. No hay politica de UPDATE: ademas esta prohibido por trigger.
        EXECUTE format($pol$
        CREATE POLICY system_retention_delete ON %I.%I FOR DELETE
          USING (current_setting('app.system_context', true) = 'true')
        $pol$, r.s, r.t);
    END LOOP;
END $$;
""")
    parts.append(f"""-- ---- 7. conceptos ({len(CONCEPTS)} nuevos; ids = UUIDv5 de la clave, como deriva la API) ----
INSERT INTO terminology.terminology_sources (id, code, name, created_at, updated_at, row_version)
VALUES ('d94cf414-ad1b-59b9-afe2-903641f26011', 'MANTRA_CORE', 'Mantra Core Internal Terminology', now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_systems (id, source_id, internal_code, name, canonical_url, case_sensitive, created_at, updated_at, row_version)
VALUES ('7d025a87-9c81-5c5c-9432-daf84d6fee8a', 'd94cf414-ad1b-59b9-afe2-903641f26011', 'mantra-core-internal',
        'Mantra Core Internal Code System', 'https://mantracore.health/fhir/CodeSystem/internal', true, now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_system_versions (id, code_system_id, version, published_at, is_default, created_at, updated_at, row_version)
VALUES ('{CODE_SYSTEM_VERSION_ID}', '7d025a87-9c81-5c5c-9432-daf84d6fee8a', '1.0.0', now(), true, now(), now(), 1)
ON CONFLICT DO NOTHING;

INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, abstract, selectable, created_at, updated_at, row_version) VALUES
{concept_values()}
ON CONFLICT DO NOTHING;
""")
    parts.append(f"""-- ---- 8. permisos de la aplicacion (solo si existe el rol; el schema es nuevo y no tiene privilegios por defecto) ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT USAGE ON SCHEMA "observability" TO mantra_app;
{grants()}
    END IF;
END $$;
""")
    parts.append(f"""-- ---- 9. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'observability' AND table_type = 'BASE TABLE';
    IF n <> {n_tables70} THEN RAISE EXCEPTION 'observability deberia tener {n_tables70} tablas y tiene %', n; END IF;
    IF to_regclass('telemetry.client_error_events') IS NULL THEN RAISE EXCEPTION 'falta telemetry.client_error_events'; END IF;
    IF to_regclass('telemetry.ix_user_activity_events_occurred_at') IS NULL
       OR to_regclass('telemetry.ix_user_activity_events_route_template_occurred_at') IS NULL THEN
        RAISE EXCEPTION 'faltan los indices nuevos de telemetry.user_activity_events';
    END IF;
    -- D-F1-1: ninguna tabla nueva puede llevar una columna tenant_id (el RLS la alcanzaria y rompería la escritura de plataforma).
    SELECT count(*) INTO n FROM information_schema.columns
     WHERE column_name = 'tenant_id' AND ((table_schema = 'observability') OR (table_schema = 'telemetry' AND table_name = 'client_error_events'));
    IF n <> 0 THEN RAISE EXCEPTION 'las tablas nuevas no deben tener columna tenant_id (RLS): %', n; END IF;
    SELECT count(*) INTO n FROM pg_policies
     WHERE (schemaname = 'observability' AND tablename <> 'error_events')
        OR (schemaname = 'telemetry' AND tablename = 'client_error_events' AND policyname NOT IN ('actor_tenant_select', 'public_ingest_insert', 'system_retention_delete'))
        OR (schemaname = 'observability' AND tablename = 'error_events' AND policyname NOT IN ('actor_tenant_select', 'public_ingest_insert', 'system_retention_delete'));
    IF n <> 0 THEN RAISE EXCEPTION 'politicas RLS inesperadas en las tablas nuevas: %', n; END IF;
    SELECT count(*) INTO n FROM pg_policies
     WHERE (schemaname, tablename) IN (('observability', 'error_events'), ('telemetry', 'client_error_events'));
    IF n <> 6 THEN RAISE EXCEPTION 'deberia haber 6 politicas RLS (3 por tabla) y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_class c JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE c.relrowsecurity AND c.relforcerowsecurity
       AND ((s.nspname = 'observability' AND c.relname = 'error_events') OR (s.nspname = 'telemetry' AND c.relname = 'client_error_events'));
    IF n <> 2 THEN RAISE EXCEPTION 'error_events y client_error_events deben tener RLS FORZADA'; END IF;
    SELECT count(*) INTO n FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE t.tgname = 'trg_forbid_update' AND NOT t.tgisinternal
       AND ((s.nspname = 'observability') OR (s.nspname = 'telemetry' AND c.relname = 'client_error_events'));
    IF n <> {len(LOG_TABLES)} THEN RAISE EXCEPTION 'deberia haber {len(LOG_TABLES)} disparadores trg_forbid_update y hay %', n; END IF;
    SELECT count(*) INTO n FROM terminology.catalog_concepts
     WHERE code LIKE 'observability:ERROR_GROUP_STATE_%' OR code LIKE 'telemetry:ERROR_CLASS_%';
    IF n <> {len(CONCEPTS)} THEN RAISE EXCEPTION 'deberia haber {len(CONCEPTS)} conceptos nuevos y hay %', n; END IF;
END $$;

COMMIT;
""")
    TARGET.write_text("\n".join(parts), encoding="utf-8")
    print(f"Generado {TARGET.relative_to(SQL_DIR.parent)} · {n_tables70}+1 tablas · {n_fk70 + n_fk28} FK · {n_idx70 + n_idx28} índices · {len(CONCEPTS)} conceptos")


if __name__ == "__main__":
    main()
