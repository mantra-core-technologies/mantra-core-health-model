-- SALUD v4.2.68 · módulo 74 · schema pay_payments
-- Generado de diagram_74_pay_payments.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "payment_intents_merchant_created_idx" ON "payment_intents" ("merchant_id", "mode", "created_at" DESC, "id" DESC);

CREATE INDEX IF NOT EXISTS "payment_intents_merchant_status_idx" ON "payment_intents" ("merchant_id", "status");

CREATE UNIQUE INDEX IF NOT EXISTS "payment_intents_mandate_period_uidx" ON "payment_intents" ((source ->> 'id'), (source ->> 'period')) WHERE source IS NOT NULL;

CREATE INDEX IF NOT EXISTS "payment_intents_charge_idx" ON "payment_intents" ("charge_id") WHERE charge_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "refunds_intent_idx" ON "refunds" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "refunds_merchant_created_idx" ON "refunds" ("merchant_id", "mode", "created_at" DESC, "id" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "disputes_one_open_per_intent_uidx" ON "disputes" ("payment_intent_id") WHERE status = 'open';

CREATE INDEX IF NOT EXISTS "fee_schedule_replica_effective_idx" ON "fee_schedule_replica" ("merchant_id", "effective_from" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "intent_contradictions_event_uidx" ON "intent_contradictions" ("payment_intent_id", "source_event_id");

CREATE UNIQUE INDEX IF NOT EXISTS "outbox_events_seq_key" ON "outbox_events" ("seq");

CREATE INDEX IF NOT EXISTS "outbox_events_pending_idx" ON "outbox_events" ("seq") WHERE published_at IS NULL;

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
