-- SALUD v4.0.10 · módulo 27 · schema identity_assurance
-- Generado de diagram_27_identity_assurance.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_authorities" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "authority_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "authority_type_concept_id" uuid NOT NULL,
    "jurisdiction_concept_id" uuid,
    "assurance_framework_concept_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_identity_authorities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_authority_endpoints" (
    "id" uuid NOT NULL,
    "identity_authority_id" uuid NOT NULL,
    "integration_endpoint_id" uuid NOT NULL,
    "capability_concept_id" uuid NOT NULL,
    "assurance_level_concept_id" uuid,
    "request_contract_version" varchar,
    "response_contract_version" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_identity_authority_endpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_verification_policies" (
    "id" uuid NOT NULL,
    "policy_code" varchar NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "transaction_risk_concept_id" uuid NOT NULL,
    "required_identity_assurance_level_concept_id" uuid NOT NULL,
    "required_authenticator_assurance_level_concept_id" uuid,
    "required_federation_assurance_level_concept_id" uuid,
    "evidence_requirements_json" jsonb,
    "fraud_controls_json" jsonb,
    "version_number" integer NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_identity_verification_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_verification_cases" (
    "id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_entity_id" uuid NOT NULL,
    "identity_verification_policy_id" uuid NOT NULL,
    "requested_assurance_level_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "risk_score" numeric,
    "opened_at" timestamptz,
    "completed_at" timestamptz,
    "expires_at" timestamptz,
    "correlation_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_identity_verification_cases" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_evidence_records" (
    "id" uuid NOT NULL,
    "identity_verification_case_id" uuid NOT NULL,
    "evidence_type_concept_id" uuid NOT NULL,
    "issuer_authority_id" uuid,
    "evidence_identifier_hash" varchar,
    "evidence_file_id" uuid,
    "encrypted_evidence_reference" text,
    "evidence_quality_concept_id" uuid,
    "issued_at" timestamptz,
    "expires_at" timestamptz,
    "collected_under_consent_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_identity_evidence_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_verification_attempts" (
    "id" uuid NOT NULL,
    "identity_verification_case_id" uuid NOT NULL,
    "identity_authority_endpoint_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "request_message_id" uuid,
    "response_message_id" uuid,
    "idempotency_key" varchar,
    "started_at" timestamptz,
    "completed_at" timestamptz,
    "outcome_concept_id" uuid NOT NULL,
    "technical_error_code" varchar,
    "retry_eligible" boolean,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_identity_verification_attempts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_checks" (
    "id" uuid NOT NULL,
    "identity_verification_case_id" uuid NOT NULL,
    "check_type_concept_id" uuid NOT NULL,
    "authority_id" uuid,
    "required" boolean,
    "check_sequence" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_identity_checks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_check_results" (
    "id" uuid NOT NULL,
    "identity_check_id" uuid NOT NULL,
    "result_version" integer NOT NULL,
    "result_concept_id" uuid NOT NULL,
    "match_score" numeric,
    "discrepancy_codes_json" jsonb,
    "source_response_hash" varchar,
    "supersedes_result_id" uuid,
    "checked_at" timestamptz NOT NULL,
    "checked_by_actor_type_concept_id" uuid,
    "checked_by_actor_id" uuid,
    CONSTRAINT "pk_identity_check_results" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_assertions" (
    "id" uuid NOT NULL,
    "identity_verification_case_id" uuid NOT NULL,
    "issuer_identity_authority_id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_entity_id" uuid NOT NULL,
    "assertion_type_concept_id" uuid NOT NULL,
    "assurance_level_concept_id" uuid NOT NULL,
    "assertion_identifier" varchar,
    "assertion_hash" varchar,
    "issued_at" timestamptz,
    "expires_at" timestamptz,
    "revoked_at" timestamptz,
    "revocation_reason_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_identity_assertions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_fraud_signals" (
    "id" uuid NOT NULL,
    "identity_verification_case_id" uuid NOT NULL,
    "signal_type_concept_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "confidence_score" numeric,
    "source_concept_id" uuid,
    "evidence_reference" varchar,
    "detected_at" timestamptz,
    "resolved_at" timestamptz,
    "resolution_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_identity_fraud_signals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "identity_assurance"."identity_manual_review_cases" (
    "id" uuid NOT NULL,
    "identity_verification_case_id" uuid NOT NULL,
    "review_reason_concept_id" uuid NOT NULL,
    "assigned_to_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "opened_at" timestamptz,
    "decided_at" timestamptz,
    "decision_concept_id" uuid,
    "decision_reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_identity_manual_review_cases" PRIMARY KEY ("id")
);
