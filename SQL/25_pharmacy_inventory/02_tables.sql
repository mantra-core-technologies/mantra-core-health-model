-- SALUD v4.0.10 · módulo 25 · schema pharmacy_inventory
-- Generado de diagram_25_pharmacy_inventory.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_locations" (
    "id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "parent_location_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "location_type_concept_id" uuid NOT NULL,
    "temperature_zone_concept_id" uuid,
    "controlled_access" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_locations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_lots" (
    "id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "lot_number" varchar NOT NULL,
    "manufacturer_lot_number" varchar,
    "manufactured_at" date,
    "expires_at" date,
    "received_at" timestamptz,
    "quarantine_status_concept_id" uuid,
    "recall_status_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_lots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_serials" (
    "id" uuid NOT NULL,
    "inventory_lot_id" uuid NOT NULL,
    "serial_number" varchar NOT NULL,
    "verification_identifier" varchar,
    "status_concept_id" uuid NOT NULL,
    "current_inventory_location_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_serials" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_stock_positions" (
    "id" uuid NOT NULL,
    "inventory_location_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "inventory_lot_id" uuid,
    "on_hand_quantity" numeric NOT NULL,
    "reserved_quantity" numeric NOT NULL,
    "quarantine_quantity" numeric NOT NULL,
    "available_quantity" numeric NOT NULL,
    "last_ledger_sequence" bigint NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_stock_positions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_ledger_entries" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "inventory_location_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "inventory_lot_id" uuid,
    "inventory_serial_id" uuid,
    "ledger_sequence" bigint NOT NULL,
    "movement_type_concept_id" uuid NOT NULL,
    "quantity_delta" numeric NOT NULL,
    "reservation_delta" numeric,
    "quarantine_delta" numeric,
    "unit_cost_amount" numeric,
    "currency_concept_id" uuid,
    "source_type_concept_id" uuid,
    "source_id" uuid,
    "idempotency_key" varchar,
    "correlation_id" uuid,
    "erp_goods_receipt_item_id" uuid,
    "accounting_ledger_entry_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_inventory_ledger_entries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_reservations" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "medication_request_id" uuid,
    "quotation_id" uuid,
    "reservation_status_concept_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "confirmed_at" timestamptz,
    "released_at" timestamptz,
    "idempotency_key" varchar,
    "delivery_mode_concept_id" uuid,
    "delivery_address_id" uuid,
    "total_amount" numeric,
    "currency_concept_id" uuid,
    "pickup_code" varchar,
    "rejection_reason_text" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_reservations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_reservation_lines" (
    "id" uuid NOT NULL,
    "inventory_reservation_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "inventory_lot_id" uuid,
    "inventory_location_id" uuid,
    "requested_quantity" numeric NOT NULL,
    "reserved_quantity" numeric NOT NULL,
    "fulfilled_quantity" numeric,
    "status_concept_id" uuid NOT NULL,
    "unit_price_amount" numeric,
    "currency_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_reservation_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_order_substitutions" (
    "id" uuid NOT NULL,
    "inventory_reservation_id" uuid NOT NULL,
    "inventory_reservation_line_id" uuid NOT NULL,
    "original_pharmacy_product_id" uuid NOT NULL,
    "proposed_pharmacy_product_id" uuid NOT NULL,
    "original_unit_price_amount" numeric,
    "proposed_unit_price_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "decided_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_order_substitutions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_count_sessions" (
    "id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "inventory_location_id" uuid NOT NULL,
    "count_type_concept_id" uuid NOT NULL,
    "freeze_mode_concept_id" uuid,
    "started_at" timestamptz,
    "completed_at" timestamptz,
    "approved_at" timestamptz,
    "approved_by_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_count_sessions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_count_lines" (
    "id" uuid NOT NULL,
    "inventory_count_session_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "inventory_lot_id" uuid,
    "expected_quantity" numeric NOT NULL,
    "counted_quantity" numeric NOT NULL,
    "variance_quantity" numeric NOT NULL,
    "variance_reason_concept_id" uuid,
    "adjustment_ledger_entry_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_inventory_count_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."inventory_recall_holds" (
    "id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "inventory_lot_id" uuid,
    "recall_reference" varchar NOT NULL,
    "recall_class_concept_id" uuid NOT NULL,
    "hold_status_concept_id" uuid NOT NULL,
    "initiated_at" timestamptz,
    "released_at" timestamptz,
    "source_authority_tenant_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inventory_recall_holds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_suppliers" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "supplier_tenant_id" uuid NOT NULL,
    "supplier_code" varchar,
    "business_partner_id" uuid,
    "payment_terms_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_suppliers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_purchase_orders" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "pharmacy_supplier_id" uuid NOT NULL,
    "purchase_order_number" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "ordered_at" timestamptz,
    "expected_at" timestamptz,
    "currency_concept_id" uuid,
    "idempotency_key" varchar,
    "erp_purchase_order_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_purchase_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_purchase_order_lines" (
    "id" uuid NOT NULL,
    "pharmacy_purchase_order_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "erp_purchase_order_item_id" uuid,
    "ordered_quantity" numeric NOT NULL,
    "received_quantity" numeric,
    "unit_cost_amount" numeric,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_purchase_order_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_goods_receipts" (
    "id" uuid NOT NULL,
    "pharmacy_purchase_order_id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "erp_goods_receipt_id" uuid,
    "receipt_number" varchar NOT NULL,
    "received_at" timestamptz NOT NULL,
    "supplier_delivery_reference" varchar,
    "source_document_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "idempotency_key" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_goods_receipts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_goods_receipt_lines" (
    "id" uuid NOT NULL,
    "pharmacy_goods_receipt_id" uuid NOT NULL,
    "pharmacy_purchase_order_line_id" uuid NOT NULL,
    "erp_goods_receipt_item_id" uuid,
    "pharmacy_product_id" uuid NOT NULL,
    "inventory_lot_id" uuid,
    "inventory_location_id" uuid,
    "received_quantity" numeric NOT NULL,
    "accepted_quantity" numeric,
    "rejected_quantity" numeric,
    "unit_cost_amount" numeric,
    "ledger_entry_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_pharmacy_goods_receipt_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."medication_dispensations" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "medication_request_id" uuid,
    "insurance_claim_id" uuid,
    "inventory_reservation_id" uuid,
    "dispensation_status_concept_id" uuid NOT NULL,
    "dispensed_at" timestamptz,
    "dispenser_practitioner_profile_id" uuid,
    "substitution_reason_concept_id" uuid,
    "idempotency_key" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_medication_dispensations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."medication_dispensation_lines" (
    "id" uuid NOT NULL,
    "medication_dispensation_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "inventory_lot_id" uuid,
    "inventory_serial_id" uuid,
    "dispensed_quantity" numeric NOT NULL,
    "unit_price_amount" numeric,
    "patient_amount" numeric,
    "insurer_amount" numeric,
    "ledger_entry_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_medication_dispensation_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_inventory_sync_batches" (
    "id" uuid NOT NULL,
    "pharmacy_integration_connection_id" uuid NOT NULL,
    "direction_concept_id" uuid NOT NULL,
    "source_batch_identifier" varchar NOT NULL,
    "sync_cursor_before" varchar,
    "sync_cursor_after" varchar,
    "received_at" timestamptz,
    "completed_at" timestamptz,
    "item_count" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_inventory_sync_batches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_inventory_sync_items" (
    "id" uuid NOT NULL,
    "pharmacy_inventory_sync_batch_id" uuid NOT NULL,
    "pharmacy_product_id" uuid,
    "external_product_code" varchar,
    "external_location_code" varchar,
    "external_lot_number" varchar,
    "external_quantity" numeric,
    "normalized_quantity" numeric,
    "idempotency_key" varchar,
    "reconciliation_status_concept_id" uuid NOT NULL,
    "error_code" varchar,
    "error_detail" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_pharmacy_inventory_sync_items" PRIMARY KEY ("id")
);
