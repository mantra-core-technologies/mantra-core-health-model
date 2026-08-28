-- SALUD v4.0.10 · módulo 24 · schema pharmacy
-- Generado de diagram_24_pharmacy.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "legal_name" varchar NOT NULL,
    "trade_name" varchar,
    "pharmacy_type_concept_id" uuid,
    "ownership_type_concept_id" uuid,
    "public_profile_id" uuid,
    "default_currency_concept_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_sites" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "pharmacy_site_type_concept_id" uuid,
    "dispensing_mode_concept_id" uuid,
    "controlled_substance_capability_concept_id" uuid,
    "home_delivery_available" boolean,
    "pickup_available" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_sites" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_licenses" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "pharmacy_site_id" uuid,
    "license_type_concept_id" uuid NOT NULL,
    "license_number" varchar NOT NULL,
    "issuing_authority_tenant_id" uuid,
    "jurisdiction_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "evidence_file_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_licenses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_products" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "product_code" varchar NOT NULL,
    "medication_concept_id" uuid,
    "inventory_item_concept_id" uuid,
    "manufacturer_tenant_id" uuid,
    "brand_name" varchar,
    "generic_name" varchar,
    "strength_text" varchar,
    "dosage_form_concept_id" uuid,
    "package_size_text" varchar,
    "requires_prescription" boolean,
    "cold_chain_required" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_products" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_product_identifiers" (
    "id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "identifier_type_concept_id" uuid NOT NULL,
    "identifier_value" varchar NOT NULL,
    "assigning_authority_tenant_id" uuid,
    "jurisdiction_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_pharmacy_product_identifiers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_price_lists" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "pharmacy_site_id" uuid,
    "code" varchar NOT NULL,
    "price_list_type_concept_id" uuid NOT NULL,
    "insurer_tenant_id" uuid,
    "currency_concept_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "public_visibility" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_price_lists" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_product_prices" (
    "id" uuid NOT NULL,
    "pharmacy_price_list_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "unit_amount" numeric NOT NULL,
    "tax_amount" numeric,
    "patient_amount" numeric,
    "insurer_amount" numeric,
    "minimum_quantity" numeric,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_pharmacy_product_prices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_integration_connections" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "pharmacy_site_id" uuid,
    "connection_id" uuid NOT NULL,
    "integration_mode_concept_id" uuid NOT NULL,
    "inventory_authority_concept_id" uuid,
    "supports_stock_query" boolean,
    "supports_price_query" boolean,
    "supports_reservation" boolean,
    "supports_dispense_confirmation" boolean,
    "manual_fallback_allowed" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_integration_connections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_external_product_mappings" (
    "id" uuid NOT NULL,
    "pharmacy_integration_connection_id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "external_product_code" varchar NOT NULL,
    "external_unit_code" varchar,
    "mapping_version" varchar,
    "verification_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_external_product_mappings" PRIMARY KEY ("id")
);
