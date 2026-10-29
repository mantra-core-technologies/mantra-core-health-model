-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5 · operaciones (F5a imagenología,
-- F5c botiquín por unidad, F5g acceso delegado por espacio) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1, F5a, F5c y F5g (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y de
-- 2026-10-29_infraestructura_f1b_seguridad.sql (orden F1 → F1b → F2 → … → F5).
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / DROP … IF EXISTS / CREATE OR REPLACE). Se puede aplicar N veces;
-- la segunda pasada no cambia nada.
--
-- Contexto: columnas, FKs e índices los emite gen_ddl.py en SQL/23_diagnostic_units y
-- SQL/25_pharmacy_inventory desde que diagram_23 / diagram_25 los declaran; los CHECK y
-- el EXCLUDE los emite gen_integrity.py en SQL/23_*/05 y SQL/29_*/05 desde diagram_33.
-- Esas sentencias se copiaron de los archivos generados. Lo escrito a mano: las
-- precondiciones, los triggers de mismo tenant y la verificación final. gen_apply.py no
-- escanea SQL/patches/: no entra en apply_all.sql.
--
-- QUÉ CIERRA.
--   F5a. diagnostic_units.diagnostic_equipment: el equipo vive en una SALA
--        (care_space_id → practice.care_spaces), se identifica en DICOM por `ae_title` y
--        `station_name` (varchar(16)) y puede tener su recurso agendable RES_EQUIPMENT
--        (schedulable_resource_id → scheduling.schedulable_resources).
--        ck_diagnostic_equipment_ae_title (≤ 16 ASCII imprimibles, sin `\`, no solo
--        espacios) y ux_diagnostic_equipment_site_ae_title (único por sede de la unidad).
--   F5c. pharmacy_inventory.inventory_locations: care_space_id → practice.care_spaces y
--        clinical_unit_id → practice.clinical_units; un solo botiquín ACTIVO por unidad
--        (ux_inventory_locations_ward_stock_unit, índice único parcial).
--   F5g. delegated_access.organization_user_assignments (sin columnas nuevas):
--        ck_org_user_assignments_scope_target (SCOPE_UNIT ⇒ unidad, SCOPE_SPACE ⇒
--        espacio, SCOPE_SITE ⇒ sede) y ex_org_user_assignments_unit_head (un solo jefe de
--        unidad ACTIVO y vigente por unidad, regla B.5-29).
--   Mismo tenant. Ninguna de las tres tablas tiene `tenant_id` (cuelgan de la unidad
--        diagnóstica, de la farmacia y de la membresía), así que no admiten la FK
--        compuesta (tenant_id, x_id) de F1b. Igual que F1b para
--        facility_licenses.healthcare_service_id, la garantía es un trigger BEFORE
--        INSERT/UPDATE (SECURITY INVOKER: con RLS, un padre de otro tenant ni se ve y cae
--        en el mismo error) que compara el tenant del dueño con el del espacio / unidad /
--        sede / recurso referido y aborta con ERRCODE foreign_key_violation (23503):
--          diagnostic_equipment     dueño: diagnostic_units.tenant_id (vía la sede de la unidad)
--                                   referidos: care_space_id, schedulable_resource_id
--          inventory_locations      dueño: pharmacy.pharmacies.tenant_id (vía pharmacy_sites)
--                                   referidos: care_space_id, clinical_unit_id
--          organization_user_assignments
--                                   dueño: directory.tenant_memberships.tenant_id
--                                   referidos: practice_site_id, clinical_unit_id, care_space_id
--
-- UUID literales (el predicado de un índice parcial / EXCLUDE debe ser IMMUTABLE), todos
-- `deterministicId(<clave>)` de la API (common/constants/concepts.ts):
--   51dd3c8b-d630-5f5a-8bf4-2b9366752a73  pharmacy_inventory:LOCATION_TYPE_WARD_STOCK (PINV_LOCATION_TYPE_WARD_STOCK, nuevo)
--   4e556b5a-7ee6-5c64-abf9-f7e32bf83115  pharmacy_inventory:LOCATION_ACTIVE          (PINV_LOCATION_ACTIVE, existe)
--   ce54425b-5479-57f1-8bb2-274a8617723c  delegated_access:ASSIGN_ROLE_UNIT_HEAD      (DA_ASSIGN_UNIT_HEAD, nuevo, §0.3)
--   38a1d301-f40d-5b17-a695-5e6d605f8b19  state:active                                (CONCEPTS.STATE_ACTIVE: el estado
--                                          ACTIVO que escribe org-user-assignments.service.ts; el contrato lo llama ⟨DA_ACTIVE⟩)
--   928c884d-ff91-584c-8aa6-68535085e078  delegated_access:SCOPE_UNIT                 (DA_SCOPE_UNIT, existe)
--   4df1a147-cb37-55ba-94e8-ab469e9cccb0  delegated_access:SCOPE_SPACE                (DA_SCOPE_SPACE, nuevo, §0.3)
--   e69a4c95-fe59-5c3e-b826-222af123adb9  delegated_access:SCOPE_SITE                 (DA_SCOPE_SITE, existe)
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos (los siembra la API con defineModuleConcepts).
--   - No valida «misma sede» (equipo / botiquín en un espacio de la sede de su unidad o
--     farmacia), ni el perfil de función del espacio (hostsEquipment / stockPoint): son
--     422 de la API (EQUIPMENT_SPACE_SITE_MISMATCH, STOCK_POINT_SITE_MISMATCH, …).
--   - No agrega historia: ninguna de las tres tablas es nueva.
--   - No borra ni renombra nada.
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - referencias existentes a un espacio / unidad / sede / recurso de OTRO tenant;
--   - AE Title inválido o repetido en la misma sede;
--   - dos botiquines activos en la misma unidad;
--   - asignaciones con alcance UNIT/SPACE/SITE sin su objetivo;
--   - dos jefes de unidad activos con vigencias solapadas en la misma unidad.
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas   +6  (diagnostic_equipment 4 · inventory_locations 2)
--   FKs        +4
--   índices    +7  (4 IX + 2 UX declarados + el gist del EXCLUDE)
--   CHECK      +2 · EXCLUDE +1 · triggers +3
-- ============================================================================

BEGIN;

-- Las comprobaciones leen tablas con RLS forzada (practice.*, pharmacy.*, directory.*).
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ------------------------------------------------------------- 1. columnas nuevas
-- (de SQL/23_diagnostic_units/02_tables.sql y SQL/25_pharmacy_inventory/02_tables.sql)
ALTER TABLE "diagnostic_units"."diagnostic_equipment"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "diagnostic_units"."diagnostic_equipment"
    ADD COLUMN IF NOT EXISTS "ae_title" varchar(16);

ALTER TABLE "diagnostic_units"."diagnostic_equipment"
    ADD COLUMN IF NOT EXISTS "station_name" varchar(16);

ALTER TABLE "diagnostic_units"."diagnostic_equipment"
    ADD COLUMN IF NOT EXISTS "schedulable_resource_id" uuid;

ALTER TABLE "pharmacy_inventory"."inventory_locations"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "pharmacy_inventory"."inventory_locations"
    ADD COLUMN IF NOT EXISTS "clinical_unit_id" uuid;

-- ------------------------------------------------------------- 2. FKs
-- (de SQL/23_diagnostic_units/90_fk_deferred.sql y SQL/25_pharmacy_inventory/90_fk_deferred.sql)
-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: scheduling.schedulable_resources (requiere schema scheduling)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_schedulable_resource_id" FOREIGN KEY ("schedulable_resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_locations"
        ADD CONSTRAINT "fk_inventory_locations_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- 3. índices no únicos
-- (de SQL/23_diagnostic_units/04_indexes.sql y SQL/25_pharmacy_inventory/04_indexes.sql)
CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_care_space_id" ON "diagnostic_units"."diagnostic_equipment" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_schedulable_resource_id" ON "diagnostic_units"."diagnostic_equipment" ("schedulable_resource_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_care_space_id" ON "pharmacy_inventory"."inventory_locations" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_locations_clinical_unit_id" ON "pharmacy_inventory"."inventory_locations" ("clinical_unit_id");

-- ------------------------------------------------------------- 4. precondiciones
-- 4a. Referencias a un padre de OTRO tenant (la FK simple no lo impide).
DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces (relacion, hijo) AS (
        SELECT 'diagnostic_equipment.care_space_id', e."id"
          FROM "diagnostic_units"."diagnostic_equipment" e
          JOIN "diagnostic_units"."diagnostic_unit_sites" dus ON dus."id" = e."diagnostic_unit_site_id"
          JOIN "diagnostic_units"."diagnostic_units" du ON du."id" = dus."diagnostic_unit_id"
          JOIN "practice"."care_spaces" cs ON cs."id" = e."care_space_id"
          JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
         WHERE COALESCE(cs."tenant_id", ps."tenant_id") IS DISTINCT FROM du."tenant_id"
        UNION ALL
        SELECT 'diagnostic_equipment.schedulable_resource_id', e."id"
          FROM "diagnostic_units"."diagnostic_equipment" e
          JOIN "diagnostic_units"."diagnostic_unit_sites" dus ON dus."id" = e."diagnostic_unit_site_id"
          JOIN "diagnostic_units"."diagnostic_units" du ON du."id" = dus."diagnostic_unit_id"
          JOIN "scheduling"."schedulable_resources" sr ON sr."id" = e."schedulable_resource_id"
         WHERE sr."tenant_id" IS DISTINCT FROM du."tenant_id"
        UNION ALL
        SELECT 'inventory_locations.care_space_id', l."id"
          FROM "pharmacy_inventory"."inventory_locations" l
          JOIN "pharmacy"."pharmacy_sites" phs ON phs."id" = l."pharmacy_site_id"
          JOIN "pharmacy"."pharmacies" ph ON ph."id" = phs."pharmacy_id"
          JOIN "practice"."care_spaces" cs ON cs."id" = l."care_space_id"
          JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
         WHERE COALESCE(cs."tenant_id", ps."tenant_id") IS DISTINCT FROM ph."tenant_id"
        UNION ALL
        SELECT 'inventory_locations.clinical_unit_id', l."id"
          FROM "pharmacy_inventory"."inventory_locations" l
          JOIN "pharmacy"."pharmacy_sites" phs ON phs."id" = l."pharmacy_site_id"
          JOIN "pharmacy"."pharmacies" ph ON ph."id" = phs."pharmacy_id"
          JOIN "practice"."clinical_units" cu ON cu."id" = l."clinical_unit_id"
          JOIN "practice"."practice_sites" ps ON ps."id" = cu."practice_site_id"
         WHERE COALESCE(cu."tenant_id", ps."tenant_id") IS DISTINCT FROM ph."tenant_id"
        UNION ALL
        SELECT 'organization_user_assignments.practice_site_id', a."id"
          FROM "delegated_access"."organization_user_assignments" a
          JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
          JOIN "practice"."practice_sites" ps ON ps."id" = a."practice_site_id"
         WHERE ps."tenant_id" IS DISTINCT FROM tm."tenant_id"
        UNION ALL
        SELECT 'organization_user_assignments.clinical_unit_id', a."id"
          FROM "delegated_access"."organization_user_assignments" a
          JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
          JOIN "practice"."clinical_units" cu ON cu."id" = a."clinical_unit_id"
          JOIN "practice"."practice_sites" ps ON ps."id" = cu."practice_site_id"
         WHERE COALESCE(cu."tenant_id", ps."tenant_id") IS DISTINCT FROM tm."tenant_id"
        UNION ALL
        SELECT 'organization_user_assignments.care_space_id', a."id"
          FROM "delegated_access"."organization_user_assignments" a
          JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
          JOIN "practice"."care_spaces" cs ON cs."id" = a."care_space_id"
          JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
         WHERE COALESCE(cs."tenant_id", ps."tenant_id") IS DISTINCT FROM tm."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'F5 operaciones: hay referencias a un padre de OTRO tenant en % relación(es): %. No se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- 4b. AE Title válido y único por sede; botiquín único por unidad; alcance con objetivo;
--     un solo jefe de unidad vigente.
DO $$
DECLARE
    n_ae_inv   integer;
    n_ae_dup   integer;
    n_ward_dup integer;
    n_scope    integer;
    n_jefes    integer;
BEGIN
    SELECT count(*) INTO n_ae_inv
      FROM "diagnostic_units"."diagnostic_equipment"
     WHERE NOT ("ae_title" IS NULL OR ("ae_title" ~ '^[\x20-\x7E]{1,16}$' AND btrim("ae_title") <> '' AND "ae_title" !~ '\\'));

    SELECT count(*) INTO n_ae_dup
      FROM (SELECT 1 FROM "diagnostic_units"."diagnostic_equipment"
             WHERE "ae_title" IS NOT NULL
             GROUP BY "diagnostic_unit_site_id", "ae_title" HAVING count(*) > 1) d;

    SELECT count(*) INTO n_ward_dup
      FROM (SELECT 1 FROM "pharmacy_inventory"."inventory_locations"
             WHERE "location_type_concept_id" = '51dd3c8b-d630-5f5a-8bf4-2b9366752a73'
               AND "status_concept_id" = '4e556b5a-7ee6-5c64-abf9-f7e32bf83115'
               AND "clinical_unit_id" IS NOT NULL
             GROUP BY "clinical_unit_id" HAVING count(*) > 1) d;

    SELECT count(*) INTO n_scope
      FROM "delegated_access"."organization_user_assignments"
     WHERE NOT (("access_scope_concept_id" <> '928c884d-ff91-584c-8aa6-68535085e078' OR "clinical_unit_id" IS NOT NULL)
            AND ("access_scope_concept_id" <> '4df1a147-cb37-55ba-94e8-ab469e9cccb0' OR "care_space_id" IS NOT NULL)
            AND ("access_scope_concept_id" <> 'e69a4c95-fe59-5c3e-b826-222af123adb9' OR "practice_site_id" IS NOT NULL));

    SELECT count(*) INTO n_jefes
      FROM "delegated_access"."organization_user_assignments" a
      JOIN "delegated_access"."organization_user_assignments" b
        ON a."clinical_unit_id" = b."clinical_unit_id"
       AND a."id" < b."id"
       AND tstzrange(a."valid_from", a."valid_to", '[)') && tstzrange(b."valid_from", b."valid_to", '[)')
     WHERE a."assignment_role_concept_id" = 'ce54425b-5479-57f1-8bb2-274a8617723c'
       AND b."assignment_role_concept_id" = 'ce54425b-5479-57f1-8bb2-274a8617723c'
       AND a."status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
       AND b."status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

    IF n_ae_inv > 0 OR n_ae_dup > 0 OR n_ward_dup > 0 OR n_scope > 0 OR n_jefes > 0 THEN
        RAISE EXCEPTION 'F5 operaciones: datos que violan las reglas nuevas — AE Title inválido=%, AE Title repetido por sede=%, botiquines activos repetidos por unidad=%, asignaciones sin objetivo de alcance=%, pares de jefes de unidad solapados=%. No se toca ningún dato; corregirlos a mano y volver a aplicar.',
            n_ae_inv, n_ae_dup, n_ward_dup, n_scope, n_jefes;
    END IF;
END $$;

-- ------------------------------------------------------------- 5. únicos, CHECK y EXCLUDE
-- (índices de SQL/23_*/04_indexes.sql y SQL/25_*/04_indexes.sql; CHECK/EXCLUDE de
--  SQL/23_diagnostic_units/05_constraints.sql y SQL/29_delegated_access/05_constraints.sql)
CREATE UNIQUE INDEX IF NOT EXISTS "ux_diagnostic_equipment_site_ae_title" ON "diagnostic_units"."diagnostic_equipment" ("diagnostic_unit_site_id", "ae_title") WHERE ae_title IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inventory_locations_ward_stock_unit" ON "pharmacy_inventory"."inventory_locations" ("clinical_unit_id") WHERE location_type_concept_id = '51dd3c8b-d630-5f5a-8bf4-2b9366752a73' AND status_concept_id = '4e556b5a-7ee6-5c64-abf9-f7e32bf83115';

ALTER TABLE "diagnostic_units"."diagnostic_equipment" DROP CONSTRAINT IF EXISTS "ck_diagnostic_equipment_ae_title";
ALTER TABLE "diagnostic_units"."diagnostic_equipment" ADD CONSTRAINT "ck_diagnostic_equipment_ae_title" CHECK ("ae_title" IS NULL OR ("ae_title" ~ '^[\x20-\x7E]{1,16}$' AND btrim("ae_title") <> '' AND "ae_title" !~ '\\'));

ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ck_org_user_assignments_scope_target";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ck_org_user_assignments_scope_target" CHECK (("access_scope_concept_id" <> '928c884d-ff91-584c-8aa6-68535085e078' OR "clinical_unit_id" IS NOT NULL) AND ("access_scope_concept_id" <> '4df1a147-cb37-55ba-94e8-ab469e9cccb0' OR "care_space_id" IS NOT NULL) AND ("access_scope_concept_id" <> 'e69a4c95-fe59-5c3e-b826-222af123adb9' OR "practice_site_id" IS NOT NULL));

ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ex_org_user_assignments_unit_head";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ex_org_user_assignments_unit_head"
    EXCLUDE USING gist ("clinical_unit_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH &&) WHERE ("assignment_role_concept_id" = 'ce54425b-5479-57f1-8bb2-274a8617723c' AND "status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19');

-- ------------------------------------------------------------- 6. triggers de mismo tenant
-- SECURITY INVOKER a propósito (como F1b): con RLS, un padre de otro tenant ni siquiera se
-- ve y cae en el mismo error genérico. ERRCODE foreign_key_violation (23503); la API
-- pre-valida y responde 404 (recurso de otro tenant), la base es la red.

-- 6a. diagnostic_units.diagnostic_equipment → sala y recurso del tenant de la unidad diagnóstica.
CREATE OR REPLACE FUNCTION "diagnostic_units"."diagnostic_equipment_assert_location_tenant"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    t_dueno   uuid;
    t_referido uuid;
BEGIN
    IF NEW."care_space_id" IS NULL AND NEW."schedulable_resource_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT du."tenant_id" INTO t_dueno
      FROM "diagnostic_units"."diagnostic_unit_sites" dus
      JOIN "diagnostic_units"."diagnostic_units" du ON du."id" = dus."diagnostic_unit_id"
     WHERE dus."id" = NEW."diagnostic_unit_site_id";
    IF NEW."care_space_id" IS NOT NULL THEN
        SELECT COALESCE(cs."tenant_id", ps."tenant_id") INTO t_referido
          FROM "practice"."care_spaces" cs
          JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
         WHERE cs."id" = NEW."care_space_id";
        IF t_dueno IS NULL OR t_referido IS DISTINCT FROM t_dueno THEN
            RAISE EXCEPTION 'diagnostic_equipment.care_space_id: el espacio no existe en el tenant de la unidad diagnóstica'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    IF NEW."schedulable_resource_id" IS NOT NULL THEN
        SELECT sr."tenant_id" INTO t_referido
          FROM "scheduling"."schedulable_resources" sr
         WHERE sr."id" = NEW."schedulable_resource_id";
        IF t_dueno IS NULL OR t_referido IS DISTINCT FROM t_dueno THEN
            RAISE EXCEPTION 'diagnostic_equipment.schedulable_resource_id: el recurso no existe en el tenant de la unidad diagnóstica'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_diagnostic_equipment_location_tenant" ON "diagnostic_units"."diagnostic_equipment";
CREATE TRIGGER "trg_diagnostic_equipment_location_tenant"
    BEFORE INSERT OR UPDATE OF "diagnostic_unit_site_id", "care_space_id", "schedulable_resource_id"
    ON "diagnostic_units"."diagnostic_equipment"
    FOR EACH ROW EXECUTE FUNCTION "diagnostic_units"."diagnostic_equipment_assert_location_tenant"();

-- 6b. pharmacy_inventory.inventory_locations → espacio y unidad del tenant de la farmacia.
CREATE OR REPLACE FUNCTION "pharmacy_inventory"."inventory_locations_assert_location_tenant"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    t_dueno    uuid;
    t_referido uuid;
BEGIN
    IF NEW."care_space_id" IS NULL AND NEW."clinical_unit_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT ph."tenant_id" INTO t_dueno
      FROM "pharmacy"."pharmacy_sites" phs
      JOIN "pharmacy"."pharmacies" ph ON ph."id" = phs."pharmacy_id"
     WHERE phs."id" = NEW."pharmacy_site_id";
    IF NEW."care_space_id" IS NOT NULL THEN
        SELECT COALESCE(cs."tenant_id", ps."tenant_id") INTO t_referido
          FROM "practice"."care_spaces" cs
          JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
         WHERE cs."id" = NEW."care_space_id";
        IF t_dueno IS NULL OR t_referido IS DISTINCT FROM t_dueno THEN
            RAISE EXCEPTION 'inventory_locations.care_space_id: el espacio no existe en el tenant de la farmacia'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    IF NEW."clinical_unit_id" IS NOT NULL THEN
        SELECT COALESCE(cu."tenant_id", ps."tenant_id") INTO t_referido
          FROM "practice"."clinical_units" cu
          JOIN "practice"."practice_sites" ps ON ps."id" = cu."practice_site_id"
         WHERE cu."id" = NEW."clinical_unit_id";
        IF t_dueno IS NULL OR t_referido IS DISTINCT FROM t_dueno THEN
            RAISE EXCEPTION 'inventory_locations.clinical_unit_id: la unidad no existe en el tenant de la farmacia'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_inventory_locations_location_tenant" ON "pharmacy_inventory"."inventory_locations";
CREATE TRIGGER "trg_inventory_locations_location_tenant"
    BEFORE INSERT OR UPDATE OF "pharmacy_site_id", "care_space_id", "clinical_unit_id"
    ON "pharmacy_inventory"."inventory_locations"
    FOR EACH ROW EXECUTE FUNCTION "pharmacy_inventory"."inventory_locations_assert_location_tenant"();

-- 6c. delegated_access.organization_user_assignments → sede, unidad y espacio del tenant de la membresía.
CREATE OR REPLACE FUNCTION "delegated_access"."organization_user_assignments_assert_scope_tenant"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    t_dueno    uuid;
    t_referido uuid;
BEGIN
    IF NEW."practice_site_id" IS NULL AND NEW."clinical_unit_id" IS NULL AND NEW."care_space_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT tm."tenant_id" INTO t_dueno
      FROM "directory"."tenant_memberships" tm
     WHERE tm."id" = NEW."tenant_membership_id";
    IF NEW."practice_site_id" IS NOT NULL THEN
        SELECT ps."tenant_id" INTO t_referido
          FROM "practice"."practice_sites" ps
         WHERE ps."id" = NEW."practice_site_id";
        IF t_dueno IS NULL OR t_referido IS DISTINCT FROM t_dueno THEN
            RAISE EXCEPTION 'organization_user_assignments.practice_site_id: la sede no existe en el tenant de la membresía'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    IF NEW."clinical_unit_id" IS NOT NULL THEN
        SELECT COALESCE(cu."tenant_id", ps."tenant_id") INTO t_referido
          FROM "practice"."clinical_units" cu
          JOIN "practice"."practice_sites" ps ON ps."id" = cu."practice_site_id"
         WHERE cu."id" = NEW."clinical_unit_id";
        IF t_dueno IS NULL OR t_referido IS DISTINCT FROM t_dueno THEN
            RAISE EXCEPTION 'organization_user_assignments.clinical_unit_id: la unidad no existe en el tenant de la membresía'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    IF NEW."care_space_id" IS NOT NULL THEN
        SELECT COALESCE(cs."tenant_id", ps."tenant_id") INTO t_referido
          FROM "practice"."care_spaces" cs
          JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
         WHERE cs."id" = NEW."care_space_id";
        IF t_dueno IS NULL OR t_referido IS DISTINCT FROM t_dueno THEN
            RAISE EXCEPTION 'organization_user_assignments.care_space_id: el espacio no existe en el tenant de la membresía'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_organization_user_assignments_scope_tenant" ON "delegated_access"."organization_user_assignments";
CREATE TRIGGER "trg_organization_user_assignments_scope_tenant"
    BEFORE INSERT OR UPDATE OF "tenant_membership_id", "practice_site_id", "clinical_unit_id", "care_space_id"
    ON "delegated_access"."organization_user_assignments"
    FOR EACH ROW EXECUTE FUNCTION "delegated_access"."organization_user_assignments_assert_scope_tenant"();

-- ------------------------------------------------------------- 7. verificación
DO $$
DECLARE
    n_columnas integer;
    n_fk       integer;
    n_idx      integer;
    n_ck       integer;
    n_tg       integer;
BEGIN
    SELECT count(*) INTO n_columnas
      FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('diagnostic_units', 'diagnostic_equipment', 'care_space_id'),
            ('diagnostic_units', 'diagnostic_equipment', 'ae_title'),
            ('diagnostic_units', 'diagnostic_equipment', 'station_name'),
            ('diagnostic_units', 'diagnostic_equipment', 'schedulable_resource_id'),
            ('pharmacy_inventory', 'inventory_locations', 'care_space_id'),
            ('pharmacy_inventory', 'inventory_locations', 'clinical_unit_id'));

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_diagnostic_equipment_care_space_id', 'fk_diagnostic_equipment_schedulable_resource_id',
                       'fk_inventory_locations_care_space_id', 'fk_inventory_locations_clinical_unit_id');

    SELECT count(*) INTO n_idx
      FROM pg_indexes
     WHERE (schemaname, indexname) IN (
            ('diagnostic_units', 'ix_diagnostic_equipment_care_space_id'),
            ('diagnostic_units', 'ix_diagnostic_equipment_schedulable_resource_id'),
            ('diagnostic_units', 'ux_diagnostic_equipment_site_ae_title'),
            ('pharmacy_inventory', 'ix_inventory_locations_care_space_id'),
            ('pharmacy_inventory', 'ix_inventory_locations_clinical_unit_id'),
            ('pharmacy_inventory', 'ux_inventory_locations_ward_stock_unit'));

    SELECT count(*) INTO n_ck
      FROM pg_constraint
     WHERE (contype = 'c' AND conname IN ('ck_diagnostic_equipment_ae_title', 'ck_org_user_assignments_scope_target'))
        OR (contype = 'x' AND conname = 'ex_org_user_assignments_unit_head');

    SELECT count(*) INTO n_tg
      FROM pg_trigger
     WHERE NOT tgisinternal
       AND tgname IN ('trg_diagnostic_equipment_location_tenant', 'trg_inventory_locations_location_tenant',
                      'trg_organization_user_assignments_scope_tenant');

    IF n_columnas <> 6 OR n_fk <> 4 OR n_idx <> 6 OR n_ck <> 3 OR n_tg <> 3 THEN
        RAISE EXCEPTION 'F5 operaciones incompleto: columnas=% (6), fk=% (4), índices=% (6), check/exclude=% (3), triggers=% (3)',
            n_columnas, n_fk, n_idx, n_ck, n_tg;
    END IF;

    RAISE NOTICE 'F5 operaciones aplicado: 6 columnas, 4 FKs validadas, 6 índices (2 únicos), 2 CHECK + 1 EXCLUDE, 3 triggers de mismo tenant.';
END $$;

COMMIT;
