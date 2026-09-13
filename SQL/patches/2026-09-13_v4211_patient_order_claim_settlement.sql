-- v4.2.11 — T-24: trazabilidad de liquidación del pedido del paciente.
BEGIN;
SELECT pg_advisory_xact_lock(728431905112004);

ALTER TABLE "insurance"."prior_authorization_requests"
  ADD COLUMN IF NOT EXISTS "inventory_reservation_id" uuid;

ALTER TABLE "insurance"."insurance_claims"
  ADD COLUMN IF NOT EXISTS "inventory_reservation_id" uuid,
  ADD COLUMN IF NOT EXISTS "service_request_id" uuid;
ALTER TABLE "insurance"."insurance_claim_lines"
  ADD COLUMN IF NOT EXISTS "inventory_reservation_line_id" uuid;

DO $$ BEGIN
  ALTER TABLE "insurance"."insurance_claims" ADD CONSTRAINT "ck_insurance_claims_single_order_origin"
    CHECK ("inventory_reservation_id" IS NULL OR "service_request_id" IS NULL);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE "insurance"."insurance_claims" ADD CONSTRAINT "fk_insurance_claims_inventory_reservation_id"
    FOREIGN KEY ("inventory_reservation_id") REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE "insurance"."insurance_claims" ADD CONSTRAINT "fk_insurance_claims_service_request_id"
    FOREIGN KEY ("service_request_id") REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE "insurance"."insurance_claim_lines" ADD CONSTRAINT "fk_insurance_claim_lines_inventory_reservation_line_id"
    FOREIGN KEY ("inventory_reservation_line_id") REFERENCES "pharmacy_inventory"."inventory_reservation_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_insurance_claims_inventory_reservation_id" ON "insurance"."insurance_claims" ("inventory_reservation_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_claims_service_request_id" ON "insurance"."insurance_claims" ("service_request_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_claim_lines_inventory_reservation_line_id" ON "insurance"."insurance_claim_lines" ("inventory_reservation_line_id");
DO $$ BEGIN
  ALTER TABLE "insurance"."prior_authorization_requests" ADD CONSTRAINT "ck_prior_authorizations_single_order_origin"
    CHECK ("inventory_reservation_id" IS NULL OR "service_request_id" IS NULL);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE "insurance"."prior_authorization_requests" ADD CONSTRAINT "fk_prior_authorization_requests_inventory_reservation_id"
    FOREIGN KEY ("inventory_reservation_id") REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
CREATE INDEX IF NOT EXISTS "ix_prior_authorization_requests_inventory_reservation_id"
  ON "insurance"."prior_authorization_requests" ("inventory_reservation_id");
COMMIT;