-- SALUD v4.2.80 · schema telemetry · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ user_activity_events ═══
--   UK: event schema + event idempotency key  (en prosa; el módulo 33 no declara su expresión SQL)
--   PARTITION: received_at
--   RETENTION: purpose-specific
