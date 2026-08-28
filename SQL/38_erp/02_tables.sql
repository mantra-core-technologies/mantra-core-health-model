-- SALUD v4.0.10 · módulo 38 · schema erp
-- Generado de diagram_38_erp.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "erp"."employees" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "person_user_id" uuid,
    "full_name" varchar NOT NULL,
    "role_concept_id" uuid,
    "hire_date" date,
    "base_salary" numeric,
    "currency_concept_id" uuid,
    "payment_method_concept_id" uuid,
    "business_partner_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_employees" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."departments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_department_id" uuid,
    "manager_employee_id" uuid,
    "cost_center_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_departments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."positions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "department_id" uuid,
    "job_family_concept_id" uuid,
    "grade_concept_id" uuid,
    "is_managerial" boolean,
    "headcount_budget" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_positions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."employment_records" (
    "id" uuid NOT NULL,
    "employee_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "position_id" uuid,
    "department_id" uuid,
    "employment_type_concept_id" uuid NOT NULL,
    "manager_employee_id" uuid,
    "start_date" date NOT NULL,
    "end_date" date,
    "fte_ratio" numeric,
    "base_salary" numeric,
    "currency_concept_id" uuid,
    "contract_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_employment_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."employee_assignments" (
    "id" uuid NOT NULL,
    "employment_record_id" uuid NOT NULL,
    "assignment_type_concept_id" uuid NOT NULL,
    "practice_id" uuid,
    "branch_id" uuid,
    "department_id" uuid,
    "allocation_percent" numeric,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_employee_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."time_off_requests" (
    "id" uuid NOT NULL,
    "employee_id" uuid NOT NULL,
    "leave_type_concept_id" uuid NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "hours" numeric,
    "reason" varchar,
    "approver_user_id" uuid,
    "approved_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_time_off_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."performance_reviews" (
    "id" uuid NOT NULL,
    "employee_id" uuid NOT NULL,
    "reviewer_employee_id" uuid,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "rating_concept_id" uuid,
    "score" numeric,
    "summary_text" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_performance_reviews" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contracts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "contract_number" varchar NOT NULL,
    "contract_type_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "counterparty_type_concept_id" uuid NOT NULL,
    "counterparty_ref_type" varchar,
    "counterparty_ref_id" uuid,
    "counterparty_name" varchar,
    "start_date" date NOT NULL,
    "end_date" date,
    "renewal_type_concept_id" uuid,
    "notice_period_days" integer,
    "total_value" numeric,
    "currency_concept_id" uuid,
    "governing_jurisdiction_concept_id" uuid,
    "owner_user_id" uuid,
    "primary_business_partner_id" uuid,
    "current_version_id" uuid,
    "parent_contract_id" uuid,
    "master_agreement_id" uuid,
    "owning_department_id" uuid,
    "owning_cost_center_id" uuid,
    "owning_profit_center_id" uuid,
    "approval_status_concept_id" uuid,
    "signature_status_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contracts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_parties" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "party_role_concept_id" uuid NOT NULL,
    "party_type_concept_id" uuid NOT NULL,
    "party_ref_type" varchar,
    "party_ref_id" uuid,
    "party_name" varchar,
    "signatory_user_id" uuid,
    "signed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_parties" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_line_items" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "description" varchar NOT NULL,
    "service_concept_id" uuid,
    "quantity" numeric,
    "unit_price" numeric,
    "currency_concept_id" uuid,
    "recurrence_concept_id" uuid,
    "account_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_line_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_milestones" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "due_date" date,
    "amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "completed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_milestones" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_documents" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "document_type_concept_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "version" integer,
    "is_signed" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_documents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."business_partners" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "partner_number" varchar NOT NULL,
    "partner_category_concept_id" uuid NOT NULL,
    "display_name" varchar NOT NULL,
    "legal_name" varchar,
    "tax_id" varchar,
    "country_concept_id" uuid,
    "linked_tenant_id" uuid,
    "linked_person_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_business_partners" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."business_partner_roles" (
    "id" uuid NOT NULL,
    "business_partner_id" uuid NOT NULL,
    "role_concept_id" uuid NOT NULL,
    "company_code_tenant_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_business_partner_roles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."business_partner_relationships" (
    "id" uuid NOT NULL,
    "source_business_partner_id" uuid NOT NULL,
    "target_business_partner_id" uuid NOT NULL,
    "relationship_type_concept_id" uuid NOT NULL,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_business_partner_relationships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."business_partner_tax_registrations" (
    "id" uuid NOT NULL,
    "business_partner_id" uuid NOT NULL,
    "tax_type_concept_id" uuid NOT NULL,
    "tax_number" varchar NOT NULL,
    "country_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "is_primary" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_business_partner_tax_registrations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."business_partner_bank_accounts" (
    "id" uuid NOT NULL,
    "business_partner_id" uuid NOT NULL,
    "bank_name" varchar NOT NULL,
    "account_holder_name" varchar,
    "account_holder_tax_id" varchar,
    "bank_identifier_code" varchar,
    "iban_masked" varchar,
    "account_number_hash" varchar,
    "currency_concept_id" uuid,
    "is_primary" boolean,
    "verification_status_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_business_partner_bank_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."projects" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "project_number" varchar NOT NULL,
    "name" varchar NOT NULL,
    "project_type_concept_id" uuid,
    "responsible_employee_id" uuid,
    "department_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
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
    CONSTRAINT "pk_projects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."wbs_elements" (
    "id" uuid NOT NULL,
    "project_id" uuid NOT NULL,
    "parent_wbs_element_id" uuid,
    "wbs_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "responsible_employee_id" uuid,
    "start_date" date,
    "end_date" date,
    "budget_amount" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_wbs_elements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."purchase_requisitions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "requisition_number" varchar NOT NULL,
    "requester_employee_id" uuid,
    "requesting_department_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "required_by_date" date,
    "approval_status_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_purchase_requisitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."purchase_requisition_items" (
    "id" uuid NOT NULL,
    "purchase_requisition_id" uuid NOT NULL,
    "line_number" integer NOT NULL,
    "item_type_concept_id" uuid,
    "description" varchar,
    "product_ref_type" varchar,
    "product_ref_id" uuid,
    "quantity" numeric,
    "unit_concept_id" uuid,
    "estimated_unit_price" numeric,
    "currency_concept_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "asset_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_purchase_requisition_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."purchase_orders" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "purchase_order_number" varchar NOT NULL,
    "supplier_business_partner_id" uuid NOT NULL,
    "contract_id" uuid,
    "purchase_requisition_id" uuid,
    "ordering_department_id" uuid,
    "buyer_employee_id" uuid,
    "order_date" date,
    "expected_delivery_date" date,
    "currency_concept_id" uuid,
    "payment_terms_concept_id" uuid,
    "incoterm_concept_id" uuid,
    "approval_status_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_purchase_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."purchase_order_items" (
    "id" uuid NOT NULL,
    "purchase_order_id" uuid NOT NULL,
    "line_number" integer NOT NULL,
    "purchase_requisition_item_id" uuid,
    "contract_line_item_id" uuid,
    "item_type_concept_id" uuid,
    "description" varchar,
    "product_ref_type" varchar,
    "product_ref_id" uuid,
    "quantity" numeric,
    "unit_concept_id" uuid,
    "unit_price" numeric,
    "tax_code_id" uuid,
    "expense_account_id" uuid,
    "inventory_account_id" uuid,
    "asset_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "branch_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_purchase_order_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."goods_receipts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "receipt_number" varchar NOT NULL,
    "purchase_order_id" uuid NOT NULL,
    "receiving_branch_id" uuid,
    "received_by_employee_id" uuid,
    "received_at" timestamptz,
    "supplier_delivery_reference" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_goods_receipts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."goods_receipt_items" (
    "id" uuid NOT NULL,
    "goods_receipt_id" uuid NOT NULL,
    "purchase_order_item_id" uuid NOT NULL,
    "line_number" integer NOT NULL,
    "received_quantity" numeric,
    "accepted_quantity" numeric,
    "rejected_quantity" numeric,
    "inventory_ledger_entry_id" uuid,
    "asset_id" uuid,
    "quality_status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_goods_receipt_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."service_entry_sheets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "sheet_number" varchar NOT NULL,
    "purchase_order_id" uuid NOT NULL,
    "supplier_business_partner_id" uuid,
    "performed_from" date,
    "performed_to" date,
    "accepted_by_employee_id" uuid,
    "approval_status_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_entry_sheets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."service_entry_items" (
    "id" uuid NOT NULL,
    "service_entry_sheet_id" uuid NOT NULL,
    "purchase_order_item_id" uuid NOT NULL,
    "line_number" integer NOT NULL,
    "accepted_quantity" numeric,
    "accepted_amount" numeric,
    "currency_concept_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_entry_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."invoice_match_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "bill_id" uuid NOT NULL,
    "match_type_concept_id" uuid NOT NULL,
    "purchase_order_id" uuid,
    "run_at" timestamptz,
    "matched_amount" numeric,
    "variance_amount" numeric,
    "currency_concept_id" uuid,
    "result_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_invoice_match_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."invoice_match_items" (
    "id" uuid NOT NULL,
    "invoice_match_run_id" uuid NOT NULL,
    "bill_line_id" uuid NOT NULL,
    "purchase_order_item_id" uuid,
    "goods_receipt_item_id" uuid,
    "service_entry_item_id" uuid,
    "invoice_quantity" numeric,
    "ordered_quantity" numeric,
    "received_quantity" numeric,
    "invoice_amount" numeric,
    "ordered_amount" numeric,
    "variance_quantity" numeric,
    "variance_amount" numeric,
    "tolerance_rule_concept_id" uuid,
    "result_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_invoice_match_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."sales_orders" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "sales_order_number" varchar NOT NULL,
    "customer_business_partner_id" uuid NOT NULL,
    "contract_id" uuid,
    "opportunity_id" uuid,
    "order_date" date,
    "requested_service_date" date,
    "currency_concept_id" uuid,
    "payment_terms_concept_id" uuid,
    "owner_employee_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_sales_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."sales_order_items" (
    "id" uuid NOT NULL,
    "sales_order_id" uuid NOT NULL,
    "line_number" integer NOT NULL,
    "contract_line_item_id" uuid,
    "service_ref_type" varchar,
    "service_ref_id" uuid,
    "description" varchar,
    "quantity" numeric,
    "unit_price" numeric,
    "tax_code_id" uuid,
    "income_account_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_sales_order_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."enterprise_document_flow" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "predecessor_type_concept_id" uuid NOT NULL,
    "predecessor_id" uuid NOT NULL,
    "successor_type_concept_id" uuid NOT NULL,
    "successor_id" uuid NOT NULL,
    "relation_type_concept_id" uuid NOT NULL,
    "quantity" numeric,
    "amount" numeric,
    "currency_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_enterprise_document_flow" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_versions" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "version_type_concept_id" uuid NOT NULL,
    "effective_from" date,
    "effective_to" date,
    "summary_text" text,
    "main_document_file_id" uuid,
    "content_hash" varchar,
    "approved_at" timestamptz,
    "approved_by_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_contract_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_amendments" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "base_version_id" uuid NOT NULL,
    "resulting_version_id" uuid,
    "amendment_type_concept_id" uuid NOT NULL,
    "reason_text" text,
    "effective_date" date,
    "requested_by_user_id" uuid,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_amendments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_clauses" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "clause_code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "clause_type_concept_id" uuid NOT NULL,
    "default_text" text,
    "risk_level_concept_id" uuid,
    "requires_approval" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_clauses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_clause_instances" (
    "id" uuid NOT NULL,
    "contract_version_id" uuid NOT NULL,
    "contract_clause_id" uuid NOT NULL,
    "ordinal" integer,
    "rendered_text" text,
    "deviation_type_concept_id" uuid,
    "approval_required" boolean,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_clause_instances" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_obligations" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "contract_version_id" uuid,
    "contract_clause_instance_id" uuid,
    "obligation_type_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "responsible_business_partner_id" uuid,
    "responsible_user_id" uuid,
    "due_date" date,
    "recurrence_rule" varchar,
    "financial_amount" numeric,
    "currency_concept_id" uuid,
    "evidence_required" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_obligations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_obligation_events" (
    "id" uuid NOT NULL,
    "contract_obligation_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "event_at" timestamptz,
    "evidence_file_id" uuid,
    "outcome_concept_id" uuid,
    "notes" text,
    "recorded_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_contract_obligation_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_renewals" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "renewal_type_concept_id" uuid NOT NULL,
    "notice_due_date" date,
    "renewal_effective_date" date,
    "new_end_date" date,
    "proposed_value" numeric,
    "currency_concept_id" uuid,
    "initiated_by_user_id" uuid,
    "decision_by_user_id" uuid,
    "decision_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_renewals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_terminations" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "termination_type_concept_id" uuid NOT NULL,
    "notice_date" date,
    "effective_date" date,
    "reason_text" text,
    "initiated_by_user_id" uuid,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "settlement_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_terminations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_team_members" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "team_role_concept_id" uuid NOT NULL,
    "responsibility_scope_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_contract_team_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_approval_requests" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "contract_version_id" uuid,
    "contract_amendment_id" uuid,
    "approval_type_concept_id" uuid NOT NULL,
    "requested_by_user_id" uuid,
    "requested_at" timestamptz,
    "due_at" timestamptz,
    "workflow_instance_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_contract_approval_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_approval_steps" (
    "id" uuid NOT NULL,
    "contract_approval_request_id" uuid NOT NULL,
    "step_number" integer NOT NULL,
    "approver_user_id" uuid,
    "approver_team_role_concept_id" uuid,
    "decision_concept_id" uuid,
    "decision_at" timestamptz,
    "comments" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_contract_approval_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_object_assignments" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "contract_line_item_id" uuid,
    "assignment_role_concept_id" uuid NOT NULL,
    "business_partner_id" uuid,
    "asset_id" uuid,
    "liability_id" uuid,
    "project_id" uuid,
    "wbs_element_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "purchase_order_id" uuid,
    "sales_order_id" uuid,
    "employee_id" uuid,
    "practice_id" uuid,
    "branch_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_object_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_accounting_terms" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "contract_line_item_id" uuid,
    "accounting_treatment_concept_id" uuid NOT NULL,
    "expense_account_id" uuid,
    "revenue_account_id" uuid,
    "accrual_account_id" uuid,
    "asset_account_id" uuid,
    "liability_account_id" uuid,
    "cost_center_id" uuid,
    "profit_center_id" uuid,
    "tax_code_id" uuid,
    "effective_from" date,
    "effective_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_accounting_terms" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."contract_payment_schedules" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "contract_line_item_id" uuid,
    "contract_obligation_id" uuid,
    "installment_number" integer NOT NULL,
    "due_date" date,
    "amount" numeric,
    "currency_concept_id" uuid,
    "payment_direction_concept_id" uuid,
    "invoice_id" uuid,
    "bill_id" uuid,
    "payment_transaction_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contract_payment_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."lease_contracts" (
    "id" uuid NOT NULL,
    "contract_id" uuid NOT NULL,
    "lease_role_concept_id" uuid NOT NULL,
    "commencement_date" date NOT NULL,
    "end_date" date,
    "discount_rate" numeric,
    "accounting_principle_concept_id" uuid,
    "currency_concept_id" uuid,
    "short_term_exemption" boolean,
    "low_value_exemption" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lease_contracts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."lease_objects" (
    "id" uuid NOT NULL,
    "lease_contract_id" uuid NOT NULL,
    "object_type_concept_id" uuid NOT NULL,
    "description" varchar,
    "source_asset_id" uuid,
    "branch_id" uuid,
    "quantity" numeric,
    "unit_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lease_objects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."lease_cash_flows" (
    "id" uuid NOT NULL,
    "lease_contract_id" uuid NOT NULL,
    "lease_object_id" uuid,
    "flow_type_concept_id" uuid NOT NULL,
    "due_date" date,
    "amount" numeric,
    "currency_concept_id" uuid,
    "index_reference_concept_id" uuid,
    "is_fixed" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lease_cash_flows" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."lease_valuations" (
    "id" uuid NOT NULL,
    "lease_contract_id" uuid NOT NULL,
    "valuation_date" date NOT NULL,
    "accounting_principle_concept_id" uuid,
    "right_of_use_asset_value" numeric,
    "lease_liability_value" numeric,
    "interest_expense" numeric,
    "depreciation_expense" numeric,
    "currency_concept_id" uuid,
    "journal_transaction_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_lease_valuations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "erp"."lease_accounting_links" (
    "id" uuid NOT NULL,
    "lease_contract_id" uuid NOT NULL,
    "lease_object_id" uuid,
    "right_of_use_asset_id" uuid NOT NULL,
    "lease_liability_id" uuid NOT NULL,
    "right_of_use_asset_account_id" uuid,
    "lease_liability_account_id" uuid,
    "interest_expense_account_id" uuid,
    "depreciation_expense_account_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lease_accounting_links" PRIMARY KEY ("id")
);
