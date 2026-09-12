-- SALUD v4.0.10 · módulo 26 · schema insurance
-- Generado de diagram_26_insurance.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "insurance"."insurance_carriers" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "carrier_code" varchar NOT NULL,
    "legal_name" varchar NOT NULL,
    "sigla" varchar,
    "address" varchar,
    "regulator_identifier" varchar,
    "jurisdiction_concept_id" uuid,
    "public_profile_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_carriers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_brokers" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "broker_code" varchar NOT NULL,
    "legal_name" varchar NOT NULL,
    "license_number" varchar,
    "jurisdiction_concept_id" uuid,
    "public_profile_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_brokers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."broker_carrier_agreements" (
    "id" uuid NOT NULL,
    "insurance_broker_id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "agreement_code" varchar NOT NULL,
    "commission_model_concept_id" uuid,
    "effective_from" date,
    "effective_to" date,
    "contract_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_broker_carrier_agreements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."employer_groups" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "group_code" varchar NOT NULL,
    "legal_name" varchar NOT NULL,
    "tax_identifier" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_employer_groups" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_products" (
    "id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "product_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "product_type_concept_id" uuid NOT NULL,
    "market_segment_concept_id" uuid,
    "jurisdiction_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_products" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_plans" (
    "id" uuid NOT NULL,
    "insurance_product_id" uuid NOT NULL,
    "plan_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "plan_type_concept_id" uuid,
    "currency_concept_id" uuid,
    "effective_from" date,
    "effective_to" date,
    "policy_document_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_plan_benefits" (
    "id" uuid NOT NULL,
    "insurance_plan_id" uuid NOT NULL,
    "benefit_category_concept_id" uuid NOT NULL,
    "service_concept_id" uuid,
    "coverage_percent" numeric,
    "copay_amount" numeric,
    "deductible_amount" numeric,
    "annual_limit_amount" numeric,
    "requires_prior_authorization" boolean,
    "eligibility_rule_json" jsonb,
    "effective_from" date NOT NULL,
    "effective_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_plan_benefits" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."provider_networks" (
    "id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "network_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "network_type_concept_id" uuid,
    "effective_from" date,
    "effective_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_networks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."network_provider_memberships" (
    "id" uuid NOT NULL,
    "provider_network_id" uuid NOT NULL,
    "provider_type_concept_id" uuid NOT NULL,
    "provider_entity_id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid,
    "practice_id" uuid,
    "hospital_id" uuid,
    "diagnostic_unit_id" uuid,
    "pharmacy_id" uuid,
    "participation_level_concept_id" uuid,
    "contract_reference" varchar,
    "effective_from" date,
    "effective_to" date,
    "verification_status_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_network_provider_memberships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."patient_coverages" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "insurance_plan_id" uuid NOT NULL,
    "insurance_broker_id" uuid,
    "employer_group_id" uuid,
    "member_identifier" varchar NOT NULL,
    "policy_identifier" varchar,
    "coverage_order" integer,
    "relationship_to_subscriber_concept_id" uuid,
    "effective_from" date,
    "effective_to" date,
    "verification_status_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_coverages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."coverage_dependents" (
    "id" uuid NOT NULL,
    "patient_coverage_id" uuid NOT NULL,
    "dependent_patient_profile_id" uuid NOT NULL,
    "relationship_concept_id" uuid NOT NULL,
    "effective_from" date,
    "effective_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_coverage_dependents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."broker_clients" (
    "id" uuid NOT NULL,
    "insurance_broker_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "employer_group_id" uuid,
    "client_type_concept_id" uuid NOT NULL,
    "assigned_broker_user_id" uuid,
    "effective_from" date,
    "effective_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_broker_clients" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."coverage_eligibility_requests" (
    "id" uuid NOT NULL,
    "patient_coverage_id" uuid NOT NULL,
    "requesting_provider_type_concept_id" uuid NOT NULL,
    "requesting_provider_entity_id" uuid,
    "service_date" date,
    "purpose_value_set_id" uuid,
    "idempotency_key" varchar,
    "status_concept_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_coverage_eligibility_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."coverage_eligibility_responses" (
    "id" uuid NOT NULL,
    "coverage_eligibility_request_id" uuid NOT NULL,
    "response_version" integer NOT NULL,
    "in_force" boolean NOT NULL,
    "benefit_summary_json" jsonb,
    "authorization_requirements_json" jsonb,
    "response_reference" varchar,
    "outcome_concept_id" uuid NOT NULL,
    "responded_at" timestamptz NOT NULL,
    "responded_by_user_id" uuid,
    CONSTRAINT "pk_coverage_eligibility_responses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."prior_authorization_requests" (
    "id" uuid NOT NULL,
    "patient_coverage_id" uuid NOT NULL,
    "service_request_id" uuid,
    "medication_request_id" uuid,
    "requesting_provider_type_concept_id" uuid NOT NULL,
    "requesting_provider_entity_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "priority_concept_id" uuid,
    "submitted_at" timestamptz,
    "idempotency_key" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_prior_authorization_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."prior_authorization_items" (
    "id" uuid NOT NULL,
    "prior_authorization_request_id" uuid NOT NULL,
    "item_sequence" integer NOT NULL,
    "service_concept_id" uuid,
    "diagnostic_study_offering_id" uuid,
    "pharmacy_product_id" uuid,
    "requested_quantity" numeric,
    "requested_amount" numeric,
    "currency_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_prior_authorization_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."prior_authorization_determinations" (
    "id" uuid NOT NULL,
    "prior_authorization_request_id" uuid NOT NULL,
    "prior_authorization_item_id" uuid,
    "determination_version" integer NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "approved_quantity" numeric,
    "approved_amount" numeric,
    "denial_reason_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "supporting_file_id" uuid,
    "decided_at" timestamptz NOT NULL,
    "decided_by_user_id" uuid,
    CONSTRAINT "pk_prior_authorization_determinations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_claims" (
    "id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "patient_coverage_id" uuid NOT NULL,
    "billing_provider_type_concept_id" uuid NOT NULL,
    "billing_provider_entity_id" uuid NOT NULL,
    "encounter_id" uuid,
    "prior_authorization_request_id" uuid,
    "claim_identifier" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "submitted_at" timestamptz,
    "total_amount" numeric,
    "currency_concept_id" uuid,
    "idempotency_key" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_claims" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_claim_lines" (
    "id" uuid NOT NULL,
    "insurance_claim_id" uuid NOT NULL,
    "line_sequence" integer NOT NULL,
    "service_concept_id" uuid,
    "diagnostic_study_offering_id" uuid,
    "medication_dispensation_line_id" uuid,
    "quantity" numeric,
    "billed_amount" numeric,
    "patient_responsibility_amount" numeric,
    "supporting_clinical_reference" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insurance_claim_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."claim_adjudication_versions" (
    "id" uuid NOT NULL,
    "insurance_claim_id" uuid NOT NULL,
    "adjudication_version" integer NOT NULL,
    "outcome_concept_id" uuid NOT NULL,
    "disposition_text" text,
    "total_approved_amount" numeric,
    "total_patient_amount" numeric,
    "total_denied_amount" numeric,
    "supersedes_version_id" uuid,
    "adjudicated_at" timestamptz NOT NULL,
    "adjudicated_by_user_id" uuid,
    CONSTRAINT "pk_claim_adjudication_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."claim_line_adjudications" (
    "id" uuid NOT NULL,
    "claim_adjudication_version_id" uuid NOT NULL,
    "insurance_claim_line_id" uuid NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "approved_amount" numeric,
    "patient_amount" numeric,
    "denied_amount" numeric,
    "reason_concept_id" uuid,
    "policy_clause_reference" varchar,
    "denial_rationale" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_claim_line_adjudications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."patient_explanations_of_benefit" (
    "id" uuid NOT NULL,
    "insurance_claim_id" uuid NOT NULL,
    "claim_adjudication_version_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "document_record_id" uuid,
    "published_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_patient_explanations_of_benefit" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_reconciliation_batches" (
    "id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "provider_type_concept_id" uuid NOT NULL,
    "provider_entity_id" uuid NOT NULL,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "total_claimed_amount" numeric,
    "total_approved_amount" numeric,
    "total_paid_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_reconciliation_batches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_reconciliation_items" (
    "id" uuid NOT NULL,
    "insurance_reconciliation_batch_id" uuid NOT NULL,
    "insurance_claim_id" uuid NOT NULL,
    "claim_adjudication_version_id" uuid NOT NULL,
    "expected_amount" numeric,
    "accepted_amount" numeric,
    "variance_amount" numeric,
    "variance_reason_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_reconciliation_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."broker_commission_statements" (
    "id" uuid NOT NULL,
    "insurance_broker_id" uuid NOT NULL,
    "broker_carrier_agreement_id" uuid NOT NULL,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "gross_premium_amount" numeric,
    "commission_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_broker_commission_statements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."coordination_of_benefits" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "primary_patient_coverage_id" uuid NOT NULL,
    "secondary_patient_coverage_id" uuid,
    "tertiary_patient_coverage_id" uuid,
    "cob_rule_concept_id" uuid NOT NULL,
    "determination_version" integer NOT NULL,
    "determined_by_authority_concept_id" uuid,
    "effective_from" date NOT NULL,
    "effective_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_coordination_of_benefits" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."claim_disputes" (
    "id" uuid NOT NULL,
    "insurance_claim_id" uuid NOT NULL,
    "claim_adjudication_version_id" uuid,
    "dispute_type_concept_id" uuid NOT NULL,
    "dispute_reason_concept_id" uuid NOT NULL,
    "initiated_by_party_type_concept_id" uuid NOT NULL,
    "initiated_by_entity_id" uuid,
    "supporting_evidence_file_id" uuid,
    "filing_deadline" date,
    "submitted_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_claim_disputes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."claim_appeal_decisions" (
    "id" uuid NOT NULL,
    "claim_dispute_id" uuid NOT NULL,
    "appeal_level_concept_id" uuid NOT NULL,
    "decision_version" integer NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "adjusted_amount" numeric,
    "currency_concept_id" uuid,
    "rationale_text" text,
    "supersedes_decision_id" uuid,
    "decided_at" timestamptz,
    "decided_by_reviewer_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_claim_appeal_decisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."claim_reversals" (
    "id" uuid NOT NULL,
    "insurance_claim_id" uuid NOT NULL,
    "reversed_adjudication_version_id" uuid NOT NULL,
    "reversal_reason_concept_id" uuid NOT NULL,
    "reversal_amount" numeric,
    "currency_concept_id" uuid,
    "replacement_claim_id" uuid,
    "idempotency_key" varchar,
    "occurred_at" timestamptz NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_claim_reversals" PRIMARY KEY ("id")
);
