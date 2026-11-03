-- Generado desde SQL/16_accounting por gen_report_templates_patch.py.

BEGIN;

CREATE TABLE IF NOT EXISTS "accounting"."report_presentation_templates" (
    "id" uuid NOT NULL,
    "user_type" varchar(40) NOT NULL,
    "code" varchar(80) NOT NULL,
    "name" varchar(160) NOT NULL,
    "report_kind" varchar(40) NOT NULL,
    "presentation_json" jsonb NOT NULL,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_presentation_templates" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_report_presentation_templates_audience_code" ON "accounting"."report_presentation_templates" ("user_type", "code");

CREATE INDEX IF NOT EXISTS "ix_report_presentation_templates_created_by_user_id" ON "accounting"."report_presentation_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_presentation_templates_updated_by_user_id" ON "accounting"."report_presentation_templates" ("updated_by_user_id");

DO $$ BEGIN
    ALTER TABLE "accounting"."report_presentation_templates"
        ADD CONSTRAINT "fk_report_presentation_templates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."report_presentation_templates"
        ADD CONSTRAINT "fk_report_presentation_templates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='mantra_app') THEN GRANT SELECT, INSERT, UPDATE ON "accounting"."report_presentation_templates" TO mantra_app; END IF; END $$;

COMMIT;
