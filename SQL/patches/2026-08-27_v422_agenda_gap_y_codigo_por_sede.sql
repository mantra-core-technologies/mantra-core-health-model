-- ============================================================================
-- SALUD · patch v4.2.2 (scheduling · el respiro de la franja  ·  pharmacy_inventory ·
-- el código de retiro pasa a ser único POR SEDE) sobre una BD viva
-- Fecha: 2026-08-27
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS · DROP INDEX IF EXISTS).
-- UNA sola pasada: no hay backfill.
--
-- Contexto: gen_ddl.py ya emite la columna y el índice nuevo en SQL/41_scheduling/ y
-- SQL/25_pharmacy_inventory/ desde que los .puml los declaran, así que en un rebuild
-- desde cero este patch NO hace falta. Existe únicamente para una base ya aplicada y
-- poblada. gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que
-- no entra en apply_all.sql.
--
-- QUÉ CIERRA. Las dos decisiones de modelo de Justin del 27/08:
--   A · `scheduling.schedule_rules.gap_minutes` — desbloquea AG-4 (el generador con
--       paso `slot + gap`, la ficha de respiro en Publicar y la vista previa).
--   B · el código de retiro deja de ser único global y pasa a serlo por sede.
--
-- SOBRE A — POR QUÉ NULLABLE Y SIN DEFAULT. El pedido original
-- (`docs/model-handoff/2026-08-27_gap-minutes-para-marcelo.md`) decía
-- `NOT NULL DEFAULT 0`; Justin retiró ese pedido literal al ver que el modelo NO emite
-- defaults —`row_version integer NOT NULL DEFAULT 1` es la única excepción, y la emite
-- gen_ddl.py porque MikroORM no inicializa la propiedad de versión y sin ella todo
-- INSERT muere con 23502—. `NULL` ≡ «sin respiro» dice exactamente lo mismo que 0, y el
-- `?? 0` lo pone el servicio, igual que ya hace con `slot_minutes`. Queda además
-- consistente con su vecina, que también es nullable.
--
-- SOBRE B — POR QUÉ SE CORRIGE UN ÍNDICE DESPLEGADO AYER. v4.2.1 lo creó único GLOBAL.
-- El código se muestra y se canjea siempre en UNA sede: dos farmacias que no se conocen
-- pueden emitir el mismo sin que nadie se confunda, porque nadie va a presentarlo en la
-- otra. Acotarlo achica además el espacio de colisión que el generador debe evitar: con
-- 6 caracteres, la unicidad global obliga a más reintentos a medida que crece la red.
-- Se corrige HOY porque `inventory_reservations` está en 0 filas: dentro de un mes, con
-- códigos vivos, dejaría de ser gratis.
--
-- ORDEN DEL SWAP: se crea el nuevo ANTES de soltar el viejo. El global es MÁS estricto
-- que el compuesto, así que mientras conviven no hay ninguna ventana por la que se cuele
-- un duplicado — al revés sí la habría. Mismo criterio que v4.1.9 §B.
--
-- ⚠️ ACOPLE CON EL CATÁLOGO ORM: el bootstrap de índices es ADD-only (nunca DROP). Si
-- este patch corre contra una base cuyo código todavía declara
-- `ux_inventory_reservations_pickup_code` en `src/orm/catalog/indexes/pharmacy_inventory.idx.ts`,
-- el siguiente arranque en `safe` RE-CREARÍA el único global recién borrado. El cambio
-- del catálogo viaja en el mismo PR que este archivo y debe estar desplegado antes o a
-- la vez. No corras este patch contra un despliegue con el código anterior.
--
-- Este archivo es la salida de gen_ddl.py 41 y 25, no DDL escrito a mano: la columna se
-- declara en `modules/diagram_41_scheduling.puml` y el índice en el `<<INDEX_SET>>` de
-- `modules/diagram_25_pharmacy_inventory.puml`.
--
-- Correlo con `psql -v ON_ERROR_STOP=1 -f`. Con `rebuild_stack.py --yes` no hace falta.
--
-- Delta esperado sobre los conteos canónicos: +0 tablas · +0 FK · **+0 índices netos**
-- (−1 el global, +1 el compuesto) · +1 columna en scheduling.schedule_rules (14 → 15).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- A · El respiro de la franja.
--     (de SQL/41_scheduling/02_tables.sql)
-- ---------------------------------------------------------------------------

ALTER TABLE "scheduling"."schedule_rules"
    ADD COLUMN IF NOT EXISTS "gap_minutes" integer;

-- ---------------------------------------------------------------------------
-- B · El código de retiro, único por sede.
--     (de SQL/25_pharmacy_inventory/04_indexes.sql)
--
-- Sigue siendo PARCIAL por la misma razón que en v4.2.1: la enorme mayoría de las filas
-- —reservas de mostrador y pedidos que aún no llegaron a LISTO_PARA_RETIRO— no tienen
-- código, y Postgres considera cada NULL distinto de los demás, así que un único sin
-- predicado no acotaría nada mientras obliga a razonar sobre NULLs en cada lectura.
-- `pharmacy_site_id` es NOT NULL: la partición nunca es nula.
-- ---------------------------------------------------------------------------

BEGIN;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inventory_reservations_pharmacy_site_pickup_code"
    ON "pharmacy_inventory"."inventory_reservations" ("pharmacy_site_id", "pickup_code")
    WHERE pickup_code IS NOT NULL;

DROP INDEX IF EXISTS "pharmacy_inventory"."ux_inventory_reservations_pickup_code";

COMMIT;

-- ---------------------------------------------------------------------------
-- C · Comprobación: rompe si el esquema quedó a medias.
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    faltantes text;
BEGIN
    SELECT string_agg(e.objeto, ', ' ORDER BY e.objeto) INTO faltantes
    FROM (VALUES
        ('columna scheduling.schedule_rules.gap_minutes',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'scheduling' AND table_name = 'schedule_rules'
                       AND column_name = 'gap_minutes')),
        ('índice ux_inventory_reservations_pharmacy_site_pickup_code',
            EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'pharmacy_inventory'
                       AND indexname = 'ux_inventory_reservations_pharmacy_site_pickup_code'))
    ) AS e(objeto, existe)
    WHERE NOT e.existe;

    IF faltantes IS NOT NULL THEN
        RAISE EXCEPTION 'patch v4.2.2 incompleto - faltan: %', faltantes;
    END IF;

    -- La columna no debe llevar default: el modelo no emite ninguno salvo row_version.
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'scheduling' AND table_name = 'schedule_rules'
                  AND column_name = 'gap_minutes'
                  AND column_default IS NOT NULL) THEN
        RAISE EXCEPTION 'patch v4.2.2 incorrecto - gap_minutes tiene DEFAULT y no debería';
    END IF;

    -- El viejo tiene que haber desaparecido: si sobrevive, la unicidad sigue siendo
    -- global y la decisión de producto no se aplicó.
    IF EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'pharmacy_inventory'
                 AND indexname = 'ux_inventory_reservations_pickup_code') THEN
        RAISE EXCEPTION 'patch v4.2.2 incompleto - ux_inventory_reservations_pickup_code sigue existiendo';
    END IF;

    -- El nuevo tiene que ser PARCIAL y compuesto: un único total sobre las dos columnas
    -- sería otra regla, no un índice peor.
    IF NOT EXISTS (SELECT 1 FROM pg_indexes
                    WHERE schemaname = 'pharmacy_inventory'
                      AND indexname = 'ux_inventory_reservations_pharmacy_site_pickup_code'
                      AND indexdef ILIKE '%WHERE%pickup_code IS NOT NULL%'
                      AND indexdef ILIKE '%pharmacy_site_id%') THEN
        RAISE EXCEPTION 'patch v4.2.2 incompleto - el índice nuevo no es parcial o no incluye pharmacy_site_id';
    END IF;

    RAISE NOTICE 'patch v4.2.2 · C: esquema completo (1 columna · swap de único a por-sede)';
END $$;
