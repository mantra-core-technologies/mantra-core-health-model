-- SALUD v4.0.10 · módulo 03 · schema terminology
-- Generado de diagram_03_terminology.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "terminology"."terminology_sources" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "source_type_concept_id" uuid,
    "owner" varchar,
    "official_url" text,
    "license" text,
    "jurisdiction_concept_id" uuid,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_terminology_sources" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."code_systems" (
    "id" uuid NOT NULL,
    "source_id" uuid NOT NULL,
    "internal_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "canonical_url" text NOT NULL,
    "oid" varchar,
    "content_type_concept_id" uuid,
    "case_sensitive" boolean,
    "supports_composition" boolean,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_code_systems" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."code_system_versions" (
    "id" uuid NOT NULL,
    "code_system_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "published_at" timestamptz,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "checksum" varchar,
    "is_default" boolean,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_code_system_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."catalog_concepts" (
    "id" uuid NOT NULL,
    "code_system_version_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "display" varchar NOT NULL,
    "definition" text,
    "abstract" boolean,
    "selectable" boolean,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "replaced_by_concept_id" uuid,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_concepts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."concept_designations" (
    "id" uuid NOT NULL,
    "concept_id" uuid NOT NULL,
    "language_concept_id" uuid,
    "designation_type_concept_id" uuid,
    "value" varchar NOT NULL,
    "preferred" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_concept_designations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."concept_properties" (
    "id" uuid NOT NULL,
    "concept_id" uuid NOT NULL,
    "property_code" varchar NOT NULL,
    "data_type" "terminology"."technical_data_type" NOT NULL,
    "value_json" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_concept_properties" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."concept_relationships" (
    "id" uuid NOT NULL,
    "source_concept_id" uuid NOT NULL,
    "target_concept_id" uuid NOT NULL,
    "relationship_type_concept_id" uuid NOT NULL,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_concept_relationships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."value_sets" (
    "id" uuid NOT NULL,
    "internal_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "canonical_url" text NOT NULL,
    "description" text,
    "jurisdiction_concept_id" uuid,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_value_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."value_set_versions" (
    "id" uuid NOT NULL,
    "value_set_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "is_default" boolean,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_value_set_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."value_set_members" (
    "id" uuid NOT NULL,
    "value_set_version_id" uuid NOT NULL,
    "concept_id" uuid NOT NULL,
    "included" boolean NOT NULL,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_value_set_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."value_set_rules" (
    "id" uuid NOT NULL,
    "value_set_version_id" uuid NOT NULL,
    "code_system_id" uuid NOT NULL,
    "operator_concept_id" uuid,
    "property" varchar,
    "value" varchar,
    "included" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_value_set_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."concept_maps" (
    "id" uuid NOT NULL,
    "source_concept_id" uuid NOT NULL,
    "target_concept_id" uuid NOT NULL,
    "equivalence_concept_id" uuid,
    "context" varchar,
    "version" varchar,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_concept_maps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."catalog_import_batches" (
    "id" uuid NOT NULL,
    "source_id" uuid NOT NULL,
    "code_system_version_id" uuid,
    "file_id" uuid,
    "state_concept_id" uuid,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "total_read" bigint,
    "total_inserted" bigint,
    "total_errors" bigint,
    "checksum" varchar,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_catalog_import_batches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."tenant_catalog_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "value_set_id" uuid NOT NULL,
    "mode_concept_id" uuid,
    "allow_subset" boolean,
    "allow_alias" boolean,
    "allow_local_concepts" boolean,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_catalog_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "terminology"."tenant_concept_config" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "concept_id" uuid NOT NULL,
    "enabled" boolean NOT NULL,
    "alias_display" varchar,
    "ordinal" integer,
    "is_default" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_concept_config" PRIMARY KEY ("id")
);
