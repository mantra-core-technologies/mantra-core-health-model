-- SALUD v4.0.10 · módulo 39 · schema reporting
-- Generado de diagram_39_reporting.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "reporting"."report_data_sources" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "read_model_definition_id" uuid,
    "view_name" varchar,
    "spec_json" jsonb,
    "row_security_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_data_sources" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_definitions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "category_concept_id" uuid,
    "data_source_id" uuid NOT NULL,
    "query_spec_json" jsonb,
    "default_output_format_concept_id" uuid,
    "required_permission_id" uuid,
    "is_public" boolean,
    "current_version" integer NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_versions" (
    "id" uuid NOT NULL,
    "report_definition_id" uuid NOT NULL,
    "version" integer NOT NULL,
    "spec_json" jsonb NOT NULL,
    "change_note" text,
    "status_concept_id" uuid NOT NULL,
    "published_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_parameters" (
    "id" uuid NOT NULL,
    "report_definition_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "data_type" "terminology"."technical_data_type" NOT NULL,
    "required" boolean,
    "default_value_json" jsonb,
    "value_set_id" uuid,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_parameters" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_columns" (
    "id" uuid NOT NULL,
    "report_definition_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "label" varchar NOT NULL,
    "expression" text,
    "data_type" "terminology"."technical_data_type",
    "aggregation_concept_id" uuid,
    "format_mask" varchar,
    "is_visible" boolean,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_columns" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_schedules" (
    "id" uuid NOT NULL,
    "report_definition_id" uuid NOT NULL,
    "tenant_id" uuid,
    "name" varchar NOT NULL,
    "cron_expression" varchar NOT NULL,
    "time_zone" varchar,
    "parameters_json" jsonb,
    "output_format_concept_id" uuid NOT NULL,
    "is_enabled" boolean,
    "next_run_at" timestamptz,
    "last_run_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_executions" (
    "id" uuid NOT NULL,
    "report_definition_id" uuid NOT NULL,
    "report_version_id" uuid,
    "schedule_id" uuid,
    "tenant_id" uuid,
    "trigger_concept_id" uuid NOT NULL,
    "requested_by_user_id" uuid,
    "parameters_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "row_count" bigint,
    "output_format_concept_id" uuid,
    "output_file_id" uuid,
    "error_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_executions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_snapshots" (
    "id" uuid NOT NULL,
    "report_execution_id" uuid NOT NULL,
    "storage_uri" text NOT NULL,
    "content_hash" varchar,
    "row_count" bigint,
    "size_bytes" bigint,
    "expires_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_distributions" (
    "id" uuid NOT NULL,
    "schedule_id" uuid,
    "report_execution_id" uuid,
    "recipient_type_concept_id" uuid NOT NULL,
    "recipient_user_id" uuid,
    "recipient_address" varchar,
    "channel_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "sent_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_distributions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."report_subscriptions" (
    "id" uuid NOT NULL,
    "report_schedule_id" uuid NOT NULL,
    "subscriber_user_id" uuid NOT NULL,
    "channel_id" uuid NOT NULL,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_subscriptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."dashboards" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "layout_json" jsonb,
    "required_permission_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dashboards" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "reporting"."dashboard_widgets" (
    "id" uuid NOT NULL,
    "dashboard_id" uuid NOT NULL,
    "report_definition_id" uuid,
    "widget_type_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "visualization_concept_id" uuid,
    "config_json" jsonb,
    "position_json" jsonb,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dashboard_widgets" PRIMARY KEY ("id")
);
