-- SALUD v4.0.10 · módulo 14 · schema practice
-- Generado de diagram_14_practice.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "practice"."inventory_items" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "product_concept_id" uuid,
    "name" varchar NOT NULL,
    "lot_number" varchar,
    "expiry_date" date,
    "quantity_on_hand" numeric NOT NULL,
    "unit_concept_id" uuid,
    "reorder_level" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."inventory_movements" (
    "id" uuid NOT NULL,
    "inventory_item_id" uuid NOT NULL,
    "movement_type_concept_id" uuid NOT NULL,
    "quantity" numeric NOT NULL,
    "related_resource_type" varchar,
    "related_resource_id" uuid,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_inventory_movements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."practices" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "type_concept_id" uuid NOT NULL,
    "admin_user_id" uuid NOT NULL,
    "currency_concept_id" uuid,
    "time_zone" varchar,
    "settings_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."practice_sites" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "branch_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "site_type_concept_id" uuid NOT NULL,
    "physical_type_concept_id" uuid,
    "operational_status_concept_id" uuid,
    "time_zone" varchar,
    "address_id" uuid,
    "managing_tenant_id" uuid,
    "bank_qr_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practice_sites" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."clinical_units" (
    "id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "parent_unit_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "unit_type_concept_id" uuid NOT NULL,
    "specialty_concept_id" uuid,
    "service_mode_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_clinical_units" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."care_spaces" (
    "id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "clinical_unit_id" uuid,
    "parent_space_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "space_type_concept_id" uuid NOT NULL,
    "capacity" integer,
    "operational_status_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_spaces" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."healthcare_services" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "practice_site_id" uuid,
    "clinical_unit_id" uuid,
    "service_concept_id" uuid NOT NULL,
    "specialty_concept_id" uuid,
    "referral_required" boolean,
    "appointment_required" boolean,
    "telehealth_available" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_healthcare_services" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."practitioner_role_assignments" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "practice_site_id" uuid,
    "clinical_unit_id" uuid,
    "healthcare_service_id" uuid,
    "role_concept_id" uuid NOT NULL,
    "specialty_concept_id" uuid,
    "supervisor_practitioner_profile_id" uuid,
    "revenue_share_percent" numeric,
    "is_primary" boolean,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_role_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."practitioner_support_assignments" (
    "id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid NOT NULL,
    "support_profile_id" uuid NOT NULL,
    "support_role_concept_id" uuid NOT NULL,
    "scope_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_support_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."practice_accreditations" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "practice_site_id" uuid,
    "accreditation_type_concept_id" uuid NOT NULL,
    "accreditation_number" varchar,
    "issuer_tenant_id" uuid,
    "issuer_name" varchar,
    "valid_from" date,
    "valid_to" date,
    "evidence_file_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practice_accreditations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."practice_settings" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "setting_key" varchar NOT NULL,
    "value_json" jsonb NOT NULL,
    "category_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practice_settings" PRIMARY KEY ("id")
);
