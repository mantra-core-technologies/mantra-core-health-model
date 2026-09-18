-- SALUD v4.0.10 · módulo 17 · schema billing
-- Generado de diagram_17_billing.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "billing"."service_catalog" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description_text" text,
    "image_file_id" uuid,
    "service_concept_id" uuid,
    "default_price" numeric NOT NULL,
    "currency_concept_id" uuid,
    "tax_code_id" uuid,
    "income_account_id" uuid,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_catalog" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."invoices" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "invoice_number" varchar NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "issue_date" date NOT NULL,
    "due_date" date,
    "status_concept_id" uuid NOT NULL,
    "subtotal" numeric,
    "tax_total" numeric,
    "discount_total" numeric,
    "total" numeric,
    "paid_total" numeric,
    "balance" numeric,
    "currency_concept_id" uuid,
    "customer_business_partner_id" uuid,
    "customer_subledger_account_id" uuid,
    "contract_id" uuid,
    "sales_order_id" uuid,
    "transaction_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_invoices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."invoice_lines" (
    "id" uuid NOT NULL,
    "invoice_id" uuid NOT NULL,
    "service_id" uuid,
    "description" varchar,
    "quantity" numeric NOT NULL,
    "unit_price" numeric NOT NULL,
    "discount" numeric,
    "tax_code_id" uuid,
    "tax_amount" numeric,
    "line_total" numeric,
    "income_account_id" uuid,
    "cost_center_id" uuid,
    "contract_line_item_id" uuid,
    "sales_order_item_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_invoice_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."payments_received" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "invoice_id" uuid,
    "patient_profile_id" uuid,
    "amount" numeric NOT NULL,
    "method_concept_id" uuid NOT NULL,
    "received_at" timestamptz,
    "reference" varchar,
    "payment_transaction_id" uuid,
    "clearing_document_id" uuid,
    "company_bank_account_id" uuid,
    "transaction_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payments_received" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."patient_statements" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "opening_balance" numeric,
    "charges" numeric,
    "payments" numeric,
    "closing_balance" numeric,
    "generated_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_statements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."vendors" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "tax_id" varchar,
    "business_partner_id" uuid,
    "supplier_subledger_account_id" uuid,
    "contact_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_vendors" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."bills" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "vendor_id" uuid NOT NULL,
    "bill_number" varchar NOT NULL,
    "issue_date" date NOT NULL,
    "due_date" date,
    "status_concept_id" uuid NOT NULL,
    "subtotal" numeric,
    "tax_total" numeric,
    "total" numeric,
    "paid_total" numeric,
    "balance" numeric,
    "currency_concept_id" uuid,
    "supplier_business_partner_id" uuid,
    "supplier_subledger_account_id" uuid,
    "contract_id" uuid,
    "purchase_order_id" uuid,
    "transaction_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_bills" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."bill_lines" (
    "id" uuid NOT NULL,
    "bill_id" uuid NOT NULL,
    "description" varchar,
    "quantity" numeric NOT NULL,
    "unit_price" numeric NOT NULL,
    "tax_amount" numeric,
    "line_total" numeric,
    "expense_account_id" uuid,
    "cost_center_id" uuid,
    "contract_line_item_id" uuid,
    "purchase_order_item_id" uuid,
    "goods_receipt_item_id" uuid,
    "service_entry_item_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_bill_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."payments_made" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "bill_id" uuid,
    "vendor_id" uuid,
    "amount" numeric NOT NULL,
    "method_concept_id" uuid NOT NULL,
    "paid_at" timestamptz,
    "payment_transaction_id" uuid,
    "clearing_document_id" uuid,
    "company_bank_account_id" uuid,
    "transaction_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payments_made" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."reimbursements" (
    "id" uuid NOT NULL,
    "claim_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "received_at" timestamptz,
    "transaction_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_reimbursements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."tax_codes" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "tax_type_concept_id" uuid NOT NULL,
    "rate_percent" numeric NOT NULL,
    "jurisdiction_concept_id" uuid,
    "account_id" uuid,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tax_codes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."tax_periods" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "filed_at" timestamptz,
    "total_due" numeric,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tax_periods" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."budgets" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "fiscal_year_id" uuid,
    "name" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_budgets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."budget_lines" (
    "id" uuid NOT NULL,
    "budget_id" uuid NOT NULL,
    "account_id" uuid NOT NULL,
    "cost_center_id" uuid,
    "fiscal_period_id" uuid,
    "amount" numeric NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_budget_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."financial_kpi_snapshots" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "fiscal_period_id" uuid,
    "kpi_code" varchar NOT NULL,
    "value_numeric" numeric NOT NULL,
    "dimension_json" jsonb,
    "computed_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_financial_kpi_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."receivable_payment_allocations" (
    "id" uuid NOT NULL,
    "payment_received_id" uuid NOT NULL,
    "invoice_id" uuid NOT NULL,
    "open_item_id" uuid,
    "clearing_item_id" uuid,
    "allocated_amount" numeric NOT NULL,
    "discount_amount" numeric,
    "write_off_amount" numeric,
    "currency_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_receivable_payment_allocations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."payable_payment_allocations" (
    "id" uuid NOT NULL,
    "payment_made_id" uuid NOT NULL,
    "bill_id" uuid NOT NULL,
    "open_item_id" uuid,
    "clearing_item_id" uuid,
    "allocated_amount" numeric NOT NULL,
    "discount_amount" numeric,
    "withholding_amount" numeric,
    "currency_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_payable_payment_allocations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."billing_document_links" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "invoice_id" uuid,
    "bill_id" uuid,
    "contract_id" uuid,
    "sales_order_id" uuid,
    "purchase_order_id" uuid,
    "claim_id" uuid,
    "encounter_id" uuid,
    "relation_type_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_billing_document_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."dunning_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "run_number" varchar NOT NULL,
    "run_date" date,
    "dunning_level_concept_id" uuid,
    "company_bank_account_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_dunning_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."dunning_items" (
    "id" uuid NOT NULL,
    "dunning_run_id" uuid NOT NULL,
    "invoice_id" uuid NOT NULL,
    "open_item_id" uuid,
    "business_partner_id" uuid,
    "outstanding_amount" numeric,
    "currency_concept_id" uuid,
    "days_overdue" integer,
    "dunning_fee" numeric,
    "notice_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_dunning_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."quotations" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "created_by_practitioner_profile_id" uuid NOT NULL,
    "attention_date" date NOT NULL,
    "appointment_id" uuid,
    "service_catalog_id" uuid NOT NULL,
    "service_name_snapshot" varchar NOT NULL,
    "offered_price" numeric NOT NULL,
    "currency_concept_id" uuid,
    "payment_plan_installment_count" integer NOT NULL,
    "down_payment_amount" numeric NOT NULL,
    "payment_frequency" varchar NOT NULL,
    "valid_until" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quotations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."quotation_installments" (
    "id" uuid NOT NULL,
    "quotation_id" uuid NOT NULL,
    "installment_number" integer NOT NULL,
    "due_date" date NOT NULL,
    "amount" numeric NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quotation_installments" PRIMARY KEY ("id")
);
