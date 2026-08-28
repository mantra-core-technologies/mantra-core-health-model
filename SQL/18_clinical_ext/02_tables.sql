-- SALUD v4.0.10 · módulo 18 · schema clinical_ext
-- Generado de diagram_18_clinical_ext.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "clinical_ext"."care_teams" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "episode_id" uuid,
    "tenant_id" uuid NOT NULL,
    "name" varchar,
    "category_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "period_start" timestamptz,
    "period_end" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_teams" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."care_team_members" (
    "id" uuid NOT NULL,
    "care_team_id" uuid NOT NULL,
    "practitioner_profile_id" uuid,
    "related_person_id" uuid,
    "member_role_concept_id" uuid NOT NULL,
    "is_responsible" boolean,
    "period_start" timestamptz,
    "period_end" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_team_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."referrals" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "source_encounter_id" uuid,
    "referring_profile_id" uuid,
    "target_profile_id" uuid,
    "target_tenant_id" uuid,
    "specialty_concept_id" uuid,
    "service_request_id" uuid,
    "reason_concept_id" uuid,
    "reason_text" text,
    "priority_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "valid_until" date,
    "responded_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_referrals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."clinical_alerts" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "alert_type_concept_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "source_resource_type" varchar,
    "source_resource_id" uuid,
    "trigger_concept_id" uuid,
    "rule_id" uuid,
    "detail_text" text,
    "status_concept_id" uuid NOT NULL,
    "overridden_by_user_id" uuid,
    "override_reason" text,
    "overridden_at" timestamptz,
    "detected_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_clinical_alerts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."virtual_encounters" (
    "id" uuid NOT NULL,
    "encounter_id" uuid NOT NULL,
    "platform_concept_id" uuid,
    "meeting_url" text,
    "meeting_id" varchar,
    "recording_file_id" uuid,
    "joined_at" timestamptz,
    "ended_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_virtual_encounters" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."cds_rules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "rule_type_concept_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "logic_json" jsonb,
    "message_template" text,
    "is_active" boolean NOT NULL,
    "version" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_cds_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."drug_interactions" (
    "id" uuid NOT NULL,
    "substance_a_concept_id" uuid NOT NULL,
    "substance_b_concept_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "mechanism_text" text,
    "management_text" text,
    "evidence_level_concept_id" uuid,
    "source" varchar,
    "source_version" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_drug_interactions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."reference_ranges" (
    "id" uuid NOT NULL,
    "code_concept_id" uuid NOT NULL,
    "unit_concept_id" uuid,
    "sex_concept_id" uuid,
    "age_min_days" integer,
    "age_max_days" integer,
    "condition_concept_id" uuid,
    "low_value" numeric,
    "high_value" numeric,
    "critical_low" numeric,
    "critical_high" numeric,
    "interpretation_text" text,
    "source" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_reference_ranges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."order_sets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "specialty_concept_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "condition_concept_id" uuid,
    "version" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_order_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."order_set_items" (
    "id" uuid NOT NULL,
    "order_set_id" uuid NOT NULL,
    "item_type_concept_id" uuid NOT NULL,
    "code_concept_id" uuid NOT NULL,
    "default_dose_text" varchar,
    "default_route_concept_id" uuid,
    "default_frequency_text" varchar,
    "is_selected_default" boolean,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_order_set_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."prescription_favorites" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "medication_concept_id" uuid NOT NULL,
    "substance_atc_concept_id" uuid,
    "dose_text" varchar,
    "route_concept_id" uuid,
    "frequency_text" varchar,
    "quantity_decimal" numeric,
    "unit_concept_id" uuid,
    "patient_instructions_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_prescription_favorites" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."immunization_schedules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "vaccine_concept_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "recommended_age_days" integer,
    "dose_number" integer,
    "interval_days" integer,
    "jurisdiction_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_immunization_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical_ext"."care_gaps" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "gap_type_concept_id" uuid NOT NULL,
    "measure_concept_id" uuid,
    "due_date" date,
    "status_concept_id" uuid NOT NULL,
    "closed_at" timestamptz,
    "closed_by_resource_type" varchar,
    "closed_by_resource_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_gaps" PRIMARY KEY ("id")
);
