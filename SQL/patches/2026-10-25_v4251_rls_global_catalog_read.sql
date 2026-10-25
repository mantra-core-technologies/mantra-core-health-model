-- ============================================================================
-- SALUD · patch v4.2.51 (RLS · lectura de los catálogos globales, tenant_id NULL)
-- Fecha: 2026-10-25
-- Idempotente (DROP POLICY IF EXISTS antes de crear). Sin DDL de columnas ni
-- backfill. Se aplica DESPUÉS de `2026-08-05_tenant_rls.sql` (orden alfabético
-- de `patches/`, que es también cronológico).
--
-- Contexto: `2026-08-05_tenant_rls.sql` crea en cada tabla con `tenant_id` una
-- sola política, `tenant_isolation`, que compara `tenant_id` contra el tenant de
-- la sesión. Una fila con `tenant_id` NULL no es igual a nada, así que con
-- `RLS_ENFORCE=true` los catálogos GLOBALES —sembrados sin tenant porque valen
-- para todos— quedan invisibles para el rol de aplicación. Reportado en la base
-- de test del VPS (sesión «resiliencia de despliegues», 2026-10-25):
-- `system_context.dynamic_enum_definitions` tiene 82 filas con tenant NULL y
-- `/system-context/dynamic-enums` responde 404. Reproducido en la base local:
-- como `mantra_app` con tenant fijado, 0 de 126 filas visibles.
--
-- QUÉ ABRE, y qué no:
--   - Sólo SELECT (`FOR SELECT`). Las políticas permisivas de Postgres se
--     combinan con OR por comando: un tenant LEE su fila y las globales; para
--     UPDATE/DELETE/INSERT sigue rigiendo sólo `tenant_isolation`, así que nadie
--     modifica ni borra un catálogo global desde un tenant (eso sigue siendo del
--     contexto SYSTEM). No se toca `tenant_isolation`.
--   - Sólo las tablas de la lista, NO toda tabla con `tenant_id` nullable. Medido
--     en la base local (86 tablas con `tenant_id` nullable, 7 con filas NULL):
--       incluidas (catálogos que valen para todos los tenants)
--         system_context.dynamic_enum_definitions   126 filas NULL
--         authz.roles                                37
--         chart.specialty_chart_templates            28
--         forms.field_assignments                   847
--         forms.extension_target_policies             1
--       EXCLUIDAS a propósito
--         identity_assurance.identity_verification_cases (16): datos personales
--           de verificación de identidad; abrirlos expondría PII a todo tenant.
--         integration_contracts.integration_contracts (26): contratos de la
--           plataforma con proveedores externos; ninguna pantalla de tenant los lee.
--     Una política general «OR tenant_id IS NULL» habría abierto también las
--     filas sin tenant de `audit`, `consent`, `messaging`, `iam`…: por eso es una
--     lista explícita. Agregar un catálogo = sumar una línea y justificarla.
--   - Una tabla de la lista que no exista en la base se informa y se salta.
--
-- DELTAS ESPERADOS sobre la base viva:
--   políticas `global_catalog_read`  +5 (0 → 5)
-- ============================================================================

BEGIN;

DO $$
DECLARE
  t text;
  globales text[] := ARRAY[
    'system_context.dynamic_enum_definitions',
    'authz.roles',
    'chart.specialty_chart_templates',
    'forms.field_assignments',
    'forms.extension_target_policies'
  ];
BEGIN
  FOREACH t IN ARRAY globales LOOP
    IF to_regclass(t) IS NULL THEN
      RAISE WARNING 'RLS global_catalog_read: % no existe en esta base, se salta', t;
      CONTINUE;
    END IF;
    EXECUTE format('DROP POLICY IF EXISTS global_catalog_read ON %s', t);
    EXECUTE format(
      'CREATE POLICY global_catalog_read ON %s FOR SELECT USING (tenant_id IS NULL)',
      t
    );
  END LOOP;
END $$;

COMMIT;

-- Verificación (como rol de aplicación, con un tenant fijado):
--   BEGIN; SET LOCAL ROLE mantra_app;
--   SELECT set_config('app.current_tenant_id', '<tenant>', true);
--   SELECT count(*) FROM system_context.dynamic_enum_definitions WHERE tenant_id IS NULL;  -- > 0
--   SELECT count(*) FROM identity_assurance.identity_verification_cases WHERE tenant_id IS NULL;  -- 0
--   UPDATE authz.roles SET name = name WHERE tenant_id IS NULL;  -- UPDATE 0
--   ROLLBACK;
