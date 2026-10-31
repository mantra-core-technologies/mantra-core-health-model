-- SALUD v4.2.82 · schema telemetry · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ user_activity_events ═══
--   UK: event schema + event idempotency key  (en prosa; el módulo 33 no declara su expresión SQL)
--   PARTITION: received_at
--   RETENTION: purpose-specific
--   índices únicos que la tabla ya tiene en 04_indexes: ux_user_activity_events_anonymous_idempotency

-- ═══ client_error_events ═══
--   UPDATE: forbidden
--   RETENTION: 90 days (purge job on received_at; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "telemetry"."client_error_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "telemetry"."client_error_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "telemetry"."client_error_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();
