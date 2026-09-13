-- SALUD v4.0.10 · módulo 17 · schema billing
-- Generado de diagram_17_billing.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   invoice_lines.service_id
--   reimbursements.claim_id
--   billing_document_links.claim_id


-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_image_file_id" FOREIGN KEY ("image_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_income_account_id" FOREIGN KEY ("income_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_customer_business_partner_id" FOREIGN KEY ("customer_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.subledger_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_customer_subledger_account_id" FOREIGN KEY ("customer_subledger_account_id")
        REFERENCES "accounting"."subledger_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.sales_orders (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_sales_order_id" FOREIGN KEY ("sales_order_id")
        REFERENCES "erp"."sales_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."invoices"
        ADD CONSTRAINT "fk_invoices_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_income_account_id" FOREIGN KEY ("income_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contract_line_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.sales_order_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_sales_order_item_id" FOREIGN KEY ("sales_order_item_id")
        REFERENCES "erp"."sales_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_method_concept_id" FOREIGN KEY ("method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.clearing_documents (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_clearing_document_id" FOREIGN KEY ("clearing_document_id")
        REFERENCES "accounting"."clearing_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.company_bank_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_company_bank_account_id" FOREIGN KEY ("company_bank_account_id")
        REFERENCES "accounting"."company_bank_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."patient_statements"
        ADD CONSTRAINT "fk_patient_statements_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."patient_statements"
        ADD CONSTRAINT "fk_patient_statements_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."patient_statements"
        ADD CONSTRAINT "fk_patient_statements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."patient_statements"
        ADD CONSTRAINT "fk_patient_statements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."vendors"
        ADD CONSTRAINT "fk_vendors_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."vendors"
        ADD CONSTRAINT "fk_vendors_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.subledger_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."vendors"
        ADD CONSTRAINT "fk_vendors_supplier_subledger_account_id" FOREIGN KEY ("supplier_subledger_account_id")
        REFERENCES "accounting"."subledger_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."vendors"
        ADD CONSTRAINT "fk_vendors_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."vendors"
        ADD CONSTRAINT "fk_vendors_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."vendors"
        ADD CONSTRAINT "fk_vendors_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_supplier_business_partner_id" FOREIGN KEY ("supplier_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.subledger_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_supplier_subledger_account_id" FOREIGN KEY ("supplier_subledger_account_id")
        REFERENCES "accounting"."subledger_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.purchase_orders (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_purchase_order_id" FOREIGN KEY ("purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_expense_account_id" FOREIGN KEY ("expense_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contract_line_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.purchase_order_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_purchase_order_item_id" FOREIGN KEY ("purchase_order_item_id")
        REFERENCES "erp"."purchase_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.goods_receipt_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_goods_receipt_item_id" FOREIGN KEY ("goods_receipt_item_id")
        REFERENCES "erp"."goods_receipt_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.service_entry_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_service_entry_item_id" FOREIGN KEY ("service_entry_item_id")
        REFERENCES "erp"."service_entry_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_method_concept_id" FOREIGN KEY ("method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.clearing_documents (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_clearing_document_id" FOREIGN KEY ("clearing_document_id")
        REFERENCES "accounting"."clearing_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.company_bank_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_company_bank_account_id" FOREIGN KEY ("company_bank_account_id")
        REFERENCES "accounting"."company_bank_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."reimbursements"
        ADD CONSTRAINT "fk_reimbursements_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."reimbursements"
        ADD CONSTRAINT "fk_reimbursements_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."reimbursements"
        ADD CONSTRAINT "fk_reimbursements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."reimbursements"
        ADD CONSTRAINT "fk_reimbursements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_codes"
        ADD CONSTRAINT "fk_tax_codes_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_codes"
        ADD CONSTRAINT "fk_tax_codes_tax_type_concept_id" FOREIGN KEY ("tax_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_codes"
        ADD CONSTRAINT "fk_tax_codes_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_codes"
        ADD CONSTRAINT "fk_tax_codes_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_codes"
        ADD CONSTRAINT "fk_tax_codes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_codes"
        ADD CONSTRAINT "fk_tax_codes_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_periods"
        ADD CONSTRAINT "fk_tax_periods_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_periods"
        ADD CONSTRAINT "fk_tax_periods_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_periods"
        ADD CONSTRAINT "fk_tax_periods_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."tax_periods"
        ADD CONSTRAINT "fk_tax_periods_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."budgets"
        ADD CONSTRAINT "fk_budgets_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.fiscal_years (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."budgets"
        ADD CONSTRAINT "fk_budgets_fiscal_year_id" FOREIGN KEY ("fiscal_year_id")
        REFERENCES "accounting"."fiscal_years" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."budgets"
        ADD CONSTRAINT "fk_budgets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."budgets"
        ADD CONSTRAINT "fk_budgets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."budgets"
        ADD CONSTRAINT "fk_budgets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."budget_lines"
        ADD CONSTRAINT "fk_budget_lines_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."budget_lines"
        ADD CONSTRAINT "fk_budget_lines_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.fiscal_periods (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."budget_lines"
        ADD CONSTRAINT "fk_budget_lines_fiscal_period_id" FOREIGN KEY ("fiscal_period_id")
        REFERENCES "accounting"."fiscal_periods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."budget_lines"
        ADD CONSTRAINT "fk_budget_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."budget_lines"
        ADD CONSTRAINT "fk_budget_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."financial_kpi_snapshots"
        ADD CONSTRAINT "fk_financial_kpi_snapshots_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.fiscal_periods (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."financial_kpi_snapshots"
        ADD CONSTRAINT "fk_financial_kpi_snapshots_fiscal_period_id" FOREIGN KEY ("fiscal_period_id")
        REFERENCES "accounting"."fiscal_periods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."financial_kpi_snapshots"
        ADD CONSTRAINT "fk_financial_kpi_snapshots_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.open_items (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."receivable_payment_allocations"
        ADD CONSTRAINT "fk_receivable_payment_allocations_open_item_id" FOREIGN KEY ("open_item_id")
        REFERENCES "accounting"."open_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.clearing_items (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."receivable_payment_allocations"
        ADD CONSTRAINT "fk_receivable_payment_allocations_clearing_item_id" FOREIGN KEY ("clearing_item_id")
        REFERENCES "accounting"."clearing_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."receivable_payment_allocations"
        ADD CONSTRAINT "fk_receivable_payment_allocations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."receivable_payment_allocations"
        ADD CONSTRAINT "fk_receivable_payment_allocations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.open_items (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."payable_payment_allocations"
        ADD CONSTRAINT "fk_payable_payment_allocations_open_item_id" FOREIGN KEY ("open_item_id")
        REFERENCES "accounting"."open_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.clearing_items (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."payable_payment_allocations"
        ADD CONSTRAINT "fk_payable_payment_allocations_clearing_item_id" FOREIGN KEY ("clearing_item_id")
        REFERENCES "accounting"."clearing_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."payable_payment_allocations"
        ADD CONSTRAINT "fk_payable_payment_allocations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payable_payment_allocations"
        ADD CONSTRAINT "fk_payable_payment_allocations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.sales_orders (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_sales_order_id" FOREIGN KEY ("sales_order_id")
        REFERENCES "erp"."sales_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.purchase_orders (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_purchase_order_id" FOREIGN KEY ("purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_relation_type_concept_id" FOREIGN KEY ("relation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_runs"
        ADD CONSTRAINT "fk_dunning_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_runs"
        ADD CONSTRAINT "fk_dunning_runs_dunning_level_concept_id" FOREIGN KEY ("dunning_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.company_bank_accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_runs"
        ADD CONSTRAINT "fk_dunning_runs_company_bank_account_id" FOREIGN KEY ("company_bank_account_id")
        REFERENCES "accounting"."company_bank_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_runs"
        ADD CONSTRAINT "fk_dunning_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_runs"
        ADD CONSTRAINT "fk_dunning_runs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.open_items (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_items"
        ADD CONSTRAINT "fk_dunning_items_open_item_id" FOREIGN KEY ("open_item_id")
        REFERENCES "accounting"."open_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_items"
        ADD CONSTRAINT "fk_dunning_items_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_items"
        ADD CONSTRAINT "fk_dunning_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_items"
        ADD CONSTRAINT "fk_dunning_items_notice_file_id" FOREIGN KEY ("notice_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."dunning_items"
        ADD CONSTRAINT "fk_dunning_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_created_by_practitioner_profile_id" FOREIGN KEY ("created_by_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
