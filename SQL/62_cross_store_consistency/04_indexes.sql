-- SALUD v4.0.10 · módulo 62 · schema cross_store_consistency
-- Generado de diagram_62_cross_store_consistency.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "uq_projection_definition_version" ON "cross_store_consistency"."projection_definitions" ("code", "projection_version");

CREATE INDEX IF NOT EXISTS "ix_projection_definition_datasets" ON "cross_store_consistency"."projection_definitions" ("source_dataset_id", "target_dataset_id", "state");

CREATE INDEX IF NOT EXISTS "uq_projection_subscription_consumer_event" ON "cross_store_consistency"."projection_subscriptions" ("projection_definition_id", "source_event_type", "consumer_code");

CREATE INDEX IF NOT EXISTS "ix_projection_subscription_state" ON "cross_store_consistency"."projection_subscriptions" ("state", "target_backend_code");

CREATE INDEX IF NOT EXISTS "uq_projection_consumer_code_region" ON "cross_store_consistency"."projection_consumers" ("code", "deployment_region");

CREATE INDEX IF NOT EXISTS "ix_projection_consumer_heartbeat" ON "cross_store_consistency"."projection_consumers" ("state", "heartbeat_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_projection_checkpoint_partition" ON "cross_store_consistency"."projection_checkpoints" ("projection_subscription_id", "tenant_id", "partition_key");

CREATE INDEX IF NOT EXISTS "ix_projection_checkpoint_event" ON "cross_store_consistency"."projection_checkpoints" ("source_event_id");

CREATE INDEX IF NOT EXISTS "ix_projection_checkpoint_time" ON "cross_store_consistency"."projection_checkpoints" ("checkpointed_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_projection_delivery_attempt" ON "cross_store_consistency"."projection_delivery_attempts" ("projection_subscription_id", "outbox_event_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "uq_projection_delivery_idem" ON "cross_store_consistency"."projection_delivery_attempts" ("projection_subscription_id", "idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_projection_delivery_status" ON "cross_store_consistency"."projection_delivery_attempts" ("tenant_id", "status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_projection_dead_letter_attempt" ON "cross_store_consistency"."projection_dead_letters" ("projection_delivery_attempt_id");

CREATE INDEX IF NOT EXISTS "ix_projection_dead_letter_state" ON "cross_store_consistency"."projection_dead_letters" ("tenant_id", "state", "created_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_reconciliation_run_status" ON "cross_store_consistency"."reconciliation_runs" ("tenant_id", "status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_reconciliation_run_dataset" ON "cross_store_consistency"."reconciliation_runs" ("dataset_id", "started_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_reconciliation_item_entity" ON "cross_store_consistency"."reconciliation_items" ("reconciliation_run_id", "canonical_entity_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_item_result" ON "cross_store_consistency"."reconciliation_items" ("reconciliation_run_id", "result");

CREATE INDEX IF NOT EXISTS "uq_projection_drift_active" ON "cross_store_consistency"."projection_drift_events" ("tenant_id", "dataset_id", "canonical_entity_id", "drift_type", "status");

CREATE INDEX IF NOT EXISTS "ix_projection_drift_severity" ON "cross_store_consistency"."projection_drift_events" ("tenant_id", "status", "severity", "detected_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_projection_repair_idem" ON "cross_store_consistency"."projection_repair_jobs" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_projection_repair_status" ON "cross_store_consistency"."projection_repair_jobs" ("tenant_id", "status", "requested_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_deletion_request_state_due" ON "cross_store_consistency"."deletion_requests" ("tenant_id", "state", "due_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_deletion_request_subject" ON "cross_store_consistency"."deletion_requests" ("tenant_id", "subject_type", "subject_id", "requested_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_deletion_target_dataset_backend" ON "cross_store_consistency"."deletion_targets" ("deletion_request_id", "dataset_id", "backend_code", "target_locator");

CREATE INDEX IF NOT EXISTS "ix_deletion_target_state" ON "cross_store_consistency"."deletion_targets" ("state", "blocked_by_legal_hold");

CREATE INDEX IF NOT EXISTS "uq_deletion_execution_attempt" ON "cross_store_consistency"."deletion_executions" ("deletion_target_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "uq_deletion_execution_idem" ON "cross_store_consistency"."deletion_executions" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_deletion_execution_status" ON "cross_store_consistency"."deletion_executions" ("status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_deletion_verification_target" ON "cross_store_consistency"."deletion_verifications" ("deletion_target_id", "verified_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_deletion_verification_residual" ON "cross_store_consistency"."deletion_verifications" ("verified_absent", "residual_reference_count");

CREATE INDEX IF NOT EXISTS "ix_reindex_job_status" ON "cross_store_consistency"."reindex_jobs" ("tenant_id", "status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_reindex_target_index" ON "cross_store_consistency"."reindex_jobs" ("target_index");

CREATE INDEX IF NOT EXISTS "uq_cache_invalidation_version" ON "cross_store_consistency"."cache_invalidation_jobs" ("tenant_id", "dataset_id", "entity_id", "entity_version", "cache_scope");

CREATE INDEX IF NOT EXISTS "ix_cache_invalidation_status" ON "cross_store_consistency"."cache_invalidation_jobs" ("status", "created_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_data_movement_manifest" ON "cross_store_consistency"."data_movement_jobs" ("tenant_id", "dataset_id", "manifest_hash");

CREATE INDEX IF NOT EXISTS "ix_data_movement_status" ON "cross_store_consistency"."data_movement_jobs" ("tenant_id", "status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_schema_migration_versions" ON "cross_store_consistency"."schema_migration_jobs" ("collection_definition_id", "from_schema_version", "to_schema_version");

CREATE INDEX IF NOT EXISTS "ix_schema_migration_status" ON "cross_store_consistency"."schema_migration_jobs" ("status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_archive_job_cutoff" ON "cross_store_consistency"."archive_jobs" ("tenant_id", "dataset_id", "retention_cutoff");

CREATE INDEX IF NOT EXISTS "ix_archive_job_status" ON "cross_store_consistency"."archive_jobs" ("status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_store_consistency_slo" ON "cross_store_consistency"."store_consistency_slos" ("dataset_id", "target_backend_code");

CREATE INDEX IF NOT EXISTS "ix_store_consistency_state" ON "cross_store_consistency"."store_consistency_slos" ("state", "target_backend_code");
