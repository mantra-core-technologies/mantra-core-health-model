-- SALUD v4.0.10 · módulo 53 · schema procedures_perioperative
-- Generado de diagram_53_procedures_perioperative.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   procedure_performers.organization_id
--   sterility_verification_checks.sterilization_load_id
--   sterility_verification_checks.instrument_set_id


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_primary_procedure_id" FOREIGN KEY ("primary_procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_case_type_concept_id" FOREIGN KEY ("case_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_surgical_specialty_concept_id" FOREIGN KEY ("surgical_specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_requested_by_profile_id" FOREIGN KEY ("requested_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_primary_surgeon_profile_id" FOREIGN KEY ("primary_surgeon_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_anesthesiologist_profile_id" FOREIGN KEY ("anesthesiologist_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_operating_room_id" FOREIGN KEY ("operating_room_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_cancellation_reason_concept_id" FOREIGN KEY ("cancellation_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.conditions (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_diagnoses"
        ADD CONSTRAINT "fk_procedure_case_diagnoses_condition_id" FOREIGN KEY ("condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_diagnoses"
        ADD CONSTRAINT "fk_procedure_case_diagnoses_diagnosis_role_concept_id" FOREIGN KEY ("diagnosis_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_team_members"
        ADD CONSTRAINT "fk_procedure_case_team_members_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_team_members"
        ADD CONSTRAINT "fk_procedure_case_team_members_team_role_concept_id" FOREIGN KEY ("team_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_team_members"
        ADD CONSTRAINT "fk_procedure_case_team_members_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_team_members"
        ADD CONSTRAINT "fk_procedure_case_team_members_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_team_members"
        ADD CONSTRAINT "fk_procedure_case_team_members_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_locations"
        ADD CONSTRAINT "fk_procedure_case_locations_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_locations"
        ADD CONSTRAINT "fk_procedure_case_locations_location_role_concept_id" FOREIGN KEY ("location_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_locations"
        ADD CONSTRAINT "fk_procedure_case_locations_transfer_reason_concept_id" FOREIGN KEY ("transfer_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_status_history"
        ADD CONSTRAINT "fk_procedure_case_status_history_from_status_concept_id" FOREIGN KEY ("from_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_status_history"
        ADD CONSTRAINT "fk_procedure_case_status_history_to_status_concept_id" FOREIGN KEY ("to_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_status_history"
        ADD CONSTRAINT "fk_procedure_case_status_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_status_history"
        ADD CONSTRAINT "fk_procedure_case_status_history_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: workflow.state_transition_events (requiere schema workflow)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_status_history"
        ADD CONSTRAINT "fk_procedure_case_status_history_workflow_transition_id" FOREIGN KEY ("workflow_transition_id")
        REFERENCES "workflow"."state_transition_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_milestones"
        ADD CONSTRAINT "fk_procedure_case_milestones_milestone_type_concept_id" FOREIGN KEY ("milestone_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_milestones"
        ADD CONSTRAINT "fk_procedure_case_milestones_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_milestones"
        ADD CONSTRAINT "fk_procedure_case_milestones_recorded_by_profile_id" FOREIGN KEY ("recorded_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_assessment_type_concept_id" FOREIGN KEY ("assessment_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_assessed_by_profile_id" FOREIGN KEY ("assessed_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_fitness_status_concept_id" FOREIGN KEY ("fitness_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_asa_class_concept_id" FOREIGN KEY ("asa_class_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_airway_class_concept_id" FOREIGN KEY ("airway_class_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_bleeding_risk_concept_id" FOREIGN KEY ("bleeding_risk_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_infection_risk_concept_id" FOREIGN KEY ("infection_risk_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_nutrition_risk_concept_id" FOREIGN KEY ("nutrition_risk_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_pregnancy_status_concept_id" FOREIGN KEY ("pregnancy_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_risk_scores"
        ADD CONSTRAINT "fk_preoperative_risk_scores_risk_model_concept_id" FOREIGN KEY ("risk_model_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_risk_scores"
        ADD CONSTRAINT "fk_preoperative_risk_scores_risk_category_concept_id" FOREIGN KEY ("risk_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_orders"
        ADD CONSTRAINT "fk_preoperative_orders_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_orders"
        ADD CONSTRAINT "fk_preoperative_orders_order_role_concept_id" FOREIGN KEY ("order_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_orders"
        ADD CONSTRAINT "fk_preoperative_orders_required_before_milestone_concept_id" FOREIGN KEY ("required_before_milestone_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_orders"
        ADD CONSTRAINT "fk_preoperative_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_orders"
        ADD CONSTRAINT "fk_preoperative_orders_verified_by_profile_id" FOREIGN KEY ("verified_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_checklists"
        ADD CONSTRAINT "fk_surgical_safety_checklists_checklist_type_concept_id" FOREIGN KEY ("checklist_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_checklists"
        ADD CONSTRAINT "fk_surgical_safety_checklists_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_checklists"
        ADD CONSTRAINT "fk_surgical_safety_checklists_coordinator_profile_id" FOREIGN KEY ("coordinator_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_items"
        ADD CONSTRAINT "fk_surgical_safety_items_checklist_type_concept_id" FOREIGN KEY ("checklist_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_items"
        ADD CONSTRAINT "fk_surgical_safety_items_phase_concept_id" FOREIGN KEY ("phase_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_items"
        ADD CONSTRAINT "fk_surgical_safety_items_response_type_concept_id" FOREIGN KEY ("response_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_items"
        ADD CONSTRAINT "fk_surgical_safety_items_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_items"
        ADD CONSTRAINT "fk_surgical_safety_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_items"
        ADD CONSTRAINT "fk_surgical_safety_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_responses"
        ADD CONSTRAINT "fk_surgical_safety_responses_response_status_concept_id" FOREIGN KEY ("response_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_responses"
        ADD CONSTRAINT "fk_surgical_safety_responses_response_concept_id" FOREIGN KEY ("response_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_responses"
        ADD CONSTRAINT "fk_surgical_safety_responses_responded_by_profile_id" FOREIGN KEY ("responded_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_anesthesiologist_profile_id" FOREIGN KEY ("anesthesiologist_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_anesthesia_type_concept_id" FOREIGN KEY ("anesthesia_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_technique_concept_id" FOREIGN KEY ("technique_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_airway_plan_concept_id" FOREIGN KEY ("airway_plan_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_airway_assessments"
        ADD CONSTRAINT "fk_anesthesia_airway_assessments_assessed_by_profile_id" FOREIGN KEY ("assessed_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_airway_assessments"
        ADD CONSTRAINT "fk_anesthesia_airway_assessments_mallampati_concept_id" FOREIGN KEY ("mallampati_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_airway_assessments"
        ADD CONSTRAINT "fk_anesthesia_airway_assessments_neck_mobility_concept_id" FOREIGN KEY ("neck_mobility_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_airway_assessments"
        ADD CONSTRAINT "fk_anesthesia_airway_assessments_dentition_status_concept_id" FOREIGN KEY ("dentition_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.medication_records (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_medication_administration_id" FOREIGN KEY ("medication_administration_id")
        REFERENCES "clinical"."medication_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_device_id" FOREIGN KEY ("device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_performed_by_profile_id" FOREIGN KEY ("performed_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_step_code_concept_id" FOREIGN KEY ("step_code_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_performed_by_profile_id" FOREIGN KEY ("performed_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_laterality_concept_id" FOREIGN KEY ("laterality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_technique_concept_id" FOREIGN KEY ("technique_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_finding_code_concept_id" FOREIGN KEY ("finding_code_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_laterality_concept_id" FOREIGN KEY ("laterality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_recorded_by_profile_id" FOREIGN KEY ("recorded_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_body_sites"
        ADD CONSTRAINT "fk_procedure_body_sites_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_body_sites"
        ADD CONSTRAINT "fk_procedure_body_sites_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_body_sites"
        ADD CONSTRAINT "fk_procedure_body_sites_laterality_concept_id" FOREIGN KEY ("laterality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_body_sites"
        ADD CONSTRAINT "fk_procedure_body_sites_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_performers"
        ADD CONSTRAINT "fk_procedure_performers_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_performers"
        ADD CONSTRAINT "fk_procedure_performers_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_performers"
        ADD CONSTRAINT "fk_procedure_performers_performer_role_concept_id" FOREIGN KEY ("performer_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_devices"
        ADD CONSTRAINT "fk_procedure_devices_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_devices"
        ADD CONSTRAINT "fk_procedure_devices_device_id" FOREIGN KEY ("device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_devices"
        ADD CONSTRAINT "fk_procedure_devices_use_role_concept_id" FOREIGN KEY ("use_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_devices"
        ADD CONSTRAINT "fk_procedure_devices_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_implant_device_id" FOREIGN KEY ("implant_device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_implant_role_concept_id" FOREIGN KEY ("implant_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_laterality_concept_id" FOREIGN KEY ("laterality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_explant_reason_concept_id" FOREIGN KEY ("explant_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."implant_identifiers"
        ADD CONSTRAINT "fk_implant_identifiers_identifier_type_concept_id" FOREIGN KEY ("identifier_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_medication_uses"
        ADD CONSTRAINT "fk_procedure_medication_uses_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.medication_records (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_medication_uses"
        ADD CONSTRAINT "fk_procedure_medication_uses_medication_administration_id" FOREIGN KEY ("medication_administration_id")
        REFERENCES "clinical"."medication_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_medication_uses"
        ADD CONSTRAINT "fk_procedure_medication_uses_use_role_concept_id" FOREIGN KEY ("use_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_specimens"
        ADD CONSTRAINT "fk_procedure_specimens_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostics.specimens (requiere schema diagnostics)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_specimens"
        ADD CONSTRAINT "fk_procedure_specimens_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_specimens"
        ADD CONSTRAINT "fk_procedure_specimens_specimen_role_concept_id" FOREIGN KEY ("specimen_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_specimens"
        ADD CONSTRAINT "fk_procedure_specimens_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_complication_code_concept_id" FOREIGN KEY ("complication_code_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_relatedness_concept_id" FOREIGN KEY ("relatedness_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.conditions (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_condition_id" FOREIGN KEY ("condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_reported_by_profile_id" FOREIGN KEY ("reported_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_reports"
        ADD CONSTRAINT "fk_operative_reports_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_reports"
        ADD CONSTRAINT "fk_operative_reports_author_profile_id" FOREIGN KEY ("author_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_reports"
        ADD CONSTRAINT "fk_operative_reports_disposition_concept_id" FOREIGN KEY ("disposition_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_reports"
        ADD CONSTRAINT "fk_operative_reports_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_reports"
        ADD CONSTRAINT "fk_operative_reports_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: chart.clinical_note_signatures (requiere schema chart)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_reports"
        ADD CONSTRAINT "fk_operative_reports_signature_id" FOREIGN KEY ("signature_id")
        REFERENCES "chart"."clinical_note_signatures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_admitted_by_profile_id" FOREIGN KEY ("admitted_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_discharged_by_profile_id" FOREIGN KEY ("discharged_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_discharge_destination_concept_id" FOREIGN KEY ("discharge_destination_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_assessments"
        ADD CONSTRAINT "fk_pacu_assessments_assessed_by_profile_id" FOREIGN KEY ("assessed_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_assessments"
        ADD CONSTRAINT "fk_pacu_assessments_sedation_score_concept_id" FOREIGN KEY ("sedation_score_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_assessments"
        ADD CONSTRAINT "fk_pacu_assessments_airway_status_concept_id" FOREIGN KEY ("airway_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_orders"
        ADD CONSTRAINT "fk_postoperative_orders_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_orders"
        ADD CONSTRAINT "fk_postoperative_orders_order_role_concept_id" FOREIGN KEY ("order_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_orders"
        ADD CONSTRAINT "fk_postoperative_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_orders"
        ADD CONSTRAINT "fk_postoperative_orders_verified_by_profile_id" FOREIGN KEY ("verified_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_followup_type_concept_id" FOREIGN KEY ("followup_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.appointments (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_appointment_id" FOREIGN KEY ("appointment_id")
        REFERENCES "clinical"."appointments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_completed_by_profile_id" FOREIGN KEY ("completed_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_wound_status_concept_id" FOREIGN KEY ("wound_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_outcomes"
        ADD CONSTRAINT "fk_procedure_outcomes_outcome_type_concept_id" FOREIGN KEY ("outcome_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_outcomes"
        ADD CONSTRAINT "fk_procedure_outcomes_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_outcomes"
        ADD CONSTRAINT "fk_procedure_outcomes_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_outcomes"
        ADD CONSTRAINT "fk_procedure_outcomes_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cancellations"
        ADD CONSTRAINT "fk_procedure_cancellations_cancellation_reason_concept_id" FOREIGN KEY ("cancellation_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cancellations"
        ADD CONSTRAINT "fk_procedure_cancellations_cancellation_category_concept_id" FOREIGN KEY ("cancellation_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cancellations"
        ADD CONSTRAINT "fk_procedure_cancellations_cancelled_by_user_id" FOREIGN KEY ("cancelled_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cancellations"
        ADD CONSTRAINT "fk_procedure_cancellations_preventable_concept_id" FOREIGN KEY ("preventable_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_charge_item_type_concept_id" FOREIGN KEY ("charge_item_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.service_catalog (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_billable_item_id" FOREIGN KEY ("billable_item_id")
        REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.insurance_claim_lines (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_billing_claim_line_id" FOREIGN KEY ("billing_claim_line_id")
        REFERENCES "insurance"."insurance_claim_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoice_lines (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_invoice_line_id" FOREIGN KEY ("invoice_line_id")
        REFERENCES "billing"."invoice_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_operating_room_id" FOREIGN KEY ("operating_room_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_delay_reason_concept_id" FOREIGN KEY ("delay_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_turnover_category_c499a812" FOREIGN KEY ("turnover_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."sterility_verification_checks"
        ADD CONSTRAINT "fk_sterility_verification_checks_check_type_concept_id" FOREIGN KEY ("check_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."sterility_verification_checks"
        ADD CONSTRAINT "fk_sterility_verification_checks_checked_by_profile_id" FOREIGN KEY ("checked_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."sterility_verification_checks"
        ADD CONSTRAINT "fk_sterility_verification_checks_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
