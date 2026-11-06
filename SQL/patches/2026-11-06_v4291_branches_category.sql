-- ============================================================================
-- SALUD · patch v4.2.91 · categoría de la sede en directory.branches (módulo 04 directory) sobre BD viva
-- Fecha: 2026-11-06
-- Idempotente (IF NOT EXISTS / DROP CONSTRAINT IF EXISTS / NOT EXISTS en los backfills). UNA sola pasada.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten la columna, los índices y el CHECK en SQL/04_directory/
-- desde que diagram_04_directory.puml y diagram_33_integrity.puml los declaran: en un rebuild desde cero la
-- parte de esquema de este patch es un no-op. Las sentencias de esquema se copiaron de los archivos generados.
--
-- QUÉ AGREGA
--   1. directory.branches.branch_category varchar(20) NOT NULL DEFAULT 'default':
--        'default'     sin clasificar (lo que queda en toda fila que el backfill no reconoce),
--        'head_office' casa matriz (a lo sumo UNA por organización: ux_branches_one_head_office),
--        'branch'      sucursal.
--      Sirve para etiquetar las sedes y verlas por oleadas en la pantalla de Sucursales de toda
--      organización (farmacia, laboratorio, imagenología, establecimiento médico).
--   2. Backfill de la casa matriz: la sede que el alta pública crea como casa central
--      (código CASA-CENTRAL de farmacia, SEDE-CENTRAL de laboratorio/imagenología) pasa a
--      'head_office' si la organización todavía no tiene una. Una por organización (la más vieja).
--      El resto de las filas viejas queda en 'default': la persona las etiqueta desde la pantalla.
--   3. Backfill del registro de sucursales del establecimiento médico: las sedes que declaró en el alta
--      (directory.tenant_medical_facility_sites) se copian a directory.branches —casa central como
--      'head_office', sucursales como 'branch'— para las organizaciones que todavía no tienen NINGUNA
--      fila en directory.branches. Es el mismo espejo que la API hace desde v4.2.91 en el alta
--      (`TenantTypeProfileService.registerMedicalFacilityBranches`), igual al que ya hacían el alta de
--      farmacia y la de laboratorio. tenant_medical_facility_sites sigue siendo lo DECLARADO (alimenta la
--      verificación) y no se toca; directory.branches es el registro operativo que se edita.
--      Código: el nombre en mayúsculas sin tildes, lo que no es letra o dígito → '-', 90 caracteres;
--      si dos sedes de la misma organización dan el mismo código, la segunda lleva '-2', etc.
--      Descripción: las líneas de dirección declaradas. Tipo CLINIC, estado activo (conceptos deterministas
--      directory:BRANCH_TYPE_CLINIC y directory:BRANCH_ACTIVE de la API). Si esos conceptos no están
--      sembrados la copia no inserta nada (la FK no se viola).
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +1 · FKs +0 · índices +2 · constraints +1
-- ============================================================================

BEGIN;

ALTER TABLE "directory"."branches"
    ADD COLUMN IF NOT EXISTS "branch_category" varchar(20) NOT NULL DEFAULT 'default';

ALTER TABLE "directory"."branches" DROP CONSTRAINT IF EXISTS "ck_branches_branch_category";
ALTER TABLE "directory"."branches" ADD CONSTRAINT "ck_branches_branch_category" CHECK ("branch_category" IN ('default', 'head_office', 'branch'));

-- 2. Casa matriz de las altas de farmacia y laboratorio (antes del índice único).
UPDATE "directory"."branches" b
   SET "branch_category" = 'head_office',
       "updated_at" = now(),
       "row_version" = b."row_version" + 1
  FROM (
        SELECT DISTINCT ON ("tenant_id") "id"
          FROM "directory"."branches"
         WHERE "code" IN ('CASA-CENTRAL', 'SEDE-CENTRAL')
           AND "branch_category" = 'default'
         ORDER BY "tenant_id", "created_at", "id"
       ) pick
 WHERE b."id" = pick."id"
   AND NOT EXISTS (
        SELECT 1 FROM "directory"."branches" o
         WHERE o."tenant_id" = b."tenant_id" AND o."branch_category" = 'head_office'
       );

-- 3. Espejo de las sedes declaradas del establecimiento médico.
INSERT INTO "directory"."branches" (
    "id", "tenant_id", "code", "name", "branch_type_concept_id", "status_concept_id", "time_zone",
    "latitude", "longitude", "description", "location_url", "branch_category",
    "created_at", "updated_at", "created_by_user_id", "updated_by_user_id", "row_version"
)
SELECT gen_random_uuid(),
       s."tenant_id",
       CASE WHEN s.rn = 1 THEN s.base ELSE left(s.base, 86) || '-' || s.rn END,
       s."name",
       '87c93b9c-54f6-56ed-a966-45812bf2c516'::uuid,   -- directory:BRANCH_TYPE_CLINIC
       'd816e283-25ec-5bf8-8241-208236b065bd'::uuid,   -- directory:BRANCH_ACTIVE
       t."time_zone",
       s."latitude",
       s."longitude",
       nullif(array_to_string(s."address_lines", ', '), ''),
       NULL,
       CASE WHEN s."site_kind" = 'headquarters' THEN 'head_office' ELSE 'branch' END,
       now(), now(), s."created_by_user_id", s."created_by_user_id", 1
  FROM (
        SELECT x.*,
               row_number() OVER (PARTITION BY x."tenant_id", x.base ORDER BY x."ordinal") AS rn
          FROM (
                SELECT fs.*,
                       coalesce(nullif(left(trim(BOTH '-' FROM regexp_replace(
                           translate(upper(fs."name"), 'ÁÀÄÂÉÈËÊÍÌÏÎÓÒÖÔÚÙÜÛÑÇ', 'AAAAEEEEIIIIOOOOUUUUNC'),
                           '[^A-Z0-9]+', '-', 'g')), 90), ''), 'SUCURSAL') AS base
                  FROM "directory"."tenant_medical_facility_sites" fs
               ) x
       ) s
  JOIN "directory"."tenants" t ON t."id" = s."tenant_id"
 WHERE NOT EXISTS (SELECT 1 FROM "directory"."branches" b WHERE b."tenant_id" = s."tenant_id")
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" c WHERE c."id" = '87c93b9c-54f6-56ed-a966-45812bf2c516')
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" c WHERE c."id" = 'd816e283-25ec-5bf8-8241-208236b065bd');

CREATE INDEX IF NOT EXISTS "ix_branches_tenant_id_branch_category" ON "directory"."branches" ("tenant_id", "branch_category");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_branches_one_head_office" ON "directory"."branches" ("tenant_id") WHERE branch_category = 'head_office';

COMMIT;
