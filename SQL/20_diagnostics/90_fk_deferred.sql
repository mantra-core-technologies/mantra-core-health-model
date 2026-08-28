-- SALUD v4.0.10 · módulo 20 · schema diagnostics
-- Generado de diagram_20_diagnostics.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   specimen_identifiers.assigning_organization_id


-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_specimen_type_concept_id" FOREIGN KEY ("specimen_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_collection_method_concept_id" FOREIGN KEY ("collection_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_collector_profile_id" FOREIGN KEY ("collector_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_container_type_concept_id" FOREIGN KEY ("container_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_quantity_unit_concept_id" FOREIGN KEY ("quantity_unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimens"
        ADD CONSTRAINT "fk_specimens_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_processing_steps"
        ADD CONSTRAINT "fk_specimen_processing_steps_procedure_concept_id" FOREIGN KEY ("procedure_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_processing_steps"
        ADD CONSTRAINT "fk_specimen_processing_steps_additive_concept_id" FOREIGN KEY ("additive_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_processing_steps"
        ADD CONSTRAINT "fk_specimen_processing_steps_performer_profile_id" FOREIGN KEY ("performer_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_processing_steps"
        ADD CONSTRAINT "fk_specimen_processing_steps_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."observation_specimens"
        ADD CONSTRAINT "fk_observation_specimens_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."observation_specimens"
        ADD CONSTRAINT "fk_observation_specimens_relationship_concept_id" FOREIGN KEY ("relationship_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.diagnostic_reports (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_diagnostic_report_id" FOREIGN KEY ("diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_clinical_status_concept_id" FOREIGN KEY ("clinical_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_performer_tenant_id" FOREIGN KEY ("performer_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_author_profile_id" FOREIGN KEY ("author_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_amendment_reason_concept_id" FOREIGN KEY ("amendment_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_release_eligibility_concept_id" FOREIGN KEY ("release_eligibility_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: health_data.health_source_systems (requiere schema health_data)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_source_system_id" FOREIGN KEY ("source_system_id")
        REFERENCES "health_data"."health_source_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: health_data.health_provenance_records (requiere schema health_data)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_provenance_record_id" FOREIGN KEY ("provenance_record_id")
        REFERENCES "health_data"."health_provenance_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_results"
        ADD CONSTRAINT "fk_diagnostic_report_results_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_results"
        ADD CONSTRAINT "fk_diagnostic_report_results_result_role_concept_id" FOREIGN KEY ("result_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_files"
        ADD CONSTRAINT "fk_diagnostic_report_files_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_files"
        ADD CONSTRAINT "fk_diagnostic_report_files_content_role_concept_id" FOREIGN KEY ("content_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_files"
        ADD CONSTRAINT "fk_diagnostic_report_files_presentation_format_concept_id" FOREIGN KEY ("presentation_format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_files"
        ADD CONSTRAINT "fk_diagnostic_report_files_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_endpoints"
        ADD CONSTRAINT "fk_imaging_endpoints_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_endpoints"
        ADD CONSTRAINT "fk_imaging_endpoints_endpoint_type_concept_id" FOREIGN KEY ("endpoint_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.provider_connections (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_endpoints"
        ADD CONSTRAINT "fk_imaging_endpoints_connection_id" FOREIGN KEY ("connection_id")
        REFERENCES "integrations"."provider_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_endpoints"
        ADD CONSTRAINT "fk_imaging_endpoints_storage_region_concept_id" FOREIGN KEY ("storage_region_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_endpoints"
        ADD CONSTRAINT "fk_imaging_endpoints_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_endpoints"
        ADD CONSTRAINT "fk_imaging_endpoints_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_endpoints"
        ADD CONSTRAINT "fk_imaging_endpoints_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.diagnostic_reports (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_diagnostic_report_id" FOREIGN KEY ("diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_modality_value_set_id" FOREIGN KEY ("modality_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_referring_practitioner_profile_id" FOREIGN KEY ("referring_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_series"
        ADD CONSTRAINT "fk_imaging_series_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_series"
        ADD CONSTRAINT "fk_imaging_series_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_series"
        ADD CONSTRAINT "fk_imaging_series_laterality_concept_id" FOREIGN KEY ("laterality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_instances"
        ADD CONSTRAINT "fk_imaging_instances_sop_class_concept_id" FOREIGN KEY ("sop_class_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.diagnostic_reports (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_diagnostic_report_id" FOREIGN KEY ("diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_media_type_concept_id" FOREIGN KEY ("media_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_view_concept_id" FOREIGN KEY ("view_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_captured_by_profile_id" FOREIGN KEY ("captured_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_device_id" FOREIGN KEY ("device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_patient_visibility_concept_id" FOREIGN KEY ("patient_visibility_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."clinical_media"
        ADD CONSTRAINT "fk_clinical_media_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_annotation_type_concept_id" FOREIGN KEY ("annotation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_label_concept_id" FOREIGN KEY ("label_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_author_profile_id" FOREIGN KEY ("author_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_release_events"
        ADD CONSTRAINT "fk_diagnostic_release_events_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_release_events"
        ADD CONSTRAINT "fk_diagnostic_release_events_patient_visibility_concept_id" FOREIGN KEY ("patient_visibility_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_release_events"
        ADD CONSTRAINT "fk_diagnostic_release_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_release_events"
        ADD CONSTRAINT "fk_diagnostic_release_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_identifiers"
        ADD CONSTRAINT "fk_specimen_identifiers_identifier_type_concept_id" FOREIGN KEY ("identifier_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_identifiers"
        ADD CONSTRAINT "fk_specimen_identifiers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_identifiers"
        ADD CONSTRAINT "fk_specimen_identifiers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_parent_links"
        ADD CONSTRAINT "fk_specimen_parent_links_relationship_type_concept_id" FOREIGN KEY ("relationship_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_parent_links"
        ADD CONSTRAINT "fk_specimen_parent_links_quantity_unit_concept_id" FOREIGN KEY ("quantity_unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_collector_profile_id" FOREIGN KEY ("collector_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_collection_site_id" FOREIGN KEY ("collection_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_method_concept_id" FOREIGN KEY ("method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_fasting_status_concept_id" FOREIGN KEY ("fasting_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_container_type_concept_id" FOREIGN KEY ("container_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_additive_concept_id" FOREIGN KEY ("additive_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_capacity_unit_concept_id" FOREIGN KEY ("capacity_unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_specimen_quantity_unit_concept_id" FOREIGN KEY ("specimen_quantity_unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_container_events"
        ADD CONSTRAINT "fk_specimen_container_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_container_events"
        ADD CONSTRAINT "fk_specimen_container_events_destination_location_id" FOREIGN KEY ("destination_location_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_container_events"
        ADD CONSTRAINT "fk_specimen_container_events_actor_profile_id" FOREIGN KEY ("actor_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_chain_of_custody_events"
        ADD CONSTRAINT "fk_specimen_chain_of_custody_events_custody_event_type_464b802a" FOREIGN KEY ("custody_event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_chain_of_custody_events"
        ADD CONSTRAINT "fk_specimen_chain_of_custody_events_from_party_type_concept_id" FOREIGN KEY ("from_party_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_chain_of_custody_events"
        ADD CONSTRAINT "fk_specimen_chain_of_custody_events_to_party_type_concept_id" FOREIGN KEY ("to_party_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_chain_of_custody_events"
        ADD CONSTRAINT "fk_specimen_chain_of_custody_events_signed_by_user_id" FOREIGN KEY ("signed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_rejection_events"
        ADD CONSTRAINT "fk_specimen_rejection_events_rejection_reason_concept_id" FOREIGN KEY ("rejection_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_rejection_events"
        ADD CONSTRAINT "fk_specimen_rejection_events_rejected_by_profile_id" FOREIGN KEY ("rejected_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_rejection_events"
        ADD CONSTRAINT "fk_specimen_rejection_events_recollection_service_request_id" FOREIGN KEY ("recollection_service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_unit_sites (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_receiving_site_id" FOREIGN KEY ("receiving_site_id")
        REFERENCES "diagnostic_units"."diagnostic_unit_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_units (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_laboratory_unit_id" FOREIGN KEY ("laboratory_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: health_data.health_source_systems (requiere schema health_data)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_source_system_id" FOREIGN KEY ("source_system_id")
        REFERENCES "health_data"."health_source_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_accessions"
        ADD CONSTRAINT "fk_laboratory_accessions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."accession_specimens"
        ADD CONSTRAINT "fk_accession_specimens_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_units (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_assigned_laboratory_unit_id" FOREIGN KEY ("assigned_laboratory_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_assigned_profile_id" FOREIGN KEY ("assigned_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_test_code_concept_id" FOREIGN KEY ("test_code_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_method_concept_id" FOREIGN KEY ("method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_analyzer_device_id" FOREIGN KEY ("analyzer_device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.diagnostic_reports (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_diagnostic_report_id" FOREIGN KEY ("diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_runs"
        ADD CONSTRAINT "fk_analyzer_runs_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_runs"
        ADD CONSTRAINT "fk_analyzer_runs_analyzer_device_id" FOREIGN KEY ("analyzer_device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy_inventory.inventory_lots (requiere schema pharmacy_inventory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_runs"
        ADD CONSTRAINT "fk_analyzer_runs_reagent_lot_id" FOREIGN KEY ("reagent_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_runs"
        ADD CONSTRAINT "fk_analyzer_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.provider_operator_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_runs"
        ADD CONSTRAINT "fk_analyzer_runs_operator_profile_id" FOREIGN KEY ("operator_profile_id")
        REFERENCES "profiles"."provider_operator_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_result_messages"
        ADD CONSTRAINT "fk_analyzer_result_messages_message_format_concept_id" FOREIGN KEY ("message_format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_result_messages"
        ADD CONSTRAINT "fk_analyzer_result_messages_raw_message_file_id" FOREIGN KEY ("raw_message_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_result_messages"
        ADD CONSTRAINT "fk_analyzer_result_messages_validation_status_concept_id" FOREIGN KEY ("validation_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_result_messages"
        ADD CONSTRAINT "fk_analyzer_result_messages_mapped_observation_id" FOREIGN KEY ("mapped_observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."result_verifications"
        ADD CONSTRAINT "fk_result_verifications_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."result_verifications"
        ADD CONSTRAINT "fk_result_verifications_verifiable_type_concept_id" FOREIGN KEY ("verifiable_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."result_verifications"
        ADD CONSTRAINT "fk_result_verifications_verification_level_concept_id" FOREIGN KEY ("verification_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."result_verifications"
        ADD CONSTRAINT "fk_result_verifications_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."result_verifications"
        ADD CONSTRAINT "fk_result_verifications_verified_by_profile_id" FOREIGN KEY ("verified_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: chart.clinical_note_signatures (requiere schema chart)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."result_verifications"
        ADD CONSTRAINT "fk_result_verifications_signature_id" FOREIGN KEY ("signature_id")
        REFERENCES "chart"."clinical_note_signatures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_observation_id" FOREIGN KEY ("observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.diagnostic_reports (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_diagnostic_report_id" FOREIGN KEY ("diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_criticality_concept_id" FOREIGN KEY ("criticality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_detected_by_profile_id" FOREIGN KEY ("detected_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_notification_status_concept_id" FOREIGN KEY ("notification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_notified_profile_id" FOREIGN KEY ("notified_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_acknowledged_by_profile_id" FOREIGN KEY ("acknowledged_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: platform_ops.escalation_policies (requiere schema platform_ops)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_escalation_policy_id" FOREIGN KEY ("escalation_policy_id")
        REFERENCES "platform_ops"."escalation_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.notification_deliveries (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_communication_evidence_id" FOREIGN KEY ("communication_evidence_id")
        REFERENCES "messaging"."notification_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."critical_result_notifications"
        ADD CONSTRAINT "fk_critical_result_notifications_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.procedures (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_procedure_id" FOREIGN KEY ("procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_code_concept_id" FOREIGN KEY ("code_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_performed_by_profile_id" FOREIGN KEY ("performed_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selections"
        ADD CONSTRAINT "fk_imaging_selections_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selections"
        ADD CONSTRAINT "fk_imaging_selections_author_profile_id" FOREIGN KEY ("author_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selections"
        ADD CONSTRAINT "fk_imaging_selections_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selections"
        ADD CONSTRAINT "fk_imaging_selections_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selections"
        ADD CONSTRAINT "fk_imaging_selections_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: polyglot_storage.storage_backends (requiere schema polyglot_storage)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_storage_backend_id" FOREIGN KEY ("storage_backend_id")
        REFERENCES "polyglot_storage"."storage_backends" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: polyglot_storage.encryption_profiles (requiere schema polyglot_storage)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_encryption_profile_id" FOREIGN KEY ("encryption_profile_id")
        REFERENCES "polyglot_storage"."encryption_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.retention_policies (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_retention_policy_id" FOREIGN KEY ("retention_policy_id")
        REFERENCES "system_ops"."retention_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.legal_holds (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_legal_hold_id" FOREIGN KEY ("legal_hold_id")
        REFERENCES "system_ops"."legal_holds" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_document_title_concept_id" FOREIGN KEY ("document_title_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.diagnostic_reports (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_diagnostic_report_id" FOREIGN KEY ("diagnostic_report_id")
        REFERENCES "clinical"."diagnostic_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_verified_by_profile_id" FOREIGN KEY ("verified_by_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."radiation_dose_events"
        ADD CONSTRAINT "fk_radiation_dose_events_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."radiation_dose_events"
        ADD CONSTRAINT "fk_radiation_dose_events_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."radiation_dose_events"
        ADD CONSTRAINT "fk_radiation_dose_events_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.devices (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."radiation_dose_events"
        ADD CONSTRAINT "fk_radiation_dose_events_device_id" FOREIGN KEY ("device_id")
        REFERENCES "iam"."devices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_data_quality_events"
        ADD CONSTRAINT "fk_diagnostic_data_quality_events_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_data_quality_events"
        ADD CONSTRAINT "fk_diagnostic_data_quality_events_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_data_quality_events"
        ADD CONSTRAINT "fk_diagnostic_data_quality_events_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_data_quality_events"
        ADD CONSTRAINT "fk_diagnostic_data_quality_events_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_data_quality_events"
        ADD CONSTRAINT "fk_diagnostic_data_quality_events_resolved_by_user_id" FOREIGN KEY ("resolved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_provenance_links"
        ADD CONSTRAINT "fk_diagnostic_provenance_links_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_provenance_links"
        ADD CONSTRAINT "fk_diagnostic_provenance_links_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_provenance_links"
        ADD CONSTRAINT "fk_diagnostic_provenance_links_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_provenance_links"
        ADD CONSTRAINT "fk_diagnostic_provenance_links_activity_concept_id" FOREIGN KEY ("activity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_provenance_links"
        ADD CONSTRAINT "fk_diagnostic_provenance_links_agent_profile_id" FOREIGN KEY ("agent_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: health_data.health_source_systems (requiere schema health_data)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_provenance_links"
        ADD CONSTRAINT "fk_diagnostic_provenance_links_source_system_id" FOREIGN KEY ("source_system_id")
        REFERENCES "health_data"."health_source_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
