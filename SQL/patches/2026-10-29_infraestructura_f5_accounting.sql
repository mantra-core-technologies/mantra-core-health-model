-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5f · contabilidad (activos ubicados en un
-- espacio y centros de costo por unidad) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §F5f (repositorio de documentación) · agente M-F5-fin
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql (practice.clinical_units y
-- practice.care_spaces con sus columnas). Idempotente (ADD COLUMN IF NOT EXISTS / CREATE …
-- IF NOT EXISTS / FK con `duplicate_object` / CREATE OR REPLACE). Se puede aplicar N veces; la
-- segunda pasada no cambia nada. Orden por nombre: este archivo va ANTES de
-- …_f5_billing.sql, que necesita ux_cost_centers_practice_id_id (lo comprueba y aborta).
--
-- Contexto: columnas, FK e índices los emite gen_ddl.py en SQL/16_accounting desde que
-- diagram_16 los declara; esas sentencias se copiaron de los archivos generados. Lo escrito a
-- mano: la precondición, los triggers de misma práctica y la verificación final.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
--
-- QUÉ CIERRA.
--   F5f. accounting.infrastructure_items.care_space_id → practice.care_spaces: el activo se
--        ubica en un espacio del árbol físico en lugar de un texto libre (`location_text` se
--        conserva sólo como lectura heredada). Un activo ubicado bloquea la clausura del espacio
--        (retire-check, API).
--        accounting.cost_centers.clinical_unit_id → practice.clinical_units: el centro de costo
--        de una unidad. ux_cost_centers_unit_active: a lo sumo UN centro de costo ACTIVO por
--        unidad (409 UNIT_ALREADY_HAS_COST_CENTER en la API). ux_cost_centers_practice_id_id
--        existe para que billing.charge_captures apunte a un centro de costo de su práctica con
--        FK compuesta (practice_id, cost_center_id).
--   Misma práctica, en las DOS direcciones. Además de comprobarse al escribir el activo / centro
--        de costo, tres triggers sobre las tablas padre (trg_care_spaces_accounting_dependents,
--        trg_clinical_units_accounting_dependents, trg_practice_sites_accounting_dependents)
--        impiden que un espacio o una unidad pase a una sede de otra práctica, o que una sede
--        pase a otra práctica, mientras existan activos o centros de costo que dependan de ella.
--        Mover entre sedes de la MISMA práctica, o mover algo sin dependientes, sigue permitido
--        (flujo de F1). Lectura con contexto de sistema; el mensaje no revela datos de otro tenant.
--   Misma práctica (escritura). Ninguna de las dos tablas tiene `tenant_id` (cuelgan de practice_id), así
--        que no admiten la FK compuesta (tenant_id, x_id) de F1b. La garantía es un trigger
--        BEFORE INSERT/UPDATE (SECURITY INVOKER: con RLS, un espacio o unidad de otro tenant ni
--        se ve y cae en el mismo error) que exige que la sede del espacio / de la unidad
--        pertenezca a la MISMA práctica del activo / centro de costo (más estricto que «mismo
--        tenant»), con ERRCODE foreign_key_violation (23503). La API pre-valida y responde
--        422 INFRASTRUCTURE_SPACE_PRACTICE_MISMATCH / 404; la base es la red.
--
-- UUID literales (el predicado de un índice parcial debe ser IMMUTABLE), todos
-- `deterministicId(<clave>)` de la API (common/constants/concepts.ts):
--   38a1d301-f40d-5b17-a695-5e6d605f8b19  state:active (CONCEPTS.STATE_ACTIVE, el estado ACTIVO
--                                          genérico que accounting usa; el contrato lo llama ⟨activo⟩)
--
-- LO QUE ESTE PATCH NO HACE.
--   - Sin RLS nuevo: ni cost_centers ni infrastructure_items tienen `tenant_id` (no entran en el
--     patrón de 2026-08-05_tenant_rls.sql); su aislamiento es por practice_id, que la API valida.
--   - No tiene historia nueva: ninguna de las dos tablas es nueva.
--   - No migra `location_text` a `care_space_id`: es texto libre, no hay forma fiable de resolverlo.
--   - No elige el centro de costo de un cargo: «la unidad dueña del espacio» sale de
--     practice.space_unit_assignments y lo resuelve la API.
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - unidades con más de un centro de costo activo;
--   - centros de costo o activos que ya apuntan a una unidad / espacio de OTRA práctica.
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas +2 · FKs +2 · índices +4 (2 IX + 2 UX, uno de ellos parcial) · triggers +5 (2 sobre
--   las tablas hijas, 3 sobre sedes / espacios / unidades) · funciones +5
-- ============================================================================

BEGIN;

-- Las comprobaciones leen tablas con RLS forzada (practice.*).
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 1. columnas nuevas
-- (de SQL/16_accounting/02_tables.sql)
ALTER TABLE "accounting"."cost_centers"
    ADD COLUMN IF NOT EXISTS "clinical_unit_id" uuid;

ALTER TABLE "accounting"."infrastructure_items"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

-- ------------------------------------------------------------- 2. FKs
-- (de SQL/16_accounting/90_fk_deferred.sql)
-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)
-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 3. precondiciones
DO $$
DECLARE
    n_dup  integer;
    n_cc   integer;
    n_item integer;
BEGIN
    SELECT count(*) INTO n_dup
      FROM (SELECT 1 FROM "accounting"."cost_centers"
             WHERE "clinical_unit_id" IS NOT NULL
               AND "status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
             GROUP BY "clinical_unit_id" HAVING count(*) > 1) d;

    SELECT count(*) INTO n_cc
      FROM "accounting"."cost_centers" cc
      JOIN "practice"."clinical_units" cu ON cu."id" = cc."clinical_unit_id"
      JOIN "practice"."practice_sites" ps ON ps."id" = cu."practice_site_id"
     WHERE ps."practice_id" <> cc."practice_id";

    SELECT count(*) INTO n_item
      FROM "accounting"."infrastructure_items" ii
      JOIN "practice"."care_spaces" cs ON cs."id" = ii."care_space_id"
      JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
     WHERE ps."practice_id" <> ii."practice_id";

    IF n_dup > 0 OR n_cc > 0 OR n_item > 0 THEN
        RAISE EXCEPTION 'F5f contabilidad: datos que violan las reglas nuevas — unidades con más de un centro de costo activo=%, centros de costo con unidad de otra práctica=%, activos con espacio de otra práctica=%. No se toca ningún dato; corregirlos a mano y volver a aplicar.',
            n_dup, n_cc, n_item;
    END IF;
END $$;

-- ------------------------------------------------------------- 4. índices
-- (de SQL/16_accounting/04_indexes.sql)
CREATE INDEX IF NOT EXISTS "ix_cost_centers_clinical_unit_id" ON "accounting"."cost_centers" ("clinical_unit_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cost_centers_practice_id_id" ON "accounting"."cost_centers" ("practice_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cost_centers_unit_active" ON "accounting"."cost_centers" ("clinical_unit_id") WHERE clinical_unit_id IS NOT NULL AND status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';
CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_care_space_id" ON "accounting"."infrastructure_items" ("care_space_id");

-- ------------------------------------------------------------- 5. triggers de misma práctica
-- SECURITY INVOKER a propósito (como F1b / F5 operaciones). ERRCODE foreign_key_violation (23503).

-- 5a. cost_centers.clinical_unit_id → unidad de una sede de la misma práctica del centro de costo.
CREATE OR REPLACE FUNCTION "accounting"."cost_centers_assert_unit_practice"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    p_unidad uuid;
BEGIN
    IF NEW."clinical_unit_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT ps."practice_id" INTO p_unidad
      FROM "practice"."clinical_units" cu
      JOIN "practice"."practice_sites" ps ON ps."id" = cu."practice_site_id"
     WHERE cu."id" = NEW."clinical_unit_id";
    IF p_unidad IS DISTINCT FROM NEW."practice_id" THEN
        RAISE EXCEPTION 'cost_centers.clinical_unit_id: la unidad no existe en la práctica del centro de costo'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_cost_centers_unit_practice" ON "accounting"."cost_centers";
CREATE TRIGGER "trg_cost_centers_unit_practice"
    BEFORE INSERT OR UPDATE OF "practice_id", "clinical_unit_id"
    ON "accounting"."cost_centers"
    FOR EACH ROW EXECUTE FUNCTION "accounting"."cost_centers_assert_unit_practice"();

-- 5b. infrastructure_items.care_space_id → espacio de una sede de la misma práctica del activo.
CREATE OR REPLACE FUNCTION "accounting"."infrastructure_items_assert_space_practice"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    p_espacio uuid;
BEGIN
    IF NEW."care_space_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT ps."practice_id" INTO p_espacio
      FROM "practice"."care_spaces" cs
      JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
     WHERE cs."id" = NEW."care_space_id";
    IF p_espacio IS DISTINCT FROM NEW."practice_id" THEN
        RAISE EXCEPTION 'infrastructure_items.care_space_id: el espacio no existe en la práctica del activo'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_infrastructure_items_space_practice" ON "accounting"."infrastructure_items";
CREATE TRIGGER "trg_infrastructure_items_space_practice"
    BEFORE INSERT OR UPDATE OF "practice_id", "care_space_id"
    ON "accounting"."infrastructure_items"
    FOR EACH ROW EXECUTE FUNCTION "accounting"."infrastructure_items_assert_space_practice"();

-- ------------------------------------------------------------- 5c. el invariante, en la otra dirección
-- SECURITY INVOKER con `SET app.system_context = 'true'` a nivel de función (se restaura sola al
-- salir): el RLS no debe esconder a los dependientes. Sólo se consultan los dependientes del propio
-- espacio / unidad / sede que se está actualizando; el mensaje no lleva ids ni datos.
CREATE OR REPLACE FUNCTION "accounting"."care_spaces_guard_accounting_practice"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
SET app.system_context = 'true'
AS $fn$
DECLARE
    p_old uuid;
    p_new uuid;
BEGIN
    IF NEW."practice_site_id" IS NOT DISTINCT FROM OLD."practice_site_id" THEN
        RETURN NEW;
    END IF;
    SELECT "practice_id" INTO p_old FROM "practice"."practice_sites" WHERE "id" = OLD."practice_site_id";
    SELECT "practice_id" INTO p_new FROM "practice"."practice_sites" WHERE "id" = NEW."practice_site_id";
    IF p_new IS NOT DISTINCT FROM p_old THEN
        RETURN NEW;
    END IF;
    IF EXISTS (SELECT 1 FROM "accounting"."infrastructure_items" WHERE "care_space_id" = OLD."id") THEN
        RAISE EXCEPTION 'practice.care_spaces: el espacio tiene activos contables ubicados en él y no puede pasar a una sede de otra práctica'
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_care_spaces_accounting_dependents" ON "practice"."care_spaces";
CREATE TRIGGER "trg_care_spaces_accounting_dependents"
    BEFORE UPDATE OF "practice_site_id"
    ON "practice"."care_spaces"
    FOR EACH ROW EXECUTE FUNCTION "accounting"."care_spaces_guard_accounting_practice"();

CREATE OR REPLACE FUNCTION "accounting"."clinical_units_guard_accounting_practice"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
SET app.system_context = 'true'
AS $fn$
DECLARE
    p_old uuid;
    p_new uuid;
BEGIN
    IF NEW."practice_site_id" IS NOT DISTINCT FROM OLD."practice_site_id" THEN
        RETURN NEW;
    END IF;
    SELECT "practice_id" INTO p_old FROM "practice"."practice_sites" WHERE "id" = OLD."practice_site_id";
    SELECT "practice_id" INTO p_new FROM "practice"."practice_sites" WHERE "id" = NEW."practice_site_id";
    IF p_new IS NOT DISTINCT FROM p_old THEN
        RETURN NEW;
    END IF;
    IF EXISTS (SELECT 1 FROM "accounting"."cost_centers" WHERE "clinical_unit_id" = OLD."id") THEN
        RAISE EXCEPTION 'practice.clinical_units: la unidad tiene centros de costo y no puede pasar a una sede de otra práctica'
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_clinical_units_accounting_dependents" ON "practice"."clinical_units";
CREATE TRIGGER "trg_clinical_units_accounting_dependents"
    BEFORE UPDATE OF "practice_site_id"
    ON "practice"."clinical_units"
    FOR EACH ROW EXECUTE FUNCTION "accounting"."clinical_units_guard_accounting_practice"();

CREATE OR REPLACE FUNCTION "accounting"."practice_sites_guard_accounting_practice"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
SET app.system_context = 'true'
AS $fn$
BEGIN
    IF NEW."practice_id" IS NOT DISTINCT FROM OLD."practice_id" THEN
        RETURN NEW;
    END IF;
    IF EXISTS (SELECT 1 FROM "accounting"."infrastructure_items" ii
                 JOIN "practice"."care_spaces" cs ON cs."id" = ii."care_space_id"
                WHERE cs."practice_site_id" = OLD."id")
       OR EXISTS (SELECT 1 FROM "accounting"."cost_centers" cc
                    JOIN "practice"."clinical_units" cu ON cu."id" = cc."clinical_unit_id"
                   WHERE cu."practice_site_id" = OLD."id") THEN
        RAISE EXCEPTION 'practice.practice_sites: la sede tiene espacios o unidades con activos o centros de costo y no puede pasar a otra práctica'
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_practice_sites_accounting_dependents" ON "practice"."practice_sites";
CREATE TRIGGER "trg_practice_sites_accounting_dependents"
    BEFORE UPDATE OF "practice_id"
    ON "practice"."practice_sites"
    FOR EACH ROW EXECUTE FUNCTION "accounting"."practice_sites_guard_accounting_practice"();

-- ------------------------------------------------------------- 6. verificación
DO $$
DECLARE
    n_cols integer;
    n_fk   integer;
    n_idx  integer;
    n_part integer;
    n_trg  integer;
    n_fn   integer;
BEGIN
    SELECT count(*) INTO n_cols FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('accounting', 'cost_centers', 'clinical_unit_id'),
            ('accounting', 'infrastructure_items', 'care_space_id'));

    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_cost_centers_clinical_unit_id', 'fk_infrastructure_items_care_space_id');

    SELECT count(*) INTO n_idx FROM pg_indexes
     WHERE (schemaname, indexname) IN (
            ('accounting', 'ix_cost_centers_clinical_unit_id'),
            ('accounting', 'ux_cost_centers_practice_id_id'),
            ('accounting', 'ux_cost_centers_unit_active'),
            ('accounting', 'ix_infrastructure_items_care_space_id'));

    SELECT count(*) INTO n_part FROM pg_indexes
     WHERE schemaname = 'accounting' AND indexname = 'ux_cost_centers_unit_active'
       AND indexdef LIKE 'CREATE UNIQUE INDEX%' AND indexdef LIKE '%clinical_unit_id IS NOT NULL%'
       AND indexdef LIKE '%38a1d301-f40d-5b17-a695-5e6d605f8b19%';

    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal
       AND tgname IN ('trg_cost_centers_unit_practice', 'trg_infrastructure_items_space_practice',
                      'trg_care_spaces_accounting_dependents', 'trg_clinical_units_accounting_dependents',
                      'trg_practice_sites_accounting_dependents');

    SELECT count(*) INTO n_fn FROM unnest(ARRAY[
            'accounting.cost_centers_assert_unit_practice()', 'accounting.infrastructure_items_assert_space_practice()',
            'accounting.care_spaces_guard_accounting_practice()', 'accounting.clinical_units_guard_accounting_practice()',
            'accounting.practice_sites_guard_accounting_practice()']) f
     WHERE to_regprocedure(f) IS NOT NULL;

    IF n_cols <> 2 OR n_fk <> 2 OR n_idx <> 4 OR n_part <> 1 OR n_trg <> 5 OR n_fn <> 5 THEN
        RAISE EXCEPTION 'F5f contabilidad incompleto: columnas=% (2), FK=% (2), índices=% (4), único parcial de unidad activa=% (1), triggers=% (5), funciones=% (5)',
            n_cols, n_fk, n_idx, n_part, n_trg, n_fn;
    END IF;

    RAISE NOTICE 'F5f contabilidad aplicado: 2 columnas, 2 FKs validadas, 4 índices (2 únicos, 1 parcial: una unidad, un centro de costo activo), 5 triggers de misma práctica (2 al escribir la fila hija, 3 al mover sedes / espacios / unidades).';
END $$;

COMMIT;
