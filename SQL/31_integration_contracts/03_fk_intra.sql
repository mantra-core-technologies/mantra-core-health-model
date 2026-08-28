-- SALUD v4.0.10 · módulo 31 · schema integration_contracts
-- Generado de diagram_31_integration_contracts.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contract_versions"
        ADD CONSTRAINT "fk_integration_contract_versions_integration_contract_id" FOREIGN KEY ("integration_contract_id")
        REFERENCES "integration_contracts"."integration_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contract_versions"
        ADD CONSTRAINT "fk_integration_contract_versions_mapping_profile_id" FOREIGN KEY ("mapping_profile_id")
        REFERENCES "integration_contracts"."integration_auth_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_auth_profiles"
        ADD CONSTRAINT "fk_integration_auth_profiles_integration_contract_id" FOREIGN KEY ("integration_contract_id")
        REFERENCES "integration_contracts"."integration_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_records"
        ADD CONSTRAINT "fk_integration_exchange_records_integration_contract_version_id" FOREIGN KEY ("integration_contract_version_id")
        REFERENCES "integration_contracts"."integration_contract_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_exchange_attempts"
        ADD CONSTRAINT "fk_integration_exchange_attempts_integration_exchange_record_id" FOREIGN KEY ("integration_exchange_record_id")
        REFERENCES "integration_contracts"."integration_exchange_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_idempotency_records"
        ADD CONSTRAINT "fk_integration_idempotency_records_integration_contract_id" FOREIGN KEY ("integration_contract_id")
        REFERENCES "integration_contracts"."integration_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_idempotency_records"
        ADD CONSTRAINT "fk_integration_idempotency_records_first_exchange_record_id" FOREIGN KEY ("first_exchange_record_id")
        REFERENCES "integration_contracts"."integration_exchange_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_sync_cursors"
        ADD CONSTRAINT "fk_integration_sync_cursors_integration_contract_id" FOREIGN KEY ("integration_contract_id")
        REFERENCES "integration_contracts"."integration_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_sync_cursors"
        ADD CONSTRAINT "fk_integration_sync_cursors_last_successful_exchange_id" FOREIGN KEY ("last_successful_exchange_id")
        REFERENCES "integration_contracts"."integration_exchange_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."contract_webhook_subscriptions"
        ADD CONSTRAINT "fk_contract_webhook_subscriptions_integration_contract_id" FOREIGN KEY ("integration_contract_id")
        REFERENCES "integration_contracts"."integration_contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "integration_contracts"."webhook_delivery_evidence"
        ADD CONSTRAINT "fk_webhook_delivery_evidence_integration_exchange_record_id" FOREIGN KEY ("integration_exchange_record_id")
        REFERENCES "integration_contracts"."integration_exchange_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
