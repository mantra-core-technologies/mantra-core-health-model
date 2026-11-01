-- SALUD v4.2.83 · schema system_ops · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ governance_policy_revisions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."governance_policy_revisions" DROP CONSTRAINT IF EXISTS "ck_governance_policy_revisions_not_self";
ALTER TABLE "system_ops"."governance_policy_revisions" ADD CONSTRAINT "ck_governance_policy_revisions_not_self" CHECK (("decided_by_user_id" IS NULL OR "decided_by_user_id" <> "submitted_by_user_id"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."governance_policy_revisions" DROP CONSTRAINT IF EXISTS "ck_governance_policy_revisions_decision";
ALTER TABLE "system_ops"."governance_policy_revisions" ADD CONSTRAINT "ck_governance_policy_revisions_decision" CHECK (("status" NOT IN ('APPROVED', 'REJECTED') OR ("decided_by_user_id" IS NOT NULL AND "decided_at" IS NOT NULL)));


-- ═══ bulk_import_batches ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."bulk_import_batches" DROP CONSTRAINT IF EXISTS "ck_bulk_import_batches_counts";
ALTER TABLE "system_ops"."bulk_import_batches" ADD CONSTRAINT "ck_bulk_import_batches_counts" CHECK (("rows_total" >= 0 AND "rows_valid" >= 0 AND "rows_rejected" >= 0 AND "rows_total" = "rows_valid" + "rows_rejected" AND "processed_rows" BETWEEN 0 AND "rows_total" AND "issues_total" >= 0));


-- ═══ bulk_import_batch_rows ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."bulk_import_batch_rows" DROP CONSTRAINT IF EXISTS "ck_bulk_import_batch_rows_row_no";
ALTER TABLE "system_ops"."bulk_import_batch_rows" ADD CONSTRAINT "ck_bulk_import_batch_rows_row_no" CHECK (("row_no" >= 1));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."bulk_import_batch_rows" DROP CONSTRAINT IF EXISTS "ck_bulk_import_batch_rows_closed_no_data";
ALTER TABLE "system_ops"."bulk_import_batch_rows" ADD CONSTRAINT "ck_bulk_import_batch_rows_closed_no_data" CHECK (("outcome" IS NULL OR ("row_data_json" IS NULL AND "row_key" IS NULL)));


-- ═══ restore_test_runs ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."restore_test_runs" DROP CONSTRAINT IF EXISTS "ck_system_ops_restore_test_runs_objective_status";
ALTER TABLE "system_ops"."restore_test_runs" ADD CONSTRAINT "ck_system_ops_restore_test_runs_objective_status" CHECK ("objective_status" IN ('PASSED', 'FAILED', 'NOT_MEASURED'));
