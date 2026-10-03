-- Generated from SQL/05_profiles; run gen_ddl.py 05 first.

BEGIN;

ALTER TABLE "profiles"."health_practitioner_profiles" ADD COLUMN IF NOT EXISTS "signature_file_id" uuid;

DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_signature_file_id" FOREIGN KEY ("signature_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_signature_file_id" ON "profiles"."health_practitioner_profiles" ("signature_file_id");

ALTER TABLE "profiles"."health_practitioner_profiles" ADD COLUMN IF NOT EXISTS "seal_file_id" uuid;

DO $$ BEGIN
    ALTER TABLE "profiles"."health_practitioner_profiles"
        ADD CONSTRAINT "fk_health_practitioner_profiles_seal_file_id" FOREIGN KEY ("seal_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_health_practitioner_profiles_seal_file_id" ON "profiles"."health_practitioner_profiles" ("seal_file_id");

COMMIT;
