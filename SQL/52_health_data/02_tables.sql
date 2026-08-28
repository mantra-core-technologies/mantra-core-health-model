-- SALUD v4.0.10 · módulo 52 · schema health_data
-- Generado de diagram_52_health_data_platform.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "health_data"."health_source_systems" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "organization_id" uuid,
    "vendor_name" varchar,
    "product_name" varchar,
    "version" varchar,
    "base_url" varchar,
    "trust_level_concept_id" uuid NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_source_systems" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_source_connections" (
    "id" uuid NOT NULL,
    "health_source_system_id" uuid NOT NULL,
    "connection_type_concept_id" uuid NOT NULL,
    "endpoint_uri" varchar NOT NULL,
    "credential_id" uuid,
    "network_policy_id" uuid,
    "format_concept_id" uuid,
    "poll_schedule" varchar,
    "cursor_strategy_concept_id" uuid,
    "last_success_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_source_connections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_ingestion_batches" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "health_source_connection_id" uuid NOT NULL,
    "batch_identifier" varchar NOT NULL,
    "ingestion_mode_concept_id" uuid NOT NULL,
    "received_at" timestamptz NOT NULL,
    "source_period_start" timestamptz,
    "source_period_end" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "records_received" bigint,
    "records_accepted" bigint,
    "records_rejected" bigint,
    "payload_manifest_file_id" uuid,
    "content_hash" varchar,
    "completed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_ingestion_batches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_ingestion_records" (
    "id" uuid NOT NULL,
    "health_ingestion_batch_id" uuid NOT NULL,
    "source_record_identifier" varchar NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "source_version" varchar,
    "source_last_updated_at" timestamptz,
    "payload_hash" varchar NOT NULL,
    "payload_file_id" uuid,
    "validation_status_concept_id" uuid NOT NULL,
    "processing_status_concept_id" uuid NOT NULL,
    "canonical_resource_id" uuid,
    "error_summary_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_ingestion_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."canonical_health_resources" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "logical_identifier" varchar NOT NULL,
    "patient_profile_id" uuid,
    "encounter_id" uuid,
    "source_system_id" uuid,
    "current_version_id" uuid,
    "lifecycle_status_concept_id" uuid NOT NULL,
    "security_labels_json" jsonb,
    "purpose_restrictions_json" jsonb,
    "retention_policy_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_canonical_health_resources" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."canonical_health_resource_versions" (
    "id" uuid NOT NULL,
    "canonical_health_resource_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "health_ingestion_record_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "effective_start_at" timestamptz,
    "effective_end_at" timestamptz,
    "change_type_concept_id" uuid NOT NULL,
    "payload_format_concept_id" uuid NOT NULL,
    "normalized_payload_json" jsonb NOT NULL,
    "original_payload_file_id" uuid,
    "content_hash" varchar NOT NULL,
    "provenance_record_id" uuid,
    "supersedes_version_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_canonical_health_resource_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."canonical_resource_identifiers" (
    "id" uuid NOT NULL,
    "canonical_health_resource_id" uuid NOT NULL,
    "identifier_system" varchar NOT NULL,
    "identifier_value" varchar NOT NULL,
    "identifier_type_concept_id" uuid NOT NULL,
    "assigning_authority" varchar,
    "is_primary" boolean NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_canonical_resource_identifiers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."canonical_resource_relationships" (
    "id" uuid NOT NULL,
    "source_resource_id" uuid NOT NULL,
    "target_resource_id" uuid NOT NULL,
    "relationship_type_concept_id" uuid NOT NULL,
    "relationship_role_concept_id" uuid,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "confidence_score" numeric(8,5),
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_canonical_resource_relationships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."canonical_resource_bindings" (
    "id" uuid NOT NULL,
    "canonical_health_resource_id" uuid NOT NULL,
    "domain_entity_type_concept_id" uuid NOT NULL,
    "domain_entity_id" uuid NOT NULL,
    "binding_role_concept_id" uuid NOT NULL,
    "binding_status_concept_id" uuid NOT NULL,
    "mapping_version_id" uuid,
    "created_at" timestamptz NOT NULL,
    "ended_at" timestamptz,
    CONSTRAINT "pk_canonical_resource_bindings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."patient_timeline_entries" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "event_time" timestamptz NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "source_entity_type_concept_id" uuid NOT NULL,
    "source_entity_id" uuid NOT NULL,
    "encounter_id" uuid,
    "organization_id" uuid,
    "title" varchar,
    "summary_redacted" text,
    "clinical_priority_concept_id" uuid,
    "patient_visibility_concept_id" uuid,
    "security_labels_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_patient_timeline_entries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."fhir_profile_definitions" (
    "id" uuid NOT NULL,
    "canonical_url" varchar NOT NULL,
    "name" varchar NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "jurisdiction_concept_id" uuid,
    "publisher" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_fhir_profile_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."fhir_profile_versions" (
    "id" uuid NOT NULL,
    "fhir_profile_definition_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "fhir_release_concept_id" uuid NOT NULL,
    "structure_definition_json" jsonb NOT NULL,
    "package_name" varchar,
    "package_version" varchar,
    "checksum_sha256" varchar,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_fhir_profile_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."fhir_validation_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "canonical_health_resource_version_id" uuid NOT NULL,
    "fhir_profile_version_id" uuid NOT NULL,
    "validator_version" varchar NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz,
    "result_concept_id" uuid NOT NULL,
    "issue_count" integer,
    "summary_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_fhir_validation_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."fhir_validation_issues" (
    "id" uuid NOT NULL,
    "fhir_validation_run_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "issue_code" varchar NOT NULL,
    "expression_path" varchar,
    "diagnostics_text" text,
    "location_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_fhir_validation_issues" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."patient_identity_clusters" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "cluster_identifier" varchar NOT NULL,
    "master_patient_profile_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "confidence_score" numeric(8,5),
    "last_resolved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_identity_clusters" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."patient_identity_members" (
    "id" uuid NOT NULL,
    "patient_identity_cluster_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "source_system_id" uuid,
    "source_patient_identifier" varchar,
    "member_role_concept_id" uuid NOT NULL,
    "match_status_concept_id" uuid NOT NULL,
    "confidence_score" numeric(8,5),
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_patient_identity_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."patient_match_candidates" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "left_patient_profile_id" uuid NOT NULL,
    "right_patient_profile_id" uuid NOT NULL,
    "algorithm_version" varchar NOT NULL,
    "match_score" numeric(8,5) NOT NULL,
    "matching_features_json" jsonb,
    "conflicting_features_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "generated_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_patient_match_candidates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."patient_match_decisions" (
    "id" uuid NOT NULL,
    "patient_match_candidate_id" uuid NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "decided_by_user_id" uuid NOT NULL,
    "decided_at" timestamptz NOT NULL,
    "reason_text" text,
    "resulting_cluster_id" uuid,
    "evidence_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_patient_match_decisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_data_quality_rule_sets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "resource_type_concept_id" uuid,
    "version" varchar NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_data_quality_rule_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_data_quality_rules" (
    "id" uuid NOT NULL,
    "health_data_quality_rule_set_id" uuid NOT NULL,
    "rule_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "dimension_concept_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "expression_language_concept_id" uuid NOT NULL,
    "rule_expression" text NOT NULL,
    "remediation_guidance" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_data_quality_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_data_quality_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "health_data_quality_rule_set_id" uuid NOT NULL,
    "health_ingestion_batch_id" uuid,
    "canonical_resource_id" uuid,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz,
    "result_concept_id" uuid NOT NULL,
    "records_evaluated" bigint,
    "issues_detected" bigint,
    "summary_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_data_quality_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_data_quality_issues" (
    "id" uuid NOT NULL,
    "health_data_quality_run_id" uuid NOT NULL,
    "health_data_quality_rule_id" uuid NOT NULL,
    "canonical_health_resource_id" uuid,
    "canonical_resource_version_id" uuid,
    "field_path" varchar NOT NULL,
    "observed_value_hash" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "assigned_user_id" uuid,
    "resolution_text" text,
    "resolved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_data_quality_issues" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_provenance_records" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "activity_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "occurred_start_at" timestamptz,
    "occurred_end_at" timestamptz,
    "source_system_id" uuid,
    "responsible_agent_type_concept_id" uuid,
    "responsible_agent_id" uuid,
    "on_behalf_of_organization_id" uuid,
    "policy_uris_json" jsonb,
    "signature_id" uuid,
    "content_hash" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_provenance_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_provenance_targets" (
    "id" uuid NOT NULL,
    "health_provenance_record_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "role_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_provenance_targets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_lineage_edges" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "source_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "transformation_type_concept_id" uuid NOT NULL,
    "transformation_version" varchar,
    "job_run_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "content_hash" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_lineage_edges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_terminology_mapping_sets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "source_code_system_id" uuid NOT NULL,
    "target_code_system_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_terminology_mapping_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_terminology_mapping_rules" (
    "id" uuid NOT NULL,
    "health_terminology_mapping_set_id" uuid NOT NULL,
    "source_code" varchar NOT NULL,
    "target_concept_id" uuid NOT NULL,
    "equivalence_concept_id" uuid NOT NULL,
    "context_expression" text,
    "confidence_score" numeric(8,5),
    "mapping_comment" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_terminology_mapping_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_deidentification_profiles" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "methodology_concept_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "direct_identifier_rules_json" jsonb,
    "quasi_identifier_rules_json" jsonb,
    "date_shift_policy_json" jsonb,
    "free_text_policy_json" jsonb,
    "reidentification_key_secret_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_deidentification_profiles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_deidentification_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "health_deidentification_profile_id" uuid NOT NULL,
    "purpose_concept_id" uuid NOT NULL,
    "consent_directive_id" uuid,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "input_manifest_file_id" uuid,
    "output_manifest_file_id" uuid,
    "records_processed" bigint,
    "records_rejected" bigint,
    "verification_summary_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_deidentification_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_export_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "export_type_concept_id" uuid NOT NULL,
    "requested_by_user_id" uuid NOT NULL,
    "purpose_of_use_concept_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "cohort_definition_id" uuid,
    "consent_directive_id" uuid,
    "deidentification_run_id" uuid,
    "requested_at" timestamptz NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "completed_at" timestamptz,
    "expires_at" timestamptz,
    "delivery_destination_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_export_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."health_export_manifests" (
    "id" uuid NOT NULL,
    "health_export_job_id" uuid NOT NULL,
    "manifest_version" integer NOT NULL,
    "file_id" uuid NOT NULL,
    "content_hash" varchar NOT NULL,
    "record_count" bigint NOT NULL,
    "size_bytes" bigint NOT NULL,
    "encryption_profile_id" uuid,
    "retention_policy_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_health_export_manifests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."omop_mapping_sets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "omop_cdm_version" varchar NOT NULL,
    "source_model_version" varchar NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_omop_mapping_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."omop_mapping_rules" (
    "id" uuid NOT NULL,
    "omop_mapping_set_id" uuid NOT NULL,
    "source_resource_type_concept_id" uuid NOT NULL,
    "target_table" varchar NOT NULL,
    "target_column" varchar NOT NULL,
    "mapping_expression" text NOT NULL,
    "vocabulary_mapping_set_id" uuid,
    "required" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_omop_mapping_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_data"."omop_transformation_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "omop_mapping_set_id" uuid NOT NULL,
    "health_ingestion_batch_id" uuid,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "records_read" bigint,
    "records_written" bigint,
    "records_rejected" bigint,
    "quality_summary_json" jsonb,
    "lineage_job_run_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_omop_transformation_runs" PRIMARY KEY ("id")
);
