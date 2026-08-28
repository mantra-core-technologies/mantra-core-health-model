-- SALUD v4.0.10 · módulo 18 · schema clinical_ext
-- Generado de diagram_18_clinical_ext.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "clinical_ext"."care_team_members"
        ADD CONSTRAINT "fk_care_team_members_care_team_id" FOREIGN KEY ("care_team_id")
        REFERENCES "clinical_ext"."care_teams" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."clinical_alerts"
        ADD CONSTRAINT "fk_clinical_alerts_rule_id" FOREIGN KEY ("rule_id")
        REFERENCES "clinical_ext"."cds_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."order_set_items"
        ADD CONSTRAINT "fk_order_set_items_order_set_id" FOREIGN KEY ("order_set_id")
        REFERENCES "clinical_ext"."order_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
