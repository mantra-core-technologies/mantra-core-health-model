-- ============================================================================
-- SALUD · patch de DATOS (common · el logo de una organización vive en su tenant)
-- Fecha: 2026-11-06
-- Idempotente: sólo toca filas que siguen en el tenant DEFAULT; una segunda pasada no cambia nada.
-- Sin DDL.
--
-- QUÉ CIERRA.
--   `FilesService.createFile` registraba TODO archivo subido con sesión en el tenant DEFAULT
--   (`SEED.tenantId`). Con `RLS_ENFORCE=true` cada petición fija `app.current_tenant_id` al tenant
--   del actor, y la política `tenant_isolation` de `common.files` (2026-08-05_tenant_rls.sql):
--     · rechazaba el INSERT de quien trabaja en su propia organización (farmacia, laboratorio,
--       imagenología) → `POST /common/files/upload` en 500;
--     · y dejaba invisible, para esa organización, el logo que se hubiera guardado antes con RLS
--       apagado → la ficha mostraba «Sin logo».
--   El código ya registra el archivo en el tenant de la petición. Este patch mueve los logos de
--   organización ya guardados a su tenant, que es lo que el código nuevo habría escrito.
--
-- ALCANCE. Sólo los archivos que son hoy el logo de una organización: el `avatar_file_id` de la
--   ficha pública cuyo `target_id` es el propio tenant (así la guarda
--   `PublicProfileProjectionService.setOrganizationLogo`). Las pre-cargas anónimas sin reclamar
--   (sin `created_by_user_id`) no se tocan: el reclamo exige que sigan en DEFAULT.
--
-- Corre con el rol owner (omite RLS), como todo patch.
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '5s';

UPDATE "common"."files" AS f
   SET "tenant_id" = p."tenant_id",
       "updated_at" = now()
  FROM "community"."public_profiles" AS p,
       "directory"."tenants" AS d
 WHERE p."avatar_file_id" = f."id"
   AND p."target_id" = p."tenant_id"
   AND d."code" = 'DEFAULT'
   AND f."tenant_id" = d."id"
   AND p."tenant_id" <> d."id"
   AND f."created_by_user_id" IS NOT NULL;

COMMIT;
