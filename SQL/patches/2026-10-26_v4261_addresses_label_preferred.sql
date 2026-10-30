-- ============================================================================
-- SALUD · patch v4.2.61 (common · libreta de direcciones del paciente) sobre BD viva
-- Fecha: 2026-10-26
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE [UNIQUE] INDEX IF NOT EXISTS).
-- UNA sola pasada. Sin backfill — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite estas columnas e índices en SQL/02_common/
-- desde que el .puml las declara (diagram_02_common.puml, v4.2.61), así que en
-- un rebuild desde cero este patch NO hace falta. Existe para una base ya
-- aplicada y poblada. gen_apply.py no escanea SQL/patches/.
--
-- QUÉ AGREGA. Pedido del cliente del 26/10/2026: el paciente guarda varias
-- ubicaciones —«como en una app de pedidos»— para los envíos. La tabla ya
-- admitía varias filas por dueño (`owner_type_concept_id`, `owner_id`,
-- `use_concept_id`); le faltaban dos datos:
--   - `label`: el nombre que la persona le pone («Casa», «Oficina», «Casa de
--     mi mamá»). Texto libre, opcional.
--   - `is_preferred`: la que se ofrece primero. Una sola preferida VIGENTE por
--     dueño, garantizada por la base (índice único parcial), no por un SELECT
--     previo en el servicio.
-- Más un índice para listar las direcciones vigentes de un dueño, que no
-- existía (sólo había índices por columna suelta).
--
-- POR QUÉ NO HAY BACKFILL. Ninguna fila viva es «preferida» todavía y marcar
-- una por defecto sería decidir por la persona. La API trata «sin preferida»
-- como «el domicilio vigente va primero», que es lo que ya se mostraba.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de common.addresses   20 → 22
--   índices                        +2  (ix_addresses_owner_current, uq_addresses_owner_preferred)
--   tablas / FKs                   ±0
--
-- REVERSA (si hiciera falta):
--   DROP INDEX IF EXISTS "common"."uq_addresses_owner_preferred";
--   DROP INDEX IF EXISTS "common"."ix_addresses_owner_current";
--   ALTER TABLE "common"."addresses" DROP COLUMN IF EXISTS "is_preferred";
--   ALTER TABLE "common"."addresses" DROP COLUMN IF EXISTS "label";
-- ============================================================================

BEGIN;

ALTER TABLE "common"."addresses" ADD COLUMN IF NOT EXISTS "label" varchar;
ALTER TABLE "common"."addresses" ADD COLUMN IF NOT EXISTS "is_preferred" boolean NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS "ix_addresses_owner_current"
    ON "common"."addresses" ("owner_type_concept_id", "owner_id")
    WHERE valid_to IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_addresses_owner_preferred"
    ON "common"."addresses" ("owner_type_concept_id", "owner_id")
    WHERE is_preferred AND valid_to IS NULL;

COMMIT;
