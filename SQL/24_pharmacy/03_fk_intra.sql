-- SALUD v4.0.10 · módulo 24 · schema pharmacy
-- Generado de diagram_24_pharmacy.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_sites"
        ADD CONSTRAINT "fk_pharmacy_sites_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_licenses"
        ADD CONSTRAINT "fk_pharmacy_licenses_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_identifiers"
        ADD CONSTRAINT "fk_pharmacy_product_identifiers_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_price_lists"
        ADD CONSTRAINT "fk_pharmacy_price_lists_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_prices"
        ADD CONSTRAINT "fk_pharmacy_product_prices_pharmacy_price_list_id" FOREIGN KEY ("pharmacy_price_list_id")
        REFERENCES "pharmacy"."pharmacy_price_lists" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_prices"
        ADD CONSTRAINT "fk_pharmacy_product_prices_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_connection_id" FOREIGN KEY ("connection_id")
        REFERENCES "pharmacy"."pharmacy_integration_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_external_product_mappings"
        ADD CONSTRAINT "fk_pharmacy_external_product_mappings_pharmacy_integra_79e91ab7" FOREIGN KEY ("pharmacy_integration_connection_id")
        REFERENCES "pharmacy"."pharmacy_integration_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_external_product_mappings"
        ADD CONSTRAINT "fk_pharmacy_external_product_mappings_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
