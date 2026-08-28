-- SALUD v4.0.10 · módulo 62 · schema cross_store_consistency
-- Generado de diagram_62_cross_store_consistency.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_definitions" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "source_dataset_id" uuid NOT NULL,
    "target_dataset_id" uuid NOT NULL,
    "projection_version" varchar NOT NULL,
    "delivery_semantics" varchar NOT NULL,
    "transformation_ref" varchar NOT NULL,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_projection_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_subscriptions" (
    "id" uuid NOT NULL,
    "projection_definition_id" uuid NOT NULL,
    "source_event_type" varchar NOT NULL,
    "consumer_code" varchar NOT NULL,
    "target_backend_code" varchar NOT NULL,
    "concurrency_limit" integer NOT NULL,
    "retry_policy_json" jsonb NOT NULL,
    "dead_letter_enabled" boolean NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_projection_subscriptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_consumers" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "service_name" varchar NOT NULL,
    "deployment_region" varchar NOT NULL,
    "consumer_group" varchar NOT NULL,
    "heartbeat_at" timestamptz NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_projection_consumers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_checkpoints" (
    "id" uuid NOT NULL,
    "projection_subscription_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "partition_key" varchar NOT NULL,
    "source_position" varchar NOT NULL,
    "source_event_id" uuid NOT NULL,
    "target_version" bigint NOT NULL,
    "checkpointed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_projection_checkpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_delivery_attempts" (
    "id" uuid NOT NULL,
    "projection_subscription_id" uuid NOT NULL,
    "outbox_event_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "payload_hash" varchar NOT NULL,
    "status" varchar NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    "error_code" varchar,
    CONSTRAINT "pk_projection_delivery_attempts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_dead_letters" (
    "id" uuid NOT NULL,
    "projection_delivery_attempt_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "reason_code" varchar NOT NULL,
    "payload_object_id" uuid NOT NULL,
    "state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "resolved_at" timestamptz NOT NULL,
    CONSTRAINT "pk_projection_dead_letters" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."reconciliation_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "source_backend_code" varchar NOT NULL,
    "target_backend_code" varchar NOT NULL,
    "reconciliation_scope_json" jsonb NOT NULL,
    "status" varchar NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_reconciliation_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."reconciliation_items" (
    "id" uuid NOT NULL,
    "reconciliation_run_id" uuid NOT NULL,
    "canonical_entity_id" uuid NOT NULL,
    "canonical_version" bigint NOT NULL,
    "target_document_id" varchar NOT NULL,
    "target_version" varchar NOT NULL,
    "canonical_hash" varchar NOT NULL,
    "target_hash" varchar NOT NULL,
    "result" varchar NOT NULL,
    "detected_at" timestamptz NOT NULL,
    CONSTRAINT "pk_reconciliation_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_drift_events" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "canonical_entity_id" uuid NOT NULL,
    "drift_type" varchar NOT NULL,
    "severity" varchar NOT NULL,
    "canonical_version" bigint NOT NULL,
    "target_version" varchar NOT NULL,
    "reconciliation_item_id" uuid NOT NULL,
    "status" varchar NOT NULL,
    "detected_at" timestamptz NOT NULL,
    CONSTRAINT "pk_projection_drift_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."projection_repair_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "projection_drift_event_id" uuid NOT NULL,
    "repair_action" varchar NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "status" varchar NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_projection_repair_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."deletion_requests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "subject_type" varchar NOT NULL,
    "subject_id" uuid NOT NULL,
    "reason_code" varchar NOT NULL,
    "legal_basis_code" varchar NOT NULL,
    "requested_by_user_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "state" varchar NOT NULL,
    "due_at" timestamptz NOT NULL,
    CONSTRAINT "pk_deletion_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."deletion_targets" (
    "id" uuid NOT NULL,
    "deletion_request_id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "backend_code" varchar NOT NULL,
    "target_locator" varchar NOT NULL,
    "deletion_mode" varchar NOT NULL,
    "blocked_by_legal_hold" boolean NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_deletion_targets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."deletion_executions" (
    "id" uuid NOT NULL,
    "deletion_target_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "status" varchar NOT NULL,
    "provider_receipt" varchar NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    "error_code" varchar,
    CONSTRAINT "pk_deletion_executions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."deletion_verifications" (
    "id" uuid NOT NULL,
    "deletion_target_id" uuid NOT NULL,
    "verification_method" varchar NOT NULL,
    "verified_absent" boolean NOT NULL,
    "residual_reference_count" integer NOT NULL,
    "evidence_object_id" uuid NOT NULL,
    "verified_at" timestamptz NOT NULL,
    CONSTRAINT "pk_deletion_verifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."reindex_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "source_alias" varchar NOT NULL,
    "target_index" varchar NOT NULL,
    "target_schema_version" varchar NOT NULL,
    "status" varchar NOT NULL,
    "processed_count" bigint NOT NULL,
    "failed_count" bigint NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_reindex_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."cache_invalidation_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "entity_id" uuid NOT NULL,
    "entity_version" bigint NOT NULL,
    "cache_scope" varchar NOT NULL,
    "status" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_cache_invalidation_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."data_movement_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "source_placement_id" uuid NOT NULL,
    "target_placement_id" uuid NOT NULL,
    "movement_mode" varchar NOT NULL,
    "manifest_hash" varchar NOT NULL,
    "status" varchar NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_data_movement_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."schema_migration_jobs" (
    "id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "collection_definition_id" uuid NOT NULL,
    "from_schema_version" varchar NOT NULL,
    "to_schema_version" varchar NOT NULL,
    "migration_strategy" varchar NOT NULL,
    "status" varchar NOT NULL,
    "migrated_count" bigint NOT NULL,
    "failed_count" bigint NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_schema_migration_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."archive_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "retention_cutoff" timestamptz NOT NULL,
    "archive_manifest_object_id" uuid NOT NULL,
    "status" varchar NOT NULL,
    "archived_count" bigint NOT NULL,
    "deleted_hot_count" bigint NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_archive_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "cross_store_consistency"."store_consistency_slos" (
    "id" uuid NOT NULL,
    "dataset_id" uuid NOT NULL,
    "target_backend_code" varchar NOT NULL,
    "max_projection_lag_seconds" integer NOT NULL,
    "max_drift_rate" numeric(8,6) NOT NULL,
    "reconciliation_interval_minutes" integer NOT NULL,
    "alert_policy_code" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_store_consistency_slos" PRIMARY KEY ("id")
);
