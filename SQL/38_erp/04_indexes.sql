-- SALUD v4.0.10 · módulo 38 · schema erp
-- Generado de diagram_38_erp.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_business_partners_tenant_id_partner_number" ON "erp"."business_partners" ("tenant_id", "partner_number");

CREATE INDEX IF NOT EXISTS "ix_business_partners_tenant_id" ON "erp"."business_partners" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_partner_category_concept_id" ON "erp"."business_partners" ("partner_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_country_concept_id" ON "erp"."business_partners" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_linked_tenant_id" ON "erp"."business_partners" ("linked_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_linked_person_id" ON "erp"."business_partners" ("linked_person_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_status_concept_id" ON "erp"."business_partners" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_created_by_user_id" ON "erp"."business_partners" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_updated_by_user_id" ON "erp"."business_partners" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partners_tenant_status_updated" ON "erp"."business_partners" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_business_partners_search" ON "erp"."business_partners" USING gin (to_tsvector('simple', (coalesce(partner_number, '') || ' ' || coalesce(display_name, '') || ' ' || coalesce(legal_name, '') || ' ' || coalesce(tax_id, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_business_partner_roles_business_partner_id_role_con_4a8deccf" ON "erp"."business_partner_roles" ("business_partner_id", "role_concept_id", "company_code_tenant_id", "valid_from");

CREATE INDEX IF NOT EXISTS "ix_business_partner_roles_business_partner_id" ON "erp"."business_partner_roles" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_roles_role_concept_id" ON "erp"."business_partner_roles" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_roles_company_code_tenant_id" ON "erp"."business_partner_roles" ("company_code_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_roles_status_concept_id" ON "erp"."business_partner_roles" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_roles_created_by_user_id" ON "erp"."business_partner_roles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_roles_updated_by_user_id" ON "erp"."business_partner_roles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_relationships_source_business_partner_id" ON "erp"."business_partner_relationships" ("source_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_relationships_target_business_partner_id" ON "erp"."business_partner_relationships" ("target_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_relationships_relationship_type_concept_id" ON "erp"."business_partner_relationships" ("relationship_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_relationships_status_concept_id" ON "erp"."business_partner_relationships" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_relationships_created_by_user_id" ON "erp"."business_partner_relationships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_relationships_updated_by_user_id" ON "erp"."business_partner_relationships" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_relationships_source_type_valid" ON "erp"."business_partner_relationships" ("source_business_partner_id", "relationship_type_concept_id", "valid_from");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_business_partner_tax_registrations_business_partner_91eeddc3" ON "erp"."business_partner_tax_registrations" ("business_partner_id", "tax_type_concept_id", "tax_number");

CREATE INDEX IF NOT EXISTS "ix_business_partner_tax_registrations_business_partner_id" ON "erp"."business_partner_tax_registrations" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_tax_registrations_tax_type_concept_id" ON "erp"."business_partner_tax_registrations" ("tax_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_tax_registrations_country_concept_id" ON "erp"."business_partner_tax_registrations" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_tax_registrations_created_by_user_id" ON "erp"."business_partner_tax_registrations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_tax_registrations_updated_by_user_id" ON "erp"."business_partner_tax_registrations" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_business_partner_bank_accounts_business_partner_id__0b2a44a3" ON "erp"."business_partner_bank_accounts" ("business_partner_id", "account_number_hash");

CREATE INDEX IF NOT EXISTS "ix_business_partner_bank_accounts_business_partner_id" ON "erp"."business_partner_bank_accounts" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_bank_accounts_currency_concept_id" ON "erp"."business_partner_bank_accounts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_bank_accounts_verification_status__14f1d2aa" ON "erp"."business_partner_bank_accounts" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_bank_accounts_status_concept_id" ON "erp"."business_partner_bank_accounts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_bank_accounts_created_by_user_id" ON "erp"."business_partner_bank_accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_partner_bank_accounts_updated_by_user_id" ON "erp"."business_partner_bank_accounts" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_projects_tenant_id_project_number" ON "erp"."projects" ("tenant_id", "project_number");

CREATE INDEX IF NOT EXISTS "ix_projects_tenant_id" ON "erp"."projects" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_projects_project_type_concept_id" ON "erp"."projects" ("project_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_projects_responsible_employee_id" ON "erp"."projects" ("responsible_employee_id");

CREATE INDEX IF NOT EXISTS "ix_projects_department_id" ON "erp"."projects" ("department_id");

CREATE INDEX IF NOT EXISTS "ix_projects_cost_center_id" ON "erp"."projects" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_projects_profit_center_id" ON "erp"."projects" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_projects_currency_concept_id" ON "erp"."projects" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_projects_status_concept_id" ON "erp"."projects" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_projects_created_by_user_id" ON "erp"."projects" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_projects_updated_by_user_id" ON "erp"."projects" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_projects_search" ON "erp"."projects" USING gin (to_tsvector('simple', (coalesce(project_number, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_wbs_elements_project_id_wbs_code" ON "erp"."wbs_elements" ("project_id", "wbs_code");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_project_id" ON "erp"."wbs_elements" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_parent_wbs_element_id" ON "erp"."wbs_elements" ("parent_wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_cost_center_id" ON "erp"."wbs_elements" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_profit_center_id" ON "erp"."wbs_elements" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_responsible_employee_id" ON "erp"."wbs_elements" ("responsible_employee_id");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_status_concept_id" ON "erp"."wbs_elements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_created_by_user_id" ON "erp"."wbs_elements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_wbs_elements_updated_by_user_id" ON "erp"."wbs_elements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_wbs_elements_search" ON "erp"."wbs_elements" USING gin (to_tsvector('simple', (coalesce(wbs_code, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_purchase_requisitions_tenant_id_requisition_number" ON "erp"."purchase_requisitions" ("tenant_id", "requisition_number");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_tenant_id" ON "erp"."purchase_requisitions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_requester_employee_id" ON "erp"."purchase_requisitions" ("requester_employee_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_requesting_department_id" ON "erp"."purchase_requisitions" ("requesting_department_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_project_id" ON "erp"."purchase_requisitions" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_wbs_element_id" ON "erp"."purchase_requisitions" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_approval_status_concept_id" ON "erp"."purchase_requisitions" ("approval_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_status_concept_id" ON "erp"."purchase_requisitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_created_by_user_id" ON "erp"."purchase_requisitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_updated_by_user_id" ON "erp"."purchase_requisitions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisitions_tenant_status_updated" ON "erp"."purchase_requisitions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_purchase_requisitions_search" ON "erp"."purchase_requisitions" USING gin (to_tsvector('simple', (coalesce(requisition_number, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_purchase_requisition_items_purchase_requisition_id__283ecf3d" ON "erp"."purchase_requisition_items" ("purchase_requisition_id", "line_number");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_purchase_requisition_id" ON "erp"."purchase_requisition_items" ("purchase_requisition_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_item_type_concept_id" ON "erp"."purchase_requisition_items" ("item_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_unit_concept_id" ON "erp"."purchase_requisition_items" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_currency_concept_id" ON "erp"."purchase_requisition_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_cost_center_id" ON "erp"."purchase_requisition_items" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_profit_center_id" ON "erp"."purchase_requisition_items" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_project_id" ON "erp"."purchase_requisition_items" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_wbs_element_id" ON "erp"."purchase_requisition_items" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_asset_id" ON "erp"."purchase_requisition_items" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_status_concept_id" ON "erp"."purchase_requisition_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_created_by_user_id" ON "erp"."purchase_requisition_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_requisition_items_updated_by_user_id" ON "erp"."purchase_requisition_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_purchase_orders_tenant_id_purchase_order_number" ON "erp"."purchase_orders" ("tenant_id", "purchase_order_number");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_tenant_id" ON "erp"."purchase_orders" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_supplier_business_partner_id" ON "erp"."purchase_orders" ("supplier_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_contract_id" ON "erp"."purchase_orders" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_purchase_requisition_id" ON "erp"."purchase_orders" ("purchase_requisition_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_ordering_department_id" ON "erp"."purchase_orders" ("ordering_department_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_buyer_employee_id" ON "erp"."purchase_orders" ("buyer_employee_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_currency_concept_id" ON "erp"."purchase_orders" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_payment_terms_concept_id" ON "erp"."purchase_orders" ("payment_terms_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_incoterm_concept_id" ON "erp"."purchase_orders" ("incoterm_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_approval_status_concept_id" ON "erp"."purchase_orders" ("approval_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_status_concept_id" ON "erp"."purchase_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_created_by_user_id" ON "erp"."purchase_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_updated_by_user_id" ON "erp"."purchase_orders" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_orders_tenant_status_updated" ON "erp"."purchase_orders" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_purchase_orders_search" ON "erp"."purchase_orders" USING gin (to_tsvector('simple', (coalesce(purchase_order_number, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_purchase_order_items_purchase_order_id_line_number" ON "erp"."purchase_order_items" ("purchase_order_id", "line_number");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_purchase_order_id" ON "erp"."purchase_order_items" ("purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_purchase_requisition_item_id" ON "erp"."purchase_order_items" ("purchase_requisition_item_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_contract_line_item_id" ON "erp"."purchase_order_items" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_item_type_concept_id" ON "erp"."purchase_order_items" ("item_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_unit_concept_id" ON "erp"."purchase_order_items" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_tax_code_id" ON "erp"."purchase_order_items" ("tax_code_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_expense_account_id" ON "erp"."purchase_order_items" ("expense_account_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_inventory_account_id" ON "erp"."purchase_order_items" ("inventory_account_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_asset_id" ON "erp"."purchase_order_items" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_cost_center_id" ON "erp"."purchase_order_items" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_profit_center_id" ON "erp"."purchase_order_items" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_project_id" ON "erp"."purchase_order_items" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_wbs_element_id" ON "erp"."purchase_order_items" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_branch_id" ON "erp"."purchase_order_items" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_status_concept_id" ON "erp"."purchase_order_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_created_by_user_id" ON "erp"."purchase_order_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchase_order_items_updated_by_user_id" ON "erp"."purchase_order_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_goods_receipts_tenant_id_receipt_number" ON "erp"."goods_receipts" ("tenant_id", "receipt_number");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_tenant_id" ON "erp"."goods_receipts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_purchase_order_id" ON "erp"."goods_receipts" ("purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_receiving_branch_id" ON "erp"."goods_receipts" ("receiving_branch_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_received_by_employee_id" ON "erp"."goods_receipts" ("received_by_employee_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_status_concept_id" ON "erp"."goods_receipts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_created_by_user_id" ON "erp"."goods_receipts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_updated_by_user_id" ON "erp"."goods_receipts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipts_tenant_status_updated" ON "erp"."goods_receipts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_goods_receipts_search" ON "erp"."goods_receipts" USING gin (to_tsvector('simple', (coalesce(receipt_number, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_goods_receipt_items_goods_receipt_id_line_number" ON "erp"."goods_receipt_items" ("goods_receipt_id", "line_number");

CREATE INDEX IF NOT EXISTS "ix_goods_receipt_items_goods_receipt_id" ON "erp"."goods_receipt_items" ("goods_receipt_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipt_items_purchase_order_item_id" ON "erp"."goods_receipt_items" ("purchase_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipt_items_inventory_ledger_entry_id" ON "erp"."goods_receipt_items" ("inventory_ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipt_items_asset_id" ON "erp"."goods_receipt_items" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipt_items_quality_status_concept_id" ON "erp"."goods_receipt_items" ("quality_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipt_items_created_by_user_id" ON "erp"."goods_receipt_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_goods_receipt_items_updated_by_user_id" ON "erp"."goods_receipt_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_service_entry_sheets_tenant_id_sheet_number" ON "erp"."service_entry_sheets" ("tenant_id", "sheet_number");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_tenant_id" ON "erp"."service_entry_sheets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_purchase_order_id" ON "erp"."service_entry_sheets" ("purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_supplier_business_partner_id" ON "erp"."service_entry_sheets" ("supplier_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_accepted_by_employee_id" ON "erp"."service_entry_sheets" ("accepted_by_employee_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_approval_status_concept_id" ON "erp"."service_entry_sheets" ("approval_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_status_concept_id" ON "erp"."service_entry_sheets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_created_by_user_id" ON "erp"."service_entry_sheets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_updated_by_user_id" ON "erp"."service_entry_sheets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_sheets_tenant_status_updated" ON "erp"."service_entry_sheets" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_service_entry_sheets_search" ON "erp"."service_entry_sheets" USING gin (to_tsvector('simple', (coalesce(sheet_number, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_service_entry_items_service_entry_sheet_id_line_number" ON "erp"."service_entry_items" ("service_entry_sheet_id", "line_number");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_service_entry_sheet_id" ON "erp"."service_entry_items" ("service_entry_sheet_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_purchase_order_item_id" ON "erp"."service_entry_items" ("purchase_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_currency_concept_id" ON "erp"."service_entry_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_cost_center_id" ON "erp"."service_entry_items" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_profit_center_id" ON "erp"."service_entry_items" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_project_id" ON "erp"."service_entry_items" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_wbs_element_id" ON "erp"."service_entry_items" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_created_by_user_id" ON "erp"."service_entry_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_entry_items_updated_by_user_id" ON "erp"."service_entry_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_tenant_id" ON "erp"."invoice_match_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_bill_id" ON "erp"."invoice_match_runs" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_match_type_concept_id" ON "erp"."invoice_match_runs" ("match_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_purchase_order_id" ON "erp"."invoice_match_runs" ("purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_currency_concept_id" ON "erp"."invoice_match_runs" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_result_concept_id" ON "erp"."invoice_match_runs" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_status_concept_id" ON "erp"."invoice_match_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_created_by_user_id" ON "erp"."invoice_match_runs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_runs_tenant_status_run" ON "erp"."invoice_match_runs" ("tenant_id", "status_concept_id", "run_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_invoice_match_items_invoice_match_run_id_bill_line_id" ON "erp"."invoice_match_items" ("invoice_match_run_id", "bill_line_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_invoice_match_run_id" ON "erp"."invoice_match_items" ("invoice_match_run_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_bill_line_id" ON "erp"."invoice_match_items" ("bill_line_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_purchase_order_item_id" ON "erp"."invoice_match_items" ("purchase_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_goods_receipt_item_id" ON "erp"."invoice_match_items" ("goods_receipt_item_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_service_entry_item_id" ON "erp"."invoice_match_items" ("service_entry_item_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_tolerance_rule_concept_id" ON "erp"."invoice_match_items" ("tolerance_rule_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_result_concept_id" ON "erp"."invoice_match_items" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_invoice_match_items_created_by_user_id" ON "erp"."invoice_match_items" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sales_orders_tenant_id_sales_order_number" ON "erp"."sales_orders" ("tenant_id", "sales_order_number");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_tenant_id" ON "erp"."sales_orders" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_customer_business_partner_id" ON "erp"."sales_orders" ("customer_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_contract_id" ON "erp"."sales_orders" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_opportunity_id" ON "erp"."sales_orders" ("opportunity_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_currency_concept_id" ON "erp"."sales_orders" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_payment_terms_concept_id" ON "erp"."sales_orders" ("payment_terms_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_owner_employee_id" ON "erp"."sales_orders" ("owner_employee_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_status_concept_id" ON "erp"."sales_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_created_by_user_id" ON "erp"."sales_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_updated_by_user_id" ON "erp"."sales_orders" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sales_orders_tenant_status_updated" ON "erp"."sales_orders" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_sales_orders_search" ON "erp"."sales_orders" USING gin (to_tsvector('simple', (coalesce(sales_order_number, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sales_order_items_sales_order_id_line_number" ON "erp"."sales_order_items" ("sales_order_id", "line_number");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_sales_order_id" ON "erp"."sales_order_items" ("sales_order_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_contract_line_item_id" ON "erp"."sales_order_items" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_tax_code_id" ON "erp"."sales_order_items" ("tax_code_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_income_account_id" ON "erp"."sales_order_items" ("income_account_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_cost_center_id" ON "erp"."sales_order_items" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_profit_center_id" ON "erp"."sales_order_items" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_project_id" ON "erp"."sales_order_items" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_wbs_element_id" ON "erp"."sales_order_items" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_status_concept_id" ON "erp"."sales_order_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_created_by_user_id" ON "erp"."sales_order_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sales_order_items_updated_by_user_id" ON "erp"."sales_order_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_enterprise_document_flow_predecessor_type_concept_i_24f1d8d4" ON "erp"."enterprise_document_flow" ("predecessor_type_concept_id", "predecessor_id", "successor_type_concept_id", "successor_id", "relation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enterprise_document_flow_tenant_id" ON "erp"."enterprise_document_flow" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_enterprise_document_flow_predecessor_type_concept_id" ON "erp"."enterprise_document_flow" ("predecessor_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enterprise_document_flow_successor_type_concept_id" ON "erp"."enterprise_document_flow" ("successor_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enterprise_document_flow_relation_type_concept_id" ON "erp"."enterprise_document_flow" ("relation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enterprise_document_flow_currency_concept_id" ON "erp"."enterprise_document_flow" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enterprise_document_flow_created_by_user_id" ON "erp"."enterprise_document_flow" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_enterprise_document_flow_created_at" ON "erp"."enterprise_document_flow" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contract_versions_contract_id_version_number" ON "erp"."contract_versions" ("contract_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_contract_versions_contract_id" ON "erp"."contract_versions" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_versions_version_type_concept_id" ON "erp"."contract_versions" ("version_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_versions_main_document_file_id" ON "erp"."contract_versions" ("main_document_file_id");

CREATE INDEX IF NOT EXISTS "ix_contract_versions_approved_by_user_id" ON "erp"."contract_versions" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_versions_status_concept_id" ON "erp"."contract_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_versions_created_by_user_id" ON "erp"."contract_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_contract_id" ON "erp"."contract_amendments" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_base_version_id" ON "erp"."contract_amendments" ("base_version_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_resulting_version_id" ON "erp"."contract_amendments" ("resulting_version_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_amendment_type_concept_id" ON "erp"."contract_amendments" ("amendment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_requested_by_user_id" ON "erp"."contract_amendments" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_approved_by_user_id" ON "erp"."contract_amendments" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_status_concept_id" ON "erp"."contract_amendments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_created_by_user_id" ON "erp"."contract_amendments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_updated_by_user_id" ON "erp"."contract_amendments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_amendments_contract_status_effective" ON "erp"."contract_amendments" ("contract_id", "status_concept_id", "effective_date");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contract_clauses_tenant_id_clause_code" ON "erp"."contract_clauses" ("tenant_id", "clause_code");

CREATE INDEX IF NOT EXISTS "ix_contract_clauses_tenant_id" ON "erp"."contract_clauses" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clauses_clause_type_concept_id" ON "erp"."contract_clauses" ("clause_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clauses_risk_level_concept_id" ON "erp"."contract_clauses" ("risk_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clauses_status_concept_id" ON "erp"."contract_clauses" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clauses_created_by_user_id" ON "erp"."contract_clauses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clauses_updated_by_user_id" ON "erp"."contract_clauses" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_contract_clauses_search" ON "erp"."contract_clauses" USING gin (to_tsvector('simple', (coalesce(clause_code, '') || ' ' || coalesce(title, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contract_clause_instances_contract_version_id_contr_91a0f87f" ON "erp"."contract_clause_instances" ("contract_version_id", "contract_clause_id", "ordinal");

CREATE INDEX IF NOT EXISTS "ix_contract_clause_instances_contract_version_id" ON "erp"."contract_clause_instances" ("contract_version_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clause_instances_contract_clause_id" ON "erp"."contract_clause_instances" ("contract_clause_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clause_instances_deviation_type_concept_id" ON "erp"."contract_clause_instances" ("deviation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clause_instances_approved_by_user_id" ON "erp"."contract_clause_instances" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clause_instances_status_concept_id" ON "erp"."contract_clause_instances" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clause_instances_created_by_user_id" ON "erp"."contract_clause_instances" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_clause_instances_updated_by_user_id" ON "erp"."contract_clause_instances" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_contract_id" ON "erp"."contract_obligations" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_contract_version_id" ON "erp"."contract_obligations" ("contract_version_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_contract_clause_instance_id" ON "erp"."contract_obligations" ("contract_clause_instance_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_obligation_type_concept_id" ON "erp"."contract_obligations" ("obligation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_responsible_business_partner_id" ON "erp"."contract_obligations" ("responsible_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_responsible_user_id" ON "erp"."contract_obligations" ("responsible_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_currency_concept_id" ON "erp"."contract_obligations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_status_concept_id" ON "erp"."contract_obligations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_created_by_user_id" ON "erp"."contract_obligations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_updated_by_user_id" ON "erp"."contract_obligations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_contract_status_due" ON "erp"."contract_obligations" ("contract_id", "status_concept_id", "due_date");

CREATE INDEX IF NOT EXISTS "ix_contract_obligations_responsible_status_due" ON "erp"."contract_obligations" ("responsible_user_id", "status_concept_id", "due_date");

CREATE INDEX IF NOT EXISTS "gin_contract_obligations_search" ON "erp"."contract_obligations" USING gin (to_tsvector('simple', (coalesce(title, ''))));

CREATE INDEX IF NOT EXISTS "ix_contract_obligation_events_contract_obligation_id" ON "erp"."contract_obligation_events" ("contract_obligation_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligation_events_event_type_concept_id" ON "erp"."contract_obligation_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligation_events_evidence_file_id" ON "erp"."contract_obligation_events" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligation_events_outcome_concept_id" ON "erp"."contract_obligation_events" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligation_events_recorded_by_user_id" ON "erp"."contract_obligation_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_obligation_events_obligation_event" ON "erp"."contract_obligation_events" ("contract_obligation_id", "event_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_contract_obligation_events_created_at" ON "erp"."contract_obligation_events" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_contract_id" ON "erp"."contract_renewals" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_renewal_type_concept_id" ON "erp"."contract_renewals" ("renewal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_currency_concept_id" ON "erp"."contract_renewals" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_initiated_by_user_id" ON "erp"."contract_renewals" ("initiated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_decision_by_user_id" ON "erp"."contract_renewals" ("decision_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_status_concept_id" ON "erp"."contract_renewals" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_created_by_user_id" ON "erp"."contract_renewals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_updated_by_user_id" ON "erp"."contract_renewals" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_renewals_contract_status" ON "erp"."contract_renewals" ("contract_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_contract_id" ON "erp"."contract_terminations" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_termination_type_concept_id" ON "erp"."contract_terminations" ("termination_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_initiated_by_user_id" ON "erp"."contract_terminations" ("initiated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_approved_by_user_id" ON "erp"."contract_terminations" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_currency_concept_id" ON "erp"."contract_terminations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_status_concept_id" ON "erp"."contract_terminations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_created_by_user_id" ON "erp"."contract_terminations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_updated_by_user_id" ON "erp"."contract_terminations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_terminations_contract_status" ON "erp"."contract_terminations" ("contract_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contract_team_members_contract_id_user_id_team_role_5e285251" ON "erp"."contract_team_members" ("contract_id", "user_id", "team_role_concept_id", "valid_from");

CREATE INDEX IF NOT EXISTS "ix_contract_team_members_contract_id" ON "erp"."contract_team_members" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_team_members_user_id" ON "erp"."contract_team_members" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_team_members_team_role_concept_id" ON "erp"."contract_team_members" ("team_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_team_members_responsibility_scope_concept_id" ON "erp"."contract_team_members" ("responsibility_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_team_members_status_concept_id" ON "erp"."contract_team_members" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_team_members_created_by_user_id" ON "erp"."contract_team_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_contract_id" ON "erp"."contract_approval_requests" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_contract_version_id" ON "erp"."contract_approval_requests" ("contract_version_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_contract_amendment_id" ON "erp"."contract_approval_requests" ("contract_amendment_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_approval_type_concept_id" ON "erp"."contract_approval_requests" ("approval_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_requested_by_user_id" ON "erp"."contract_approval_requests" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_workflow_instance_id" ON "erp"."contract_approval_requests" ("workflow_instance_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_status_concept_id" ON "erp"."contract_approval_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_requests_contract_status_due" ON "erp"."contract_approval_requests" ("contract_id", "status_concept_id", "due_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contract_approval_steps_contract_approval_request_i_754e6454" ON "erp"."contract_approval_steps" ("contract_approval_request_id", "step_number");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_steps_contract_approval_request_id" ON "erp"."contract_approval_steps" ("contract_approval_request_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_steps_approver_user_id" ON "erp"."contract_approval_steps" ("approver_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_steps_approver_team_role_concept_id" ON "erp"."contract_approval_steps" ("approver_team_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_steps_decision_concept_id" ON "erp"."contract_approval_steps" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_approval_steps_status_concept_id" ON "erp"."contract_approval_steps" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_contract_id" ON "erp"."contract_object_assignments" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_contract_line_item_id" ON "erp"."contract_object_assignments" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_assignment_role_concept_id" ON "erp"."contract_object_assignments" ("assignment_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_business_partner_id" ON "erp"."contract_object_assignments" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_asset_id" ON "erp"."contract_object_assignments" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_liability_id" ON "erp"."contract_object_assignments" ("liability_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_project_id" ON "erp"."contract_object_assignments" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_wbs_element_id" ON "erp"."contract_object_assignments" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_cost_center_id" ON "erp"."contract_object_assignments" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_profit_center_id" ON "erp"."contract_object_assignments" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_purchase_order_id" ON "erp"."contract_object_assignments" ("purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_sales_order_id" ON "erp"."contract_object_assignments" ("sales_order_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_employee_id" ON "erp"."contract_object_assignments" ("employee_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_practice_id" ON "erp"."contract_object_assignments" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_branch_id" ON "erp"."contract_object_assignments" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_status_concept_id" ON "erp"."contract_object_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_created_by_user_id" ON "erp"."contract_object_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_updated_by_user_id" ON "erp"."contract_object_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_object_assignments_contract_role_status" ON "erp"."contract_object_assignments" ("contract_id", "assignment_role_concept_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_contract_id" ON "erp"."contract_accounting_terms" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_contract_line_item_id" ON "erp"."contract_accounting_terms" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_accounting_treatment_concept_id" ON "erp"."contract_accounting_terms" ("accounting_treatment_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_expense_account_id" ON "erp"."contract_accounting_terms" ("expense_account_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_revenue_account_id" ON "erp"."contract_accounting_terms" ("revenue_account_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_accrual_account_id" ON "erp"."contract_accounting_terms" ("accrual_account_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_asset_account_id" ON "erp"."contract_accounting_terms" ("asset_account_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_liability_account_id" ON "erp"."contract_accounting_terms" ("liability_account_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_cost_center_id" ON "erp"."contract_accounting_terms" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_profit_center_id" ON "erp"."contract_accounting_terms" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_tax_code_id" ON "erp"."contract_accounting_terms" ("tax_code_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_status_concept_id" ON "erp"."contract_accounting_terms" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_created_by_user_id" ON "erp"."contract_accounting_terms" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_updated_by_user_id" ON "erp"."contract_accounting_terms" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_accounting_terms_contract_effective" ON "erp"."contract_accounting_terms" ("contract_id", "effective_from" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contract_payment_schedules_contract_id_installment_number" ON "erp"."contract_payment_schedules" ("contract_id", "installment_number");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_contract_id" ON "erp"."contract_payment_schedules" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_contract_line_item_id" ON "erp"."contract_payment_schedules" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_contract_obligation_id" ON "erp"."contract_payment_schedules" ("contract_obligation_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_currency_concept_id" ON "erp"."contract_payment_schedules" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_payment_direction_concept_id" ON "erp"."contract_payment_schedules" ("payment_direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_invoice_id" ON "erp"."contract_payment_schedules" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_bill_id" ON "erp"."contract_payment_schedules" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_payment_transaction_id" ON "erp"."contract_payment_schedules" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_status_concept_id" ON "erp"."contract_payment_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_created_by_user_id" ON "erp"."contract_payment_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_updated_by_user_id" ON "erp"."contract_payment_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_payment_schedules_status_due" ON "erp"."contract_payment_schedules" ("status_concept_id", "due_date");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_lease_contracts_contract_id" ON "erp"."lease_contracts" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_lease_contracts_contract_id" ON "erp"."lease_contracts" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_lease_contracts_lease_role_concept_id" ON "erp"."lease_contracts" ("lease_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_contracts_accounting_principle_concept_id" ON "erp"."lease_contracts" ("accounting_principle_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_contracts_currency_concept_id" ON "erp"."lease_contracts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_contracts_status_concept_id" ON "erp"."lease_contracts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_contracts_created_by_user_id" ON "erp"."lease_contracts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_contracts_updated_by_user_id" ON "erp"."lease_contracts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_lease_contract_id" ON "erp"."lease_objects" ("lease_contract_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_object_type_concept_id" ON "erp"."lease_objects" ("object_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_source_asset_id" ON "erp"."lease_objects" ("source_asset_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_branch_id" ON "erp"."lease_objects" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_unit_concept_id" ON "erp"."lease_objects" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_status_concept_id" ON "erp"."lease_objects" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_created_by_user_id" ON "erp"."lease_objects" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_objects_updated_by_user_id" ON "erp"."lease_objects" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_lease_contract_id" ON "erp"."lease_cash_flows" ("lease_contract_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_lease_object_id" ON "erp"."lease_cash_flows" ("lease_object_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_flow_type_concept_id" ON "erp"."lease_cash_flows" ("flow_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_currency_concept_id" ON "erp"."lease_cash_flows" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_index_reference_concept_id" ON "erp"."lease_cash_flows" ("index_reference_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_status_concept_id" ON "erp"."lease_cash_flows" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_created_by_user_id" ON "erp"."lease_cash_flows" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_updated_by_user_id" ON "erp"."lease_cash_flows" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_cash_flows_lease_status_due" ON "erp"."lease_cash_flows" ("lease_contract_id", "status_concept_id", "due_date");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_lease_valuations_lease_contract_id_valuation_date_accountin" ON "erp"."lease_valuations" ("lease_contract_id", "valuation_date", "accounting_principle_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_valuations_lease_contract_id" ON "erp"."lease_valuations" ("lease_contract_id");

CREATE INDEX IF NOT EXISTS "ix_lease_valuations_accounting_principle_concept_id" ON "erp"."lease_valuations" ("accounting_principle_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_valuations_currency_concept_id" ON "erp"."lease_valuations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_valuations_journal_transaction_id" ON "erp"."lease_valuations" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_lease_valuations_status_concept_id" ON "erp"."lease_valuations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lease_valuations_created_by_user_id" ON "erp"."lease_valuations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_lease_contract_id" ON "erp"."lease_accounting_links" ("lease_contract_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_lease_object_id" ON "erp"."lease_accounting_links" ("lease_object_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_right_of_use_asset_id" ON "erp"."lease_accounting_links" ("right_of_use_asset_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_lease_liability_id" ON "erp"."lease_accounting_links" ("lease_liability_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_right_of_use_asset_account_id" ON "erp"."lease_accounting_links" ("right_of_use_asset_account_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_lease_liability_account_id" ON "erp"."lease_accounting_links" ("lease_liability_account_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_interest_expense_account_id" ON "erp"."lease_accounting_links" ("interest_expense_account_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_depreciation_expense_account_id" ON "erp"."lease_accounting_links" ("depreciation_expense_account_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_created_by_user_id" ON "erp"."lease_accounting_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_updated_by_user_id" ON "erp"."lease_accounting_links" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lease_accounting_links_lease_valid_from" ON "erp"."lease_accounting_links" ("lease_contract_id", "valid_from" DESC);

CREATE INDEX IF NOT EXISTS "ix_employees_practice_id" ON "erp"."employees" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_employees_person_user_id" ON "erp"."employees" ("person_user_id");

CREATE INDEX IF NOT EXISTS "ix_employees_role_concept_id" ON "erp"."employees" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employees_currency_concept_id" ON "erp"."employees" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employees_payment_method_concept_id" ON "erp"."employees" ("payment_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employees_business_partner_id" ON "erp"."employees" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_employees_status_concept_id" ON "erp"."employees" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employees_created_by_user_id" ON "erp"."employees" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employees_updated_by_user_id" ON "erp"."employees" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_departments_tenant_id" ON "erp"."departments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_departments_parent_department_id" ON "erp"."departments" ("parent_department_id");

CREATE INDEX IF NOT EXISTS "ix_departments_manager_employee_id" ON "erp"."departments" ("manager_employee_id");

CREATE INDEX IF NOT EXISTS "ix_departments_cost_center_id" ON "erp"."departments" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_departments_status_concept_id" ON "erp"."departments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_departments_created_by_user_id" ON "erp"."departments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_departments_updated_by_user_id" ON "erp"."departments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_departments_tenant_id_status_concept_id" ON "erp"."departments" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_positions_tenant_id" ON "erp"."positions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_positions_department_id" ON "erp"."positions" ("department_id");

CREATE INDEX IF NOT EXISTS "ix_positions_job_family_concept_id" ON "erp"."positions" ("job_family_concept_id");

CREATE INDEX IF NOT EXISTS "ix_positions_grade_concept_id" ON "erp"."positions" ("grade_concept_id");

CREATE INDEX IF NOT EXISTS "ix_positions_status_concept_id" ON "erp"."positions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_positions_created_by_user_id" ON "erp"."positions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_positions_updated_by_user_id" ON "erp"."positions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_positions_tenant_id_status_concept_id" ON "erp"."positions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_employment_records_employee_id" ON "erp"."employment_records" ("employee_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_tenant_id" ON "erp"."employment_records" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_position_id" ON "erp"."employment_records" ("position_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_department_id" ON "erp"."employment_records" ("department_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_employment_type_concept_id" ON "erp"."employment_records" ("employment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_manager_employee_id" ON "erp"."employment_records" ("manager_employee_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_currency_concept_id" ON "erp"."employment_records" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_contract_id" ON "erp"."employment_records" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_status_concept_id" ON "erp"."employment_records" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_created_by_user_id" ON "erp"."employment_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_updated_by_user_id" ON "erp"."employment_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employment_records_tenant_id_status_concept_id" ON "erp"."employment_records" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_employment_record_id" ON "erp"."employee_assignments" ("employment_record_id");

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_assignment_type_concept_id" ON "erp"."employee_assignments" ("assignment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_practice_id" ON "erp"."employee_assignments" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_branch_id" ON "erp"."employee_assignments" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_department_id" ON "erp"."employee_assignments" ("department_id");

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_status_concept_id" ON "erp"."employee_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_created_by_user_id" ON "erp"."employee_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employee_assignments_updated_by_user_id" ON "erp"."employee_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_employee_assignments_effective_period" ON "erp"."employee_assignments" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_time_off_requests_employee_id" ON "erp"."time_off_requests" ("employee_id");

CREATE INDEX IF NOT EXISTS "ix_time_off_requests_leave_type_concept_id" ON "erp"."time_off_requests" ("leave_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_time_off_requests_approver_user_id" ON "erp"."time_off_requests" ("approver_user_id");

CREATE INDEX IF NOT EXISTS "ix_time_off_requests_status_concept_id" ON "erp"."time_off_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_time_off_requests_created_by_user_id" ON "erp"."time_off_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_time_off_requests_updated_by_user_id" ON "erp"."time_off_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_performance_reviews_employee_id" ON "erp"."performance_reviews" ("employee_id");

CREATE INDEX IF NOT EXISTS "ix_performance_reviews_reviewer_employee_id" ON "erp"."performance_reviews" ("reviewer_employee_id");

CREATE INDEX IF NOT EXISTS "ix_performance_reviews_rating_concept_id" ON "erp"."performance_reviews" ("rating_concept_id");

CREATE INDEX IF NOT EXISTS "ix_performance_reviews_status_concept_id" ON "erp"."performance_reviews" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_performance_reviews_created_by_user_id" ON "erp"."performance_reviews" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_performance_reviews_updated_by_user_id" ON "erp"."performance_reviews" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contracts_contract_number" ON "erp"."contracts" ("contract_number");

CREATE INDEX IF NOT EXISTS "ix_contracts_tenant_id" ON "erp"."contracts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_contract_type_concept_id" ON "erp"."contracts" ("contract_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_counterparty_type_concept_id" ON "erp"."contracts" ("counterparty_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_renewal_type_concept_id" ON "erp"."contracts" ("renewal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_currency_concept_id" ON "erp"."contracts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_governing_jurisdiction_concept_id" ON "erp"."contracts" ("governing_jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_owner_user_id" ON "erp"."contracts" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_primary_business_partner_id" ON "erp"."contracts" ("primary_business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_current_version_id" ON "erp"."contracts" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_parent_contract_id" ON "erp"."contracts" ("parent_contract_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_master_agreement_id" ON "erp"."contracts" ("master_agreement_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_owning_department_id" ON "erp"."contracts" ("owning_department_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_owning_cost_center_id" ON "erp"."contracts" ("owning_cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_owning_profit_center_id" ON "erp"."contracts" ("owning_profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_approval_status_concept_id" ON "erp"."contracts" ("approval_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_signature_status_concept_id" ON "erp"."contracts" ("signature_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_status_concept_id" ON "erp"."contracts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_created_by_user_id" ON "erp"."contracts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_updated_by_user_id" ON "erp"."contracts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contracts_tenant_id_status_concept_id" ON "erp"."contracts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_contract_parties_contract_id" ON "erp"."contract_parties" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_parties_party_role_concept_id" ON "erp"."contract_parties" ("party_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_parties_party_type_concept_id" ON "erp"."contract_parties" ("party_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_parties_signatory_user_id" ON "erp"."contract_parties" ("signatory_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_parties_created_by_user_id" ON "erp"."contract_parties" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_parties_updated_by_user_id" ON "erp"."contract_parties" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_line_items_contract_id" ON "erp"."contract_line_items" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_line_items_service_concept_id" ON "erp"."contract_line_items" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_line_items_currency_concept_id" ON "erp"."contract_line_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_line_items_recurrence_concept_id" ON "erp"."contract_line_items" ("recurrence_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_line_items_account_id" ON "erp"."contract_line_items" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_contract_line_items_created_by_user_id" ON "erp"."contract_line_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_line_items_updated_by_user_id" ON "erp"."contract_line_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_milestones_contract_id" ON "erp"."contract_milestones" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_milestones_currency_concept_id" ON "erp"."contract_milestones" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_milestones_status_concept_id" ON "erp"."contract_milestones" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_milestones_created_by_user_id" ON "erp"."contract_milestones" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_milestones_updated_by_user_id" ON "erp"."contract_milestones" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_documents_contract_id" ON "erp"."contract_documents" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_contract_documents_document_type_concept_id" ON "erp"."contract_documents" ("document_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contract_documents_file_id" ON "erp"."contract_documents" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_contract_documents_created_by_user_id" ON "erp"."contract_documents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contract_documents_updated_by_user_id" ON "erp"."contract_documents" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_contract_documents_contract_id_version" ON "erp"."contract_documents" ("contract_id", "version");
