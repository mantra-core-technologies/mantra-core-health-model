-- SALUD v4.2.83 · módulo 08 · schema clinical
-- Generado de diagram_08_clinical.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_prescription_signature_policies_tenant_id" ON "clinical"."prescription_signature_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_custodian_tenant_id" ON "clinical"."family_member_history" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_patient_profile_id" ON "clinical"."family_member_history" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_relationship_concept_id" ON "clinical"."family_member_history" ("relationship_concept_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_condition_concept_id" ON "clinical"."family_member_history" ("condition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_recorded_by_user_id" ON "clinical"."family_member_history" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_created_by_user_id" ON "clinical"."family_member_history" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_updated_by_user_id" ON "clinical"."family_member_history" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_family_member_history_custodian_tenant_id_updated_at" ON "clinical"."family_member_history" ("custodian_tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_family_member_history_patient_profile_id_updated_at" ON "clinical"."family_member_history" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_social_history_custodian_tenant_id" ON "clinical"."social_history" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_patient_profile_id" ON "clinical"."social_history" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_category_concept_id" ON "clinical"."social_history" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_status_concept_id" ON "clinical"."social_history" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_value_concept_id" ON "clinical"."social_history" ("value_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_unit_concept_id" ON "clinical"."social_history" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_recorded_by_user_id" ON "clinical"."social_history" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_created_by_user_id" ON "clinical"."social_history" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_updated_by_user_id" ON "clinical"."social_history" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_history_custodian_tenant_id_status_concept_id" ON "clinical"."social_history" ("custodian_tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_social_history_patient_profile_id_updated_at" ON "clinical"."social_history" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_episodes_patient_profile_id" ON "clinical"."care_episodes" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_care_episodes_tenant_id" ON "clinical"."care_episodes" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_episodes_responsible_practitioner_id" ON "clinical"."care_episodes" ("responsible_practitioner_id");

CREATE INDEX IF NOT EXISTS "ix_care_episodes_type_concept_id" ON "clinical"."care_episodes" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_episodes_status_concept_id" ON "clinical"."care_episodes" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_episodes_created_by_user_id" ON "clinical"."care_episodes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_episodes_updated_by_user_id" ON "clinical"."care_episodes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_episodes_tenant_id_status_concept_id" ON "clinical"."care_episodes" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_episodes_patient_profile_id_updated_at" ON "clinical"."care_episodes" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_encounters_patient_profile_id" ON "clinical"."encounters" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_episode_id" ON "clinical"."encounters" ("episode_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_tenant_id" ON "clinical"."encounters" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_branch_id" ON "clinical"."encounters" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_primary_practitioner_id" ON "clinical"."encounters" ("primary_practitioner_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_class_concept_id" ON "clinical"."encounters" ("class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_type_concept_id" ON "clinical"."encounters" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_status_concept_id" ON "clinical"."encounters" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_appointment_id" ON "clinical"."encounters" ("appointment_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_created_by_user_id" ON "clinical"."encounters" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_updated_by_user_id" ON "clinical"."encounters" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_tenant_id_status_concept_id" ON "clinical"."encounters" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_encounters_patient_profile_id_updated_at" ON "clinical"."encounters" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_encounters_level_of_care_concept_id" ON "clinical"."encounters" ("level_of_care_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_admission_source_concept_id" ON "clinical"."encounters" ("admission_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_discharge_disposition_concept_id" ON "clinical"."encounters" ("discharge_disposition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_isolation_precaution_concept_id" ON "clinical"."encounters" ("isolation_precaution_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_encounters_tenant_id_id" ON "clinical"."encounters" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_observations_custodian_tenant_id" ON "clinical"."observations" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_observations_patient_profile_id" ON "clinical"."observations" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_observations_encounter_id" ON "clinical"."observations" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_observations_based_on_service_request_id" ON "clinical"."observations" ("based_on_service_request_id");

CREATE INDEX IF NOT EXISTS "ix_observations_category_concept_id" ON "clinical"."observations" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_code_concept_id" ON "clinical"."observations" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_status_concept_id" ON "clinical"."observations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_value_type_concept_id" ON "clinical"."observations" ("value_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_value_concept_id" ON "clinical"."observations" ("value_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_quantity_unit_concept_id" ON "clinical"."observations" ("quantity_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_range_unit_concept_id" ON "clinical"."observations" ("range_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_ratio_numerator_unit_concept_id" ON "clinical"."observations" ("ratio_numerator_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_ratio_denominator_unit_concept_id" ON "clinical"."observations" ("ratio_denominator_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_value_file_id" ON "clinical"."observations" ("value_file_id");

CREATE INDEX IF NOT EXISTS "ix_observations_value_reference_type_concept_id" ON "clinical"."observations" ("value_reference_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_data_absent_reason_concept_id" ON "clinical"."observations" ("data_absent_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_interpretation_concept_id" ON "clinical"."observations" ("interpretation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_method_concept_id" ON "clinical"."observations" ("method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_body_site_concept_id" ON "clinical"."observations" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observations_specimen_id" ON "clinical"."observations" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_observations_source_device_id" ON "clinical"."observations" ("source_device_id");

CREATE INDEX IF NOT EXISTS "ix_observations_recorded_by_user_id" ON "clinical"."observations" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observations_created_by_user_id" ON "clinical"."observations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observations_updated_by_user_id" ON "clinical"."observations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observations_custodian_tenant_id_status_concept_id" ON "clinical"."observations" ("custodian_tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_observations_patient_profile_id_updated_at" ON "clinical"."observations" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_observations_patient_code_effective" ON "clinical"."observations" ("custodian_tenant_id", "patient_profile_id", "code_concept_id", "effective_start_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_observations_encounter_code" ON "clinical"."observations" ("encounter_id", "code_concept_id") WHERE encounter_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_observation_components_observation_id" ON "clinical"."observation_components" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_code_concept_id" ON "clinical"."observation_components" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_value_type_concept_id" ON "clinical"."observation_components" ("value_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_value_concept_id" ON "clinical"."observation_components" ("value_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_quantity_unit_concept_id" ON "clinical"."observation_components" ("quantity_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_range_unit_concept_id" ON "clinical"."observation_components" ("range_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_data_absent_reason_concept_id" ON "clinical"."observation_components" ("data_absent_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_interpretation_concept_id" ON "clinical"."observation_components" ("interpretation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_created_by_user_id" ON "clinical"."observation_components" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observation_components_updated_by_user_id" ON "clinical"."observation_components" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_custodian_tenant_id" ON "clinical"."conditions" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_patient_profile_id" ON "clinical"."conditions" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_encounter_id" ON "clinical"."conditions" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_code_concept_id" ON "clinical"."conditions" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_category_concept_id" ON "clinical"."conditions" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_clinical_status_concept_id" ON "clinical"."conditions" ("clinical_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_verification_status_concept_id" ON "clinical"."conditions" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_severity_concept_id" ON "clinical"."conditions" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_laterality_concept_id" ON "clinical"."conditions" ("laterality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_clinical_course_concept_id" ON "clinical"."conditions" ("clinical_course_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_recorded_by_user_id" ON "clinical"."conditions" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_created_by_user_id" ON "clinical"."conditions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_updated_by_user_id" ON "clinical"."conditions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conditions_custodian_tenant_id_updated_at" ON "clinical"."conditions" ("custodian_tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_conditions_patient_profile_id_updated_at" ON "clinical"."conditions" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_conditions_patient_clinical_status" ON "clinical"."conditions" ("custodian_tenant_id", "patient_profile_id", "clinical_status_concept_id", "onset_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_custodian_tenant_id" ON "clinical"."allergy_intolerances" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_patient_profile_id" ON "clinical"."allergy_intolerances" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_substance_concept_id" ON "clinical"."allergy_intolerances" ("substance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_type_concept_id" ON "clinical"."allergy_intolerances" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_category_concept_id" ON "clinical"."allergy_intolerances" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_criticality_concept_id" ON "clinical"."allergy_intolerances" ("criticality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_clinical_status_concept_id" ON "clinical"."allergy_intolerances" ("clinical_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_verification_status_concept_id" ON "clinical"."allergy_intolerances" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_recorded_by_user_id" ON "clinical"."allergy_intolerances" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_encounter_id" ON "clinical"."allergy_intolerances" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_created_by_user_id" ON "clinical"."allergy_intolerances" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_updated_by_user_id" ON "clinical"."allergy_intolerances" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_custodian_tenant_id_updated_at" ON "clinical"."allergy_intolerances" ("custodian_tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_patient_profile_id_updated_at" ON "clinical"."allergy_intolerances" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_allergies_patient_status" ON "clinical"."allergy_intolerances" ("custodian_tenant_id", "patient_profile_id", "clinical_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_reactions_allergy_id" ON "clinical"."allergy_reactions" ("allergy_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_reactions_manifestation_concept_id" ON "clinical"."allergy_reactions" ("manifestation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_reactions_severity_concept_id" ON "clinical"."allergy_reactions" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_reactions_created_by_user_id" ON "clinical"."allergy_reactions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_allergy_reactions_updated_by_user_id" ON "clinical"."allergy_reactions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_custodian_tenant_id" ON "clinical"."service_requests" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_patient_profile_id" ON "clinical"."service_requests" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_encounter_id" ON "clinical"."service_requests" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_code_concept_id" ON "clinical"."service_requests" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_category_concept_id" ON "clinical"."service_requests" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_intent_concept_id" ON "clinical"."service_requests" ("intent_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_priority_concept_id" ON "clinical"."service_requests" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_status_concept_id" ON "clinical"."service_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_requester_profile_id" ON "clinical"."service_requests" ("requester_profile_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_performer_tenant_id" ON "clinical"."service_requests" ("performer_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_performer_practitioner_profile_id" ON "clinical"."service_requests" ("performer_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_suggested_practice_site_id" ON "clinical"."service_requests" ("suggested_practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_previous_diagnostic_report_id" ON "clinical"."service_requests" ("previous_diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_form_instance_id" ON "clinical"."service_requests" ("form_instance_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_created_by_user_id" ON "clinical"."service_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_updated_by_user_id" ON "clinical"."service_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_custodian_tenant_id_status_concept_id" ON "clinical"."service_requests" ("custodian_tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_service_requests_patient_profile_id_updated_at" ON "clinical"."service_requests" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_service_requests_suggested_care_space_id" ON "clinical"."service_requests" ("suggested_care_space_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_specimen_type_concept_id" ON "clinical"."service_requests" ("specimen_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_modality_concept_id" ON "clinical"."service_requests" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_body_site_concept_id" ON "clinical"."service_requests" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_laterality_concept_id" ON "clinical"."service_requests" ("laterality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_contrast_concept_id" ON "clinical"."service_requests" ("contrast_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_requisition_id" ON "clinical"."service_requests" ("custodian_tenant_id", "requisition_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_performer_inbox" ON "clinical"."service_requests" ("performer_tenant_id", "status_concept_id", "created_at", "id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_custodian_tenant_id" ON "clinical"."diagnostic_reports" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_patient_profile_id" ON "clinical"."diagnostic_reports" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_service_request_id" ON "clinical"."diagnostic_reports" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_encounter_id" ON "clinical"."diagnostic_reports" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_code_concept_id" ON "clinical"."diagnostic_reports" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_category_concept_id" ON "clinical"."diagnostic_reports" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_lifecycle_status_concept_id" ON "clinical"."diagnostic_reports" ("lifecycle_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_current_version_id" ON "clinical"."diagnostic_reports" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_current_released_version_id" ON "clinical"."diagnostic_reports" ("current_released_version_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_result_release_status_concept_id" ON "clinical"."diagnostic_reports" ("result_release_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_created_by_user_id" ON "clinical"."diagnostic_reports" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_updated_by_user_id" ON "clinical"."diagnostic_reports" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_custodian_tenant_id_lifecycle_st_43c65044" ON "clinical"."diagnostic_reports" ("custodian_tenant_id", "lifecycle_status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_reports_patient_profile_id_updated_at" ON "clinical"."diagnostic_reports" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_medication_requests_custodian_tenant_id" ON "clinical"."medication_requests" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_patient_profile_id" ON "clinical"."medication_requests" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_encounter_id" ON "clinical"."medication_requests" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_medication_concept_id" ON "clinical"."medication_requests" ("medication_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_substance_atc_concept_id" ON "clinical"."medication_requests" ("substance_atc_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_intent_concept_id" ON "clinical"."medication_requests" ("intent_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_status_concept_id" ON "clinical"."medication_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_prescriber_profile_id" ON "clinical"."medication_requests" ("prescriber_profile_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_route_concept_id" ON "clinical"."medication_requests" ("route_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_unit_concept_id" ON "clinical"."medication_requests" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_indication_condition_id" ON "clinical"."medication_requests" ("indication_condition_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_form_instance_id" ON "clinical"."medication_requests" ("form_instance_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_created_by_user_id" ON "clinical"."medication_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_updated_by_user_id" ON "clinical"."medication_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_requests_custodian_tenant_id_status_concept_id" ON "clinical"."medication_requests" ("custodian_tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_medication_requests_patient_profile_id_updated_at" ON "clinical"."medication_requests" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_medication_requests_issue_idempotency_key" ON "clinical"."medication_requests" ("issue_idempotency_key") WHERE issue_idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_medication_records_custodian_tenant_id" ON "clinical"."medication_records" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_patient_profile_id" ON "clinical"."medication_records" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_request_id" ON "clinical"."medication_records" ("request_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_medication_concept_id" ON "clinical"."medication_records" ("medication_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_status_concept_id" ON "clinical"."medication_records" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_record_type_concept_id" ON "clinical"."medication_records" ("record_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_unit_concept_id" ON "clinical"."medication_records" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_recorded_by_user_id" ON "clinical"."medication_records" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_created_by_user_id" ON "clinical"."medication_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_updated_by_user_id" ON "clinical"."medication_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_records_custodian_tenant_id_status_concept_id" ON "clinical"."medication_records" ("custodian_tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_medication_records_patient_profile_id_updated_at" ON "clinical"."medication_records" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_procedures_custodian_tenant_id" ON "clinical"."procedures" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_patient_profile_id" ON "clinical"."procedures" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_encounter_id" ON "clinical"."procedures" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_code_concept_id" ON "clinical"."procedures" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_status_concept_id" ON "clinical"."procedures" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_performer_profile_id" ON "clinical"."procedures" ("performer_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_created_by_user_id" ON "clinical"."procedures" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_updated_by_user_id" ON "clinical"."procedures" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_custodian_tenant_id_status_concept_id" ON "clinical"."procedures" ("custodian_tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_procedures_patient_profile_id_updated_at" ON "clinical"."procedures" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_procedures_service_request_id" ON "clinical"."procedures" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_parent_procedure_id" ON "clinical"."procedures" ("parent_procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_practice_site_id" ON "clinical"."procedures" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_procedures_patient_occurrence" ON "clinical"."procedures" ("custodian_tenant_id", "patient_profile_id", "occurrence_start_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_procedures_code_status_time" ON "clinical"."procedures" ("custodian_tenant_id", "code_concept_id", "status_concept_id", "occurrence_start_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_immunizations_custodian_tenant_id" ON "clinical"."immunizations" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_patient_profile_id" ON "clinical"."immunizations" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_vaccine_concept_id" ON "clinical"."immunizations" ("vaccine_concept_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_status_concept_id" ON "clinical"."immunizations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_route_concept_id" ON "clinical"."immunizations" ("route_concept_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_administered_by_profile_id" ON "clinical"."immunizations" ("administered_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_created_by_user_id" ON "clinical"."immunizations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_updated_by_user_id" ON "clinical"."immunizations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_immunizations_custodian_tenant_id_status_concept_id" ON "clinical"."immunizations" ("custodian_tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_immunizations_patient_profile_id_updated_at" ON "clinical"."immunizations" ("custodian_tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_received_services_custodian_tenant_id" ON "clinical"."received_services" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_patient_profile_id" ON "clinical"."received_services" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_encounter_id" ON "clinical"."received_services" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_service_type_concept_id" ON "clinical"."received_services" ("service_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_service_concept_id" ON "clinical"."received_services" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_status_concept_id" ON "clinical"."received_services" ("status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_received_services_source_procedure_id" ON "clinical"."received_services" ("source_procedure_id") WHERE source_procedure_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_received_services_source_immunization_id" ON "clinical"."received_services" ("source_immunization_id") WHERE source_immunization_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_received_services_procedure_case_id" ON "clinical"."received_services" ("procedure_case_id") WHERE procedure_case_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_received_services_service_catalog_id" ON "clinical"."received_services" ("service_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_invoice_line_id" ON "clinical"."received_services" ("invoice_line_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_insurance_claim_line_id" ON "clinical"."received_services" ("insurance_claim_line_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_performer_profile_id" ON "clinical"."received_services" ("performer_profile_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_practice_site_id" ON "clinical"."received_services" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_outcome_concept_id" ON "clinical"."received_services" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_created_by_user_id" ON "clinical"."received_services" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_updated_by_user_id" ON "clinical"."received_services" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_received_services_patient_performed_at" ON "clinical"."received_services" ("custodian_tenant_id", "patient_profile_id", "performed_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_appointments_patient_profile_id" ON "clinical"."appointments" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_practitioner_profile_id" ON "clinical"."appointments" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_tenant_id" ON "clinical"."appointments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_branch_id" ON "clinical"."appointments" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_type_concept_id" ON "clinical"."appointments" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_status_concept_id" ON "clinical"."appointments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_channel_concept_id" ON "clinical"."appointments" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_created_by_user_id" ON "clinical"."appointments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_updated_by_user_id" ON "clinical"."appointments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_tenant_id_status_concept_id" ON "clinical"."appointments" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_appointments_patient_profile_id_updated_at" ON "clinical"."appointments" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_appointments_effective_period" ON "clinical"."appointments" USING gist (tstzrange(start_at, end_at, '[)'));

-- OMITIDO (predicado con función placeholder del modelo, sin definir en la base): CREATE INDEX IF NOT EXISTS "gist_appointments_practitioner_time" ON "clinical"."appointments" USING gist ("practitioner_profile_id", tstzrange(start_at, end_at, '[)')) WHERE status_concept_id IN (held_status(), confirmed_status());

CREATE INDEX IF NOT EXISTS "ix_appointments_patient_start" ON "clinical"."appointments" ("patient_profile_id", "start_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_appointments_care_space_id" ON "clinical"."appointments" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_participants_encounter_id" ON "clinical"."encounter_participants" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_participants_practitioner_profile_id" ON "clinical"."encounter_participants" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_participants_participant_role_concept_id" ON "clinical"."encounter_participants" ("participant_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_participants_practitioner_role_assignment_id" ON "clinical"."encounter_participants" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_participants_status_concept_id" ON "clinical"."encounter_participants" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_participants_created_by_user_id" ON "clinical"."encounter_participants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_participants_updated_by_user_id" ON "clinical"."encounter_participants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_encounter_id" ON "clinical"."encounter_locations" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_practice_site_id" ON "clinical"."encounter_locations" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_clinical_unit_id" ON "clinical"."encounter_locations" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_care_space_id" ON "clinical"."encounter_locations" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_location_status_concept_id" ON "clinical"."encounter_locations" ("location_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_created_by_user_id" ON "clinical"."encounter_locations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_updated_by_user_id" ON "clinical"."encounter_locations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_tenant_id" ON "clinical"."encounter_locations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_movement_type_concept_id" ON "clinical"."encounter_locations" ("movement_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_previous_encounter_location_id" ON "clinical"."encounter_locations" ("previous_encounter_location_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_end_reason_concept_id" ON "clinical"."encounter_locations" ("end_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_bed_category_concept_id" ON "clinical"."encounter_locations" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_placement_incident_id" ON "clinical"."encounter_locations" ("placement_incident_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_bed_period" ON "clinical"."encounter_locations" ("care_space_id", "period_start" DESC) WHERE is_bed_assignment;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_encounter_locations_tenant_id_id" ON "clinical"."encounter_locations" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_tenant_id" ON "clinical"."placement_incidents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_encounter_id" ON "clinical"."placement_incidents" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_encounter_location_id" ON "clinical"."placement_incidents" ("encounter_location_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_care_space_id" ON "clinical"."placement_incidents" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_patient_profile_id" ON "clinical"."placement_incidents" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_authorized_by_user_id" ON "clinical"."placement_incidents" ("authorized_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_status_concept_id" ON "clinical"."placement_incidents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_reviewed_by_user_id" ON "clinical"."placement_incidents" ("reviewed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_created_by_user_id" ON "clinical"."placement_incidents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_updated_by_user_id" ON "clinical"."placement_incidents" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_placement_incidents_tenant_id_id" ON "clinical"."placement_incidents" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inpatient_census_days_site_unit_date" ON "clinical"."inpatient_census_days" ("practice_site_id", "clinical_unit_id", "census_date");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_tenant_id" ON "clinical"."inpatient_census_days" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_clinical_unit_id" ON "clinical"."inpatient_census_days" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_status_concept_id" ON "clinical"."inpatient_census_days" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_closed_by_user_id" ON "clinical"."inpatient_census_days" ("closed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_created_by_user_id" ON "clinical"."inpatient_census_days" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_updated_by_user_id" ON "clinical"."inpatient_census_days" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_site_date" ON "clinical"."inpatient_census_days" ("practice_site_id", "census_date" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inpatient_census_days_tenant_id_id" ON "clinical"."inpatient_census_days" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_patient_admission_footprints_tenant_patient" ON "clinical"."patient_admission_footprints" ("tenant_id", "patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_patient_profile_id" ON "clinical"."patient_admission_footprints" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_encounter_id" ON "clinical"."patient_admission_footprints" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_practice_site_id" ON "clinical"."patient_admission_footprints" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_admission_origin_concept_id" ON "clinical"."patient_admission_footprints" ("admission_origin_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_identity_verification__51230394" ON "clinical"."patient_admission_footprints" ("identity_verification_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_referral_id" ON "clinical"."patient_admission_footprints" ("referral_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_recorded_by_user_id" ON "clinical"."patient_admission_footprints" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_tenant_id" ON "clinical"."inpatient_census_entries" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_census_day_id" ON "clinical"."inpatient_census_entries" ("census_day_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_encounter_id" ON "clinical"."inpatient_census_entries" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_patient_profile_id" ON "clinical"."inpatient_census_entries" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_care_space_id" ON "clinical"."inpatient_census_entries" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_bed_category_concept_id" ON "clinical"."inpatient_census_entries" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_movement_concept_id" ON "clinical"."inpatient_census_entries" ("movement_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_tenant_id" ON "clinical"."inpatient_census_adjustments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_census_day_id" ON "clinical"."inpatient_census_adjustments" ("census_day_id", "created_at");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_adjusted_by_user_id" ON "clinical"."inpatient_census_adjustments" ("adjusted_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observation_performers_observation_id" ON "clinical"."observation_performers" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_observation_performers_performer_type_concept_id" ON "clinical"."observation_performers" ("performer_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_performers_performer_role_concept_id" ON "clinical"."observation_performers" ("performer_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_performers_created_by_user_id" ON "clinical"."observation_performers" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_service_request_notes_request_note" ON "clinical"."service_request_notes" ("service_request_id", "clinical_note_header_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_notes_service_request_id" ON "clinical"."service_request_notes" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_notes_clinical_note_header_id" ON "clinical"."service_request_notes" ("clinical_note_header_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_notes_created_by_user_id" ON "clinical"."service_request_notes" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_service_request_components_request_component" ON "clinical"."service_request_components" ("service_request_id", "component_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_components_service_request_id" ON "clinical"."service_request_components" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_components_custodian_tenant_id" ON "clinical"."service_request_components" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_components_component_concept_id" ON "clinical"."service_request_components" ("component_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_components_created_by_user_id" ON "clinical"."service_request_components" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observation_reference_ranges_observation_id" ON "clinical"."observation_reference_ranges" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_observation_reference_ranges_observation_component_id" ON "clinical"."observation_reference_ranges" ("observation_component_id");

CREATE INDEX IF NOT EXISTS "ix_observation_reference_ranges_unit_concept_id" ON "clinical"."observation_reference_ranges" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_reference_ranges_type_concept_id" ON "clinical"."observation_reference_ranges" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_reference_ranges_applies_to_concept_id" ON "clinical"."observation_reference_ranges" ("applies_to_concept_id");

CREATE INDEX IF NOT EXISTS "ix_observation_reference_ranges_created_by_user_id" ON "clinical"."observation_reference_ranges" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observation_notes_observation_id" ON "clinical"."observation_notes" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_observation_notes_author_user_id" ON "clinical"."observation_notes" ("author_user_id");
