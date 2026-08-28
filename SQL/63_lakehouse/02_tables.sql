-- SALUD v4.0.10 · módulo 63 · schema lakehouse
-- Generado de diagram_63_lakehouse.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "lakehouse"."data_lake_zones" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "zone_type" varchar NOT NULL,
    "namespace_id" uuid NOT NULL,
    "encryption_profile_code" varchar NOT NULL,
    "retention_policy_code" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_data_lake_zones" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_catalogs" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "catalog_type" varchar NOT NULL,
    "metastore_uri" varchar NOT NULL,
    "default_format" varchar NOT NULL,
    "default_compression" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_lakehouse_catalogs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."data_products" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "owner_team_id" uuid NOT NULL,
    "business_purpose" text NOT NULL,
    "classification_code" varchar NOT NULL,
    "contains_phi" boolean NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    CONSTRAINT "pk_data_products" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."data_product_versions" (
    "id" uuid NOT NULL,
    "data_product_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "contract_schema_json" jsonb NOT NULL,
    "quality_slo_json" jsonb NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_data_product_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_datasets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "data_product_version_id" uuid NOT NULL,
    "data_lake_zone_id" uuid NOT NULL,
    "lakehouse_catalog_id" uuid NOT NULL,
    "database_name" varchar NOT NULL,
    "table_name" varchar NOT NULL,
    "storage_format" varchar NOT NULL,
    "partition_spec_json" jsonb NOT NULL,
    "source_dataset_code" varchar NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    CONSTRAINT "pk_lakehouse_datasets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_schema_versions" (
    "id" uuid NOT NULL,
    "lakehouse_dataset_id" uuid NOT NULL,
    "schema_version" integer NOT NULL,
    "schema_json" jsonb NOT NULL,
    "schema_fingerprint" varchar NOT NULL,
    "compatibility_mode" varchar NOT NULL,
    "effective_from" timestamptz NOT NULL,
    CONSTRAINT "pk_lakehouse_schema_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_partitions" (
    "id" uuid NOT NULL,
    "lakehouse_dataset_id" uuid NOT NULL,
    "partition_spec_hash" varchar NOT NULL,
    "partition_values_json" jsonb NOT NULL,
    "record_count" bigint NOT NULL,
    "size_bytes" bigint NOT NULL,
    "min_event_at" timestamptz NOT NULL,
    "max_event_at" timestamptz NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_lakehouse_partitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_files" (
    "id" uuid NOT NULL,
    "lakehouse_partition_id" uuid NOT NULL,
    "object_manifest_id" uuid NOT NULL,
    "file_format" varchar NOT NULL,
    "row_count" bigint NOT NULL,
    "size_bytes" bigint NOT NULL,
    "content_hash" varchar NOT NULL,
    "min_max_statistics_json" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_lakehouse_files" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."transformation_definitions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "version" varchar NOT NULL,
    "engine" varchar NOT NULL,
    "source_dataset_ids" uuid[] NOT NULL,
    "target_dataset_id" uuid NOT NULL,
    "transformation_ref" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_transformation_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."transformation_runs" (
    "id" uuid NOT NULL,
    "transformation_definition_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "source_checkpoint" varchar NOT NULL,
    "status" varchar NOT NULL,
    "input_record_count" bigint NOT NULL,
    "output_record_count" bigint NOT NULL,
    "rejected_record_count" bigint NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_transformation_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_quality_rules" (
    "id" uuid NOT NULL,
    "data_product_version_id" uuid NOT NULL,
    "rule_code" varchar NOT NULL,
    "dimension" varchar NOT NULL,
    "expression" text NOT NULL,
    "severity" varchar NOT NULL,
    "threshold" numeric NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_lakehouse_quality_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_quality_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "lakehouse_dataset_id" uuid NOT NULL,
    "transformation_run_id" uuid NOT NULL,
    "status" varchar NOT NULL,
    "evaluated_record_count" bigint NOT NULL,
    "failed_record_count" bigint NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_lakehouse_quality_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_quality_issues" (
    "id" uuid NOT NULL,
    "lakehouse_quality_run_id" uuid NOT NULL,
    "lakehouse_quality_rule_id" uuid NOT NULL,
    "partition_id" uuid NOT NULL,
    "issue_count" bigint NOT NULL,
    "sample_object_manifest_id" uuid NOT NULL,
    "status" varchar NOT NULL,
    "detected_at" timestamptz NOT NULL,
    CONSTRAINT "pk_lakehouse_quality_issues" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."lakehouse_lineage_edges" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "source_dataset_id" uuid NOT NULL,
    "target_dataset_id" uuid NOT NULL,
    "transformation_run_id" uuid NOT NULL,
    "source_partition_id" uuid NOT NULL,
    "target_partition_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_lakehouse_lineage_edges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."research_projects" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "protocol_reference" varchar NOT NULL,
    "principal_investigator_id" uuid NOT NULL,
    "ethics_approval_reference" varchar NOT NULL,
    "approved_from" date NOT NULL,
    "approved_to" date NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_research_projects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."cohort_definitions" (
    "id" uuid NOT NULL,
    "research_project_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "version" varchar NOT NULL,
    "inclusion_expression" text NOT NULL,
    "exclusion_expression" text NOT NULL,
    "deidentification_profile_id" uuid NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_cohort_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."dataset_release_requests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "research_project_id" uuid NOT NULL,
    "data_product_version_id" uuid NOT NULL,
    "cohort_definition_id" uuid NOT NULL,
    "purpose_of_use_code" varchar NOT NULL,
    "requested_by_user_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "status" varchar NOT NULL,
    CONSTRAINT "pk_dataset_release_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "lakehouse"."dataset_release_manifests" (
    "id" uuid NOT NULL,
    "dataset_release_request_id" uuid NOT NULL,
    "deidentification_run_id" uuid NOT NULL,
    "object_manifest_id" uuid NOT NULL,
    "schema_version" varchar NOT NULL,
    "record_count" bigint NOT NULL,
    "content_hash" varchar NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_dataset_release_manifests" PRIMARY KEY ("id")
);
