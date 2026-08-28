-- SALUD v4.0.10 · módulo 17 · schema billing
-- Generado de diagram_17_billing.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "billing"."service_catalog"
        ADD CONSTRAINT "fk_service_catalog_tax_code_id" FOREIGN KEY ("tax_code_id")
        REFERENCES "billing"."tax_codes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_tax_code_id" FOREIGN KEY ("tax_code_id")
        REFERENCES "billing"."tax_codes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."payments_received"
        ADD CONSTRAINT "fk_payments_received_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."bills"
        ADD CONSTRAINT "fk_bills_vendor_id" FOREIGN KEY ("vendor_id")
        REFERENCES "billing"."vendors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."bill_lines"
        ADD CONSTRAINT "fk_bill_lines_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."payments_made"
        ADD CONSTRAINT "fk_payments_made_vendor_id" FOREIGN KEY ("vendor_id")
        REFERENCES "billing"."vendors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."budget_lines"
        ADD CONSTRAINT "fk_budget_lines_budget_id" FOREIGN KEY ("budget_id")
        REFERENCES "billing"."budgets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."receivable_payment_allocations"
        ADD CONSTRAINT "fk_receivable_payment_allocations_payment_received_id" FOREIGN KEY ("payment_received_id")
        REFERENCES "billing"."payments_received" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."receivable_payment_allocations"
        ADD CONSTRAINT "fk_receivable_payment_allocations_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."payable_payment_allocations"
        ADD CONSTRAINT "fk_payable_payment_allocations_payment_made_id" FOREIGN KEY ("payment_made_id")
        REFERENCES "billing"."payments_made" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."payable_payment_allocations"
        ADD CONSTRAINT "fk_payable_payment_allocations_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_bill_id" FOREIGN KEY ("bill_id")
        REFERENCES "billing"."bills" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."dunning_items"
        ADD CONSTRAINT "fk_dunning_items_dunning_run_id" FOREIGN KEY ("dunning_run_id")
        REFERENCES "billing"."dunning_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."dunning_items"
        ADD CONSTRAINT "fk_dunning_items_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
