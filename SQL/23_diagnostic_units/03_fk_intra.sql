-- SALUD v4.0.10 · módulo 23 · schema diagnostic_units
-- Generado de diagram_23_diagnostic_units.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_sites"
        ADD CONSTRAINT "fk_diagnostic_unit_sites_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_specialties"
        ADD CONSTRAINT "fk_diagnostic_unit_specialties_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_diagnostic_1163bc0c" FOREIGN KEY ("diagnostic_unit_site_id")
        REFERENCES "diagnostic_units"."diagnostic_unit_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_diagnostic_unit_site_id" FOREIGN KEY ("diagnostic_unit_site_id")
        REFERENCES "diagnostic_units"."diagnostic_unit_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_components"
        ADD CONSTRAINT "fk_diagnostic_study_components_parent_offering_id" FOREIGN KEY ("parent_offering_id")
        REFERENCES "diagnostic_units"."diagnostic_study_offerings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_components"
        ADD CONSTRAINT "fk_diagnostic_study_components_component_offering_id" FOREIGN KEY ("component_offering_id")
        REFERENCES "diagnostic_units"."diagnostic_study_offerings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_diagnostic_unit_site_id" FOREIGN KEY ("diagnostic_unit_site_id")
        REFERENCES "diagnostic_units"."diagnostic_unit_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_prices"
        ADD CONSTRAINT "fk_diagnostic_study_prices_price_schedule_id" FOREIGN KEY ("price_schedule_id")
        REFERENCES "diagnostic_units"."diagnostic_price_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_prices"
        ADD CONSTRAINT "fk_diagnostic_study_prices_diagnostic_study_offering_id" FOREIGN KEY ("diagnostic_study_offering_id")
        REFERENCES "diagnostic_units"."diagnostic_study_offerings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_diagnostic_unit_site_id" FOREIGN KEY ("diagnostic_unit_site_id")
        REFERENCES "diagnostic_units"."diagnostic_unit_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_diagnostic_unit_site_id" FOREIGN KEY ("diagnostic_unit_site_id")
        REFERENCES "diagnostic_units"."diagnostic_unit_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
