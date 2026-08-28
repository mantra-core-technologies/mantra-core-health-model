-- SALUD v4.0.10 · módulo 38 · schema erp
-- Generado de diagram_38_erp.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."departments"
        ADD CONSTRAINT "fk_departments_parent_department_id" FOREIGN KEY ("parent_department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."departments"
        ADD CONSTRAINT "fk_departments_manager_employee_id" FOREIGN KEY ("manager_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."positions"
        ADD CONSTRAINT "fk_positions_department_id" FOREIGN KEY ("department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_employee_id" FOREIGN KEY ("employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_position_id" FOREIGN KEY ("position_id")
        REFERENCES "erp"."positions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_department_id" FOREIGN KEY ("department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_manager_employee_id" FOREIGN KEY ("manager_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_employment_record_id" FOREIGN KEY ("employment_record_id")
        REFERENCES "erp"."employment_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_department_id" FOREIGN KEY ("department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."time_off_requests"
        ADD CONSTRAINT "fk_time_off_requests_employee_id" FOREIGN KEY ("employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."performance_reviews"
        ADD CONSTRAINT "fk_performance_reviews_employee_id" FOREIGN KEY ("employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."performance_reviews"
        ADD CONSTRAINT "fk_performance_reviews_reviewer_employee_id" FOREIGN KEY ("reviewer_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_primary_business_partner_id" FOREIGN KEY ("primary_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_current_version_id" FOREIGN KEY ("current_version_id")
        REFERENCES "erp"."contract_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_parent_contract_id" FOREIGN KEY ("parent_contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_owning_department_id" FOREIGN KEY ("owning_department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_parties"
        ADD CONSTRAINT "fk_contract_parties_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_line_items"
        ADD CONSTRAINT "fk_contract_line_items_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_milestones"
        ADD CONSTRAINT "fk_contract_milestones_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_documents"
        ADD CONSTRAINT "fk_contract_documents_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_roles"
        ADD CONSTRAINT "fk_business_partner_roles_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_relationships"
        ADD CONSTRAINT "fk_business_partner_relationships_source_business_partner_id" FOREIGN KEY ("source_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_relationships"
        ADD CONSTRAINT "fk_business_partner_relationships_target_business_partner_id" FOREIGN KEY ("target_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_tax_registrations"
        ADD CONSTRAINT "fk_business_partner_tax_registrations_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_bank_accounts"
        ADD CONSTRAINT "fk_business_partner_bank_accounts_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_responsible_employee_id" FOREIGN KEY ("responsible_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_department_id" FOREIGN KEY ("department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_parent_wbs_element_id" FOREIGN KEY ("parent_wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_responsible_employee_id" FOREIGN KEY ("responsible_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_requester_employee_id" FOREIGN KEY ("requester_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_requesting_department_id" FOREIGN KEY ("requesting_department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_purchase_requisition_id" FOREIGN KEY ("purchase_requisition_id")
        REFERENCES "erp"."purchase_requisitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_supplier_business_partner_id" FOREIGN KEY ("supplier_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_purchase_requisition_id" FOREIGN KEY ("purchase_requisition_id")
        REFERENCES "erp"."purchase_requisitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_ordering_department_id" FOREIGN KEY ("ordering_department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_buyer_employee_id" FOREIGN KEY ("buyer_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_purchase_order_id" FOREIGN KEY ("purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_purchase_requisition_item_id" FOREIGN KEY ("purchase_requisition_item_id")
        REFERENCES "erp"."purchase_requisition_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipts"
        ADD CONSTRAINT "fk_goods_receipts_purchase_order_id" FOREIGN KEY ("purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipts"
        ADD CONSTRAINT "fk_goods_receipts_received_by_employee_id" FOREIGN KEY ("received_by_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipt_items"
        ADD CONSTRAINT "fk_goods_receipt_items_goods_receipt_id" FOREIGN KEY ("goods_receipt_id")
        REFERENCES "erp"."goods_receipts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipt_items"
        ADD CONSTRAINT "fk_goods_receipt_items_purchase_order_item_id" FOREIGN KEY ("purchase_order_item_id")
        REFERENCES "erp"."purchase_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_purchase_order_id" FOREIGN KEY ("purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_supplier_business_partner_id" FOREIGN KEY ("supplier_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_accepted_by_employee_id" FOREIGN KEY ("accepted_by_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_service_entry_sheet_id" FOREIGN KEY ("service_entry_sheet_id")
        REFERENCES "erp"."service_entry_sheets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_purchase_order_item_id" FOREIGN KEY ("purchase_order_item_id")
        REFERENCES "erp"."purchase_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_purchase_order_id" FOREIGN KEY ("purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_invoice_match_run_id" FOREIGN KEY ("invoice_match_run_id")
        REFERENCES "erp"."invoice_match_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_purchase_order_item_id" FOREIGN KEY ("purchase_order_item_id")
        REFERENCES "erp"."purchase_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_goods_receipt_item_id" FOREIGN KEY ("goods_receipt_item_id")
        REFERENCES "erp"."goods_receipt_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_service_entry_item_id" FOREIGN KEY ("service_entry_item_id")
        REFERENCES "erp"."service_entry_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_customer_business_partner_id" FOREIGN KEY ("customer_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_owner_employee_id" FOREIGN KEY ("owner_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_sales_order_id" FOREIGN KEY ("sales_order_id")
        REFERENCES "erp"."sales_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_versions"
        ADD CONSTRAINT "fk_contract_versions_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_base_version_id" FOREIGN KEY ("base_version_id")
        REFERENCES "erp"."contract_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_resulting_version_id" FOREIGN KEY ("resulting_version_id")
        REFERENCES "erp"."contract_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_clause_instances"
        ADD CONSTRAINT "fk_contract_clause_instances_contract_version_id" FOREIGN KEY ("contract_version_id")
        REFERENCES "erp"."contract_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_clause_instances"
        ADD CONSTRAINT "fk_contract_clause_instances_contract_clause_id" FOREIGN KEY ("contract_clause_id")
        REFERENCES "erp"."contract_clauses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_contract_version_id" FOREIGN KEY ("contract_version_id")
        REFERENCES "erp"."contract_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_contract_clause_instance_id" FOREIGN KEY ("contract_clause_instance_id")
        REFERENCES "erp"."contract_clause_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_responsible_business_partner_id" FOREIGN KEY ("responsible_business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligation_events"
        ADD CONSTRAINT "fk_contract_obligation_events_contract_obligation_id" FOREIGN KEY ("contract_obligation_id")
        REFERENCES "erp"."contract_obligations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_team_members"
        ADD CONSTRAINT "fk_contract_team_members_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_requests"
        ADD CONSTRAINT "fk_contract_approval_requests_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_requests"
        ADD CONSTRAINT "fk_contract_approval_requests_contract_version_id" FOREIGN KEY ("contract_version_id")
        REFERENCES "erp"."contract_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_requests"
        ADD CONSTRAINT "fk_contract_approval_requests_contract_amendment_id" FOREIGN KEY ("contract_amendment_id")
        REFERENCES "erp"."contract_amendments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_steps"
        ADD CONSTRAINT "fk_contract_approval_steps_contract_approval_request_id" FOREIGN KEY ("contract_approval_request_id")
        REFERENCES "erp"."contract_approval_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_purchase_order_id" FOREIGN KEY ("purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_sales_order_id" FOREIGN KEY ("sales_order_id")
        REFERENCES "erp"."sales_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_employee_id" FOREIGN KEY ("employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_contract_obligation_id" FOREIGN KEY ("contract_obligation_id")
        REFERENCES "erp"."contract_obligations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."lease_contracts"
        ADD CONSTRAINT "fk_lease_contracts_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_lease_contract_id" FOREIGN KEY ("lease_contract_id")
        REFERENCES "erp"."lease_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_lease_contract_id" FOREIGN KEY ("lease_contract_id")
        REFERENCES "erp"."lease_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_lease_object_id" FOREIGN KEY ("lease_object_id")
        REFERENCES "erp"."lease_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."lease_valuations"
        ADD CONSTRAINT "fk_lease_valuations_lease_contract_id" FOREIGN KEY ("lease_contract_id")
        REFERENCES "erp"."lease_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_lease_contract_id" FOREIGN KEY ("lease_contract_id")
        REFERENCES "erp"."lease_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_lease_object_id" FOREIGN KEY ("lease_object_id")
        REFERENCES "erp"."lease_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
