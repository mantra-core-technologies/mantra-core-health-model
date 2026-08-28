-- SALUD v4.0.10 · módulo 53 · schema procedures_perioperative
-- Generado de diagram_53_procedures_perioperative.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_diagnoses"
        ADD CONSTRAINT "fk_procedure_case_diagnoses_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_team_members"
        ADD CONSTRAINT "fk_procedure_case_team_members_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_locations"
        ADD CONSTRAINT "fk_procedure_case_locations_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_status_history"
        ADD CONSTRAINT "fk_procedure_case_status_history_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_case_milestones"
        ADD CONSTRAINT "fk_procedure_case_milestones_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_assessments"
        ADD CONSTRAINT "fk_preoperative_assessments_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_risk_scores"
        ADD CONSTRAINT "fk_preoperative_risk_scores_preoperative_assessment_id" FOREIGN KEY ("preoperative_assessment_id")
        REFERENCES "procedures_perioperative"."preoperative_assessments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."preoperative_orders"
        ADD CONSTRAINT "fk_preoperative_orders_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_checklists"
        ADD CONSTRAINT "fk_surgical_safety_checklists_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_responses"
        ADD CONSTRAINT "fk_surgical_safety_responses_surgical_safety_checklist_id" FOREIGN KEY ("surgical_safety_checklist_id")
        REFERENCES "procedures_perioperative"."surgical_safety_checklists" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_responses"
        ADD CONSTRAINT "fk_surgical_safety_responses_surgical_safety_item_id" FOREIGN KEY ("surgical_safety_item_id")
        REFERENCES "procedures_perioperative"."surgical_safety_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_plans"
        ADD CONSTRAINT "fk_anesthesia_plans_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_airway_assessments"
        ADD CONSTRAINT "fk_anesthesia_airway_assessments_anesthesia_plan_id" FOREIGN KEY ("anesthesia_plan_id")
        REFERENCES "procedures_perioperative"."anesthesia_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."anesthesia_events"
        ADD CONSTRAINT "fk_anesthesia_events_anesthesia_plan_id" FOREIGN KEY ("anesthesia_plan_id")
        REFERENCES "procedures_perioperative"."anesthesia_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_steps"
        ADD CONSTRAINT "fk_operative_steps_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_findings"
        ADD CONSTRAINT "fk_operative_findings_operative_step_id" FOREIGN KEY ("operative_step_id")
        REFERENCES "procedures_perioperative"."operative_steps" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_implants"
        ADD CONSTRAINT "fk_procedure_implants_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."implant_identifiers"
        ADD CONSTRAINT "fk_implant_identifiers_procedure_implant_id" FOREIGN KEY ("procedure_implant_id")
        REFERENCES "procedures_perioperative"."procedure_implants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_medication_uses"
        ADD CONSTRAINT "fk_procedure_medication_uses_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_medication_uses"
        ADD CONSTRAINT "fk_procedure_medication_uses_operative_step_id" FOREIGN KEY ("operative_step_id")
        REFERENCES "procedures_perioperative"."operative_steps" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_specimens"
        ADD CONSTRAINT "fk_procedure_specimens_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_specimens"
        ADD CONSTRAINT "fk_procedure_specimens_operative_step_id" FOREIGN KEY ("operative_step_id")
        REFERENCES "procedures_perioperative"."operative_steps" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_complications"
        ADD CONSTRAINT "fk_procedure_complications_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operative_reports"
        ADD CONSTRAINT "fk_operative_reports_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_stays"
        ADD CONSTRAINT "fk_pacu_stays_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."pacu_assessments"
        ADD CONSTRAINT "fk_pacu_assessments_pacu_stay_id" FOREIGN KEY ("pacu_stay_id")
        REFERENCES "procedures_perioperative"."pacu_stays" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_orders"
        ADD CONSTRAINT "fk_postoperative_orders_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."postoperative_followups"
        ADD CONSTRAINT "fk_postoperative_followups_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_outcomes"
        ADD CONSTRAINT "fk_procedure_outcomes_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cancellations"
        ADD CONSTRAINT "fk_procedure_cancellations_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cancellations"
        ADD CONSTRAINT "fk_procedure_cancellations_replacement_case_id" FOREIGN KEY ("replacement_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_charge_items"
        ADD CONSTRAINT "fk_procedure_charge_items_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."sterility_verification_checks"
        ADD CONSTRAINT "fk_sterility_verification_checks_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
