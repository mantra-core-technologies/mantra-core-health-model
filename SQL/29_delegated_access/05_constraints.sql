-- SALUD v4.0.10 · schema delegated_access · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ practitioner_delegate_assignments ═══
-- TODO EXCLUDE (incompatible overlapping assignments): ALTER TABLE "delegated_access"."practitioner_delegate_assignments" ADD CONSTRAINT "ex_practitioner_delegate_assignments_..." EXCLUDE USING gist (... WITH =, tstzrange(...) WITH &&) [WHERE ...];
-- TODO CHECK (signature permission requires authorized role): ALTER TABLE "delegated_access"."practitioner_delegate_assignments" ADD CONSTRAINT "ck_practitioner_delegate_assignments_..." CHECK (...);
