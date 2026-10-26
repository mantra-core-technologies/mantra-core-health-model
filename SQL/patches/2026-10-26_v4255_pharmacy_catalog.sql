-- ============================================================================
-- SALUD · patch v4.2.55 (pharmacy · P47) sobre BD viva
-- Fecha: 2026-10-26
--
-- QUÉ ENTRA. El catálogo que administra la propia farmacia (P47 §3-5):
--   1. `pharmacy.pharmacy_products` gana categoría (FK), descripción y la
--      DECLARACIÓN de existencias de la vitrina: stock_quantity (NULL = «sin
--      conteo»), min_stock_quantity (NULL = umbral por defecto del servicio) y
--      out_of_stock_declared («no tengo»). No es el ledger de existencias
--      (`pharmacy_inventory.inventory_stock_positions`), que no se toca.
--   2. Tabla nueva `pharmacy.pharmacy_product_categories` (por farmacia, nombre
--      único sin distinguir mayúsculas ni tildes vía `name_key`).
--   3. Tabla nueva `pharmacy.pharmacy_product_images` (hasta 3 por producto, la
--      regla del tope vive en el servicio; orden y archivo únicos por producto).
--   4. CHECK de existencias no negativas y del orden de imagen 1..3.
--   5. Las seis categorías de partida para las farmacias que ya existen.
--      Procedencia: mockup del cliente `farmacia_ecommerce_mantra.html`
--      (28/09/2026). Es catálogo INTERNO de cada farmacia, no un catálogo oficial:
--      la farmacia las renombra o elimina.
--
-- ESTADO BORRADOR. El concepto `PHARM_PRODUCT_DRAFT` lo siembra la API
-- (`pharmacy.concepts.ts`, `yarn seed:boot`), igual que el resto de los PHARM_*.
-- El precio NO entra acá: se versiona en `pharmacy_product_prices` sobre la
-- lista pública de mostrador `CATALOGO` de cada farmacia (la crea el servicio).
--
-- MODELO. Declarado en `diagram_24_pharmacy.puml`; un rebuild desde cero lo trae
-- en SQL/24_pharmacy/0{2,3,4}_*.sql y 90_fk_deferred.sql. Este patch es sólo
-- para bases ya aplicadas. Idempotente: IF NOT EXISTS, duplicate_object tolerado
-- y ON CONFLICT DO NOTHING en los datos.
--
-- DELTAS ESPERADOS: columnas +5 · tablas +2 · FKs +8 · índices +10 (+2 PK) ·
-- CHECK +4 · filas de categoría = 6 × farmacias existentes.
-- ============================================================================
BEGIN;

ALTER TABLE "pharmacy"."pharmacy_products"
    ADD COLUMN IF NOT EXISTS "pharmacy_product_category_id" uuid,
    ADD COLUMN IF NOT EXISTS "description_text" text,
    ADD COLUMN IF NOT EXISTS "stock_quantity" integer,
    ADD COLUMN IF NOT EXISTS "min_stock_quantity" integer,
    ADD COLUMN IF NOT EXISTS "out_of_stock_declared" boolean NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_product_categories" (
    "id" uuid NOT NULL,
    "pharmacy_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "name_key" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_product_categories" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_product_images" (
    "id" uuid NOT NULL,
    "pharmacy_product_id" uuid NOT NULL,
    "image_file_id" uuid NOT NULL,
    "ordinal" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_pharmacy_product_images" PRIMARY KEY ("id")
);

-- --- FKs (mismos nombres que SQL/24_pharmacy/03_fk_intra.sql y 90_fk_deferred.sql)
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_pharmacy_product_category_id" FOREIGN KEY ("pharmacy_product_category_id")
        REFERENCES "pharmacy"."pharmacy_product_categories" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_categories"
        ADD CONSTRAINT "fk_pharmacy_product_categories_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_images"
        ADD CONSTRAINT "fk_pharmacy_product_images_pharmacy_product_id" FOREIGN KEY ("pharmacy_product_id")
        REFERENCES "pharmacy"."pharmacy_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_categories"
        ADD CONSTRAINT "fk_pharmacy_product_categories_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_categories"
        ADD CONSTRAINT "fk_pharmacy_product_categories_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_images"
        ADD CONSTRAINT "fk_pharmacy_product_images_image_file_id" FOREIGN KEY ("image_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_images"
        ADD CONSTRAINT "fk_pharmacy_product_images_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --- índices (mismos nombres que SQL/24_pharmacy/04_indexes.sql)
CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_pharmacy_product_category_id" ON "pharmacy"."pharmacy_products" ("pharmacy_product_category_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_categories_pharmacy_id" ON "pharmacy"."pharmacy_product_categories" ("pharmacy_id");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_product_categories_pharmacy_id_name_key" ON "pharmacy"."pharmacy_product_categories" ("pharmacy_id", "name_key");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_categories_created_by_user_id" ON "pharmacy"."pharmacy_product_categories" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_categories_updated_by_user_id" ON "pharmacy"."pharmacy_product_categories" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_images_pharmacy_product_id" ON "pharmacy"."pharmacy_product_images" ("pharmacy_product_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_images_image_file_id" ON "pharmacy"."pharmacy_product_images" ("image_file_id");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_product_images_pharmacy_product_id_ordinal" ON "pharmacy"."pharmacy_product_images" ("pharmacy_product_id", "ordinal");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_product_images_pharmacy_product_id_image_file_id" ON "pharmacy"."pharmacy_product_images" ("pharmacy_product_id", "image_file_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_product_images_created_by_user_id" ON "pharmacy"."pharmacy_product_images" ("created_by_user_id");

-- --- CHECK: la base es el último lugar donde la invariante vale.
DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "ck_pharmacy_products_stock_quantity_non_negative" CHECK ("stock_quantity" IS NULL OR "stock_quantity" >= 0);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "ck_pharmacy_products_min_stock_quantity_non_negative" CHECK ("min_stock_quantity" IS NULL OR "min_stock_quantity" >= 0);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_images"
        ADD CONSTRAINT "ck_pharmacy_product_images_ordinal_range" CHECK ("ordinal" BETWEEN 1 AND 3);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_product_categories"
        ADD CONSTRAINT "ck_pharmacy_product_categories_name_length" CHECK (char_length(btrim("name")) BETWEEN 1 AND 60);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --- las seis categorías de partida (catálogo interno; ids deterministas)
INSERT INTO "pharmacy"."pharmacy_product_categories"
       ("id", "pharmacy_id", "name", "name_key", "created_at", "updated_at")
SELECT md5('pharmacy-category:' || ph.id::text || ':' || d.name_key)::uuid,
       ph.id, d.name, d.name_key, now(), now()
  FROM "pharmacy"."pharmacies" ph
 CROSS JOIN (VALUES
       ('Medicamentos', 'medicamentos'),
       ('Dermocosmética', 'dermocosmetica'),
       ('Cuidado personal', 'cuidado personal'),
       ('Bebé y maternidad', 'bebe y maternidad'),
       ('Dispositivos', 'dispositivos'),
       ('Bienestar', 'bienestar')) AS d(name, name_key)
ON CONFLICT ("pharmacy_id", "name_key") DO NOTHING;

COMMIT;
