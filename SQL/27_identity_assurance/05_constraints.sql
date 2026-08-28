-- SALUD v4.0.10 · schema identity_assurance · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ identity_verification_attempts ═══
-- TODO UK (case + endpoint + attempt number): ALTER TABLE "identity_assurance"."identity_verification_attempts" ADD CONSTRAINT "uq_identity_verification_attempts_..." UNIQUE (...);
-- TODO UK (endpoint + idempotency key): ALTER TABLE "identity_assurance"."identity_verification_attempts" ADD CONSTRAINT "uq_identity_verification_attempts_..." UNIQUE (...);
--   RETRY: bounded policy only
