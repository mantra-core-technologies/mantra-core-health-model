-- SALUD v4.0.10 · módulo 40 · schema auth_providers
-- Generado de diagram_40_auth_providers.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "auth_providers"."provider_protocol_configs"
        ADD CONSTRAINT "fk_provider_protocol_configs_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "auth_providers"."provider_signing_keys"
        ADD CONSTRAINT "fk_provider_signing_keys_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "auth_providers"."provider_tenant_bindings"
        ADD CONSTRAINT "fk_provider_tenant_bindings_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "auth_providers"."provider_attribute_mappings"
        ADD CONSTRAINT "fk_provider_attribute_mappings_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "auth_providers"."provisioning_rules"
        ADD CONSTRAINT "fk_provisioning_rules_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "auth_providers"."federated_identities"
        ADD CONSTRAINT "fk_federated_identities_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "auth_providers"."account_link_requests"
        ADD CONSTRAINT "fk_account_link_requests_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "auth_providers"."federated_login_attempts"
        ADD CONSTRAINT "fk_federated_login_attempts_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "auth_providers"."identity_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
