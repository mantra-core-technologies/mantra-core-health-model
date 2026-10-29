-- SALUD v4.0.10 · módulo 05 · schema profiles
-- Generado de diagram_05_profiles.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "profiles"."persons" (
    "id" uuid NOT NULL,
    "person_status_concept_id" uuid NOT NULL,
    "name" varchar,
    "middle_name" varchar,
    "last_name" varchar,
    "mother_last_name" varchar,
    "display_name" varchar,
    "photo_file_id" uuid,
    "birth_date" date,
    "administrative_gender_concept_id" uuid,
    "sex_at_birth_concept_id" uuid,
    "gender_identity_concept_id" uuid,
    "vital_status_concept_id" uuid,
    "deceased_at" timestamptz,
    "nationality_concept_id" uuid,
    "preferred_language_concept_id" uuid,
    "occupation_concept_id" uuid,
    "occupation_free_text" varchar,
    "work_employer_concept_id" uuid,
    "work_employer_free_text" varchar,
    "merge_survivor_person_id" uuid,
    "anonymized_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_persons" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."person_account_links" (
    "id" uuid NOT NULL,
    "person_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "link_type_concept_id" uuid NOT NULL,
    "verification_status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_person_account_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."person_profiles" (
    "id" uuid NOT NULL,
    "person_id" uuid NOT NULL,
    "profile_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_person_profiles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."patient_profiles" (
    "profile_id" uuid NOT NULL,
    "patient_code" varchar NOT NULL,
    "master_patient_index_code" varchar,
    "abo_group_concept_id" uuid,
    "rh_factor_concept_id" uuid,
    "insurance_status_concept_id" uuid,
    "clinical_language_concept_id" uuid,
    "record_linkage_status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_profiles" PRIMARY KEY ("profile_id")
);

CREATE TABLE IF NOT EXISTS "profiles"."patient_identity_links" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "source_tenant_id" uuid NOT NULL,
    "source_patient_identifier" varchar NOT NULL,
    "source_system_uri" text,
    "link_type_concept_id" uuid NOT NULL,
    "confidence_score" numeric NOT NULL,
    "verification_status_concept_id" uuid NOT NULL,
    "verified_by_user_id" uuid,
    "verified_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_identity_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."patient_merge_events" (
    "id" uuid NOT NULL,
    "surviving_patient_profile_id" uuid NOT NULL,
    "merged_patient_profile_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "decision_status_concept_id" uuid NOT NULL,
    "approved_by_user_id" uuid,
    "reversal_of_event_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_patient_merge_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."health_practitioner_profiles" (
    "profile_id" uuid NOT NULL,
    "practitioner_code" varchar NOT NULL,
    "practitioner_category_concept_id" uuid NOT NULL,
    "professional_title" varchar,
    "verification_status_concept_id" uuid NOT NULL,
    "practice_status_concept_id" uuid NOT NULL,
    "professional_bio" text,
    "photo_file_id" uuid,
    "signature_file_id" uuid,
    "seal_file_id" uuid,
    "accepts_new_patients" boolean,
    "telehealth_available" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_practitioner_profiles" PRIMARY KEY ("profile_id")
);

CREATE TABLE IF NOT EXISTS "profiles"."professional_credentials" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "credential_type_concept_id" uuid NOT NULL,
    "number" varchar NOT NULL,
    "issuing_authority_tenant_id" uuid,
    "issuing_institution_text" varchar,
    "issuing_country_concept_id" uuid,
    "issuing_city_text" varchar,
    "issuing_country_text" varchar,
    "profession_concept_id" uuid,
    "title_text" varchar,
    "issue_date" date,
    "expiry_date" date,
    "state_concept_id" uuid NOT NULL,
    "file_id" uuid,
    "verification_source_uri" text,
    "verified_by_user_id" uuid,
    "verified_at" timestamptz,
    "rejection_reason_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_professional_credentials" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_specialties" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "specialty_concept_id" uuid NOT NULL,
    "supporting_credential_id" uuid,
    "specialty_role_concept_id" uuid,
    "is_primary" boolean,
    "board_certified" boolean,
    "practice_scope_text" text,
    "verification_status_concept_id" uuid NOT NULL,
    "verified_at" timestamptz,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_specialties" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_languages" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "language_concept_id" uuid NOT NULL,
    "proficiency_concept_id" uuid,
    "clinical_interpretation_allowed" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_languages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."jurisdiction_authorizations" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "jurisdiction_concept_id" uuid NOT NULL,
    "license_number" varchar NOT NULL,
    "regulatory_authority" varchar,
    "practice_scope_concept_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "valid_from" date,
    "valid_to" date,
    "file_id" uuid,
    "verified_by_user_id" uuid,
    "verified_at" timestamptz,
    "verification_source_uri" text,
    "rejection_reason_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_jurisdiction_authorizations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_affiliations" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "organization_name" varchar NOT NULL,
    "practice_site_id" uuid,
    "health_facility_concept_id" uuid,
    "role_title" varchar,
    "department_text" varchar,
    "affiliation_type_concept_id" uuid,
    "start_date" date NOT NULL,
    "end_date" date,
    "status_concept_id" uuid NOT NULL,
    "decision_reason_text" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_affiliations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."related_persons" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "person_id" uuid NOT NULL,
    "relationship_concept_id" uuid NOT NULL,
    "is_emergency_contact" boolean NOT NULL,
    "is_legal_guardian" boolean NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_related_persons" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."patient_portal_proxies" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "proxy_user_id" uuid NOT NULL,
    "related_person_id" uuid,
    "scope_value_set_id" uuid NOT NULL,
    "legal_basis_record_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_portal_proxies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."patient_primary_practitioners" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_primary_practitioners" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."admission_requirements" (
    "id" uuid NOT NULL,
    "admission_type_concept_id" uuid NOT NULL,
    "requirement_code" varchar NOT NULL,
    "label" varchar NOT NULL,
    "description" text,
    "item_type_concept_id" uuid NOT NULL,
    "item_subtype_code" varchar,
    "evidence_kind_concept_id" uuid NOT NULL,
    "verification_method_concept_id" uuid NOT NULL,
    "is_required" boolean NOT NULL DEFAULT true,
    "requires_source_uri" boolean NOT NULL DEFAULT true,
    "applies_to_profession_group" varchar,
    "min_items" smallint,
    "max_items" smallint,
    "sort_order" integer NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_admission_requirements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_admissions" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "admission_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "submitted_at" timestamptz NOT NULL,
    "due_at" timestamptz NOT NULL,
    "assigned_to_user_id" uuid,
    "decided_at" timestamptz,
    "decided_by_user_id" uuid,
    "decision_reason_text" text,
    "decision_reason_code_concept_id" uuid,
    "internal_note" text,
    "info_requested_text" text,
    "info_due_at" timestamptz,
    "resubmission_count" integer NOT NULL,
    "valid_until" date,
    "four_eyes_waived" boolean,
    "attested_at" timestamptz,
    "attestation_text_version" varchar,
    "closed_at" timestamptz,
    "submitted_snapshot" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_admissions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_admission_reviews" (
    "id" uuid NOT NULL,
    "admission_id" uuid NOT NULL,
    "requirement_id" uuid NOT NULL,
    "item_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "file_id" uuid,
    "verification_source_uri" text,
    "source_type_concept_id" uuid,
    "source_ref" text,
    "source_consulted_at" timestamptz,
    "evidence_sha256" varchar,
    "reason_code_concept_id" uuid,
    "reason_text" text,
    "internal_note" text,
    "reviewed_by_user_id" uuid,
    "reviewed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_admission_reviews" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_admission_events" (
    "id" uuid NOT NULL,
    "admission_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "from_status_concept_id" uuid,
    "to_status_concept_id" uuid,
    "item_type_concept_id" uuid,
    "item_id" uuid,
    "requirement_id" uuid,
    "verification_source_uri" text,
    "reason_code_concept_id" uuid,
    "reason_text" text,
    "actor_user_id" uuid,
    "actor_role_code" varchar,
    "request_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_practitioner_admission_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."insurance_representative_profiles" (
    "profile_id" uuid NOT NULL,
    "representative_type_concept_id" uuid NOT NULL,
    "role_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_representative_profiles" PRIMARY KEY ("profile_id")
);

CREATE TABLE IF NOT EXISTS "profiles"."provider_operator_profiles" (
    "profile_id" uuid NOT NULL,
    "operator_type_concept_id" uuid NOT NULL,
    "role_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_operator_profiles" PRIMARY KEY ("profile_id")
);

CREATE TABLE IF NOT EXISTS "profiles"."emergency_staff_profiles" (
    "profile_id" uuid NOT NULL,
    "staff_type_concept_id" uuid NOT NULL,
    "availability_status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_emergency_staff_profiles" PRIMARY KEY ("profile_id")
);

CREATE TABLE IF NOT EXISTS "profiles"."administrator_profiles" (
    "profile_id" uuid NOT NULL,
    "administrator_type_concept_id" uuid NOT NULL,
    "administrative_level_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_administrator_profiles" PRIMARY KEY ("profile_id")
);

CREATE TABLE IF NOT EXISTS "profiles"."secretary_profiles" (
    "profile_id" uuid NOT NULL,
    "role_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_secretary_profiles" PRIMARY KEY ("profile_id")
);
