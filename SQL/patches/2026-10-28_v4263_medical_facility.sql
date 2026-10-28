-- ============================================================================
-- SALUD · patch v4.2.63 · bloque medicalFacility del alta de organización médica (módulo 04 directory) sobre BD viva
-- Fecha: 2026-10-28
-- Idempotente (IF NOT EXISTS / DROP CONSTRAINT IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/04_directory/ desde que
-- diagram_04_directory.puml y diagram_33_integrity.puml lo declaran, así que en un rebuild desde cero este
-- patch NO hace falta. Existe para una base ya aplicada y poblada. gen_apply.py no escanea SQL/patches/:
-- no entra en apply_all.sql. Las sentencias se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ AGREGA. Dos tablas nuevas, ninguna columna en tablas existentes:
--   - directory.tenant_medical_facilities: una fila por tenant con el NIT declarado, el número de
--     registro/habilitación del establecimiento ante la autoridad sanitaria (SEDES) y el director médico
--     (nombre en partes, matrícula profesional, correo, teléfono).
--   - directory.tenant_medical_facility_sites: casa central (ordinal 0) y 0..50 sucursales DECLARADAS.
--     No son directory.branches ni practice.practice_sites: el alta no crea sedes operativas.
-- Es un registro DECLARADO por el titular, pendiente de verificación; ni el NIT ni el número de
-- habilitación son UNIQUE a propósito (ver el comentario de diagram_04_directory.puml v4.2.63).
--
-- RLS: ambas tablas llevan `tenant_id uuid`, así que las cubre SQL/patches/2026-08-05_tenant_rls.sql
-- (genérico, por columna). Si la base ya tiene RLS aplicado, volver a correr ese patch para estas dos.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +2 · columnas +30 · FKs +7 · índices +11 (-0) · constraints +6
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "directory"."tenant_medical_facilities" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "tax_identifier_number" varchar(20) NOT NULL,
    "health_facility_registration_number" varchar(50) NOT NULL,
    "medical_director_name" varchar NOT NULL,
    "medical_director_middle_name" varchar,
    "medical_director_last_name" varchar NOT NULL,
    "medical_director_mother_last_name" varchar,
    "medical_director_license_number" varchar(50) NOT NULL,
    "medical_director_email" varchar NOT NULL,
    "medical_director_phone" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_medical_facilities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."tenant_medical_facility_sites" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "medical_facility_id" uuid NOT NULL,
    "site_kind" varchar NOT NULL,
    "ordinal" integer NOT NULL,
    "name" varchar(200) NOT NULL,
    "address_lines" varchar[] NOT NULL,
    "latitude" numeric,
    "longitude" numeric,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_medical_facility_sites" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_medical_facilities"
        ADD CONSTRAINT "fk_tenant_medical_facilities_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_medical_facility_sites"
        ADD CONSTRAINT "fk_tenant_medical_facility_sites_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_medical_facility_sites"
        ADD CONSTRAINT "fk_tenant_medical_facility_sites_medical_facility_id" FOREIGN KEY ("medical_facility_id")
        REFERENCES "directory"."tenant_medical_facilities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_medical_facilities"
        ADD CONSTRAINT "fk_tenant_medical_facilities_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_medical_facilities"
        ADD CONSTRAINT "fk_tenant_medical_facilities_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_medical_facility_sites"
        ADD CONSTRAINT "fk_tenant_medical_facility_sites_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_medical_facility_sites"
        ADD CONSTRAINT "fk_tenant_medical_facility_sites_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE UNIQUE INDEX IF NOT EXISTS "uk_tenant_medical_facilities_tenant" ON "directory"."tenant_medical_facilities" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facilities_registration_number" ON "directory"."tenant_medical_facilities" ("health_facility_registration_number");

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facilities_tax_identifier_number" ON "directory"."tenant_medical_facilities" ("tax_identifier_number");

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facilities_created_by_user_id" ON "directory"."tenant_medical_facilities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facilities_updated_by_user_id" ON "directory"."tenant_medical_facilities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facility_sites_tenant_id" ON "directory"."tenant_medical_facility_sites" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facility_sites_medical_facility_id" ON "directory"."tenant_medical_facility_sites" ("medical_facility_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_tenant_medical_facility_sites_facility_ordinal" ON "directory"."tenant_medical_facility_sites" ("medical_facility_id", "ordinal");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_tenant_medical_facility_sites_one_headquarters" ON "directory"."tenant_medical_facility_sites" ("medical_facility_id") WHERE site_kind = 'headquarters';

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facility_sites_created_by_user_id" ON "directory"."tenant_medical_facility_sites" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_medical_facility_sites_updated_by_user_id" ON "directory"."tenant_medical_facility_sites" ("updated_by_user_id");

-- ═══ tenant_medical_facilities ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facilities" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facilities_tax_identifier_format";
ALTER TABLE "directory"."tenant_medical_facilities" ADD CONSTRAINT "ck_tenant_medical_facilities_tax_identifier_format" CHECK ("tax_identifier_number" ~ '^[0-9][0-9-]{3,19}$');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facilities" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facilities_registration_format";
ALTER TABLE "directory"."tenant_medical_facilities" ADD CONSTRAINT "ck_tenant_medical_facilities_registration_format" CHECK ("health_facility_registration_number" ~ '^[A-Za-z0-9./-]{3,50}$');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facilities" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facilities_director_license";
ALTER TABLE "directory"."tenant_medical_facilities" ADD CONSTRAINT "ck_tenant_medical_facilities_director_license" CHECK (char_length(btrim("medical_director_license_number")) BETWEEN 3 AND 50);


-- ═══ tenant_medical_facility_sites ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facility_sites" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facility_sites_kind_ordinal";
ALTER TABLE "directory"."tenant_medical_facility_sites" ADD CONSTRAINT "ck_tenant_medical_facility_sites_kind_ordinal" CHECK (("site_kind" = 'headquarters' AND "ordinal" = 0) OR ("site_kind" = 'branch' AND "ordinal" BETWEEN 1 AND 50));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facility_sites" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facility_sites_address_lines";
ALTER TABLE "directory"."tenant_medical_facility_sites" ADD CONSTRAINT "ck_tenant_medical_facility_sites_address_lines" CHECK (cardinality("address_lines") >= 1);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facility_sites" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facility_sites_geo";
ALTER TABLE "directory"."tenant_medical_facility_sites" ADD CONSTRAINT "ck_tenant_medical_facility_sites_geo" CHECK ((("latitude" IS NULL) = ("longitude" IS NULL)) AND ("latitude" IS NULL OR ("latitude" BETWEEN -90 AND 90 AND "longitude" BETWEEN -180 AND 180)));

COMMIT;
