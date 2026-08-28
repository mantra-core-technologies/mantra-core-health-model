-- SALUD v4.0.10 · módulo 16 · schema accounting
-- Generado de diagram_16_accounting.puml — NO editar a mano.


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."exchange_rates"
        ADD CONSTRAINT "fk_exchange_rates_from_currency_concept_id" FOREIGN KEY ("from_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."exchange_rates"
        ADD CONSTRAINT "fk_exchange_rates_to_currency_concept_id" FOREIGN KEY ("to_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."exchange_rates"
        ADD CONSTRAINT "fk_exchange_rates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."exchange_rates"
        ADD CONSTRAINT "fk_exchange_rates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_years"
        ADD CONSTRAINT "fk_fiscal_years_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_years"
        ADD CONSTRAINT "fk_fiscal_years_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_years"
        ADD CONSTRAINT "fk_fiscal_years_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_years"
        ADD CONSTRAINT "fk_fiscal_years_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_periods"
        ADD CONSTRAINT "fk_fiscal_periods_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_periods"
        ADD CONSTRAINT "fk_fiscal_periods_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."fiscal_periods"
        ADD CONSTRAINT "fk_fiscal_periods_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_groups"
        ADD CONSTRAINT "fk_account_groups_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.groups (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_groups"
        ADD CONSTRAINT "fk_account_groups_parent_group_id" FOREIGN KEY ("parent_group_id")
        REFERENCES "community"."groups" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_groups"
        ADD CONSTRAINT "fk_account_groups_account_type_concept_id" FOREIGN KEY ("account_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_groups"
        ADD CONSTRAINT "fk_account_groups_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_groups"
        ADD CONSTRAINT "fk_account_groups_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_account_type_concept_id" FOREIGN KEY ("account_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_normal_balance_concept_id" FOREIGN KEY ("normal_balance_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounts"
        ADD CONSTRAINT "fk_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_center_maps"
        ADD CONSTRAINT "fk_cost_center_maps_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_center_maps"
        ADD CONSTRAINT "fk_cost_center_maps_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_center_maps"
        ADD CONSTRAINT "fk_cost_center_maps_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_center_maps"
        ADD CONSTRAINT "fk_cost_center_maps_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_transaction_type_concept_id" FOREIGN KEY ("transaction_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_posted_by_user_id" FOREIGN KEY ("posted_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_transactions"
        ADD CONSTRAINT "fk_journal_transactions_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."ledger_entries"
        ADD CONSTRAINT "fk_ledger_entries_direction_concept_id" FOREIGN KEY ("direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."ledger_entries"
        ADD CONSTRAINT "fk_ledger_entries_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."ledger_entries"
        ADD CONSTRAINT "fk_ledger_entries_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."ledger_entries"
        ADD CONSTRAINT "fk_ledger_entries_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "accounting"."transaction_files"
        ADD CONSTRAINT "fk_transaction_files_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."transaction_files"
        ADD CONSTRAINT "fk_transaction_files_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."transaction_files"
        ADD CONSTRAINT "fk_transaction_files_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."transaction_files"
        ADD CONSTRAINT "fk_transaction_files_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."sales"
        ADD CONSTRAINT "fk_sales_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."sales"
        ADD CONSTRAINT "fk_sales_customer_type_concept_id" FOREIGN KEY ("customer_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."sales"
        ADD CONSTRAINT "fk_sales_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."sales"
        ADD CONSTRAINT "fk_sales_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."sales"
        ADD CONSTRAINT "fk_sales_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."sales"
        ADD CONSTRAINT "fk_sales_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."purchases"
        ADD CONSTRAINT "fk_purchases_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.vendors (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."purchases"
        ADD CONSTRAINT "fk_purchases_vendor_id" FOREIGN KEY ("vendor_id")
        REFERENCES "billing"."vendors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.bills (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."purchases"
        ADD CONSTRAINT "fk_purchases_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."purchases"
        ADD CONSTRAINT "fk_purchases_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."purchases"
        ADD CONSTRAINT "fk_purchases_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."purchases"
        ADD CONSTRAINT "fk_purchases_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."assets"
        ADD CONSTRAINT "fk_assets_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."assets"
        ADD CONSTRAINT "fk_assets_asset_type_concept_id" FOREIGN KEY ("asset_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."assets"
        ADD CONSTRAINT "fk_assets_depreciation_method_concept_id" FOREIGN KEY ("depreciation_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."assets"
        ADD CONSTRAINT "fk_assets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."assets"
        ADD CONSTRAINT "fk_assets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."assets"
        ADD CONSTRAINT "fk_assets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_depreciations"
        ADD CONSTRAINT "fk_asset_depreciations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_depreciations"
        ADD CONSTRAINT "fk_asset_depreciations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."liabilities"
        ADD CONSTRAINT "fk_liabilities_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."liabilities"
        ADD CONSTRAINT "fk_liabilities_liability_type_concept_id" FOREIGN KEY ("liability_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."liabilities"
        ADD CONSTRAINT "fk_liabilities_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."liabilities"
        ADD CONSTRAINT "fk_liabilities_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."liabilities"
        ADD CONSTRAINT "fk_liabilities_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_payments"
        ADD CONSTRAINT "fk_liability_payments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_payments"
        ADD CONSTRAINT "fk_liability_payments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.employees (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."employee_payments"
        ADD CONSTRAINT "fk_employee_payments_employee_id" FOREIGN KEY ("employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."employee_payments"
        ADD CONSTRAINT "fk_employee_payments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."employee_payments"
        ADD CONSTRAINT "fk_employee_payments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."employee_payments"
        ADD CONSTRAINT "fk_employee_payments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."controlling_areas"
        ADD CONSTRAINT "fk_controlling_areas_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."controlling_areas"
        ADD CONSTRAINT "fk_controlling_areas_operating_currency_concept_id" FOREIGN KEY ("operating_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."controlling_areas"
        ADD CONSTRAINT "fk_controlling_areas_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."controlling_areas"
        ADD CONSTRAINT "fk_controlling_areas_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."controlling_areas"
        ADD CONSTRAINT "fk_controlling_areas_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."segments"
        ADD CONSTRAINT "fk_segments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."segments"
        ADD CONSTRAINT "fk_segments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."segments"
        ADD CONSTRAINT "fk_segments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."segments"
        ADD CONSTRAINT "fk_segments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."functional_areas"
        ADD CONSTRAINT "fk_functional_areas_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."functional_areas"
        ADD CONSTRAINT "fk_functional_areas_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."functional_areas"
        ADD CONSTRAINT "fk_functional_areas_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."functional_areas"
        ADD CONSTRAINT "fk_functional_areas_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.employees (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_responsible_employee_id" FOREIGN KEY ("responsible_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."profit_centers"
        ADD CONSTRAINT "fk_profit_centers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_order_type_concept_id" FOREIGN KEY ("order_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.projects (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.wbs_elements (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."internal_orders"
        ADD CONSTRAINT "fk_internal_orders_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."company_bank_accounts"
        ADD CONSTRAINT "fk_company_bank_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_subledger_role_concept_id" FOREIGN KEY ("subledger_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_payment_terms_concept_id" FOREIGN KEY ("payment_terms_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_dunning_procedure_concept_id" FOREIGN KEY ("dunning_procedure_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."subledger_accounts"
        ADD CONSTRAINT "fk_subledger_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.departments (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_department_id" FOREIGN KEY ("department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.projects (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.wbs_elements (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.bills (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.purchase_order_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_purchase_order_item_id" FOREIGN KEY ("purchase_order_item_id")
        REFERENCES "erp"."purchase_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.goods_receipt_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_goods_receipt_item_id" FOREIGN KEY ("goods_receipt_item_id")
        REFERENCES "erp"."goods_receipt_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.sales_order_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_sales_order_item_id" FOREIGN KEY ("sales_order_item_id")
        REFERENCES "erp"."sales_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.employees (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_employee_id" FOREIGN KEY ("employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_assignment_source_concept_id" FOREIGN KEY ("assignment_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."journal_entry_assignments"
        ADD CONSTRAINT "fk_journal_entry_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_posting_scenario_concept_id" FOREIGN KEY ("posting_scenario_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_account_role_concept_id" FOREIGN KEY ("account_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_liability_type_concept_id" FOREIGN KEY ("liability_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_contract_type_concept_id" FOREIGN KEY ("contract_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.tax_codes (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_tax_code_id" FOREIGN KEY ("tax_code_id")
        REFERENCES "billing"."tax_codes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."account_determination_rules"
        ADD CONSTRAINT "fk_account_determination_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounting_document_links"
        ADD CONSTRAINT "fk_accounting_document_links_relation_type_concept_id" FOREIGN KEY ("relation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accounting_document_links"
        ADD CONSTRAINT "fk_accounting_document_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_document_type_concept_id" FOREIGN KEY ("document_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.bills (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."open_items"
        ADD CONSTRAINT "fk_open_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_documents"
        ADD CONSTRAINT "fk_clearing_documents_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_documents"
        ADD CONSTRAINT "fk_clearing_documents_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_documents"
        ADD CONSTRAINT "fk_clearing_documents_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_documents"
        ADD CONSTRAINT "fk_clearing_documents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_items"
        ADD CONSTRAINT "fk_clearing_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."clearing_items"
        ADD CONSTRAINT "fk_clearing_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_asset_type_concept_id" FOREIGN KEY ("asset_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_classes"
        ADD CONSTRAINT "fk_asset_classes_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_components"
        ADD CONSTRAINT "fk_asset_components_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_components"
        ADD CONSTRAINT "fk_asset_components_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_components"
        ADD CONSTRAINT "fk_asset_components_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."depreciation_areas"
        ADD CONSTRAINT "fk_depreciation_areas_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."depreciation_areas"
        ADD CONSTRAINT "fk_depreciation_areas_accounting_principle_concept_id" FOREIGN KEY ("accounting_principle_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."depreciation_areas"
        ADD CONSTRAINT "fk_depreciation_areas_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."depreciation_areas"
        ADD CONSTRAINT "fk_depreciation_areas_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."depreciation_areas"
        ADD CONSTRAINT "fk_depreciation_areas_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."depreciation_areas"
        ADD CONSTRAINT "fk_depreciation_areas_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_valuations"
        ADD CONSTRAINT "fk_asset_valuations_depreciation_method_concept_id" FOREIGN KEY ("depreciation_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_valuations"
        ADD CONSTRAINT "fk_asset_valuations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_valuations"
        ADD CONSTRAINT "fk_asset_valuations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_postings"
        ADD CONSTRAINT "fk_asset_postings_transaction_type_concept_id" FOREIGN KEY ("transaction_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_postings"
        ADD CONSTRAINT "fk_asset_postings_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_postings"
        ADD CONSTRAINT "fk_asset_postings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.departments (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_department_id" FOREIGN KEY ("department_id")
        REFERENCES "erp"."departments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.projects (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_project_id" FOREIGN KEY ("project_id")
        REFERENCES "erp"."projects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.wbs_elements (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_wbs_element_id" FOREIGN KEY ("wbs_element_id")
        REFERENCES "erp"."wbs_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.employees (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_responsible_employee_id" FOREIGN KEY ("responsible_employee_id")
        REFERENCES "erp"."employees" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."asset_assignments"
        ADD CONSTRAINT "fk_asset_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_schedules"
        ADD CONSTRAINT "fk_liability_schedules_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_schedules"
        ADD CONSTRAINT "fk_liability_schedules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_schedules"
        ADD CONSTRAINT "fk_liability_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_schedules"
        ADD CONSTRAINT "fk_liability_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_postings"
        ADD CONSTRAINT "fk_liability_postings_component_concept_id" FOREIGN KEY ("component_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_postings"
        ADD CONSTRAINT "fk_liability_postings_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."liability_postings"
        ADD CONSTRAINT "fk_liability_postings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_accrual_type_concept_id" FOREIGN KEY ("accrual_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_objects"
        ADD CONSTRAINT "fk_accrual_objects_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_schedule_lines"
        ADD CONSTRAINT "fk_accrual_schedule_lines_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_schedule_lines"
        ADD CONSTRAINT "fk_accrual_schedule_lines_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_schedule_lines"
        ADD CONSTRAINT "fk_accrual_schedule_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_schedule_lines"
        ADD CONSTRAINT "fk_accrual_schedule_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_postings"
        ADD CONSTRAINT "fk_accrual_postings_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."accrual_postings"
        ADD CONSTRAINT "fk_accrual_postings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
