-- SALUD v4.0.10 · módulo 02 · schema common
-- Generado de diagram_02_common.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "common"."identifiers" (
    "id" uuid NOT NULL,
    "owner_type_concept_id" uuid NOT NULL,
    "owner_id" uuid NOT NULL,
    "use_concept_id" uuid,
    "type_concept_id" uuid NOT NULL,
    "system" text,
    "value" varchar NOT NULL,
    "issuer_country_concept_id" uuid,
    "issuer_administrative_area_concept_id" uuid,
    "assigner_tenant_id" uuid,
    "holder_name" varchar,
    "valid_from" date,
    "valid_to" date,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_identifiers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "common"."contact_points" (
    "id" uuid NOT NULL,
    "owner_type_concept_id" uuid NOT NULL,
    "owner_id" uuid NOT NULL,
    "system_concept_id" uuid NOT NULL,
    "value" varchar NOT NULL,
    "use_concept_id" uuid,
    "rank" integer,
    "verified" boolean,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contact_points" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "common"."addresses" (
    "id" uuid NOT NULL,
    "owner_type_concept_id" uuid NOT NULL,
    "owner_id" uuid NOT NULL,
    "use_concept_id" uuid,
    "type_concept_id" uuid,
    "lines" varchar,
    "city" varchar,
    "administrative_area_concept_id" uuid,
    "municipality_concept_id" uuid,
    "postal_code" varchar,
    "country_concept_id" uuid NOT NULL,
    "latitude" numeric,
    "longitude" numeric,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_addresses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "common"."files" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "category_concept_id" uuid NOT NULL,
    "original_name" varchar,
    "sensitivity_concept_id" uuid NOT NULL,
    "lifecycle_status_concept_id" uuid NOT NULL,
    "current_version_id" uuid,
    "retention_class_concept_id" uuid,
    "legal_hold_until" timestamptz,
    "deleted_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_files" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "common"."file_versions" (
    "id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "storage_provider_concept_id" uuid NOT NULL,
    "storage_region_concept_id" uuid NOT NULL,
    "bucket_or_container" varchar,
    "object_key" text,
    "object_version" varchar,
    "storage_uri" text NOT NULL,
    "external_source_uri" text,
    "mime_type" varchar NOT NULL,
    "size_bytes" bigint NOT NULL,
    "checksum_algorithm_concept_id" uuid NOT NULL,
    "content_hash" varchar NOT NULL,
    "encryption_status_concept_id" uuid NOT NULL,
    "encryption_key_reference" varchar,
    "malware_scan_status_concept_id" uuid NOT NULL,
    "integrity_status_concept_id" uuid,
    "uploaded_at" timestamptz,
    "verified_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_file_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "common"."file_links" (
    "id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "owner_type_concept_id" uuid NOT NULL,
    "owner_id" uuid NOT NULL,
    "link_role_concept_id" uuid NOT NULL,
    "visibility_concept_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_file_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "common"."file_derivatives" (
    "id" uuid NOT NULL,
    "source_file_version_id" uuid NOT NULL,
    "derivative_file_version_id" uuid NOT NULL,
    "derivative_type_concept_id" uuid NOT NULL,
    "generation_profile" varchar,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_file_derivatives" PRIMARY KEY ("id")
);
