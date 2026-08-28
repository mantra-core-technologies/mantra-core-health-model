-- SALUD v4.0.10 · módulo 31 · schema integration_contracts
-- Generado de diagram_31_integration_contracts.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   integration_contracts.data_use_agreement_id


-- destino: integrations.external_providers (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_external_provider_id" FOREIGN KEY ("external_provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_capability_concept_id" FOREIGN KEY ("capability_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_data_classification_concept_id" FOREIGN KEY ("data_classification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_legal_basis_concept_id" FOREIGN KEY ("legal_basis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_allowed_purpose_value_set_id" FOREIGN KEY ("allowed_purpose_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contract_versions"
        ADD CONSTRAINT "fk_integration_contract_versions_request_schema_file_id" FOREIGN KEY ("request_schema_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contract_versions"
        ADD CONSTRAINT "fk_integration_contract_versions_response_schema_file_id" FOREIGN KEY ("response_schema_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contract_versions"
        ADD CONSTRAINT "fk_integration_contract_versions_openapi_file_id" FOREIGN KEY ("openapi_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contract_versions"
        ADD CONSTRAINT "fk_integration_contract_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contract_versions"
        ADD CONSTRAINT "fk_integration_contract_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_auth_profiles"
        ADD CONSTRAINT "fk_integration_auth_profiles_auth_profile_concept_id" FOREIGN KEY ("auth_profile_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_auth_profiles"
        ADD CONSTRAINT "fk_integration_auth_profiles_token_binding_concept_id" FOREIGN KEY ("token_binding_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_auth_profiles"
        ADD CONSTRAINT "fk_integration_auth_profiles_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_auth_profiles"
        ADD CONSTRAINT "fk_integration_auth_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_auth_profiles"
        ADD CONSTRAINT "fk_integration_auth_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_records"
        ADD CONSTRAINT "fk_integration_exchange_records_direction_concept_id" FOREIGN KEY ("direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_records"
        ADD CONSTRAINT "fk_integration_exchange_records_message_type_concept_id" FOREIGN KEY ("message_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_records"
        ADD CONSTRAINT "fk_integration_exchange_records_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_records"
        ADD CONSTRAINT "fk_integration_exchange_records_payload_file_id" FOREIGN KEY ("payload_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_records"
        ADD CONSTRAINT "fk_integration_exchange_records_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.integration_endpoints (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_attempts"
        ADD CONSTRAINT "fk_integration_exchange_attempts_endpoint_id" FOREIGN KEY ("endpoint_id")
        REFERENCES "integrations"."integration_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_attempts"
        ADD CONSTRAINT "fk_integration_exchange_attempts_retry_decision_concept_id" FOREIGN KEY ("retry_decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_attempts"
        ADD CONSTRAINT "fk_integration_exchange_attempts_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_idempotency_records"
        ADD CONSTRAINT "fk_integration_idempotency_records_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_idempotency_records"
        ADD CONSTRAINT "fk_integration_idempotency_records_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_sync_cursors"
        ADD CONSTRAINT "fk_integration_sync_cursors_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."contract_webhook_subscriptions"
        ADD CONSTRAINT "fk_contract_webhook_subscriptions_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."contract_webhook_subscriptions"
        ADD CONSTRAINT "fk_contract_webhook_subscriptions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."contract_webhook_subscriptions"
        ADD CONSTRAINT "fk_contract_webhook_subscriptions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."contract_webhook_subscriptions"
        ADD CONSTRAINT "fk_contract_webhook_subscriptions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.webhook_subscriptions (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."webhook_delivery_evidence"
        ADD CONSTRAINT "fk_webhook_delivery_evidence_webhook_subscription_id" FOREIGN KEY ("webhook_subscription_id")
        REFERENCES "integrations"."webhook_subscriptions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."webhook_delivery_evidence"
        ADD CONSTRAINT "fk_webhook_delivery_evidence_signature_verification_concept_id" FOREIGN KEY ("signature_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."webhook_delivery_evidence"
        ADD CONSTRAINT "fk_webhook_delivery_evidence_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
