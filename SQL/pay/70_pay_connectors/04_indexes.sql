-- SALUD v4.2.79 · módulo 70 · schema pay_connectors
-- Generado de diagram_70_pay_connectors.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "connector_charges_caller_key_uidx" ON "connector_charges" ("caller", "pay_mode", "idempotency_key");

CREATE UNIQUE INDEX IF NOT EXISTS "connector_charges_live_intent_uidx" ON "connector_charges" ("pay_mode", "payment_intent_id") WHERE provider_status IN ('pending', 'authorized', 'captured');

CREATE INDEX IF NOT EXISTS "connector_charges_poll_idx" ON "connector_charges" ("next_poll_at") WHERE provider_status IN ('pending', 'authorized');

CREATE UNIQUE INDEX IF NOT EXISTS "connector_refunds_caller_key_uidx" ON "connector_refunds" ("caller", "pay_mode", "idempotency_key");

CREATE INDEX IF NOT EXISTS "connector_refunds_charge_idx" ON "connector_refunds" ("charge_id");

CREATE UNIQUE INDEX IF NOT EXISTS "connector_refunds_refund_id_uidx" ON "connector_refunds" ("pay_mode", "refund_id") WHERE refund_id IS NOT NULL AND status <> 'failed';

CREATE UNIQUE INDEX IF NOT EXISTS "connector_callback_events_dedup_uidx" ON "connector_callback_events" ("connector", "provider_event_id");

CREATE INDEX IF NOT EXISTS "connector_callback_events_charge_idx" ON "connector_callback_events" ("charge_id");

CREATE INDEX IF NOT EXISTS "connector_api_attempts_subject_idx" ON "connector_api_attempts" ("subject_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "connector_callback_endpoints_path_uidx" ON "connector_callback_endpoints" ("connector", "callback_path");

CREATE UNIQUE INDEX IF NOT EXISTS "routing_rule_sets_one_active_uidx" ON "routing_rule_sets" ("active") WHERE active;

CREATE UNIQUE INDEX IF NOT EXISTS "bank_transfer_references_charge_uidx" ON "bank_transfer_references" ("charge_id");

CREATE UNIQUE INDEX IF NOT EXISTS "statement_exceptions_line_uidx" ON "statement_exceptions" ("connector", "provider_reference", "kind");

CREATE UNIQUE INDEX IF NOT EXISTS "connector_transfers_ref_attempt_uidx" ON "connector_transfers" ("pay_mode", "business_ref", "attempt");

CREATE UNIQUE INDEX IF NOT EXISTS "connector_transfers_one_paid_uidx" ON "connector_transfers" ("pay_mode", "business_ref") WHERE status = 'paid';

CREATE UNIQUE INDEX IF NOT EXISTS "outbox_events_seq_key" ON "outbox_events" ("seq");

CREATE INDEX IF NOT EXISTS "outbox_events_pending_idx" ON "outbox_events" ("seq") WHERE published_at IS NULL;

CREATE INDEX IF NOT EXISTS "idempotency_keys_expires_at_idx" ON "idempotency_keys" ("expires_at");
