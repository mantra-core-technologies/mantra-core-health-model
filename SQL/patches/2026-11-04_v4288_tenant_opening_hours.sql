-- ============================================================================
-- SALUD · patch v4.2.88 · horario de atención declarado en el alta de organización (módulo 04 directory) sobre BD viva
-- Fecha: 2026-11-04
-- Idempotente (IF NOT EXISTS / DROP CONSTRAINT IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/04_directory/ desde que
-- diagram_04_directory.puml y diagram_33_integrity.puml lo declaran, así que en un rebuild desde cero este
-- patch NO hace falta. Existe para una base ya aplicada y poblada. gen_apply.py no escanea SQL/patches/:
-- no entra en apply_all.sql. Las sentencias se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ AGREGA. Una tabla nueva, ninguna columna en tablas existentes:
--   - directory.tenant_opening_hours: una fila por turno del horario semanal de atención que el titular
--     DECLARA en el alta. Hasta dos turnos por día (shift_ordinal 1..2). La sede es la casa central
--     (branch_id y medical_facility_site_id en NULL), una fila de directory.branches (farmacia, centro de
--     diagnóstico) o una sucursal declarada del establecimiento médico (tenant_medical_facility_sites).
--     «Abierto las 24 h» es 00:00–24:00. day_of_week es ISO-8601 (1 = lunes … 7 = domingo).
--
-- RLS: la tabla lleva `tenant_id uuid`, así que la cubre SQL/patches/2026-08-05_tenant_rls.sql
-- (genérico, por columna). Si la base ya tiene RLS aplicado, volver a correr ese patch para esta tabla.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +1 · columnas +13 · FKs +5 · índices +8 (-0) · constraints +4
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "directory"."tenant_opening_hours" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "branch_id" uuid,
    "medical_facility_site_id" uuid,
    "day_of_week" smallint NOT NULL,
    "shift_ordinal" smallint NOT NULL,
    "opens_at" time NOT NULL,
    "closes_at" time NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_opening_hours" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_opening_hours"
        ADD CONSTRAINT "fk_tenant_opening_hours_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_opening_hours"
        ADD CONSTRAINT "fk_tenant_opening_hours_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_opening_hours"
        ADD CONSTRAINT "fk_tenant_opening_hours_medical_facility_site_id" FOREIGN KEY ("medical_facility_site_id")
        REFERENCES "directory"."tenant_medical_facility_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_opening_hours"
        ADD CONSTRAINT "fk_tenant_opening_hours_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_opening_hours"
        ADD CONSTRAINT "fk_tenant_opening_hours_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_tenant_opening_hours_tenant_id" ON "directory"."tenant_opening_hours" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_opening_hours_branch_id" ON "directory"."tenant_opening_hours" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_opening_hours_medical_facility_site_id" ON "directory"."tenant_opening_hours" ("medical_facility_site_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_tenant_opening_hours_headquarters_shift" ON "directory"."tenant_opening_hours" ("tenant_id", "day_of_week", "shift_ordinal") WHERE branch_id IS NULL AND medical_facility_site_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_tenant_opening_hours_branch_shift" ON "directory"."tenant_opening_hours" ("branch_id", "day_of_week", "shift_ordinal") WHERE branch_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_tenant_opening_hours_facility_site_shift" ON "directory"."tenant_opening_hours" ("medical_facility_site_id", "day_of_week", "shift_ordinal") WHERE medical_facility_site_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_tenant_opening_hours_created_by_user_id" ON "directory"."tenant_opening_hours" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_opening_hours_updated_by_user_id" ON "directory"."tenant_opening_hours" ("updated_by_user_id");

-- ═══ tenant_opening_hours ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_opening_hours" DROP CONSTRAINT IF EXISTS "ck_tenant_opening_hours_day_of_week";
ALTER TABLE "directory"."tenant_opening_hours" ADD CONSTRAINT "ck_tenant_opening_hours_day_of_week" CHECK ("day_of_week" BETWEEN 1 AND 7);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_opening_hours" DROP CONSTRAINT IF EXISTS "ck_tenant_opening_hours_shift_ordinal";
ALTER TABLE "directory"."tenant_opening_hours" ADD CONSTRAINT "ck_tenant_opening_hours_shift_ordinal" CHECK ("shift_ordinal" BETWEEN 1 AND 2);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_opening_hours" DROP CONSTRAINT IF EXISTS "ck_tenant_opening_hours_closes_after_opens";
ALTER TABLE "directory"."tenant_opening_hours" ADD CONSTRAINT "ck_tenant_opening_hours_closes_after_opens" CHECK ("closes_at" > "opens_at");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_opening_hours" DROP CONSTRAINT IF EXISTS "ck_tenant_opening_hours_one_site";
ALTER TABLE "directory"."tenant_opening_hours" ADD CONSTRAINT "ck_tenant_opening_hours_one_site" CHECK (("branch_id" IS NULL OR "medical_facility_site_id" IS NULL));

COMMIT;
