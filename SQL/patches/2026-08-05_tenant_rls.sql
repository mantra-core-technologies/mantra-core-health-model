-- =============================================================================
-- Aislamiento por tenant con Row Level Security (RLS)
-- =============================================================================
-- Cierra el hallazgo #1 de la auditoría (IDOR cross-tenant sistémico): impone en
-- la propia base que ninguna consulta devuelva o escriba filas de un tenant que
-- no sea el del contexto de la petición.
--
-- Modelo:
--   * El rol de aplicación `mantra_app` NO es superusuario ni tiene BYPASSRLS, así
--     que SÍ está sujeto a las políticas (el rol `mantra`, superusuario/owner, las
--     omite y se reserva para DDL/migraciones/seed administrativo).
--   * Cada request fija `app.current_tenant_id` (GUC de sesión) tras verificar la
--     membresía del actor en `directory.tenant_memberships`. La política compara
--     `tenant_id` contra ese GUC.
--   * Cuando el GUC NO está fijado, la política falla cerrada: no permite leer
--     ni escribir ninguna fila. Migraciones, seed y trabajos cross-tenant usan
--     el rol owner o una elevación SYSTEM explícita, local a la transacción
--     (`app.system_context`).
--
-- Idempotente: se puede re-ejecutar. Cubre TODAS las tablas con `tenant_id uuid`.
--
-- -----------------------------------------------------------------------------
-- Procedencia (v4.0.9, 2026-08-05) — reconciliación de dos árboles divergentes.
--
-- Este archivo reemplaza a `2026-07-30_tenant_rls.sql`, que era la versión
-- rescatada a la raíz en v4.0.8 y había quedado atrás: creaba `mantra_app` con
-- LOGIN y una contraseña conocida escrita en el repositorio, no endurecía un rol
-- preexistente, y su política era FAIL-OPEN (sin GUC fijado permitía todo, para
-- no ser disruptiva con el código que aún no propagaba tenant).
--
-- La versión endurecida vivía solo en `mantra-core-health-api/database/`, que un
-- merge de `dev` había devuelto al repositorio de la API. Al retirar ese árbol
-- (ver `docs/architecture/ddl-sources.md`) se conserva la variante correcta: rol
-- sin credencial conocida y política fail-closed con escape explícito.
--
-- Ninguna base tenía el RLS aplicado cuando se reconcilió — verificado el
-- 2026-08-05 contra el stack `mantra-redesa`: el rol `mantra_app` no existía y
-- `pg_policies` no tenía ninguna `tenant_isolation`. No hubo, por tanto, ninguna
-- base que migrar de la política permisiva a la estricta.
--
-- Vive en SQL/patches/ —fuera de apply_all.sql— porque no se deriva de los
-- `.puml`. Se aplica a mano, y lo aplica por su cuenta `test/integration/
-- rls.int-spec.ts` para ejercerlo.
-- =============================================================================

-- 1. Rol de aplicación sujeto a RLS -------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
    -- IaC habilita LOGIN y obtiene la contraseña del gestor de secretos. La
    -- migración nunca debe crear una credencial conocida.
    CREATE ROLE mantra_app NOLOGIN
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
  ELSE
    ALTER ROLE mantra_app
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
  END IF;
END $$;

-- 2. Privilegios DML sobre todos los esquemas de negocio ----------------------
DO $$
DECLARE s text;
BEGIN
  FOR s IN
    SELECT nspname FROM pg_namespace
    WHERE nspname NOT LIKE 'pg\_%'
      AND nspname NOT IN ('information_schema')
      AND nspname NOT LIKE '\_timescaledb%'
      AND nspname NOT IN ('timescaledb_information', 'timescaledb_experimental')
  LOOP
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO mantra_app', s);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO mantra_app', s);
    EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO mantra_app', s);
    EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %I TO mantra_app', s);
    -- Objetos futuros creados por `mantra`.
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE mantra IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO mantra_app', s);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE mantra IN SCHEMA %I GRANT USAGE, SELECT ON SEQUENCES TO mantra_app', s);
  END LOOP;
END $$;

-- 3. RLS + política de aislamiento en cada tabla con `tenant_id uuid` ----------
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT c.table_schema, c.table_name
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema
     AND t.table_name  = c.table_name
     AND t.table_type  = 'BASE TABLE'
    WHERE c.column_name = 'tenant_id'
      AND c.data_type   = 'uuid'
      AND c.table_schema NOT LIKE 'pg\_%'
      AND c.table_schema NOT IN ('information_schema')
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.table_schema, r.table_name);
    EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.table_schema, r.table_name);
    EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I.%I', r.table_schema, r.table_name);
    EXECUTE format($pol$
      CREATE POLICY tenant_isolation ON %I.%I
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
    $pol$, r.table_schema, r.table_name);
  END LOOP;
END $$;
