-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5e · vigencias de la categoría de cama
-- (practice.care_space_category_periods) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §F5e (repositorio de documentación) · agente M-F5-fin
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y de
-- 2026-10-29_infraestructura_f1b_seguridad.sql (necesita ux_care_spaces_tenant_id_id y
-- ux_practices_tenant_id_id). Idempotente (CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / CHECK y EXCLUDE sólo si faltan / CREATE OR REPLACE / backfill sólo de
-- camas sin período). Se puede aplicar N veces; la segunda pasada no cambia nada.
--
-- Contexto: la tabla, los índices y las FK los emite gen_ddl.py en SQL/14_practice desde que
-- diagram_14 declara `care_space_category_periods`; el CHECK y el EXCLUDE los emite
-- gen_integrity.py en SQL/14_practice/05_constraints.sql desde diagram_33. Esas sentencias se
-- copiaron del generador. Lo escrito a mano: la precondición, el backfill, el trigger de
-- «sólo se cierra valid_to», el RLS y la verificación final. gen_apply.py no escanea
-- SQL/patches/: no entra en apply_all.sql.
--
-- POR QUÉ. La regla de medianoche (D7) cobra la categoría que la cama tenía EN esa medianoche.
-- `care_spaces.bed_category_concept_id` sólo dice cuál es la de ahora; si se cambia, las noches
-- ya devengadas no pueden reinterpretarse. Esta tabla guarda cada categoría con su vigencia
-- [valid_from, valid_to) y la base impide que dos períodos de una misma cama se solapen.
--
-- QUÉ CIERRA.
--   - practice.care_space_category_periods(id, tenant_id, care_space_id, bed_category_concept_id,
--     valid_from, valid_to, columnas comunes). FK compuesta (tenant_id, care_space_id) →
--     care_spaces(tenant_id, id): el período sólo apunta a una cama de su propio tenant.
--   - ck_care_space_category_periods_range (valid_to > valid_from) y
--     ex_care_space_category_periods_validity (EXCLUDE gist: sin solape por cama).
--   - Backfill: una fila por cama (care_spaces con bed_category_concept_id) desde su created_at,
--     abierta (valid_to NULL), sólo si la cama no tiene ya ningún período.
--   - Trigger de guarda: un período no se borra y de un período sólo se cierra valid_to, una vez
--     (es un hecho de facturación; cambiar la categoría = cerrar el vigente y abrir otro en la
--     misma transacción, lo hace PATCH /care-spaces/:id). Sin historia propia (audit): la tabla
--     ES la historia de la categoría y sólo crece.
--   - RLS tenant_isolation (texto exacto de 2026-08-05_tenant_rls.sql) y GRANT sin DELETE.
--
-- LO QUE ESTE PATCH NO HACE.
--   - No mantiene sola la coherencia entre care_spaces.bed_category_concept_id y el período
--     abierto: el contrato la deja en el servicio de la API (cerrar y abrir en una transacción).
--     Una cama cuya categoría cambió sin tocar los períodos factura con la categoría vieja.
--   - No siembra conceptos (BED_CAT_* los siembra la API).
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - períodos ya existentes que se solapan para la misma cama.
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   tablas +1 · FK +5 (1 compuesta) · índices +5 (+ el gist del EXCLUDE y el PK)
--   CHECK +1 · EXCLUDE +1 · trigger +1 · política RLS +1 · filas = una por cama con categoría
-- ============================================================================

BEGIN;

-- El backfill y las comprobaciones leen tablas con RLS forzada (practice.*).
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ------------------------------------------------------------- 1. tabla
-- (de SQL/14_practice/02_tables.sql)
CREATE TABLE IF NOT EXISTS "practice"."care_space_category_periods" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "bed_category_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_space_category_periods" PRIMARY KEY ("id")
);

-- ------------------------------------------------------------- 2. índices
-- (de SQL/14_practice/04_indexes.sql)
CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_tenant_id" ON "practice"."care_space_category_periods" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_care_space_id" ON "practice"."care_space_category_periods" ("care_space_id", "valid_from" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_bed_category_concept_id" ON "practice"."care_space_category_periods" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_created_by_user_id" ON "practice"."care_space_category_periods" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_updated_by_user_id" ON "practice"."care_space_category_periods" ("updated_by_user_id");

-- ------------------------------------------------------------- 3. FKs
-- (de SQL/14_practice/90_fk_deferred.sql; la compuesta exige ux_care_spaces_tenant_id_id de F1b)
-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: practice.care_space_category_periods sólo apunta a practice.care_spaces del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_care_space_id" FOREIGN KEY ("tenant_id", "care_space_id")
        REFERENCES "practice"."care_spaces" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 4. precondición, CHECK y EXCLUDE
DO $$
DECLARE
    n_solapes integer;
BEGIN
    SELECT count(*) INTO n_solapes
      FROM "practice"."care_space_category_periods" a
      JOIN "practice"."care_space_category_periods" b
        ON a."care_space_id" = b."care_space_id"
       AND a."id" < b."id"
       AND tstzrange(a."valid_from", a."valid_to", '[)') && tstzrange(b."valid_from", b."valid_to", '[)');
    IF n_solapes > 0 THEN
        RAISE EXCEPTION 'F5e prácticas: % par(es) de períodos de categoría se solapan para la misma cama. No se toca ningún dato; cerrar o corregir los períodos a mano y volver a aplicar.', n_solapes
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

-- (de SQL/14_practice/05_constraints.sql) Sólo se agregan si faltan: reaplicar no reconstruye el gist.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'practice.care_space_category_periods'::regclass
                      AND conname = 'ck_care_space_category_periods_range') THEN
        ALTER TABLE "practice"."care_space_category_periods" ADD CONSTRAINT "ck_care_space_category_periods_range" CHECK ("valid_to" IS NULL OR "valid_to" > "valid_from");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'practice.care_space_category_periods'::regclass
                      AND conname = 'ex_care_space_category_periods_validity') THEN
        ALTER TABLE "practice"."care_space_category_periods" ADD CONSTRAINT "ex_care_space_category_periods_validity"
            EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH &&);
    END IF;
END $$;

-- ------------------------------------------------------------- 5. backfill
-- Una fila por cama con categoría, desde que existe la cama. Sólo camas SIN ningún período: la
-- segunda pasada (y las camas que la API ya gestiona) no se tocan. SUPUESTO: antes de este patch
-- no hubo cargos devengados que dependieran de la categoría, así que dar por buena la actual
-- desde created_at no reescribe ningún hecho.
INSERT INTO "practice"."care_space_category_periods"
       ("id", "tenant_id", "care_space_id", "bed_category_concept_id", "valid_from", "valid_to",
        "created_at", "updated_at", "created_by_user_id", "updated_by_user_id", "row_version")
SELECT gen_random_uuid(), cs."tenant_id", cs."id", cs."bed_category_concept_id", cs."created_at", NULL,
       now(), now(), NULL, NULL, 1
  FROM "practice"."care_spaces" cs
 WHERE cs."bed_category_concept_id" IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM "practice"."care_space_category_periods" p
                    WHERE p."care_space_id" = cs."id");

-- ------------------------------------------------------------- 6. trigger de guarda
-- SECURITY INVOKER (como F1b/F5 operaciones). Un período no se borra; de un período sólo se
-- cierra valid_to, una sola vez. Nada más cambia (ni la categoría ni el inicio): reescribir un
-- período cambiaría retroactivamente la categoría de noches ya devengadas.
CREATE OR REPLACE FUNCTION "practice"."care_space_category_periods_guard"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'practice.care_space_category_periods: un período de categoría no se borra (es la base de la facturación día-cama); se cierra con valid_to'
            USING ERRCODE = 'restrict_violation';
    END IF;
    IF (to_jsonb(NEW) - ARRAY['valid_to', 'updated_at', 'updated_by_user_id', 'row_version'])
       IS DISTINCT FROM (to_jsonb(OLD) - ARRAY['valid_to', 'updated_at', 'updated_by_user_id', 'row_version']) THEN
        RAISE EXCEPTION 'practice.care_space_category_periods: de un período sólo se cierra valid_to; para cambiar la categoría se cierra este y se abre otro'
            USING ERRCODE = 'restrict_violation';
    END IF;
    IF OLD."valid_to" IS NOT NULL AND NEW."valid_to" IS DISTINCT FROM OLD."valid_to" THEN
        RAISE EXCEPTION 'practice.care_space_category_periods: el período ya está cerrado'
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_care_space_category_periods_guard" ON "practice"."care_space_category_periods";
CREATE TRIGGER "trg_care_space_category_periods_guard"
    BEFORE UPDATE OR DELETE
    ON "practice"."care_space_category_periods"
    FOR EACH ROW EXECUTE FUNCTION "practice"."care_space_category_periods_guard"();

-- ------------------------------------------------------------- 7. RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql. Ese patch descubre toda tabla con
-- `tenant_id` y, si se vuelve a ejecutar, deja la misma política. El GRANT cubre el caso en
-- que la tabla la cree un rol distinto del que fijó los DEFAULT PRIVILEGES; no incluye DELETE
-- (el trigger lo rechazaría igual, también para el dueño).
DO $$
DECLARE
    t text := 'practice.care_space_category_periods';
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        EXECUTE format('REVOKE DELETE, TRUNCATE ON %s FROM mantra_app', t);
        EXECUTE format('GRANT SELECT, INSERT, UPDATE ON %s TO mantra_app', t);
    END IF;

    EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE %s FORCE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %s', t);
    EXECUTE format($pol$
    CREATE POLICY tenant_isolation ON %s
      USING (
        tenant_id = NULLIF(
          current_setting('app.current_tenant_id', true),
          ''
        )::uuid
        OR current_setting('app.system_context', true) = 'true'
      )
      WITH CHECK (
        tenant_id = NULLIF(
          current_setting('app.current_tenant_id', true),
          ''
        )::uuid
        OR current_setting('app.system_context', true) = 'true'
      )
    $pol$, t);
END $$;

-- ------------------------------------------------------------- 8. verificación
DO $$
DECLARE
    n_tabla  integer;
    n_cols   integer;
    n_fk     integer;
    n_fkc    integer;
    n_idx    integer;
    n_ck     integer;
    n_ex     integer;
    n_trg    integer;
    n_rls    integer;
    n_sin    integer;
BEGIN
    SELECT (to_regclass('practice.care_space_category_periods') IS NOT NULL)::int INTO n_tabla;

    SELECT count(*) INTO n_cols FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'care_space_category_periods';

    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conrelid = 'practice.care_space_category_periods'::regclass;

    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conrelid = 'practice.care_space_category_periods'::regclass
       AND conname = 'fk_care_space_category_periods_care_space_id';

    SELECT count(*) INTO n_idx FROM pg_indexes
     WHERE schemaname = 'practice' AND tablename = 'care_space_category_periods';

    SELECT count(*) INTO n_ck FROM pg_constraint
     WHERE contype = 'c' AND conname = 'ck_care_space_category_periods_range'
       AND conrelid = 'practice.care_space_category_periods'::regclass;

    SELECT count(*) INTO n_ex FROM pg_constraint
     WHERE contype = 'x' AND conname = 'ex_care_space_category_periods_validity'
       AND conrelid = 'practice.care_space_category_periods'::regclass;

    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgname = 'trg_care_space_category_periods_guard'
       AND tgrelid = 'practice.care_space_category_periods'::regclass;

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE n.nspname = 'practice' AND c.relname = 'care_space_category_periods'
       AND c.relrowsecurity AND c.relforcerowsecurity;

    SELECT count(*) INTO n_sin FROM "practice"."care_spaces" cs
     WHERE cs."bed_category_concept_id" IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM "practice"."care_space_category_periods" p WHERE p."care_space_id" = cs."id");

    -- índices: PK + 5 ix + el gist del EXCLUDE = 7
    IF n_tabla <> 1 OR n_cols <> 11 OR n_fk <> 5 OR n_fkc <> 1 OR n_idx <> 7 OR n_ck <> 1 OR n_ex <> 1
       OR n_trg <> 1 OR n_rls <> 1 OR n_sin <> 0 THEN
        RAISE EXCEPTION 'F5e prácticas incompleto: tabla=% (1), columnas=% (11), FK=% (5), FK compuesta=% (1), índices=% (7), CHECK=% (1), EXCLUDE=% (1), trigger=% (1), RLS=% (1), camas sin período=% (0)',
            n_tabla, n_cols, n_fk, n_fkc, n_idx, n_ck, n_ex, n_trg, n_rls, n_sin;
    END IF;

    RAISE NOTICE 'F5e prácticas aplicado: care_space_category_periods con 5 FK (1 compuesta por tenant), CHECK + EXCLUDE sin solape por cama, guarda de solo-cierre, RLS, y una fila por cama con categoría.';
END $$;

COMMIT;
