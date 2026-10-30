-- SALUD v4.0.10 · perfil pay · módulo 80 · base pay_webhooks
-- Generado de diagram_80_pay_webhooks.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

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
