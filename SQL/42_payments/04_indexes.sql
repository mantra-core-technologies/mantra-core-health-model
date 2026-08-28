-- SALUD v4.0.10 · módulo 42 · schema payments
-- Generado de diagram_42_payments.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_payment_gateways_code" ON "payments"."payment_gateways" ("code");

CREATE INDEX IF NOT EXISTS "ix_payment_gateways_gateway_type_concept_id" ON "payments"."payment_gateways" ("gateway_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_gateways_external_provider_id" ON "payments"."payment_gateways" ("external_provider_id");

CREATE INDEX IF NOT EXISTS "ix_payment_gateways_state_concept_id" ON "payments"."payment_gateways" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_gateways_created_by_user_id" ON "payments"."payment_gateways" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_gateways_updated_by_user_id" ON "payments"."payment_gateways" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_gateway_id" ON "payments"."gateway_connections" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_tenant_id" ON "payments"."gateway_connections" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_practice_id" ON "payments"."gateway_connections" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_environment_concept_id" ON "payments"."gateway_connections" ("environment_concept_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_credential_id" ON "payments"."gateway_connections" ("credential_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_state_concept_id" ON "payments"."gateway_connections" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_created_by_user_id" ON "payments"."gateway_connections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_updated_by_user_id" ON "payments"."gateway_connections" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_connections_tenant_id_state_concept_id" ON "payments"."gateway_connections" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_payment_methods_tenant_id" ON "payments"."payment_methods" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_owner_type_concept_id" ON "payments"."payment_methods" ("owner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_gateway_id" ON "payments"."payment_methods" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_method_type_concept_id" ON "payments"."payment_methods" ("method_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_billing_address_id" ON "payments"."payment_methods" ("billing_address_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_status_concept_id" ON "payments"."payment_methods" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_created_by_user_id" ON "payments"."payment_methods" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_updated_by_user_id" ON "payments"."payment_methods" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_methods_tenant_id_status_concept_id" ON "payments"."payment_methods" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_payment_intents_idempotency_key" ON "payments"."payment_intents" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_tenant_id" ON "payments"."payment_intents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_practice_id" ON "payments"."payment_intents" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_gateway_id" ON "payments"."payment_intents" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_gateway_connection_id" ON "payments"."payment_intents" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_payment_method_id" ON "payments"."payment_intents" ("payment_method_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_purpose_concept_id" ON "payments"."payment_intents" ("purpose_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_invoice_id" ON "payments"."payment_intents" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_currency_concept_id" ON "payments"."payment_intents" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_status_concept_id" ON "payments"."payment_intents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_created_by_user_id" ON "payments"."payment_intents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_updated_by_user_id" ON "payments"."payment_intents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_intents_tenant_id_status_concept_id" ON "payments"."payment_intents" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_payment_transactions_gateway_transaction_ref" ON "payments"."payment_transactions" ("gateway_transaction_ref");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_payment_intent_id" ON "payments"."payment_transactions" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_payer_business_partner_id" ON "payments"."payment_transactions" ("payer_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_payee_business_partner_id" ON "payments"."payment_transactions" ("payee_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_contract_id" ON "payments"."payment_transactions" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_company_bank_account_id" ON "payments"."payment_transactions" ("company_bank_account_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_clearing_document_id" ON "payments"."payment_transactions" ("clearing_document_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_gateway_id" ON "payments"."payment_transactions" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_transaction_type_concept_id" ON "payments"."payment_transactions" ("transaction_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_currency_concept_id" ON "payments"."payment_transactions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_status_concept_id" ON "payments"."payment_transactions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_failure_reason_concept_id" ON "payments"."payment_transactions" ("failure_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_journal_transaction_id" ON "payments"."payment_transactions" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_created_by_user_id" ON "payments"."payment_transactions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_transactions_updated_by_user_id" ON "payments"."payment_transactions" ("updated_by_user_id");

-- OMITIDO "uq_payment_provider_transaction" (payment_gateway_id, provider_transaction_id) btree: columna(s) ['payment_gateway_id', 'provider_transaction_id'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "ix_refunds_payment_transaction_id" ON "payments"."refunds" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_refunds_currency_concept_id" ON "payments"."refunds" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_refunds_reason_concept_id" ON "payments"."refunds" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_refunds_status_concept_id" ON "payments"."refunds" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_refunds_journal_transaction_id" ON "payments"."refunds" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_refunds_created_by_user_id" ON "payments"."refunds" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_refunds_updated_by_user_id" ON "payments"."refunds" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_payment_transaction_id" ON "payments"."payment_disputes" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_dispute_type_concept_id" ON "payments"."payment_disputes" ("dispute_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_reason_concept_id" ON "payments"."payment_disputes" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_currency_concept_id" ON "payments"."payment_disputes" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_status_concept_id" ON "payments"."payment_disputes" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_evidence_file_id" ON "payments"."payment_disputes" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_created_by_user_id" ON "payments"."payment_disputes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_disputes_updated_by_user_id" ON "payments"."payment_disputes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_tenant_id" ON "payments"."payouts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_practice_id" ON "payments"."payouts" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_payee_type_concept_id" ON "payments"."payouts" ("payee_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_gateway_id" ON "payments"."payouts" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_currency_concept_id" ON "payments"."payouts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_status_concept_id" ON "payments"."payouts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_journal_transaction_id" ON "payments"."payouts" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_created_by_user_id" ON "payments"."payouts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_updated_by_user_id" ON "payments"."payouts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payouts_tenant_id_status_concept_id" ON "payments"."payouts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_payout_items_payout_id" ON "payments"."payout_items" ("payout_id");

CREATE INDEX IF NOT EXISTS "ix_payout_items_source_type_concept_id" ON "payments"."payout_items" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payout_items_created_by_user_id" ON "payments"."payout_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payout_items_updated_by_user_id" ON "payments"."payout_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_gateway_settlements_settlement_ref" ON "payments"."gateway_settlements" ("settlement_ref");

CREATE INDEX IF NOT EXISTS "ix_gateway_settlements_gateway_id" ON "payments"."gateway_settlements" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_settlements_currency_concept_id" ON "payments"."gateway_settlements" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_settlements_status_concept_id" ON "payments"."gateway_settlements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_settlements_journal_transaction_id" ON "payments"."gateway_settlements" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_settlements_created_by_user_id" ON "payments"."gateway_settlements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_settlements_updated_by_user_id" ON "payments"."gateway_settlements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_settlement_lines_settlement_id" ON "payments"."settlement_lines" ("settlement_id");

CREATE INDEX IF NOT EXISTS "ix_settlement_lines_payment_transaction_id" ON "payments"."settlement_lines" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_settlement_lines_refund_id" ON "payments"."settlement_lines" ("refund_id");

CREATE INDEX IF NOT EXISTS "ix_settlement_lines_created_by_user_id" ON "payments"."settlement_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_settlement_lines_updated_by_user_id" ON "payments"."settlement_lines" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_payment_webhook_events_gateway_event_ref" ON "payments"."payment_webhook_events" ("gateway_event_ref");

CREATE INDEX IF NOT EXISTS "ix_payment_webhook_events_gateway_id" ON "payments"."payment_webhook_events" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_payment_webhook_events_gateway_connection_id" ON "payments"."payment_webhook_events" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_payment_webhook_events_related_intent_id" ON "payments"."payment_webhook_events" ("related_intent_id");

CREATE INDEX IF NOT EXISTS "ix_payment_webhook_events_recorded_by_user_id" ON "payments"."payment_webhook_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_payment_webhook_events_recorded_at" ON "payments"."payment_webhook_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_wallets_tenant_id" ON "payments"."wallets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_owner_type_concept_id" ON "payments"."wallets" ("owner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_wallet_type_concept_id" ON "payments"."wallets" ("wallet_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_currency_concept_id" ON "payments"."wallets" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_ledger_account_id" ON "payments"."wallets" ("ledger_account_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_status_concept_id" ON "payments"."wallets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_created_by_user_id" ON "payments"."wallets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_updated_by_user_id" ON "payments"."wallets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_wallets_tenant_id_status_concept_id" ON "payments"."wallets" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_wallet_ledger_entries_idempotency_key" ON "payments"."wallet_ledger_entries" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_wallet_ledger_entries_wallet_id" ON "payments"."wallet_ledger_entries" ("wallet_id");

CREATE INDEX IF NOT EXISTS "ix_wallet_ledger_entries_direction_concept_id" ON "payments"."wallet_ledger_entries" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallet_ledger_entries_currency_concept_id" ON "payments"."wallet_ledger_entries" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallet_ledger_entries_entry_type_concept_id" ON "payments"."wallet_ledger_entries" ("entry_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wallet_ledger_entries_payment_transaction_id" ON "payments"."wallet_ledger_entries" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_wallet_ledger_entries_journal_transaction_id" ON "payments"."wallet_ledger_entries" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_wallet_ledger_entries_recorded_by_user_id" ON "payments"."wallet_ledger_entries" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_wallet_ledger_entries_recorded_at" ON "payments"."wallet_ledger_entries" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_tenant_id" ON "payments"."connected_accounts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_gateway_id" ON "payments"."connected_accounts" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_business_partner_id" ON "payments"."connected_accounts" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_company_bank_account_id" ON "payments"."connected_accounts" ("company_bank_account_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_payee_type_concept_id" ON "payments"."connected_accounts" ("payee_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_onboarding_status_concept_id" ON "payments"."connected_accounts" ("onboarding_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_default_wallet_id" ON "payments"."connected_accounts" ("default_wallet_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_payout_schedule_concept_id" ON "payments"."connected_accounts" ("payout_schedule_concept_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_status_concept_id" ON "payments"."connected_accounts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_created_by_user_id" ON "payments"."connected_accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_updated_by_user_id" ON "payments"."connected_accounts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_connected_accounts_tenant_id_status_concept_id" ON "payments"."connected_accounts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_kyc_verifications_connected_account_id" ON "payments"."kyc_verifications" ("connected_account_id");

CREATE INDEX IF NOT EXISTS "ix_kyc_verifications_kyc_level_concept_id" ON "payments"."kyc_verifications" ("kyc_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_kyc_verifications_status_concept_id" ON "payments"."kyc_verifications" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_kyc_verifications_risk_rating_concept_id" ON "payments"."kyc_verifications" ("risk_rating_concept_id");

CREATE INDEX IF NOT EXISTS "ix_kyc_verifications_evidence_file_id" ON "payments"."kyc_verifications" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_kyc_verifications_created_by_user_id" ON "payments"."kyc_verifications" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_kyc_verifications_updated_by_user_id" ON "payments"."kyc_verifications" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_payment_intent_id" ON "payments"."payment_splits" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_payee_connected_account_id" ON "payments"."payment_splits" ("payee_connected_account_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_split_type_concept_id" ON "payments"."payment_splits" ("split_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_currency_concept_id" ON "payments"."payment_splits" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_destination_wallet_id" ON "payments"."payment_splits" ("destination_wallet_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_status_concept_id" ON "payments"."payment_splits" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_created_by_user_id" ON "payments"."payment_splits" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_splits_updated_by_user_id" ON "payments"."payment_splits" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_fee_schedules_code" ON "payments"."fee_schedules" ("code");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_tenant_id" ON "payments"."fee_schedules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_fee_type_concept_id" ON "payments"."fee_schedules" ("fee_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_calculation_method_concept_id" ON "payments"."fee_schedules" ("calculation_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_currency_concept_id" ON "payments"."fee_schedules" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_applies_to_concept_id" ON "payments"."fee_schedules" ("applies_to_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_state_concept_id" ON "payments"."fee_schedules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_created_by_user_id" ON "payments"."fee_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_updated_by_user_id" ON "payments"."fee_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fee_schedules_tenant_id_state_concept_id" ON "payments"."fee_schedules" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_fee_schedules_effective_period" ON "payments"."fee_schedules" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_transaction_fees_payment_transaction_id" ON "payments"."transaction_fees" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_fees_fee_schedule_id" ON "payments"."transaction_fees" ("fee_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_fees_fee_type_concept_id" ON "payments"."transaction_fees" ("fee_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_fees_currency_concept_id" ON "payments"."transaction_fees" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_fees_bearer_type_concept_id" ON "payments"."transaction_fees" ("bearer_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_fees_created_by_user_id" ON "payments"."transaction_fees" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_fees_updated_by_user_id" ON "payments"."transaction_fees" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tips_payment_intent_id" ON "payments"."tips" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_tips_beneficiary_type_concept_id" ON "payments"."tips" ("beneficiary_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tips_currency_concept_id" ON "payments"."tips" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tips_destination_wallet_id" ON "payments"."tips" ("destination_wallet_id");

CREATE INDEX IF NOT EXISTS "ix_tips_status_concept_id" ON "payments"."tips" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tips_created_by_user_id" ON "payments"."tips" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tips_updated_by_user_id" ON "payments"."tips" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_subscription_plans_code" ON "payments"."subscription_plans" ("code");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_tenant_id" ON "payments"."subscription_plans" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_practice_id" ON "payments"."subscription_plans" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_billing_interval_concept_id" ON "payments"."subscription_plans" ("billing_interval_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_currency_concept_id" ON "payments"."subscription_plans" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_usage_type_concept_id" ON "payments"."subscription_plans" ("usage_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_state_concept_id" ON "payments"."subscription_plans" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_created_by_user_id" ON "payments"."subscription_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_updated_by_user_id" ON "payments"."subscription_plans" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_plans_tenant_id_state_concept_id" ON "payments"."subscription_plans" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_subscriptions_tenant_id" ON "payments"."subscriptions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_plan_id" ON "payments"."subscriptions" ("plan_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_subscriber_type_concept_id" ON "payments"."subscriptions" ("subscriber_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_payment_method_id" ON "payments"."subscriptions" ("payment_method_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_status_concept_id" ON "payments"."subscriptions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_mandate_id" ON "payments"."subscriptions" ("mandate_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_created_by_user_id" ON "payments"."subscriptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_updated_by_user_id" ON "payments"."subscriptions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subscriptions_tenant_id_status_concept_id" ON "payments"."subscriptions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_installment_plans_payment_intent_id" ON "payments"."installment_plans" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_installment_plans_currency_concept_id" ON "payments"."installment_plans" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_installment_plans_status_concept_id" ON "payments"."installment_plans" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_installment_plans_created_by_user_id" ON "payments"."installment_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_installment_plans_updated_by_user_id" ON "payments"."installment_plans" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_installment_schedules_installment_plan_id" ON "payments"."installment_schedules" ("installment_plan_id");

CREATE INDEX IF NOT EXISTS "ix_installment_schedules_payment_transaction_id" ON "payments"."installment_schedules" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_installment_schedules_status_concept_id" ON "payments"."installment_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_installment_schedules_created_by_user_id" ON "payments"."installment_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_installment_schedules_updated_by_user_id" ON "payments"."installment_schedules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_payment_mandates_mandate_ref" ON "payments"."payment_mandates" ("mandate_ref");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_tenant_id" ON "payments"."payment_mandates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_payer_type_concept_id" ON "payments"."payment_mandates" ("payer_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_mandate_type_concept_id" ON "payments"."payment_mandates" ("mandate_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_payment_method_id" ON "payments"."payment_mandates" ("payment_method_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_scheme_concept_id" ON "payments"."payment_mandates" ("scheme_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_status_concept_id" ON "payments"."payment_mandates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_created_by_user_id" ON "payments"."payment_mandates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_updated_by_user_id" ON "payments"."payment_mandates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_mandates_tenant_id_status_concept_id" ON "payments"."payment_mandates" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_fx_rate_locks_payment_intent_id" ON "payments"."fx_rate_locks" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_fx_rate_locks_from_currency_concept_id" ON "payments"."fx_rate_locks" ("from_currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fx_rate_locks_to_currency_concept_id" ON "payments"."fx_rate_locks" ("to_currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fx_rate_locks_status_concept_id" ON "payments"."fx_rate_locks" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fx_rate_locks_created_by_user_id" ON "payments"."fx_rate_locks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fx_rate_locks_updated_by_user_id" ON "payments"."fx_rate_locks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_risk_assessments_payment_intent_id" ON "payments"."risk_assessments" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_risk_assessments_risk_level_concept_id" ON "payments"."risk_assessments" ("risk_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_risk_assessments_decision_concept_id" ON "payments"."risk_assessments" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_risk_assessments_three_ds_status_concept_id" ON "payments"."risk_assessments" ("three_ds_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_risk_assessments_reviewed_by_user_id" ON "payments"."risk_assessments" ("reviewed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_risk_assessments_created_by_user_id" ON "payments"."risk_assessments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_risk_assessments_updated_by_user_id" ON "payments"."risk_assessments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_runs_tenant_id" ON "payments"."reconciliation_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_runs_gateway_id" ON "payments"."reconciliation_runs" ("gateway_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_runs_status_concept_id" ON "payments"."reconciliation_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_runs_created_by_user_id" ON "payments"."reconciliation_runs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_runs_updated_by_user_id" ON "payments"."reconciliation_runs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_runs_tenant_id_status_concept_id" ON "payments"."reconciliation_runs" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_reconciliation_run_id" ON "payments"."reconciliation_exceptions" ("reconciliation_run_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_exception_type_concept_id" ON "payments"."reconciliation_exceptions" ("exception_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_payment_transaction_id" ON "payments"."reconciliation_exceptions" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_wallet_ledger_entry_id" ON "payments"."reconciliation_exceptions" ("wallet_ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_status_concept_id" ON "payments"."reconciliation_exceptions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_resolved_by_user_id" ON "payments"."reconciliation_exceptions" ("resolved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_created_by_user_id" ON "payments"."reconciliation_exceptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reconciliation_exceptions_updated_by_user_id" ON "payments"."reconciliation_exceptions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_channel_catalog_channel_type_concept_id" ON "payments"."payment_channel_catalog" ("channel_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_channel_catalog_state_concept_id" ON "payments"."payment_channel_catalog" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_channel_catalog_created_by_user_id" ON "payments"."payment_channel_catalog" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_channel_catalog_updated_by_user_id" ON "payments"."payment_channel_catalog" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_payment_channel_mappings_gateway_connection_id" ON "payments"."gateway_payment_channel_mappings" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_payment_channel_mappings_payment_channel_catalog_id" ON "payments"."gateway_payment_channel_mappings" ("payment_channel_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_payment_channel_mappings_state_concept_id" ON "payments"."gateway_payment_channel_mappings" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_payment_channel_mappings_created_by_user_id" ON "payments"."gateway_payment_channel_mappings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_gateway_payment_channel_mappings_updated_by_user_id" ON "payments"."gateway_payment_channel_mappings" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_gateway_channel_mapping" ON "payments"."gateway_payment_channel_mappings" ("gateway_connection_id", "payment_channel_catalog_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_gateway_external_channel" ON "payments"."gateway_payment_channel_mappings" ("gateway_connection_id", "external_channel_code");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_tenant_id" ON "payments"."payment_debts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_gateway_connection_id" ON "payments"."payment_debts" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_debtor_business_partner_id" ON "payments"."payment_debts" ("debtor_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_patient_profile_id" ON "payments"."payment_debts" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_contract_id" ON "payments"."payment_debts" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_invoice_id" ON "payments"."payment_debts" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_external_debt_id" ON "payments"."payment_debts" ("external_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_status_concept_id" ON "payments"."payment_debts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_created_by_user_id" ON "payments"."payment_debts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_updated_by_user_id" ON "payments"."payment_debts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_tenant_status" ON "payments"."payment_debts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_debts_tenant_number" ON "payments"."payment_debts" ("tenant_id", "internal_debt_number");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_debts_gateway_external" ON "payments"."payment_debts" ("gateway_connection_id", "external_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debts_partner_status_due" ON "payments"."payment_debts" ("debtor_business_partner_id", "status_concept_id", "due_at");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_lines_payment_debt_id" ON "payments"."payment_debt_lines" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_lines_billable_item_type_concept_id" ON "payments"."payment_debt_lines" ("billable_item_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_lines_billable_item_id" ON "payments"."payment_debt_lines" ("billable_item_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_lines_accounting_account_id" ON "payments"."payment_debt_lines" ("accounting_account_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_lines_created_by_user_id" ON "payments"."payment_debt_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_lines_updated_by_user_id" ON "payments"."payment_debt_lines" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_debt_lines_debt_line" ON "payments"."payment_debt_lines" ("payment_debt_id", "line_number");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_invoice_requests_payment_debt_id" ON "payments"."payment_debt_invoice_requests" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_invoice_requests_requested_by_user_id" ON "payments"."payment_debt_invoice_requests" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_invoice_requests_status_concept_id" ON "payments"."payment_debt_invoice_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_debt_invoice_requests_external_invoice_request_id" ON "payments"."payment_debt_invoice_requests" ("external_invoice_request_id");

CREATE INDEX IF NOT EXISTS "brin_payment_debt_invoice_requests_created_at" ON "payments"."payment_debt_invoice_requests" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_debt_invoice_requests_debt_number" ON "payments"."payment_debt_invoice_requests" ("payment_debt_id", "request_number");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_tenant_id" ON "payments"."payment_checkout_sessions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_gateway_connection_id" ON "payments"."payment_checkout_sessions" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_payment_debt_id" ON "payments"."payment_checkout_sessions" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_payment_intent_id" ON "payments"."payment_checkout_sessions" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_external_transaction_id" ON "payments"."payment_checkout_sessions" ("external_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_callback_endpoint_id" ON "payments"."payment_checkout_sessions" ("callback_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_status_concept_id" ON "payments"."payment_checkout_sessions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_created_by_user_id" ON "payments"."payment_checkout_sessions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_updated_by_user_id" ON "payments"."payment_checkout_sessions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_checkout_sessions_tenant_status" ON "payments"."payment_checkout_sessions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_checkout_sessions_token" ON "payments"."payment_checkout_sessions" ("session_token_hash");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_checkout_external_transaction" ON "payments"."payment_checkout_sessions" ("gateway_connection_id", "external_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_operations_gateway_connection_id" ON "payments"."provider_api_operations" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_operations_state_concept_id" ON "payments"."provider_api_operations" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_operations_created_by_user_id" ON "payments"."provider_api_operations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_operations_updated_by_user_id" ON "payments"."provider_api_operations" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_provider_api_operations_connection_code" ON "payments"."provider_api_operations" ("gateway_connection_id", "operation_code");

CREATE INDEX IF NOT EXISTS "ix_provider_api_attempts_provider_api_operation_id" ON "payments"."provider_api_attempts" ("provider_api_operation_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_attempts_payment_debt_id" ON "payments"."provider_api_attempts" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_attempts_payment_checkout_session_id" ON "payments"."provider_api_attempts" ("payment_checkout_session_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_attempts_payment_transaction_id" ON "payments"."provider_api_attempts" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_attempts_correlation_id" ON "payments"."provider_api_attempts" ("correlation_id");

CREATE INDEX IF NOT EXISTS "ix_provider_api_attempts_result_concept_id" ON "payments"."provider_api_attempts" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "brin_provider_api_attempts_created_at" ON "payments"."provider_api_attempts" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_provider_api_attempts_operation_correlation_attempt" ON "payments"."provider_api_attempts" ("provider_api_operation_id", "correlation_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_endpoints_gateway_connection_id" ON "payments"."provider_callback_endpoints" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_endpoints_verification_method_concept_id" ON "payments"."provider_callback_endpoints" ("verification_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_endpoints_verification_secret_id" ON "payments"."provider_callback_endpoints" ("verification_secret_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_endpoints_state_concept_id" ON "payments"."provider_callback_endpoints" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_endpoints_created_by_user_id" ON "payments"."provider_callback_endpoints" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_endpoints_updated_by_user_id" ON "payments"."provider_callback_endpoints" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_provider_callback_endpoints_connection_code" ON "payments"."provider_callback_endpoints" ("gateway_connection_id", "code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_provider_callback_endpoints_path" ON "payments"."provider_callback_endpoints" ("callback_path");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_provider_callback_endpoint_id" ON "payments"."provider_callback_events" ("provider_callback_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_payment_checkout_session_id" ON "payments"."provider_callback_events" ("payment_checkout_session_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_payment_transaction_id" ON "payments"."provider_callback_events" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_external_event_id" ON "payments"."provider_callback_events" ("external_event_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_external_transaction_id" ON "payments"."provider_callback_events" ("external_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_verification_status_concept_id" ON "payments"."provider_callback_events" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_processing_status_concept_id" ON "payments"."provider_callback_events" ("processing_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_events_duplicate_of_event_id" ON "payments"."provider_callback_events" ("duplicate_of_event_id");

CREATE INDEX IF NOT EXISTS "brin_provider_callback_events_created_at" ON "payments"."provider_callback_events" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_provider_callback_external_event" ON "payments"."provider_callback_events" ("provider_callback_endpoint_id", "external_event_id");

CREATE INDEX IF NOT EXISTS "ix_provider_callback_external_transaction" ON "payments"."provider_callback_events" ("provider_callback_endpoint_id", "external_transaction_id", "received_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_callback_verification_runs_provider_callback_event_id" ON "payments"."callback_verification_runs" ("provider_callback_event_id");

CREATE INDEX IF NOT EXISTS "ix_callback_verification_runs_verification_method_concept_id" ON "payments"."callback_verification_runs" ("verification_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_callback_verification_runs_result_concept_id" ON "payments"."callback_verification_runs" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "brin_callback_verification_runs_created_at" ON "payments"."callback_verification_runs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_payment_status_inquiries_gateway_connection_id" ON "payments"."payment_status_inquiries" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_payment_status_inquiries_payment_debt_id" ON "payments"."payment_status_inquiries" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_status_inquiries_payment_checkout_session_id" ON "payments"."payment_status_inquiries" ("payment_checkout_session_id");

CREATE INDEX IF NOT EXISTS "ix_payment_status_inquiries_payment_transaction_id" ON "payments"."payment_status_inquiries" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_status_inquiries_external_transaction_id" ON "payments"."payment_status_inquiries" ("external_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_status_inquiries_inquiry_reason_concept_id" ON "payments"."payment_status_inquiries" ("inquiry_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_status_inquiries_result_status_concept_id" ON "payments"."payment_status_inquiries" ("result_status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_payment_status_inquiries_created_at" ON "payments"."payment_status_inquiries" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_cashier_payment_contexts_tenant_id" ON "payments"."cashier_payment_contexts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cashier_payment_contexts_payment_checkout_session_id" ON "payments"."cashier_payment_contexts" ("payment_checkout_session_id");

CREATE INDEX IF NOT EXISTS "ix_cashier_payment_contexts_cashier_user_id" ON "payments"."cashier_payment_contexts" ("cashier_user_id");

CREATE INDEX IF NOT EXISTS "ix_cashier_payment_contexts_cash_register_id" ON "payments"."cashier_payment_contexts" ("cash_register_id");

CREATE INDEX IF NOT EXISTS "ix_cashier_payment_contexts_site_id" ON "payments"."cashier_payment_contexts" ("site_id");

CREATE INDEX IF NOT EXISTS "ix_cashier_payment_contexts_tenant_created" ON "payments"."cashier_payment_contexts" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_cashier_payment_contexts_session" ON "payments"."cashier_payment_contexts" ("payment_checkout_session_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_tenant_id" ON "payments"."payment_cancellation_requests" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_gateway_connection_id" ON "payments"."payment_cancellation_requests" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_payment_debt_id" ON "payments"."payment_cancellation_requests" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_payment_checkout_session_id" ON "payments"."payment_cancellation_requests" ("payment_checkout_session_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_payment_transaction_id" ON "payments"."payment_cancellation_requests" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_reason_concept_id" ON "payments"."payment_cancellation_requests" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_requested_by_user_id" ON "payments"."payment_cancellation_requests" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_status_concept_id" ON "payments"."payment_cancellation_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_external_cancellation_id" ON "payments"."payment_cancellation_requests" ("external_cancellation_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_created_by_user_id" ON "payments"."payment_cancellation_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_updated_by_user_id" ON "payments"."payment_cancellation_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_cancellation_requests_tenant_status" ON "payments"."payment_cancellation_requests" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_cancellation_requests_tenant_number" ON "payments"."payment_cancellation_requests" ("tenant_id", "request_number");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_tenant_id" ON "payments"."invoice_regeneration_requests" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_gateway_connection_id" ON "payments"."invoice_regeneration_requests" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_payment_transaction_id" ON "payments"."invoice_regeneration_requests" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_payment_debt_id" ON "payments"."invoice_regeneration_requests" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_requested_by_user_id" ON "payments"."invoice_regeneration_requests" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_status_concept_id" ON "payments"."invoice_regeneration_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_external_request_id" ON "payments"."invoice_regeneration_requests" ("external_request_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_created_by_user_id" ON "payments"."invoice_regeneration_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_updated_by_user_id" ON "payments"."invoice_regeneration_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_regeneration_requests_tenant_status" ON "payments"."invoice_regeneration_requests" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_invoice_regeneration_tenant_number" ON "payments"."invoice_regeneration_requests" ("tenant_id", "request_number");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_gateway_connection_id" ON "payments"."provider_invoice_artifacts" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_payment_transaction_id" ON "payments"."provider_invoice_artifacts" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_invoice_regeneration_request_id" ON "payments"."provider_invoice_artifacts" ("invoice_regeneration_request_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_artifact_type_concept_id" ON "payments"."provider_invoice_artifacts" ("artifact_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_external_invoice_id" ON "payments"."provider_invoice_artifacts" ("external_invoice_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_file_id" ON "payments"."provider_invoice_artifacts" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_status_concept_id" ON "payments"."provider_invoice_artifacts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_created_by_user_id" ON "payments"."provider_invoice_artifacts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_invoice_artifacts_updated_by_user_id" ON "payments"."provider_invoice_artifacts" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_provider_invoice_artifacts_external" ON "payments"."provider_invoice_artifacts" ("gateway_connection_id", "external_invoice_id", "artifact_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_tenant_id" ON "payments"."payment_receipts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_payment_transaction_id" ON "payments"."payment_receipts" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_payment_debt_id" ON "payments"."payment_receipts" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_payer_business_partner_id" ON "payments"."payment_receipts" ("payer_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_file_id" ON "payments"."payment_receipts" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_created_by_user_id" ON "payments"."payment_receipts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_updated_by_user_id" ON "payments"."payment_receipts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payment_receipts_tenant_created" ON "payments"."payment_receipts" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_receipts_tenant_number" ON "payments"."payment_receipts" ("tenant_id", "receipt_number");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_payment_receipts_transaction" ON "payments"."payment_receipts" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_reconciliation_records_gateway_connection_id" ON "payments"."provider_reconciliation_records" ("gateway_connection_id");

CREATE INDEX IF NOT EXISTS "ix_provider_reconciliation_records_reconciliation_run_id" ON "payments"."provider_reconciliation_records" ("reconciliation_run_id");

CREATE INDEX IF NOT EXISTS "ix_provider_reconciliation_records_payment_debt_id" ON "payments"."provider_reconciliation_records" ("payment_debt_id");

CREATE INDEX IF NOT EXISTS "ix_provider_reconciliation_records_payment_transaction_id" ON "payments"."provider_reconciliation_records" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_reconciliation_records_external_transaction_id" ON "payments"."provider_reconciliation_records" ("external_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_provider_reconciliation_records_match_status_concept_id" ON "payments"."provider_reconciliation_records" ("match_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_reconciliation_records_mismatch_reason_concept_id" ON "payments"."provider_reconciliation_records" ("mismatch_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_provider_reconciliation_records_recorded_at" ON "payments"."provider_reconciliation_records" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_provider_reconciliation_connection_external_run" ON "payments"."provider_reconciliation_records" ("gateway_connection_id", "external_transaction_id", "reconciliation_run_id");

CREATE INDEX IF NOT EXISTS "ix_plan_prices_plan_id" ON "payments"."plan_prices" ("plan_id");

CREATE INDEX IF NOT EXISTS "ix_plan_prices_currency_concept_id" ON "payments"."plan_prices" ("currency_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_plan_prices_plan_currency_interval" ON "payments"."plan_prices" ("plan_id", "currency_concept_id", "billing_interval_concept_id", "region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_plan_features_plan_id" ON "payments"."plan_features" ("plan_id");

CREATE INDEX IF NOT EXISTS "ix_plan_features_feature_concept_id" ON "payments"."plan_features" ("feature_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_plan_features_plan_feature" ON "payments"."plan_features" ("plan_id", "feature_concept_id");

CREATE INDEX IF NOT EXISTS "ix_plan_quotas_plan_id" ON "payments"."plan_quotas" ("plan_id");

CREATE INDEX IF NOT EXISTS "ix_plan_quotas_metric_concept_id" ON "payments"."plan_quotas" ("metric_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_plan_quotas_plan_metric" ON "payments"."plan_quotas" ("plan_id", "metric_concept_id");

CREATE INDEX IF NOT EXISTS "ix_plan_eligibility_rules_plan_id" ON "payments"."plan_eligibility_rules" ("plan_id");

CREATE INDEX IF NOT EXISTS "ix_plan_eligibility_rules_practice_type" ON "payments"."plan_eligibility_rules" ("eligible_practice_type_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_plan_eligibility_rules_plan_type" ON "payments"."plan_eligibility_rules" ("plan_id", "eligible_practice_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_usage_counters_subscription_id" ON "payments"."subscription_usage_counters" ("subscription_id");

CREATE INDEX IF NOT EXISTS "ix_subscription_usage_counters_metric_concept_id" ON "payments"."subscription_usage_counters" ("metric_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_subscription_usage_counters_period" ON "payments"."subscription_usage_counters" ("subscription_id", "metric_concept_id", "period_start");
