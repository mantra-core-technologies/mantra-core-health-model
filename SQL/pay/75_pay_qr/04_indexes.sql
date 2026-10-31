-- SALUD v4.2.80 · módulo 75 · schema pay_qr
-- Generado de diagram_75_pay_qr.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "qr_codes_reference_uidx" ON "qr_codes" ("reference");

CREATE UNIQUE INDEX IF NOT EXISTS "qr_codes_static_per_merchant_uidx" ON "qr_codes" ("pay_mode", "merchant_id") WHERE kind = 'static' AND canceled_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "qr_codes_live_per_intent_uidx" ON "qr_codes" ("pay_mode", "payment_intent_id") WHERE kind = 'dynamic' AND canceled_at IS NULL;

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
