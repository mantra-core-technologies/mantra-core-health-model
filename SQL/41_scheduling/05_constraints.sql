-- SALUD v4.0.10 · schema scheduling · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ practitioner_service_offerings ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."practitioner_service_offerings" DROP CONSTRAINT IF EXISTS "ck_practitioner_service_offerings_duration_range";
ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "ck_practitioner_service_offerings_duration_range" CHECK (("min_duration_minutes" > 0 AND "min_duration_minutes" <= "max_duration_minutes" AND "max_duration_minutes" <= 720));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."practitioner_service_offerings" DROP CONSTRAINT IF EXISTS "ck_practitioner_service_offerings_buffers";
ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "ck_practitioner_service_offerings_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));
