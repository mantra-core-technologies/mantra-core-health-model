-- SALUD v4.0.10 · módulo 68 · schema qa_execution
-- Generado de diagram_68_qa_execution.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_plans"
        ADD CONSTRAINT "fk_execution_plans_target_id" FOREIGN KEY ("target_id")
        REFERENCES "qa_execution"."execution_targets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_execution"."plan_approvals"
        ADD CONSTRAINT "fk_plan_approvals_plan_id" FOREIGN KEY ("plan_id")
        REFERENCES "qa_execution"."execution_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_execution"."plan_events"
        ADD CONSTRAINT "fk_plan_events_plan_id" FOREIGN KEY ("plan_id")
        REFERENCES "qa_execution"."execution_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
