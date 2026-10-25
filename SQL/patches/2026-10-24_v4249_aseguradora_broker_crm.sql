-- ============================================================================
-- SALUD · patch (insurance · broker, requisitos de contratación, términos y condiciones, caso CRM ↔ siniestro, calificación comercial) sobre BD viva
-- Fecha: 2026-10-24 · issue #60
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA.
--   - insurance.broker_carrier_agreements: representation_mode_concept_id (independiente / en
--     representación), relationship_type_concept_id, branch_id (sede), commercial_area,
--     supervisor_user_id y assigned_zone. insurance_brokers.tenant_id NO cambia: es la identidad
--     propia del broker (UNIQUE), no la de una aseguradora.
--   - insurance.insurance_products: min_age_years, max_age_years y eligibility_requirements
--     (CHECK de rango de edad).
--   - insurance.insurance_terms_conditions: términos y condiciones como registro propio.
--   - crm.crm_cases.insurance_claim_id (FK a insurance.insurance_claims) y la tabla
--     crm.crm_case_owner_history (cambios de responsable).
--   - community.service_reviews.verified_crm_case_id: ancla de verificación de la atención
--     comercial, y su índice único parcial.
--
-- PRECONDICIÓN: ninguna; todo es nuevo y nullable. SIN BACKFILL.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +2 · columnas +11 · NOT NULL quitados 0 · FKs +21 · índices +25 (-0) · constraints +1
-- ============================================================================

BEGIN;

ALTER TABLE "insurance"."broker_carrier_agreements"
    ADD COLUMN IF NOT EXISTS "representation_mode_concept_id" uuid;

ALTER TABLE "insurance"."broker_carrier_agreements"
    ADD COLUMN IF NOT EXISTS "relationship_type_concept_id" uuid;

ALTER TABLE "insurance"."broker_carrier_agreements"
    ADD COLUMN IF NOT EXISTS "branch_id" uuid;

ALTER TABLE "insurance"."broker_carrier_agreements"
    ADD COLUMN IF NOT EXISTS "commercial_area" varchar;

ALTER TABLE "insurance"."broker_carrier_agreements"
    ADD COLUMN IF NOT EXISTS "supervisor_user_id" uuid;

ALTER TABLE "insurance"."broker_carrier_agreements"
    ADD COLUMN IF NOT EXISTS "assigned_zone" varchar;

ALTER TABLE "insurance"."insurance_products"
    ADD COLUMN IF NOT EXISTS "min_age_years" integer;

ALTER TABLE "insurance"."insurance_products"
    ADD COLUMN IF NOT EXISTS "max_age_years" integer;

ALTER TABLE "insurance"."insurance_products"
    ADD COLUMN IF NOT EXISTS "eligibility_requirements" jsonb;

ALTER TABLE "crm"."crm_cases"
    ADD COLUMN IF NOT EXISTS "insurance_claim_id" uuid;

ALTER TABLE "community"."service_reviews"
    ADD COLUMN IF NOT EXISTS "verified_crm_case_id" uuid;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_representation_mode_concept_id" FOREIGN KEY ("representation_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_representation_mode_concept_id" ON "insurance"."broker_carrier_agreements" ("representation_mode_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_relationship_type_concept_id" FOREIGN KEY ("relationship_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_relationship_type_concept_id" ON "insurance"."broker_carrier_agreements" ("relationship_type_concept_id");

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_branch_id" ON "insurance"."broker_carrier_agreements" ("branch_id");

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."broker_carrier_agreements"
        ADD CONSTRAINT "fk_broker_carrier_agreements_supervisor_user_id" FOREIGN KEY ("supervisor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_broker_carrier_agreements_supervisor_user_id" ON "insurance"."broker_carrier_agreements" ("supervisor_user_id");

-- destino: insurance.insurance_claims (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_insurance_claim_id" FOREIGN KEY ("insurance_claim_id")
        REFERENCES "insurance"."insurance_claims" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_crm_cases_insurance_claim_id" ON "crm"."crm_cases" ("insurance_claim_id");

-- destino: crm.crm_cases (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "community"."service_reviews"
        ADD CONSTRAINT "fk_service_reviews_verified_crm_case_id" FOREIGN KEY ("verified_crm_case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_service_reviews_verified_crm_case_id" ON "community"."service_reviews" ("verified_crm_case_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_service_reviews_verified_crm_case" ON "community"."service_reviews" ("reviewer_patient_profile_id", "target_public_profile_id", "verified_crm_case_id") WHERE verified_crm_case_id IS NOT NULL;

-- ═══ insurance_products ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "insurance"."insurance_products" DROP CONSTRAINT IF EXISTS "ck_insurance_products_age_range";
ALTER TABLE "insurance"."insurance_products" ADD CONSTRAINT "ck_insurance_products_age_range" CHECK ((COALESCE("min_age_years", 0) >= 0 AND ("max_age_years" IS NULL OR "max_age_years" >= COALESCE("min_age_years", 0))));

CREATE TABLE IF NOT EXISTS "insurance"."insurance_terms_conditions" (
    "id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "version_number" integer NOT NULL,
    "document_file_id" uuid NOT NULL,
    "insurance_product_id" uuid,
    "insurance_plan_id" uuid,
    "service_concept_id" uuid,
    "contract_id" uuid,
    "jurisdiction_concept_id" uuid,
    "client_type_concept_id" uuid,
    "effective_from" date NOT NULL,
    "effective_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_terms_conditions" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_insurance_product_id" FOREIGN KEY ("insurance_product_id")
        REFERENCES "insurance"."insurance_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_insurance_plan_id" FOREIGN KEY ("insurance_plan_id")
        REFERENCES "insurance"."insurance_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_document_file_id" FOREIGN KEY ("document_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: erp.contracts (requiere schema erp)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_contract_id" FOREIGN KEY ("contract_id")
        REFERENCES "erp"."contracts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_client_type_concept_id" FOREIGN KEY ("client_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_terms_conditions"
        ADD CONSTRAINT "fk_insurance_terms_conditions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_insurance_carrier_id" ON "insurance"."insurance_terms_conditions" ("insurance_carrier_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_document_file_id" ON "insurance"."insurance_terms_conditions" ("document_file_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_insurance_product_id" ON "insurance"."insurance_terms_conditions" ("insurance_product_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_insurance_plan_id" ON "insurance"."insurance_terms_conditions" ("insurance_plan_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_service_concept_id" ON "insurance"."insurance_terms_conditions" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_contract_id" ON "insurance"."insurance_terms_conditions" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_jurisdiction_concept_id" ON "insurance"."insurance_terms_conditions" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_client_type_concept_id" ON "insurance"."insurance_terms_conditions" ("client_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_status_concept_id" ON "insurance"."insurance_terms_conditions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_created_by_user_id" ON "insurance"."insurance_terms_conditions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insurance_terms_conditions_updated_by_user_id" ON "insurance"."insurance_terms_conditions" ("updated_by_user_id");

CREATE TABLE IF NOT EXISTS "crm"."crm_case_owner_history" (
    "id" uuid NOT NULL,
    "crm_case_id" uuid NOT NULL,
    "from_owner_user_id" uuid,
    "to_owner_user_id" uuid,
    "changed_at" timestamptz,
    "changed_by_user_id" uuid,
    "reason_text" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_crm_case_owner_history" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_owner_history"
        ADD CONSTRAINT "fk_crm_case_owner_history_crm_case_id" FOREIGN KEY ("crm_case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_owner_history"
        ADD CONSTRAINT "fk_crm_case_owner_history_from_owner_user_id" FOREIGN KEY ("from_owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_owner_history"
        ADD CONSTRAINT "fk_crm_case_owner_history_to_owner_user_id" FOREIGN KEY ("to_owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_owner_history"
        ADD CONSTRAINT "fk_crm_case_owner_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_crm_case_owner_history_crm_case_id" ON "crm"."crm_case_owner_history" ("crm_case_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_owner_history_from_owner_user_id" ON "crm"."crm_case_owner_history" ("from_owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_owner_history_to_owner_user_id" ON "crm"."crm_case_owner_history" ("to_owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_owner_history_changed_by_user_id" ON "crm"."crm_case_owner_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_owner_history_case_changed" ON "crm"."crm_case_owner_history" ("crm_case_id", "changed_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_crm_case_owner_history_created_at" ON "crm"."crm_case_owner_history" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_service_reviews_verified_crm_case" ON "community"."service_reviews" ("reviewer_patient_profile_id", "target_public_profile_id", "verified_crm_case_id") WHERE verified_crm_case_id IS NOT NULL;

COMMIT;
