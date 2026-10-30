-- SALUD v4.0.10 · módulo 76 · schema pay_risk
-- Generado de diagram_76_pay_risk.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "risk_assessments_request_uq" ON "risk_assessments" ("caller_service", "request_key");

CREATE INDEX IF NOT EXISTS "risk_assessments_merchant_created_idx" ON "risk_assessments" ("merchant_id", "created_at");

CREATE INDEX IF NOT EXISTS "risk_assessments_payer_created_idx" ON "risk_assessments" ("payer_hash", "created_at") WHERE payer_hash IS NOT NULL;

CREATE INDEX IF NOT EXISTS "risk_assessments_intent_idx" ON "risk_assessments" ("payment_intent_id", "created_at");

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
