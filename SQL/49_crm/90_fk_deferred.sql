-- SALUD v4.0.10 · módulo 49 · schema crm
-- Generado de diagram_49_crm.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_account_type_concept_id" FOREIGN KEY ("account_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_industry_concept_id" FOREIGN KEY ("industry_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.accounts (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_parent_account_id" FOREIGN KEY ("parent_account_id")
        REFERENCES "accounting"."accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_linked_tenant_id" FOREIGN KEY ("linked_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_accounts"
        ADD CONSTRAINT "fk_crm_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_contact_type_concept_id" FOREIGN KEY ("contact_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_linked_user_id" FOREIGN KEY ("linked_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_lifecycle_stage_concept_id" FOREIGN KEY ("lifecycle_stage_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: consent.consents (requiere schema consent)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_marketing_consent_id" FOREIGN KEY ("marketing_consent_id")
        REFERENCES "consent"."consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channels"
        ADD CONSTRAINT "fk_contact_channels_channel_type_concept_id" FOREIGN KEY ("channel_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channels"
        ADD CONSTRAINT "fk_contact_channels_opt_in_status_concept_id" FOREIGN KEY ("opt_in_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channels"
        ADD CONSTRAINT "fk_contact_channels_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channels"
        ADD CONSTRAINT "fk_contact_channels_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_lead_source_concept_id" FOREIGN KEY ("lead_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_lead_status_concept_id" FOREIGN KEY ("lead_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."pipelines"
        ADD CONSTRAINT "fk_pipelines_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."pipelines"
        ADD CONSTRAINT "fk_pipelines_pipeline_type_concept_id" FOREIGN KEY ("pipeline_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."pipelines"
        ADD CONSTRAINT "fk_pipelines_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."pipelines"
        ADD CONSTRAINT "fk_pipelines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."pipelines"
        ADD CONSTRAINT "fk_pipelines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."pipeline_stages"
        ADD CONSTRAINT "fk_pipeline_stages_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."pipeline_stages"
        ADD CONSTRAINT "fk_pipeline_stages_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.sales_orders (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_sales_order_id" FOREIGN KEY ("sales_order_id")
        REFERENCES "erp"."sales_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_lost_reason_concept_id" FOREIGN KEY ("lost_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_activity_type_concept_id" FOREIGN KEY ("activity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_direction_concept_id" FOREIGN KEY ("direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_partnership_type_concept_id" FOREIGN KEY ("partnership_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.ad_partners (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_ad_partner_id" FOREIGN KEY ("ad_partner_id")
        REFERENCES "ads"."ad_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_tier_concept_id" FOREIGN KEY ("tier_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_agreement_type_concept_id" FOREIGN KEY ("agreement_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_document_file_id" FOREIGN KEY ("document_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."account_contact_relations"
        ADD CONSTRAINT "fk_account_contact_relations_relation_role_concept_id" FOREIGN KEY ("relation_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."account_contact_relations"
        ADD CONSTRAINT "fk_account_contact_relations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."account_contact_relations"
        ADD CONSTRAINT "fk_account_contact_relations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."account_contact_relations"
        ADD CONSTRAINT "fk_account_contact_relations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."account_team_members"
        ADD CONSTRAINT "fk_account_team_members_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."account_team_members"
        ADD CONSTRAINT "fk_account_team_members_team_role_concept_id" FOREIGN KEY ("team_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."account_team_members"
        ADD CONSTRAINT "fk_account_team_members_access_level_concept_id" FOREIGN KEY ("access_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."account_team_members"
        ADD CONSTRAINT "fk_account_team_members_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."account_team_members"
        ADD CONSTRAINT "fk_account_team_members_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_contact_roles"
        ADD CONSTRAINT "fk_opportunity_contact_roles_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_contact_roles"
        ADD CONSTRAINT "fk_opportunity_contact_roles_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_contact_roles"
        ADD CONSTRAINT "fk_opportunity_contact_roles_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_line_items"
        ADD CONSTRAINT "fk_opportunity_line_items_product_or_service_type_concept_id" FOREIGN KEY ("product_or_service_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_line_items"
        ADD CONSTRAINT "fk_opportunity_line_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contract_line_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_line_items"
        ADD CONSTRAINT "fk_opportunity_line_items_contract_line_item_id" FOREIGN KEY ("contract_line_item_id")
        REFERENCES "erp"."contract_line_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_line_items"
        ADD CONSTRAINT "fk_opportunity_line_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_line_items"
        ADD CONSTRAINT "fk_opportunity_line_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_line_items"
        ADD CONSTRAINT "fk_opportunity_line_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_stage_history"
        ADD CONSTRAINT "fk_opportunity_stage_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_stage_history"
        ADD CONSTRAINT "fk_opportunity_stage_history_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_relation_kind_concept_id" FOREIGN KEY ("relation_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_related_entity_type_concept_id" FOREIGN KEY ("related_entity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_related_user_id" FOREIGN KEY ("related_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_participant_role_concept_id" FOREIGN KEY ("participant_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_response_status_concept_id" FOREIGN KEY ("response_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_assignments"
        ADD CONSTRAINT "fk_crm_activity_assignments_assignee_user_id" FOREIGN KEY ("assignee_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_assignments"
        ADD CONSTRAINT "fk_crm_activity_assignments_assignment_role_concept_id" FOREIGN KEY ("assignment_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_assignments"
        ADD CONSTRAINT "fk_crm_activity_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_assignments"
        ADD CONSTRAINT "fk_crm_activity_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_tasks"
        ADD CONSTRAINT "fk_crm_tasks_task_subtype_concept_id" FOREIGN KEY ("task_subtype_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_tasks"
        ADD CONSTRAINT "fk_crm_tasks_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_tasks"
        ADD CONSTRAINT "fk_crm_tasks_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_tasks"
        ADD CONSTRAINT "fk_crm_tasks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_tasks"
        ADD CONSTRAINT "fk_crm_tasks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_event_subtype_concept_id" FOREIGN KEY ("event_subtype_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_organizer_user_id" FOREIGN KEY ("organizer_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_recurrence_rules"
        ADD CONSTRAINT "fk_crm_recurrence_rules_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_recurrence_rules"
        ADD CONSTRAINT "fk_crm_recurrence_rules_recurrence_frequency_concept_id" FOREIGN KEY ("recurrence_frequency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_recurrence_rules"
        ADD CONSTRAINT "fk_crm_recurrence_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_recurrence_rules"
        ADD CONSTRAINT "fk_crm_recurrence_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_reminders"
        ADD CONSTRAINT "fk_crm_activity_reminders_recipient_user_id" FOREIGN KEY ("recipient_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_reminders"
        ADD CONSTRAINT "fk_crm_activity_reminders_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_reminders"
        ADD CONSTRAINT "fk_crm_activity_reminders_delivery_status_concept_id" FOREIGN KEY ("delivery_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_reminders"
        ADD CONSTRAINT "fk_crm_activity_reminders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_messages"
        ADD CONSTRAINT "fk_crm_email_messages_body_html_file_id" FOREIGN KEY ("body_html_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_messages"
        ADD CONSTRAINT "fk_crm_email_messages_delivery_status_concept_id" FOREIGN KEY ("delivery_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_messages"
        ADD CONSTRAINT "fk_crm_email_messages_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_recipients"
        ADD CONSTRAINT "fk_crm_email_recipients_recipient_type_concept_id" FOREIGN KEY ("recipient_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_recipients"
        ADD CONSTRAINT "fk_crm_email_recipients_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_recipients"
        ADD CONSTRAINT "fk_crm_email_recipients_delivery_status_concept_id" FOREIGN KEY ("delivery_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_call_logs"
        ADD CONSTRAINT "fk_crm_call_logs_call_direction_concept_id" FOREIGN KEY ("call_direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_call_logs"
        ADD CONSTRAINT "fk_crm_call_logs_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_call_logs"
        ADD CONSTRAINT "fk_crm_call_logs_recording_file_id" FOREIGN KEY ("recording_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_call_logs"
        ADD CONSTRAINT "fk_crm_call_logs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_notes"
        ADD CONSTRAINT "fk_crm_notes_document_file_id" FOREIGN KEY ("document_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_notes"
        ADD CONSTRAINT "fk_crm_notes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_notes"
        ADD CONSTRAINT "fk_crm_notes_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.invoices (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_case_type_concept_id" FOREIGN KEY ("case_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_origin_concept_id" FOREIGN KEY ("origin_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_contacts"
        ADD CONSTRAINT "fk_crm_case_contacts_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_contacts"
        ADD CONSTRAINT "fk_crm_case_contacts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_comments"
        ADD CONSTRAINT "fk_crm_case_comments_author_user_id" FOREIGN KEY ("author_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_comments"
        ADD CONSTRAINT "fk_crm_case_comments_attachment_file_id" FOREIGN KEY ("attachment_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_status_history"
        ADD CONSTRAINT "fk_crm_case_status_history_from_status_concept_id" FOREIGN KEY ("from_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_status_history"
        ADD CONSTRAINT "fk_crm_case_status_history_to_status_concept_id" FOREIGN KEY ("to_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_status_history"
        ADD CONSTRAINT "fk_crm_case_status_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_entitlement_type_concept_id" FOREIGN KEY ("entitlement_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_milestones"
        ADD CONSTRAINT "fk_crm_case_milestones_milestone_type_concept_id" FOREIGN KEY ("milestone_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_milestones"
        ADD CONSTRAINT "fk_crm_case_milestones_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_milestones"
        ADD CONSTRAINT "fk_crm_case_milestones_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_milestones"
        ADD CONSTRAINT "fk_crm_case_milestones_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_endpoint_type_concept_id" FOREIGN KEY ("endpoint_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_deliverability_status_concept_id" FOREIGN KEY ("deliverability_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
