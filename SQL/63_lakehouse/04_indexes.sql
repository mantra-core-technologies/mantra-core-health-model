-- SALUD v4.0.10 · módulo 63 · schema lakehouse
-- Generado de diagram_63_lakehouse.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "uq_data_lake_zone_code" ON "lakehouse"."data_lake_zones" ("code");

CREATE INDEX IF NOT EXISTS "ix_data_lake_zone_type_state" ON "lakehouse"."data_lake_zones" ("zone_type", "state");

CREATE INDEX IF NOT EXISTS "uq_lakehouse_catalog_code" ON "lakehouse"."lakehouse_catalogs" ("code");

CREATE INDEX IF NOT EXISTS "ix_lakehouse_catalog_state" ON "lakehouse"."lakehouse_catalogs" ("state", "catalog_type");

CREATE INDEX IF NOT EXISTS "uq_data_product_tenant_code" ON "lakehouse"."data_products" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_data_product_owner_state" ON "lakehouse"."data_products" ("owner_team_id", "lifecycle_state");

CREATE INDEX IF NOT EXISTS "uq_data_product_version" ON "lakehouse"."data_product_versions" ("data_product_id", "version");

CREATE INDEX IF NOT EXISTS "ix_data_product_version_effective" ON "lakehouse"."data_product_versions" ("data_product_id", "effective_from" DESC);

CREATE INDEX IF NOT EXISTS "gin_data_product_quality_slo" ON "lakehouse"."data_product_versions" USING gin (quality_slo_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS "uq_lakehouse_dataset_table" ON "lakehouse"."lakehouse_datasets" ("lakehouse_catalog_id", "database_name", "table_name");

CREATE INDEX IF NOT EXISTS "ix_lakehouse_dataset_product" ON "lakehouse"."lakehouse_datasets" ("data_product_version_id", "lifecycle_state");

CREATE INDEX IF NOT EXISTS "gin_lakehouse_partition_spec" ON "lakehouse"."lakehouse_datasets" USING gin (partition_spec_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS "uq_lakehouse_schema_version" ON "lakehouse"."lakehouse_schema_versions" ("lakehouse_dataset_id", "schema_version");

CREATE INDEX IF NOT EXISTS "uq_lakehouse_schema_fingerprint" ON "lakehouse"."lakehouse_schema_versions" ("lakehouse_dataset_id", "schema_fingerprint");

CREATE INDEX IF NOT EXISTS "gin_lakehouse_schema_json" ON "lakehouse"."lakehouse_schema_versions" USING gin (schema_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS "uq_lakehouse_partition_hash" ON "lakehouse"."lakehouse_partitions" ("lakehouse_dataset_id", "partition_spec_hash");

CREATE INDEX IF NOT EXISTS "ix_lakehouse_partition_time" ON "lakehouse"."lakehouse_partitions" ("lakehouse_dataset_id", "max_event_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_lakehouse_partition_values" ON "lakehouse"."lakehouse_partitions" USING gin (partition_values_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS "uq_lakehouse_file_object" ON "lakehouse"."lakehouse_files" ("lakehouse_partition_id", "object_manifest_id");

CREATE INDEX IF NOT EXISTS "uq_lakehouse_file_hash" ON "lakehouse"."lakehouse_files" ("lakehouse_partition_id", "content_hash");

CREATE INDEX IF NOT EXISTS "ix_lakehouse_file_created" ON "lakehouse"."lakehouse_files" ("lakehouse_partition_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_transformation_version" ON "lakehouse"."transformation_definitions" ("tenant_id", "code", "version");

CREATE INDEX IF NOT EXISTS "ix_transformation_target_state" ON "lakehouse"."transformation_definitions" ("target_dataset_id", "state");

CREATE INDEX IF NOT EXISTS "ix_transformation_run_status" ON "lakehouse"."transformation_runs" ("tenant_id", "status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_transformation_run_definition" ON "lakehouse"."transformation_runs" ("transformation_definition_id", "started_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_lakehouse_quality_rule" ON "lakehouse"."lakehouse_quality_rules" ("data_product_version_id", "rule_code");

CREATE INDEX IF NOT EXISTS "ix_lakehouse_quality_rule_state" ON "lakehouse"."lakehouse_quality_rules" ("state", "severity");

CREATE INDEX IF NOT EXISTS "ix_lakehouse_quality_run_dataset" ON "lakehouse"."lakehouse_quality_runs" ("lakehouse_dataset_id", "started_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_lakehouse_quality_run_status" ON "lakehouse"."lakehouse_quality_runs" ("tenant_id", "status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_lakehouse_quality_issue_run" ON "lakehouse"."lakehouse_quality_issues" ("lakehouse_quality_run_id", "status");

CREATE INDEX IF NOT EXISTS "ix_lakehouse_quality_issue_rule" ON "lakehouse"."lakehouse_quality_issues" ("lakehouse_quality_rule_id", "detected_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_lakehouse_lineage_source" ON "lakehouse"."lakehouse_lineage_edges" ("source_dataset_id", "source_partition_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_lakehouse_lineage_target" ON "lakehouse"."lakehouse_lineage_edges" ("target_dataset_id", "target_partition_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_research_project_tenant_code" ON "lakehouse"."research_projects" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_research_project_state_period" ON "lakehouse"."research_projects" ("state", "approved_to");

CREATE INDEX IF NOT EXISTS "uq_cohort_definition_version" ON "lakehouse"."cohort_definitions" ("research_project_id", "code", "version");

CREATE INDEX IF NOT EXISTS "ix_cohort_definition_state" ON "lakehouse"."cohort_definitions" ("research_project_id", "state");

CREATE INDEX IF NOT EXISTS "ix_dataset_release_status" ON "lakehouse"."dataset_release_requests" ("tenant_id", "status", "requested_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_dataset_release_project" ON "lakehouse"."dataset_release_requests" ("research_project_id", "requested_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_dataset_release_manifest_request" ON "lakehouse"."dataset_release_manifests" ("dataset_release_request_id");

CREATE INDEX IF NOT EXISTS "uq_dataset_release_manifest_hash" ON "lakehouse"."dataset_release_manifests" ("content_hash");

CREATE INDEX IF NOT EXISTS "ix_dataset_release_expiry" ON "lakehouse"."dataset_release_manifests" ("expires_at");
