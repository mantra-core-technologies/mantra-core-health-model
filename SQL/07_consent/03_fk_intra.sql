-- SALUD v4.0.10 · módulo 07 · schema consent
-- Generado de diagram_07_consent.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "consent"."processing_legal_bases"
        ADD CONSTRAINT "fk_processing_legal_bases_processing_purpose_id" FOREIGN KEY ("processing_purpose_id")
        REFERENCES "consent"."processing_purposes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."consents"
        ADD CONSTRAINT "fk_consents_processing_purpose_id" FOREIGN KEY ("processing_purpose_id")
        REFERENCES "consent"."processing_purposes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."consents"
        ADD CONSTRAINT "fk_consents_processing_legal_basis_id" FOREIGN KEY ("processing_legal_basis_id")
        REFERENCES "consent"."processing_legal_bases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."consent_provisions"
        ADD CONSTRAINT "fk_consent_provisions_consent_id" FOREIGN KEY ("consent_id")
        REFERENCES "consent"."consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."hipaa_authorizations"
        ADD CONSTRAINT "fk_hipaa_authorizations_processing_purpose_id" FOREIGN KEY ("processing_purpose_id")
        REFERENCES "consent"."processing_purposes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."patient_objections"
        ADD CONSTRAINT "fk_patient_objections_processing_purpose_id" FOREIGN KEY ("processing_purpose_id")
        REFERENCES "consent"."processing_purposes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
