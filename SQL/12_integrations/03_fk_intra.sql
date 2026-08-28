-- SALUD v4.0.10 · módulo 12 · schema integrations
-- Generado de diagram_12_integrations.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "integrations"."provider_connections"
        ADD CONSTRAINT "fk_provider_connections_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."provider_connections"
        ADD CONSTRAINT "fk_provider_connections_credential_id" FOREIGN KEY ("credential_id")
        REFERENCES "integrations"."provider_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."provider_credentials"
        ADD CONSTRAINT "fk_provider_credentials_connection_id" FOREIGN KEY ("connection_id")
        REFERENCES "integrations"."provider_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."integration_endpoints"
        ADD CONSTRAINT "fk_integration_endpoints_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."outbound_messages"
        ADD CONSTRAINT "fk_outbound_messages_connection_id" FOREIGN KEY ("connection_id")
        REFERENCES "integrations"."provider_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."outbound_messages"
        ADD CONSTRAINT "fk_outbound_messages_endpoint_id" FOREIGN KEY ("endpoint_id")
        REFERENCES "integrations"."integration_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."inbound_messages"
        ADD CONSTRAINT "fk_inbound_messages_connection_id" FOREIGN KEY ("connection_id")
        REFERENCES "integrations"."provider_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."inbound_messages"
        ADD CONSTRAINT "fk_inbound_messages_endpoint_id" FOREIGN KEY ("endpoint_id")
        REFERENCES "integrations"."integration_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."message_responses"
        ADD CONSTRAINT "fk_message_responses_outbound_message_id" FOREIGN KEY ("outbound_message_id")
        REFERENCES "integrations"."outbound_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."message_retries"
        ADD CONSTRAINT "fk_message_retries_outbound_message_id" FOREIGN KEY ("outbound_message_id")
        REFERENCES "integrations"."outbound_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."webhook_subscriptions"
        ADD CONSTRAINT "fk_webhook_subscriptions_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integrations"."integration_field_mappings"
        ADD CONSTRAINT "fk_integration_field_mappings_endpoint_id" FOREIGN KEY ("endpoint_id")
        REFERENCES "integrations"."integration_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
