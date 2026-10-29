-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F2 (operación de los espacios: ejes de
-- disponibilidad, higiene y aislamiento; eventos de estado A20; bloqueos; cola de limpieza)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y F2.1 (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y _f1b_seguridad.sql (orden F1 →
-- F1b → F2 → …). Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / DROP … IF EXISTS / CREATE OR REPLACE). Se puede aplicar N veces; la
-- segunda pasada no cambia nada (salvo completar el backfill de los ejes si, entre una pasada
-- y otra, la API sembró los conceptos: ver 10).
--
-- Contexto: columnas, tablas, FK simples e índices los emite gen_ddl.py en SQL/14_practice y
-- SQL/10_audit desde que diagram_14 y diagram_10 los declaran; los CHECK, el EXCLUDE y la
-- guarda de inmutabilidad los emite gen_integrity.py en SQL/14_practice/05_constraints.sql
-- desde diagram_33. Esas sentencias se copiaron de los archivos generados. Lo escrito a mano
-- (gen_ddl no lo sabe expresar): las precondiciones, las FK COMPUESTAS (tenant_id, x_id), los
-- triggers de historia, el RLS, los GRANT/REVOKE, el backfill y la verificación final. Igual
-- que F1/F1b. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
--
-- QUÉ CIERRA (CONTRATO-F2-F5 F2.1).
--   1. practice.care_spaces gana los ejes MANUALES de operación (la ocupación no se guarda:
--      se deriva de clinical.encounter_locations en F3). Disponibilidad REUTILIZA
--      operational_status_concept_id; se agregan su motivo vigente, fecha estimada y desde
--      cuándo; higiene (HYG_*), aislamiento (ISO_*) con organismo, `terminal_cleaning_required`
--      y `ops_version` (versión operativa separada de row_version: If-Match-Ops).
--   2. practice.care_space_status_events — evento A20 de cambio de estado. APPEND-ONLY:
--      guarda `integrity.forbid_mutation` (rechaza UPDATE y DELETE también al dueño) y
--      mantra_app sin UPDATE/DELETE/TRUNCATE. CHECK del código v2-0116.
--   3. practice.care_space_blocks — bloqueos (clínico, admin, mantenimiento, cierre).
--      EXCLUDE: un solo bloqueo no cancelado a la vez por espacio. CHECK: mantenimiento
--      exige fecha estimada; fin y fin estimado no preceden al inicio.
--   4. practice.cleaning_orders — cola de limpieza. Único parcial: a lo sumo una orden
--      abierta (PENDING / IN_PROGRESS / DONE) por espacio. CHECK: quien inspecciona no es
--      quien terminó.
--   5. audit.care_space_blocks_history y audit.cleaning_orders_history con el molde de F1b:
--      `tenant_id` NOT NULL (lo completa un trigger desde el origen), RLS, mantra_app con
--      SELECT, INSERT y UPDATE solo de `valid_to`, trigger de «solo inserción».
--      care_space_status_events NO tiene historia (es en sí mismo el rastro).
--   6. Las cinco tablas nuevas con `tenant_id` + RLS `tenant_isolation` (texto exacto de
--      2026-08-05_tenant_rls.sql) y FK COMPUESTAS (tenant_id, x_id) → padre del MISMO tenant,
--      como F1b. Además (practice_site_id, care_space_id) → care_spaces (practice_site_id, id)
--      en eventos y órdenes: la sede declarada es la del espacio.
--
-- UUID literales (el predicado de un índice parcial / CHECK debe ser IMMUTABLE), todos
-- `deterministicId('practice:<NOMBRE>')` de la API (common/constants/concepts.ts +
-- defineModuleConcepts('practice', …); calculados con uuid5 y verificados contra un literal
-- ya publicado de F5):
--   7ce5a926-1c46-56d4-8ca8-679e7429fa1d  practice:SPACE_OP_AVAILABLE   (existe)
--   7874b037-177f-5cac-adad-e7ba679d9ad3  practice:HYG_CLEAN            (nuevo, F2.2)
--   f2ead1d9-06f7-59a3-b26f-a3642a164f47  practice:ISO_NONE             (nuevo, F2.2)
--   b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0  practice:BLOCK_MAINTENANCE     (nuevo, F2.1)
--   c0c5918f-cf97-51e1-9ede-72d856e61c93  practice:CLN_PENDING           (nuevo, F2.1)
--   60ff8df8-4ba5-591c-b092-e8da81187539  practice:CLN_IN_PROGRESS       (nuevo, F2.1)
--   334b9e1f-b123-5477-a22e-2dd1b838c2fa  practice:CLN_DONE              (nuevo, F2.1)
-- La API DEBE registrar estos conceptos con exactamente esas claves (nombre de propiedad en
-- `practice.concepts.ts`); si usa otros nombres, el EXCLUDE/único/CHECK dejan de coincidir.
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos: sus ids los deriva la API (como F1). Por eso el backfill de los
--     ejes (NULL → SPACE_OP_AVAILABLE / HYG_CLEAN / ISO_NONE) es CONDICIONAL: solo escribe un
--     valor si ese concepto ya existe en terminology.catalog_concepts (la FK lo exige). En una
--     base donde la API todavía no sembró HYG_CLEAN / ISO_NONE los ejes quedan NULL (la API debe
--     leerlos como el valor por defecto) y volver a aplicar este patch después del seed
--     completa el backfill. SPACE_OP_AVAILABLE ya existe en cualquier base sembrada.
--   - No incrementa ops_version ni row_version: es de la API (como row_version hoy). El
--     backfill de los ejes tampoco toca row_version/updated_at (no debe provocar 412 a
--     quien edita estructura).
--   - No crea la historia de care_space_status_events (append-only).
--   - No borra ni renombra nada.
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo). Solo pueden
-- fallar si las tablas nuevas ya existían (p. ej. creadas desde SQL/14_practice/02_tables.sql
-- sin las constraints) y traen filas que las nuevas reglas rechazan:
--   - F1 / F1b / integridad sin aplicar (falta ux_care_spaces_tenant_id_id, las funciones
--     audit.structure_history_* o integrity.forbid_mutation).
--   - bloqueos solapados del mismo espacio; mantenimiento sin fecha estimada; fin o fin
--     estimado anterior al inicio; código v2-0116 fuera de C,H,I,K,O,U,R.
--   - órdenes abiertas repetidas por espacio; inspector = quien terminó.
--   - cualquier referencia hija → padre de OTRO tenant (o con sede ≠ la del espacio).
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas  +10 (care_spaces)
--   tablas     +5 (3 en practice, 2 en audit)
--   FK simples +45 (3 en care_spaces) · FK compuestas +11
--   índices    +54 nombrados (+5 PK de las tablas nuevas)
--   CHECK +4 · EXCLUDE +1 (+ su índice gist) · triggers +5 · políticas RLS +5
-- ============================================================================

BEGIN;

-- Las comprobaciones y el backfill leen/escriben tablas con RLS forzada (practice.*,
-- audit.*). El rol dueño la sortea si es superusuario; si no lo es, esto abre el contexto
-- SYSTEM solo para esta transacción (SET LOCAL), igual que F1/F1b.
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por el EXCLUDE de care_space_blocks

-- ------------------------------------------------------------- 0. prerrequisitos
DO $$
DECLARE
    faltan text[] := ARRAY[]::text[];
BEGIN
    IF to_regclass('practice.space_unit_assignments') IS NULL THEN
        faltan := faltan || 'F1 (practice.space_unit_assignments)';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'practice' AND indexname = 'ux_care_spaces_tenant_id_id')
       OR NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'practice' AND indexname = 'ux_practice_sites_tenant_id_id')
       OR NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'practice' AND indexname = 'ux_clinical_units_tenant_id_id') THEN
        faltan := faltan || 'F1b (UNIQUE (tenant_id, id) en sedes, unidades y espacios)';
    END IF;
    IF to_regprocedure('audit.structure_history_fill_tenant()') IS NULL
       OR to_regprocedure('audit.structure_history_close_only()') IS NULL THEN
        faltan := faltan || 'F1b (funciones audit.structure_history_*)';
    END IF;
    IF to_regprocedure('integrity.forbid_mutation()') IS NULL THEN
        faltan := faltan || 'SQL/_integrity/00_integrity_functions.sql (integrity.forbid_mutation)';
    END IF;
    IF cardinality(faltan) > 0 THEN
        RAISE EXCEPTION 'F2 practice: faltan prerrequisitos que se aplican antes: %. No se toca nada.', array_to_string(faltan, '; ')
            USING ERRCODE = 'undefined_object';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. care_spaces: ejes de operación
-- (de SQL/14_practice/02_tables.sql). Todo NULLable salvo las dos banderas/versiones, que
-- nacen con default para no romper las filas existentes.
ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "availability_reason_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "availability_expected_until" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "availability_changed_at" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "hygiene_status_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "hygiene_changed_at" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "terminal_cleaning_required" boolean NOT NULL DEFAULT false;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "isolation_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "isolation_organism_text" varchar;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "isolation_changed_at" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "ops_version" integer NOT NULL DEFAULT 1;

-- ops_version se declara NOT NULL sin default en el .puml (gen_ddl solo emite DEFAULT para
-- row_version y los booleanos marcados); el default lo pone este patch, igual que
-- row_version: MikroORM no inicializa el contador y mandaría NULL.
ALTER TABLE "practice"."care_spaces" ALTER COLUMN "ops_version" SET DEFAULT 1;
ALTER TABLE "practice"."care_spaces" ALTER COLUMN "terminal_cleaning_required" SET DEFAULT false;

-- ------------------------------------------------------------- 2. tablas nuevas
-- (de SQL/14_practice/02_tables.sql y SQL/10_audit/02_tables.sql)
CREATE TABLE IF NOT EXISTS "practice"."care_space_status_events" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "axis_concept_id" uuid NOT NULL,
    "from_concept_id" uuid,
    "to_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "reason_text" varchar,
    "expected_until" timestamptz,
    "v2_0116_code" char(1) NOT NULL,
    "source_concept_id" uuid NOT NULL,
    "source_ref_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    "request_id" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_care_space_status_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."care_space_blocks" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "reason_text" varchar,
    "starts_at" timestamptz NOT NULL,
    "expected_end_at" timestamptz,
    "ended_at" timestamptz,
    "ended_by_user_id" uuid,
    "end_note" varchar,
    "cancelled_at" timestamptz,
    "cancel_reason" varchar,
    "work_order_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_space_blocks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."cleaning_orders" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "clinical_unit_id" uuid,
    "cleaning_type_concept_id" uuid NOT NULL,
    "trigger_concept_id" uuid NOT NULL,
    "source_ref_id" uuid,
    "previous_order_id" uuid,
    "priority_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "due_at" timestamptz,
    "assigned_user_id" uuid,
    "started_at" timestamptz,
    "started_by_user_id" uuid,
    "finished_at" timestamptz,
    "finished_by_user_id" uuid,
    "inspected_at" timestamptz,
    "inspected_by_user_id" uuid,
    "inspection_result_concept_id" uuid,
    "rejection_reason" varchar,
    "cancel_reason" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_cleaning_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."care_space_blocks_history" (
    "history_id" uuid NOT NULL,
    "care_space_block_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_care_space_blocks_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."cleaning_orders_history" (
    "history_id" uuid NOT NULL,
    "cleaning_order_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_cleaning_orders_history" PRIMARY KEY ("history_id")
);

-- ------------------------------------------------------------- 3. precondiciones
-- Sobre las tablas nuevas: solo pueden tener filas si ya existían (creadas sin constraints).
-- Se listan todas las violaciones y se aborta; decidir cuál dato es el correcto no le toca
-- al patch.
DO $$
DECLARE
    n_solape   integer;
    n_eta      integer;
    n_rango    integer;
    n_v2       integer;
    n_abiertas integer;
    n_insp     integer;
BEGIN
    -- Fin o fin estimado anterior al inicio (se cuenta primero: tstzrange fallaría con ellos).
    SELECT count(*) INTO n_rango FROM "practice"."care_space_blocks"
     WHERE ("ended_at" IS NOT NULL AND "ended_at" < "starts_at")
        OR ("expected_end_at" IS NOT NULL AND "expected_end_at" < "starts_at");

    -- Mantenimiento sin fecha estimada.
    SELECT count(*) INTO n_eta FROM "practice"."care_space_blocks"
     WHERE "kind_concept_id" = 'b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0' AND "expected_end_at" IS NULL;

    -- Bloqueos no cancelados que se solapan en el mismo espacio.
    WITH ok AS (
        SELECT "id", "care_space_id", tstzrange("starts_at", "ended_at", '[)') AS r
          FROM "practice"."care_space_blocks"
         WHERE "cancelled_at" IS NULL AND ("ended_at" IS NULL OR "ended_at" >= "starts_at")
    )
    SELECT count(*) INTO n_solape
      FROM ok a JOIN ok b ON a."care_space_id" = b."care_space_id" AND a."id" < b."id" AND a.r && b.r;

    SELECT count(*) INTO n_v2 FROM "practice"."care_space_status_events"
     WHERE "v2_0116_code" NOT IN ('C','H','I','K','O','U','R');

    -- Más de una orden abierta (PENDING, IN_PROGRESS, DONE) en el mismo espacio.
    SELECT count(*) INTO n_abiertas
      FROM (SELECT "care_space_id" FROM "practice"."cleaning_orders"
             WHERE "status_concept_id" IN ('c0c5918f-cf97-51e1-9ede-72d856e61c93',
                                           '60ff8df8-4ba5-591c-b092-e8da81187539',
                                           '334b9e1f-b123-5477-a22e-2dd1b838c2fa')
             GROUP BY 1 HAVING count(*) > 1) d;

    SELECT count(*) INTO n_insp FROM "practice"."cleaning_orders"
     WHERE "inspected_by_user_id" IS NOT NULL AND "inspected_by_user_id" = "finished_by_user_id";

    IF n_solape > 0 OR n_eta > 0 OR n_rango > 0 OR n_v2 > 0 OR n_abiertas > 0 OR n_insp > 0 THEN
        RAISE EXCEPTION 'F2 practice: filas existentes que violan las reglas nuevas — bloqueos solapados=%, mantenimiento sin fecha estimada=%, fin anterior al inicio=%, código v2-0116 inválido=%, espacios con más de una orden de limpieza abierta=%, inspector = quien terminó=%. No se toca ningún dato; corregirlos a mano y volver a aplicar.',
            n_solape, n_eta, n_rango, n_v2, n_abiertas, n_insp
            USING ERRCODE = 'check_violation';
    END IF;
END $$;

-- Referencias hijo → padre de OTRO tenant (o con una sede distinta de la del espacio): las FK
-- compuestas no podrían crearse.
DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'care_space_status_events.practice_site_id', c."id" FROM "practice"."care_space_status_events" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_space_status_events.care_space_id', c."id" FROM "practice"."care_space_status_events" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_space_status_events.sede≠sede del espacio', c."id" FROM "practice"."care_space_status_events" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."practice_site_id" <> c."practice_site_id"
        UNION ALL
        SELECT 'care_space_blocks.care_space_id', c."id" FROM "practice"."care_space_blocks" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.practice_site_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.care_space_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.sede≠sede del espacio', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."practice_site_id" <> c."practice_site_id"
        UNION ALL
        SELECT 'cleaning_orders.clinical_unit_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.previous_order_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."cleaning_orders" p ON p."id" = c."previous_order_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_space_blocks_history.care_space_block_id', c."history_id" FROM "audit"."care_space_blocks_history" c
          JOIN "practice"."care_space_blocks" p ON p."id" = c."care_space_block_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders_history.cleaning_order_id', c."history_id" FROM "audit"."cleaning_orders_history" c
          JOIN "practice"."cleaning_orders" p ON p."id" = c."cleaning_order_id" WHERE p."tenant_id" <> c."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'F2 practice: hay referencias a un padre de OTRO tenant (o a una sede distinta de la del espacio) en % relación(es): %. No se crean las FK compuestas y no se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- ------------------------------------------------------------- 4. índices
-- (de SQL/14_practice/04_indexes.sql y SQL/10_audit/04_indexes.sql). Incluye los
-- UNIQUE (tenant_id, id) y ux_care_spaces_site_id_id que piden las FK compuestas.
CREATE INDEX IF NOT EXISTS "ix_care_spaces_availability_reason_concept_id" ON "practice"."care_spaces" ("availability_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_hygiene_status_concept_id" ON "practice"."care_spaces" ("hygiene_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_isolation_concept_id" ON "practice"."care_spaces" ("isolation_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_spaces_site_id_id" ON "practice"."care_spaces" ("practice_site_id", "id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_tenant_id" ON "practice"."care_space_status_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_practice_site_id" ON "practice"."care_space_status_events" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_care_space_id" ON "practice"."care_space_status_events" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_axis_concept_id" ON "practice"."care_space_status_events" ("axis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_from_concept_id" ON "practice"."care_space_status_events" ("from_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_to_concept_id" ON "practice"."care_space_status_events" ("to_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_reason_concept_id" ON "practice"."care_space_status_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_source_concept_id" ON "practice"."care_space_status_events" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_recorded_by_user_id" ON "practice"."care_space_status_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_space_occurred_at" ON "practice"."care_space_status_events" ("care_space_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_site_occurred_at" ON "practice"."care_space_status_events" ("practice_site_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_tenant_id" ON "practice"."care_space_blocks" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_care_space_id" ON "practice"."care_space_blocks" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_kind_concept_id" ON "practice"."care_space_blocks" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_reason_concept_id" ON "practice"."care_space_blocks" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_ended_by_user_id" ON "practice"."care_space_blocks" ("ended_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_created_by_user_id" ON "practice"."care_space_blocks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_updated_by_user_id" ON "practice"."care_space_blocks" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_space_blocks_tenant_id_id" ON "practice"."care_space_blocks" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_tenant_id" ON "practice"."cleaning_orders" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_practice_site_id" ON "practice"."cleaning_orders" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_care_space_id" ON "practice"."cleaning_orders" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_clinical_unit_id" ON "practice"."cleaning_orders" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_cleaning_type_concept_id" ON "practice"."cleaning_orders" ("cleaning_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_trigger_concept_id" ON "practice"."cleaning_orders" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_previous_order_id" ON "practice"."cleaning_orders" ("previous_order_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_priority_concept_id" ON "practice"."cleaning_orders" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_status_concept_id" ON "practice"."cleaning_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_assigned_user_id" ON "practice"."cleaning_orders" ("assigned_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_started_by_user_id" ON "practice"."cleaning_orders" ("started_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_finished_by_user_id" ON "practice"."cleaning_orders" ("finished_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_inspected_by_user_id" ON "practice"."cleaning_orders" ("inspected_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_inspection_result_concept_id" ON "practice"."cleaning_orders" ("inspection_result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_created_by_user_id" ON "practice"."cleaning_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_updated_by_user_id" ON "practice"."cleaning_orders" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_site_status_requested" ON "practice"."cleaning_orders" ("practice_site_id", "status_concept_id", "requested_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cleaning_orders_tenant_id_id" ON "practice"."cleaning_orders" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_care_space_block_id" ON "audit"."care_space_blocks_history" ("care_space_block_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_operation_concept_id" ON "audit"."care_space_blocks_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_changed_by_user_id" ON "audit"."care_space_blocks_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_change_reason_concept_id" ON "audit"."care_space_blocks_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_care_space_blocks_history_recorded_at" ON "audit"."care_space_blocks_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_tenant_id" ON "audit"."care_space_blocks_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_cleaning_order_id" ON "audit"."cleaning_orders_history" ("cleaning_order_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_operation_concept_id" ON "audit"."cleaning_orders_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_changed_by_user_id" ON "audit"."cleaning_orders_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_change_reason_concept_id" ON "audit"."cleaning_orders_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_cleaning_orders_history_recorded_at" ON "audit"."cleaning_orders_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_tenant_id" ON "audit"."cleaning_orders_history" ("tenant_id");

-- Una sola orden abierta por espacio (UUID literales: CLN_PENDING, CLN_IN_PROGRESS, CLN_DONE).
CREATE UNIQUE INDEX IF NOT EXISTS "ux_cleaning_orders_one_open_per_space" ON "practice"."cleaning_orders" ("care_space_id") WHERE status_concept_id IN ('c0c5918f-cf97-51e1-9ede-72d856e61c93', '60ff8df8-4ba5-591c-b092-e8da81187539', '334b9e1f-b123-5477-a22e-2dd1b838c2fa');

-- ------------------------------------------------------------- 5. FK simples
-- (de SQL/14_practice/03_fk_intra.sql, 90_fk_deferred.sql y SQL/10_audit/90_fk_deferred.sql)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_previous_order_id" FOREIGN KEY ("previous_order_id")
        REFERENCES "practice"."cleaning_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_availability_reason_concept_id" FOREIGN KEY ("availability_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_hygiene_status_concept_id" FOREIGN KEY ("hygiene_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_isolation_concept_id" FOREIGN KEY ("isolation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_axis_concept_id" FOREIGN KEY ("axis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_from_concept_id" FOREIGN KEY ("from_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_to_concept_id" FOREIGN KEY ("to_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_ended_by_user_id" FOREIGN KEY ("ended_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_cleaning_type_concept_id" FOREIGN KEY ("cleaning_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_trigger_concept_id" FOREIGN KEY ("trigger_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_assigned_user_id" FOREIGN KEY ("assigned_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_started_by_user_id" FOREIGN KEY ("started_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_finished_by_user_id" FOREIGN KEY ("finished_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_inspected_by_user_id" FOREIGN KEY ("inspected_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_inspection_result_concept_id" FOREIGN KEY ("inspection_result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_space_blocks (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_care_space_block_id" FOREIGN KEY ("care_space_block_id")
        REFERENCES "practice"."care_space_blocks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.cleaning_orders (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_cleaning_order_id" FOREIGN KEY ("cleaning_order_id")
        REFERENCES "practice"."cleaning_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 6. FK compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id): la base rechaza apuntar a un padre de otro
-- tenant. El RLS filtra filas pero no valida a dónde apunta una FK (se verifica sin RLS).
-- (practice_site_id, care_space_id) → care_spaces (practice_site_id, id): la sede del evento
-- o de la orden es la del espacio. MATCH SIMPLE: con la columna NULL no se exige nada, así que
-- sirven también para los padres opcionales. Conviven con la FK simple generada. Error al
-- cruzar tenants: 23503 (la API lo traduce al 404 del contrato, nunca revela que existe).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.care_space_status_events', 'fk_care_space_status_events_tenant_site',  '"tenant_id", "practice_site_id"',  'practice.practice_sites',   '"tenant_id", "id"'),
            ('practice.care_space_status_events', 'fk_care_space_status_events_tenant_space', '"tenant_id", "care_space_id"',     'practice.care_spaces',      '"tenant_id", "id"'),
            ('practice.care_space_status_events', 'fk_care_space_status_events_site_space',   '"practice_site_id", "care_space_id"', 'practice.care_spaces',   '"practice_site_id", "id"'),
            ('practice.care_space_blocks',        'fk_care_space_blocks_tenant_space',        '"tenant_id", "care_space_id"',     'practice.care_spaces',      '"tenant_id", "id"'),
            ('practice.cleaning_orders',          'fk_cleaning_orders_tenant_site',           '"tenant_id", "practice_site_id"',  'practice.practice_sites',   '"tenant_id", "id"'),
            ('practice.cleaning_orders',          'fk_cleaning_orders_tenant_space',          '"tenant_id", "care_space_id"',     'practice.care_spaces',      '"tenant_id", "id"'),
            ('practice.cleaning_orders',          'fk_cleaning_orders_site_space',            '"practice_site_id", "care_space_id"', 'practice.care_spaces',    '"practice_site_id", "id"'),
            ('practice.cleaning_orders',          'fk_cleaning_orders_tenant_unit',           '"tenant_id", "clinical_unit_id"',  'practice.clinical_units',   '"tenant_id", "id"'),
            ('practice.cleaning_orders',          'fk_cleaning_orders_tenant_previous',       '"tenant_id", "previous_order_id"', 'practice.cleaning_orders',  '"tenant_id", "id"'),
            ('audit.care_space_blocks_history',   'fk_care_space_blocks_history_tenant_source', '"tenant_id", "care_space_block_id"', 'practice.care_space_blocks', '"tenant_id", "id"'),
            ('audit.cleaning_orders_history',     'fk_cleaning_orders_history_tenant_source', '"tenant_id", "cleaning_order_id"', 'practice.cleaning_orders', '"tenant_id", "id"')
        ) AS v(hijo, nombre, columnas, padre, columnas_padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY (%s) REFERENCES %s (%s)',
                           r.hijo, r.nombre, r.columnas, r.padre, r.columnas_padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 7. CHECK, EXCLUDE y guarda de inmutabilidad
-- (de SQL/14_practice/05_constraints.sql, generado por gen_integrity.py desde diagram_33)

-- A20 append-only: la base rechaza UPDATE y DELETE sea cual sea el rol, incluido el dueño.
-- mantra_app, además, no recibe esos privilegios.
REVOKE UPDATE, DELETE ON "practice"."care_space_status_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "practice"."care_space_status_events";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "practice"."care_space_status_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

ALTER TABLE "practice"."care_space_status_events" DROP CONSTRAINT IF EXISTS "ck_care_space_status_events_v2_code";
ALTER TABLE "practice"."care_space_status_events" ADD CONSTRAINT "ck_care_space_status_events_v2_code" CHECK ("v2_0116_code" IN ('C','H','I','K','O','U','R'));

-- Un EXCLUDE no se recrea en cada pasada (reconstruiría su índice gist): solo si falta.
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conname = 'ex_care_space_blocks_time'
                      AND conrelid = 'practice.care_space_blocks'::regclass) THEN
        ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ex_care_space_blocks_time"
            EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("starts_at", "ended_at", '[)') WITH &&) WHERE ("cancelled_at" IS NULL);
    END IF;
END $$;

ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ck_care_space_blocks_maintenance_eta";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ck_care_space_blocks_maintenance_eta" CHECK (("kind_concept_id" <> 'b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0' OR "expected_end_at" IS NOT NULL));

ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ck_care_space_blocks_end_after_start";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ck_care_space_blocks_end_after_start" CHECK ((("ended_at" IS NULL OR "ended_at" >= "starts_at") AND ("expected_end_at" IS NULL OR "expected_end_at" >= "starts_at")));

ALTER TABLE "practice"."cleaning_orders" DROP CONSTRAINT IF EXISTS "ck_cleaning_orders_inspector_differs";
ALTER TABLE "practice"."cleaning_orders" ADD CONSTRAINT "ck_cleaning_orders_inspector_differs" CHECK (("inspected_by_user_id" IS NULL OR "inspected_by_user_id" <> "finished_by_user_id"));

-- ------------------------------------------------------------- 8. historia: tenant y solo inserción
-- Mismos triggers que F1b (audit.structure_history_fill_tenant / _close_only): el tenant se
-- completa desde la fila de origen si la API no lo manda, y solo se puede cerrar `valid_to`
-- una vez. TG_ARGV: tabla de origen, columna de origen.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('care_space_blocks_history', 'practice.care_space_blocks', 'care_space_block_id'),
            ('cleaning_orders_history',   'practice.cleaning_orders',   'cleaning_order_id')
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

-- ------------------------------------------------------------- 9. privilegios y RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql (ese patch también la pondría
-- sola ahora que estas tablas tienen tenant_id: no hay ventana sin aislamiento).
DO $$
DECLARE
    t text;
    tablas text[] := ARRAY[
        'practice.care_space_status_events',
        'practice.care_space_blocks',
        'practice.cleaning_orders',
        'audit.care_space_blocks_history',
        'audit.cleaning_orders_history'
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        -- bloqueos y órdenes: DML normal (como las tablas de F1).
        GRANT SELECT, INSERT, UPDATE, DELETE ON "practice"."care_space_blocks" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "practice"."cleaning_orders" TO mantra_app;
        -- eventos A20: solo SELECT e INSERT.
        REVOKE UPDATE, DELETE, TRUNCATE ON "practice"."care_space_status_events" FROM mantra_app;
        GRANT SELECT, INSERT ON "practice"."care_space_status_events" TO mantra_app;
        -- historia: SELECT, INSERT y UPDATE solo de valid_to (cierre SCD-2), como F1b.
        FOREACH t IN ARRAY ARRAY['audit.care_space_blocks_history', 'audit.cleaning_orders_history'] LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    FOREACH t IN ARRAY tablas LOOP
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

-- ------------------------------------------------------------- 10. backfill de los ejes
-- NULL → valor por defecto del eje (CONTRATO-F2-F5 F2.1), SOLO si ese concepto ya existe en
-- terminology.catalog_concepts (la FK lo exige; el patch no siembra conceptos, ver arriba).
-- Reaplicar el patch después de que la API sembró HYG_CLEAN / ISO_NONE completa el backfill.
-- No toca row_version ni updated_at ni los *_changed_at (se desconoce desde cuándo).
UPDATE "practice"."care_spaces" SET "operational_status_concept_id" = '7ce5a926-1c46-56d4-8ca8-679e7429fa1d'
 WHERE "operational_status_concept_id" IS NULL
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" WHERE "id" = '7ce5a926-1c46-56d4-8ca8-679e7429fa1d');

UPDATE "practice"."care_spaces" SET "hygiene_status_concept_id" = '7874b037-177f-5cac-adad-e7ba679d9ad3'
 WHERE "hygiene_status_concept_id" IS NULL
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" WHERE "id" = '7874b037-177f-5cac-adad-e7ba679d9ad3');

UPDATE "practice"."care_spaces" SET "isolation_concept_id" = 'f2ead1d9-06f7-59a3-b26f-a3642a164f47'
 WHERE "isolation_concept_id" IS NULL
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" WHERE "id" = 'f2ead1d9-06f7-59a3-b26f-a3642a164f47');

-- ------------------------------------------------------------- 11. verificación
DO $$
DECLARE
    n_cols   integer;
    n_nn     integer;
    n_tablas integer;
    n_fks    integer;
    n_fkc    integer;
    n_ix     integer;
    n_ux     integer;
    n_ck     integer;
    n_ex     integer;
    n_trg    integer;
    n_rls    integer;
    n_priv   integer;
    n_hist   integer;
    n_evt    integer;
BEGIN
    SELECT count(*) INTO n_cols FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'care_spaces'
       AND column_name IN ('availability_reason_concept_id', 'availability_expected_until',
            'availability_changed_at', 'hygiene_status_concept_id', 'hygiene_changed_at',
            'terminal_cleaning_required', 'isolation_concept_id', 'isolation_organism_text',
            'isolation_changed_at', 'ops_version');

    -- terminal_cleaning_required y ops_version: NOT NULL con su default.
    SELECT count(*) INTO n_nn FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'care_spaces' AND is_nullable = 'NO'
       AND ((column_name = 'terminal_cleaning_required' AND column_default = 'false')
         OR (column_name = 'ops_version' AND column_default = '1'));

    SELECT count(*) INTO n_tablas FROM information_schema.tables
     WHERE (table_schema, table_name) IN (('practice', 'care_space_status_events'),
            ('practice', 'care_space_blocks'), ('practice', 'cleaning_orders'),
            ('audit', 'care_space_blocks_history'), ('audit', 'cleaning_orders_history'));

    SELECT count(*) INTO n_fks FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND conname = ANY (ARRAY['fk_care_space_status_events_practice_site_id', 'fk_care_space_status_events_care_space_id', 'fk_care_space_blocks_care_space_id', 'fk_cleaning_orders_practice_site_id', 'fk_cleaning_orders_care_space_id', 'fk_cleaning_orders_clinical_unit_id', 'fk_cleaning_orders_previous_order_id', 'fk_care_spaces_availability_reason_concept_id', 'fk_care_spaces_hygiene_status_concept_id', 'fk_care_spaces_isolation_concept_id', 'fk_care_space_status_events_tenant_id', 'fk_care_space_status_events_axis_concept_id', 'fk_care_space_status_events_from_concept_id', 'fk_care_space_status_events_to_concept_id', 'fk_care_space_status_events_reason_concept_id', 'fk_care_space_status_events_source_concept_id', 'fk_care_space_status_events_recorded_by_user_id', 'fk_care_space_blocks_tenant_id', 'fk_care_space_blocks_kind_concept_id', 'fk_care_space_blocks_reason_concept_id', 'fk_care_space_blocks_ended_by_user_id', 'fk_care_space_blocks_created_by_user_id', 'fk_care_space_blocks_updated_by_user_id', 'fk_cleaning_orders_tenant_id', 'fk_cleaning_orders_cleaning_type_concept_id', 'fk_cleaning_orders_trigger_concept_id', 'fk_cleaning_orders_priority_concept_id', 'fk_cleaning_orders_status_concept_id', 'fk_cleaning_orders_assigned_user_id', 'fk_cleaning_orders_started_by_user_id', 'fk_cleaning_orders_finished_by_user_id', 'fk_cleaning_orders_inspected_by_user_id', 'fk_cleaning_orders_inspection_result_concept_id', 'fk_cleaning_orders_created_by_user_id', 'fk_cleaning_orders_updated_by_user_id', 'fk_care_space_blocks_history_care_space_block_id', 'fk_care_space_blocks_history_operation_concept_id', 'fk_care_space_blocks_history_changed_by_user_id', 'fk_care_space_blocks_history_change_reason_concept_id', 'fk_care_space_blocks_history_tenant_id', 'fk_cleaning_orders_history_cleaning_order_id', 'fk_cleaning_orders_history_operation_concept_id', 'fk_cleaning_orders_history_changed_by_user_id', 'fk_cleaning_orders_history_change_reason_concept_id', 'fk_cleaning_orders_history_tenant_id']);

    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname = ANY (ARRAY['fk_care_space_status_events_tenant_site', 'fk_care_space_status_events_tenant_space',
            'fk_care_space_status_events_site_space', 'fk_care_space_blocks_tenant_space',
            'fk_cleaning_orders_tenant_site', 'fk_cleaning_orders_tenant_space', 'fk_cleaning_orders_site_space',
            'fk_cleaning_orders_tenant_unit', 'fk_cleaning_orders_tenant_previous',
            'fk_care_space_blocks_history_tenant_source', 'fk_cleaning_orders_history_tenant_source']);

    SELECT count(*) INTO n_ix FROM pg_indexes
     WHERE indexname = ANY (ARRAY['ix_care_spaces_availability_reason_concept_id', 'ix_care_spaces_hygiene_status_concept_id', 'ix_care_spaces_isolation_concept_id', 'ux_care_spaces_site_id_id', 'ix_care_space_status_events_tenant_id', 'ix_care_space_status_events_practice_site_id', 'ix_care_space_status_events_care_space_id', 'ix_care_space_status_events_axis_concept_id', 'ix_care_space_status_events_from_concept_id', 'ix_care_space_status_events_to_concept_id', 'ix_care_space_status_events_reason_concept_id', 'ix_care_space_status_events_source_concept_id', 'ix_care_space_status_events_recorded_by_user_id', 'ix_care_space_status_events_space_occurred_at', 'ix_care_space_status_events_site_occurred_at', 'ix_care_space_blocks_tenant_id', 'ix_care_space_blocks_care_space_id', 'ix_care_space_blocks_kind_concept_id', 'ix_care_space_blocks_reason_concept_id', 'ix_care_space_blocks_ended_by_user_id', 'ix_care_space_blocks_created_by_user_id', 'ix_care_space_blocks_updated_by_user_id', 'ux_care_space_blocks_tenant_id_id', 'ix_cleaning_orders_tenant_id', 'ix_cleaning_orders_practice_site_id', 'ix_cleaning_orders_care_space_id', 'ix_cleaning_orders_clinical_unit_id', 'ix_cleaning_orders_cleaning_type_concept_id', 'ix_cleaning_orders_trigger_concept_id', 'ix_cleaning_orders_previous_order_id', 'ix_cleaning_orders_priority_concept_id', 'ix_cleaning_orders_status_concept_id', 'ix_cleaning_orders_assigned_user_id', 'ix_cleaning_orders_started_by_user_id', 'ix_cleaning_orders_finished_by_user_id', 'ix_cleaning_orders_inspected_by_user_id', 'ix_cleaning_orders_inspection_result_concept_id', 'ix_cleaning_orders_created_by_user_id', 'ix_cleaning_orders_updated_by_user_id', 'ix_cleaning_orders_site_status_requested', 'ux_cleaning_orders_tenant_id_id', 'ix_care_space_blocks_history_care_space_block_id', 'ix_care_space_blocks_history_operation_concept_id', 'ix_care_space_blocks_history_changed_by_user_id', 'ix_care_space_blocks_history_change_reason_concept_id', 'brin_care_space_blocks_history_recorded_at', 'ix_care_space_blocks_history_tenant_id', 'ix_cleaning_orders_history_cleaning_order_id', 'ix_cleaning_orders_history_operation_concept_id', 'ix_cleaning_orders_history_changed_by_user_id', 'ix_cleaning_orders_history_change_reason_concept_id', 'brin_cleaning_orders_history_recorded_at', 'ix_cleaning_orders_history_tenant_id', 'ux_cleaning_orders_one_open_per_space']);

    -- único parcial con los tres UUID literales de órdenes abiertas
    SELECT count(*) INTO n_ux FROM pg_indexes
     WHERE schemaname = 'practice' AND indexname = 'ux_cleaning_orders_one_open_per_space'
       AND indexdef LIKE 'CREATE UNIQUE INDEX%'
       AND indexdef LIKE '%c0c5918f-cf97-51e1-9ede-72d856e61c93%'
       AND indexdef LIKE '%60ff8df8-4ba5-591c-b092-e8da81187539%'
       AND indexdef LIKE '%334b9e1f-b123-5477-a22e-2dd1b838c2fa%';

    SELECT count(*) INTO n_ck FROM pg_constraint
     WHERE contype = 'c' AND convalidated
       AND conname IN ('ck_care_space_status_events_v2_code', 'ck_care_space_blocks_maintenance_eta',
                       'ck_care_space_blocks_end_after_start', 'ck_cleaning_orders_inspector_differs');

    SELECT count(*) INTO n_ex FROM pg_constraint
     WHERE contype = 'x' AND conname = 'ex_care_space_blocks_time'
       AND conrelid = 'practice.care_space_blocks'::regclass
       AND pg_get_constraintdef(oid) LIKE '%cancelled_at IS NULL%';

    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal
       AND ((tgrelid = 'practice.care_space_status_events'::regclass AND tgname = 'trg_forbid_mutation')
         OR (tgrelid = 'audit.care_space_blocks_history'::regclass AND tgname IN ('trg_fill_tenant', 'trg_close_only'))
         OR (tgrelid = 'audit.cleaning_orders_history'::regclass AND tgname IN ('trg_fill_tenant', 'trg_close_only')));

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE (n.nspname, c.relname) IN (('practice', 'care_space_status_events'), ('practice', 'care_space_blocks'),
            ('practice', 'cleaning_orders'), ('audit', 'care_space_blocks_history'), ('audit', 'cleaning_orders_history'))
       AND c.relrowsecurity AND c.relforcerowsecurity;

    n_priv := 0; n_hist := 0; n_evt := 0;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        -- historias: sin UPDATE/DELETE de tabla; eventos: sin UPDATE/DELETE/TRUNCATE.
        SELECT count(*) INTO n_hist FROM unnest(ARRAY['audit.care_space_blocks_history', 'audit.cleaning_orders_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE') OR has_table_privilege('mantra_app', t, 'DELETE');
        SELECT count(*) INTO n_evt
         WHERE has_table_privilege('mantra_app', 'practice.care_space_status_events', 'UPDATE')
            OR has_table_privilege('mantra_app', 'practice.care_space_status_events', 'DELETE')
            OR has_table_privilege('mantra_app', 'practice.care_space_status_events', 'TRUNCATE');
        n_priv := n_hist + n_evt;
    END IF;

    IF n_cols <> 10 OR n_nn <> 2 OR n_tablas <> 5 OR n_fks <> 45 OR n_fkc <> 11 OR n_ix <> 54
       OR n_ux <> 1 OR n_ck <> 4 OR n_ex <> 1 OR n_trg <> 5 OR n_rls <> 5 OR n_priv <> 0 THEN
        RAISE EXCEPTION
            'F2 practice incompleto: columnas=% (10), NOT NULL con default=% (2), tablas=% (5), FK simples=% (45), FK compuestas=% (11), índices=% (54), único de orden abierta=% (1), CHECK=% (4), EXCLUDE=% (1), triggers=% (5), RLS=% (5), privilegios de más para mantra_app=% (0)',
            n_cols, n_nn, n_tablas, n_fks, n_fkc, n_ix, n_ux, n_ck, n_ex, n_trg, n_rls, n_priv;
    END IF;

    RAISE NOTICE 'F2 practice aplicado: 10 columnas en care_spaces, 5 tablas (eventos A20 append-only, bloqueos, órdenes de limpieza, 2 historias), 45 FK simples + 11 compuestas por tenant, 4 CHECK, 1 EXCLUDE, 5 políticas RLS.';
END $$;

COMMIT;
