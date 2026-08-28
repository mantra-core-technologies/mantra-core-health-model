-- SALUD v4.0.10 · módulo 20 · schema diagnostics
-- Generado de diagram_20_diagnostics.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_processing_steps"
        ADD CONSTRAINT "fk_specimen_processing_steps_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."observation_specimens"
        ADD CONSTRAINT "fk_observation_specimens_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_versions"
        ADD CONSTRAINT "fk_diagnostic_report_versions_supersedes_version_id" FOREIGN KEY ("supersedes_version_id")
        REFERENCES "diagnostics"."diagnostic_report_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_results"
        ADD CONSTRAINT "fk_diagnostic_report_results_diagnostic_report_version_id" FOREIGN KEY ("diagnostic_report_version_id")
        REFERENCES "diagnostics"."diagnostic_report_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_report_files"
        ADD CONSTRAINT "fk_diagnostic_report_files_diagnostic_report_version_id" FOREIGN KEY ("diagnostic_report_version_id")
        REFERENCES "diagnostics"."diagnostic_report_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_studies"
        ADD CONSTRAINT "fk_imaging_studies_imaging_endpoint_id" FOREIGN KEY ("imaging_endpoint_id")
        REFERENCES "diagnostics"."imaging_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_series"
        ADD CONSTRAINT "fk_imaging_series_imaging_study_id" FOREIGN KEY ("imaging_study_id")
        REFERENCES "diagnostics"."imaging_studies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_instances"
        ADD CONSTRAINT "fk_imaging_instances_imaging_series_id" FOREIGN KEY ("imaging_series_id")
        REFERENCES "diagnostics"."imaging_series" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_clinical_media_id" FOREIGN KEY ("clinical_media_id")
        REFERENCES "diagnostics"."clinical_media" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."media_annotations"
        ADD CONSTRAINT "fk_media_annotations_imaging_instance_id" FOREIGN KEY ("imaging_instance_id")
        REFERENCES "diagnostics"."imaging_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_release_events"
        ADD CONSTRAINT "fk_diagnostic_release_events_diagnostic_report_version_id" FOREIGN KEY ("diagnostic_report_version_id")
        REFERENCES "diagnostics"."diagnostic_report_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."diagnostic_release_events"
        ADD CONSTRAINT "fk_diagnostic_release_events_imaging_study_id" FOREIGN KEY ("imaging_study_id")
        REFERENCES "diagnostics"."imaging_studies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_identifiers"
        ADD CONSTRAINT "fk_specimen_identifiers_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_parent_links"
        ADD CONSTRAINT "fk_specimen_parent_links_child_specimen_id" FOREIGN KEY ("child_specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_parent_links"
        ADD CONSTRAINT "fk_specimen_parent_links_parent_specimen_id" FOREIGN KEY ("parent_specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_containers"
        ADD CONSTRAINT "fk_specimen_containers_parent_container_id" FOREIGN KEY ("parent_container_id")
        REFERENCES "diagnostics"."specimen_containers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_container_events"
        ADD CONSTRAINT "fk_specimen_container_events_specimen_container_id" FOREIGN KEY ("specimen_container_id")
        REFERENCES "diagnostics"."specimen_containers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_container_events"
        ADD CONSTRAINT "fk_specimen_container_events_source_location_id" FOREIGN KEY ("source_location_id")
        REFERENCES "diagnostics"."dicom_object_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_chain_of_custody_events"
        ADD CONSTRAINT "fk_specimen_chain_of_custody_events_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_chain_of_custody_events"
        ADD CONSTRAINT "fk_specimen_chain_of_custody_events_specimen_container_id" FOREIGN KEY ("specimen_container_id")
        REFERENCES "diagnostics"."specimen_containers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_chain_of_custody_events"
        ADD CONSTRAINT "fk_specimen_chain_of_custody_events_location_id" FOREIGN KEY ("location_id")
        REFERENCES "diagnostics"."dicom_object_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_rejection_events"
        ADD CONSTRAINT "fk_specimen_rejection_events_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."accession_specimens"
        ADD CONSTRAINT "fk_accession_specimens_laboratory_accession_id" FOREIGN KEY ("laboratory_accession_id")
        REFERENCES "diagnostics"."laboratory_accessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."accession_specimens"
        ADD CONSTRAINT "fk_accession_specimens_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_orders"
        ADD CONSTRAINT "fk_laboratory_work_orders_laboratory_accession_id" FOREIGN KEY ("laboratory_accession_id")
        REFERENCES "diagnostics"."laboratory_accessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_laboratory_work_order_id" FOREIGN KEY ("laboratory_work_order_id")
        REFERENCES "diagnostics"."laboratory_work_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."laboratory_work_order_tests"
        ADD CONSTRAINT "fk_laboratory_work_order_tests_specimen_id" FOREIGN KEY ("specimen_id")
        REFERENCES "diagnostics"."specimens" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_runs"
        ADD CONSTRAINT "fk_analyzer_runs_quality_control_run_id" FOREIGN KEY ("quality_control_run_id")
        REFERENCES "diagnostics"."analyzer_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_result_messages"
        ADD CONSTRAINT "fk_analyzer_result_messages_analyzer_run_id" FOREIGN KEY ("analyzer_run_id")
        REFERENCES "diagnostics"."analyzer_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."analyzer_result_messages"
        ADD CONSTRAINT "fk_analyzer_result_messages_laboratory_work_order_test_id" FOREIGN KEY ("laboratory_work_order_test_id")
        REFERENCES "diagnostics"."laboratory_work_order_tests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."result_verifications"
        ADD CONSTRAINT "fk_result_verifications_previous_verification_id" FOREIGN KEY ("previous_verification_id")
        REFERENCES "diagnostics"."result_verifications" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_imaging_study_id" FOREIGN KEY ("imaging_study_id")
        REFERENCES "diagnostics"."imaging_studies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selections"
        ADD CONSTRAINT "fk_imaging_selections_imaging_study_id" FOREIGN KEY ("imaging_study_id")
        REFERENCES "diagnostics"."imaging_studies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selection_items"
        ADD CONSTRAINT "fk_imaging_selection_items_imaging_selection_id" FOREIGN KEY ("imaging_selection_id")
        REFERENCES "diagnostics"."imaging_selections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selection_items"
        ADD CONSTRAINT "fk_imaging_selection_items_imaging_series_id" FOREIGN KEY ("imaging_series_id")
        REFERENCES "diagnostics"."imaging_series" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_selection_items"
        ADD CONSTRAINT "fk_imaging_selection_items_imaging_instance_id" FOREIGN KEY ("imaging_instance_id")
        REFERENCES "diagnostics"."imaging_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_object_locations"
        ADD CONSTRAINT "fk_dicom_object_locations_imaging_instance_id" FOREIGN KEY ("imaging_instance_id")
        REFERENCES "diagnostics"."imaging_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_imaging_study_id" FOREIGN KEY ("imaging_study_id")
        REFERENCES "diagnostics"."imaging_studies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."dicom_structured_reports"
        ADD CONSTRAINT "fk_dicom_structured_reports_imaging_instance_id" FOREIGN KEY ("imaging_instance_id")
        REFERENCES "diagnostics"."imaging_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."radiation_dose_events"
        ADD CONSTRAINT "fk_radiation_dose_events_imaging_study_id" FOREIGN KEY ("imaging_study_id")
        REFERENCES "diagnostics"."imaging_studies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "diagnostics"."radiation_dose_events"
        ADD CONSTRAINT "fk_radiation_dose_events_imaging_series_id" FOREIGN KEY ("imaging_series_id")
        REFERENCES "diagnostics"."imaging_series" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
