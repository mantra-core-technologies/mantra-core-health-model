-- SALUD v4.0.10 · módulo 26 · schema insurance
-- Generado de diagram_26_insurance.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_carriers"
        ADD CONSTRAINT "fk_insurance_carriers_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_carriers"
        ADD CONSTRAINT "fk_insurance_carriers_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.public_profiles (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_carriers"
        ADD CONSTRAINT "fk_insurance_carriers_public_profile_id" FOREIGN KEY ("public_profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_carriers"
        ADD CONSTRAINT "fk_insurance_carriers_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_carriers"
        ADD CONSTRAINT "fk_insurance_carriers_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_carriers"
        ADD CONSTRAINT "fk_insurance_carriers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_carriers"
        ADD CONSTRAINT "fk_insurance_carriers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_brokers"
        ADD CONSTRAINT "fk_insurance_brokers_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_brokers"
        ADD CONSTRAINT "fk_insurance_brokers_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.public_profiles (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_brokers"
        ADD CONSTRAINT "fk_insurance_brokers_public_profile_id" FOREIGN KEY ("public_profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_brokers"
        ADD CONSTRAINT "fk_insurance_brokers_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_brokers"
        ADD CONSTRAINT "fk_insurance_brokers_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_brokers"
        ADD CONSTRAINT "fk_insurance_brokers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_brokers"
        ADD CONSTRAINT "fk_insurance_brokers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_commission_model_concept_id" FOREIGN KEY ("commission_model_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_contract_file_id" FOREIGN KEY ("contract_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "insurance"."employer_groups"
        ADD CONSTRAINT "fk_employer_groups_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."employer_groups"
        ADD CONSTRAINT "fk_employer_groups_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."employer_groups"
        ADD CONSTRAINT "fk_employer_groups_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."employer_groups"
        ADD CONSTRAINT "fk_employer_groups_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_products"
        ADD CONSTRAINT "fk_insurance_products_product_type_concept_id" FOREIGN KEY ("product_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_products"
        ADD CONSTRAINT "fk_insurance_products_market_segment_concept_id" FOREIGN KEY ("market_segment_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_products"
        ADD CONSTRAINT "fk_insurance_products_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_products"
        ADD CONSTRAINT "fk_insurance_products_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_products"
        ADD CONSTRAINT "fk_insurance_products_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_products"
        ADD CONSTRAINT "fk_insurance_products_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plans"
        ADD CONSTRAINT "fk_insurance_plans_plan_type_concept_id" FOREIGN KEY ("plan_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plans"
        ADD CONSTRAINT "fk_insurance_plans_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plans"
        ADD CONSTRAINT "fk_insurance_plans_policy_document_file_id" FOREIGN KEY ("policy_document_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plans"
        ADD CONSTRAINT "fk_insurance_plans_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plans"
        ADD CONSTRAINT "fk_insurance_plans_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plans"
        ADD CONSTRAINT "fk_insurance_plans_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plan_benefits"
        ADD CONSTRAINT "fk_insurance_plan_benefits_benefit_category_concept_id" FOREIGN KEY ("benefit_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plan_benefits"
        ADD CONSTRAINT "fk_insurance_plan_benefits_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plan_benefits"
        ADD CONSTRAINT "fk_insurance_plan_benefits_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plan_benefits"
        ADD CONSTRAINT "fk_insurance_plan_benefits_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_plan_benefits"
        ADD CONSTRAINT "fk_insurance_plan_benefits_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."provider_networks"
        ADD CONSTRAINT "fk_provider_networks_network_type_concept_id" FOREIGN KEY ("network_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."provider_networks"
        ADD CONSTRAINT "fk_provider_networks_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."provider_networks"
        ADD CONSTRAINT "fk_provider_networks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."provider_networks"
        ADD CONSTRAINT "fk_provider_networks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_provider_type_concept_id" FOREIGN KEY ("provider_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practitioner_role_assignments (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_practitioner_role_assignment_id" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: organization_extensions.hospitals (requiere schema organization_extensions)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_hospital_id" FOREIGN KEY ("hospital_id")
        REFERENCES "organization_extensions"."hospitals" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_units (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_participation_level_concept_id" FOREIGN KEY ("participation_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."network_provider_memberships"
        ADD CONSTRAINT "fk_network_provider_memberships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_campaign_type_concept_id" FOREIGN KEY ("campaign_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_target_condition_concept_id" FOREIGN KEY ("target_condition_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_partner_role_concept_id" FOREIGN KEY ("partner_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_partner_type_concept_id" FOREIGN KEY ("partner_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_relationship_to_subscriber_concept_id" FOREIGN KEY ("relationship_to_subscriber_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_coverages"
        ADD CONSTRAINT "fk_patient_coverages_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_dependents"
        ADD CONSTRAINT "fk_coverage_dependents_dependent_patient_profile_id" FOREIGN KEY ("dependent_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_dependents"
        ADD CONSTRAINT "fk_coverage_dependents_relationship_concept_id" FOREIGN KEY ("relationship_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_dependents"
        ADD CONSTRAINT "fk_coverage_dependents_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_dependents"
        ADD CONSTRAINT "fk_coverage_dependents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_dependents"
        ADD CONSTRAINT "fk_coverage_dependents_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_client_type_concept_id" FOREIGN KEY ("client_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_assigned_broker_user_id" FOREIGN KEY ("assigned_broker_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_clients"
        ADD CONSTRAINT "fk_broker_clients_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_requests"
        ADD CONSTRAINT "fk_coverage_eligibility_requests_requesting_provider_t_48adc63f" FOREIGN KEY ("requesting_provider_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_requests"
        ADD CONSTRAINT "fk_coverage_eligibility_requests_purpose_value_set_id" FOREIGN KEY ("purpose_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_requests"
        ADD CONSTRAINT "fk_coverage_eligibility_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_requests"
        ADD CONSTRAINT "fk_coverage_eligibility_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_responses"
        ADD CONSTRAINT "fk_coverage_eligibility_responses_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."coverage_eligibility_responses"
        ADD CONSTRAINT "fk_coverage_eligibility_responses_responded_by_user_id" FOREIGN KEY ("responded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.medication_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_medication_request_id" FOREIGN KEY ("medication_request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy_inventory.inventory_reservations (requiere schema pharmacy_inventory)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_inventory_reservation_id" FOREIGN KEY ("inventory_reservation_id")
        REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_requesting_provider_ty_cccf5fb5" FOREIGN KEY ("requesting_provider_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_requests"
        ADD CONSTRAINT "fk_prior_authorization_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_items"
        ADD CONSTRAINT "fk_prior_authorization_items_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_study_offerings (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_items"
        ADD CONSTRAINT "fk_prior_authorization_items_diagnostic_study_offering_id" FOREIGN KEY ("diagnostic_study_offering_id")
        REFERENCES "diagnostic_units"."diagnostic_study_offerings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_items"
        ADD CONSTRAINT "fk_prior_authorization_items_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_items"
        ADD CONSTRAINT "fk_prior_authorization_items_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_determinations"
        ADD CONSTRAINT "fk_prior_authorization_determinations_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_determinations"
        ADD CONSTRAINT "fk_prior_authorization_determinations_denial_reason_concept_id" FOREIGN KEY ("denial_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_determinations"
        ADD CONSTRAINT "fk_prior_authorization_determinations_supporting_file_id" FOREIGN KEY ("supporting_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."prior_authorization_determinations"
        ADD CONSTRAINT "fk_prior_authorization_determinations_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_billing_provider_type_concept_id" FOREIGN KEY ("billing_provider_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy_inventory.inventory_reservations (requiere schema pharmacy_inventory)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_inventory_reservation_id" FOREIGN KEY ("inventory_reservation_id")
        REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.service_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claims"
        ADD CONSTRAINT "fk_insurance_claims_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claim_lines"
        ADD CONSTRAINT "fk_insurance_claim_lines_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_study_offerings (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claim_lines"
        ADD CONSTRAINT "fk_insurance_claim_lines_diagnostic_study_offering_id" FOREIGN KEY ("diagnostic_study_offering_id")
        REFERENCES "diagnostic_units"."diagnostic_study_offerings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy_inventory.medication_dispensation_lines (requiere schema pharmacy_inventory)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claim_lines"
        ADD CONSTRAINT "fk_insurance_claim_lines_medication_dispensation_line_id" FOREIGN KEY ("medication_dispensation_line_id")
        REFERENCES "pharmacy_inventory"."medication_dispensation_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy_inventory.inventory_reservation_lines (requiere schema pharmacy_inventory)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_claim_lines"
        ADD CONSTRAINT "fk_insurance_claim_lines_inventory_reservation_line_id" FOREIGN KEY ("inventory_reservation_line_id")
        REFERENCES "pharmacy_inventory"."inventory_reservation_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_adjudication_versions"
        ADD CONSTRAINT "fk_claim_adjudication_versions_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_adjudication_versions"
        ADD CONSTRAINT "fk_claim_adjudication_versions_adjudicated_by_user_id" FOREIGN KEY ("adjudicated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_line_adjudications"
        ADD CONSTRAINT "fk_claim_line_adjudications_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_line_adjudications"
        ADD CONSTRAINT "fk_claim_line_adjudications_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_explanations_of_benefit"
        ADD CONSTRAINT "fk_patient_explanations_of_benefit_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: chart.document_records (requiere schema chart)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_explanations_of_benefit"
        ADD CONSTRAINT "fk_patient_explanations_of_benefit_document_record_id" FOREIGN KEY ("document_record_id")
        REFERENCES "chart"."document_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_explanations_of_benefit"
        ADD CONSTRAINT "fk_patient_explanations_of_benefit_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."patient_explanations_of_benefit"
        ADD CONSTRAINT "fk_patient_explanations_of_benefit_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_batches"
        ADD CONSTRAINT "fk_insurance_reconciliation_batches_provider_type_concept_id" FOREIGN KEY ("provider_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_batches"
        ADD CONSTRAINT "fk_insurance_reconciliation_batches_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_batches"
        ADD CONSTRAINT "fk_insurance_reconciliation_batches_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_batches"
        ADD CONSTRAINT "fk_insurance_reconciliation_batches_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_batches"
        ADD CONSTRAINT "fk_insurance_reconciliation_batches_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_items"
        ADD CONSTRAINT "fk_insurance_reconciliation_items_variance_reason_concept_id" FOREIGN KEY ("variance_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_items"
        ADD CONSTRAINT "fk_insurance_reconciliation_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_items"
        ADD CONSTRAINT "fk_insurance_reconciliation_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_reconciliation_items"
        ADD CONSTRAINT "fk_insurance_reconciliation_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_commission_statements"
        ADD CONSTRAINT "fk_broker_commission_statements_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_commission_statements"
        ADD CONSTRAINT "fk_broker_commission_statements_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_commission_statements"
        ADD CONSTRAINT "fk_broker_commission_statements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_commission_statements"
        ADD CONSTRAINT "fk_broker_commission_statements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_cob_rule_concept_id" FOREIGN KEY ("cob_rule_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_determined_by_authority_concept_id" FOREIGN KEY ("determined_by_authority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."coordination_of_benefits"
        ADD CONSTRAINT "fk_coordination_of_benefits_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_dispute_type_concept_id" FOREIGN KEY ("dispute_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_dispute_reason_concept_id" FOREIGN KEY ("dispute_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_initiated_by_party_type_concept_id" FOREIGN KEY ("initiated_by_party_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_supporting_evidence_file_id" FOREIGN KEY ("supporting_evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_disputes"
        ADD CONSTRAINT "fk_claim_disputes_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_appeal_decisions"
        ADD CONSTRAINT "fk_claim_appeal_decisions_appeal_level_concept_id" FOREIGN KEY ("appeal_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_appeal_decisions"
        ADD CONSTRAINT "fk_claim_appeal_decisions_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_appeal_decisions"
        ADD CONSTRAINT "fk_claim_appeal_decisions_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_appeal_decisions"
        ADD CONSTRAINT "fk_claim_appeal_decisions_decided_by_reviewer_user_id" FOREIGN KEY ("decided_by_reviewer_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_reversals"
        ADD CONSTRAINT "fk_claim_reversals_reversal_reason_concept_id" FOREIGN KEY ("reversal_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_reversals"
        ADD CONSTRAINT "fk_claim_reversals_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."claim_reversals"
        ADD CONSTRAINT "fk_claim_reversals_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
