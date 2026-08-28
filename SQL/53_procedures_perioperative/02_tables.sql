-- SALUD v4.0.10 · módulo 53 · schema procedures_perioperative
-- Generado de diagram_53_procedures_perioperative.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_cases" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "service_request_id" uuid,
    "primary_procedure_id" uuid,
    "case_number" varchar NOT NULL,
    "case_type_concept_id" uuid NOT NULL,
    "priority_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "surgical_specialty_concept_id" uuid,
    "requested_by_profile_id" uuid,
    "primary_surgeon_profile_id" uuid,
    "anesthesiologist_profile_id" uuid,
    "practice_site_id" uuid,
    "operating_room_id" uuid,
    "scheduled_start_at" timestamptz,
    "scheduled_end_at" timestamptz,
    "actual_start_at" timestamptz,
    "actual_end_at" timestamptz,
    "cancellation_reason_concept_id" uuid,
    "urgency_reason_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_procedure_cases" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_case_diagnoses" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "condition_id" uuid NOT NULL,
    "diagnosis_role_concept_id" uuid NOT NULL,
    "sequence_number" integer NOT NULL,
    "present_on_admission" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_case_diagnoses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_case_team_members" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "team_role_concept_id" uuid NOT NULL,
    "assigned_at" timestamptz,
    "accepted_at" timestamptz,
    "arrived_at" timestamptz,
    "departed_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_procedure_case_team_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_case_locations" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "location_role_concept_id" uuid NOT NULL,
    "starts_at" timestamptz NOT NULL,
    "ends_at" timestamptz,
    "transfer_reason_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_case_locations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_case_status_history" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "from_status_concept_id" uuid NOT NULL,
    "to_status_concept_id" uuid NOT NULL,
    "changed_at" timestamptz NOT NULL,
    "changed_by_user_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "reason_text" text,
    "workflow_transition_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_case_status_history" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_case_milestones" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "milestone_type_concept_id" uuid NOT NULL,
    "planned_at" timestamptz,
    "occurred_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "recorded_by_profile_id" uuid,
    "notes" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_case_milestones" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."preoperative_assessments" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "assessment_type_concept_id" uuid NOT NULL,
    "assessed_by_profile_id" uuid NOT NULL,
    "assessed_at" timestamptz NOT NULL,
    "fitness_status_concept_id" uuid NOT NULL,
    "asa_class_concept_id" uuid,
    "airway_class_concept_id" uuid,
    "bleeding_risk_concept_id" uuid,
    "infection_risk_concept_id" uuid,
    "nutrition_risk_concept_id" uuid,
    "pregnancy_status_concept_id" uuid,
    "allergies_reviewed" boolean,
    "medications_reviewed" boolean,
    "anticoagulation_plan_text" text,
    "fasting_instructions_text" text,
    "assessment_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_preoperative_assessments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."preoperative_risk_scores" (
    "id" uuid NOT NULL,
    "preoperative_assessment_id" uuid NOT NULL,
    "risk_model_concept_id" uuid NOT NULL,
    "model_version" varchar NOT NULL,
    "score_value" numeric(12,6) NOT NULL,
    "risk_category_concept_id" uuid,
    "inputs_json" jsonb,
    "interpretation_text" text,
    "calculated_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_preoperative_risk_scores" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."preoperative_orders" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "service_request_id" uuid NOT NULL,
    "order_role_concept_id" uuid NOT NULL,
    "required_before_milestone_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "verified_at" timestamptz,
    "verified_by_profile_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_preoperative_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."surgical_safety_checklists" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "checklist_type_concept_id" uuid NOT NULL,
    "checklist_version" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "sign_in_completed_at" timestamptz,
    "time_out_completed_at" timestamptz,
    "sign_out_completed_at" timestamptz,
    "coordinator_profile_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_surgical_safety_checklists" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."surgical_safety_items" (
    "id" uuid NOT NULL,
    "checklist_type_concept_id" uuid NOT NULL,
    "checklist_version" varchar NOT NULL,
    "phase_concept_id" uuid NOT NULL,
    "item_code" varchar NOT NULL,
    "prompt_text" text NOT NULL,
    "response_type_concept_id" uuid NOT NULL,
    "display_order" integer NOT NULL,
    "is_mandatory" boolean NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_surgical_safety_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."surgical_safety_responses" (
    "id" uuid NOT NULL,
    "surgical_safety_checklist_id" uuid NOT NULL,
    "surgical_safety_item_id" uuid NOT NULL,
    "response_status_concept_id" uuid NOT NULL,
    "response_boolean" boolean,
    "response_text" text,
    "response_concept_id" uuid,
    "responded_by_profile_id" uuid,
    "responded_at" timestamptz NOT NULL,
    "exception_reason" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_surgical_safety_responses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."anesthesia_plans" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "anesthesiologist_profile_id" uuid NOT NULL,
    "anesthesia_type_concept_id" uuid NOT NULL,
    "technique_concept_id" uuid,
    "airway_plan_concept_id" uuid,
    "monitoring_plan_json" jsonb,
    "medications_plan_json" jsonb,
    "fluids_plan_json" jsonb,
    "blood_products_plan_json" jsonb,
    "postoperative_analgesia_plan_text" text,
    "status_concept_id" uuid NOT NULL,
    "approved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_anesthesia_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."anesthesia_airway_assessments" (
    "id" uuid NOT NULL,
    "anesthesia_plan_id" uuid NOT NULL,
    "assessed_at" timestamptz NOT NULL,
    "assessed_by_profile_id" uuid NOT NULL,
    "mallampati_concept_id" uuid,
    "mouth_opening_mm" numeric(8,2),
    "thyromental_distance_mm" numeric(8,2),
    "neck_mobility_concept_id" uuid,
    "dentition_status_concept_id" uuid,
    "difficult_airway_expected" boolean,
    "rescue_plan_text" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_anesthesia_airway_assessments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."anesthesia_events" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "anesthesia_plan_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "medication_administration_id" uuid,
    "observation_id" uuid,
    "device_id" uuid,
    "performed_by_profile_id" uuid,
    "details_json" jsonb,
    "severity_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_anesthesia_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."operative_steps" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "procedure_id" uuid,
    "step_number" integer NOT NULL,
    "step_code_concept_id" uuid NOT NULL,
    "description" text NOT NULL,
    "performed_by_profile_id" uuid,
    "started_at" timestamptz,
    "ended_at" timestamptz,
    "body_site_concept_id" uuid,
    "laterality_concept_id" uuid,
    "technique_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operative_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."operative_findings" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "operative_step_id" uuid,
    "finding_code_concept_id" uuid NOT NULL,
    "finding_text" text NOT NULL,
    "body_site_concept_id" uuid,
    "laterality_concept_id" uuid,
    "severity_concept_id" uuid,
    "observation_id" uuid,
    "recorded_by_profile_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_operative_findings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_body_sites" (
    "id" uuid NOT NULL,
    "procedure_id" uuid NOT NULL,
    "body_site_concept_id" uuid NOT NULL,
    "laterality_concept_id" uuid,
    "role_concept_id" uuid NOT NULL,
    "description" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_body_sites" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_performers" (
    "id" uuid NOT NULL,
    "procedure_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "performer_role_concept_id" uuid NOT NULL,
    "organization_id" uuid,
    "starts_at" timestamptz,
    "ends_at" timestamptz,
    "contribution_text" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_performers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_devices" (
    "id" uuid NOT NULL,
    "procedure_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "use_role_concept_id" uuid NOT NULL,
    "lot_number" varchar,
    "serial_number" varchar,
    "udi_carrier" varchar,
    "used_at" timestamptz,
    "removed_at" timestamptz,
    "status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_devices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_implants" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "procedure_id" uuid NOT NULL,
    "implant_device_id" uuid NOT NULL,
    "implant_role_concept_id" uuid NOT NULL,
    "body_site_concept_id" uuid,
    "laterality_concept_id" uuid,
    "implanted_at" timestamptz NOT NULL,
    "explanted_at" timestamptz,
    "explant_reason_concept_id" uuid,
    "status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_procedure_implants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."implant_identifiers" (
    "id" uuid NOT NULL,
    "procedure_implant_id" uuid NOT NULL,
    "identifier_type_concept_id" uuid NOT NULL,
    "identifier_value" varchar NOT NULL,
    "issuing_system" varchar,
    "lot_number" varchar,
    "serial_number" varchar,
    "expiration_date" date,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_implant_identifiers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_medication_uses" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "procedure_id" uuid,
    "medication_administration_id" uuid NOT NULL,
    "use_role_concept_id" uuid NOT NULL,
    "operative_step_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_medication_uses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_specimens" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "procedure_id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "specimen_role_concept_id" uuid NOT NULL,
    "operative_step_id" uuid,
    "body_site_concept_id" uuid,
    "orientation_text" text,
    "surgeon_comment" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_specimens" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_complications" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "procedure_id" uuid,
    "complication_code_concept_id" uuid NOT NULL,
    "onset_at" timestamptz NOT NULL,
    "resolved_at" timestamptz,
    "severity_concept_id" uuid NOT NULL,
    "relatedness_concept_id" uuid NOT NULL,
    "condition_id" uuid,
    "management_text" text,
    "outcome_concept_id" uuid,
    "reported_by_profile_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_complications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."operative_reports" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "procedure_id" uuid NOT NULL,
    "report_version" integer NOT NULL,
    "author_profile_id" uuid NOT NULL,
    "authored_at" timestamptz NOT NULL,
    "preoperative_diagnosis_text" text,
    "postoperative_diagnosis_text" text,
    "procedure_description" text,
    "findings_text" text,
    "estimated_blood_loss_ml" numeric(12,3),
    "drains_text" text,
    "complications_text" text,
    "disposition_concept_id" uuid,
    "file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "signed_at" timestamptz,
    "signature_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_operative_reports" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."pacu_stays" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "admitted_at" timestamptz NOT NULL,
    "discharged_at" timestamptz,
    "admitted_by_profile_id" uuid,
    "discharged_by_profile_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "discharge_destination_concept_id" uuid,
    "discharge_criteria_met" boolean,
    "notes" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pacu_stays" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."pacu_assessments" (
    "id" uuid NOT NULL,
    "pacu_stay_id" uuid NOT NULL,
    "assessed_at" timestamptz NOT NULL,
    "assessed_by_profile_id" uuid NOT NULL,
    "aldrete_score" integer,
    "pain_score" numeric(8,3),
    "nausea_score" numeric(8,3),
    "sedation_score_concept_id" uuid,
    "airway_status_concept_id" uuid,
    "observations_json" jsonb,
    "criteria_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_pacu_assessments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."postoperative_orders" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "service_request_id" uuid NOT NULL,
    "order_role_concept_id" uuid NOT NULL,
    "start_at" timestamptz,
    "stop_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "verified_by_profile_id" uuid,
    "verified_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_postoperative_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."postoperative_followups" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "followup_type_concept_id" uuid NOT NULL,
    "appointment_id" uuid,
    "due_at" timestamptz,
    "completed_at" timestamptz,
    "completed_by_profile_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "wound_status_concept_id" uuid,
    "pain_score" numeric(8,3),
    "complications_present" boolean,
    "instructions_text" text,
    "next_followup_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_postoperative_followups" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_outcomes" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "outcome_type_concept_id" uuid NOT NULL,
    "measured_at" timestamptz NOT NULL,
    "observation_id" uuid,
    "outcome_concept_id" uuid,
    "numeric_value" numeric(20,6),
    "unit_concept_id" uuid,
    "patient_reported" boolean,
    "instrument_code" varchar,
    "interpretation_text" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_outcomes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_cancellations" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "cancelled_at" timestamptz NOT NULL,
    "cancellation_reason_concept_id" uuid NOT NULL,
    "cancellation_category_concept_id" uuid,
    "cancelled_by_user_id" uuid,
    "preventable_concept_id" uuid,
    "explanation_text" text,
    "reschedule_required" boolean,
    "replacement_case_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_cancellations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."procedure_charge_items" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "procedure_id" uuid,
    "charge_item_type_concept_id" uuid NOT NULL,
    "billable_item_id" uuid NOT NULL,
    "quantity" numeric(20,6),
    "unit_price" numeric(20,6),
    "currency_code" char(3),
    "billing_claim_line_id" uuid,
    "invoice_line_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_procedure_charge_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."operating_room_utilization_events" (
    "id" uuid NOT NULL,
    "operating_room_id" uuid NOT NULL,
    "procedure_case_id" uuid,
    "event_type_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "duration_seconds" bigint,
    "delay_reason_concept_id" uuid,
    "turnover_category_concept_id" uuid,
    "recorded_by_user_id" uuid,
    "details_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_operating_room_utilization_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."sterility_verification_checks" (
    "id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "check_type_concept_id" uuid NOT NULL,
    "checked_at" timestamptz NOT NULL,
    "checked_by_profile_id" uuid NOT NULL,
    "result_concept_id" uuid NOT NULL,
    "sterilization_load_id" uuid,
    "instrument_set_id" uuid,
    "biological_indicator_reference" varchar,
    "chemical_indicator_reference" varchar,
    "exception_text" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_sterility_verification_checks" PRIMARY KEY ("id")
);
