-- SALUD v4.0.10 · módulo 27 · schema identity_assurance
-- Generado de diagram_27_identity_assurance.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_authority_endpoints"
        ADD CONSTRAINT "fk_identity_authority_endpoints_identity_authority_id" FOREIGN KEY ("identity_authority_id")
        REFERENCES "identity_assurance"."identity_authorities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_cases"
        ADD CONSTRAINT "fk_identity_verification_cases_identity_verification_policy_id" FOREIGN KEY ("identity_verification_policy_id")
        REFERENCES "identity_assurance"."identity_verification_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_identity_verification_case_id" FOREIGN KEY ("identity_verification_case_id")
        REFERENCES "identity_assurance"."identity_verification_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_evidence_records"
        ADD CONSTRAINT "fk_identity_evidence_records_issuer_authority_id" FOREIGN KEY ("issuer_authority_id")
        REFERENCES "identity_assurance"."identity_authorities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_attempts"
        ADD CONSTRAINT "fk_identity_verification_attempts_identity_verification_case_id" FOREIGN KEY ("identity_verification_case_id")
        REFERENCES "identity_assurance"."identity_verification_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_attempts"
        ADD CONSTRAINT "fk_identity_verification_attempts_identity_authority_e_91da2d59" FOREIGN KEY ("identity_authority_endpoint_id")
        REFERENCES "identity_assurance"."identity_authority_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_checks"
        ADD CONSTRAINT "fk_identity_checks_identity_verification_case_id" FOREIGN KEY ("identity_verification_case_id")
        REFERENCES "identity_assurance"."identity_verification_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_checks"
        ADD CONSTRAINT "fk_identity_checks_authority_id" FOREIGN KEY ("authority_id")
        REFERENCES "identity_assurance"."identity_authorities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_check_results"
        ADD CONSTRAINT "fk_identity_check_results_identity_check_id" FOREIGN KEY ("identity_check_id")
        REFERENCES "identity_assurance"."identity_checks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_check_results"
        ADD CONSTRAINT "fk_identity_check_results_supersedes_result_id" FOREIGN KEY ("supersedes_result_id")
        REFERENCES "identity_assurance"."identity_check_results" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_assertions"
        ADD CONSTRAINT "fk_identity_assertions_identity_verification_case_id" FOREIGN KEY ("identity_verification_case_id")
        REFERENCES "identity_assurance"."identity_verification_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_assertions"
        ADD CONSTRAINT "fk_identity_assertions_issuer_identity_authority_id" FOREIGN KEY ("issuer_identity_authority_id")
        REFERENCES "identity_assurance"."identity_authorities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_fraud_signals"
        ADD CONSTRAINT "fk_identity_fraud_signals_identity_verification_case_id" FOREIGN KEY ("identity_verification_case_id")
        REFERENCES "identity_assurance"."identity_verification_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_manual_review_cases"
        ADD CONSTRAINT "fk_identity_manual_review_cases_identity_verification_case_id" FOREIGN KEY ("identity_verification_case_id")
        REFERENCES "identity_assurance"."identity_verification_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
