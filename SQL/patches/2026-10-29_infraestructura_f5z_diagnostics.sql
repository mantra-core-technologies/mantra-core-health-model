-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5 · diagnóstico (F5a worklist DICOM del
-- estudio de imagen, F5b punto de toma de la muestra) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1, F5a y F5b (repositorio de documentación). Agente M-F5-clin.
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql, f1b_seguridad y
-- f5_operaciones (este último trae diagnostic_units.diagnostic_equipment.care_space_id, que
-- el trigger de imagen lee). Orden F1 → F1b → F2 → … → F5.
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / DROP … IF EXISTS / CREATE OR REPLACE). Se puede aplicar N veces;
-- la segunda pasada no cambia nada.
--
-- Contexto: columnas, FKs e índices los emite gen_ddl.py en SQL/20_diagnostics desde que
-- diagram_20 los declara; los dos CHECK de pareja los emite gen_integrity.py desde diagram_33.
-- Esas sentencias se escribieron aquí a mano con la MISMA forma que emiten los generadores (el
-- integrador regenera SQL/NN_*). Lo escrito sólo aquí: las precondiciones, los dos triggers de
-- coherencia y la verificación final. No hay EXCLUDE nuevos en este módulo. gen_apply.py no escanea SQL/patches/: no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA.
--   F5b. diagnostics.specimen_collection_events.collection_care_space_id → practice.care_spaces:
--        el punto de toma donde se extrajo la muestra. Se conserva collection_site_id.
--        ck_specimen_collection_events_care_space_requires_site: el espacio exige la sede.
--        trg_specimen_collection_events_space_site: el espacio debe ser de esa sede.
--   F5a. diagnostics.imaging_procedure_steps: Scheduled Procedure Step de la DICOM Modality
--        Worklist. scheduled_equipment_id → diagnostic_units.diagnostic_equipment,
--        scheduled_care_space_id → practice.care_spaces (SPS Location = care_spaces.code) y
--        scheduled_start_at. started_at / ended_at siguen siendo lo REALIZADO.
--        ck_imaging_procedure_steps_scheduled_space_requires_equipment: la sala exige el equipo.
--        trg_imaging_procedure_steps_scheduled_room: (1) si el equipo está ubicado en una sala,
--        esa es la sala del paso; (2) si no está ubicado, la sala debe ser del tenant de la
--        unidad diagnóstica dueña del equipo.
--
-- POR QUÉ LOS DOS CHECK DE PAREJA (hallazgo de seguridad, falla cerrado).
--   Los triggers comparan el espacio contra su pareja (sede de la toma / equipo del paso). Si
--   la pareja es NULL no hay contra qué comparar, y la primera versión de este patch dejaba
--   pasar la fila: se podía guardar el espacio de OTRO tenant poniendo sólo el espacio. Estas
--   dos tablas no tienen `tenant_id`, así que la base no puede validar el espacio contra el
--   tenant directamente; lo que sí puede es exigir que el espacio vaya con su pareja, y la
--   pareja es lo que el trigger valida. Se descartó la alternativa (no exigir la pareja y
--   validar el tenant del espacio contra el custodio/ejecutor): el centro ejecutor puede ser de
--   otro tenant (M-01..M-03) y no hay columna de ejecutor en estas filas.
--   Sigue siendo posible una pareja de otro tenant (sede o equipo de otro centro): es el flujo
--   legítimo «en este centro»; esa autorización es de la API (404 ante un id ajeno).
--
-- POR QUÉ NO HAY tenant_id NI RLS NUEVOS EN ESTAS DOS TABLAS.
--   Ninguna de las dos tiene `tenant_id`: cuelgan de specimens / imaging_studies, que llevan
--   `custodian_tenant_id`. Agregarles `tenant_id` sería un cambio de modelo de tablas ajenas a
--   esta franja y la FK compuesta por tenant de F1b (tenant_id, x_id) no tiene de dónde
--   tomarlo. Tampoco se compara contra custodian_tenant_id: el centro que ejecuta la orden
--   puede ser de otro tenant (performer_tenant_id, M-01..M-03) y la toma/el estudio ocurre en
--   SU sede. Lo que la base sí garantiza, sin suponer quién es el dueño del dato:
--     - muestra: el espacio es de la sede de la toma (misma sede);
--     - imagen: la sala es la del equipo, o del mismo tenant que el equipo.
--   Quién puede registrar una toma o programar un estudio en un espacio lo decide la API
--   (404 ante un id de otro tenant). Igual que F5 operaciones, las funciones leen
--   practice.care_spaces con `app.system_context = 'true'` fijado sólo dentro de la función
--   (cláusula SET: se restaura al salir) porque la sede/unidad puede ser de otro tenant y RLS
--   la volvería invisible; sus errores no distinguen «no existe» de «es de otra sede/tenant».
--
-- LO QUE ESTE PATCH NO HACE.
--   - No valida la función del espacio (SAMPLE_COLLECTION, IMAGING_ROOM), su estado ni su
--     disponibilidad: perfil de función y estados son de la API (422).
--   - No impide reservar dos pasos en el mismo equipo/sala a la hora: la capacidad del equipo
--     vive en el cupo de scheduling (F5a) y la de la sala en ex_appointments_care_space_time
--     (patch f5_clinical); un EXCLUDE sobre estos pasos sería una regla nueva.
--   - No revalida pasos ya programados cuando un equipo cambia de sala (la API los revalida:
--     proceso 07). Los triggers disparan sólo al escribir las columnas scheduled_*.
--   - No agrega historia ni RLS (ver arriba); no borra ni renombra nada.
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - f5_operaciones sin aplicar (falta diagnostic_equipment.care_space_id);
--   - tomas con espacio y sin sede, o cuyo espacio no es de su sede;
--   - pasos con sala y sin equipo, cuya sala no es la de su equipo o es de otro tenant que el equipo.
--   En el primer despliegue todas son imposibles (columnas nuevas NULL).
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas   +4  (specimen_collection_events 1 · imaging_procedure_steps 3)
--   FKs        +3
--   índices    +3
--   CHECK      +2 · triggers +2 · funciones +2
-- ============================================================================

BEGIN;

-- Las comprobaciones leen tablas con RLS forzada (practice.*, diagnostic_units.*).
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 0. requisito: f5_operaciones
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_schema = 'diagnostic_units' AND table_name = 'diagnostic_equipment'
                      AND column_name = 'care_space_id') THEN
        RAISE EXCEPTION 'F5 diagnóstico: falta diagnostic_units.diagnostic_equipment.care_space_id. Aplicar antes 2026-10-29_infraestructura_f5_operaciones.sql (orden F1 → F1b → … → F5).';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. columnas nuevas
-- (de SQL/20_diagnostics/02_tables.sql)
ALTER TABLE "diagnostics"."specimen_collection_events"
    ADD COLUMN IF NOT EXISTS "collection_care_space_id" uuid;

ALTER TABLE "diagnostics"."imaging_procedure_steps"
    ADD COLUMN IF NOT EXISTS "scheduled_equipment_id" uuid;

ALTER TABLE "diagnostics"."imaging_procedure_steps"
    ADD COLUMN IF NOT EXISTS "scheduled_care_space_id" uuid;

ALTER TABLE "diagnostics"."imaging_procedure_steps"
    ADD COLUMN IF NOT EXISTS "scheduled_start_at" timestamptz;

-- ------------------------------------------------------------- 2. FKs
-- (de SQL/20_diagnostics/90_fk_deferred.sql)
-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_collection_care_space_id" FOREIGN KEY ("collection_care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_equipment (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_scheduled_equipment_id" FOREIGN KEY ("scheduled_equipment_id")
        REFERENCES "diagnostic_units"."diagnostic_equipment" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_scheduled_care_space_id" FOREIGN KEY ("scheduled_care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- 3. índices no únicos
-- (de SQL/20_diagnostics/04_indexes.sql)
CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_collection_care_space_id" ON "diagnostics"."specimen_collection_events" ("collection_care_space_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_scheduled_equipment_id" ON "diagnostics"."imaging_procedure_steps" ("scheduled_equipment_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_scheduled_care_space_id" ON "diagnostics"."imaging_procedure_steps" ("scheduled_care_space_id");

-- ------------------------------------------------------------- 4. precondiciones
DO $$
DECLARE
    n_toma    integer;
    n_sala    integer;
    n_tenant  integer;
    n_toma_sin_sede integer;
    n_paso_sin_equipo integer;
BEGIN
    -- 4-. Espacio sin su pareja (lo rechazan los CHECK de la sección 5).
    SELECT count(*) INTO n_toma_sin_sede
      FROM "diagnostics"."specimen_collection_events"
     WHERE "collection_care_space_id" IS NOT NULL AND "collection_site_id" IS NULL;

    SELECT count(*) INTO n_paso_sin_equipo
      FROM "diagnostics"."imaging_procedure_steps"
     WHERE "scheduled_care_space_id" IS NOT NULL AND "scheduled_equipment_id" IS NULL;

    -- 4a. Toma con un espacio que no es de la sede de la toma.
    SELECT count(*) INTO n_toma
      FROM "diagnostics"."specimen_collection_events" e
      JOIN "practice"."care_spaces" cs ON cs."id" = e."collection_care_space_id"
     WHERE e."collection_site_id" IS NOT NULL
       AND cs."practice_site_id" IS DISTINCT FROM e."collection_site_id";

    -- 4b. Paso cuya sala no es la del equipo (equipo ubicado).
    SELECT count(*) INTO n_sala
      FROM "diagnostics"."imaging_procedure_steps" s
      JOIN "diagnostic_units"."diagnostic_equipment" q ON q."id" = s."scheduled_equipment_id"
     WHERE s."scheduled_care_space_id" IS NOT NULL
       AND q."care_space_id" IS NOT NULL
       AND q."care_space_id" IS DISTINCT FROM s."scheduled_care_space_id";

    -- 4c. Paso con sala de otro tenant que el equipo (equipo sin sala ubicada).
    SELECT count(*) INTO n_tenant
      FROM "diagnostics"."imaging_procedure_steps" s
      JOIN "diagnostic_units"."diagnostic_equipment" q ON q."id" = s."scheduled_equipment_id"
      JOIN "diagnostic_units"."diagnostic_unit_sites" dus ON dus."id" = q."diagnostic_unit_site_id"
      JOIN "diagnostic_units"."diagnostic_units" du ON du."id" = dus."diagnostic_unit_id"
      JOIN "practice"."care_spaces" cs ON cs."id" = s."scheduled_care_space_id"
     WHERE q."care_space_id" IS NULL
       AND cs."tenant_id" IS DISTINCT FROM du."tenant_id";

    IF n_toma > 0 OR n_sala > 0 OR n_tenant > 0 OR n_toma_sin_sede > 0 OR n_paso_sin_equipo > 0 THEN
        RAISE EXCEPTION 'F5 diagnóstico: datos que violan las reglas nuevas — tomas con espacio y sin sede=%, pasos con sala y sin equipo=%, tomas con espacio de otra sede=%, pasos con sala distinta de la del equipo=%, pasos con sala de otro tenant que el equipo=%. No se toca ningún dato; corregirlos a mano y volver a aplicar.',
            n_toma_sin_sede, n_paso_sin_equipo, n_toma, n_sala, n_tenant;
    END IF;
END $$;

-- ------------------------------------------------------------- 5. CHECK de pareja (falla cerrado)
-- (de SQL/20_diagnostics/05_constraints.sql, CHECK_SQL de diagram_33). Sin la pareja, el trigger
-- de la sección 6 no tiene contra qué comparar el espacio (ver cabecera).
ALTER TABLE "diagnostics"."specimen_collection_events" DROP CONSTRAINT IF EXISTS "ck_specimen_collection_events_care_space_requires_site";
ALTER TABLE "diagnostics"."specimen_collection_events" ADD CONSTRAINT "ck_specimen_collection_events_care_space_requires_site" CHECK ("collection_care_space_id" IS NULL OR "collection_site_id" IS NOT NULL);

ALTER TABLE "diagnostics"."imaging_procedure_steps" DROP CONSTRAINT IF EXISTS "ck_imaging_procedure_steps_scheduled_space_requires_equipment";
ALTER TABLE "diagnostics"."imaging_procedure_steps" ADD CONSTRAINT "ck_imaging_procedure_steps_scheduled_space_requires_equipment" CHECK ("scheduled_care_space_id" IS NULL OR "scheduled_equipment_id" IS NOT NULL);

-- ------------------------------------------------------------- 6. triggers de coherencia
-- Con los CHECK de la sección 5 la pareja nunca falta cuando hay espacio; los RETURN NEW por NULL
-- de abajo son sólo el camino «sin espacio». ERRCODE foreign_key_violation (23503) para sede/tenant, check_violation (23514) para «no es
-- la sala del equipo». La API pre-valida; la base es la red. SECURITY INVOKER; la cláusula SET
-- sólo sube app.system_context mientras corre la función (ver cabecera).

-- 6a. specimen_collection_events: el espacio de la toma es de la sede de la toma.
CREATE OR REPLACE FUNCTION "diagnostics"."specimen_collection_events_assert_space_site"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
SET app.system_context = 'true'
AS $fn$
DECLARE
    sede_del_espacio uuid;
BEGIN
    IF NEW."collection_care_space_id" IS NULL OR NEW."collection_site_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT cs."practice_site_id" INTO sede_del_espacio
      FROM "practice"."care_spaces" cs
     WHERE cs."id" = NEW."collection_care_space_id";
    IF sede_del_espacio IS DISTINCT FROM NEW."collection_site_id" THEN
        RAISE EXCEPTION 'specimen_collection_events.collection_care_space_id: el espacio no existe en la sede de la toma'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_specimen_collection_events_space_site" ON "diagnostics"."specimen_collection_events";
CREATE TRIGGER "trg_specimen_collection_events_space_site"
    BEFORE INSERT OR UPDATE OF "collection_site_id", "collection_care_space_id"
    ON "diagnostics"."specimen_collection_events"
    FOR EACH ROW EXECUTE FUNCTION "diagnostics"."specimen_collection_events_assert_space_site"();

-- 6b. imaging_procedure_steps: la sala del paso es la del equipo (o, si el equipo no está
--     ubicado, del tenant del equipo).
CREATE OR REPLACE FUNCTION "diagnostics"."imaging_procedure_steps_assert_scheduled_room"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
SET app.system_context = 'true'
AS $fn$
DECLARE
    sala_del_equipo  uuid;
    tenant_del_equipo uuid;
    tenant_de_sala   uuid;
BEGIN
    IF NEW."scheduled_care_space_id" IS NULL OR NEW."scheduled_equipment_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT q."care_space_id", du."tenant_id" INTO sala_del_equipo, tenant_del_equipo
      FROM "diagnostic_units"."diagnostic_equipment" q
      JOIN "diagnostic_units"."diagnostic_unit_sites" dus ON dus."id" = q."diagnostic_unit_site_id"
      JOIN "diagnostic_units"."diagnostic_units" du ON du."id" = dus."diagnostic_unit_id"
     WHERE q."id" = NEW."scheduled_equipment_id";
    IF sala_del_equipo IS NOT NULL THEN
        IF sala_del_equipo IS DISTINCT FROM NEW."scheduled_care_space_id" THEN
            RAISE EXCEPTION 'imaging_procedure_steps.scheduled_care_space_id: la sala no es la sala donde está ubicado el equipo'
                USING ERRCODE = 'check_violation';
        END IF;
    ELSE
        SELECT cs."tenant_id" INTO tenant_de_sala
          FROM "practice"."care_spaces" cs
         WHERE cs."id" = NEW."scheduled_care_space_id";
        IF tenant_del_equipo IS NULL OR tenant_de_sala IS DISTINCT FROM tenant_del_equipo THEN
            RAISE EXCEPTION 'imaging_procedure_steps.scheduled_care_space_id: la sala no existe en el tenant del equipo'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_imaging_procedure_steps_scheduled_room" ON "diagnostics"."imaging_procedure_steps";
CREATE TRIGGER "trg_imaging_procedure_steps_scheduled_room"
    BEFORE INSERT OR UPDATE OF "scheduled_equipment_id", "scheduled_care_space_id"
    ON "diagnostics"."imaging_procedure_steps"
    FOR EACH ROW EXECUTE FUNCTION "diagnostics"."imaging_procedure_steps_assert_scheduled_room"();

-- ------------------------------------------------------------- 7. verificación
DO $$
DECLARE
    n_columnas integer;
    n_fk       integer;
    n_idx      integer;
    n_ck       integer;
    n_tg       integer;
    n_fn       integer;
BEGIN
    SELECT count(*) INTO n_columnas
      FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('diagnostics', 'specimen_collection_events', 'collection_care_space_id'),
            ('diagnostics', 'imaging_procedure_steps', 'scheduled_equipment_id'),
            ('diagnostics', 'imaging_procedure_steps', 'scheduled_care_space_id'),
            ('diagnostics', 'imaging_procedure_steps', 'scheduled_start_at'));

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_specimen_collection_events_collection_care_space_id',
                       'fk_imaging_procedure_steps_scheduled_equipment_id',
                       'fk_imaging_procedure_steps_scheduled_care_space_id');

    SELECT count(*) INTO n_idx
      FROM pg_indexes
     WHERE (schemaname, indexname) IN (
            ('diagnostics', 'ix_specimen_collection_events_collection_care_space_id'),
            ('diagnostics', 'ix_imaging_procedure_steps_scheduled_equipment_id'),
            ('diagnostics', 'ix_imaging_procedure_steps_scheduled_care_space_id'));

    SELECT count(*) INTO n_ck
      FROM pg_constraint
     WHERE contype = 'c' AND convalidated
       AND conname IN ('ck_specimen_collection_events_care_space_requires_site',
                       'ck_imaging_procedure_steps_scheduled_space_requires_equipment');

    SELECT count(*) INTO n_tg
      FROM pg_trigger
     WHERE NOT tgisinternal
       AND tgname IN ('trg_specimen_collection_events_space_site', 'trg_imaging_procedure_steps_scheduled_room');

    SELECT count(*) INTO n_fn
      FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'diagnostics'
       AND p.proname IN ('specimen_collection_events_assert_space_site', 'imaging_procedure_steps_assert_scheduled_room');

    IF n_columnas <> 4 OR n_fk <> 3 OR n_idx <> 3 OR n_ck <> 2 OR n_tg <> 2 OR n_fn <> 2 THEN
        RAISE EXCEPTION 'F5 diagnóstico incompleto: columnas=% (4), fk=% (3), índices=% (3), check=% (2), triggers=% (2), funciones=% (2)',
            n_columnas, n_fk, n_idx, n_ck, n_tg, n_fn;
    END IF;

    RAISE NOTICE 'F5 diagnóstico aplicado: 4 columnas, 3 FKs validadas, 3 índices, 2 CHECK de pareja, 2 triggers de coherencia.';
END $$;

COMMIT;
