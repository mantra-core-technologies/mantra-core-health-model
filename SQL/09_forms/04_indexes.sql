-- SALUD v4.0.10 · módulo 09 · schema forms
-- Generado de diagram_09_forms.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_dynamic_field_sections_code" ON "forms"."dynamic_field_sections" ("code");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_sections_parent_section_id" ON "forms"."dynamic_field_sections" ("parent_section_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_sections_state_concept_id" ON "forms"."dynamic_field_sections" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_sections_created_by_user_id" ON "forms"."dynamic_field_sections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_sections_updated_by_user_id" ON "forms"."dynamic_field_sections" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_dynamic_field_definitions_code" ON "forms"."dynamic_field_definitions" ("code");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_data_use_concept_id" ON "forms"."dynamic_field_definitions" ("data_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_sensitivity_concept_id" ON "forms"."dynamic_field_definitions" ("sensitivity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_semantic_concept_id" ON "forms"."dynamic_field_definitions" ("semantic_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_value_set_id" ON "forms"."dynamic_field_definitions" ("value_set_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_unit_value_set_id" ON "forms"."dynamic_field_definitions" ("unit_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_state_concept_id" ON "forms"."dynamic_field_definitions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_created_by_user_id" ON "forms"."dynamic_field_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_field_definitions_updated_by_user_id" ON "forms"."dynamic_field_definitions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_field_id" ON "forms"."field_assignments" ("field_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_target_resource_concept_id" ON "forms"."field_assignments" ("target_resource_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_profile_type_concept_id" ON "forms"."field_assignments" ("profile_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_tenant_id" ON "forms"."field_assignments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_branch_id" ON "forms"."field_assignments" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_section_id" ON "forms"."field_assignments" ("section_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_read_role_value_set_id" ON "forms"."field_assignments" ("read_role_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_write_role_value_set_id" ON "forms"."field_assignments" ("write_role_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_state_concept_id" ON "forms"."field_assignments" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_created_by_user_id" ON "forms"."field_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_updated_by_user_id" ON "forms"."field_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_assignments_tenant_id_state_concept_id" ON "forms"."field_assignments" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_field_assignments_effective_period" ON "forms"."field_assignments" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_field_validation_rules_field_id" ON "forms"."field_validation_rules" ("field_id");

CREATE INDEX IF NOT EXISTS "ix_field_validation_rules_rule_type_concept_id" ON "forms"."field_validation_rules" ("rule_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_validation_rules_operator_concept_id" ON "forms"."field_validation_rules" ("operator_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_validation_rules_severity_concept_id" ON "forms"."field_validation_rules" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_validation_rules_created_by_user_id" ON "forms"."field_validation_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_validation_rules_updated_by_user_id" ON "forms"."field_validation_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_dependencies_target_field_id" ON "forms"."field_dependencies" ("target_field_id");

CREATE INDEX IF NOT EXISTS "ix_field_dependencies_source_field_id" ON "forms"."field_dependencies" ("source_field_id");

CREATE INDEX IF NOT EXISTS "ix_field_dependencies_operator_concept_id" ON "forms"."field_dependencies" ("operator_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_dependencies_behavior_concept_id" ON "forms"."field_dependencies" ("behavior_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_dependencies_created_by_user_id" ON "forms"."field_dependencies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_dependencies_updated_by_user_id" ON "forms"."field_dependencies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_form_instances_resource_type_concept_id" ON "forms"."form_instances" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_form_instances_tenant_context_id" ON "forms"."form_instances" ("tenant_context_id");

CREATE INDEX IF NOT EXISTS "ix_form_instances_state_concept_id" ON "forms"."form_instances" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_form_instances_created_by_user_id" ON "forms"."form_instances" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_form_instances_updated_by_user_id" ON "forms"."form_instances" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_form_instance_id" ON "forms"."field_values" ("form_instance_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_resource_type_concept_id" ON "forms"."field_values" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_field_id" ON "forms"."field_values" ("field_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_assignment_id" ON "forms"."field_values" ("assignment_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_value_concept_id" ON "forms"."field_values" ("value_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_file_id" ON "forms"."field_values" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_unit_concept_id" ON "forms"."field_values" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_data_source_concept_id" ON "forms"."field_values" ("data_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_value_status_concept_id" ON "forms"."field_values" ("value_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_supersedes_value_id" ON "forms"."field_values" ("supersedes_value_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_created_by_user_id" ON "forms"."field_values" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_values_updated_by_user_id" ON "forms"."field_values" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_audit_field_value_id" ON "forms"."field_value_audit" ("field_value_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_audit_action_concept_id" ON "forms"."field_value_audit" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_audit_user_id" ON "forms"."field_value_audit" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_audit_reason_concept_id" ON "forms"."field_value_audit" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_audit_recorded_by_user_id" ON "forms"."field_value_audit" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_field_value_audit_recorded_at" ON "forms"."field_value_audit" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_field_definition_sets_namespace_uri" ON "forms"."field_definition_sets" ("namespace_uri");

CREATE INDEX IF NOT EXISTS "ix_field_definition_sets_owner_tenant_id" ON "forms"."field_definition_sets" ("owner_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_sets_target_domain_concept_id" ON "forms"."field_definition_sets" ("target_domain_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_sets_status_concept_id" ON "forms"."field_definition_sets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_sets_created_by_user_id" ON "forms"."field_definition_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_sets_updated_by_user_id" ON "forms"."field_definition_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_set_versions_definition_set_id" ON "forms"."field_definition_set_versions" ("definition_set_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_set_versions_publication_status_concept_id" ON "forms"."field_definition_set_versions" ("publication_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_set_versions_compatibility_concept_id" ON "forms"."field_definition_set_versions" ("compatibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_set_versions_recorded_by_user_id" ON "forms"."field_definition_set_versions" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_field_definition_set_versions_recorded_at" ON "forms"."field_definition_set_versions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_field_set_members_definition_set_version_id" ON "forms"."field_set_members" ("definition_set_version_id");

CREATE INDEX IF NOT EXISTS "ix_field_set_members_field_id" ON "forms"."field_set_members" ("field_id");

CREATE INDEX IF NOT EXISTS "ix_field_set_members_section_id" ON "forms"."field_set_members" ("section_id");

CREATE INDEX IF NOT EXISTS "ix_field_set_members_created_by_user_id" ON "forms"."field_set_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_localizations_field_id" ON "forms"."field_definition_localizations" ("field_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_localizations_language_concept_id" ON "forms"."field_definition_localizations" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_localizations_created_by_user_id" ON "forms"."field_definition_localizations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_definition_localizations_updated_by_user_id" ON "forms"."field_definition_localizations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_provenance_field_value_id" ON "forms"."field_value_provenance" ("field_value_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_provenance_import_batch_id" ON "forms"."field_value_provenance" ("import_batch_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_provenance_author_profile_id" ON "forms"."field_value_provenance" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_provenance_entered_by_user_id" ON "forms"."field_value_provenance" ("entered_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_provenance_verification_status_concept_id" ON "forms"."field_value_provenance" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_provenance_recorded_by_user_id" ON "forms"."field_value_provenance" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_field_value_provenance_recorded_at" ON "forms"."field_value_provenance" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_field_id" ON "forms"."field_value_access_rules" ("field_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_assignment_id" ON "forms"."field_value_access_rules" ("assignment_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_purpose_of_use_value_set_id" ON "forms"."field_value_access_rules" ("purpose_of_use_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_read_role_value_set_id" ON "forms"."field_value_access_rules" ("read_role_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_write_role_value_set_id" ON "forms"."field_value_access_rules" ("write_role_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_consent_category_concept_id" ON "forms"."field_value_access_rules" ("consent_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_mask_strategy_concept_id" ON "forms"."field_value_access_rules" ("mask_strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_status_concept_id" ON "forms"."field_value_access_rules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_created_by_user_id" ON "forms"."field_value_access_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_value_access_rules_updated_by_user_id" ON "forms"."field_value_access_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_schema_migrations_definition_set_id" ON "forms"."field_schema_migrations" ("definition_set_id");

CREATE INDEX IF NOT EXISTS "ix_field_schema_migrations_from_version_id" ON "forms"."field_schema_migrations" ("from_version_id");

CREATE INDEX IF NOT EXISTS "ix_field_schema_migrations_to_version_id" ON "forms"."field_schema_migrations" ("to_version_id");

CREATE INDEX IF NOT EXISTS "ix_field_schema_migrations_migration_type_concept_id" ON "forms"."field_schema_migrations" ("migration_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_schema_migrations_status_concept_id" ON "forms"."field_schema_migrations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_schema_migrations_created_by_user_id" ON "forms"."field_schema_migrations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_schema_migrations_updated_by_user_id" ON "forms"."field_schema_migrations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_target_resource_concept_id" ON "forms"."extension_target_policies" ("target_resource_concept_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_definition_set_id" ON "forms"."extension_target_policies" ("definition_set_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_tenant_id" ON "forms"."extension_target_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_jurisdiction_concept_id" ON "forms"."extension_target_policies" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_status_concept_id" ON "forms"."extension_target_policies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_created_by_user_id" ON "forms"."extension_target_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_updated_by_user_id" ON "forms"."extension_target_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_extension_target_policies_tenant_id_status_concept_id" ON "forms"."extension_target_policies" ("tenant_id", "status_concept_id", "updated_at" DESC);
