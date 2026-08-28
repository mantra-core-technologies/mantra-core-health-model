-- SALUD v4.0.10 · módulo 28 · schema telemetry
-- Generado de diagram_28_telemetry.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_tracking_purpose_definitions_purpose_code" ON "telemetry"."tracking_purpose_definitions" ("purpose_code");

CREATE INDEX IF NOT EXISTS "ix_tracking_purpose_definitions_purpose_category_concept_id" ON "telemetry"."tracking_purpose_definitions" ("purpose_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_purpose_definitions_legal_basis_concept_id" ON "telemetry"."tracking_purpose_definitions" ("legal_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_purpose_definitions_status_concept_id" ON "telemetry"."tracking_purpose_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_purpose_definitions_created_by_user_id" ON "telemetry"."tracking_purpose_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_activity_event_schema_definitions_purpose_definition_id" ON "telemetry"."activity_event_schema_definitions" ("purpose_definition_id");

CREATE INDEX IF NOT EXISTS "ix_activity_event_schema_definitions_portal_type_concept_id" ON "telemetry"."activity_event_schema_definitions" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_activity_event_schema_definitions_pii_classificatio_2357b2ab" ON "telemetry"."activity_event_schema_definitions" ("pii_classification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_activity_event_schema_definitions_status_concept_id" ON "telemetry"."activity_event_schema_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_activity_event_schema_definitions_created_by_user_id" ON "telemetry"."activity_event_schema_definitions" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_analytics_subjects_pseudonymous_subject_key" ON "telemetry"."analytics_subjects" ("pseudonymous_subject_key");

CREATE INDEX IF NOT EXISTS "ix_analytics_subjects_user_id" ON "telemetry"."analytics_subjects" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_analytics_subjects_patient_profile_id" ON "telemetry"."analytics_subjects" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_analytics_subjects_rotated_from_subject_id" ON "telemetry"."analytics_subjects" ("rotated_from_subject_id");

CREATE INDEX IF NOT EXISTS "ix_analytics_subjects_created_from_consent_id" ON "telemetry"."analytics_subjects" ("created_from_consent_id");

CREATE INDEX IF NOT EXISTS "ix_analytics_subjects_patient_profile_id_created_at" ON "telemetry"."analytics_subjects" ("patient_profile_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_tracking_consents_user_id" ON "telemetry"."tracking_consents" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_consents_purpose_definition_id" ON "telemetry"."tracking_consents" ("purpose_definition_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_consents_decision_concept_id" ON "telemetry"."tracking_consents" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_consents_jurisdiction_concept_id" ON "telemetry"."tracking_consents" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_consents_created_by_user_id" ON "telemetry"."tracking_consents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_versions_jurisdiction_concept_id" ON "telemetry"."tracking_disclosure_versions" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_versions_file_id" ON "telemetry"."tracking_disclosure_versions" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_versions_status_concept_id" ON "telemetry"."tracking_disclosure_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_versions_created_by_user_id" ON "telemetry"."tracking_disclosure_versions" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_tracking_disclosure_versions_file_id_version_number" ON "telemetry"."tracking_disclosure_versions" ("file_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_acceptances_tracking_disclosure_ca448e76" ON "telemetry"."tracking_disclosure_acceptances" ("tracking_disclosure_version_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_acceptances_user_id" ON "telemetry"."tracking_disclosure_acceptances" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_acceptances_session_id" ON "telemetry"."tracking_disclosure_acceptances" ("session_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_disclosure_acceptances_acceptance_status_concept_id" ON "telemetry"."tracking_disclosure_acceptances" ("acceptance_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_event_schema_definition_id" ON "telemetry"."user_activity_events" ("event_schema_definition_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_analytics_subject_id" ON "telemetry"."user_activity_events" ("analytics_subject_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_user_id" ON "telemetry"."user_activity_events" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_session_id" ON "telemetry"."user_activity_events" ("session_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_device_id" ON "telemetry"."user_activity_events" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_tenant_id" ON "telemetry"."user_activity_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_portal_type_concept_id" ON "telemetry"."user_activity_events" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_target_type_concept_id" ON "telemetry"."user_activity_events" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_consent_snapshot_id" ON "telemetry"."user_activity_events" ("consent_snapshot_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_security_audit_event_id" ON "telemetry"."user_activity_events" ("security_audit_event_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_tenant_id_created_at" ON "telemetry"."user_activity_events" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_user_activity_events_created_at" ON "telemetry"."user_activity_events" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_user_activity_event_properties_user_activity_event_id" ON "telemetry"."user_activity_event_properties" ("user_activity_event_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_event_properties_value_type_concept_id" ON "telemetry"."user_activity_event_properties" ("value_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_event_properties_value_concept_id" ON "telemetry"."user_activity_event_properties" ("value_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_activity_event_properties_data_classification__18c7c7cf" ON "telemetry"."user_activity_event_properties" ("data_classification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_session_journeys_session_id" ON "telemetry"."session_journeys" ("session_id");

CREATE INDEX IF NOT EXISTS "ix_session_journeys_analytics_subject_id" ON "telemetry"."session_journeys" ("analytics_subject_id");

CREATE INDEX IF NOT EXISTS "ix_session_journeys_portal_type_concept_id" ON "telemetry"."session_journeys" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_session_journeys_entry_event_id" ON "telemetry"."session_journeys" ("entry_event_id");

CREATE INDEX IF NOT EXISTS "ix_session_journeys_exit_event_id" ON "telemetry"."session_journeys" ("exit_event_id");

CREATE INDEX IF NOT EXISTS "ix_session_journeys_journey_status_concept_id" ON "telemetry"."session_journeys" ("journey_status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_funnel_definitions_funnel_code" ON "telemetry"."funnel_definitions" ("funnel_code");

CREATE INDEX IF NOT EXISTS "ix_funnel_definitions_portal_type_concept_id" ON "telemetry"."funnel_definitions" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_funnel_definitions_purpose_definition_id" ON "telemetry"."funnel_definitions" ("purpose_definition_id");

CREATE INDEX IF NOT EXISTS "ix_funnel_definitions_status_concept_id" ON "telemetry"."funnel_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_funnel_definitions_created_by_user_id" ON "telemetry"."funnel_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_funnel_definitions_updated_by_user_id" ON "telemetry"."funnel_definitions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_funnel_definitions_purpose_definition_id_version_number" ON "telemetry"."funnel_definitions" ("purpose_definition_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_funnel_steps_funnel_definition_id" ON "telemetry"."funnel_steps" ("funnel_definition_id");

CREATE INDEX IF NOT EXISTS "ix_funnel_steps_event_schema_definition_id" ON "telemetry"."funnel_steps" ("event_schema_definition_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_events_funnel_definition_id" ON "telemetry"."conversion_events" ("funnel_definition_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_events_analytics_subject_id" ON "telemetry"."conversion_events" ("analytics_subject_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_events_session_journey_id" ON "telemetry"."conversion_events" ("session_journey_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_events_completion_event_id" ON "telemetry"."conversion_events" ("completion_event_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_session_journey_id" ON "telemetry"."client_contexts" ("session_journey_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_analytics_subject_id" ON "telemetry"."client_contexts" ("analytics_subject_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_session_id" ON "telemetry"."client_contexts" ("session_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_portal_type_concept_id" ON "telemetry"."client_contexts" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_device_type_concept_id" ON "telemetry"."client_contexts" ("device_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_os_family_concept_id" ON "telemetry"."client_contexts" ("os_family_concept_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_browser_family_concept_id" ON "telemetry"."client_contexts" ("browser_family_concept_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_country_concept_id" ON "telemetry"."client_contexts" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_client_contexts_data_classification_concept_id" ON "telemetry"."client_contexts" ("data_classification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_user_activity_event_id" ON "telemetry"."web_vitals" ("user_activity_event_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_session_journey_id" ON "telemetry"."web_vitals" ("session_journey_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_analytics_subject_id" ON "telemetry"."web_vitals" ("analytics_subject_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_client_context_id" ON "telemetry"."web_vitals" ("client_context_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_portal_type_concept_id" ON "telemetry"."web_vitals" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_metric_concept_id" ON "telemetry"."web_vitals" ("metric_concept_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_rating_concept_id" ON "telemetry"."web_vitals" ("rating_concept_id");

CREATE INDEX IF NOT EXISTS "ix_web_vitals_navigation_type_concept_id" ON "telemetry"."web_vitals" ("navigation_type_concept_id");

CREATE INDEX IF NOT EXISTS "brin_web_vitals_created_at" ON "telemetry"."web_vitals" USING brin ("created_at") WITH (pages_per_range=128);
