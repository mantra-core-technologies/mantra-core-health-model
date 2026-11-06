-- ============================================================================
-- SALUD · patch v4.2.86 (RLS · lectura acotada de las farmacias publicadas
--                         para el paciente que navega el mercado — FAR-C9 H-01)
-- Fecha: 2026-11-03
-- Idempotente (DROP POLICY IF EXISTS antes de crear). Sin DDL de columnas ni
-- backfill. Se aplica DESPUÉS de `2026-08-05_tenant_rls.sql` (orden alfabético
-- de `patches/`, que es también cronológico).
--
-- Contexto (H-01): `2026-08-05_tenant_rls.sql` crea en `pharmacy.pharmacies`
-- —la única tabla del contexto de farmacia con `tenant_id`— la política
-- `tenant_isolation`. Un paciente de la organización A que pide a una farmacia
-- de la organización B corre con `app.current_tenant_id = A`: la política le
-- oculta la fila de la farmacia y el pedido responde 404 (lo mismo les pasa al
-- buscador y al listado «Mis pedidos»). La aplicación ya trata al paciente como
-- espectador del mercado de todas las organizaciones
-- (`marketplaceTenantScope()`, `TenantContext.marketplaceViewer`); esta política
-- es la mitad que le faltaba a la base.
--
-- QUÉ ABRE, y qué no:
--   - Sólo SELECT (`FOR SELECT`). Las políticas permisivas se combinan con OR
--     por comando: para INSERT/UPDATE/DELETE sigue rigiendo únicamente
--     `tenant_isolation`, así que nadie crea, edita ni borra una farmacia ajena.
--   - Sólo la tabla `pharmacy.pharmacies`. El resto del contexto de farmacia
--     (sedes, productos, precios, reservas, libro) no tiene `tenant_id` y no
--     está bajo RLS; las conexiones de integración, con sus credenciales, viven
--     en `integrations.*` y NO se abren.
--   - Sólo las farmacias publicadas (activas Y verificadas): las mismas que el
--     directorio ya muestra a un paciente. Borradores, pendientes y rechazadas
--     de otra organización siguen sin existir para él.
--   - Sólo cuando la transacción declara `app.marketplace_viewer = 'true'`. Lo
--     fija `TenantContextInterceptor` —dentro de la transacción del request, con
--     `set_config(..., true)`— únicamente para un sujeto con rol PATIENT y sin
--     rol de farmacia ni de plataforma; el cliente no puede enviarlo. Sin ese
--     GUC la política no abre nada: personal, administradores y trabajos de
--     fondo ven exactamente lo mismo que antes, y una consulta que dependiera
--     de RLS para acotar «mis farmacias» no se ensancha.
--   - El rol se resuelve contra el catálogo de conceptos (por código), no con
--     UUID escritos a mano: los ids del seed son deterministas pero derivados,
--     y copiarlos acá los dejaría desincronizados en silencio.
--
-- Fuera de alcance, a propósito: las tablas de mensajería (`messaging.*`) siguen
-- cerradas. El evento `PharmacyOrderSubmitted` ya no se registra con el tenant
-- de la farmacia cuando es distinto del de la sesión (ver
-- `PharmacyOrdersUseCases.create`), así que no hace falta abrir el outbox.
--
-- DELTAS ESPERADOS sobre la base viva:
--   políticas `pharmacies_marketplace_read` en pharmacy.pharmacies  +1 (0 → 1)
-- ============================================================================

BEGIN;

DO $$
BEGIN
  IF to_regclass('pharmacy.pharmacies') IS NULL THEN
    RAISE EXCEPTION 'v4.2.86: falta pharmacy.pharmacies; aplicar antes el modelo base';
  END IF;
END $$;

DROP POLICY IF EXISTS pharmacies_marketplace_read ON pharmacy.pharmacies;

CREATE POLICY pharmacies_marketplace_read ON pharmacy.pharmacies
  FOR SELECT
  USING (
    current_setting('app.marketplace_viewer', true) = 'true'
    AND status_concept_id IN (
      SELECT c.id FROM terminology.catalog_concepts c
       WHERE c.code = 'PHARM_PHARMACY_ACTIVE'
    )
    AND verification_status_concept_id IN (
      SELECT c.id FROM terminology.catalog_concepts c
       WHERE c.code = 'PHARM_VERIFICATION_VERIFIED'
    )
  );

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'pharmacy'
      AND tablename  = 'pharmacies'
      AND policyname = 'pharmacies_marketplace_read'
  ) THEN
    RAISE EXCEPTION 'v4.2.86 incompleto: falta la política pharmacies_marketplace_read';
  END IF;
  RAISE NOTICE 'v4.2.86 aplicado: pharmacy.pharmacies legible (sólo publicadas) por el paciente espectador del mercado.';
END $$;

COMMIT;

-- Verificación (como rol de aplicación, con el tenant de un paciente fijado):
--   BEGIN; SET LOCAL ROLE mantra_app;
--   SELECT set_config('app.current_tenant_id', '<tenant-del-paciente>', true);
--   SELECT count(*) FROM pharmacy.pharmacies WHERE tenant_id <> '<tenant-del-paciente>';  -- 0
--   SELECT set_config('app.marketplace_viewer', 'true', true);
--   SELECT count(*) FROM pharmacy.pharmacies WHERE tenant_id <> '<tenant-del-paciente>';  -- > 0, sólo publicadas
--   UPDATE pharmacy.pharmacies SET trade_name = trade_name
--    WHERE tenant_id <> '<tenant-del-paciente>';                                          -- UPDATE 0
--   ROLLBACK;
