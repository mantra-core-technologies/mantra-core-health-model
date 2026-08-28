-- SALUD v4.0.10 · módulo 27 · schema identity_assurance
-- Generado de diagram_27_identity_assurance.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_identity_authorities_authority_code" ON "identity_assurance"."identity_authorities" ("authority_code");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_tenant_id" ON "identity_assurance"."identity_authorities" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_authority_type_concept_id" ON "identity_assurance"."identity_authorities" ("authority_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_jurisdiction_concept_id" ON "identity_assurance"."identity_authorities" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_assurance_framework_concept_id" ON "identity_assurance"."identity_authorities" ("assurance_framework_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_verification_status_concept_id" ON "identity_assurance"."identity_authorities" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_status_concept_id" ON "identity_assurance"."identity_authorities" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_created_by_user_id" ON "identity_assurance"."identity_authorities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_updated_by_user_id" ON "identity_assurance"."identity_authorities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authorities_tenant_id_status_concept_id" ON "identity_assurance"."identity_authorities" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_identity_authority_endpoints_identity_authority_id" ON "identity_assurance"."identity_authority_endpoints" ("identity_authority_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authority_endpoints_integration_endpoint_id" ON "identity_assurance"."identity_authority_endpoints" ("integration_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authority_endpoints_capability_concept_id" ON "identity_assurance"."identity_authority_endpoints" ("capability_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authority_endpoints_assurance_level_concept_id" ON "identity_assurance"."identity_authority_endpoints" ("assurance_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authority_endpoints_status_concept_id" ON "identity_assurance"."identity_authority_endpoints" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authority_endpoints_created_by_user_id" ON "identity_assurance"."identity_authority_endpoints" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_authority_endpoints_updated_by_user_id" ON "identity_assurance"."identity_authority_endpoints" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_identity_verification_policies_policy_code" ON "identity_assurance"."identity_verification_policies" ("policy_code");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_policies_subject_type_concept_id" ON "identity_assurance"."identity_verification_policies" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_policies_transaction_risk_concept_id" ON "identity_assurance"."identity_verification_policies" ("transaction_risk_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_policies_required_identity_as_c2e6ce75" ON "identity_assurance"."identity_verification_policies" ("required_identity_assurance_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_policies_required_authenticat_2f8a398a" ON "identity_assurance"."identity_verification_policies" ("required_authenticator_assurance_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_policies_required_federation__a44c44f2" ON "identity_assurance"."identity_verification_policies" ("required_federation_assurance_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_policies_status_concept_id" ON "identity_assurance"."identity_verification_policies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_policies_created_by_user_id" ON "identity_assurance"."identity_verification_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_cases_subject_type_concept_id" ON "identity_assurance"."identity_verification_cases" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_cases_identity_verification_policy_id" ON "identity_assurance"."identity_verification_cases" ("identity_verification_policy_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_cases_requested_assurance_lev_ebd923e4" ON "identity_assurance"."identity_verification_cases" ("requested_assurance_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_cases_status_concept_id" ON "identity_assurance"."identity_verification_cases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_cases_created_by_user_id" ON "identity_assurance"."identity_verification_cases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_cases_updated_by_user_id" ON "identity_assurance"."identity_verification_cases" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_identity_verification_case_id" ON "identity_assurance"."identity_evidence_records" ("identity_verification_case_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_evidence_type_concept_id" ON "identity_assurance"."identity_evidence_records" ("evidence_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_issuer_authority_id" ON "identity_assurance"."identity_evidence_records" ("issuer_authority_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_evidence_file_id" ON "identity_assurance"."identity_evidence_records" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_evidence_quality_concept_id" ON "identity_assurance"."identity_evidence_records" ("evidence_quality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_collected_under_consent_id" ON "identity_assurance"."identity_evidence_records" ("collected_under_consent_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_verification_status_concept_id" ON "identity_assurance"."identity_evidence_records" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_evidence_records_created_by_user_id" ON "identity_assurance"."identity_evidence_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_attempts_identity_verification_case_id" ON "identity_assurance"."identity_verification_attempts" ("identity_verification_case_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_attempts_identity_authority_e_96e7ce47" ON "identity_assurance"."identity_verification_attempts" ("identity_authority_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_attempts_request_message_id" ON "identity_assurance"."identity_verification_attempts" ("request_message_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_attempts_response_message_id" ON "identity_assurance"."identity_verification_attempts" ("response_message_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_attempts_outcome_concept_id" ON "identity_assurance"."identity_verification_attempts" ("outcome_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_identity_verification_attempts_identity_verificatio_905f086b" ON "identity_assurance"."identity_verification_attempts" ("identity_verification_case_id", "attempt_number");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_identity_verification_attempts_idempotency" ON "identity_assurance"."identity_verification_attempts" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_identity_checks_identity_verification_case_id" ON "identity_assurance"."identity_checks" ("identity_verification_case_id");

CREATE INDEX IF NOT EXISTS "ix_identity_checks_check_type_concept_id" ON "identity_assurance"."identity_checks" ("check_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_checks_authority_id" ON "identity_assurance"."identity_checks" ("authority_id");

CREATE INDEX IF NOT EXISTS "ix_identity_checks_status_concept_id" ON "identity_assurance"."identity_checks" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_checks_created_by_user_id" ON "identity_assurance"."identity_checks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_checks_updated_by_user_id" ON "identity_assurance"."identity_checks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_check_results_identity_check_id" ON "identity_assurance"."identity_check_results" ("identity_check_id");

CREATE INDEX IF NOT EXISTS "ix_identity_check_results_result_concept_id" ON "identity_assurance"."identity_check_results" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_check_results_supersedes_result_id" ON "identity_assurance"."identity_check_results" ("supersedes_result_id");

CREATE INDEX IF NOT EXISTS "ix_identity_check_results_checked_by_actor_type_concept_id" ON "identity_assurance"."identity_check_results" ("checked_by_actor_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_assertions_identity_verification_case_id" ON "identity_assurance"."identity_assertions" ("identity_verification_case_id");

CREATE INDEX IF NOT EXISTS "ix_identity_assertions_issuer_identity_authority_id" ON "identity_assurance"."identity_assertions" ("issuer_identity_authority_id");

CREATE INDEX IF NOT EXISTS "ix_identity_assertions_subject_type_concept_id" ON "identity_assurance"."identity_assertions" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_assertions_assertion_type_concept_id" ON "identity_assurance"."identity_assertions" ("assertion_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_assertions_assurance_level_concept_id" ON "identity_assurance"."identity_assertions" ("assurance_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_assertions_revocation_reason_concept_id" ON "identity_assurance"."identity_assertions" ("revocation_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_identity_assertions_created_at" ON "identity_assurance"."identity_assertions" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_identity_fraud_signals_identity_verification_case_id" ON "identity_assurance"."identity_fraud_signals" ("identity_verification_case_id");

CREATE INDEX IF NOT EXISTS "ix_identity_fraud_signals_signal_type_concept_id" ON "identity_assurance"."identity_fraud_signals" ("signal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_fraud_signals_severity_concept_id" ON "identity_assurance"."identity_fraud_signals" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_fraud_signals_source_concept_id" ON "identity_assurance"."identity_fraud_signals" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_fraud_signals_resolution_concept_id" ON "identity_assurance"."identity_fraud_signals" ("resolution_concept_id");

CREATE INDEX IF NOT EXISTS "brin_identity_fraud_signals_created_at" ON "identity_assurance"."identity_fraud_signals" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_identity_manual_review_cases_identity_verification_case_id" ON "identity_assurance"."identity_manual_review_cases" ("identity_verification_case_id");

CREATE INDEX IF NOT EXISTS "ix_identity_manual_review_cases_review_reason_concept_id" ON "identity_assurance"."identity_manual_review_cases" ("review_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_manual_review_cases_assigned_to_user_id" ON "identity_assurance"."identity_manual_review_cases" ("assigned_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_manual_review_cases_status_concept_id" ON "identity_assurance"."identity_manual_review_cases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_manual_review_cases_decision_concept_id" ON "identity_assurance"."identity_manual_review_cases" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_manual_review_cases_created_by_user_id" ON "identity_assurance"."identity_manual_review_cases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_manual_review_cases_updated_by_user_id" ON "identity_assurance"."identity_manual_review_cases" ("updated_by_user_id");
