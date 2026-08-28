-- SALUD v4.0.10 · módulo 07 · schema consent
-- Generado de diagram_07_consent.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_processing_purposes_code" ON "consent"."processing_purposes" ("code");

CREATE INDEX IF NOT EXISTS "ix_processing_purposes_purpose_category_concept_id" ON "consent"."processing_purposes" ("purpose_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_purposes_purpose_of_use_concept_id" ON "consent"."processing_purposes" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_purposes_default_retention_class_concept_id" ON "consent"."processing_purposes" ("default_retention_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_purposes_status_concept_id" ON "consent"."processing_purposes" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_purposes_created_by_user_id" ON "consent"."processing_purposes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_processing_purposes_updated_by_user_id" ON "consent"."processing_purposes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_tenant_id" ON "consent"."processing_legal_bases" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_processing_purpose_id" ON "consent"."processing_legal_bases" ("processing_purpose_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_jurisdiction_concept_id" ON "consent"."processing_legal_bases" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_general_legal_basis_concept_id" ON "consent"."processing_legal_bases" ("general_legal_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_special_category_condition_concept_id" ON "consent"."processing_legal_bases" ("special_category_condition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_status_concept_id" ON "consent"."processing_legal_bases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_created_by_user_id" ON "consent"."processing_legal_bases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_updated_by_user_id" ON "consent"."processing_legal_bases" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_processing_legal_bases_tenant_id_status_concept_id" ON "consent"."processing_legal_bases" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_processing_legal_bases_effective_period" ON "consent"."processing_legal_bases" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_processing_legal_basis_version" ON "consent"."processing_legal_bases" ("tenant_id", "processing_purpose_id", "jurisdiction_concept_id", "valid_from");

CREATE INDEX IF NOT EXISTS "ix_consents_patient_profile_id" ON "consent"."consents" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_consents_granted_by_user_id" ON "consent"."consents" ("granted_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_consents_granted_by_related_person_id" ON "consent"."consents" ("granted_by_related_person_id");

CREATE INDEX IF NOT EXISTS "ix_consents_category_concept_id" ON "consent"."consents" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consents_processing_purpose_id" ON "consent"."consents" ("processing_purpose_id");

CREATE INDEX IF NOT EXISTS "ix_consents_processing_legal_basis_id" ON "consent"."consents" ("processing_legal_basis_id");

CREATE INDEX IF NOT EXISTS "ix_consents_status_concept_id" ON "consent"."consents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consents_tenant_id" ON "consent"."consents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_consents_withdrawal_reason_concept_id" ON "consent"."consents" ("withdrawal_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consents_created_by_user_id" ON "consent"."consents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_consents_updated_by_user_id" ON "consent"."consents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_consents_tenant_id_status_concept_id" ON "consent"."consents" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_consents_patient_profile_id_updated_at" ON "consent"."consents" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_consents_effective_period" ON "consent"."consents" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_consents_patient_purpose_status" ON "consent"."consents" ("patient_profile_id", "processing_purpose_id", "status_concept_id", "valid_from" DESC);

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_consent_id" ON "consent"."consent_provisions" ("consent_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_provision_type_concept_id" ON "consent"."consent_provisions" ("provision_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_action_concept_id" ON "consent"."consent_provisions" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_data_class_concept_id" ON "consent"."consent_provisions" ("data_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_actor_tenant_id" ON "consent"."consent_provisions" ("actor_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_actor_user_id" ON "consent"."consent_provisions" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_actor_role_concept_id" ON "consent"."consent_provisions" ("actor_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_purpose_of_use_concept_id" ON "consent"."consent_provisions" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_security_label_concept_id" ON "consent"."consent_provisions" ("security_label_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_created_by_user_id" ON "consent"."consent_provisions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_consent_provisions_updated_by_user_id" ON "consent"."consent_provisions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_consent_provisions_effective_period" ON "consent"."consent_provisions" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_patient_profile_id" ON "consent"."hipaa_authorizations" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_tenant_id" ON "consent"."hipaa_authorizations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_processing_purpose_id" ON "consent"."hipaa_authorizations" ("processing_purpose_id");

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_expiration_type_concept_id" ON "consent"."hipaa_authorizations" ("expiration_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_status_concept_id" ON "consent"."hipaa_authorizations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_created_by_user_id" ON "consent"."hipaa_authorizations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_updated_by_user_id" ON "consent"."hipaa_authorizations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_tenant_id_status_concept_id" ON "consent"."hipaa_authorizations" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_hipaa_authorizations_patient_profile_id_updated_at" ON "consent"."hipaa_authorizations" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_patient_profile_id" ON "consent"."treatment_informed_consents" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_tenant_id" ON "consent"."treatment_informed_consents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_encounter_id" ON "consent"."treatment_informed_consents" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_procedure_code_concept_id" ON "consent"."treatment_informed_consents" ("procedure_code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_interpreter_user_id" ON "consent"."treatment_informed_consents" ("interpreter_user_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_witness_user_id" ON "consent"."treatment_informed_consents" ("witness_user_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_decision_concept_id" ON "consent"."treatment_informed_consents" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_status_concept_id" ON "consent"."treatment_informed_consents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_created_by_user_id" ON "consent"."treatment_informed_consents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_updated_by_user_id" ON "consent"."treatment_informed_consents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_tenant_id_status_concept_id" ON "consent"."treatment_informed_consents" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_patient_profile_id_updated_at" ON "consent"."treatment_informed_consents" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_patient_profile_id" ON "consent"."privacy_restrictions" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_tenant_id" ON "consent"."privacy_restrictions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_restriction_type_concept_id" ON "consent"."privacy_restrictions" ("restriction_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_data_class_concept_id" ON "consent"."privacy_restrictions" ("data_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_target_actor_type_concept_id" ON "consent"."privacy_restrictions" ("target_actor_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_status_concept_id" ON "consent"."privacy_restrictions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_created_by_user_id" ON "consent"."privacy_restrictions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_updated_by_user_id" ON "consent"."privacy_restrictions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_tenant_id_status_concept_id" ON "consent"."privacy_restrictions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_privacy_restrictions_patient_profile_id_updated_at" ON "consent"."privacy_restrictions" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_privacy_restrictions_effective_period" ON "consent"."privacy_restrictions" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_patient_objections_patient_profile_id" ON "consent"."patient_objections" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_tenant_id" ON "consent"."patient_objections" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_processing_purpose_id" ON "consent"."patient_objections" ("processing_purpose_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_objection_type_concept_id" ON "consent"."patient_objections" ("objection_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_status_concept_id" ON "consent"."patient_objections" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_resolution_concept_id" ON "consent"."patient_objections" ("resolution_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_created_by_user_id" ON "consent"."patient_objections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_updated_by_user_id" ON "consent"."patient_objections" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_objections_tenant_id_status_concept_id" ON "consent"."patient_objections" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_patient_objections_patient_profile_id_updated_at" ON "consent"."patient_objections" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_consent_evidence_subject_type_concept_id" ON "consent"."consent_evidence" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_evidence_evidence_type_concept_id" ON "consent"."consent_evidence" ("evidence_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_evidence_document_file_id" ON "consent"."consent_evidence" ("document_file_id");

CREATE INDEX IF NOT EXISTS "ix_consent_evidence_signature_id" ON "consent"."consent_evidence" ("signature_id");

CREATE INDEX IF NOT EXISTS "ix_consent_evidence_captured_channel_concept_id" ON "consent"."consent_evidence" ("captured_channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_evidence_recorded_by_user_id" ON "consent"."consent_evidence" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_consent_evidence_recorded_at" ON "consent"."consent_evidence" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_consent_events_subject_type_concept_id" ON "consent"."consent_events" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_events_event_type_concept_id" ON "consent"."consent_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_events_previous_status_concept_id" ON "consent"."consent_events" ("previous_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_events_new_status_concept_id" ON "consent"."consent_events" ("new_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_events_reason_concept_id" ON "consent"."consent_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_consent_events_recorded_by_user_id" ON "consent"."consent_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_consent_events_recorded_at" ON "consent"."consent_events" USING brin ("recorded_at") WITH (pages_per_range=128);
