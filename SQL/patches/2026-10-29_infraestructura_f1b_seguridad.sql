-- ============================================================================
-- SALUD · patch v4.2.67b (infraestructura hospitalaria F1b · endurecimiento de seguridad)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F0-F1.md §1 y «Desvíos» (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql. Idempotente (ADD COLUMN IF NOT
-- EXISTS / CREATE … IF NOT EXISTS / FK con `duplicate_object` / DROP … IF EXISTS /
-- CREATE OR REPLACE). Se puede aplicar N veces; la segunda pasada no cambia nada.
--
-- Contexto: lo que sí expresan los .puml (columnas, NOT NULL, FKs simples, índices) ya lo
-- emite gen_ddl.py en SQL/14_practice, SQL/10_audit y SQL/22_organization_extensions, y
-- esas sentencias se copiaron de ahí. Lo que el generador NO sabe expresar va solo acá,
-- igual que el RLS: FKs compuestas, triggers, CHECK de guarda, REVOKE/GRANT y políticas.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql (postgres-init de la API
-- aplica los patches en orden después del DDL).
--
-- QUÉ CIERRA (revisión de seguridad de F1).
--   1. Aislamiento entre tenants en las REFERENCIAS. Una fila hija podía apuntar a un padre
--      de otro tenant (el RLS filtra filas, no valida a dónde apunta una FK: la FK simple se
--      verifica sin RLS). Ahora cada padre con tenant expone UNIQUE (tenant_id, id) y el hijo
--      lo referencia con FK compuesta (tenant_id, x_id): la base rechaza el cruce.
--        practice_sites (tenant_id, practice_id)            → practices
--        clinical_units (tenant_id, practice_site_id)       → practice_sites
--        clinical_units (tenant_id, parent_unit_id)         → clinical_units
--        care_spaces    (tenant_id, practice_site_id)       → practice_sites
--        care_spaces    (tenant_id, parent_space_id)        → care_spaces
--        care_spaces    (tenant_id, clinical_unit_id)       → clinical_units
--        space_unit_assignments (tenant_id, care_space_id / clinical_unit_id)
--        site_declared_capacities (tenant_id, practice_site_id)
--        organization_extensions.facility_licenses (tenant_id, practice_site_id / clinical_unit_id)
--        audit.{practice_sites,clinical_units,care_spaces}_history (tenant_id, <origen>_id)
--      practice.healthcare_services no tiene tenant_id (cuelga de practices): para
--      facility_licenses.healthcare_service_id la garantía es un trigger que compara con
--      practices.tenant_id del servicio.
--      clinical_units.tenant_id y care_spaces.tenant_id pasan a NOT NULL.
--   2. snis_code como oráculo / squatting entre tenants. El único global pasa a ser parcial
--      sobre los códigos VERIFICADOS por la plataforma (`snis_verified_at IS NOT NULL`); sin
--      verificar, dos tenants pueden declarar el mismo código. Índice no único
--      (tenant_id, snis_code) para las búsquedas del tenant. Un trigger impide que el rol de
--      aplicación escriba `snis_verified_*` fuera del contexto SYSTEM y borra la verificación
--      cuando cambia el código.
--   3. Historia sin tenant y mutable. audit.practice_sites_history, clinical_units_history y
--      care_spaces_history ganan `tenant_id NOT NULL` (backfill desde la fila de origen;
--      un trigger lo completa en INSERT si la API no lo manda), RLS tenant_isolation, y
--      mantra_app queda con SELECT, INSERT y UPDATE sólo de `valid_to` (cierre SCD-2 de la
--      revisión anterior, que HistoryRepository.append hace hoy). Un trigger rechaza DELETE
--      y todo UPDATE que no sea cerrar una vez `valid_to`, también para el rol dueño.
--   4. Alcance del orquestador: practice.site_licenses y audit.site_licenses_history
--      duplicaban organization_extensions.facility_licenses. Se eliminan (abortando si
--      tienen filas) y facility_licenses gana clinical_unit_id y healthcare_service_id.
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - practice.site_licenses / audit.site_licenses_history con filas.
--   - unidades o espacios con tenant_id NULL después del backfill desde su sede.
--   - cualquier referencia hija → padre entre tenants distintos (lista en el mensaje).
--   - filas de historia cuyo tenant no se puede derivar del origen ni del snapshot.
--   - dos sedes con el mismo snis_code ya verificado.
-- ============================================================================

BEGIN;

-- Igual que F1: el backfill y las comprobaciones leen tablas con RLS forzada.
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 0. site_licenses fuera
DO $$
DECLARE
    n bigint;
BEGIN
    IF to_regclass('audit.site_licenses_history') IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM "audit"."site_licenses_history"' INTO n;
        IF n > 0 THEN
            RAISE EXCEPTION 'audit.site_licenses_history tiene % fila(s): no se borra historia. Migrarlas a organization_extensions.facility_licenses a mano y volver a aplicar.', n;
        END IF;
    END IF;
    IF to_regclass('practice.site_licenses') IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM "practice"."site_licenses"' INTO n;
        IF n > 0 THEN
            RAISE EXCEPTION 'practice.site_licenses tiene % fila(s): migrarlas a organization_extensions.facility_licenses a mano y volver a aplicar.', n;
        END IF;
    END IF;
END $$;

DROP TABLE IF EXISTS "audit"."site_licenses_history";
DROP TABLE IF EXISTS "practice"."site_licenses";

-- ------------------------------------------------------------- 1. columnas nuevas
ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "snis_verified_at" timestamptz;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "snis_verified_by_user_id" uuid;

ALTER TABLE "organization_extensions"."facility_licenses"
    ADD COLUMN IF NOT EXISTS "clinical_unit_id" uuid;

ALTER TABLE "organization_extensions"."facility_licenses"
    ADD COLUMN IF NOT EXISTS "healthcare_service_id" uuid;

ALTER TABLE "audit"."practice_sites_history"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

ALTER TABLE "audit"."clinical_units_history"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

ALTER TABLE "audit"."care_spaces_history"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

-- ------------------------------------------------------------- 2. backfill de tenant_id
-- Unidades y espacios: el de su sede (lo mismo que hizo F1, para las filas que la API haya
-- creado sin tenant entre F1 y este patch). Sólo filas con NULL.
UPDATE "practice"."clinical_units" cu
   SET "tenant_id" = ps."tenant_id"
  FROM "practice"."practice_sites" ps
 WHERE ps."id" = cu."practice_site_id"
   AND cu."tenant_id" IS NULL;

UPDATE "practice"."care_spaces" cs
   SET "tenant_id" = ps."tenant_id"
  FROM "practice"."practice_sites" ps
 WHERE ps."id" = cs."practice_site_id"
   AND cs."tenant_id" IS NULL;

-- Historia: el de la fila de origen; si el origen ya no está, el que guardó la foto
-- (`tenantId` es la propiedad de la entidad MikroORM; `tenant_id`, la columna).
UPDATE "audit"."practice_sites_history" h
   SET "tenant_id" = s."tenant_id"
  FROM "practice"."practice_sites" s
 WHERE s."id" = h."practice_site_id"
   AND h."tenant_id" IS NULL;

UPDATE "audit"."clinical_units_history" h
   SET "tenant_id" = s."tenant_id"
  FROM "practice"."clinical_units" s
 WHERE s."id" = h."clinical_unit_id"
   AND h."tenant_id" IS NULL;

UPDATE "audit"."care_spaces_history" h
   SET "tenant_id" = s."tenant_id"
  FROM "practice"."care_spaces" s
 WHERE s."id" = h."care_space_id"
   AND h."tenant_id" IS NULL;

DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['practice_sites_history', 'clinical_units_history', 'care_spaces_history'] LOOP
        EXECUTE format($u$
            UPDATE "audit".%I
               SET "tenant_id" = COALESCE(data_snapshot->>'tenantId', data_snapshot->>'tenant_id')::uuid
             WHERE "tenant_id" IS NULL
               AND COALESCE(data_snapshot->>'tenantId', data_snapshot->>'tenant_id')
                   ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
        $u$, t);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 3. precondiciones
DO $$
DECLARE
    n_null  integer;
    detalle text;
BEGIN
    SELECT string_agg(format('%s: %s', tabla, n), '; '), coalesce(sum(n), 0)
      INTO detalle, n_null
      FROM (SELECT 'practice.clinical_units' AS tabla, count(*) AS n
              FROM "practice"."clinical_units" WHERE "tenant_id" IS NULL
            UNION ALL
            SELECT 'practice.care_spaces', count(*)
              FROM "practice"."care_spaces" WHERE "tenant_id" IS NULL
            UNION ALL
            SELECT 'audit.practice_sites_history', count(*)
              FROM "audit"."practice_sites_history" WHERE "tenant_id" IS NULL
            UNION ALL
            SELECT 'audit.clinical_units_history', count(*)
              FROM "audit"."clinical_units_history" WHERE "tenant_id" IS NULL
            UNION ALL
            SELECT 'audit.care_spaces_history', count(*)
              FROM "audit"."care_spaces_history" WHERE "tenant_id" IS NULL) x
     WHERE n > 0;
    IF n_null > 0 THEN
        RAISE EXCEPTION 'v4.2.67b: % fila(s) sin tenant_id tras el backfill (%). No se puede poner NOT NULL: asignarles el tenant a mano (o borrar la fila huérfana) y volver a aplicar.', n_null, detalle
            USING ERRCODE = 'not_null_violation';
    END IF;
END $$;

-- Referencias cruzadas entre tenants: se listan todas y se aborta. Decidir cuál de los dos
-- tenants es el correcto no le toca al patch.
DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'practice_sites.practice_id', c."id" FROM "practice"."practice_sites" c
          JOIN "practice"."practices" p ON p."id" = c."practice_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'clinical_units.practice_site_id', c."id" FROM "practice"."clinical_units" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'clinical_units.parent_unit_id', c."id" FROM "practice"."clinical_units" c
          JOIN "practice"."clinical_units" p ON p."id" = c."parent_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_spaces.practice_site_id', c."id" FROM "practice"."care_spaces" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_spaces.parent_space_id', c."id" FROM "practice"."care_spaces" c
          JOIN "practice"."care_spaces" p ON p."id" = c."parent_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_spaces.clinical_unit_id', c."id" FROM "practice"."care_spaces" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'space_unit_assignments.care_space_id', c."id" FROM "practice"."space_unit_assignments" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'space_unit_assignments.clinical_unit_id', c."id" FROM "practice"."space_unit_assignments" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'site_declared_capacities.practice_site_id', c."id" FROM "practice"."site_declared_capacities" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'facility_licenses.practice_site_id', c."id" FROM "organization_extensions"."facility_licenses" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'facility_licenses.clinical_unit_id', c."id" FROM "organization_extensions"."facility_licenses" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'facility_licenses.healthcare_service_id', c."id" FROM "organization_extensions"."facility_licenses" c
          JOIN "practice"."healthcare_services" hs ON hs."id" = c."healthcare_service_id"
          JOIN "practice"."practices" p ON p."id" = hs."practice_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'practice_sites_history.practice_site_id', c."history_id" FROM "audit"."practice_sites_history" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'clinical_units_history.clinical_unit_id', c."history_id" FROM "audit"."clinical_units_history" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_spaces_history.care_space_id', c."history_id" FROM "audit"."care_spaces_history" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'v4.2.67b: hay referencias a un padre de OTRO tenant en % relación(es): %. No se crean las FK compuestas y no se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

DO $$
DECLARE
    n_dup integer;
BEGIN
    SELECT count(*) INTO n_dup
      FROM (SELECT "snis_code" FROM "practice"."practice_sites"
             WHERE "snis_code" IS NOT NULL AND "snis_verified_at" IS NOT NULL
             GROUP BY 1 HAVING count(*) > 1) d;
    IF n_dup > 0 THEN
        RAISE EXCEPTION 'v4.2.67b: % código(s) SNIS verificados en más de una sede; resolver a mano.', n_dup
            USING ERRCODE = 'unique_violation';
    END IF;
END $$;

ALTER TABLE "practice"."clinical_units" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "practice"."care_spaces" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "audit"."practice_sites_history" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "audit"."clinical_units_history" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "audit"."care_spaces_history" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- 4. índices (copiados de 04_indexes)
CREATE UNIQUE INDEX IF NOT EXISTS "ux_practices_tenant_id_id" ON "practice"."practices" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_tenant_id_snis_code" ON "practice"."practice_sites" ("tenant_id", "snis_code");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_snis_verified_by_user_id" ON "practice"."practice_sites" ("snis_verified_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practice_sites_tenant_id_id" ON "practice"."practice_sites" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_clinical_units_tenant_id_id" ON "practice"."clinical_units" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_spaces_tenant_id_id" ON "practice"."care_spaces" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_clinical_unit_id" ON "organization_extensions"."facility_licenses" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_healthcare_service_id" ON "organization_extensions"."facility_licenses" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_history_tenant_id" ON "audit"."practice_sites_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_history_tenant_id" ON "audit"."clinical_units_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_history_tenant_id" ON "audit"."care_spaces_history" ("tenant_id");

-- El único global del SNIS cambia de predicado: un CREATE … IF NOT EXISTS no reemplaza el
-- índice de F1 (mismo nombre), así que se recrea sólo si todavía tiene el predicado viejo.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes
                    WHERE schemaname = 'practice' AND indexname = 'ux_practice_sites_snis_code'
                      AND indexdef LIKE '%snis_verified_at IS NOT NULL%') THEN
        DROP INDEX IF EXISTS "practice"."ux_practice_sites_snis_code";
        CREATE UNIQUE INDEX "ux_practice_sites_snis_code" ON "practice"."practice_sites" ("snis_code") WHERE snis_code IS NOT NULL AND snis_verified_at IS NOT NULL;
    END IF;
END $$;

-- ------------------------------------------------------------- 5. FKs simples (copiadas de 90_fk_deferred)
-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."practice_sites"
        ADD CONSTRAINT "fk_practice_sites_snis_verified_by_user_id" FOREIGN KEY ("snis_verified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."practice_sites_history"
        ADD CONSTRAINT "fk_practice_sites_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."clinical_units_history"
        ADD CONSTRAINT "fk_clinical_units_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."care_spaces_history"
        ADD CONSTRAINT "fk_care_spaces_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 6. FKs compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id). MATCH SIMPLE: si x_id es NULL no se exige nada,
-- así que sirven también para los padres opcionales. Conviven con la FK simple generada.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.practice_sites',                   'fk_practice_sites_tenant_practice',           'practice_id',      'practice.practices'),
            ('practice.clinical_units',                   'fk_clinical_units_tenant_site',               'practice_site_id', 'practice.practice_sites'),
            ('practice.clinical_units',                   'fk_clinical_units_tenant_parent',             'parent_unit_id',   'practice.clinical_units'),
            ('practice.care_spaces',                      'fk_care_spaces_tenant_site',                  'practice_site_id', 'practice.practice_sites'),
            ('practice.care_spaces',                      'fk_care_spaces_tenant_parent',                'parent_space_id',  'practice.care_spaces'),
            ('practice.care_spaces',                      'fk_care_spaces_tenant_unit',                  'clinical_unit_id', 'practice.clinical_units'),
            ('practice.space_unit_assignments',           'fk_space_unit_assignments_tenant_space',      'care_space_id',    'practice.care_spaces'),
            ('practice.space_unit_assignments',           'fk_space_unit_assignments_tenant_unit',       'clinical_unit_id', 'practice.clinical_units'),
            ('practice.site_declared_capacities',         'fk_site_declared_capacities_tenant_site',     'practice_site_id', 'practice.practice_sites'),
            ('organization_extensions.facility_licenses', 'fk_facility_licenses_tenant_site',            'practice_site_id', 'practice.practice_sites'),
            ('organization_extensions.facility_licenses', 'fk_facility_licenses_tenant_unit',            'clinical_unit_id', 'practice.clinical_units'),
            ('audit.practice_sites_history',              'fk_practice_sites_history_tenant_source',     'practice_site_id', 'practice.practice_sites'),
            ('audit.clinical_units_history',              'fk_clinical_units_history_tenant_source',     'clinical_unit_id', 'practice.clinical_units'),
            ('audit.care_spaces_history',                 'fk_care_spaces_history_tenant_source',        'care_space_id',    'practice.care_spaces')
        ) AS v(hijo, nombre, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 7. triggers
-- 7a. facility_licenses.healthcare_service_id: healthcare_services no tiene tenant_id; el
-- tenant del servicio es el de su práctica. SECURITY INVOKER a propósito: con RLS, un
-- servicio de otro tenant ni siquiera se ve y cae en el mismo error genérico.
CREATE OR REPLACE FUNCTION "organization_extensions"."facility_licenses_assert_service_tenant"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    t_servicio uuid;
BEGIN
    IF NEW."healthcare_service_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT p."tenant_id" INTO t_servicio
      FROM "practice"."healthcare_services" hs
      JOIN "practice"."practices" p ON p."id" = hs."practice_id"
     WHERE hs."id" = NEW."healthcare_service_id";
    IF t_servicio IS DISTINCT FROM NEW."tenant_id" THEN
        RAISE EXCEPTION 'facility_licenses.healthcare_service_id: el servicio no existe en el tenant de la habilitación'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_facility_licenses_service_tenant" ON "organization_extensions"."facility_licenses";
CREATE TRIGGER "trg_facility_licenses_service_tenant"
    BEFORE INSERT OR UPDATE OF "tenant_id", "healthcare_service_id"
    ON "organization_extensions"."facility_licenses"
    FOR EACH ROW EXECUTE FUNCTION "organization_extensions"."facility_licenses_assert_service_tenant"();

-- 7b. practice_sites.snis_verified_*: sólo la plataforma verifica. El rol de aplicación
-- (sin BYPASSRLS) sólo puede escribirlas con `app.system_context = 'true'`, que la API abre
-- en el caso de uso de SECURITY_ADMIN/SUPERADMIN. Cambiar el código borra la verificación.
CREATE OR REPLACE FUNCTION "practice"."practice_sites_guard_snis_verification"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    tocada      boolean;
    privilegiado boolean;
BEGIN
    IF TG_OP = 'INSERT' THEN
        tocada := NEW."snis_verified_at" IS NOT NULL OR NEW."snis_verified_by_user_id" IS NOT NULL;
    ELSE
        tocada := NEW."snis_verified_at" IS DISTINCT FROM OLD."snis_verified_at"
               OR NEW."snis_verified_by_user_id" IS DISTINCT FROM OLD."snis_verified_by_user_id";
    END IF;

    IF tocada THEN
        SELECT coalesce(current_setting('app.system_context', true), '') = 'true'
               OR coalesce((SELECT r.rolsuper OR r.rolbypassrls FROM pg_roles r WHERE r.rolname = current_user), false)
          INTO privilegiado;
        IF NOT privilegiado THEN
            RAISE EXCEPTION 'practice_sites.snis_verified_*: la verificación del código SNIS la registra la plataforma'
                USING ERRCODE = 'insufficient_privilege';
        END IF;
    ELSIF TG_OP = 'UPDATE' AND NEW."snis_code" IS DISTINCT FROM OLD."snis_code" THEN
        NEW."snis_verified_at" := NULL;
        NEW."snis_verified_by_user_id" := NULL;
    END IF;

    IF NEW."snis_verified_at" IS NOT NULL AND NEW."snis_code" IS NULL THEN
        RAISE EXCEPTION 'practice_sites: no hay verificación SNIS sin snis_code'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_practice_sites_snis_verification" ON "practice"."practice_sites";
CREATE TRIGGER "trg_practice_sites_snis_verification"
    BEFORE INSERT OR UPDATE OF "snis_code", "snis_verified_at", "snis_verified_by_user_id"
    ON "practice"."practice_sites"
    FOR EACH ROW EXECUTE FUNCTION "practice"."practice_sites_guard_snis_verification"();

-- 7c. Historia: tenant por defecto desde el origen (la API actual no lo manda) y
-- «sólo inserción + cierre de valid_to». TG_ARGV: tabla de origen, columna de origen.
CREATE OR REPLACE FUNCTION "audit"."structure_history_fill_tenant"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    t uuid;
BEGIN
    IF NEW."tenant_id" IS NULL THEN
        EXECUTE format('SELECT "tenant_id" FROM %s WHERE "id" = $1', TG_ARGV[0])
           INTO t
          USING (to_jsonb(NEW) ->> TG_ARGV[1])::uuid;
        NEW."tenant_id" := t;
    END IF;
    RETURN NEW;
END $fn$;

CREATE OR REPLACE FUNCTION "audit"."structure_history_close_only"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'append-only: DELETE no permitido en %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME
            USING ERRCODE = 'restrict_violation';
    END IF;
    IF OLD."valid_to" IS NOT NULL
       OR (to_jsonb(NEW) - 'valid_to') IS DISTINCT FROM (to_jsonb(OLD) - 'valid_to') THEN
        RAISE EXCEPTION 'append-only: en %.% sólo se cierra valid_to de la revisión vigente, una vez', TG_TABLE_SCHEMA, TG_TABLE_NAME
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NEW;
END $fn$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice_sites_history', 'practice.practice_sites', 'practice_site_id'),
            ('clinical_units_history', 'practice.clinical_units', 'clinical_unit_id'),
            ('care_spaces_history',    'practice.care_spaces',    'care_space_id')
        ) AS v(historia, origen, columna)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_fill_tenant ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_fill_tenant BEFORE INSERT ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_fill_tenant"(%L, %L)',
                       r.historia, r.origen, r.columna);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_close_only ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_close_only BEFORE UPDATE OR DELETE ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_close_only"()',
                       r.historia);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 8. privilegios y RLS
-- mantra_app: SELECT e INSERT sobre la historia, y UPDATE sólo de la columna valid_to
-- (HistoryRepository.append cierra la revisión anterior). Si 2026-08-05_tenant_rls.sql se
-- reaplica después (GRANT … ON ALL TABLES), vuelve a dar UPDATE/DELETE de tabla: el
-- trigger trg_close_only sigue rechazando todo lo que no sea cerrar valid_to. Reaplicar
-- este patch deja otra vez los privilegios mínimos.
DO $$
DECLARE
    t text;
    historias text[] := ARRAY[
        'audit.practice_sites_history',
        'audit.clinical_units_history',
        'audit.care_spaces_history'
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    -- Texto exacto de la política de 2026-08-05_tenant_rls.sql (ese patch también la pondría
    -- sola ahora que estas tablas tienen tenant_id).
    FOREACH t IN ARRAY historias LOOP
        EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %s FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %s', t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %s
          USING (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, t);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 9. verificación
DO $$
DECLARE
    n_drop  integer;
    n_nn    integer;
    n_cols  integer;
    n_fkc   integer;
    n_fks   integer;
    n_ux    integer;
    n_snis  integer;
    n_trg   integer;
    n_rls   integer;
    n_upd   integer;
BEGIN
    SELECT (to_regclass('practice.site_licenses') IS NOT NULL)::int
         + (to_regclass('audit.site_licenses_history') IS NOT NULL)::int INTO n_drop;

    SELECT count(*) INTO n_nn FROM information_schema.columns
     WHERE column_name = 'tenant_id' AND is_nullable = 'NO'
       AND (table_schema, table_name) IN (('practice', 'clinical_units'), ('practice', 'care_spaces'),
            ('audit', 'practice_sites_history'), ('audit', 'clinical_units_history'), ('audit', 'care_spaces_history'));

    SELECT count(*) INTO n_cols FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('practice', 'practice_sites', 'snis_verified_at'), ('practice', 'practice_sites', 'snis_verified_by_user_id'),
            ('organization_extensions', 'facility_licenses', 'clinical_unit_id'),
            ('organization_extensions', 'facility_licenses', 'healthcare_service_id'));

    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_practice_sites_tenant_practice', 'fk_clinical_units_tenant_site',
            'fk_clinical_units_tenant_parent', 'fk_care_spaces_tenant_site', 'fk_care_spaces_tenant_parent',
            'fk_care_spaces_tenant_unit', 'fk_space_unit_assignments_tenant_space',
            'fk_space_unit_assignments_tenant_unit', 'fk_site_declared_capacities_tenant_site',
            'fk_facility_licenses_tenant_site', 'fk_facility_licenses_tenant_unit',
            'fk_practice_sites_history_tenant_source', 'fk_clinical_units_history_tenant_source',
            'fk_care_spaces_history_tenant_source');

    SELECT count(*) INTO n_fks FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_practice_sites_snis_verified_by_user_id', 'fk_facility_licenses_clinical_unit_id',
            'fk_facility_licenses_healthcare_service_id', 'fk_practice_sites_history_tenant_id',
            'fk_clinical_units_history_tenant_id', 'fk_care_spaces_history_tenant_id');

    SELECT count(*) INTO n_ux FROM pg_indexes
     WHERE indexname IN ('ux_practices_tenant_id_id', 'ux_practice_sites_tenant_id_id',
            'ux_clinical_units_tenant_id_id', 'ux_care_spaces_tenant_id_id', 'ix_practice_sites_tenant_id_snis_code');

    SELECT count(*) INTO n_snis FROM pg_indexes
     WHERE schemaname = 'practice' AND indexname = 'ux_practice_sites_snis_code'
       AND indexdef LIKE '%snis_verified_at IS NOT NULL%';

    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgname IN ('trg_facility_licenses_service_tenant',
            'trg_practice_sites_snis_verification', 'trg_fill_tenant', 'trg_close_only');

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE n.nspname = 'audit' AND c.relname IN ('practice_sites_history', 'clinical_units_history', 'care_spaces_history')
       AND c.relrowsecurity AND c.relforcerowsecurity;

    n_upd := 0;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_upd FROM unnest(ARRAY['audit.practice_sites_history',
                'audit.clinical_units_history', 'audit.care_spaces_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE') OR has_table_privilege('mantra_app', t, 'DELETE');
    END IF;

    IF n_drop <> 0 OR n_nn <> 5 OR n_cols <> 4 OR n_fkc <> 14 OR n_fks <> 6 OR n_ux <> 5
       OR n_snis <> 1 OR n_trg <> 8 OR n_rls <> 3 OR n_upd <> 0 THEN
        RAISE EXCEPTION
            'v4.2.67b incompleto: site_licenses vivas=% (0), tenant NOT NULL=% (5), columnas=% (4), FK compuestas=% (14), FK simples=% (6), índices=% (5), único SNIS verificado=% (1), triggers=% (8), RLS historia=% (3), historia con UPDATE/DELETE de tabla para mantra_app=% (0)',
            n_drop, n_nn, n_cols, n_fkc, n_fks, n_ux, n_snis, n_trg, n_rls, n_upd;
    END IF;

    RAISE NOTICE 'v4.2.67b aplicado: 14 FK compuestas por tenant, 5 tenant_id NOT NULL, SNIS único sólo si verificado, historia con RLS y solo inserción (+ cierre de valid_to), site_licenses retiradas.';
END $$;

COMMIT;
