-- ============================================================================
-- SALUD · patch v4.2.67c (infraestructura hospitalaria F1c · tenant de los servicios de salud)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F0-F1.md «Desvíos» y CONTRATO-F2-F5.md «Desvíos» (M-F2) (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1b_seguridad.sql y ANTES de los de F2/F5.
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con `duplicate_object` /
-- DROP … IF EXISTS / CREATE OR REPLACE). La segunda pasada no cambia nada.
--
-- QUÉ CIERRA (revisión de seguridad de F1b). F1b protegía
-- organization_extensions.facility_licenses.healthcare_service_id con un trigger del lado de la
-- habilitación (trg_facility_licenses_service_tenant) que comparaba con el tenant de la práctica
-- del servicio. Se eludía cambiando después practice.healthcare_services.practice_id a una
-- práctica de otro tenant: el trigger no mira ese UPDATE. Ahora:
--   - practice.healthcare_services gana `tenant_id NOT NULL` (backfill desde practices) y
--     UNIQUE (tenant_id, id);
--   - FK compuestas (tenant_id, practice_id) → practices, (tenant_id, practice_site_id) →
--     practice_sites, (tenant_id, clinical_unit_id) → clinical_units: el servicio no puede
--     colgar de un padre de otro tenant, y su tenant no puede cambiar sin romperlas;
--   - facility_licenses (tenant_id, healthcare_service_id) → healthcare_services (tenant_id, id),
--     que reemplaza al trigger (se borra con su función);
--   - RLS tenant_isolation en healthcare_services;
--   - trigger BEFORE INSERT que completa tenant_id desde la práctica si la API todavía no lo
--     manda (la entidad MikroORM actual no tiene la columna). Si lo manda distinto del de la
--     práctica, la FK compuesta lo rechaza (23503).
-- Lo que sí expresa el .puml (columna, índices, FK simple a directory.tenants) está en
-- SQL/14_practice generado; acá se copia y se agrega lo que gen_ddl no expresa.
--
-- PRECONDICIONES (abortan sin tocar nada):
--   - servicios cuya práctica no existe (tenant_id NULL tras el backfill);
--   - servicios cuya sede o unidad es de otro tenant que su práctica;
--   - habilitaciones cuyo servicio es de otro tenant.
-- ============================================================================

BEGIN;

-- El backfill y las comprobaciones leen tablas con RLS forzada.
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 1. columna
ALTER TABLE "practice"."healthcare_services"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

-- ------------------------------------------------------------- 2. backfill
UPDATE "practice"."healthcare_services" hs
   SET "tenant_id" = p."tenant_id"
  FROM "practice"."practices" p
 WHERE p."id" = hs."practice_id"
   AND hs."tenant_id" IS NULL;

-- ------------------------------------------------------------- 3. precondiciones
DO $$
DECLARE
    n integer;
BEGIN
    SELECT count(*) INTO n FROM "practice"."healthcare_services" WHERE "tenant_id" IS NULL;
    IF n > 0 THEN
        RAISE EXCEPTION 'v4.2.67c: % servicio(s) de salud sin tenant_id tras el backfill desde su práctica; corregirlos a mano y volver a aplicar.', n
            USING ERRCODE = 'not_null_violation';
    END IF;
END $$;

DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'healthcare_services.practice_id', c."id" FROM "practice"."healthcare_services" c
          JOIN "practice"."practices" p ON p."id" = c."practice_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'healthcare_services.practice_site_id', c."id" FROM "practice"."healthcare_services" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'healthcare_services.clinical_unit_id', c."id" FROM "practice"."healthcare_services" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'facility_licenses.healthcare_service_id', c."id" FROM "organization_extensions"."facility_licenses" c
          JOIN "practice"."healthcare_services" p ON p."id" = c."healthcare_service_id" WHERE p."tenant_id" <> c."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'v4.2.67c: hay referencias a un padre de OTRO tenant en % relación(es): %. No se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

ALTER TABLE "practice"."healthcare_services" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- 4. índices (copiados de 04_indexes)
CREATE INDEX IF NOT EXISTS "ix_healthcare_services_tenant_id" ON "practice"."healthcare_services" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_healthcare_services_tenant_id_id" ON "practice"."healthcare_services" ("tenant_id", "id");

-- ------------------------------------------------------------- 5. FK simple (copiada de 90_fk_deferred)
-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."healthcare_services"
        ADD CONSTRAINT "fk_healthcare_services_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 6. FK compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id). MATCH SIMPLE: si x_id es NULL no se exige nada.
-- Conviven con la FK simple generada (mismo mecanismo que 2026-10-29_infraestructura_f1b_seguridad.sql).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.healthcare_services',             'fk_healthcare_services_tenant_practice','practice_id',          'practice.practices'),
            ('practice.healthcare_services',             'fk_healthcare_services_tenant_site',    'practice_site_id',     'practice.practice_sites'),
            ('practice.healthcare_services',             'fk_healthcare_services_tenant_unit',    'clinical_unit_id',     'practice.clinical_units'),
            ('organization_extensions.facility_licenses','fk_facility_licenses_tenant_service',   'healthcare_service_id','practice.healthcare_services')
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
-- 7a. El trigger de F1b queda reemplazado por fk_facility_licenses_tenant_service. Si alguien
-- reaplica el f1b después de este patch, lo vuelve a crear: es redundante (no contradice la FK)
-- y reaplicar este patch lo borra otra vez.
DROP TRIGGER IF EXISTS "trg_facility_licenses_service_tenant" ON "organization_extensions"."facility_licenses";
DROP FUNCTION IF EXISTS "organization_extensions"."facility_licenses_assert_service_tenant"();

-- 7b. Tenant por defecto desde la práctica (genérica: la reutilizan los patches F5 para
-- accounting.cost_centers, accounting.infrastructure_items, billing.space_tariffs y
-- billing.charge_captures). Sólo completa un NULL; nunca corrige un valor mandado.
-- SECURITY INVOKER: con RLS, una práctica de otro tenant no se ve y el tenant queda NULL
-- (23502), sin revelar nada.
CREATE OR REPLACE FUNCTION "practice"."fill_tenant_from_practice"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    IF NEW."tenant_id" IS NULL AND NEW."practice_id" IS NOT NULL THEN
        SELECT p."tenant_id" INTO NEW."tenant_id"
          FROM "practice"."practices" p
         WHERE p."id" = NEW."practice_id";
    END IF;
    RETURN NEW;
END $fn$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN SELECT * FROM (VALUES
            ('practice.healthcare_services')
        ) AS v(tabla)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_fill_tenant_from_practice ON %s', r.tabla);
        EXECUTE format('CREATE TRIGGER trg_fill_tenant_from_practice BEFORE INSERT ON %s FOR EACH ROW EXECUTE FUNCTION "practice"."fill_tenant_from_practice"()', r.tabla);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 8. privilegios y RLS
DO $$
DECLARE
    t text;
    tablas text[] := ARRAY[
        'practice.healthcare_services'
    ];
    completas text[] := ARRAY[]::text[];
    solo_insercion text[] := ARRAY[]::text[];
    historias text[] := ARRAY[]::text[];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY completas LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %s TO mantra_app', t);
        END LOOP;
        -- append-only: SELECT e INSERT; nada de UPDATE/DELETE/TRUNCATE (la guarda de
        -- inmutabilidad también los rechaza, incluso al dueño).
        FOREACH t IN ARRAY solo_insercion LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
        END LOOP;
        -- historia: SELECT, INSERT y UPDATE sólo de valid_to (mismo criterio que F1b).
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    FOREACH t IN ARRAY tablas LOOP
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
    n_nn  integer;
    n_fkc integer;
    n_ux  integer;
    n_old integer;
    n_trg integer;
    n_rls integer;
BEGIN
    SELECT count(*) INTO n_nn FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'healthcare_services'
       AND column_name = 'tenant_id' AND is_nullable = 'NO';
    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_healthcare_services_tenant_practice', 'fk_healthcare_services_tenant_site',
            'fk_healthcare_services_tenant_unit', 'fk_facility_licenses_tenant_service');
    SELECT count(*) INTO n_ux FROM pg_indexes
     WHERE schemaname = 'practice' AND indexname IN ('ux_healthcare_services_tenant_id_id', 'ix_healthcare_services_tenant_id');
    SELECT count(*) INTO n_old FROM pg_trigger WHERE NOT tgisinternal AND tgname = 'trg_facility_licenses_service_tenant';
    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgname = 'trg_fill_tenant_from_practice'
       AND tgrelid = 'practice.healthcare_services'::regclass;
    SELECT count(*) INTO n_rls FROM pg_class c
      JOIN pg_policies p ON p.schemaname = 'practice' AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE c.oid = 'practice.healthcare_services'::regclass AND c.relrowsecurity AND c.relforcerowsecurity;
    IF n_nn <> 1 OR n_fkc <> 4 OR n_ux <> 2 OR n_old <> 0 OR n_trg <> 1 OR n_rls <> 1 THEN
        RAISE EXCEPTION 'v4.2.67c incompleto: tenant NOT NULL=% (1), FK compuestas=% (4), índices=% (2), trigger viejo=% (0), trigger de relleno=% (1), RLS=% (1)',
            n_nn, n_fkc, n_ux, n_old, n_trg, n_rls;
    END IF;
    RAISE NOTICE 'v4.2.67c aplicado: healthcare_services con tenant_id NOT NULL, 4 FK compuestas por tenant (incluida la habilitación por servicio) y RLS; trigger de F1b retirado.';
END $$;

COMMIT;
