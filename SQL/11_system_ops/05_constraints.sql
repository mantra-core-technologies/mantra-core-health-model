-- SALUD v4.0.10 · schema system_ops · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ restore_test_runs ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."restore_test_runs" DROP CONSTRAINT IF EXISTS "ck_system_ops_restore_test_runs_objective_status";
ALTER TABLE "system_ops"."restore_test_runs" ADD CONSTRAINT "ck_system_ops_restore_test_runs_objective_status" CHECK ("objective_status" IN ('PASSED', 'FAILED', 'NOT_MEASURED'));
