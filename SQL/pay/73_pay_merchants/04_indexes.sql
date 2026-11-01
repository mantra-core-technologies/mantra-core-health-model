-- SALUD v4.2.83 · módulo 73 · schema pay_merchants
-- Generado de diagram_73_pay_merchants.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "merchants_tax_id_open_uq" ON "merchants" ("tax_id") WHERE status <> 'closed';

CREATE INDEX IF NOT EXISTS "kyc_documents_merchant_kind_idx" ON "kyc_documents" ("merchant_id", "kind", "uploaded_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "contract_acceptances_merchant_version_uq" ON "contract_acceptances" ("merchant_id", "version");

CREATE INDEX IF NOT EXISTS "api_keys_merchant_created_idx" ON "api_keys" ("merchant_id", "created_at" DESC, "key_id" DESC);

CREATE INDEX IF NOT EXISTS "api_keys_grace_pending_idx" ON "api_keys" ("grace_ends_at") WHERE revoked_at IS NULL AND grace_ends_at IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "outbox_events_seq_key" ON "outbox_events" ("seq");

CREATE INDEX IF NOT EXISTS "outbox_events_pending_idx" ON "outbox_events" ("seq") WHERE published_at IS NULL;

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
