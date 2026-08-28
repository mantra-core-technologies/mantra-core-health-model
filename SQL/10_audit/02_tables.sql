-- SALUD v4.0.10 · módulo 10 · schema audit
-- Generado de diagram_10_audit.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "audit"."audit_log" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "tenant_id" uuid,
    "branch_id" uuid,
    "action" varchar NOT NULL,
    "entity" varchar NOT NULL,
    "entity_id" uuid,
    "outcome_concept_id" uuid NOT NULL,
    "ip" inet,
    "device_id" uuid,
    "previous_hash" varchar,
    "record_hash" varchar NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_audit_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."data_access_log" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "tenant_id" uuid,
    "purpose" varchar,
    "legal_basis_concept_id" uuid,
    "resource_type" varchar,
    "resource_id" uuid,
    "action_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_data_access_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."dsar_requests" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "jurisdiction_concept_id" uuid,
    "requested_at" timestamptz NOT NULL,
    "completed_at" timestamptz,
    "result_file_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dsar_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."users_history" (
    "history_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_users_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."tenants_history" (
    "history_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_tenants_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."patient_profiles_history" (
    "history_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_patient_profiles_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."health_practitioner_profiles_history" (
    "history_id" uuid NOT NULL,
    "health_practitioner_profile_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_practitioner_profiles_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."professional_credentials_history" (
    "history_id" uuid NOT NULL,
    "professional_credential_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_professional_credentials_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."jurisdiction_authorizations_history" (
    "history_id" uuid NOT NULL,
    "jurisdiction_authorization_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_jurisdiction_authorizations_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."consents_history" (
    "history_id" uuid NOT NULL,
    "consent_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_consents_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."patient_identity_links_history" (
    "history_id" uuid NOT NULL,
    "patient_identity_link_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_patient_identity_links_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."practitioner_role_assignments_history" (
    "history_id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_practitioner_role_assignments_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."practice_sites_history" (
    "history_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_practice_sites_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."clinical_units_history" (
    "history_id" uuid NOT NULL,
    "clinical_unit_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_clinical_units_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."care_spaces_history" (
    "history_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_care_spaces_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."diagnostic_reports_history" (
    "history_id" uuid NOT NULL,
    "diagnostic_report_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_diagnostic_reports_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."imaging_studies_history" (
    "history_id" uuid NOT NULL,
    "imaging_study_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_imaging_studies_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."public_profiles_history" (
    "history_id" uuid NOT NULL,
    "public_profile_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_public_profiles_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."social_posts_history" (
    "history_id" uuid NOT NULL,
    "social_post_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_social_posts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."service_reviews_history" (
    "history_id" uuid NOT NULL,
    "service_review_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_service_reviews_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."moderation_events" (
    "id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "policy_version" varchar,
    "evidence_json" jsonb,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_moderation_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."patient_content_access_log" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "resource_version_id" uuid,
    "action_concept_id" uuid NOT NULL,
    "purpose_of_use_concept_id" uuid NOT NULL,
    "decision_concept_id" uuid,
    "policy_version" varchar,
    "request_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_patient_content_access_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."organization_affiliations_history" (
    "history_id" uuid NOT NULL,
    "organization_affiliation_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_organization_affiliations_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."diagnostic_study_prices_history" (
    "history_id" uuid NOT NULL,
    "diagnostic_study_price_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_diagnostic_study_prices_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."pharmacy_product_prices_history" (
    "history_id" uuid NOT NULL,
    "pharmacy_product_price_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_pharmacy_product_prices_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."pharmacy_inventory_access_log" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "actor_user_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "target_type_concept_id" uuid,
    "target_id" uuid,
    "purpose_of_use_concept_id" uuid,
    "outcome_concept_id" uuid,
    "occurred_at" timestamptz,
    "correlation_id" uuid,
    CONSTRAINT "pk_pharmacy_inventory_access_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."insurance_decision_access_log" (
    "id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "actor_user_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "claim_id" uuid,
    "authorization_request_id" uuid,
    "action_concept_id" uuid NOT NULL,
    "purpose_of_use_concept_id" uuid NOT NULL,
    "outcome_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insurance_decision_access_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."identity_verification_access_log" (
    "id" uuid NOT NULL,
    "verification_case_id" uuid NOT NULL,
    "actor_user_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "evidence_type_concept_id" uuid,
    "data_disclosed_value_set_id" uuid,
    "purpose_of_use_concept_id" uuid NOT NULL,
    "outcome_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_identity_verification_access_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."delegated_access_audit_log" (
    "id" uuid NOT NULL,
    "delegate_user_id" uuid NOT NULL,
    "delegating_practitioner_profile_id" uuid NOT NULL,
    "delegated_assignment_id" uuid,
    "patient_profile_id" uuid,
    "resource_type_concept_id" uuid,
    "resource_id" uuid,
    "action_concept_id" uuid NOT NULL,
    "outcome_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_delegated_access_audit_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."analytics_governance_log" (
    "id" uuid NOT NULL,
    "actor_user_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "purpose_definition_id" uuid,
    "export_reference" varchar,
    "affected_subject_count" bigint,
    "query_hash" varchar,
    "approval_status_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_analytics_governance_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."conditions_history" (
    "history_id" uuid NOT NULL,
    "condition_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conditions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."allergy_intolerances_history" (
    "history_id" uuid NOT NULL,
    "allergy_intolerance_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_allergy_intolerances_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."medication_requests_history" (
    "history_id" uuid NOT NULL,
    "medication_request_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_medication_requests_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."practices_history" (
    "history_id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_practices_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."clinical_note_headers_history" (
    "history_id" uuid NOT NULL,
    "clinical_note_header_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_clinical_note_headers_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."care_plans_history" (
    "history_id" uuid NOT NULL,
    "care_plan_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_care_plans_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."document_records_history" (
    "history_id" uuid NOT NULL,
    "document_record_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_document_records_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."care_teams_history" (
    "history_id" uuid NOT NULL,
    "care_team_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_care_teams_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."referrals_history" (
    "history_id" uuid NOT NULL,
    "referral_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_referrals_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."clinical_alerts_history" (
    "history_id" uuid NOT NULL,
    "clinical_alert_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_clinical_alerts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."cds_rules_history" (
    "history_id" uuid NOT NULL,
    "cds_rule_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_cds_rules_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."order_sets_history" (
    "history_id" uuid NOT NULL,
    "order_set_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_order_sets_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."provider_connections_history" (
    "history_id" uuid NOT NULL,
    "provider_connection_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_provider_connections_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."integration_endpoints_history" (
    "history_id" uuid NOT NULL,
    "integration_endpoint_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_integration_endpoints_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."outbound_messages_history" (
    "history_id" uuid NOT NULL,
    "outbound_message_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_outbound_messages_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."inbound_messages_history" (
    "history_id" uuid NOT NULL,
    "inbound_message_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_inbound_messages_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."message_retries_history" (
    "history_id" uuid NOT NULL,
    "message_retry_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_message_retries_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."accounts_history" (
    "history_id" uuid NOT NULL,
    "account_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_accounts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."journal_transactions_history" (
    "history_id" uuid NOT NULL,
    "journal_transaction_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_journal_transactions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."assets_history" (
    "history_id" uuid NOT NULL,
    "asset_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_assets_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."liabilities_history" (
    "history_id" uuid NOT NULL,
    "liability_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_liabilities_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."invoices_history" (
    "history_id" uuid NOT NULL,
    "invoice_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_invoices_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."bills_history" (
    "history_id" uuid NOT NULL,
    "bill_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_bills_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."insurance_claims_history" (
    "history_id" uuid NOT NULL,
    "insurance_claim_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insurance_claims_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."message_templates_history" (
    "history_id" uuid NOT NULL,
    "message_template_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_message_templates_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."provider_channel_configs_history" (
    "history_id" uuid NOT NULL,
    "provider_channel_config_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_provider_channel_configs_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."event_subscriptions_history" (
    "history_id" uuid NOT NULL,
    "event_subscription_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_event_subscriptions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."test_suites_history" (
    "history_id" uuid NOT NULL,
    "test_suite_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_test_suites_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."test_cases_history" (
    "history_id" uuid NOT NULL,
    "test_case_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_test_cases_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."trackable_subjects_history" (
    "history_id" uuid NOT NULL,
    "trackable_subject_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_trackable_subjects_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."shipments_history" (
    "history_id" uuid NOT NULL,
    "shipment_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_shipments_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."contracts_history" (
    "history_id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_contracts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."employment_records_history" (
    "history_id" uuid NOT NULL,
    "employment_record_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_employment_records_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."departments_history" (
    "history_id" uuid NOT NULL,
    "department_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_departments_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."positions_history" (
    "history_id" uuid NOT NULL,
    "position_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_positions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."report_definitions_history" (
    "history_id" uuid NOT NULL,
    "report_definition_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_report_definitions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."report_schedules_history" (
    "history_id" uuid NOT NULL,
    "report_schedule_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_report_schedules_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."identity_providers_history" (
    "history_id" uuid NOT NULL,
    "identity_provider_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_identity_providers_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."provider_protocol_configs_history" (
    "history_id" uuid NOT NULL,
    "provider_protocol_config_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_provider_protocol_configs_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."provider_tenant_bindings_history" (
    "history_id" uuid NOT NULL,
    "provider_tenant_binding_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_provider_tenant_bindings_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."federated_identities_history" (
    "history_id" uuid NOT NULL,
    "federated_identity_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_federated_identities_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."schedule_templates_history" (
    "history_id" uuid NOT NULL,
    "schedule_template_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_schedule_templates_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."booking_policies_history" (
    "history_id" uuid NOT NULL,
    "booking_policy_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_booking_policies_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."appointment_bookings_history" (
    "history_id" uuid NOT NULL,
    "appointment_booking_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_appointment_bookings_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."payment_methods_history" (
    "history_id" uuid NOT NULL,
    "payment_method_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_payment_methods_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."payment_intents_history" (
    "history_id" uuid NOT NULL,
    "payment_intent_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_payment_intents_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."payment_transactions_history" (
    "history_id" uuid NOT NULL,
    "payment_transaction_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_payment_transactions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."payouts_history" (
    "history_id" uuid NOT NULL,
    "payout_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_payouts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."ad_accounts_history" (
    "history_id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ad_accounts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."campaigns_history" (
    "history_id" uuid NOT NULL,
    "campaign_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_campaigns_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."ad_sets_history" (
    "history_id" uuid NOT NULL,
    "ad_set_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ad_sets_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."ads_history" (
    "history_id" uuid NOT NULL,
    "ad_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ads_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."ad_creatives_history" (
    "history_id" uuid NOT NULL,
    "ad_creative_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ad_creatives_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."custom_audiences_history" (
    "history_id" uuid NOT NULL,
    "custom_audience_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_custom_audiences_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."wallets_history" (
    "history_id" uuid NOT NULL,
    "wallets_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_wallets_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."subscription_plans_history" (
    "history_id" uuid NOT NULL,
    "subscription_plans_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_subscription_plans_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."subscriptions_history" (
    "history_id" uuid NOT NULL,
    "subscriptions_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_subscriptions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."connected_accounts_history" (
    "history_id" uuid NOT NULL,
    "connected_accounts_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_connected_accounts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."payment_mandates_history" (
    "history_id" uuid NOT NULL,
    "payment_mandates_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_payment_mandates_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."product_catalogs_history" (
    "history_id" uuid NOT NULL,
    "product_catalogs_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_product_catalogs_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."catalog_products_history" (
    "history_id" uuid NOT NULL,
    "catalog_products_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_products_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."product_sets_history" (
    "history_id" uuid NOT NULL,
    "product_sets_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_product_sets_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."automated_rules_history" (
    "history_id" uuid NOT NULL,
    "automated_rules_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_automated_rules_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."custom_conversions_history" (
    "history_id" uuid NOT NULL,
    "custom_conversions_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_custom_conversions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."ad_experiments_history" (
    "history_id" uuid NOT NULL,
    "ad_experiments_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ad_experiments_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."comments_history" (
    "history_id" uuid NOT NULL,
    "comments_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_comments_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."groups_history" (
    "history_id" uuid NOT NULL,
    "groups_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_groups_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."topics_history" (
    "history_id" uuid NOT NULL,
    "topics_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_topics_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."conversations_history" (
    "history_id" uuid NOT NULL,
    "conversations_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conversations_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."verified_badges_history" (
    "history_id" uuid NOT NULL,
    "verified_badges_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_verified_badges_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."moderation_decisions_history" (
    "history_id" uuid NOT NULL,
    "moderation_decisions_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_moderation_decisions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."courses_history" (
    "history_id" uuid NOT NULL,
    "courses_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_courses_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."course_versions_history" (
    "history_id" uuid NOT NULL,
    "course_versions_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_course_versions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."enrollments_history" (
    "history_id" uuid NOT NULL,
    "enrollments_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_enrollments_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."certificates_history" (
    "history_id" uuid NOT NULL,
    "certificates_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_certificates_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."agents_history" (
    "history_id" uuid NOT NULL,
    "agents_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_agents_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."agent_versions_history" (
    "history_id" uuid NOT NULL,
    "agent_versions_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_agent_versions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."workflows_history" (
    "history_id" uuid NOT NULL,
    "workflows_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_workflows_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."guardrail_policies_history" (
    "history_id" uuid NOT NULL,
    "guardrail_policies_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_guardrail_policies_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."record_automations_history" (
    "history_id" uuid NOT NULL,
    "record_automations_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_record_automations_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."crm_accounts_history" (
    "history_id" uuid NOT NULL,
    "crm_accounts_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_crm_accounts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."contacts_history" (
    "history_id" uuid NOT NULL,
    "contacts_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_contacts_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."opportunities_history" (
    "history_id" uuid NOT NULL,
    "opportunities_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_opportunities_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."partnerships_history" (
    "history_id" uuid NOT NULL,
    "partnerships_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_partnerships_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."partnership_agreements_history" (
    "history_id" uuid NOT NULL,
    "partnership_agreements_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_partnership_agreements_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."segments_history" (
    "history_id" uuid NOT NULL,
    "segments_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_segments_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."marketing_campaigns_history" (
    "history_id" uuid NOT NULL,
    "marketing_campaigns_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_marketing_campaigns_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."journeys_history" (
    "history_id" uuid NOT NULL,
    "journeys_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_journeys_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."loyalty_programs_history" (
    "history_id" uuid NOT NULL,
    "loyalty_programs_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_loyalty_programs_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."loyalty_memberships_history" (
    "history_id" uuid NOT NULL,
    "loyalty_memberships_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_loyalty_memberships_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."promotions_history" (
    "history_id" uuid NOT NULL,
    "promotions_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_promotions_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."coupons_history" (
    "history_id" uuid NOT NULL,
    "coupons_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_coupons_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."referral_programs_history" (
    "history_id" uuid NOT NULL,
    "referral_programs_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_referral_programs_history" PRIMARY KEY ("history_id")
);
