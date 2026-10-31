-- SALUD v4.2.82 · schema insurance · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ patient_coverages ═══
--   UK: insurer + member identifier + effective period  (en prosa; el módulo 33 no declara su expresión SQL)
--   EXCLUDE: conflicting primary coverage periods  (en prosa; el módulo 33 no declara su expresión SQL)

-- ═══ claim_adjudication_versions ═══
--   UK: claim + adjudication version  (en prosa; el módulo 33 no declara su expresión SQL)
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "insurance"."claim_adjudication_versions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "insurance"."claim_adjudication_versions";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "insurance"."claim_adjudication_versions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ insurance_claims ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."insurance_claims" DROP CONSTRAINT IF EXISTS "ck_insurance_claims_single_order_origin";
ALTER TABLE "insurance"."insurance_claims" ADD CONSTRAINT "ck_insurance_claims_single_order_origin" CHECK (("inventory_reservation_id" IS NULL OR "service_request_id" IS NULL));


-- ═══ prior_authorization_requests ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."prior_authorization_requests" DROP CONSTRAINT IF EXISTS "ck_prior_authorizations_single_order_origin";
ALTER TABLE "insurance"."prior_authorization_requests" ADD CONSTRAINT "ck_prior_authorizations_single_order_origin" CHECK (("inventory_reservation_id" IS NULL OR "service_request_id" IS NULL));


-- ═══ insurance_campaigns ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."insurance_campaigns" DROP CONSTRAINT IF EXISTS "ck_insurance_campaigns_valid_period";
ALTER TABLE "insurance"."insurance_campaigns" ADD CONSTRAINT "ck_insurance_campaigns_valid_period" CHECK (("valid_from" <= "valid_to"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."insurance_campaigns" DROP CONSTRAINT IF EXISTS "ck_insurance_campaigns_copay_bonus_range";
ALTER TABLE "insurance"."insurance_campaigns" ADD CONSTRAINT "ck_insurance_campaigns_copay_bonus_range" CHECK (("copay_bonus_percentage" >= 0 AND "copay_bonus_percentage" <= 100));


-- ═══ claim_appeal_decisions ═══
--   UK: dispute + decision version  (en prosa; el módulo 33 no declara su expresión SQL)
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "insurance"."claim_appeal_decisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "insurance"."claim_appeal_decisions";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "insurance"."claim_appeal_decisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ claim_reversals ═══
--   UK: claim + idempotency_key  (en prosa; el módulo 33 no declara su expresión SQL)
--   UPDATE_DELETE: forbidden
--   índices únicos que la tabla ya tiene en 04_indexes: uq_claim_reversals_idempotency
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "insurance"."claim_reversals" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "insurance"."claim_reversals";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "insurance"."claim_reversals"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ coordination_of_benefits ═══
--   UK: patient + determination version  (en prosa; el módulo 33 no declara su expresión SQL)
--   EXCLUDE: overlapping active COB periods  (en prosa; el módulo 33 no declara su expresión SQL)

-- ═══ insurance_products ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."insurance_products" DROP CONSTRAINT IF EXISTS "ck_insurance_products_age_range";
ALTER TABLE "insurance"."insurance_products" ADD CONSTRAINT "ck_insurance_products_age_range" CHECK ((COALESCE("min_age_years", 0) >= 0 AND ("max_age_years" IS NULL OR "max_age_years" >= COALESCE("min_age_years", 0))));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."insurance_products" DROP CONSTRAINT IF EXISTS "ck_insurance_products_valid_period";
ALTER TABLE "insurance"."insurance_products" ADD CONSTRAINT "ck_insurance_products_valid_period" CHECK (("effective_from" IS NULL OR "effective_to" IS NULL OR "effective_from" <= "effective_to"));
