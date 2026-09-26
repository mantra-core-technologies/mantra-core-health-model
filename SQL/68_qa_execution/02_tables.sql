-- SALUD v4.0.10 · módulo 68 · schema qa_execution
-- Generado de diagram_68_qa_execution.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "qa_execution"."execution_targets" (
    "id" uuid NOT NULL,
    "environment_id" uuid NOT NULL,
    "scheme" varchar NOT NULL,
    "host" varchar NOT NULL,
    "port" integer NOT NULL,
    "allowed_path_prefixes" jsonb NOT NULL,
    "allow_private_network" boolean NOT NULL,
    "allow_mutations" boolean NOT NULL,
    "auth_secret_ref" varchar,
    "auth_header_name" varchar,
    "max_requests" integer NOT NULL,
    "max_duration_seconds" integer NOT NULL,
    "request_timeout_ms" integer NOT NULL,
    "min_interval_ms" integer NOT NULL,
    "status" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_execution_targets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_execution"."execution_plans" (
    "id" uuid NOT NULL,
    "run_id" uuid NOT NULL,
    "suite_id" uuid NOT NULL,
    "suite_version" integer NOT NULL,
    "environment_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "plan_hash" varchar NOT NULL,
    "plan_json" jsonb NOT NULL,
    "limits_json" jsonb NOT NULL,
    "requires_approval" boolean NOT NULL,
    "approval_reasons" jsonb,
    "status" varchar NOT NULL,
    "requested_by_user_id" uuid,
    "idempotency_key" varchar,
    "lease_owner" varchar,
    "lease_expires_at" timestamptz,
    "attempt" integer NOT NULL,
    "cancel_requested_at" timestamptz,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "requests_sent" integer NOT NULL,
    "cases_passed" integer NOT NULL,
    "cases_failed" integer NOT NULL,
    "cases_not_run" integer NOT NULL,
    "error_code" varchar,
    "error_message" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_execution_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_execution"."plan_approvals" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "plan_hash" varchar NOT NULL,
    "decision" varchar NOT NULL,
    "reason" text NOT NULL,
    "approver_user_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_plan_approvals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_execution"."plan_events" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "seq" integer NOT NULL,
    "kind" varchar NOT NULL,
    "case_id" uuid,
    "detail_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_plan_events" PRIMARY KEY ("id")
);
