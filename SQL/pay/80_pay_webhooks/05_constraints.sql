-- SALUD v4.0.10 · perfil pay · módulo 80 · base pay_webhooks
-- Generado de diagram_80_pay_webhooks.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

CREATE OR REPLACE FUNCTION forbid_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'la tabla % es inmutable (%)', TG_TABLE_NAME, TG_OP USING ERRCODE = 'integrity_constraint_violation';
END;
$$;

ALTER TABLE "webhook_endpoints" DROP CONSTRAINT IF EXISTS "webhook_endpoints_id_check";
ALTER TABLE "webhook_endpoints" ADD CONSTRAINT "webhook_endpoints_id_check" CHECK (id ~ '^we_[a-z0-9]{10,40}$');

ALTER TABLE "webhook_endpoints" DROP CONSTRAINT IF EXISTS "webhook_endpoints_events_check";
ALTER TABLE "webhook_endpoints" ADD CONSTRAINT "webhook_endpoints_events_check" CHECK (cardinality(enabled_events) >= 1);

ALTER TABLE "webhook_endpoints" DROP CONSTRAINT IF EXISTS "webhook_endpoints_scheme_check";
ALTER TABLE "webhook_endpoints" ADD CONSTRAINT "webhook_endpoints_scheme_check" CHECK (signature_scheme IN ('v1', 'v1a'));

ALTER TABLE "webhook_endpoints" DROP CONSTRAINT IF EXISTS "webhook_endpoints_status_check";
ALTER TABLE "webhook_endpoints" ADD CONSTRAINT "webhook_endpoints_status_check" CHECK (status IN ('enabled', 'disabled'));

ALTER TABLE "webhook_endpoints" DROP CONSTRAINT IF EXISTS "webhook_endpoints_reason_check";
ALTER TABLE "webhook_endpoints" ADD CONSTRAINT "webhook_endpoints_reason_check" CHECK (disabled_reason IS NULL OR disabled_reason IN ('gone_410', 'too_many_failures', 'manual'));

ALTER TABLE "webhook_endpoints" DROP CONSTRAINT IF EXISTS "webhook_endpoints_reason_status_check";
ALTER TABLE "webhook_endpoints" ADD CONSTRAINT "webhook_endpoints_reason_status_check" CHECK ((status = 'disabled') = (disabled_reason IS NOT NULL));

ALTER TABLE "webhook_deliveries" DROP CONSTRAINT IF EXISTS "webhook_deliveries_status_check";
ALTER TABLE "webhook_deliveries" ADD CONSTRAINT "webhook_deliveries_status_check" CHECK (status IN ('pending', 'succeeded', 'dead'));

ALTER TABLE "idempotency_keys" DROP CONSTRAINT IF EXISTS "idempotency_keys_state_check";
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_state_check" CHECK (state IN ('started', 'completed'));

-- Un intento de entrega es un hecho ya ocurrido: delivery.worker.ts solo hace INSERT … ON CONFLICT DO NOTHING (el estado que cambia vive en webhook_deliveries, que SÍ se actualiza y
-- NO se guarda). No hay UPDATE/DELETE/TRUNCATE sobre esta tabla en services/*/src; las pruebas la vacían dentro de una transacción que apaga SOLO este trigger (ver test/harness.ts).
DROP TRIGGER IF EXISTS "webhook_delivery_attempts_immutable" ON "webhook_delivery_attempts";
CREATE TRIGGER webhook_delivery_attempts_immutable BEFORE UPDATE OR DELETE ON webhook_delivery_attempts FOR EACH ROW EXECUTE FUNCTION forbid_mutation();

DROP TRIGGER IF EXISTS "webhook_delivery_attempts_no_truncate" ON "webhook_delivery_attempts";
CREATE TRIGGER webhook_delivery_attempts_no_truncate BEFORE TRUNCATE ON webhook_delivery_attempts FOR EACH STATEMENT EXECUTE FUNCTION forbid_mutation();
