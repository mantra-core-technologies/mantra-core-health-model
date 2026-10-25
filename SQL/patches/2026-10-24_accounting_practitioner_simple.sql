-- ============================================================================
-- SALUD · patch (accounting · contabilidad simple del doctor, P49) sobre BD viva
-- Fecha: 2026-10-24 · schema accounting · 3 tablas nuevas
-- Idempotente (IF NOT EXISTS / duplicate_object / DROP CONSTRAINT IF EXISTS). Sin backfill.
--
-- Contexto: gen_ddl.py ya emite estas tablas, sus FK e índices en SQL/16_accounting/ y
-- gen_integrity.py sus CHECK en SQL/16_accounting/05_constraints.sql desde que
-- diagram_16_accounting.puml las declara (CHECK_SQL en diagram_33), así que en un rebuild
-- desde cero este patch NO hace falta. Existe para una base ya aplicada y poblada:
-- docker/db-init/init-postgres.sh se salta apply_deferred.sql cuando ya existe la base.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. La API (P49) creó estas tres tablas editando su copia vendorizada del SQL;
-- el modelo oficial quedó desfasado. Este patch las lleva al modelo con los mismos nombres
-- de constraint que la API:
--   accounting.practitioner_simple_accounts      cuentas por práctica, con su clase
--   accounting.practitioner_simple_records       gastos / activos / deudas (el tipo ES una cuenta)
--   accounting.practitioner_simple_transactions  transacciones debe / haber
-- NO genera asientos ni toca accounting.journal_transactions: es un libro propio de la
-- práctica. Las cuentas generales se siembran por práctica desde la API, al primer acceso.
--
-- DIFERENCIA CONOCIDA con la copia de la API: la unicidad (practice_id, code) sale como
-- índice único (UK de diagram_16, 04_indexes) con el mismo nombre uq_practitioner_simple_
-- accounts_practice_code y no como CONSTRAINT ... UNIQUE, porque gen_ddl.py no emite UNIQUE
-- constraints. Garantiza lo mismo; en una base donde la API ya creó el CONSTRAINT, el
-- CREATE UNIQUE INDEX IF NOT EXISTS no hace nada (el índice del constraint ya existe).
-- Los CHECK salen como ALTER TABLE ... ADD CONSTRAINT (05_constraints) y no en línea
-- dentro del CREATE TABLE; mismos nombres y mismas expresiones.
--
-- PRECONDICIÓN: existen los schemas practice (practice.practices) e iam (iam.users).
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +3 · columnas +35 · FKs +12 · índices +13 (1 único + 12 IX; los PK no se cuentan) · CHECK +5
-- ============================================================================

BEGIN;

-- Tablas (02_tables)
CREATE TABLE IF NOT EXISTS "accounting"."practitioner_simple_accounts" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "account_class" varchar NOT NULL,
    "seeded" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_simple_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."practitioner_simple_records" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "kind" varchar NOT NULL,
    "record_date" date NOT NULL,
    "account_id" uuid NOT NULL,
    "description" varchar NOT NULL,
    "amount" numeric NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_simple_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "accounting"."practitioner_simple_transactions" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "transaction_date" date NOT NULL,
    "description" varchar NOT NULL,
    "debit_account_id" uuid NOT NULL,
    "credit_account_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_simple_transactions" PRIMARY KEY ("id")
);

-- FK intra-schema (03_fk_intra)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_records"
        ADD CONSTRAINT "fk_practitioner_simple_records_account_id" FOREIGN KEY ("account_id")
        REFERENCES "accounting"."practitioner_simple_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_transactions"
        ADD CONSTRAINT "fk_practitioner_simple_transactions_debit_account_id" FOREIGN KEY ("debit_account_id")
        REFERENCES "accounting"."practitioner_simple_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_transactions"
        ADD CONSTRAINT "fk_practitioner_simple_transactions_credit_account_id" FOREIGN KEY ("credit_account_id")
        REFERENCES "accounting"."practitioner_simple_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- FK hacia otros schemas (90_fk_deferred)
-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_accounts"
        ADD CONSTRAINT "fk_practitioner_simple_accounts_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_accounts"
        ADD CONSTRAINT "fk_practitioner_simple_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_accounts"
        ADD CONSTRAINT "fk_practitioner_simple_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_records"
        ADD CONSTRAINT "fk_practitioner_simple_records_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_records"
        ADD CONSTRAINT "fk_practitioner_simple_records_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_records"
        ADD CONSTRAINT "fk_practitioner_simple_records_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_transactions"
        ADD CONSTRAINT "fk_practitioner_simple_transactions_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_transactions"
        ADD CONSTRAINT "fk_practitioner_simple_transactions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "accounting"."practitioner_simple_transactions"
        ADD CONSTRAINT "fk_practitioner_simple_transactions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Índices (04_indexes)
CREATE UNIQUE INDEX IF NOT EXISTS "uq_practitioner_simple_accounts_practice_code" ON "accounting"."practitioner_simple_accounts" ("practice_id", "code");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_accounts_practice_id" ON "accounting"."practitioner_simple_accounts" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_accounts_created_by_user_id" ON "accounting"."practitioner_simple_accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_accounts_updated_by_user_id" ON "accounting"."practitioner_simple_accounts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_records_practice_id" ON "accounting"."practitioner_simple_records" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_records_account_id" ON "accounting"."practitioner_simple_records" ("account_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_records_created_by_user_id" ON "accounting"."practitioner_simple_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_records_updated_by_user_id" ON "accounting"."practitioner_simple_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_transactions_practice_id" ON "accounting"."practitioner_simple_transactions" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_transactions_debit_account_id" ON "accounting"."practitioner_simple_transactions" ("debit_account_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_transactions_credit_account_id" ON "accounting"."practitioner_simple_transactions" ("credit_account_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_transactions_created_by_user_id" ON "accounting"."practitioner_simple_transactions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_simple_transactions_updated_by_user_id" ON "accounting"."practitioner_simple_transactions" ("updated_by_user_id");

-- CHECK (05_constraints)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_accounts" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_accounts_class";
ALTER TABLE "accounting"."practitioner_simple_accounts" ADD CONSTRAINT "ck_practitioner_simple_accounts_class" CHECK ("account_class" IN ('ASSET', 'LIABILITY', 'EQUITY', 'INCOME', 'EXPENSE'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_records" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_records_kind";
ALTER TABLE "accounting"."practitioner_simple_records" ADD CONSTRAINT "ck_practitioner_simple_records_kind" CHECK ("kind" IN ('EXPENSE', 'ASSET', 'DEBT'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_records" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_records_amount";
ALTER TABLE "accounting"."practitioner_simple_records" ADD CONSTRAINT "ck_practitioner_simple_records_amount" CHECK ("amount" > 0);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_transactions" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_transactions_distinct";
ALTER TABLE "accounting"."practitioner_simple_transactions" ADD CONSTRAINT "ck_practitioner_simple_transactions_distinct" CHECK ("debit_account_id" <> "credit_account_id");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_transactions" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_transactions_amount";
ALTER TABLE "accounting"."practitioner_simple_transactions" ADD CONSTRAINT "ck_practitioner_simple_transactions_amount" CHECK ("amount" > 0);

COMMIT;
