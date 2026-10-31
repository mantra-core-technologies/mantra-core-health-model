-- SALUD v4.2.68 · módulo 80 · schema pay_webhooks
-- Generado de diagram_80_pay_webhooks.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "webhook_secrets"
        ADD CONSTRAINT "fk_webhook_secrets_endpoint_id" FOREIGN KEY ("endpoint_id")
        REFERENCES "webhook_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "webhook_deliveries"
        ADD CONSTRAINT "fk_webhook_deliveries_endpoint_id" FOREIGN KEY ("endpoint_id")
        REFERENCES "webhook_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "webhook_delivery_attempts"
        ADD CONSTRAINT "fk_webhook_delivery_attempts_delivery_id" FOREIGN KEY ("delivery_id")
        REFERENCES "webhook_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
