-- SALUD v4.0.10 · módulo 22 · schema organization_extensions
-- Generado de diagram_22_organization_extensions.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_hospital_id" FOREIGN KEY ("hospital_id")
        REFERENCES "organization_extensions"."hospitals" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
