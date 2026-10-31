-- SALUD v4.2.80 · módulo 70 · schema observability
-- Generado de diagram_70_observability.puml — NO editar a mano.


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
