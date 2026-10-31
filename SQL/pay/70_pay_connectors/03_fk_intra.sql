-- SALUD v4.2.81 · módulo 70 · schema pay_connectors
-- Generado de diagram_70_pay_connectors.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "connector_refunds"
        ADD CONSTRAINT "fk_connector_refunds_charge_id" FOREIGN KEY ("charge_id")
        REFERENCES "connector_charges" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "bank_transfer_references"
        ADD CONSTRAINT "fk_bank_transfer_references_charge_id" FOREIGN KEY ("charge_id")
        REFERENCES "connector_charges" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
