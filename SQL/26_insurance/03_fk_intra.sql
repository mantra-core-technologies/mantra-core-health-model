-- SALUD v4.0.10 · módulo 26 · schema insurance
-- Generado de diagram_26_insurance.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_insurance_broker_id" FOREIGN KEY ("insurance_broker_id")
        REFERENCES "insurance"."insurance_brokers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_products"
        ADD CONSTRAINT "fk_insurance_products_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plans"
        ADD CONSTRAINT "fk_insurance_plans_insurance_product_id" FOREIGN KEY ("insurance_product_id")
        REFERENCES "insurance"."insurance_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plan_benefits"
        ADD CONSTRAINT "fk_insurance_plan_benefits_insurance_plan_id" FOREIGN KEY ("insurance_plan_id")
        REFERENCES "insurance"."insurance_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."provider_networks"
        ADD CONSTRAINT "fk_provider_networks_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_provider_network_id" FOREIGN KEY ("provider_network_id")
        REFERENCES "insurance"."provider_networks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_insurance_plan_id" FOREIGN KEY ("insurance_plan_id")
        REFERENCES "insurance"."insurance_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_insurance_broker_id" FOREIGN KEY ("insurance_broker_id")
        REFERENCES "insurance"."insurance_brokers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_employer_group_id" FOREIGN KEY ("employer_group_id")
        REFERENCES "insurance"."employer_groups" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_dependents"
        ADD CONSTRAINT "fk_coverage_dependents_patient_coverage_id" FOREIGN KEY ("patient_coverage_id")
        REFERENCES "insurance"."patient_coverages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_insurance_broker_id" FOREIGN KEY ("insurance_broker_id")
        REFERENCES "insurance"."insurance_brokers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_employer_group_id" FOREIGN KEY ("employer_group_id")
        REFERENCES "insurance"."employer_groups" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_requests"
        ADD CONSTRAINT "fk_coverage_eligibility_requests_patient_coverage_id" FOREIGN KEY ("patient_coverage_id")
        REFERENCES "insurance"."patient_coverages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_responses"
        ADD CONSTRAINT "fk_coverage_eligibility_responses_coverage_eligibility_13062047" FOREIGN KEY ("coverage_eligibility_request_id")
        REFERENCES "insurance"."coverage_eligibility_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_patient_coverage_id" FOREIGN KEY ("patient_coverage_id")
        REFERENCES "insurance"."patient_coverages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_items"
        ADD CONSTRAINT "fk_prior_authorization_items_prior_authorization_request_id" FOREIGN KEY ("prior_authorization_request_id")
        REFERENCES "insurance"."prior_authorization_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_determinations"
        ADD CONSTRAINT "fk_prior_authorization_determinations_prior_authorizat_e32a5f15" FOREIGN KEY ("prior_authorization_request_id")
        REFERENCES "insurance"."prior_authorization_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_determinations"
        ADD CONSTRAINT "fk_prior_authorization_determinations_prior_authorizat_cbb60fad" FOREIGN KEY ("prior_authorization_item_id")
        REFERENCES "insurance"."prior_authorization_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_patient_coverage_id" FOREIGN KEY ("patient_coverage_id")
        REFERENCES "insurance"."patient_coverages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_prior_authorization_request_id" FOREIGN KEY ("prior_authorization_request_id")
        REFERENCES "insurance"."prior_authorization_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claim_lines"
        ADD CONSTRAINT "fk_insurance_claim_lines_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_adjudication_versions"
        ADD CONSTRAINT "fk_claim_adjudication_versions_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_adjudication_versions"
        ADD CONSTRAINT "fk_claim_adjudication_versions_supersedes_version_id" FOREIGN KEY ("supersedes_version_id")
        REFERENCES "insurance"."claim_adjudication_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_line_adjudications"
        ADD CONSTRAINT "fk_claim_line_adjudications_claim_adjudication_version_id" FOREIGN KEY ("claim_adjudication_version_id")
        REFERENCES "insurance"."claim_adjudication_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_line_adjudications"
        ADD CONSTRAINT "fk_claim_line_adjudications_insurance_claim_line_id" FOREIGN KEY ("insurance_claim_line_id")
        REFERENCES "insurance"."insurance_claim_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."patient_explanations_of_benefit"
        ADD CONSTRAINT "fk_patient_explanations_of_benefit_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."patient_explanations_of_benefit"
        ADD CONSTRAINT "fk_patient_explanations_of_benefit_claim_adjudication__6194b135" FOREIGN KEY ("claim_adjudication_version_id")
        REFERENCES "insurance"."claim_adjudication_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_batches"
        ADD CONSTRAINT "fk_insurance_reconciliation_batches_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_items"
        ADD CONSTRAINT "fk_insurance_reconciliation_items_insurance_reconcilia_c4896cd0" FOREIGN KEY ("insurance_reconciliation_batch_id")
        REFERENCES "insurance"."insurance_reconciliation_batches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_items"
        ADD CONSTRAINT "fk_insurance_reconciliation_items_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_items"
        ADD CONSTRAINT "fk_insurance_reconciliation_items_claim_adjudication_version_id" FOREIGN KEY ("claim_adjudication_version_id")
        REFERENCES "insurance"."claim_adjudication_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."broker_commission_statements"
        ADD CONSTRAINT "fk_broker_commission_statements_insurance_broker_id" FOREIGN KEY ("insurance_broker_id")
        REFERENCES "insurance"."insurance_brokers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."broker_commission_statements"
        ADD CONSTRAINT "fk_broker_commission_statements_broker_carrier_agreement_id" FOREIGN KEY ("broker_carrier_agreement_id")
        REFERENCES "insurance"."broker_carrier_agreements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_primary_patient_coverage_id" FOREIGN KEY ("primary_patient_coverage_id")
        REFERENCES "insurance"."patient_coverages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_secondary_patient_coverage_id" FOREIGN KEY ("secondary_patient_coverage_id")
        REFERENCES "insurance"."patient_coverages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_tertiary_patient_coverage_id" FOREIGN KEY ("tertiary_patient_coverage_id")
        REFERENCES "insurance"."patient_coverages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_claim_adjudication_version_id" FOREIGN KEY ("claim_adjudication_version_id")
        REFERENCES "insurance"."claim_adjudication_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_appeal_decisions"
        ADD CONSTRAINT "fk_claim_appeal_decisions_claim_dispute_id" FOREIGN KEY ("claim_dispute_id")
        REFERENCES "insurance"."claim_disputes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_appeal_decisions"
        ADD CONSTRAINT "fk_claim_appeal_decisions_supersedes_decision_id" FOREIGN KEY ("supersedes_decision_id")
        REFERENCES "insurance"."claim_appeal_decisions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_reversals"
        ADD CONSTRAINT "fk_claim_reversals_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_reversals"
        ADD CONSTRAINT "fk_claim_reversals_reversed_adjudication_version_id" FOREIGN KEY ("reversed_adjudication_version_id")
        REFERENCES "insurance"."claim_adjudication_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."claim_reversals"
        ADD CONSTRAINT "fk_claim_reversals_replacement_claim_id" FOREIGN KEY ("replacement_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
