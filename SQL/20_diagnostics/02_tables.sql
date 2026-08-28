-- SALUD v4.0.10 · módulo 20 · schema diagnostics
-- Generado de diagram_20_diagnostics.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "diagnostics"."specimens" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "service_request_id" uuid,
    "encounter_id" uuid,
    "specimen_type_concept_id" uuid NOT NULL,
    "accession_identifier" varchar,
    "body_site_concept_id" uuid,
    "collection_method_concept_id" uuid,
    "collected_at" timestamptz,
    "received_at" timestamptz,
    "collector_profile_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "container_type_concept_id" uuid,
    "quantity_decimal" numeric,
    "quantity_unit_concept_id" uuid,
    "custodian_tenant_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_specimens" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_processing_steps" (
    "id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "procedure_concept_id" uuid NOT NULL,
    "additive_concept_id" uuid,
    "description" text,
    "performed_at" timestamptz,
    "performer_profile_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_specimen_processing_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."observation_specimens" (
    "id" uuid NOT NULL,
    "observation_id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "relationship_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_observation_specimens" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."diagnostic_report_versions" (
    "id" uuid NOT NULL,
    "diagnostic_report_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "clinical_status_concept_id" uuid NOT NULL,
    "conclusion_text" text,
    "issued_at" timestamptz,
    "performer_tenant_id" uuid,
    "author_profile_id" uuid,
    "supersedes_version_id" uuid,
    "amendment_reason_concept_id" uuid,
    "amendment_reason_text" text,
    "content_hash" varchar,
    "release_eligibility_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    "custodian_tenant_id" uuid NOT NULL,
    "source_system_id" uuid,
    "provenance_record_id" uuid,
    CONSTRAINT "pk_diagnostic_report_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."diagnostic_report_results" (
    "id" uuid NOT NULL,
    "diagnostic_report_version_id" uuid NOT NULL,
    "observation_id" uuid NOT NULL,
    "result_role_concept_id" uuid,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_diagnostic_report_results" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."diagnostic_report_files" (
    "id" uuid NOT NULL,
    "diagnostic_report_version_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "content_role_concept_id" uuid NOT NULL,
    "presentation_format_concept_id" uuid,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_diagnostic_report_files" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."imaging_endpoints" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "endpoint_type_concept_id" uuid NOT NULL,
    "base_uri" text NOT NULL,
    "connection_id" uuid,
    "storage_region_concept_id" uuid,
    "dicom_conformance_statement_uri" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_imaging_endpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."imaging_studies" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "service_request_id" uuid,
    "diagnostic_report_id" uuid,
    "imaging_endpoint_id" uuid NOT NULL,
    "dicom_study_instance_uid" varchar NOT NULL,
    "accession_number" varchar,
    "modality_value_set_id" uuid,
    "body_site_concept_id" uuid,
    "reason_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "number_of_series" integer,
    "number_of_instances" integer,
    "referring_practitioner_profile_id" uuid,
    "custodian_tenant_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_imaging_studies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."imaging_series" (
    "id" uuid NOT NULL,
    "imaging_study_id" uuid NOT NULL,
    "dicom_series_instance_uid" varchar NOT NULL,
    "modality_concept_id" uuid NOT NULL,
    "body_site_concept_id" uuid,
    "laterality_concept_id" uuid,
    "series_number" integer,
    "description" varchar,
    "number_of_instances" integer,
    "started_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_imaging_series" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."imaging_instances" (
    "id" uuid NOT NULL,
    "imaging_series_id" uuid NOT NULL,
    "dicom_sop_instance_uid" varchar NOT NULL,
    "sop_class_concept_id" uuid NOT NULL,
    "instance_number" integer,
    "frames_count" integer,
    "retrieval_uri" text,
    "metadata_hash" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_imaging_instances" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."clinical_media" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "diagnostic_report_id" uuid,
    "media_type_concept_id" uuid NOT NULL,
    "body_site_concept_id" uuid,
    "view_concept_id" uuid,
    "file_id" uuid NOT NULL,
    "captured_at" timestamptz,
    "captured_by_profile_id" uuid,
    "device_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "patient_visibility_concept_id" uuid,
    "custodian_tenant_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_clinical_media" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."media_annotations" (
    "id" uuid NOT NULL,
    "clinical_media_id" uuid NOT NULL,
    "imaging_instance_id" uuid,
    "annotation_type_concept_id" uuid NOT NULL,
    "geometry_json" jsonb,
    "label_concept_id" uuid,
    "label_text" varchar,
    "confidence_score" numeric,
    "author_profile_id" uuid,
    "algorithm_model_reference" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_media_annotations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."diagnostic_release_events" (
    "id" uuid NOT NULL,
    "diagnostic_report_version_id" uuid,
    "imaging_study_id" uuid,
    "action_concept_id" uuid NOT NULL,
    "patient_visibility_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "policy_version" varchar,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_diagnostic_release_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_identifiers" (
    "id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "identifier_system" varchar NOT NULL,
    "identifier_value" varchar NOT NULL,
    "identifier_type_concept_id" uuid NOT NULL,
    "assigning_organization_id" uuid,
    "is_primary" boolean NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_specimen_identifiers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_parent_links" (
    "id" uuid NOT NULL,
    "child_specimen_id" uuid NOT NULL,
    "parent_specimen_id" uuid NOT NULL,
    "relationship_type_concept_id" uuid NOT NULL,
    "quantity_decimal" numeric(20,6),
    "quantity_unit_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_specimen_parent_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_collection_events" (
    "id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "collector_profile_id" uuid,
    "collection_site_id" uuid,
    "body_site_concept_id" uuid,
    "method_concept_id" uuid,
    "fasting_status_concept_id" uuid,
    "condition_json" jsonb,
    "notes" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_specimen_collection_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_containers" (
    "id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "container_identifier" varchar NOT NULL,
    "container_type_concept_id" uuid NOT NULL,
    "additive_concept_id" uuid,
    "capacity_decimal" numeric(20,6),
    "capacity_unit_concept_id" uuid,
    "specimen_quantity_decimal" numeric(20,6),
    "specimen_quantity_unit_concept_id" uuid,
    "parent_container_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_specimen_containers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_container_events" (
    "id" uuid NOT NULL,
    "specimen_container_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "source_location_id" uuid,
    "destination_location_id" uuid,
    "actor_profile_id" uuid,
    "temperature_celsius" numeric(8,3),
    "condition_json" jsonb,
    "notes" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_specimen_container_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_chain_of_custody_events" (
    "id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "specimen_container_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    "custody_event_type_concept_id" uuid NOT NULL,
    "from_party_type_concept_id" uuid,
    "from_party_id" uuid,
    "to_party_type_concept_id" uuid,
    "to_party_id" uuid,
    "location_id" uuid,
    "seal_identifier" varchar,
    "evidence_hash" varchar,
    "signed_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_specimen_chain_of_custody_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."specimen_rejection_events" (
    "id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "rejected_at" timestamptz NOT NULL,
    "rejection_reason_concept_id" uuid NOT NULL,
    "rejected_by_profile_id" uuid,
    "notes" text,
    "recollection_required" boolean,
    "recollection_service_request_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_specimen_rejection_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."laboratory_accessions" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "service_request_id" uuid,
    "accession_number" varchar NOT NULL,
    "received_at" timestamptz NOT NULL,
    "receiving_site_id" uuid,
    "laboratory_unit_id" uuid,
    "priority_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "source_system_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_laboratory_accessions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."accession_specimens" (
    "id" uuid NOT NULL,
    "laboratory_accession_id" uuid NOT NULL,
    "specimen_id" uuid NOT NULL,
    "sequence_number" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_accession_specimens" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."laboratory_work_orders" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "laboratory_accession_id" uuid NOT NULL,
    "work_order_number" varchar NOT NULL,
    "assigned_laboratory_unit_id" uuid,
    "assigned_profile_id" uuid,
    "priority_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "scheduled_at" timestamptz,
    "started_at" timestamptz,
    "completed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_laboratory_work_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."laboratory_work_order_tests" (
    "id" uuid NOT NULL,
    "laboratory_work_order_id" uuid NOT NULL,
    "service_request_id" uuid NOT NULL,
    "test_code_concept_id" uuid NOT NULL,
    "specimen_id" uuid,
    "method_concept_id" uuid,
    "analyzer_device_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "completed_at" timestamptz,
    "observation_id" uuid,
    "diagnostic_report_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_laboratory_work_order_tests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."analyzer_runs" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "analyzer_device_id" uuid NOT NULL,
    "run_identifier" varchar NOT NULL,
    "reagent_lot_id" uuid,
    "calibration_reference" varchar,
    "quality_control_run_id" uuid,
    "started_at" timestamptz NOT NULL,
    "ended_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "operator_profile_id" uuid,
    "metadata_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_analyzer_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."analyzer_result_messages" (
    "id" uuid NOT NULL,
    "analyzer_run_id" uuid NOT NULL,
    "laboratory_work_order_test_id" uuid,
    "received_at" timestamptz NOT NULL,
    "message_format_concept_id" uuid NOT NULL,
    "message_control_id" varchar,
    "raw_message_file_id" uuid,
    "payload_hash" varchar NOT NULL,
    "validation_status_concept_id" uuid NOT NULL,
    "mapped_observation_id" uuid,
    "processing_error_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_analyzer_result_messages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."result_verifications" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "verifiable_type_concept_id" uuid NOT NULL,
    "verifiable_id" uuid NOT NULL,
    "verification_level_concept_id" uuid NOT NULL,
    "result_concept_id" uuid NOT NULL,
    "verified_by_profile_id" uuid NOT NULL,
    "verified_at" timestamptz NOT NULL,
    "verification_comment" text,
    "previous_verification_id" uuid,
    "signature_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_result_verifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."critical_result_notifications" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "observation_id" uuid NOT NULL,
    "diagnostic_report_id" uuid,
    "criticality_concept_id" uuid NOT NULL,
    "detected_at" timestamptz NOT NULL,
    "detected_by_profile_id" uuid,
    "notification_status_concept_id" uuid NOT NULL,
    "notified_profile_id" uuid,
    "notified_at" timestamptz,
    "acknowledged_by_profile_id" uuid,
    "acknowledged_at" timestamptz,
    "escalation_policy_id" uuid,
    "escalation_due_at" timestamptz,
    "communication_evidence_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_critical_result_notifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."imaging_procedure_steps" (
    "id" uuid NOT NULL,
    "imaging_study_id" uuid NOT NULL,
    "procedure_id" uuid,
    "step_number" integer NOT NULL,
    "code_concept_id" uuid NOT NULL,
    "modality_concept_id" uuid,
    "body_site_concept_id" uuid,
    "performed_by_profile_id" uuid,
    "started_at" timestamptz,
    "ended_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "protocol_reference" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_imaging_procedure_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."imaging_selections" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "imaging_study_id" uuid NOT NULL,
    "selection_uid" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "author_profile_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_imaging_selections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."imaging_selection_items" (
    "id" uuid NOT NULL,
    "imaging_selection_id" uuid NOT NULL,
    "imaging_series_id" uuid,
    "imaging_instance_id" uuid,
    "frames_json" jsonb,
    "region_of_interest_json" jsonb,
    "order_index" integer,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_imaging_selection_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."dicom_object_locations" (
    "id" uuid NOT NULL,
    "imaging_instance_id" uuid NOT NULL,
    "storage_backend_id" uuid NOT NULL,
    "object_key" varchar NOT NULL,
    "object_version_id" varchar,
    "transfer_syntax_uid" varchar,
    "content_hash" varchar NOT NULL,
    "size_bytes" bigint NOT NULL,
    "encryption_profile_id" uuid,
    "retention_policy_id" uuid,
    "legal_hold_id" uuid,
    "is_primary" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dicom_object_locations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."dicom_structured_reports" (
    "id" uuid NOT NULL,
    "imaging_study_id" uuid NOT NULL,
    "imaging_instance_id" uuid,
    "sop_instance_uid" varchar NOT NULL,
    "document_title_concept_id" uuid NOT NULL,
    "diagnostic_report_id" uuid,
    "file_id" uuid,
    "content_hash" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "verified_by_profile_id" uuid,
    "verified_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dicom_structured_reports" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."radiation_dose_events" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "imaging_study_id" uuid NOT NULL,
    "imaging_series_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "dose_length_product" numeric(20,6),
    "computed_tomography_dose_index" numeric(20,6),
    "dose_area_product" numeric(20,6),
    "effective_dose_msv" numeric(20,6),
    "unit_concept_id" uuid,
    "source_sop_instance_uid" varchar,
    "device_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_radiation_dose_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."diagnostic_data_quality_events" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "rule_code" varchar NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "details_json" jsonb,
    "resolution_text" text,
    "resolved_at" timestamptz,
    "resolved_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_diagnostic_data_quality_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."diagnostic_provenance_links" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "source_id" uuid NOT NULL,
    "activity_concept_id" uuid NOT NULL,
    "agent_profile_id" uuid,
    "source_system_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "content_hash" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_diagnostic_provenance_links" PRIMARY KEY ("id")
);
