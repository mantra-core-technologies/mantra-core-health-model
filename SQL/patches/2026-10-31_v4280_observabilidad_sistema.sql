-- ============================================================================
-- SALUD · patch v4.2.80 (franja F1 del portal de observabilidad: módulo 70 `observability` + `telemetry.client_error_events`) sobre BD viva
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
--   schema `observability` (modulo 70): 12 tablas = instances, error_groups, error_events, http_request_minute_series, sql_statements,
--                   sql_statement_minute_series, worker_tick_minute_series, slow_request_samples, dependency_probe_runs, rollup_watermarks,
--                   alert_rules, alert_evaluations
--   telemetry       +1 tabla (client_error_events, append-only, retencion 90 dias) y +2 indices en user_activity_events
--                   (occurred_at; route_template + occurred_at)
--   conceptos       +12: observability:ERROR_GROUP_STATE_{NEW,SEEN,RESOLVED,IGNORED} y telemetry:ERROR_CLASS_{JS,PROMISE,HTTP,ROUTE,CHUNK,HYDRATION,TEMPLATE,NATIVE}
--                   (ids = UUIDv5 de la clave, los mismos que deriva la API: si ya arranco con ellos, es un no-op)
--   permisos        mantra_app: USAGE en observability; en las tablas de historia SELECT/INSERT/DELETE y sin UPDATE/TRUNCATE; en las mutables DML completo
--
-- DELTAS ESPERADOS sobre una base con v4.2.79 y sin este parche:
--   tablas 13 (12 + 1) · FKs 17 (13 del modulo 70 + 4 de client_error_events) · indices 49 (secundarios y unicos; los PK nacen con las tablas)
--   CHECK +6 (modulo 70) · disparadores trg_forbid_update +8 (7 historias del modulo 70 + client_error_events) · conceptos +12
--
-- RLS: NINGUNA tabla nueva tiene columna `tenant_id` (el tenant del actor es `actor_tenant_id`), asi que 2026-08-05_tenant_rls.sql no las
-- alcanza y esta base no recibe politicas nuevas. La seccion 9 lo comprueba.
--
-- TIMESCALEDB: no se requiere. Las 6 series con hypertable declarada (ver nota HYPERTABLE POLICY del .puml 70) llevan la columna de tiempo en la
-- clave primaria; la API las convierte al arrancar (physical.catalog.ts) si la extension esta presente. Este parche NO llama create_hypertable.
--
-- REVERSA (el parche solo agrega; un rollback de la API deja datos inertes):
--   DROP TABLE IF EXISTS "telemetry"."client_error_events";
--   DROP INDEX IF EXISTS "telemetry"."ix_user_activity_events_occurred_at", "telemetry"."ix_user_activity_events_route_template_occurred_at";
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

-- ---- 1. modulo 70: schema y tablas (SQL/70_observability/01_schema.sql, 02_tables.sql) ----
CREATE SCHEMA IF NOT EXISTS "observability";

CREATE TABLE IF NOT EXISTS "observability"."instances" (
    "id" uuid NOT NULL,
    "kind" varchar NOT NULL,
    "name" varchar NOT NULL,
    "build_commit" varchar,
    "build_version" varchar,
    "host_hash" varchar(64),
    "started_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "status" varchar NOT NULL,
    "last_snapshot_json" jsonb,
    "expected" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_instances" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "observability"."error_groups" (
    "id" uuid NOT NULL,
    "fingerprint" varchar(64) NOT NULL,
    "source" varchar NOT NULL,
    "http_status" integer,
    "error_code" varchar NOT NULL,
    "error_reason" varchar,
    "exception_type" varchar,
    "module_code" varchar,
    "operation_key" varchar,
    "http_method" varchar,
    "route_template" varchar,
    "title" varchar NOT NULL,
    "sample_message" text,
    "sample_frames_json" jsonb,
    "first_seen_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "occurrences_total" bigint NOT NULL,
    "occurrences_24h" bigint NOT NULL,
    "affected_actors_24h" integer,
    "state_concept_id" uuid NOT NULL,
    "assigned_to_user_id" uuid,
    "resolved_at" timestamptz,
    "resolved_by_user_id" uuid,
    "resolution_note" text,
    "regressed_at" timestamptz,
    "last_request_id" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_error_groups" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "observability"."error_events" (
    "id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "error_group_id" uuid NOT NULL,
    "request_id" varchar,
    "trace_id" varchar(32),
    "instance_id" uuid NOT NULL,
    "source" varchar NOT NULL,
    "http_status" integer,
    "error_code" varchar NOT NULL,
    "error_reason" varchar,
    "exception_type" varchar,
    "module_code" varchar,
    "operation_key" varchar,
    "http_method" varchar,
    "route_template" varchar,
    "actor_tenant_id" uuid,
    "actor_hash" varchar(64),
    "duration_ms" integer,
    "sqlstate" varchar,
    "constraint_name" varchar,
    "table_name" varchar,
    "column_name" varchar,
    "violations_json" jsonb,
    "message_redacted" text,
    "frames_json" jsonb,
    "client_kind" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_error_events" PRIMARY KEY ("id", "occurred_at")
);

CREATE TABLE IF NOT EXISTS "observability"."http_request_minute_series" (
    "time" timestamptz NOT NULL,
    "instance_id" uuid NOT NULL,
    "flush_seq" integer NOT NULL,
    "http_method" varchar NOT NULL,
    "route_template" varchar NOT NULL,
    "http_status" integer NOT NULL,
    "operation_key" varchar,
    "module_code" varchar,
    "requests" integer NOT NULL,
    "sum_ms" double precision NOT NULL,
    "max_ms" double precision NOT NULL,
    "le5" integer NOT NULL,
    "le10" integer NOT NULL,
    "le25" integer NOT NULL,
    "le50" integer NOT NULL,
    "le100" integer NOT NULL,
    "le250" integer NOT NULL,
    "le500" integer NOT NULL,
    "le1000" integer NOT NULL,
    "le2000" integer NOT NULL,
    "le5000" integer NOT NULL,
    "le10000" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_http_request_minute_series" PRIMARY KEY ("time", "instance_id", "flush_seq", "http_method", "route_template", "http_status")
);

CREATE TABLE IF NOT EXISTS "observability"."sql_statements" (
    "query_hash" varchar(12) NOT NULL,
    "statement_class" varchar NOT NULL,
    "normalized_sql" text,
    "primary_table" varchar,
    "first_seen_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "is_slow_ever" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_sql_statements" PRIMARY KEY ("query_hash")
);

CREATE TABLE IF NOT EXISTS "observability"."sql_statement_minute_series" (
    "time" timestamptz NOT NULL,
    "instance_id" uuid NOT NULL,
    "flush_seq" integer NOT NULL,
    "query_hash" varchar(12) NOT NULL,
    "operation_key" varchar NOT NULL,
    "module_code" varchar,
    "executions" integer NOT NULL,
    "sum_ms" double precision NOT NULL,
    "max_ms" double precision NOT NULL,
    "slow_count" integer NOT NULL,
    "failed_count" integer NOT NULL,
    "rows_sum" bigint NOT NULL,
    "le1" integer NOT NULL,
    "le5" integer NOT NULL,
    "le10" integer NOT NULL,
    "le25" integer NOT NULL,
    "le50" integer NOT NULL,
    "le100" integer NOT NULL,
    "le250" integer NOT NULL,
    "le500" integer NOT NULL,
    "le1000" integer NOT NULL,
    "le5000" integer NOT NULL,
    "inf" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_sql_statement_minute_series" PRIMARY KEY ("time", "instance_id", "flush_seq", "query_hash", "operation_key")
);

CREATE TABLE IF NOT EXISTS "observability"."worker_tick_minute_series" (
    "time" timestamptz NOT NULL,
    "instance_id" uuid NOT NULL,
    "operation" varchar NOT NULL,
    "worker_name" varchar NOT NULL,
    "runs" integer NOT NULL,
    "failures" integer NOT NULL,
    "timeouts" integer NOT NULL,
    "skipped" integer NOT NULL,
    "sum_ms" double precision NOT NULL,
    "max_ms" double precision NOT NULL,
    "consecutive_failures_max" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_worker_tick_minute_series" PRIMARY KEY ("time", "instance_id", "operation")
);

CREATE TABLE IF NOT EXISTS "observability"."slow_request_samples" (
    "id" uuid NOT NULL,
    "time" timestamptz NOT NULL,
    "request_id" varchar NOT NULL,
    "trace_id" varchar(32),
    "instance_id" uuid NOT NULL,
    "http_method" varchar NOT NULL,
    "route_template" varchar NOT NULL,
    "operation_key" varchar,
    "module_code" varchar,
    "http_status" integer NOT NULL,
    "duration_ms" integer NOT NULL,
    "sql_count" integer,
    "sql_total_ms" double precision,
    "sql_top_json" jsonb,
    "sampled_because" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_slow_request_samples" PRIMARY KEY ("id", "time")
);

CREATE TABLE IF NOT EXISTS "observability"."dependency_probe_runs" (
    "time" timestamptz NOT NULL,
    "instance_id" uuid NOT NULL,
    "dependency_code" varchar NOT NULL,
    "service_component_id" uuid,
    "status" varchar NOT NULL,
    "latency_ms" integer,
    "error_type" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_dependency_probe_runs" PRIMARY KEY ("time", "instance_id", "dependency_code")
);

CREATE TABLE IF NOT EXISTS "observability"."rollup_watermarks" (
    "rollup_name" varchar NOT NULL,
    "materialized_until" timestamptz NOT NULL,
    "last_run_at" timestamptz,
    "last_duration_ms" integer,
    "last_error" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_rollup_watermarks" PRIMARY KEY ("rollup_name")
);

CREATE TABLE IF NOT EXISTS "observability"."alert_rules" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "metric" varchar NOT NULL,
    "comparator" varchar NOT NULL,
    "threshold" numeric NOT NULL,
    "for_seconds" integer NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "enabled" boolean NOT NULL,
    "module_code" varchar,
    "route_template" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_alert_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "observability"."alert_evaluations" (
    "id" uuid NOT NULL,
    "time" timestamptz NOT NULL,
    "alert_rule_id" uuid NOT NULL,
    "observed_value" double precision NOT NULL,
    "fired" boolean NOT NULL,
    "health_incident_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_alert_evaluations" PRIMARY KEY ("id")
);

-- ---- 2. telemetry.client_error_events (SQL/28_telemetry/02_tables.sql) ----
CREATE TABLE IF NOT EXISTS "telemetry"."client_error_events" (
    "id" uuid NOT NULL,
    "received_at" timestamptz NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "portal_type_concept_id" uuid NOT NULL,
    "actor_tenant_id" uuid,
    "user_id" uuid,
    "session_id" uuid,
    "route_template" varchar(300),
    "fingerprint" varchar(32) NOT NULL,
    "error_class_concept_id" uuid NOT NULL,
    "error_type" varchar(120) NOT NULL,
    "sanitized_message" varchar(500),
    "http_method" varchar(8),
    "api_route_template" varchar(300),
    "http_status" smallint,
    "api_error_code" varchar(60),
    "request_id" varchar(80),
    "support_code" varchar(40),
    "app_version" varchar(40) NOT NULL,
    "build_id" varchar(40),
    "screen_size" varchar(12),
    "is_online" boolean,
    "suppressed_count" integer NOT NULL DEFAULT 0,
    CONSTRAINT "pk_client_error_events" PRIMARY KEY ("id")
);

-- ---- 3. FK dentro del schema observability (SQL/70_observability/03_fk_intra.sql) ----
DO $$ BEGIN
    ALTER TABLE "observability"."error_events"
        ADD CONSTRAINT "fk_error_events_error_group_id" FOREIGN KEY ("error_group_id")
        REFERENCES "observability"."error_groups" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "observability"."error_events"
        ADD CONSTRAINT "fk_error_events_instance_id" FOREIGN KEY ("instance_id")
        REFERENCES "observability"."instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "observability"."alert_evaluations"
        ADD CONSTRAINT "fk_alert_evaluations_alert_rule_id" FOREIGN KEY ("alert_rule_id")
        REFERENCES "observability"."alert_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---- 4. indices (SQL/70_observability/04_indexes.sql; SQL/28_telemetry/04_indexes.sql: client_error_events y user_activity_events) ----
CREATE INDEX IF NOT EXISTS "ix_instances_kind_last_seen" ON "observability"."instances" ("kind", "last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_instances_name" ON "observability"."instances" ("name");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_error_groups_fingerprint" ON "observability"."error_groups" ("fingerprint");

CREATE INDEX IF NOT EXISTS "ix_error_groups_state_last_seen" ON "observability"."error_groups" ("state_concept_id", "last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_groups_module_last_seen" ON "observability"."error_groups" ("module_code", "last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_groups_code" ON "observability"."error_groups" ("error_code", "error_reason");

CREATE INDEX IF NOT EXISTS "ix_error_groups_assigned_to_user_id" ON "observability"."error_groups" ("assigned_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_groups_resolved_by_user_id" ON "observability"."error_groups" ("resolved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_groups_created_by_user_id" ON "observability"."error_groups" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_groups_updated_by_user_id" ON "observability"."error_groups" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_events_group_time" ON "observability"."error_events" ("error_group_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_events_module_time" ON "observability"."error_events" ("module_code", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_events_request_id" ON "observability"."error_events" ("request_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_events_instance_time" ON "observability"."error_events" ("instance_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_error_events_time" ON "observability"."error_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_http_minute_module_time" ON "observability"."http_request_minute_series" ("module_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_http_minute_route_time" ON "observability"."http_request_minute_series" ("route_template", "http_method", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_http_minute_time" ON "observability"."http_request_minute_series" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_sql_statements_primary_table" ON "observability"."sql_statements" ("primary_table");

CREATE INDEX IF NOT EXISTS "ix_sql_statements_last_seen" ON "observability"."sql_statements" ("last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_sql_minute_hash_time" ON "observability"."sql_statement_minute_series" ("query_hash", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_sql_minute_module_time" ON "observability"."sql_statement_minute_series" ("module_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_sql_minute_time" ON "observability"."sql_statement_minute_series" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_worker_tick_worker_time" ON "observability"."worker_tick_minute_series" ("worker_name", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_worker_tick_time" ON "observability"."worker_tick_minute_series" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_slow_request_request_id" ON "observability"."slow_request_samples" ("request_id");

CREATE INDEX IF NOT EXISTS "ix_slow_request_module_time" ON "observability"."slow_request_samples" ("module_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_slow_request_time" ON "observability"."slow_request_samples" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_dependency_probe_code_time" ON "observability"."dependency_probe_runs" ("dependency_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_dependency_probe_service_component_id" ON "observability"."dependency_probe_runs" ("service_component_id");

CREATE INDEX IF NOT EXISTS "brin_dependency_probe_time" ON "observability"."dependency_probe_runs" USING brin ("time") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_alert_rules_code" ON "observability"."alert_rules" ("code");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_severity_concept_id" ON "observability"."alert_rules" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_enabled_module" ON "observability"."alert_rules" ("enabled", "module_code");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_created_by_user_id" ON "observability"."alert_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_updated_by_user_id" ON "observability"."alert_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_alert_evaluations_rule_time" ON "observability"."alert_evaluations" ("alert_rule_id", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_alert_evaluations_health_incident_id" ON "observability"."alert_evaluations" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "brin_alert_evaluations_time" ON "observability"."alert_evaluations" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_client_error_events_received_at" ON "telemetry"."client_error_events" ("received_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_client_error_events_fingerprint_received_at" ON "telemetry"."client_error_events" ("fingerprint", "received_at");

CREATE INDEX IF NOT EXISTS "ix_client_error_events_route_template_received_at" ON "telemetry"."client_error_events" ("route_template", "received_at");

CREATE INDEX IF NOT EXISTS "ix_client_error_events_request_id" ON "telemetry"."client_error_events" ("request_id");

CREATE INDEX IF NOT EXISTS "ix_client_error_events_portal_type_concept_id" ON "telemetry"."client_error_events" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_client_error_events_error_class_concept_id" ON "telemetry"."client_error_events" ("error_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_client_error_events_user_id" ON "telemetry"."client_error_events" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_client_error_events_session_id" ON "telemetry"."client_error_events" ("session_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_occurred_at" ON "telemetry"."user_activity_events" ("occurred_at");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_route_template_occurred_at" ON "telemetry"."user_activity_events" ("route_template", "occurred_at");

-- ---- 5. FK entre schemas (SQL/70_observability/90_fk_deferred.sql; SQL/28_telemetry/90_fk_deferred.sql: client_error_events) ----
-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_assigned_to_user_id" FOREIGN KEY ("assigned_to_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_resolved_by_user_id" FOREIGN KEY ("resolved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: platform_ops.service_components (requiere schema platform_ops)
DO $$ BEGIN
    ALTER TABLE "observability"."dependency_probe_runs"
        ADD CONSTRAINT "fk_dependency_probe_runs_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_rules"
        ADD CONSTRAINT "fk_alert_rules_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_rules"
        ADD CONSTRAINT "fk_alert_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_rules"
        ADD CONSTRAINT "fk_alert_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: platform_ops.health_incidents (requiere schema platform_ops)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_evaluations"
        ADD CONSTRAINT "fk_alert_evaluations_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_error_events"
        ADD CONSTRAINT "fk_client_error_events_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_error_events"
        ADD CONSTRAINT "fk_client_error_events_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.sessions (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_error_events"
        ADD CONSTRAINT "fk_client_error_events_session_id" FOREIGN KEY ("session_id")
        REFERENCES "iam"."sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_error_events"
        ADD CONSTRAINT "fk_client_error_events_error_class_concept_id" FOREIGN KEY ("error_class_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ---- 6. integridad: CHECK de vocabularios cerrados y UPDATE prohibido (SQL/70_observability/05_constraints.sql; 28_telemetry: client_error_events) ----
-- ═══ error_events ═══
--   UPDATE: forbidden
--   RETENTION: 90 days (drop_chunks; DELETE allowed)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."error_events" DROP CONSTRAINT IF EXISTS "ck_error_events_source";
ALTER TABLE "observability"."error_events" ADD CONSTRAINT "ck_error_events_source" CHECK ("source" IN ('api', 'worker', 'web'));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."error_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."error_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."error_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ http_request_minute_series ═══
--   UPDATE: forbidden
--   RETENTION: 14 days raw (drop_chunks; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."http_request_minute_series" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."http_request_minute_series";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."http_request_minute_series"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ sql_statement_minute_series ═══
--   UPDATE: forbidden
--   RETENTION: 14 days (drop_chunks; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."sql_statement_minute_series" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."sql_statement_minute_series";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."sql_statement_minute_series"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ worker_tick_minute_series ═══
--   UPDATE: forbidden
--   RETENTION: 30 days (drop_chunks; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."worker_tick_minute_series" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."worker_tick_minute_series";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."worker_tick_minute_series"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ slow_request_samples ═══
--   UPDATE: forbidden
--   RETENTION: 30 days (drop_chunks; DELETE allowed)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."slow_request_samples" DROP CONSTRAINT IF EXISTS "ck_slow_request_samples_sampled_because";
ALTER TABLE "observability"."slow_request_samples" ADD CONSTRAINT "ck_slow_request_samples_sampled_because" CHECK ("sampled_because" IN ('slow', 'error', 'random'));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."slow_request_samples" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."slow_request_samples";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."slow_request_samples"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ dependency_probe_runs ═══
--   UPDATE: forbidden
--   RETENTION: 30 days (drop_chunks; DELETE allowed)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."dependency_probe_runs" DROP CONSTRAINT IF EXISTS "ck_dependency_probe_runs_status";
ALTER TABLE "observability"."dependency_probe_runs" ADD CONSTRAINT "ck_dependency_probe_runs_status" CHECK ("status" IN ('up', 'degraded', 'down', 'not_probed'));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."dependency_probe_runs" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."dependency_probe_runs";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."dependency_probe_runs"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ alert_evaluations ═══
--   UPDATE: forbidden
--   RETENTION: 400 days (purge job; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."alert_evaluations" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."alert_evaluations";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."alert_evaluations"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ error_groups ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."error_groups" DROP CONSTRAINT IF EXISTS "ck_error_groups_source";
ALTER TABLE "observability"."error_groups" ADD CONSTRAINT "ck_error_groups_source" CHECK ("source" IN ('api', 'worker', 'web'));


-- ═══ instances ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."instances" DROP CONSTRAINT IF EXISTS "ck_instances_kind";
ALTER TABLE "observability"."instances" ADD CONSTRAINT "ck_instances_kind" CHECK ("kind" IN ('API', 'WORKER'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."instances" DROP CONSTRAINT IF EXISTS "ck_instances_status";
ALTER TABLE "observability"."instances" ADD CONSTRAINT "ck_instances_status" CHECK ("status" IN ('starting', 'running', 'draining', 'stopped'));

-- ═══ client_error_events ═══
--   UPDATE: forbidden
--   RETENTION: 90 days (purge job on received_at; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "telemetry"."client_error_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "telemetry"."client_error_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "telemetry"."client_error_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ---- 7. conceptos (12 nuevos; ids = UUIDv5 de la clave, como deriva la API) ----
INSERT INTO terminology.terminology_sources (id, code, name, created_at, updated_at, row_version)
VALUES ('d94cf414-ad1b-59b9-afe2-903641f26011', 'MANTRA_CORE', 'Mantra Core Internal Terminology', now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_systems (id, source_id, internal_code, name, canonical_url, case_sensitive, created_at, updated_at, row_version)
VALUES ('7d025a87-9c81-5c5c-9432-daf84d6fee8a', 'd94cf414-ad1b-59b9-afe2-903641f26011', 'mantra-core-internal',
        'Mantra Core Internal Code System', 'https://mantracore.health/fhir/CodeSystem/internal', true, now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_system_versions (id, code_system_id, version, published_at, is_default, created_at, updated_at, row_version)
VALUES ('ffda3cef-e77a-5002-8709-e79f32e62fb4', '7d025a87-9c81-5c5c-9432-daf84d6fee8a', '1.0.0', now(), true, now(), now(), 1)
ON CONFLICT DO NOTHING;

INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, abstract, selectable, created_at, updated_at, row_version) VALUES
  ('2529878b-9021-5f78-84e7-277a0f2736fd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'observability:ERROR_GROUP_STATE_NEW', 'Error group state: new', false, true, now(), now(), 1),
  ('5dd2898e-a1e9-5581-b525-4868cb33dc2d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'observability:ERROR_GROUP_STATE_SEEN', 'Error group state: seen', false, true, now(), now(), 1),
  ('65878481-6760-5406-8c59-e530bcaaea17', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'observability:ERROR_GROUP_STATE_RESOLVED', 'Error group state: resolved', false, true, now(), now(), 1),
  ('45c74d83-87a6-5fcd-95cc-785783a67feb', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'observability:ERROR_GROUP_STATE_IGNORED', 'Error group state: ignored', false, true, now(), now(), 1),
  ('5ba43268-115e-5daa-b5b6-4c87aa675a43', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_JS', 'Client error class: uncaught JavaScript error', false, true, now(), now(), 1),
  ('81575400-d9af-5769-8289-43eea6ed152f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_PROMISE', 'Client error class: unhandled promise rejection', false, true, now(), now(), 1),
  ('b50bdf43-d747-5942-a472-f6462afe4a86', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_HTTP', 'Client error class: failed HTTP request', false, true, now(), now(), 1),
  ('730cc3b1-69ac-56a6-941f-4d7e0dd91609', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_ROUTE', 'Client error class: route not found or navigation failure', false, true, now(), now(), 1),
  ('18aa38ac-4de0-5ef8-b5b0-b359ff8e3515', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_CHUNK', 'Client error class: lazy chunk failed to load', false, true, now(), now(), 1),
  ('77e406cb-8fac-5fbf-889f-5dd5d2dc358e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_HYDRATION', 'Client error class: hydration mismatch', false, true, now(), now(), 1),
  ('ca456806-4152-5b27-8fa3-8327422f8c79', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_TEMPLATE', 'Client error class: template rendering error', false, true, now(), now(), 1),
  ('f71fb756-3320-5d6a-b852-8e9a81335799', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'telemetry:ERROR_CLASS_NATIVE', 'Client error class: native (mobile) error', false, true, now(), now(), 1)
ON CONFLICT DO NOTHING;

-- ---- 8. permisos de la aplicacion (solo si existe el rol; el schema es nuevo y no tiene privilegios por defecto) ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT USAGE ON SCHEMA "observability" TO mantra_app;
        GRANT SELECT, INSERT, DELETE ON "observability"."error_events" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "observability"."error_events" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "observability"."http_request_minute_series" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "observability"."http_request_minute_series" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "observability"."sql_statement_minute_series" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "observability"."sql_statement_minute_series" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "observability"."worker_tick_minute_series" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "observability"."worker_tick_minute_series" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "observability"."slow_request_samples" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "observability"."slow_request_samples" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "observability"."dependency_probe_runs" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "observability"."dependency_probe_runs" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "observability"."alert_evaluations" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "observability"."alert_evaluations" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "telemetry"."client_error_events" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "telemetry"."client_error_events" FROM mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "observability"."instances" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "observability"."error_groups" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "observability"."sql_statements" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "observability"."rollup_watermarks" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "observability"."alert_rules" TO mantra_app;
    END IF;
END $$;

-- ---- 9. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'observability' AND table_type = 'BASE TABLE';
    IF n <> 12 THEN RAISE EXCEPTION 'observability deberia tener 12 tablas y tiene %', n; END IF;
    IF to_regclass('telemetry.client_error_events') IS NULL THEN RAISE EXCEPTION 'falta telemetry.client_error_events'; END IF;
    IF to_regclass('telemetry.ix_user_activity_events_occurred_at') IS NULL
       OR to_regclass('telemetry.ix_user_activity_events_route_template_occurred_at') IS NULL THEN
        RAISE EXCEPTION 'faltan los indices nuevos de telemetry.user_activity_events';
    END IF;
    -- D-F1-1: ninguna tabla nueva puede llevar una columna tenant_id (el RLS la alcanzaria y rompería la escritura de plataforma).
    SELECT count(*) INTO n FROM information_schema.columns
     WHERE column_name = 'tenant_id' AND ((table_schema = 'observability') OR (table_schema = 'telemetry' AND table_name = 'client_error_events'));
    IF n <> 0 THEN RAISE EXCEPTION 'las tablas nuevas no deben tener columna tenant_id (RLS): %', n; END IF;
    SELECT count(*) INTO n FROM pg_policies WHERE schemaname = 'observability' OR (schemaname = 'telemetry' AND tablename = 'client_error_events');
    IF n <> 0 THEN RAISE EXCEPTION 'las tablas nuevas no deben tener politicas RLS: %', n; END IF;
    SELECT count(*) INTO n FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE t.tgname = 'trg_forbid_update' AND NOT t.tgisinternal
       AND ((s.nspname = 'observability') OR (s.nspname = 'telemetry' AND c.relname = 'client_error_events'));
    IF n <> 8 THEN RAISE EXCEPTION 'deberia haber 8 disparadores trg_forbid_update y hay %', n; END IF;
    SELECT count(*) INTO n FROM terminology.catalog_concepts
     WHERE code LIKE 'observability:ERROR_GROUP_STATE_%' OR code LIKE 'telemetry:ERROR_CLASS_%';
    IF n <> 12 THEN RAISE EXCEPTION 'deberia haber 12 conceptos nuevos y hay %', n; END IF;
END $$;

COMMIT;
