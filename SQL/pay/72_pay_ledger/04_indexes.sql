-- SALUD v4.2.82 · módulo 72 · schema pay_ledger
-- Generado de diagram_72_pay_ledger.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "ledger_accounts_tb_id_unique" ON "ledger_accounts" ("tb_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ledger_transactions_ref_attempt_key" ON "ledger_transactions" ("mode", "business_ref", "attempt");

CREATE UNIQUE INDEX IF NOT EXISTS "ledger_legs_source_index_key" ON "ledger_legs" ("source_id", "leg_index");

CREATE INDEX IF NOT EXISTS "ledger_legs_business_ref_idx" ON "ledger_legs" ("mode", "business_ref", "attempt");

CREATE INDEX IF NOT EXISTS "ledger_statement_lines_account_page_idx" ON "ledger_statement_lines" ("mode", "account", "posted_at" DESC, "id" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ledger_holds_ref_attempt_key" ON "ledger_holds" ("mode", "business_ref", "attempt");

CREATE INDEX IF NOT EXISTS "ledger_holds_pending_expiry_idx" ON "ledger_holds" ("expires_at") WHERE status = 'pending';

CREATE UNIQUE INDEX IF NOT EXISTS "ledger_rejections_ref_attempt_kind_key" ON "ledger_rejections" ("mode", "kind", "business_ref", "attempt");

CREATE UNIQUE INDEX IF NOT EXISTS "outbox_events_seq_key" ON "outbox_events" ("seq");

CREATE INDEX IF NOT EXISTS "outbox_events_pending_idx" ON "outbox_events" ("seq") WHERE published_at IS NULL;

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
