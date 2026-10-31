-- SALUD v4.0.10 · schema practice · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ care_spaces ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_buffers";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_fhir_physical_type";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_fhir_physical_type" CHECK (("fhir_physical_type" IS NULL OR "fhir_physical_type" IN ('bu', 'lvl', 'wi', 'ro', 'bd', 'si')));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_location_path";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_location_path" CHECK (("location_path" IS NULL OR "location_path" ~ '^/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)+$'));


-- ═══ practitioner_location_assignments ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."practitioner_location_assignments" DROP CONSTRAINT IF EXISTS "ck_practitioner_location_assignments_period";
ALTER TABLE "practice"."practitioner_location_assignments" ADD CONSTRAINT "ck_practitioner_location_assignments_period" CHECK (("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to"));
