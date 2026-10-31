-- SALUD v4.2.68 · schema system_ops · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ restore_test_runs ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."restore_test_runs" DROP CONSTRAINT IF EXISTS "ck_system_ops_restore_test_runs_objective_status";
ALTER TABLE "system_ops"."restore_test_runs" ADD CONSTRAINT "ck_system_ops_restore_test_runs_objective_status" CHECK ("objective_status" IN ('PASSED', 'FAILED', 'NOT_MEASURED'));
