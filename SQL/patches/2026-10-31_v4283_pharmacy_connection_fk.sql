-- ============================================================================
-- SALUD · patch v4.2.83 (pharmacy · connection_id apunta a la conexión de integraciones) sobre BD viva
-- Fecha: 2026-10-31
-- Idempotente: se puede volver a correr; la segunda pasada no cambia nada.
-- UNA sola transacción (BEGIN … COMMIT).
--
-- Contexto: gen_ddl.py ya emite este cambio en SQL/24_pharmacy/ desde que
-- diagram_24_pharmacy.puml lo declara (columna opcional y FK diferida en 90_fk_deferred.sql),
-- así que en una reconstrucción desde cero este parche NO hace falta. Existe para una base ya
-- aplicada y poblada.
--
-- QUÉ CAMBIA
--   pharmacy.pharmacy_integration_connections.connection_id
--     - Antes: NOT NULL, con una FK a la propia tabla (resuelta por una heurística de mismo
--       schema) y la API lo rellenaba con el id de la fila.
--     - Ahora: opcional, con FK a integrations.provider_connections (id). Nulo quiere decir
--       que todavía no está configurado el sistema de la farmacia y trabaja en manual.
--
-- ORDEN (cada paso depende del anterior)
--   1. Quitar la FK propia. La nueva lleva el mismo nombre, así que va primero. Solo se quita
--      si aún apunta a la propia tabla: en la segunda pasada la FK ya es la nueva y no se toca.
--   2. Quitar el NOT NULL.
--   3. MIGRACIÓN DE DATOS: poner en nulo connection_id donde no hay una conexión válida en
--      integrations.provider_connections (las filas auto-referenciadas, y las que apuntaban a
--      otra fila de la propia tabla). Las filas no se borran: otras dos tablas las referencian
--      por id (pharmacy_external_product_mappings y pharmacy_inventory_sync_batches) y esos
--      vínculos siguen intactos. Es idempotente y respeta las conexiones reales que se
--      registren después.
--   4. Agregar la FK nueva, validada (sin NOT VALID), con la guarda de duplicate_object.
--
-- REVERSA (manual; vale mientras ninguna fila apunte a una conexión real de integraciones)
--   BEGIN;
--   ALTER TABLE "pharmacy"."pharmacy_integration_connections"
--       DROP CONSTRAINT IF EXISTS "fk_pharmacy_integration_connections_connection_id";
--   UPDATE "pharmacy"."pharmacy_integration_connections"
--      SET "connection_id" = "id" WHERE "connection_id" IS NULL;
--   ALTER TABLE "pharmacy"."pharmacy_integration_connections"
--       ALTER COLUMN "connection_id" SET NOT NULL;
--   ALTER TABLE "pharmacy"."pharmacy_integration_connections"
--       ADD CONSTRAINT "fk_pharmacy_integration_connections_connection_id" FOREIGN KEY ("connection_id")
--       REFERENCES "pharmacy"."pharmacy_integration_connections" ("id");
--   COMMIT;
-- ============================================================================

BEGIN;

-- 1. Quitar la FK propia (solo si todavía apunta a su propia tabla).
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM pg_constraint c
         WHERE c.conname = 'fk_pharmacy_integration_connections_connection_id'
           AND c.conrelid = '"pharmacy"."pharmacy_integration_connections"'::regclass
           AND c.confrelid = '"pharmacy"."pharmacy_integration_connections"'::regclass
    ) THEN
        ALTER TABLE "pharmacy"."pharmacy_integration_connections"
            DROP CONSTRAINT "fk_pharmacy_integration_connections_connection_id";
    END IF;
END $$;

-- 2. connection_id deja de ser obligatorio.
ALTER TABLE "pharmacy"."pharmacy_integration_connections"
    ALTER COLUMN "connection_id" DROP NOT NULL;

-- 3. Migración de datos: nulo donde no hay una conexión de integraciones válida.
UPDATE "pharmacy"."pharmacy_integration_connections" pic
   SET "connection_id" = NULL
 WHERE pic."connection_id" IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
         FROM "integrations"."provider_connections" pc
        WHERE pc."id" = pic."connection_id"
   );

-- 4. FK nueva hacia la conexión de integraciones (la misma que emite gen_ddl.py).
-- destino: integrations.provider_connections (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_integration_connections"
        ADD CONSTRAINT "fk_pharmacy_integration_connections_connection_id" FOREIGN KEY ("connection_id")
        REFERENCES "integrations"."provider_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
