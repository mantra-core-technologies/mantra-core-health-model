-- SALUD v4.2.81 · schema system_ops · constraints de integridad (módulo 33)
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


-- ═══ restore_test_runs ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."restore_test_runs" DROP CONSTRAINT IF EXISTS "ck_system_ops_restore_test_runs_objective_status";
ALTER TABLE "system_ops"."restore_test_runs" ADD CONSTRAINT "ck_system_ops_restore_test_runs_objective_status" CHECK ("objective_status" IN ('PASSED', 'FAILED', 'NOT_MEASURED'));
