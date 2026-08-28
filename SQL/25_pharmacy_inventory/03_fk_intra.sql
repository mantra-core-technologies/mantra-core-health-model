-- SALUD v4.0.10 · módulo 25 · schema pharmacy_inventory
-- Generado de diagram_25_pharmacy_inventory.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_parent_location_id" FOREIGN KEY ("parent_location_id")
        REFERENCES "pharmacy_inventory"."inventory_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_serials"
        ADD CONSTRAINT "fk_inventory_serials_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_serials"
        ADD CONSTRAINT "fk_inventory_serials_current_inventory_location_id" FOREIGN KEY ("current_inventory_location_id")
        REFERENCES "pharmacy_inventory"."inventory_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_stock_positions"
        ADD CONSTRAINT "fk_inventory_stock_positions_inventory_location_id" FOREIGN KEY ("inventory_location_id")
        REFERENCES "pharmacy_inventory"."inventory_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_stock_positions"
        ADD CONSTRAINT "fk_inventory_stock_positions_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_inventory_location_id" FOREIGN KEY ("inventory_location_id")
        REFERENCES "pharmacy_inventory"."inventory_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries"
        ADD CONSTRAINT "fk_inventory_ledger_entries_inventory_serial_id" FOREIGN KEY ("inventory_serial_id")
        REFERENCES "pharmacy_inventory"."inventory_serials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_inventory_reservation_id" FOREIGN KEY ("inventory_reservation_id")
        REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_inventory_location_id" FOREIGN KEY ("inventory_location_id")
        REFERENCES "pharmacy_inventory"."inventory_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_inventory_reservation_id" FOREIGN KEY ("inventory_reservation_id")
        REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_inventory_reservation_line_id" FOREIGN KEY ("inventory_reservation_line_id")
        REFERENCES "pharmacy_inventory"."inventory_reservation_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_sessions"
        ADD CONSTRAINT "fk_inventory_count_sessions_inventory_location_id" FOREIGN KEY ("inventory_location_id")
        REFERENCES "pharmacy_inventory"."inventory_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_lines"
        ADD CONSTRAINT "fk_inventory_count_lines_inventory_count_session_id" FOREIGN KEY ("inventory_count_session_id")
        REFERENCES "pharmacy_inventory"."inventory_count_sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_count_lines"
        ADD CONSTRAINT "fk_inventory_count_lines_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_recall_holds"
        ADD CONSTRAINT "fk_inventory_recall_holds_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_orders"
        ADD CONSTRAINT "fk_pharmacy_purchase_orders_pharmacy_supplier_id" FOREIGN KEY ("pharmacy_supplier_id")
        REFERENCES "pharmacy_inventory"."pharmacy_suppliers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_purchase_order_lines"
        ADD CONSTRAINT "fk_pharmacy_purchase_order_lines_pharmacy_purchase_order_id" FOREIGN KEY ("pharmacy_purchase_order_id")
        REFERENCES "pharmacy_inventory"."pharmacy_purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipts"
        ADD CONSTRAINT "fk_pharmacy_goods_receipts_pharmacy_purchase_order_id" FOREIGN KEY ("pharmacy_purchase_order_id")
        REFERENCES "pharmacy_inventory"."pharmacy_purchase_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_pharmacy_goods_receipt_id" FOREIGN KEY ("pharmacy_goods_receipt_id")
        REFERENCES "pharmacy_inventory"."pharmacy_goods_receipts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_pharmacy_purchase_order_line_id" FOREIGN KEY ("pharmacy_purchase_order_line_id")
        REFERENCES "pharmacy_inventory"."pharmacy_purchase_order_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_goods_receipt_lines"
        ADD CONSTRAINT "fk_pharmacy_goods_receipt_lines_inventory_location_id" FOREIGN KEY ("inventory_location_id")
        REFERENCES "pharmacy_inventory"."inventory_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensations"
        ADD CONSTRAINT "fk_medication_dispensations_inventory_reservation_id" FOREIGN KEY ("inventory_reservation_id")
        REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensation_lines"
        ADD CONSTRAINT "fk_medication_dispensation_lines_medication_dispensation_id" FOREIGN KEY ("medication_dispensation_id")
        REFERENCES "pharmacy_inventory"."medication_dispensations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensation_lines"
        ADD CONSTRAINT "fk_medication_dispensation_lines_inventory_lot_id" FOREIGN KEY ("inventory_lot_id")
        REFERENCES "pharmacy_inventory"."inventory_lots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."medication_dispensation_lines"
        ADD CONSTRAINT "fk_medication_dispensation_lines_inventory_serial_id" FOREIGN KEY ("inventory_serial_id")
        REFERENCES "pharmacy_inventory"."inventory_serials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_items"
        ADD CONSTRAINT "fk_pharmacy_inventory_sync_items_pharmacy_inventory_sy_5a88ae55" FOREIGN KEY ("pharmacy_inventory_sync_batch_id")
        REFERENCES "pharmacy_inventory"."pharmacy_inventory_sync_batches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
