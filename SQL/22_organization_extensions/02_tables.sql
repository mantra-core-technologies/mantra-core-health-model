-- SALUD v4.0.10 · módulo 22 · schema organization_extensions
-- Generado de diagram_22_organization_extensions.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "organization_extensions"."hospitals" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "primary_practice_site_id" uuid,
    "public_profile_id" uuid,
    "hospital_type_concept_id" uuid NOT NULL,
    "care_level_concept_id" uuid,
    "ownership_type_concept_id" uuid,
    "teaching_status_concept_id" uuid,
    "emergency_capability_concept_id" uuid,
    "licensed_bed_capacity" integer,
    "operational_bed_capacity" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_hospitals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "organization_extensions"."hospital_service_lines" (
    "id" uuid NOT NULL,
    "hospital_id" uuid NOT NULL,
    "clinical_unit_id" uuid,
    "healthcare_service_id" uuid,
    "service_line_concept_id" uuid NOT NULL,
    "specialty_concept_id" uuid,
    "acuity_level_concept_id" uuid,
    "referral_required" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_hospital_service_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "organization_extensions"."facility_licenses" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid,
    "facility_type_concept_id" uuid NOT NULL,
    "license_type_concept_id" uuid NOT NULL,
    "license_number" varchar NOT NULL,
    "issuing_authority_tenant_id" uuid,
    "issuing_authority_name" varchar,
    "jurisdiction_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "evidence_file_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_facility_licenses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "organization_extensions"."organization_affiliations" (
    "id" uuid NOT NULL,
    "primary_tenant_id" uuid NOT NULL,
    "participating_tenant_id" uuid NOT NULL,
    "affiliation_type_concept_id" uuid NOT NULL,
    "host_practice_site_id" uuid,
    "healthcare_service_id" uuid,
    "contract_reference" varchar,
    "data_use_agreement_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_organization_affiliations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "organization_extensions"."organization_data_boundaries" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "boundary_type_concept_id" uuid NOT NULL,
    "data_controller_tenant_id" uuid NOT NULL,
    "data_processor_tenant_id" uuid,
    "jurisdiction_concept_id" uuid,
    "residency_region_concept_id" uuid,
    "allowed_purpose_value_set_id" uuid,
    "isolation_schema_name" varchar,
    "isolation_policy_version" varchar,
    "status_concept_id" uuid NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_organization_data_boundaries" PRIMARY KEY ("id")
);
