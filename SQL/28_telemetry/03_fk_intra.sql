-- SALUD v4.0.10 · módulo 28 · schema telemetry
-- Generado de diagram_28_telemetry.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "telemetry"."activity_event_schema_definitions"
        ADD CONSTRAINT "fk_activity_event_schema_definitions_purpose_definition_id" FOREIGN KEY ("purpose_definition_id")
        REFERENCES "telemetry"."tracking_purpose_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."analytics_subjects"
        ADD CONSTRAINT "fk_analytics_subjects_rotated_from_subject_id" FOREIGN KEY ("rotated_from_subject_id")
        REFERENCES "telemetry"."analytics_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_consents"
        ADD CONSTRAINT "fk_tracking_consents_purpose_definition_id" FOREIGN KEY ("purpose_definition_id")
        REFERENCES "telemetry"."tracking_purpose_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_acceptances"
        ADD CONSTRAINT "fk_tracking_disclosure_acceptances_tracking_disclosure_fc01b619" FOREIGN KEY ("tracking_disclosure_version_id")
        REFERENCES "telemetry"."tracking_disclosure_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_event_schema_definition_id" FOREIGN KEY ("event_schema_definition_id")
        REFERENCES "telemetry"."activity_event_schema_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_analytics_subject_id" FOREIGN KEY ("analytics_subject_id")
        REFERENCES "telemetry"."analytics_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_event_properties"
        ADD CONSTRAINT "fk_user_activity_event_properties_user_activity_event_id" FOREIGN KEY ("user_activity_event_id")
        REFERENCES "telemetry"."user_activity_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."session_journeys"
        ADD CONSTRAINT "fk_session_journeys_analytics_subject_id" FOREIGN KEY ("analytics_subject_id")
        REFERENCES "telemetry"."analytics_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."session_journeys"
        ADD CONSTRAINT "fk_session_journeys_entry_event_id" FOREIGN KEY ("entry_event_id")
        REFERENCES "telemetry"."user_activity_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."session_journeys"
        ADD CONSTRAINT "fk_session_journeys_exit_event_id" FOREIGN KEY ("exit_event_id")
        REFERENCES "telemetry"."user_activity_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."funnel_definitions"
        ADD CONSTRAINT "fk_funnel_definitions_purpose_definition_id" FOREIGN KEY ("purpose_definition_id")
        REFERENCES "telemetry"."tracking_purpose_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."funnel_steps"
        ADD CONSTRAINT "fk_funnel_steps_funnel_definition_id" FOREIGN KEY ("funnel_definition_id")
        REFERENCES "telemetry"."funnel_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."funnel_steps"
        ADD CONSTRAINT "fk_funnel_steps_event_schema_definition_id" FOREIGN KEY ("event_schema_definition_id")
        REFERENCES "telemetry"."activity_event_schema_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."conversion_events"
        ADD CONSTRAINT "fk_conversion_events_funnel_definition_id" FOREIGN KEY ("funnel_definition_id")
        REFERENCES "telemetry"."funnel_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."conversion_events"
        ADD CONSTRAINT "fk_conversion_events_analytics_subject_id" FOREIGN KEY ("analytics_subject_id")
        REFERENCES "telemetry"."analytics_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."conversion_events"
        ADD CONSTRAINT "fk_conversion_events_session_journey_id" FOREIGN KEY ("session_journey_id")
        REFERENCES "telemetry"."session_journeys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."conversion_events"
        ADD CONSTRAINT "fk_conversion_events_completion_event_id" FOREIGN KEY ("completion_event_id")
        REFERENCES "telemetry"."user_activity_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_session_journey_id" FOREIGN KEY ("session_journey_id")
        REFERENCES "telemetry"."session_journeys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_analytics_subject_id" FOREIGN KEY ("analytics_subject_id")
        REFERENCES "telemetry"."analytics_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_user_activity_event_id" FOREIGN KEY ("user_activity_event_id")
        REFERENCES "telemetry"."user_activity_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_session_journey_id" FOREIGN KEY ("session_journey_id")
        REFERENCES "telemetry"."session_journeys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_analytics_subject_id" FOREIGN KEY ("analytics_subject_id")
        REFERENCES "telemetry"."analytics_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_client_context_id" FOREIGN KEY ("client_context_id")
        REFERENCES "telemetry"."client_contexts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
