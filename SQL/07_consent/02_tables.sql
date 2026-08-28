-- SALUD v4.0.10 · módulo 07 · schema consent
-- Generado de diagram_07_consent.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "consent"."processing_purposes" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "purpose_category_concept_id" uuid NOT NULL,
    "description" text,
    "purpose_of_use_concept_id" uuid,
    "default_retention_class_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_processing_purposes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."processing_legal_bases" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "processing_purpose_id" uuid NOT NULL,
    "jurisdiction_concept_id" uuid NOT NULL,
    "general_legal_basis_concept_id" uuid NOT NULL,
    "special_category_condition_concept_id" uuid,
    "policy_version" varchar,
    "legal_reference_uri" text,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_processing_legal_bases" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."consents" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "granted_by_user_id" uuid,
    "granted_by_related_person_id" uuid,
    "category_concept_id" uuid NOT NULL,
    "processing_purpose_id" uuid NOT NULL,
    "processing_legal_basis_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "policy_uri" text,
    "policy_version" varchar,
    "tenant_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "withdrawal_reason_concept_id" uuid,
    "withdrawn_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_consents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."consent_provisions" (
    "id" uuid NOT NULL,
    "consent_id" uuid NOT NULL,
    "provision_type_concept_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "data_class_concept_id" uuid,
    "actor_tenant_id" uuid,
    "actor_user_id" uuid,
    "actor_role_concept_id" uuid,
    "purpose_of_use_concept_id" uuid,
    "security_label_concept_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_consent_provisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."hipaa_authorizations" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "processing_purpose_id" uuid NOT NULL,
    "recipient_description" varchar NOT NULL,
    "information_description" text NOT NULL,
    "expiration_type_concept_id" uuid NOT NULL,
    "expires_at" timestamptz,
    "expiration_event_text" text,
    "status_concept_id" uuid NOT NULL,
    "signed_at" timestamptz,
    "revoked_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_hipaa_authorizations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."treatment_informed_consents" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "encounter_id" uuid NOT NULL,
    "procedure_code_concept_id" uuid,
    "information_version" varchar,
    "interpreter_user_id" uuid,
    "witness_user_id" uuid,
    "decision_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "signed_at" timestamptz,
    "withdrawn_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_treatment_informed_consents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."privacy_restrictions" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "restriction_type_concept_id" uuid NOT NULL,
    "data_class_concept_id" uuid NOT NULL,
    "target_actor_type_concept_id" uuid,
    "target_actor_id" uuid,
    "reason_text" text,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_privacy_restrictions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."patient_objections" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "processing_purpose_id" uuid NOT NULL,
    "objection_type_concept_id" uuid NOT NULL,
    "reason_text" text,
    "status_concept_id" uuid NOT NULL,
    "raised_at" timestamptz,
    "resolved_at" timestamptz,
    "resolution_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_objections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."consent_evidence" (
    "id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_id" uuid NOT NULL,
    "evidence_type_concept_id" uuid NOT NULL,
    "document_file_id" uuid,
    "signature_id" uuid,
    "captured_channel_concept_id" uuid,
    "policy_snapshot_hash" varchar,
    "evidence_hash" varchar,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_consent_evidence" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "consent"."consent_events" (
    "id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "previous_status_concept_id" uuid NOT NULL,
    "new_status_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "correlation_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_consent_events" PRIMARY KEY ("id")
);
