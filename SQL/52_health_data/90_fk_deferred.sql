-- SALUD v4.0.10 · módulo 52 · schema health_data
-- Generado de diagram_52_health_data_platform.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   health_source_systems.organization_id
--   health_source_connections.network_policy_id
--   patient_timeline_entries.organization_id
--   health_provenance_records.on_behalf_of_organization_id
--   health_deidentification_runs.consent_directive_id
--   health_export_jobs.consent_directive_id


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_systems"
        ADD CONSTRAINT "fk_health_source_systems_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_systems"
        ADD CONSTRAINT "fk_health_source_systems_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_systems"
        ADD CONSTRAINT "fk_health_source_systems_trust_level_concept_id" FOREIGN KEY ("trust_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_systems"
        ADD CONSTRAINT "fk_health_source_systems_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_systems"
        ADD CONSTRAINT "fk_health_source_systems_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_systems"
        ADD CONSTRAINT "fk_health_source_systems_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_connection_type_concept_id" FOREIGN KEY ("connection_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.provider_credentials (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_credential_id" FOREIGN KEY ("credential_id")
        REFERENCES "integrations"."provider_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_format_concept_id" FOREIGN KEY ("format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_cursor_strategy_concept_id" FOREIGN KEY ("cursor_strategy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_source_connections"
        ADD CONSTRAINT "fk_health_source_connections_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_batches"
        ADD CONSTRAINT "fk_health_ingestion_batches_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_batches"
        ADD CONSTRAINT "fk_health_ingestion_batches_ingestion_mode_concept_id" FOREIGN KEY ("ingestion_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_batches"
        ADD CONSTRAINT "fk_health_ingestion_batches_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_batches"
        ADD CONSTRAINT "fk_health_ingestion_batches_payload_manifest_file_id" FOREIGN KEY ("payload_manifest_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_records"
        ADD CONSTRAINT "fk_health_ingestion_records_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_records"
        ADD CONSTRAINT "fk_health_ingestion_records_payload_file_id" FOREIGN KEY ("payload_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_records"
        ADD CONSTRAINT "fk_health_ingestion_records_validation_status_concept_id" FOREIGN KEY ("validation_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_ingestion_records"
        ADD CONSTRAINT "fk_health_ingestion_records_processing_status_concept_id" FOREIGN KEY ("processing_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_lifecycle_status_concept_id" FOREIGN KEY ("lifecycle_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.retention_policies (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resources"
        ADD CONSTRAINT "fk_canonical_health_resources_retention_policy_id" FOREIGN KEY ("retention_policy_id")
        REFERENCES "system_ops"."retention_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resource_versions"
        ADD CONSTRAINT "fk_canonical_health_resource_versions_change_type_concept_id" FOREIGN KEY ("change_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resource_versions"
        ADD CONSTRAINT "fk_canonical_health_resource_versions_payload_format_concept_id" FOREIGN KEY ("payload_format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_health_resource_versions"
        ADD CONSTRAINT "fk_canonical_health_resource_versions_original_payload_file_id" FOREIGN KEY ("original_payload_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_identifiers"
        ADD CONSTRAINT "fk_canonical_resource_identifiers_identifier_type_concept_id" FOREIGN KEY ("identifier_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_relationships"
        ADD CONSTRAINT "fk_canonical_resource_relationships_relationship_type__919725f6" FOREIGN KEY ("relationship_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_relationships"
        ADD CONSTRAINT "fk_canonical_resource_relationships_relationship_role__a1ad800f" FOREIGN KEY ("relationship_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_bindings"
        ADD CONSTRAINT "fk_canonical_resource_bindings_domain_entity_type_concept_id" FOREIGN KEY ("domain_entity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_bindings"
        ADD CONSTRAINT "fk_canonical_resource_bindings_binding_role_concept_id" FOREIGN KEY ("binding_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."canonical_resource_bindings"
        ADD CONSTRAINT "fk_canonical_resource_bindings_binding_status_concept_id" FOREIGN KEY ("binding_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_timeline_entries"
        ADD CONSTRAINT "fk_patient_timeline_entries_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_timeline_entries"
        ADD CONSTRAINT "fk_patient_timeline_entries_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_timeline_entries"
        ADD CONSTRAINT "fk_patient_timeline_entries_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_timeline_entries"
        ADD CONSTRAINT "fk_patient_timeline_entries_source_entity_type_concept_id" FOREIGN KEY ("source_entity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_timeline_entries"
        ADD CONSTRAINT "fk_patient_timeline_entries_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_timeline_entries"
        ADD CONSTRAINT "fk_patient_timeline_entries_clinical_priority_concept_id" FOREIGN KEY ("clinical_priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_timeline_entries"
        ADD CONSTRAINT "fk_patient_timeline_entries_patient_visibility_concept_id" FOREIGN KEY ("patient_visibility_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_definitions"
        ADD CONSTRAINT "fk_fhir_profile_definitions_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_definitions"
        ADD CONSTRAINT "fk_fhir_profile_definitions_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_definitions"
        ADD CONSTRAINT "fk_fhir_profile_definitions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_definitions"
        ADD CONSTRAINT "fk_fhir_profile_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_definitions"
        ADD CONSTRAINT "fk_fhir_profile_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_versions"
        ADD CONSTRAINT "fk_fhir_profile_versions_fhir_release_concept_id" FOREIGN KEY ("fhir_release_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_versions"
        ADD CONSTRAINT "fk_fhir_profile_versions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_versions"
        ADD CONSTRAINT "fk_fhir_profile_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_profile_versions"
        ADD CONSTRAINT "fk_fhir_profile_versions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_validation_runs"
        ADD CONSTRAINT "fk_fhir_validation_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_validation_runs"
        ADD CONSTRAINT "fk_fhir_validation_runs_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."fhir_validation_issues"
        ADD CONSTRAINT "fk_fhir_validation_issues_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_clusters"
        ADD CONSTRAINT "fk_patient_identity_clusters_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_clusters"
        ADD CONSTRAINT "fk_patient_identity_clusters_master_patient_profile_id" FOREIGN KEY ("master_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_clusters"
        ADD CONSTRAINT "fk_patient_identity_clusters_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_clusters"
        ADD CONSTRAINT "fk_patient_identity_clusters_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_clusters"
        ADD CONSTRAINT "fk_patient_identity_clusters_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_members"
        ADD CONSTRAINT "fk_patient_identity_members_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_members"
        ADD CONSTRAINT "fk_patient_identity_members_member_role_concept_id" FOREIGN KEY ("member_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_identity_members"
        ADD CONSTRAINT "fk_patient_identity_members_match_status_concept_id" FOREIGN KEY ("match_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_candidates"
        ADD CONSTRAINT "fk_patient_match_candidates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_candidates"
        ADD CONSTRAINT "fk_patient_match_candidates_left_patient_profile_id" FOREIGN KEY ("left_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_candidates"
        ADD CONSTRAINT "fk_patient_match_candidates_right_patient_profile_id" FOREIGN KEY ("right_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_candidates"
        ADD CONSTRAINT "fk_patient_match_candidates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_decisions"
        ADD CONSTRAINT "fk_patient_match_decisions_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."patient_match_decisions"
        ADD CONSTRAINT "fk_patient_match_decisions_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rule_sets"
        ADD CONSTRAINT "fk_health_data_quality_rule_sets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rule_sets"
        ADD CONSTRAINT "fk_health_data_quality_rule_sets_scope_concept_id" FOREIGN KEY ("scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rule_sets"
        ADD CONSTRAINT "fk_health_data_quality_rule_sets_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rule_sets"
        ADD CONSTRAINT "fk_health_data_quality_rule_sets_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rule_sets"
        ADD CONSTRAINT "fk_health_data_quality_rule_sets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rule_sets"
        ADD CONSTRAINT "fk_health_data_quality_rule_sets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rules"
        ADD CONSTRAINT "fk_health_data_quality_rules_dimension_concept_id" FOREIGN KEY ("dimension_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rules"
        ADD CONSTRAINT "fk_health_data_quality_rules_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rules"
        ADD CONSTRAINT "fk_health_data_quality_rules_expression_language_concept_id" FOREIGN KEY ("expression_language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rules"
        ADD CONSTRAINT "fk_health_data_quality_rules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rules"
        ADD CONSTRAINT "fk_health_data_quality_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_rules"
        ADD CONSTRAINT "fk_health_data_quality_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_runs"
        ADD CONSTRAINT "fk_health_data_quality_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_runs"
        ADD CONSTRAINT "fk_health_data_quality_runs_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_issues"
        ADD CONSTRAINT "fk_health_data_quality_issues_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_data_quality_issues"
        ADD CONSTRAINT "fk_health_data_quality_issues_assigned_user_id" FOREIGN KEY ("assigned_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_records"
        ADD CONSTRAINT "fk_health_provenance_records_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_records"
        ADD CONSTRAINT "fk_health_provenance_records_activity_concept_id" FOREIGN KEY ("activity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_records"
        ADD CONSTRAINT "fk_health_provenance_records_responsible_agent_type_concept_id" FOREIGN KEY ("responsible_agent_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: chart.clinical_note_signatures (requiere schema chart)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_records"
        ADD CONSTRAINT "fk_health_provenance_records_signature_id" FOREIGN KEY ("signature_id")
        REFERENCES "chart"."clinical_note_signatures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_targets"
        ADD CONSTRAINT "fk_health_provenance_targets_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_provenance_targets"
        ADD CONSTRAINT "fk_health_provenance_targets_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_lineage_edges"
        ADD CONSTRAINT "fk_health_lineage_edges_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_lineage_edges"
        ADD CONSTRAINT "fk_health_lineage_edges_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_lineage_edges"
        ADD CONSTRAINT "fk_health_lineage_edges_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_lineage_edges"
        ADD CONSTRAINT "fk_health_lineage_edges_transformation_type_concept_id" FOREIGN KEY ("transformation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_sets"
        ADD CONSTRAINT "fk_health_terminology_mapping_sets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.code_systems (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_sets"
        ADD CONSTRAINT "fk_health_terminology_mapping_sets_source_code_system_id" FOREIGN KEY ("source_code_system_id")
        REFERENCES "terminology"."code_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.code_systems (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_sets"
        ADD CONSTRAINT "fk_health_terminology_mapping_sets_target_code_system_id" FOREIGN KEY ("target_code_system_id")
        REFERENCES "terminology"."code_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_sets"
        ADD CONSTRAINT "fk_health_terminology_mapping_sets_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_sets"
        ADD CONSTRAINT "fk_health_terminology_mapping_sets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_sets"
        ADD CONSTRAINT "fk_health_terminology_mapping_sets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_rules"
        ADD CONSTRAINT "fk_health_terminology_mapping_rules_target_concept_id" FOREIGN KEY ("target_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_rules"
        ADD CONSTRAINT "fk_health_terminology_mapping_rules_equivalence_concept_id" FOREIGN KEY ("equivalence_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_rules"
        ADD CONSTRAINT "fk_health_terminology_mapping_rules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_rules"
        ADD CONSTRAINT "fk_health_terminology_mapping_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_terminology_mapping_rules"
        ADD CONSTRAINT "fk_health_terminology_mapping_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_profiles"
        ADD CONSTRAINT "fk_health_deidentification_profiles_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_profiles"
        ADD CONSTRAINT "fk_health_deidentification_profiles_methodology_concept_id" FOREIGN KEY ("methodology_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.encryption_keys (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_profiles"
        ADD CONSTRAINT "fk_health_deidentification_profiles_reidentification_k_76ae9fd3" FOREIGN KEY ("reidentification_key_secret_id")
        REFERENCES "system_ops"."encryption_keys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_profiles"
        ADD CONSTRAINT "fk_health_deidentification_profiles_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_profiles"
        ADD CONSTRAINT "fk_health_deidentification_profiles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_profiles"
        ADD CONSTRAINT "fk_health_deidentification_profiles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_runs"
        ADD CONSTRAINT "fk_health_deidentification_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_runs"
        ADD CONSTRAINT "fk_health_deidentification_runs_purpose_concept_id" FOREIGN KEY ("purpose_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_runs"
        ADD CONSTRAINT "fk_health_deidentification_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_runs"
        ADD CONSTRAINT "fk_health_deidentification_runs_input_manifest_file_id" FOREIGN KEY ("input_manifest_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_deidentification_runs"
        ADD CONSTRAINT "fk_health_deidentification_runs_output_manifest_file_id" FOREIGN KEY ("output_manifest_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_export_type_concept_id" FOREIGN KEY ("export_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: lakehouse.cohort_definitions (requiere schema lakehouse)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_cohort_definition_id" FOREIGN KEY ("cohort_definition_id")
        REFERENCES "lakehouse"."cohort_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_jobs"
        ADD CONSTRAINT "fk_health_export_jobs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_manifests"
        ADD CONSTRAINT "fk_health_export_manifests_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: polyglot_storage.encryption_profiles (requiere schema polyglot_storage)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_manifests"
        ADD CONSTRAINT "fk_health_export_manifests_encryption_profile_id" FOREIGN KEY ("encryption_profile_id")
        REFERENCES "polyglot_storage"."encryption_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.retention_policies (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "health_data"."health_export_manifests"
        ADD CONSTRAINT "fk_health_export_manifests_retention_policy_id" FOREIGN KEY ("retention_policy_id")
        REFERENCES "system_ops"."retention_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_sets"
        ADD CONSTRAINT "fk_omop_mapping_sets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_sets"
        ADD CONSTRAINT "fk_omop_mapping_sets_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_sets"
        ADD CONSTRAINT "fk_omop_mapping_sets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_sets"
        ADD CONSTRAINT "fk_omop_mapping_sets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_rules"
        ADD CONSTRAINT "fk_omop_mapping_rules_source_resource_type_concept_id" FOREIGN KEY ("source_resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_rules"
        ADD CONSTRAINT "fk_omop_mapping_rules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_rules"
        ADD CONSTRAINT "fk_omop_mapping_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_mapping_rules"
        ADD CONSTRAINT "fk_omop_mapping_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_transformation_runs"
        ADD CONSTRAINT "fk_omop_transformation_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_data"."omop_transformation_runs"
        ADD CONSTRAINT "fk_omop_transformation_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
