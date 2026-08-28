-- SALUD v4.0.10 · módulo 25 · schema pharmacy_inventory
-- Generado de diagram_25_pharmacy_inventory.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   inventory_reservations.quotation_id


-- destino: pharmacy.pharmacy_sites (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_location_type_concept_id" FOREIGN KEY ("location_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_temperature_zone_concept_id" FOREIGN KEY ("temperature_zone_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_lots"
        ADD CONSTRAINT "fk_inventory_lots_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_lots"
        ADD CONSTRAINT "fk_inventory_lots_quarantine_status_concept_id" FOREIGN KEY ("quarantine_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_lots"
        ADD CONSTRAINT "fk_inventory_lots_recall_status_concept_id" FOREIGN KEY ("recall_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_lots"
        ADD CONSTRAINT "fk_inventory_lots_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_lots"
        ADD CONSTRAINT "fk_inventory_lots_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_lots"
        ADD CONSTRAINT "fk_inventory_lots_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_serials"
        ADD CONSTRAINT "fk_inventory_serials_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_serials"
        ADD CONSTRAINT "fk_inventory_serials_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_serials"
        ADD CONSTRAINT "fk_inventory_serials_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_stock_positions"
        ADD CONSTRAINT "fk_inventory_stock_positions_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_sites (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_movement_type_concept_id" FOREIGN KEY ("movement_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.goods_receipt_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_erp_goods_receipt_item_id" FOREIGN KEY ("erp_goods_receipt_item_id")
        REFERENCES "erp"."goods_receipt_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.ledger_entries (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_accounting_ledger_entry_id" FOREIGN KEY ("accounting_ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_sites (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.medication_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_medication_request_id" FOREIGN KEY ("medication_request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_reservation_status_concept_id" FOREIGN KEY ("reservation_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_delivery_mode_concept_id" FOREIGN KEY ("delivery_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.addresses (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_delivery_address_id" FOREIGN KEY ("delivery_address_id")
        REFERENCES "common"."addresses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_original_pharmacy_product_id" FOREIGN KEY ("original_pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_proposed_pharmacy_product_id" FOREIGN KEY ("proposed_pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_sites (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_count_type_concept_id" FOREIGN KEY ("count_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_freeze_mode_concept_id" FOREIGN KEY ("freeze_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_lines"
        ADD CONSTRAINT "fk_inventory_count_lines_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_lines"
        ADD CONSTRAINT "fk_inventory_count_lines_variance_reason_concept_id" FOREIGN KEY ("variance_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.ledger_entries (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_lines"
        ADD CONSTRAINT "fk_inventory_count_lines_adjustment_ledger_entry_id" FOREIGN KEY ("adjustment_ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_lines"
        ADD CONSTRAINT "fk_inventory_count_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_recall_holds"
        ADD CONSTRAINT "fk_inventory_recall_holds_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_recall_holds"
        ADD CONSTRAINT "fk_inventory_recall_holds_recall_class_concept_id" FOREIGN KEY ("recall_class_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_recall_holds"
        ADD CONSTRAINT "fk_inventory_recall_holds_hold_status_concept_id" FOREIGN KEY ("hold_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_recall_holds"
        ADD CONSTRAINT "fk_inventory_recall_holds_source_authority_tenant_id" FOREIGN KEY ("source_authority_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_recall_holds"
        ADD CONSTRAINT "fk_inventory_recall_holds_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_recall_holds"
        ADD CONSTRAINT "fk_inventory_recall_holds_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_suppliers"
        ADD CONSTRAINT "fk_pharmacy_suppliers_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_suppliers"
        ADD CONSTRAINT "fk_pharmacy_suppliers_supplier_tenant_id" FOREIGN KEY ("supplier_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.business_partners (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_suppliers"
        ADD CONSTRAINT "fk_pharmacy_suppliers_business_partner_id" FOREIGN KEY ("business_partner_id")
        REFERENCES "erp"."business_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_suppliers"
        ADD CONSTRAINT "fk_pharmacy_suppliers_payment_terms_concept_id" FOREIGN KEY ("payment_terms_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_suppliers"
        ADD CONSTRAINT "fk_pharmacy_suppliers_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_suppliers"
        ADD CONSTRAINT "fk_pharmacy_suppliers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_suppliers"
        ADD CONSTRAINT "fk_pharmacy_suppliers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_sites (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.purchase_orders (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_erp_purchase_order_id" FOREIGN KEY ("erp_purchase_order_id")
        REFERENCES "erp"."purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_order_lines"
        ADD CONSTRAINT "fk_pharmacy_purchase_order_lines_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.purchase_order_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_order_lines"
        ADD CONSTRAINT "fk_pharmacy_purchase_order_lines_erp_purchase_order_item_id" FOREIGN KEY ("erp_purchase_order_item_id")
        REFERENCES "erp"."purchase_order_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_order_lines"
        ADD CONSTRAINT "fk_pharmacy_purchase_order_lines_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_order_lines"
        ADD CONSTRAINT "fk_pharmacy_purchase_order_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_order_lines"
        ADD CONSTRAINT "fk_pharmacy_purchase_order_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_sites (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipts"
        ADD CONSTRAINT "fk_pharmacy_goods_receipts_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.goods_receipts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipts"
        ADD CONSTRAINT "fk_pharmacy_goods_receipts_erp_goods_receipt_id" FOREIGN KEY ("erp_goods_receipt_id")
        REFERENCES "erp"."goods_receipts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipts"
        ADD CONSTRAINT "fk_pharmacy_goods_receipts_source_document_file_id" FOREIGN KEY ("source_document_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipts"
        ADD CONSTRAINT "fk_pharmacy_goods_receipts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipts"
        ADD CONSTRAINT "fk_pharmacy_goods_receipts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipts"
        ADD CONSTRAINT "fk_pharmacy_goods_receipts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: erp.goods_receipt_items (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_erp_goods_receipt_item_id" FOREIGN KEY ("erp_goods_receipt_item_id")
        REFERENCES "erp"."goods_receipt_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.ledger_entries (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_ledger_entry_id" FOREIGN KEY ("ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_sites (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.medication_requests (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_medication_request_id" FOREIGN KEY ("medication_request_id")
        REFERENCES "clinical"."medication_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.insurance_claims (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_dispensation_status_concept_id" FOREIGN KEY ("dispensation_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_dispenser_practitioner_profile_id" FOREIGN KEY ("dispenser_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_substitution_reason_concept_id" FOREIGN KEY ("substitution_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensation_lines"
        ADD CONSTRAINT "fk_medication_dispensation_lines_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: accounting.ledger_entries (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensation_lines"
        ADD CONSTRAINT "fk_medication_dispensation_lines_ledger_entry_id" FOREIGN KEY ("ledger_entry_id")
        REFERENCES "accounting"."ledger_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensation_lines"
        ADD CONSTRAINT "fk_medication_dispensation_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_integration_connections (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_batches"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_batches_pharmacy_integratio_81168ea5" FOREIGN KEY ("pharmacy_integration_connection_id")
        REFERENCES "pharmacy"."pharmacy_integration_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_batches"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_batches_direction_concept_id" FOREIGN KEY ("direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_batches"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_batches_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_batches"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_batches_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_batches"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_batches_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_items"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_items_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_items"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_items_reconciliation_status_d2a662cb" FOREIGN KEY ("reconciliation_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
