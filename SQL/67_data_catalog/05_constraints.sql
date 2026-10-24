-- SALUD v4.0.10 · schema data_catalog · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ catalog_change_events ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_change_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_change_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_change_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ catalog_annotation_revisions ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_annotation_revisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_annotation_revisions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_annotation_revisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ catalog_review_decisions ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_review_decisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_review_decisions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_review_decisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ catalog_evidence_items ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_evidence_items" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_evidence_items";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_evidence_items"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();
