-- SALUD v4.0.10 · módulo 31 · schema integration_contracts
-- Generado de diagram_31_integration_contracts.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "integration_contracts"."integration_contracts" (
    "id" uuid NOT NULL,
    "external_provider_id" uuid NOT NULL,
    "contract_code" varchar NOT NULL,
    "capability_concept_id" uuid NOT NULL,
    "data_classification_concept_id" uuid,
    "legal_basis_concept_id" uuid,
    "allowed_purpose_value_set_id" uuid,
    "data_use_agreement_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_integration_contracts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."integration_contract_versions" (
    "id" uuid NOT NULL,
    "integration_contract_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "request_schema_file_id" uuid,
    "response_schema_file_id" uuid,
    "openapi_file_id" uuid,
    "mapping_profile_id" uuid,
    "effective_from" timestamptz,
    "effective_to" timestamptz,
    "contract_hash" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_integration_contract_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."integration_auth_profiles" (
    "id" uuid NOT NULL,
    "integration_contract_id" uuid NOT NULL,
    "auth_profile_concept_id" uuid NOT NULL,
    "oauth_issuer_uri" text,
    "client_identifier" varchar,
    "credential_secret_reference" text,
    "token_binding_concept_id" uuid,
    "mtls_certificate_reference" text,
    "dpop_key_reference" text,
    "scopes_json" jsonb,
    "audience" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_integration_auth_profiles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."integration_exchange_records" (
    "id" uuid NOT NULL,
    "integration_contract_version_id" uuid NOT NULL,
    "direction_concept_id" uuid NOT NULL,
    "message_type_concept_id" uuid NOT NULL,
    "business_identifier" varchar,
    "idempotency_key" varchar,
    "correlation_id" uuid,
    "subject_type_concept_id" uuid,
    "subject_entity_id" uuid,
    "request_hash" varchar,
    "response_hash" varchar,
    "payload_file_id" uuid,
    "received_at" timestamptz,
    "completed_at" timestamptz,
    "outcome_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_integration_exchange_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."integration_exchange_attempts" (
    "id" uuid NOT NULL,
    "integration_exchange_record_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "endpoint_id" uuid,
    "started_at" timestamptz,
    "completed_at" timestamptz,
    "http_status" integer,
    "provider_error_code" varchar,
    "retry_decision_concept_id" uuid,
    "next_retry_at" timestamptz,
    "trace_id" varchar,
    "outcome_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_integration_exchange_attempts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."integration_idempotency_records" (
    "id" uuid NOT NULL,
    "integration_contract_id" uuid NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "request_hash" varchar,
    "first_exchange_record_id" uuid,
    "response_reference" varchar,
    "expires_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_integration_idempotency_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."integration_sync_cursors" (
    "id" uuid NOT NULL,
    "integration_contract_id" uuid NOT NULL,
    "cursor_scope" varchar NOT NULL,
    "cursor_value" text NOT NULL,
    "watermark_at" timestamptz,
    "last_successful_exchange_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_integration_sync_cursors" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."contract_webhook_subscriptions" (
    "id" uuid NOT NULL,
    "integration_contract_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "callback_uri" text,
    "signing_key_reference" text,
    "secret_reference" text,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_webhook_subscriptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integration_contracts"."webhook_delivery_evidence" (
    "id" uuid NOT NULL,
    "webhook_subscription_id" uuid NOT NULL,
    "integration_exchange_record_id" uuid NOT NULL,
    "signature_algorithm" varchar,
    "signature_verification_concept_id" uuid,
    "delivered_at" timestamptz,
    "acknowledged_at" timestamptz,
    "outcome_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_webhook_delivery_evidence" PRIMARY KEY ("id")
);
