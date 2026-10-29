-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5 · clínico (F5d cita con consultorio,
-- F5b punto de toma sugerido en la orden) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1, F5b y F5d (repositorio de documentación). Agente M-F5-clin.
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y de
-- 2026-10-29_infraestructura_f1b_seguridad.sql (orden F1 → F1b → F2 → … → F5). No depende
-- de ningún otro patch de F2–F5 (no toca encounter_locations ni encounters: son de F3).
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / DROP … IF EXISTS / CREATE OR REPLACE). Se puede aplicar N veces;
-- la segunda pasada no cambia nada.
--
-- Contexto: las columnas, FKs simples e índices los emite gen_ddl.py en SQL/08_clinical desde
-- que diagram_08 los declara; el CHECK y el EXCLUDE los emite gen_integrity.py en
-- SQL/08_clinical/05_constraints.sql desde diagram_33. Esas sentencias se escribieron aquí a
-- mano con la MISMA forma que emiten los generadores (el integrador regenera SQL/NN_*).
-- Lo escrito sólo aquí (gen_ddl no lo expresa): las FK compuestas por tenant, las
-- precondiciones, el trigger de sede y la verificación final. gen_apply.py no escanea
-- SQL/patches/: este archivo no entra en apply_all.sql.
--
-- QUÉ CIERRA.
--   F5d. clinical.appointments.care_space_id → practice.care_spaces: el consultorio o sala
--        donde se atiende la cita. Nullable, SIN backfill (ninguna cita existente lo tiene).
--        · fk_appointments_tenant_care_space: FK compuesta (tenant_id, care_space_id) →
--          care_spaces (tenant_id, id) (ux_care_spaces_tenant_id_id de F1b). La cita no puede
--          apuntar a un espacio de OTRO tenant; las FK no pasan por RLS, así que el error es
--          el mismo aunque el espacio ni se vea. Convive con la FK simple generada.
--        · ex_appointments_care_space_time: EXCLUDE gist (care_space_id =, tstzrange(start_at,
--          end_at, '[)') &&) para las citas BOOKED y CHECKED_IN, la mitad «location» que
--          v4.2.3 dejó en prosa (INV-36). Dos citas del mismo consultorio a la misma hora
--          fallan con 23P01 aunque sean de médicos y agendas distintos.
--   F5b. clinical.service_requests.suggested_care_space_id → practice.care_spaces: el punto
--        de toma de muestras sugerido, refinamiento de suggested_practice_site_id.
--        · ck_service_requests_suggested_care_space_requires_site: sin sede sugerida no hay
--          punto sugerido.
--        · trg_service_requests_suggested_space_site: el espacio debe ser de ESA sede.
--
-- UUID literales (el predicado de un EXCLUDE debe ser IMMUTABLE), `deterministicId(<clave>)`
-- de la API (common/seed/concept-seed.ts), los mismos de ex_appointments_practitioner_time:
--   51530fd7-05b1-5c29-80c4-da740ede4d27  clinical:APPOINTMENT_BOOKED
--   37dded87-7a7a-5a24-86f6-0ef48cccb482  clinical:APPOINTMENT_CHECKED_IN
--
-- POR QUÉ service_requests NO LLEVA FK COMPUESTA POR TENANT (a diferencia de appointments).
--   La tabla no tiene `tenant_id` (tiene `custodian_tenant_id`, el dueño del dato) y la sede
--   sugerida es una RECOMENDACIÓN que puede ser de OTRO tenant (el centro que ejecuta:
--   modo «en este centro», M-01..M-03). Exigir tenant(espacio) = custodian_tenant_id rompería
--   ese flujo legítimo. Lo que sí es seguro y verificable: el espacio pertenece a la sede
--   sugerida (trigger). Quién puede sugerir qué sede lo decide la API, igual que hoy.
--   Como la sede sugerida puede ser de otro tenant, el trigger lee practice.care_spaces con
--   `app.system_context = 'true'` fijado SÓLO dentro de la función (cláusula SET de la
--   función: se restaura al salir) para que RLS no lo vuelva ciego; lee una sola columna
--   (practice_site_id) y su error no distingue «no existe» de «es de otra sede».
--
-- LO QUE ESTE PATCH NO HACE.
--   - No escribe appointments.care_space_id ni suggested_care_space_id en filas existentes.
--   - No valida la función del espacio (CONSULTING_ROOM / PROCEDURE_ROOM / IMAGING_ROOM con
--     perfil schedulable, SAMPLE_COLLECTION) ni que esté activo, disponible o fuera de
--     mantenimiento, ni que el espacio sea «allowOverlap»: el perfil de función es una
--     constante de la API (CONTRATO-F0-F1 §2). 422 de la API (TEMPLATE_CARE_SPACE_INVALID_FUNCTION,
--     COLLECTION_POINT_INVALID, …).
--   - No compara appointments.branch_id con la sucursal de la sede del espacio (branch ≠ sede
--     sigue siendo una decisión abierta, PLAN §7); lo valida la API (misma sede/práctica).
--   - No agrega RLS: appointments ya tiene `tenant_id` y su política tenant_isolation;
--     service_requests no tiene `tenant_id` (ver arriba) y no se le inventa uno.
--   - No agrega historia: ninguna tabla es nueva.
--   - No siembra conceptos ni toca schedule_templates / availability_exceptions (M-F5-sched).
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - F1b sin aplicar (falta ux_care_spaces_tenant_id_id);
--   - citas con care_space_id de OTRO tenant;
--   - órdenes con punto de toma sin sede, o cuyo espacio no es de la sede sugerida;
--   - citas BOOKED/CHECKED_IN solapadas en el mismo espacio (en el primer despliegue es
--     imposible: la columna nace NULL).
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas   +2  (appointments 1 · service_requests 1)
--   FKs        +3  (2 simples + 1 compuesta por tenant)
--   índices    +3  (2 IX declarados + el gist del EXCLUDE)
--   CHECK      +1 · EXCLUDE +1 · triggers +1 · funciones +1
-- ============================================================================

BEGIN;

-- Las comprobaciones leen tablas con RLS forzada (clinical.*, practice.*).
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ------------------------------------------------------------- 0. requisito: F1b
DO $$
BEGIN
    IF to_regclass('practice.ux_care_spaces_tenant_id_id') IS NULL THEN
        RAISE EXCEPTION 'F5 clínico: falta practice.ux_care_spaces_tenant_id_id. Aplicar antes 2026-10-29_infraestructura_f1b_seguridad.sql (orden F1 → F1b → … → F5).';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. columnas nuevas
-- (de SQL/08_clinical/02_tables.sql)
ALTER TABLE "clinical"."appointments"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "suggested_care_space_id" uuid;

-- ------------------------------------------------------------- 2. FKs simples
-- (de SQL/08_clinical/90_fk_deferred.sql)
-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."appointments"
        ADD CONSTRAINT "fk_appointments_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_suggested_care_space_id" FOREIGN KEY ("suggested_care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- 3. índices no únicos
-- (de SQL/08_clinical/04_indexes.sql)
CREATE INDEX IF NOT EXISTS "ix_appointments_care_space_id" ON "clinical"."appointments" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_suggested_care_space_id" ON "clinical"."service_requests" ("suggested_care_space_id");

-- ------------------------------------------------------------- 4. precondiciones
DO $$
DECLARE
    n_cruce    integer;
    n_sin_sede integer;
    n_otra     integer;
    n_solape   bigint;
BEGIN
    -- 4a. Cita con espacio de OTRO tenant (la FK simple no lo impide).
    SELECT count(*) INTO n_cruce
      FROM "clinical"."appointments" a
      JOIN "practice"."care_spaces" cs ON cs."id" = a."care_space_id"
     WHERE cs."tenant_id" IS DISTINCT FROM a."tenant_id";

    -- 4b. Orden con punto de toma sin sede, o con un espacio que no es de la sede sugerida.
    SELECT count(*) INTO n_sin_sede
      FROM "clinical"."service_requests"
     WHERE "suggested_care_space_id" IS NOT NULL AND "suggested_practice_site_id" IS NULL;

    SELECT count(*) INTO n_otra
      FROM "clinical"."service_requests" sr
      JOIN "practice"."care_spaces" cs ON cs."id" = sr."suggested_care_space_id"
     WHERE sr."suggested_practice_site_id" IS NOT NULL
       AND cs."practice_site_id" IS DISTINCT FROM sr."suggested_practice_site_id";

    -- 4c. Solapes existentes en el mismo espacio (imposible en el primer despliegue: columna NULL).
    SELECT count(*) INTO n_solape
      FROM "clinical"."appointments" a
      JOIN "clinical"."appointments" b
        ON a."care_space_id" = b."care_space_id"
       AND a."id" < b."id"
       AND tstzrange(a."start_at", a."end_at", '[)') && tstzrange(b."start_at", b."end_at", '[)')
     WHERE a."care_space_id" IS NOT NULL AND a."end_at" IS NOT NULL
       AND b."end_at" IS NOT NULL
       AND a."status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482')
       AND b."status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482');

    IF n_cruce > 0 OR n_sin_sede > 0 OR n_otra > 0 OR n_solape > 0 THEN
        RAISE EXCEPTION 'F5 clínico: datos que violan las reglas nuevas — citas con espacio de otro tenant=%, órdenes con punto de toma sin sede=%, órdenes con punto de toma de otra sede=%, pares de citas solapadas en el mismo espacio=%. No se toca ningún dato; corregirlos a mano y volver a aplicar.',
            n_cruce, n_sin_sede, n_otra, n_solape;
    END IF;
END $$;

-- ------------------------------------------------------------- 5. FK compuesta por tenant, CHECK y EXCLUDE
-- (CHECK/EXCLUDE de SQL/08_clinical/05_constraints.sql; la FK compuesta no la emite gen_ddl)

-- 5a. La cita y su consultorio son del mismo tenant. Convive con la FK simple. Nombre como las
--     de F1b: fk_<tabla>_tenant_<padre>. MATCH SIMPLE: con care_space_id NULL no se evalúa.
DO $$ BEGIN
    ALTER TABLE "clinical"."appointments"
        ADD CONSTRAINT "fk_appointments_tenant_care_space" FOREIGN KEY ("tenant_id", "care_space_id")
        REFERENCES "practice"."care_spaces" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 5b. Sin sede sugerida no hay punto de toma sugerido.
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_suggested_care_space_requires_site";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_suggested_care_space_requires_site" CHECK ("suggested_care_space_id" IS NULL OR "suggested_practice_site_id" IS NOT NULL);

-- 5c. Un consultorio no atiende dos citas confirmadas a la vez (INV-36).
ALTER TABLE "clinical"."appointments" DROP CONSTRAINT IF EXISTS "ex_appointments_care_space_time";
ALTER TABLE "clinical"."appointments" ADD CONSTRAINT "ex_appointments_care_space_time"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH &&) WHERE ("care_space_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'));

-- ------------------------------------------------------------- 6. trigger de sede
-- El espacio sugerido es de la sede sugerida. ERRCODE foreign_key_violation (23503), como los
-- triggers de mismo tenant de F1b / F5 operaciones: la API pre-valida (422
-- COLLECTION_POINT_INVALID) y la base es la red. SECURITY INVOKER; la cláusula SET sólo
-- sube app.system_context mientras corre la función (ver cabecera).
CREATE OR REPLACE FUNCTION "clinical"."service_requests_assert_suggested_space_site"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
SET app.system_context = 'true'
AS $fn$
DECLARE
    sede_del_espacio uuid;
BEGIN
    IF NEW."suggested_care_space_id" IS NULL THEN
        RETURN NEW;
    END IF;
    -- Sin sede lo rechaza el CHECK; aquí se evita una comparación contra NULL.
    IF NEW."suggested_practice_site_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT cs."practice_site_id" INTO sede_del_espacio
      FROM "practice"."care_spaces" cs
     WHERE cs."id" = NEW."suggested_care_space_id";
    IF sede_del_espacio IS DISTINCT FROM NEW."suggested_practice_site_id" THEN
        RAISE EXCEPTION 'service_requests.suggested_care_space_id: el espacio no existe en la sede sugerida'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_service_requests_suggested_space_site" ON "clinical"."service_requests";
CREATE TRIGGER "trg_service_requests_suggested_space_site"
    BEFORE INSERT OR UPDATE OF "suggested_practice_site_id", "suggested_care_space_id"
    ON "clinical"."service_requests"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."service_requests_assert_suggested_space_site"();

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
            ('clinical', 'appointments', 'care_space_id'),
            ('clinical', 'service_requests', 'suggested_care_space_id'));

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_appointments_care_space_id', 'fk_service_requests_suggested_care_space_id',
                       'fk_appointments_tenant_care_space');

    SELECT count(*) INTO n_idx
      FROM pg_indexes
     WHERE (schemaname, indexname) IN (
            ('clinical', 'ix_appointments_care_space_id'),
            ('clinical', 'ix_service_requests_suggested_care_space_id'),
            ('clinical', 'ex_appointments_care_space_time'));

    SELECT count(*) INTO n_ck
      FROM pg_constraint
     WHERE (contype = 'c' AND conname = 'ck_service_requests_suggested_care_space_requires_site')
        OR (contype = 'x' AND conname = 'ex_appointments_care_space_time');

    SELECT count(*) INTO n_tg
      FROM pg_trigger
     WHERE NOT tgisinternal AND tgname = 'trg_service_requests_suggested_space_site';

    SELECT count(*) INTO n_fn
      FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'clinical' AND p.proname = 'service_requests_assert_suggested_space_site';

    IF n_columnas <> 2 OR n_fk <> 3 OR n_idx <> 3 OR n_ck <> 2 OR n_tg <> 1 OR n_fn <> 1 THEN
        RAISE EXCEPTION 'F5 clínico incompleto: columnas=% (2), fk=% (3), índices=% (3), check/exclude=% (2), triggers=% (1), funciones=% (1)',
            n_columnas, n_fk, n_idx, n_ck, n_tg, n_fn;
    END IF;

    RAISE NOTICE 'F5 clínico aplicado: 2 columnas, 3 FKs validadas (1 compuesta por tenant), 3 índices (1 gist del EXCLUDE), 1 CHECK + 1 EXCLUDE, 1 trigger de sede.';
END $$;

COMMIT;
