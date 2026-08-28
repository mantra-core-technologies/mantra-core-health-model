-- SALUD v4.0.10 · módulo 14 · schema practice
-- Generado de diagram_14_practice.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "practice"."inventory_items"
        ADD CONSTRAINT "fk_inventory_items_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."inventory_movements"
        ADD CONSTRAINT "fk_inventory_movements_inventory_item_id" FOREIGN KEY ("inventory_item_id")
        REFERENCES "practice"."inventory_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practice_sites"
        ADD CONSTRAINT "fk_practice_sites_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."clinical_units"
        ADD CONSTRAINT "fk_clinical_units_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."clinical_units"
        ADD CONSTRAINT "fk_clinical_units_parent_unit_id" FOREIGN KEY ("parent_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_parent_space_id" FOREIGN KEY ("parent_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."healthcare_services"
        ADD CONSTRAINT "fk_healthcare_services_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."healthcare_services"
        ADD CONSTRAINT "fk_healthcare_services_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."healthcare_services"
        ADD CONSTRAINT "fk_healthcare_services_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_role_assignments"
        ADD CONSTRAINT "fk_practitioner_role_assignments_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_role_assignments"
        ADD CONSTRAINT "fk_practitioner_role_assignments_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_role_assignments"
        ADD CONSTRAINT "fk_practitioner_role_assignments_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_role_assignments"
        ADD CONSTRAINT "fk_practitioner_role_assignments_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_support_assignments"
        ADD CONSTRAINT "fk_practitioner_support_assignments_practitioner_role__75362a27" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practice_accreditations"
        ADD CONSTRAINT "fk_practice_accreditations_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practice_accreditations"
        ADD CONSTRAINT "fk_practice_accreditations_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practice_settings"
        ADD CONSTRAINT "fk_practice_settings_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
