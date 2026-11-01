-- SALUD v4.2.83 · módulo 80 · schema pay_webhooks
-- Generado de diagram_80_pay_webhooks.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "webhook_endpoints_merchant_idx" ON "webhook_endpoints" ("merchant_id", "created_at" DESC, "id" DESC) WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "webhook_deliveries_endpoint_event_key" ON "webhook_deliveries" ("endpoint_id", "event_id");

CREATE INDEX IF NOT EXISTS "webhook_deliveries_due_idx" ON "webhook_deliveries" ("next_attempt_at") WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
