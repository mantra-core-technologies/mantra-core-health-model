-- ============================================================================
-- SALUD · patch de integración de la infraestructura hospitalaria F2–F5 sobre BD viva
-- Fecha: 2026-10-31 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §6.2 (el integrador del modelo) — repositorio de documentación
-- Idempotente (CREATE OR REPLACE / DROP TRIGGER IF EXISTS + CREATE / FK con
-- `duplicate_object` / SET NOT NULL condicionado). Se puede aplicar N veces. Va DESPUÉS de
-- todos los 2026-10-29_infraestructura_*.sql (F1, F1b, F1c, F2, F3, F4, F5): usa sus
-- UNIQUE (tenant_id, id), la columna operating_room_utilization_events.tenant_id (F4), las
-- columnas de F5b/F5a (suggested_care_space_id, collection_care_space_id,
-- scheduled_care_space_id, scheduled_equipment_id) y aborta con mensaje si faltan.
--
-- Origen: revisión adversarial de seguridad de los patches F2–F5 al integrarlos (regla de
-- F1b: toda FK hacia practice.* o hacia una tabla con tenant_id es compuesta
-- (tenant_id, x_id) o, si una de las dos tablas no tiene tenant_id, va con trigger).
-- Lo demás de esa regla (RLS tenant_isolation en las 50 tablas tocadas, historias con el
-- patrón F1b y sin GRANT UPDATE/DELETE de tabla) ya lo cumplían los patches de cada franja.
--
-- QUÉ CIERRA.
--   A. procedures_perioperative.operating_room_utilization_events.tenant_id quedaba NULLable
--      (F4) y sin trigger que lo completara. Con tenant_id NULL la FK compuesta
--      fk_operating_room_utilization_events_tenant_room (tenant_id, operating_room_id) NO se
--      evalúa (MATCH SIMPLE), así que un escritor con app.system_context = 'true' (los jobs
--      SYSTEM_WORKER, §0.2) podía imputar un evento a una sala de cualquier tenant y dejarlo
--      fuera del RLS de todos. Ahora: trg_operating_room_utilization_events_fill_tenant
--      (BEFORE INSERT OR UPDATE OF tenant_id, operating_room_id) lo completa desde la sala si
--      llega NULL, backfill y SET NOT NULL (care_spaces.tenant_id es NOT NULL desde F1b y
--      operating_room_id es NOT NULL, así que siempre se puede completar).
--   B. FK compuestas que faltaban en tablas que F2/F4 ataron por tenant (columnas previas a
--      F1, pero la tabla ya expone el resto de sus referencias por (tenant_id, x_id)):
--        fk_procedure_cases_tenant_site        (custodian_tenant_id, practice_site_id) → practice.practice_sites (tenant_id, id)
--        fk_schedulable_resources_tenant_practice (tenant_id, practice_id)           → practice.practices (tenant_id, id)
--        fk_cost_centers_tenant_parent         (tenant_id, parent_cost_center_id)   → accounting.cost_centers (tenant_id, id)
--      Precondición: aborta con la lista si hoy hay filas que cruzan tenant.
--   C. Columnas nuevas de F5a/F5b hacia practice.care_spaces desde tablas SIN tenant_id (el
--      desvío de M-F3 las dejaba sólo a la API). Trigger de coherencia, mismo patrón que
--      trg_diagnostic_equipment_location_tenant (SECURITY INVOKER, 23503):
--        clinical.service_requests.suggested_care_space_id — el punto de toma debe ser un
--          espacio de suggested_practice_site_id (§F5b; la API responde 422
--          COLLECTION_POINT_INVALID antes). Si la sede viene NULL se completa desde el espacio.
--          El tenant del punto puede ser otro que el de la orden (ejecutor externo): eso no
--          cambia.
--        diagnostics.specimen_collection_events.collection_care_space_id — espacio de
--          collection_site_id; si la sede viene NULL se completa desde el espacio.
--        diagnostics.imaging_procedure_steps.scheduled_care_space_id — con equipo programado,
--          la sala tiene que ser del tenant de la unidad diagnóstica del equipo (la misma
--          resolución que usa trg_diagnostic_equipment_location_tenant).
--
-- QUÉ NO CIERRA (riesgo residual, fuera de F2–F5; columnas anteriores a F1 en tablas de otros
-- dueños): FK simples entre tablas con tenant_id que ya existían —clinical.encounters
-- (appointment_id, episode_id, branch_id), clinical.service_requests.encounter_id,
-- clinical.appointments.branch_id, practice.practice_sites.branch_id,
-- accounting.infrastructure_items.branch_id, procedure_cases.encounter_id,
-- scheduling.availability_exceptions.resource_id (tabla sin tenant_id)—.
-- directory.branches y clinical.* no exponen UNIQUE (tenant_id, id) en los módulos de esta
-- tanda. billing.charge_captures.encounter_id ya va por trg_charge_captures_refs (F5e).
--
-- ABORTA (RAISE EXCEPTION, sin cambios) si:
--   1. Falta algo de F1b/F4/F5 que este patch usa.
--   2. Hay filas que la FK compuesta de B rechazaría (lista hasta 20).
--   3. Hay filas de C incoherentes (punto de toma de otra sede, sala de otro tenant que el
--      equipo) — lista hasta 20.
--
-- DELTAS ESPERADOS (primera aplicación): FK +3 · funciones +4 · triggers +4 ·
-- NOT NULL +1 (operating_room_utilization_events.tenant_id).
-- ============================================================================

BEGIN;

SET LOCAL lock_timeout = '10s';
-- El backfill de A escribe una tabla con RLS forzada; el dueño la sortea si es superusuario,
-- si no, esto abre el contexto SYSTEM sólo para esta transacción.
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 0. precondiciones
DO $$
DECLARE
    faltan text;
BEGIN
    SELECT string_agg(x, ', ') INTO faltan FROM (
        SELECT 'índice ' || i AS x FROM unnest(ARRAY[
            'practice.ux_practices_tenant_id_id', 'practice.ux_practice_sites_tenant_id_id',
            'practice.ux_care_spaces_tenant_id_id', 'accounting.ux_cost_centers_tenant_id_id']) i
         WHERE to_regclass(i) IS NULL
        UNION ALL
        SELECT 'columna ' || c FROM unnest(ARRAY[
            'procedures_perioperative.operating_room_utilization_events.tenant_id',
            'procedures_perioperative.procedure_cases.custodian_tenant_id',
            'scheduling.schedulable_resources.tenant_id',
            'accounting.cost_centers.tenant_id',
            'clinical.service_requests.suggested_care_space_id',
            'diagnostics.specimen_collection_events.collection_care_space_id',
            'diagnostics.imaging_procedure_steps.scheduled_care_space_id',
            'diagnostics.imaging_procedure_steps.scheduled_equipment_id']) c
         WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns ic
                            WHERE ic.table_schema || '.' || ic.table_name || '.' || ic.column_name = c)
    ) q;
    IF faltan IS NOT NULL THEN
        RAISE EXCEPTION 'Integración F2–F5: faltan objetos de F1b/F4/F5 (%). Aplicá antes los 2026-10-29_infraestructura_*.sql.', faltan;
    END IF;
END $$;

DO $$
DECLARE
    n integer;
    detalle text;
BEGIN
    -- B. cruces de tenant que las FK compuestas rechazarían
    SELECT count(*), string_agg(x, '; ') INTO n, detalle FROM (
        SELECT format('procedure_cases %s (tenant %s) → sede %s (tenant %s)', c.id, c.custodian_tenant_id, s.id, s.tenant_id) x
          FROM "procedures_perioperative"."procedure_cases" c
          JOIN "practice"."practice_sites" s ON s.id = c.practice_site_id
         WHERE s.tenant_id IS DISTINCT FROM c.custodian_tenant_id
        UNION ALL
        SELECT format('schedulable_resources %s (tenant %s) → práctica %s (tenant %s)', r.id, r.tenant_id, p.id, p.tenant_id)
          FROM "scheduling"."schedulable_resources" r
          JOIN "practice"."practices" p ON p.id = r.practice_id
         WHERE r.tenant_id IS NOT NULL AND p.tenant_id IS DISTINCT FROM r.tenant_id
        UNION ALL
        SELECT format('cost_centers %s (tenant %s) → padre %s (tenant %s)', c.id, c.tenant_id, p.id, p.tenant_id)
          FROM "accounting"."cost_centers" c
          JOIN "accounting"."cost_centers" p ON p.id = c.parent_cost_center_id
         WHERE p.tenant_id IS DISTINCT FROM c.tenant_id
        LIMIT 20
    ) q;
    IF n > 0 THEN
        RAISE EXCEPTION 'Integración F2–F5: % referencia(s) cruzan tenant; corregilas antes de aplicar: %', n, detalle;
    END IF;

    -- C. coherencia de los puntos de toma y de la sala del paso de imagen
    SELECT count(*), string_agg(x, '; ') INTO n, detalle FROM (
        SELECT format('service_requests %s: punto %s no es de la sede %s', r.id, r.suggested_care_space_id, r.suggested_practice_site_id) x
          FROM "clinical"."service_requests" r
          JOIN "practice"."care_spaces" cs ON cs.id = r.suggested_care_space_id
         WHERE r.suggested_practice_site_id IS NOT NULL AND cs.practice_site_id IS DISTINCT FROM r.suggested_practice_site_id
        UNION ALL
        SELECT format('specimen_collection_events %s: punto %s no es de la sede %s', e.id, e.collection_care_space_id, e.collection_site_id)
          FROM "diagnostics"."specimen_collection_events" e
          JOIN "practice"."care_spaces" cs ON cs.id = e.collection_care_space_id
         WHERE e.collection_site_id IS NOT NULL AND cs.practice_site_id IS DISTINCT FROM e.collection_site_id
        UNION ALL
        SELECT format('imaging_procedure_steps %s: sala %s (tenant %s) ≠ tenant del equipo %s (%s)', s.id, s.scheduled_care_space_id, cs.tenant_id, s.scheduled_equipment_id, du.tenant_id)
          FROM "diagnostics"."imaging_procedure_steps" s
          JOIN "practice"."care_spaces" cs ON cs.id = s.scheduled_care_space_id
          JOIN "diagnostic_units"."diagnostic_equipment" de ON de.id = s.scheduled_equipment_id
          JOIN "diagnostic_units"."diagnostic_unit_sites" dus ON dus.id = de.diagnostic_unit_site_id
          JOIN "diagnostic_units"."diagnostic_units" du ON du.id = dus.diagnostic_unit_id
         WHERE cs.tenant_id IS DISTINCT FROM du.tenant_id
        LIMIT 20
    ) q;
    IF n > 0 THEN
        RAISE EXCEPTION 'Integración F2–F5: % fila(s) incoherentes en puntos de toma / salas de imagen: %', n, detalle;
    END IF;
END $$;

-- ------------------------------------------------------------- A. tenant de los eventos de sala
CREATE OR REPLACE FUNCTION "procedures_perioperative"."operating_room_utilization_events_fill_tenant"() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog, pg_temp AS $fn$
BEGIN
    IF NEW."tenant_id" IS NULL AND NEW."operating_room_id" IS NOT NULL THEN
        SELECT cs."tenant_id" INTO NEW."tenant_id"
          FROM "practice"."care_spaces" cs
         WHERE cs."id" = NEW."operating_room_id";
    END IF;
    -- Si la sala no es visible (otro tenant bajo RLS) queda NULL → 23502 por el NOT NULL;
    -- si el cliente manda otro tenant, la FK compuesta (tenant_id, operating_room_id) → 23503.
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_operating_room_utilization_events_fill_tenant" ON "procedures_perioperative"."operating_room_utilization_events";
CREATE TRIGGER "trg_operating_room_utilization_events_fill_tenant"
    BEFORE INSERT OR UPDATE OF "tenant_id", "operating_room_id" ON "procedures_perioperative"."operating_room_utilization_events"
    FOR EACH ROW EXECUTE FUNCTION "procedures_perioperative"."operating_room_utilization_events_fill_tenant"();

DO $$
DECLARE
    n_upd integer;
    n_sin integer;
BEGIN
    UPDATE "procedures_perioperative"."operating_room_utilization_events" e
       SET tenant_id = cs.tenant_id
      FROM "practice"."care_spaces" cs
     WHERE cs.id = e.operating_room_id AND e.tenant_id IS NULL;
    GET DIAGNOSTICS n_upd = ROW_COUNT;
    SELECT count(*) INTO n_sin FROM "procedures_perioperative"."operating_room_utilization_events" WHERE tenant_id IS NULL;
    IF n_sin > 0 THEN
        RAISE EXCEPTION 'operating_room_utilization_events: % fila(s) sin tenant aun después del backfill (sala inexistente).', n_sin;
    END IF;
    IF n_upd > 0 THEN
        RAISE NOTICE 'operating_room_utilization_events: % fila(s) con tenant completado desde la sala.', n_upd;
    END IF;
END $$;

ALTER TABLE "procedures_perioperative"."operating_room_utilization_events" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- B. FK compuestas
DO $$ BEGIN
    ALTER TABLE "procedures_perioperative"."procedure_cases"
        ADD CONSTRAINT "fk_procedure_cases_tenant_site" FOREIGN KEY ("custodian_tenant_id", "practice_site_id")
        REFERENCES "practice"."practice_sites" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."schedulable_resources"
        ADD CONSTRAINT "fk_schedulable_resources_tenant_practice" FOREIGN KEY ("tenant_id", "practice_id")
        REFERENCES "practice"."practices" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_tenant_parent" FOREIGN KEY ("tenant_id", "parent_cost_center_id")
        REFERENCES "accounting"."cost_centers" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_procedure_cases_tenant_site" ON "procedures_perioperative"."procedure_cases" ("custodian_tenant_id", "practice_site_id");
CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_tenant_practice" ON "scheduling"."schedulable_resources" ("tenant_id", "practice_id");
CREATE INDEX IF NOT EXISTS "ix_cost_centers_tenant_parent" ON "accounting"."cost_centers" ("tenant_id", "parent_cost_center_id");

-- ------------------------------------------------------------- C. puntos de toma y sala de imagen
-- Las dos funciones de punto de toma son SECURITY DEFINER a propósito: el punto puede ser de otro
-- tenant (el ejecutor), y bajo RLS el tenant que escribe la orden no ve ese espacio; con
-- INVOKER la orden a un ejecutor externo se rechazaría siempre. Sólo leen practice_site_id de un
-- id dado (lo mismo que ya revela la FK simple), con search_path fijo, y no escriben otra tabla.
-- La de la sala de imagen es INVOKER: quien programa el paso es la unidad dueña del equipo y la
-- sala tiene que ser suya; si no la ve, no es suya.
CREATE OR REPLACE FUNCTION "clinical"."service_requests_assert_collection_point"() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $fn$
DECLARE
    sede uuid;
BEGIN
    IF NEW."suggested_care_space_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT cs."practice_site_id" INTO sede FROM "practice"."care_spaces" cs WHERE cs."id" = NEW."suggested_care_space_id";
    IF sede IS NULL THEN
        RAISE EXCEPTION 'service_requests.suggested_care_space_id: el punto de toma no existe'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    IF NEW."suggested_practice_site_id" IS NULL THEN
        NEW."suggested_practice_site_id" := sede;
    ELSIF NEW."suggested_practice_site_id" <> sede THEN
        RAISE EXCEPTION 'service_requests.suggested_care_space_id: el punto de toma no es de la sede sugerida'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_service_requests_collection_point" ON "clinical"."service_requests";
CREATE TRIGGER "trg_service_requests_collection_point"
    BEFORE INSERT OR UPDATE OF "suggested_care_space_id", "suggested_practice_site_id" ON "clinical"."service_requests"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."service_requests_assert_collection_point"();

CREATE OR REPLACE FUNCTION "diagnostics"."specimen_collection_events_assert_collection_point"() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $fn$
DECLARE
    sede uuid;
BEGIN
    IF NEW."collection_care_space_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT cs."practice_site_id" INTO sede FROM "practice"."care_spaces" cs WHERE cs."id" = NEW."collection_care_space_id";
    IF sede IS NULL THEN
        RAISE EXCEPTION 'specimen_collection_events.collection_care_space_id: el punto de toma no existe'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    IF NEW."collection_site_id" IS NULL THEN
        NEW."collection_site_id" := sede;
    ELSIF NEW."collection_site_id" <> sede THEN
        RAISE EXCEPTION 'specimen_collection_events.collection_care_space_id: el punto de toma no es de la sede de la toma'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_specimen_collection_events_collection_point" ON "diagnostics"."specimen_collection_events";
CREATE TRIGGER "trg_specimen_collection_events_collection_point"
    BEFORE INSERT OR UPDATE OF "collection_care_space_id", "collection_site_id" ON "diagnostics"."specimen_collection_events"
    FOR EACH ROW EXECUTE FUNCTION "diagnostics"."specimen_collection_events_assert_collection_point"();

CREATE OR REPLACE FUNCTION "diagnostics"."imaging_procedure_steps_assert_room_tenant"() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog, pg_temp AS $fn$
DECLARE
    t_equipo uuid;
    t_sala   uuid;
BEGIN
    IF NEW."scheduled_care_space_id" IS NULL OR NEW."scheduled_equipment_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT du."tenant_id" INTO t_equipo
      FROM "diagnostic_units"."diagnostic_equipment" de
      JOIN "diagnostic_units"."diagnostic_unit_sites" dus ON dus."id" = de."diagnostic_unit_site_id"
      JOIN "diagnostic_units"."diagnostic_units" du ON du."id" = dus."diagnostic_unit_id"
     WHERE de."id" = NEW."scheduled_equipment_id";
    SELECT cs."tenant_id" INTO t_sala FROM "practice"."care_spaces" cs WHERE cs."id" = NEW."scheduled_care_space_id";
    IF t_equipo IS NULL OR t_sala IS DISTINCT FROM t_equipo THEN
        RAISE EXCEPTION 'imaging_procedure_steps.scheduled_care_space_id: la sala no existe en el tenant de la unidad diagnóstica del equipo'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_imaging_procedure_steps_room_tenant" ON "diagnostics"."imaging_procedure_steps";
CREATE TRIGGER "trg_imaging_procedure_steps_room_tenant"
    BEFORE INSERT OR UPDATE OF "scheduled_care_space_id", "scheduled_equipment_id" ON "diagnostics"."imaging_procedure_steps"
    FOR EACH ROW EXECUTE FUNCTION "diagnostics"."imaging_procedure_steps_assert_room_tenant"();

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_fk  integer;
    n_trg integer;
    nn    boolean;
BEGIN
    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_procedure_cases_tenant_site', 'fk_schedulable_resources_tenant_practice', 'fk_cost_centers_tenant_parent');
    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgenabled <> 'D'
       AND tgname IN ('trg_operating_room_utilization_events_fill_tenant', 'trg_service_requests_collection_point',
                      'trg_specimen_collection_events_collection_point', 'trg_imaging_procedure_steps_room_tenant');
    SELECT attnotnull INTO nn FROM pg_attribute
     WHERE attrelid = 'procedures_perioperative.operating_room_utilization_events'::regclass AND attname = 'tenant_id';
    IF n_fk <> 3 OR n_trg <> 4 OR NOT nn THEN
        RAISE EXCEPTION 'Integración F2–F5 incompleta: fk=% (3), triggers=% (4), tenant NOT NULL=%', n_fk, n_trg, nn;
    END IF;
    RAISE NOTICE 'Integración F2–F5 aplicada: 3 FK compuestas, 4 triggers, operating_room_utilization_events.tenant_id NOT NULL.';
END $$;

COMMIT;
