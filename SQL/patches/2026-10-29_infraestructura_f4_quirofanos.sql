-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F4 (quirófanos) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §F4.1 (repositorio de documentación)
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / constraints con DROP IF EXISTS + ADD / DROP POLICY IF EXISTS /
-- CREATE OR REPLACE). Se puede aplicar N veces. Va DESPUÉS de
-- 2026-10-29_infraestructura_f1b_seguridad.sql (usa sus UNIQUE (tenant_id, id) y sus funciones de
-- historia) y ANTES de 2026-10-29_infraestructura_f5_agenda.sql.
--
-- Contexto: gen_ddl.py / gen_integrity.py ya emiten las columnas, tablas, FKs, índices,
-- CHECK y EXCLUDE en SQL/41_scheduling, SQL/53_procedures_perioperative y SQL/10_audit
-- desde que los .puml (41, 53, 10, 33) los declaran. Este patch existe para una base ya
-- aplicada y poblada. Las sentencias de columnas, tablas, FKs, índices y constraints se
-- copiaron de los archivos generados. Lo escrito a mano: las precondiciones, los
-- backfills, el trigger de la ventana reservada (el modelo no expresa triggers que no
-- sean guardas de inmutabilidad), el reemplazo condicional del EXCLUDE de
-- procedure_cases, el RLS y la verificación final.
--
-- QUÉ CIERRA.
--   A. R0 · scheduling.schedulable_resources.care_space_id (FK → practice.care_spaces).
--      ck_schedulable_resources_care_space_ref: resource_ref_type <> 'care_spaces' OR
--      care_space_id = resource_ref_id. ux_schedulable_resources_care_space_active:
--      UNIQUE (care_space_id) WHERE care_space_id IS NOT NULL AND state = STATE_ACTIVE.
--      Backfill: filas con resource_ref_type IN ('care_spaces','practice.care_spaces') cuyo
--      resource_ref_id existe en practice.care_spaces → care_space_id = resource_ref_id y
--      resource_ref_type canónico 'care_spaces'. Las filas RES_ROOM (o con tipo de
--      referencia de espacio) cuya referencia NO existe se listan con RAISE NOTICE y no
--      se tocan.
--   B. procedures_perioperative.procedure_cases: schedulable_resource_id (FK),
--      operating_room_block_id (FK), reserved_start_at, reserved_end_at, mantenidas por
--      trg_procedure_cases_reserved_window (BEFORE INSERT OR UPDATE):
--        reserved_start_at = scheduled_start_at − coalesce(prep_minutes, 0) min
--        reserved_end_at   = scheduled_end_at   + coalesce(cleanup_minutes, 0) min
--      y ex_procedure_cases_operating_room_time pasa a usar tstzrange(reserved_*) (mismo
--      nombre, mismos tres estados: CASE_SCHEDULED, CASE_READY, SURG_CASE_IN_PROGRESS).
--      La FK operating_room_id → practice.care_spaces ya existía; se reasegura.
--   C. operating_room_utilization_events: tenant_id (backfill desde care_spaces.tenant_id
--      de la sala; RLS) y operating_room_block_id (FK).
--   D. surgical_safety_checklists: ux_surgical_safety_checklists_case_type UNIQUE
--      (procedure_case_id, checklist_type_concept_id).
--   E. Tablas nuevas operating_room_block_series y operating_room_blocks (con
--      ex_operating_room_blocks_time sobre bloques ORB_ACTIVE y CHECK de dueño coherente),
--      y sus historias audit.operating_room_block_series_history / _blocks_history.
--   F. RLS tenant_isolation (texto exacto de 2026-08-05_tenant_rls.sql) en
--      operating_room_block_series, operating_room_blocks, operating_room_utilization_events y
--      las dos historias.
--   G. Aislamiento entre tenants en las REFERENCIAS (patrón F1b): UNIQUE (tenant_id, id) en
--      schedulable_resources, operating_room_block_series y operating_room_blocks, y 14 FK
--      compuestas (tenant_id, x_id) → padre (tenant_id, id): toda FK nueva hacia practice.*
--      (care_spaces, practice_sites, clinical_units), las FK entre series/bloques/casos/eventos,
--      procedure_cases (custodian_tenant_id, operating_room_id / schedulable_resource_id /
--      operating_room_block_id) y cada historia → su origen.
--   H. Historias con el patrón F1b: tenant_id NOT NULL (lo completa trg_fill_tenant desde el
--      origen), trg_close_only (rechaza DELETE y todo UPDATE salvo cerrar valid_to una vez),
--      mantra_app con SELECT, INSERT y UPDATE (valid_to).
--
-- UUID literales (deterministicId de common/constants/concepts.ts de la API):
--   STATE_ACTIVE           'state:active'                              38a1d301-f40d-5b17-a695-5e6d605f8b19
--   RESOURCE_ROOM (RES_ROOM) 'scheduling:resource-type:room'           2e3d1a52-5455-5714-a4f2-db0879616235
--   CASE_SCHEDULED         'periop:case-status:scheduled'              6fe38139-ad1d-5214-84c1-8c184e4e58fb
--   CASE_READY_FOR_SURGERY 'periop:case-status:ready'                  f6985cd5-f867-5d76-b70c-1138667fd2ab
--   SURGICAL_CASE_IN_PROGRESS 'periop:case-status:in-progress'         fdc78cc9-eda6-5625-9a26-1bdcec4dc203
--   ORB_ACTIVE             'procedures_perioperative:ORB_ACTIVE'       762dc30b-3e3c-5e1e-8504-5c511fd1d4a8
--   ORB_OWNER_SERVICE      'procedures_perioperative:ORB_OWNER_SERVICE' 6b4fd1e9-892f-572b-9e9b-96b321ecdc26
--   ORB_OWNER_SURGEON      'procedures_perioperative:ORB_OWNER_SURGEON' 48a989b7-6300-516d-9982-8f741aaf0758
--   (los ORB_* los declara la API en procedures_perioperative.concepts.ts con
--    defineModuleConcepts('procedures_perioperative', …): el prefijo da estos UUID).
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos (ORB_*, OR_EVENT_*, MILESTONE_*) ni los ítems OMS: los siembra la API.
--   - No borra ni renombra datos. No rellena schedulable_resource_id ni operating_room_block_id
--     en casos existentes (lo hace la API al reprogramar).
--   - operating_room_utilization_events.tenant_id queda NULLable (como care_spaces.tenant_id,
--     F1): se completa desde la sala; las filas cuya sala no tiene tenant se informan con
--     NOTICE. Con RLS, una fila con tenant NULL es invisible para mantra_app: la API tiene que
--     escribirlo siempre.
--
-- PRECONDICIONES (todas antes de tocar nada; el BEGIN hace rollback de todo si una aborta).
-- NO se borra ni se reprograma ningún dato: resolver a mano y volver a aplicar.
--   1. Casos vivos en el mismo quirófano cuyas ventanas CON preparación/limpieza se solapan
--      (el EXCLUDE nuevo fallaría). Aborta con la lista de pares. Consulta para el operador:
--
--        WITH v AS (
--          SELECT id, case_number, operating_room_id,
--                 tstzrange(scheduled_start_at - make_interval(mins => coalesce(prep_minutes, 0)),
--                           scheduled_end_at + make_interval(mins => coalesce(cleanup_minutes, 0)), '[)') AS w
--            FROM procedures_perioperative.procedure_cases
--           WHERE operating_room_id IS NOT NULL AND scheduled_start_at IS NOT NULL
--             AND scheduled_end_at IS NOT NULL
--             AND status_concept_id IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb',
--                 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'))
--        SELECT a.operating_room_id, a.id, a.case_number, a.w, b.id, b.case_number, b.w
--          FROM v a JOIN v b ON a.operating_room_id = b.operating_room_id AND a.id < b.id AND a.w && b.w;
--
--   2. Dos recursos ACTIVOS que quedarían ligados al mismo espacio (rompe el único parcial).
--   3. Dos checklists del mismo tipo para el mismo caso (rompe el único nuevo).
--   5. Referencias a un espacio de OTRO tenant (caso → quirófano, recurso → espacio, evento →
--      sala): se listan y se aborta, como F1b.
--   4. Dos bloques ACTIVOS solapados en la misma sala (sólo puede pasar si la tabla ya existía
--      sin el EXCLUDE).
--
-- DELTAS ESPERADOS (primera aplicación sobre la base anterior):
--   columnas  +7  (schedulable_resources 1 · procedure_cases 4 · operating_room_utilization_events 2)
--   tablas    +4  (2 en procedures_perioperative, 2 en audit)
--   FKs      +36 simples (generadas) + 14 compuestas (a mano)
--   índices  +49  (45 declarados —5 únicos— + 4 PK de las tablas nuevas)
--   EXCLUDE   +1 nuevo (ex_operating_room_blocks_time) y 1 reemplazado
--   CHECK     +9
--   triggers  +5  (ventana reservada + 2×2 de historia) · políticas RLS +5
-- ============================================================================

BEGIN;

-- El backfill escribe tablas con RLS forzada (schedulable_resources). El rol dueño la sortea
-- si es superusuario; si no lo es, esto abre el contexto SYSTEM sólo para esta transacción.
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ------------------------------------------------------------- A–C. columnas
-- Primero las columnas: la precondición 0.2 lee care_space_id. Si una precondición aborta,
-- el ROLLBACK las deshace igual.
ALTER TABLE "scheduling"."schedulable_resources"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "schedulable_resource_id" uuid,
    ADD COLUMN IF NOT EXISTS "operating_room_block_id" uuid,
    ADD COLUMN IF NOT EXISTS "reserved_start_at" timestamptz,
    ADD COLUMN IF NOT EXISTS "reserved_end_at" timestamptz;

ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid,
    ADD COLUMN IF NOT EXISTS "operating_room_block_id" uuid;

-- ------------------------------------------------------------- 0. precondiciones
-- 0.1 Ventanas reservadas solapadas (casos vivos, mismo quirófano).
DO $$
DECLARE
    n_pares integer;
    detalle text;
BEGIN
    WITH v AS (
        SELECT id, case_number, operating_room_id,
               tstzrange(scheduled_start_at - make_interval(mins => coalesce(prep_minutes, 0)),
                         scheduled_end_at + make_interval(mins => coalesce(cleanup_minutes, 0)), '[)') AS w
          FROM "procedures_perioperative"."procedure_cases"
         WHERE operating_room_id IS NOT NULL
           AND scheduled_start_at IS NOT NULL
           AND scheduled_end_at IS NOT NULL
           AND status_concept_id IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb',
                                     'f6985cd5-f867-5d76-b70c-1138667fd2ab',
                                     'fdc78cc9-eda6-5625-9a26-1bdcec4dc203')
    ), pares AS (
        SELECT a.operating_room_id, a.id AS a_id, a.case_number AS a_num, a.w AS a_w,
               b.id AS b_id, b.case_number AS b_num, b.w AS b_w
          FROM v a
          JOIN v b ON a.operating_room_id = b.operating_room_id AND a.id < b.id AND a.w && b.w
    )
    SELECT count(*),
           string_agg(format('quirófano %s: caso %s (%s, ventana %s) ⟷ caso %s (%s, ventana %s)',
                             operating_room_id, a_num, a_id, a_w, b_num, b_id, b_w), E'\n'
                      ORDER BY operating_room_id, a_w)
      INTO n_pares, detalle
      FROM pares;

    IF n_pares > 0 THEN
        RAISE EXCEPTION E'procedure_cases: % par(es) de casos vivos en el mismo quirófano se solapan al sumar preparación/limpieza; no se reemplaza ex_procedure_cases_operating_room_time y no se toca ningún dato. Reprogramar o ajustar prep/cleanup a mano y volver a aplicar.\n%', n_pares, detalle;
    END IF;
END $$;

-- 0.2 Recursos activos que quedarían ligados al mismo espacio.
DO $$
DECLARE
    n_dup   integer;
    detalle text;
BEGIN
    WITH ligables AS (
        SELECT r.id,
               coalesce(r.care_space_id, cs.id) AS espacio
          FROM "scheduling"."schedulable_resources" r
          LEFT JOIN "practice"."care_spaces" cs
            ON cs.id = r.resource_ref_id
           AND r.resource_ref_type IN ('care_spaces', 'practice.care_spaces')
         WHERE r.state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
    )
    SELECT count(*), string_agg(format('espacio %s ← recursos %s', espacio, ids), '; ')
      INTO n_dup, detalle
      FROM (SELECT espacio, array_agg(id ORDER BY id) AS ids
              FROM ligables WHERE espacio IS NOT NULL
             GROUP BY espacio HAVING count(*) > 1) d;

    IF n_dup > 0 THEN
        RAISE EXCEPTION 'scheduling.schedulable_resources: % espacio(s) con más de un recurso ACTIVO; no se crea ux_schedulable_resources_care_space_active y no se toca ningún dato. Desactivar o fusionar a mano y volver a aplicar. Detalle: %', n_dup, detalle;
    END IF;
END $$;

-- 0.3 Checklists repetidos por (caso, tipo).
DO $$
DECLARE
    n_dup   integer;
    detalle text;
BEGIN
    SELECT count(*), string_agg(format('caso %s · tipo %s ← checklists %s', procedure_case_id, checklist_type_concept_id, ids), '; ')
      INTO n_dup, detalle
      FROM (SELECT procedure_case_id, checklist_type_concept_id, array_agg(id ORDER BY created_at, id) AS ids
              FROM "procedures_perioperative"."surgical_safety_checklists"
             GROUP BY 1, 2 HAVING count(*) > 1) d;

    IF n_dup > 0 THEN
        RAISE EXCEPTION 'surgical_safety_checklists: % (caso, tipo) con más de un checklist; no se crea ux_surgical_safety_checklists_case_type y no se toca ningún dato. Detalle: %', n_dup, detalle;
    END IF;
END $$;

-- 0.5 Referencias a un espacio de OTRO tenant (patrón F1b: se listan y se aborta; decidir
-- cuál de los dos tenants es el correcto no le toca al patch).
DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'procedure_cases.operating_room_id', c."id"
          FROM "procedures_perioperative"."procedure_cases" c
          JOIN "practice"."care_spaces" p ON p."id" = c."operating_room_id"
         WHERE p."tenant_id" <> c."custodian_tenant_id"
        UNION ALL
        SELECT 'schedulable_resources.care_space_id', r."id"
          FROM "scheduling"."schedulable_resources" r
          JOIN "practice"."care_spaces" p
            ON p."id" = coalesce(r."care_space_id",
                                 CASE WHEN r."resource_ref_type" IN ('care_spaces', 'practice.care_spaces')
                                      THEN r."resource_ref_id" END)
         WHERE p."tenant_id" <> r."tenant_id"
        UNION ALL
        SELECT 'operating_room_utilization_events.operating_room_id', e."id"
          FROM "procedures_perioperative"."operating_room_utilization_events" e
          JOIN "practice"."care_spaces" p ON p."id" = e."operating_room_id"
         WHERE e."tenant_id" IS NOT NULL AND p."tenant_id" <> e."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'F4: hay referencias a un espacio de OTRO tenant en % relación(es): %. No se crean las FK compuestas y no se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- 0.4 Bloques activos solapados (sólo si la tabla ya existe).
DO $$
DECLARE
    n_pares integer;
    detalle text;
BEGIN
    IF to_regclass('procedures_perioperative.operating_room_blocks') IS NULL THEN
        RETURN;
    END IF;
    EXECUTE $q$
        SELECT count(*), string_agg(format('sala %s: bloque %s ⟷ bloque %s', a.operating_room_id, a.id, b.id), '; ')
          FROM procedures_perioperative.operating_room_blocks a
          JOIN procedures_perioperative.operating_room_blocks b
            ON a.operating_room_id = b.operating_room_id AND a.id < b.id
           AND tstzrange(a.starts_at, a.ends_at, '[)') && tstzrange(b.starts_at, b.ends_at, '[)')
         WHERE a.status_concept_id = '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8'
           AND b.status_concept_id = '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8'
    $q$ INTO n_pares, detalle;
    IF n_pares > 0 THEN
        RAISE EXCEPTION 'operating_room_blocks: % par(es) de bloques ACTIVOS solapados; no se toca ningún dato. Detalle: %', n_pares, detalle;
    END IF;
END $$;

-- ------------------------------------------------------------- E. tablas nuevas
CREATE TABLE IF NOT EXISTS "procedures_perioperative"."operating_room_block_series" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "operating_room_id" uuid NOT NULL,
    "owner_kind_concept_id" uuid NOT NULL,
    "clinical_unit_id" uuid,
    "surgical_specialty_concept_id" uuid,
    "surgeon_profile_id" uuid,
    "weekdays" smallint[] NOT NULL,
    "start_time" time NOT NULL,
    "end_time" time NOT NULL,
    "valid_from" date NOT NULL,
    "valid_to" date,
    "release_hours" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operating_room_block_series" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "procedures_perioperative"."operating_room_blocks" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" uuid,
    "operating_room_id" uuid NOT NULL,
    "owner_kind_concept_id" uuid NOT NULL,
    "clinical_unit_id" uuid,
    "surgical_specialty_concept_id" uuid,
    "surgeon_profile_id" uuid,
    "starts_at" timestamptz NOT NULL,
    "ends_at" timestamptz NOT NULL,
    "release_at" timestamptz NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "released_at" timestamptz,
    "released_by_user_id" uuid,
    "release_reason" text,
    "released_minutes" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operating_room_blocks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."operating_room_block_series_history" (
    "history_id" uuid NOT NULL,
    "operating_room_block_series_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_operating_room_block_series_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."operating_room_blocks_history" (
    "history_id" uuid NOT NULL,
    "operating_room_block_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_operating_room_blocks_history" PRIMARY KEY ("history_id")
);

-- Bases donde las historias se crearon con un borrador previo de este patch (sin tenant_id):
-- se agrega, se completa desde el origen y queda NOT NULL. En una base nueva no hace nada.
ALTER TABLE "audit"."operating_room_block_series_history" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "audit"."operating_room_blocks_history" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
UPDATE "audit"."operating_room_block_series_history" h SET tenant_id = o.tenant_id
  FROM "procedures_perioperative"."operating_room_block_series" o
 WHERE o.id = h.operating_room_block_series_id AND h.tenant_id IS NULL;
UPDATE "audit"."operating_room_blocks_history" h SET tenant_id = o.tenant_id
  FROM "procedures_perioperative"."operating_room_blocks" o
 WHERE o.id = h.operating_room_block_id AND h.tenant_id IS NULL;
ALTER TABLE "audit"."operating_room_block_series_history" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "audit"."operating_room_blocks_history" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- FKs
-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedulable_resources"
        ADD CONSTRAINT "fk_schedulable_resources_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_operating_room_block_id" FOREIGN KEY ("operating_room_block_id")
        REFERENCES "procedures_perioperative"."operating_room_blocks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_operating_room_block_id" FOREIGN KEY ("operating_room_block_id")
        REFERENCES "procedures_perioperative"."operating_room_blocks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_series_id" FOREIGN KEY ("series_id")
        REFERENCES "procedures_perioperative"."operating_room_block_series" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: scheduling.schedulable_resources (requiere schema scheduling)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_schedulable_resource_id" FOREIGN KEY ("schedulable_resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
        ADD CONSTRAINT "fk_operating_room_utilization_events_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_operating_room_id" FOREIGN KEY ("operating_room_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_owner_kind_concept_id" FOREIGN KEY ("owner_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_surgical_specialty_concept_id" FOREIGN KEY ("surgical_specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_surgeon_profile_id" FOREIGN KEY ("surgeon_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series"
        ADD CONSTRAINT "fk_operating_room_block_series_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_operating_room_id" FOREIGN KEY ("operating_room_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_owner_kind_concept_id" FOREIGN KEY ("owner_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_surgical_specialty_concept_id" FOREIGN KEY ("surgical_specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_surgeon_profile_id" FOREIGN KEY ("surgeon_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_released_by_user_id" FOREIGN KEY ("released_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks"
        ADD CONSTRAINT "fk_operating_room_blocks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: procedures_perioperative.operating_room_block_series (requiere schema procedures_perioperative)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_block_series_history"
        ADD CONSTRAINT "fk_operating_room_block_series_history_operating_room__9ea3a62d" FOREIGN KEY ("operating_room_block_series_id")
        REFERENCES "procedures_perioperative"."operating_room_block_series" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_block_series_history"
        ADD CONSTRAINT "fk_operating_room_block_series_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_block_series_history"
        ADD CONSTRAINT "fk_operating_room_block_series_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_block_series_history"
        ADD CONSTRAINT "fk_operating_room_block_series_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_block_series_history"
        ADD CONSTRAINT "fk_operating_room_block_series_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: procedures_perioperative.operating_room_blocks (requiere schema procedures_perioperative)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_blocks_history"
        ADD CONSTRAINT "fk_operating_room_blocks_history_operating_room_block_id" FOREIGN KEY ("operating_room_block_id")
        REFERENCES "procedures_perioperative"."operating_room_blocks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_blocks_history"
        ADD CONSTRAINT "fk_operating_room_blocks_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_blocks_history"
        ADD CONSTRAINT "fk_operating_room_blocks_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_blocks_history"
        ADD CONSTRAINT "fk_operating_room_blocks_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."operating_room_blocks_history"
        ADD CONSTRAINT "fk_operating_room_blocks_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- FK operating_room_id → practice.care_spaces (ya existía desde el SQL generado; se reasegura).
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_operating_room_id" FOREIGN KEY ("operating_room_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- A. backfill R0
DO $$
DECLARE
    n_ligados  integer;
    n_huerf    integer;
    detalle    text;
BEGIN
    UPDATE "scheduling"."schedulable_resources" r
       SET care_space_id = r.resource_ref_id,
           resource_ref_type = 'care_spaces'
      FROM "practice"."care_spaces" cs
     WHERE cs.id = r.resource_ref_id
       AND r.resource_ref_type IN ('care_spaces', 'practice.care_spaces')
       AND (r.care_space_id IS DISTINCT FROM r.resource_ref_id OR r.resource_ref_type <> 'care_spaces');
    GET DIAGNOSTICS n_ligados = ROW_COUNT;
    IF n_ligados > 0 THEN
        RAISE NOTICE 'R0: % recurso(s) ligado(s) a su espacio (care_space_id) con resource_ref_type canónico care_spaces.', n_ligados;
    END IF;

    SELECT count(*), string_agg(format('recurso %s (%s → %s.%s)', r.id, r.name, r.resource_ref_type, r.resource_ref_id), '; ')
      INTO n_huerf, detalle
      FROM "scheduling"."schedulable_resources" r
     WHERE r.care_space_id IS NULL
       AND (r.resource_type_concept_id = '2e3d1a52-5455-5714-a4f2-db0879616235'
            OR r.resource_ref_type IN ('care_spaces', 'practice.care_spaces'))
       AND NOT EXISTS (SELECT 1 FROM "practice"."care_spaces" cs WHERE cs.id = r.resource_ref_id);
    IF n_huerf > 0 THEN
        RAISE NOTICE 'R0: % recurso(s) de sala cuya referencia no es un espacio existente; NO se tocan (revisar a mano): %', n_huerf, detalle;
    END IF;

END $$;

-- ------------------------------------------------------------- C. backfill tenant de eventos de sala
DO $$
DECLARE
    n_upd integer;
    n_sin integer;
BEGIN
    UPDATE "procedures_perioperative"."operating_room_utilization_events" e
       SET tenant_id = cs.tenant_id
      FROM "practice"."care_spaces" cs
     WHERE cs.id = e.operating_room_id
       AND e.tenant_id IS NULL
       AND cs.tenant_id IS NOT NULL;
    GET DIAGNOSTICS n_upd = ROW_COUNT;
    SELECT count(*) INTO n_sin FROM "procedures_perioperative"."operating_room_utilization_events" WHERE tenant_id IS NULL;
    IF n_upd > 0 OR n_sin > 0 THEN
        RAISE NOTICE 'operating_room_utilization_events: % fila(s) con tenant completado desde la sala; % siguen sin tenant (sala sin tenant_id).', n_upd, n_sin;
    END IF;
END $$;

-- ------------------------------------------------------------- B. ventana reservada (trigger)
-- La API escribe en el caso la FOTO de care_spaces.prep_minutes/cleanup_minutes al programar
-- (salvo valor explícito); acá sólo se deriva el rango. `timestamptz ± interval` es STABLE:
-- por eso el EXCLUDE no puede calcularlo y se materializa. Se recalcula SIEMPRE (no se confía
-- en un valor escrito por el cliente).
CREATE OR REPLACE FUNCTION "procedures_perioperative"."procedure_cases_reserved_window"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.reserved_start_at := NEW.scheduled_start_at - make_interval(mins => coalesce(NEW.prep_minutes, 0));
    NEW.reserved_end_at   := NEW.scheduled_end_at   + make_interval(mins => coalesce(NEW.cleanup_minutes, 0));
    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_procedure_cases_reserved_window ON "procedures_perioperative"."procedure_cases";
CREATE TRIGGER trg_procedure_cases_reserved_window
    BEFORE INSERT OR UPDATE ON "procedures_perioperative"."procedure_cases"
    FOR EACH ROW EXECUTE FUNCTION "procedures_perioperative"."procedure_cases_reserved_window"();

-- Backfill: el UPDATE dispara el trigger, que recalcula la ventana. Sólo filas desfasadas.
UPDATE "procedures_perioperative"."procedure_cases"
   SET prep_minutes = prep_minutes
 WHERE reserved_start_at IS DISTINCT FROM scheduled_start_at - make_interval(mins => coalesce(prep_minutes, 0))
    OR reserved_end_at   IS DISTINCT FROM scheduled_end_at   + make_interval(mins => coalesce(cleanup_minutes, 0));

-- ------------------------------------------------------------- índices
CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_care_space_id" ON "scheduling"."schedulable_resources" ("care_space_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_schedulable_resources_tenant_id_id" ON "scheduling"."schedulable_resources" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_schedulable_resources_care_space_active" ON "scheduling"."schedulable_resources" ("care_space_id") WHERE care_space_id IS NOT NULL AND state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';
CREATE INDEX IF NOT EXISTS "ix_procedure_cases_schedulable_resource_id" ON "procedures_perioperative"."procedure_cases" ("schedulable_resource_id");
CREATE INDEX IF NOT EXISTS "ix_procedure_cases_operating_room_block_id" ON "procedures_perioperative"."procedure_cases" ("operating_room_block_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_tenant_id" ON "procedures_perioperative"."operating_room_utilization_events" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_utilization_events_operating_room_block_id" ON "procedures_perioperative"."operating_room_utilization_events" ("operating_room_block_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_tenant_id" ON "procedures_perioperative"."operating_room_block_series" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_practice_site_id" ON "procedures_perioperative"."operating_room_block_series" ("practice_site_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_operating_room_id" ON "procedures_perioperative"."operating_room_block_series" ("operating_room_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_owner_kind_concept_id" ON "procedures_perioperative"."operating_room_block_series" ("owner_kind_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_clinical_unit_id" ON "procedures_perioperative"."operating_room_block_series" ("clinical_unit_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_surgical_specialty_concept_id" ON "procedures_perioperative"."operating_room_block_series" ("surgical_specialty_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_surgeon_profile_id" ON "procedures_perioperative"."operating_room_block_series" ("surgeon_profile_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_status_concept_id" ON "procedures_perioperative"."operating_room_block_series" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_created_by_user_id" ON "procedures_perioperative"."operating_room_block_series" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_updated_by_user_id" ON "procedures_perioperative"."operating_room_block_series" ("updated_by_user_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_operating_room_block_series_tenant_id_id" ON "procedures_perioperative"."operating_room_block_series" ("tenant_id", "id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_tenant_id" ON "procedures_perioperative"."operating_room_blocks" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_series_id" ON "procedures_perioperative"."operating_room_blocks" ("series_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_operating_room_id" ON "procedures_perioperative"."operating_room_blocks" ("operating_room_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_owner_kind_concept_id" ON "procedures_perioperative"."operating_room_blocks" ("owner_kind_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_clinical_unit_id" ON "procedures_perioperative"."operating_room_blocks" ("clinical_unit_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_surgical_specialty_concept_id" ON "procedures_perioperative"."operating_room_blocks" ("surgical_specialty_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_surgeon_profile_id" ON "procedures_perioperative"."operating_room_blocks" ("surgeon_profile_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_status_concept_id" ON "procedures_perioperative"."operating_room_blocks" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_released_by_user_id" ON "procedures_perioperative"."operating_room_blocks" ("released_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_created_by_user_id" ON "procedures_perioperative"."operating_room_blocks" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_updated_by_user_id" ON "procedures_perioperative"."operating_room_blocks" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_room_time" ON "procedures_perioperative"."operating_room_blocks" ("operating_room_id", "starts_at", "ends_at");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_release_due" ON "procedures_perioperative"."operating_room_blocks" ("status_concept_id", "release_at");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_operating_room_blocks_tenant_id_id" ON "procedures_perioperative"."operating_room_blocks" ("tenant_id", "id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_history_operating_room__bd611718" ON "audit"."operating_room_block_series_history" ("operating_room_block_series_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_history_operation_concept_id" ON "audit"."operating_room_block_series_history" ("operation_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_history_changed_by_user_id" ON "audit"."operating_room_block_series_history" ("changed_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_history_change_reason_concept_id" ON "audit"."operating_room_block_series_history" ("change_reason_concept_id");
CREATE INDEX IF NOT EXISTS "brin_operating_room_block_series_history_recorded_at" ON "audit"."operating_room_block_series_history" USING brin ("recorded_at") WITH (pages_per_range=128);
CREATE INDEX IF NOT EXISTS "ix_operating_room_block_series_history_tenant_id" ON "audit"."operating_room_block_series_history" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_history_operating_room_block_id" ON "audit"."operating_room_blocks_history" ("operating_room_block_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_history_operation_concept_id" ON "audit"."operating_room_blocks_history" ("operation_concept_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_history_changed_by_user_id" ON "audit"."operating_room_blocks_history" ("changed_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_history_change_reason_concept_id" ON "audit"."operating_room_blocks_history" ("change_reason_concept_id");
CREATE INDEX IF NOT EXISTS "brin_operating_room_blocks_history_recorded_at" ON "audit"."operating_room_blocks_history" USING brin ("recorded_at") WITH (pages_per_range=128);
CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_history_tenant_id" ON "audit"."operating_room_blocks_history" ("tenant_id");

-- D. un checklist por (caso, tipo) — después de la precondición 0.3.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_surgical_safety_checklists_case_type" ON "procedures_perioperative"."surgical_safety_checklists" ("procedure_case_id", "checklist_type_concept_id");

-- FKs compuestas (escritas a mano, patrón F1b): (tenant_id, x_id) → padre (tenant_id, id).
-- MATCH SIMPLE: si x_id (o el tenant) es NULL no se exige nada. Conviven con la FK simple
-- generada. En procedure_cases el tenant es custodian_tenant_id. surgeon_profile_id no entra:
-- profiles.health_practitioner_profiles no tiene tenant_id (lo valida la API).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('scheduling.schedulable_resources',                    'fk_schedulable_resources_tenant_space',                    'tenant_id',           'care_space_id',                  'practice.care_spaces'),
            ('procedures_perioperative.procedure_cases',            'fk_procedure_cases_tenant_room',                           'custodian_tenant_id', 'operating_room_id',              'practice.care_spaces'),
            ('procedures_perioperative.procedure_cases',            'fk_procedure_cases_tenant_resource',                       'custodian_tenant_id', 'schedulable_resource_id',        'scheduling.schedulable_resources'),
            ('procedures_perioperative.procedure_cases',            'fk_procedure_cases_tenant_block',                          'custodian_tenant_id', 'operating_room_block_id',        'procedures_perioperative.operating_room_blocks'),
            ('procedures_perioperative.operating_room_utilization_events', 'fk_operating_room_utilization_events_tenant_room',  'tenant_id',           'operating_room_id',              'practice.care_spaces'),
            ('procedures_perioperative.operating_room_utilization_events', 'fk_operating_room_utilization_events_tenant_block', 'tenant_id',           'operating_room_block_id',        'procedures_perioperative.operating_room_blocks'),
            ('procedures_perioperative.operating_room_block_series', 'fk_operating_room_block_series_tenant_site',              'tenant_id',           'practice_site_id',               'practice.practice_sites'),
            ('procedures_perioperative.operating_room_block_series', 'fk_operating_room_block_series_tenant_room',              'tenant_id',           'operating_room_id',              'practice.care_spaces'),
            ('procedures_perioperative.operating_room_block_series', 'fk_operating_room_block_series_tenant_unit',              'tenant_id',           'clinical_unit_id',               'practice.clinical_units'),
            ('procedures_perioperative.operating_room_blocks',       'fk_operating_room_blocks_tenant_series',                  'tenant_id',           'series_id',                      'procedures_perioperative.operating_room_block_series'),
            ('procedures_perioperative.operating_room_blocks',       'fk_operating_room_blocks_tenant_room',                    'tenant_id',           'operating_room_id',              'practice.care_spaces'),
            ('procedures_perioperative.operating_room_blocks',       'fk_operating_room_blocks_tenant_unit',                    'tenant_id',           'clinical_unit_id',               'practice.clinical_units'),
            ('audit.operating_room_block_series_history',            'fk_operating_room_block_series_history_tenant_source',    'tenant_id',           'operating_room_block_series_id', 'procedures_perioperative.operating_room_block_series'),
            ('audit.operating_room_blocks_history',                  'fk_operating_room_blocks_history_tenant_source',          'tenant_id',           'operating_room_block_id',        'procedures_perioperative.operating_room_blocks')
        ) AS v(hijo, nombre, col_tenant, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY (%I, %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.col_tenant, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- historia (patrón F1b)
-- Tenant por defecto desde el origen y «sólo inserción + cierre de valid_to», con las mismas
-- funciones de F1b (audit.structure_history_fill_tenant / structure_history_close_only, de
-- 2026-10-29_infraestructura_f1b_seguridad.sql, que va antes que este patch).
DO $$
DECLARE
    r record;
BEGIN
    IF to_regproc('audit.structure_history_fill_tenant') IS NULL
       OR to_regproc('audit.structure_history_close_only') IS NULL THEN
        RAISE EXCEPTION 'F4 requiere 2026-10-29_infraestructura_f1b_seguridad.sql aplicado antes (faltan las funciones de historia de F1b).';
    END IF;
    FOR r IN
        SELECT * FROM (VALUES
            ('operating_room_block_series_history', 'procedures_perioperative.operating_room_block_series', 'operating_room_block_series_id'),
            ('operating_room_blocks_history',       'procedures_perioperative.operating_room_blocks',       'operating_room_block_id')
        ) AS v(historia, origen, columna)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_fill_tenant ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_fill_tenant BEFORE INSERT ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_fill_tenant"(%L, %L)',
                       r.historia, r.origen, r.columna);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_close_only ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_close_only BEFORE UPDATE OR DELETE ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_close_only"()',
                       r.historia);
    END LOOP;
END $$;

-- ------------------------------------------------------------- constraints (módulo 33)
-- B. Reemplazo del EXCLUDE de procedure_cases: sólo si todavía usa el rango programado.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ex_procedure_cases_operating_room_time'
           AND conrelid = '"procedures_perioperative"."procedure_cases"'::regclass
           AND pg_get_constraintdef(oid) LIKE '%reserved_start_at%'
    ) THEN
        ALTER TABLE "procedures_perioperative"."procedure_cases" DROP CONSTRAINT IF EXISTS "ex_procedure_cases_operating_room_time";
        ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ex_procedure_cases_operating_room_time"
            EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("reserved_start_at", "reserved_end_at", '[)') WITH &&) WHERE ("operating_room_id" IS NOT NULL AND "reserved_start_at" IS NOT NULL AND "reserved_end_at" IS NOT NULL AND "status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'));
        RAISE NOTICE 'ex_procedure_cases_operating_room_time: ahora sobre la ventana reservada (reserved_start_at, reserved_end_at).';
    END IF;
END $$;

-- E. operating_room_block_series
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_owner";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_owner" CHECK (("owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_time_order";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_time_order" CHECK (("end_time" > "start_time"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_validity";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_validity" CHECK (("valid_to" IS NULL OR "valid_to" >= "valid_from"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_weekdays";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_weekdays" CHECK ((cardinality("weekdays") > 0 AND "weekdays" <@ ARRAY[1, 2, 3, 4, 5, 6, 7]::smallint[]));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_release_hours";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_release_hours" CHECK (("release_hours" >= 0));

-- E. operating_room_blocks
--   EXCLUDE: active operating room block time overlap  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ex_operating_room_blocks_time";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ex_operating_room_blocks_time"
    EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("starts_at", "ends_at", '[)') WITH &&) WHERE ("status_concept_id" = '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ck_operating_room_blocks_owner";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_owner" CHECK (("owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ck_operating_room_blocks_end_after_start";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_end_after_start" CHECK (("ends_at" > "starts_at"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ck_operating_room_blocks_release_before_start";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_release_before_start" CHECK (("release_at" <= "starts_at"));

-- A. schedulable_resources
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."schedulable_resources" DROP CONSTRAINT IF EXISTS "ck_schedulable_resources_care_space_ref";
ALTER TABLE "scheduling"."schedulable_resources" ADD CONSTRAINT "ck_schedulable_resources_care_space_ref" CHECK (("resource_ref_type" <> 'care_spaces' OR "care_space_id" = "resource_ref_id"));

-- ------------------------------------------------------------- F. RLS
-- (bloques, series, eventos de sala y las dos historias)
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql. Los GRANT cubren el caso en que
-- las tablas nuevas las cree un rol distinto del que fijó los DEFAULT PRIVILEGES.
DO $$
DECLARE
    t text;
    tablas text[] := ARRAY[
        'procedures_perioperative.operating_room_block_series',
        'procedures_perioperative.operating_room_blocks',
        'procedures_perioperative.operating_room_utilization_events'
    ];
    nuevas text[] := ARRAY[
        'procedures_perioperative.operating_room_block_series',
        'procedures_perioperative.operating_room_blocks'
    ];
    historias text[] := ARRAY[
        'audit.operating_room_block_series_history',
        'audit.operating_room_blocks_history'
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY nuevas LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %s TO mantra_app', t);
        END LOOP;
        -- Historia: SELECT e INSERT, y UPDATE sólo de valid_to (igual que F1b).
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    FOREACH t IN ARRAY tablas || historias LOOP
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

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_columnas integer;
    n_tablas   integer;
    n_fk       integer;
    n_fkc      integer;
    n_htrg     integer;
    n_ux       integer;
    n_ex       integer;
    n_ck       integer;
    n_trg      integer;
    n_rls      integer;
BEGIN
    SELECT count(*) INTO n_columnas
      FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('scheduling', 'schedulable_resources', 'care_space_id'),
            ('procedures_perioperative', 'procedure_cases', 'schedulable_resource_id'),
            ('procedures_perioperative', 'procedure_cases', 'operating_room_block_id'),
            ('procedures_perioperative', 'procedure_cases', 'reserved_start_at'),
            ('procedures_perioperative', 'procedure_cases', 'reserved_end_at'),
            ('procedures_perioperative', 'operating_room_utilization_events', 'tenant_id'),
            ('procedures_perioperative', 'operating_room_utilization_events', 'operating_room_block_id'));

    SELECT count(*) INTO n_tablas
      FROM information_schema.tables
     WHERE (table_schema, table_name) IN (
            ('procedures_perioperative', 'operating_room_block_series'),
            ('procedures_perioperative', 'operating_room_blocks'),
            ('audit', 'operating_room_block_series_history'),
            ('audit', 'operating_room_blocks_history'));

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname = ANY (ARRAY['fk_schedulable_resources_care_space_id', 'fk_procedure_cases_operating_room_block_id', 'fk_operating_room_utilization_events_operating_room_block_id', 'fk_operating_room_blocks_series_id', 'fk_procedure_cases_schedulable_resource_id', 'fk_operating_room_utilization_events_tenant_id', 'fk_operating_room_block_series_tenant_id', 'fk_operating_room_block_series_practice_site_id', 'fk_operating_room_block_series_operating_room_id', 'fk_operating_room_block_series_owner_kind_concept_id', 'fk_operating_room_block_series_clinical_unit_id', 'fk_operating_room_block_series_surgical_specialty_concept_id', 'fk_operating_room_block_series_surgeon_profile_id', 'fk_operating_room_block_series_status_concept_id', 'fk_operating_room_block_series_created_by_user_id', 'fk_operating_room_block_series_updated_by_user_id', 'fk_operating_room_blocks_tenant_id', 'fk_operating_room_blocks_operating_room_id', 'fk_operating_room_blocks_owner_kind_concept_id', 'fk_operating_room_blocks_clinical_unit_id', 'fk_operating_room_blocks_surgical_specialty_concept_id', 'fk_operating_room_blocks_surgeon_profile_id', 'fk_operating_room_blocks_status_concept_id', 'fk_operating_room_blocks_released_by_user_id', 'fk_operating_room_blocks_created_by_user_id', 'fk_operating_room_blocks_updated_by_user_id', 'fk_operating_room_block_series_history_operating_room__9ea3a62d', 'fk_operating_room_block_series_history_operation_concept_id', 'fk_operating_room_block_series_history_changed_by_user_id', 'fk_operating_room_block_series_history_change_reason_concept_id', 'fk_operating_room_block_series_history_tenant_id', 'fk_operating_room_blocks_history_operating_room_block_id', 'fk_operating_room_blocks_history_operation_concept_id', 'fk_operating_room_blocks_history_changed_by_user_id', 'fk_operating_room_blocks_history_change_reason_concept_id', 'fk_operating_room_blocks_history_tenant_id']);

    SELECT count(*) INTO n_fkc
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname = ANY (ARRAY[
            'fk_schedulable_resources_tenant_space', 'fk_procedure_cases_tenant_room',
            'fk_procedure_cases_tenant_resource', 'fk_procedure_cases_tenant_block',
            'fk_operating_room_utilization_events_tenant_room', 'fk_operating_room_utilization_events_tenant_block',
            'fk_operating_room_block_series_tenant_site', 'fk_operating_room_block_series_tenant_room',
            'fk_operating_room_block_series_tenant_unit', 'fk_operating_room_blocks_tenant_series',
            'fk_operating_room_blocks_tenant_room', 'fk_operating_room_blocks_tenant_unit',
            'fk_operating_room_block_series_history_tenant_source', 'fk_operating_room_blocks_history_tenant_source']);

    SELECT count(*) INTO n_htrg
      FROM pg_trigger
     WHERE NOT tgisinternal AND tgname IN ('trg_fill_tenant', 'trg_close_only')
       AND tgrelid IN ('"audit"."operating_room_block_series_history"'::regclass,
                       '"audit"."operating_room_blocks_history"'::regclass);

    SELECT count(*) INTO n_ux
      FROM pg_indexes
     WHERE indexname IN ('ux_schedulable_resources_care_space_active', 'ux_surgical_safety_checklists_case_type',
                         'ux_schedulable_resources_tenant_id_id', 'ux_operating_room_block_series_tenant_id_id',
                         'ux_operating_room_blocks_tenant_id_id');

    SELECT count(*) INTO n_ex
      FROM pg_constraint
     WHERE contype = 'x'
       AND ((conname = 'ex_procedure_cases_operating_room_time' AND pg_get_constraintdef(oid) LIKE '%reserved_start_at%')
            OR conname = 'ex_operating_room_blocks_time');

    SELECT count(*) INTO n_ck
      FROM pg_constraint
     WHERE contype = 'c'
       AND conname IN ('ck_schedulable_resources_care_space_ref',
                       'ck_operating_room_block_series_owner', 'ck_operating_room_block_series_time_order',
                       'ck_operating_room_block_series_validity', 'ck_operating_room_block_series_weekdays',
                       'ck_operating_room_block_series_release_hours',
                       'ck_operating_room_blocks_owner', 'ck_operating_room_blocks_end_after_start',
                       'ck_operating_room_blocks_release_before_start');

    SELECT count(*) INTO n_trg
      FROM pg_trigger
     WHERE tgname = 'trg_procedure_cases_reserved_window' AND NOT tgisinternal
       AND tgrelid = '"procedures_perioperative"."procedure_cases"'::regclass;

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname
                        AND p.policyname = 'tenant_isolation'
     WHERE (n.nspname, c.relname) IN (
            ('procedures_perioperative', 'operating_room_block_series'),
            ('procedures_perioperative', 'operating_room_blocks'),
            ('procedures_perioperative', 'operating_room_utilization_events'),
            ('audit', 'operating_room_block_series_history'),
            ('audit', 'operating_room_blocks_history'))
       AND c.relrowsecurity AND c.relforcerowsecurity;

    IF n_columnas <> 7 OR n_tablas <> 4 OR n_fk <> 36 OR n_fkc <> 14 OR n_ux <> 5 OR n_ex <> 2
       OR n_ck <> 9 OR n_trg <> 1 OR n_htrg <> 4 OR n_rls <> 5 THEN
        RAISE EXCEPTION
            'F4 incompleto: columnas=% (7), tablas=% (4), fk=% (36), fk compuestas=% (14), únicos=% (5), exclude=% (2), check=% (9), trigger ventana=% (1), triggers historia=% (4), rls=% (5)',
            n_columnas, n_tablas, n_fk, n_fkc, n_ux, n_ex, n_ck, n_trg, n_htrg, n_rls;
    END IF;

    RAISE NOTICE 'F4 (quirófanos) aplicado: 7 columnas, 4 tablas, 36 FKs + 14 compuestas validadas, 5 únicos, 2 EXCLUDE, 9 CHECK, trigger de ventana reservada, historia solo inserción, 5 tablas con RLS.';
END $$;

COMMIT;
