-- SALUD v4.2.83 · módulo 79 · schema pay_vault
-- Generado de diagram_79_pay_vault.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "capture_sessions_merchant_idx" ON "capture_sessions" ("merchant_id", "created_at");

CREATE INDEX IF NOT EXISTS "card_tokens_merchant_idx" ON "card_tokens" ("merchant_id", "created_at");

CREATE INDEX IF NOT EXISTS "reveal_audit_token_idx" ON "reveal_audit" ("token", "at");

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
