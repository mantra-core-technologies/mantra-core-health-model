-- SALUD v4.0.10 · módulo 45 · schema system_context
-- Generado de diagram_45_system_context.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "system_context"."system_contexts" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "context_type_concept_id" uuid NOT NULL,
    "scope_type_concept_id" uuid NOT NULL,
    "tenant_id" uuid,
    "country_concept_id" uuid,
    "locale_concept_id" uuid,
    "current_version_id" uuid,
    "refresh_policy_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_system_contexts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."system_context_refresh_runs" (
    "id" uuid NOT NULL,
    "system_context_id" uuid NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "trigger_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz NOT NULL,
    "finished_at" timestamptz,
    "input_count" integer,
    "output_content_hash" varchar,
    "error_summary" text,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_system_context_refresh_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."system_context_versions" (
    "id" uuid NOT NULL,
    "system_context_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "refresh_run_id" uuid,
    "schema_version" varchar NOT NULL,
    "context_json" jsonb NOT NULL,
    "content_hash" varchar NOT NULL,
    "generated_by_agent_id" uuid,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "expires_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_system_context_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."system_context_inputs" (
    "id" uuid NOT NULL,
    "system_context_version_id" uuid NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "source_schema_name" varchar NOT NULL,
    "source_entity_name" varchar NOT NULL,
    "source_record_id" uuid NOT NULL,
    "source_version_id" uuid,
    "source_content_hash" varchar NOT NULL,
    "source_freshness_at" timestamptz,
    "precedence" integer,
    "required" boolean,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_system_context_inputs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."system_context_bindings" (
    "id" uuid NOT NULL,
    "system_context_id" uuid NOT NULL,
    "consumer_type_concept_id" uuid NOT NULL,
    "consumer_id" uuid NOT NULL,
    "tenant_id" uuid,
    "country_concept_id" uuid,
    "activation_rule_json" jsonb,
    "priority" integer,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_system_context_bindings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."dynamic_enum_definitions" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "value_set_id" uuid NOT NULL,
    "scope_type_concept_id" uuid NOT NULL,
    "tenant_id" uuid,
    "country_concept_id" uuid,
    "selection_mode_concept_id" uuid,
    "allow_tenant_extension" boolean,
    "allow_custom_value" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dynamic_enum_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."dynamic_enum_versions" (
    "id" uuid NOT NULL,
    "dynamic_enum_definition_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "value_set_version_id" uuid NOT NULL,
    "schema_version" varchar NOT NULL,
    "cache_token" varchar,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_dynamic_enum_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."dynamic_enum_options" (
    "id" uuid NOT NULL,
    "dynamic_enum_version_id" uuid NOT NULL,
    "concept_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "display" varchar NOT NULL,
    "ordinal" integer,
    "is_default" boolean,
    "enabled" boolean,
    "metadata_json" jsonb,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_dynamic_enum_options" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_context"."dynamic_enum_bindings" (
    "id" uuid NOT NULL,
    "dynamic_enum_definition_id" uuid NOT NULL,
    "target_schema_name" varchar NOT NULL,
    "target_entity_name" varchar NOT NULL,
    "target_field_name" varchar NOT NULL,
    "system_context_id" uuid,
    "required" boolean,
    "fallback_concept_id" uuid,
    "validation_mode_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dynamic_enum_bindings" PRIMARY KEY ("id")
);
