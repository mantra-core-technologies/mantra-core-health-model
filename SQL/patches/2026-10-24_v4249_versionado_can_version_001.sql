-- ============================================================================
-- SALUD · patch (versionado · intervenciones, productos de seguro, campañas y segmentos) sobre BD viva
-- Fecha: 2026-10-24 · issue #57 CAN-VERSION-001
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. Columnas nullable de versión (el objeto existente queda sin versión; el servicio
-- que la escriba trata NULL como la versión inicial):
--   - procedures_perioperative.procedure_cases.version_number y
--     procedure_case_team_members.accepted_version_number (qué versión aceptó cada integrante);
--   - insurance.insurance_products.version_number, effective_from y effective_to (los planes ya
--     tenían vigencia);
--   - ads.campaigns, ads.custom_audiences, ads.saved_audiences y marketing.segments:
--     version_number.
-- Y los historiales de versiones de los dos objetos que no tenían: audit.insurance_products_history
-- y audit.procedure_cases_history (mismo patrón que audit.campaigns_history).
--
-- PRECONDICIÓN: effective_from <= effective_to; las columnas son nuevas, así que se cumple.
-- SIN BACKFILL.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +2 · columnas +9 · NOT NULL quitados 0 · FKs +8 · índices +10 (-0) · constraints +1
-- ============================================================================

BEGIN;

ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "version_number" integer;

ALTER TABLE "procedures_perioperative"."procedure_case_team_members"
    ADD COLUMN IF NOT EXISTS "accepted_version_number" integer;

ALTER TABLE "insurance"."insurance_products"
    ADD COLUMN IF NOT EXISTS "version_number" integer;

ALTER TABLE "insurance"."insurance_products"
    ADD COLUMN IF NOT EXISTS "effective_from" date;

ALTER TABLE "insurance"."insurance_products"
    ADD COLUMN IF NOT EXISTS "effective_to" date;

ALTER TABLE "ads"."campaigns"
    ADD COLUMN IF NOT EXISTS "version_number" integer;

ALTER TABLE "ads"."custom_audiences"
    ADD COLUMN IF NOT EXISTS "version_number" integer;

ALTER TABLE "ads"."saved_audiences"
    ADD COLUMN IF NOT EXISTS "version_number" integer;

ALTER TABLE "marketing"."segments"
    ADD COLUMN IF NOT EXISTS "version_number" integer;

CREATE TABLE IF NOT EXISTS "audit"."insurance_products_history" (
    "history_id" uuid NOT NULL,
    "insurance_product_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insurance_products_history" PRIMARY KEY ("history_id")
);

-- destino: insurance.insurance_products (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_products_history"
        ADD CONSTRAINT "fk_insurance_products_history_insurance_product_id" FOREIGN KEY ("insurance_product_id")
        REFERENCES "insurance"."insurance_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_products_history"
        ADD CONSTRAINT "fk_insurance_products_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_products_history"
        ADD CONSTRAINT "fk_insurance_products_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."insurance_products_history"
        ADD CONSTRAINT "fk_insurance_products_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_insurance_products_history_insurance_product_id" ON "audit"."insurance_products_history" ("insurance_product_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_history_operation_concept_id" ON "audit"."insurance_products_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_history_changed_by_user_id" ON "audit"."insurance_products_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_products_history_change_reason_concept_id" ON "audit"."insurance_products_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_insurance_products_history_recorded_at" ON "audit"."insurance_products_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE TABLE IF NOT EXISTS "audit"."procedure_cases_history" (
    "history_id" uuid NOT NULL,
    "procedure_case_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_procedure_cases_history" PRIMARY KEY ("history_id")
);

-- destino: procedures_perioperative.procedure_cases (requiere schema procedures_perioperative)
DO $$ BEGIN
    ALTER TABLE "audit"."procedure_cases_history"
        ADD CONSTRAINT "fk_procedure_cases_history_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."procedure_cases_history"
        ADD CONSTRAINT "fk_procedure_cases_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."procedure_cases_history"
        ADD CONSTRAINT "fk_procedure_cases_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."procedure_cases_history"
        ADD CONSTRAINT "fk_procedure_cases_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_history_procedure_case_id" ON "audit"."procedure_cases_history" ("procedure_case_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_history_operation_concept_id" ON "audit"."procedure_cases_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_history_changed_by_user_id" ON "audit"."procedure_cases_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_history_change_reason_concept_id" ON "audit"."procedure_cases_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_procedure_cases_history_recorded_at" ON "audit"."procedure_cases_history" USING brin ("recorded_at") WITH (pages_per_range=128);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."insurance_products" DROP CONSTRAINT IF EXISTS "ck_insurance_products_valid_period";
ALTER TABLE "insurance"."insurance_products" ADD CONSTRAINT "ck_insurance_products_valid_period" CHECK (("effective_from" IS NULL OR "effective_to" IS NULL OR "effective_from" <= "effective_to"));

COMMIT;
