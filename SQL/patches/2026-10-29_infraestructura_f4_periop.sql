-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F4 · quirófanos (procedures_perioperative)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §F4.1 y §F4.2 (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql, …_f1b_seguridad.sql y
-- …_f4_scheduling.sql (que crea schedulable_resources.care_space_id y el único (tenant_id, id)
-- que este patch referencia). Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK y
-- CHECK con `duplicate_object` / DROP … IF EXISTS / CREATE OR REPLACE): se puede aplicar N veces; la
-- segunda pasada no cambia nada.
--
-- Lo que sí expresan los .puml (columnas, NOT NULL, FK simples, índices, CHECK y EXCLUDE de
-- diagram_33) ya lo emite gen_ddl.py / gen_integrity.py en SQL/53_procedures_perioperative y
-- SQL/10_audit, y esas sentencias se copiaron de ahí. Lo que el generador NO sabe expresar va solo
-- acá, igual que en F1b: FK compuestas por tenant, triggers, backfill, comprobaciones previas,
-- REVOKE/GRANT y políticas RLS. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
--
-- QUÉ HACE.
--   1. procedure_cases: schedulable_resource_id, operating_room_block_id, reserved_start_at,
--      reserved_end_at. El trigger trg_procedure_cases_reserved_window calcula SIEMPRE la ventana
--      reservada = [inicio − preparación, fin + limpieza) (la del caso o, si es NULL, la del
--      espacio); un timestamptz ± interval es STABLE y no entra en un EXCLUDE, por eso se
--      materializa. ex_procedure_cases_operating_room_reserved_time REEMPLAZA a
--      ex_procedure_cases_operating_room_time (ventana programada sin recambio): una sala no admite
--      dos casos vivos (programado, listo, en curso) cuyas ventanas reservadas se solapen.
--   2. Bloques de quirófano por servicio o cirujano: operating_room_block_series (regla recurrente)
--      y operating_room_blocks (instancia con regla de liberación); ex_operating_room_blocks_time
--      impide dos bloques ACTIVOS solapados en la misma sala; historias solo-inserción.
--   3. operating_room_utilization_events: tenant_id (backfill desde la sala; RLS) y
--      operating_room_block_id. El trigger BEFORE INSERT completa tenant_id desde la sala si el
--      cliente no lo manda (la API actual no lo manda).
--   4. surgical_safety_checklists: un solo check-list de cada tipo por caso
--      (ux_surgical_safety_checklists_case_type) y fases en orden (Pausa exige Entrada, Salida exige
--      Pausa).
--   5. Aislamiento entre tenants en las REFERENCIAS (patrón de F1b): UNIQUE (tenant_id, id) en las
--      tablas nuevas y en procedure_cases (custodian_tenant_id, id), y FK compuestas
--      (tenant_id, x_id) → padre (tenant_id, id): sala, sede, unidad, recurso, bloque, serie y caso
--      no pueden ser de otro tenant que la fila. Dos triggers de coherencia: la sala de una serie es
--      de la sede de la serie; un bloque de una serie usa la sala de la serie.
--   6. RLS tenant_isolation (texto exacto de 2026-08-05_tenant_rls.sql) en las tablas con tenant_id
--      nuevas; historias con mantra_app limitado a SELECT, INSERT y UPDATE de valid_to, más
--      triggers fill_tenant / close_only (las funciones las crea F1b).
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - falta F1 / F1b / f4_scheduling (índices (tenant_id, id), funciones de historia, care_space_id).
--   - referencias hacia un padre de OTRO tenant (caso → sala / sede; evento → caso): lista en el mensaje.
--   - casos vivos cuyas ventanas reservadas se solapan al sumar preparación y limpieza: lista de pares.
--   - más de un check-list del mismo tipo para un caso (versiones distintas), o con fases desordenadas.
-- ============================================================================

BEGIN;

-- Igual que F1: el backfill y las comprobaciones leen tablas con RLS forzada.
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 0. precondiciones de orden
DO $$
DECLARE
    faltan text[] := ARRAY[]::text[];
    i text;
BEGIN
    FOREACH i IN ARRAY ARRAY['ux_care_spaces_tenant_id_id', 'ux_practice_sites_tenant_id_id',
                             'ux_clinical_units_tenant_id_id', 'ux_schedulable_resources_tenant_id_id'] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = i) THEN
            faltan := faltan || ('índice ' || i);
        END IF;
    END LOOP;
    IF to_regprocedure('audit.structure_history_fill_tenant()') IS NULL THEN
        faltan := faltan || 'función audit.structure_history_fill_tenant()';
    END IF;
    IF to_regprocedure('audit.structure_history_close_only()') IS NULL THEN
        faltan := faltan || 'función audit.structure_history_close_only()';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_schema = 'scheduling' AND table_name = 'schedulable_resources'
                      AND column_name = 'care_space_id') THEN
        faltan := faltan || 'columna scheduling.schedulable_resources.care_space_id';
    END IF;
    IF cardinality(faltan) > 0 THEN
        RAISE EXCEPTION 'F4 periop: faltan % . Aplicar antes 2026-10-29_infraestructura_f1.sql, …_f1b_seguridad.sql y …_f4_scheduling.sql.',
            array_to_string(faltan, '; ')
            USING ERRCODE = 'undefined_object';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. columnas nuevas (copiadas de 02_tables)
ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "schedulable_resource_id" uuid;

ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "operating_room_block_id" uuid;

ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "reserved_start_at" timestamptz;

ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "reserved_end_at" timestamptz;

ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

ALTER TABLE "procedures_perioperative"."operating_room_utilization_events"
    ADD COLUMN IF NOT EXISTS "operating_room_block_id" uuid;

-- ------------------------------------------------------------- 2. tablas nuevas (copiadas de 02_tables)
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

-- ------------------------------------------------------------- 3. backfill de tenant_id en los eventos
-- El de la sala del evento. Sólo filas con NULL.
UPDATE "procedures_perioperative"."operating_room_utilization_events" e
   SET "tenant_id" = cs."tenant_id"
  FROM "practice"."care_spaces" cs
 WHERE cs."id" = e."operating_room_id"
   AND e."tenant_id" IS NULL;

-- ------------------------------------------------------------- 4. ventana reservada del caso
-- Preparación y limpieza: las del caso (la API guarda la foto de care_spaces al programar) o, si
-- son NULL, las del espacio (misma semántica que el comentario de v4.2.49 en el .puml). La
-- ventana se recalcula al insertar o cuando cambia alguna de sus entradas (horario, preparación,
-- limpieza, sala) o alguien toca reserved_*: así un cambio posterior de care_spaces.prep_minutes no
-- re-evalúa el EXCLUDE de casos ya programados al actualizar cualquier otra columna.
-- SECURITY INVOKER a propósito: con RLS, una sala de otro tenant ni se ve (no suma tiempos).
CREATE OR REPLACE FUNCTION "procedures_perioperative"."procedure_cases_set_reserved_window"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_prep      integer;
    v_cleanup   integer;
    r_prep      integer;
    r_cleanup   integer;
BEGIN
    IF TG_OP = 'UPDATE'
       AND NEW."reserved_start_at" IS NOT NULL
       AND NEW."reserved_start_at" IS NOT DISTINCT FROM OLD."reserved_start_at"
       AND NEW."reserved_end_at"   IS NOT DISTINCT FROM OLD."reserved_end_at"
       AND NEW."scheduled_start_at" IS NOT DISTINCT FROM OLD."scheduled_start_at"
       AND NEW."scheduled_end_at"   IS NOT DISTINCT FROM OLD."scheduled_end_at"
       AND NEW."prep_minutes"       IS NOT DISTINCT FROM OLD."prep_minutes"
       AND NEW."cleanup_minutes"    IS NOT DISTINCT FROM OLD."cleanup_minutes"
       AND NEW."operating_room_id"  IS NOT DISTINCT FROM OLD."operating_room_id" THEN
        RETURN NEW;   -- ninguna entrada cambió: se conserva la ventana ya reservada
    END IF;

    IF NEW."scheduled_start_at" IS NULL OR NEW."scheduled_end_at" IS NULL THEN
        NEW."reserved_start_at" := NULL;
        NEW."reserved_end_at"   := NULL;
        RETURN NEW;
    END IF;

    v_prep    := NEW."prep_minutes";
    v_cleanup := NEW."cleanup_minutes";
    IF (v_prep IS NULL OR v_cleanup IS NULL) AND NEW."operating_room_id" IS NOT NULL THEN
        SELECT cs."prep_minutes", cs."cleanup_minutes" INTO r_prep, r_cleanup
          FROM "practice"."care_spaces" cs
         WHERE cs."id" = NEW."operating_room_id";
        v_prep    := coalesce(v_prep, r_prep);
        v_cleanup := coalesce(v_cleanup, r_cleanup);
    END IF;

    NEW."reserved_start_at" := NEW."scheduled_start_at" - make_interval(mins => coalesce(v_prep, 0));
    NEW."reserved_end_at"   := NEW."scheduled_end_at"   + make_interval(mins => coalesce(v_cleanup, 0));
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_procedure_cases_reserved_window" ON "procedures_perioperative"."procedure_cases";
CREATE TRIGGER "trg_procedure_cases_reserved_window"
    BEFORE INSERT OR UPDATE
    ON "procedures_perioperative"."procedure_cases"
    FOR EACH ROW EXECUTE FUNCTION "procedures_perioperative"."procedure_cases_set_reserved_window"();

-- Backfill: la ventana de los casos que ya existen (el UPDATE dispara el trigger, que la calcula).
UPDATE "procedures_perioperative"."procedure_cases"
   SET "reserved_start_at" = NULL
 WHERE "reserved_start_at" IS NULL
   AND "scheduled_start_at" IS NOT NULL
   AND "scheduled_end_at" IS NOT NULL;

-- ------------------------------------------------------------- 5. precondiciones de datos
-- 5a. Eventos sin tenant derivable (no puede pasar: la sala es NOT NULL y tiene tenant).
DO $$
DECLARE
    n_null integer;
BEGIN
    SELECT count(*) INTO n_null FROM "procedures_perioperative"."operating_room_utilization_events"
     WHERE "tenant_id" IS NULL;
    IF n_null > 0 THEN
        RAISE EXCEPTION 'F4 periop: % evento(s) de utilización sin tenant_id tras el backfill desde la sala. No se puede poner NOT NULL: asignarles el tenant a mano y volver a aplicar.', n_null
            USING ERRCODE = 'not_null_violation';
    END IF;
END $$;

-- 5b. Referencias hacia un padre de OTRO tenant: se listan todas y se aborta (decidir cuál de los
-- dos tenants es el correcto no le toca al patch).
DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'procedure_cases.operating_room_id', c."id" FROM "procedures_perioperative"."procedure_cases" c
          JOIN "practice"."care_spaces" p ON p."id" = c."operating_room_id" WHERE p."tenant_id" <> c."custodian_tenant_id"
        UNION ALL
        SELECT 'procedure_cases.practice_site_id', c."id" FROM "procedures_perioperative"."procedure_cases" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."custodian_tenant_id"
        UNION ALL
        SELECT 'operating_room_utilization_events.procedure_case_id', c."id" FROM "procedures_perioperative"."operating_room_utilization_events" c
          JOIN "procedures_perioperative"."procedure_cases" p ON p."id" = c."procedure_case_id" WHERE p."custodian_tenant_id" <> c."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'F4 periop: hay referencias a un padre de OTRO tenant en % relación(es): %. No se crean las FK compuestas y no se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- 5c. Casos vivos cuyas ventanas reservadas se solapan al sumar preparación y limpieza. Estados
-- vivos: CASE_SCHEDULED, CASE_READY, SURG_CASE_IN_PROGRESS (los mismos tres UUID literales del
-- EXCLUDE anterior). Sin backfill silencioso: se listan los pares y se aborta.
DO $$
DECLARE
    n_pares integer;
    detalle text;
BEGIN
    SELECT count(*), string_agg(format('%s ↔ %s (sala %s)', a_id, b_id, sala), '; ')
      INTO n_pares, detalle
      FROM (SELECT a."id" AS a_id, b."id" AS b_id, a."operating_room_id" AS sala
              FROM "procedures_perioperative"."procedure_cases" a
              JOIN "procedures_perioperative"."procedure_cases" b
                ON b."operating_room_id" = a."operating_room_id" AND a."id" < b."id"
             WHERE a."reserved_start_at" < a."reserved_end_at" AND b."reserved_start_at" < b."reserved_end_at"
               AND a."reserved_start_at" < b."reserved_end_at" AND b."reserved_start_at" < a."reserved_end_at"
               AND a."status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203')
               AND b."status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203')
             ORDER BY a."id", b."id" LIMIT 20) p;
    IF n_pares > 0 THEN
        RAISE EXCEPTION 'F4 periop: % par(es) de casos vivos solapan su ventana reservada (preparación + limpieza) en la misma sala: %. Reprogramar uno de cada par y volver a aplicar (se muestran hasta 20).', n_pares, detalle
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

-- 5d. Check-lists: un solo registro de cada tipo por caso (aunque difiera la versión) y fases en orden.
DO $$
DECLARE
    n_dup   integer;
    n_ord   integer;
    detalle text;
BEGIN
    SELECT count(*), string_agg(format('caso %s tipo %s (%s registros)', "procedure_case_id", "checklist_type_concept_id", n), '; ')
      INTO n_dup, detalle
      FROM (SELECT "procedure_case_id", "checklist_type_concept_id", count(*) AS n
              FROM "procedures_perioperative"."surgical_safety_checklists"
             GROUP BY 1, 2 HAVING count(*) > 1 ORDER BY 1, 2 LIMIT 20) d;
    IF n_dup > 0 THEN
        RAISE EXCEPTION 'F4 periop: % caso(s) con más de un check-list del mismo tipo (versiones distintas): %. Dejar uno por tipo y volver a aplicar (se muestran hasta 20).', n_dup, detalle
            USING ERRCODE = 'unique_violation';
    END IF;

    SELECT count(*), string_agg("id"::text, ', ')
      INTO n_ord, detalle
      FROM (SELECT "id" FROM "procedures_perioperative"."surgical_safety_checklists"
             WHERE NOT (("time_out_completed_at" IS NULL OR "sign_in_completed_at" IS NOT NULL)
                    AND ("sign_out_completed_at" IS NULL OR "time_out_completed_at" IS NOT NULL))
             ORDER BY "id" LIMIT 20) o;
    IF n_ord > 0 THEN
        RAISE EXCEPTION 'F4 periop: % check-list(s) con fases fuera de orden (Pausa sin Entrada o Salida sin Pausa): %. Corregirlos a mano y volver a aplicar (se muestran hasta 20).', n_ord, detalle
            USING ERRCODE = 'check_violation';
    END IF;
END $$;

ALTER TABLE "procedures_perioperative"."operating_room_utilization_events" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- 6. índices (copiados de 04_indexes)
CREATE INDEX IF NOT EXISTS "ix_procedure_cases_schedulable_resource_id" ON "procedures_perioperative"."procedure_cases" ("schedulable_resource_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_operating_room_block_id" ON "procedures_perioperative"."procedure_cases" ("operating_room_block_id");

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_room_reserved" ON "procedures_perioperative"."procedure_cases" ("operating_room_id", "reserved_start_at", "reserved_end_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_procedure_cases_custodian_tenant_id_id" ON "procedures_perioperative"."procedure_cases" ("custodian_tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_surgical_safety_checklists_case_type" ON "procedures_perioperative"."surgical_safety_checklists" ("procedure_case_id", "checklist_type_concept_id");

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

CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_room_starts_at" ON "procedures_perioperative"."operating_room_blocks" ("operating_room_id", "starts_at");

CREATE INDEX IF NOT EXISTS "ix_operating_room_blocks_release_due" ON "procedures_perioperative"."operating_room_blocks" ("release_at") WHERE status_concept_id = '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8';

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

-- ------------------------------------------------------------- 7. FKs simples (copiadas de 03_fk_intra / 90_fk_deferred)
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

-- ------------------------------------------------------------- 8. FKs compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id). MATCH SIMPLE: si x_id es NULL no se exige nada, así
-- que sirven también para los padres opcionales. Conviven con la FK simple generada. procedure_cases
-- guarda su tenant en custodian_tenant_id.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('procedures_perioperative.procedure_cases',                 'fk_procedure_cases_tenant_operating_room', 'custodian_tenant_id, operating_room_id',        'practice.care_spaces',                                'tenant_id, id'),
            ('procedures_perioperative.procedure_cases',                 'fk_procedure_cases_tenant_practice_site',  'custodian_tenant_id, practice_site_id',         'practice.practice_sites',                             'tenant_id, id'),
            ('procedures_perioperative.procedure_cases',                 'fk_procedure_cases_tenant_resource',       'custodian_tenant_id, schedulable_resource_id',  'scheduling.schedulable_resources',                    'tenant_id, id'),
            ('procedures_perioperative.procedure_cases',                 'fk_procedure_cases_tenant_block',          'custodian_tenant_id, operating_room_block_id',  'procedures_perioperative.operating_room_blocks',      'tenant_id, id'),
            ('procedures_perioperative.operating_room_utilization_events','fk_or_utilization_events_tenant_room',    'tenant_id, operating_room_id',                  'practice.care_spaces',                                'tenant_id, id'),
            ('procedures_perioperative.operating_room_utilization_events','fk_or_utilization_events_tenant_case',    'tenant_id, procedure_case_id',                  'procedures_perioperative.procedure_cases',            'custodian_tenant_id, id'),
            ('procedures_perioperative.operating_room_utilization_events','fk_or_utilization_events_tenant_block',   'tenant_id, operating_room_block_id',            'procedures_perioperative.operating_room_blocks',      'tenant_id, id'),
            ('procedures_perioperative.operating_room_block_series',     'fk_or_block_series_tenant_site',           'tenant_id, practice_site_id',                   'practice.practice_sites',                             'tenant_id, id'),
            ('procedures_perioperative.operating_room_block_series',     'fk_or_block_series_tenant_room',           'tenant_id, operating_room_id',                  'practice.care_spaces',                                'tenant_id, id'),
            ('procedures_perioperative.operating_room_block_series',     'fk_or_block_series_tenant_unit',           'tenant_id, clinical_unit_id',                   'practice.clinical_units',                             'tenant_id, id'),
            ('procedures_perioperative.operating_room_blocks',           'fk_or_blocks_tenant_series',               'tenant_id, series_id',                          'procedures_perioperative.operating_room_block_series','tenant_id, id'),
            ('procedures_perioperative.operating_room_blocks',           'fk_or_blocks_tenant_room',                 'tenant_id, operating_room_id',                  'practice.care_spaces',                                'tenant_id, id'),
            ('procedures_perioperative.operating_room_blocks',           'fk_or_blocks_tenant_unit',                 'tenant_id, clinical_unit_id',                   'practice.clinical_units',                             'tenant_id, id'),
            ('audit.operating_room_block_series_history',                'fk_or_block_series_history_tenant_source', 'tenant_id, operating_room_block_series_id',     'procedures_perioperative.operating_room_block_series','tenant_id, id'),
            ('audit.operating_room_blocks_history',                      'fk_or_blocks_history_tenant_source',       'tenant_id, operating_room_block_id',            'procedures_perioperative.operating_room_blocks',      'tenant_id, id')
        ) AS v(hijo, nombre, columnas, padre, columnas_padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY (%s) REFERENCES %s (%s)',
                           r.hijo, r.nombre, r.columnas, r.padre, r.columnas_padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 9. EXCLUDE y CHECK (copiados de 05_constraints)
-- La sala no admite dos casos vivos con la ventana reservada solapada: reemplaza al EXCLUDE de la
-- ventana programada (sin recambio). Los bloques ACTIVOS de una sala tampoco se solapan.
ALTER TABLE "procedures_perioperative"."procedure_cases"
    DROP CONSTRAINT IF EXISTS "ex_procedure_cases_operating_room_time";

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ex_procedure_cases_operating_room_reserved_time"
        EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("reserved_start_at", "reserved_end_at", '[)') WITH &&) WHERE ("operating_room_id" IS NOT NULL AND "reserved_start_at" IS NOT NULL AND "reserved_end_at" IS NOT NULL AND "status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_owner" CHECK ("owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_schedule" CHECK (cardinality("weekdays") >= 1 AND "weekdays" <@ ARRAY[0,1,2,3,4,5,6]::smallint[] AND "end_time" > "start_time" AND ("valid_to" IS NULL OR "valid_to" >= "valid_from") AND "release_hours" >= 0);
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ex_operating_room_blocks_time"
        EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("starts_at", "ends_at", '[)') WITH &&) WHERE ("status_concept_id" = '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8');
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_owner" CHECK ("owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_window" CHECK ("ends_at" > "starts_at" AND "release_at" <= "starts_at");
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_status" CHECK ("status_concept_id" IN ('762dc30b-3e3c-5e1e-8504-5c511fd1d4a8', 'c3225706-ef13-5cbe-af6d-caaf25437458', 'e420cc84-8fd2-5887-a9bd-faf77d561508'));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_release_state" CHECK (("status_concept_id" <> 'c3225706-ef13-5cbe-af6d-caaf25437458' OR "released_at" IS NOT NULL) AND ("status_concept_id" <> '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8' OR "released_at" IS NULL) AND ("released_minutes" IS NULL OR "released_minutes" >= 0) AND ("status_concept_id" <> 'c3225706-ef13-5cbe-af6d-caaf25437458' OR "released_by_user_id" IS NULL OR btrim(coalesce("release_reason", '')) <> ''));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."surgical_safety_checklists" ADD CONSTRAINT "ck_surgical_safety_checklists_phase_order" CHECK (("time_out_completed_at" IS NULL OR "sign_in_completed_at" IS NOT NULL) AND ("sign_out_completed_at" IS NULL OR "time_out_completed_at" IS NOT NULL));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

-- ------------------------------------------------------------- 10. triggers de coherencia
-- 10a. Eventos: tenant_id desde la sala si el cliente no lo manda.
CREATE OR REPLACE FUNCTION "procedures_perioperative"."operating_room_utilization_events_fill_tenant"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    IF NEW."tenant_id" IS NULL THEN
        SELECT cs."tenant_id" INTO NEW."tenant_id"
          FROM "practice"."care_spaces" cs
         WHERE cs."id" = NEW."operating_room_id";
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_or_utilization_events_fill_tenant" ON "procedures_perioperative"."operating_room_utilization_events";
CREATE TRIGGER "trg_or_utilization_events_fill_tenant"
    BEFORE INSERT
    ON "procedures_perioperative"."operating_room_utilization_events"
    FOR EACH ROW EXECUTE FUNCTION "procedures_perioperative"."operating_room_utilization_events_fill_tenant"();

-- 10b. Serie: la sala es de la sede de la serie (regla 2 del contrato: misma sede).
CREATE OR REPLACE FUNCTION "procedures_perioperative"."operating_room_block_series_assert_room_site"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_site uuid;
BEGIN
    SELECT cs."practice_site_id" INTO v_site
      FROM "practice"."care_spaces" cs
     WHERE cs."id" = NEW."operating_room_id";
    IF v_site IS DISTINCT FROM NEW."practice_site_id" THEN
        RAISE EXCEPTION 'operating_room_block_series: el quirófano no pertenece a la sede de la serie'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_or_block_series_room_site" ON "procedures_perioperative"."operating_room_block_series";
CREATE TRIGGER "trg_or_block_series_room_site"
    BEFORE INSERT OR UPDATE OF "practice_site_id", "operating_room_id"
    ON "procedures_perioperative"."operating_room_block_series"
    FOR EACH ROW EXECUTE FUNCTION "procedures_perioperative"."operating_room_block_series_assert_room_site"();

-- 10c. Bloque de una serie: usa la sala de la serie.
CREATE OR REPLACE FUNCTION "procedures_perioperative"."operating_room_blocks_assert_series_room"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_room uuid;
BEGIN
    IF NEW."series_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT s."operating_room_id" INTO v_room
      FROM "procedures_perioperative"."operating_room_block_series" s
     WHERE s."id" = NEW."series_id";
    IF v_room IS DISTINCT FROM NEW."operating_room_id" THEN
        RAISE EXCEPTION 'operating_room_blocks: el bloque de una serie usa el quirófano de la serie'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_or_blocks_series_room" ON "procedures_perioperative"."operating_room_blocks";
CREATE TRIGGER "trg_or_blocks_series_room"
    BEFORE INSERT OR UPDATE OF "series_id", "operating_room_id"
    ON "procedures_perioperative"."operating_room_blocks"
    FOR EACH ROW EXECUTE FUNCTION "procedures_perioperative"."operating_room_blocks_assert_series_room"();

-- 10d. Historias de los bloques: tenant desde el origen y «sólo inserción + cierre de valid_to».
-- Las funciones las crea 2026-10-29_infraestructura_f1b_seguridad.sql. TG_ARGV: tabla de origen,
-- columna de origen.
DO $$
DECLARE
    r record;
BEGIN
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

-- ------------------------------------------------------------- 11. privilegios y RLS
-- Historias: mantra_app sólo SELECT, INSERT y UPDATE de valid_to (cierre SCD-2 de la revisión
-- anterior). Reaplicar este patch deja otra vez los privilegios mínimos (si
-- 2026-08-05_tenant_rls.sql se reaplica después, vuelve a dar UPDATE/DELETE de tabla: el trigger
-- trg_close_only sigue rechazando todo lo que no sea cerrar valid_to).
DO $$
DECLARE
    t text;
    historias text[] := ARRAY[
        'audit.operating_room_block_series_history',
        'audit.operating_room_blocks_history'
    ];
    con_tenant text[] := ARRAY[
        'procedures_perioperative.operating_room_block_series',
        'procedures_perioperative.operating_room_blocks',
        'procedures_perioperative.operating_room_utilization_events',
        'audit.operating_room_block_series_history',
        'audit.operating_room_blocks_history'
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
        -- Las tablas mutables nuevas conservan el DML general (como care_spaces): los privilegios
        -- por defecto del esquema ya se los dan a las creadas por el dueño; esto cubre una base donde
        -- no estén configurados.
        EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON "procedures_perioperative"."operating_room_block_series" TO mantra_app';
        EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON "procedures_perioperative"."operating_room_blocks" TO mantra_app';
    END IF;

    -- Texto exacto de la política de 2026-08-05_tenant_rls.sql (ese patch también la pondría sola
    -- ahora que estas tablas tienen tenant_id).
    FOREACH t IN ARRAY con_tenant LOOP
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

-- ------------------------------------------------------------- 12. verificación
DO $$
DECLARE
    n_tab   integer;
    n_col   integer;
    n_nn    integer;
    n_idx   integer;
    n_fks   integer;
    n_fkc   integer;
    n_cons  integer;
    n_old   integer;
    n_trg   integer;
    n_trgh  integer;
    n_rls   integer;
    n_upd   integer;
BEGIN
    SELECT count(*) INTO n_tab FROM information_schema.tables
     WHERE (table_schema, table_name) IN (('procedures_perioperative', 'operating_room_block_series'),
            ('procedures_perioperative', 'operating_room_blocks'),
            ('audit', 'operating_room_block_series_history'), ('audit', 'operating_room_blocks_history'));

    SELECT count(*) INTO n_col FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('procedures_perioperative', 'procedure_cases', 'schedulable_resource_id'),
            ('procedures_perioperative', 'procedure_cases', 'operating_room_block_id'),
            ('procedures_perioperative', 'procedure_cases', 'reserved_start_at'),
            ('procedures_perioperative', 'procedure_cases', 'reserved_end_at'),
            ('procedures_perioperative', 'operating_room_utilization_events', 'tenant_id'),
            ('procedures_perioperative', 'operating_room_utilization_events', 'operating_room_block_id'));

    SELECT count(*) INTO n_nn FROM information_schema.columns
     WHERE column_name = 'tenant_id' AND is_nullable = 'NO'
       AND (table_schema, table_name) IN (('procedures_perioperative', 'operating_room_utilization_events'),
            ('procedures_perioperative', 'operating_room_block_series'), ('procedures_perioperative', 'operating_room_blocks'),
            ('audit', 'operating_room_block_series_history'), ('audit', 'operating_room_blocks_history'));

    SELECT count(*) INTO n_idx FROM pg_indexes
     WHERE indexname IN (
            'ix_procedure_cases_schedulable_resource_id',
            'ix_procedure_cases_operating_room_block_id',
            'ix_procedure_cases_room_reserved',
            'ux_procedure_cases_custodian_tenant_id_id',
            'ux_surgical_safety_checklists_case_type',
            'ix_operating_room_utilization_events_tenant_id',
            'ix_operating_room_utilization_events_operating_room_block_id',
            'ix_operating_room_block_series_tenant_id',
            'ix_operating_room_block_series_practice_site_id',
            'ix_operating_room_block_series_operating_room_id',
            'ix_operating_room_block_series_owner_kind_concept_id',
            'ix_operating_room_block_series_clinical_unit_id',
            'ix_operating_room_block_series_surgical_specialty_concept_id',
            'ix_operating_room_block_series_surgeon_profile_id',
            'ix_operating_room_block_series_status_concept_id',
            'ix_operating_room_block_series_created_by_user_id',
            'ix_operating_room_block_series_updated_by_user_id',
            'ux_operating_room_block_series_tenant_id_id',
            'ix_operating_room_blocks_tenant_id',
            'ix_operating_room_blocks_series_id',
            'ix_operating_room_blocks_operating_room_id',
            'ix_operating_room_blocks_owner_kind_concept_id',
            'ix_operating_room_blocks_clinical_unit_id',
            'ix_operating_room_blocks_surgical_specialty_concept_id',
            'ix_operating_room_blocks_surgeon_profile_id',
            'ix_operating_room_blocks_status_concept_id',
            'ix_operating_room_blocks_released_by_user_id',
            'ix_operating_room_blocks_created_by_user_id',
            'ix_operating_room_blocks_updated_by_user_id',
            'ix_operating_room_blocks_room_starts_at',
            'ix_operating_room_blocks_release_due',
            'ux_operating_room_blocks_tenant_id_id',
            'ix_operating_room_block_series_history_operating_room__bd611718',
            'ix_operating_room_block_series_history_operation_concept_id',
            'ix_operating_room_block_series_history_changed_by_user_id',
            'ix_operating_room_block_series_history_change_reason_concept_id',
            'brin_operating_room_block_series_history_recorded_at',
            'ix_operating_room_block_series_history_tenant_id',
            'ix_operating_room_blocks_history_operating_room_block_id',
            'ix_operating_room_blocks_history_operation_concept_id',
            'ix_operating_room_blocks_history_changed_by_user_id',
            'ix_operating_room_blocks_history_change_reason_concept_id',
            'brin_operating_room_blocks_history_recorded_at',
            'ix_operating_room_blocks_history_tenant_id');

    SELECT count(*) INTO n_fks FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN (
            'fk_procedure_cases_operating_room_block_id',
            'fk_operating_room_utilization_events_operating_room_block_id',
            'fk_operating_room_blocks_series_id',
            'fk_procedure_cases_schedulable_resource_id',
            'fk_operating_room_utilization_events_tenant_id',
            'fk_operating_room_block_series_tenant_id',
            'fk_operating_room_block_series_practice_site_id',
            'fk_operating_room_block_series_operating_room_id',
            'fk_operating_room_block_series_owner_kind_concept_id',
            'fk_operating_room_block_series_clinical_unit_id',
            'fk_operating_room_block_series_surgical_specialty_concept_id',
            'fk_operating_room_block_series_surgeon_profile_id',
            'fk_operating_room_block_series_status_concept_id',
            'fk_operating_room_block_series_created_by_user_id',
            'fk_operating_room_block_series_updated_by_user_id',
            'fk_operating_room_blocks_tenant_id',
            'fk_operating_room_blocks_operating_room_id',
            'fk_operating_room_blocks_owner_kind_concept_id',
            'fk_operating_room_blocks_clinical_unit_id',
            'fk_operating_room_blocks_surgical_specialty_concept_id',
            'fk_operating_room_blocks_surgeon_profile_id',
            'fk_operating_room_blocks_status_concept_id',
            'fk_operating_room_blocks_released_by_user_id',
            'fk_operating_room_blocks_created_by_user_id',
            'fk_operating_room_blocks_updated_by_user_id',
            'fk_operating_room_block_series_history_operating_room__9ea3a62d',
            'fk_operating_room_block_series_history_operation_concept_id',
            'fk_operating_room_block_series_history_changed_by_user_id',
            'fk_operating_room_block_series_history_change_reason_concept_id',
            'fk_operating_room_block_series_history_tenant_id',
            'fk_operating_room_blocks_history_operating_room_block_id',
            'fk_operating_room_blocks_history_operation_concept_id',
            'fk_operating_room_blocks_history_changed_by_user_id',
            'fk_operating_room_blocks_history_change_reason_concept_id',
            'fk_operating_room_blocks_history_tenant_id');

    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_procedure_cases_tenant_operating_room', 'fk_procedure_cases_tenant_practice_site',
            'fk_procedure_cases_tenant_resource', 'fk_procedure_cases_tenant_block',
            'fk_or_utilization_events_tenant_room', 'fk_or_utilization_events_tenant_case',
            'fk_or_utilization_events_tenant_block', 'fk_or_block_series_tenant_site',
            'fk_or_block_series_tenant_room', 'fk_or_block_series_tenant_unit', 'fk_or_blocks_tenant_series',
            'fk_or_blocks_tenant_room', 'fk_or_blocks_tenant_unit', 'fk_or_block_series_history_tenant_source',
            'fk_or_blocks_history_tenant_source');

    SELECT count(*) INTO n_cons FROM pg_constraint
     WHERE contype IN ('c', 'x') AND convalidated
       AND conname IN (
            'ex_procedure_cases_operating_room_reserved_time',
            'ck_operating_room_block_series_owner',
            'ck_operating_room_block_series_schedule',
            'ex_operating_room_blocks_time',
            'ck_operating_room_blocks_owner',
            'ck_operating_room_blocks_window',
            'ck_operating_room_blocks_status',
            'ck_operating_room_blocks_release_state',
            'ck_surgical_safety_checklists_phase_order');

    SELECT count(*) INTO n_old FROM pg_constraint
     WHERE conname = 'ex_procedure_cases_operating_room_time';

    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgname IN ('trg_procedure_cases_reserved_window',
            'trg_or_utilization_events_fill_tenant', 'trg_or_block_series_room_site', 'trg_or_blocks_series_room');

    SELECT count(*) INTO n_trgh FROM pg_trigger t
      JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE NOT t.tgisinternal AND n.nspname = 'audit' AND t.tgname IN ('trg_fill_tenant', 'trg_close_only')
       AND c.relname IN ('operating_room_block_series_history', 'operating_room_blocks_history');

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE c.relrowsecurity AND c.relforcerowsecurity
       AND (n.nspname, c.relname) IN (('procedures_perioperative', 'operating_room_block_series'),
            ('procedures_perioperative', 'operating_room_blocks'),
            ('procedures_perioperative', 'operating_room_utilization_events'),
            ('audit', 'operating_room_block_series_history'), ('audit', 'operating_room_blocks_history'));

    n_upd := 0;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_upd FROM unnest(ARRAY['audit.operating_room_block_series_history',
                'audit.operating_room_blocks_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE') OR has_table_privilege('mantra_app', t, 'DELETE');
    END IF;

    IF n_tab <> 4 OR n_col <> 6 OR n_nn <> 5 OR n_idx <> 44 OR n_fks <> 35 OR n_fkc <> 15
       OR n_cons <> 9 OR n_old <> 0 OR n_trg <> 4 OR n_trgh <> 4 OR n_rls <> 5 OR n_upd <> 0 THEN
        RAISE EXCEPTION
            'F4 periop incompleto: tablas=% (4), columnas=% (6), tenant NOT NULL=% (5), índices=% (44), FK simples=% (35), FK compuestas=% (15), CHECK/EXCLUDE=% (9), EXCLUDE viejo vivo=% (0), triggers de F4=% (4), triggers de historia=% (4), RLS=% (5), historia con UPDATE/DELETE de tabla para mantra_app=% (0)',
            n_tab, n_col, n_nn, n_idx, n_fks, n_fkc, n_cons, n_old, n_trg, n_trgh, n_rls, n_upd;
    END IF;

    RAISE NOTICE 'F4 periop aplicado: ventana reservada con recambio y EXCLUDE por sala, bloques de quirófano (serie + instancia) con EXCLUDE de solape y liberación, eventos con tenant y bloque, check-list OMS único y en orden, FK compuestas por tenant, RLS e historias solo inserción.';
END $$;

COMMIT;
