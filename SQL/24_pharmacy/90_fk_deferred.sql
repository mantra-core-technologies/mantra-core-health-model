-- SALUD v4.0.10 · módulo 24 · schema pharmacy
-- Generado de diagram_24_pharmacy.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_pharmacy_type_concept_id" FOREIGN KEY ("pharmacy_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_ownership_type_concept_id" FOREIGN KEY ("ownership_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.public_profiles (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_public_profile_id" FOREIGN KEY ("public_profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_default_currency_concept_id" FOREIGN KEY ("default_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_pharmacy_site_type_concept_id" FOREIGN KEY ("pharmacy_site_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_dispensing_mode_concept_id" FOREIGN KEY ("dispensing_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_controlled_substance_capability_concept_id" FOREIGN KEY ("controlled_substance_capability_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_license_type_concept_id" FOREIGN KEY ("license_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_issuing_authority_tenant_id" FOREIGN KEY ("issuing_authority_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_medication_concept_id" FOREIGN KEY ("medication_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_inventory_item_concept_id" FOREIGN KEY ("inventory_item_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_manufacturer_tenant_id" FOREIGN KEY ("manufacturer_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_dosage_form_concept_id" FOREIGN KEY ("dosage_form_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_identifiers"
        ADD CONSTRAINT "fk_pharmacy_product_identifiers_identifier_type_concept_id" FOREIGN KEY ("identifier_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_identifiers"
        ADD CONSTRAINT "fk_pharmacy_product_identifiers_assigning_authority_tenant_id" FOREIGN KEY ("assigning_authority_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_identifiers"
        ADD CONSTRAINT "fk_pharmacy_product_identifiers_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_identifiers"
        ADD CONSTRAINT "fk_pharmacy_product_identifiers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_price_list_type_concept_id" FOREIGN KEY ("price_list_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_insurer_tenant_id" FOREIGN KEY ("insurer_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_prices"
        ADD CONSTRAINT "fk_pharmacy_product_prices_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_prices"
        ADD CONSTRAINT "fk_pharmacy_product_prices_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_integration_mode_concept_id" FOREIGN KEY ("integration_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_inventory_authorit_3c66cc96" FOREIGN KEY ("inventory_authority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_external_product_mappings"
        ADD CONSTRAINT "fk_pharmacy_external_product_mappings_verification_sta_0e29f411" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_external_product_mappings"
        ADD CONSTRAINT "fk_pharmacy_external_product_mappings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_external_product_mappings"
        ADD CONSTRAINT "fk_pharmacy_external_product_mappings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
