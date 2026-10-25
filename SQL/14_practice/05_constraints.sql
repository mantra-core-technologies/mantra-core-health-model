-- SALUD v4.0.10 · schema practice · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ care_spaces ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_buffers";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));
