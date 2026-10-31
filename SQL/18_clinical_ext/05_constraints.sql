-- SALUD v4.2.68 · schema clinical_ext · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ cds_rule_versions ═══
--   UPDATE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."cds_rule_versions" DROP CONSTRAINT IF EXISTS "ck_cds_rule_versions_number";
ALTER TABLE "clinical_ext"."cds_rule_versions" ADD CONSTRAINT "ck_cds_rule_versions_number" CHECK ("version_number" >= 1);

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "clinical_ext"."cds_rule_versions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "clinical_ext"."cds_rule_versions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "clinical_ext"."cds_rule_versions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();
