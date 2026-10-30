-- ============================================================================
-- SALUD · patch v4.2.64 (insurance · solicitud médico → aseguradora) sobre BD viva
-- Fecha: 2026-10-28 · pedido del propietario del 2026-10-28
-- Idempotente (IF NOT EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py emite esta tabla, sus índices y sus FKs en
-- SQL/26_insurance/ desde que el .puml la declara, así que en un rebuild desde
-- cero este patch NO hace falta. Existe para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las
-- sentencias se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. El médico declara con qué aseguradoras trabaja —en el alta o
-- después— y cada aseguradora lo confirma o lo rechaza desde su bandeja. La
-- confirmación es el sello oficial que ve el médico en «Mis verificaciones».
-- No reemplaza a network_provider_memberships: aquélla es el contrato con una
-- red; ésta, el pedido.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +1 · FKs +6 · índices +8 (7 declarados + PK)
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "insurance"."practitioner_insurer_requests" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "decision_reason_text" varchar,
    "decided_at" timestamptz,
    "decided_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_insurer_requests" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "ix_practitioner_insurer_requests_practitioner_profile_id" ON "insurance"."practitioner_insurer_requests" ("practitioner_profile_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_insurer_requests_insurance_carrier_id" ON "insurance"."practitioner_insurer_requests" ("insurance_carrier_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_insurer_requests_status_concept_id" ON "insurance"."practitioner_insurer_requests" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_insurer_requests_decided_by_user_id" ON "insurance"."practitioner_insurer_requests" ("decided_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_insurer_requests_created_by_user_id" ON "insurance"."practitioner_insurer_requests" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_insurer_requests_updated_by_user_id" ON "insurance"."practitioner_insurer_requests" ("updated_by_user_id");
-- Única sólo entre las vivas (pendiente, aprobada): volver a pedir tras un
-- rechazo o un retiro crea otra fila y la anterior queda como historia. El
-- DROP cubre una base donde se aplicó el borrador de este patch con el índice
-- único por par; en una base nueva no hace nada.
DROP INDEX IF EXISTS "insurance"."uq_practitioner_insurer_requests_pair";
CREATE UNIQUE INDEX IF NOT EXISTS "uq_practitioner_insurer_requests_live_pair" ON "insurance"."practitioner_insurer_requests" ("practitioner_profile_id", "insurance_carrier_id") WHERE status_concept_id IN ('bc4f121c-f0cf-54b9-a1b8-f9a62a1cde8c', 'dfb1912e-d1ad-5566-8f9b-1d7a09f9da8f');

DO $$ BEGIN
    ALTER TABLE "insurance"."practitioner_insurer_requests"
        ADD CONSTRAINT "fk_practitioner_insurer_requests_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."practitioner_insurer_requests"
        ADD CONSTRAINT "fk_practitioner_insurer_requests_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."practitioner_insurer_requests"
        ADD CONSTRAINT "fk_practitioner_insurer_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."practitioner_insurer_requests"
        ADD CONSTRAINT "fk_practitioner_insurer_requests_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."practitioner_insurer_requests"
        ADD CONSTRAINT "fk_practitioner_insurer_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "insurance"."practitioner_insurer_requests"
        ADD CONSTRAINT "fk_practitioner_insurer_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
