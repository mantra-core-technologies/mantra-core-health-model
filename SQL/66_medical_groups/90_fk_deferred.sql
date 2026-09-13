-- SALUD v4.0.10 · módulo 66 · schema medical_groups
-- Generado de diagram_66_medical_groups.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.service_catalog (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_service_catalog_id" FOREIGN KEY ("service_catalog_id")
        REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_requesting_practitioner_id" FOREIGN KEY ("requesting_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.conditions (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_condition_id" FOREIGN KEY ("condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_proposed_by_practitioner_id" FOREIGN KEY ("proposed_by_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_groups_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_group_members_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_group_members_agreed_payment_currency_concept_id" FOREIGN KEY ("agreed_payment_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_group_members_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_group_members_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
