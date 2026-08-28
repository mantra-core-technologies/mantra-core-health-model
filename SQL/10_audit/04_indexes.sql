-- SALUD v4.0.10 · módulo 10 · schema audit
-- Generado de diagram_10_audit.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_audit_log_user_id" ON "audit"."audit_log" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_audit_log_tenant_id" ON "audit"."audit_log" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_audit_log_branch_id" ON "audit"."audit_log" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_audit_log_outcome_concept_id" ON "audit"."audit_log" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_audit_log_device_id" ON "audit"."audit_log" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_audit_log_recorded_by_user_id" ON "audit"."audit_log" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_audit_log_tenant_id_recorded_at" ON "audit"."audit_log" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_audit_log_recorded_at" ON "audit"."audit_log" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_data_access_log_user_id" ON "audit"."data_access_log" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_data_access_log_patient_profile_id" ON "audit"."data_access_log" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_data_access_log_tenant_id" ON "audit"."data_access_log" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_data_access_log_legal_basis_concept_id" ON "audit"."data_access_log" ("legal_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_data_access_log_action_concept_id" ON "audit"."data_access_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_data_access_log_recorded_by_user_id" ON "audit"."data_access_log" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_data_access_log_tenant_id_recorded_at" ON "audit"."data_access_log" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_data_access_log_patient_profile_id_recorded_at" ON "audit"."data_access_log" ("tenant_id", "patient_profile_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_data_access_log_recorded_at" ON "audit"."data_access_log" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_dsar_requests_user_id" ON "audit"."dsar_requests" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_dsar_requests_type_concept_id" ON "audit"."dsar_requests" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dsar_requests_status_concept_id" ON "audit"."dsar_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dsar_requests_jurisdiction_concept_id" ON "audit"."dsar_requests" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dsar_requests_result_file_id" ON "audit"."dsar_requests" ("result_file_id");

CREATE INDEX IF NOT EXISTS "ix_dsar_requests_created_by_user_id" ON "audit"."dsar_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dsar_requests_updated_by_user_id" ON "audit"."dsar_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_users_history_user_id" ON "audit"."users_history" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_users_history_operation_concept_id" ON "audit"."users_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_history_changed_by_user_id" ON "audit"."users_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_users_history_change_reason_concept_id" ON "audit"."users_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_users_history_recorded_at" ON "audit"."users_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_tenants_history_tenant_id" ON "audit"."tenants_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_history_operation_concept_id" ON "audit"."tenants_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_history_changed_by_user_id" ON "audit"."tenants_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_history_change_reason_concept_id" ON "audit"."tenants_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_history_tenant_id_recorded_at" ON "audit"."tenants_history" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_tenants_history_recorded_at" ON "audit"."tenants_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_history_patient_profile_id" ON "audit"."patient_profiles_history" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_history_operation_concept_id" ON "audit"."patient_profiles_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_history_changed_by_user_id" ON "audit"."patient_profiles_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_history_change_reason_concept_id" ON "audit"."patient_profiles_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_history_patient_profile_id_recorded_at" ON "audit"."patient_profiles_history" ("patient_profile_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_patient_profiles_history_recorded_at" ON "audit"."patient_profiles_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_history_health_practit_622f20f2" ON "audit"."health_practitioner_profiles_history" ("health_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_history_operation_concept_id" ON "audit"."health_practitioner_profiles_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_history_changed_by_user_id" ON "audit"."health_practitioner_profiles_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_history_change_reason__55227d17" ON "audit"."health_practitioner_profiles_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_health_practitioner_profiles_history_recorded_at" ON "audit"."health_practitioner_profiles_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_history_professional_credential_id" ON "audit"."professional_credentials_history" ("professional_credential_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_history_operation_concept_id" ON "audit"."professional_credentials_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_history_changed_by_user_id" ON "audit"."professional_credentials_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_history_change_reason_concept_id" ON "audit"."professional_credentials_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_professional_credentials_history_recorded_at" ON "audit"."professional_credentials_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_history_jurisdiction_au_831b1b79" ON "audit"."jurisdiction_authorizations_history" ("jurisdiction_authorization_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_history_operation_concept_id" ON "audit"."jurisdiction_authorizations_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_history_changed_by_user_id" ON "audit"."jurisdiction_authorizations_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_history_change_reason_concept_id" ON "audit"."jurisdiction_authorizations_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_jurisdiction_authorizations_history_effective_period" ON "audit"."jurisdiction_authorizations_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_jurisdiction_authorizations_history_recorded_at" ON "audit"."jurisdiction_authorizations_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_consents_history_consent_id" ON "audit"."consents_history" ("consent_id");

CREATE INDEX IF NOT EXISTS "ix_consents_history_operation_concept_id" ON "audit"."consents_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consents_history_changed_by_user_id" ON "audit"."consents_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_consents_history_change_reason_concept_id" ON "audit"."consents_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_consents_history_effective_period" ON "audit"."consents_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_consents_history_recorded_at" ON "audit"."consents_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_history_patient_identity_link_id" ON "audit"."patient_identity_links_history" ("patient_identity_link_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_history_operation_concept_id" ON "audit"."patient_identity_links_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_history_changed_by_user_id" ON "audit"."patient_identity_links_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_history_change_reason_concept_id" ON "audit"."patient_identity_links_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_patient_identity_links_history_recorded_at" ON "audit"."patient_identity_links_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_history_practitioner__3c54201b" ON "audit"."practitioner_role_assignments_history" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_history_operation_concept_id" ON "audit"."practitioner_role_assignments_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_history_changed_by_user_id" ON "audit"."practitioner_role_assignments_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_history_change_reason_fd6e8399" ON "audit"."practitioner_role_assignments_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_practitioner_role_assignments_history_effective_period" ON "audit"."practitioner_role_assignments_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_practitioner_role_assignments_history_recorded_at" ON "audit"."practitioner_role_assignments_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_practice_sites_history_practice_site_id" ON "audit"."practice_sites_history" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_history_operation_concept_id" ON "audit"."practice_sites_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_history_changed_by_user_id" ON "audit"."practice_sites_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_history_change_reason_concept_id" ON "audit"."practice_sites_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_practice_sites_history_recorded_at" ON "audit"."practice_sites_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_clinical_units_history_clinical_unit_id" ON "audit"."clinical_units_history" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_history_operation_concept_id" ON "audit"."clinical_units_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_history_changed_by_user_id" ON "audit"."clinical_units_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_history_change_reason_concept_id" ON "audit"."clinical_units_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_clinical_units_history_recorded_at" ON "audit"."clinical_units_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_care_spaces_history_care_space_id" ON "audit"."care_spaces_history" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_history_operation_concept_id" ON "audit"."care_spaces_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_history_changed_by_user_id" ON "audit"."care_spaces_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_history_change_reason_concept_id" ON "audit"."care_spaces_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_care_spaces_history_recorded_at" ON "audit"."care_spaces_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_history_diagnostic_report_id" ON "audit"."diagnostic_reports_history" ("diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_history_operation_concept_id" ON "audit"."diagnostic_reports_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_history_changed_by_user_id" ON "audit"."diagnostic_reports_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_history_change_reason_concept_id" ON "audit"."diagnostic_reports_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_diagnostic_reports_history_recorded_at" ON "audit"."diagnostic_reports_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_history_imaging_study_id" ON "audit"."imaging_studies_history" ("imaging_study_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_history_operation_concept_id" ON "audit"."imaging_studies_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_history_changed_by_user_id" ON "audit"."imaging_studies_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_history_change_reason_concept_id" ON "audit"."imaging_studies_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_imaging_studies_history_recorded_at" ON "audit"."imaging_studies_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_public_profiles_history_public_profile_id" ON "audit"."public_profiles_history" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_history_operation_concept_id" ON "audit"."public_profiles_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_history_changed_by_user_id" ON "audit"."public_profiles_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_history_change_reason_concept_id" ON "audit"."public_profiles_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_public_profiles_history_recorded_at" ON "audit"."public_profiles_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_social_posts_history_social_post_id" ON "audit"."social_posts_history" ("social_post_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_history_operation_concept_id" ON "audit"."social_posts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_history_changed_by_user_id" ON "audit"."social_posts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_history_change_reason_concept_id" ON "audit"."social_posts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_social_posts_history_recorded_at" ON "audit"."social_posts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_service_reviews_history_service_review_id" ON "audit"."service_reviews_history" ("service_review_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_history_operation_concept_id" ON "audit"."service_reviews_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_history_changed_by_user_id" ON "audit"."service_reviews_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_history_change_reason_concept_id" ON "audit"."service_reviews_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_service_reviews_history_recorded_at" ON "audit"."service_reviews_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_moderation_events_target_type_concept_id" ON "audit"."moderation_events" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_events_action_concept_id" ON "audit"."moderation_events" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_events_reason_concept_id" ON "audit"."moderation_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_events_recorded_by_user_id" ON "audit"."moderation_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_moderation_events_recorded_at" ON "audit"."moderation_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_patient_content_access_log_patient_profile_id" ON "audit"."patient_content_access_log" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_content_access_log_resource_type_concept_id" ON "audit"."patient_content_access_log" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_content_access_log_action_concept_id" ON "audit"."patient_content_access_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_content_access_log_purpose_of_use_concept_id" ON "audit"."patient_content_access_log" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_content_access_log_decision_concept_id" ON "audit"."patient_content_access_log" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_content_access_log_recorded_by_user_id" ON "audit"."patient_content_access_log" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_content_access_log_patient_profile_id_recorded_at" ON "audit"."patient_content_access_log" ("patient_profile_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_patient_content_access_log_recorded_at" ON "audit"."patient_content_access_log" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_history_organization_affi_157652c3" ON "audit"."organization_affiliations_history" ("organization_affiliation_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_history_operation_concept_id" ON "audit"."organization_affiliations_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_history_changed_by_user_id" ON "audit"."organization_affiliations_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_history_change_reason_concept_id" ON "audit"."organization_affiliations_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_organization_affiliations_history_recorded_at" ON "audit"."organization_affiliations_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_history_diagnostic_study_price_id" ON "audit"."diagnostic_study_prices_history" ("diagnostic_study_price_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_history_operation_concept_id" ON "audit"."diagnostic_study_prices_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_history_changed_by_user_id" ON "audit"."diagnostic_study_prices_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_history_change_reason_concept_id" ON "audit"."diagnostic_study_prices_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_diagnostic_study_prices_history_effective_period" ON "audit"."diagnostic_study_prices_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_diagnostic_study_prices_history_recorded_at" ON "audit"."diagnostic_study_prices_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_history_pharmacy_product_price_id" ON "audit"."pharmacy_product_prices_history" ("pharmacy_product_price_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_history_operation_concept_id" ON "audit"."pharmacy_product_prices_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_history_changed_by_user_id" ON "audit"."pharmacy_product_prices_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_history_change_reason_concept_id" ON "audit"."pharmacy_product_prices_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_pharmacy_product_prices_history_effective_period" ON "audit"."pharmacy_product_prices_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_pharmacy_product_prices_history_recorded_at" ON "audit"."pharmacy_product_prices_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_access_log_pharmacy_id" ON "audit"."pharmacy_inventory_access_log" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_access_log_actor_user_id" ON "audit"."pharmacy_inventory_access_log" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_access_log_action_concept_id" ON "audit"."pharmacy_inventory_access_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_access_log_target_type_concept_id" ON "audit"."pharmacy_inventory_access_log" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_access_log_purpose_of_use_concept_id" ON "audit"."pharmacy_inventory_access_log" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_access_log_outcome_concept_id" ON "audit"."pharmacy_inventory_access_log" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "brin_pharmacy_inventory_access_log_occurred_at" ON "audit"."pharmacy_inventory_access_log" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_insurance_carrier_id" ON "audit"."insurance_decision_access_log" ("insurance_carrier_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_actor_user_id" ON "audit"."insurance_decision_access_log" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_patient_profile_id" ON "audit"."insurance_decision_access_log" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_claim_id" ON "audit"."insurance_decision_access_log" ("claim_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_authorization_request_id" ON "audit"."insurance_decision_access_log" ("authorization_request_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_action_concept_id" ON "audit"."insurance_decision_access_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_purpose_of_use_concept_id" ON "audit"."insurance_decision_access_log" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_outcome_concept_id" ON "audit"."insurance_decision_access_log" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_decision_access_log_patient_profile_id_occurred_at" ON "audit"."insurance_decision_access_log" ("patient_profile_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_insurance_decision_access_log_occurred_at" ON "audit"."insurance_decision_access_log" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_identity_verification_access_log_verification_case_id" ON "audit"."identity_verification_access_log" ("verification_case_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_access_log_actor_user_id" ON "audit"."identity_verification_access_log" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_access_log_action_concept_id" ON "audit"."identity_verification_access_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_access_log_evidence_type_concept_id" ON "audit"."identity_verification_access_log" ("evidence_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_access_log_data_disclosed_value_set_id" ON "audit"."identity_verification_access_log" ("data_disclosed_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_access_log_purpose_of_use_concept_id" ON "audit"."identity_verification_access_log" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_verification_access_log_outcome_concept_id" ON "audit"."identity_verification_access_log" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "brin_identity_verification_access_log_occurred_at" ON "audit"."identity_verification_access_log" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_delegate_user_id" ON "audit"."delegated_access_audit_log" ("delegate_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_delegating_practitioner__a08f34c4" ON "audit"."delegated_access_audit_log" ("delegating_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_delegated_assignment_id" ON "audit"."delegated_access_audit_log" ("delegated_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_patient_profile_id" ON "audit"."delegated_access_audit_log" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_resource_type_concept_id" ON "audit"."delegated_access_audit_log" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_action_concept_id" ON "audit"."delegated_access_audit_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_outcome_concept_id" ON "audit"."delegated_access_audit_log" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_audit_log_patient_profile_id_occurred_at" ON "audit"."delegated_access_audit_log" ("patient_profile_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_delegated_access_audit_log_occurred_at" ON "audit"."delegated_access_audit_log" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_analytics_governance_log_actor_user_id" ON "audit"."analytics_governance_log" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_analytics_governance_log_action_concept_id" ON "audit"."analytics_governance_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_analytics_governance_log_purpose_definition_id" ON "audit"."analytics_governance_log" ("purpose_definition_id");

CREATE INDEX IF NOT EXISTS "ix_analytics_governance_log_approval_status_concept_id" ON "audit"."analytics_governance_log" ("approval_status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_analytics_governance_log_occurred_at" ON "audit"."analytics_governance_log" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_conditions_history_condition_id" ON "audit"."conditions_history" ("condition_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_history_operation_concept_id" ON "audit"."conditions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_history_changed_by_user_id" ON "audit"."conditions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_history_change_reason_concept_id" ON "audit"."conditions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_conditions_history_recorded_at" ON "audit"."conditions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_history_allergy_intolerance_id" ON "audit"."allergy_intolerances_history" ("allergy_intolerance_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_history_operation_concept_id" ON "audit"."allergy_intolerances_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_history_changed_by_user_id" ON "audit"."allergy_intolerances_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_history_change_reason_concept_id" ON "audit"."allergy_intolerances_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_allergy_intolerances_history_recorded_at" ON "audit"."allergy_intolerances_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_medication_requests_history_medication_request_id" ON "audit"."medication_requests_history" ("medication_request_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_history_operation_concept_id" ON "audit"."medication_requests_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_history_changed_by_user_id" ON "audit"."medication_requests_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_history_change_reason_concept_id" ON "audit"."medication_requests_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_medication_requests_history_recorded_at" ON "audit"."medication_requests_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_practices_history_practice_id" ON "audit"."practices_history" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practices_history_operation_concept_id" ON "audit"."practices_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practices_history_changed_by_user_id" ON "audit"."practices_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practices_history_change_reason_concept_id" ON "audit"."practices_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_practices_history_recorded_at" ON "audit"."practices_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_history_clinical_note_header_id" ON "audit"."clinical_note_headers_history" ("clinical_note_header_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_history_operation_concept_id" ON "audit"."clinical_note_headers_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_history_changed_by_user_id" ON "audit"."clinical_note_headers_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_history_change_reason_concept_id" ON "audit"."clinical_note_headers_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_clinical_note_headers_history_recorded_at" ON "audit"."clinical_note_headers_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_care_plans_history_care_plan_id" ON "audit"."care_plans_history" ("care_plan_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_history_operation_concept_id" ON "audit"."care_plans_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_history_changed_by_user_id" ON "audit"."care_plans_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_history_change_reason_concept_id" ON "audit"."care_plans_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_care_plans_history_recorded_at" ON "audit"."care_plans_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_document_records_history_document_record_id" ON "audit"."document_records_history" ("document_record_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_history_operation_concept_id" ON "audit"."document_records_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_history_changed_by_user_id" ON "audit"."document_records_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_history_change_reason_concept_id" ON "audit"."document_records_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_document_records_history_recorded_at" ON "audit"."document_records_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_care_teams_history_care_team_id" ON "audit"."care_teams_history" ("care_team_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_history_operation_concept_id" ON "audit"."care_teams_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_history_changed_by_user_id" ON "audit"."care_teams_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_history_change_reason_concept_id" ON "audit"."care_teams_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_care_teams_history_recorded_at" ON "audit"."care_teams_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_referrals_history_referral_id" ON "audit"."referrals_history" ("referral_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_history_operation_concept_id" ON "audit"."referrals_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_history_changed_by_user_id" ON "audit"."referrals_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_history_change_reason_concept_id" ON "audit"."referrals_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_referrals_history_recorded_at" ON "audit"."referrals_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_history_clinical_alert_id" ON "audit"."clinical_alerts_history" ("clinical_alert_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_history_operation_concept_id" ON "audit"."clinical_alerts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_history_changed_by_user_id" ON "audit"."clinical_alerts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_history_change_reason_concept_id" ON "audit"."clinical_alerts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_clinical_alerts_history_recorded_at" ON "audit"."clinical_alerts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_cds_rules_history_cds_rule_id" ON "audit"."cds_rules_history" ("cds_rule_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_history_operation_concept_id" ON "audit"."cds_rules_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_history_changed_by_user_id" ON "audit"."cds_rules_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_history_change_reason_concept_id" ON "audit"."cds_rules_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_cds_rules_history_recorded_at" ON "audit"."cds_rules_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_order_sets_history_order_set_id" ON "audit"."order_sets_history" ("order_set_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_history_operation_concept_id" ON "audit"."order_sets_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_history_changed_by_user_id" ON "audit"."order_sets_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_history_change_reason_concept_id" ON "audit"."order_sets_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_order_sets_history_recorded_at" ON "audit"."order_sets_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_provider_connections_history_provider_connection_id" ON "audit"."provider_connections_history" ("provider_connection_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_history_operation_concept_id" ON "audit"."provider_connections_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_history_changed_by_user_id" ON "audit"."provider_connections_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_history_change_reason_concept_id" ON "audit"."provider_connections_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_provider_connections_history_recorded_at" ON "audit"."provider_connections_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_history_integration_endpoint_id" ON "audit"."integration_endpoints_history" ("integration_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_history_operation_concept_id" ON "audit"."integration_endpoints_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_history_changed_by_user_id" ON "audit"."integration_endpoints_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_history_change_reason_concept_id" ON "audit"."integration_endpoints_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_integration_endpoints_history_recorded_at" ON "audit"."integration_endpoints_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_history_outbound_message_id" ON "audit"."outbound_messages_history" ("outbound_message_id");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_history_operation_concept_id" ON "audit"."outbound_messages_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_history_changed_by_user_id" ON "audit"."outbound_messages_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_history_change_reason_concept_id" ON "audit"."outbound_messages_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_outbound_messages_history_recorded_at" ON "audit"."outbound_messages_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_history_inbound_message_id" ON "audit"."inbound_messages_history" ("inbound_message_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_history_operation_concept_id" ON "audit"."inbound_messages_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_history_changed_by_user_id" ON "audit"."inbound_messages_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_history_change_reason_concept_id" ON "audit"."inbound_messages_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_inbound_messages_history_recorded_at" ON "audit"."inbound_messages_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_message_retries_history_message_retry_id" ON "audit"."message_retries_history" ("message_retry_id");

CREATE INDEX IF NOT EXISTS "ix_message_retries_history_operation_concept_id" ON "audit"."message_retries_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_retries_history_changed_by_user_id" ON "audit"."message_retries_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_retries_history_change_reason_concept_id" ON "audit"."message_retries_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_message_retries_history_recorded_at" ON "audit"."message_retries_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_accounts_history_account_id" ON "audit"."accounts_history" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_history_operation_concept_id" ON "audit"."accounts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_history_changed_by_user_id" ON "audit"."accounts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_history_change_reason_concept_id" ON "audit"."accounts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_accounts_history_recorded_at" ON "audit"."accounts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_history_journal_transaction_id" ON "audit"."journal_transactions_history" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_history_operation_concept_id" ON "audit"."journal_transactions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_history_changed_by_user_id" ON "audit"."journal_transactions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_history_change_reason_concept_id" ON "audit"."journal_transactions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_journal_transactions_history_recorded_at" ON "audit"."journal_transactions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_assets_history_asset_id" ON "audit"."assets_history" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_assets_history_operation_concept_id" ON "audit"."assets_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assets_history_changed_by_user_id" ON "audit"."assets_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assets_history_change_reason_concept_id" ON "audit"."assets_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_assets_history_recorded_at" ON "audit"."assets_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_liabilities_history_liability_id" ON "audit"."liabilities_history" ("liability_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_history_operation_concept_id" ON "audit"."liabilities_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_history_changed_by_user_id" ON "audit"."liabilities_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_history_change_reason_concept_id" ON "audit"."liabilities_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_liabilities_history_recorded_at" ON "audit"."liabilities_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_invoices_history_invoice_id" ON "audit"."invoices_history" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_history_operation_concept_id" ON "audit"."invoices_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_history_changed_by_user_id" ON "audit"."invoices_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_history_change_reason_concept_id" ON "audit"."invoices_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_invoices_history_recorded_at" ON "audit"."invoices_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_bills_history_bill_id" ON "audit"."bills_history" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_bills_history_operation_concept_id" ON "audit"."bills_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_bills_history_changed_by_user_id" ON "audit"."bills_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bills_history_change_reason_concept_id" ON "audit"."bills_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_bills_history_recorded_at" ON "audit"."bills_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_history_insurance_claim_id" ON "audit"."insurance_claims_history" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_history_operation_concept_id" ON "audit"."insurance_claims_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_history_changed_by_user_id" ON "audit"."insurance_claims_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_history_change_reason_concept_id" ON "audit"."insurance_claims_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_insurance_claims_history_recorded_at" ON "audit"."insurance_claims_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_message_templates_history_message_template_id" ON "audit"."message_templates_history" ("message_template_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_history_operation_concept_id" ON "audit"."message_templates_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_history_changed_by_user_id" ON "audit"."message_templates_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_history_change_reason_concept_id" ON "audit"."message_templates_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_message_templates_history_recorded_at" ON "audit"."message_templates_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_history_provider_channel_config_id" ON "audit"."provider_channel_configs_history" ("provider_channel_config_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_history_operation_concept_id" ON "audit"."provider_channel_configs_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_history_changed_by_user_id" ON "audit"."provider_channel_configs_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_history_change_reason_concept_id" ON "audit"."provider_channel_configs_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_provider_channel_configs_history_recorded_at" ON "audit"."provider_channel_configs_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_history_event_subscription_id" ON "audit"."event_subscriptions_history" ("event_subscription_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_history_operation_concept_id" ON "audit"."event_subscriptions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_history_changed_by_user_id" ON "audit"."event_subscriptions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_history_change_reason_concept_id" ON "audit"."event_subscriptions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_event_subscriptions_history_recorded_at" ON "audit"."event_subscriptions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_test_suites_history_test_suite_id" ON "audit"."test_suites_history" ("test_suite_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_history_operation_concept_id" ON "audit"."test_suites_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_history_changed_by_user_id" ON "audit"."test_suites_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_history_change_reason_concept_id" ON "audit"."test_suites_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_test_suites_history_recorded_at" ON "audit"."test_suites_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_test_cases_history_test_case_id" ON "audit"."test_cases_history" ("test_case_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_history_operation_concept_id" ON "audit"."test_cases_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_history_changed_by_user_id" ON "audit"."test_cases_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_history_change_reason_concept_id" ON "audit"."test_cases_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_test_cases_history_recorded_at" ON "audit"."test_cases_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_history_trackable_subject_id" ON "audit"."trackable_subjects_history" ("trackable_subject_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_history_operation_concept_id" ON "audit"."trackable_subjects_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_history_changed_by_user_id" ON "audit"."trackable_subjects_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_history_change_reason_concept_id" ON "audit"."trackable_subjects_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_trackable_subjects_history_recorded_at" ON "audit"."trackable_subjects_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_shipments_history_shipment_id" ON "audit"."shipments_history" ("shipment_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_history_operation_concept_id" ON "audit"."shipments_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_history_changed_by_user_id" ON "audit"."shipments_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_history_change_reason_concept_id" ON "audit"."shipments_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_shipments_history_recorded_at" ON "audit"."shipments_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_contracts_history_contract_id" ON "audit"."contracts_history" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_history_operation_concept_id" ON "audit"."contracts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_history_changed_by_user_id" ON "audit"."contracts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_history_change_reason_concept_id" ON "audit"."contracts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_contracts_history_recorded_at" ON "audit"."contracts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_employment_records_history_employment_record_id" ON "audit"."employment_records_history" ("employment_record_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_history_operation_concept_id" ON "audit"."employment_records_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_history_changed_by_user_id" ON "audit"."employment_records_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_history_change_reason_concept_id" ON "audit"."employment_records_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_employment_records_history_recorded_at" ON "audit"."employment_records_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_departments_history_department_id" ON "audit"."departments_history" ("department_id");

CREATE INDEX IF NOT EXISTS "ix_departments_history_operation_concept_id" ON "audit"."departments_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_departments_history_changed_by_user_id" ON "audit"."departments_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_departments_history_change_reason_concept_id" ON "audit"."departments_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_departments_history_recorded_at" ON "audit"."departments_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_positions_history_position_id" ON "audit"."positions_history" ("position_id");

CREATE INDEX IF NOT EXISTS "ix_positions_history_operation_concept_id" ON "audit"."positions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_positions_history_changed_by_user_id" ON "audit"."positions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_positions_history_change_reason_concept_id" ON "audit"."positions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_positions_history_recorded_at" ON "audit"."positions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_report_definitions_history_report_definition_id" ON "audit"."report_definitions_history" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_history_operation_concept_id" ON "audit"."report_definitions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_history_changed_by_user_id" ON "audit"."report_definitions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_history_change_reason_concept_id" ON "audit"."report_definitions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_report_definitions_history_recorded_at" ON "audit"."report_definitions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_report_schedules_history_report_schedule_id" ON "audit"."report_schedules_history" ("report_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_history_operation_concept_id" ON "audit"."report_schedules_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_history_changed_by_user_id" ON "audit"."report_schedules_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_history_change_reason_concept_id" ON "audit"."report_schedules_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_report_schedules_history_effective_period" ON "audit"."report_schedules_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_report_schedules_history_recorded_at" ON "audit"."report_schedules_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_identity_providers_history_identity_provider_id" ON "audit"."identity_providers_history" ("identity_provider_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_history_operation_concept_id" ON "audit"."identity_providers_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_history_changed_by_user_id" ON "audit"."identity_providers_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_history_change_reason_concept_id" ON "audit"."identity_providers_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_identity_providers_history_recorded_at" ON "audit"."identity_providers_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_history_provider_protocol_c117b009" ON "audit"."provider_protocol_configs_history" ("provider_protocol_config_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_history_operation_concept_id" ON "audit"."provider_protocol_configs_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_history_changed_by_user_id" ON "audit"."provider_protocol_configs_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_history_change_reason_concept_id" ON "audit"."provider_protocol_configs_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_provider_protocol_configs_history_recorded_at" ON "audit"."provider_protocol_configs_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_history_provider_tenant_binding_id" ON "audit"."provider_tenant_bindings_history" ("provider_tenant_binding_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_history_operation_concept_id" ON "audit"."provider_tenant_bindings_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_history_changed_by_user_id" ON "audit"."provider_tenant_bindings_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_history_change_reason_concept_id" ON "audit"."provider_tenant_bindings_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_provider_tenant_bindings_history_recorded_at" ON "audit"."provider_tenant_bindings_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_federated_identities_history_federated_identity_id" ON "audit"."federated_identities_history" ("federated_identity_id");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_history_operation_concept_id" ON "audit"."federated_identities_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_history_changed_by_user_id" ON "audit"."federated_identities_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_history_change_reason_concept_id" ON "audit"."federated_identities_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_federated_identities_history_recorded_at" ON "audit"."federated_identities_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_history_schedule_template_id" ON "audit"."schedule_templates_history" ("schedule_template_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_history_operation_concept_id" ON "audit"."schedule_templates_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_history_changed_by_user_id" ON "audit"."schedule_templates_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_history_change_reason_concept_id" ON "audit"."schedule_templates_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_schedule_templates_history_effective_period" ON "audit"."schedule_templates_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_schedule_templates_history_recorded_at" ON "audit"."schedule_templates_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_booking_policies_history_booking_policy_id" ON "audit"."booking_policies_history" ("booking_policy_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_history_operation_concept_id" ON "audit"."booking_policies_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_history_changed_by_user_id" ON "audit"."booking_policies_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_history_change_reason_concept_id" ON "audit"."booking_policies_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_booking_policies_history_recorded_at" ON "audit"."booking_policies_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_history_appointment_booking_id" ON "audit"."appointment_bookings_history" ("appointment_booking_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_history_operation_concept_id" ON "audit"."appointment_bookings_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_history_changed_by_user_id" ON "audit"."appointment_bookings_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_history_change_reason_concept_id" ON "audit"."appointment_bookings_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_appointment_bookings_history_effective_period" ON "audit"."appointment_bookings_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_appointment_bookings_history_recorded_at" ON "audit"."appointment_bookings_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_payment_methods_history_payment_method_id" ON "audit"."payment_methods_history" ("payment_method_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_history_operation_concept_id" ON "audit"."payment_methods_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_history_changed_by_user_id" ON "audit"."payment_methods_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_history_change_reason_concept_id" ON "audit"."payment_methods_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_payment_methods_history_recorded_at" ON "audit"."payment_methods_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_payment_intents_history_payment_intent_id" ON "audit"."payment_intents_history" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_history_operation_concept_id" ON "audit"."payment_intents_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_history_changed_by_user_id" ON "audit"."payment_intents_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_history_change_reason_concept_id" ON "audit"."payment_intents_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_payment_intents_history_recorded_at" ON "audit"."payment_intents_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_history_payment_transaction_id" ON "audit"."payment_transactions_history" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_history_operation_concept_id" ON "audit"."payment_transactions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_history_changed_by_user_id" ON "audit"."payment_transactions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_history_change_reason_concept_id" ON "audit"."payment_transactions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_payment_transactions_history_recorded_at" ON "audit"."payment_transactions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_payouts_history_payout_id" ON "audit"."payouts_history" ("payout_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_history_operation_concept_id" ON "audit"."payouts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_history_changed_by_user_id" ON "audit"."payouts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_history_change_reason_concept_id" ON "audit"."payouts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_payouts_history_recorded_at" ON "audit"."payouts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_history_ad_account_id" ON "audit"."ad_accounts_history" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_history_operation_concept_id" ON "audit"."ad_accounts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_history_changed_by_user_id" ON "audit"."ad_accounts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_history_change_reason_concept_id" ON "audit"."ad_accounts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_ad_accounts_history_recorded_at" ON "audit"."ad_accounts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_campaigns_history_campaign_id" ON "audit"."campaigns_history" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_history_operation_concept_id" ON "audit"."campaigns_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_history_changed_by_user_id" ON "audit"."campaigns_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_history_change_reason_concept_id" ON "audit"."campaigns_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_campaigns_history_recorded_at" ON "audit"."campaigns_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_sets_history_ad_set_id" ON "audit"."ad_sets_history" ("ad_set_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_history_operation_concept_id" ON "audit"."ad_sets_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_history_changed_by_user_id" ON "audit"."ad_sets_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_history_change_reason_concept_id" ON "audit"."ad_sets_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_ad_sets_history_recorded_at" ON "audit"."ad_sets_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ads_history_ad_id" ON "audit"."ads_history" ("ad_id");

CREATE INDEX IF NOT EXISTS "ix_ads_history_operation_concept_id" ON "audit"."ads_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ads_history_changed_by_user_id" ON "audit"."ads_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ads_history_change_reason_concept_id" ON "audit"."ads_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_ads_history_recorded_at" ON "audit"."ads_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_history_ad_creative_id" ON "audit"."ad_creatives_history" ("ad_creative_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_history_operation_concept_id" ON "audit"."ad_creatives_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_history_changed_by_user_id" ON "audit"."ad_creatives_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_history_change_reason_concept_id" ON "audit"."ad_creatives_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_ad_creatives_history_recorded_at" ON "audit"."ad_creatives_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_history_custom_audience_id" ON "audit"."custom_audiences_history" ("custom_audience_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_history_operation_concept_id" ON "audit"."custom_audiences_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_history_changed_by_user_id" ON "audit"."custom_audiences_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_history_change_reason_concept_id" ON "audit"."custom_audiences_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_custom_audiences_history_recorded_at" ON "audit"."custom_audiences_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_wallets_history_wallets_id" ON "audit"."wallets_history" ("wallets_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_history_operation_concept_id" ON "audit"."wallets_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_history_changed_by_user_id" ON "audit"."wallets_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_history_change_reason_concept_id" ON "audit"."wallets_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_wallets_history_recorded_at" ON "audit"."wallets_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_history_subscription_plans_id" ON "audit"."subscription_plans_history" ("subscription_plans_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_history_operation_concept_id" ON "audit"."subscription_plans_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_history_changed_by_user_id" ON "audit"."subscription_plans_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_history_change_reason_concept_id" ON "audit"."subscription_plans_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_subscription_plans_history_recorded_at" ON "audit"."subscription_plans_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_subscriptions_history_subscriptions_id" ON "audit"."subscriptions_history" ("subscriptions_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_history_operation_concept_id" ON "audit"."subscriptions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_history_changed_by_user_id" ON "audit"."subscriptions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_history_change_reason_concept_id" ON "audit"."subscriptions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_subscriptions_history_recorded_at" ON "audit"."subscriptions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_history_connected_accounts_id" ON "audit"."connected_accounts_history" ("connected_accounts_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_history_operation_concept_id" ON "audit"."connected_accounts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_history_changed_by_user_id" ON "audit"."connected_accounts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_history_change_reason_concept_id" ON "audit"."connected_accounts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_connected_accounts_history_recorded_at" ON "audit"."connected_accounts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_history_payment_mandates_id" ON "audit"."payment_mandates_history" ("payment_mandates_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_history_operation_concept_id" ON "audit"."payment_mandates_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_history_changed_by_user_id" ON "audit"."payment_mandates_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_history_change_reason_concept_id" ON "audit"."payment_mandates_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_payment_mandates_history_recorded_at" ON "audit"."payment_mandates_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_history_product_catalogs_id" ON "audit"."product_catalogs_history" ("product_catalogs_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_history_operation_concept_id" ON "audit"."product_catalogs_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_history_changed_by_user_id" ON "audit"."product_catalogs_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_history_change_reason_concept_id" ON "audit"."product_catalogs_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_product_catalogs_history_recorded_at" ON "audit"."product_catalogs_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_catalog_products_history_catalog_products_id" ON "audit"."catalog_products_history" ("catalog_products_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_history_operation_concept_id" ON "audit"."catalog_products_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_history_changed_by_user_id" ON "audit"."catalog_products_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_history_change_reason_concept_id" ON "audit"."catalog_products_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_catalog_products_history_recorded_at" ON "audit"."catalog_products_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_product_sets_history_product_sets_id" ON "audit"."product_sets_history" ("product_sets_id");

CREATE INDEX IF NOT EXISTS "ix_product_sets_history_operation_concept_id" ON "audit"."product_sets_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_sets_history_changed_by_user_id" ON "audit"."product_sets_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_product_sets_history_change_reason_concept_id" ON "audit"."product_sets_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_product_sets_history_recorded_at" ON "audit"."product_sets_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_automated_rules_history_automated_rules_id" ON "audit"."automated_rules_history" ("automated_rules_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_history_operation_concept_id" ON "audit"."automated_rules_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_history_changed_by_user_id" ON "audit"."automated_rules_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_history_change_reason_concept_id" ON "audit"."automated_rules_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_automated_rules_history_recorded_at" ON "audit"."automated_rules_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_history_custom_conversions_id" ON "audit"."custom_conversions_history" ("custom_conversions_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_history_operation_concept_id" ON "audit"."custom_conversions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_history_changed_by_user_id" ON "audit"."custom_conversions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_history_change_reason_concept_id" ON "audit"."custom_conversions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_custom_conversions_history_recorded_at" ON "audit"."custom_conversions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_history_ad_experiments_id" ON "audit"."ad_experiments_history" ("ad_experiments_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_history_operation_concept_id" ON "audit"."ad_experiments_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_history_changed_by_user_id" ON "audit"."ad_experiments_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_history_change_reason_concept_id" ON "audit"."ad_experiments_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_ad_experiments_history_recorded_at" ON "audit"."ad_experiments_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_comments_history_comments_id" ON "audit"."comments_history" ("comments_id");

CREATE INDEX IF NOT EXISTS "ix_comments_history_operation_concept_id" ON "audit"."comments_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_comments_history_changed_by_user_id" ON "audit"."comments_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_comments_history_change_reason_concept_id" ON "audit"."comments_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_comments_history_recorded_at" ON "audit"."comments_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_groups_history_groups_id" ON "audit"."groups_history" ("groups_id");

CREATE INDEX IF NOT EXISTS "ix_groups_history_operation_concept_id" ON "audit"."groups_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_groups_history_changed_by_user_id" ON "audit"."groups_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_groups_history_change_reason_concept_id" ON "audit"."groups_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_groups_history_recorded_at" ON "audit"."groups_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_topics_history_topics_id" ON "audit"."topics_history" ("topics_id");

CREATE INDEX IF NOT EXISTS "ix_topics_history_operation_concept_id" ON "audit"."topics_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_topics_history_changed_by_user_id" ON "audit"."topics_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_topics_history_change_reason_concept_id" ON "audit"."topics_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_topics_history_recorded_at" ON "audit"."topics_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_conversations_history_conversations_id" ON "audit"."conversations_history" ("conversations_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_history_operation_concept_id" ON "audit"."conversations_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_history_changed_by_user_id" ON "audit"."conversations_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_history_change_reason_concept_id" ON "audit"."conversations_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_conversations_history_recorded_at" ON "audit"."conversations_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_verified_badges_history_verified_badges_id" ON "audit"."verified_badges_history" ("verified_badges_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_history_operation_concept_id" ON "audit"."verified_badges_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_history_changed_by_user_id" ON "audit"."verified_badges_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_history_change_reason_concept_id" ON "audit"."verified_badges_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_verified_badges_history_recorded_at" ON "audit"."verified_badges_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_history_moderation_decisions_id" ON "audit"."moderation_decisions_history" ("moderation_decisions_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_history_operation_concept_id" ON "audit"."moderation_decisions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_history_changed_by_user_id" ON "audit"."moderation_decisions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_history_change_reason_concept_id" ON "audit"."moderation_decisions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_moderation_decisions_history_recorded_at" ON "audit"."moderation_decisions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_courses_history_courses_id" ON "audit"."courses_history" ("courses_id");

CREATE INDEX IF NOT EXISTS "ix_courses_history_operation_concept_id" ON "audit"."courses_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_history_changed_by_user_id" ON "audit"."courses_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_courses_history_change_reason_concept_id" ON "audit"."courses_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_courses_history_recorded_at" ON "audit"."courses_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_course_versions_history_course_versions_id" ON "audit"."course_versions_history" ("course_versions_id");

CREATE INDEX IF NOT EXISTS "ix_course_versions_history_operation_concept_id" ON "audit"."course_versions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_course_versions_history_changed_by_user_id" ON "audit"."course_versions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_versions_history_change_reason_concept_id" ON "audit"."course_versions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_course_versions_history_recorded_at" ON "audit"."course_versions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_enrollments_history_enrollments_id" ON "audit"."enrollments_history" ("enrollments_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_history_operation_concept_id" ON "audit"."enrollments_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_history_changed_by_user_id" ON "audit"."enrollments_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_history_change_reason_concept_id" ON "audit"."enrollments_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_enrollments_history_recorded_at" ON "audit"."enrollments_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_certificates_history_certificates_id" ON "audit"."certificates_history" ("certificates_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_history_operation_concept_id" ON "audit"."certificates_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_history_changed_by_user_id" ON "audit"."certificates_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_history_change_reason_concept_id" ON "audit"."certificates_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_certificates_history_recorded_at" ON "audit"."certificates_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_agents_history_agents_id" ON "audit"."agents_history" ("agents_id");

CREATE INDEX IF NOT EXISTS "ix_agents_history_operation_concept_id" ON "audit"."agents_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agents_history_changed_by_user_id" ON "audit"."agents_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agents_history_change_reason_concept_id" ON "audit"."agents_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_agents_history_recorded_at" ON "audit"."agents_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_agent_versions_history_agent_versions_id" ON "audit"."agent_versions_history" ("agent_versions_id");

CREATE INDEX IF NOT EXISTS "ix_agent_versions_history_operation_concept_id" ON "audit"."agent_versions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_versions_history_changed_by_user_id" ON "audit"."agent_versions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_versions_history_change_reason_concept_id" ON "audit"."agent_versions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_agent_versions_history_recorded_at" ON "audit"."agent_versions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_workflows_history_workflows_id" ON "audit"."workflows_history" ("workflows_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_history_operation_concept_id" ON "audit"."workflows_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_history_changed_by_user_id" ON "audit"."workflows_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_history_change_reason_concept_id" ON "audit"."workflows_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_workflows_history_recorded_at" ON "audit"."workflows_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_history_guardrail_policies_id" ON "audit"."guardrail_policies_history" ("guardrail_policies_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_history_operation_concept_id" ON "audit"."guardrail_policies_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_history_changed_by_user_id" ON "audit"."guardrail_policies_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_history_change_reason_concept_id" ON "audit"."guardrail_policies_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_guardrail_policies_history_recorded_at" ON "audit"."guardrail_policies_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_record_automations_history_record_automations_id" ON "audit"."record_automations_history" ("record_automations_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_history_operation_concept_id" ON "audit"."record_automations_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_history_changed_by_user_id" ON "audit"."record_automations_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_history_change_reason_concept_id" ON "audit"."record_automations_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_record_automations_history_recorded_at" ON "audit"."record_automations_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_history_crm_accounts_id" ON "audit"."crm_accounts_history" ("crm_accounts_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_history_operation_concept_id" ON "audit"."crm_accounts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_history_changed_by_user_id" ON "audit"."crm_accounts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_history_change_reason_concept_id" ON "audit"."crm_accounts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_crm_accounts_history_recorded_at" ON "audit"."crm_accounts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_contacts_history_contacts_id" ON "audit"."contacts_history" ("contacts_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_history_operation_concept_id" ON "audit"."contacts_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_history_changed_by_user_id" ON "audit"."contacts_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_history_change_reason_concept_id" ON "audit"."contacts_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_contacts_history_recorded_at" ON "audit"."contacts_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_opportunities_history_opportunities_id" ON "audit"."opportunities_history" ("opportunities_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_history_operation_concept_id" ON "audit"."opportunities_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_history_changed_by_user_id" ON "audit"."opportunities_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_history_change_reason_concept_id" ON "audit"."opportunities_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_opportunities_history_recorded_at" ON "audit"."opportunities_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_partnerships_history_partnerships_id" ON "audit"."partnerships_history" ("partnerships_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_history_operation_concept_id" ON "audit"."partnerships_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_history_changed_by_user_id" ON "audit"."partnerships_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_history_change_reason_concept_id" ON "audit"."partnerships_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_partnerships_history_recorded_at" ON "audit"."partnerships_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_history_partnership_agreements_id" ON "audit"."partnership_agreements_history" ("partnership_agreements_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_history_operation_concept_id" ON "audit"."partnership_agreements_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_history_changed_by_user_id" ON "audit"."partnership_agreements_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_history_change_reason_concept_id" ON "audit"."partnership_agreements_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_partnership_agreements_history_effective_period" ON "audit"."partnership_agreements_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_partnership_agreements_history_recorded_at" ON "audit"."partnership_agreements_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_segments_history_segments_id" ON "audit"."segments_history" ("segments_id");

CREATE INDEX IF NOT EXISTS "ix_segments_history_operation_concept_id" ON "audit"."segments_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_segments_history_changed_by_user_id" ON "audit"."segments_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_segments_history_change_reason_concept_id" ON "audit"."segments_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_segments_history_recorded_at" ON "audit"."segments_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_history_marketing_campaigns_id" ON "audit"."marketing_campaigns_history" ("marketing_campaigns_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_history_operation_concept_id" ON "audit"."marketing_campaigns_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_history_changed_by_user_id" ON "audit"."marketing_campaigns_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_history_change_reason_concept_id" ON "audit"."marketing_campaigns_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_marketing_campaigns_history_recorded_at" ON "audit"."marketing_campaigns_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_journeys_history_journeys_id" ON "audit"."journeys_history" ("journeys_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_history_operation_concept_id" ON "audit"."journeys_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_history_changed_by_user_id" ON "audit"."journeys_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_history_change_reason_concept_id" ON "audit"."journeys_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_journeys_history_recorded_at" ON "audit"."journeys_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_history_loyalty_programs_id" ON "audit"."loyalty_programs_history" ("loyalty_programs_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_history_operation_concept_id" ON "audit"."loyalty_programs_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_history_changed_by_user_id" ON "audit"."loyalty_programs_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_history_change_reason_concept_id" ON "audit"."loyalty_programs_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_loyalty_programs_history_recorded_at" ON "audit"."loyalty_programs_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_history_loyalty_memberships_id" ON "audit"."loyalty_memberships_history" ("loyalty_memberships_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_history_operation_concept_id" ON "audit"."loyalty_memberships_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_history_changed_by_user_id" ON "audit"."loyalty_memberships_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_history_change_reason_concept_id" ON "audit"."loyalty_memberships_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "gist_loyalty_memberships_history_effective_period" ON "audit"."loyalty_memberships_history" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "brin_loyalty_memberships_history_recorded_at" ON "audit"."loyalty_memberships_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_promotions_history_promotions_id" ON "audit"."promotions_history" ("promotions_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_history_operation_concept_id" ON "audit"."promotions_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_history_changed_by_user_id" ON "audit"."promotions_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_history_change_reason_concept_id" ON "audit"."promotions_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_promotions_history_recorded_at" ON "audit"."promotions_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_coupons_history_coupons_id" ON "audit"."coupons_history" ("coupons_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_history_operation_concept_id" ON "audit"."coupons_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_history_changed_by_user_id" ON "audit"."coupons_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_history_change_reason_concept_id" ON "audit"."coupons_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_coupons_history_recorded_at" ON "audit"."coupons_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_referral_programs_history_referral_programs_id" ON "audit"."referral_programs_history" ("referral_programs_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_history_operation_concept_id" ON "audit"."referral_programs_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_history_changed_by_user_id" ON "audit"."referral_programs_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_history_change_reason_concept_id" ON "audit"."referral_programs_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_referral_programs_history_recorded_at" ON "audit"."referral_programs_history" USING brin ("recorded_at") WITH (pages_per_range=128);
