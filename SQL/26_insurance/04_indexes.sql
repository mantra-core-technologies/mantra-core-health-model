-- SALUD v4.0.10 · módulo 26 · schema insurance
-- Generado de diagram_26_insurance.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_insurance_carriers_tenant_id" ON "insurance"."insurance_carriers" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insurance_carriers_carrier_code" ON "insurance"."insurance_carriers" ("carrier_code");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_tenant_id" ON "insurance"."insurance_carriers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_jurisdiction_concept_id" ON "insurance"."insurance_carriers" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_public_profile_id" ON "insurance"."insurance_carriers" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_verification_status_concept_id" ON "insurance"."insurance_carriers" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_status_concept_id" ON "insurance"."insurance_carriers" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_created_by_user_id" ON "insurance"."insurance_carriers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_updated_by_user_id" ON "insurance"."insurance_carriers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_carriers_tenant_id_status_concept_id" ON "insurance"."insurance_carriers" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insurance_brokers_tenant_id" ON "insurance"."insurance_brokers" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insurance_brokers_broker_code" ON "insurance"."insurance_brokers" ("broker_code");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_tenant_id" ON "insurance"."insurance_brokers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_jurisdiction_concept_id" ON "insurance"."insurance_brokers" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_public_profile_id" ON "insurance"."insurance_brokers" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_verification_status_concept_id" ON "insurance"."insurance_brokers" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_status_concept_id" ON "insurance"."insurance_brokers" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_created_by_user_id" ON "insurance"."insurance_brokers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_updated_by_user_id" ON "insurance"."insurance_brokers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_brokers_tenant_id_status_concept_id" ON "insurance"."insurance_brokers" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_insurance_broker_id" ON "insurance"."broker_carrier_agreements" ("insurance_broker_id");

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_insurance_carrier_id" ON "insurance"."broker_carrier_agreements" ("insurance_carrier_id");

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_commission_model_concept_id" ON "insurance"."broker_carrier_agreements" ("commission_model_concept_id");

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_contract_file_id" ON "insurance"."broker_carrier_agreements" ("contract_file_id");

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_status_concept_id" ON "insurance"."broker_carrier_agreements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_created_by_user_id" ON "insurance"."broker_carrier_agreements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_updated_by_user_id" ON "insurance"."broker_carrier_agreements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employer_groups_tenant_id" ON "insurance"."employer_groups" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_employer_groups_status_concept_id" ON "insurance"."employer_groups" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employer_groups_created_by_user_id" ON "insurance"."employer_groups" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employer_groups_updated_by_user_id" ON "insurance"."employer_groups" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employer_groups_tenant_id_status_concept_id" ON "insurance"."employer_groups" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_insurance_products_insurance_carrier_id" ON "insurance"."insurance_products" ("insurance_carrier_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_product_type_concept_id" ON "insurance"."insurance_products" ("product_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_market_segment_concept_id" ON "insurance"."insurance_products" ("market_segment_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_jurisdiction_concept_id" ON "insurance"."insurance_products" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_status_concept_id" ON "insurance"."insurance_products" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_created_by_user_id" ON "insurance"."insurance_products" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_updated_by_user_id" ON "insurance"."insurance_products" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plans_insurance_product_id" ON "insurance"."insurance_plans" ("insurance_product_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plans_plan_type_concept_id" ON "insurance"."insurance_plans" ("plan_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plans_currency_concept_id" ON "insurance"."insurance_plans" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plans_policy_document_file_id" ON "insurance"."insurance_plans" ("policy_document_file_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plans_status_concept_id" ON "insurance"."insurance_plans" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plans_created_by_user_id" ON "insurance"."insurance_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plans_updated_by_user_id" ON "insurance"."insurance_plans" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plan_benefits_insurance_plan_id" ON "insurance"."insurance_plan_benefits" ("insurance_plan_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plan_benefits_benefit_category_concept_id" ON "insurance"."insurance_plan_benefits" ("benefit_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plan_benefits_service_concept_id" ON "insurance"."insurance_plan_benefits" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plan_benefits_status_concept_id" ON "insurance"."insurance_plan_benefits" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plan_benefits_created_by_user_id" ON "insurance"."insurance_plan_benefits" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_plan_benefits_updated_by_user_id" ON "insurance"."insurance_plan_benefits" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_networks_insurance_carrier_id" ON "insurance"."provider_networks" ("insurance_carrier_id");

CREATE INDEX IF NOT EXISTS "ix_provider_networks_network_type_concept_id" ON "insurance"."provider_networks" ("network_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_networks_status_concept_id" ON "insurance"."provider_networks" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_networks_created_by_user_id" ON "insurance"."provider_networks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_networks_updated_by_user_id" ON "insurance"."provider_networks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_provider_network_id" ON "insurance"."network_provider_memberships" ("provider_network_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_provider_type_concept_id" ON "insurance"."network_provider_memberships" ("provider_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_practitioner_role_assignment_id" ON "insurance"."network_provider_memberships" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_practice_id" ON "insurance"."network_provider_memberships" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_hospital_id" ON "insurance"."network_provider_memberships" ("hospital_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_diagnostic_unit_id" ON "insurance"."network_provider_memberships" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_pharmacy_id" ON "insurance"."network_provider_memberships" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_participation_level_concept_id" ON "insurance"."network_provider_memberships" ("participation_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_verification_status_concept_id" ON "insurance"."network_provider_memberships" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_status_concept_id" ON "insurance"."network_provider_memberships" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_created_by_user_id" ON "insurance"."network_provider_memberships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_network_provider_memberships_updated_by_user_id" ON "insurance"."network_provider_memberships" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_patient_profile_id" ON "insurance"."patient_coverages" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_insurance_plan_id" ON "insurance"."patient_coverages" ("insurance_plan_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_insurance_broker_id" ON "insurance"."patient_coverages" ("insurance_broker_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_employer_group_id" ON "insurance"."patient_coverages" ("employer_group_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_relationship_to_subscriber_concept_id" ON "insurance"."patient_coverages" ("relationship_to_subscriber_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_verification_status_concept_id" ON "insurance"."patient_coverages" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_status_concept_id" ON "insurance"."patient_coverages" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_created_by_user_id" ON "insurance"."patient_coverages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_updated_by_user_id" ON "insurance"."patient_coverages" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_coverages_patient_profile_id_updated_at" ON "insurance"."patient_coverages" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_coverage_dependents_patient_coverage_id" ON "insurance"."coverage_dependents" ("patient_coverage_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_dependents_dependent_patient_profile_id" ON "insurance"."coverage_dependents" ("dependent_patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_dependents_relationship_concept_id" ON "insurance"."coverage_dependents" ("relationship_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_dependents_status_concept_id" ON "insurance"."coverage_dependents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_dependents_created_by_user_id" ON "insurance"."coverage_dependents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_dependents_updated_by_user_id" ON "insurance"."coverage_dependents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_insurance_broker_id" ON "insurance"."broker_clients" ("insurance_broker_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_patient_profile_id" ON "insurance"."broker_clients" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_employer_group_id" ON "insurance"."broker_clients" ("employer_group_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_client_type_concept_id" ON "insurance"."broker_clients" ("client_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_assigned_broker_user_id" ON "insurance"."broker_clients" ("assigned_broker_user_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_status_concept_id" ON "insurance"."broker_clients" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_created_by_user_id" ON "insurance"."broker_clients" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_updated_by_user_id" ON "insurance"."broker_clients" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_broker_clients_patient_profile_id_updated_at" ON "insurance"."broker_clients" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_requests_patient_coverage_id" ON "insurance"."coverage_eligibility_requests" ("patient_coverage_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_requests_requesting_provider_t_ccab8dd1" ON "insurance"."coverage_eligibility_requests" ("requesting_provider_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_requests_purpose_value_set_id" ON "insurance"."coverage_eligibility_requests" ("purpose_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_requests_status_concept_id" ON "insurance"."coverage_eligibility_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_requests_created_by_user_id" ON "insurance"."coverage_eligibility_requests" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_coverage_eligibility_requests_idempotency" ON "insurance"."coverage_eligibility_requests" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_responses_coverage_eligibility_44692f00" ON "insurance"."coverage_eligibility_responses" ("coverage_eligibility_request_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_responses_outcome_concept_id" ON "insurance"."coverage_eligibility_responses" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coverage_eligibility_responses_responded_by_user_id" ON "insurance"."coverage_eligibility_responses" ("responded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_patient_coverage_id" ON "insurance"."prior_authorization_requests" ("patient_coverage_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_service_request_id" ON "insurance"."prior_authorization_requests" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_medication_request_id" ON "insurance"."prior_authorization_requests" ("medication_request_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_inventory_reservation_id" ON "insurance"."prior_authorization_requests" ("inventory_reservation_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_requesting_provider_ty_ace534e5" ON "insurance"."prior_authorization_requests" ("requesting_provider_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_status_concept_id" ON "insurance"."prior_authorization_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_priority_concept_id" ON "insurance"."prior_authorization_requests" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_created_by_user_id" ON "insurance"."prior_authorization_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_updated_by_user_id" ON "insurance"."prior_authorization_requests" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_prior_authorization_requests_idempotency" ON "insurance"."prior_authorization_requests" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_items_prior_authorization_request_id" ON "insurance"."prior_authorization_items" ("prior_authorization_request_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_items_service_concept_id" ON "insurance"."prior_authorization_items" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_items_diagnostic_study_offering_id" ON "insurance"."prior_authorization_items" ("diagnostic_study_offering_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_items_pharmacy_product_id" ON "insurance"."prior_authorization_items" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_items_currency_concept_id" ON "insurance"."prior_authorization_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_determinations_prior_authorizat_9b22376b" ON "insurance"."prior_authorization_determinations" ("prior_authorization_request_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_determinations_prior_authorizat_3c8c8cdf" ON "insurance"."prior_authorization_determinations" ("prior_authorization_item_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_determinations_decision_concept_id" ON "insurance"."prior_authorization_determinations" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_determinations_denial_reason_concept_id" ON "insurance"."prior_authorization_determinations" ("denial_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_determinations_supporting_file_id" ON "insurance"."prior_authorization_determinations" ("supporting_file_id");

CREATE INDEX IF NOT EXISTS "ix_prior_authorization_determinations_decided_by_user_id" ON "insurance"."prior_authorization_determinations" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_prior_authorization_determinations_effective_period" ON "insurance"."prior_authorization_determinations" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_insurance_carrier_id" ON "insurance"."insurance_claims" ("insurance_carrier_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_patient_coverage_id" ON "insurance"."insurance_claims" ("patient_coverage_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_billing_provider_type_concept_id" ON "insurance"."insurance_claims" ("billing_provider_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_encounter_id" ON "insurance"."insurance_claims" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_prior_authorization_request_id" ON "insurance"."insurance_claims" ("prior_authorization_request_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_inventory_reservation_id" ON "insurance"."insurance_claims" ("inventory_reservation_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_service_request_id" ON "insurance"."insurance_claims" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_status_concept_id" ON "insurance"."insurance_claims" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_currency_concept_id" ON "insurance"."insurance_claims" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_created_by_user_id" ON "insurance"."insurance_claims" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_updated_by_user_id" ON "insurance"."insurance_claims" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insurance_claims_idempotency" ON "insurance"."insurance_claims" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_insurance_claim_lines_insurance_claim_id" ON "insurance"."insurance_claim_lines" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claim_lines_service_concept_id" ON "insurance"."insurance_claim_lines" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claim_lines_diagnostic_study_offering_id" ON "insurance"."insurance_claim_lines" ("diagnostic_study_offering_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claim_lines_medication_dispensation_line_id" ON "insurance"."insurance_claim_lines" ("medication_dispensation_line_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claim_lines_inventory_reservation_line_id" ON "insurance"."insurance_claim_lines" ("inventory_reservation_line_id");

CREATE INDEX IF NOT EXISTS "ix_claim_adjudication_versions_insurance_claim_id" ON "insurance"."claim_adjudication_versions" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_claim_adjudication_versions_outcome_concept_id" ON "insurance"."claim_adjudication_versions" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_adjudication_versions_supersedes_version_id" ON "insurance"."claim_adjudication_versions" ("supersedes_version_id");

CREATE INDEX IF NOT EXISTS "ix_claim_adjudication_versions_adjudicated_by_user_id" ON "insurance"."claim_adjudication_versions" ("adjudicated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_claim_line_adjudications_claim_adjudication_version_id" ON "insurance"."claim_line_adjudications" ("claim_adjudication_version_id");

CREATE INDEX IF NOT EXISTS "ix_claim_line_adjudications_insurance_claim_line_id" ON "insurance"."claim_line_adjudications" ("insurance_claim_line_id");

CREATE INDEX IF NOT EXISTS "ix_claim_line_adjudications_decision_concept_id" ON "insurance"."claim_line_adjudications" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_line_adjudications_reason_concept_id" ON "insurance"."claim_line_adjudications" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_claim_line_adjudications_created_at" ON "insurance"."claim_line_adjudications" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_patient_explanations_of_benefit_insurance_claim_id" ON "insurance"."patient_explanations_of_benefit" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_patient_explanations_of_benefit_claim_adjudication__441b4744" ON "insurance"."patient_explanations_of_benefit" ("claim_adjudication_version_id");

CREATE INDEX IF NOT EXISTS "ix_patient_explanations_of_benefit_patient_profile_id" ON "insurance"."patient_explanations_of_benefit" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_explanations_of_benefit_document_record_id" ON "insurance"."patient_explanations_of_benefit" ("document_record_id");

CREATE INDEX IF NOT EXISTS "ix_patient_explanations_of_benefit_status_concept_id" ON "insurance"."patient_explanations_of_benefit" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_explanations_of_benefit_created_by_user_id" ON "insurance"."patient_explanations_of_benefit" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_explanations_of_benefit_patient_profile_id__2239c1f8" ON "insurance"."patient_explanations_of_benefit" ("patient_profile_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_batches_insurance_carrier_id" ON "insurance"."insurance_reconciliation_batches" ("insurance_carrier_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_batches_provider_type_concept_id" ON "insurance"."insurance_reconciliation_batches" ("provider_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_batches_currency_concept_id" ON "insurance"."insurance_reconciliation_batches" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_batches_status_concept_id" ON "insurance"."insurance_reconciliation_batches" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_batches_created_by_user_id" ON "insurance"."insurance_reconciliation_batches" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_batches_updated_by_user_id" ON "insurance"."insurance_reconciliation_batches" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_items_insurance_reconcilia_4340c85a" ON "insurance"."insurance_reconciliation_items" ("insurance_reconciliation_batch_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_items_insurance_claim_id" ON "insurance"."insurance_reconciliation_items" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_items_claim_adjudication_version_id" ON "insurance"."insurance_reconciliation_items" ("claim_adjudication_version_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_items_variance_reason_concept_id" ON "insurance"."insurance_reconciliation_items" ("variance_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_items_status_concept_id" ON "insurance"."insurance_reconciliation_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_items_created_by_user_id" ON "insurance"."insurance_reconciliation_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_reconciliation_items_updated_by_user_id" ON "insurance"."insurance_reconciliation_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_broker_commission_statements_insurance_broker_id" ON "insurance"."broker_commission_statements" ("insurance_broker_id");

CREATE INDEX IF NOT EXISTS "ix_broker_commission_statements_broker_carrier_agreement_id" ON "insurance"."broker_commission_statements" ("broker_carrier_agreement_id");

CREATE INDEX IF NOT EXISTS "ix_broker_commission_statements_currency_concept_id" ON "insurance"."broker_commission_statements" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_broker_commission_statements_status_concept_id" ON "insurance"."broker_commission_statements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_broker_commission_statements_created_by_user_id" ON "insurance"."broker_commission_statements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_broker_commission_statements_updated_by_user_id" ON "insurance"."broker_commission_statements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_patient_profile_id" ON "insurance"."coordination_of_benefits" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_primary_patient_coverage_id" ON "insurance"."coordination_of_benefits" ("primary_patient_coverage_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_secondary_patient_coverage_id" ON "insurance"."coordination_of_benefits" ("secondary_patient_coverage_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_tertiary_patient_coverage_id" ON "insurance"."coordination_of_benefits" ("tertiary_patient_coverage_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_cob_rule_concept_id" ON "insurance"."coordination_of_benefits" ("cob_rule_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_determined_by_authority_concept_id" ON "insurance"."coordination_of_benefits" ("determined_by_authority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_status_concept_id" ON "insurance"."coordination_of_benefits" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_created_by_user_id" ON "insurance"."coordination_of_benefits" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_coordination_of_benefits_patient_profile_id_created_at" ON "insurance"."coordination_of_benefits" ("patient_profile_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_insurance_claim_id" ON "insurance"."claim_disputes" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_claim_adjudication_version_id" ON "insurance"."claim_disputes" ("claim_adjudication_version_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_dispute_type_concept_id" ON "insurance"."claim_disputes" ("dispute_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_dispute_reason_concept_id" ON "insurance"."claim_disputes" ("dispute_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_initiated_by_party_type_concept_id" ON "insurance"."claim_disputes" ("initiated_by_party_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_supporting_evidence_file_id" ON "insurance"."claim_disputes" ("supporting_evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_status_concept_id" ON "insurance"."claim_disputes" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_created_by_user_id" ON "insurance"."claim_disputes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_claim_disputes_updated_by_user_id" ON "insurance"."claim_disputes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_claim_appeal_decisions_claim_dispute_id" ON "insurance"."claim_appeal_decisions" ("claim_dispute_id");

CREATE INDEX IF NOT EXISTS "ix_claim_appeal_decisions_appeal_level_concept_id" ON "insurance"."claim_appeal_decisions" ("appeal_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_appeal_decisions_decision_concept_id" ON "insurance"."claim_appeal_decisions" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_appeal_decisions_currency_concept_id" ON "insurance"."claim_appeal_decisions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_appeal_decisions_supersedes_decision_id" ON "insurance"."claim_appeal_decisions" ("supersedes_decision_id");

CREATE INDEX IF NOT EXISTS "ix_claim_appeal_decisions_decided_by_reviewer_user_id" ON "insurance"."claim_appeal_decisions" ("decided_by_reviewer_user_id");

CREATE INDEX IF NOT EXISTS "brin_claim_appeal_decisions_created_at" ON "insurance"."claim_appeal_decisions" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_claim_reversals_insurance_claim_id" ON "insurance"."claim_reversals" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_claim_reversals_reversed_adjudication_version_id" ON "insurance"."claim_reversals" ("reversed_adjudication_version_id");

CREATE INDEX IF NOT EXISTS "ix_claim_reversals_reversal_reason_concept_id" ON "insurance"."claim_reversals" ("reversal_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_reversals_currency_concept_id" ON "insurance"."claim_reversals" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_claim_reversals_replacement_claim_id" ON "insurance"."claim_reversals" ("replacement_claim_id");

CREATE INDEX IF NOT EXISTS "ix_claim_reversals_recorded_by_user_id" ON "insurance"."claim_reversals" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_claim_reversals_idempotency" ON "insurance"."claim_reversals" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "brin_claim_reversals_recorded_at" ON "insurance"."claim_reversals" USING brin ("recorded_at") WITH (pages_per_range=128);
