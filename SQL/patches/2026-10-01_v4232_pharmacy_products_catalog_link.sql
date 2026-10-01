-- ============================================================================
-- SALUD · patch v4.2.32 (farmacia · el producto sale del catálogo oficial)
-- Fecha: 2026-10-01 · catálogo universal de medicamentos
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS, FK con duplicate_object).
-- UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py ya emite estas columnas, la FK y los índices en
-- SQL/24_pharmacy/ desde que el .puml los declara, así que en un rebuild desde
-- cero este patch NO hace falta. Existe únicamente para una base ya aplicada y
-- poblada. gen_apply.py no escanea SQL/patches/, así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. Hoy cada farmacia tipea a mano marca, genérico, concentración y
-- presentación de cada producto; dos farmacias cargan el mismo medicamento con
-- grafías distintas y «dónde comprar mi receta» no los reconoce como uno. El
-- producto pasa a elegirse del catálogo universal de medicamentos
-- (terminology.catalog_concepts, un code system por registro sanitario oficial:
-- cima-medicamentos, invima-medicamentos, anvisa-medicamentos…) y la farmacia
-- carga sólo lo suyo: SKU, precio, existencias, fotos, descripción.
--
-- QUÉ AGREGA a pharmacy.pharmacy_products:
--   catalog_product_concept_id uuid NULL  FK → terminology.catalog_concepts
--   catalog_presentation_code  varchar NULL  código de la presentación elegida
--                                             (CN en CIMA, CUM en INVIMA…)
--   dos índices únicos PARCIALES: una farmacia no carga dos veces el mismo
--   producto y presentación (y, sin presentación, el mismo producto).
--
-- POR QUÉ NULLABLE. Los productos que las farmacias ya cargaron a mano antes
-- del catálogo siguen siendo válidos y se siguen editando enteros; el índice
-- parcial sólo rige para filas vinculadas. Cuando el vínculo existe, el
-- servidor deriva marca, genérico, concentración, forma, presentación, receta
-- y medication_concept_id (el ATC con que la receta identifica el fármaco)
-- desde el catálogo: ese contrato lo hace cumplir la API, no un default de BD.
--
-- POR QUÉ DOS ÍNDICES PARCIALES. En Postgres NULL no es igual a NULL: un único
-- índice sobre (farmacia, producto, presentación) dejaría cargar N veces el
-- mismo producto sin presentación.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de pharmacy.pharmacy_products  +2
--   FKs +1 · índices +3 · tablas ±0 · filas ±0
-- ============================================================================

BEGIN;

ALTER TABLE "pharmacy"."pharmacy_products"
    ADD COLUMN IF NOT EXISTS "catalog_product_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "catalog_presentation_code" varchar;

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_products"
        ADD CONSTRAINT "fk_pharmacy_products_catalog_product_concept_id" FOREIGN KEY ("catalog_product_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_pharmacy_products_catalog_product_concept_id" ON "pharmacy"."pharmacy_products" ("catalog_product_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_products_catalog_presentation" ON "pharmacy"."pharmacy_products" ("pharmacy_id", "catalog_product_concept_id", "catalog_presentation_code") WHERE catalog_product_concept_id IS NOT NULL AND catalog_presentation_code IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_products_catalog_no_presentation" ON "pharmacy"."pharmacy_products" ("pharmacy_id", "catalog_product_concept_id") WHERE catalog_product_concept_id IS NOT NULL AND catalog_presentation_code IS NULL;

DO $$
DECLARE
    n_columnas integer;
    n_fk integer;
    n_indices integer;
BEGIN
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'pharmacy'
      AND table_name = 'pharmacy_products'
      AND column_name IN ('catalog_product_concept_id', 'catalog_presentation_code')
      AND is_nullable = 'YES';

    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname = 'fk_pharmacy_products_catalog_product_concept_id'
      AND convalidated;

    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'pharmacy'
      AND tablename = 'pharmacy_products'
      AND indexname IN (
          'ix_pharmacy_products_catalog_product_concept_id',
          'uq_pharmacy_products_catalog_presentation',
          'uq_pharmacy_products_catalog_no_presentation'
      );

    IF n_columnas <> 2 OR n_fk <> 1 OR n_indices <> 3 THEN
        RAISE EXCEPTION
            'v4.2.32 incompleto: columnas=% (esperado 2), fk=% (esperado 1), índices=% (esperado 3)',
            n_columnas, n_fk, n_indices;
    END IF;

    RAISE NOTICE 'v4.2.32 aplicado: 2 columnas, 1 FK, 3 índices en pharmacy.pharmacy_products.';
END $$;

COMMIT;
