-- ============================================================================
-- SALUD · patch: unicidad de (schema_name, table_name) en system_ops.entity_registry sobre BD viva
-- Fecha: 2026-11-01
-- Escrito a mano (un solo índice). El DDL generado de 11_system_ops todavía no lo declara: hasta que el .puml lo
-- incorpore y se suba la versión del modelo, una base nueva lo recibe por aquí (postgres-init aplica patches/ siempre).
-- Idempotente: CREATE UNIQUE INDEX IF NOT EXISTS. Se puede volver a correr.
--
-- POR QUÉ: el registro de mutabilidad tiene que tener exactamente una fila por tabla. El ciclo de purga de identidad
-- (identity_assurance) la busca por (schema_name, table_name) y exige una sola; un alta por API
-- (POST de catalogación en system_ops) creaba una segunda fila para una tabla ya sembrada. Con el índice, esa alta
-- choca con la restricción (la API la traduce a 409) en vez de duplicar.
--
-- PREREQUISITOS: la tabla existe y NO tiene duplicados. Si los tiene, el parche aborta sin tocar nada y lista
-- cuántos pares hay: deduplicar es una decisión de datos (qué fila conserva sus referencias), no de este parche.
--
-- DELTAS ESPERADOS sobre una base sin este parche: índices +1 (único). Sin cambios de datos.
--
-- REVERSA: DROP INDEX IF EXISTS "system_ops"."uq_entity_registry_schema_name_table_name";
-- ============================================================================

BEGIN;

DO $$
DECLARE
    duplicados integer;
BEGIN
    IF to_regclass('system_ops.entity_registry') IS NULL THEN
        RAISE EXCEPTION 'falta system_ops.entity_registry: aplicar antes apply_all.sql';
    END IF;
    SELECT count(*) INTO duplicados FROM (
        SELECT 1 FROM "system_ops"."entity_registry"
        GROUP BY "schema_name", "table_name" HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'system_ops.entity_registry tiene % pares (schema_name, table_name) duplicados: deduplicar antes de aplicar este parche', duplicados;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_entity_registry_schema_name_table_name"
    ON "system_ops"."entity_registry" ("schema_name", "table_name");

COMMIT;
