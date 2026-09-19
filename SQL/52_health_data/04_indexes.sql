-- SALUD v4.0.10 · módulo 52 · schema health_data
-- Generado de diagram_52_health_data_platform.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_health_source_systems_tenant_id" ON "health_data"."health_source_systems" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_systems_source_type_concept_id" ON "health_data"."health_source_systems" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_systems_organization_id" ON "health_data"."health_source_systems" ("organization_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_systems_trust_level_concept_id" ON "health_data"."health_source_systems" ("trust_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_systems_state_concept_id" ON "health_data"."health_source_systems" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_systems_created_by_user_id" ON "health_data"."health_source_systems" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_systems_updated_by_user_id" ON "health_data"."health_source_systems" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_systems_tenant_created" ON "health_data"."health_source_systems" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_source_systems_tenant_code" ON "health_data"."health_source_systems" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_health_source_system_id" ON "health_data"."health_source_connections" ("health_source_system_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_connection_type_concept_id" ON "health_data"."health_source_connections" ("connection_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_credential_id" ON "health_data"."health_source_connections" ("credential_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_network_policy_id" ON "health_data"."health_source_connections" ("network_policy_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_format_concept_id" ON "health_data"."health_source_connections" ("format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_cursor_strategy_concept_id" ON "health_data"."health_source_connections" ("cursor_strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_status_concept_id" ON "health_data"."health_source_connections" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_created_by_user_id" ON "health_data"."health_source_connections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_source_connections_updated_by_user_id" ON "health_data"."health_source_connections" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_source_connections_system_type_endpoint" ON "health_data"."health_source_connections" ("health_source_system_id", "connection_type_concept_id", "endpoint_uri");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_batches_tenant_id" ON "health_data"."health_ingestion_batches" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_batches_health_source_connection_id" ON "health_data"."health_ingestion_batches" ("health_source_connection_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_batches_ingestion_mode_concept_id" ON "health_data"."health_ingestion_batches" ("ingestion_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_batches_status_concept_id" ON "health_data"."health_ingestion_batches" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_batches_payload_manifest_file_id" ON "health_data"."health_ingestion_batches" ("payload_manifest_file_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_batches_tenant_status" ON "health_data"."health_ingestion_batches" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_health_ingestion_batches_created_at" ON "health_data"."health_ingestion_batches" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_ingestion_batches_connection_identifier" ON "health_data"."health_ingestion_batches" ("health_source_connection_id", "batch_identifier");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_records_health_ingestion_batch_id" ON "health_data"."health_ingestion_records" ("health_ingestion_batch_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_records_resource_type_concept_id" ON "health_data"."health_ingestion_records" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_records_payload_file_id" ON "health_data"."health_ingestion_records" ("payload_file_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_records_validation_status_concept_id" ON "health_data"."health_ingestion_records" ("validation_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_records_processing_status_concept_id" ON "health_data"."health_ingestion_records" ("processing_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_ingestion_records_canonical_resource_id" ON "health_data"."health_ingestion_records" ("canonical_resource_id");

CREATE INDEX IF NOT EXISTS "brin_health_ingestion_records_created_at" ON "health_data"."health_ingestion_records" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_ingestion_records_batch_source" ON "health_data"."health_ingestion_records" ("health_ingestion_batch_id", "source_record_identifier", "source_version");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_custodian_tenant_id" ON "health_data"."canonical_health_resources" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_resource_type_concept_id" ON "health_data"."canonical_health_resources" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_patient_profile_id" ON "health_data"."canonical_health_resources" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_encounter_id" ON "health_data"."canonical_health_resources" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_source_system_id" ON "health_data"."canonical_health_resources" ("source_system_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_current_version_id" ON "health_data"."canonical_health_resources" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_lifecycle_status_concept_id" ON "health_data"."canonical_health_resources" ("lifecycle_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_retention_policy_id" ON "health_data"."canonical_health_resources" ("retention_policy_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_canonical_health_resources_tenant_type_logical" ON "health_data"."canonical_health_resources" ("custodian_tenant_id", "resource_type_concept_id", "logical_identifier");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resources_patient_type" ON "health_data"."canonical_health_resources" ("custodian_tenant_id", "patient_profile_id", "resource_type_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resource_versions_canonical_health_e81f83a5" ON "health_data"."canonical_health_resource_versions" ("canonical_health_resource_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resource_versions_health_ingestion_d6d6039b" ON "health_data"."canonical_health_resource_versions" ("health_ingestion_record_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resource_versions_change_type_concept_id" ON "health_data"."canonical_health_resource_versions" ("change_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resource_versions_payload_format_concept_id" ON "health_data"."canonical_health_resource_versions" ("payload_format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resource_versions_original_payload_file_id" ON "health_data"."canonical_health_resource_versions" ("original_payload_file_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resource_versions_provenance_record_id" ON "health_data"."canonical_health_resource_versions" ("provenance_record_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_health_resource_versions_supersedes_version_id" ON "health_data"."canonical_health_resource_versions" ("supersedes_version_id");

CREATE INDEX IF NOT EXISTS "brin_canonical_health_resource_versions_recorded_at" ON "health_data"."canonical_health_resource_versions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_canonical_health_resource_versions_resource_version" ON "health_data"."canonical_health_resource_versions" ("canonical_health_resource_id", "version_number");

CREATE INDEX IF NOT EXISTS "gin_canonical_health_versions_payload" ON "health_data"."canonical_health_resource_versions" USING gin ("normalized_payload_json");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_identifiers_canonical_health_resource_id" ON "health_data"."canonical_resource_identifiers" ("canonical_health_resource_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_identifiers_identifier_type_concept_id" ON "health_data"."canonical_resource_identifiers" ("identifier_type_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_canonical_resource_identifiers_system_value" ON "health_data"."canonical_resource_identifiers" ("identifier_system", "identifier_value", "canonical_health_resource_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_relationships_source_resource_id" ON "health_data"."canonical_resource_relationships" ("source_resource_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_relationships_target_resource_id" ON "health_data"."canonical_resource_relationships" ("target_resource_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_relationships_relationship_type__429279b9" ON "health_data"."canonical_resource_relationships" ("relationship_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_relationships_relationship_role__312b7dc1" ON "health_data"."canonical_resource_relationships" ("relationship_role_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_canonical_resource_relationships_pair_type" ON "health_data"."canonical_resource_relationships" ("source_resource_id", "target_resource_id", "relationship_type_concept_id", "effective_from");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_bindings_canonical_health_resource_id" ON "health_data"."canonical_resource_bindings" ("canonical_health_resource_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_bindings_domain_entity_type_concept_id" ON "health_data"."canonical_resource_bindings" ("domain_entity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_bindings_domain_entity_id" ON "health_data"."canonical_resource_bindings" ("domain_entity_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_bindings_binding_role_concept_id" ON "health_data"."canonical_resource_bindings" ("binding_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_bindings_binding_status_concept_id" ON "health_data"."canonical_resource_bindings" ("binding_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_bindings_mapping_version_id" ON "health_data"."canonical_resource_bindings" ("mapping_version_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_canonical_resource_bindings_resource_target" ON "health_data"."canonical_resource_bindings" ("canonical_health_resource_id", "domain_entity_type_concept_id", "domain_entity_id", "binding_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_canonical_resource_bindings_target" ON "health_data"."canonical_resource_bindings" ("domain_entity_type_concept_id", "domain_entity_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_custodian_tenant_id" ON "health_data"."patient_timeline_entries" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_patient_profile_id" ON "health_data"."patient_timeline_entries" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_event_type_concept_id" ON "health_data"."patient_timeline_entries" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_source_entity_type_concept_id" ON "health_data"."patient_timeline_entries" ("source_entity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_source_entity_id" ON "health_data"."patient_timeline_entries" ("source_entity_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_encounter_id" ON "health_data"."patient_timeline_entries" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_organization_id" ON "health_data"."patient_timeline_entries" ("organization_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_clinical_priority_concept_id" ON "health_data"."patient_timeline_entries" ("clinical_priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_patient_visibility_concept_id" ON "health_data"."patient_timeline_entries" ("patient_visibility_concept_id");

CREATE INDEX IF NOT EXISTS "brin_patient_timeline_entries_created_at" ON "health_data"."patient_timeline_entries" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_patient_timeline_entries_source" ON "health_data"."patient_timeline_entries" ("source_entity_type_concept_id", "source_entity_id", "event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_timeline_entries_patient_time" ON "health_data"."patient_timeline_entries" ("custodian_tenant_id", "patient_profile_id", "event_time" DESC);

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_definitions_resource_type_concept_id" ON "health_data"."fhir_profile_definitions" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_definitions_jurisdiction_concept_id" ON "health_data"."fhir_profile_definitions" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_definitions_state_concept_id" ON "health_data"."fhir_profile_definitions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_definitions_created_by_user_id" ON "health_data"."fhir_profile_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_definitions_updated_by_user_id" ON "health_data"."fhir_profile_definitions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_fhir_profile_definitions_url" ON "health_data"."fhir_profile_definitions" ("canonical_url");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_versions_fhir_profile_definition_id" ON "health_data"."fhir_profile_versions" ("fhir_profile_definition_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_versions_fhir_release_concept_id" ON "health_data"."fhir_profile_versions" ("fhir_release_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_versions_state_concept_id" ON "health_data"."fhir_profile_versions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_versions_created_by_user_id" ON "health_data"."fhir_profile_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_profile_versions_updated_by_user_id" ON "health_data"."fhir_profile_versions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_fhir_profile_versions_profile_version" ON "health_data"."fhir_profile_versions" ("fhir_profile_definition_id", "version");

CREATE INDEX IF NOT EXISTS "ix_fhir_validation_runs_tenant_id" ON "health_data"."fhir_validation_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_validation_runs_canonical_health_resource_version_id" ON "health_data"."fhir_validation_runs" ("canonical_health_resource_version_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_validation_runs_fhir_profile_version_id" ON "health_data"."fhir_validation_runs" ("fhir_profile_version_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_validation_runs_result_concept_id" ON "health_data"."fhir_validation_runs" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_validation_runs_tenant_created" ON "health_data"."fhir_validation_runs" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_fhir_validation_runs_created_at" ON "health_data"."fhir_validation_runs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_fhir_validation_issues_fhir_validation_run_id" ON "health_data"."fhir_validation_issues" ("fhir_validation_run_id");

CREATE INDEX IF NOT EXISTS "ix_fhir_validation_issues_severity_concept_id" ON "health_data"."fhir_validation_issues" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "brin_fhir_validation_issues_created_at" ON "health_data"."fhir_validation_issues" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_patient_identity_clusters_tenant_id" ON "health_data"."patient_identity_clusters" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_clusters_master_patient_profile_id" ON "health_data"."patient_identity_clusters" ("master_patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_clusters_status_concept_id" ON "health_data"."patient_identity_clusters" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_clusters_created_by_user_id" ON "health_data"."patient_identity_clusters" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_clusters_updated_by_user_id" ON "health_data"."patient_identity_clusters" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_clusters_tenant_status" ON "health_data"."patient_identity_clusters" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_patient_identity_clusters_tenant_identifier" ON "health_data"."patient_identity_clusters" ("tenant_id", "cluster_identifier");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_members_patient_identity_cluster_id" ON "health_data"."patient_identity_members" ("patient_identity_cluster_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_members_patient_profile_id" ON "health_data"."patient_identity_members" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_members_source_system_id" ON "health_data"."patient_identity_members" ("source_system_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_members_member_role_concept_id" ON "health_data"."patient_identity_members" ("member_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_identity_members_match_status_concept_id" ON "health_data"."patient_identity_members" ("match_status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_patient_identity_members_cluster_patient" ON "health_data"."patient_identity_members" ("patient_identity_cluster_id", "patient_profile_id", "effective_from");

CREATE INDEX IF NOT EXISTS "ix_patient_match_candidates_tenant_id" ON "health_data"."patient_match_candidates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_patient_match_candidates_left_patient_profile_id" ON "health_data"."patient_match_candidates" ("left_patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_match_candidates_right_patient_profile_id" ON "health_data"."patient_match_candidates" ("right_patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_match_candidates_status_concept_id" ON "health_data"."patient_match_candidates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_match_candidates_tenant_status" ON "health_data"."patient_match_candidates" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_patient_match_candidates_created_at" ON "health_data"."patient_match_candidates" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_patient_match_candidates_pair_algorithm" ON "health_data"."patient_match_candidates" ("tenant_id", "left_patient_profile_id", "right_patient_profile_id", "algorithm_version");

CREATE INDEX IF NOT EXISTS "ix_patient_match_decisions_patient_match_candidate_id" ON "health_data"."patient_match_decisions" ("patient_match_candidate_id");

CREATE INDEX IF NOT EXISTS "ix_patient_match_decisions_decision_concept_id" ON "health_data"."patient_match_decisions" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_match_decisions_decided_by_user_id" ON "health_data"."patient_match_decisions" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_match_decisions_resulting_cluster_id" ON "health_data"."patient_match_decisions" ("resulting_cluster_id");

CREATE INDEX IF NOT EXISTS "brin_patient_match_decisions_created_at" ON "health_data"."patient_match_decisions" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_patient_match_decisions_candidate" ON "health_data"."patient_match_decisions" ("patient_match_candidate_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rule_sets_tenant_id" ON "health_data"."health_data_quality_rule_sets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rule_sets_scope_concept_id" ON "health_data"."health_data_quality_rule_sets" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rule_sets_resource_type_concept_id" ON "health_data"."health_data_quality_rule_sets" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rule_sets_state_concept_id" ON "health_data"."health_data_quality_rule_sets" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rule_sets_created_by_user_id" ON "health_data"."health_data_quality_rule_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rule_sets_updated_by_user_id" ON "health_data"."health_data_quality_rule_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rule_sets_tenant_created" ON "health_data"."health_data_quality_rule_sets" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_data_quality_rule_sets_tenant_code_version" ON "health_data"."health_data_quality_rule_sets" ("tenant_id", "code", "version");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rules_health_data_quality_rule_set_id" ON "health_data"."health_data_quality_rules" ("health_data_quality_rule_set_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rules_dimension_concept_id" ON "health_data"."health_data_quality_rules" ("dimension_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rules_severity_concept_id" ON "health_data"."health_data_quality_rules" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rules_expression_language_concept_id" ON "health_data"."health_data_quality_rules" ("expression_language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rules_state_concept_id" ON "health_data"."health_data_quality_rules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rules_created_by_user_id" ON "health_data"."health_data_quality_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_rules_updated_by_user_id" ON "health_data"."health_data_quality_rules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_data_quality_rules_set_code" ON "health_data"."health_data_quality_rules" ("health_data_quality_rule_set_id", "rule_code");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_runs_tenant_id" ON "health_data"."health_data_quality_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_runs_health_data_quality_rule_set_id" ON "health_data"."health_data_quality_runs" ("health_data_quality_rule_set_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_runs_health_ingestion_batch_id" ON "health_data"."health_data_quality_runs" ("health_ingestion_batch_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_runs_canonical_resource_id" ON "health_data"."health_data_quality_runs" ("canonical_resource_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_runs_result_concept_id" ON "health_data"."health_data_quality_runs" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_runs_tenant_created" ON "health_data"."health_data_quality_runs" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_health_data_quality_runs_created_at" ON "health_data"."health_data_quality_runs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_issues_health_data_quality_run_id" ON "health_data"."health_data_quality_issues" ("health_data_quality_run_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_issues_health_data_quality_rule_id" ON "health_data"."health_data_quality_issues" ("health_data_quality_rule_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_issues_canonical_health_resource_id" ON "health_data"."health_data_quality_issues" ("canonical_health_resource_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_issues_canonical_resource_version_id" ON "health_data"."health_data_quality_issues" ("canonical_resource_version_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_issues_status_concept_id" ON "health_data"."health_data_quality_issues" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_data_quality_issues_assigned_user_id" ON "health_data"."health_data_quality_issues" ("assigned_user_id");

CREATE INDEX IF NOT EXISTS "brin_health_data_quality_issues_created_at" ON "health_data"."health_data_quality_issues" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_health_provenance_records_custodian_tenant_id" ON "health_data"."health_provenance_records" ("custodian_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_records_activity_concept_id" ON "health_data"."health_provenance_records" ("activity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_records_source_system_id" ON "health_data"."health_provenance_records" ("source_system_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_records_responsible_agent_type_concept_id" ON "health_data"."health_provenance_records" ("responsible_agent_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_records_responsible_agent_id" ON "health_data"."health_provenance_records" ("responsible_agent_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_records_on_behalf_of_organization_id" ON "health_data"."health_provenance_records" ("on_behalf_of_organization_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_records_signature_id" ON "health_data"."health_provenance_records" ("signature_id");

CREATE INDEX IF NOT EXISTS "brin_health_provenance_records_recorded_at" ON "health_data"."health_provenance_records" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_health_provenance_targets_health_provenance_record_id" ON "health_data"."health_provenance_targets" ("health_provenance_record_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_targets_target_type_concept_id" ON "health_data"."health_provenance_targets" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_targets_target_id" ON "health_data"."health_provenance_targets" ("target_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_targets_role_concept_id" ON "health_data"."health_provenance_targets" ("role_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_provenance_targets_record_target" ON "health_data"."health_provenance_targets" ("health_provenance_record_id", "target_type_concept_id", "target_id", "role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_provenance_targets_target" ON "health_data"."health_provenance_targets" ("target_type_concept_id", "target_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_tenant_id" ON "health_data"."health_lineage_edges" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_source_type_concept_id" ON "health_data"."health_lineage_edges" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_source_id" ON "health_data"."health_lineage_edges" ("source_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_target_type_concept_id" ON "health_data"."health_lineage_edges" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_target_id" ON "health_data"."health_lineage_edges" ("target_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_transformation_type_concept_id" ON "health_data"."health_lineage_edges" ("transformation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_job_run_id" ON "health_data"."health_lineage_edges" ("job_run_id");

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_tenant_created" ON "health_data"."health_lineage_edges" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_health_lineage_edges_recorded_at" ON "health_data"."health_lineage_edges" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_source" ON "health_data"."health_lineage_edges" ("source_type_concept_id", "source_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_health_lineage_edges_target" ON "health_data"."health_lineage_edges" ("target_type_concept_id", "target_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_sets_tenant_id" ON "health_data"."health_terminology_mapping_sets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_sets_source_code_system_id" ON "health_data"."health_terminology_mapping_sets" ("source_code_system_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_sets_target_code_system_id" ON "health_data"."health_terminology_mapping_sets" ("target_code_system_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_sets_state_concept_id" ON "health_data"."health_terminology_mapping_sets" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_sets_created_by_user_id" ON "health_data"."health_terminology_mapping_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_sets_updated_by_user_id" ON "health_data"."health_terminology_mapping_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_sets_tenant_created" ON "health_data"."health_terminology_mapping_sets" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_terminology_mapping_sets_tenant_code_version" ON "health_data"."health_terminology_mapping_sets" ("tenant_id", "code", "version");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_rules_health_terminology_f5718527" ON "health_data"."health_terminology_mapping_rules" ("health_terminology_mapping_set_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_rules_target_concept_id" ON "health_data"."health_terminology_mapping_rules" ("target_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_rules_equivalence_concept_id" ON "health_data"."health_terminology_mapping_rules" ("equivalence_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_rules_state_concept_id" ON "health_data"."health_terminology_mapping_rules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_rules_created_by_user_id" ON "health_data"."health_terminology_mapping_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_terminology_mapping_rules_updated_by_user_id" ON "health_data"."health_terminology_mapping_rules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_terminology_mapping_rules_set_source_context" ON "health_data"."health_terminology_mapping_rules" ("health_terminology_mapping_set_id", "source_code", "context_expression");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_profiles_tenant_id" ON "health_data"."health_deidentification_profiles" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_profiles_methodology_concept_id" ON "health_data"."health_deidentification_profiles" ("methodology_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_profiles_reidentification_k_57e6e028" ON "health_data"."health_deidentification_profiles" ("reidentification_key_secret_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_profiles_state_concept_id" ON "health_data"."health_deidentification_profiles" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_profiles_created_by_user_id" ON "health_data"."health_deidentification_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_profiles_updated_by_user_id" ON "health_data"."health_deidentification_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_profiles_tenant_created" ON "health_data"."health_deidentification_profiles" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_deidentification_profiles_tenant_code_version" ON "health_data"."health_deidentification_profiles" ("tenant_id", "code", "version");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_tenant_id" ON "health_data"."health_deidentification_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_health_deidentificatio_06745a39" ON "health_data"."health_deidentification_runs" ("health_deidentification_profile_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_purpose_concept_id" ON "health_data"."health_deidentification_runs" ("purpose_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_consent_directive_id" ON "health_data"."health_deidentification_runs" ("consent_directive_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_status_concept_id" ON "health_data"."health_deidentification_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_input_manifest_file_id" ON "health_data"."health_deidentification_runs" ("input_manifest_file_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_output_manifest_file_id" ON "health_data"."health_deidentification_runs" ("output_manifest_file_id");

CREATE INDEX IF NOT EXISTS "ix_health_deidentification_runs_tenant_status" ON "health_data"."health_deidentification_runs" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_health_deidentification_runs_created_at" ON "health_data"."health_deidentification_runs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_tenant_id" ON "health_data"."health_export_jobs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_export_type_concept_id" ON "health_data"."health_export_jobs" ("export_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_requested_by_user_id" ON "health_data"."health_export_jobs" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_purpose_of_use_concept_id" ON "health_data"."health_export_jobs" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_patient_profile_id" ON "health_data"."health_export_jobs" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_cohort_definition_id" ON "health_data"."health_export_jobs" ("cohort_definition_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_consent_directive_id" ON "health_data"."health_export_jobs" ("consent_directive_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_deidentification_run_id" ON "health_data"."health_export_jobs" ("deidentification_run_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_status_concept_id" ON "health_data"."health_export_jobs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_jobs_tenant_status" ON "health_data"."health_export_jobs" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_health_export_jobs_created_at" ON "health_data"."health_export_jobs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_health_export_manifests_health_export_job_id" ON "health_data"."health_export_manifests" ("health_export_job_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_manifests_file_id" ON "health_data"."health_export_manifests" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_manifests_encryption_profile_id" ON "health_data"."health_export_manifests" ("encryption_profile_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_manifests_retention_policy_id" ON "health_data"."health_export_manifests" ("retention_policy_id");

CREATE INDEX IF NOT EXISTS "ix_health_export_manifests_content_hash" ON "health_data"."health_export_manifests" ("content_hash");

CREATE INDEX IF NOT EXISTS "brin_health_export_manifests_created_at" ON "health_data"."health_export_manifests" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_health_export_manifests_job_version" ON "health_data"."health_export_manifests" ("health_export_job_id", "manifest_version");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_sets_tenant_id" ON "health_data"."omop_mapping_sets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_sets_state_concept_id" ON "health_data"."omop_mapping_sets" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_sets_created_by_user_id" ON "health_data"."omop_mapping_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_sets_updated_by_user_id" ON "health_data"."omop_mapping_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_sets_tenant_created" ON "health_data"."omop_mapping_sets" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_omop_mapping_sets_tenant_code_versions" ON "health_data"."omop_mapping_sets" ("tenant_id", "code", "omop_cdm_version", "source_model_version");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_rules_omop_mapping_set_id" ON "health_data"."omop_mapping_rules" ("omop_mapping_set_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_rules_source_resource_type_concept_id" ON "health_data"."omop_mapping_rules" ("source_resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_rules_vocabulary_mapping_set_id" ON "health_data"."omop_mapping_rules" ("vocabulary_mapping_set_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_rules_state_concept_id" ON "health_data"."omop_mapping_rules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_rules_created_by_user_id" ON "health_data"."omop_mapping_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_omop_mapping_rules_updated_by_user_id" ON "health_data"."omop_mapping_rules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_omop_mapping_rules_set_target" ON "health_data"."omop_mapping_rules" ("omop_mapping_set_id", "source_resource_type_concept_id", "target_table", "target_column");

CREATE INDEX IF NOT EXISTS "ix_omop_transformation_runs_tenant_id" ON "health_data"."omop_transformation_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_omop_transformation_runs_omop_mapping_set_id" ON "health_data"."omop_transformation_runs" ("omop_mapping_set_id");

CREATE INDEX IF NOT EXISTS "ix_omop_transformation_runs_health_ingestion_batch_id" ON "health_data"."omop_transformation_runs" ("health_ingestion_batch_id");

CREATE INDEX IF NOT EXISTS "ix_omop_transformation_runs_status_concept_id" ON "health_data"."omop_transformation_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_omop_transformation_runs_lineage_job_run_id" ON "health_data"."omop_transformation_runs" ("lineage_job_run_id");

CREATE INDEX IF NOT EXISTS "ix_omop_transformation_runs_tenant_status" ON "health_data"."omop_transformation_runs" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_omop_transformation_runs_created_at" ON "health_data"."omop_transformation_runs" USING brin ("created_at") WITH (pages_per_range=128);
