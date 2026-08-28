-- SALUD v4.0.10 · módulo 36 · schema qa_lab
-- Generado de diagram_36_qa_lab.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "qa_lab"."test_environments" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "environment_concept_id" uuid NOT NULL,
    "base_url" text,
    "tenant_id" uuid,
    "config_json" jsonb,
    "is_production_safe" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_environments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_suites" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "target_system_concept_id" uuid,
    "suite_type_concept_id" uuid,
    "owner_team" varchar,
    "version" integer NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_suites" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_cases" (
    "id" uuid NOT NULL,
    "suite_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "case_type_concept_id" uuid,
    "endpoint_id" uuid,
    "http_method_concept_id" uuid,
    "request_path" text,
    "expected_http_status" integer,
    "setup_json" jsonb,
    "teardown_json" jsonb,
    "ordinal" integer,
    "is_critical" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_cases" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_assertions" (
    "id" uuid NOT NULL,
    "test_case_id" uuid NOT NULL,
    "assertion_type_concept_id" uuid NOT NULL,
    "json_path" varchar,
    "operator_concept_id" uuid,
    "expected_value" text,
    "tolerance" numeric,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_assertions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_fixtures" (
    "id" uuid NOT NULL,
    "suite_id" uuid,
    "test_case_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "payload_json" jsonb NOT NULL,
    "file_id" uuid,
    "fixture_type_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_fixtures" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_runs" (
    "id" uuid NOT NULL,
    "suite_id" uuid NOT NULL,
    "environment_id" uuid NOT NULL,
    "tenant_id" uuid,
    "run_number" varchar NOT NULL,
    "trigger_concept_id" uuid NOT NULL,
    "triggered_by_user_id" uuid,
    "git_ref" varchar,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "total_cases" integer,
    "total_passed" integer,
    "total_failed" integer,
    "total_skipped" integer,
    "duration_ms" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_case_results" (
    "id" uuid NOT NULL,
    "test_run_id" uuid NOT NULL,
    "test_case_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "duration_ms" integer,
    "assertions_total" integer,
    "assertions_passed" integer,
    "assertions_failed" integer,
    "error_type_concept_id" uuid,
    "error_text" text,
    "stack_trace" text,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_case_results" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."assertion_results" (
    "id" uuid NOT NULL,
    "test_case_result_id" uuid NOT NULL,
    "test_assertion_id" uuid NOT NULL,
    "passed" boolean NOT NULL,
    "actual_value" text,
    "message" text,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_assertion_results" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."request_payloads" (
    "id" uuid NOT NULL,
    "test_case_result_id" uuid NOT NULL,
    "direction_concept_id" uuid NOT NULL,
    "sequence_no" integer,
    "http_method_concept_id" uuid,
    "target_url" text,
    "headers_json" jsonb,
    "body_json" jsonb NOT NULL,
    "body_hash" varchar,
    "size_bytes" integer,
    "sent_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_request_payloads" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."response_payloads" (
    "id" uuid NOT NULL,
    "test_case_result_id" uuid NOT NULL,
    "request_payload_id" uuid,
    "http_status" integer,
    "headers_json" jsonb,
    "body_json" jsonb NOT NULL,
    "body_hash" varchar,
    "latency_ms" integer,
    "size_bytes" integer,
    "received_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_response_payloads" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."run_artifacts" (
    "id" uuid NOT NULL,
    "test_run_id" uuid NOT NULL,
    "test_case_result_id" uuid,
    "artifact_type_concept_id" uuid NOT NULL,
    "file_id" uuid,
    "label" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_run_artifacts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_schedules" (
    "id" uuid NOT NULL,
    "suite_id" uuid NOT NULL,
    "environment_id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "cron_expression" varchar,
    "timezone" varchar,
    "trigger_concept_id" uuid NOT NULL,
    "concurrency_policy_concept_id" uuid,
    "is_enabled" boolean,
    "last_run_id" uuid,
    "last_run_at" timestamptz,
    "next_run_at" timestamptz,
    "notify_channel_concept_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_lab"."test_defects" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "test_case_id" uuid NOT NULL,
    "test_case_result_id" uuid,
    "defect_number" varchar NOT NULL,
    "defect_type_concept_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "is_flaky" boolean,
    "failure_signature_hash" varchar,
    "occurrences_count" integer,
    "first_seen_at" timestamptz,
    "last_seen_at" timestamptz,
    "external_issue_ref" varchar,
    "assigned_to_user_id" uuid,
    "title" varchar NOT NULL,
    "description" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_test_defects" PRIMARY KEY ("id")
);
