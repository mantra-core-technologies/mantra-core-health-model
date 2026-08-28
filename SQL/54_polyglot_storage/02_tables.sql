-- SALUD v4.0.10 · módulo 54 · schema polyglot_storage
-- Generado de diagram_54_polyglot_storage.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "polyglot_storage"."storage_backends" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "backend_type" varchar NOT NULL,
    "provider_code" varchar NOT NULL,
    "control_plane_endpoint" varchar NOT NULL,
    "supports_transactions" boolean NOT NULL,
    "supports_ttl" boolean NOT NULL,
    "supports_encryption" boolean NOT NULL,
    "supports_versioning" boolean NOT NULL,
    "supports_worm" boolean NOT NULL,
    "supports_vector_search" boolean NOT NULL,
    "supports_full_text" boolean NOT NULL,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_storage_backends" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."storage_backend_regions" (
    "id" uuid NOT NULL,
    "storage_backend_id" uuid NOT NULL,
    "region_code" varchar NOT NULL,
    "country_code" char(2) NOT NULL,
    "jurisdiction_code" varchar NOT NULL,
    "endpoint_uri" varchar NOT NULL,
    "is_primary" boolean NOT NULL,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_storage_backend_regions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."storage_capabilities" (
    "id" uuid NOT NULL,
    "storage_backend_id" uuid NOT NULL,
    "capability_code" varchar NOT NULL,
    "capability_version" varchar NOT NULL,
    "configuration_json" jsonb NOT NULL,
    "verified_at" timestamptz NOT NULL,
    "verification_status" varchar NOT NULL,
    CONSTRAINT "pk_storage_capabilities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."data_classifications" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "sensitivity_level" smallint NOT NULL,
    "contains_phi" boolean NOT NULL,
    "contains_pii" boolean NOT NULL,
    "contains_financial_data" boolean NOT NULL,
    "default_encryption_profile_id" uuid NOT NULL,
    "default_retention_policy_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_data_classifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."dataset_definitions" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "owning_module_code" varchar NOT NULL,
    "data_classification_id" uuid NOT NULL,
    "source_of_truth" varchar NOT NULL,
    "canonical_entity_type" varchar NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dataset_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."dataset_versions" (
    "id" uuid NOT NULL,
    "dataset_definition_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "schema_fingerprint" varchar NOT NULL,
    "compatibility_mode" varchar NOT NULL,
    "schema_document_file_id" uuid NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_dataset_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."collection_definitions" (
    "id" uuid NOT NULL,
    "storage_backend_id" uuid NOT NULL,
    "dataset_definition_id" uuid NOT NULL,
    "logical_name" varchar NOT NULL,
    "physical_name_pattern" varchar NOT NULL,
    "partitioning_strategy" varchar NOT NULL,
    "tenant_isolation_mode" varchar NOT NULL,
    "routing_key_expression" varchar NOT NULL,
    "shard_key_expression" varchar NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_collection_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."collection_schema_versions" (
    "id" uuid NOT NULL,
    "collection_definition_id" uuid NOT NULL,
    "dataset_version_id" uuid NOT NULL,
    "schema_version" varchar NOT NULL,
    "validation_mode" varchar NOT NULL,
    "schema_document_json" jsonb NOT NULL,
    "migration_strategy" varchar NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_collection_schema_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."dataset_placements" (
    "id" uuid NOT NULL,
    "dataset_version_id" uuid NOT NULL,
    "storage_backend_region_id" uuid NOT NULL,
    "collection_definition_id" uuid NOT NULL,
    "placement_role" varchar NOT NULL,
    "residency_policy_id" uuid NOT NULL,
    "replication_policy_id" uuid NOT NULL,
    "consistency_policy_id" uuid NOT NULL,
    "encryption_profile_id" uuid NOT NULL,
    "state" varchar NOT NULL,
    "activated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_dataset_placements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."tenant_storage_bindings" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_definition_id" uuid NOT NULL,
    "primary_placement_id" uuid NOT NULL,
    "secondary_placement_id" uuid,
    "tenant_partition_key" varchar NOT NULL,
    "tenant_encryption_key_ref" varchar NOT NULL,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_tenant_storage_bindings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."encryption_profiles" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "algorithm" varchar NOT NULL,
    "key_management_provider" varchar NOT NULL,
    "key_reference" varchar NOT NULL,
    "envelope_encryption" boolean NOT NULL,
    "field_level_encryption" boolean NOT NULL,
    "deterministic_fields_json" jsonb NOT NULL,
    "rotation_policy_id" uuid NOT NULL,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_encryption_profiles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."key_rotation_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "rotation_interval_days" integer NOT NULL,
    "overlap_days" integer NOT NULL,
    "reencrypt_existing_data" boolean NOT NULL,
    "emergency_rotation_enabled" boolean NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_key_rotation_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."retention_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "retention_days" integer NOT NULL,
    "archive_after_days" integer NOT NULL,
    "deletion_mode" varchar NOT NULL,
    "legal_hold_overrides_deletion" boolean NOT NULL,
    "jurisdiction_code" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_retention_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."replication_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "replica_count" smallint NOT NULL,
    "replication_mode" varchar NOT NULL,
    "cross_region_enabled" boolean NOT NULL,
    "max_replication_lag_seconds" integer NOT NULL,
    "failover_mode" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_replication_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."consistency_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "read_consistency" varchar NOT NULL,
    "write_consistency" varchar NOT NULL,
    "conflict_resolution" varchar NOT NULL,
    "stale_read_tolerance_seconds" integer NOT NULL,
    "requires_read_your_writes" boolean NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_consistency_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."residency_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "allowed_country_codes" text[] NOT NULL,
    "forbidden_country_codes" text[] NOT NULL,
    "allowed_region_codes" text[] NOT NULL,
    "requires_in_country_backup" boolean NOT NULL,
    "cross_border_transfer_basis" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_residency_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."data_access_policies" (
    "id" uuid NOT NULL,
    "dataset_definition_id" uuid NOT NULL,
    "purpose_of_use_code" varchar NOT NULL,
    "principal_type" varchar NOT NULL,
    "field_policy_json" jsonb NOT NULL,
    "row_filter_expression" text NOT NULL,
    "masking_profile_code" varchar NOT NULL,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_data_access_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."store_health_checks" (
    "id" uuid NOT NULL,
    "storage_backend_region_id" uuid NOT NULL,
    "check_type" varchar NOT NULL,
    "checked_at" timestamptz NOT NULL,
    "status" varchar NOT NULL,
    "latency_ms" integer NOT NULL,
    "details_json" jsonb NOT NULL,
    CONSTRAINT "pk_store_health_checks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."storage_cost_snapshots" (
    "id" uuid NOT NULL,
    "storage_backend_region_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_definition_id" uuid NOT NULL,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "storage_bytes" bigint NOT NULL,
    "read_units" numeric NOT NULL,
    "write_units" numeric NOT NULL,
    "egress_bytes" bigint NOT NULL,
    "estimated_cost" numeric(18,6) NOT NULL,
    "currency_code" char(3) NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_storage_cost_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "polyglot_storage"."storage_integrity_policies" (
    "id" uuid NOT NULL,
    "dataset_definition_id" uuid NOT NULL,
    "hash_algorithm" varchar NOT NULL,
    "verification_interval_hours" integer NOT NULL,
    "sample_percentage" numeric(5,2) NOT NULL,
    "compare_with_canonical_source" boolean NOT NULL,
    "quarantine_on_mismatch" boolean NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_storage_integrity_policies" PRIMARY KEY ("id")
);
