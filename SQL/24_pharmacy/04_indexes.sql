-- SALUD v4.0.10 · módulo 24 · schema pharmacy
-- Generado de diagram_24_pharmacy.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacies_tenant_id" ON "pharmacy"."pharmacies" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacies_code" ON "pharmacy"."pharmacies" ("code");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_tenant_id" ON "pharmacy"."pharmacies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_pharmacy_type_concept_id" ON "pharmacy"."pharmacies" ("pharmacy_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_ownership_type_concept_id" ON "pharmacy"."pharmacies" ("ownership_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_public_profile_id" ON "pharmacy"."pharmacies" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_default_currency_concept_id" ON "pharmacy"."pharmacies" ("default_currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_verification_status_concept_id" ON "pharmacy"."pharmacies" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_status_concept_id" ON "pharmacy"."pharmacies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_created_by_user_id" ON "pharmacy"."pharmacies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_updated_by_user_id" ON "pharmacy"."pharmacies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacies_tenant_id_status_concept_id" ON "pharmacy"."pharmacies" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_pharmacies_search" ON "pharmacy"."pharmacies" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_pharmacy_id" ON "pharmacy"."pharmacy_sites" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_practice_site_id" ON "pharmacy"."pharmacy_sites" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_pharmacy_site_type_concept_id" ON "pharmacy"."pharmacy_sites" ("pharmacy_site_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_dispensing_mode_concept_id" ON "pharmacy"."pharmacy_sites" ("dispensing_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_controlled_substance_capability_concept_id" ON "pharmacy"."pharmacy_sites" ("controlled_substance_capability_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_status_concept_id" ON "pharmacy"."pharmacy_sites" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_created_by_user_id" ON "pharmacy"."pharmacy_sites" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_sites_updated_by_user_id" ON "pharmacy"."pharmacy_sites" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_pharmacy_sites_search" ON "pharmacy"."pharmacy_sites" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_pharmacy_id" ON "pharmacy"."pharmacy_licenses" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_pharmacy_site_id" ON "pharmacy"."pharmacy_licenses" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_license_type_concept_id" ON "pharmacy"."pharmacy_licenses" ("license_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_issuing_authority_tenant_id" ON "pharmacy"."pharmacy_licenses" ("issuing_authority_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_jurisdiction_concept_id" ON "pharmacy"."pharmacy_licenses" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_evidence_file_id" ON "pharmacy"."pharmacy_licenses" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_verification_status_concept_id" ON "pharmacy"."pharmacy_licenses" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_created_by_user_id" ON "pharmacy"."pharmacy_licenses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_licenses_updated_by_user_id" ON "pharmacy"."pharmacy_licenses" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_pharmacy_id" ON "pharmacy"."pharmacy_products" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_medication_concept_id" ON "pharmacy"."pharmacy_products" ("medication_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_inventory_item_concept_id" ON "pharmacy"."pharmacy_products" ("inventory_item_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_manufacturer_tenant_id" ON "pharmacy"."pharmacy_products" ("manufacturer_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_dosage_form_concept_id" ON "pharmacy"."pharmacy_products" ("dosage_form_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_status_concept_id" ON "pharmacy"."pharmacy_products" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_created_by_user_id" ON "pharmacy"."pharmacy_products" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_updated_by_user_id" ON "pharmacy"."pharmacy_products" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_identifiers_pharmacy_product_id" ON "pharmacy"."pharmacy_product_identifiers" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_identifiers_identifier_type_concept_id" ON "pharmacy"."pharmacy_product_identifiers" ("identifier_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_identifiers_assigning_authority_tenant_id" ON "pharmacy"."pharmacy_product_identifiers" ("assigning_authority_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_identifiers_jurisdiction_concept_id" ON "pharmacy"."pharmacy_product_identifiers" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_identifiers_created_by_user_id" ON "pharmacy"."pharmacy_product_identifiers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_pharmacy_id" ON "pharmacy"."pharmacy_price_lists" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_pharmacy_site_id" ON "pharmacy"."pharmacy_price_lists" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_price_list_type_concept_id" ON "pharmacy"."pharmacy_price_lists" ("price_list_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_insurer_tenant_id" ON "pharmacy"."pharmacy_price_lists" ("insurer_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_currency_concept_id" ON "pharmacy"."pharmacy_price_lists" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_status_concept_id" ON "pharmacy"."pharmacy_price_lists" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_created_by_user_id" ON "pharmacy"."pharmacy_price_lists" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_price_lists_updated_by_user_id" ON "pharmacy"."pharmacy_price_lists" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_pharmacy_price_lists_search" ON "pharmacy"."pharmacy_price_lists" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "gist_pharmacy_price_lists_effective_period" ON "pharmacy"."pharmacy_price_lists" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_pharmacy_price_list_id" ON "pharmacy"."pharmacy_product_prices" ("pharmacy_price_list_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_pharmacy_product_id" ON "pharmacy"."pharmacy_product_prices" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_status_concept_id" ON "pharmacy"."pharmacy_product_prices" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_prices_recorded_by_user_id" ON "pharmacy"."pharmacy_product_prices" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_product_prices_pharmacy_price_list_id_vers_7ebb36be" ON "pharmacy"."pharmacy_product_prices" ("pharmacy_price_list_id", "pharmacy_product_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_pharmacy_id" ON "pharmacy"."pharmacy_integration_connections" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_pharmacy_site_id" ON "pharmacy"."pharmacy_integration_connections" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_connection_id" ON "pharmacy"."pharmacy_integration_connections" ("connection_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_integration_mode_concept_id" ON "pharmacy"."pharmacy_integration_connections" ("integration_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_inventory_authorit_20c81904" ON "pharmacy"."pharmacy_integration_connections" ("inventory_authority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_status_concept_id" ON "pharmacy"."pharmacy_integration_connections" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_created_by_user_id" ON "pharmacy"."pharmacy_integration_connections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_integration_connections_updated_by_user_id" ON "pharmacy"."pharmacy_integration_connections" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_external_product_mappings_pharmacy_integra_f6b3c236" ON "pharmacy"."pharmacy_external_product_mappings" ("pharmacy_integration_connection_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_external_product_mappings_pharmacy_product_id" ON "pharmacy"."pharmacy_external_product_mappings" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_external_product_mappings_verification_sta_079f1a0f" ON "pharmacy"."pharmacy_external_product_mappings" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_external_product_mappings_created_by_user_id" ON "pharmacy"."pharmacy_external_product_mappings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_external_product_mappings_updated_by_user_id" ON "pharmacy"."pharmacy_external_product_mappings" ("updated_by_user_id");
