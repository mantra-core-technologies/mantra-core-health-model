-- SALUD v4.2.80 · módulo 70 · schema observability
-- Generado de diagram_70_observability.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "observability"."error_events"
        ADD CONSTRAINT "fk_error_events_error_group_id" FOREIGN KEY ("error_group_id")
        REFERENCES "observability"."error_groups" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "observability"."error_events"
        ADD CONSTRAINT "fk_error_events_instance_id" FOREIGN KEY ("instance_id")
        REFERENCES "observability"."instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "observability"."alert_evaluations"
        ADD CONSTRAINT "fk_alert_evaluations_alert_rule_id" FOREIGN KEY ("alert_rule_id")
        REFERENCES "observability"."alert_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
