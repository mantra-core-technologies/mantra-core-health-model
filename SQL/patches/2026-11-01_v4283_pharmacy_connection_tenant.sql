-- ============================================================================
-- SALUD · patch v4.2.83 (pharmacy · la conexión de la farmacia es de SU tenant) sobre BD viva
-- Fecha: 2026-11-01
-- Idempotente: se puede volver a correr; la segunda pasada no cambia nada.
-- UNA sola transacción (BEGIN … COMMIT). Va DESPUÉS de 2026-10-31_v4283_pharmacy_connection_fk.sql.
--
-- Contexto: v4.2.83 hizo que pharmacy.pharmacy_integration_connections.connection_id
-- referencie integrations.provider_connections (id). La FK simple no impide que una farmacia
-- de un tenant use la conexión (credenciales, configuración) de OTRO tenant. Una FK compuesta
-- (tenant_id, connection_id) no se puede: la fila de conexión de la farmacia no tiene
-- tenant_id, lo hereda de pharmacy.pharmacies. Por eso es un disparador, como los de la
-- integración F2–F5 (2026-10-31_infraestructura_f2_f5_integracion.sql). gen_ddl.py no expresa
-- disparadores: también hace falta en una reconstrucción desde cero.
--
-- QUÉ CREA
--   pharmacy.pharmacy_integration_connections_assert_connection_tenant()
--     + trg_pharmacy_integration_connections_connection_tenant
--       (BEFORE INSERT OR UPDATE OF pharmacy_id, connection_id): si connection_id no es nulo,
--       la conexión tiene que existir y ser del tenant de la farmacia. Nulo pasa (modo manual).
--   pharmacy.pharmacies_assert_connection_tenant()
--     + trg_pharmacies_connection_tenant (BEFORE UPDATE OF tenant_id ON pharmacy.pharmacies)
--   integrations.provider_connections_assert_pharmacy_tenant()
--     + trg_provider_connections_pharmacy_tenant (BEFORE UPDATE OF tenant_id ON
--       integrations.provider_connections)
--       Las dos últimas cierran el otro lado: cambiar el tenant de la farmacia o de la
--       conexión no puede dejar un cruce que el primer disparador habría rechazado.
--   Error: ERRCODE foreign_key_violation (23503), como los disparadores de F2–F5.
--
-- ABORTA (RAISE EXCEPTION, sin cambios) si ya hay filas que cruzan tenant: lista hasta 20.
-- No las corrige solo, porque elegir otra conexión o dejarla en nulo es una decisión de
-- operación; para modo manual: UPDATE … SET connection_id = NULL WHERE id IN (…).
--
-- REVERSA
--   BEGIN;
--   DROP TRIGGER IF EXISTS "trg_pharmacy_integration_connections_connection_tenant" ON "pharmacy"."pharmacy_integration_connections";
--   DROP TRIGGER IF EXISTS "trg_pharmacies_connection_tenant" ON "pharmacy"."pharmacies";
--   DROP TRIGGER IF EXISTS "trg_provider_connections_pharmacy_tenant" ON "integrations"."provider_connections";
--   DROP FUNCTION IF EXISTS "pharmacy"."pharmacy_integration_connections_assert_connection_tenant"();
--   DROP FUNCTION IF EXISTS "pharmacy"."pharmacies_assert_connection_tenant"();
--   DROP FUNCTION IF EXISTS "integrations"."provider_connections_assert_pharmacy_tenant"();
--   COMMIT;
-- ============================================================================

BEGIN;

-- ------------------------------------------------------------- precondiciones
DO $$
DECLARE
    n integer;
    detalle text;
BEGIN
    IF to_regclass('"integrations"."provider_connections"') IS NULL
       OR to_regclass('"pharmacy"."pharmacy_integration_connections"') IS NULL
       OR to_regclass('"pharmacy"."pharmacies"') IS NULL THEN
        RAISE EXCEPTION 'v4.2.83 (tenant de la conexión de farmacia): faltan tablas de los módulos 12/24.';
    END IF;

    SELECT count(*), string_agg(x, '; ') INTO n, detalle FROM (
        SELECT format('pharmacy_integration_connections %s (farmacia %s, tenant %s) → conexión %s (tenant %s)',
                      pic.id, ph.id, ph.tenant_id, pc.id, pc.tenant_id) x
          FROM "pharmacy"."pharmacy_integration_connections" pic
          JOIN "pharmacy"."pharmacies" ph ON ph.id = pic.pharmacy_id
          JOIN "integrations"."provider_connections" pc ON pc.id = pic.connection_id
         WHERE pc.tenant_id IS DISTINCT FROM ph.tenant_id
         LIMIT 20
    ) q;
    IF n > 0 THEN
        RAISE EXCEPTION 'v4.2.83: % conexión(es) de farmacia usan una conexión de otro tenant; corregilas antes de aplicar: %', n, detalle;
    END IF;
END $$;

-- ------------------------------------------------------------- disparador principal
CREATE OR REPLACE FUNCTION "pharmacy"."pharmacy_integration_connections_assert_connection_tenant"() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog, pg_temp AS $fn$
DECLARE
    t_farmacia uuid;
    t_conexion uuid;
BEGIN
    IF NEW."connection_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT ph."tenant_id" INTO t_farmacia FROM "pharmacy"."pharmacies" ph WHERE ph."id" = NEW."pharmacy_id";
    SELECT pc."tenant_id" INTO t_conexion FROM "integrations"."provider_connections" pc WHERE pc."id" = NEW."connection_id";
    IF t_conexion IS NULL OR t_farmacia IS NULL OR t_conexion IS DISTINCT FROM t_farmacia THEN
        RAISE EXCEPTION 'pharmacy_integration_connections.connection_id: la conexión no existe en el tenant de la farmacia'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_pharmacy_integration_connections_connection_tenant" ON "pharmacy"."pharmacy_integration_connections";
CREATE TRIGGER "trg_pharmacy_integration_connections_connection_tenant"
    BEFORE INSERT OR UPDATE OF "pharmacy_id", "connection_id" ON "pharmacy"."pharmacy_integration_connections"
    FOR EACH ROW EXECUTE FUNCTION "pharmacy"."pharmacy_integration_connections_assert_connection_tenant"();

-- ------------------------------------------------------------- el otro lado: cambio de tenant
CREATE OR REPLACE FUNCTION "pharmacy"."pharmacies_assert_connection_tenant"() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog, pg_temp AS $fn$
BEGIN
    IF NEW."tenant_id" IS DISTINCT FROM OLD."tenant_id" AND EXISTS (
        SELECT 1
          FROM "pharmacy"."pharmacy_integration_connections" pic
          JOIN "integrations"."provider_connections" pc ON pc."id" = pic."connection_id"
         WHERE pic."pharmacy_id" = NEW."id"
           AND pc."tenant_id" IS DISTINCT FROM NEW."tenant_id"
    ) THEN
        RAISE EXCEPTION 'pharmacies.tenant_id: la farmacia quedaría usando una conexión de integraciones de otro tenant'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_pharmacies_connection_tenant" ON "pharmacy"."pharmacies";
CREATE TRIGGER "trg_pharmacies_connection_tenant"
    BEFORE UPDATE OF "tenant_id" ON "pharmacy"."pharmacies"
    FOR EACH ROW EXECUTE FUNCTION "pharmacy"."pharmacies_assert_connection_tenant"();

CREATE OR REPLACE FUNCTION "integrations"."provider_connections_assert_pharmacy_tenant"() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog, pg_temp AS $fn$
BEGIN
    IF NEW."tenant_id" IS DISTINCT FROM OLD."tenant_id" AND EXISTS (
        SELECT 1
          FROM "pharmacy"."pharmacy_integration_connections" pic
          JOIN "pharmacy"."pharmacies" ph ON ph."id" = pic."pharmacy_id"
         WHERE pic."connection_id" = NEW."id"
           AND ph."tenant_id" IS DISTINCT FROM NEW."tenant_id"
    ) THEN
        RAISE EXCEPTION 'provider_connections.tenant_id: una farmacia de otro tenant usa esta conexión'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_provider_connections_pharmacy_tenant" ON "integrations"."provider_connections";
CREATE TRIGGER "trg_provider_connections_pharmacy_tenant"
    BEFORE UPDATE OF "tenant_id" ON "integrations"."provider_connections"
    FOR EACH ROW EXECUTE FUNCTION "integrations"."provider_connections_assert_pharmacy_tenant"();

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_trg integer;
BEGIN
    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgenabled <> 'D'
       AND tgname IN ('trg_pharmacy_integration_connections_connection_tenant',
                      'trg_pharmacies_connection_tenant',
                      'trg_provider_connections_pharmacy_tenant');
    IF n_trg <> 3 THEN
        RAISE EXCEPTION 'v4.2.83 (tenant de la conexión de farmacia): se esperaban 3 disparadores activos, hay %', n_trg;
    END IF;
END $$;

COMMIT;
