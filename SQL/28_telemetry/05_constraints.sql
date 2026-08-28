-- SALUD v4.0.10 · schema telemetry · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ user_activity_events ═══
-- TODO UK (event schema + event idempotency key): ALTER TABLE "telemetry"."user_activity_events" ADD CONSTRAINT "uq_user_activity_events_..." UNIQUE (...);
--   PARTITION: received_at
--   RETENTION: purpose-specific
