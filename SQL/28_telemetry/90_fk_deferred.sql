-- SALUD v4.0.10 · módulo 28 · schema telemetry
-- Generado de diagram_28_telemetry.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   user_activity_events.consent_snapshot_id


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_purpose_definitions"
        ADD CONSTRAINT "fk_tracking_purpose_definitions_purpose_category_concept_id" FOREIGN KEY ("purpose_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_purpose_definitions"
        ADD CONSTRAINT "fk_tracking_purpose_definitions_legal_basis_concept_id" FOREIGN KEY ("legal_basis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_purpose_definitions"
        ADD CONSTRAINT "fk_tracking_purpose_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_purpose_definitions"
        ADD CONSTRAINT "fk_tracking_purpose_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."activity_event_schema_definitions"
        ADD CONSTRAINT "fk_activity_event_schema_definitions_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."activity_event_schema_definitions"
        ADD CONSTRAINT "fk_activity_event_schema_definitions_pii_classificatio_cf444a2d" FOREIGN KEY ("pii_classification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."activity_event_schema_definitions"
        ADD CONSTRAINT "fk_activity_event_schema_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."activity_event_schema_definitions"
        ADD CONSTRAINT "fk_activity_event_schema_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."analytics_subjects"
        ADD CONSTRAINT "fk_analytics_subjects_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "telemetry"."analytics_subjects"
        ADD CONSTRAINT "fk_analytics_subjects_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: consent.consents (requiere schema consent)
DO $$ BEGIN
    ALTER TABLE "telemetry"."analytics_subjects"
        ADD CONSTRAINT "fk_analytics_subjects_created_from_consent_id" FOREIGN KEY ("created_from_consent_id")
        REFERENCES "consent"."consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_consents"
        ADD CONSTRAINT "fk_tracking_consents_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_consents"
        ADD CONSTRAINT "fk_tracking_consents_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_consents"
        ADD CONSTRAINT "fk_tracking_consents_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_consents"
        ADD CONSTRAINT "fk_tracking_consents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_versions"
        ADD CONSTRAINT "fk_tracking_disclosure_versions_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_versions"
        ADD CONSTRAINT "fk_tracking_disclosure_versions_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_versions"
        ADD CONSTRAINT "fk_tracking_disclosure_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_versions"
        ADD CONSTRAINT "fk_tracking_disclosure_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_acceptances"
        ADD CONSTRAINT "fk_tracking_disclosure_acceptances_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.sessions (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_acceptances"
        ADD CONSTRAINT "fk_tracking_disclosure_acceptances_session_id" FOREIGN KEY ("session_id")
        REFERENCES "iam"."sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."tracking_disclosure_acceptances"
        ADD CONSTRAINT "fk_tracking_disclosure_acceptances_acceptance_status_concept_id" FOREIGN KEY ("acceptance_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.sessions (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_session_id" FOREIGN KEY ("session_id")
        REFERENCES "iam"."sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_device_id" FOREIGN KEY ("device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.security_events (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_events"
        ADD CONSTRAINT "fk_user_activity_events_security_audit_event_id" FOREIGN KEY ("security_audit_event_id")
        REFERENCES "iam"."security_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_event_properties"
        ADD CONSTRAINT "fk_user_activity_event_properties_value_type_concept_id" FOREIGN KEY ("value_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_event_properties"
        ADD CONSTRAINT "fk_user_activity_event_properties_value_concept_id" FOREIGN KEY ("value_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."user_activity_event_properties"
        ADD CONSTRAINT "fk_user_activity_event_properties_data_classification__e558232d" FOREIGN KEY ("data_classification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.sessions (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."session_journeys"
        ADD CONSTRAINT "fk_session_journeys_session_id" FOREIGN KEY ("session_id")
        REFERENCES "iam"."sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."session_journeys"
        ADD CONSTRAINT "fk_session_journeys_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."session_journeys"
        ADD CONSTRAINT "fk_session_journeys_journey_status_concept_id" FOREIGN KEY ("journey_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."funnel_definitions"
        ADD CONSTRAINT "fk_funnel_definitions_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."funnel_definitions"
        ADD CONSTRAINT "fk_funnel_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."funnel_definitions"
        ADD CONSTRAINT "fk_funnel_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."funnel_definitions"
        ADD CONSTRAINT "fk_funnel_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.sessions (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_session_id" FOREIGN KEY ("session_id")
        REFERENCES "iam"."sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_device_type_concept_id" FOREIGN KEY ("device_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_os_family_concept_id" FOREIGN KEY ("os_family_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_browser_family_concept_id" FOREIGN KEY ("browser_family_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."client_contexts"
        ADD CONSTRAINT "fk_client_contexts_data_classification_concept_id" FOREIGN KEY ("data_classification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_metric_concept_id" FOREIGN KEY ("metric_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_rating_concept_id" FOREIGN KEY ("rating_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "telemetry"."web_vitals"
        ADD CONSTRAINT "fk_web_vitals_navigation_type_concept_id" FOREIGN KEY ("navigation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
