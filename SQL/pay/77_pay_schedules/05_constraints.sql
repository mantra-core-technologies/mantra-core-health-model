-- SALUD v4.2.81 · perfil pay · módulo 77 · base pay_schedules
-- Generado de diagram_77_pay_schedules.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

ALTER TABLE "merchant_replica" DROP CONSTRAINT IF EXISTS "merchant_replica_id_format";
ALTER TABLE "merchant_replica" ADD CONSTRAINT "merchant_replica_id_format" CHECK (merchant_id ~ '^mc_[a-z0-9]{10,40}$');

ALTER TABLE "merchant_replica" DROP CONSTRAINT IF EXISTS "merchant_replica_status_valid";
ALTER TABLE "merchant_replica" ADD CONSTRAINT "merchant_replica_status_valid" CHECK (status IN ('active', 'suspended', 'closed'));

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_id_format";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_id_format" CHECK (id ~ '^md_[a-z0-9]{10,40}$');

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_merchant_format";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_merchant_format" CHECK (merchant_id ~ '^mc_[a-z0-9]{10,40}$' AND beneficiary_merchant_id ~ '^mc_[a-z0-9]{10,40}$');

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_mode_valid";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_mode_valid" CHECK (mode IN ('test', 'live'));

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_kind_valid";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_kind_valid" CHECK (kind IN ('pay_obligation', 'pay_commission'));

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_amount_pos";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_amount_pos" CHECK (amount_minor >= 1);

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_currency_bob";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_currency_bob" CHECK (currency = 'BOB');

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_frequency_monthly";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_frequency_monthly" CHECK (frequency = 'monthly');

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_day_valid";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_day_valid" CHECK (day_of_month BETWEEN 1 AND 28);

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_end_after_start";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_end_after_start" CHECK (end_date IS NULL OR end_date >= start_date);

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_status_valid";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_status_valid" CHECK (status IN ('active', 'paused_insufficient_funds', 'canceled', 'completed'));

ALTER TABLE "mandates" DROP CONSTRAINT IF EXISTS "mandates_not_self";
ALTER TABLE "mandates" ADD CONSTRAINT "mandates_not_self" CHECK (merchant_id <> beneficiary_merchant_id);

ALTER TABLE "scheduled_payments" DROP CONSTRAINT IF EXISTS "scheduled_payments_id_format";
ALTER TABLE "scheduled_payments" ADD CONSTRAINT "scheduled_payments_id_format" CHECK (id ~ '^sp_[a-z0-9]{10,40}$');

ALTER TABLE "scheduled_payments" DROP CONSTRAINT IF EXISTS "scheduled_payments_period_format";
ALTER TABLE "scheduled_payments" ADD CONSTRAINT "scheduled_payments_period_format" CHECK (period ~ '^\d{4}-(0[1-9]|1[0-2])$');

ALTER TABLE "scheduled_payments" DROP CONSTRAINT IF EXISTS "scheduled_payments_status_valid";
ALTER TABLE "scheduled_payments" ADD CONSTRAINT "scheduled_payments_status_valid" CHECK (status IN ('due', 'waiting_funds', 'executed', 'failed', 'canceled'));

ALTER TABLE "scheduled_payments" DROP CONSTRAINT IF EXISTS "scheduled_payments_phase_valid";
ALTER TABLE "scheduled_payments" ADD CONSTRAINT "scheduled_payments_phase_valid" CHECK (phase IN ('hold', 'post', 'release', 'void', 'reverse', 'done'));

-- El dinero se movió: un `executed` siempre tiene su asiento (`tx_…`), que es lo que cita `scheduled_payment.executed.ledger_transfer_id`.
ALTER TABLE "scheduled_payments" DROP CONSTRAINT IF EXISTS "scheduled_payments_executed_has_transaction";
ALTER TABLE "scheduled_payments" ADD CONSTRAINT "scheduled_payments_executed_has_transaction" CHECK (status <> 'executed' OR (ledger_transaction_id IS NOT NULL AND executed_at IS NOT NULL));

ALTER TABLE "idempotency_keys" DROP CONSTRAINT IF EXISTS "idempotency_keys_state_check";
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_state_check" CHECK (state IN ('started', 'completed'));
