-- ============================================================================
-- SALUD · patch (RLS · farmacias publicadas para el paciente: comparar por id)
-- Fecha: 2026-11-04
-- Idempotente (DROP POLICY IF EXISTS antes de crear). Sin DDL de columnas ni
-- backfill. Se aplica DESPUÉS de
-- `2026-11-03_v4286_farmacias_mercado_lectura_paciente.sql` (orden alfabético
-- de `patches/`) y reemplaza la política que crea ese patch.
--
-- Por qué: `pharmacies_marketplace_read` (v4.2.86) busca los estados por
-- `terminology.catalog_concepts.code = 'PHARM_PHARMACY_ACTIVE'` y
-- `'PHARM_VERIFICATION_VERIFIED'`. Pero los conceptos de módulo se guardan con
-- su CLAVE como código (`src/common/seed/catalog-concept-definitions.ts`:
-- `code: seed.key`): en la base son `pharmacy:PHARMACY_ACTIVE` y
-- `pharmacy:VERIFICATION_VERIFIED`, y los `PHARM_*` no existen. La política no
-- dejaba pasar ninguna fila: el paciente no veía ninguna farmacia publicada de
-- otra organización.
--
-- Arreglo: comparar contra el id del concepto, no contra su texto. Los ids son
-- UUIDv5 deterministas de la clave (`deterministicId` en
-- `src/common/constants/concepts.ts`, el mismo valor que `PHARM.*` en
-- `src/modules/pharmacy/pharmacy.concepts.ts`):
--   pharmacy:PHARMACY_ACTIVE        → 7e2446c4-6707-5455-8168-87b28bcfd292
--   pharmacy:VERIFICATION_VERIFIED  → 25f8508d-c0eb-5c18-8c0d-7fd4268c8b3c
-- Escribirlos acá no los deja desincronizados en silencio:
-- `src/modules/pharmacy/pharmacy-marketplace-policy.contract.spec.ts` falla si
-- dejan de coincidir con `PHARM.*`.
--
-- Lo que abre no cambia respecto de v4.2.86: sólo SELECT, sólo
-- `pharmacy.pharmacies`, sólo las farmacias activas Y verificadas, y sólo con
-- `app.marketplace_viewer = 'true'` (lo fija `TenantContextInterceptor` para un
-- paciente). Para INSERT/UPDATE/DELETE sigue rigiendo únicamente
-- `tenant_isolation`.
--
-- DELTAS ESPERADOS sobre la base viva:
--   políticas `pharmacies_marketplace_read` en pharmacy.pharmacies  1 → 1
--   (misma política, otra condición)
-- ============================================================================

BEGIN;

DO $$
BEGIN
  IF to_regclass('pharmacy.pharmacies') IS NULL THEN
    RAISE EXCEPTION 'farmacias por id: falta pharmacy.pharmacies; aplicar antes el modelo base';
  END IF;
END $$;

DROP POLICY IF EXISTS pharmacies_marketplace_read ON pharmacy.pharmacies;

CREATE POLICY pharmacies_marketplace_read ON pharmacy.pharmacies
  FOR SELECT
  USING (
    current_setting('app.marketplace_viewer', true) = 'true'
    -- pharmacy:PHARMACY_ACTIVE
    AND status_concept_id = '7e2446c4-6707-5455-8168-87b28bcfd292'::uuid
    -- pharmacy:VERIFICATION_VERIFIED
    AND verification_status_concept_id = '25f8508d-c0eb-5c18-8c0d-7fd4268c8b3c'::uuid
  );

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'pharmacy'
      AND tablename  = 'pharmacies'
      AND policyname = 'pharmacies_marketplace_read'
  ) THEN
    RAISE EXCEPTION 'farmacias por id: la política pharmacies_marketplace_read no quedó creada';
  END IF;
  -- Aviso, no error: en una base nueva los conceptos llegan después, con el seed.
  IF NOT EXISTS (
    SELECT 1 FROM terminology.catalog_concepts
    WHERE id IN ('7e2446c4-6707-5455-8168-87b28bcfd292'::uuid,
                 '25f8508d-c0eb-5c18-8c0d-7fd4268c8b3c'::uuid)
  ) THEN
    RAISE NOTICE 'farmacias por id: los conceptos de estado de farmacia todavía no están sembrados';
  END IF;
END $$;

COMMIT;
