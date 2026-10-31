-- SALUD v4.2.81 · schema data_catalog · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


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


-- ═══ catalog_glossary_term_revisions ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_glossary_term_revisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_glossary_term_revisions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_glossary_term_revisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ quality_issue_events ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."quality_issue_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."quality_issue_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."quality_issue_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ quality_score_snapshots ═══
--   UPDATE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."quality_score_snapshots" DROP CONSTRAINT IF EXISTS "ck_quality_score_snapshots_score";
ALTER TABLE "data_catalog"."quality_score_snapshots" ADD CONSTRAINT "ck_quality_score_snapshots_score" CHECK (("score" BETWEEN 0 AND 100));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."quality_score_snapshots" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."quality_score_snapshots";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."quality_score_snapshots"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ catalog_change_acknowledgements ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_change_acknowledgements" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_change_acknowledgements";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_change_acknowledgements"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ catalog_stewardships ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_stewardships" DROP CONSTRAINT IF EXISTS "ck_catalog_stewardships_scope";
ALTER TABLE "data_catalog"."catalog_stewardships" ADD CONSTRAINT "ck_catalog_stewardships_scope" CHECK ((("scope_kind" = 'DOMAIN' AND "domain_id" IS NOT NULL AND "object_id" IS NULL) OR ("scope_kind" = 'OBJECT' AND "object_id" IS NOT NULL AND "domain_id" IS NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_stewardships" DROP CONSTRAINT IF EXISTS "ck_catalog_stewardships_holder";
ALTER TABLE "data_catalog"."catalog_stewardships" ADD CONSTRAINT "ck_catalog_stewardships_holder" CHECK (("user_id" IS NOT NULL OR "team_code" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_stewardships" DROP CONSTRAINT IF EXISTS "ck_catalog_stewardships_period";
ALTER TABLE "data_catalog"."catalog_stewardships" ADD CONSTRAINT "ck_catalog_stewardships_period" CHECK (("valid_to" IS NULL OR "valid_to" >= "valid_from"));


-- ═══ quality_rules ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."quality_rules" DROP CONSTRAINT IF EXISTS "ck_quality_rules_threshold";
ALTER TABLE "data_catalog"."quality_rules" ADD CONSTRAINT "ck_quality_rules_threshold" CHECK (("threshold_pct" BETWEEN 0 AND 100));


-- ═══ catalog_certifications ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_certifications" DROP CONSTRAINT IF EXISTS "ck_catalog_certifications_not_self";
ALTER TABLE "data_catalog"."catalog_certifications" ADD CONSTRAINT "ck_catalog_certifications_not_self" CHECK (("certified_by_user_id" IS NULL OR "certified_by_user_id" <> "requested_by_user_id"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_certifications" DROP CONSTRAINT IF EXISTS "ck_catalog_certifications_target";
ALTER TABLE "data_catalog"."catalog_certifications" ADD CONSTRAINT "ck_catalog_certifications_target" CHECK ((num_nonnulls("object_id", "read_model_definition_id", "report_definition_id", "kpi_code") = 1));
