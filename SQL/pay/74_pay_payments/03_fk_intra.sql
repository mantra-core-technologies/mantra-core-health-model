-- SALUD v4.2.82 · módulo 74 · schema pay_payments
-- Generado de diagram_74_pay_payments.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "refunds"
        ADD CONSTRAINT "fk_refunds_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "disputes"
        ADD CONSTRAINT "fk_disputes_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "payment_cancellation_requests"
        ADD CONSTRAINT "fk_payment_cancellation_requests_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
