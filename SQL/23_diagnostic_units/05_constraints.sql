-- SALUD v4.0.10 · schema diagnostic_units · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ diagnostic_study_prices ═══
-- TODO UK (schedule + offering + version): ALTER TABLE "diagnostic_units"."diagnostic_study_prices" ADD CONSTRAINT "uq_diagnostic_study_prices_..." UNIQUE (...);
-- TODO EXCLUDE (no overlapping active effective periods): ALTER TABLE "diagnostic_units"."diagnostic_study_prices" ADD CONSTRAINT "ex_diagnostic_study_prices_..." EXCLUDE USING gist (... WITH =, tstzrange(...) WITH &&) [WHERE ...];
-- TODO CHECK (amounts >= 0): ALTER TABLE "diagnostic_units"."diagnostic_study_prices" ADD CONSTRAINT "ck_diagnostic_study_prices_..." CHECK (...);
