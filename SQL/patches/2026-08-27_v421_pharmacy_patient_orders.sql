-- ============================================================================
-- SALUD · patch v4.2.1 (pharmacy_inventory · el pedido de paciente gana su modelo:
-- modalidad de entrega, dirección, precios congelados, código de retiro, motivo de
-- rechazo y las propuestas de sustitución) sobre una BD viva
-- Fecha: 2026-08-27
-- Idempotente (ADD COLUMN / CREATE TABLE / CREATE INDEX IF NOT EXISTS ·
-- duplicate_object en las FK). UNA sola pasada: no hay backfill.
--
-- Contexto: gen_ddl.py ya emite estas columnas, índices y la tabla nueva en
-- SQL/25_pharmacy_inventory/ desde que el .puml del módulo 25 los declara, así que
-- en un rebuild desde cero este patch NO hace falta. Existe únicamente para una base
-- ya aplicada y poblada. gen_apply.py no escanea SQL/patches/ (solo directorios
-- NN_schema), así que no entra en apply_all.sql.
--
-- QUÉ CIERRA. Los dos paquetes de bloqueadores de Ender —FAR-E1 (2026-08-25) y
-- FAR-E3 (2026-08-26)— enumeran siete cosas del contrato del front que no tenían
-- dónde persistirse. Este patch las declara todas:
--   1. modalidad de entrega         -> inventory_reservations.delivery_mode_concept_id
--   2. dirección de entrega elegida -> inventory_reservations.delivery_address_id
--   3. total congelado + moneda     -> inventory_reservations.total_amount / currency_concept_id
--   4. precio + moneda por línea    -> inventory_reservation_lines.unit_price_amount / currency_concept_id
--   5. código de retiro             -> inventory_reservations.pickup_code (+ único PARCIAL)
--   6. motivo de rechazo            -> inventory_reservations.rejection_reason_text
--   7. sustituciones propuestas     -> tabla nueva pharmacy_order_substitutions
-- Con 1 y 5, el `ready` de FAR-E2 deja de responder 422 y FAR-E3 entero se destraba.
--
-- DECISIÓN DE FONDO: el pedido se materializa SOBRE `inventory_reservations`, no en
-- una tabla `pharmacy_orders` envolvente. No es una decisión nueva: `dev` ya la tomó
-- —«una fila con estado PINV_ORDER_* ES un pedido de paciente», en
-- `pharmacy_inventory.concepts.ts`— y FAR-E1/E2 están mergeados sobre esa premisa.
-- Por eso TODAS las columnas nuevas son nullable: la tabla la comparten las reservas
-- de mostrador, que no son pedidos y no llevan nada de esto. Que un pedido siempre
-- tenga modalidad es regla de SERVICIO, no del esquema.
--
-- SIN DEFAULTS, como todo el modelo: `row_version integer NOT NULL DEFAULT 1` es la
-- única excepción y la emite gen_ddl.py (MikroORM no inicializa la propiedad de
-- versión y sin el default todo INSERT muere con 23502).
--
-- CONCEPTOS: los 7 nuevos (`PINV_DELIVERY_*` x3, `PINV_SUBSTITUTION_*` x4) los
-- siembra LA API al arrancar (`SeedBootstrapService` -> `TerminologySeedService`), NO
-- este archivo ni gen_seeds.py. Son conjuntos dinámicos cuyo dueño es la API: no hay
-- ni debe haber nota `Patch v4.*/Value sets/vs_*.md`, porque gen_seeds.py globea ese
-- patrón y se adueñaría del conjunto con ids de otro namespace — dos catálogos
-- peleando por la misma columna, que es el problema del módulo 64. Mismo criterio que
-- v4.1.9. Como no hay backfill, el orden de despliegue es LIBRE: este patch puede
-- correrse antes o después de desplegar la API.
--
-- Este archivo es la salida de gen_ddl.py 25, no DDL escrito a mano: las columnas y
-- la tabla se declaran en
-- `Mantra Core Health Context/modules/diagram_25_pharmacy_inventory.puml` y los
-- destinos de las 12 FK en `SALUD/FK/FK pharmacy_inventory.*.md`.
--
-- Correlo con `psql -v ON_ERROR_STOP=1 -f`. Con `rebuild_stack.py --yes` no hace
-- falta: la base nace con todo esto desde `SQL/`.
--
-- Delta esperado sobre los conteos canónicos: +1 tabla · +12 FK · +14 índices
-- (13 declarados en 04_indexes.sql + la PK que crea Postgres sola).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- A · Columnas nuevas de las dos tablas existentes, sus índices y sus FK
--     (de SQL/25_pharmacy_inventory/02_tables.sql, 04_indexes.sql y 90_fk_deferred.sql)
-- ---------------------------------------------------------------------------

ALTER TABLE "pharmacy_inventory"."inventory_reservations"
    ADD COLUMN IF NOT EXISTS "delivery_mode_concept_id" uuid;

ALTER TABLE "pharmacy_inventory"."inventory_reservations"
    ADD COLUMN IF NOT EXISTS "delivery_address_id" uuid;

ALTER TABLE "pharmacy_inventory"."inventory_reservations"
    ADD COLUMN IF NOT EXISTS "total_amount" numeric;

ALTER TABLE "pharmacy_inventory"."inventory_reservations"
    ADD COLUMN IF NOT EXISTS "currency_concept_id" uuid;

ALTER TABLE "pharmacy_inventory"."inventory_reservations"
    ADD COLUMN IF NOT EXISTS "pickup_code" varchar;

ALTER TABLE "pharmacy_inventory"."inventory_reservations"
    ADD COLUMN IF NOT EXISTS "rejection_reason_text" varchar;

ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
    ADD COLUMN IF NOT EXISTS "unit_price_amount" numeric;

ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
    ADD COLUMN IF NOT EXISTS "currency_concept_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_delivery_mode_concept_id" ON "pharmacy_inventory"."inventory_reservations" ("delivery_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_delivery_address_id" ON "pharmacy_inventory"."inventory_reservations" ("delivery_address_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservations_currency_concept_id" ON "pharmacy_inventory"."inventory_reservations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_reservation_lines_currency_concept_id" ON "pharmacy_inventory"."inventory_reservation_lines" ("currency_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_delivery_mode_concept_id" FOREIGN KEY ("delivery_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.addresses (requiere schema common)
-- Ojo: `common.addresses` es polimórfica (owner_type_concept_id + owner_id, sin FK),
-- así que esta clave garantiza que la dirección existe pero NO que sea del paciente
-- del pedido. Eso lo comprueba el servicio.
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_delivery_address_id" FOREIGN KEY ("delivery_address_id")
        REFERENCES "common"."addresses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservation_lines"
        ADD CONSTRAINT "fk_inventory_reservation_lines_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- B · El código de retiro es único, pero SOLO donde existe.
--
-- Un único TOTAL no serviría de guarda: Postgres considera cada NULL distinto de los
-- demás, y la enorme mayoría de las filas de esta tabla —reservas de mostrador y
-- pedidos que todavía no llegaron a LISTO_PARA_RETIRO— no tienen código. El predicado
-- además deja el índice del tamaño de los pedidos vivos con código, que es contra lo
-- que el mostrador busca. Mismo razonamiento que los dos parciales de v4.1.9.
-- ---------------------------------------------------------------------------

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inventory_reservations_pickup_code"
    ON "pharmacy_inventory"."inventory_reservations" ("pickup_code")
    WHERE pickup_code IS NOT NULL;

-- ---------------------------------------------------------------------------
-- C · Tabla nueva: las propuestas de sustitución, por línea del pedido.
--     (de SQL/25_pharmacy_inventory/02_tables.sql, 04_indexes.sql, 03_fk_intra.sql
--      y 90_fk_deferred.sql)
--
-- Es una BITÁCORA, no un campo mutable: aceptar y preferir-el-original dejan la fila
-- viva como historia, y por eso NO hay único por línea — una línea cuya propuesta se
-- rechazó puede recibir una segunda.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS "pharmacy_inventory"."pharmacy_order_substitutions" (
    "id" uuid NOT NULL,
    "inventory_reservation_id" uuid NOT NULL,
    "inventory_reservation_line_id" uuid NOT NULL,
    "original_pharmacy_product_id" uuid NOT NULL,
    "proposed_pharmacy_product_id" uuid NOT NULL,
    "original_unit_price_amount" numeric,
    "proposed_unit_price_amount" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "decided_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_order_substitutions" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_inventory_reservation_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("inventory_reservation_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_inventory_reservation_line_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("inventory_reservation_line_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_original_pharmacy_product_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("original_pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_proposed_pharmacy_product_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("proposed_pharmacy_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_currency_concept_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_status_concept_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_created_by_user_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacy_order_substitutions_updated_by_user_id" ON "pharmacy_inventory"."pharmacy_order_substitutions" ("updated_by_user_id");

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_inventory_reservation_id" FOREIGN KEY ("inventory_reservation_id")
        REFERENCES "pharmacy_inventory"."inventory_reservations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_inventory_reservation_line_id" FOREIGN KEY ("inventory_reservation_line_id")
        REFERENCES "pharmacy_inventory"."inventory_reservation_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_original_pharmacy_product_id" FOREIGN KEY ("original_pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacy_products (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_proposed_pharmacy_product_id" FOREIGN KEY ("proposed_pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."pharmacy_order_substitutions"
        ADD CONSTRAINT "fk_pharmacy_order_substitutions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- D · Comprobación: rompe si el esquema quedó a medias.
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    faltantes text;
BEGIN
    SELECT string_agg(e.objeto, ', ' ORDER BY e.objeto) INTO faltantes
    FROM (VALUES
        ('tabla pharmacy_order_substitutions',
            EXISTS (SELECT 1 FROM information_schema.tables
                     WHERE table_schema = 'pharmacy_inventory'
                       AND table_name = 'pharmacy_order_substitutions')),
        ('columna inventory_reservations.delivery_mode_concept_id',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservations'
                       AND column_name = 'delivery_mode_concept_id')),
        ('columna inventory_reservations.delivery_address_id',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservations'
                       AND column_name = 'delivery_address_id')),
        ('columna inventory_reservations.total_amount',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservations'
                       AND column_name = 'total_amount')),
        ('columna inventory_reservations.currency_concept_id',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservations'
                       AND column_name = 'currency_concept_id')),
        ('columna inventory_reservations.pickup_code',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservations'
                       AND column_name = 'pickup_code')),
        ('columna inventory_reservations.rejection_reason_text',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservations'
                       AND column_name = 'rejection_reason_text')),
        ('columna inventory_reservation_lines.unit_price_amount',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservation_lines'
                       AND column_name = 'unit_price_amount')),
        ('columna inventory_reservation_lines.currency_concept_id',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'pharmacy_inventory' AND table_name = 'inventory_reservation_lines'
                       AND column_name = 'currency_concept_id')),
        ('índice ux_inventory_reservations_pickup_code',
            EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'pharmacy_inventory'
                       AND indexname = 'ux_inventory_reservations_pickup_code')),
        ('FK fk_inventory_reservations_delivery_address_id',
            EXISTS (SELECT 1 FROM pg_constraint
                     WHERE conname = 'fk_inventory_reservations_delivery_address_id')),
        ('FK fk_pharmacy_order_substitutions_inventory_reservation_line_id',
            EXISTS (SELECT 1 FROM pg_constraint
                     WHERE conname = 'fk_pharmacy_order_substitutions_inventory_reservation_line_id'))
    ) AS e(objeto, existe)
    WHERE NOT e.existe;

    IF faltantes IS NOT NULL THEN
        RAISE EXCEPTION 'patch v4.2.1 incompleto - faltan: %', faltantes;
    END IF;

    -- El parcial tiene que ser PARCIAL: si alguien lo creó total, el índice dice otra
    -- regla y ninguna reserva de mostrador podría convivir con otra sin código.
    IF NOT EXISTS (SELECT 1 FROM pg_indexes
                    WHERE schemaname = 'pharmacy_inventory'
                      AND indexname = 'ux_inventory_reservations_pickup_code'
                      AND indexdef ILIKE '%WHERE%pickup_code IS NOT NULL%') THEN
        RAISE EXCEPTION 'patch v4.2.1 incompleto - ux_inventory_reservations_pickup_code existe pero NO es parcial';
    END IF;

    RAISE NOTICE 'patch v4.2.1 · D: esquema completo (1 tabla · 8 columnas · 14 índices · 12 FK)';
END $$;
