-- SALUD v4.2.68 · schema delegated_access · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ practitioner_delegate_assignments ═══
--   EXCLUDE: incompatible overlapping assignments  (en prosa; el módulo 33 no declara su expresión SQL)
--   CHECK: signature permission requires authorized role  (en prosa; el módulo 33 no declara su expresión SQL)

-- ═══ organization_user_assignments ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ck_org_user_assignments_scope_target";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ck_org_user_assignments_scope_target" CHECK (("access_scope_concept_id" <> '928c884d-ff91-584c-8aa6-68535085e078' OR "clinical_unit_id" IS NOT NULL) AND ("access_scope_concept_id" <> '4df1a147-cb37-55ba-94e8-ab469e9cccb0' OR "care_space_id" IS NOT NULL) AND ("access_scope_concept_id" <> 'e69a4c95-fe59-5c3e-b826-222af123adb9' OR "practice_site_id" IS NOT NULL));

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ex_org_user_assignments_unit_head";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ex_org_user_assignments_unit_head"
    EXCLUDE USING gist ("clinical_unit_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH &&) WHERE ("assignment_role_concept_id" = 'ce54425b-5479-57f1-8bb2-274a8617723c' AND "status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19');


-- ═══ shared_access_link_uses ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "delegated_access"."shared_access_link_uses" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "delegated_access"."shared_access_link_uses";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "delegated_access"."shared_access_link_uses"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();
