-- SALUD v4.2.81 · módulo 78 · schema pay_settlement
-- Generado de diagram_78_pay_settlement.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "settlement_batches_cutoff_unique" ON "settlement_batches" ("mode", "cutoff_date");

CREATE UNIQUE INDEX IF NOT EXISTS "settlement_payouts_batch_merchant_unique" ON "settlement_payouts" ("batch_id", "merchant_id") WHERE batch_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "settlement_payouts_merchant_page" ON "settlement_payouts" ("mode", "merchant_id", "created_at" DESC, "id" DESC);

CREATE INDEX IF NOT EXISTS "settlement_payouts_open" ON "settlement_payouts" ("updated_at") WHERE step <> 'resolved';

CREATE UNIQUE INDEX IF NOT EXISTS "settlement_charges_period_unique" ON "settlement_charges" ("mode", "merchant_id", "kind", "period_key");

CREATE INDEX IF NOT EXISTS "settlement_charges_open" ON "settlement_charges" ("mode", "merchant_id") WHERE status = 'open';

CREATE UNIQUE INDEX IF NOT EXISTS "settlement_exceptions_dedupe_unique" ON "settlement_exceptions" ("dedupe_key");

CREATE INDEX IF NOT EXISTS "settlement_exceptions_page" ON "settlement_exceptions" ("mode", "created_at" DESC, "id" DESC);

CREATE INDEX IF NOT EXISTS "settlement_exceptions_run" ON "settlement_exceptions" ("run_id");

CREATE UNIQUE INDEX IF NOT EXISTS "settlement_adjustment_requests_exception_unique" ON "settlement_adjustment_requests" ("exception_id");

CREATE UNIQUE INDEX IF NOT EXISTS "outbox_events_seq_key" ON "outbox_events" ("seq");

CREATE INDEX IF NOT EXISTS "outbox_events_pending_idx" ON "outbox_events" ("seq") WHERE published_at IS NULL;

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
