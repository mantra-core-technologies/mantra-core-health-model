-- SALUD v4.0.10 · módulo 16 · schema accounting
-- Generado de diagram_16_accounting.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_controlling_areas_tenant_id_code" ON "accounting"."controlling_areas" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_controlling_areas_tenant_id" ON "accounting"."controlling_areas" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_controlling_areas_operating_currency_concept_id" ON "accounting"."controlling_areas" ("operating_currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_controlling_areas_status_concept_id" ON "accounting"."controlling_areas" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_controlling_areas_created_by_user_id" ON "accounting"."controlling_areas" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_controlling_areas_updated_by_user_id" ON "accounting"."controlling_areas" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_controlling_areas_search" ON "accounting"."controlling_areas" USING gin (to_tsvector('simple', (coalesce(code, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_segments_tenant_id_code" ON "accounting"."segments" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_segments_tenant_id" ON "accounting"."segments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_segments_parent_segment_id" ON "accounting"."segments" ("parent_segment_id");

CREATE INDEX IF NOT EXISTS "ix_segments_status_concept_id" ON "accounting"."segments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_segments_created_by_user_id" ON "accounting"."segments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_segments_updated_by_user_id" ON "accounting"."segments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_segments_search" ON "accounting"."segments" USING gin (to_tsvector('simple', (coalesce(code, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_functional_areas_tenant_id_code" ON "accounting"."functional_areas" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_functional_areas_tenant_id" ON "accounting"."functional_areas" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_functional_areas_parent_functional_area_id" ON "accounting"."functional_areas" ("parent_functional_area_id");

CREATE INDEX IF NOT EXISTS "ix_functional_areas_status_concept_id" ON "accounting"."functional_areas" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_functional_areas_created_by_user_id" ON "accounting"."functional_areas" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_functional_areas_updated_by_user_id" ON "accounting"."functional_areas" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_functional_areas_search" ON "accounting"."functional_areas" USING gin (to_tsvector('simple', (coalesce(code, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_profit_centers_tenant_id_code" ON "accounting"."profit_centers" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_controlling_area_id" ON "accounting"."profit_centers" ("controlling_area_id");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_tenant_id" ON "accounting"."profit_centers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_parent_profit_center_id" ON "accounting"."profit_centers" ("parent_profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_segment_id" ON "accounting"."profit_centers" ("segment_id");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_responsible_employee_id" ON "accounting"."profit_centers" ("responsible_employee_id");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_status_concept_id" ON "accounting"."profit_centers" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_created_by_user_id" ON "accounting"."profit_centers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_profit_centers_updated_by_user_id" ON "accounting"."profit_centers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_profit_centers_search" ON "accounting"."profit_centers" USING gin (to_tsvector('simple', (coalesce(code, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_internal_orders_tenant_id_order_number" ON "accounting"."internal_orders" ("tenant_id", "order_number");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_controlling_area_id" ON "accounting"."internal_orders" ("controlling_area_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_tenant_id" ON "accounting"."internal_orders" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_order_type_concept_id" ON "accounting"."internal_orders" ("order_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_responsible_cost_center_id" ON "accounting"."internal_orders" ("responsible_cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_responsible_profit_center_id" ON "accounting"."internal_orders" ("responsible_profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_project_id" ON "accounting"."internal_orders" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_wbs_element_id" ON "accounting"."internal_orders" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_currency_concept_id" ON "accounting"."internal_orders" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_status_concept_id" ON "accounting"."internal_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_created_by_user_id" ON "accounting"."internal_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_updated_by_user_id" ON "accounting"."internal_orders" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_internal_orders_tenant_status_updated" ON "accounting"."internal_orders" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_internal_orders_search" ON "accounting"."internal_orders" USING gin (to_tsvector('simple', (coalesce(order_number, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_company_bank_accounts_tenant_id_account_number_hash" ON "accounting"."company_bank_accounts" ("tenant_id", "account_number_hash");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_tenant_id" ON "accounting"."company_bank_accounts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_account_id" ON "accounting"."company_bank_accounts" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_currency_concept_id" ON "accounting"."company_bank_accounts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_branch_id" ON "accounting"."company_bank_accounts" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_clearing_account_id" ON "accounting"."company_bank_accounts" ("clearing_account_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_status_concept_id" ON "accounting"."company_bank_accounts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_created_by_user_id" ON "accounting"."company_bank_accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_updated_by_user_id" ON "accounting"."company_bank_accounts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_company_bank_accounts_tenant_status" ON "accounting"."company_bank_accounts" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_subledger_accounts_tenant_id_business_partner_id_su_8a871de6" ON "accounting"."subledger_accounts" ("tenant_id", "business_partner_id", "subledger_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_tenant_id" ON "accounting"."subledger_accounts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_business_partner_id" ON "accounting"."subledger_accounts" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_subledger_role_concept_id" ON "accounting"."subledger_accounts" ("subledger_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_reconciliation_account_id" ON "accounting"."subledger_accounts" ("reconciliation_account_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_currency_concept_id" ON "accounting"."subledger_accounts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_payment_terms_concept_id" ON "accounting"."subledger_accounts" ("payment_terms_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_dunning_procedure_concept_id" ON "accounting"."subledger_accounts" ("dunning_procedure_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_status_concept_id" ON "accounting"."subledger_accounts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_created_by_user_id" ON "accounting"."subledger_accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_updated_by_user_id" ON "accounting"."subledger_accounts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_subledger_accounts_tenant_status" ON "accounting"."subledger_accounts" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_journal_entry_assignments_ledger_entry_id" ON "accounting"."journal_entry_assignments" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_ledger_entry_id" ON "accounting"."journal_entry_assignments" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_branch_id" ON "accounting"."journal_entry_assignments" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_department_id" ON "accounting"."journal_entry_assignments" ("department_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_cost_center_id" ON "accounting"."journal_entry_assignments" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_profit_center_id" ON "accounting"."journal_entry_assignments" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_functional_area_id" ON "accounting"."journal_entry_assignments" ("functional_area_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_segment_id" ON "accounting"."journal_entry_assignments" ("segment_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_internal_order_id" ON "accounting"."journal_entry_assignments" ("internal_order_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_project_id" ON "accounting"."journal_entry_assignments" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_wbs_element_id" ON "accounting"."journal_entry_assignments" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_business_partner_id" ON "accounting"."journal_entry_assignments" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_subledger_account_id" ON "accounting"."journal_entry_assignments" ("subledger_account_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_asset_id" ON "accounting"."journal_entry_assignments" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_asset_component_id" ON "accounting"."journal_entry_assignments" ("asset_component_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_liability_id" ON "accounting"."journal_entry_assignments" ("liability_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_contract_id" ON "accounting"."journal_entry_assignments" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_invoice_id" ON "accounting"."journal_entry_assignments" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_bill_id" ON "accounting"."journal_entry_assignments" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_purchase_order_item_id" ON "accounting"."journal_entry_assignments" ("purchase_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_goods_receipt_item_id" ON "accounting"."journal_entry_assignments" ("goods_receipt_item_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_sales_order_item_id" ON "accounting"."journal_entry_assignments" ("sales_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_payment_transaction_id" ON "accounting"."journal_entry_assignments" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_company_bank_account_id" ON "accounting"."journal_entry_assignments" ("company_bank_account_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_employee_id" ON "accounting"."journal_entry_assignments" ("employee_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_assignment_source_concept_id" ON "accounting"."journal_entry_assignments" ("assignment_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_derived_by_rule_id" ON "accounting"."journal_entry_assignments" ("derived_by_rule_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_created_by_user_id" ON "accounting"."journal_entry_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_business_partner_line" ON "accounting"."journal_entry_assignments" ("business_partner_id", "ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_asset_line" ON "accounting"."journal_entry_assignments" ("asset_id", "ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_liability_line" ON "accounting"."journal_entry_assignments" ("liability_id", "ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_journal_entry_assignments_contract_line" ON "accounting"."journal_entry_assignments" ("contract_id", "ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_tenant_id" ON "accounting"."account_determination_rules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_posting_scenario_concept_id" ON "accounting"."account_determination_rules" ("posting_scenario_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_account_role_concept_id" ON "accounting"."account_determination_rules" ("account_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_source_type_concept_id" ON "accounting"."account_determination_rules" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_asset_class_id" ON "accounting"."account_determination_rules" ("asset_class_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_liability_type_concept_id" ON "accounting"."account_determination_rules" ("liability_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_contract_type_concept_id" ON "accounting"."account_determination_rules" ("contract_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_tax_code_id" ON "accounting"."account_determination_rules" ("tax_code_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_service_concept_id" ON "accounting"."account_determination_rules" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_target_account_id" ON "accounting"."account_determination_rules" ("target_account_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_status_concept_id" ON "accounting"."account_determination_rules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_created_by_user_id" ON "accounting"."account_determination_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_updated_by_user_id" ON "accounting"."account_determination_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_account_determination_rules_tenant_scenario_priority" ON "accounting"."account_determination_rules" ("tenant_id", "posting_scenario_concept_id", "priority");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_accounting_document_links_source_transaction_id_tar_c5560530" ON "accounting"."accounting_document_links" ("source_transaction_id", "target_transaction_id", "relation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accounting_document_links_source_transaction_id" ON "accounting"."accounting_document_links" ("source_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_accounting_document_links_target_transaction_id" ON "accounting"."accounting_document_links" ("target_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_accounting_document_links_relation_type_concept_id" ON "accounting"."accounting_document_links" ("relation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accounting_document_links_source_line_id" ON "accounting"."accounting_document_links" ("source_line_id");

CREATE INDEX IF NOT EXISTS "ix_accounting_document_links_target_line_id" ON "accounting"."accounting_document_links" ("target_line_id");

CREATE INDEX IF NOT EXISTS "ix_accounting_document_links_created_by_user_id" ON "accounting"."accounting_document_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_accounting_document_links_target_relation" ON "accounting"."accounting_document_links" ("target_transaction_id", "relation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_tenant_id" ON "accounting"."open_items" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_subledger_account_id" ON "accounting"."open_items" ("subledger_account_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_ledger_entry_id" ON "accounting"."open_items" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_document_type_concept_id" ON "accounting"."open_items" ("document_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_invoice_id" ON "accounting"."open_items" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_bill_id" ON "accounting"."open_items" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_contract_id" ON "accounting"."open_items" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_currency_concept_id" ON "accounting"."open_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_status_concept_id" ON "accounting"."open_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_created_by_user_id" ON "accounting"."open_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_updated_by_user_id" ON "accounting"."open_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_open_items_tenant_status_due" ON "accounting"."open_items" ("tenant_id", "status_concept_id", "due_date");

CREATE INDEX IF NOT EXISTS "ix_open_items_subledger_status_due" ON "accounting"."open_items" ("subledger_account_id", "status_concept_id", "due_date");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_clearing_documents_tenant_id_clearing_number" ON "accounting"."clearing_documents" ("tenant_id", "clearing_number");

CREATE INDEX IF NOT EXISTS "ix_clearing_documents_tenant_id" ON "accounting"."clearing_documents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_documents_transaction_id" ON "accounting"."clearing_documents" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_documents_company_bank_account_id" ON "accounting"."clearing_documents" ("company_bank_account_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_documents_payment_transaction_id" ON "accounting"."clearing_documents" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_documents_status_concept_id" ON "accounting"."clearing_documents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_documents_created_by_user_id" ON "accounting"."clearing_documents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_documents_tenant_date" ON "accounting"."clearing_documents" ("tenant_id", "clearing_date");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_clearing_items_clearing_document_id_open_item_id" ON "accounting"."clearing_items" ("clearing_document_id", "open_item_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_items_clearing_document_id" ON "accounting"."clearing_items" ("clearing_document_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_items_open_item_id" ON "accounting"."clearing_items" ("open_item_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_items_currency_concept_id" ON "accounting"."clearing_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_items_residual_open_item_id" ON "accounting"."clearing_items" ("residual_open_item_id");

CREATE INDEX IF NOT EXISTS "ix_clearing_items_created_by_user_id" ON "accounting"."clearing_items" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_asset_classes_tenant_id_code" ON "accounting"."asset_classes" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_tenant_id" ON "accounting"."asset_classes" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_asset_type_concept_id" ON "accounting"."asset_classes" ("asset_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_acquisition_account_id" ON "accounting"."asset_classes" ("acquisition_account_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_accumulated_depreciation_account_id" ON "accounting"."asset_classes" ("accumulated_depreciation_account_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_depreciation_expense_account_id" ON "accounting"."asset_classes" ("depreciation_expense_account_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_gain_account_id" ON "accounting"."asset_classes" ("gain_account_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_loss_account_id" ON "accounting"."asset_classes" ("loss_account_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_status_concept_id" ON "accounting"."asset_classes" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_created_by_user_id" ON "accounting"."asset_classes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_classes_updated_by_user_id" ON "accounting"."asset_classes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_asset_classes_search" ON "accounting"."asset_classes" USING gin (to_tsvector('simple', (coalesce(code, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_asset_components_asset_id_component_number" ON "accounting"."asset_components" ("asset_id", "component_number");

CREATE INDEX IF NOT EXISTS "ix_asset_components_asset_id" ON "accounting"."asset_components" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_asset_components_asset_class_id" ON "accounting"."asset_components" ("asset_class_id");

CREATE INDEX IF NOT EXISTS "ix_asset_components_status_concept_id" ON "accounting"."asset_components" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_asset_components_created_by_user_id" ON "accounting"."asset_components" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_components_updated_by_user_id" ON "accounting"."asset_components" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_asset_components_search" ON "accounting"."asset_components" USING gin (to_tsvector('simple', (coalesce(component_number, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_depreciation_areas_tenant_id_code" ON "accounting"."depreciation_areas" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_depreciation_areas_tenant_id" ON "accounting"."depreciation_areas" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_depreciation_areas_accounting_principle_concept_id" ON "accounting"."depreciation_areas" ("accounting_principle_concept_id");

CREATE INDEX IF NOT EXISTS "ix_depreciation_areas_currency_concept_id" ON "accounting"."depreciation_areas" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_depreciation_areas_status_concept_id" ON "accounting"."depreciation_areas" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_depreciation_areas_created_by_user_id" ON "accounting"."depreciation_areas" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_depreciation_areas_updated_by_user_id" ON "accounting"."depreciation_areas" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_depreciation_areas_search" ON "accounting"."depreciation_areas" USING gin (to_tsvector('simple', (coalesce(code, '') || ' ' || coalesce(name, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_asset_valuations_asset_id_asset_component_id_depreciation_a" ON "accounting"."asset_valuations" ("asset_id", "asset_component_id", "depreciation_area_id", "valid_from");

CREATE INDEX IF NOT EXISTS "ix_asset_valuations_asset_id" ON "accounting"."asset_valuations" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_asset_valuations_asset_component_id" ON "accounting"."asset_valuations" ("asset_component_id");

CREATE INDEX IF NOT EXISTS "ix_asset_valuations_depreciation_area_id" ON "accounting"."asset_valuations" ("depreciation_area_id");

CREATE INDEX IF NOT EXISTS "ix_asset_valuations_depreciation_method_concept_id" ON "accounting"."asset_valuations" ("depreciation_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_asset_valuations_created_by_user_id" ON "accounting"."asset_valuations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_valuations_updated_by_user_id" ON "accounting"."asset_valuations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_asset_id" ON "accounting"."asset_postings" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_asset_component_id" ON "accounting"."asset_postings" ("asset_component_id");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_ledger_entry_id" ON "accounting"."asset_postings" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_transaction_type_concept_id" ON "accounting"."asset_postings" ("transaction_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_currency_concept_id" ON "accounting"."asset_postings" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_created_by_user_id" ON "accounting"."asset_postings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_asset_value_date" ON "accounting"."asset_postings" ("asset_id", "asset_value_date");

CREATE INDEX IF NOT EXISTS "ix_asset_postings_ledger_asset" ON "accounting"."asset_postings" ("ledger_entry_id", "asset_id");

CREATE INDEX IF NOT EXISTS "brin_asset_postings_created_at" ON "accounting"."asset_postings" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_asset_id" ON "accounting"."asset_assignments" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_asset_component_id" ON "accounting"."asset_assignments" ("asset_component_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_branch_id" ON "accounting"."asset_assignments" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_department_id" ON "accounting"."asset_assignments" ("department_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_cost_center_id" ON "accounting"."asset_assignments" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_profit_center_id" ON "accounting"."asset_assignments" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_project_id" ON "accounting"."asset_assignments" ("project_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_wbs_element_id" ON "accounting"."asset_assignments" ("wbs_element_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_responsible_employee_id" ON "accounting"."asset_assignments" ("responsible_employee_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_created_by_user_id" ON "accounting"."asset_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_updated_by_user_id" ON "accounting"."asset_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_assignments_asset_valid_from" ON "accounting"."asset_assignments" ("asset_id", "valid_from" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_liability_schedules_liability_id_installment_number" ON "accounting"."liability_schedules" ("liability_id", "installment_number");

CREATE INDEX IF NOT EXISTS "ix_liability_schedules_liability_id" ON "accounting"."liability_schedules" ("liability_id");

CREATE INDEX IF NOT EXISTS "ix_liability_schedules_currency_concept_id" ON "accounting"."liability_schedules" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liability_schedules_status_concept_id" ON "accounting"."liability_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liability_schedules_created_by_user_id" ON "accounting"."liability_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liability_schedules_updated_by_user_id" ON "accounting"."liability_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liability_schedules_liability_status_due" ON "accounting"."liability_schedules" ("liability_id", "status_concept_id", "due_date");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_liability_id" ON "accounting"."liability_postings" ("liability_id");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_liability_schedule_id" ON "accounting"."liability_postings" ("liability_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_ledger_entry_id" ON "accounting"."liability_postings" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_component_concept_id" ON "accounting"."liability_postings" ("component_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_currency_concept_id" ON "accounting"."liability_postings" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_created_by_user_id" ON "accounting"."liability_postings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_liability_effective" ON "accounting"."liability_postings" ("liability_id", "effective_date");

CREATE INDEX IF NOT EXISTS "ix_liability_postings_ledger_liability" ON "accounting"."liability_postings" ("ledger_entry_id", "liability_id");

CREATE INDEX IF NOT EXISTS "brin_liability_postings_created_at" ON "accounting"."liability_postings" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_accrual_objects_tenant_id_object_number" ON "accounting"."accrual_objects" ("tenant_id", "object_number");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_tenant_id" ON "accounting"."accrual_objects" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_accrual_type_concept_id" ON "accounting"."accrual_objects" ("accrual_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_contract_id" ON "accounting"."accrual_objects" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_business_partner_id" ON "accounting"."accrual_objects" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_expense_account_id" ON "accounting"."accrual_objects" ("expense_account_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_accrual_account_id" ON "accounting"."accrual_objects" ("accrual_account_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_cost_center_id" ON "accounting"."accrual_objects" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_profit_center_id" ON "accounting"."accrual_objects" ("profit_center_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_currency_concept_id" ON "accounting"."accrual_objects" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_status_concept_id" ON "accounting"."accrual_objects" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_created_by_user_id" ON "accounting"."accrual_objects" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_updated_by_user_id" ON "accounting"."accrual_objects" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_objects_tenant_status" ON "accounting"."accrual_objects" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "gin_accrual_objects_search" ON "accounting"."accrual_objects" USING gin (to_tsvector('simple', (coalesce(object_number, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_accrual_schedule_lines_accrual_object_id_fiscal_period_id" ON "accounting"."accrual_schedule_lines" ("accrual_object_id", "fiscal_period_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_schedule_lines_accrual_object_id" ON "accounting"."accrual_schedule_lines" ("accrual_object_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_schedule_lines_fiscal_period_id" ON "accounting"."accrual_schedule_lines" ("fiscal_period_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_schedule_lines_currency_concept_id" ON "accounting"."accrual_schedule_lines" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_schedule_lines_status_concept_id" ON "accounting"."accrual_schedule_lines" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_schedule_lines_created_by_user_id" ON "accounting"."accrual_schedule_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_schedule_lines_updated_by_user_id" ON "accounting"."accrual_schedule_lines" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_accrual_postings_accrual_schedule_line_id_ledger_entry_id" ON "accounting"."accrual_postings" ("accrual_schedule_line_id", "ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_postings_accrual_schedule_line_id" ON "accounting"."accrual_postings" ("accrual_schedule_line_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_postings_ledger_entry_id" ON "accounting"."accrual_postings" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_postings_currency_concept_id" ON "accounting"."accrual_postings" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accrual_postings_created_by_user_id" ON "accounting"."accrual_postings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_accrual_postings_created_at" ON "accounting"."accrual_postings" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_exchange_rates_from_currency_concept_id" ON "accounting"."exchange_rates" ("from_currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_exchange_rates_to_currency_concept_id" ON "accounting"."exchange_rates" ("to_currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_exchange_rates_created_by_user_id" ON "accounting"."exchange_rates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_exchange_rates_updated_by_user_id" ON "accounting"."exchange_rates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_years_practice_id" ON "accounting"."fiscal_years" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_years_status_concept_id" ON "accounting"."fiscal_years" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_years_created_by_user_id" ON "accounting"."fiscal_years" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_years_updated_by_user_id" ON "accounting"."fiscal_years" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_periods_fiscal_year_id" ON "accounting"."fiscal_periods" ("fiscal_year_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_periods_status_concept_id" ON "accounting"."fiscal_periods" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_periods_created_by_user_id" ON "accounting"."fiscal_periods" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_fiscal_periods_updated_by_user_id" ON "accounting"."fiscal_periods" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_account_groups_practice_id" ON "accounting"."account_groups" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_account_groups_parent_group_id" ON "accounting"."account_groups" ("parent_group_id");

CREATE INDEX IF NOT EXISTS "ix_account_groups_account_type_concept_id" ON "accounting"."account_groups" ("account_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_groups_created_by_user_id" ON "accounting"."account_groups" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_account_groups_updated_by_user_id" ON "accounting"."account_groups" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_practice_id" ON "accounting"."accounts" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_account_group_id" ON "accounting"."accounts" ("account_group_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_account_type_concept_id" ON "accounting"."accounts" ("account_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_normal_balance_concept_id" ON "accounting"."accounts" ("normal_balance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_parent_account_id" ON "accounting"."accounts" ("parent_account_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_currency_concept_id" ON "accounting"."accounts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_status_concept_id" ON "accounting"."accounts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_created_by_user_id" ON "accounting"."accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_accounts_updated_by_user_id" ON "accounting"."accounts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cost_centers_practice_id" ON "accounting"."cost_centers" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_cost_centers_parent_cost_center_id" ON "accounting"."cost_centers" ("parent_cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_cost_centers_practitioner_profile_id" ON "accounting"."cost_centers" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_cost_centers_status_concept_id" ON "accounting"."cost_centers" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cost_centers_created_by_user_id" ON "accounting"."cost_centers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cost_centers_updated_by_user_id" ON "accounting"."cost_centers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cost_center_maps_practice_id" ON "accounting"."cost_center_maps" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_cost_center_maps_source_type_concept_id" ON "accounting"."cost_center_maps" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cost_center_maps_cost_center_id" ON "accounting"."cost_center_maps" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_cost_center_maps_created_by_user_id" ON "accounting"."cost_center_maps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cost_center_maps_updated_by_user_id" ON "accounting"."cost_center_maps" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_journal_transactions_transaction_number" ON "accounting"."journal_transactions" ("transaction_number");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_practice_id" ON "accounting"."journal_transactions" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_transaction_type_concept_id" ON "accounting"."journal_transactions" ("transaction_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_fiscal_period_id" ON "accounting"."journal_transactions" ("fiscal_period_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_currency_concept_id" ON "accounting"."journal_transactions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_status_concept_id" ON "accounting"."journal_transactions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_posted_by_user_id" ON "accounting"."journal_transactions" ("posted_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_created_by_user_id" ON "accounting"."journal_transactions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journal_transactions_updated_by_user_id" ON "accounting"."journal_transactions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ledger_entries_transaction_id" ON "accounting"."ledger_entries" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_ledger_entries_account_id" ON "accounting"."ledger_entries" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_ledger_entries_cost_center_id" ON "accounting"."ledger_entries" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_ledger_entries_direction_concept_id" ON "accounting"."ledger_entries" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ledger_entries_currency_concept_id" ON "accounting"."ledger_entries" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ledger_entries_created_by_user_id" ON "accounting"."ledger_entries" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ledger_entries_updated_by_user_id" ON "accounting"."ledger_entries" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_files_transaction_id" ON "accounting"."transaction_files" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_files_file_id" ON "accounting"."transaction_files" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_files_category_concept_id" ON "accounting"."transaction_files" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_files_created_by_user_id" ON "accounting"."transaction_files" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_transaction_files_updated_by_user_id" ON "accounting"."transaction_files" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sales_practice_id" ON "accounting"."sales" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_sales_transaction_id" ON "accounting"."sales" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_sales_customer_type_concept_id" ON "accounting"."sales" ("customer_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sales_invoice_id" ON "accounting"."sales" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_sales_status_concept_id" ON "accounting"."sales" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sales_created_by_user_id" ON "accounting"."sales" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sales_updated_by_user_id" ON "accounting"."sales" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchases_practice_id" ON "accounting"."purchases" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_purchases_transaction_id" ON "accounting"."purchases" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_purchases_vendor_id" ON "accounting"."purchases" ("vendor_id");

CREATE INDEX IF NOT EXISTS "ix_purchases_bill_id" ON "accounting"."purchases" ("bill_id");

CREATE INDEX IF NOT EXISTS "ix_purchases_status_concept_id" ON "accounting"."purchases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_purchases_created_by_user_id" ON "accounting"."purchases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_purchases_updated_by_user_id" ON "accounting"."purchases" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assets_practice_id" ON "accounting"."assets" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_assets_asset_type_concept_id" ON "accounting"."assets" ("asset_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assets_account_id" ON "accounting"."assets" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_assets_practice_id_account_id" ON "accounting"."assets" ("practice_id", "account_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assets_depreciation_method_concept_id" ON "accounting"."assets" ("depreciation_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assets_status_concept_id" ON "accounting"."assets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assets_created_by_user_id" ON "accounting"."assets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assets_updated_by_user_id" ON "accounting"."assets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_depreciations_asset_id" ON "accounting"."asset_depreciations" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_asset_depreciations_fiscal_period_id" ON "accounting"."asset_depreciations" ("fiscal_period_id");

CREATE INDEX IF NOT EXISTS "ix_asset_depreciations_transaction_id" ON "accounting"."asset_depreciations" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_asset_depreciations_created_by_user_id" ON "accounting"."asset_depreciations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_asset_depreciations_updated_by_user_id" ON "accounting"."asset_depreciations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_practice_id" ON "accounting"."liabilities" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_liability_type_concept_id" ON "accounting"."liabilities" ("liability_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_account_id" ON "accounting"."liabilities" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_practice_id_account_id" ON "accounting"."liabilities" ("practice_id", "account_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_status_concept_id" ON "accounting"."liabilities" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_created_by_user_id" ON "accounting"."liabilities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liabilities_updated_by_user_id" ON "accounting"."liabilities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liability_payments_liability_id" ON "accounting"."liability_payments" ("liability_id");

CREATE INDEX IF NOT EXISTS "ix_liability_payments_transaction_id" ON "accounting"."liability_payments" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_liability_payments_created_by_user_id" ON "accounting"."liability_payments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_liability_payments_updated_by_user_id" ON "accounting"."liability_payments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_practice_id" ON "accounting"."infrastructure_items" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_category_concept_id" ON "accounting"."infrastructure_items" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_asset_id" ON "accounting"."infrastructure_items" ("asset_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_branch_id" ON "accounting"."infrastructure_items" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_status_concept_id" ON "accounting"."infrastructure_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_created_by_user_id" ON "accounting"."infrastructure_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_updated_by_user_id" ON "accounting"."infrastructure_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employee_payments_employee_id" ON "accounting"."employee_payments" ("employee_id");

CREATE INDEX IF NOT EXISTS "ix_employee_payments_fiscal_period_id" ON "accounting"."employee_payments" ("fiscal_period_id");

CREATE INDEX IF NOT EXISTS "ix_employee_payments_transaction_id" ON "accounting"."employee_payments" ("transaction_id");

CREATE INDEX IF NOT EXISTS "ix_employee_payments_status_concept_id" ON "accounting"."employee_payments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_employee_payments_created_by_user_id" ON "accounting"."employee_payments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_employee_payments_updated_by_user_id" ON "accounting"."employee_payments" ("updated_by_user_id");
