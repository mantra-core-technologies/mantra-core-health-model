-- ============================================================================
-- SALUD · patch de la visibilidad de la interfaz (authz.ui_visibility_elements y authz.ui_visibility_rules) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_ui_visibility_patch.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a
-- mano. Idempotente (CREATE ... IF NOT EXISTS, FKs con duplicate_object, CHECK con DROP IF EXISTS + ADD). UNA sola transaccion; se puede
-- volver a correr. En un rebuild desde cero apply_all.sql + apply_deferred.sql ya traen todo salvo la seccion 6 (permisos de `mantra_app`).
--
-- Contrato: mantra-core-health/docs/trabajo/2026-10-31-visibilidad-rbac/CONTRATO.md. LA VISIBILIDAD NO ES AUTORIZACION: estas tablas
-- deciden que se presenta; la API sigue autorizando cada peticion con authz.*.
--
-- PREREQUISITOS: schema authz, iam.users. Se comprueban al principio; si falta alguno el parche aborta sin tocar nada.
--
-- QUE AGREGA (2 tablas)
--   authz.ui_visibility_elements  catalogo de elementos de la interfaz (key unica, jerarquia por parent_element_id)
--   authz.ui_visibility_rules     reglas SHOW/HIDE por sujeto (USER | TENANT | ROLE | ORG_TYPE | ALL), vigencia opcional, se TERMINAN (no se borran)
--   unicidad real: key; y la terna elemento+sujeto NO terminada (2 indices unicos parciales: sujeto concreto y ALL)
--
-- DELTAS ESPERADOS sobre una base con v4.2.81 y sin este parche:
--   tablas +2 · FKs +6 · indices +12 (de ellos 3 unicos; los PK nacen con las tablas) · CHECK +14
--
-- RLS: ninguna de las dos lleva columna `tenant_id` (D-UV-1 del .puml 06), asi que 2026-08-05_tenant_rls.sql no las alcanza: el catalogo es de
-- plataforma y la organizacion que acota una regla se llama `scope_tenant_id`. El alcance por organizacion lo aplica la API (404 identico).
--
-- REVERSA (el parche solo agrega; un rollback de la API deja datos inertes):
--   DROP TABLE IF EXISTS "authz"."ui_visibility_rules"; DROP TABLE IF EXISTS "authz"."ui_visibility_elements";
-- ============================================================================

BEGIN;

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regclass('iam.users') IS NULL THEN
        RAISE EXCEPTION 'falta iam.users: aplicar antes apply_all.sql';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'authz') THEN
        RAISE EXCEPTION 'falta el schema authz: aplicar antes apply_all.sql';
    END IF;
END $$;

-- ---- 1. tablas (SQL/06_authz/02_tables.sql) ----
CREATE TABLE IF NOT EXISTS "authz"."ui_visibility_elements" (
    "id" uuid NOT NULL,
    "key" varchar(160) NOT NULL,
    "kind" varchar(20) NOT NULL,
    "module_code" varchar(80) NOT NULL,
    "parent_element_id" uuid,
    "label" varchar(200) NOT NULL,
    "description" varchar(500),
    "default_visible" boolean NOT NULL DEFAULT true,
    "source" varchar(10) NOT NULL,
    "status" varchar(10) NOT NULL,
    "retired_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ui_visibility_elements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."ui_visibility_rules" (
    "id" uuid NOT NULL,
    "element_id" uuid NOT NULL,
    "effect" varchar(4) NOT NULL,
    "subject_type" varchar(10) NOT NULL,
    "subject_id" varchar(160),
    "scope_tenant_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "ended_at" timestamptz,
    "reason" varchar(500) NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ui_visibility_rules" PRIMARY KEY ("id")
);

-- ---- 2. FK dentro del schema authz (SQL/06_authz/03_fk_intra.sql) ----
DO $$ BEGIN
    ALTER TABLE "authz"."ui_visibility_elements"
        ADD CONSTRAINT "fk_ui_visibility_elements_parent_element_id" FOREIGN KEY ("parent_element_id")
        REFERENCES "authz"."ui_visibility_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."ui_visibility_rules"
        ADD CONSTRAINT "fk_ui_visibility_rules_element_id" FOREIGN KEY ("element_id")
        REFERENCES "authz"."ui_visibility_elements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---- 3. indices, incluidos los 3 unicos (SQL/06_authz/04_indexes.sql) ----
CREATE UNIQUE INDEX IF NOT EXISTS "uq_ui_visibility_elements_key" ON "authz"."ui_visibility_elements" ("key");

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_elements_module_kind" ON "authz"."ui_visibility_elements" ("module_code", "kind");

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_elements_parent_element_id" ON "authz"."ui_visibility_elements" ("parent_element_id");

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_elements_created_by_user_id" ON "authz"."ui_visibility_elements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_elements_updated_by_user_id" ON "authz"."ui_visibility_elements" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_ui_visibility_rules_open_subject" ON "authz"."ui_visibility_rules" ("element_id", "subject_type", "subject_id") WHERE ended_at IS NULL AND subject_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_ui_visibility_rules_open_all" ON "authz"."ui_visibility_rules" ("element_id") WHERE ended_at IS NULL AND subject_type = 'ALL';

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_rules_open_subject" ON "authz"."ui_visibility_rules" ("subject_type", "subject_id") WHERE ended_at IS NULL;

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_rules_scope_tenant_id" ON "authz"."ui_visibility_rules" ("scope_tenant_id") WHERE scope_tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_rules_created_at_id" ON "authz"."ui_visibility_rules" ("created_at" DESC, "id" DESC);

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_rules_created_by_user_id" ON "authz"."ui_visibility_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ui_visibility_rules_updated_by_user_id" ON "authz"."ui_visibility_rules" ("updated_by_user_id");

-- ---- 4. FK entre schemas (SQL/06_authz/90_fk_deferred.sql) ----
-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "authz"."ui_visibility_elements"
        ADD CONSTRAINT "fk_ui_visibility_elements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "authz"."ui_visibility_elements"
        ADD CONSTRAINT "fk_ui_visibility_elements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "authz"."ui_visibility_rules"
        ADD CONSTRAINT "fk_ui_visibility_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "authz"."ui_visibility_rules"
        ADD CONSTRAINT "fk_ui_visibility_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ---- 5. integridad: CHECK de vocabularios y de forma (SQL/06_authz/05_constraints.sql) ----
-- ═══ ui_visibility_elements ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_key";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_key" CHECK (char_length("key") <= 160 AND "key" ~ '^[a-z][a-z0-9-]*(\.[a-z0-9][a-z0-9-]*)*$');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_kind";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_kind" CHECK ("kind" IN ('MODULE', 'MENU_SECTION', 'SCREEN', 'SECTION', 'WIDGET', 'FIELD', 'ACTION'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_source";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_source" CHECK ("source" IN ('CODE', 'ADMIN'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_status";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_status" CHECK ("status" IN ('ACTIVE', 'RETIRED'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_retired";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_retired" CHECK (("status" = 'RETIRED') = ("retired_at" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_elements" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_elements_not_own_parent";
ALTER TABLE "authz"."ui_visibility_elements" ADD CONSTRAINT "ck_ui_visibility_elements_not_own_parent" CHECK ("parent_element_id" IS NULL OR "parent_element_id" <> "id");

-- ═══ ui_visibility_rules ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_effect";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_effect" CHECK ("effect" IN ('SHOW', 'HIDE'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_subject_type";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_subject_type" CHECK ("subject_type" IN ('USER', 'TENANT', 'ROLE', 'ORG_TYPE', 'ALL'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_subject_shape";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_subject_shape" CHECK (("subject_type" = 'ALL') = ("subject_id" IS NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_subject_id_len";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_subject_id_len" CHECK (char_length("subject_id") BETWEEN 1 AND 160);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_validity";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_validity" CHECK ("ended_at" IS NOT NULL OR "valid_from" IS NULL OR "valid_to" IS NULL OR "valid_to" > "valid_from");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_reason_len";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_reason_len" CHECK (char_length(btrim("reason")) BETWEEN 10 AND 500);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_ended_has_valid_to";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_ended_has_valid_to" CHECK ("ended_at" IS NULL OR "valid_to" IS NOT NULL);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."ui_visibility_rules" DROP CONSTRAINT IF EXISTS "ck_ui_visibility_rules_scope_subject";
ALTER TABLE "authz"."ui_visibility_rules" ADD CONSTRAINT "ck_ui_visibility_rules_scope_subject" CHECK ("scope_tenant_id" IS NULL OR ("subject_type" IN ('TENANT', 'USER') AND ("subject_type" <> 'TENANT' OR "subject_id" = "scope_tenant_id"::text)));

-- ---- 6. permisos de la aplicacion (solo si existe el rol). Sin DELETE: los elementos se retiran y las reglas se terminan. ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT SELECT, INSERT, UPDATE ON "authz"."ui_visibility_elements" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE ON "authz"."ui_visibility_rules" TO mantra_app;
        REVOKE DELETE, TRUNCATE ON "authz"."ui_visibility_elements" FROM mantra_app;
        REVOKE DELETE, TRUNCATE ON "authz"."ui_visibility_rules" FROM mantra_app;
    END IF;
END $$;

-- ---- 7. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables
     WHERE table_schema = 'authz' AND table_name IN ('ui_visibility_elements', 'ui_visibility_rules');
    IF n <> 2 THEN RAISE EXCEPTION 'deberia haber 2 tablas ui_visibility_* y hay %', n; END IF;
    -- D-UV-1: ninguna de las dos puede llevar una columna tenant_id (el RLS la alcanzaria y rompería la escritura de plataforma).
    SELECT count(*) INTO n FROM information_schema.columns
     WHERE table_schema = 'authz' AND table_name IN ('ui_visibility_elements', 'ui_visibility_rules') AND column_name = 'tenant_id';
    IF n <> 0 THEN RAISE EXCEPTION 'las tablas ui_visibility_* no deben tener columna tenant_id (RLS): %', n; END IF;
    SELECT count(*) INTO n FROM pg_indexes
     WHERE schemaname = 'authz' AND indexdef LIKE 'CREATE UNIQUE INDEX%'
       AND indexname IN ('uq_ui_visibility_elements_key', 'uq_ui_visibility_rules_open_subject', 'uq_ui_visibility_rules_open_all');
    IF n <> 3 THEN RAISE EXCEPTION 'deberia haber 3 indices unicos de visibilidad y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid JOIN pg_namespace s ON s.oid = t.relnamespace
     WHERE c.contype = 'c' AND s.nspname = 'authz' AND t.relname IN ('ui_visibility_elements', 'ui_visibility_rules');
    IF n <> 14 THEN RAISE EXCEPTION 'deberia haber 14 CHECK en ui_visibility_* y hay %', n; END IF;
END $$;

COMMIT;
