-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5d · agenda de consultorios y salas
-- (horario por espacio, excepciones con origen, FK real al espacio, solape imposible)
-- sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y F5d (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y 2026-10-29_infraestructura_f1b_seguridad.sql
-- (necesita practice.care_spaces con tenant_id NOT NULL y ux_care_spaces_tenant_id_id) y DESPUÉS
-- del patch de M-F4 (`…_f4_scheduling.sql`, dueño de scheduling.schedulable_resources). Orden:
-- F1 → F1b → F2 → … → F4 → F5. Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS /
-- FK con `duplicate_object` / DROP … IF EXISTS / CREATE OR REPLACE.
-- Se puede aplicar N veces; la segunda pasada no cambia nada.
--
-- Contexto: columnas, FKs simples, índices y el CHECK los emiten gen_ddl.py y gen_integrity.py
-- en SQL/41_scheduling y SQL/08_clinical desde que diagram_41 / diagram_33 los declaran; esas
-- sentencias se copiaron de los archivos generados (en una copia de trabajo, sin tocar SQL/).
-- Lo escrito a mano, porque el generador no lo expresa: las precondiciones, las FK compuestas
-- (tenant_id, x_id), los triggers, el RLS y la verificación final. gen_apply.py no escanea
-- SQL/patches/: no entra en apply_all.sql.
--
-- QUÉ CIERRA.
--   1. Horario por espacio. scheduling.schedule_templates.care_space_id → practice.care_spaces
--      (nullable: NULL ≡ la plantilla no reserva un espacio, lo que toda plantilla era).
--   2. Excepciones con origen. scheduling.availability_exceptions.source_kind_concept_id
--      (EXC_SRC_MANUAL | CARE_SPACE_BLOCK | EQUIPMENT_STATUS, los siembra la API; NULL ≡ manual) y
--      source_ref_id (el espacio o equipo que la originó; referencia polimórfica, SIN FK).
--      ck_availability_exceptions_source_ref_needs_kind: no hay referencia sin origen.
--   3. Aislamiento por tenant, garantizado en la base, en las dos tablas:
--        - tenant_id NOT NULL (backfill desde el recurso agendable; un trigger BEFORE INSERT lo
--          completa si el INSERT no lo manda, así no se rompe quien aún no lo escribe);
--        - FK compuestas (tenant_id, resource_id) → schedulable_resources y
--          (tenant_id, care_space_id) → care_spaces: la base rechaza el cruce de tenants
--          (la FK simple se verifica sin RLS y no lo veía);
--        - RLS `tenant_isolation` (texto exacto de 2026-08-05_tenant_rls.sql), ENABLE + FORCE.
--      ux_schedulable_resources_tenant_id_id (UNIQUE (tenant_id, id)) es el destino de las FK
--      compuestas hacia el recurso; lo declara y lo crea M-F4 (diagram_41, `…_f4_scheduling.sql`).
--   4. (Fuera de este patch) El solape imposible de las citas (appointments.care_space_id y
--      ex_appointments_care_space_time, 23P01 → 409 CARE_SPACE_DOUBLE_BOOKED) es de M-F5-clin.
--
-- DUEÑO ÚNICO de clinical.appointments.care_space_id (integración del modelo, 2026-10-29).
-- La columna, su FK (simple y compuesta fk_appointments_tenant_care_space), su índice y el
-- EXCLUDE ex_appointments_care_space_time son de M-F5-clin (`…_f5_clinical.sql`, declarados en
-- diagram_08 / diagram_33). Este patch ya NO los crea: los duplicaba. Tampoco crea
-- ux_schedulable_resources_tenant_id_id: es de M-F4 (`…_f4_scheduling.sql`, diagram_41) y acá se
-- exige como prerrequisito. Orden real (alfabético de postgres-init): f4_scheduling < f5_clinical
-- < f5_scheduling.
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos (EXC_SRC_* los siembra la API con defineModuleConcepts) ni rellena
--     source_kind_concept_id de las filas existentes (NULL ≡ manual).
--   - No valida que el espacio de la plantilla sea de la misma sede/práctica que el recurso, ni su
--     función (CONSULTING_ROOM / PROCEDURE_ROOM / IMAGING_ROOM con perfil `schedulable`): son 422
--     de la API (TEMPLATE_CARE_SPACE_SITE_MISMATCH / …_INVALID_FUNCTION).
--   - No impide el solape de DOS PLANTILLAS sobre el mismo espacio y hora (reglas semanales en
--     schedule_rules, sin espacio ni vigencia propios): es 422 TEMPLATE_RULE_OVERLAP_CARE_SPACE
--     de la API; la red en la base es el EXCLUDE de las citas.
--   - No valida el tenant de source_ref_id (polimórfico, sin FK): lo valida la API.
--   - No toca scheduling.schedulable_resources (dueño: M-F4) ni clinical.appointments (dueño: M-F5-clin).
--   - No agrega historia: ninguna tabla es nueva (audit.schedule_templates_history guarda
--     data_snapshot jsonb, así que recoge las columnas nuevas sin cambios).
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - F1b no aplicado (falta practice.care_spaces con tenant_id NOT NULL o su ux_*_tenant_id_id);
--   - M-F4 no aplicado (falta ux_schedulable_resources_tenant_id_id);
--   - plantillas / excepciones cuyo tenant_id (si la columna ya existía con datos) no es el de su recurso;
--   - plantillas que ya referencian un espacio de OTRO tenant;
--   - excepciones con source_ref_id sin origen;
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas   +5  (schedule_templates{tenant_id, care_space_id}, availability_exceptions{tenant_id,
--                   source_kind_concept_id, source_ref_id})
--   FKs        +7  (4 simples + 3 compuestas)
--   índices    +5  (los 5 IX de diagram_41)
--   CHECK      +1 · triggers +2 · políticas RLS +2 · tenant_id NOT NULL en 2 tablas
-- ============================================================================

BEGIN;

-- Las comprobaciones y el backfill leen tablas con RLS forzada (practice.*, scheduling.*, clinical.*).
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 0. prerrequisitos
DO $$
BEGIN
    IF to_regclass('practice.care_spaces') IS NULL
       OR NOT EXISTS (SELECT 1 FROM information_schema.columns
                       WHERE table_schema = 'practice' AND table_name = 'care_spaces'
                         AND column_name = 'tenant_id' AND is_nullable = 'NO')
       OR NOT EXISTS (SELECT 1 FROM pg_indexes
                       WHERE schemaname = 'practice' AND indexname = 'ux_care_spaces_tenant_id_id') THEN
        RAISE EXCEPTION 'F5d requiere F1b (practice.care_spaces con tenant_id NOT NULL y ux_care_spaces_tenant_id_id): aplicar antes 2026-10-29_infraestructura_f1b_seguridad.sql'
            USING ERRCODE = 'undefined_table';
    END IF;
    IF to_regclass('scheduling.schedulable_resources') IS NULL
       OR to_regclass('scheduling.schedule_templates') IS NULL
       OR to_regclass('scheduling.availability_exceptions') IS NULL THEN
        RAISE EXCEPTION 'F5d requiere el módulo 41 (scheduling) creado'
            USING ERRCODE = 'undefined_table';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes
                    WHERE schemaname = 'scheduling' AND indexname = 'ux_schedulable_resources_tenant_id_id') THEN
        RAISE EXCEPTION 'F5d requiere ux_schedulable_resources_tenant_id_id (UNIQUE (tenant_id, id) de scheduling.schedulable_resources, dueño M-F4): aplicar antes 2026-10-29_infraestructura_f4_scheduling.sql'
            USING ERRCODE = 'undefined_table';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. columnas nuevas
-- (de SQL/41_scheduling/02_tables.sql)
ALTER TABLE "scheduling"."schedule_templates"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

ALTER TABLE "scheduling"."schedule_templates"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "scheduling"."availability_exceptions"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

ALTER TABLE "scheduling"."availability_exceptions"
    ADD COLUMN IF NOT EXISTS "source_kind_concept_id" uuid;

ALTER TABLE "scheduling"."availability_exceptions"
    ADD COLUMN IF NOT EXISTS "source_ref_id" uuid;

-- ------------------------------------------------------------- 2. backfill de tenant_id
-- El de su recurso agendable (resource_id es NOT NULL con FK). Sólo filas con NULL.
UPDATE "scheduling"."schedule_templates" t
   SET "tenant_id" = r."tenant_id"
  FROM "scheduling"."schedulable_resources" r
 WHERE r."id" = t."resource_id"
   AND t."tenant_id" IS NULL;

UPDATE "scheduling"."availability_exceptions" e
   SET "tenant_id" = r."tenant_id"
  FROM "scheduling"."schedulable_resources" r
 WHERE r."id" = e."resource_id"
   AND e."tenant_id" IS NULL;

-- ------------------------------------------------------------- 3. precondiciones
-- 3a. tenant_id sin resolver o distinto del de su recurso (sólo si la columna ya traía datos).
DO $$
DECLARE
    n_null   integer;
    n_dist   integer;
BEGIN
    SELECT (SELECT count(*) FROM "scheduling"."schedule_templates" WHERE "tenant_id" IS NULL)
         + (SELECT count(*) FROM "scheduling"."availability_exceptions" WHERE "tenant_id" IS NULL)
      INTO n_null;
    SELECT (SELECT count(*) FROM "scheduling"."schedule_templates" t
              JOIN "scheduling"."schedulable_resources" r ON r."id" = t."resource_id"
             WHERE t."tenant_id" <> r."tenant_id")
         + (SELECT count(*) FROM "scheduling"."availability_exceptions" e
              JOIN "scheduling"."schedulable_resources" r ON r."id" = e."resource_id"
             WHERE e."tenant_id" <> r."tenant_id")
      INTO n_dist;
    IF n_null > 0 OR n_dist > 0 THEN
        RAISE EXCEPTION 'F5d: plantillas/excepciones sin tenant_id tras el backfill=% o con un tenant distinto del de su recurso=%. No se toca ningún dato; corregirlas a mano y volver a aplicar.', n_null, n_dist
            USING ERRCODE = 'not_null_violation';
    END IF;
END $$;

-- 3b. Referencias a un espacio de OTRO tenant (la FK simple no lo impide). Se listan todas y se
-- aborta: decidir cuál de los dos tenants es el correcto no le toca al patch.
DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces (relacion, hijo) AS (
        SELECT 'schedule_templates.care_space_id', t."id"
          FROM "scheduling"."schedule_templates" t
          JOIN "practice"."care_spaces" cs ON cs."id" = t."care_space_id"
         WHERE cs."tenant_id" <> t."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'F5d: hay referencias a un espacio de OTRO tenant en % relación(es): %. No se crean las FK compuestas y no se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- 3c. Excepciones con referencia de origen pero sin origen (sólo si las columnas ya traían datos).
DO $$
DECLARE
    n_ref integer;
BEGIN
    SELECT count(*) INTO n_ref
      FROM "scheduling"."availability_exceptions"
     WHERE "source_ref_id" IS NOT NULL AND "source_kind_concept_id" IS NULL;
    IF n_ref > 0 THEN
        RAISE EXCEPTION 'F5d: % excepción(es) con source_ref_id y sin source_kind_concept_id. No se toca ningún dato; corregirlas a mano y volver a aplicar.', n_ref
            USING ERRCODE = 'check_violation';
    END IF;
END $$;

ALTER TABLE "scheduling"."schedule_templates" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "scheduling"."availability_exceptions" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- 4. índices (copiados de 04_indexes)
CREATE INDEX IF NOT EXISTS "ix_schedule_templates_tenant_id" ON "scheduling"."schedule_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_care_space_id" ON "scheduling"."schedule_templates" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_tenant_id" ON "scheduling"."availability_exceptions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_source_kind_concept_id" ON "scheduling"."availability_exceptions" ("source_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_source_ref_id" ON "scheduling"."availability_exceptions" ("source_ref_id") WHERE source_ref_id IS NOT NULL;

-- ------------------------------------------------------------- 5. FKs simples (copiadas de 90_fk_deferred)
-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_templates"
        ADD CONSTRAINT "fk_schedule_templates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_templates"
        ADD CONSTRAINT "fk_schedule_templates_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "scheduling"."availability_exceptions"
        ADD CONSTRAINT "fk_availability_exceptions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "scheduling"."availability_exceptions"
        ADD CONSTRAINT "fk_availability_exceptions_source_kind_concept_id" FOREIGN KEY ("source_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 6. FKs compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id). MATCH SIMPLE: si x_id es NULL no se exige nada, así
-- sirven también para care_space_id opcional. Conviven con la FK simple generada.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('scheduling.schedule_templates',      'fk_schedule_templates_tenant_resource',      'resource_id',    'scheduling.schedulable_resources'),
            ('scheduling.schedule_templates',      'fk_schedule_templates_tenant_care_space',    'care_space_id',  'practice.care_spaces'),
            ('scheduling.availability_exceptions', 'fk_availability_exceptions_tenant_resource', 'resource_id',    'scheduling.schedulable_resources')
        ) AS v(hijo, nombre, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 7. CHECK
-- (de SQL/41_scheduling/05_constraints.sql)
ALTER TABLE "scheduling"."availability_exceptions" DROP CONSTRAINT IF EXISTS "ck_availability_exceptions_source_ref_needs_kind";
ALTER TABLE "scheduling"."availability_exceptions" ADD CONSTRAINT "ck_availability_exceptions_source_ref_needs_kind" CHECK (("source_ref_id" IS NULL OR "source_kind_concept_id" IS NOT NULL));

-- ------------------------------------------------------------- 8. trigger: tenant desde el recurso
-- Si el INSERT / UPDATE no manda tenant_id, se completa con el del recurso agendable (así no se
-- rompe quien aún no lo escribe). SECURITY INVOKER a propósito (como F1b): con RLS, un recurso de
-- otro tenant ni siquiera se ve y cae en el mismo error genérico. Si el llamador SÍ manda
-- tenant_id, no se toca: la FK compuesta (tenant_id, resource_id) decide. Se usa el mismo
-- cuerpo para las dos tablas (ambas tienen tenant_id y resource_id).
CREATE OR REPLACE FUNCTION "scheduling"."fill_tenant_from_resource"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    t_recurso uuid;
BEGIN
    IF NEW."tenant_id" IS NOT NULL THEN
        RETURN NEW;
    END IF;
    SELECT sr."tenant_id" INTO t_recurso
      FROM "scheduling"."schedulable_resources" sr
     WHERE sr."id" = NEW."resource_id";
    IF t_recurso IS NULL THEN
        RAISE EXCEPTION '%.resource_id: el recurso agendable no existe en el tenant del contexto', TG_TABLE_NAME
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    NEW."tenant_id" := t_recurso;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_schedule_templates_fill_tenant" ON "scheduling"."schedule_templates";
CREATE TRIGGER "trg_schedule_templates_fill_tenant"
    BEFORE INSERT OR UPDATE OF "tenant_id", "resource_id"
    ON "scheduling"."schedule_templates"
    FOR EACH ROW EXECUTE FUNCTION "scheduling"."fill_tenant_from_resource"();

DROP TRIGGER IF EXISTS "trg_availability_exceptions_fill_tenant" ON "scheduling"."availability_exceptions";
CREATE TRIGGER "trg_availability_exceptions_fill_tenant"
    BEFORE INSERT OR UPDATE OF "tenant_id", "resource_id"
    ON "scheduling"."availability_exceptions"
    FOR EACH ROW EXECUTE FUNCTION "scheduling"."fill_tenant_from_resource"();

-- ------------------------------------------------------------- 9. RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql (ese patch también las cubriría al
-- reaplicarse: tienen tenant_id uuid). DROP + CREATE es idempotente.
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['scheduling.schedule_templates', 'scheduling.availability_exceptions'] LOOP
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
    END LOOP;
END $$;

-- ------------------------------------------------------------- 10. verificación
DO $$
DECLARE
    n_columnas integer;
    n_notnull  integer;
    n_fk       integer;
    n_idx      integer;
    n_ck       integer;
    n_tg       integer;
    n_rls      integer;
    n_pol      integer;
BEGIN
    SELECT count(*) INTO n_columnas
      FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('scheduling', 'schedule_templates', 'tenant_id'),
            ('scheduling', 'schedule_templates', 'care_space_id'),
            ('scheduling', 'availability_exceptions', 'tenant_id'),
            ('scheduling', 'availability_exceptions', 'source_kind_concept_id'),
            ('scheduling', 'availability_exceptions', 'source_ref_id'));

    SELECT count(*) INTO n_notnull
      FROM information_schema.columns
     WHERE table_schema = 'scheduling' AND column_name = 'tenant_id' AND is_nullable = 'NO'
       AND table_name IN ('schedule_templates', 'availability_exceptions');

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_schedule_templates_tenant_id', 'fk_schedule_templates_care_space_id',
                       'fk_availability_exceptions_tenant_id', 'fk_availability_exceptions_source_kind_concept_id',
                       'fk_schedule_templates_tenant_resource', 'fk_schedule_templates_tenant_care_space',
                       'fk_availability_exceptions_tenant_resource');

    SELECT count(*) INTO n_idx
      FROM pg_indexes
     WHERE (schemaname, indexname) IN (
            ('scheduling', 'ix_schedule_templates_tenant_id'),
            ('scheduling', 'ix_schedule_templates_care_space_id'),
            ('scheduling', 'ix_availability_exceptions_tenant_id'),
            ('scheduling', 'ix_availability_exceptions_source_kind_concept_id'),
            ('scheduling', 'ix_availability_exceptions_source_ref_id'));

    SELECT count(*) INTO n_ck
      FROM pg_constraint
     WHERE contype = 'c' AND convalidated AND conname = 'ck_availability_exceptions_source_ref_needs_kind';

    SELECT count(*) INTO n_tg
      FROM pg_trigger
     WHERE NOT tgisinternal
       AND tgname IN ('trg_schedule_templates_fill_tenant', 'trg_availability_exceptions_fill_tenant');

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE n.nspname = 'scheduling' AND c.relname IN ('schedule_templates', 'availability_exceptions')
       AND c.relrowsecurity AND c.relforcerowsecurity;

    SELECT count(*) INTO n_pol
      FROM pg_policies
     WHERE schemaname = 'scheduling' AND policyname = 'tenant_isolation'
       AND tablename IN ('schedule_templates', 'availability_exceptions');

    IF n_columnas <> 5 OR n_notnull <> 2 OR n_fk <> 7 OR n_idx <> 5 OR n_ck <> 1
       OR n_tg <> 2 OR n_rls <> 2 OR n_pol <> 2 THEN
        RAISE EXCEPTION 'F5d incompleto: columnas=% (5), tenant NOT NULL=% (2), fk=% (7), índices=% (5), check=% (1), triggers=% (2), tablas con RLS forzada=% (2), políticas=% (2)',
            n_columnas, n_notnull, n_fk, n_idx, n_ck, n_tg, n_rls, n_pol;
    END IF;

    RAISE NOTICE 'F5d aplicado: 5 columnas, tenant_id NOT NULL en 2 tablas, 7 FKs validadas (4 simples + 3 compuestas), 5 índices, 1 CHECK, 2 triggers, RLS forzada con tenant_isolation en 2 tablas.';
END $$;

COMMIT;
