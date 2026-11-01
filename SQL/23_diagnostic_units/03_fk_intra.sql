-- SALUD v4.2.83 · módulo 23 · schema diagnostic_units
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

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_unit_medical_visitor_id" FOREIGN KEY ("unit_medical_visitor_id")
        REFERENCES "diagnostic_units"."unit_medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_rescheduled_from_id" FOREIGN KEY ("rescheduled_from_id")
        REFERENCES "diagnostic_units"."unit_visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_request_events"
        ADD CONSTRAINT "fk_unit_visit_request_events_unit_visit_request_id" FOREIGN KEY ("unit_visit_request_id")
        REFERENCES "diagnostic_units"."unit_visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_unit_visit_request_id" FOREIGN KEY ("unit_visit_request_id")
        REFERENCES "diagnostic_units"."unit_visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_unit_medical_visitor_id" FOREIGN KEY ("unit_medical_visitor_id")
        REFERENCES "diagnostic_units"."unit_medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_ratings"
        ADD CONSTRAINT "fk_unit_visit_ratings_unit_visit_record_id" FOREIGN KEY ("unit_visit_record_id")
        REFERENCES "diagnostic_units"."unit_visit_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
