-- SALUD v4.2.79 · módulo 72 · schema pay_ledger
-- Generado de diagram_72_pay_ledger.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "ledger_statement_lines"
        ADD CONSTRAINT "fk_ledger_statement_lines_leg_id" FOREIGN KEY ("leg_id")
        REFERENCES "ledger_legs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
