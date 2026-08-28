-- SALUD v4.0.10 · módulo 31 · schema integration_contracts
-- Generado de diagram_31_integration_contracts.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_integration_contracts_external_provider_id" ON "integration_contracts"."integration_contracts" ("external_provider_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_capability_concept_id" ON "integration_contracts"."integration_contracts" ("capability_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_data_classification_concept_id" ON "integration_contracts"."integration_contracts" ("data_classification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_legal_basis_concept_id" ON "integration_contracts"."integration_contracts" ("legal_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_allowed_purpose_value_set_id" ON "integration_contracts"."integration_contracts" ("allowed_purpose_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_data_use_agreement_id" ON "integration_contracts"."integration_contracts" ("data_use_agreement_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_status_concept_id" ON "integration_contracts"."integration_contracts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_created_by_user_id" ON "integration_contracts"."integration_contracts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_updated_by_user_id" ON "integration_contracts"."integration_contracts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contract_versions_integration_contract_id" ON "integration_contracts"."integration_contract_versions" ("integration_contract_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contract_versions_request_schema_file_id" ON "integration_contracts"."integration_contract_versions" ("request_schema_file_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contract_versions_response_schema_file_id" ON "integration_contracts"."integration_contract_versions" ("response_schema_file_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contract_versions_openapi_file_id" ON "integration_contracts"."integration_contract_versions" ("openapi_file_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contract_versions_mapping_profile_id" ON "integration_contracts"."integration_contract_versions" ("mapping_profile_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contract_versions_status_concept_id" ON "integration_contracts"."integration_contract_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_contract_versions_created_by_user_id" ON "integration_contracts"."integration_contract_versions" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_integration_contract_versions_integration_contract__74f90c0c" ON "integration_contracts"."integration_contract_versions" ("integration_contract_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_integration_auth_profiles_integration_contract_id" ON "integration_contracts"."integration_auth_profiles" ("integration_contract_id");

CREATE INDEX IF NOT EXISTS "ix_integration_auth_profiles_auth_profile_concept_id" ON "integration_contracts"."integration_auth_profiles" ("auth_profile_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_auth_profiles_token_binding_concept_id" ON "integration_contracts"."integration_auth_profiles" ("token_binding_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_auth_profiles_status_concept_id" ON "integration_contracts"."integration_auth_profiles" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_auth_profiles_created_by_user_id" ON "integration_contracts"."integration_auth_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_auth_profiles_updated_by_user_id" ON "integration_contracts"."integration_auth_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_records_integration_contract_version_id" ON "integration_contracts"."integration_exchange_records" ("integration_contract_version_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_records_direction_concept_id" ON "integration_contracts"."integration_exchange_records" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_records_message_type_concept_id" ON "integration_contracts"."integration_exchange_records" ("message_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_records_subject_type_concept_id" ON "integration_contracts"."integration_exchange_records" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_records_payload_file_id" ON "integration_contracts"."integration_exchange_records" ("payload_file_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_records_outcome_concept_id" ON "integration_contracts"."integration_exchange_records" ("outcome_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_integration_exchange_records_idempotency" ON "integration_contracts"."integration_exchange_records" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "brin_integration_exchange_records_created_at" ON "integration_contracts"."integration_exchange_records" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_attempts_integration_exchange_record_id" ON "integration_contracts"."integration_exchange_attempts" ("integration_exchange_record_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_attempts_endpoint_id" ON "integration_contracts"."integration_exchange_attempts" ("endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_attempts_retry_decision_concept_id" ON "integration_contracts"."integration_exchange_attempts" ("retry_decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_exchange_attempts_outcome_concept_id" ON "integration_contracts"."integration_exchange_attempts" ("outcome_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_integration_exchange_attempts_integration_exchange__2d126a36" ON "integration_contracts"."integration_exchange_attempts" ("integration_exchange_record_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "brin_integration_exchange_attempts_created_at" ON "integration_contracts"."integration_exchange_attempts" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_integration_idempotency_records_integration_contract_id" ON "integration_contracts"."integration_idempotency_records" ("integration_contract_id");

CREATE INDEX IF NOT EXISTS "ix_integration_idempotency_records_operation_concept_id" ON "integration_contracts"."integration_idempotency_records" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_idempotency_records_first_exchange_record_id" ON "integration_contracts"."integration_idempotency_records" ("first_exchange_record_id");

CREATE INDEX IF NOT EXISTS "ix_integration_idempotency_records_status_concept_id" ON "integration_contracts"."integration_idempotency_records" ("status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_integration_idempotency_records_idempotency" ON "integration_contracts"."integration_idempotency_records" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_integration_sync_cursors_integration_contract_id" ON "integration_contracts"."integration_sync_cursors" ("integration_contract_id");

CREATE INDEX IF NOT EXISTS "ix_integration_sync_cursors_last_successful_exchange_id" ON "integration_contracts"."integration_sync_cursors" ("last_successful_exchange_id");

CREATE INDEX IF NOT EXISTS "ix_integration_sync_cursors_status_concept_id" ON "integration_contracts"."integration_sync_cursors" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_webhook_subscriptions_integration_contract_id" ON "integration_contracts"."contract_webhook_subscriptions" ("integration_contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_webhook_subscriptions_event_type_concept_id" ON "integration_contracts"."contract_webhook_subscriptions" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_webhook_subscriptions_status_concept_id" ON "integration_contracts"."contract_webhook_subscriptions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_webhook_subscriptions_created_by_user_id" ON "integration_contracts"."contract_webhook_subscriptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_webhook_subscriptions_updated_by_user_id" ON "integration_contracts"."contract_webhook_subscriptions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_delivery_evidence_webhook_subscription_id" ON "integration_contracts"."webhook_delivery_evidence" ("webhook_subscription_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_delivery_evidence_integration_exchange_record_id" ON "integration_contracts"."webhook_delivery_evidence" ("integration_exchange_record_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_delivery_evidence_signature_verification_concept_id" ON "integration_contracts"."webhook_delivery_evidence" ("signature_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_delivery_evidence_outcome_concept_id" ON "integration_contracts"."webhook_delivery_evidence" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "brin_webhook_delivery_evidence_created_at" ON "integration_contracts"."webhook_delivery_evidence" USING brin ("created_at") WITH (pages_per_range=128);
