-- SALUD v4.0.10 · módulo 04 · schema directory
-- Generado de diagram_04_directory.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "directory"."tenants" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "tenant_type_concept_id" uuid NOT NULL,
    "legal_name" varchar NOT NULL,
    "trade_name" varchar,
    "legal_entity_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "verification_status_concept_id" uuid NOT NULL,
    "country_concept_id" uuid,
    "jurisdiction_concept_id" uuid,
    "data_residency_region_concept_id" uuid,
    "currency_concept_id" uuid,
    "time_zone" varchar,
    "parent_tenant_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."branches" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "branch_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "time_zone" varchar,
    "latitude" numeric,
    "longitude" numeric,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_branches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."tenant_memberships" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "primary_branch_id" uuid,
    "tenant_role_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "access_scope_concept_id" uuid NOT NULL,
    "start_date" timestamptz NOT NULL,
    "end_date" timestamptz,
    "invited_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_memberships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."branch_memberships" (
    "id" uuid NOT NULL,
    "tenant_membership_id" uuid NOT NULL,
    "branch_id" uuid NOT NULL,
    "local_role_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_branch_memberships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."tenant_affiliation_documents" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "document_type_concept_id" uuid NOT NULL,
    "issuing_authority_concept_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "identifier_id" uuid,
    "related_person_id" uuid,
    "document_number" varchar,
    "registered_at" date,
    "issued_at" date,
    "valid_from" date,
    "valid_to" date,
    "verification_status_concept_id" uuid NOT NULL,
    "verified_by_user_id" uuid,
    "verified_at" timestamptz,
    "is_required_for_affiliation" boolean,
    "notes" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_affiliation_documents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."tenant_legal_representatives" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "person_id" uuid NOT NULL,
    "representative_role_concept_id" uuid NOT NULL,
    "ci_identifier_id" uuid,
    "power_of_attorney_document_id" uuid,
    "appointed_at" date,
    "valid_from" date,
    "valid_to" date,
    "is_primary" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_legal_representatives" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."tenant_web_configs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "domain" varchar NOT NULL,
    "subdomain" varchar,
    "primary_language_concept_id" uuid,
    "supported_languages_json" jsonb,
    "locale" varchar,
    "build_language" varchar,
    "framework" varchar,
    "theme_json" jsonb,
    "ssl_enabled" boolean,
    "is_published" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_web_configs" PRIMARY KEY ("id")
);
