-- SALUD v4.0.10 · módulo 53 · schema procedures_perioperative
-- Generado de diagram_53_procedures_perioperative.puml — NO editar a mano.


-- Requerida por índices GiST sobre columnas escalares (uuid/int/…):
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_custodian_tenant_id" ON "procedures_perioperative"."procedure_cases" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_patient_profile_id" ON "procedures_perioperative"."procedure_cases" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_encounter_id" ON "procedures_perioperative"."procedure_cases" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_service_request_id" ON "procedures_perioperative"."procedure_cases" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_primary_procedure_id" ON "procedures_perioperative"."procedure_cases" ("primary_procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_case_type_concept_id" ON "procedures_perioperative"."procedure_cases" ("case_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_priority_concept_id" ON "procedures_perioperative"."procedure_cases" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_status_concept_id" ON "procedures_perioperative"."procedure_cases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_surgical_specialty_concept_id" ON "procedures_perioperative"."procedure_cases" ("surgical_specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_requested_by_profile_id" ON "procedures_perioperative"."procedure_cases" ("requested_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_primary_surgeon_profile_id" ON "procedures_perioperative"."procedure_cases" ("primary_surgeon_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_anesthesiologist_profile_id" ON "procedures_perioperative"."procedure_cases" ("anesthesiologist_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_practice_site_id" ON "procedures_perioperative"."procedure_cases" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_operating_room_id" ON "procedures_perioperative"."procedure_cases" ("operating_room_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_cancellation_reason_concept_id" ON "procedures_perioperative"."procedure_cases" ("cancellation_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_created_by_user_id" ON "procedures_perioperative"."procedure_cases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_updated_by_user_id" ON "procedures_perioperative"."procedure_cases" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_cases_tenant_number" ON "procedures_perioperative"."procedure_cases" ("custodian_tenant_id", "case_number");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_room_schedule" ON "procedures_perioperative"."procedure_cases" ("operating_room_id", "scheduled_start_at", "scheduled_end_at");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_patient_time" ON "procedures_perioperative"."procedure_cases" ("custodian_tenant_id", "patient_profile_id", "scheduled_start_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_procedure_case_diagnoses_procedure_case_id" ON "procedures_perioperative"."procedure_case_diagnoses" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_diagnoses_condition_id" ON "procedures_perioperative"."procedure_case_diagnoses" ("condition_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_diagnoses_diagnosis_role_concept_id" ON "procedures_perioperative"."procedure_case_diagnoses" ("diagnosis_role_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_case_diagnoses_case_sequence" ON "procedures_perioperative"."procedure_case_diagnoses" ("procedure_case_id", "sequence_number");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_team_members_procedure_case_id" ON "procedures_perioperative"."procedure_case_team_members" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_team_members_practitioner_profile_id" ON "procedures_perioperative"."procedure_case_team_members" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_team_members_team_role_concept_id" ON "procedures_perioperative"."procedure_case_team_members" ("team_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_team_members_status_concept_id" ON "procedures_perioperative"."procedure_case_team_members" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_team_members_created_by_user_id" ON "procedures_perioperative"."procedure_case_team_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_team_members_updated_by_user_id" ON "procedures_perioperative"."procedure_case_team_members" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_case_team_member_role" ON "procedures_perioperative"."procedure_case_team_members" ("procedure_case_id", "practitioner_profile_id", "team_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_locations_procedure_case_id" ON "procedures_perioperative"."procedure_case_locations" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_locations_care_space_id" ON "procedures_perioperative"."procedure_case_locations" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_locations_location_role_concept_id" ON "procedures_perioperative"."procedure_case_locations" ("location_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_locations_transfer_reason_concept_id" ON "procedures_perioperative"."procedure_case_locations" ("transfer_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_procedure_case_locations_created_at" ON "procedures_perioperative"."procedure_case_locations" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "gist_procedure_case_locations_case_range" ON "procedures_perioperative"."procedure_case_locations" USING gist ("procedure_case_id", tstzrange(starts_at, ends_at, '[)'));

CREATE INDEX IF NOT EXISTS "ix_procedure_case_status_history_procedure_case_id" ON "procedures_perioperative"."procedure_case_status_history" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_status_history_from_status_concept_id" ON "procedures_perioperative"."procedure_case_status_history" ("from_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_status_history_to_status_concept_id" ON "procedures_perioperative"."procedure_case_status_history" ("to_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_status_history_changed_by_user_id" ON "procedures_perioperative"."procedure_case_status_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_status_history_reason_concept_id" ON "procedures_perioperative"."procedure_case_status_history" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_status_history_workflow_transition_id" ON "procedures_perioperative"."procedure_case_status_history" ("workflow_transition_id");

CREATE INDEX IF NOT EXISTS "brin_procedure_case_status_history_created_at" ON "procedures_perioperative"."procedure_case_status_history" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_procedure_case_milestones_procedure_case_id" ON "procedures_perioperative"."procedure_case_milestones" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_milestones_milestone_type_concept_id" ON "procedures_perioperative"."procedure_case_milestones" ("milestone_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_milestones_status_concept_id" ON "procedures_perioperative"."procedure_case_milestones" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_case_milestones_recorded_by_profile_id" ON "procedures_perioperative"."procedure_case_milestones" ("recorded_by_profile_id");

CREATE INDEX IF NOT EXISTS "brin_procedure_case_milestones_occurred_at" ON "procedures_perioperative"."procedure_case_milestones" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_case_milestones_case_type" ON "procedures_perioperative"."procedure_case_milestones" ("procedure_case_id", "milestone_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_procedure_case_id" ON "procedures_perioperative"."preoperative_assessments" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_assessment_type_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("assessment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_assessed_by_profile_id" ON "procedures_perioperative"."preoperative_assessments" ("assessed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_fitness_status_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("fitness_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_asa_class_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("asa_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_airway_class_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("airway_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_bleeding_risk_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("bleeding_risk_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_infection_risk_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("infection_risk_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_nutrition_risk_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("nutrition_risk_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_pregnancy_status_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("pregnancy_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_status_concept_id" ON "procedures_perioperative"."preoperative_assessments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_created_by_user_id" ON "procedures_perioperative"."preoperative_assessments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_assessments_updated_by_user_id" ON "procedures_perioperative"."preoperative_assessments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_risk_scores_preoperative_assessment_id" ON "procedures_perioperative"."preoperative_risk_scores" ("preoperative_assessment_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_risk_scores_risk_model_concept_id" ON "procedures_perioperative"."preoperative_risk_scores" ("risk_model_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_risk_scores_risk_category_concept_id" ON "procedures_perioperative"."preoperative_risk_scores" ("risk_category_concept_id");

CREATE INDEX IF NOT EXISTS "brin_preoperative_risk_scores_created_at" ON "procedures_perioperative"."preoperative_risk_scores" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_preoperative_risk_scores_assessment_model" ON "procedures_perioperative"."preoperative_risk_scores" ("preoperative_assessment_id", "risk_model_concept_id", "model_version");

CREATE INDEX IF NOT EXISTS "ix_preoperative_orders_procedure_case_id" ON "procedures_perioperative"."preoperative_orders" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_orders_service_request_id" ON "procedures_perioperative"."preoperative_orders" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_orders_order_role_concept_id" ON "procedures_perioperative"."preoperative_orders" ("order_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_orders_required_before_milestone_concept_id" ON "procedures_perioperative"."preoperative_orders" ("required_before_milestone_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_orders_status_concept_id" ON "procedures_perioperative"."preoperative_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_preoperative_orders_verified_by_profile_id" ON "procedures_perioperative"."preoperative_orders" ("verified_by_profile_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_preoperative_orders_case_request" ON "procedures_perioperative"."preoperative_orders" ("procedure_case_id", "service_request_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_checklists_procedure_case_id" ON "procedures_perioperative"."surgical_safety_checklists" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_checklists_checklist_type_concept_id" ON "procedures_perioperative"."surgical_safety_checklists" ("checklist_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_checklists_status_concept_id" ON "procedures_perioperative"."surgical_safety_checklists" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_checklists_coordinator_profile_id" ON "procedures_perioperative"."surgical_safety_checklists" ("coordinator_profile_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_surgical_safety_checklists_case_type_version" ON "procedures_perioperative"."surgical_safety_checklists" ("procedure_case_id", "checklist_type_concept_id", "checklist_version");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_items_checklist_type_concept_id" ON "procedures_perioperative"."surgical_safety_items" ("checklist_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_items_phase_concept_id" ON "procedures_perioperative"."surgical_safety_items" ("phase_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_items_response_type_concept_id" ON "procedures_perioperative"."surgical_safety_items" ("response_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_items_state_concept_id" ON "procedures_perioperative"."surgical_safety_items" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_items_created_by_user_id" ON "procedures_perioperative"."surgical_safety_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_items_updated_by_user_id" ON "procedures_perioperative"."surgical_safety_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_surgical_safety_items_version_code" ON "procedures_perioperative"."surgical_safety_items" ("checklist_type_concept_id", "checklist_version", "item_code");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_responses_surgical_safety_checklist_id" ON "procedures_perioperative"."surgical_safety_responses" ("surgical_safety_checklist_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_responses_surgical_safety_item_id" ON "procedures_perioperative"."surgical_safety_responses" ("surgical_safety_item_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_responses_response_status_concept_id" ON "procedures_perioperative"."surgical_safety_responses" ("response_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_responses_response_concept_id" ON "procedures_perioperative"."surgical_safety_responses" ("response_concept_id");

CREATE INDEX IF NOT EXISTS "ix_surgical_safety_responses_responded_by_profile_id" ON "procedures_perioperative"."surgical_safety_responses" ("responded_by_profile_id");

CREATE INDEX IF NOT EXISTS "brin_surgical_safety_responses_created_at" ON "procedures_perioperative"."surgical_safety_responses" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_surgical_safety_responses_checklist_item" ON "procedures_perioperative"."surgical_safety_responses" ("surgical_safety_checklist_id", "surgical_safety_item_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_procedure_case_id" ON "procedures_perioperative"."anesthesia_plans" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_anesthesiologist_profile_id" ON "procedures_perioperative"."anesthesia_plans" ("anesthesiologist_profile_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_anesthesia_type_concept_id" ON "procedures_perioperative"."anesthesia_plans" ("anesthesia_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_technique_concept_id" ON "procedures_perioperative"."anesthesia_plans" ("technique_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_airway_plan_concept_id" ON "procedures_perioperative"."anesthesia_plans" ("airway_plan_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_status_concept_id" ON "procedures_perioperative"."anesthesia_plans" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_created_by_user_id" ON "procedures_perioperative"."anesthesia_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_plans_updated_by_user_id" ON "procedures_perioperative"."anesthesia_plans" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_airway_assessments_anesthesia_plan_id" ON "procedures_perioperative"."anesthesia_airway_assessments" ("anesthesia_plan_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_airway_assessments_assessed_by_profile_id" ON "procedures_perioperative"."anesthesia_airway_assessments" ("assessed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_airway_assessments_mallampati_concept_id" ON "procedures_perioperative"."anesthesia_airway_assessments" ("mallampati_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_airway_assessments_neck_mobility_concept_id" ON "procedures_perioperative"."anesthesia_airway_assessments" ("neck_mobility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_airway_assessments_dentition_status_concept_id" ON "procedures_perioperative"."anesthesia_airway_assessments" ("dentition_status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_anesthesia_airway_assessments_created_at" ON "procedures_perioperative"."anesthesia_airway_assessments" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_procedure_case_id" ON "procedures_perioperative"."anesthesia_events" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_anesthesia_plan_id" ON "procedures_perioperative"."anesthesia_events" ("anesthesia_plan_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_event_type_concept_id" ON "procedures_perioperative"."anesthesia_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_medication_administration_id" ON "procedures_perioperative"."anesthesia_events" ("medication_administration_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_observation_id" ON "procedures_perioperative"."anesthesia_events" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_device_id" ON "procedures_perioperative"."anesthesia_events" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_performed_by_profile_id" ON "procedures_perioperative"."anesthesia_events" ("performed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_severity_concept_id" ON "procedures_perioperative"."anesthesia_events" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "brin_anesthesia_events_occurred_at" ON "procedures_perioperative"."anesthesia_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_anesthesia_events_case_time" ON "procedures_perioperative"."anesthesia_events" ("procedure_case_id", "occurred_at");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_procedure_case_id" ON "procedures_perioperative"."operative_steps" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_procedure_id" ON "procedures_perioperative"."operative_steps" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_step_code_concept_id" ON "procedures_perioperative"."operative_steps" ("step_code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_performed_by_profile_id" ON "procedures_perioperative"."operative_steps" ("performed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_body_site_concept_id" ON "procedures_perioperative"."operative_steps" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_laterality_concept_id" ON "procedures_perioperative"."operative_steps" ("laterality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_technique_concept_id" ON "procedures_perioperative"."operative_steps" ("technique_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_status_concept_id" ON "procedures_perioperative"."operative_steps" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_created_by_user_id" ON "procedures_perioperative"."operative_steps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operative_steps_updated_by_user_id" ON "procedures_perioperative"."operative_steps" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_operative_steps_case_step" ON "procedures_perioperative"."operative_steps" ("procedure_case_id", "step_number");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_procedure_case_id" ON "procedures_perioperative"."operative_findings" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_operative_step_id" ON "procedures_perioperative"."operative_findings" ("operative_step_id");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_finding_code_concept_id" ON "procedures_perioperative"."operative_findings" ("finding_code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_body_site_concept_id" ON "procedures_perioperative"."operative_findings" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_laterality_concept_id" ON "procedures_perioperative"."operative_findings" ("laterality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_severity_concept_id" ON "procedures_perioperative"."operative_findings" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_observation_id" ON "procedures_perioperative"."operative_findings" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_operative_findings_recorded_by_profile_id" ON "procedures_perioperative"."operative_findings" ("recorded_by_profile_id");

CREATE INDEX IF NOT EXISTS "brin_operative_findings_recorded_at" ON "procedures_perioperative"."operative_findings" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_procedure_body_sites_procedure_id" ON "procedures_perioperative"."procedure_body_sites" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_body_sites_body_site_concept_id" ON "procedures_perioperative"."procedure_body_sites" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_body_sites_laterality_concept_id" ON "procedures_perioperative"."procedure_body_sites" ("laterality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_body_sites_role_concept_id" ON "procedures_perioperative"."procedure_body_sites" ("role_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_body_sites_procedure_site_role" ON "procedures_perioperative"."procedure_body_sites" ("procedure_id", "body_site_concept_id", "laterality_concept_id", "role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_performers_procedure_id" ON "procedures_perioperative"."procedure_performers" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_performers_practitioner_profile_id" ON "procedures_perioperative"."procedure_performers" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_performers_performer_role_concept_id" ON "procedures_perioperative"."procedure_performers" ("performer_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_performers_organization_id" ON "procedures_perioperative"."procedure_performers" ("organization_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_performers_procedure_practitioner_role" ON "procedures_perioperative"."procedure_performers" ("procedure_id", "practitioner_profile_id", "performer_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_devices_procedure_id" ON "procedures_perioperative"."procedure_devices" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_devices_device_id" ON "procedures_perioperative"."procedure_devices" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_devices_use_role_concept_id" ON "procedures_perioperative"."procedure_devices" ("use_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_devices_status_concept_id" ON "procedures_perioperative"."procedure_devices" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_devices_device" ON "procedures_perioperative"."procedure_devices" ("device_id", "used_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_procedure_case_id" ON "procedures_perioperative"."procedure_implants" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_procedure_id" ON "procedures_perioperative"."procedure_implants" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_implant_device_id" ON "procedures_perioperative"."procedure_implants" ("implant_device_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_implant_role_concept_id" ON "procedures_perioperative"."procedure_implants" ("implant_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_body_site_concept_id" ON "procedures_perioperative"."procedure_implants" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_laterality_concept_id" ON "procedures_perioperative"."procedure_implants" ("laterality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_explant_reason_concept_id" ON "procedures_perioperative"."procedure_implants" ("explant_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_status_concept_id" ON "procedures_perioperative"."procedure_implants" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_created_by_user_id" ON "procedures_perioperative"."procedure_implants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_implants_updated_by_user_id" ON "procedures_perioperative"."procedure_implants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_implant_identifiers_procedure_implant_id" ON "procedures_perioperative"."implant_identifiers" ("procedure_implant_id");

CREATE INDEX IF NOT EXISTS "ix_implant_identifiers_identifier_type_concept_id" ON "procedures_perioperative"."implant_identifiers" ("identifier_type_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_implant_identifiers_type_value" ON "procedures_perioperative"."implant_identifiers" ("identifier_type_concept_id", "identifier_value");

CREATE INDEX IF NOT EXISTS "ix_procedure_medication_uses_procedure_case_id" ON "procedures_perioperative"."procedure_medication_uses" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_medication_uses_procedure_id" ON "procedures_perioperative"."procedure_medication_uses" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_medication_uses_medication_administration_id" ON "procedures_perioperative"."procedure_medication_uses" ("medication_administration_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_medication_uses_use_role_concept_id" ON "procedures_perioperative"."procedure_medication_uses" ("use_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_medication_uses_operative_step_id" ON "procedures_perioperative"."procedure_medication_uses" ("operative_step_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_medication_uses_case_admin_role" ON "procedures_perioperative"."procedure_medication_uses" ("procedure_case_id", "medication_administration_id", "use_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_specimens_procedure_case_id" ON "procedures_perioperative"."procedure_specimens" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_specimens_procedure_id" ON "procedures_perioperative"."procedure_specimens" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_specimens_specimen_id" ON "procedures_perioperative"."procedure_specimens" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_specimens_specimen_role_concept_id" ON "procedures_perioperative"."procedure_specimens" ("specimen_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_specimens_operative_step_id" ON "procedures_perioperative"."procedure_specimens" ("operative_step_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_specimens_body_site_concept_id" ON "procedures_perioperative"."procedure_specimens" ("body_site_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_procedure_specimens_case_specimen" ON "procedures_perioperative"."procedure_specimens" ("procedure_case_id", "specimen_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_procedure_case_id" ON "procedures_perioperative"."procedure_complications" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_procedure_id" ON "procedures_perioperative"."procedure_complications" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_complication_code_concept_id" ON "procedures_perioperative"."procedure_complications" ("complication_code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_severity_concept_id" ON "procedures_perioperative"."procedure_complications" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_relatedness_concept_id" ON "procedures_perioperative"."procedure_complications" ("relatedness_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_condition_id" ON "procedures_perioperative"."procedure_complications" ("condition_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_outcome_concept_id" ON "procedures_perioperative"."procedure_complications" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_complications_reported_by_profile_id" ON "procedures_perioperative"."procedure_complications" ("reported_by_profile_id");

CREATE INDEX IF NOT EXISTS "brin_procedure_complications_created_at" ON "procedures_perioperative"."procedure_complications" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_operative_reports_procedure_case_id" ON "procedures_perioperative"."operative_reports" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_operative_reports_procedure_id" ON "procedures_perioperative"."operative_reports" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_operative_reports_author_profile_id" ON "procedures_perioperative"."operative_reports" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_operative_reports_disposition_concept_id" ON "procedures_perioperative"."operative_reports" ("disposition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_reports_file_id" ON "procedures_perioperative"."operative_reports" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_operative_reports_status_concept_id" ON "procedures_perioperative"."operative_reports" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operative_reports_signature_id" ON "procedures_perioperative"."operative_reports" ("signature_id");

CREATE INDEX IF NOT EXISTS "brin_operative_reports_created_at" ON "procedures_perioperative"."operative_reports" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_operative_reports_case_version" ON "procedures_perioperative"."operative_reports" ("procedure_case_id", "report_version");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_procedure_case_id" ON "procedures_perioperative"."pacu_stays" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_care_space_id" ON "procedures_perioperative"."pacu_stays" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_admitted_by_profile_id" ON "procedures_perioperative"."pacu_stays" ("admitted_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_discharged_by_profile_id" ON "procedures_perioperative"."pacu_stays" ("discharged_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_status_concept_id" ON "procedures_perioperative"."pacu_stays" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_discharge_destination_concept_id" ON "procedures_perioperative"."pacu_stays" ("discharge_destination_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_created_by_user_id" ON "procedures_perioperative"."pacu_stays" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_stays_updated_by_user_id" ON "procedures_perioperative"."pacu_stays" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_pacu_stays_case" ON "procedures_perioperative"."pacu_stays" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_assessments_pacu_stay_id" ON "procedures_perioperative"."pacu_assessments" ("pacu_stay_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_assessments_assessed_by_profile_id" ON "procedures_perioperative"."pacu_assessments" ("assessed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_assessments_sedation_score_concept_id" ON "procedures_perioperative"."pacu_assessments" ("sedation_score_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pacu_assessments_airway_status_concept_id" ON "procedures_perioperative"."pacu_assessments" ("airway_status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_pacu_assessments_created_at" ON "procedures_perioperative"."pacu_assessments" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_postoperative_orders_procedure_case_id" ON "procedures_perioperative"."postoperative_orders" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_orders_service_request_id" ON "procedures_perioperative"."postoperative_orders" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_orders_order_role_concept_id" ON "procedures_perioperative"."postoperative_orders" ("order_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_orders_status_concept_id" ON "procedures_perioperative"."postoperative_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_orders_verified_by_profile_id" ON "procedures_perioperative"."postoperative_orders" ("verified_by_profile_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_postoperative_orders_case_request" ON "procedures_perioperative"."postoperative_orders" ("procedure_case_id", "service_request_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_procedure_case_id" ON "procedures_perioperative"."postoperative_followups" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_followup_type_concept_id" ON "procedures_perioperative"."postoperative_followups" ("followup_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_appointment_id" ON "procedures_perioperative"."postoperative_followups" ("appointment_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_completed_by_profile_id" ON "procedures_perioperative"."postoperative_followups" ("completed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_status_concept_id" ON "procedures_perioperative"."postoperative_followups" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_wound_status_concept_id" ON "procedures_perioperative"."postoperative_followups" ("wound_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_created_by_user_id" ON "procedures_perioperative"."postoperative_followups" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_postoperative_followups_updated_by_user_id" ON "procedures_perioperative"."postoperative_followups" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_outcomes_procedure_case_id" ON "procedures_perioperative"."procedure_outcomes" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_outcomes_outcome_type_concept_id" ON "procedures_perioperative"."procedure_outcomes" ("outcome_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_outcomes_observation_id" ON "procedures_perioperative"."procedure_outcomes" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_outcomes_outcome_concept_id" ON "procedures_perioperative"."procedure_outcomes" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_outcomes_unit_concept_id" ON "procedures_perioperative"."procedure_outcomes" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "brin_procedure_outcomes_created_at" ON "procedures_perioperative"."procedure_outcomes" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_procedure_cancellations_procedure_case_id" ON "procedures_perioperative"."procedure_cancellations" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cancellations_cancellation_reason_concept_id" ON "procedures_perioperative"."procedure_cancellations" ("cancellation_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cancellations_cancellation_category_concept_id" ON "procedures_perioperative"."procedure_cancellations" ("cancellation_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cancellations_cancelled_by_user_id" ON "procedures_perioperative"."procedure_cancellations" ("cancelled_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cancellations_preventable_concept_id" ON "procedures_perioperative"."procedure_cancellations" ("preventable_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cancellations_replacement_case_id" ON "procedures_perioperative"."procedure_cancellations" ("replacement_case_id");

CREATE INDEX IF NOT EXISTS "brin_procedure_cancellations_created_at" ON "procedures_perioperative"."procedure_cancellations" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_procedure_case_id" ON "procedures_perioperative"."procedure_charge_items" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_procedure_id" ON "procedures_perioperative"."procedure_charge_items" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_charge_item_type_concept_id" ON "procedures_perioperative"."procedure_charge_items" ("charge_item_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_billable_item_id" ON "procedures_perioperative"."procedure_charge_items" ("billable_item_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_billing_claim_line_id" ON "procedures_perioperative"."procedure_charge_items" ("billing_claim_line_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_invoice_line_id" ON "procedures_perioperative"."procedure_charge_items" ("invoice_line_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_status_concept_id" ON "procedures_perioperative"."procedure_charge_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_created_by_user_id" ON "procedures_perioperative"."procedure_charge_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_charge_items_updated_by_user_id" ON "procedures_perioperative"."procedure_charge_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_operating_room_id" ON "procedures_perioperative"."operating_room_utilization_events" ("operating_room_id");

CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_procedure_case_id" ON "procedures_perioperative"."operating_room_utilization_events" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_event_type_concept_id" ON "procedures_perioperative"."operating_room_utilization_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_delay_reason_concept_id" ON "procedures_perioperative"."operating_room_utilization_events" ("delay_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_turnover_category_21fa0c9f" ON "procedures_perioperative"."operating_room_utilization_events" ("turnover_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_recorded_by_user_id" ON "procedures_perioperative"."operating_room_utilization_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_operating_room_utilization_events_occurred_at" ON "procedures_perioperative"."operating_room_utilization_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_or_utilization_room_time" ON "procedures_perioperative"."operating_room_utilization_events" ("operating_room_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_sterility_verification_checks_procedure_case_id" ON "procedures_perioperative"."sterility_verification_checks" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_sterility_verification_checks_check_type_concept_id" ON "procedures_perioperative"."sterility_verification_checks" ("check_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sterility_verification_checks_checked_by_profile_id" ON "procedures_perioperative"."sterility_verification_checks" ("checked_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_sterility_verification_checks_result_concept_id" ON "procedures_perioperative"."sterility_verification_checks" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sterility_verification_checks_sterilization_load_id" ON "procedures_perioperative"."sterility_verification_checks" ("sterilization_load_id");

CREATE INDEX IF NOT EXISTS "ix_sterility_verification_checks_instrument_set_id" ON "procedures_perioperative"."sterility_verification_checks" ("instrument_set_id");

CREATE INDEX IF NOT EXISTS "brin_sterility_verification_checks_created_at" ON "procedures_perioperative"."sterility_verification_checks" USING brin ("created_at") WITH (pages_per_range=128);
