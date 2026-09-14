-- ============================================================================
-- SALUD · patch v4.2.0 (directory.tenant_memberships · membresía asistencial
-- para los vínculos médico–organización ya aprobados)
-- sobre una BD viva
-- Fecha: 2026-08-26
-- Idempotente y re-ejecutable (INSERT ... WHERE NOT EXISTS; segunda corrida = 0 filas)
--
-- NO cambia el esquema: no hay DDL, ni columna nueva, ni tabla nueva. Es un
-- patch de DATOS. El único elemento «nuevo» del modelo es un CONCEPTO
-- (`directory:ROLE_PRACTITIONER`), que es una fila de
-- `terminology.catalog_concepts` y la siembra la propia API al arrancar
-- (`TerminologySeedService`, id determinista). Por eso este patch NO hace falta
-- en un rebuild desde cero: ahí no hay vínculos previos que reparar.
--
-- ============================================================================
-- QUÉ CIERRA
-- ============================================================================
--
-- Aprobar un vínculo médico–organización no habilitaba nada. El circuito
-- funcionaba de punta a punta —el médico pedía, la organización lo veía en su
-- bandeja y aprobaba con un 204— y el médico seguía sin poder publicar agenda
-- ahí: recibía 403.
--
-- La causa no era la regla del vínculo sino que la petición nunca llegaba hasta
-- ella. El aislamiento multi-tenant se resuelve por MEMBRESÍA: el claim
-- `tenants` del token se arma leyendo `directory.tenant_memberships`
-- (`iam-auth.service.ts`, `loadActiveTenantIds`), y `TenantContextInterceptor`
-- rechaza toda petición que nombre un tenant que no esté ahí. Aprobar un
-- vínculo no escribía ninguna membresía, así que la aprobación se quedaba sin
-- efecto y el caso multi-sede (MEDICO 3.1/3.2 del registro de procesos) era
-- inalcanzable.
--
-- Desde el PR que acompaña a este patch, aprobar concede la membresía dentro de
-- la misma transacción de la decisión. Este patch repara lo YA aprobado: sin él,
-- los vínculos aprobados antes del despliegue seguirían sin habilitar nada y
-- habría que re-aprobarlos a mano.
--
-- ============================================================================
-- POR QUÉ UN ROL PROPIO Y NO `STAFF`
-- ============================================================================
--
-- Lo que la organización aceptó fue que el profesional ATIENDA, no que
-- administre. `DIR_ROLE_PRACTITIONER` queda fuera de los roles que administran
-- (`ADMIN_TENANT_ROLES` = OWNER/ADMIN, y su gemelo `ROLES_QUE_ADMINISTRAN`), así
-- que la membresía abre el tenant para su agenda y deja cerrada la gestión de
-- personas, sedes y configuración. Con `STAFF` un cardiólogo de turno habría
-- quedado con los mismos cimientos que un administrador de la institución.
--
-- ============================================================================
-- ORDEN DE APLICACIÓN — IMPORTA CUANDO HAY FILAS LEGACY
-- ============================================================================
--
--   * En una base vacía no hay afiliaciones que reparar: el patch termina como
--     no-op aunque la API todavía no haya sembrado terminología.
--   * En una base con afiliaciones candidatas, primero desplegar la API (siembra
--     los seis conceptos usados por el backfill) y después ejecutar este patch.
--
-- Si hay trabajo e invertís ese orden, falla con un mensaje explícito: rol,
-- estado, scope y estados de filtro son conceptos de
-- `terminology.catalog_concepts`; la guarda los comprueba antes de escribir para
-- no morir con una violación de constraint que no nombra la causa.
--
-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
--
--   -- antes y después; la diferencia son las membresías reparadas
--   SELECT count(*) FROM directory.tenant_memberships
--    WHERE tenant_role_concept_id = '9384ffcc-901f-5fb3-a9d6-2c1593d7f019';
--
--   -- segunda corrida del patch: INSERT 0 0
--
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Guarda vacío-safe y de orden: los conceptos los siembra la API, no este patch.
-- Primero se replica exactamente la selección del INSERT. Una base vacía o sin
-- pares usuario/tenant pendientes no necesita terminología para ejecutar una
-- migración que no tiene nada que hacer.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  faltantes text;
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM profiles.practitioner_affiliations pa
      JOIN practice.practice_sites ps
           ON ps.id = pa.practice_site_id
      JOIN profiles.person_account_links pal
           ON pal.person_id = pa.practitioner_profile_id
          AND pal.status_concept_id = '6db29320-acc3-50f6-ac19-cb906aa96209'
     WHERE pa.status_concept_id IN (
             'f581c24c-71bd-51b7-928b-7ea67da84baa',
             'a1084a63-5e11-53a4-9cbc-7cdc9ba8ba23')
       AND ps.managing_tenant_id IS NOT NULL
       AND NOT EXISTS (
         SELECT 1
           FROM directory.tenant_memberships m
          WHERE m.user_id = pal.user_id
            AND m.tenant_id = ps.managing_tenant_id
            AND m.status_concept_id = '13ca1b46-61d5-5c25-9d49-8247bcd7769c'
       )
  ) THEN
    RAISE NOTICE 'patch v4.2.0: 0 membresías asistenciales legacy pendientes; backfill omitido';
    RETURN;
  END IF;

  SELECT string_agg(e.code, ', ' ORDER BY e.code) INTO faltantes
    FROM (VALUES
      ('9384ffcc-901f-5fb3-a9d6-2c1593d7f019'::uuid, 'directory:ROLE_PRACTITIONER'),
      ('13ca1b46-61d5-5c25-9d49-8247bcd7769c'::uuid, 'directory:MEMBERSHIP_ACTIVE'),
      ('297d044a-a1e9-51db-8f96-68f4de6b3d62'::uuid, 'directory:SCOPE_ALL_TENANT'),
      ('6db29320-acc3-50f6-ac19-cb906aa96209'::uuid, 'profiles:ACCOUNT_LINK_ACTIVE'),
      ('f581c24c-71bd-51b7-928b-7ea67da84baa'::uuid, 'profiles:AFFILIATION_ACTIVE'),
      ('a1084a63-5e11-53a4-9cbc-7cdc9ba8ba23'::uuid, 'profiles:AFFILIATION_APPROVED')
    ) AS e(id, code)
   WHERE NOT EXISTS (
     SELECT 1 FROM terminology.catalog_concepts cc
      WHERE cc.id = e.id AND cc.code = e.code
   );

  IF faltantes IS NOT NULL THEN
    RAISE EXCEPTION
      'patch v4.2.0: hay membresías asistenciales legacy pendientes y faltan los conceptos [%]. Desplegá la API antes de este patch: los siembra TerminologySeedService al arrancar.',
      faltantes;
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- Las membresías que la aprobación debió conceder y no concedió.
--
-- El vínculo no guarda tenant: la organización se alcanza por la sede
-- (`practice_site_id` -> `practice_sites.managing_tenant_id`), que es la misma
-- columna que mira el aprobador. Y la membresía se escribe sobre el USUARIO, no
-- sobre el perfil, así que hace falta el salto por `person_account_links`
-- (`practitioner_profile_id` ES `persons.id`).
--
-- Se contemplan LOS DOS conceptos de «aprobado» a propósito: el vigente en el
-- código (`AFFILIATION_ACTIVE`, deprecado pero todavía el que se escribe) y el
-- de v4.1.9 (`AFFILIATION_APPROVED`), para que este patch siga siendo correcto
-- cuando el carril MAC-VINCULO migre los estados.
--
-- El DISTINCT colapsa dos vínculos aprobados en dos sedes de la misma
-- organización a una sola membresía. El NOT EXISTS respeta cualquier membresía
-- activa previa —incluida la de un OWNER o ADMIN—: aprobar un vínculo sólo puede
-- SUMAR acceso, nunca degradar a quien ya administra.
--
-- Un profesional sin cuenta activa no aparece acá y es correcto: no hay usuario
-- a quien darle la llave. Cuando vincule su cuenta, re-correr este patch lo
-- captura.
-- ---------------------------------------------------------------------------
INSERT INTO directory.tenant_memberships (
  id, user_id, tenant_id,
  tenant_role_concept_id, status_concept_id, access_scope_concept_id,
  start_date, created_at, updated_at, row_version
)
SELECT gen_random_uuid(), c.user_id, c.tenant_id,
       '9384ffcc-901f-5fb3-a9d6-2c1593d7f019',  -- directory:ROLE_PRACTITIONER
       '13ca1b46-61d5-5c25-9d49-8247bcd7769c',  -- directory:MEMBERSHIP_ACTIVE
       '297d044a-a1e9-51db-8f96-68f4de6b3d62',  -- directory:SCOPE_ALL_TENANT
       now(), now(), now(), 1
FROM (
  SELECT DISTINCT pal.user_id, ps.managing_tenant_id AS tenant_id
    FROM profiles.practitioner_affiliations pa
    JOIN practice.practice_sites ps
         ON ps.id = pa.practice_site_id
    JOIN profiles.person_account_links pal
         ON pal.person_id = pa.practitioner_profile_id
        AND pal.status_concept_id = '6db29320-acc3-50f6-ac19-cb906aa96209'  -- profiles:ACCOUNT_LINK_ACTIVE
   WHERE pa.status_concept_id IN (
           'f581c24c-71bd-51b7-928b-7ea67da84baa',   -- profiles:AFFILIATION_ACTIVE   (deprecado, aún vigente)
           'a1084a63-5e11-53a4-9cbc-7cdc9ba8ba23')   -- profiles:AFFILIATION_APPROVED (v4.1.9)
     AND ps.managing_tenant_id IS NOT NULL
) c
WHERE NOT EXISTS (
  SELECT 1 FROM directory.tenant_memberships m
   WHERE m.user_id = c.user_id
     AND m.tenant_id = c.tenant_id
     AND m.status_concept_id = '13ca1b46-61d5-5c25-9d49-8247bcd7769c'
);

COMMIT;
