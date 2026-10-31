-- SALUD v4.2.80 · módulo 67 · schema data_catalog
-- Generado de diagram_67_data_catalog.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_objects"
        ADD CONSTRAINT "fk_catalog_objects_first_seen_scan_id" FOREIGN KEY ("first_seen_scan_id")
        REFERENCES "data_catalog"."catalog_scan_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_objects"
        ADD CONSTRAINT "fk_catalog_objects_last_seen_scan_id" FOREIGN KEY ("last_seen_scan_id")
        REFERENCES "data_catalog"."catalog_scan_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_columns"
        ADD CONSTRAINT "fk_catalog_columns_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_columns"
        ADD CONSTRAINT "fk_catalog_columns_first_seen_scan_id" FOREIGN KEY ("first_seen_scan_id")
        REFERENCES "data_catalog"."catalog_scan_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_columns"
        ADD CONSTRAINT "fk_catalog_columns_last_seen_scan_id" FOREIGN KEY ("last_seen_scan_id")
        REFERENCES "data_catalog"."catalog_scan_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_change_events"
        ADD CONSTRAINT "fk_catalog_change_events_scan_run_id" FOREIGN KEY ("scan_run_id")
        REFERENCES "data_catalog"."catalog_scan_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_change_events"
        ADD CONSTRAINT "fk_catalog_change_events_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_change_events"
        ADD CONSTRAINT "fk_catalog_change_events_column_id" FOREIGN KEY ("column_id")
        REFERENCES "data_catalog"."catalog_columns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_annotations"
        ADD CONSTRAINT "fk_catalog_annotations_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_annotations"
        ADD CONSTRAINT "fk_catalog_annotations_column_id" FOREIGN KEY ("column_id")
        REFERENCES "data_catalog"."catalog_columns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_annotation_revisions"
        ADD CONSTRAINT "fk_catalog_annotation_revisions_annotation_id" FOREIGN KEY ("annotation_id")
        REFERENCES "data_catalog"."catalog_annotations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_review_decisions"
        ADD CONSTRAINT "fk_catalog_review_decisions_annotation_id" FOREIGN KEY ("annotation_id")
        REFERENCES "data_catalog"."catalog_annotations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_evidence_items"
        ADD CONSTRAINT "fk_catalog_evidence_items_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_evidence_items"
        ADD CONSTRAINT "fk_catalog_evidence_items_column_id" FOREIGN KEY ("column_id")
        REFERENCES "data_catalog"."catalog_columns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_operation_impacts"
        ADD CONSTRAINT "fk_catalog_operation_impacts_operation_id" FOREIGN KEY ("operation_id")
        REFERENCES "data_catalog"."catalog_operations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_operation_impacts"
        ADD CONSTRAINT "fk_catalog_operation_impacts_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_operation_impacts"
        ADD CONSTRAINT "fk_catalog_operation_impacts_column_id" FOREIGN KEY ("column_id")
        REFERENCES "data_catalog"."catalog_columns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_process_steps"
        ADD CONSTRAINT "fk_catalog_process_steps_process_id" FOREIGN KEY ("process_id")
        REFERENCES "data_catalog"."catalog_processes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_process_step_operations"
        ADD CONSTRAINT "fk_catalog_process_step_operations_step_id" FOREIGN KEY ("step_id")
        REFERENCES "data_catalog"."catalog_process_steps" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_process_step_operations"
        ADD CONSTRAINT "fk_catalog_process_step_operations_operation_id" FOREIGN KEY ("operation_id")
        REFERENCES "data_catalog"."catalog_operations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
