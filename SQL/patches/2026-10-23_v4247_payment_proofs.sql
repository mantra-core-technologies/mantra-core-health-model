-- ============================================================================
-- SALUD · patch v4.2.47 (billing · comprobantes de pago del paciente, C-01) sobre BD viva
-- Fecha: 2026-10-23 · correcciones del propietario del 2026-10-23 (MD-06 / PA-04)
-- Numeración: la serie v42xx sigue en la copia de despliegue de la API (database/SQL/patches
-- llega a v4246 con cambios que todavía no volvieron a este repo); por eso este es v4247.
-- Idempotente (IF NOT EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esta tabla, sus índices, sus
-- FKs y sus CHECK en SQL/17_billing/ desde que diagram_17_billing.puml y
-- diagram_33_integrity.puml la declaran, así que en un rebuild desde cero este
-- patch NO hace falta. Existe para una base ya aplicada y poblada. Las
-- sentencias se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. El paciente paga la consulta contra el QR bancario estático de la
-- sede (practice.practice_sites.bank_qr_file_id) y sube el comprobante, o declara
-- que pagó en efectivo. El médico lo acepta o lo rechaza con motivo. El cargo de
-- la consulta ES el encuentro (clinical.encounters): no existe billing.charges,
-- por eso la columna se llama encounter_id. Un solo comprobante PENDING_REVIEW por
-- encuentro (índice único parcial sobre el concepto sembrado billing:PROOF_PENDING_REVIEW).
-- Dinero en unidades menores (amount_minor bigint + currency ISO).
--
-- Conceptos nuevos que siembra la API al arrancar (common/seed, billing.concepts.ts):
--   billing:PROOF_PENDING_REVIEW 351d39c9-7ffe-598b-96f5-d30125186cfe
--   billing:PROOF_ACCEPTED       9687803d-d8bd-5952-a822-f1668e8c13f2
--   billing:PROOF_REJECTED       c487d958-3cbf-5082-8b6a-735cb2186cd8
--   billing:METHOD_QR_TRANSFER   78a2a1c8-5e68-5aaa-b43f-b23d00f69e95
-- ============================================================================
BEGIN;

-- 02_tables.sql
CREATE TABLE IF NOT EXISTS "billing"."payment_proofs" (
    "id" uuid NOT NULL,
    "encounter_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "practice_site_id" uuid,
    "method_concept_id" uuid NOT NULL,
    "file_id" uuid,
    "amount_minor" bigint NOT NULL,
    "currency" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "rejection_reason" text,
    "reviewed_by_user_id" uuid,
    "reviewed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_payment_proofs" PRIMARY KEY ("id")
);

-- 04_indexes.sql
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_encounter_id" ON "billing"."payment_proofs" ("encounter_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_tenant_id" ON "billing"."payment_proofs" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_patient_profile_id" ON "billing"."payment_proofs" ("patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_practice_site_id" ON "billing"."payment_proofs" ("practice_site_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_method_concept_id" ON "billing"."payment_proofs" ("method_concept_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_file_id" ON "billing"."payment_proofs" ("file_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_status_concept_id" ON "billing"."payment_proofs" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_reviewed_by_user_id" ON "billing"."payment_proofs" ("reviewed_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_created_by_user_id" ON "billing"."payment_proofs" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_updated_by_user_id" ON "billing"."payment_proofs" ("updated_by_user_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_payment_proofs_pending_per_charge" ON "billing"."payment_proofs" ("encounter_id") WHERE status_concept_id = '351d39c9-7ffe-598b-96f5-d30125186cfe';
CREATE INDEX IF NOT EXISTS "ix_payment_proofs_patient_profile_id_created_at" ON "billing"."payment_proofs" ("patient_profile_id", "created_at" DESC);

-- 90_fk_deferred.sql
-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_method_concept_id" FOREIGN KEY ("method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_reviewed_by_user_id" FOREIGN KEY ("reviewed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."payment_proofs"
        ADD CONSTRAINT "fk_payment_proofs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- 05_constraints.sql
ALTER TABLE "billing"."payment_proofs" DROP CONSTRAINT IF EXISTS "ck_payment_proofs_qr_requires_file";
ALTER TABLE "billing"."payment_proofs" ADD CONSTRAINT "ck_payment_proofs_qr_requires_file" CHECK (("method_concept_id" <> '78a2a1c8-5e68-5aaa-b43f-b23d00f69e95' OR "file_id" IS NOT NULL));
ALTER TABLE "billing"."payment_proofs" DROP CONSTRAINT IF EXISTS "ck_payment_proofs_rejected_requires_reason";
ALTER TABLE "billing"."payment_proofs" ADD CONSTRAINT "ck_payment_proofs_rejected_requires_reason" CHECK (("status_concept_id" <> 'c487d958-3cbf-5082-8b6a-735cb2186cd8' OR NULLIF(BTRIM("rejection_reason"), '') IS NOT NULL));
ALTER TABLE "billing"."payment_proofs" DROP CONSTRAINT IF EXISTS "ck_payment_proofs_amount_positive";
ALTER TABLE "billing"."payment_proofs" ADD CONSTRAINT "ck_payment_proofs_amount_positive" CHECK (("amount_minor" > 0));

COMMIT;
