-- SALUD v4.2.83 · schema scheduling · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ practitioner_service_offerings ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."practitioner_service_offerings" DROP CONSTRAINT IF EXISTS "ck_practitioner_service_offerings_duration_range";
ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "ck_practitioner_service_offerings_duration_range" CHECK (("min_duration_minutes" > 0 AND "min_duration_minutes" <= "max_duration_minutes" AND "max_duration_minutes" <= 720));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."practitioner_service_offerings" DROP CONSTRAINT IF EXISTS "ck_practitioner_service_offerings_buffers";
ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "ck_practitioner_service_offerings_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));


-- ═══ schedulable_resources ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."schedulable_resources" DROP CONSTRAINT IF EXISTS "ck_schedulable_resources_care_space_ref";
ALTER TABLE "scheduling"."schedulable_resources" ADD CONSTRAINT "ck_schedulable_resources_care_space_ref" CHECK (("resource_ref_type" <> 'care_spaces' OR "care_space_id" = "resource_ref_id"));


-- ═══ booking_policies ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."booking_policies" DROP CONSTRAINT IF EXISTS "ck_booking_policies_no_show_fee_percentage";
ALTER TABLE "scheduling"."booking_policies" ADD CONSTRAINT "ck_booking_policies_no_show_fee_percentage" CHECK (("no_show_fee_percentage" IS NULL OR ("no_show_fee_percentage" >= 0 AND "no_show_fee_percentage" <= 100)));
