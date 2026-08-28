-- SALUD v4.0.10 · módulo 25 · schema pharmacy_inventory
-- Generado de diagram_25_pharmacy_inventory.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_inventory_locations_pharmacy_site_id" ON "pharmacy_inventory"."inventory_locations" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_parent_location_id" ON "pharmacy_inventory"."inventory_locations" ("parent_location_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_location_type_concept_id" ON "pharmacy_inventory"."inventory_locations" ("location_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_temperature_zone_concept_id" ON "pharmacy_inventory"."inventory_locations" ("temperature_zone_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_status_concept_id" ON "pharmacy_inventory"."inventory_locations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_created_by_user_id" ON "pharmacy_inventory"."inventory_locations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_updated_by_user_id" ON "pharmacy_inventory"."inventory_locations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_lots_pharmacy_product_id" ON "pharmacy_inventory"."inventory_lots" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_lots_quarantine_status_concept_id" ON "pharmacy_inventory"."inventory_lots" ("quarantine_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_lots_recall_status_concept_id" ON "pharmacy_inventory"."inventory_lots" ("recall_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_lots_status_concept_id" ON "pharmacy_inventory"."inventory_lots" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_lots_created_by_user_id" ON "pharmacy_inventory"."inventory_lots" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_lots_updated_by_user_id" ON "pharmacy_inventory"."inventory_lots" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_serials_inventory_lot_id" ON "pharmacy_inventory"."inventory_serials" ("inventory_lot_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_serials_status_concept_id" ON "pharmacy_inventory"."inventory_serials" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_serials_current_inventory_location_id" ON "pharmacy_inventory"."inventory_serials" ("current_inventory_location_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_serials_created_by_user_id" ON "pharmacy_inventory"."inventory_serials" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_serials_updated_by_user_id" ON "pharmacy_inventory"."inventory_serials" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_stock_positions_inventory_location_id" ON "pharmacy_inventory"."inventory_stock_positions" ("inventory_location_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_stock_positions_pharmacy_product_id" ON "pharmacy_inventory"."inventory_stock_positions" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_stock_positions_inventory_lot_id" ON "pharmacy_inventory"."inventory_stock_positions" ("inventory_lot_id");

-- OMITIDO "uq_inventory_position_lot" (pharmacy_site_id, product_id, lot_id) btree: columna(s) ['pharmacy_site_id', 'product_id', 'lot_id'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_pharmacy_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_pharmacy_site_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_inventory_location_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("inventory_location_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_pharmacy_product_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_inventory_lot_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("inventory_lot_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_inventory_serial_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("inventory_serial_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_movement_type_concept_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("movement_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_currency_concept_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_erp_goods_receipt_item_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("erp_goods_receipt_item_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_accounting_ledger_entry_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("accounting_ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_source_type_concept_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_ledger_entries_recorded_by_user_id" ON "pharmacy_inventory"."inventory_ledger_entries" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_inventory_ledger_entries_pharmacy_id_ledger_sequence" ON "pharmacy_inventory"."inventory_ledger_entries" ("pharmacy_id", "ledger_sequence");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_inventory_ledger_entries_idempotency" ON "pharmacy_inventory"."inventory_ledger_entries" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "brin_inventory_ledger_entries_recorded_at" ON "pharmacy_inventory"."inventory_ledger_entries" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_inventory_ledger_idempotency" ON "pharmacy_inventory"."inventory_ledger_entries" ("pharmacy_id", "idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_pharmacy_id" ON "pharmacy_inventory"."inventory_reservations" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_pharmacy_site_id" ON "pharmacy_inventory"."inventory_reservations" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_patient_profile_id" ON "pharmacy_inventory"."inventory_reservations" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_medication_request_id" ON "pharmacy_inventory"."inventory_reservations" ("medication_request_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_quotation_id" ON "pharmacy_inventory"."inventory_reservations" ("quotation_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_reservation_status_concept_id" ON "pharmacy_inventory"."inventory_reservations" ("reservation_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_delivery_mode_concept_id" ON "pharmacy_inventory"."inventory_reservations" ("delivery_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_delivery_address_id" ON "pharmacy_inventory"."inventory_reservations" ("delivery_address_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_currency_concept_id" ON "pharmacy_inventory"."inventory_reservations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_created_by_user_id" ON "pharmacy_inventory"."inventory_reservations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_updated_by_user_id" ON "pharmacy_inventory"."inventory_reservations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_patient_profile_id_updated_at" ON "pharmacy_inventory"."inventory_reservations" ("patient_profile_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_inventory_reservations_idempotency" ON "pharmacy_inventory"."inventory_reservations" ("idempotency_key");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inventory_reservations_pharmacy_site_pickup_code" ON "pharmacy_inventory"."inventory_reservations" ("pharmacy_site_id", "pickup_code") WHERE pickup_code IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_inventory_reservation_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("inventory_reservation_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_pharmacy_product_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_inventory_lot_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("inventory_lot_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_inventory_location_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("inventory_location_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_status_concept_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_currency_concept_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_created_by_user_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_updated_by_user_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_inventory_reservation_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("inventory_reservation_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_inventory_reservation_line_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("inventory_reservation_line_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_original_pharmacy_product_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("original_pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_proposed_pharmacy_product_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("proposed_pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_currency_concept_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_status_concept_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_created_by_user_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_updated_by_user_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_pharmacy_site_id" ON "pharmacy_inventory"."inventory_count_sessions" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_inventory_location_id" ON "pharmacy_inventory"."inventory_count_sessions" ("inventory_location_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_count_type_concept_id" ON "pharmacy_inventory"."inventory_count_sessions" ("count_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_freeze_mode_concept_id" ON "pharmacy_inventory"."inventory_count_sessions" ("freeze_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_approved_by_user_id" ON "pharmacy_inventory"."inventory_count_sessions" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_status_concept_id" ON "pharmacy_inventory"."inventory_count_sessions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_created_by_user_id" ON "pharmacy_inventory"."inventory_count_sessions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_sessions_updated_by_user_id" ON "pharmacy_inventory"."inventory_count_sessions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_lines_inventory_count_session_id" ON "pharmacy_inventory"."inventory_count_lines" ("inventory_count_session_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_lines_pharmacy_product_id" ON "pharmacy_inventory"."inventory_count_lines" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_lines_inventory_lot_id" ON "pharmacy_inventory"."inventory_count_lines" ("inventory_lot_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_lines_variance_reason_concept_id" ON "pharmacy_inventory"."inventory_count_lines" ("variance_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_lines_adjustment_ledger_entry_id" ON "pharmacy_inventory"."inventory_count_lines" ("adjustment_ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_count_lines_created_by_user_id" ON "pharmacy_inventory"."inventory_count_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_recall_holds_pharmacy_product_id" ON "pharmacy_inventory"."inventory_recall_holds" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_recall_holds_inventory_lot_id" ON "pharmacy_inventory"."inventory_recall_holds" ("inventory_lot_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_recall_holds_recall_class_concept_id" ON "pharmacy_inventory"."inventory_recall_holds" ("recall_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_recall_holds_hold_status_concept_id" ON "pharmacy_inventory"."inventory_recall_holds" ("hold_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_recall_holds_source_authority_tenant_id" ON "pharmacy_inventory"."inventory_recall_holds" ("source_authority_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_recall_holds_created_by_user_id" ON "pharmacy_inventory"."inventory_recall_holds" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_recall_holds_updated_by_user_id" ON "pharmacy_inventory"."inventory_recall_holds" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_suppliers_pharmacy_id" ON "pharmacy_inventory"."pharmacy_suppliers" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_suppliers_supplier_tenant_id" ON "pharmacy_inventory"."pharmacy_suppliers" ("supplier_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_suppliers_payment_terms_concept_id" ON "pharmacy_inventory"."pharmacy_suppliers" ("payment_terms_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_suppliers_business_partner_id" ON "pharmacy_inventory"."pharmacy_suppliers" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_suppliers_status_concept_id" ON "pharmacy_inventory"."pharmacy_suppliers" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_suppliers_created_by_user_id" ON "pharmacy_inventory"."pharmacy_suppliers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_suppliers_updated_by_user_id" ON "pharmacy_inventory"."pharmacy_suppliers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_pharmacy_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_pharmacy_site_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_pharmacy_supplier_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("pharmacy_supplier_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_status_concept_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_erp_purchase_order_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("erp_purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_currency_concept_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_created_by_user_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_orders_updated_by_user_id" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_purchase_orders_idempotency" ON "pharmacy_inventory"."pharmacy_purchase_orders" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_order_lines_pharmacy_purchase_order_id" ON "pharmacy_inventory"."pharmacy_purchase_order_lines" ("pharmacy_purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_order_lines_pharmacy_product_id" ON "pharmacy_inventory"."pharmacy_purchase_order_lines" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_order_lines_erp_purchase_order_item_id" ON "pharmacy_inventory"."pharmacy_purchase_order_lines" ("erp_purchase_order_item_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_order_lines_status_concept_id" ON "pharmacy_inventory"."pharmacy_purchase_order_lines" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_order_lines_created_by_user_id" ON "pharmacy_inventory"."pharmacy_purchase_order_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_purchase_order_lines_updated_by_user_id" ON "pharmacy_inventory"."pharmacy_purchase_order_lines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipts_pharmacy_purchase_order_id" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("pharmacy_purchase_order_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipts_erp_goods_receipt_id" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("erp_goods_receipt_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipts_pharmacy_site_id" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipts_source_document_file_id" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("source_document_file_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipts_status_concept_id" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipts_created_by_user_id" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipts_updated_by_user_id" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_goods_receipts_idempotency" ON "pharmacy_inventory"."pharmacy_goods_receipts" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_pharmacy_goods_receipt_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("pharmacy_goods_receipt_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_pharmacy_purchase_order_line_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("pharmacy_purchase_order_line_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_erp_goods_receipt_item_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("erp_goods_receipt_item_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_pharmacy_product_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_inventory_lot_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("inventory_lot_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_inventory_location_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("inventory_location_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_ledger_entry_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_goods_receipt_lines_created_by_user_id" ON "pharmacy_inventory"."pharmacy_goods_receipt_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_pharmacy_id" ON "pharmacy_inventory"."medication_dispensations" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_pharmacy_site_id" ON "pharmacy_inventory"."medication_dispensations" ("pharmacy_site_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_patient_profile_id" ON "pharmacy_inventory"."medication_dispensations" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_medication_request_id" ON "pharmacy_inventory"."medication_dispensations" ("medication_request_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_insurance_claim_id" ON "pharmacy_inventory"."medication_dispensations" ("insurance_claim_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_inventory_reservation_id" ON "pharmacy_inventory"."medication_dispensations" ("inventory_reservation_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_dispensation_status_concept_id" ON "pharmacy_inventory"."medication_dispensations" ("dispensation_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_dispenser_practitioner_profile_id" ON "pharmacy_inventory"."medication_dispensations" ("dispenser_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_substitution_reason_concept_id" ON "pharmacy_inventory"."medication_dispensations" ("substitution_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_created_by_user_id" ON "pharmacy_inventory"."medication_dispensations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_updated_by_user_id" ON "pharmacy_inventory"."medication_dispensations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensations_patient_profile_id_updated_at" ON "pharmacy_inventory"."medication_dispensations" ("patient_profile_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_medication_dispensations_idempotency" ON "pharmacy_inventory"."medication_dispensations" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensation_lines_medication_dispensation_id" ON "pharmacy_inventory"."medication_dispensation_lines" ("medication_dispensation_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensation_lines_pharmacy_product_id" ON "pharmacy_inventory"."medication_dispensation_lines" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensation_lines_inventory_lot_id" ON "pharmacy_inventory"."medication_dispensation_lines" ("inventory_lot_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensation_lines_inventory_serial_id" ON "pharmacy_inventory"."medication_dispensation_lines" ("inventory_serial_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensation_lines_ledger_entry_id" ON "pharmacy_inventory"."medication_dispensation_lines" ("ledger_entry_id");

CREATE INDEX IF NOT EXISTS "ix_medication_dispensation_lines_created_by_user_id" ON "pharmacy_inventory"."medication_dispensation_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_batches_pharmacy_integratio_1a78cf50" ON "pharmacy_inventory"."pharmacy_inventory_sync_batches" ("pharmacy_integration_connection_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_batches_direction_concept_id" ON "pharmacy_inventory"."pharmacy_inventory_sync_batches" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_batches_status_concept_id" ON "pharmacy_inventory"."pharmacy_inventory_sync_batches" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_batches_created_by_user_id" ON "pharmacy_inventory"."pharmacy_inventory_sync_batches" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_batches_updated_by_user_id" ON "pharmacy_inventory"."pharmacy_inventory_sync_batches" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_items_pharmacy_inventory_sy_f46e49ba" ON "pharmacy_inventory"."pharmacy_inventory_sync_items" ("pharmacy_inventory_sync_batch_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_items_pharmacy_product_id" ON "pharmacy_inventory"."pharmacy_inventory_sync_items" ("pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_inventory_sync_items_reconciliation_status_ef599848" ON "pharmacy_inventory"."pharmacy_inventory_sync_items" ("reconciliation_status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_inventory_sync_items_idempotency" ON "pharmacy_inventory"."pharmacy_inventory_sync_items" ("idempotency_key");
