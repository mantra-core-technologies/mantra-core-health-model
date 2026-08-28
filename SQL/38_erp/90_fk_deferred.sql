-- SALUD v4.0.10 · módulo 38 · schema erp
-- Generado de diagram_38_erp.puml — NO editar a mano.


-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_person_user_id" FOREIGN KEY ("person_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_payment_method_concept_id" FOREIGN KEY ("payment_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."employees"
        ADD CONSTRAINT "fk_employees_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."departments"
        ADD CONSTRAINT "fk_departments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."departments"
        ADD CONSTRAINT "fk_departments_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."departments"
        ADD CONSTRAINT "fk_departments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."departments"
        ADD CONSTRAINT "fk_departments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."departments"
        ADD CONSTRAINT "fk_departments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."positions"
        ADD CONSTRAINT "fk_positions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."positions"
        ADD CONSTRAINT "fk_positions_job_family_concept_id" FOREIGN KEY ("job_family_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."positions"
        ADD CONSTRAINT "fk_positions_grade_concept_id" FOREIGN KEY ("grade_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."positions"
        ADD CONSTRAINT "fk_positions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."positions"
        ADD CONSTRAINT "fk_positions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."positions"
        ADD CONSTRAINT "fk_positions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_employment_type_concept_id" FOREIGN KEY ("employment_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."employment_records"
        ADD CONSTRAINT "fk_employment_records_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_assignment_type_concept_id" FOREIGN KEY ("assignment_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."employee_assignments"
        ADD CONSTRAINT "fk_employee_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."time_off_requests"
        ADD CONSTRAINT "fk_time_off_requests_leave_type_concept_id" FOREIGN KEY ("leave_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."time_off_requests"
        ADD CONSTRAINT "fk_time_off_requests_approver_user_id" FOREIGN KEY ("approver_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."time_off_requests"
        ADD CONSTRAINT "fk_time_off_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."time_off_requests"
        ADD CONSTRAINT "fk_time_off_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."time_off_requests"
        ADD CONSTRAINT "fk_time_off_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."performance_reviews"
        ADD CONSTRAINT "fk_performance_reviews_rating_concept_id" FOREIGN KEY ("rating_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."performance_reviews"
        ADD CONSTRAINT "fk_performance_reviews_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."performance_reviews"
        ADD CONSTRAINT "fk_performance_reviews_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."performance_reviews"
        ADD CONSTRAINT "fk_performance_reviews_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_contract_type_concept_id" FOREIGN KEY ("contract_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_counterparty_type_concept_id" FOREIGN KEY ("counterparty_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_renewal_type_concept_id" FOREIGN KEY ("renewal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_governing_jurisdiction_concept_id" FOREIGN KEY ("governing_jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.partnership_agreements (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_master_agreement_id" FOREIGN KEY ("master_agreement_id")
        REFERENCES "crm"."partnership_agreements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_owning_cost_center_id" FOREIGN KEY ("owning_cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_owning_profit_center_id" FOREIGN KEY ("owning_profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_approval_status_concept_id" FOREIGN KEY ("approval_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_signature_status_concept_id" FOREIGN KEY ("signature_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contracts"
        ADD CONSTRAINT "fk_contracts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_parties"
        ADD CONSTRAINT "fk_contract_parties_party_role_concept_id" FOREIGN KEY ("party_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_parties"
        ADD CONSTRAINT "fk_contract_parties_party_type_concept_id" FOREIGN KEY ("party_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_parties"
        ADD CONSTRAINT "fk_contract_parties_signatory_user_id" FOREIGN KEY ("signatory_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_parties"
        ADD CONSTRAINT "fk_contract_parties_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_parties"
        ADD CONSTRAINT "fk_contract_parties_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_line_items"
        ADD CONSTRAINT "fk_contract_line_items_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_line_items"
        ADD CONSTRAINT "fk_contract_line_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_line_items"
        ADD CONSTRAINT "fk_contract_line_items_recurrence_concept_id" FOREIGN KEY ("recurrence_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_line_items"
        ADD CONSTRAINT "fk_contract_line_items_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_line_items"
        ADD CONSTRAINT "fk_contract_line_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_line_items"
        ADD CONSTRAINT "fk_contract_line_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_milestones"
        ADD CONSTRAINT "fk_contract_milestones_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_milestones"
        ADD CONSTRAINT "fk_contract_milestones_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_milestones"
        ADD CONSTRAINT "fk_contract_milestones_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_milestones"
        ADD CONSTRAINT "fk_contract_milestones_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_documents"
        ADD CONSTRAINT "fk_contract_documents_document_type_concept_id" FOREIGN KEY ("document_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_documents"
        ADD CONSTRAINT "fk_contract_documents_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_documents"
        ADD CONSTRAINT "fk_contract_documents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_documents"
        ADD CONSTRAINT "fk_contract_documents_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_partner_category_concept_id" FOREIGN KEY ("partner_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_linked_tenant_id" FOREIGN KEY ("linked_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.persons (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_linked_person_id" FOREIGN KEY ("linked_person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partners"
        ADD CONSTRAINT "fk_business_partners_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_roles"
        ADD CONSTRAINT "fk_business_partner_roles_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_roles"
        ADD CONSTRAINT "fk_business_partner_roles_company_code_tenant_id" FOREIGN KEY ("company_code_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_roles"
        ADD CONSTRAINT "fk_business_partner_roles_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_roles"
        ADD CONSTRAINT "fk_business_partner_roles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_roles"
        ADD CONSTRAINT "fk_business_partner_roles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_relationships"
        ADD CONSTRAINT "fk_business_partner_relationships_relationship_type_concept_id" FOREIGN KEY ("relationship_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_relationships"
        ADD CONSTRAINT "fk_business_partner_relationships_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_relationships"
        ADD CONSTRAINT "fk_business_partner_relationships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_relationships"
        ADD CONSTRAINT "fk_business_partner_relationships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_tax_registrations"
        ADD CONSTRAINT "fk_business_partner_tax_registrations_tax_type_concept_id" FOREIGN KEY ("tax_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_tax_registrations"
        ADD CONSTRAINT "fk_business_partner_tax_registrations_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_tax_registrations"
        ADD CONSTRAINT "fk_business_partner_tax_registrations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_tax_registrations"
        ADD CONSTRAINT "fk_business_partner_tax_registrations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_bank_accounts"
        ADD CONSTRAINT "fk_business_partner_bank_accounts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_bank_accounts"
        ADD CONSTRAINT "fk_business_partner_bank_accounts_verification_status__769cb0dc" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_bank_accounts"
        ADD CONSTRAINT "fk_business_partner_bank_accounts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_bank_accounts"
        ADD CONSTRAINT "fk_business_partner_bank_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."business_partner_bank_accounts"
        ADD CONSTRAINT "fk_business_partner_bank_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_project_type_concept_id" FOREIGN KEY ("project_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."projects"
        ADD CONSTRAINT "fk_projects_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."wbs_elements"
        ADD CONSTRAINT "fk_wbs_elements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_approval_status_concept_id" FOREIGN KEY ("approval_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisitions"
        ADD CONSTRAINT "fk_purchase_requisitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_item_type_concept_id" FOREIGN KEY ("item_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.assets (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_requisition_items"
        ADD CONSTRAINT "fk_purchase_requisition_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_payment_terms_concept_id" FOREIGN KEY ("payment_terms_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_incoterm_concept_id" FOREIGN KEY ("incoterm_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_approval_status_concept_id" FOREIGN KEY ("approval_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_orders"
        ADD CONSTRAINT "fk_purchase_orders_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_item_type_concept_id" FOREIGN KEY ("item_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.tax_codes (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_tax_code_id" FOREIGN KEY ("tax_code_id")
        REFERENCES "billing"."tax_codes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_expense_account_id" FOREIGN KEY ("expense_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_inventory_account_id" FOREIGN KEY ("inventory_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.assets (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."purchase_order_items"
        ADD CONSTRAINT "fk_purchase_order_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipts"
        ADD CONSTRAINT "fk_goods_receipts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipts"
        ADD CONSTRAINT "fk_goods_receipts_receiving_branch_id" FOREIGN KEY ("receiving_branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipts"
        ADD CONSTRAINT "fk_goods_receipts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipts"
        ADD CONSTRAINT "fk_goods_receipts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipts"
        ADD CONSTRAINT "fk_goods_receipts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy_inventory.inventory_ledger_entries (requiere schema pharmacy_inventory)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipt_items"
        ADD CONSTRAINT "fk_goods_receipt_items_inventory_ledger_entry_id" FOREIGN KEY ("inventory_ledger_entry_id")
        REFERENCES "pharmacy_inventory"."inventory_ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.assets (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipt_items"
        ADD CONSTRAINT "fk_goods_receipt_items_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipt_items"
        ADD CONSTRAINT "fk_goods_receipt_items_quality_status_concept_id" FOREIGN KEY ("quality_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipt_items"
        ADD CONSTRAINT "fk_goods_receipt_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."goods_receipt_items"
        ADD CONSTRAINT "fk_goods_receipt_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_approval_status_concept_id" FOREIGN KEY ("approval_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_sheets"
        ADD CONSTRAINT "fk_service_entry_sheets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."service_entry_items"
        ADD CONSTRAINT "fk_service_entry_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.bills (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_match_type_concept_id" FOREIGN KEY ("match_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_runs"
        ADD CONSTRAINT "fk_invoice_match_runs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.bill_lines (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_bill_line_id" FOREIGN KEY ("bill_line_id")
        REFERENCES "billing"."bill_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_tolerance_rule_concept_id" FOREIGN KEY ("tolerance_rule_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."invoice_match_items"
        ADD CONSTRAINT "fk_invoice_match_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.opportunities (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_opportunity_id" FOREIGN KEY ("opportunity_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_payment_terms_concept_id" FOREIGN KEY ("payment_terms_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_orders"
        ADD CONSTRAINT "fk_sales_orders_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.tax_codes (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_tax_code_id" FOREIGN KEY ("tax_code_id")
        REFERENCES "billing"."tax_codes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_income_account_id" FOREIGN KEY ("income_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."sales_order_items"
        ADD CONSTRAINT "fk_sales_order_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."enterprise_document_flow"
        ADD CONSTRAINT "fk_enterprise_document_flow_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."enterprise_document_flow"
        ADD CONSTRAINT "fk_enterprise_document_flow_predecessor_type_concept_id" FOREIGN KEY ("predecessor_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."enterprise_document_flow"
        ADD CONSTRAINT "fk_enterprise_document_flow_successor_type_concept_id" FOREIGN KEY ("successor_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."enterprise_document_flow"
        ADD CONSTRAINT "fk_enterprise_document_flow_relation_type_concept_id" FOREIGN KEY ("relation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."enterprise_document_flow"
        ADD CONSTRAINT "fk_enterprise_document_flow_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."enterprise_document_flow"
        ADD CONSTRAINT "fk_enterprise_document_flow_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_versions"
        ADD CONSTRAINT "fk_contract_versions_version_type_concept_id" FOREIGN KEY ("version_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_versions"
        ADD CONSTRAINT "fk_contract_versions_main_document_file_id" FOREIGN KEY ("main_document_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_versions"
        ADD CONSTRAINT "fk_contract_versions_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_versions"
        ADD CONSTRAINT "fk_contract_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_versions"
        ADD CONSTRAINT "fk_contract_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_amendment_type_concept_id" FOREIGN KEY ("amendment_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_amendments"
        ADD CONSTRAINT "fk_contract_amendments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clauses"
        ADD CONSTRAINT "fk_contract_clauses_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clauses"
        ADD CONSTRAINT "fk_contract_clauses_clause_type_concept_id" FOREIGN KEY ("clause_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clauses"
        ADD CONSTRAINT "fk_contract_clauses_risk_level_concept_id" FOREIGN KEY ("risk_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clauses"
        ADD CONSTRAINT "fk_contract_clauses_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clauses"
        ADD CONSTRAINT "fk_contract_clauses_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clauses"
        ADD CONSTRAINT "fk_contract_clauses_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clause_instances"
        ADD CONSTRAINT "fk_contract_clause_instances_deviation_type_concept_id" FOREIGN KEY ("deviation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clause_instances"
        ADD CONSTRAINT "fk_contract_clause_instances_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clause_instances"
        ADD CONSTRAINT "fk_contract_clause_instances_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clause_instances"
        ADD CONSTRAINT "fk_contract_clause_instances_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_clause_instances"
        ADD CONSTRAINT "fk_contract_clause_instances_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_obligation_type_concept_id" FOREIGN KEY ("obligation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_responsible_user_id" FOREIGN KEY ("responsible_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligations"
        ADD CONSTRAINT "fk_contract_obligations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligation_events"
        ADD CONSTRAINT "fk_contract_obligation_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligation_events"
        ADD CONSTRAINT "fk_contract_obligation_events_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligation_events"
        ADD CONSTRAINT "fk_contract_obligation_events_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_obligation_events"
        ADD CONSTRAINT "fk_contract_obligation_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_renewal_type_concept_id" FOREIGN KEY ("renewal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_initiated_by_user_id" FOREIGN KEY ("initiated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_decision_by_user_id" FOREIGN KEY ("decision_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_renewals"
        ADD CONSTRAINT "fk_contract_renewals_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_termination_type_concept_id" FOREIGN KEY ("termination_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_initiated_by_user_id" FOREIGN KEY ("initiated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_terminations"
        ADD CONSTRAINT "fk_contract_terminations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_team_members"
        ADD CONSTRAINT "fk_contract_team_members_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_team_members"
        ADD CONSTRAINT "fk_contract_team_members_team_role_concept_id" FOREIGN KEY ("team_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_team_members"
        ADD CONSTRAINT "fk_contract_team_members_responsibility_scope_concept_id" FOREIGN KEY ("responsibility_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_team_members"
        ADD CONSTRAINT "fk_contract_team_members_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_team_members"
        ADD CONSTRAINT "fk_contract_team_members_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_requests"
        ADD CONSTRAINT "fk_contract_approval_requests_approval_type_concept_id" FOREIGN KEY ("approval_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_requests"
        ADD CONSTRAINT "fk_contract_approval_requests_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: workflow.workflow_instances (requiere schema workflow)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_requests"
        ADD CONSTRAINT "fk_contract_approval_requests_workflow_instance_id" FOREIGN KEY ("workflow_instance_id")
        REFERENCES "workflow"."workflow_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_requests"
        ADD CONSTRAINT "fk_contract_approval_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_steps"
        ADD CONSTRAINT "fk_contract_approval_steps_approver_user_id" FOREIGN KEY ("approver_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_steps"
        ADD CONSTRAINT "fk_contract_approval_steps_approver_team_role_concept_id" FOREIGN KEY ("approver_team_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_steps"
        ADD CONSTRAINT "fk_contract_approval_steps_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_approval_steps"
        ADD CONSTRAINT "fk_contract_approval_steps_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_assignment_role_concept_id" FOREIGN KEY ("assignment_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.assets (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_asset_id" FOREIGN KEY ("asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.liabilities (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_liability_id" FOREIGN KEY ("liability_id")
        REFERENCES "accounting"."liabilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_object_assignments"
        ADD CONSTRAINT "fk_contract_object_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_accounting_treatment_concept_id" FOREIGN KEY ("accounting_treatment_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_expense_account_id" FOREIGN KEY ("expense_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_revenue_account_id" FOREIGN KEY ("revenue_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_accrual_account_id" FOREIGN KEY ("accrual_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_asset_account_id" FOREIGN KEY ("asset_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_liability_account_id" FOREIGN KEY ("liability_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.profit_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_profit_center_id" FOREIGN KEY ("profit_center_id")
        REFERENCES "accounting"."profit_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.tax_codes (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_tax_code_id" FOREIGN KEY ("tax_code_id")
        REFERENCES "billing"."tax_codes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_accounting_terms"
        ADD CONSTRAINT "fk_contract_accounting_terms_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_payment_direction_concept_id" FOREIGN KEY ("payment_direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.bills (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."contract_payment_schedules"
        ADD CONSTRAINT "fk_contract_payment_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_contracts"
        ADD CONSTRAINT "fk_lease_contracts_lease_role_concept_id" FOREIGN KEY ("lease_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_contracts"
        ADD CONSTRAINT "fk_lease_contracts_accounting_principle_concept_id" FOREIGN KEY ("accounting_principle_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_contracts"
        ADD CONSTRAINT "fk_lease_contracts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_contracts"
        ADD CONSTRAINT "fk_lease_contracts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_contracts"
        ADD CONSTRAINT "fk_lease_contracts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_contracts"
        ADD CONSTRAINT "fk_lease_contracts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_object_type_concept_id" FOREIGN KEY ("object_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.assets (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_source_asset_id" FOREIGN KEY ("source_asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_objects"
        ADD CONSTRAINT "fk_lease_objects_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_flow_type_concept_id" FOREIGN KEY ("flow_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_index_reference_concept_id" FOREIGN KEY ("index_reference_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_cash_flows"
        ADD CONSTRAINT "fk_lease_cash_flows_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_valuations"
        ADD CONSTRAINT "fk_lease_valuations_accounting_principle_concept_id" FOREIGN KEY ("accounting_principle_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_valuations"
        ADD CONSTRAINT "fk_lease_valuations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_valuations"
        ADD CONSTRAINT "fk_lease_valuations_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_valuations"
        ADD CONSTRAINT "fk_lease_valuations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_valuations"
        ADD CONSTRAINT "fk_lease_valuations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.assets (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_right_of_use_asset_id" FOREIGN KEY ("right_of_use_asset_id")
        REFERENCES "accounting"."assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.liabilities (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_lease_liability_id" FOREIGN KEY ("lease_liability_id")
        REFERENCES "accounting"."liabilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_right_of_use_asset_account_id" FOREIGN KEY ("right_of_use_asset_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_lease_liability_account_id" FOREIGN KEY ("lease_liability_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_interest_expense_account_id" FOREIGN KEY ("interest_expense_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_depreciation_expense_account_id" FOREIGN KEY ("depreciation_expense_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "erp"."lease_accounting_links"
        ADD CONSTRAINT "fk_lease_accounting_links_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
