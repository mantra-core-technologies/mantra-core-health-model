-- SALUD v4.2.80 · schema authz · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ permissions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."permissions" DROP CONSTRAINT IF EXISTS "ck_permissions_approval_needs_sensitivity";
ALTER TABLE "authz"."permissions" ADD CONSTRAINT "ck_permissions_approval_needs_sensitivity" CHECK (("approval_mode_concept_id" IS NULL OR "sensitivity_concept_id" IS NOT NULL));
