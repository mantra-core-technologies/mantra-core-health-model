-- SALUD v4.0.10 · módulo 17 · schema billing
-- Generado de diagram_17_billing.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_receivable_payment_allocations_payment_received_id__c1caeee3" ON "billing"."receivable_payment_allocations" ("payment_received_id", "invoice_id", "open_item_id");

CREATE INDEX IF NOT EXISTS "ix_receivable_payment_allocations_payment_received_id" ON "billing"."receivable_payment_allocations" ("payment_received_id");

CREATE INDEX IF NOT EXISTS "ix_receivable_payment_allocations_invoice_id" ON "billing"."receivable_payment_allocations" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_receivable_payment_allocations_open_item_id" ON "billing"."receivable_payment_allocations" ("open_item_id");

CREATE INDEX IF NOT EXISTS "ix_receivable_payment_allocations_clearing_item_id" ON "billing"."receivable_payment_allocations" ("clearing_item_id");

CREATE INDEX IF NOT EXISTS "ix_receivable_payment_allocations_currency_concept_id" ON "billing"."receivable_payment_allocations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_receivable_payment_allocations_created_by_user_id" ON "billing"."receivable_payment_allocations" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_payable_payment_allocations_payment_made_id_bill_id_3897742e" ON "billing"."payable_payment_allocations" ("payment_made_id", "bill_id", "open_item_id");

CREATE INDEX IF NOT EXISTS "ix_payable_payment_allocations_payment_made_id" ON "billing"."payable_payment_allocations" ("payment_made_id");

CREATE INDEX IF NOT EXISTS "ix_payable_payment_allocations_bill_id" ON "billing"."payable_payment_allocations" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_payable_payment_allocations_open_item_id" ON "billing"."payable_payment_allocations" ("open_item_id");

CREATE INDEX IF NOT EXISTS "ix_payable_payment_allocations_clearing_item_id" ON "billing"."payable_payment_allocations" ("clearing_item_id");

CREATE INDEX IF NOT EXISTS "ix_payable_payment_allocations_currency_concept_id" ON "billing"."payable_payment_allocations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payable_payment_allocations_created_by_user_id" ON "billing"."payable_payment_allocations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_tenant_id" ON "billing"."billing_document_links" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_invoice_id" ON "billing"."billing_document_links" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_bill_id" ON "billing"."billing_document_links" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_contract_id" ON "billing"."billing_document_links" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_sales_order_id" ON "billing"."billing_document_links" ("sales_order_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_purchase_order_id" ON "billing"."billing_document_links" ("purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_claim_id" ON "billing"."billing_document_links" ("claim_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_encounter_id" ON "billing"."billing_document_links" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_relation_type_concept_id" ON "billing"."billing_document_links" ("relation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_created_by_user_id" ON "billing"."billing_document_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_billing_document_links_tenant_relation_created" ON "billing"."billing_document_links" ("tenant_id", "relation_type_concept_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_billing_document_links_created_at" ON "billing"."billing_document_links" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_dunning_runs_tenant_id_run_number" ON "billing"."dunning_runs" ("tenant_id", "run_number");

CREATE INDEX IF NOT EXISTS "ix_dunning_runs_tenant_id" ON "billing"."dunning_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_runs_dunning_level_concept_id" ON "billing"."dunning_runs" ("dunning_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_runs_company_bank_account_id" ON "billing"."dunning_runs" ("company_bank_account_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_runs_status_concept_id" ON "billing"."dunning_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_runs_created_by_user_id" ON "billing"."dunning_runs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_runs_tenant_status_date" ON "billing"."dunning_runs" ("tenant_id", "status_concept_id", "run_date" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_dunning_items_dunning_run_id_invoice_id" ON "billing"."dunning_items" ("dunning_run_id", "invoice_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_dunning_run_id" ON "billing"."dunning_items" ("dunning_run_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_invoice_id" ON "billing"."dunning_items" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_open_item_id" ON "billing"."dunning_items" ("open_item_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_business_partner_id" ON "billing"."dunning_items" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_currency_concept_id" ON "billing"."dunning_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_notice_file_id" ON "billing"."dunning_items" ("notice_file_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_status_concept_id" ON "billing"."dunning_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dunning_items_status_overdue" ON "billing"."dunning_items" ("status_concept_id", "days_overdue" DESC);

CREATE INDEX IF NOT EXISTS "ix_quotations_practice_id" ON "billing"."quotations" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_patient_profile_id" ON "billing"."quotations" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_created_by_practitioner_profile_id" ON "billing"."quotations" ("created_by_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_appointment_id" ON "billing"."quotations" ("appointment_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_service_catalog_id" ON "billing"."quotations" ("service_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_currency_concept_id" ON "billing"."quotations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_status_concept_id" ON "billing"."quotations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_created_by_user_id" ON "billing"."quotations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_quotations_updated_by_user_id" ON "billing"."quotations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_quotation_installments_quotation_id" ON "billing"."quotation_installments" ("quotation_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_practice_id" ON "billing"."service_catalog" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_image_file_id" ON "billing"."service_catalog" ("image_file_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_service_concept_id" ON "billing"."service_catalog" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_currency_concept_id" ON "billing"."service_catalog" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_tax_code_id" ON "billing"."service_catalog" ("tax_code_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_income_account_id" ON "billing"."service_catalog" ("income_account_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_created_by_user_id" ON "billing"."service_catalog" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_catalog_updated_by_user_id" ON "billing"."service_catalog" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_invoices_invoice_number" ON "billing"."invoices" ("invoice_number");

CREATE INDEX IF NOT EXISTS "ix_invoices_practice_id" ON "billing"."invoices" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_patient_profile_id" ON "billing"."invoices" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_encounter_id" ON "billing"."invoices" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_status_concept_id" ON "billing"."invoices" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_currency_concept_id" ON "billing"."invoices" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_customer_business_partner_id" ON "billing"."invoices" ("customer_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_customer_subledger_account_id" ON "billing"."invoices" ("customer_subledger_account_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_contract_id" ON "billing"."invoices" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_sales_order_id" ON "billing"."invoices" ("sales_order_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_transaction_id" ON "billing"."invoices" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_created_by_user_id" ON "billing"."invoices" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_updated_by_user_id" ON "billing"."invoices" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoices_patient_profile_id_updated_at" ON "billing"."invoices" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_invoice_id" ON "billing"."invoice_lines" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_service_id" ON "billing"."invoice_lines" ("service_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_tax_code_id" ON "billing"."invoice_lines" ("tax_code_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_income_account_id" ON "billing"."invoice_lines" ("income_account_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_cost_center_id" ON "billing"."invoice_lines" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_contract_line_item_id" ON "billing"."invoice_lines" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_sales_order_item_id" ON "billing"."invoice_lines" ("sales_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_created_by_user_id" ON "billing"."invoice_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_updated_by_user_id" ON "billing"."invoice_lines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_practice_id" ON "billing"."payments_received" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_invoice_id" ON "billing"."payments_received" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_patient_profile_id" ON "billing"."payments_received" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_method_concept_id" ON "billing"."payments_received" ("method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_transaction_id" ON "billing"."payments_received" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_payment_transaction_id" ON "billing"."payments_received" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_clearing_document_id" ON "billing"."payments_received" ("clearing_document_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_company_bank_account_id" ON "billing"."payments_received" ("company_bank_account_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_status_concept_id" ON "billing"."payments_received" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_created_by_user_id" ON "billing"."payments_received" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_updated_by_user_id" ON "billing"."payments_received" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payments_received_patient_profile_id_updated_at" ON "billing"."payments_received" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_patient_statements_practice_id" ON "billing"."patient_statements" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_patient_statements_patient_profile_id" ON "billing"."patient_statements" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_statements_created_by_user_id" ON "billing"."patient_statements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_statements_updated_by_user_id" ON "billing"."patient_statements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_statements_patient_profile_id_updated_at" ON "billing"."patient_statements" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_vendors_practice_id" ON "billing"."vendors" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_vendors_status_concept_id" ON "billing"."vendors" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_vendors_business_partner_id" ON "billing"."vendors" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_vendors_supplier_subledger_account_id" ON "billing"."vendors" ("supplier_subledger_account_id");

CREATE INDEX IF NOT EXISTS "ix_vendors_created_by_user_id" ON "billing"."vendors" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_vendors_updated_by_user_id" ON "billing"."vendors" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bills_practice_id" ON "billing"."bills" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_bills_vendor_id" ON "billing"."bills" ("vendor_id");

CREATE INDEX IF NOT EXISTS "ix_bills_status_concept_id" ON "billing"."bills" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_bills_transaction_id" ON "billing"."bills" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_bills_currency_concept_id" ON "billing"."bills" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_bills_supplier_business_partner_id" ON "billing"."bills" ("supplier_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_bills_supplier_subledger_account_id" ON "billing"."bills" ("supplier_subledger_account_id");

CREATE INDEX IF NOT EXISTS "ix_bills_contract_id" ON "billing"."bills" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_bills_purchase_order_id" ON "billing"."bills" ("purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_bills_created_by_user_id" ON "billing"."bills" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bills_updated_by_user_id" ON "billing"."bills" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_bill_id" ON "billing"."bill_lines" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_expense_account_id" ON "billing"."bill_lines" ("expense_account_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_cost_center_id" ON "billing"."bill_lines" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_contract_line_item_id" ON "billing"."bill_lines" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_purchase_order_item_id" ON "billing"."bill_lines" ("purchase_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_goods_receipt_item_id" ON "billing"."bill_lines" ("goods_receipt_item_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_service_entry_item_id" ON "billing"."bill_lines" ("service_entry_item_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_created_by_user_id" ON "billing"."bill_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bill_lines_updated_by_user_id" ON "billing"."bill_lines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_practice_id" ON "billing"."payments_made" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_bill_id" ON "billing"."payments_made" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_vendor_id" ON "billing"."payments_made" ("vendor_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_method_concept_id" ON "billing"."payments_made" ("method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_transaction_id" ON "billing"."payments_made" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_payment_transaction_id" ON "billing"."payments_made" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_clearing_document_id" ON "billing"."payments_made" ("clearing_document_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_company_bank_account_id" ON "billing"."payments_made" ("company_bank_account_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_status_concept_id" ON "billing"."payments_made" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_created_by_user_id" ON "billing"."payments_made" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_payments_made_updated_by_user_id" ON "billing"."payments_made" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reimbursements_claim_id" ON "billing"."reimbursements" ("claim_id");

CREATE INDEX IF NOT EXISTS "ix_reimbursements_transaction_id" ON "billing"."reimbursements" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_reimbursements_status_concept_id" ON "billing"."reimbursements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reimbursements_created_by_user_id" ON "billing"."reimbursements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reimbursements_updated_by_user_id" ON "billing"."reimbursements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tax_codes_practice_id" ON "billing"."tax_codes" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_tax_codes_tax_type_concept_id" ON "billing"."tax_codes" ("tax_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tax_codes_jurisdiction_concept_id" ON "billing"."tax_codes" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tax_codes_account_id" ON "billing"."tax_codes" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_tax_codes_created_by_user_id" ON "billing"."tax_codes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tax_codes_updated_by_user_id" ON "billing"."tax_codes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tax_periods_practice_id" ON "billing"."tax_periods" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_tax_periods_status_concept_id" ON "billing"."tax_periods" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tax_periods_created_by_user_id" ON "billing"."tax_periods" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tax_periods_updated_by_user_id" ON "billing"."tax_periods" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_budgets_practice_id" ON "billing"."budgets" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_budgets_fiscal_year_id" ON "billing"."budgets" ("fiscal_year_id");

CREATE INDEX IF NOT EXISTS "ix_budgets_status_concept_id" ON "billing"."budgets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_budgets_created_by_user_id" ON "billing"."budgets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_budgets_updated_by_user_id" ON "billing"."budgets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_budget_lines_budget_id" ON "billing"."budget_lines" ("budget_id");

CREATE INDEX IF NOT EXISTS "ix_budget_lines_account_id" ON "billing"."budget_lines" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_budget_lines_cost_center_id" ON "billing"."budget_lines" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_budget_lines_fiscal_period_id" ON "billing"."budget_lines" ("fiscal_period_id");

CREATE INDEX IF NOT EXISTS "ix_budget_lines_created_by_user_id" ON "billing"."budget_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_budget_lines_updated_by_user_id" ON "billing"."budget_lines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_financial_kpi_snapshots_practice_id" ON "billing"."financial_kpi_snapshots" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_financial_kpi_snapshots_fiscal_period_id" ON "billing"."financial_kpi_snapshots" ("fiscal_period_id");

CREATE INDEX IF NOT EXISTS "ix_financial_kpi_snapshots_recorded_by_user_id" ON "billing"."financial_kpi_snapshots" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_financial_kpi_snapshots_recorded_at" ON "billing"."financial_kpi_snapshots" USING brin ("recorded_at") WITH (pages_per_range=128);
