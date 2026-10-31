-- Verificación (B7a) de dos pendientes del piloto:
--   A  el administrador del hospital de 04 es SECURITY_ADMIN (si no, las rutas /org/* de gobierno y de seguridad dan 403 ROLE_INSUFFICIENT), con
--      o sin 07, y 04 + 07 no le duplican la fila del rol
--   B  D-03 (compuerta de ingreso): los vínculos de 04 (Ana, Lucía, Marcos, Rosa) están COMPLETOS (onboarding_completed_at = created_at), así la política
--      no los corta con ONBOARDING_INCOMPLETE aunque la organización tenga `onboardingRequired` y se hayan cargado después de `onboardingRequiredSince`
--   C  (solo si 07 está cargado) la semilla distingue: Mario, Sofía, Ricardo y Pablo completos; Nora INCOMPLETA (su caso de ingreso sigue abierto)
--   D  el parche v4278 (sección 7b) marca como completos los vínculos EXISTENTES: se simula el estado anterior al parche (vínculos de 04 con la fecha en NULL, y un
--      vínculo «en curso» con caso de ingreso abierto), se RE-EJECUTA el parche y se comprueba que los existentes quedan completos con `created_at` y el
--      que tiene caso abierto NO se completa de rebote; volver a correr el parche no cambia nada más
--
-- A-C solo leen. D re-ejecuta el parche (idempotente, es una operación soportada) y deja la base como estaba: usar en bases de demostración.
-- Uso (desde la raíz del repo del modelo):
--   psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/11-verifica-onboarding-y-admin.sql
--   (otra ruta del parche:  -v patch=/ruta/2026-10-31_v4278_gobierno_de_accesos.sql  -v patch73=/ruta/2026-10-31_v4279_revision_seguridad_gobierno.sql)
-- Requiere 04 y el parche v4278; D crea en una transacción propia un vínculo auxiliar con un caso de ingreso abierto y lo borra al final.

\set ON_ERROR_STOP on
\if :{?patch}
\else
  \set patch 'SQL/patches/2026-10-31_v4278_gobierno_de_accesos.sql'
\endif
\if :{?patch73}
\else
  \set patch73 'SQL/patches/2026-10-31_v4279_revision_seguridad_gobierno.sql'
\endif

-- ------------------------------------------------------------------ A, B, C (solo lectura)
BEGIN;
DO $abc$
DECLARE
    admin_user constant uuid := 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810';
    n integer; bad text;
BEGIN
    -- A
    SELECT count(*) INTO n
      FROM iam.user_global_roles g JOIN terminology.catalog_concepts c ON c.id = g.role_concept_id
     WHERE g.user_id = admin_user AND c.code = 'SECURITY_ADMIN' AND g.state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';
    IF n <> 1 THEN RAISE EXCEPTION 'A FALLÓ: el administrador del hospital debe tener exactamente 1 rol SECURITY_ADMIN activo y tiene %', n; END IF;
    SELECT count(*) INTO n
      FROM iam.user_global_roles g JOIN terminology.catalog_concepts c ON c.id = g.role_concept_id
     WHERE g.user_id = admin_user AND c.code = 'USER' AND g.state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';
    IF n <> 1 THEN RAISE EXCEPTION 'A FALLÓ: el administrador del hospital conserva su rol base USER (1 fila) y tiene %', n; END IF;

    -- B
    SELECT string_agg(u.display_name, ', ' ORDER BY u.display_name) INTO bad
      FROM delegated_access.organization_user_assignments a
      JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
      JOIN iam.users u ON u.id = m.user_id
     WHERE a.id IN ('9f1761b6-e456-5a99-bf11-d14b05077d4f', 'f9e96f37-5a9a-5ccb-aaea-21b880985301',
                    'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', 'fa601b88-ccf6-5360-aea4-52a889a0d5a7')
       AND (a.onboarding_completed_at IS NULL OR a.onboarding_completed_at <> a.created_at);
    IF bad IS NOT NULL THEN RAISE EXCEPTION 'B FALLÓ: vínculos de 04 que no quedaron completos (onboarding_completed_at = created_at): %', bad; END IF;
    SELECT count(*) INTO n FROM delegated_access.organization_user_assignments
     WHERE id IN ('9f1761b6-e456-5a99-bf11-d14b05077d4f', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', 'fa601b88-ccf6-5360-aea4-52a889a0d5a7');
    IF n <> 4 THEN RAISE EXCEPTION 'B FALLÓ: se esperaban los 4 vínculos de 04 y hay %', n; END IF;

    -- C
    IF EXISTS (SELECT 1 FROM directory.tenants WHERE id = '830e47e1-8e82-50ff-99c0-bfed0a7971a4')
       AND EXISTS (SELECT 1 FROM iam.users WHERE display_name = 'Nora Villarroel') THEN
        SELECT string_agg(u.display_name || CASE WHEN a.onboarding_completed_at IS NULL THEN ' (incompleto)' ELSE ' (completo)' END, ', ' ORDER BY u.display_name) INTO bad
          FROM delegated_access.organization_user_assignments a
          JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
          JOIN iam.users u ON u.id = m.user_id
         WHERE (u.display_name IN ('Mario Salvatierra', 'Sofía Camacho', 'Ricardo Terceros', 'Pablo Mamani') AND a.onboarding_completed_at IS NULL)
            OR (u.display_name = 'Nora Villarroel' AND a.onboarding_completed_at IS NOT NULL);
        IF bad IS NOT NULL THEN RAISE EXCEPTION 'C FALLÓ: la semilla de 07 debía dejar completos a Mario, Sofía, Ricardo y Pablo e incompleta a Nora: %', bad; END IF;
    END IF;
    RAISE NOTICE 'OK (A, B, C) · el administrador es SECURITY_ADMIN (1 fila) y los 4 vínculos de 04 están completos (= created_at); 07 deja a Nora incompleta';
END
$abc$;
ROLLBACK;

-- ------------------------------------------------------------------ D: el parche v4278 completa los vínculos existentes
-- Estado «anterior al parche»: los 4 vínculos de 04 sin fecha, más un vínculo auxiliar (copia de la membresía de Marcos con otro rol) CON caso de ingreso abierto.
BEGIN;
SELECT set_config('app.system_context', 'true', true);   -- por si la base usa RLS y quien corre esto es el dueño (FORCE)
UPDATE delegated_access.organization_user_assignments SET onboarding_completed_at = NULL
 WHERE id IN ('9f1761b6-e456-5a99-bf11-d14b05077d4f', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', 'fa601b88-ccf6-5360-aea4-52a889a0d5a7');
-- vínculo auxiliar «en curso»: revocado para no chocar con el único parcial de vínculo activo, con la fecha en NULL y su caso de ingreso abierto
INSERT INTO delegated_access.organization_user_assignments (id, tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, valid_from, status_concept_id, created_at, updated_at, row_version, role_template_id)
SELECT '5a0d0b11-0000-4000-8000-000000000001', tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, now(), '8d56de1d-f25e-54eb-bc54-3ab2fbc70249', now(), now(), 1, role_template_id
  FROM delegated_access.organization_user_assignments WHERE id = 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6';
INSERT INTO delegated_access.lifecycle_cases (id, tenant_id, organization_user_assignment_id, subject_user_id, kind_concept_id, status_concept_id, opened_at, checklist_json, created_at, updated_at, row_version)
SELECT '5a0d0b11-0000-4000-8000-000000000002', m.tenant_id, '5a0d0b11-0000-4000-8000-000000000001', m.user_id,
       'c2a9a59d-c88c-5e87-9065-1e0e068c479d',                                  -- delegated_access:LIFECYCLE_JOINER
       (SELECT id FROM terminology.catalog_concepts WHERE code = 'delegated_access:LIFECYCLE_OPEN' ORDER BY id LIMIT 1),
       now(), '[]'::jsonb, now(), now(), 1
  FROM delegated_access.organization_user_assignments a JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
 WHERE a.id = '5a0d0b11-0000-4000-8000-000000000001';
COMMIT;

\echo -- D: re-ejecutando el parche v4278 (:patch)
\i :patch
-- v4.2.79: volver a correr el v4278 restituye support_tenant_consistency y support_access_allowed anteriores; el v4279 las vuelve a dejar completas.
\echo -- D2: re-ejecutando el parche v4279 (:patch73)
\i :patch73

BEGIN;
SELECT set_config('app.system_context', 'true', true);
DO $d$
DECLARE bad text; aux timestamptz; n integer;
BEGIN
    SELECT string_agg(u.display_name, ', ' ORDER BY u.display_name) INTO bad
      FROM delegated_access.organization_user_assignments a
      JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
      JOIN iam.users u ON u.id = m.user_id
     WHERE a.id IN ('9f1761b6-e456-5a99-bf11-d14b05077d4f', 'f9e96f37-5a9a-5ccb-aaea-21b880985301',
                    'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', 'fa601b88-ccf6-5360-aea4-52a889a0d5a7')
       AND (a.onboarding_completed_at IS NULL OR a.onboarding_completed_at <> a.created_at);
    IF bad IS NOT NULL THEN RAISE EXCEPTION 'D FALLÓ: el parche no completó (con created_at) a: %', bad; END IF;
    SELECT onboarding_completed_at INTO aux FROM delegated_access.organization_user_assignments WHERE id = '5a0d0b11-0000-4000-8000-000000000001';
    IF aux IS NOT NULL THEN RAISE EXCEPTION 'D FALLÓ: un vínculo con caso de ingreso abierto NO debe completarse de rebote (quedó en %)', aux; END IF;
    -- Nora (07) también tiene su caso abierto: sigue incompleta si 07 está cargado
    SELECT count(*) INTO n FROM delegated_access.organization_user_assignments a
      JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id JOIN iam.users u ON u.id = m.user_id
     WHERE u.display_name = 'Nora Villarroel' AND a.onboarding_completed_at IS NOT NULL;
    IF n <> 0 THEN RAISE EXCEPTION 'D FALLÓ: Nora Villarroel (caso de ingreso abierto) fue completada por el parche'; END IF;
    RAISE NOTICE 'OK (D) · el parche v4278 completó los vínculos existentes (= created_at) y no tocó el que tenía su caso de ingreso abierto';
END
$d$;
-- limpieza del vínculo y el caso auxiliares (el parche ya corrió: la base queda como estaba)
DELETE FROM delegated_access.lifecycle_cases WHERE id = '5a0d0b11-0000-4000-8000-000000000002';
DELETE FROM delegated_access.organization_user_assignments WHERE id = '5a0d0b11-0000-4000-8000-000000000001';
COMMIT;
