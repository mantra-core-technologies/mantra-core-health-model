-- ============================================================================
-- SALUD · patch v4.2.26 (RLS · custodia clínica) sobre BD viva
-- Fecha original: 2026-09-19 (API, v4.2.19) · promovido al modelo: 2026-09-26
--
-- PROMOCIÓN AL MODELO (carril M1). Este archivo vivía SOLO en
-- mantra-core-health-api/database/SQL/patches/ con el número v4.2.19, que
-- colisionaba con el patch v4.2.19 del módulo data_catalog (dos parches
-- distintos con el mismo número, en árboles distintos). Se renumera a v4.2.26,
-- continuando la secuencia única del modelo (hasta acá: v4.2.23). Contenido
-- SIN CAMBIOS respecto del original — es un patch procedural (DO $$ … $$) que
-- escanea `information_schema` en tiempo de ejecución, no crea tablas: no tiene
-- .puml propio, igual que su predecesor `2026-08-05_tenant_rls.sql`, que
-- tampoco lo tiene.
-- Idempotente (DROP POLICY IF EXISTS antes de crear; ENABLE/FORCE RLS son
-- operaciones sin efecto si ya estaban puestas). UNA sola pasada.
--
-- Contexto: MCH-002. El patch `2026-08-05_tenant_rls.sql` cierra el aislamiento
-- por tenant, pero su descubrimiento de tablas es literal:
--   WHERE c.column_name = 'tenant_id' AND c.data_type = 'uuid'
-- `custodian_tenant_id` es un nombre distinto, y ese patch no lo toca. Se
-- verificó contra esta base viva (2026-09-19): 28 tablas —el mismo número que
-- reportó la auditoría— tienen `custodian_tenant_id uuid` y NINGUNA tiene
-- además `tenant_id`: quedan sin una sola fila de RLS.
--
-- `custodian_tenant_id` no es lo mismo que `tenant_id`: nombra qué tenant
-- custodia el recurso clínico (quién puede leerlo/escribirlo por defecto), y
-- puede migrar entre tenants por una derivación o transferencia de custodia
-- sin que el recurso cambie de "dueño" en otro sentido. Por eso este patch
-- NO reutiliza la columna `tenant_id` ni renombra nada: crea una política
-- paralela, `custodian_tenant_isolation`, con el mismo criterio fail-closed
-- que la original (mismo GUC de sesión, mismo escape `app.system_context`).
--
-- Este patch es EXPAND puro: no toca `2026-08-05_tenant_rls.sql` (el hallazgo
-- pide explícitamente no editar el parche histórico ya aplicado) ni ninguna
-- columna existente. El descubrimiento es dinámico (igual que el original):
-- una tabla nueva con `custodian_tenant_id uuid` queda cubierta la próxima vez
-- que este patch se re-ejecute, sin tocar el archivo.
--
-- No cubre las 33 columnas *_tenant_id restantes que reportó el inventario
-- (`parent_tenant_id`, `linked_tenant_id`, `issuer_tenant_id`, …): esas son
-- referencias a OTRO tenant (una organización padre, un emisor, un asegurador),
-- no la propiedad de la fila. Aplicarles esta misma política compararía el
-- tenant equivocado y rompería lecturas legítimas cross-tenant que son parte
-- del propio modelo (p. ej. `directory.tenants.parent_tenant_id`). Cada una
-- necesita su propia decisión de dominio; no entran en este patch.
--
-- Verificado contra `mantra_app` (rol de aplicación, sin BYPASSRLS, del patch
-- anterior): ver `test/integration/rls.int-spec.ts`, sección MCH-002.
--
-- DELTAS ESPERADOS sobre la base viva:
--   políticas `custodian_tenant_isolation`   +28 (0 → 28)
--   tablas con RLS habilitado                +28 (las 28 de arriba)
-- ============================================================================

BEGIN;

DO $$
DECLARE
  r record;
  sin_rls text[] := '{}';
  n_tablas int := 0;
  n_politicas int;
BEGIN
  FOR r IN
    SELECT c.table_schema, c.table_name
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema
     AND t.table_name  = c.table_name
     AND t.table_type  = 'BASE TABLE'
    WHERE c.column_name = 'custodian_tenant_id'
      AND c.data_type   = 'uuid'
      AND c.table_schema NOT LIKE 'pg\_%'
      AND c.table_schema NOT IN ('information_schema')
      -- Mismo motivo que en el patch de tenant_id: los chunks/hypertables de
      -- TimescaleDB no admiten ALTER ... ENABLE ROW LEVEL SECURITY.
      AND c.table_schema NOT LIKE '\_timescaledb%'
      AND c.table_schema NOT IN ('timescaledb_information', 'timescaledb_experimental')
  LOOP
    n_tablas := n_tablas + 1;
    BEGIN
      EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.table_schema, r.table_name);
      EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.table_schema, r.table_name);
      EXECUTE format('DROP POLICY IF EXISTS custodian_tenant_isolation ON %I.%I', r.table_schema, r.table_name);
      EXECUTE format($pol$
      CREATE POLICY custodian_tenant_isolation ON %I.%I
        USING (
          custodian_tenant_id = NULLIF(
            current_setting('app.current_tenant_id', true),
            ''
          )::uuid
          OR current_setting('app.system_context', true) = 'true'
        )
        WITH CHECK (
          custodian_tenant_id = NULLIF(
            current_setting('app.current_tenant_id', true),
            ''
          )::uuid
          OR current_setting('app.system_context', true) = 'true'
        )
      $pol$, r.table_schema, r.table_name);
    EXCEPTION WHEN feature_not_supported THEN
      sin_rls := sin_rls || format('%I.%I', r.table_schema, r.table_name);
    END;
  END LOOP;

  IF array_length(sin_rls, 1) > 0 THEN
    RAISE WARNING 'RLS custodia: % tabla(s) con custodian_tenant_id se quedaron SIN aislamiento por fila (limitación de TimescaleDB): %',
      array_length(sin_rls, 1), array_to_string(sin_rls, ', ');
  END IF;

  -- Verificación: cada tabla detectada tiene su política, salvo las anotadas
  -- arriba por limitación del motor. Falla cerrado si algo quedó a medias.
  SELECT count(*) INTO n_politicas
  FROM pg_policies
  WHERE policyname = 'custodian_tenant_isolation';

  IF n_politicas <> n_tablas - coalesce(array_length(sin_rls, 1), 0) THEN
    RAISE EXCEPTION
      'v4.2.19 incompleto: % tabla(s) con custodian_tenant_id, % política(s) creada(s), % sin soporte del motor',
      n_tablas, n_politicas, coalesce(array_length(sin_rls, 1), 0);
  END IF;

  RAISE NOTICE 'v4.2.19 aplicado: % tabla(s) con custodian_tenant_id, % política(s) custodian_tenant_isolation.',
    n_tablas, n_politicas;
END $$;

COMMIT;
