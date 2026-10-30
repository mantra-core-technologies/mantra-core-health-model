-- SALUD v4.0.10 · perfil pay · módulo 74 · base pay_payments
-- Generado de diagram_74_pay_payments.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_mode_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_mode_chk" CHECK (mode IN ('test', 'live'));

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_amount_positive_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_amount_positive_chk" CHECK (amount_minor > 0);

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_fee_net_sum_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_fee_net_sum_chk" CHECK (fee_minor >= 0 AND net_minor >= 0 AND fee_minor + net_minor = amount_minor);

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_method_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_method_chk" CHECK (method IN ('qr', 'card', 'bank_transfer', 'wallet'));

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_status_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_status_chk" CHECK (status IN ('requires_action', 'processing', 'succeeded', 'failed', 'canceled', 'expired'));

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_charge_status_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_charge_status_chk" CHECK (charge_status IN ('pending', 'authorized', 'captured', 'settled', 'failed', 'canceled', 'expired'));

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_card_token_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_card_token_chk" CHECK (card_token IS NULL OR card_token ~ '^tok_[a-z0-9]{10,60}$');

ALTER TABLE "payment_intents" DROP CONSTRAINT IF EXISTS "payment_intents_terminal_completed_chk";
ALTER TABLE "payment_intents" ADD CONSTRAINT "payment_intents_terminal_completed_chk" CHECK ((status IN ('succeeded', 'failed', 'canceled', 'expired')) = (completed_at IS NOT NULL));

ALTER TABLE "refunds" DROP CONSTRAINT IF EXISTS "refunds_mode_chk";
ALTER TABLE "refunds" ADD CONSTRAINT "refunds_mode_chk" CHECK (mode IN ('test', 'live'));

ALTER TABLE "refunds" DROP CONSTRAINT IF EXISTS "refunds_amount_positive_chk";
ALTER TABLE "refunds" ADD CONSTRAINT "refunds_amount_positive_chk" CHECK (amount_minor > 0);

ALTER TABLE "refunds" DROP CONSTRAINT IF EXISTS "refunds_status_chk";
ALTER TABLE "refunds" ADD CONSTRAINT "refunds_status_chk" CHECK (status IN ('pending', 'succeeded', 'failed'));

ALTER TABLE "disputes" DROP CONSTRAINT IF EXISTS "disputes_mode_chk";
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_mode_chk" CHECK (mode IN ('test', 'live'));

ALTER TABLE "disputes" DROP CONSTRAINT IF EXISTS "disputes_amount_positive_chk";
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_amount_positive_chk" CHECK (amount_minor > 0);

ALTER TABLE "disputes" DROP CONSTRAINT IF EXISTS "disputes_status_chk";
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_status_chk" CHECK (status IN ('open', 'won', 'lost'));

ALTER TABLE "merchant_replica" DROP CONSTRAINT IF EXISTS "merchant_replica_status_chk";
ALTER TABLE "merchant_replica" ADD CONSTRAINT "merchant_replica_status_chk" CHECK (status IN ('pending', 'active', 'suspended', 'closed'));

ALTER TABLE "idempotency_keys" DROP CONSTRAINT IF EXISTS "idempotency_keys_state_check";
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_state_check" CHECK (state IN ('started', 'completed'));
