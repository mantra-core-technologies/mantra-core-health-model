-- SALUD v4.0.10 · módulo 78 · schema pay_settlement
-- Generado de diagram_78_pay_settlement.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "settlement_merchant_marks"
        ADD CONSTRAINT "fk_settlement_merchant_marks_merchant_id" FOREIGN KEY ("merchant_id")
        REFERENCES "settlement_merchants" ("merchant_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "settlement_batch_items"
        ADD CONSTRAINT "fk_settlement_batch_items_batch_id" FOREIGN KEY ("batch_id")
        REFERENCES "settlement_batches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "settlement_payouts"
        ADD CONSTRAINT "fk_settlement_payouts_batch_id" FOREIGN KEY ("batch_id")
        REFERENCES "settlement_batches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "settlement_charge_collections"
        ADD CONSTRAINT "fk_settlement_charge_collections_charge_id" FOREIGN KEY ("charge_id")
        REFERENCES "settlement_charges" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "settlement_statement_lines"
        ADD CONSTRAINT "fk_settlement_statement_lines_run_id" FOREIGN KEY ("run_id")
        REFERENCES "settlement_reconciliation_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "settlement_exceptions"
        ADD CONSTRAINT "fk_settlement_exceptions_run_id" FOREIGN KEY ("run_id")
        REFERENCES "settlement_reconciliation_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "settlement_adjustment_requests"
        ADD CONSTRAINT "fk_settlement_adjustment_requests_exception_id" FOREIGN KEY ("exception_id")
        REFERENCES "settlement_exceptions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
