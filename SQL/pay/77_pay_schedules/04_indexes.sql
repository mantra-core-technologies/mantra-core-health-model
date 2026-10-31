-- SALUD v4.2.80 · módulo 77 · schema pay_schedules
-- Generado de diagram_77_pay_schedules.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "mandates_owner_idx" ON "mandates" ("merchant_id", "mode", "created_at" DESC, "id" DESC);

CREATE INDEX IF NOT EXISTS "mandates_due_idx" ON "mandates" ("next_run_on") WHERE status = 'active' AND next_run_on IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "scheduled_payments_period_uq" ON "scheduled_payments" ("mandate_id", "period");

CREATE INDEX IF NOT EXISTS "scheduled_payments_due_idx" ON "scheduled_payments" ("next_attempt_at") WHERE status IN ('due', 'waiting_funds');

CREATE UNIQUE INDEX IF NOT EXISTS "outbox_events_seq_key" ON "outbox_events" ("seq");

CREATE INDEX IF NOT EXISTS "outbox_events_pending_idx" ON "outbox_events" ("seq") WHERE published_at IS NULL;

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
