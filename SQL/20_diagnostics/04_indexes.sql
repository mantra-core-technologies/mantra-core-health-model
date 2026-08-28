-- SALUD v4.0.10 · módulo 20 · schema diagnostics
-- Generado de diagram_20_diagnostics.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_specimens_patient_profile_id" ON "diagnostics"."specimens" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_service_request_id" ON "diagnostics"."specimens" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_encounter_id" ON "diagnostics"."specimens" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_specimen_type_concept_id" ON "diagnostics"."specimens" ("specimen_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_body_site_concept_id" ON "diagnostics"."specimens" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_collection_method_concept_id" ON "diagnostics"."specimens" ("collection_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_collector_profile_id" ON "diagnostics"."specimens" ("collector_profile_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_status_concept_id" ON "diagnostics"."specimens" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_container_type_concept_id" ON "diagnostics"."specimens" ("container_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_quantity_unit_concept_id" ON "diagnostics"."specimens" ("quantity_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_created_by_user_id" ON "diagnostics"."specimens" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_updated_by_user_id" ON "diagnostics"."specimens" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_specimens_patient_profile_id_updated_at" ON "diagnostics"."specimens" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_specimens_custodian_tenant_id" ON "diagnostics"."specimens" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_processing_steps_specimen_id" ON "diagnostics"."specimen_processing_steps" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_processing_steps_procedure_concept_id" ON "diagnostics"."specimen_processing_steps" ("procedure_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_processing_steps_additive_concept_id" ON "diagnostics"."specimen_processing_steps" ("additive_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_processing_steps_performer_profile_id" ON "diagnostics"."specimen_processing_steps" ("performer_profile_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_processing_steps_created_by_user_id" ON "diagnostics"."specimen_processing_steps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_observation_specimens_observation_id" ON "diagnostics"."observation_specimens" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_observation_specimens_specimen_id" ON "diagnostics"."observation_specimens" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_observation_specimens_relationship_concept_id" ON "diagnostics"."observation_specimens" ("relationship_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_diagnostic_report_id" ON "diagnostics"."diagnostic_report_versions" ("diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_clinical_status_concept_id" ON "diagnostics"."diagnostic_report_versions" ("clinical_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_performer_tenant_id" ON "diagnostics"."diagnostic_report_versions" ("performer_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_author_profile_id" ON "diagnostics"."diagnostic_report_versions" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_supersedes_version_id" ON "diagnostics"."diagnostic_report_versions" ("supersedes_version_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_amendment_reason_concept_id" ON "diagnostics"."diagnostic_report_versions" ("amendment_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_release_eligibility_concept_id" ON "diagnostics"."diagnostic_report_versions" ("release_eligibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_recorded_by_user_id" ON "diagnostics"."diagnostic_report_versions" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_diagnostic_report_versions_diagnostic_report_id_ver_f2f11b3b" ON "diagnostics"."diagnostic_report_versions" ("diagnostic_report_id", "version_number");

CREATE INDEX IF NOT EXISTS "brin_diagnostic_report_versions_recorded_at" ON "diagnostics"."diagnostic_report_versions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_tenant_report" ON "diagnostics"."diagnostic_report_versions" ("custodian_tenant_id", "diagnostic_report_id", "version_number" DESC);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_versions_source_system" ON "diagnostics"."diagnostic_report_versions" ("source_system_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_results_diagnostic_report_version_id" ON "diagnostics"."diagnostic_report_results" ("diagnostic_report_version_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_results_observation_id" ON "diagnostics"."diagnostic_report_results" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_results_result_role_concept_id" ON "diagnostics"."diagnostic_report_results" ("result_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_files_diagnostic_report_version_id" ON "diagnostics"."diagnostic_report_files" ("diagnostic_report_version_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_files_file_id" ON "diagnostics"."diagnostic_report_files" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_files_content_role_concept_id" ON "diagnostics"."diagnostic_report_files" ("content_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_files_presentation_format_concept_id" ON "diagnostics"."diagnostic_report_files" ("presentation_format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_report_files_created_by_user_id" ON "diagnostics"."diagnostic_report_files" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_tenant_id" ON "diagnostics"."imaging_endpoints" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_endpoint_type_concept_id" ON "diagnostics"."imaging_endpoints" ("endpoint_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_connection_id" ON "diagnostics"."imaging_endpoints" ("connection_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_storage_region_concept_id" ON "diagnostics"."imaging_endpoints" ("storage_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_status_concept_id" ON "diagnostics"."imaging_endpoints" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_created_by_user_id" ON "diagnostics"."imaging_endpoints" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_updated_by_user_id" ON "diagnostics"."imaging_endpoints" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_endpoints_tenant_id_status_concept_id" ON "diagnostics"."imaging_endpoints" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_imaging_studies_dicom_study_instance_uid" ON "diagnostics"."imaging_studies" ("dicom_study_instance_uid");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_patient_profile_id" ON "diagnostics"."imaging_studies" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_encounter_id" ON "diagnostics"."imaging_studies" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_service_request_id" ON "diagnostics"."imaging_studies" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_diagnostic_report_id" ON "diagnostics"."imaging_studies" ("diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_imaging_endpoint_id" ON "diagnostics"."imaging_studies" ("imaging_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_modality_value_set_id" ON "diagnostics"."imaging_studies" ("modality_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_body_site_concept_id" ON "diagnostics"."imaging_studies" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_reason_concept_id" ON "diagnostics"."imaging_studies" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_status_concept_id" ON "diagnostics"."imaging_studies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_referring_practitioner_profile_id" ON "diagnostics"."imaging_studies" ("referring_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_created_by_user_id" ON "diagnostics"."imaging_studies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_updated_by_user_id" ON "diagnostics"."imaging_studies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_patient_profile_id_updated_at" ON "diagnostics"."imaging_studies" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_imaging_studies_custodian_tenant_id" ON "diagnostics"."imaging_studies" ("custodian_tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_imaging_series_dicom_series_instance_uid" ON "diagnostics"."imaging_series" ("dicom_series_instance_uid");

CREATE INDEX IF NOT EXISTS "ix_imaging_series_imaging_study_id" ON "diagnostics"."imaging_series" ("imaging_study_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_series_modality_concept_id" ON "diagnostics"."imaging_series" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_series_body_site_concept_id" ON "diagnostics"."imaging_series" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_series_laterality_concept_id" ON "diagnostics"."imaging_series" ("laterality_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_imaging_instances_dicom_sop_instance_uid" ON "diagnostics"."imaging_instances" ("dicom_sop_instance_uid");

CREATE INDEX IF NOT EXISTS "ix_imaging_instances_imaging_series_id" ON "diagnostics"."imaging_instances" ("imaging_series_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_instances_sop_class_concept_id" ON "diagnostics"."imaging_instances" ("sop_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_patient_profile_id" ON "diagnostics"."clinical_media" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_encounter_id" ON "diagnostics"."clinical_media" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_diagnostic_report_id" ON "diagnostics"."clinical_media" ("diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_media_type_concept_id" ON "diagnostics"."clinical_media" ("media_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_body_site_concept_id" ON "diagnostics"."clinical_media" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_view_concept_id" ON "diagnostics"."clinical_media" ("view_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_file_id" ON "diagnostics"."clinical_media" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_captured_by_profile_id" ON "diagnostics"."clinical_media" ("captured_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_device_id" ON "diagnostics"."clinical_media" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_status_concept_id" ON "diagnostics"."clinical_media" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_patient_visibility_concept_id" ON "diagnostics"."clinical_media" ("patient_visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_created_by_user_id" ON "diagnostics"."clinical_media" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_updated_by_user_id" ON "diagnostics"."clinical_media" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_media_patient_profile_id_updated_at" ON "diagnostics"."clinical_media" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_clinical_media_custodian_tenant_id" ON "diagnostics"."clinical_media" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_clinical_media_id" ON "diagnostics"."media_annotations" ("clinical_media_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_imaging_instance_id" ON "diagnostics"."media_annotations" ("imaging_instance_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_annotation_type_concept_id" ON "diagnostics"."media_annotations" ("annotation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_label_concept_id" ON "diagnostics"."media_annotations" ("label_concept_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_author_profile_id" ON "diagnostics"."media_annotations" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_status_concept_id" ON "diagnostics"."media_annotations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_created_by_user_id" ON "diagnostics"."media_annotations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_media_annotations_updated_by_user_id" ON "diagnostics"."media_annotations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_release_events_diagnostic_report_version_id" ON "diagnostics"."diagnostic_release_events" ("diagnostic_report_version_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_release_events_imaging_study_id" ON "diagnostics"."diagnostic_release_events" ("imaging_study_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_release_events_action_concept_id" ON "diagnostics"."diagnostic_release_events" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_release_events_patient_visibility_concept_id" ON "diagnostics"."diagnostic_release_events" ("patient_visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_release_events_reason_concept_id" ON "diagnostics"."diagnostic_release_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_release_events_recorded_by_user_id" ON "diagnostics"."diagnostic_release_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_diagnostic_release_events_recorded_at" ON "diagnostics"."diagnostic_release_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_specimen_identifiers_specimen_id" ON "diagnostics"."specimen_identifiers" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_identifiers_identifier_type_concept_id" ON "diagnostics"."specimen_identifiers" ("identifier_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_identifiers_assigning_organization_id" ON "diagnostics"."specimen_identifiers" ("assigning_organization_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_identifiers_created_by_user_id" ON "diagnostics"."specimen_identifiers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_identifiers_updated_by_user_id" ON "diagnostics"."specimen_identifiers" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_specimen_identifiers_system_value" ON "diagnostics"."specimen_identifiers" ("identifier_system", "identifier_value");

CREATE INDEX IF NOT EXISTS "ix_specimen_parent_links_child_specimen_id" ON "diagnostics"."specimen_parent_links" ("child_specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_parent_links_parent_specimen_id" ON "diagnostics"."specimen_parent_links" ("parent_specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_parent_links_relationship_type_concept_id" ON "diagnostics"."specimen_parent_links" ("relationship_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_parent_links_quantity_unit_concept_id" ON "diagnostics"."specimen_parent_links" ("quantity_unit_concept_id");

CREATE INDEX IF NOT EXISTS "brin_specimen_parent_links_created_at" ON "diagnostics"."specimen_parent_links" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_specimen_parent_links_pair_type" ON "diagnostics"."specimen_parent_links" ("child_specimen_id", "parent_specimen_id", "relationship_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_specimen_id" ON "diagnostics"."specimen_collection_events" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_event_type_concept_id" ON "diagnostics"."specimen_collection_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_collector_profile_id" ON "diagnostics"."specimen_collection_events" ("collector_profile_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_collection_site_id" ON "diagnostics"."specimen_collection_events" ("collection_site_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_body_site_concept_id" ON "diagnostics"."specimen_collection_events" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_method_concept_id" ON "diagnostics"."specimen_collection_events" ("method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_fasting_status_concept_id" ON "diagnostics"."specimen_collection_events" ("fasting_status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_specimen_collection_events_occurred_at" ON "diagnostics"."specimen_collection_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_specimen_id" ON "diagnostics"."specimen_containers" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_container_type_concept_id" ON "diagnostics"."specimen_containers" ("container_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_additive_concept_id" ON "diagnostics"."specimen_containers" ("additive_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_capacity_unit_concept_id" ON "diagnostics"."specimen_containers" ("capacity_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_specimen_quantity_unit_concept_id" ON "diagnostics"."specimen_containers" ("specimen_quantity_unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_parent_container_id" ON "diagnostics"."specimen_containers" ("parent_container_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_status_concept_id" ON "diagnostics"."specimen_containers" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_created_by_user_id" ON "diagnostics"."specimen_containers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_containers_updated_by_user_id" ON "diagnostics"."specimen_containers" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_specimen_containers_specimen_identifier" ON "diagnostics"."specimen_containers" ("specimen_id", "container_identifier");

CREATE INDEX IF NOT EXISTS "ix_specimen_container_events_specimen_container_id" ON "diagnostics"."specimen_container_events" ("specimen_container_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_container_events_event_type_concept_id" ON "diagnostics"."specimen_container_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_container_events_source_location_id" ON "diagnostics"."specimen_container_events" ("source_location_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_container_events_destination_location_id" ON "diagnostics"."specimen_container_events" ("destination_location_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_container_events_actor_profile_id" ON "diagnostics"."specimen_container_events" ("actor_profile_id");

CREATE INDEX IF NOT EXISTS "brin_specimen_container_events_occurred_at" ON "diagnostics"."specimen_container_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_specimen_id" ON "diagnostics"."specimen_chain_of_custody_events" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_specimen_container_id" ON "diagnostics"."specimen_chain_of_custody_events" ("specimen_container_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_custody_event_type_cbadcc6c" ON "diagnostics"."specimen_chain_of_custody_events" ("custody_event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_from_party_type_concept_id" ON "diagnostics"."specimen_chain_of_custody_events" ("from_party_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_from_party_id" ON "diagnostics"."specimen_chain_of_custody_events" ("from_party_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_to_party_type_concept_id" ON "diagnostics"."specimen_chain_of_custody_events" ("to_party_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_to_party_id" ON "diagnostics"."specimen_chain_of_custody_events" ("to_party_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_location_id" ON "diagnostics"."specimen_chain_of_custody_events" ("location_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_chain_of_custody_events_signed_by_user_id" ON "diagnostics"."specimen_chain_of_custody_events" ("signed_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_specimen_chain_of_custody_events_occurred_at" ON "diagnostics"."specimen_chain_of_custody_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_specimen_rejection_events_specimen_id" ON "diagnostics"."specimen_rejection_events" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_rejection_events_rejection_reason_concept_id" ON "diagnostics"."specimen_rejection_events" ("rejection_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_rejection_events_rejected_by_profile_id" ON "diagnostics"."specimen_rejection_events" ("rejected_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_specimen_rejection_events_recollection_service_request_id" ON "diagnostics"."specimen_rejection_events" ("recollection_service_request_id");

CREATE INDEX IF NOT EXISTS "brin_specimen_rejection_events_created_at" ON "diagnostics"."specimen_rejection_events" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_custodian_tenant_id" ON "diagnostics"."laboratory_accessions" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_patient_profile_id" ON "diagnostics"."laboratory_accessions" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_encounter_id" ON "diagnostics"."laboratory_accessions" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_service_request_id" ON "diagnostics"."laboratory_accessions" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_receiving_site_id" ON "diagnostics"."laboratory_accessions" ("receiving_site_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_laboratory_unit_id" ON "diagnostics"."laboratory_accessions" ("laboratory_unit_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_priority_concept_id" ON "diagnostics"."laboratory_accessions" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_status_concept_id" ON "diagnostics"."laboratory_accessions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_source_system_id" ON "diagnostics"."laboratory_accessions" ("source_system_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_created_by_user_id" ON "diagnostics"."laboratory_accessions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_updated_by_user_id" ON "diagnostics"."laboratory_accessions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_laboratory_accessions_tenant_number" ON "diagnostics"."laboratory_accessions" ("custodian_tenant_id", "accession_number");

CREATE INDEX IF NOT EXISTS "ix_laboratory_accessions_patient_received" ON "diagnostics"."laboratory_accessions" ("custodian_tenant_id", "patient_profile_id", "received_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_accession_specimens_laboratory_accession_id" ON "diagnostics"."accession_specimens" ("laboratory_accession_id");

CREATE INDEX IF NOT EXISTS "ix_accession_specimens_specimen_id" ON "diagnostics"."accession_specimens" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_accession_specimens_status_concept_id" ON "diagnostics"."accession_specimens" ("status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_accession_specimens_accession_specimen" ON "diagnostics"."accession_specimens" ("laboratory_accession_id", "specimen_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_custodian_tenant_id" ON "diagnostics"."laboratory_work_orders" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_laboratory_accession_id" ON "diagnostics"."laboratory_work_orders" ("laboratory_accession_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_assigned_laboratory_unit_id" ON "diagnostics"."laboratory_work_orders" ("assigned_laboratory_unit_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_assigned_profile_id" ON "diagnostics"."laboratory_work_orders" ("assigned_profile_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_priority_concept_id" ON "diagnostics"."laboratory_work_orders" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_status_concept_id" ON "diagnostics"."laboratory_work_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_created_by_user_id" ON "diagnostics"."laboratory_work_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_orders_updated_by_user_id" ON "diagnostics"."laboratory_work_orders" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lab_work_orders_tenant_number" ON "diagnostics"."laboratory_work_orders" ("custodian_tenant_id", "work_order_number");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_laboratory_work_order_id" ON "diagnostics"."laboratory_work_order_tests" ("laboratory_work_order_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_service_request_id" ON "diagnostics"."laboratory_work_order_tests" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_test_code_concept_id" ON "diagnostics"."laboratory_work_order_tests" ("test_code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_specimen_id" ON "diagnostics"."laboratory_work_order_tests" ("specimen_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_method_concept_id" ON "diagnostics"."laboratory_work_order_tests" ("method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_analyzer_device_id" ON "diagnostics"."laboratory_work_order_tests" ("analyzer_device_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_status_concept_id" ON "diagnostics"."laboratory_work_order_tests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_observation_id" ON "diagnostics"."laboratory_work_order_tests" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_diagnostic_report_id" ON "diagnostics"."laboratory_work_order_tests" ("diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_created_by_user_id" ON "diagnostics"."laboratory_work_order_tests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_laboratory_work_order_tests_updated_by_user_id" ON "diagnostics"."laboratory_work_order_tests" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lab_work_order_tests_order_request_code" ON "diagnostics"."laboratory_work_order_tests" ("laboratory_work_order_id", "service_request_id", "test_code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_runs_custodian_tenant_id" ON "diagnostics"."analyzer_runs" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_runs_analyzer_device_id" ON "diagnostics"."analyzer_runs" ("analyzer_device_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_runs_reagent_lot_id" ON "diagnostics"."analyzer_runs" ("reagent_lot_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_runs_quality_control_run_id" ON "diagnostics"."analyzer_runs" ("quality_control_run_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_runs_status_concept_id" ON "diagnostics"."analyzer_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_runs_operator_profile_id" ON "diagnostics"."analyzer_runs" ("operator_profile_id");

CREATE INDEX IF NOT EXISTS "brin_analyzer_runs_created_at" ON "diagnostics"."analyzer_runs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_analyzer_runs_device_identifier" ON "diagnostics"."analyzer_runs" ("analyzer_device_id", "run_identifier");

CREATE INDEX IF NOT EXISTS "ix_analyzer_result_messages_analyzer_run_id" ON "diagnostics"."analyzer_result_messages" ("analyzer_run_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_result_messages_laboratory_work_order_test_id" ON "diagnostics"."analyzer_result_messages" ("laboratory_work_order_test_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_result_messages_message_format_concept_id" ON "diagnostics"."analyzer_result_messages" ("message_format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_result_messages_message_control_id" ON "diagnostics"."analyzer_result_messages" ("message_control_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_result_messages_raw_message_file_id" ON "diagnostics"."analyzer_result_messages" ("raw_message_file_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_result_messages_validation_status_concept_id" ON "diagnostics"."analyzer_result_messages" ("validation_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_analyzer_result_messages_mapped_observation_id" ON "diagnostics"."analyzer_result_messages" ("mapped_observation_id");

CREATE INDEX IF NOT EXISTS "brin_analyzer_result_messages_created_at" ON "diagnostics"."analyzer_result_messages" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_analyzer_result_messages_run_control" ON "diagnostics"."analyzer_result_messages" ("analyzer_run_id", "message_control_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_custodian_tenant_id" ON "diagnostics"."result_verifications" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_verifiable_type_concept_id" ON "diagnostics"."result_verifications" ("verifiable_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_verifiable_id" ON "diagnostics"."result_verifications" ("verifiable_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_verification_level_concept_id" ON "diagnostics"."result_verifications" ("verification_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_result_concept_id" ON "diagnostics"."result_verifications" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_verified_by_profile_id" ON "diagnostics"."result_verifications" ("verified_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_previous_verification_id" ON "diagnostics"."result_verifications" ("previous_verification_id");

CREATE INDEX IF NOT EXISTS "ix_result_verifications_signature_id" ON "diagnostics"."result_verifications" ("signature_id");

CREATE INDEX IF NOT EXISTS "brin_result_verifications_created_at" ON "diagnostics"."result_verifications" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_result_verifications_target" ON "diagnostics"."result_verifications" ("verifiable_type_concept_id", "verifiable_id", "verified_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_custodian_tenant_id" ON "diagnostics"."critical_result_notifications" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_patient_profile_id" ON "diagnostics"."critical_result_notifications" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_observation_id" ON "diagnostics"."critical_result_notifications" ("observation_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_diagnostic_report_id" ON "diagnostics"."critical_result_notifications" ("diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_criticality_concept_id" ON "diagnostics"."critical_result_notifications" ("criticality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_detected_by_profile_id" ON "diagnostics"."critical_result_notifications" ("detected_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_notification_status_concept_id" ON "diagnostics"."critical_result_notifications" ("notification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_notified_profile_id" ON "diagnostics"."critical_result_notifications" ("notified_profile_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_acknowledged_by_profile_id" ON "diagnostics"."critical_result_notifications" ("acknowledged_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_escalation_policy_id" ON "diagnostics"."critical_result_notifications" ("escalation_policy_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_communication_evidence_id" ON "diagnostics"."critical_result_notifications" ("communication_evidence_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_created_by_user_id" ON "diagnostics"."critical_result_notifications" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_critical_result_notifications_updated_by_user_id" ON "diagnostics"."critical_result_notifications" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_critical_results_patient_status_detected" ON "diagnostics"."critical_result_notifications" ("custodian_tenant_id", "patient_profile_id", "notification_status_concept_id", "detected_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_imaging_study_id" ON "diagnostics"."imaging_procedure_steps" ("imaging_study_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_procedure_id" ON "diagnostics"."imaging_procedure_steps" ("procedure_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_code_concept_id" ON "diagnostics"."imaging_procedure_steps" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_modality_concept_id" ON "diagnostics"."imaging_procedure_steps" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_body_site_concept_id" ON "diagnostics"."imaging_procedure_steps" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_performed_by_profile_id" ON "diagnostics"."imaging_procedure_steps" ("performed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_status_concept_id" ON "diagnostics"."imaging_procedure_steps" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_created_by_user_id" ON "diagnostics"."imaging_procedure_steps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_updated_by_user_id" ON "diagnostics"."imaging_procedure_steps" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_imaging_procedure_steps_study_step" ON "diagnostics"."imaging_procedure_steps" ("imaging_study_id", "step_number");

CREATE INDEX IF NOT EXISTS "ix_imaging_selections_custodian_tenant_id" ON "diagnostics"."imaging_selections" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selections_imaging_study_id" ON "diagnostics"."imaging_selections" ("imaging_study_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selections_author_profile_id" ON "diagnostics"."imaging_selections" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selections_status_concept_id" ON "diagnostics"."imaging_selections" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selections_created_by_user_id" ON "diagnostics"."imaging_selections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selections_updated_by_user_id" ON "diagnostics"."imaging_selections" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_imaging_selections_study_uid" ON "diagnostics"."imaging_selections" ("imaging_study_id", "selection_uid");

CREATE INDEX IF NOT EXISTS "ix_imaging_selection_items_imaging_selection_id" ON "diagnostics"."imaging_selection_items" ("imaging_selection_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selection_items_imaging_series_id" ON "diagnostics"."imaging_selection_items" ("imaging_series_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selection_items_imaging_instance_id" ON "diagnostics"."imaging_selection_items" ("imaging_instance_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_selection_items_selection_order" ON "diagnostics"."imaging_selection_items" ("imaging_selection_id", "order_index");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_imaging_instance_id" ON "diagnostics"."dicom_object_locations" ("imaging_instance_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_storage_backend_id" ON "diagnostics"."dicom_object_locations" ("storage_backend_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_object_version_id" ON "diagnostics"."dicom_object_locations" ("object_version_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_encryption_profile_id" ON "diagnostics"."dicom_object_locations" ("encryption_profile_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_retention_policy_id" ON "diagnostics"."dicom_object_locations" ("retention_policy_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_legal_hold_id" ON "diagnostics"."dicom_object_locations" ("legal_hold_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_status_concept_id" ON "diagnostics"."dicom_object_locations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_created_by_user_id" ON "diagnostics"."dicom_object_locations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_object_locations_updated_by_user_id" ON "diagnostics"."dicom_object_locations" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_dicom_object_locations_backend_key_version" ON "diagnostics"."dicom_object_locations" ("storage_backend_id", "object_key", "object_version_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_imaging_study_id" ON "diagnostics"."dicom_structured_reports" ("imaging_study_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_imaging_instance_id" ON "diagnostics"."dicom_structured_reports" ("imaging_instance_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_document_title_concept_id" ON "diagnostics"."dicom_structured_reports" ("document_title_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_diagnostic_report_id" ON "diagnostics"."dicom_structured_reports" ("diagnostic_report_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_file_id" ON "diagnostics"."dicom_structured_reports" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_status_concept_id" ON "diagnostics"."dicom_structured_reports" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_verified_by_profile_id" ON "diagnostics"."dicom_structured_reports" ("verified_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_created_by_user_id" ON "diagnostics"."dicom_structured_reports" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dicom_structured_reports_updated_by_user_id" ON "diagnostics"."dicom_structured_reports" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_dicom_structured_reports_sop_uid" ON "diagnostics"."dicom_structured_reports" ("sop_instance_uid");

CREATE INDEX IF NOT EXISTS "ix_radiation_dose_events_custodian_tenant_id" ON "diagnostics"."radiation_dose_events" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_radiation_dose_events_patient_profile_id" ON "diagnostics"."radiation_dose_events" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_radiation_dose_events_imaging_study_id" ON "diagnostics"."radiation_dose_events" ("imaging_study_id");

CREATE INDEX IF NOT EXISTS "ix_radiation_dose_events_imaging_series_id" ON "diagnostics"."radiation_dose_events" ("imaging_series_id");

CREATE INDEX IF NOT EXISTS "ix_radiation_dose_events_unit_concept_id" ON "diagnostics"."radiation_dose_events" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_radiation_dose_events_device_id" ON "diagnostics"."radiation_dose_events" ("device_id");

CREATE INDEX IF NOT EXISTS "brin_radiation_dose_events_recorded_at" ON "diagnostics"."radiation_dose_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_radiation_dose_patient_time" ON "diagnostics"."radiation_dose_events" ("custodian_tenant_id", "patient_profile_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_data_quality_events_custodian_tenant_id" ON "diagnostics"."diagnostic_data_quality_events" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_data_quality_events_target_type_concept_id" ON "diagnostics"."diagnostic_data_quality_events" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_data_quality_events_target_id" ON "diagnostics"."diagnostic_data_quality_events" ("target_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_data_quality_events_severity_concept_id" ON "diagnostics"."diagnostic_data_quality_events" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_data_quality_events_status_concept_id" ON "diagnostics"."diagnostic_data_quality_events" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_data_quality_events_resolved_by_user_id" ON "diagnostics"."diagnostic_data_quality_events" ("resolved_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_diagnostic_data_quality_events_occurred_at" ON "diagnostics"."diagnostic_data_quality_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_quality_target" ON "diagnostics"."diagnostic_data_quality_events" ("target_type_concept_id", "target_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_custodian_tenant_id" ON "diagnostics"."diagnostic_provenance_links" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_target_type_concept_id" ON "diagnostics"."diagnostic_provenance_links" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_target_id" ON "diagnostics"."diagnostic_provenance_links" ("target_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_source_type_concept_id" ON "diagnostics"."diagnostic_provenance_links" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_source_id" ON "diagnostics"."diagnostic_provenance_links" ("source_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_activity_concept_id" ON "diagnostics"."diagnostic_provenance_links" ("activity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_agent_profile_id" ON "diagnostics"."diagnostic_provenance_links" ("agent_profile_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_links_source_system_id" ON "diagnostics"."diagnostic_provenance_links" ("source_system_id");

CREATE INDEX IF NOT EXISTS "brin_diagnostic_provenance_links_recorded_at" ON "diagnostics"."diagnostic_provenance_links" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_target" ON "diagnostics"."diagnostic_provenance_links" ("target_type_concept_id", "target_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_diagnostic_provenance_source" ON "diagnostics"."diagnostic_provenance_links" ("source_type_concept_id", "source_id");
