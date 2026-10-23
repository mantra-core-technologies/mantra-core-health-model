-- ============================================================================
-- SALUD · patch v4.2.36 (RLS · lectura de la orden por el laboratorio ejecutante)
-- Fecha: 2026-09-26
-- Idempotente (DROP POLICY IF EXISTS antes de crear). UNA sola pasada. Sin DDL
-- de columnas ni backfill.
--
-- Contexto: `2026-09-19_v4219_custodian_tenant_rls.sql` aísla
-- `clinical.service_requests` por `custodian_tenant_id`: la orden sólo la ve la
-- organización que la emitió. Pero la orden de laboratorio tiene un SEGUNDO
-- tenant legítimo, el ejecutante (`performer_tenant_id`): el laboratorio al que
-- se derivó. `ObservationsService` ya lo reconoce como custodio válido al
-- registrar un resultado contra la orden, y la bandeja de recepción
-- (`POST /diagnostics/service-requests/inbox`) lee exactamente eso: órdenes de
-- OTRA organización dirigidas al laboratorio del contexto.
--
-- Con `RLS_ENFORCE=true` y sin esta política, esa lectura devuelve cero filas
-- —fail-closed, sin error—: la bandeja del laboratorio quedaría vacía para
-- siempre. Hoy `RLS_ENFORCE` es `false` por defecto (docker-compose, .env), así
-- que el efecto es latente; este patch lo cierra antes de que se encienda.
--
-- QUÉ ABRE, y qué no:
--   - Sólo SELECT (`FOR SELECT`). El laboratorio LEE la orden; escribirla sigue
--     siendo del custodio (`custodian_tenant_isolation`, intacta).
--   - Sólo las filas cuyo `performer_tenant_id` es el tenant de la sesión. Las
--     políticas permisivas de Postgres se combinan con OR: la orden la ven su
--     custodio (política existente) y su ejecutante (ésta), nadie más.
--   - Mismo GUC y mismo escape `app.system_context` que la política original.
--
-- No verificado contra una base viva en esta rama (la máquina de desarrollo no
-- levanta Postgres para agentes): aplicar primero en un entorno de prueba y
-- correr la verificación del final.
--
-- DELTAS ESPERADOS sobre la base viva:
--   políticas `service_requests_performer_read` en clinical.service_requests  +1 (0 → 1)
-- ============================================================================

BEGIN;

DROP POLICY IF EXISTS service_requests_performer_read ON clinical.service_requests;

CREATE POLICY service_requests_performer_read ON clinical.service_requests
  FOR SELECT
  USING (
    performer_tenant_id = NULLIF(
      current_setting('app.current_tenant_id', true),
      ''
    )::uuid
    OR current_setting('app.system_context', true) = 'true'
  );

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'clinical'
      AND tablename  = 'service_requests'
      AND policyname = 'service_requests_performer_read'
  ) THEN
    RAISE EXCEPTION 'v4.2.36 incompleto: falta la política service_requests_performer_read';
  END IF;
  RAISE NOTICE 'v4.2.36 aplicado: clinical.service_requests legible por su tenant ejecutante.';
END $$;

COMMIT;
