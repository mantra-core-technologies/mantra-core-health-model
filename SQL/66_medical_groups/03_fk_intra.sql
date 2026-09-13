-- SALUD v4.0.10 · módulo 66 · schema medical_groups
-- Generado de diagram_66_medical_groups.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_group_members_group_id" FOREIGN KEY ("group_id")
        REFERENCES "medical_groups"."groups" ("id") ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
