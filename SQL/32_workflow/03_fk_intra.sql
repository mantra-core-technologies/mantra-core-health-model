-- SALUD v4.0.10 · módulo 32 · schema workflow
-- Generado de diagram_32_workflow.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "workflow"."state_definitions"
        ADD CONSTRAINT "fk_state_definitions_state_machine_definition_id" FOREIGN KEY ("state_machine_definition_id")
        REFERENCES "workflow"."state_machine_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_state_machine_definition_id" FOREIGN KEY ("state_machine_definition_id")
        REFERENCES "workflow"."state_machine_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "workflow"."transition_guards"
        ADD CONSTRAINT "fk_transition_guards_state_transition_definition_id" FOREIGN KEY ("state_transition_definition_id")
        REFERENCES "workflow"."state_transition_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "workflow"."transition_side_effects"
        ADD CONSTRAINT "fk_transition_side_effects_state_transition_definition_id" FOREIGN KEY ("state_transition_definition_id")
        REFERENCES "workflow"."state_transition_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_events"
        ADD CONSTRAINT "fk_state_transition_events_state_machine_definition_id" FOREIGN KEY ("state_machine_definition_id")
        REFERENCES "workflow"."state_machine_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_events"
        ADD CONSTRAINT "fk_state_transition_events_transition_definition_id" FOREIGN KEY ("transition_definition_id")
        REFERENCES "workflow"."state_transition_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_workflow_instance_id" FOREIGN KEY ("workflow_instance_id")
        REFERENCES "workflow"."workflow_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
