-- SALUD v4.2.83 · módulo 08 · schema clinical
-- Generado de diagram_08_clinical.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "clinical"."encounters"
        ADD CONSTRAINT "fk_encounters_episode_id" FOREIGN KEY ("episode_id")
        REFERENCES "clinical"."care_episodes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."encounters"
        ADD CONSTRAINT "fk_encounters_appointment_id" FOREIGN KEY ("appointment_id")
        REFERENCES "clinical"."appointments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."observations"
        ADD CONSTRAINT "fk_observations_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."observations"
        ADD CONSTRAINT "fk_observations_based_on_service_request_id" FOREIGN KEY ("based_on_service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."observation_components"
        ADD CONSTRAINT "fk_observation_components_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."conditions"
        ADD CONSTRAINT "fk_conditions_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."allergy_intolerances"
        ADD CONSTRAINT "fk_allergy_intolerances_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."allergy_reactions"
        ADD CONSTRAINT "fk_allergy_reactions_allergy_id" FOREIGN KEY ("allergy_id")
        REFERENCES "clinical"."allergy_intolerances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_previous_diagnostic_report_id" FOREIGN KEY ("previous_diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."diagnostic_reports"
        ADD CONSTRAINT "fk_diagnostic_reports_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."diagnostic_reports"
        ADD CONSTRAINT "fk_diagnostic_reports_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_request_notes"
        ADD CONSTRAINT "fk_service_request_notes_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_request_components"
        ADD CONSTRAINT "fk_service_request_components_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."medication_requests"
        ADD CONSTRAINT "fk_medication_requests_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."medication_requests"
        ADD CONSTRAINT "fk_medication_requests_indication_condition_id" FOREIGN KEY ("indication_condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."medication_requests"
        ADD CONSTRAINT "fk_medication_requests_replaces_request_id" FOREIGN KEY ("replaces_request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."medication_requests"
        ADD CONSTRAINT "fk_medication_requests_replaced_by_request_id" FOREIGN KEY ("replaced_by_request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."medication_requests"
        ADD CONSTRAINT "fk_medication_requests_renewed_from_request_id" FOREIGN KEY ("renewed_from_request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."medication_records"
        ADD CONSTRAINT "fk_medication_records_request_id" FOREIGN KEY ("request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."procedures"
        ADD CONSTRAINT "fk_procedures_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."procedures"
        ADD CONSTRAINT "fk_procedures_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."procedures"
        ADD CONSTRAINT "fk_procedures_parent_procedure_id" FOREIGN KEY ("parent_procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_source_procedure_id" FOREIGN KEY ("source_procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_source_immunization_id" FOREIGN KEY ("source_immunization_id")
        REFERENCES "clinical"."immunizations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_participants"
        ADD CONSTRAINT "fk_encounter_participants_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_previous_encounter_location_id" FOREIGN KEY ("previous_encounter_location_id")
        REFERENCES "clinical"."encounter_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_placement_incident_id" FOREIGN KEY ("placement_incident_id")
        REFERENCES "clinical"."placement_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_encounter_location_id" FOREIGN KEY ("encounter_location_id")
        REFERENCES "clinical"."encounter_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_census_day_id" FOREIGN KEY ("census_day_id")
        REFERENCES "clinical"."inpatient_census_days" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_adjustments"
        ADD CONSTRAINT "fk_inpatient_census_adjustments_census_day_id" FOREIGN KEY ("census_day_id")
        REFERENCES "clinical"."inpatient_census_days" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."observation_performers"
        ADD CONSTRAINT "fk_observation_performers_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."observation_reference_ranges"
        ADD CONSTRAINT "fk_observation_reference_ranges_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."observation_reference_ranges"
        ADD CONSTRAINT "fk_observation_reference_ranges_observation_component_id" FOREIGN KEY ("observation_component_id")
        REFERENCES "clinical"."observation_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."observation_notes"
        ADD CONSTRAINT "fk_observation_notes_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
