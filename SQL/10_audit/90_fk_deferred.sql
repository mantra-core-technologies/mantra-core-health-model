-- SALUD v4.0.10 · módulo 10 · schema audit
-- Generado de diagram_10_audit.puml — NO editar a mano.


-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."audit_log"
        ADD CONSTRAINT "fk_audit_log_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."audit_log"
        ADD CONSTRAINT "fk_audit_log_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."audit_log"
        ADD CONSTRAINT "fk_audit_log_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."audit_log"
        ADD CONSTRAINT "fk_audit_log_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."audit_log"
        ADD CONSTRAINT "fk_audit_log_device_id" FOREIGN KEY ("device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."audit_log"
        ADD CONSTRAINT "fk_audit_log_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."data_access_log"
        ADD CONSTRAINT "fk_data_access_log_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."data_access_log"
        ADD CONSTRAINT "fk_data_access_log_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."data_access_log"
        ADD CONSTRAINT "fk_data_access_log_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."data_access_log"
        ADD CONSTRAINT "fk_data_access_log_legal_basis_concept_id" FOREIGN KEY ("legal_basis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."data_access_log"
        ADD CONSTRAINT "fk_data_access_log_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."data_access_log"
        ADD CONSTRAINT "fk_data_access_log_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."dsar_requests"
        ADD CONSTRAINT "fk_dsar_requests_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."dsar_requests"
        ADD CONSTRAINT "fk_dsar_requests_type_concept_id" FOREIGN KEY ("type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."dsar_requests"
        ADD CONSTRAINT "fk_dsar_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."dsar_requests"
        ADD CONSTRAINT "fk_dsar_requests_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "audit"."dsar_requests"
        ADD CONSTRAINT "fk_dsar_requests_result_file_id" FOREIGN KEY ("result_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."dsar_requests"
        ADD CONSTRAINT "fk_dsar_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."dsar_requests"
        ADD CONSTRAINT "fk_dsar_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."users_history"
        ADD CONSTRAINT "fk_users_history_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."users_history"
        ADD CONSTRAINT "fk_users_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."users_history"
        ADD CONSTRAINT "fk_users_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."users_history"
        ADD CONSTRAINT "fk_users_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."tenants_history"
        ADD CONSTRAINT "fk_tenants_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."tenants_history"
        ADD CONSTRAINT "fk_tenants_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."tenants_history"
        ADD CONSTRAINT "fk_tenants_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."tenants_history"
        ADD CONSTRAINT "fk_tenants_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_profiles_history"
        ADD CONSTRAINT "fk_patient_profiles_history_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_profiles_history"
        ADD CONSTRAINT "fk_patient_profiles_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_profiles_history"
        ADD CONSTRAINT "fk_patient_profiles_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_profiles_history"
        ADD CONSTRAINT "fk_patient_profiles_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."health_practitioner_profiles_history"
        ADD CONSTRAINT "fk_health_practitioner_profiles_history_health_practit_b2903f37" FOREIGN KEY ("health_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."health_practitioner_profiles_history"
        ADD CONSTRAINT "fk_health_practitioner_profiles_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."health_practitioner_profiles_history"
        ADD CONSTRAINT "fk_health_practitioner_profiles_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."health_practitioner_profiles_history"
        ADD CONSTRAINT "fk_health_practitioner_profiles_history_change_reason__8785974d" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.professional_credentials (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."professional_credentials_history"
        ADD CONSTRAINT "fk_professional_credentials_history_professional_credential_id" FOREIGN KEY ("professional_credential_id")
        REFERENCES "profiles"."professional_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."professional_credentials_history"
        ADD CONSTRAINT "fk_professional_credentials_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."professional_credentials_history"
        ADD CONSTRAINT "fk_professional_credentials_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."professional_credentials_history"
        ADD CONSTRAINT "fk_professional_credentials_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.jurisdiction_authorizations (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."jurisdiction_authorizations_history"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_history_jurisdiction_au_5b12cb5b" FOREIGN KEY ("jurisdiction_authorization_id")
        REFERENCES "profiles"."jurisdiction_authorizations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."jurisdiction_authorizations_history"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."jurisdiction_authorizations_history"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."jurisdiction_authorizations_history"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: consent.consents (requiere schema consent)
DO $$ BEGIN
    ALTER TABLE "audit"."consents_history"
        ADD CONSTRAINT "fk_consents_history_consent_id" FOREIGN KEY ("consent_id")
        REFERENCES "consent"."consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."consents_history"
        ADD CONSTRAINT "fk_consents_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."consents_history"
        ADD CONSTRAINT "fk_consents_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."consents_history"
        ADD CONSTRAINT "fk_consents_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_identity_links (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_identity_links_history"
        ADD CONSTRAINT "fk_patient_identity_links_history_patient_identity_link_id" FOREIGN KEY ("patient_identity_link_id")
        REFERENCES "profiles"."patient_identity_links" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_identity_links_history"
        ADD CONSTRAINT "fk_patient_identity_links_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_identity_links_history"
        ADD CONSTRAINT "fk_patient_identity_links_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_identity_links_history"
        ADD CONSTRAINT "fk_patient_identity_links_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practitioner_role_assignments (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."practitioner_role_assignments_history"
        ADD CONSTRAINT "fk_practitioner_role_assignments_history_practitioner__baff3e62" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."practitioner_role_assignments_history"
        ADD CONSTRAINT "fk_practitioner_role_assignments_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."practitioner_role_assignments_history"
        ADD CONSTRAINT "fk_practitioner_role_assignments_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."practitioner_role_assignments_history"
        ADD CONSTRAINT "fk_practitioner_role_assignments_history_change_reason_a26f251f" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."practice_sites_history"
        ADD CONSTRAINT "fk_practice_sites_history_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."practice_sites_history"
        ADD CONSTRAINT "fk_practice_sites_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."practice_sites_history"
        ADD CONSTRAINT "fk_practice_sites_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."practice_sites_history"
        ADD CONSTRAINT "fk_practice_sites_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_units_history"
        ADD CONSTRAINT "fk_clinical_units_history_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_units_history"
        ADD CONSTRAINT "fk_clinical_units_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_units_history"
        ADD CONSTRAINT "fk_clinical_units_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_units_history"
        ADD CONSTRAINT "fk_clinical_units_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."care_spaces_history"
        ADD CONSTRAINT "fk_care_spaces_history_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_spaces_history"
        ADD CONSTRAINT "fk_care_spaces_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."care_spaces_history"
        ADD CONSTRAINT "fk_care_spaces_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_spaces_history"
        ADD CONSTRAINT "fk_care_spaces_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.diagnostic_reports (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_reports_history"
        ADD CONSTRAINT "fk_diagnostic_reports_history_diagnostic_report_id" FOREIGN KEY ("diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_reports_history"
        ADD CONSTRAINT "fk_diagnostic_reports_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_reports_history"
        ADD CONSTRAINT "fk_diagnostic_reports_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_reports_history"
        ADD CONSTRAINT "fk_diagnostic_reports_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostics.imaging_studies (requiere schema diagnostics)
DO $$ BEGIN
    ALTER TABLE "audit"."imaging_studies_history"
        ADD CONSTRAINT "fk_imaging_studies_history_imaging_study_id" FOREIGN KEY ("imaging_study_id")
        REFERENCES "diagnostics"."imaging_studies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."imaging_studies_history"
        ADD CONSTRAINT "fk_imaging_studies_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."imaging_studies_history"
        ADD CONSTRAINT "fk_imaging_studies_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."imaging_studies_history"
        ADD CONSTRAINT "fk_imaging_studies_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.public_profiles (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."public_profiles_history"
        ADD CONSTRAINT "fk_public_profiles_history_public_profile_id" FOREIGN KEY ("public_profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."public_profiles_history"
        ADD CONSTRAINT "fk_public_profiles_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."public_profiles_history"
        ADD CONSTRAINT "fk_public_profiles_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."public_profiles_history"
        ADD CONSTRAINT "fk_public_profiles_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.social_posts (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."social_posts_history"
        ADD CONSTRAINT "fk_social_posts_history_social_post_id" FOREIGN KEY ("social_post_id")
        REFERENCES "community"."social_posts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."social_posts_history"
        ADD CONSTRAINT "fk_social_posts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."social_posts_history"
        ADD CONSTRAINT "fk_social_posts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."social_posts_history"
        ADD CONSTRAINT "fk_social_posts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.service_reviews (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."service_reviews_history"
        ADD CONSTRAINT "fk_service_reviews_history_service_review_id" FOREIGN KEY ("service_review_id")
        REFERENCES "community"."service_reviews" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."service_reviews_history"
        ADD CONSTRAINT "fk_service_reviews_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."service_reviews_history"
        ADD CONSTRAINT "fk_service_reviews_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."service_reviews_history"
        ADD CONSTRAINT "fk_service_reviews_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_events"
        ADD CONSTRAINT "fk_moderation_events_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_events"
        ADD CONSTRAINT "fk_moderation_events_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_events"
        ADD CONSTRAINT "fk_moderation_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_events"
        ADD CONSTRAINT "fk_moderation_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_content_access_log"
        ADD CONSTRAINT "fk_patient_content_access_log_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_content_access_log"
        ADD CONSTRAINT "fk_patient_content_access_log_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_content_access_log"
        ADD CONSTRAINT "fk_patient_content_access_log_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_content_access_log"
        ADD CONSTRAINT "fk_patient_content_access_log_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_content_access_log"
        ADD CONSTRAINT "fk_patient_content_access_log_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."patient_content_access_log"
        ADD CONSTRAINT "fk_patient_content_access_log_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: organization_extensions.organization_affiliations (requiere schema organization_extensions)
DO $$ BEGIN
    ALTER TABLE "audit"."organization_affiliations_history"
        ADD CONSTRAINT "fk_organization_affiliations_history_organization_affi_000fda2f" FOREIGN KEY ("organization_affiliation_id")
        REFERENCES "organization_extensions"."organization_affiliations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."organization_affiliations_history"
        ADD CONSTRAINT "fk_organization_affiliations_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."organization_affiliations_history"
        ADD CONSTRAINT "fk_organization_affiliations_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."organization_affiliations_history"
        ADD CONSTRAINT "fk_organization_affiliations_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_study_prices (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_study_prices_history"
        ADD CONSTRAINT "fk_diagnostic_study_prices_history_diagnostic_study_price_id" FOREIGN KEY ("diagnostic_study_price_id")
        REFERENCES "diagnostic_units"."diagnostic_study_prices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_study_prices_history"
        ADD CONSTRAINT "fk_diagnostic_study_prices_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_study_prices_history"
        ADD CONSTRAINT "fk_diagnostic_study_prices_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."diagnostic_study_prices_history"
        ADD CONSTRAINT "fk_diagnostic_study_prices_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_product_prices (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_product_prices_history"
        ADD CONSTRAINT "fk_pharmacy_product_prices_history_pharmacy_product_price_id" FOREIGN KEY ("pharmacy_product_price_id")
        REFERENCES "pharmacy"."pharmacy_product_prices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_product_prices_history"
        ADD CONSTRAINT "fk_pharmacy_product_prices_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_product_prices_history"
        ADD CONSTRAINT "fk_pharmacy_product_prices_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_product_prices_history"
        ADD CONSTRAINT "fk_pharmacy_product_prices_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_inventory_access_log"
        ADD CONSTRAINT "fk_pharmacy_inventory_access_log_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_inventory_access_log"
        ADD CONSTRAINT "fk_pharmacy_inventory_access_log_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_inventory_access_log"
        ADD CONSTRAINT "fk_pharmacy_inventory_access_log_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_inventory_access_log"
        ADD CONSTRAINT "fk_pharmacy_inventory_access_log_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_inventory_access_log"
        ADD CONSTRAINT "fk_pharmacy_inventory_access_log_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacy_inventory_access_log"
        ADD CONSTRAINT "fk_pharmacy_inventory_access_log_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.insurance_carriers (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.insurance_claims (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_claim_id" FOREIGN KEY ("claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.prior_authorization_requests (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_authorization_request_id" FOREIGN KEY ("authorization_request_id")
        REFERENCES "insurance"."prior_authorization_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_decision_access_log"
        ADD CONSTRAINT "fk_insurance_decision_access_log_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: identity_assurance.identity_verification_cases (requiere schema identity_assurance)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_verification_access_log"
        ADD CONSTRAINT "fk_identity_verification_access_log_verification_case_id" FOREIGN KEY ("verification_case_id")
        REFERENCES "identity_assurance"."identity_verification_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_verification_access_log"
        ADD CONSTRAINT "fk_identity_verification_access_log_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_verification_access_log"
        ADD CONSTRAINT "fk_identity_verification_access_log_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_verification_access_log"
        ADD CONSTRAINT "fk_identity_verification_access_log_evidence_type_concept_id" FOREIGN KEY ("evidence_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_verification_access_log"
        ADD CONSTRAINT "fk_identity_verification_access_log_data_disclosed_value_set_id" FOREIGN KEY ("data_disclosed_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_verification_access_log"
        ADD CONSTRAINT "fk_identity_verification_access_log_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_verification_access_log"
        ADD CONSTRAINT "fk_identity_verification_access_log_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."delegated_access_audit_log"
        ADD CONSTRAINT "fk_delegated_access_audit_log_delegate_user_id" FOREIGN KEY ("delegate_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."delegated_access_audit_log"
        ADD CONSTRAINT "fk_delegated_access_audit_log_delegating_practitioner__652b7b85" FOREIGN KEY ("delegating_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: delegated_access.practitioner_delegate_assignments (requiere schema delegated_access)
DO $$ BEGIN
    ALTER TABLE "audit"."delegated_access_audit_log"
        ADD CONSTRAINT "fk_delegated_access_audit_log_delegated_assignment_id" FOREIGN KEY ("delegated_assignment_id")
        REFERENCES "delegated_access"."practitioner_delegate_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "audit"."delegated_access_audit_log"
        ADD CONSTRAINT "fk_delegated_access_audit_log_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."delegated_access_audit_log"
        ADD CONSTRAINT "fk_delegated_access_audit_log_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."delegated_access_audit_log"
        ADD CONSTRAINT "fk_delegated_access_audit_log_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."delegated_access_audit_log"
        ADD CONSTRAINT "fk_delegated_access_audit_log_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."analytics_governance_log"
        ADD CONSTRAINT "fk_analytics_governance_log_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."analytics_governance_log"
        ADD CONSTRAINT "fk_analytics_governance_log_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: telemetry.tracking_purpose_definitions (requiere schema telemetry)
DO $$ BEGIN
    ALTER TABLE "audit"."analytics_governance_log"
        ADD CONSTRAINT "fk_analytics_governance_log_purpose_definition_id" FOREIGN KEY ("purpose_definition_id")
        REFERENCES "telemetry"."tracking_purpose_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."analytics_governance_log"
        ADD CONSTRAINT "fk_analytics_governance_log_approval_status_concept_id" FOREIGN KEY ("approval_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.conditions (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "audit"."conditions_history"
        ADD CONSTRAINT "fk_conditions_history_condition_id" FOREIGN KEY ("condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."conditions_history"
        ADD CONSTRAINT "fk_conditions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."conditions_history"
        ADD CONSTRAINT "fk_conditions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."conditions_history"
        ADD CONSTRAINT "fk_conditions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.allergy_intolerances (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "audit"."allergy_intolerances_history"
        ADD CONSTRAINT "fk_allergy_intolerances_history_allergy_intolerance_id" FOREIGN KEY ("allergy_intolerance_id")
        REFERENCES "clinical"."allergy_intolerances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."allergy_intolerances_history"
        ADD CONSTRAINT "fk_allergy_intolerances_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."allergy_intolerances_history"
        ADD CONSTRAINT "fk_allergy_intolerances_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."allergy_intolerances_history"
        ADD CONSTRAINT "fk_allergy_intolerances_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.medication_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "audit"."medication_requests_history"
        ADD CONSTRAINT "fk_medication_requests_history_medication_request_id" FOREIGN KEY ("medication_request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."medication_requests_history"
        ADD CONSTRAINT "fk_medication_requests_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."medication_requests_history"
        ADD CONSTRAINT "fk_medication_requests_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."medication_requests_history"
        ADD CONSTRAINT "fk_medication_requests_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."practices_history"
        ADD CONSTRAINT "fk_practices_history_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."practices_history"
        ADD CONSTRAINT "fk_practices_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."practices_history"
        ADD CONSTRAINT "fk_practices_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."practices_history"
        ADD CONSTRAINT "fk_practices_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: chart.clinical_note_headers (requiere schema chart)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_note_headers_history"
        ADD CONSTRAINT "fk_clinical_note_headers_history_clinical_note_header_id" FOREIGN KEY ("clinical_note_header_id")
        REFERENCES "chart"."clinical_note_headers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_note_headers_history"
        ADD CONSTRAINT "fk_clinical_note_headers_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_note_headers_history"
        ADD CONSTRAINT "fk_clinical_note_headers_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_note_headers_history"
        ADD CONSTRAINT "fk_clinical_note_headers_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: chart.care_plans (requiere schema chart)
DO $$ BEGIN
    ALTER TABLE "audit"."care_plans_history"
        ADD CONSTRAINT "fk_care_plans_history_care_plan_id" FOREIGN KEY ("care_plan_id")
        REFERENCES "chart"."care_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_plans_history"
        ADD CONSTRAINT "fk_care_plans_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."care_plans_history"
        ADD CONSTRAINT "fk_care_plans_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_plans_history"
        ADD CONSTRAINT "fk_care_plans_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: chart.document_records (requiere schema chart)
DO $$ BEGIN
    ALTER TABLE "audit"."document_records_history"
        ADD CONSTRAINT "fk_document_records_history_document_record_id" FOREIGN KEY ("document_record_id")
        REFERENCES "chart"."document_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."document_records_history"
        ADD CONSTRAINT "fk_document_records_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."document_records_history"
        ADD CONSTRAINT "fk_document_records_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."document_records_history"
        ADD CONSTRAINT "fk_document_records_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical_ext.care_teams (requiere schema clinical_ext)
DO $$ BEGIN
    ALTER TABLE "audit"."care_teams_history"
        ADD CONSTRAINT "fk_care_teams_history_care_team_id" FOREIGN KEY ("care_team_id")
        REFERENCES "clinical_ext"."care_teams" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_teams_history"
        ADD CONSTRAINT "fk_care_teams_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."care_teams_history"
        ADD CONSTRAINT "fk_care_teams_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_teams_history"
        ADD CONSTRAINT "fk_care_teams_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical_ext.referrals (requiere schema clinical_ext)
DO $$ BEGIN
    ALTER TABLE "audit"."referrals_history"
        ADD CONSTRAINT "fk_referrals_history_referral_id" FOREIGN KEY ("referral_id")
        REFERENCES "clinical_ext"."referrals" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."referrals_history"
        ADD CONSTRAINT "fk_referrals_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."referrals_history"
        ADD CONSTRAINT "fk_referrals_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."referrals_history"
        ADD CONSTRAINT "fk_referrals_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical_ext.clinical_alerts (requiere schema clinical_ext)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_alerts_history"
        ADD CONSTRAINT "fk_clinical_alerts_history_clinical_alert_id" FOREIGN KEY ("clinical_alert_id")
        REFERENCES "clinical_ext"."clinical_alerts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_alerts_history"
        ADD CONSTRAINT "fk_clinical_alerts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_alerts_history"
        ADD CONSTRAINT "fk_clinical_alerts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_alerts_history"
        ADD CONSTRAINT "fk_clinical_alerts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical_ext.cds_rules (requiere schema clinical_ext)
DO $$ BEGIN
    ALTER TABLE "audit"."cds_rules_history"
        ADD CONSTRAINT "fk_cds_rules_history_cds_rule_id" FOREIGN KEY ("cds_rule_id")
        REFERENCES "clinical_ext"."cds_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."cds_rules_history"
        ADD CONSTRAINT "fk_cds_rules_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."cds_rules_history"
        ADD CONSTRAINT "fk_cds_rules_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."cds_rules_history"
        ADD CONSTRAINT "fk_cds_rules_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical_ext.order_sets (requiere schema clinical_ext)
DO $$ BEGIN
    ALTER TABLE "audit"."order_sets_history"
        ADD CONSTRAINT "fk_order_sets_history_order_set_id" FOREIGN KEY ("order_set_id")
        REFERENCES "clinical_ext"."order_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."order_sets_history"
        ADD CONSTRAINT "fk_order_sets_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."order_sets_history"
        ADD CONSTRAINT "fk_order_sets_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."order_sets_history"
        ADD CONSTRAINT "fk_order_sets_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.provider_connections (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_connections_history"
        ADD CONSTRAINT "fk_provider_connections_history_provider_connection_id" FOREIGN KEY ("provider_connection_id")
        REFERENCES "integrations"."provider_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_connections_history"
        ADD CONSTRAINT "fk_provider_connections_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_connections_history"
        ADD CONSTRAINT "fk_provider_connections_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_connections_history"
        ADD CONSTRAINT "fk_provider_connections_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.integration_endpoints (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "audit"."integration_endpoints_history"
        ADD CONSTRAINT "fk_integration_endpoints_history_integration_endpoint_id" FOREIGN KEY ("integration_endpoint_id")
        REFERENCES "integrations"."integration_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."integration_endpoints_history"
        ADD CONSTRAINT "fk_integration_endpoints_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."integration_endpoints_history"
        ADD CONSTRAINT "fk_integration_endpoints_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."integration_endpoints_history"
        ADD CONSTRAINT "fk_integration_endpoints_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.outbound_messages (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "audit"."outbound_messages_history"
        ADD CONSTRAINT "fk_outbound_messages_history_outbound_message_id" FOREIGN KEY ("outbound_message_id")
        REFERENCES "integrations"."outbound_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."outbound_messages_history"
        ADD CONSTRAINT "fk_outbound_messages_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."outbound_messages_history"
        ADD CONSTRAINT "fk_outbound_messages_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."outbound_messages_history"
        ADD CONSTRAINT "fk_outbound_messages_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.inbound_messages (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "audit"."inbound_messages_history"
        ADD CONSTRAINT "fk_inbound_messages_history_inbound_message_id" FOREIGN KEY ("inbound_message_id")
        REFERENCES "integrations"."inbound_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."inbound_messages_history"
        ADD CONSTRAINT "fk_inbound_messages_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."inbound_messages_history"
        ADD CONSTRAINT "fk_inbound_messages_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."inbound_messages_history"
        ADD CONSTRAINT "fk_inbound_messages_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.message_retries (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "audit"."message_retries_history"
        ADD CONSTRAINT "fk_message_retries_history_message_retry_id" FOREIGN KEY ("message_retry_id")
        REFERENCES "integrations"."message_retries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."message_retries_history"
        ADD CONSTRAINT "fk_message_retries_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."message_retries_history"
        ADD CONSTRAINT "fk_message_retries_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."message_retries_history"
        ADD CONSTRAINT "fk_message_retries_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "audit"."accounts_history"
        ADD CONSTRAINT "fk_accounts_history_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."accounts_history"
        ADD CONSTRAINT "fk_accounts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."accounts_history"
        ADD CONSTRAINT "fk_accounts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."accounts_history"
        ADD CONSTRAINT "fk_accounts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "audit"."journal_transactions_history"
        ADD CONSTRAINT "fk_journal_transactions_history_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."journal_transactions_history"
        ADD CONSTRAINT "fk_journal_transactions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."journal_transactions_history"
        ADD CONSTRAINT "fk_journal_transactions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."journal_transactions_history"
        ADD CONSTRAINT "fk_journal_transactions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.assets (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "audit"."assets_history"
        ADD CONSTRAINT "fk_assets_history_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."assets_history"
        ADD CONSTRAINT "fk_assets_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."assets_history"
        ADD CONSTRAINT "fk_assets_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."assets_history"
        ADD CONSTRAINT "fk_assets_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.liabilities (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "audit"."liabilities_history"
        ADD CONSTRAINT "fk_liabilities_history_liability_id" FOREIGN KEY ("liability_id")
        REFERENCES "accounting"."liabilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."liabilities_history"
        ADD CONSTRAINT "fk_liabilities_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."liabilities_history"
        ADD CONSTRAINT "fk_liabilities_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."liabilities_history"
        ADD CONSTRAINT "fk_liabilities_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "audit"."invoices_history"
        ADD CONSTRAINT "fk_invoices_history_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."invoices_history"
        ADD CONSTRAINT "fk_invoices_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."invoices_history"
        ADD CONSTRAINT "fk_invoices_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."invoices_history"
        ADD CONSTRAINT "fk_invoices_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.bills (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "audit"."bills_history"
        ADD CONSTRAINT "fk_bills_history_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."bills_history"
        ADD CONSTRAINT "fk_bills_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."bills_history"
        ADD CONSTRAINT "fk_bills_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."bills_history"
        ADD CONSTRAINT "fk_bills_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.insurance_claims (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_claims_history"
        ADD CONSTRAINT "fk_insurance_claims_history_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_claims_history"
        ADD CONSTRAINT "fk_insurance_claims_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_claims_history"
        ADD CONSTRAINT "fk_insurance_claims_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_claims_history"
        ADD CONSTRAINT "fk_insurance_claims_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.message_templates (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "audit"."message_templates_history"
        ADD CONSTRAINT "fk_message_templates_history_message_template_id" FOREIGN KEY ("message_template_id")
        REFERENCES "messaging"."message_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."message_templates_history"
        ADD CONSTRAINT "fk_message_templates_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."message_templates_history"
        ADD CONSTRAINT "fk_message_templates_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."message_templates_history"
        ADD CONSTRAINT "fk_message_templates_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.provider_channel_configs (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_channel_configs_history"
        ADD CONSTRAINT "fk_provider_channel_configs_history_provider_channel_config_id" FOREIGN KEY ("provider_channel_config_id")
        REFERENCES "messaging"."provider_channel_configs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_channel_configs_history"
        ADD CONSTRAINT "fk_provider_channel_configs_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_channel_configs_history"
        ADD CONSTRAINT "fk_provider_channel_configs_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_channel_configs_history"
        ADD CONSTRAINT "fk_provider_channel_configs_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.event_subscriptions (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "audit"."event_subscriptions_history"
        ADD CONSTRAINT "fk_event_subscriptions_history_event_subscription_id" FOREIGN KEY ("event_subscription_id")
        REFERENCES "messaging"."event_subscriptions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."event_subscriptions_history"
        ADD CONSTRAINT "fk_event_subscriptions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."event_subscriptions_history"
        ADD CONSTRAINT "fk_event_subscriptions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."event_subscriptions_history"
        ADD CONSTRAINT "fk_event_subscriptions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: qa_lab.test_suites (requiere schema qa_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."test_suites_history"
        ADD CONSTRAINT "fk_test_suites_history_test_suite_id" FOREIGN KEY ("test_suite_id")
        REFERENCES "qa_lab"."test_suites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."test_suites_history"
        ADD CONSTRAINT "fk_test_suites_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."test_suites_history"
        ADD CONSTRAINT "fk_test_suites_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."test_suites_history"
        ADD CONSTRAINT "fk_test_suites_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: qa_lab.test_cases (requiere schema qa_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."test_cases_history"
        ADD CONSTRAINT "fk_test_cases_history_test_case_id" FOREIGN KEY ("test_case_id")
        REFERENCES "qa_lab"."test_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."test_cases_history"
        ADD CONSTRAINT "fk_test_cases_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."test_cases_history"
        ADD CONSTRAINT "fk_test_cases_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."test_cases_history"
        ADD CONSTRAINT "fk_test_cases_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: tracking.trackable_subjects (requiere schema tracking)
DO $$ BEGIN
    ALTER TABLE "audit"."trackable_subjects_history"
        ADD CONSTRAINT "fk_trackable_subjects_history_trackable_subject_id" FOREIGN KEY ("trackable_subject_id")
        REFERENCES "tracking"."trackable_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."trackable_subjects_history"
        ADD CONSTRAINT "fk_trackable_subjects_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."trackable_subjects_history"
        ADD CONSTRAINT "fk_trackable_subjects_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."trackable_subjects_history"
        ADD CONSTRAINT "fk_trackable_subjects_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: tracking.shipments (requiere schema tracking)
DO $$ BEGIN
    ALTER TABLE "audit"."shipments_history"
        ADD CONSTRAINT "fk_shipments_history_shipment_id" FOREIGN KEY ("shipment_id")
        REFERENCES "tracking"."shipments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."shipments_history"
        ADD CONSTRAINT "fk_shipments_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."shipments_history"
        ADD CONSTRAINT "fk_shipments_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."shipments_history"
        ADD CONSTRAINT "fk_shipments_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "audit"."contracts_history"
        ADD CONSTRAINT "fk_contracts_history_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."contracts_history"
        ADD CONSTRAINT "fk_contracts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."contracts_history"
        ADD CONSTRAINT "fk_contracts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."contracts_history"
        ADD CONSTRAINT "fk_contracts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.employment_records (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "audit"."employment_records_history"
        ADD CONSTRAINT "fk_employment_records_history_employment_record_id" FOREIGN KEY ("employment_record_id")
        REFERENCES "erp"."employment_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."employment_records_history"
        ADD CONSTRAINT "fk_employment_records_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."employment_records_history"
        ADD CONSTRAINT "fk_employment_records_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."employment_records_history"
        ADD CONSTRAINT "fk_employment_records_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.departments (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "audit"."departments_history"
        ADD CONSTRAINT "fk_departments_history_department_id" FOREIGN KEY ("department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."departments_history"
        ADD CONSTRAINT "fk_departments_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."departments_history"
        ADD CONSTRAINT "fk_departments_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."departments_history"
        ADD CONSTRAINT "fk_departments_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.positions (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "audit"."positions_history"
        ADD CONSTRAINT "fk_positions_history_position_id" FOREIGN KEY ("position_id")
        REFERENCES "erp"."positions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."positions_history"
        ADD CONSTRAINT "fk_positions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."positions_history"
        ADD CONSTRAINT "fk_positions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."positions_history"
        ADD CONSTRAINT "fk_positions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: reporting.report_definitions (requiere schema reporting)
DO $$ BEGIN
    ALTER TABLE "audit"."report_definitions_history"
        ADD CONSTRAINT "fk_report_definitions_history_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."report_definitions_history"
        ADD CONSTRAINT "fk_report_definitions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."report_definitions_history"
        ADD CONSTRAINT "fk_report_definitions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."report_definitions_history"
        ADD CONSTRAINT "fk_report_definitions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: reporting.report_schedules (requiere schema reporting)
DO $$ BEGIN
    ALTER TABLE "audit"."report_schedules_history"
        ADD CONSTRAINT "fk_report_schedules_history_report_schedule_id" FOREIGN KEY ("report_schedule_id")
        REFERENCES "reporting"."report_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."report_schedules_history"
        ADD CONSTRAINT "fk_report_schedules_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."report_schedules_history"
        ADD CONSTRAINT "fk_report_schedules_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."report_schedules_history"
        ADD CONSTRAINT "fk_report_schedules_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: auth_providers.identity_providers (requiere schema auth_providers)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_providers_history"
        ADD CONSTRAINT "fk_identity_providers_history_identity_provider_id" FOREIGN KEY ("identity_provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_providers_history"
        ADD CONSTRAINT "fk_identity_providers_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_providers_history"
        ADD CONSTRAINT "fk_identity_providers_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."identity_providers_history"
        ADD CONSTRAINT "fk_identity_providers_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: auth_providers.provider_protocol_configs (requiere schema auth_providers)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_protocol_configs_history"
        ADD CONSTRAINT "fk_provider_protocol_configs_history_provider_protocol_e11b566a" FOREIGN KEY ("provider_protocol_config_id")
        REFERENCES "auth_providers"."provider_protocol_configs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_protocol_configs_history"
        ADD CONSTRAINT "fk_provider_protocol_configs_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_protocol_configs_history"
        ADD CONSTRAINT "fk_provider_protocol_configs_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_protocol_configs_history"
        ADD CONSTRAINT "fk_provider_protocol_configs_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: auth_providers.provider_tenant_bindings (requiere schema auth_providers)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_tenant_bindings_history"
        ADD CONSTRAINT "fk_provider_tenant_bindings_history_provider_tenant_binding_id" FOREIGN KEY ("provider_tenant_binding_id")
        REFERENCES "auth_providers"."provider_tenant_bindings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_tenant_bindings_history"
        ADD CONSTRAINT "fk_provider_tenant_bindings_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_tenant_bindings_history"
        ADD CONSTRAINT "fk_provider_tenant_bindings_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."provider_tenant_bindings_history"
        ADD CONSTRAINT "fk_provider_tenant_bindings_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: auth_providers.federated_identities (requiere schema auth_providers)
DO $$ BEGIN
    ALTER TABLE "audit"."federated_identities_history"
        ADD CONSTRAINT "fk_federated_identities_history_federated_identity_id" FOREIGN KEY ("federated_identity_id")
        REFERENCES "auth_providers"."federated_identities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."federated_identities_history"
        ADD CONSTRAINT "fk_federated_identities_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."federated_identities_history"
        ADD CONSTRAINT "fk_federated_identities_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."federated_identities_history"
        ADD CONSTRAINT "fk_federated_identities_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: scheduling.schedule_templates (requiere schema scheduling)
DO $$ BEGIN
    ALTER TABLE "audit"."schedule_templates_history"
        ADD CONSTRAINT "fk_schedule_templates_history_schedule_template_id" FOREIGN KEY ("schedule_template_id")
        REFERENCES "scheduling"."schedule_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."schedule_templates_history"
        ADD CONSTRAINT "fk_schedule_templates_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."schedule_templates_history"
        ADD CONSTRAINT "fk_schedule_templates_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."schedule_templates_history"
        ADD CONSTRAINT "fk_schedule_templates_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: scheduling.booking_policies (requiere schema scheduling)
DO $$ BEGIN
    ALTER TABLE "audit"."booking_policies_history"
        ADD CONSTRAINT "fk_booking_policies_history_booking_policy_id" FOREIGN KEY ("booking_policy_id")
        REFERENCES "scheduling"."booking_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."booking_policies_history"
        ADD CONSTRAINT "fk_booking_policies_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."booking_policies_history"
        ADD CONSTRAINT "fk_booking_policies_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."booking_policies_history"
        ADD CONSTRAINT "fk_booking_policies_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: scheduling.appointment_bookings (requiere schema scheduling)
DO $$ BEGIN
    ALTER TABLE "audit"."appointment_bookings_history"
        ADD CONSTRAINT "fk_appointment_bookings_history_appointment_booking_id" FOREIGN KEY ("appointment_booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."appointment_bookings_history"
        ADD CONSTRAINT "fk_appointment_bookings_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."appointment_bookings_history"
        ADD CONSTRAINT "fk_appointment_bookings_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."appointment_bookings_history"
        ADD CONSTRAINT "fk_appointment_bookings_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_methods (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_methods_history"
        ADD CONSTRAINT "fk_payment_methods_history_payment_method_id" FOREIGN KEY ("payment_method_id")
        REFERENCES "payments"."payment_methods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_methods_history"
        ADD CONSTRAINT "fk_payment_methods_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_methods_history"
        ADD CONSTRAINT "fk_payment_methods_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_methods_history"
        ADD CONSTRAINT "fk_payment_methods_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_intents (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_intents_history"
        ADD CONSTRAINT "fk_payment_intents_history_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_intents_history"
        ADD CONSTRAINT "fk_payment_intents_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_intents_history"
        ADD CONSTRAINT "fk_payment_intents_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_intents_history"
        ADD CONSTRAINT "fk_payment_intents_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_transactions_history"
        ADD CONSTRAINT "fk_payment_transactions_history_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_transactions_history"
        ADD CONSTRAINT "fk_payment_transactions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_transactions_history"
        ADD CONSTRAINT "fk_payment_transactions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_transactions_history"
        ADD CONSTRAINT "fk_payment_transactions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payouts (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."payouts_history"
        ADD CONSTRAINT "fk_payouts_history_payout_id" FOREIGN KEY ("payout_id")
        REFERENCES "payments"."payouts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payouts_history"
        ADD CONSTRAINT "fk_payouts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."payouts_history"
        ADD CONSTRAINT "fk_payouts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payouts_history"
        ADD CONSTRAINT "fk_payouts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.ad_accounts (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_accounts_history"
        ADD CONSTRAINT "fk_ad_accounts_history_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_accounts_history"
        ADD CONSTRAINT "fk_ad_accounts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_accounts_history"
        ADD CONSTRAINT "fk_ad_accounts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_accounts_history"
        ADD CONSTRAINT "fk_ad_accounts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.campaigns (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."campaigns_history"
        ADD CONSTRAINT "fk_campaigns_history_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."campaigns_history"
        ADD CONSTRAINT "fk_campaigns_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."campaigns_history"
        ADD CONSTRAINT "fk_campaigns_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."campaigns_history"
        ADD CONSTRAINT "fk_campaigns_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.ad_sets (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_sets_history"
        ADD CONSTRAINT "fk_ad_sets_history_ad_set_id" FOREIGN KEY ("ad_set_id")
        REFERENCES "ads"."ad_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_sets_history"
        ADD CONSTRAINT "fk_ad_sets_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_sets_history"
        ADD CONSTRAINT "fk_ad_sets_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_sets_history"
        ADD CONSTRAINT "fk_ad_sets_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.ads (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."ads_history"
        ADD CONSTRAINT "fk_ads_history_ad_id" FOREIGN KEY ("ad_id")
        REFERENCES "ads"."ads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ads_history"
        ADD CONSTRAINT "fk_ads_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."ads_history"
        ADD CONSTRAINT "fk_ads_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ads_history"
        ADD CONSTRAINT "fk_ads_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.ad_creatives (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_creatives_history"
        ADD CONSTRAINT "fk_ad_creatives_history_ad_creative_id" FOREIGN KEY ("ad_creative_id")
        REFERENCES "ads"."ad_creatives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_creatives_history"
        ADD CONSTRAINT "fk_ad_creatives_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_creatives_history"
        ADD CONSTRAINT "fk_ad_creatives_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_creatives_history"
        ADD CONSTRAINT "fk_ad_creatives_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.custom_audiences (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_audiences_history"
        ADD CONSTRAINT "fk_custom_audiences_history_custom_audience_id" FOREIGN KEY ("custom_audience_id")
        REFERENCES "ads"."custom_audiences" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_audiences_history"
        ADD CONSTRAINT "fk_custom_audiences_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_audiences_history"
        ADD CONSTRAINT "fk_custom_audiences_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_audiences_history"
        ADD CONSTRAINT "fk_custom_audiences_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.wallets (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."wallets_history"
        ADD CONSTRAINT "fk_wallets_history_wallets_id" FOREIGN KEY ("wallets_id")
        REFERENCES "payments"."wallets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."wallets_history"
        ADD CONSTRAINT "fk_wallets_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."wallets_history"
        ADD CONSTRAINT "fk_wallets_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."wallets_history"
        ADD CONSTRAINT "fk_wallets_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.subscription_plans (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."subscription_plans_history"
        ADD CONSTRAINT "fk_subscription_plans_history_subscription_plans_id" FOREIGN KEY ("subscription_plans_id")
        REFERENCES "payments"."subscription_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."subscription_plans_history"
        ADD CONSTRAINT "fk_subscription_plans_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."subscription_plans_history"
        ADD CONSTRAINT "fk_subscription_plans_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."subscription_plans_history"
        ADD CONSTRAINT "fk_subscription_plans_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.subscriptions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."subscriptions_history"
        ADD CONSTRAINT "fk_subscriptions_history_subscriptions_id" FOREIGN KEY ("subscriptions_id")
        REFERENCES "payments"."subscriptions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."subscriptions_history"
        ADD CONSTRAINT "fk_subscriptions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."subscriptions_history"
        ADD CONSTRAINT "fk_subscriptions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."subscriptions_history"
        ADD CONSTRAINT "fk_subscriptions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.connected_accounts (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."connected_accounts_history"
        ADD CONSTRAINT "fk_connected_accounts_history_connected_accounts_id" FOREIGN KEY ("connected_accounts_id")
        REFERENCES "payments"."connected_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."connected_accounts_history"
        ADD CONSTRAINT "fk_connected_accounts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."connected_accounts_history"
        ADD CONSTRAINT "fk_connected_accounts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."connected_accounts_history"
        ADD CONSTRAINT "fk_connected_accounts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_mandates (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_mandates_history"
        ADD CONSTRAINT "fk_payment_mandates_history_payment_mandates_id" FOREIGN KEY ("payment_mandates_id")
        REFERENCES "payments"."payment_mandates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_mandates_history"
        ADD CONSTRAINT "fk_payment_mandates_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_mandates_history"
        ADD CONSTRAINT "fk_payment_mandates_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."payment_mandates_history"
        ADD CONSTRAINT "fk_payment_mandates_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.product_catalogs (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."product_catalogs_history"
        ADD CONSTRAINT "fk_product_catalogs_history_product_catalogs_id" FOREIGN KEY ("product_catalogs_id")
        REFERENCES "ads"."product_catalogs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."product_catalogs_history"
        ADD CONSTRAINT "fk_product_catalogs_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."product_catalogs_history"
        ADD CONSTRAINT "fk_product_catalogs_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."product_catalogs_history"
        ADD CONSTRAINT "fk_product_catalogs_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.catalog_products (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."catalog_products_history"
        ADD CONSTRAINT "fk_catalog_products_history_catalog_products_id" FOREIGN KEY ("catalog_products_id")
        REFERENCES "ads"."catalog_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."catalog_products_history"
        ADD CONSTRAINT "fk_catalog_products_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."catalog_products_history"
        ADD CONSTRAINT "fk_catalog_products_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."catalog_products_history"
        ADD CONSTRAINT "fk_catalog_products_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.product_sets (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."product_sets_history"
        ADD CONSTRAINT "fk_product_sets_history_product_sets_id" FOREIGN KEY ("product_sets_id")
        REFERENCES "ads"."product_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."product_sets_history"
        ADD CONSTRAINT "fk_product_sets_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."product_sets_history"
        ADD CONSTRAINT "fk_product_sets_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."product_sets_history"
        ADD CONSTRAINT "fk_product_sets_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.automated_rules (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."automated_rules_history"
        ADD CONSTRAINT "fk_automated_rules_history_automated_rules_id" FOREIGN KEY ("automated_rules_id")
        REFERENCES "ads"."automated_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."automated_rules_history"
        ADD CONSTRAINT "fk_automated_rules_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."automated_rules_history"
        ADD CONSTRAINT "fk_automated_rules_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."automated_rules_history"
        ADD CONSTRAINT "fk_automated_rules_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.custom_conversions (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_conversions_history"
        ADD CONSTRAINT "fk_custom_conversions_history_custom_conversions_id" FOREIGN KEY ("custom_conversions_id")
        REFERENCES "ads"."custom_conversions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_conversions_history"
        ADD CONSTRAINT "fk_custom_conversions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_conversions_history"
        ADD CONSTRAINT "fk_custom_conversions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."custom_conversions_history"
        ADD CONSTRAINT "fk_custom_conversions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.ad_experiments (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_experiments_history"
        ADD CONSTRAINT "fk_ad_experiments_history_ad_experiments_id" FOREIGN KEY ("ad_experiments_id")
        REFERENCES "ads"."ad_experiments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_experiments_history"
        ADD CONSTRAINT "fk_ad_experiments_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_experiments_history"
        ADD CONSTRAINT "fk_ad_experiments_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."ad_experiments_history"
        ADD CONSTRAINT "fk_ad_experiments_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.comments (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."comments_history"
        ADD CONSTRAINT "fk_comments_history_comments_id" FOREIGN KEY ("comments_id")
        REFERENCES "community"."comments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."comments_history"
        ADD CONSTRAINT "fk_comments_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."comments_history"
        ADD CONSTRAINT "fk_comments_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."comments_history"
        ADD CONSTRAINT "fk_comments_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.groups (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."groups_history"
        ADD CONSTRAINT "fk_groups_history_groups_id" FOREIGN KEY ("groups_id")
        REFERENCES "community"."groups" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."groups_history"
        ADD CONSTRAINT "fk_groups_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."groups_history"
        ADD CONSTRAINT "fk_groups_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."groups_history"
        ADD CONSTRAINT "fk_groups_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.topics (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."topics_history"
        ADD CONSTRAINT "fk_topics_history_topics_id" FOREIGN KEY ("topics_id")
        REFERENCES "community"."topics" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."topics_history"
        ADD CONSTRAINT "fk_topics_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."topics_history"
        ADD CONSTRAINT "fk_topics_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."topics_history"
        ADD CONSTRAINT "fk_topics_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.conversations (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."conversations_history"
        ADD CONSTRAINT "fk_conversations_history_conversations_id" FOREIGN KEY ("conversations_id")
        REFERENCES "community"."conversations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."conversations_history"
        ADD CONSTRAINT "fk_conversations_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."conversations_history"
        ADD CONSTRAINT "fk_conversations_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."conversations_history"
        ADD CONSTRAINT "fk_conversations_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.verified_badges (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."verified_badges_history"
        ADD CONSTRAINT "fk_verified_badges_history_verified_badges_id" FOREIGN KEY ("verified_badges_id")
        REFERENCES "community"."verified_badges" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."verified_badges_history"
        ADD CONSTRAINT "fk_verified_badges_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."verified_badges_history"
        ADD CONSTRAINT "fk_verified_badges_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."verified_badges_history"
        ADD CONSTRAINT "fk_verified_badges_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.moderation_decisions (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_decisions_history"
        ADD CONSTRAINT "fk_moderation_decisions_history_moderation_decisions_id" FOREIGN KEY ("moderation_decisions_id")
        REFERENCES "community"."moderation_decisions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_decisions_history"
        ADD CONSTRAINT "fk_moderation_decisions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_decisions_history"
        ADD CONSTRAINT "fk_moderation_decisions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."moderation_decisions_history"
        ADD CONSTRAINT "fk_moderation_decisions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: education.courses (requiere schema education)
DO $$ BEGIN
    ALTER TABLE "audit"."courses_history"
        ADD CONSTRAINT "fk_courses_history_courses_id" FOREIGN KEY ("courses_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."courses_history"
        ADD CONSTRAINT "fk_courses_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."courses_history"
        ADD CONSTRAINT "fk_courses_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."courses_history"
        ADD CONSTRAINT "fk_courses_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: education.course_versions (requiere schema education)
DO $$ BEGIN
    ALTER TABLE "audit"."course_versions_history"
        ADD CONSTRAINT "fk_course_versions_history_course_versions_id" FOREIGN KEY ("course_versions_id")
        REFERENCES "education"."course_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."course_versions_history"
        ADD CONSTRAINT "fk_course_versions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."course_versions_history"
        ADD CONSTRAINT "fk_course_versions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."course_versions_history"
        ADD CONSTRAINT "fk_course_versions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: education.enrollments (requiere schema education)
DO $$ BEGIN
    ALTER TABLE "audit"."enrollments_history"
        ADD CONSTRAINT "fk_enrollments_history_enrollments_id" FOREIGN KEY ("enrollments_id")
        REFERENCES "education"."enrollments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."enrollments_history"
        ADD CONSTRAINT "fk_enrollments_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."enrollments_history"
        ADD CONSTRAINT "fk_enrollments_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."enrollments_history"
        ADD CONSTRAINT "fk_enrollments_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: education.certificates (requiere schema education)
DO $$ BEGIN
    ALTER TABLE "audit"."certificates_history"
        ADD CONSTRAINT "fk_certificates_history_certificates_id" FOREIGN KEY ("certificates_id")
        REFERENCES "education"."certificates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."certificates_history"
        ADD CONSTRAINT "fk_certificates_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."certificates_history"
        ADD CONSTRAINT "fk_certificates_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."certificates_history"
        ADD CONSTRAINT "fk_certificates_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.agents (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "audit"."agents_history"
        ADD CONSTRAINT "fk_agents_history_agents_id" FOREIGN KEY ("agents_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."agents_history"
        ADD CONSTRAINT "fk_agents_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."agents_history"
        ADD CONSTRAINT "fk_agents_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."agents_history"
        ADD CONSTRAINT "fk_agents_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.agent_versions (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "audit"."agent_versions_history"
        ADD CONSTRAINT "fk_agent_versions_history_agent_versions_id" FOREIGN KEY ("agent_versions_id")
        REFERENCES "automation"."agent_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."agent_versions_history"
        ADD CONSTRAINT "fk_agent_versions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."agent_versions_history"
        ADD CONSTRAINT "fk_agent_versions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."agent_versions_history"
        ADD CONSTRAINT "fk_agent_versions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.workflows (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "audit"."workflows_history"
        ADD CONSTRAINT "fk_workflows_history_workflows_id" FOREIGN KEY ("workflows_id")
        REFERENCES "automation"."workflows" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."workflows_history"
        ADD CONSTRAINT "fk_workflows_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."workflows_history"
        ADD CONSTRAINT "fk_workflows_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."workflows_history"
        ADD CONSTRAINT "fk_workflows_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.guardrail_policies (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "audit"."guardrail_policies_history"
        ADD CONSTRAINT "fk_guardrail_policies_history_guardrail_policies_id" FOREIGN KEY ("guardrail_policies_id")
        REFERENCES "automation"."guardrail_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."guardrail_policies_history"
        ADD CONSTRAINT "fk_guardrail_policies_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."guardrail_policies_history"
        ADD CONSTRAINT "fk_guardrail_policies_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."guardrail_policies_history"
        ADD CONSTRAINT "fk_guardrail_policies_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.record_automations (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "audit"."record_automations_history"
        ADD CONSTRAINT "fk_record_automations_history_record_automations_id" FOREIGN KEY ("record_automations_id")
        REFERENCES "automation"."record_automations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."record_automations_history"
        ADD CONSTRAINT "fk_record_automations_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."record_automations_history"
        ADD CONSTRAINT "fk_record_automations_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."record_automations_history"
        ADD CONSTRAINT "fk_record_automations_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.crm_accounts (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "audit"."crm_accounts_history"
        ADD CONSTRAINT "fk_crm_accounts_history_crm_accounts_id" FOREIGN KEY ("crm_accounts_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."crm_accounts_history"
        ADD CONSTRAINT "fk_crm_accounts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."crm_accounts_history"
        ADD CONSTRAINT "fk_crm_accounts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."crm_accounts_history"
        ADD CONSTRAINT "fk_crm_accounts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.contacts (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "audit"."contacts_history"
        ADD CONSTRAINT "fk_contacts_history_contacts_id" FOREIGN KEY ("contacts_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."contacts_history"
        ADD CONSTRAINT "fk_contacts_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."contacts_history"
        ADD CONSTRAINT "fk_contacts_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."contacts_history"
        ADD CONSTRAINT "fk_contacts_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.opportunities (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "audit"."opportunities_history"
        ADD CONSTRAINT "fk_opportunities_history_opportunities_id" FOREIGN KEY ("opportunities_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."opportunities_history"
        ADD CONSTRAINT "fk_opportunities_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."opportunities_history"
        ADD CONSTRAINT "fk_opportunities_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."opportunities_history"
        ADD CONSTRAINT "fk_opportunities_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.partnerships (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "audit"."partnerships_history"
        ADD CONSTRAINT "fk_partnerships_history_partnerships_id" FOREIGN KEY ("partnerships_id")
        REFERENCES "crm"."partnerships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."partnerships_history"
        ADD CONSTRAINT "fk_partnerships_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."partnerships_history"
        ADD CONSTRAINT "fk_partnerships_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."partnerships_history"
        ADD CONSTRAINT "fk_partnerships_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.partnership_agreements (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "audit"."partnership_agreements_history"
        ADD CONSTRAINT "fk_partnership_agreements_history_partnership_agreements_id" FOREIGN KEY ("partnership_agreements_id")
        REFERENCES "crm"."partnership_agreements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."partnership_agreements_history"
        ADD CONSTRAINT "fk_partnership_agreements_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."partnership_agreements_history"
        ADD CONSTRAINT "fk_partnership_agreements_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."partnership_agreements_history"
        ADD CONSTRAINT "fk_partnership_agreements_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.segments (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "audit"."segments_history"
        ADD CONSTRAINT "fk_segments_history_segments_id" FOREIGN KEY ("segments_id")
        REFERENCES "accounting"."segments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."segments_history"
        ADD CONSTRAINT "fk_segments_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."segments_history"
        ADD CONSTRAINT "fk_segments_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."segments_history"
        ADD CONSTRAINT "fk_segments_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: marketing.marketing_campaigns (requiere schema marketing)
DO $$ BEGIN
    ALTER TABLE "audit"."marketing_campaigns_history"
        ADD CONSTRAINT "fk_marketing_campaigns_history_marketing_campaigns_id" FOREIGN KEY ("marketing_campaigns_id")
        REFERENCES "marketing"."marketing_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."marketing_campaigns_history"
        ADD CONSTRAINT "fk_marketing_campaigns_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."marketing_campaigns_history"
        ADD CONSTRAINT "fk_marketing_campaigns_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."marketing_campaigns_history"
        ADD CONSTRAINT "fk_marketing_campaigns_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: marketing.journeys (requiere schema marketing)
DO $$ BEGIN
    ALTER TABLE "audit"."journeys_history"
        ADD CONSTRAINT "fk_journeys_history_journeys_id" FOREIGN KEY ("journeys_id")
        REFERENCES "marketing"."journeys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."journeys_history"
        ADD CONSTRAINT "fk_journeys_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."journeys_history"
        ADD CONSTRAINT "fk_journeys_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."journeys_history"
        ADD CONSTRAINT "fk_journeys_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: promotions.loyalty_programs (requiere schema promotions)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_programs_history"
        ADD CONSTRAINT "fk_loyalty_programs_history_loyalty_programs_id" FOREIGN KEY ("loyalty_programs_id")
        REFERENCES "promotions"."loyalty_programs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_programs_history"
        ADD CONSTRAINT "fk_loyalty_programs_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_programs_history"
        ADD CONSTRAINT "fk_loyalty_programs_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_programs_history"
        ADD CONSTRAINT "fk_loyalty_programs_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: promotions.loyalty_memberships (requiere schema promotions)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_memberships_history"
        ADD CONSTRAINT "fk_loyalty_memberships_history_loyalty_memberships_id" FOREIGN KEY ("loyalty_memberships_id")
        REFERENCES "promotions"."loyalty_memberships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_memberships_history"
        ADD CONSTRAINT "fk_loyalty_memberships_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_memberships_history"
        ADD CONSTRAINT "fk_loyalty_memberships_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."loyalty_memberships_history"
        ADD CONSTRAINT "fk_loyalty_memberships_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: promotions.promotions (requiere schema promotions)
DO $$ BEGIN
    ALTER TABLE "audit"."promotions_history"
        ADD CONSTRAINT "fk_promotions_history_promotions_id" FOREIGN KEY ("promotions_id")
        REFERENCES "promotions"."promotions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."promotions_history"
        ADD CONSTRAINT "fk_promotions_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."promotions_history"
        ADD CONSTRAINT "fk_promotions_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."promotions_history"
        ADD CONSTRAINT "fk_promotions_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: promotions.coupons (requiere schema promotions)
DO $$ BEGIN
    ALTER TABLE "audit"."coupons_history"
        ADD CONSTRAINT "fk_coupons_history_coupons_id" FOREIGN KEY ("coupons_id")
        REFERENCES "promotions"."coupons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."coupons_history"
        ADD CONSTRAINT "fk_coupons_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."coupons_history"
        ADD CONSTRAINT "fk_coupons_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."coupons_history"
        ADD CONSTRAINT "fk_coupons_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: promotions.referral_programs (requiere schema promotions)
DO $$ BEGIN
    ALTER TABLE "audit"."referral_programs_history"
        ADD CONSTRAINT "fk_referral_programs_history_referral_programs_id" FOREIGN KEY ("referral_programs_id")
        REFERENCES "promotions"."referral_programs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."referral_programs_history"
        ADD CONSTRAINT "fk_referral_programs_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."referral_programs_history"
        ADD CONSTRAINT "fk_referral_programs_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."referral_programs_history"
        ADD CONSTRAINT "fk_referral_programs_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
