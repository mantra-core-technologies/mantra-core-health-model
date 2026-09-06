-- SALUD v4.0.10 · módulo 05 · schema profiles
-- Generado de diagram_05_profiles.puml — NO editar a mano.


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_person_status_concept_id" FOREIGN KEY ("person_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_photo_file_id" FOREIGN KEY ("photo_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_administrative_gender_concept_id" FOREIGN KEY ("administrative_gender_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_sex_at_birth_concept_id" FOREIGN KEY ("sex_at_birth_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_gender_identity_concept_id" FOREIGN KEY ("gender_identity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_vital_status_concept_id" FOREIGN KEY ("vital_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_nationality_concept_id" FOREIGN KEY ("nationality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_preferred_language_concept_id" FOREIGN KEY ("preferred_language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_occupation_concept_id" FOREIGN KEY ("occupation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_work_employer_concept_id" FOREIGN KEY ("work_employer_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_account_links"
        ADD CONSTRAINT "fk_person_account_links_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_account_links"
        ADD CONSTRAINT "fk_person_account_links_link_type_concept_id" FOREIGN KEY ("link_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_account_links"
        ADD CONSTRAINT "fk_person_account_links_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_account_links"
        ADD CONSTRAINT "fk_person_account_links_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_account_links"
        ADD CONSTRAINT "fk_person_account_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_account_links"
        ADD CONSTRAINT "fk_person_account_links_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_profiles"
        ADD CONSTRAINT "fk_person_profiles_profile_type_concept_id" FOREIGN KEY ("profile_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_profiles"
        ADD CONSTRAINT "fk_person_profiles_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_profiles"
        ADD CONSTRAINT "fk_person_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."person_profiles"
        ADD CONSTRAINT "fk_person_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_abo_group_concept_id" FOREIGN KEY ("abo_group_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_rh_factor_concept_id" FOREIGN KEY ("rh_factor_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_insurance_status_concept_id" FOREIGN KEY ("insurance_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_clinical_language_concept_id" FOREIGN KEY ("clinical_language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_record_linkage_status_concept_id" FOREIGN KEY ("record_linkage_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_identity_links"
        ADD CONSTRAINT "fk_patient_identity_links_source_tenant_id" FOREIGN KEY ("source_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_identity_links"
        ADD CONSTRAINT "fk_patient_identity_links_link_type_concept_id" FOREIGN KEY ("link_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_identity_links"
        ADD CONSTRAINT "fk_patient_identity_links_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_identity_links"
        ADD CONSTRAINT "fk_patient_identity_links_verified_by_user_id" FOREIGN KEY ("verified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_identity_links"
        ADD CONSTRAINT "fk_patient_identity_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_identity_links"
        ADD CONSTRAINT "fk_patient_identity_links_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_merge_events"
        ADD CONSTRAINT "fk_patient_merge_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_merge_events"
        ADD CONSTRAINT "fk_patient_merge_events_decision_status_concept_id" FOREIGN KEY ("decision_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_merge_events"
        ADD CONSTRAINT "fk_patient_merge_events_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_merge_events"
        ADD CONSTRAINT "fk_patient_merge_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_practitioner_category__93fc9ab7" FOREIGN KEY ("practitioner_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_practice_status_concept_id" FOREIGN KEY ("practice_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_photo_file_id" FOREIGN KEY ("photo_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_credential_type_concept_id" FOREIGN KEY ("credential_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_issuing_authority_tenant_id" FOREIGN KEY ("issuing_authority_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_issuing_country_concept_id" FOREIGN KEY ("issuing_country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_verified_by_user_id" FOREIGN KEY ("verified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_specialties"
        ADD CONSTRAINT "fk_practitioner_specialties_specialty_concept_id" FOREIGN KEY ("specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_specialties"
        ADD CONSTRAINT "fk_practitioner_specialties_specialty_role_concept_id" FOREIGN KEY ("specialty_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_specialties"
        ADD CONSTRAINT "fk_practitioner_specialties_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_specialties"
        ADD CONSTRAINT "fk_practitioner_specialties_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_specialties"
        ADD CONSTRAINT "fk_practitioner_specialties_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_languages"
        ADD CONSTRAINT "fk_practitioner_languages_language_concept_id" FOREIGN KEY ("language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_languages"
        ADD CONSTRAINT "fk_practitioner_languages_proficiency_concept_id" FOREIGN KEY ("proficiency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_languages"
        ADD CONSTRAINT "fk_practitioner_languages_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_languages"
        ADD CONSTRAINT "fk_practitioner_languages_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."jurisdiction_authorizations"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."jurisdiction_authorizations"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_practice_scope_concept_id" FOREIGN KEY ("practice_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."jurisdiction_authorizations"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."jurisdiction_authorizations"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."jurisdiction_authorizations"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_health_facility_concept_id" FOREIGN KEY ("health_facility_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_affiliation_type_concept_id" FOREIGN KEY ("affiliation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."related_persons"
        ADD CONSTRAINT "fk_related_persons_relationship_concept_id" FOREIGN KEY ("relationship_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."related_persons"
        ADD CONSTRAINT "fk_related_persons_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."related_persons"
        ADD CONSTRAINT "fk_related_persons_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."related_persons"
        ADD CONSTRAINT "fk_related_persons_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_proxy_user_id" FOREIGN KEY ("proxy_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_scope_value_set_id" FOREIGN KEY ("scope_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: consent.processing_legal_bases (requiere schema consent)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_legal_basis_record_id" FOREIGN KEY ("legal_basis_record_id")
        REFERENCES "consent"."processing_legal_bases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."insurance_representative_profiles"
        ADD CONSTRAINT "fk_insurance_representative_profiles_representative_ty_fcc1b52f" FOREIGN KEY ("representative_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."insurance_representative_profiles"
        ADD CONSTRAINT "fk_insurance_representative_profiles_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."insurance_representative_profiles"
        ADD CONSTRAINT "fk_insurance_representative_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."insurance_representative_profiles"
        ADD CONSTRAINT "fk_insurance_representative_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."provider_operator_profiles"
        ADD CONSTRAINT "fk_provider_operator_profiles_operator_type_concept_id" FOREIGN KEY ("operator_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."provider_operator_profiles"
        ADD CONSTRAINT "fk_provider_operator_profiles_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."provider_operator_profiles"
        ADD CONSTRAINT "fk_provider_operator_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."provider_operator_profiles"
        ADD CONSTRAINT "fk_provider_operator_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."emergency_staff_profiles"
        ADD CONSTRAINT "fk_emergency_staff_profiles_staff_type_concept_id" FOREIGN KEY ("staff_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."emergency_staff_profiles"
        ADD CONSTRAINT "fk_emergency_staff_profiles_availability_status_concept_id" FOREIGN KEY ("availability_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."emergency_staff_profiles"
        ADD CONSTRAINT "fk_emergency_staff_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."emergency_staff_profiles"
        ADD CONSTRAINT "fk_emergency_staff_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."administrator_profiles"
        ADD CONSTRAINT "fk_administrator_profiles_administrator_type_concept_id" FOREIGN KEY ("administrator_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."administrator_profiles"
        ADD CONSTRAINT "fk_administrator_profiles_administrative_level_concept_id" FOREIGN KEY ("administrative_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."administrator_profiles"
        ADD CONSTRAINT "fk_administrator_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."administrator_profiles"
        ADD CONSTRAINT "fk_administrator_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."secretary_profiles"
        ADD CONSTRAINT "fk_secretary_profiles_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."secretary_profiles"
        ADD CONSTRAINT "fk_secretary_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."secretary_profiles"
        ADD CONSTRAINT "fk_secretary_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
