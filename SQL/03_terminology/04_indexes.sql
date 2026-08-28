-- SALUD v4.0.10 · módulo 03 · schema terminology
-- Generado de diagram_03_terminology.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_terminology_sources_code" ON "terminology"."terminology_sources" ("code");

CREATE INDEX IF NOT EXISTS "ix_terminology_sources_source_type_concept_id" ON "terminology"."terminology_sources" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_terminology_sources_jurisdiction_concept_id" ON "terminology"."terminology_sources" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_terminology_sources_state_concept_id" ON "terminology"."terminology_sources" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_terminology_sources_created_by_user_id" ON "terminology"."terminology_sources" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_terminology_sources_updated_by_user_id" ON "terminology"."terminology_sources" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_terminology_sources_search" ON "terminology"."terminology_sources" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_code_systems_internal_code" ON "terminology"."code_systems" ("internal_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_code_systems_canonical_url" ON "terminology"."code_systems" ("canonical_url");

CREATE INDEX IF NOT EXISTS "ix_code_systems_source_id" ON "terminology"."code_systems" ("source_id");

CREATE INDEX IF NOT EXISTS "ix_code_systems_content_type_concept_id" ON "terminology"."code_systems" ("content_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_code_systems_state_concept_id" ON "terminology"."code_systems" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_code_systems_created_by_user_id" ON "terminology"."code_systems" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_code_systems_updated_by_user_id" ON "terminology"."code_systems" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_code_systems_search" ON "terminology"."code_systems" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_code_system_versions_code_system_id" ON "terminology"."code_system_versions" ("code_system_id");

CREATE INDEX IF NOT EXISTS "ix_code_system_versions_state_concept_id" ON "terminology"."code_system_versions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_code_system_versions_created_by_user_id" ON "terminology"."code_system_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_code_system_versions_updated_by_user_id" ON "terminology"."code_system_versions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_code_system_versions_code_system_id_version" ON "terminology"."code_system_versions" ("code_system_id", "version");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_code_system_versions_system_version" ON "terminology"."code_system_versions" ("code_system_id", "version");

CREATE INDEX IF NOT EXISTS "ix_catalog_concepts_code_system_version_id" ON "terminology"."catalog_concepts" ("code_system_version_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_concepts_replaced_by_concept_id" ON "terminology"."catalog_concepts" ("replaced_by_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_concepts_state_concept_id" ON "terminology"."catalog_concepts" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_concepts_created_by_user_id" ON "terminology"."catalog_concepts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_concepts_updated_by_user_id" ON "terminology"."catalog_concepts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_catalog_concepts_search" ON "terminology"."catalog_concepts" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_catalog_concepts_version_code" ON "terminology"."catalog_concepts" ("code_system_version_id", "code");

CREATE INDEX IF NOT EXISTS "ix_catalog_concepts_display" ON "terminology"."catalog_concepts" ("display");

CREATE INDEX IF NOT EXISTS "ix_concept_designations_concept_id" ON "terminology"."concept_designations" ("concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_designations_language_concept_id" ON "terminology"."concept_designations" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_designations_designation_type_concept_id" ON "terminology"."concept_designations" ("designation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_designations_created_by_user_id" ON "terminology"."concept_designations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_concept_designations_updated_by_user_id" ON "terminology"."concept_designations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_concept_properties_concept_id" ON "terminology"."concept_properties" ("concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_properties_created_by_user_id" ON "terminology"."concept_properties" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_concept_properties_updated_by_user_id" ON "terminology"."concept_properties" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_source_concept_id" ON "terminology"."concept_relationships" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_target_concept_id" ON "terminology"."concept_relationships" ("target_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_relationship_type_concept_id" ON "terminology"."concept_relationships" ("relationship_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_created_by_user_id" ON "terminology"."concept_relationships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_updated_by_user_id" ON "terminology"."concept_relationships" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_value_sets_internal_code" ON "terminology"."value_sets" ("internal_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_value_sets_canonical_url" ON "terminology"."value_sets" ("canonical_url");

CREATE INDEX IF NOT EXISTS "ix_value_sets_jurisdiction_concept_id" ON "terminology"."value_sets" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_value_sets_state_concept_id" ON "terminology"."value_sets" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_value_sets_created_by_user_id" ON "terminology"."value_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_value_sets_updated_by_user_id" ON "terminology"."value_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_value_sets_search" ON "terminology"."value_sets" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_value_set_versions_value_set_id" ON "terminology"."value_set_versions" ("value_set_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_versions_state_concept_id" ON "terminology"."value_set_versions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_versions_created_by_user_id" ON "terminology"."value_set_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_versions_updated_by_user_id" ON "terminology"."value_set_versions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_value_set_versions_value_set_id_version" ON "terminology"."value_set_versions" ("value_set_id", "version");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_value_set_versions_set_version" ON "terminology"."value_set_versions" ("value_set_id", "version");

CREATE INDEX IF NOT EXISTS "ix_value_set_members_value_set_version_id" ON "terminology"."value_set_members" ("value_set_version_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_members_concept_id" ON "terminology"."value_set_members" ("concept_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_members_created_by_user_id" ON "terminology"."value_set_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_members_updated_by_user_id" ON "terminology"."value_set_members" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_value_set_members_version_concept" ON "terminology"."value_set_members" ("value_set_version_id", "concept_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_rules_value_set_version_id" ON "terminology"."value_set_rules" ("value_set_version_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_rules_code_system_id" ON "terminology"."value_set_rules" ("code_system_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_rules_operator_concept_id" ON "terminology"."value_set_rules" ("operator_concept_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_rules_created_by_user_id" ON "terminology"."value_set_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_value_set_rules_updated_by_user_id" ON "terminology"."value_set_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_concept_maps_source_concept_id" ON "terminology"."concept_maps" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_maps_target_concept_id" ON "terminology"."concept_maps" ("target_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_maps_equivalence_concept_id" ON "terminology"."concept_maps" ("equivalence_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_maps_state_concept_id" ON "terminology"."concept_maps" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_maps_created_by_user_id" ON "terminology"."concept_maps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_concept_maps_updated_by_user_id" ON "terminology"."concept_maps" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_import_batches_source_id" ON "terminology"."catalog_import_batches" ("source_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_import_batches_code_system_version_id" ON "terminology"."catalog_import_batches" ("code_system_version_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_import_batches_file_id" ON "terminology"."catalog_import_batches" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_import_batches_state_concept_id" ON "terminology"."catalog_import_batches" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_import_batches_recorded_by_user_id" ON "terminology"."catalog_import_batches" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_catalog_import_batches_recorded_at" ON "terminology"."catalog_import_batches" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_tenant_catalog_policies_tenant_id" ON "terminology"."tenant_catalog_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_catalog_policies_value_set_id" ON "terminology"."tenant_catalog_policies" ("value_set_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_catalog_policies_mode_concept_id" ON "terminology"."tenant_catalog_policies" ("mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_catalog_policies_created_by_user_id" ON "terminology"."tenant_catalog_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_catalog_policies_updated_by_user_id" ON "terminology"."tenant_catalog_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_catalog_policies_tenant_id_updated_at" ON "terminology"."tenant_catalog_policies" ("tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_tenant_concept_config_tenant_id" ON "terminology"."tenant_concept_config" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_concept_config_concept_id" ON "terminology"."tenant_concept_config" ("concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_concept_config_created_by_user_id" ON "terminology"."tenant_concept_config" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_concept_config_updated_by_user_id" ON "terminology"."tenant_concept_config" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_concept_config_tenant_id_updated_at" ON "terminology"."tenant_concept_config" ("tenant_id", "updated_at" DESC);
