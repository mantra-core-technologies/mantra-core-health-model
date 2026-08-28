-- SALUD v4.0.10 · módulo 23 · schema diagnostic_units
-- Generado de diagram_23_diagnostic_units.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_units" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "primary_practice_site_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "diagnostic_unit_type_concept_id" uuid NOT NULL,
    "ownership_type_concept_id" uuid,
    "public_profile_id" uuid,
    "accepts_external_orders" boolean,
    "walk_in_available" boolean,
    "home_collection_available" boolean,
    "verification_status_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_units" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_unit_sites" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "site_role_concept_id" uuid NOT NULL,
    "accession_prefix" varchar,
    "sample_collection_available" boolean,
    "imaging_available" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_unit_sites" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_unit_specialties" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "specialty_concept_id" uuid NOT NULL,
    "is_primary" boolean,
    "verification_status_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_unit_specialties" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_unit_practitioner_assignments" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid NOT NULL,
    "diagnostic_unit_site_id" uuid,
    "specialty_concept_id" uuid,
    "assignment_role_concept_id" uuid,
    "may_validate_results" boolean,
    "may_sign_reports" boolean,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_unit_practitioner_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_study_offerings" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "diagnostic_unit_site_id" uuid,
    "study_code" varchar NOT NULL,
    "study_concept_id" uuid NOT NULL,
    "modality_concept_id" uuid,
    "body_site_concept_id" uuid,
    "specimen_type_concept_id" uuid,
    "display_name" varchar NOT NULL,
    "description" text,
    "preparation_instructions" text,
    "expected_duration_minutes" integer,
    "expected_turnaround_minutes" integer,
    "requires_medical_order" boolean,
    "requires_prior_authorization" boolean,
    "home_collection_eligible" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_study_offerings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_study_components" (
    "id" uuid NOT NULL,
    "parent_offering_id" uuid NOT NULL,
    "component_offering_id" uuid NOT NULL,
    "component_role_concept_id" uuid NOT NULL,
    "quantity" numeric,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_diagnostic_study_components" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_price_schedules" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "diagnostic_unit_site_id" uuid,
    "code" varchar NOT NULL,
    "price_schedule_type_concept_id" uuid NOT NULL,
    "insurer_tenant_id" uuid,
    "broker_tenant_id" uuid,
    "currency_concept_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "public_visibility" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_price_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_study_prices" (
    "id" uuid NOT NULL,
    "price_schedule_id" uuid NOT NULL,
    "diagnostic_study_offering_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "base_amount" numeric NOT NULL,
    "patient_amount" numeric,
    "insurer_amount" numeric,
    "tax_amount" numeric,
    "discount_factor" numeric,
    "pricing_rule_json" jsonb,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_diagnostic_study_prices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_equipment" (
    "id" uuid NOT NULL,
    "diagnostic_unit_site_id" uuid NOT NULL,
    "equipment_type_concept_id" uuid NOT NULL,
    "manufacturer" varchar,
    "model" varchar,
    "serial_number" varchar,
    "modality_concept_id" uuid,
    "last_calibration_at" timestamptz,
    "next_calibration_due_at" timestamptz,
    "operational_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_equipment" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_unit_accreditations" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "diagnostic_unit_site_id" uuid,
    "accreditation_concept_id" uuid NOT NULL,
    "accreditation_number" varchar,
    "issuer_tenant_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "evidence_file_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_unit_accreditations" PRIMARY KEY ("id")
);
