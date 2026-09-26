-- SALUD v4.0.10 · módulo 67 · schema data_catalog
-- Generado de diagram_67_data_catalog.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_data_catalog_scan_runs_status_requested_at" ON "data_catalog"."catalog_scan_runs" ("status", "requested_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_scan_runs_one_active" ON "data_catalog"."catalog_scan_runs" ("source_code") WHERE status IN ('QUEUED', 'RUNNING');

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_scan_runs_idempotency" ON "data_catalog"."catalog_scan_runs" ("requested_by_user_id", "idempotency_key") WHERE idempotency_key IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_objects_identity" ON "data_catalog"."catalog_objects" ("source_code", "schema_name", "object_name");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_objects_observation_status" ON "data_catalog"."catalog_objects" ("observation_status");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_columns_identity" ON "data_catalog"."catalog_columns" ("object_id", "column_name");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_events_scan_run_id" ON "data_catalog"."catalog_change_events" ("scan_run_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_events_object_created" ON "data_catalog"."catalog_change_events" ("object_id", "created_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotations_object" ON "data_catalog"."catalog_annotations" ("object_id") WHERE target_kind = 'OBJECT';

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotations_column" ON "data_catalog"."catalog_annotations" ("column_id") WHERE column_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_annotations_review_status" ON "data_catalog"."catalog_annotations" ("review_status");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotation_revisions_no" ON "data_catalog"."catalog_annotation_revisions" ("annotation_id", "revision_no");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_review_decisions_annotation" ON "data_catalog"."catalog_review_decisions" ("annotation_id", "revision_no");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_evidence_items_object_id" ON "data_catalog"."catalog_evidence_items" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_evidence_items_column_id" ON "data_catalog"."catalog_evidence_items" ("column_id");
