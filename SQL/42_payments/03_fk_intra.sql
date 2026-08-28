-- SALUD v4.0.10 · módulo 42 · schema payments
-- Generado de diagram_42_payments.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_payment_method_id" FOREIGN KEY ("payment_method_id")
        REFERENCES "payments"."payment_methods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."refunds"
        ADD CONSTRAINT "fk_refunds_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payout_items"
        ADD CONSTRAINT "fk_payout_items_payout_id" FOREIGN KEY ("payout_id")
        REFERENCES "payments"."payouts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."gateway_settlements"
        ADD CONSTRAINT "fk_gateway_settlements_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."settlement_lines"
        ADD CONSTRAINT "fk_settlement_lines_settlement_id" FOREIGN KEY ("settlement_id")
        REFERENCES "payments"."gateway_settlements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."settlement_lines"
        ADD CONSTRAINT "fk_settlement_lines_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."settlement_lines"
        ADD CONSTRAINT "fk_settlement_lines_refund_id" FOREIGN KEY ("refund_id")
        REFERENCES "payments"."refunds" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_webhook_events"
        ADD CONSTRAINT "fk_payment_webhook_events_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_webhook_events"
        ADD CONSTRAINT "fk_payment_webhook_events_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_webhook_events"
        ADD CONSTRAINT "fk_payment_webhook_events_related_intent_id" FOREIGN KEY ("related_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."wallet_ledger_entries"
        ADD CONSTRAINT "fk_wallet_ledger_entries_wallet_id" FOREIGN KEY ("wallet_id")
        REFERENCES "payments"."wallets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."wallet_ledger_entries"
        ADD CONSTRAINT "fk_wallet_ledger_entries_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_default_wallet_id" FOREIGN KEY ("default_wallet_id")
        REFERENCES "payments"."wallets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."kyc_verifications"
        ADD CONSTRAINT "fk_kyc_verifications_connected_account_id" FOREIGN KEY ("connected_account_id")
        REFERENCES "payments"."connected_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_payee_connected_account_id" FOREIGN KEY ("payee_connected_account_id")
        REFERENCES "payments"."connected_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_destination_wallet_id" FOREIGN KEY ("destination_wallet_id")
        REFERENCES "payments"."wallets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."transaction_fees"
        ADD CONSTRAINT "fk_transaction_fees_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."transaction_fees"
        ADD CONSTRAINT "fk_transaction_fees_fee_schedule_id" FOREIGN KEY ("fee_schedule_id")
        REFERENCES "payments"."fee_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."tips"
        ADD CONSTRAINT "fk_tips_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."tips"
        ADD CONSTRAINT "fk_tips_destination_wallet_id" FOREIGN KEY ("destination_wallet_id")
        REFERENCES "payments"."wallets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_plan_id" FOREIGN KEY ("plan_id")
        REFERENCES "payments"."subscription_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_payment_method_id" FOREIGN KEY ("payment_method_id")
        REFERENCES "payments"."payment_methods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_mandate_id" FOREIGN KEY ("mandate_id")
        REFERENCES "payments"."payment_mandates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."installment_plans"
        ADD CONSTRAINT "fk_installment_plans_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."installment_schedules"
        ADD CONSTRAINT "fk_installment_schedules_installment_plan_id" FOREIGN KEY ("installment_plan_id")
        REFERENCES "payments"."installment_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."installment_schedules"
        ADD CONSTRAINT "fk_installment_schedules_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_payment_method_id" FOREIGN KEY ("payment_method_id")
        REFERENCES "payments"."payment_methods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."fx_rate_locks"
        ADD CONSTRAINT "fk_fx_rate_locks_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_runs"
        ADD CONSTRAINT "fk_reconciliation_runs_gateway_id" FOREIGN KEY ("gateway_id")
        REFERENCES "payments"."payment_gateways" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_reconciliation_run_id" FOREIGN KEY ("reconciliation_run_id")
        REFERENCES "payments"."reconciliation_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_wallet_ledger_entry_id" FOREIGN KEY ("wallet_ledger_entry_id")
        REFERENCES "payments"."wallet_ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."gateway_payment_channel_mappings"
        ADD CONSTRAINT "fk_gateway_payment_channel_mappings_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."gateway_payment_channel_mappings"
        ADD CONSTRAINT "fk_gateway_payment_channel_mappings_payment_channel_catalog_id" FOREIGN KEY ("payment_channel_catalog_id")
        REFERENCES "payments"."payment_channel_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_lines"
        ADD CONSTRAINT "fk_payment_debt_lines_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_invoice_requests"
        ADD CONSTRAINT "fk_payment_debt_invoice_requests_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_callback_endpoint_id" FOREIGN KEY ("callback_endpoint_id")
        REFERENCES "payments"."provider_callback_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_operations"
        ADD CONSTRAINT "fk_provider_api_operations_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_attempts"
        ADD CONSTRAINT "fk_provider_api_attempts_provider_api_operation_id" FOREIGN KEY ("provider_api_operation_id")
        REFERENCES "payments"."provider_api_operations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_attempts"
        ADD CONSTRAINT "fk_provider_api_attempts_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_attempts"
        ADD CONSTRAINT "fk_provider_api_attempts_payment_checkout_session_id" FOREIGN KEY ("payment_checkout_session_id")
        REFERENCES "payments"."payment_checkout_sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_attempts"
        ADD CONSTRAINT "fk_provider_api_attempts_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_endpoints"
        ADD CONSTRAINT "fk_provider_callback_endpoints_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_events"
        ADD CONSTRAINT "fk_provider_callback_events_provider_callback_endpoint_id" FOREIGN KEY ("provider_callback_endpoint_id")
        REFERENCES "payments"."provider_callback_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_events"
        ADD CONSTRAINT "fk_provider_callback_events_payment_checkout_session_id" FOREIGN KEY ("payment_checkout_session_id")
        REFERENCES "payments"."payment_checkout_sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_events"
        ADD CONSTRAINT "fk_provider_callback_events_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_events"
        ADD CONSTRAINT "fk_provider_callback_events_duplicate_of_event_id" FOREIGN KEY ("duplicate_of_event_id")
        REFERENCES "payments"."provider_callback_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."callback_verification_runs"
        ADD CONSTRAINT "fk_callback_verification_runs_provider_callback_event_id" FOREIGN KEY ("provider_callback_event_id")
        REFERENCES "payments"."provider_callback_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_status_inquiries"
        ADD CONSTRAINT "fk_payment_status_inquiries_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_status_inquiries"
        ADD CONSTRAINT "fk_payment_status_inquiries_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_status_inquiries"
        ADD CONSTRAINT "fk_payment_status_inquiries_payment_checkout_session_id" FOREIGN KEY ("payment_checkout_session_id")
        REFERENCES "payments"."payment_checkout_sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_status_inquiries"
        ADD CONSTRAINT "fk_payment_status_inquiries_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."cashier_payment_contexts"
        ADD CONSTRAINT "fk_cashier_payment_contexts_payment_checkout_session_id" FOREIGN KEY ("payment_checkout_session_id")
        REFERENCES "payments"."payment_checkout_sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_payment_checkout_session_id" FOREIGN KEY ("payment_checkout_session_id")
        REFERENCES "payments"."payment_checkout_sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_invoice_regeneration_request_id" FOREIGN KEY ("invoice_regeneration_request_id")
        REFERENCES "payments"."invoice_regeneration_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_receipts"
        ADD CONSTRAINT "fk_payment_receipts_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."payment_receipts"
        ADD CONSTRAINT "fk_payment_receipts_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_reconciliation_records"
        ADD CONSTRAINT "fk_provider_reconciliation_records_gateway_connection_id" FOREIGN KEY ("gateway_connection_id")
        REFERENCES "payments"."gateway_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_reconciliation_records"
        ADD CONSTRAINT "fk_provider_reconciliation_records_reconciliation_run_id" FOREIGN KEY ("reconciliation_run_id")
        REFERENCES "payments"."reconciliation_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_reconciliation_records"
        ADD CONSTRAINT "fk_provider_reconciliation_records_payment_debt_id" FOREIGN KEY ("payment_debt_id")
        REFERENCES "payments"."payment_debts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."provider_reconciliation_records"
        ADD CONSTRAINT "fk_provider_reconciliation_records_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."plan_prices"
        ADD CONSTRAINT "fk_plan_prices_plan_id" FOREIGN KEY ("plan_id")
        REFERENCES "payments"."subscription_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."plan_features"
        ADD CONSTRAINT "fk_plan_features_plan_id" FOREIGN KEY ("plan_id")
        REFERENCES "payments"."subscription_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."plan_quotas"
        ADD CONSTRAINT "fk_plan_quotas_plan_id" FOREIGN KEY ("plan_id")
        REFERENCES "payments"."subscription_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."plan_eligibility_rules"
        ADD CONSTRAINT "fk_plan_eligibility_rules_plan_id" FOREIGN KEY ("plan_id")
        REFERENCES "payments"."subscription_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payments"."subscription_usage_counters"
        ADD CONSTRAINT "fk_subscription_usage_counters_subscription_id" FOREIGN KEY ("subscription_id")
        REFERENCES "payments"."subscriptions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
