-- SALUD v4.0.10 · módulo 09 · schema forms
-- Generado de diagram_09_forms.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "forms"."dynamic_field_sections" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_section_id" uuid,
    "ordinal" integer,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dynamic_field_sections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."dynamic_field_definitions" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "data_type" "terminology"."technical_data_type" NOT NULL,
    "data_use_concept_id" uuid,
    "sensitivity_concept_id" uuid,
    "semantic_concept_id" uuid,
    "value_set_id" uuid,
    "unit_value_set_id" uuid,
    "cardinality_min" integer,
    "cardinality_max" integer,
    "length_min" integer,
    "length_max" integer,
    "num_precision" integer,
    "num_scale" integer,
    "min_value_decimal" numeric,
    "max_value_decimal" numeric,
    "regex" text,
    "default_value_json" jsonb,
    "keeps_history" boolean,
    "computed" boolean,
    "computation_expression" text,
    "fhir_path" varchar,
    "fhir_extension_url" text,
    "schema_version" integer,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dynamic_field_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_assignments" (
    "id" uuid NOT NULL,
    "field_id" uuid NOT NULL,
    "target_resource_concept_id" uuid NOT NULL,
    "profile_type_concept_id" uuid,
    "tenant_id" uuid,
    "branch_id" uuid,
    "section_id" uuid NOT NULL,
    "required" boolean NOT NULL,
    "visible" boolean NOT NULL,
    "editable" boolean NOT NULL,
    "ordinal" integer,
    "read_role_value_set_id" uuid,
    "write_role_value_set_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_validation_rules" (
    "id" uuid NOT NULL,
    "field_id" uuid NOT NULL,
    "rule_type_concept_id" uuid NOT NULL,
    "operator_concept_id" uuid,
    "parameters_json" jsonb NOT NULL,
    "error_message" varchar,
    "severity_concept_id" uuid,
    "ordinal" integer,
    "active" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_validation_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_dependencies" (
    "id" uuid NOT NULL,
    "target_field_id" uuid NOT NULL,
    "source_field_id" uuid NOT NULL,
    "operator_concept_id" uuid NOT NULL,
    "comparison_value_json" jsonb,
    "behavior_concept_id" uuid NOT NULL,
    "logical_group" varchar,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_dependencies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."form_instances" (
    "id" uuid NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "tenant_context_id" uuid,
    "schema_version" integer NOT NULL,
    "state_concept_id" uuid,
    "closed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_form_instances" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_values" (
    "id" uuid NOT NULL,
    "form_instance_id" uuid NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "field_id" uuid NOT NULL,
    "assignment_id" uuid,
    "instance_group_id" uuid,
    "ordinal" integer NOT NULL,
    "value_string" varchar,
    "value_text" text,
    "value_integer" bigint,
    "value_decimal" numeric,
    "value_boolean" boolean,
    "value_date" date,
    "value_datetime" timestamptz,
    "value_time" time,
    "value_url" text,
    "value_json" jsonb,
    "value_concept_id" uuid,
    "value_reference_type" varchar,
    "value_reference_id" uuid,
    "file_id" uuid,
    "unit_concept_id" uuid,
    "data_source_concept_id" uuid,
    "value_status_concept_id" uuid,
    "effective_from" timestamptz,
    "effective_to" timestamptz,
    "value_version" integer,
    "supersedes_value_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_values" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_value_audit" (
    "id" uuid NOT NULL,
    "field_value_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "previous_snapshot_json" jsonb,
    "new_snapshot_json" jsonb,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_field_value_audit" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_definition_sets" (
    "id" uuid NOT NULL,
    "namespace_uri" text NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "owner_tenant_id" uuid,
    "owner_organization_text" varchar,
    "target_domain_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_definition_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_definition_set_versions" (
    "id" uuid NOT NULL,
    "definition_set_id" uuid NOT NULL,
    "semantic_version" varchar NOT NULL,
    "schema_hash" varchar NOT NULL,
    "effective_from" timestamptz,
    "effective_to" timestamptz,
    "publication_status_concept_id" uuid,
    "compatibility_concept_id" uuid,
    "fhir_structure_definition_url" text,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_field_definition_set_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_set_members" (
    "id" uuid NOT NULL,
    "definition_set_version_id" uuid NOT NULL,
    "field_id" uuid NOT NULL,
    "section_id" uuid,
    "required" boolean,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_field_set_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_definition_localizations" (
    "id" uuid NOT NULL,
    "field_id" uuid NOT NULL,
    "language_concept_id" uuid NOT NULL,
    "label" varchar,
    "help_text" text,
    "placeholder" varchar,
    "validation_message" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_definition_localizations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_value_provenance" (
    "id" uuid NOT NULL,
    "field_value_id" uuid NOT NULL,
    "source_system_uri" text,
    "source_resource_type" varchar,
    "source_resource_id" varchar,
    "source_version" varchar,
    "import_batch_id" uuid,
    "author_profile_id" uuid,
    "entered_by_user_id" uuid,
    "verification_status_concept_id" uuid,
    "confidence_score" numeric,
    "content_hash" varchar,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_field_value_provenance" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_value_access_rules" (
    "id" uuid NOT NULL,
    "field_id" uuid NOT NULL,
    "assignment_id" uuid,
    "purpose_of_use_value_set_id" uuid NOT NULL,
    "read_role_value_set_id" uuid,
    "write_role_value_set_id" uuid,
    "consent_category_concept_id" uuid,
    "mask_strategy_concept_id" uuid,
    "break_glass_allowed" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_value_access_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."field_schema_migrations" (
    "id" uuid NOT NULL,
    "definition_set_id" uuid NOT NULL,
    "from_version_id" uuid NOT NULL,
    "to_version_id" uuid NOT NULL,
    "migration_type_concept_id" uuid NOT NULL,
    "transformation_expression" text,
    "validation_expression" text,
    "rollback_expression" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_schema_migrations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."extension_target_policies" (
    "id" uuid NOT NULL,
    "target_resource_concept_id" uuid NOT NULL,
    "definition_set_id" uuid NOT NULL,
    "tenant_id" uuid,
    "jurisdiction_concept_id" uuid,
    "allow_tenant_fields" boolean,
    "allow_vendor_fields" boolean,
    "maximum_fields" integer,
    "maximum_payload_bytes" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_extension_target_policies" PRIMARY KEY ("id")
);
