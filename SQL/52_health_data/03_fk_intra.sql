-- SALUD v4.0.10 · módulo 52 · schema health_data
-- Generado de diagram_52_health_data_platform.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_health_source_system_id" FOREIGN KEY ("health_source_system_id")
        REFERENCES "health_data"."health_source_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_batches"
        ADD CONSTRAINT "fk_health_ingestion_batches_health_source_connection_id" FOREIGN KEY ("health_source_connection_id")
        REFERENCES "health_data"."health_source_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_records"
        ADD CONSTRAINT "fk_health_ingestion_records_health_ingestion_batch_id" FOREIGN KEY ("health_ingestion_batch_id")
        REFERENCES "health_data"."health_ingestion_batches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_records"
        ADD CONSTRAINT "fk_health_ingestion_records_canonical_resource_id" FOREIGN KEY ("canonical_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_source_system_id" FOREIGN KEY ("source_system_id")
        REFERENCES "health_data"."health_source_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_current_version_id" FOREIGN KEY ("current_version_id")
        REFERENCES "health_data"."canonical_health_resource_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resource_versions"
        ADD CONSTRAINT "fk_canonical_health_resource_versions_canonical_health_97ff4d77" FOREIGN KEY ("canonical_health_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resource_versions"
        ADD CONSTRAINT "fk_canonical_health_resource_versions_health_ingestion_196b9e10" FOREIGN KEY ("health_ingestion_record_id")
        REFERENCES "health_data"."health_ingestion_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resource_versions"
        ADD CONSTRAINT "fk_canonical_health_resource_versions_provenance_record_id" FOREIGN KEY ("provenance_record_id")
        REFERENCES "health_data"."health_provenance_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resource_versions"
        ADD CONSTRAINT "fk_canonical_health_resource_versions_supersedes_version_id" FOREIGN KEY ("supersedes_version_id")
        REFERENCES "health_data"."canonical_health_resource_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_identifiers"
        ADD CONSTRAINT "fk_canonical_resource_identifiers_canonical_health_resource_id" FOREIGN KEY ("canonical_health_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_relationships"
        ADD CONSTRAINT "fk_canonical_resource_relationships_source_resource_id" FOREIGN KEY ("source_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_relationships"
        ADD CONSTRAINT "fk_canonical_resource_relationships_target_resource_id" FOREIGN KEY ("target_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_bindings"
        ADD CONSTRAINT "fk_canonical_resource_bindings_canonical_health_resource_id" FOREIGN KEY ("canonical_health_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_bindings"
        ADD CONSTRAINT "fk_canonical_resource_bindings_mapping_version_id" FOREIGN KEY ("mapping_version_id")
        REFERENCES "health_data"."canonical_health_resource_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_versions"
        ADD CONSTRAINT "fk_fhir_profile_versions_fhir_profile_definition_id" FOREIGN KEY ("fhir_profile_definition_id")
        REFERENCES "health_data"."fhir_profile_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_validation_runs"
        ADD CONSTRAINT "fk_fhir_validation_runs_canonical_health_resource_version_id" FOREIGN KEY ("canonical_health_resource_version_id")
        REFERENCES "health_data"."canonical_health_resource_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_validation_runs"
        ADD CONSTRAINT "fk_fhir_validation_runs_fhir_profile_version_id" FOREIGN KEY ("fhir_profile_version_id")
        REFERENCES "health_data"."fhir_profile_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_validation_issues"
        ADD CONSTRAINT "fk_fhir_validation_issues_fhir_validation_run_id" FOREIGN KEY ("fhir_validation_run_id")
        REFERENCES "health_data"."fhir_validation_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_members"
        ADD CONSTRAINT "fk_patient_identity_members_patient_identity_cluster_id" FOREIGN KEY ("patient_identity_cluster_id")
        REFERENCES "health_data"."patient_identity_clusters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_members"
        ADD CONSTRAINT "fk_patient_identity_members_source_system_id" FOREIGN KEY ("source_system_id")
        REFERENCES "health_data"."health_source_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_decisions"
        ADD CONSTRAINT "fk_patient_match_decisions_patient_match_candidate_id" FOREIGN KEY ("patient_match_candidate_id")
        REFERENCES "health_data"."patient_match_candidates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_decisions"
        ADD CONSTRAINT "fk_patient_match_decisions_resulting_cluster_id" FOREIGN KEY ("resulting_cluster_id")
        REFERENCES "health_data"."patient_identity_clusters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rules"
        ADD CONSTRAINT "fk_health_data_quality_rules_health_data_quality_rule_set_id" FOREIGN KEY ("health_data_quality_rule_set_id")
        REFERENCES "health_data"."health_data_quality_rule_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_runs"
        ADD CONSTRAINT "fk_health_data_quality_runs_health_data_quality_rule_set_id" FOREIGN KEY ("health_data_quality_rule_set_id")
        REFERENCES "health_data"."health_data_quality_rule_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_runs"
        ADD CONSTRAINT "fk_health_data_quality_runs_health_ingestion_batch_id" FOREIGN KEY ("health_ingestion_batch_id")
        REFERENCES "health_data"."health_ingestion_batches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_runs"
        ADD CONSTRAINT "fk_health_data_quality_runs_canonical_resource_id" FOREIGN KEY ("canonical_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_issues"
        ADD CONSTRAINT "fk_health_data_quality_issues_health_data_quality_run_id" FOREIGN KEY ("health_data_quality_run_id")
        REFERENCES "health_data"."health_data_quality_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_issues"
        ADD CONSTRAINT "fk_health_data_quality_issues_health_data_quality_rule_id" FOREIGN KEY ("health_data_quality_rule_id")
        REFERENCES "health_data"."health_data_quality_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_issues"
        ADD CONSTRAINT "fk_health_data_quality_issues_canonical_health_resource_id" FOREIGN KEY ("canonical_health_resource_id")
        REFERENCES "health_data"."canonical_health_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_issues"
        ADD CONSTRAINT "fk_health_data_quality_issues_canonical_resource_version_id" FOREIGN KEY ("canonical_resource_version_id")
        REFERENCES "health_data"."canonical_health_resource_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_records"
        ADD CONSTRAINT "fk_health_provenance_records_source_system_id" FOREIGN KEY ("source_system_id")
        REFERENCES "health_data"."health_source_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_targets"
        ADD CONSTRAINT "fk_health_provenance_targets_health_provenance_record_id" FOREIGN KEY ("health_provenance_record_id")
        REFERENCES "health_data"."health_provenance_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_rules"
        ADD CONSTRAINT "fk_health_terminology_mapping_rules_health_terminology_8892ed0e" FOREIGN KEY ("health_terminology_mapping_set_id")
        REFERENCES "health_data"."health_terminology_mapping_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_runs"
        ADD CONSTRAINT "fk_health_deidentification_runs_health_deidentificatio_32e15d81" FOREIGN KEY ("health_deidentification_profile_id")
        REFERENCES "health_data"."health_deidentification_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_deidentification_run_id" FOREIGN KEY ("deidentification_run_id")
        REFERENCES "health_data"."health_deidentification_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_manifests"
        ADD CONSTRAINT "fk_health_export_manifests_health_export_job_id" FOREIGN KEY ("health_export_job_id")
        REFERENCES "health_data"."health_export_jobs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_rules"
        ADD CONSTRAINT "fk_omop_mapping_rules_omop_mapping_set_id" FOREIGN KEY ("omop_mapping_set_id")
        REFERENCES "health_data"."omop_mapping_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_rules"
        ADD CONSTRAINT "fk_omop_mapping_rules_vocabulary_mapping_set_id" FOREIGN KEY ("vocabulary_mapping_set_id")
        REFERENCES "health_data"."omop_mapping_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."omop_transformation_runs"
        ADD CONSTRAINT "fk_omop_transformation_runs_omop_mapping_set_id" FOREIGN KEY ("omop_mapping_set_id")
        REFERENCES "health_data"."omop_mapping_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_data"."omop_transformation_runs"
        ADD CONSTRAINT "fk_omop_transformation_runs_health_ingestion_batch_id" FOREIGN KEY ("health_ingestion_batch_id")
        REFERENCES "health_data"."health_ingestion_batches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
