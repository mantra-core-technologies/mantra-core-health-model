-- SALUD v4.2.81 · módulo 77 · schema pay_schedules
-- Generado de diagram_77_pay_schedules.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "scheduled_payments"
        ADD CONSTRAINT "fk_scheduled_payments_mandate_id" FOREIGN KEY ("mandate_id")
        REFERENCES "mandates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
