-- SALUD v4.2.81 · módulo 73 · schema pay_merchants
-- Generado de diagram_73_pay_merchants.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "merchant_kyc"
        ADD CONSTRAINT "fk_merchant_kyc_merchant_id" FOREIGN KEY ("merchant_id")
        REFERENCES "merchants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "kyc_documents"
        ADD CONSTRAINT "fk_kyc_documents_merchant_id" FOREIGN KEY ("merchant_id")
        REFERENCES "merchants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "contract_acceptances"
        ADD CONSTRAINT "fk_contract_acceptances_merchant_id" FOREIGN KEY ("merchant_id")
        REFERENCES "merchants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "contract_acceptances"
        ADD CONSTRAINT "fk_contract_acceptances_version" FOREIGN KEY ("version")
        REFERENCES "contract_versions" ("version");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "fee_schedule_versions"
        ADD CONSTRAINT "fk_fee_schedule_versions_merchant_id" FOREIGN KEY ("merchant_id")
        REFERENCES "merchants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "api_keys"
        ADD CONSTRAINT "fk_api_keys_merchant_id" FOREIGN KEY ("merchant_id")
        REFERENCES "merchants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
