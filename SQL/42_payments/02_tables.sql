-- SALUD v4.0.10 · módulo 42 · schema payments
-- Generado de diagram_42_payments.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "payments"."payment_gateways" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "gateway_type_concept_id" uuid NOT NULL,
    "capabilities_json" jsonb,
    "supported_currencies_json" jsonb,
    "external_provider_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_gateways" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."gateway_connections" (
    "id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "environment_concept_id" uuid NOT NULL,
    "merchant_ref" varchar,
    "credential_id" uuid,
    "config_json" jsonb,
    "webhook_secret_ref" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_gateway_connections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_methods" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "owner_type_concept_id" uuid NOT NULL,
    "owner_ref_id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "method_type_concept_id" uuid NOT NULL,
    "gateway_token" varchar NOT NULL,
    "brand" varchar,
    "last_four" varchar,
    "expiry_month" integer,
    "expiry_year" integer,
    "holder_name" varchar,
    "is_default" boolean,
    "billing_address_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_methods" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_intents" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "gateway_id" uuid NOT NULL,
    "gateway_connection_id" uuid,
    "payment_method_id" uuid,
    "purpose_concept_id" uuid NOT NULL,
    "invoice_id" uuid,
    "source_ref_type" varchar,
    "source_ref_id" uuid,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "gateway_intent_ref" varchar,
    "status_concept_id" uuid NOT NULL,
    "client_secret_ref" varchar,
    "expires_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_intents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_transactions" (
    "id" uuid NOT NULL,
    "payment_intent_id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "transaction_type_concept_id" uuid NOT NULL,
    "gateway_transaction_ref" varchar,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "fee_amount" numeric,
    "net_amount" numeric,
    "payer_business_partner_id" uuid,
    "payee_business_partner_id" uuid,
    "contract_id" uuid,
    "company_bank_account_id" uuid,
    "clearing_document_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "authorization_code" varchar,
    "processed_at" timestamptz,
    "failure_reason_concept_id" uuid,
    "journal_transaction_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_transactions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."refunds" (
    "id" uuid NOT NULL,
    "payment_transaction_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "gateway_refund_ref" varchar,
    "status_concept_id" uuid NOT NULL,
    "processed_at" timestamptz,
    "journal_transaction_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_refunds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_disputes" (
    "id" uuid NOT NULL,
    "payment_transaction_id" uuid NOT NULL,
    "dispute_type_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "evidence_file_id" uuid,
    "gateway_dispute_ref" varchar,
    "due_by" timestamptz,
    "resolved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_disputes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payouts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "payee_type_concept_id" uuid NOT NULL,
    "payee_ref_id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "scheduled_at" timestamptz,
    "executed_at" timestamptz,
    "destination_ref" varchar,
    "gateway_payout_ref" varchar,
    "journal_transaction_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payouts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payout_items" (
    "id" uuid NOT NULL,
    "payout_id" uuid NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "source_ref_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "commission_amount" numeric,
    "description" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payout_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."gateway_settlements" (
    "id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "settlement_ref" varchar NOT NULL,
    "gross_amount" numeric NOT NULL,
    "fee_amount" numeric NOT NULL,
    "net_amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "settled_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "journal_transaction_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_gateway_settlements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."settlement_lines" (
    "id" uuid NOT NULL,
    "settlement_id" uuid NOT NULL,
    "payment_transaction_id" uuid,
    "refund_id" uuid,
    "amount" numeric NOT NULL,
    "fee_amount" numeric,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_settlement_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_webhook_events" (
    "id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "gateway_connection_id" uuid,
    "event_type" varchar NOT NULL,
    "gateway_event_ref" varchar,
    "payload_json" jsonb NOT NULL,
    "signature" varchar,
    "is_verified" boolean,
    "processed" boolean,
    "related_intent_id" uuid,
    "received_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_payment_webhook_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."wallets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "owner_type_concept_id" uuid NOT NULL,
    "owner_ref_id" uuid NOT NULL,
    "wallet_type_concept_id" uuid NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "available_balance" numeric,
    "pending_balance" numeric,
    "reserved_balance" numeric,
    "ledger_account_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_wallets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."wallet_ledger_entries" (
    "id" uuid NOT NULL,
    "wallet_id" uuid NOT NULL,
    "direction_concept_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "entry_type_concept_id" uuid NOT NULL,
    "balance_after" numeric,
    "source_type" varchar,
    "source_ref_id" uuid,
    "payment_transaction_id" uuid,
    "journal_transaction_id" uuid,
    "idempotency_key" varchar NOT NULL,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_wallet_ledger_entries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."connected_accounts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "payee_type_concept_id" uuid NOT NULL,
    "payee_ref_id" uuid NOT NULL,
    "external_account_ref" varchar NOT NULL,
    "business_partner_id" uuid,
    "company_bank_account_id" uuid,
    "onboarding_status_concept_id" uuid NOT NULL,
    "capabilities_json" jsonb,
    "default_wallet_id" uuid,
    "payout_schedule_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_connected_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."kyc_verifications" (
    "id" uuid NOT NULL,
    "connected_account_id" uuid NOT NULL,
    "kyc_level_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "provider_ref" varchar,
    "risk_rating_concept_id" uuid,
    "verified_at" timestamptz,
    "expires_at" timestamptz,
    "evidence_file_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_kyc_verifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_splits" (
    "id" uuid NOT NULL,
    "payment_intent_id" uuid NOT NULL,
    "payee_connected_account_id" uuid NOT NULL,
    "split_type_concept_id" uuid NOT NULL,
    "amount" numeric,
    "percentage" numeric,
    "currency_concept_id" uuid,
    "is_platform_fee" boolean NOT NULL,
    "destination_wallet_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_splits" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."fee_schedules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "fee_type_concept_id" uuid NOT NULL,
    "calculation_method_concept_id" uuid NOT NULL,
    "percentage" numeric,
    "fixed_amount" numeric,
    "currency_concept_id" uuid,
    "min_amount" numeric,
    "max_amount" numeric,
    "applies_to_concept_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_fee_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."transaction_fees" (
    "id" uuid NOT NULL,
    "payment_transaction_id" uuid NOT NULL,
    "fee_schedule_id" uuid,
    "fee_type_concept_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "bearer_type_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_transaction_fees" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."tips" (
    "id" uuid NOT NULL,
    "payment_intent_id" uuid NOT NULL,
    "beneficiary_type_concept_id" uuid NOT NULL,
    "beneficiary_ref_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "destination_wallet_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tips" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."subscription_plans" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "tier_concept_id" uuid NOT NULL,
    "is_default" boolean,
    "is_public" boolean,
    "billing_interval_concept_id" uuid NOT NULL,
    "interval_count" integer,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "trial_days" integer,
    "setup_fee" numeric,
    "usage_type_concept_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_subscription_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."subscriptions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "subscriber_type_concept_id" uuid NOT NULL,
    "subscriber_ref_id" uuid NOT NULL,
    "payment_method_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "current_period_start" timestamptz,
    "current_period_end" timestamptz,
    "trial_end_at" timestamptz,
    "cancel_at" timestamptz,
    "canceled_at" timestamptz,
    "mandate_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_subscriptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."installment_plans" (
    "id" uuid NOT NULL,
    "payment_intent_id" uuid NOT NULL,
    "number_of_installments" integer NOT NULL,
    "total_amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "interest_rate" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_installment_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."installment_schedules" (
    "id" uuid NOT NULL,
    "installment_plan_id" uuid NOT NULL,
    "sequence_no" integer NOT NULL,
    "due_date" date NOT NULL,
    "amount" numeric NOT NULL,
    "paid_amount" numeric,
    "payment_transaction_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_installment_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_mandates" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "payer_type_concept_id" uuid NOT NULL,
    "payer_ref_id" uuid NOT NULL,
    "mandate_type_concept_id" uuid NOT NULL,
    "payment_method_id" uuid,
    "mandate_ref" varchar NOT NULL,
    "scheme_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "signed_at" timestamptz,
    "revoked_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_mandates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."fx_rate_locks" (
    "id" uuid NOT NULL,
    "payment_intent_id" uuid NOT NULL,
    "from_currency_concept_id" uuid NOT NULL,
    "to_currency_concept_id" uuid NOT NULL,
    "locked_rate" numeric NOT NULL,
    "provider_ref" varchar,
    "locked_at" timestamptz,
    "expires_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_fx_rate_locks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."risk_assessments" (
    "id" uuid NOT NULL,
    "payment_intent_id" uuid NOT NULL,
    "risk_score" numeric NOT NULL,
    "risk_level_concept_id" uuid NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "provider_ref" varchar,
    "signals_json" jsonb,
    "three_ds_status_concept_id" uuid,
    "reviewed_by_user_id" uuid,
    "assessed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_risk_assessments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."reconciliation_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "gateway_id" uuid NOT NULL,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "total_gateway" numeric,
    "total_ledger" numeric,
    "total_bank" numeric,
    "matched_count" integer,
    "unmatched_count" integer,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_reconciliation_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."reconciliation_exceptions" (
    "id" uuid NOT NULL,
    "reconciliation_run_id" uuid NOT NULL,
    "exception_type_concept_id" uuid NOT NULL,
    "payment_transaction_id" uuid,
    "wallet_ledger_entry_id" uuid,
    "external_ref" varchar,
    "amount_difference" numeric,
    "status_concept_id" uuid NOT NULL,
    "resolution_text" text,
    "resolved_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_reconciliation_exceptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_channel_catalog" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "channel_type_concept_id" uuid NOT NULL,
    "description" text,
    "supports_qr" boolean,
    "supports_card" boolean,
    "supports_bank_transfer" boolean,
    "supports_cash" boolean,
    "requires_payer_identity" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_channel_catalog" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."gateway_payment_channel_mappings" (
    "id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "payment_channel_catalog_id" uuid NOT NULL,
    "external_channel_code" varchar NOT NULL,
    "configuration_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_gateway_payment_channel_mappings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_debts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "debtor_business_partner_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "contract_id" uuid,
    "invoice_id" uuid,
    "internal_debt_number" varchar NOT NULL,
    "external_debt_id" varchar,
    "currency_code" char(3) NOT NULL,
    "total_amount" numeric(20,6) NOT NULL,
    "outstanding_amount" numeric(20,6) NOT NULL,
    "due_at" timestamptz NOT NULL,
    "description" text,
    "status_concept_id" uuid NOT NULL,
    "registered_at" timestamptz,
    "settled_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_debts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_debt_lines" (
    "id" uuid NOT NULL,
    "payment_debt_id" uuid NOT NULL,
    "line_number" integer NOT NULL,
    "billable_item_type_concept_id" uuid,
    "billable_item_id" uuid,
    "description" varchar NOT NULL,
    "quantity" numeric(20,6) NOT NULL,
    "unit_amount" numeric(20,6) NOT NULL,
    "line_amount" numeric(20,6) NOT NULL,
    "tax_amount" numeric(20,6),
    "discount_amount" numeric(20,6),
    "accounting_account_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_debt_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_debt_invoice_requests" (
    "id" uuid NOT NULL,
    "payment_debt_id" uuid NOT NULL,
    "request_number" integer NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "requested_by_user_id" uuid,
    "invoice_name" varchar,
    "tax_identifier" varchar,
    "invoice_email" varchar,
    "invoice_metadata_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "external_invoice_request_id" varchar,
    "completed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_payment_debt_invoice_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_checkout_sessions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "payment_debt_id" uuid NOT NULL,
    "payment_intent_id" uuid,
    "session_token_hash" varchar NOT NULL,
    "external_transaction_id" varchar,
    "redirect_url" varchar NOT NULL,
    "success_return_url" varchar,
    "failure_return_url" varchar,
    "callback_endpoint_id" uuid,
    "expires_at" timestamptz NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "opened_at" timestamptz,
    "completed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_checkout_sessions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."provider_api_operations" (
    "id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "operation_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "http_method" varchar NOT NULL,
    "endpoint_template" varchar NOT NULL,
    "timeout_ms" integer,
    "retry_policy_json" jsonb,
    "request_schema_json" jsonb,
    "response_schema_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_api_operations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."provider_api_attempts" (
    "id" uuid NOT NULL,
    "provider_api_operation_id" uuid NOT NULL,
    "payment_debt_id" uuid,
    "payment_checkout_session_id" uuid,
    "payment_transaction_id" uuid,
    "correlation_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "responded_at" timestamptz,
    "http_status" integer,
    "result_concept_id" uuid NOT NULL,
    "external_error_code" varchar,
    "request_hash" varchar,
    "response_hash" varchar,
    "response_body_redacted_json" jsonb,
    "retry_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_provider_api_attempts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."provider_callback_endpoints" (
    "id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "callback_path" varchar NOT NULL,
    "verification_method_concept_id" uuid NOT NULL,
    "verification_secret_id" uuid,
    "allowed_source_cidrs_json" jsonb,
    "replay_window_seconds" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_callback_endpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."provider_callback_events" (
    "id" uuid NOT NULL,
    "provider_callback_endpoint_id" uuid NOT NULL,
    "payment_checkout_session_id" uuid,
    "payment_transaction_id" uuid,
    "external_event_id" varchar,
    "external_transaction_id" varchar,
    "received_at" timestamptz NOT NULL,
    "payload_hash" varchar NOT NULL,
    "headers_redacted_json" jsonb,
    "payload_redacted_json" jsonb,
    "verification_status_concept_id" uuid NOT NULL,
    "processing_status_concept_id" uuid NOT NULL,
    "duplicate_of_event_id" uuid,
    "processed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_provider_callback_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."callback_verification_runs" (
    "id" uuid NOT NULL,
    "provider_callback_event_id" uuid NOT NULL,
    "verification_method_concept_id" uuid NOT NULL,
    "verified_at" timestamptz NOT NULL,
    "result_concept_id" uuid NOT NULL,
    "signature_present" boolean,
    "timestamp_within_window" boolean,
    "source_network_allowed" boolean,
    "status_inquiry_confirmed" boolean,
    "failure_reason" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_callback_verification_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_status_inquiries" (
    "id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "payment_debt_id" uuid,
    "payment_checkout_session_id" uuid,
    "payment_transaction_id" uuid,
    "external_transaction_id" varchar,
    "inquiry_reason_concept_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "responded_at" timestamptz,
    "result_status_concept_id" uuid NOT NULL,
    "provider_status_code" varchar,
    "provider_amount" numeric(20,6),
    "provider_currency_code" char(3),
    "response_hash" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_payment_status_inquiries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."cashier_payment_contexts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "payment_checkout_session_id" uuid NOT NULL,
    "cashier_user_id" uuid,
    "cash_register_id" uuid,
    "site_id" uuid,
    "workstation_reference" varchar,
    "shift_reference" varchar,
    "customer_display_reference" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_cashier_payment_contexts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_cancellation_requests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "payment_debt_id" uuid,
    "payment_checkout_session_id" uuid,
    "payment_transaction_id" uuid,
    "request_number" varchar NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "reason_text" text,
    "requested_by_user_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "external_cancellation_id" varchar,
    "completed_at" timestamptz,
    "provider_result_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_cancellation_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."invoice_regeneration_requests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "payment_transaction_id" uuid NOT NULL,
    "payment_debt_id" uuid,
    "request_number" varchar NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "requested_by_user_id" uuid,
    "invoice_name" varchar,
    "tax_identifier" varchar,
    "invoice_email" varchar,
    "status_concept_id" uuid NOT NULL,
    "external_request_id" varchar,
    "completed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_invoice_regeneration_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."provider_invoice_artifacts" (
    "id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "payment_transaction_id" uuid NOT NULL,
    "invoice_regeneration_request_id" uuid,
    "artifact_type_concept_id" uuid NOT NULL,
    "external_invoice_id" varchar NOT NULL,
    "invoice_number" varchar,
    "authorization_code" varchar,
    "issue_date" date,
    "file_id" uuid,
    "download_url_encrypted" text,
    "content_hash" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_invoice_artifacts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."payment_receipts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "payment_transaction_id" uuid NOT NULL,
    "payment_debt_id" uuid,
    "receipt_number" varchar NOT NULL,
    "issued_at" timestamptz NOT NULL,
    "amount" numeric(20,6) NOT NULL,
    "currency_code" char(3) NOT NULL,
    "payer_business_partner_id" uuid,
    "file_id" uuid,
    "content_hash" varchar,
    "voided_at" timestamptz,
    "void_reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_receipts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."provider_reconciliation_records" (
    "id" uuid NOT NULL,
    "gateway_connection_id" uuid NOT NULL,
    "reconciliation_run_id" uuid NOT NULL,
    "payment_debt_id" uuid,
    "payment_transaction_id" uuid,
    "external_transaction_id" varchar NOT NULL,
    "provider_status_code" varchar NOT NULL,
    "provider_paid_at" timestamptz,
    "provider_amount" numeric(20,6) NOT NULL,
    "provider_currency_code" char(3) NOT NULL,
    "provider_fee_amount" numeric(20,6),
    "settlement_reference" varchar,
    "match_status_concept_id" uuid NOT NULL,
    "mismatch_reason_concept_id" uuid,
    "source_record_hash" varchar,
    "recorded_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_provider_reconciliation_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."plan_prices" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "billing_interval_concept_id" uuid NOT NULL,
    "interval_count" integer,
    "amount" numeric NOT NULL,
    "region_concept_id" uuid,
    "tax_included" boolean,
    "valid_from" date,
    "valid_to" date,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_plan_prices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."plan_features" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "feature_concept_id" uuid NOT NULL,
    "is_enabled" boolean NOT NULL,
    "limit_value" numeric,
    "value_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_plan_features" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."plan_quotas" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "metric_concept_id" uuid NOT NULL,
    "limit_value" numeric,
    "soft_limit_value" numeric,
    "quota_period_concept_id" uuid,
    "overage_policy_concept_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_plan_quotas" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."plan_eligibility_rules" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "eligible_practice_type_concept_id" uuid NOT NULL,
    "is_included" boolean NOT NULL,
    "notes" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_plan_eligibility_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payments"."subscription_usage_counters" (
    "id" uuid NOT NULL,
    "subscription_id" uuid NOT NULL,
    "metric_concept_id" uuid NOT NULL,
    "period_start" timestamptz NOT NULL,
    "period_end" timestamptz NOT NULL,
    "used_value" numeric,
    "limit_value" numeric,
    "last_event_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_subscription_usage_counters" PRIMARY KEY ("id")
);
