-- SALUD v4.2.80 · schema procedures_perioperative · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ procedure_cases ═══
--   EXCLUDE: operating room time overlap  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "procedures_perioperative"."procedure_cases" DROP CONSTRAINT IF EXISTS "ex_procedure_cases_operating_room_time";
ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ex_procedure_cases_operating_room_time"
    EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("scheduled_start_at", "scheduled_end_at", '[)') WITH &&) WHERE ("operating_room_id" IS NOT NULL AND "scheduled_start_at" IS NOT NULL AND "scheduled_end_at" IS NOT NULL AND "status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."procedure_cases" DROP CONSTRAINT IF EXISTS "ck_procedure_cases_buffers";
ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ck_procedure_cases_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));
