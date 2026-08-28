-- SALUD v4.0.10 · módulo 05 · schema profiles
-- Generado de diagram_05_profiles.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_persons_person_status_concept_id" ON "profiles"."persons" ("person_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_administrative_gender_concept_id" ON "profiles"."persons" ("administrative_gender_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_sex_at_birth_concept_id" ON "profiles"."persons" ("sex_at_birth_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_gender_identity_concept_id" ON "profiles"."persons" ("gender_identity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_vital_status_concept_id" ON "profiles"."persons" ("vital_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_nationality_concept_id" ON "profiles"."persons" ("nationality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_preferred_language_concept_id" ON "profiles"."persons" ("preferred_language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_occupation_concept_id" ON "profiles"."persons" ("occupation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_persons_merge_survivor_person_id" ON "profiles"."persons" ("merge_survivor_person_id");

CREATE INDEX IF NOT EXISTS "ix_persons_photo_file_id" ON "profiles"."persons" ("photo_file_id");

CREATE INDEX IF NOT EXISTS "ix_persons_created_by_user_id" ON "profiles"."persons" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_persons_updated_by_user_id" ON "profiles"."persons" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_persons_search" ON "profiles"."persons" USING gin (to_tsvector('simple', (coalesce(display_name, ''))));

CREATE INDEX IF NOT EXISTS "ix_person_account_links_person_id" ON "profiles"."person_account_links" ("person_id");

CREATE INDEX IF NOT EXISTS "ix_person_account_links_user_id" ON "profiles"."person_account_links" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_person_account_links_link_type_concept_id" ON "profiles"."person_account_links" ("link_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_person_account_links_verification_status_concept_id" ON "profiles"."person_account_links" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_person_account_links_status_concept_id" ON "profiles"."person_account_links" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_person_account_links_created_by_user_id" ON "profiles"."person_account_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_person_account_links_updated_by_user_id" ON "profiles"."person_account_links" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_person_account_links_effective_period" ON "profiles"."person_account_links" USING gist (tstzrange(valid_from, valid_to, '[)'));

-- TODO(predicado placeholder, definir funciones): CREATE UNIQUE INDEX IF NOT EXISTS "uq_person_account_links_active_user" ON "profiles"."person_account_links" ("user_id") WHERE status_concept_id = active_status();

CREATE INDEX IF NOT EXISTS "ix_person_profiles_person_id" ON "profiles"."person_profiles" ("person_id");

CREATE INDEX IF NOT EXISTS "ix_person_profiles_profile_type_concept_id" ON "profiles"."person_profiles" ("profile_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_person_profiles_status_concept_id" ON "profiles"."person_profiles" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_person_profiles_created_by_user_id" ON "profiles"."person_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_person_profiles_updated_by_user_id" ON "profiles"."person_profiles" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_person_profiles_person_type" ON "profiles"."person_profiles" ("person_id", "profile_type_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_patient_profiles_patient_code" ON "profiles"."patient_profiles" ("patient_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_patient_profiles_master_patient_index_code" ON "profiles"."patient_profiles" ("master_patient_index_code");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_abo_group_concept_id" ON "profiles"."patient_profiles" ("abo_group_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_rh_factor_concept_id" ON "profiles"."patient_profiles" ("rh_factor_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_insurance_status_concept_id" ON "profiles"."patient_profiles" ("insurance_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_clinical_language_concept_id" ON "profiles"."patient_profiles" ("clinical_language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_record_linkage_status_concept_id" ON "profiles"."patient_profiles" ("record_linkage_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_created_by_user_id" ON "profiles"."patient_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_profiles_updated_by_user_id" ON "profiles"."patient_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_patient_profile_id" ON "profiles"."patient_identity_links" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_source_tenant_id" ON "profiles"."patient_identity_links" ("source_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_link_type_concept_id" ON "profiles"."patient_identity_links" ("link_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_verification_status_concept_id" ON "profiles"."patient_identity_links" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_verified_by_user_id" ON "profiles"."patient_identity_links" ("verified_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_created_by_user_id" ON "profiles"."patient_identity_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_updated_by_user_id" ON "profiles"."patient_identity_links" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_source_tenant_id_updated_at" ON "profiles"."patient_identity_links" ("source_tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_patient_identity_links_patient_profile_id_updated_at" ON "profiles"."patient_identity_links" ("source_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_patient_identity_source" ON "profiles"."patient_identity_links" ("source_tenant_id", "source_system_uri", "source_patient_identifier");

CREATE INDEX IF NOT EXISTS "ix_patient_merge_events_surviving_patient_profile_id" ON "profiles"."patient_merge_events" ("surviving_patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_merge_events_merged_patient_profile_id" ON "profiles"."patient_merge_events" ("merged_patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_merge_events_reason_concept_id" ON "profiles"."patient_merge_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_merge_events_decision_status_concept_id" ON "profiles"."patient_merge_events" ("decision_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_merge_events_approved_by_user_id" ON "profiles"."patient_merge_events" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_merge_events_reversal_of_event_id" ON "profiles"."patient_merge_events" ("reversal_of_event_id");

CREATE INDEX IF NOT EXISTS "ix_patient_merge_events_recorded_by_user_id" ON "profiles"."patient_merge_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_patient_merge_events_recorded_at" ON "profiles"."patient_merge_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_health_practitioner_profiles_practitioner_code" ON "profiles"."health_practitioner_profiles" ("practitioner_code");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_practitioner_category__a69797c8" ON "profiles"."health_practitioner_profiles" ("practitioner_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_verification_status_concept_id" ON "profiles"."health_practitioner_profiles" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_practice_status_concept_id" ON "profiles"."health_practitioner_profiles" ("practice_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_photo_file_id" ON "profiles"."health_practitioner_profiles" ("photo_file_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_created_by_user_id" ON "profiles"."health_practitioner_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_updated_by_user_id" ON "profiles"."health_practitioner_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_practitioner_profile_id" ON "profiles"."professional_credentials" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_credential_type_concept_id" ON "profiles"."professional_credentials" ("credential_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_issuing_authority_tenant_id" ON "profiles"."professional_credentials" ("issuing_authority_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_issuing_country_concept_id" ON "profiles"."professional_credentials" ("issuing_country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_state_concept_id" ON "profiles"."professional_credentials" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_file_id" ON "profiles"."professional_credentials" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_verified_by_user_id" ON "profiles"."professional_credentials" ("verified_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_created_by_user_id" ON "profiles"."professional_credentials" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_updated_by_user_id" ON "profiles"."professional_credentials" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_specialties_practitioner_profile_id" ON "profiles"."practitioner_specialties" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_specialties_specialty_concept_id" ON "profiles"."practitioner_specialties" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_specialties_supporting_credential_id" ON "profiles"."practitioner_specialties" ("supporting_credential_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_specialties_specialty_role_concept_id" ON "profiles"."practitioner_specialties" ("specialty_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_specialties_verification_status_concept_id" ON "profiles"."practitioner_specialties" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_specialties_created_by_user_id" ON "profiles"."practitioner_specialties" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_specialties_updated_by_user_id" ON "profiles"."practitioner_specialties" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_practitioner_specialty_active" ON "profiles"."practitioner_specialties" ("practitioner_profile_id", "specialty_concept_id") WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_practitioner_languages_practitioner_profile_id" ON "profiles"."practitioner_languages" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_languages_language_concept_id" ON "profiles"."practitioner_languages" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_languages_proficiency_concept_id" ON "profiles"."practitioner_languages" ("proficiency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_languages_created_by_user_id" ON "profiles"."practitioner_languages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_languages_updated_by_user_id" ON "profiles"."practitioner_languages" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_practitioner_profile_id" ON "profiles"."jurisdiction_authorizations" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_jurisdiction_concept_id" ON "profiles"."jurisdiction_authorizations" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_practice_scope_concept_id" ON "profiles"."jurisdiction_authorizations" ("practice_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_state_concept_id" ON "profiles"."jurisdiction_authorizations" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_created_by_user_id" ON "profiles"."jurisdiction_authorizations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_updated_by_user_id" ON "profiles"."jurisdiction_authorizations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_jurisdiction_authorizations_effective_period" ON "profiles"."jurisdiction_authorizations" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_practitioner_profile_id" ON "profiles"."practitioner_affiliations" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_practice_site_id" ON "profiles"."practitioner_affiliations" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_health_facility_concept_id" ON "profiles"."practitioner_affiliations" ("health_facility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_affiliation_type_concept_id" ON "profiles"."practitioner_affiliations" ("affiliation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_status_concept_id" ON "profiles"."practitioner_affiliations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_created_by_user_id" ON "profiles"."practitioner_affiliations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_updated_by_user_id" ON "profiles"."practitioner_affiliations" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practitioner_affiliations_same_health_facility" ON "profiles"."practitioner_affiliations" ("practitioner_profile_id", "health_facility_concept_id", "role_title", "start_date") WHERE health_facility_concept_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practitioner_affiliations_same_organization_name" ON "profiles"."practitioner_affiliations" ("practitioner_profile_id", "organization_name", "role_title", "start_date") WHERE health_facility_concept_id IS NULL;

CREATE INDEX IF NOT EXISTS "ix_related_persons_patient_profile_id" ON "profiles"."related_persons" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_related_persons_person_id" ON "profiles"."related_persons" ("person_id");

CREATE INDEX IF NOT EXISTS "ix_related_persons_relationship_concept_id" ON "profiles"."related_persons" ("relationship_concept_id");

CREATE INDEX IF NOT EXISTS "ix_related_persons_status_concept_id" ON "profiles"."related_persons" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_related_persons_created_by_user_id" ON "profiles"."related_persons" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_related_persons_updated_by_user_id" ON "profiles"."related_persons" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_related_persons_patient_profile_id_updated_at" ON "profiles"."related_persons" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_patient_profile_id" ON "profiles"."patient_portal_proxies" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_proxy_user_id" ON "profiles"."patient_portal_proxies" ("proxy_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_related_person_id" ON "profiles"."patient_portal_proxies" ("related_person_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_scope_value_set_id" ON "profiles"."patient_portal_proxies" ("scope_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_legal_basis_record_id" ON "profiles"."patient_portal_proxies" ("legal_basis_record_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_status_concept_id" ON "profiles"."patient_portal_proxies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_created_by_user_id" ON "profiles"."patient_portal_proxies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_updated_by_user_id" ON "profiles"."patient_portal_proxies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_portal_proxies_patient_profile_id_updated_at" ON "profiles"."patient_portal_proxies" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_insurance_representative_profiles_representative_ty_e1930540" ON "profiles"."insurance_representative_profiles" ("representative_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_representative_profiles_role_concept_id" ON "profiles"."insurance_representative_profiles" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_representative_profiles_created_by_user_id" ON "profiles"."insurance_representative_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_representative_profiles_updated_by_user_id" ON "profiles"."insurance_representative_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_operator_profiles_operator_type_concept_id" ON "profiles"."provider_operator_profiles" ("operator_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_operator_profiles_role_concept_id" ON "profiles"."provider_operator_profiles" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_operator_profiles_created_by_user_id" ON "profiles"."provider_operator_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_operator_profiles_updated_by_user_id" ON "profiles"."provider_operator_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_emergency_staff_profiles_staff_type_concept_id" ON "profiles"."emergency_staff_profiles" ("staff_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_emergency_staff_profiles_availability_status_concept_id" ON "profiles"."emergency_staff_profiles" ("availability_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_emergency_staff_profiles_created_by_user_id" ON "profiles"."emergency_staff_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_emergency_staff_profiles_updated_by_user_id" ON "profiles"."emergency_staff_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_administrator_profiles_administrator_type_concept_id" ON "profiles"."administrator_profiles" ("administrator_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_administrator_profiles_administrative_level_concept_id" ON "profiles"."administrator_profiles" ("administrative_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_administrator_profiles_created_by_user_id" ON "profiles"."administrator_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_administrator_profiles_updated_by_user_id" ON "profiles"."administrator_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_secretary_profiles_role_concept_id" ON "profiles"."secretary_profiles" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_secretary_profiles_created_by_user_id" ON "profiles"."secretary_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_secretary_profiles_updated_by_user_id" ON "profiles"."secretary_profiles" ("updated_by_user_id");
