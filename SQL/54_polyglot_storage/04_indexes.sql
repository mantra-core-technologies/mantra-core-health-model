-- SALUD v4.0.10 · módulo 54 · schema polyglot_storage
-- Generado de diagram_54_polyglot_storage.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uk_storage_backends_code" ON "polyglot_storage"."storage_backends" ("code");

CREATE INDEX IF NOT EXISTS "ix_storage_backends_type_state" ON "polyglot_storage"."storage_backends" ("backend_type", "state");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_storage_backend_regions_backend_region" ON "polyglot_storage"."storage_backend_regions" ("storage_backend_id", "region_code");

CREATE INDEX IF NOT EXISTS "ix_storage_backend_regions_country" ON "polyglot_storage"."storage_backend_regions" ("country_code", "state");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_storage_capabilities_backend_code" ON "polyglot_storage"."storage_capabilities" ("storage_backend_id", "capability_code", "capability_version");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_data_classifications_code" ON "polyglot_storage"."data_classifications" ("code");

CREATE INDEX IF NOT EXISTS "ix_data_classifications_sensitivity" ON "polyglot_storage"."data_classifications" ("sensitivity_level", "contains_phi");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_dataset_definitions_code" ON "polyglot_storage"."dataset_definitions" ("code");

CREATE INDEX IF NOT EXISTS "ix_dataset_definitions_owner_state" ON "polyglot_storage"."dataset_definitions" ("owning_module_code", "lifecycle_state");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_dataset_versions_dataset_version" ON "polyglot_storage"."dataset_versions" ("dataset_definition_id", "version");

CREATE INDEX IF NOT EXISTS "ix_dataset_versions_effective" ON "polyglot_storage"."dataset_versions" ("dataset_definition_id", "effective_from" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_collection_definitions_backend_name" ON "polyglot_storage"."collection_definitions" ("storage_backend_id", "logical_name");

CREATE INDEX IF NOT EXISTS "ix_collection_definitions_dataset" ON "polyglot_storage"."collection_definitions" ("dataset_definition_id", "lifecycle_state");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_collection_schema_versions_collection_version" ON "polyglot_storage"."collection_schema_versions" ("collection_definition_id", "schema_version");

CREATE INDEX IF NOT EXISTS "gin_collection_schema_versions_schema" ON "polyglot_storage"."collection_schema_versions" USING gin (schema_document_json jsonb_path_ops);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_dataset_placements_version_region_role" ON "polyglot_storage"."dataset_placements" ("dataset_version_id", "storage_backend_region_id", "placement_role");

CREATE INDEX IF NOT EXISTS "ix_dataset_placements_state" ON "polyglot_storage"."dataset_placements" ("state", "activated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_tenant_storage_bindings_tenant_dataset" ON "polyglot_storage"."tenant_storage_bindings" ("tenant_id", "dataset_definition_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_storage_bindings_state" ON "polyglot_storage"."tenant_storage_bindings" ("tenant_id", "state");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_encryption_profiles_code" ON "polyglot_storage"."encryption_profiles" ("code");

CREATE INDEX IF NOT EXISTS "ix_encryption_profiles_provider_state" ON "polyglot_storage"."encryption_profiles" ("key_management_provider", "state");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_key_rotation_policies_code" ON "polyglot_storage"."key_rotation_policies" ("code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_retention_policies_code" ON "polyglot_storage"."retention_policies" ("code");

CREATE INDEX IF NOT EXISTS "ix_retention_policies_jurisdiction" ON "polyglot_storage"."retention_policies" ("jurisdiction_code", "state");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_replication_policies_code" ON "polyglot_storage"."replication_policies" ("code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_consistency_policies_code" ON "polyglot_storage"."consistency_policies" ("code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_residency_policies_code" ON "polyglot_storage"."residency_policies" ("code");

CREATE INDEX IF NOT EXISTS "gin_residency_policies_allowed_countries" ON "polyglot_storage"."residency_policies" USING gin ("allowed_country_codes");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_data_access_policies_dataset_purpose_principal" ON "polyglot_storage"."data_access_policies" ("dataset_definition_id", "purpose_of_use_code", "principal_type");

CREATE INDEX IF NOT EXISTS "gin_data_access_policies_fields" ON "polyglot_storage"."data_access_policies" USING gin (field_policy_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS "ix_store_health_checks_region_time" ON "polyglot_storage"."store_health_checks" ("storage_backend_region_id", "checked_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_store_health_checks_checked_at" ON "polyglot_storage"."store_health_checks" USING brin ("checked_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_storage_cost_snapshots_scope_period" ON "polyglot_storage"."storage_cost_snapshots" ("storage_backend_region_id", "tenant_id", "dataset_definition_id", "period_start", "period_end");

CREATE INDEX IF NOT EXISTS "ix_storage_cost_snapshots_tenant_period" ON "polyglot_storage"."storage_cost_snapshots" ("tenant_id", "period_end" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_storage_integrity_policies_dataset" ON "polyglot_storage"."storage_integrity_policies" ("dataset_definition_id");
