-- SALUD v4.0.10 · módulo 42 · schema payments
-- Generado de diagram_42_payments.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   cashier_payment_contexts.cash_register_id


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_gateways"
        ADD CONSTRAINT "fk_payment_gateways_gateway_type_concept_id" FOREIGN KEY ("gateway_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.external_providers (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_gateways"
        ADD CONSTRAINT "fk_payment_gateways_external_provider_id" FOREIGN KEY ("external_provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_gateways"
        ADD CONSTRAINT "fk_payment_gateways_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_gateways"
        ADD CONSTRAINT "fk_payment_gateways_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_gateways"
        ADD CONSTRAINT "fk_payment_gateways_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_environment_concept_id" FOREIGN KEY ("environment_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.provider_credentials (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_credential_id" FOREIGN KEY ("credential_id")
        REFERENCES "integrations"."provider_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_connections"
        ADD CONSTRAINT "fk_gateway_connections_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_owner_type_concept_id" FOREIGN KEY ("owner_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_method_type_concept_id" FOREIGN KEY ("method_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.addresses (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_billing_address_id" FOREIGN KEY ("billing_address_id")
        REFERENCES "common"."addresses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_methods"
        ADD CONSTRAINT "fk_payment_methods_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_purpose_concept_id" FOREIGN KEY ("purpose_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_intents"
        ADD CONSTRAINT "fk_payment_intents_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_transaction_type_concept_id" FOREIGN KEY ("transaction_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_payer_business_partner_id" FOREIGN KEY ("payer_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_payee_business_partner_id" FOREIGN KEY ("payee_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.company_bank_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_company_bank_account_id" FOREIGN KEY ("company_bank_account_id")
        REFERENCES "accounting"."company_bank_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.clearing_documents (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_clearing_document_id" FOREIGN KEY ("clearing_document_id")
        REFERENCES "accounting"."clearing_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_failure_reason_concept_id" FOREIGN KEY ("failure_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_transactions"
        ADD CONSTRAINT "fk_payment_transactions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."refunds"
        ADD CONSTRAINT "fk_refunds_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."refunds"
        ADD CONSTRAINT "fk_refunds_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."refunds"
        ADD CONSTRAINT "fk_refunds_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."refunds"
        ADD CONSTRAINT "fk_refunds_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."refunds"
        ADD CONSTRAINT "fk_refunds_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."refunds"
        ADD CONSTRAINT "fk_refunds_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_dispute_type_concept_id" FOREIGN KEY ("dispute_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_disputes"
        ADD CONSTRAINT "fk_payment_disputes_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_payee_type_concept_id" FOREIGN KEY ("payee_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payouts"
        ADD CONSTRAINT "fk_payouts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payout_items"
        ADD CONSTRAINT "fk_payout_items_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payout_items"
        ADD CONSTRAINT "fk_payout_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payout_items"
        ADD CONSTRAINT "fk_payout_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_settlements"
        ADD CONSTRAINT "fk_gateway_settlements_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_settlements"
        ADD CONSTRAINT "fk_gateway_settlements_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_settlements"
        ADD CONSTRAINT "fk_gateway_settlements_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_settlements"
        ADD CONSTRAINT "fk_gateway_settlements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_settlements"
        ADD CONSTRAINT "fk_gateway_settlements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."settlement_lines"
        ADD CONSTRAINT "fk_settlement_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."settlement_lines"
        ADD CONSTRAINT "fk_settlement_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_webhook_events"
        ADD CONSTRAINT "fk_payment_webhook_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_owner_type_concept_id" FOREIGN KEY ("owner_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_wallet_type_concept_id" FOREIGN KEY ("wallet_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_ledger_account_id" FOREIGN KEY ("ledger_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."wallets"
        ADD CONSTRAINT "fk_wallets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."wallet_ledger_entries"
        ADD CONSTRAINT "fk_wallet_ledger_entries_direction_concept_id" FOREIGN KEY ("direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."wallet_ledger_entries"
        ADD CONSTRAINT "fk_wallet_ledger_entries_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."wallet_ledger_entries"
        ADD CONSTRAINT "fk_wallet_ledger_entries_entry_type_concept_id" FOREIGN KEY ("entry_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."wallet_ledger_entries"
        ADD CONSTRAINT "fk_wallet_ledger_entries_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."wallet_ledger_entries"
        ADD CONSTRAINT "fk_wallet_ledger_entries_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_payee_type_concept_id" FOREIGN KEY ("payee_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.company_bank_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_company_bank_account_id" FOREIGN KEY ("company_bank_account_id")
        REFERENCES "accounting"."company_bank_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_onboarding_status_concept_id" FOREIGN KEY ("onboarding_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_payout_schedule_concept_id" FOREIGN KEY ("payout_schedule_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."connected_accounts"
        ADD CONSTRAINT "fk_connected_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."kyc_verifications"
        ADD CONSTRAINT "fk_kyc_verifications_kyc_level_concept_id" FOREIGN KEY ("kyc_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."kyc_verifications"
        ADD CONSTRAINT "fk_kyc_verifications_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."kyc_verifications"
        ADD CONSTRAINT "fk_kyc_verifications_risk_rating_concept_id" FOREIGN KEY ("risk_rating_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "payments"."kyc_verifications"
        ADD CONSTRAINT "fk_kyc_verifications_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."kyc_verifications"
        ADD CONSTRAINT "fk_kyc_verifications_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."kyc_verifications"
        ADD CONSTRAINT "fk_kyc_verifications_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_split_type_concept_id" FOREIGN KEY ("split_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_splits"
        ADD CONSTRAINT "fk_payment_splits_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_fee_type_concept_id" FOREIGN KEY ("fee_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_calculation_method_concept_id" FOREIGN KEY ("calculation_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_applies_to_concept_id" FOREIGN KEY ("applies_to_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."fee_schedules"
        ADD CONSTRAINT "fk_fee_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."transaction_fees"
        ADD CONSTRAINT "fk_transaction_fees_fee_type_concept_id" FOREIGN KEY ("fee_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."transaction_fees"
        ADD CONSTRAINT "fk_transaction_fees_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."transaction_fees"
        ADD CONSTRAINT "fk_transaction_fees_bearer_type_concept_id" FOREIGN KEY ("bearer_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."transaction_fees"
        ADD CONSTRAINT "fk_transaction_fees_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."transaction_fees"
        ADD CONSTRAINT "fk_transaction_fees_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."tips"
        ADD CONSTRAINT "fk_tips_beneficiary_type_concept_id" FOREIGN KEY ("beneficiary_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."tips"
        ADD CONSTRAINT "fk_tips_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."tips"
        ADD CONSTRAINT "fk_tips_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."tips"
        ADD CONSTRAINT "fk_tips_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."tips"
        ADD CONSTRAINT "fk_tips_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_tier_concept_id" FOREIGN KEY ("tier_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_billing_interval_concept_id" FOREIGN KEY ("billing_interval_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_usage_type_concept_id" FOREIGN KEY ("usage_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_plans"
        ADD CONSTRAINT "fk_subscription_plans_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_subscriber_type_concept_id" FOREIGN KEY ("subscriber_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."subscriptions"
        ADD CONSTRAINT "fk_subscriptions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."installment_plans"
        ADD CONSTRAINT "fk_installment_plans_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."installment_plans"
        ADD CONSTRAINT "fk_installment_plans_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."installment_plans"
        ADD CONSTRAINT "fk_installment_plans_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."installment_plans"
        ADD CONSTRAINT "fk_installment_plans_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."installment_schedules"
        ADD CONSTRAINT "fk_installment_schedules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."installment_schedules"
        ADD CONSTRAINT "fk_installment_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."installment_schedules"
        ADD CONSTRAINT "fk_installment_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_payer_type_concept_id" FOREIGN KEY ("payer_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_mandate_type_concept_id" FOREIGN KEY ("mandate_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_scheme_concept_id" FOREIGN KEY ("scheme_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_mandates"
        ADD CONSTRAINT "fk_payment_mandates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fx_rate_locks"
        ADD CONSTRAINT "fk_fx_rate_locks_from_currency_concept_id" FOREIGN KEY ("from_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fx_rate_locks"
        ADD CONSTRAINT "fk_fx_rate_locks_to_currency_concept_id" FOREIGN KEY ("to_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."fx_rate_locks"
        ADD CONSTRAINT "fk_fx_rate_locks_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."fx_rate_locks"
        ADD CONSTRAINT "fk_fx_rate_locks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."fx_rate_locks"
        ADD CONSTRAINT "fk_fx_rate_locks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_risk_level_concept_id" FOREIGN KEY ("risk_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_three_ds_status_concept_id" FOREIGN KEY ("three_ds_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_reviewed_by_user_id" FOREIGN KEY ("reviewed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_runs"
        ADD CONSTRAINT "fk_reconciliation_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_runs"
        ADD CONSTRAINT "fk_reconciliation_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_runs"
        ADD CONSTRAINT "fk_reconciliation_runs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_runs"
        ADD CONSTRAINT "fk_reconciliation_runs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_exception_type_concept_id" FOREIGN KEY ("exception_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_resolved_by_user_id" FOREIGN KEY ("resolved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."reconciliation_exceptions"
        ADD CONSTRAINT "fk_reconciliation_exceptions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_channel_catalog"
        ADD CONSTRAINT "fk_payment_channel_catalog_channel_type_concept_id" FOREIGN KEY ("channel_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_channel_catalog"
        ADD CONSTRAINT "fk_payment_channel_catalog_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_channel_catalog"
        ADD CONSTRAINT "fk_payment_channel_catalog_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_channel_catalog"
        ADD CONSTRAINT "fk_payment_channel_catalog_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_payment_channel_mappings"
        ADD CONSTRAINT "fk_gateway_payment_channel_mappings_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_payment_channel_mappings"
        ADD CONSTRAINT "fk_gateway_payment_channel_mappings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."gateway_payment_channel_mappings"
        ADD CONSTRAINT "fk_gateway_payment_channel_mappings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_debtor_business_partner_id" FOREIGN KEY ("debtor_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debts"
        ADD CONSTRAINT "fk_payment_debts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_lines"
        ADD CONSTRAINT "fk_payment_debt_lines_billable_item_type_concept_id" FOREIGN KEY ("billable_item_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_lines"
        ADD CONSTRAINT "fk_payment_debt_lines_accounting_account_id" FOREIGN KEY ("accounting_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_lines"
        ADD CONSTRAINT "fk_payment_debt_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_lines"
        ADD CONSTRAINT "fk_payment_debt_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_invoice_requests"
        ADD CONSTRAINT "fk_payment_debt_invoice_requests_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_debt_invoice_requests"
        ADD CONSTRAINT "fk_payment_debt_invoice_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_checkout_sessions"
        ADD CONSTRAINT "fk_payment_checkout_sessions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_operations"
        ADD CONSTRAINT "fk_provider_api_operations_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_operations"
        ADD CONSTRAINT "fk_provider_api_operations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_operations"
        ADD CONSTRAINT "fk_provider_api_operations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_api_attempts"
        ADD CONSTRAINT "fk_provider_api_attempts_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_endpoints"
        ADD CONSTRAINT "fk_provider_callback_endpoints_verification_method_concept_id" FOREIGN KEY ("verification_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.encryption_keys (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_endpoints"
        ADD CONSTRAINT "fk_provider_callback_endpoints_verification_secret_id" FOREIGN KEY ("verification_secret_id")
        REFERENCES "system_ops"."encryption_keys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_endpoints"
        ADD CONSTRAINT "fk_provider_callback_endpoints_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_endpoints"
        ADD CONSTRAINT "fk_provider_callback_endpoints_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_endpoints"
        ADD CONSTRAINT "fk_provider_callback_endpoints_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_events"
        ADD CONSTRAINT "fk_provider_callback_events_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_callback_events"
        ADD CONSTRAINT "fk_provider_callback_events_processing_status_concept_id" FOREIGN KEY ("processing_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."callback_verification_runs"
        ADD CONSTRAINT "fk_callback_verification_runs_verification_method_concept_id" FOREIGN KEY ("verification_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."callback_verification_runs"
        ADD CONSTRAINT "fk_callback_verification_runs_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_status_inquiries"
        ADD CONSTRAINT "fk_payment_status_inquiries_inquiry_reason_concept_id" FOREIGN KEY ("inquiry_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_status_inquiries"
        ADD CONSTRAINT "fk_payment_status_inquiries_result_status_concept_id" FOREIGN KEY ("result_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."cashier_payment_contexts"
        ADD CONSTRAINT "fk_cashier_payment_contexts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."cashier_payment_contexts"
        ADD CONSTRAINT "fk_cashier_payment_contexts_cashier_user_id" FOREIGN KEY ("cashier_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "payments"."cashier_payment_contexts"
        ADD CONSTRAINT "fk_cashier_payment_contexts_site_id" FOREIGN KEY ("site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."invoice_regeneration_requests"
        ADD CONSTRAINT "fk_invoice_regeneration_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_artifact_type_concept_id" FOREIGN KEY ("artifact_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_invoice_artifacts"
        ADD CONSTRAINT "fk_provider_invoice_artifacts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_receipts"
        ADD CONSTRAINT "fk_payment_receipts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_receipts"
        ADD CONSTRAINT "fk_payment_receipts_payer_business_partner_id" FOREIGN KEY ("payer_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_receipts"
        ADD CONSTRAINT "fk_payment_receipts_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_receipts"
        ADD CONSTRAINT "fk_payment_receipts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."payment_receipts"
        ADD CONSTRAINT "fk_payment_receipts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_reconciliation_records"
        ADD CONSTRAINT "fk_provider_reconciliation_records_match_status_concept_id" FOREIGN KEY ("match_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."provider_reconciliation_records"
        ADD CONSTRAINT "fk_provider_reconciliation_records_mismatch_reason_concept_id" FOREIGN KEY ("mismatch_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_prices"
        ADD CONSTRAINT "fk_plan_prices_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_prices"
        ADD CONSTRAINT "fk_plan_prices_billing_interval_concept_id" FOREIGN KEY ("billing_interval_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_prices"
        ADD CONSTRAINT "fk_plan_prices_region_concept_id" FOREIGN KEY ("region_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_prices"
        ADD CONSTRAINT "fk_plan_prices_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_prices"
        ADD CONSTRAINT "fk_plan_prices_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_prices"
        ADD CONSTRAINT "fk_plan_prices_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_features"
        ADD CONSTRAINT "fk_plan_features_feature_concept_id" FOREIGN KEY ("feature_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_features"
        ADD CONSTRAINT "fk_plan_features_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_features"
        ADD CONSTRAINT "fk_plan_features_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_features"
        ADD CONSTRAINT "fk_plan_features_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_quotas"
        ADD CONSTRAINT "fk_plan_quotas_metric_concept_id" FOREIGN KEY ("metric_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_quotas"
        ADD CONSTRAINT "fk_plan_quotas_quota_period_concept_id" FOREIGN KEY ("quota_period_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_quotas"
        ADD CONSTRAINT "fk_plan_quotas_overage_policy_concept_id" FOREIGN KEY ("overage_policy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_quotas"
        ADD CONSTRAINT "fk_plan_quotas_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_quotas"
        ADD CONSTRAINT "fk_plan_quotas_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_quotas"
        ADD CONSTRAINT "fk_plan_quotas_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_eligibility_rules"
        ADD CONSTRAINT "fk_plan_eligibility_rules_eligible_practice_type_concept_id" FOREIGN KEY ("eligible_practice_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_eligibility_rules"
        ADD CONSTRAINT "fk_plan_eligibility_rules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_eligibility_rules"
        ADD CONSTRAINT "fk_plan_eligibility_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."plan_eligibility_rules"
        ADD CONSTRAINT "fk_plan_eligibility_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_usage_counters"
        ADD CONSTRAINT "fk_subscription_usage_counters_metric_concept_id" FOREIGN KEY ("metric_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_usage_counters"
        ADD CONSTRAINT "fk_subscription_usage_counters_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_usage_counters"
        ADD CONSTRAINT "fk_subscription_usage_counters_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "payments"."subscription_usage_counters"
        ADD CONSTRAINT "fk_subscription_usage_counters_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
