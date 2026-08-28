-- SALUD v4.0.10 · módulo 16 · schema accounting
-- Generado de diagram_16_accounting.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_periods"
        ADD CONSTRAINT "fk_fiscal_periods_fiscal_year_id" FOREIGN KEY ("fiscal_year_id")
        REFERENCES "accounting"."fiscal_years" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_account_group_id" FOREIGN KEY ("account_group_id")
        REFERENCES "accounting"."account_groups" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_parent_account_id" FOREIGN KEY ("parent_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_parent_cost_center_id" FOREIGN KEY ("parent_cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."cost_center_maps"
        ADD CONSTRAINT "fk_cost_center_maps_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_fiscal_period_id" FOREIGN KEY ("fiscal_period_id")
        REFERENCES "accounting"."fiscal_periods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."ledger_entries"
        ADD CONSTRAINT "fk_ledger_entries_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."ledger_entries"
        ADD CONSTRAINT "fk_ledger_entries_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."ledger_entries"
        ADD CONSTRAINT "fk_ledger_entries_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."transaction_files"
        ADD CONSTRAINT "fk_transaction_files_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."sales"
        ADD CONSTRAINT "fk_sales_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."purchases"
        ADD CONSTRAINT "fk_purchases_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."assets"
        ADD CONSTRAINT "fk_assets_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_depreciations"
        ADD CONSTRAINT "fk_asset_depreciations_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_depreciations"
        ADD CONSTRAINT "fk_asset_depreciations_fiscal_period_id" FOREIGN KEY ("fiscal_period_id")
        REFERENCES "accounting"."fiscal_periods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_depreciations"
        ADD CONSTRAINT "fk_asset_depreciations_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."liabilities"
        ADD CONSTRAINT "fk_liabilities_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."liability_payments"
        ADD CONSTRAINT "fk_liability_payments_liability_id" FOREIGN KEY ("liability_id")
        REFERENCES "accounting"."liabilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."liability_payments"
        ADD CONSTRAINT "fk_liability_payments_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."employee_payments"
        ADD CONSTRAINT "fk_employee_payments_fiscal_period_id" FOREIGN KEY ("fiscal_period_id")
        REFERENCES "accounting"."fiscal_periods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."employee_payments"
        ADD CONSTRAINT "fk_employee_payments_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."segments"
        ADD CONSTRAINT "fk_segments_parent_segment_id" FOREIGN KEY ("parent_segment_id")
        REFERENCES "accounting"."segments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."functional_areas"
        ADD CONSTRAINT "fk_functional_areas_parent_functional_area_id" FOREIGN KEY ("parent_functional_area_id")
        REFERENCES "accounting"."functional_areas" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_controlling_area_id" FOREIGN KEY ("controlling_area_id")
        REFERENCES "accounting"."controlling_areas" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_parent_profit_center_id" FOREIGN KEY ("parent_profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_segment_id" FOREIGN KEY ("segment_id")
        REFERENCES "accounting"."segments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_controlling_area_id" FOREIGN KEY ("controlling_area_id")
        REFERENCES "accounting"."controlling_areas" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_responsible_cost_center_id" FOREIGN KEY ("responsible_cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_responsible_profit_center_id" FOREIGN KEY ("responsible_profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_clearing_account_id" FOREIGN KEY ("clearing_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_reconciliation_account_id" FOREIGN KEY ("reconciliation_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_ledger_entry_id" FOREIGN KEY ("ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_functional_area_id" FOREIGN KEY ("functional_area_id")
        REFERENCES "accounting"."functional_areas" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_segment_id" FOREIGN KEY ("segment_id")
        REFERENCES "accounting"."segments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_internal_order_id" FOREIGN KEY ("internal_order_id")
        REFERENCES "accounting"."internal_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_subledger_account_id" FOREIGN KEY ("subledger_account_id")
        REFERENCES "accounting"."subledger_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_asset_component_id" FOREIGN KEY ("asset_component_id")
        REFERENCES "accounting"."asset_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_liability_id" FOREIGN KEY ("liability_id")
        REFERENCES "accounting"."liabilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_company_bank_account_id" FOREIGN KEY ("company_bank_account_id")
        REFERENCES "accounting"."company_bank_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_derived_by_rule_id" FOREIGN KEY ("derived_by_rule_id")
        REFERENCES "accounting"."account_determination_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_asset_class_id" FOREIGN KEY ("asset_class_id")
        REFERENCES "accounting"."asset_classes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_target_account_id" FOREIGN KEY ("target_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accounting_document_links"
        ADD CONSTRAINT "fk_accounting_document_links_source_transaction_id" FOREIGN KEY ("source_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accounting_document_links"
        ADD CONSTRAINT "fk_accounting_document_links_target_transaction_id" FOREIGN KEY ("target_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accounting_document_links"
        ADD CONSTRAINT "fk_accounting_document_links_source_line_id" FOREIGN KEY ("source_line_id")
        REFERENCES "accounting"."accrual_schedule_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accounting_document_links"
        ADD CONSTRAINT "fk_accounting_document_links_target_line_id" FOREIGN KEY ("target_line_id")
        REFERENCES "accounting"."accrual_schedule_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_subledger_account_id" FOREIGN KEY ("subledger_account_id")
        REFERENCES "accounting"."subledger_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_ledger_entry_id" FOREIGN KEY ("ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_documents"
        ADD CONSTRAINT "fk_clearing_documents_transaction_id" FOREIGN KEY ("transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_documents"
        ADD CONSTRAINT "fk_clearing_documents_company_bank_account_id" FOREIGN KEY ("company_bank_account_id")
        REFERENCES "accounting"."company_bank_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_items"
        ADD CONSTRAINT "fk_clearing_items_clearing_document_id" FOREIGN KEY ("clearing_document_id")
        REFERENCES "accounting"."clearing_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_items"
        ADD CONSTRAINT "fk_clearing_items_open_item_id" FOREIGN KEY ("open_item_id")
        REFERENCES "accounting"."open_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_items"
        ADD CONSTRAINT "fk_clearing_items_residual_open_item_id" FOREIGN KEY ("residual_open_item_id")
        REFERENCES "accounting"."open_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_acquisition_account_id" FOREIGN KEY ("acquisition_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_accumulated_depreciation_account_id" FOREIGN KEY ("accumulated_depreciation_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_depreciation_expense_account_id" FOREIGN KEY ("depreciation_expense_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_gain_account_id" FOREIGN KEY ("gain_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_loss_account_id" FOREIGN KEY ("loss_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_components"
        ADD CONSTRAINT "fk_asset_components_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_components"
        ADD CONSTRAINT "fk_asset_components_asset_class_id" FOREIGN KEY ("asset_class_id")
        REFERENCES "accounting"."asset_classes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_valuations"
        ADD CONSTRAINT "fk_asset_valuations_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_valuations"
        ADD CONSTRAINT "fk_asset_valuations_asset_component_id" FOREIGN KEY ("asset_component_id")
        REFERENCES "accounting"."asset_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_valuations"
        ADD CONSTRAINT "fk_asset_valuations_depreciation_area_id" FOREIGN KEY ("depreciation_area_id")
        REFERENCES "accounting"."depreciation_areas" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_postings"
        ADD CONSTRAINT "fk_asset_postings_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_postings"
        ADD CONSTRAINT "fk_asset_postings_asset_component_id" FOREIGN KEY ("asset_component_id")
        REFERENCES "accounting"."asset_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_postings"
        ADD CONSTRAINT "fk_asset_postings_ledger_entry_id" FOREIGN KEY ("ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_asset_component_id" FOREIGN KEY ("asset_component_id")
        REFERENCES "accounting"."asset_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."liability_schedules"
        ADD CONSTRAINT "fk_liability_schedules_liability_id" FOREIGN KEY ("liability_id")
        REFERENCES "accounting"."liabilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."liability_postings"
        ADD CONSTRAINT "fk_liability_postings_liability_id" FOREIGN KEY ("liability_id")
        REFERENCES "accounting"."liabilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."liability_postings"
        ADD CONSTRAINT "fk_liability_postings_liability_schedule_id" FOREIGN KEY ("liability_schedule_id")
        REFERENCES "accounting"."liability_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."liability_postings"
        ADD CONSTRAINT "fk_liability_postings_ledger_entry_id" FOREIGN KEY ("ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_expense_account_id" FOREIGN KEY ("expense_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_accrual_account_id" FOREIGN KEY ("accrual_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_schedule_lines"
        ADD CONSTRAINT "fk_accrual_schedule_lines_accrual_object_id" FOREIGN KEY ("accrual_object_id")
        REFERENCES "accounting"."accrual_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_schedule_lines"
        ADD CONSTRAINT "fk_accrual_schedule_lines_fiscal_period_id" FOREIGN KEY ("fiscal_period_id")
        REFERENCES "accounting"."fiscal_periods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_postings"
        ADD CONSTRAINT "fk_accrual_postings_accrual_schedule_line_id" FOREIGN KEY ("accrual_schedule_line_id")
        REFERENCES "accounting"."accrual_schedule_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_postings"
        ADD CONSTRAINT "fk_accrual_postings_ledger_entry_id" FOREIGN KEY ("ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
