-- SALUD v4.0.10 · schema insurance · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ patient_coverages ═══
-- TODO UK (insurer + member identifier + effective period): ALTER TABLE "insurance"."patient_coverages" ADD CONSTRAINT "uq_patient_coverages_..." UNIQUE (...);
-- TODO EXCLUDE (conflicting primary coverage periods): ALTER TABLE "insurance"."patient_coverages" ADD CONSTRAINT "ex_patient_coverages_..." EXCLUDE USING gist (... WITH =, tstzrange(...) WITH &&) [WHERE ...];

-- ═══ claim_adjudication_versions ═══
-- TODO UK (claim + adjudication version): ALTER TABLE "insurance"."claim_adjudication_versions" ADD CONSTRAINT "uq_claim_adjudication_versions_..." UNIQUE (...);
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "insurance"."claim_adjudication_versions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "insurance"."claim_adjudication_versions";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "insurance"."claim_adjudication_versions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ claim_appeal_decisions ═══
-- TODO UK (dispute + decision version): ALTER TABLE "insurance"."claim_appeal_decisions" ADD CONSTRAINT "uq_claim_appeal_decisions_..." UNIQUE (...);
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "insurance"."claim_appeal_decisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "insurance"."claim_appeal_decisions";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "insurance"."claim_appeal_decisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ claim_reversals ═══
-- TODO UK (claim + idempotency_key): ALTER TABLE "insurance"."claim_reversals" ADD CONSTRAINT "uq_claim_reversals_..." UNIQUE (...);
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "insurance"."claim_reversals" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "insurance"."claim_reversals";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "insurance"."claim_reversals"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ coordination_of_benefits ═══
-- TODO UK (patient + determination version): ALTER TABLE "insurance"."coordination_of_benefits" ADD CONSTRAINT "uq_coordination_of_benefits_..." UNIQUE (...);
-- TODO EXCLUDE (overlapping active COB periods): ALTER TABLE "insurance"."coordination_of_benefits" ADD CONSTRAINT "ex_coordination_of_benefits_..." EXCLUDE USING gist (... WITH =, tstzrange(...) WITH &&) [WHERE ...];
