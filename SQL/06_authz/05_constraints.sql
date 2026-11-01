-- SALUD v4.2.82 · schema authz · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ ui_visibility_elements ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_key";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_key" CHECK (char_length("key") <= 160 AND "key" ~ '^[a-z][a-z0-9-]*(\.[a-z0-9][a-z0-9-]*)*$');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_kind";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_kind" CHECK ("kind" IN ('MODULE', 'MENU_SECTION', 'SCREEN', 'SECTION', 'WIDGET', 'FIELD', 'ACTION'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_source";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_source" CHECK ("source" IN ('CODE', 'ADMIN'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_status";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_status" CHECK ("status" IN ('ACTIVE', 'RETIRED'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_retired";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_retired" CHECK (("status" = 'RETIRED') = ("retired_at" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_not_own_parent";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_not_own_parent" CHECK ("parent_element_id" IS NULL OR "parent_element_id" <> "id");


-- ═══ ui_visibility_rules ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_effect";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_effect" CHECK ("effect" IN ('SHOW', 'HIDE'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_subject_type";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_subject_type" CHECK ("subject_type" IN ('USER', 'TENANT', 'ROLE', 'ORG_TYPE', 'ALL'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_subject_shape";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_subject_shape" CHECK (("subject_type" = 'ALL') = ("subject_id" IS NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_subject_id_len";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_subject_id_len" CHECK (char_length("subject_id") BETWEEN 1 AND 160);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_validity";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_validity" CHECK ("ended_at" IS NOT NULL OR "valid_from" IS NULL OR "valid_to" IS NULL OR "valid_to" > "valid_from");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_reason_len";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_reason_len" CHECK (char_length(btrim("reason")) BETWEEN 10 AND 500);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_ended_has_valid_to";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_ended_has_valid_to" CHECK ("ended_at" IS NULL OR "valid_to" IS NOT NULL);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_scope_subject";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_scope_subject" CHECK ("scope_tenant_id" IS NULL OR ("subject_type" IN ('TENANT', 'USER') AND ("subject_type" <> 'TENANT' OR "subject_id" = "scope_tenant_id"::text)));


-- ═══ permissions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."permissions" DROP CONSTRAINT IF EXISTS "ck_permissions_approval_needs_sensitivity";
ALTER TABLE "authz"."permissions" ADD CONSTRAINT "ck_permissions_approval_needs_sensitivity" CHECK (("approval_mode_concept_id" IS NULL OR "sensitivity_concept_id" IS NOT NULL));
