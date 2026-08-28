-- SALUD v4.0.10 · módulo 16 · schema accounting
-- Generado de diagram_16_accounting.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "accounting"."exchange_rates" (
    "id" uuid NOT NULL,
    "from_currency_concept_id" uuid NOT NULL,
    "to_currency_concept_id" uuid NOT NULL,
    "rate" numeric NOT NULL,
    "valid_on" date NOT NULL,
    "source" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_exchange_rates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."fiscal_years" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_fiscal_years" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."fiscal_periods" (
    "id" uuid NOT NULL,
    "fiscal_year_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_fiscal_periods" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."account_groups" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_group_id" uuid,
    "account_type_concept_id" uuid NOT NULL,
    "ordinal" integer,
    "is_system" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_account_groups" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."accounts" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "account_group_id" uuid,
    "account_type_concept_id" uuid NOT NULL,
    "normal_balance_concept_id" uuid NOT NULL,
    "parent_account_id" uuid,
    "currency_concept_id" uuid,
    "is_configurable" boolean NOT NULL,
    "is_system" boolean,
    "is_postable" boolean NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."cost_centers" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_cost_center_id" uuid,
    "practitioner_profile_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_cost_centers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."cost_center_maps" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "source_id" uuid NOT NULL,
    "cost_center_id" uuid NOT NULL,
    "allocation_percent" numeric NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_cost_center_maps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."journal_transactions" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "transaction_number" varchar NOT NULL,
    "transaction_type_concept_id" uuid NOT NULL,
    "transaction_date" date NOT NULL,
    "fiscal_period_id" uuid,
    "description" varchar,
    "reference" varchar,
    "source_document_type" varchar,
    "source_document_id" uuid,
    "currency_concept_id" uuid,
    "total_amount" numeric,
    "status_concept_id" uuid NOT NULL,
    "posted_at" timestamptz,
    "posted_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    "approved_at" timestamptz,
    "approved_by_user_id" uuid,
    CONSTRAINT "pk_journal_transactions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."ledger_entries" (
    "id" uuid NOT NULL,
    "transaction_id" uuid NOT NULL,
    "account_id" uuid NOT NULL,
    "cost_center_id" uuid,
    "direction_concept_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid,
    "fx_rate" numeric,
    "amount_base" numeric,
    "line_no" integer NOT NULL,
    "memo" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ledger_entries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."transaction_files" (
    "id" uuid NOT NULL,
    "transaction_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "category_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_transaction_files" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."sales" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "transaction_id" uuid,
    "customer_type_concept_id" uuid,
    "customer_id" uuid,
    "invoice_id" uuid,
    "sale_date" date NOT NULL,
    "subtotal" numeric,
    "tax_total" numeric,
    "total" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_sales" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."purchases" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "transaction_id" uuid,
    "vendor_id" uuid,
    "bill_id" uuid,
    "purchase_date" date NOT NULL,
    "subtotal" numeric,
    "tax_total" numeric,
    "total" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_purchases" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."assets" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "asset_type_concept_id" uuid,
    "account_id" uuid,
    "acquisition_date" date,
    "acquisition_cost" numeric,
    "depreciation_method_concept_id" uuid,
    "useful_life_months" integer,
    "salvage_value" numeric,
    "accumulated_depreciation" numeric,
    "book_value" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_assets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."asset_depreciations" (
    "id" uuid NOT NULL,
    "asset_id" uuid NOT NULL,
    "fiscal_period_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "book_value_after" numeric,
    "transaction_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_asset_depreciations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."liabilities" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "liability_type_concept_id" uuid,
    "account_id" uuid,
    "principal_amount" numeric,
    "outstanding_amount" numeric,
    "interest_rate" numeric,
    "start_date" date,
    "due_date" date,
    "creditor_name" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_liabilities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."liability_payments" (
    "id" uuid NOT NULL,
    "liability_id" uuid NOT NULL,
    "transaction_id" uuid,
    "amount" numeric NOT NULL,
    "principal_component" numeric,
    "interest_component" numeric,
    "paid_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_liability_payments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."infrastructure_items" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "category_concept_id" uuid NOT NULL,
    "asset_id" uuid,
    "branch_id" uuid,
    "location_text" varchar,
    "acquisition_cost" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_infrastructure_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."employee_payments" (
    "id" uuid NOT NULL,
    "employee_id" uuid NOT NULL,
    "fiscal_period_id" uuid,
    "transaction_id" uuid,
    "gross_amount" numeric NOT NULL,
    "deductions" numeric,
    "net_amount" numeric,
    "paid_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_employee_payments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."controlling_areas" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "operating_currency_concept_id" uuid NOT NULL,
    "fiscal_year_variant_code" varchar NOT NULL,
    "chart_of_accounts_code" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_controlling_areas" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."segments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_segment_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_segments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."functional_areas" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_functional_area_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_functional_areas" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."profit_centers" (
    "id" uuid NOT NULL,
    "controlling_area_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_profit_center_id" uuid,
    "segment_id" uuid,
    "responsible_employee_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_profit_centers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."internal_orders" (
    "id" uuid NOT NULL,
    "controlling_area_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "order_number" varchar NOT NULL,
    "name" varchar NOT NULL,
    "order_type_concept_id" uuid NOT NULL,
    "responsible_cost_center_id" uuid,
    "responsible_profit_center_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "start_date" date,
    "end_date" date,
    "budget_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_internal_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."company_bank_accounts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "account_id" uuid NOT NULL,
    "bank_name" varchar NOT NULL,
    "account_holder_name" varchar,
    "account_holder_tax_id" varchar,
    "bank_identifier_code" varchar,
    "iban_masked" varchar,
    "account_number_hash" varchar,
    "currency_concept_id" uuid NOT NULL,
    "branch_id" uuid,
    "clearing_account_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_company_bank_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."subledger_accounts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "business_partner_id" uuid NOT NULL,
    "subledger_role_concept_id" uuid NOT NULL,
    "reconciliation_account_id" uuid NOT NULL,
    "currency_concept_id" uuid,
    "payment_terms_concept_id" uuid,
    "dunning_procedure_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_subledger_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."journal_entry_assignments" (
    "id" uuid NOT NULL,
    "ledger_entry_id" uuid NOT NULL,
    "branch_id" uuid,
    "department_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "functional_area_id" uuid,
    "segment_id" uuid,
    "internal_order_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "business_partner_id" uuid,
    "subledger_account_id" uuid,
    "asset_id" uuid,
    "asset_component_id" uuid,
    "liability_id" uuid,
    "contract_id" uuid,
    "invoice_id" uuid,
    "bill_id" uuid,
    "purchase_order_item_id" uuid,
    "goods_receipt_item_id" uuid,
    "sales_order_item_id" uuid,
    "payment_transaction_id" uuid,
    "company_bank_account_id" uuid,
    "employee_id" uuid,
    "assignment_source_concept_id" uuid,
    "derived_by_rule_id" uuid,
    "is_statistical" boolean,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_journal_entry_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."account_determination_rules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "posting_scenario_concept_id" uuid NOT NULL,
    "account_role_concept_id" uuid NOT NULL,
    "source_type_concept_id" uuid,
    "asset_class_id" uuid,
    "liability_type_concept_id" uuid,
    "contract_type_concept_id" uuid,
    "tax_code_id" uuid,
    "service_concept_id" uuid,
    "target_account_id" uuid NOT NULL,
    "priority" integer,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_account_determination_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."accounting_document_links" (
    "id" uuid NOT NULL,
    "source_transaction_id" uuid NOT NULL,
    "target_transaction_id" uuid NOT NULL,
    "relation_type_concept_id" uuid NOT NULL,
    "source_line_id" uuid,
    "target_line_id" uuid,
    "effective_at" timestamptz,
    "reason_text" varchar,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_accounting_document_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."open_items" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "subledger_account_id" uuid NOT NULL,
    "ledger_entry_id" uuid NOT NULL,
    "document_type_concept_id" uuid NOT NULL,
    "document_number" varchar,
    "invoice_id" uuid,
    "bill_id" uuid,
    "contract_id" uuid,
    "baseline_date" date,
    "due_date" date,
    "original_amount" numeric,
    "outstanding_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_open_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."clearing_documents" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "clearing_number" varchar NOT NULL,
    "transaction_id" uuid NOT NULL,
    "clearing_date" date,
    "company_bank_account_id" uuid,
    "payment_transaction_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_clearing_documents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."clearing_items" (
    "id" uuid NOT NULL,
    "clearing_document_id" uuid NOT NULL,
    "open_item_id" uuid NOT NULL,
    "cleared_amount" numeric NOT NULL,
    "currency_concept_id" uuid,
    "residual_open_item_id" uuid,
    "discount_amount" numeric,
    "exchange_difference_amount" numeric,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_clearing_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."asset_classes" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "asset_type_concept_id" uuid,
    "acquisition_account_id" uuid,
    "accumulated_depreciation_account_id" uuid,
    "depreciation_expense_account_id" uuid,
    "gain_account_id" uuid,
    "loss_account_id" uuid,
    "default_useful_life_months" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_asset_classes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."asset_components" (
    "id" uuid NOT NULL,
    "asset_id" uuid NOT NULL,
    "component_number" varchar NOT NULL,
    "name" varchar NOT NULL,
    "asset_class_id" uuid,
    "acquisition_date" date,
    "acquisition_cost" numeric,
    "useful_life_months" integer,
    "salvage_value" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_asset_components" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."depreciation_areas" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "accounting_principle_concept_id" uuid NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "posts_to_general_ledger" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_depreciation_areas" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."asset_valuations" (
    "id" uuid NOT NULL,
    "asset_id" uuid NOT NULL,
    "asset_component_id" uuid,
    "depreciation_area_id" uuid NOT NULL,
    "depreciation_method_concept_id" uuid,
    "useful_life_months" integer,
    "salvage_value" numeric,
    "acquisition_value" numeric,
    "accumulated_depreciation" numeric,
    "book_value" numeric,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_asset_valuations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."asset_postings" (
    "id" uuid NOT NULL,
    "asset_id" uuid NOT NULL,
    "asset_component_id" uuid,
    "ledger_entry_id" uuid NOT NULL,
    "transaction_type_concept_id" uuid NOT NULL,
    "asset_value_date" date,
    "amount" numeric,
    "currency_concept_id" uuid,
    "quantity" numeric,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_asset_postings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."asset_assignments" (
    "id" uuid NOT NULL,
    "asset_id" uuid NOT NULL,
    "asset_component_id" uuid,
    "branch_id" uuid,
    "department_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "responsible_employee_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_asset_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."liability_schedules" (
    "id" uuid NOT NULL,
    "liability_id" uuid NOT NULL,
    "installment_number" integer NOT NULL,
    "due_date" date,
    "principal_due" numeric,
    "interest_due" numeric,
    "fee_due" numeric,
    "currency_concept_id" uuid,
    "paid_amount" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_liability_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."liability_postings" (
    "id" uuid NOT NULL,
    "liability_id" uuid NOT NULL,
    "liability_schedule_id" uuid,
    "ledger_entry_id" uuid NOT NULL,
    "component_concept_id" uuid NOT NULL,
    "amount" numeric,
    "currency_concept_id" uuid,
    "effective_date" date,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_liability_postings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."accrual_objects" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "object_number" varchar NOT NULL,
    "accrual_type_concept_id" uuid NOT NULL,
    "contract_id" uuid,
    "business_partner_id" uuid,
    "expense_account_id" uuid,
    "accrual_account_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "start_date" date,
    "end_date" date,
    "total_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_accrual_objects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."accrual_schedule_lines" (
    "id" uuid NOT NULL,
    "accrual_object_id" uuid NOT NULL,
    "fiscal_period_id" uuid NOT NULL,
    "planned_amount" numeric,
    "posted_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_accrual_schedule_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."accrual_postings" (
    "id" uuid NOT NULL,
    "accrual_schedule_line_id" uuid NOT NULL,
    "ledger_entry_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid,
    "posting_date" date,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_accrual_postings" PRIMARY KEY ("id")
);
