-- SALUD v4.2.68 · perfil pay · módulo 78 · base pay_settlement
-- Generado de diagram_78_pay_settlement.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

ALTER TABLE "settlement_merchant_marks" DROP CONSTRAINT IF EXISTS "settlement_merchant_marks_mode_check";
ALTER TABLE "settlement_merchant_marks" ADD CONSTRAINT "settlement_merchant_marks_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "settlement_fee_plans" DROP CONSTRAINT IF EXISTS "settlement_fee_plans_version_check";
ALTER TABLE "settlement_fee_plans" ADD CONSTRAINT "settlement_fee_plans_version_check" CHECK (version >= 1);

ALTER TABLE "settlement_fee_plans" DROP CONSTRAINT IF EXISTS "settlement_fee_plans_monthly_fee_minor_check";
ALTER TABLE "settlement_fee_plans" ADD CONSTRAINT "settlement_fee_plans_monthly_fee_minor_check" CHECK (monthly_fee_minor >= 0);

ALTER TABLE "settlement_batches" DROP CONSTRAINT IF EXISTS "settlement_batches_mode_check";
ALTER TABLE "settlement_batches" ADD CONSTRAINT "settlement_batches_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "settlement_batches" DROP CONSTRAINT IF EXISTS "settlement_batches_release_days_check";
ALTER TABLE "settlement_batches" ADD CONSTRAINT "settlement_batches_release_days_check" CHECK (release_days BETWEEN 0 AND 60);

ALTER TABLE "settlement_batches" DROP CONSTRAINT IF EXISTS "settlement_batches_status_check";
ALTER TABLE "settlement_batches" ADD CONSTRAINT "settlement_batches_status_check" CHECK (status IN ('running', 'completed', 'failed'));

ALTER TABLE "settlement_batches" DROP CONSTRAINT IF EXISTS "settlement_batches_released_minor_check";
ALTER TABLE "settlement_batches" ADD CONSTRAINT "settlement_batches_released_minor_check" CHECK (released_minor >= 0);

ALTER TABLE "settlement_batch_items" DROP CONSTRAINT IF EXISTS "settlement_batch_items_status_check";
ALTER TABLE "settlement_batch_items" ADD CONSTRAINT "settlement_batch_items_status_check" CHECK (status IN ('pending', 'planned', 'released', 'done', 'failed'));

ALTER TABLE "settlement_batch_items" DROP CONSTRAINT IF EXISTS "settlement_batch_items_planned_release_minor_check";
ALTER TABLE "settlement_batch_items" ADD CONSTRAINT "settlement_batch_items_planned_release_minor_check" CHECK (planned_release_minor >= 0);

ALTER TABLE "settlement_batch_items" DROP CONSTRAINT IF EXISTS "settlement_batch_items_ledger_attempt_check";
ALTER TABLE "settlement_batch_items" ADD CONSTRAINT "settlement_batch_items_ledger_attempt_check" CHECK (ledger_attempt >= 1);

ALTER TABLE "settlement_batch_items" DROP CONSTRAINT IF EXISTS "settlement_batch_items_released_minor_check";
ALTER TABLE "settlement_batch_items" ADD CONSTRAINT "settlement_batch_items_released_minor_check" CHECK (released_minor >= 0);

ALTER TABLE "settlement_batch_items" DROP CONSTRAINT IF EXISTS "settlement_batch_items_netting_minor_check";
ALTER TABLE "settlement_batch_items" ADD CONSTRAINT "settlement_batch_items_netting_minor_check" CHECK (netting_minor >= 0);

ALTER TABLE "settlement_batch_items" DROP CONSTRAINT IF EXISTS "settlement_batch_items_netting_attempt_check";
ALTER TABLE "settlement_batch_items" ADD CONSTRAINT "settlement_batch_items_netting_attempt_check" CHECK (netting_attempt >= 1);

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_mode_check";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_amount_minor_check";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_amount_minor_check" CHECK (amount_minor >= 1);

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_rail_check";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_rail_check" CHECK (rail IN ('bank_transfer', 'acquirer_settlement'));

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_reason_check";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_reason_check" CHECK (reason IN ('weekly_cut', 'mandate_obligation', 'mandate_commission', 'manual'));

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_status_check";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_status_check" CHECK (status IN ('pending', 'in_transit', 'paid', 'failed'));

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_step_check";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_step_check" CHECK (step IN ('created', 'held', 'sent', 'resolved'));

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_terminal_consistency";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_terminal_consistency" CHECK ((status IN ('paid', 'failed')) = (step = 'resolved'));

ALTER TABLE "settlement_payouts" DROP CONSTRAINT IF EXISTS "settlement_payouts_failure_consistency";
ALTER TABLE "settlement_payouts" ADD CONSTRAINT "settlement_payouts_failure_consistency" CHECK ((status = 'failed') = (failure_code IS NOT NULL));

ALTER TABLE "settlement_charges" DROP CONSTRAINT IF EXISTS "settlement_charges_mode_check";
ALTER TABLE "settlement_charges" ADD CONSTRAINT "settlement_charges_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "settlement_charges" DROP CONSTRAINT IF EXISTS "settlement_charges_kind_check";
ALTER TABLE "settlement_charges" ADD CONSTRAINT "settlement_charges_kind_check" CHECK (kind IN ('monthly_fee', 'provider_commission', 'chargeback_debt'));

ALTER TABLE "settlement_charges" DROP CONSTRAINT IF EXISTS "settlement_charges_ledger_code_check";
ALTER TABLE "settlement_charges" ADD CONSTRAINT "settlement_charges_ledger_code_check" CHECK (ledger_code IN ('fee', 'refund'));

ALTER TABLE "settlement_charges" DROP CONSTRAINT IF EXISTS "settlement_charges_amount_minor_check";
ALTER TABLE "settlement_charges" ADD CONSTRAINT "settlement_charges_amount_minor_check" CHECK (amount_minor >= 1);

ALTER TABLE "settlement_charges" DROP CONSTRAINT IF EXISTS "settlement_charges_check";
ALTER TABLE "settlement_charges" ADD CONSTRAINT "settlement_charges_check" CHECK (collected_minor >= 0 AND collected_minor <= amount_minor);

ALTER TABLE "settlement_charges" DROP CONSTRAINT IF EXISTS "settlement_charges_status_check";
ALTER TABLE "settlement_charges" ADD CONSTRAINT "settlement_charges_status_check" CHECK (status IN ('open', 'collected'));

ALTER TABLE "settlement_charges" DROP CONSTRAINT IF EXISTS "settlement_charges_status_consistency";
ALTER TABLE "settlement_charges" ADD CONSTRAINT "settlement_charges_status_consistency" CHECK ((status = 'collected') = (collected_minor = amount_minor));

ALTER TABLE "settlement_charge_collections" DROP CONSTRAINT IF EXISTS "settlement_charge_collections_seq_check";
ALTER TABLE "settlement_charge_collections" ADD CONSTRAINT "settlement_charge_collections_seq_check" CHECK (seq >= 1);

ALTER TABLE "settlement_charge_collections" DROP CONSTRAINT IF EXISTS "settlement_charge_collections_amount_minor_check";
ALTER TABLE "settlement_charge_collections" ADD CONSTRAINT "settlement_charge_collections_amount_minor_check" CHECK (amount_minor >= 1);

ALTER TABLE "settlement_charge_collections" DROP CONSTRAINT IF EXISTS "settlement_charge_collections_status_check";
ALTER TABLE "settlement_charge_collections" ADD CONSTRAINT "settlement_charge_collections_status_check" CHECK (status IN ('planned', 'posted', 'rejected'));

ALTER TABLE "settlement_reconciliation_runs" DROP CONSTRAINT IF EXISTS "settlement_reconciliation_runs_mode_check";
ALTER TABLE "settlement_reconciliation_runs" ADD CONSTRAINT "settlement_reconciliation_runs_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "settlement_reconciliation_runs" DROP CONSTRAINT IF EXISTS "settlement_reconciliation_runs_source_check";
ALTER TABLE "settlement_reconciliation_runs" ADD CONSTRAINT "settlement_reconciliation_runs_source_check" CHECK (source IN ('api', 'csv', 'camt053'));

ALTER TABLE "settlement_reconciliation_runs" DROP CONSTRAINT IF EXISTS "settlement_reconciliation_runs_status_check";
ALTER TABLE "settlement_reconciliation_runs" ADD CONSTRAINT "settlement_reconciliation_runs_status_check" CHECK (status IN ('running', 'completed', 'failed'));

ALTER TABLE "settlement_statement_lines" DROP CONSTRAINT IF EXISTS "settlement_statement_lines_direction_check";
ALTER TABLE "settlement_statement_lines" ADD CONSTRAINT "settlement_statement_lines_direction_check" CHECK (direction IN ('credit', 'debit'));

ALTER TABLE "settlement_statement_lines" DROP CONSTRAINT IF EXISTS "settlement_statement_lines_amount_minor_check";
ALTER TABLE "settlement_statement_lines" ADD CONSTRAINT "settlement_statement_lines_amount_minor_check" CHECK (amount_minor >= 0);

ALTER TABLE "settlement_statement_lines" DROP CONSTRAINT IF EXISTS "settlement_statement_lines_outcome_check";
ALTER TABLE "settlement_statement_lines" ADD CONSTRAINT "settlement_statement_lines_outcome_check" CHECK (outcome IN ('matched', 'exception', 'ignored'));

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_mode_check";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_kind_check";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_kind_check" CHECK (kind IN ('missing_in_ledger', 'missing_in_statement', 'amount_mismatch', 'duplicate_in_statement', 'unknown_reference', 'payment_contradiction'));

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_statement_amount_minor_check";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_statement_amount_minor_check" CHECK (statement_amount_minor >= 0);

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_ledger_amount_minor_check";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_ledger_amount_minor_check" CHECK (ledger_amount_minor >= 0);

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_status_check";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_status_check" CHECK (status IN ('open', 'resolved', 'dismissed'));

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_resolution_check";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_resolution_check" CHECK (resolution IN ('request_adjustment', 'dismiss'));

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_resolution_note_check";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_resolution_note_check" CHECK (char_length(resolution_note) <= 500);

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_origin_shape";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_origin_shape" CHECK ((kind = 'payment_contradiction' AND run_id IS NULL AND connector IS NULL AND source_detail IS NOT NULL) OR (kind <> 'payment_contradiction' AND run_id IS NOT NULL AND connector IS NOT NULL AND mode IS NOT NULL AND source_detail IS NULL));

ALTER TABLE "settlement_exceptions" DROP CONSTRAINT IF EXISTS "settlement_exceptions_resolution_consistency";
ALTER TABLE "settlement_exceptions" ADD CONSTRAINT "settlement_exceptions_resolution_consistency" CHECK ((status = 'open') = (resolution IS NULL));

ALTER TABLE "settlement_adjustment_requests" DROP CONSTRAINT IF EXISTS "settlement_adjustment_requests_status_check";
ALTER TABLE "settlement_adjustment_requests" ADD CONSTRAINT "settlement_adjustment_requests_status_check" CHECK (status IN ('requested'));

ALTER TABLE "idempotency_keys" DROP CONSTRAINT IF EXISTS "idempotency_keys_state_check";
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_state_check" CHECK (state IN ('started', 'completed'));
