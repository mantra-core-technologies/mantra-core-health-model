-- ============================================================================
-- SALUD · patch v4.2.81 (franja F1b del portal de observabilidad: idempotencia de los eventos anónimos) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_v4281_patches.py a partir del DDL que ya emite gen_ddl.py (SQL/28_telemetry/04_indexes.sql): los dos
-- CREATE INDEX no están escritos a mano. Idempotente (CREATE INDEX IF NOT EXISTS; la deduplicación no hace nada si no hay repetidos).
-- UNA sola transacción; se puede volver a correr.
--
-- Contexto: hallazgo 2 (Alta) de evidencia-f0/REVISION-codigo-api.md del plan docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo
-- del front): `telemetry.user_activity_events` no tenía índice por clave de idempotencia, de modo que dos lotes concurrentes con la misma
-- clave pasaban a la vez el «buscar y luego insertar» de la API. En el evento anónimo (propósito PLATFORM_USAGE_AGGREGATE) `user_id` es
-- NULL y `event_idempotency_key` guarda un HMAC de (persona, organización, clave del cliente).
--
-- QUE AGREGA
--   ux_user_activity_events_anonymous_idempotency  UNIQUE (COALESCE(tenant_id, uuid cero), event_idempotency_key) WHERE user_id IS NULL
--       El tenant va envuelto en COALESCE a propósito: `tenant_id` admite NULL y un índice único trata cada NULL como distinto, así que un evento
--       anónimo sin organización nunca chocaría. La API debe inferir el conflicto con la MISMA expresión:
--         ON CONFLICT ((COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid)), event_idempotency_key) WHERE user_id IS NULL DO NOTHING
--       o capturar SQLSTATE 23505 y contar el evento como `skipped`.
--   ix_user_activity_events_user_idempotency       (user_id, event_idempotency_key) WHERE user_id IS NOT NULL   (búsqueda, NO único)
--
-- DEDUPLICACION PREVIA (determinista): si la base ya tiene eventos anónimos repetidos (misma organización y misma clave), se conserva el
-- MAS ANTIGUO (created_at, luego id) y se eliminan los demás. Lo que colgaba de un repetido no se pierde:
--   session_journeys.entry_event_id / exit_event_id y conversion_events.completion_event_id  -> se reapuntan al conservado
--   web_vitals.user_activity_event_id                                                         -> se reapunta al conservado
--   user_activity_event_properties                                                            -> se reapuntan las propiedades que el conservado no
--       tenga (por property_name) y se borran las que ya tenía (son copias del mismo reintento)
-- La cantidad eliminada se informa con RAISE NOTICE. Corre con `app.system_context = 'true'` (local a la transacción): la tabla tiene RLS
-- forzada y un dueño sin BYPASSRLS no vería las filas de ninguna organización.
--
-- BLOQUEO: crear un índice único toma un lock que frena las escrituras de la tabla mientras se construye. `SET LOCAL lock_timeout` hace que
-- el parche falle rápido (y se pueda reintentar) en vez de esperar detrás de una transacción larga y encolar a todas las demás. En una tabla
-- grande, correr ANTES, fuera de transacción, los dos `CREATE [UNIQUE] INDEX CONCURRENTLY IF NOT EXISTS` de la sección 2 (con la
-- deduplicación de la sección 1 ya hecha a mano): este parche los encuentra y no los reconstruye.
--
-- REVERSA (solo agrega índices; lo deduplicado no se recupera):
--   DROP INDEX IF EXISTS "telemetry"."ux_user_activity_events_anonymous_idempotency", "telemetry"."ix_user_activity_events_user_idempotency";
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '15s';

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regclass('telemetry.user_activity_events') IS NULL THEN
        RAISE EXCEPTION 'falta telemetry.user_activity_events: aplicar antes apply_all.sql';
    END IF;
END $$;

-- ---- 1. deduplicacion determinista de los eventos anonimos repetidos (antes de crear el indice unico) ----
DO $$
DECLARE
    v_dups bigint;
    v_props_moved bigint := 0;
    v_props_dropped bigint := 0;
    v_n bigint;
BEGIN
    PERFORM set_config('app.system_context', 'true', true);   -- local a la transaccion (la tabla tiene RLS forzada)

    CREATE TEMP TABLE _uae_dups ON COMMIT DROP AS
    SELECT r.id AS dup_id, r.keeper_id
      FROM (SELECT e.id,
                   first_value(e.id) OVER w AS keeper_id,
                   row_number() OVER w AS rn
              FROM telemetry.user_activity_events e
             WHERE e.user_id IS NULL
            WINDOW w AS (PARTITION BY COALESCE(e.tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), e.event_idempotency_key
                         ORDER BY e.created_at, e.id)) r
     WHERE r.rn > 1;
    CREATE INDEX ON _uae_dups (dup_id);
    SELECT count(*) INTO v_dups FROM _uae_dups;

    IF v_dups > 0 THEN
        -- un solo UPDATE por fila (dos sobre la misma fila obligarian a PostgreSQL a revalidar todas sus FK)
        UPDATE telemetry.session_journeys j
           SET entry_event_id = COALESCE((SELECT d.keeper_id FROM _uae_dups d WHERE d.dup_id = j.entry_event_id), j.entry_event_id),
               exit_event_id = COALESCE((SELECT d.keeper_id FROM _uae_dups d WHERE d.dup_id = j.exit_event_id), j.exit_event_id)
         WHERE j.entry_event_id IN (SELECT dup_id FROM _uae_dups) OR j.exit_event_id IN (SELECT dup_id FROM _uae_dups);
        UPDATE telemetry.conversion_events c SET completion_event_id = d.keeper_id FROM _uae_dups d WHERE c.completion_event_id = d.dup_id;
        UPDATE telemetry.web_vitals w SET user_activity_event_id = d.keeper_id FROM _uae_dups d WHERE w.user_activity_event_id = d.dup_id;

        UPDATE telemetry.user_activity_event_properties p SET user_activity_event_id = d.keeper_id
          FROM _uae_dups d
         WHERE p.user_activity_event_id = d.dup_id
           AND NOT EXISTS (SELECT 1 FROM telemetry.user_activity_event_properties k
                            WHERE k.user_activity_event_id = d.keeper_id AND k.property_name = p.property_name);
        GET DIAGNOSTICS v_props_moved = ROW_COUNT;
        DELETE FROM telemetry.user_activity_event_properties p USING _uae_dups d WHERE p.user_activity_event_id = d.dup_id;
        GET DIAGNOSTICS v_props_dropped = ROW_COUNT;

        DELETE FROM telemetry.user_activity_events e USING _uae_dups d WHERE e.id = d.dup_id;
        GET DIAGNOSTICS v_n = ROW_COUNT;
        IF v_n <> v_dups THEN
            RAISE EXCEPTION 'v4281: se esperaba eliminar % eventos anonimos repetidos y se eliminaron %', v_dups, v_n;
        END IF;
    END IF;
    RAISE NOTICE 'v4281: % evento(s) anonimo(s) repetido(s) eliminado(s) (propiedades reapuntadas: %, propiedades repetidas eliminadas: %)',
        v_dups, v_props_moved, v_props_dropped;
END $$;

-- ---- 2. indices (SQL/28_telemetry/04_indexes.sql, generados desde el .puml) ----
CREATE UNIQUE INDEX IF NOT EXISTS "ux_user_activity_events_anonymous_idempotency" ON "telemetry"."user_activity_events" (COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), "event_idempotency_key") WHERE user_id IS NULL;

CREATE INDEX IF NOT EXISTS "ix_user_activity_events_user_idempotency" ON "telemetry"."user_activity_events" ("user_id", "event_idempotency_key") WHERE user_id IS NOT NULL;

-- ---- 3. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n
      FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE s.nspname = 'telemetry' AND c.relname = 'ux_user_activity_events_anonymous_idempotency'
       AND i.indisunique AND i.indisvalid AND i.indpred IS NOT NULL;
    IF n <> 1 THEN RAISE EXCEPTION 'v4281: el indice unico parcial de eventos anonimos no existe, no es unico o no es valido'; END IF;
    SELECT count(*) INTO n
      FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE s.nspname = 'telemetry' AND c.relname = 'ix_user_activity_events_user_idempotency'
       AND NOT i.indisunique AND i.indisvalid AND i.indpred IS NOT NULL;
    IF n <> 1 THEN RAISE EXCEPTION 'v4281: falta el indice de busqueda de eventos identificados'; END IF;
END $$;

COMMIT;
