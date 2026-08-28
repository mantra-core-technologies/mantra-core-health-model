-- SALUD v4.0.10 · módulo 05 · schema profiles
-- Generado de diagram_05_profiles.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_merge_survivor_person_id" FOREIGN KEY ("merge_survivor_person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."person_account_links"
        ADD CONSTRAINT "fk_person_account_links_person_id" FOREIGN KEY ("person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."person_profiles"
        ADD CONSTRAINT "fk_person_profiles_person_id" FOREIGN KEY ("person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_profiles"
        ADD CONSTRAINT "fk_patient_profiles_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_identity_links"
        ADD CONSTRAINT "fk_patient_identity_links_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_merge_events"
        ADD CONSTRAINT "fk_patient_merge_events_surviving_patient_profile_id" FOREIGN KEY ("surviving_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_merge_events"
        ADD CONSTRAINT "fk_patient_merge_events_merged_patient_profile_id" FOREIGN KEY ("merged_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_merge_events"
        ADD CONSTRAINT "fk_patient_merge_events_reversal_of_event_id" FOREIGN KEY ("reversal_of_event_id")
        REFERENCES "profiles"."patient_merge_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_specialties"
        ADD CONSTRAINT "fk_practitioner_specialties_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_specialties"
        ADD CONSTRAINT "fk_practitioner_specialties_supporting_credential_id" FOREIGN KEY ("supporting_credential_id")
        REFERENCES "profiles"."professional_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_languages"
        ADD CONSTRAINT "fk_practitioner_languages_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."jurisdiction_authorizations"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."related_persons"
        ADD CONSTRAINT "fk_related_persons_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."related_persons"
        ADD CONSTRAINT "fk_related_persons_person_id" FOREIGN KEY ("person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_portal_proxies"
        ADD CONSTRAINT "fk_patient_portal_proxies_related_person_id" FOREIGN KEY ("related_person_id")
        REFERENCES "profiles"."related_persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."insurance_representative_profiles"
        ADD CONSTRAINT "fk_insurance_representative_profiles_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."provider_operator_profiles"
        ADD CONSTRAINT "fk_provider_operator_profiles_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."emergency_staff_profiles"
        ADD CONSTRAINT "fk_emergency_staff_profiles_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."administrator_profiles"
        ADD CONSTRAINT "fk_administrator_profiles_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."secretary_profiles"
        ADD CONSTRAINT "fk_secretary_profiles_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
