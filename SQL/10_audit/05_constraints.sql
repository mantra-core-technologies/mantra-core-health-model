-- SALUD v4.0.10 · schema audit · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ audit_log ═══
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "audit"."audit_log" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "audit"."audit_log";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "audit"."audit_log"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ data_access_log ═══
--   UPDATE: forbidden
--   DELETE: retention purge only (UC-10-09)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "audit"."data_access_log" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "audit"."data_access_log";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "audit"."data_access_log"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();
