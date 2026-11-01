-- SALUD v4.2.83 · schema diagnostic_units · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ diagnostic_study_prices ═══
--   UK: schedule + offering + version  (en prosa; el módulo 33 no declara su expresión SQL)
--   EXCLUDE: no overlapping active effective periods  (en prosa; el módulo 33 no declara su expresión SQL)
--   CHECK: amounts >= 0  (en prosa; el módulo 33 no declara su expresión SQL)
--   índices únicos que la tabla ya tiene en 04_indexes: uq_diagnostic_study_prices_price_schedule_id_version_number

-- ═══ diagnostic_equipment ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "diagnostic_units"."diagnostic_equipment" DROP CONSTRAINT IF EXISTS "ck_diagnostic_equipment_ae_title";
ALTER TABLE "diagnostic_units"."diagnostic_equipment" ADD CONSTRAINT "ck_diagnostic_equipment_ae_title" CHECK ("ae_title" IS NULL OR ("ae_title" ~ '^[\x20-\x7E]{1,16}$' AND btrim("ae_title") <> '' AND "ae_title" !~ '\\'));
