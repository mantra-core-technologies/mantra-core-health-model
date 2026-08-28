-- SALUD v4.0.10 · módulo 27 · schema identity_assurance
-- Generado de diagram_27_identity_assurance.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_authority_type_concept_id" FOREIGN KEY ("authority_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_assurance_framework_concept_id" FOREIGN KEY ("assurance_framework_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authorities"
        ADD CONSTRAINT "fk_identity_authorities_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.integration_endpoints (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authority_endpoints"
        ADD CONSTRAINT "fk_identity_authority_endpoints_integration_endpoint_id" FOREIGN KEY ("integration_endpoint_id")
        REFERENCES "integrations"."integration_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authority_endpoints"
        ADD CONSTRAINT "fk_identity_authority_endpoints_capability_concept_id" FOREIGN KEY ("capability_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authority_endpoints"
        ADD CONSTRAINT "fk_identity_authority_endpoints_assurance_level_concept_id" FOREIGN KEY ("assurance_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authority_endpoints"
        ADD CONSTRAINT "fk_identity_authority_endpoints_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authority_endpoints"
        ADD CONSTRAINT "fk_identity_authority_endpoints_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authority_endpoints"
        ADD CONSTRAINT "fk_identity_authority_endpoints_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_policies"
        ADD CONSTRAINT "fk_identity_verification_policies_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_policies"
        ADD CONSTRAINT "fk_identity_verification_policies_transaction_risk_concept_id" FOREIGN KEY ("transaction_risk_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_policies"
        ADD CONSTRAINT "fk_identity_verification_policies_required_identity_as_75460293" FOREIGN KEY ("required_identity_assurance_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_policies"
        ADD CONSTRAINT "fk_identity_verification_policies_required_authenticat_3b11417d" FOREIGN KEY ("required_authenticator_assurance_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_policies"
        ADD CONSTRAINT "fk_identity_verification_policies_required_federation__a77e7044" FOREIGN KEY ("required_federation_assurance_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_policies"
        ADD CONSTRAINT "fk_identity_verification_policies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_policies"
        ADD CONSTRAINT "fk_identity_verification_policies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_cases"
        ADD CONSTRAINT "fk_identity_verification_cases_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_cases"
        ADD CONSTRAINT "fk_identity_verification_cases_requested_assurance_lev_ee8e6b18" FOREIGN KEY ("requested_assurance_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_cases"
        ADD CONSTRAINT "fk_identity_verification_cases_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_cases"
        ADD CONSTRAINT "fk_identity_verification_cases_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_cases"
        ADD CONSTRAINT "fk_identity_verification_cases_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_evidence_type_concept_id" FOREIGN KEY ("evidence_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_evidence_quality_concept_id" FOREIGN KEY ("evidence_quality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: consent.consents (requiere schema consent)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_collected_under_consent_id" FOREIGN KEY ("collected_under_consent_id")
        REFERENCES "consent"."consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.outbound_messages (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_attempts"
        ADD CONSTRAINT "fk_identity_verification_attempts_request_message_id" FOREIGN KEY ("request_message_id")
        REFERENCES "integrations"."outbound_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.inbound_messages (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_attempts"
        ADD CONSTRAINT "fk_identity_verification_attempts_response_message_id" FOREIGN KEY ("response_message_id")
        REFERENCES "integrations"."inbound_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_attempts"
        ADD CONSTRAINT "fk_identity_verification_attempts_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_checks"
        ADD CONSTRAINT "fk_identity_checks_check_type_concept_id" FOREIGN KEY ("check_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_checks"
        ADD CONSTRAINT "fk_identity_checks_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_checks"
        ADD CONSTRAINT "fk_identity_checks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_checks"
        ADD CONSTRAINT "fk_identity_checks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_check_results"
        ADD CONSTRAINT "fk_identity_check_results_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_check_results"
        ADD CONSTRAINT "fk_identity_check_results_checked_by_actor_type_concept_id" FOREIGN KEY ("checked_by_actor_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_assertions"
        ADD CONSTRAINT "fk_identity_assertions_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_assertions"
        ADD CONSTRAINT "fk_identity_assertions_assertion_type_concept_id" FOREIGN KEY ("assertion_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_assertions"
        ADD CONSTRAINT "fk_identity_assertions_assurance_level_concept_id" FOREIGN KEY ("assurance_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_assertions"
        ADD CONSTRAINT "fk_identity_assertions_revocation_reason_concept_id" FOREIGN KEY ("revocation_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_fraud_signals"
        ADD CONSTRAINT "fk_identity_fraud_signals_signal_type_concept_id" FOREIGN KEY ("signal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_fraud_signals"
        ADD CONSTRAINT "fk_identity_fraud_signals_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_fraud_signals"
        ADD CONSTRAINT "fk_identity_fraud_signals_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_fraud_signals"
        ADD CONSTRAINT "fk_identity_fraud_signals_resolution_concept_id" FOREIGN KEY ("resolution_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_manual_review_cases"
        ADD CONSTRAINT "fk_identity_manual_review_cases_review_reason_concept_id" FOREIGN KEY ("review_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_manual_review_cases"
        ADD CONSTRAINT "fk_identity_manual_review_cases_assigned_to_user_id" FOREIGN KEY ("assigned_to_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_manual_review_cases"
        ADD CONSTRAINT "fk_identity_manual_review_cases_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_manual_review_cases"
        ADD CONSTRAINT "fk_identity_manual_review_cases_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_manual_review_cases"
        ADD CONSTRAINT "fk_identity_manual_review_cases_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_manual_review_cases"
        ADD CONSTRAINT "fk_identity_manual_review_cases_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
