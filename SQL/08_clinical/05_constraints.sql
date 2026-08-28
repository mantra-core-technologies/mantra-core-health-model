-- SALUD v4.0.10 · schema clinical · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ appointments ═══
-- TODO EXCLUDE (practitioner/location time overlap): ALTER TABLE "clinical"."appointments" ADD CONSTRAINT "ex_appointments_..." EXCLUDE USING gist (... WITH =, tstzrange(...) WITH &&) [WHERE ...];
--   LOCK: reservation confirmation transaction
