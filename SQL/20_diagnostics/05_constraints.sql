-- SALUD v4.0.10 · schema diagnostics · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ specimen_collection_events ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "diagnostics"."specimen_collection_events" DROP CONSTRAINT IF EXISTS "ck_specimen_collection_events_care_space_requires_site";
ALTER TABLE "diagnostics"."specimen_collection_events" ADD CONSTRAINT "ck_specimen_collection_events_care_space_requires_site" CHECK ("collection_care_space_id" IS NULL OR "collection_site_id" IS NOT NULL);


-- ═══ imaging_procedure_steps ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "diagnostics"."imaging_procedure_steps" DROP CONSTRAINT IF EXISTS "ck_imaging_procedure_steps_scheduled_space_requires_equipment";
ALTER TABLE "diagnostics"."imaging_procedure_steps" ADD CONSTRAINT "ck_imaging_procedure_steps_scheduled_space_requires_equipment" CHECK ("scheduled_care_space_id" IS NULL OR "scheduled_equipment_id" IS NOT NULL);
