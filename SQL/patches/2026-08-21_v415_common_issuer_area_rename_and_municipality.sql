-- ============================================================================
-- SALUD · patch v4.1.5 (common.identifiers.issuer_administrative_area_concept_id
-- + common.addresses.municipality_concept_id) sobre una BD viva
-- Fecha: 2026-08-21
-- Idempotente (renombre guardado por existencia · ADD COLUMN / CREATE INDEX
-- IF NOT EXISTS · duplicate_object en las FKs)
--
-- Contexto: gen_ddl.py ya emite las dos columnas con estos nombres en
-- SQL/02_common/ desde que el .puml del módulo 02 las declara, así que en un
-- rebuild desde cero este patch NO hace falta. Existe únicamente para una base
-- ya aplicada y poblada. gen_apply.py no escanea SQL/patches/, así que no entra
-- en apply_all.sql.
--
-- Qué cierra: DOS derivas de la clase B-9 que dejó el commit `ceba7c4d`
-- («catálogo boliviano de departamento/municipio/ocupación»). Ese carril agregó
-- las dos columnas a las entidades MikroORM y a ninguna de las otras tres
-- capas. Con ellas ausentes en Postgres, el ORM las proyecta en el SELECT y
-- **fallan todas las lecturas de `common.identifiers` y de `common.addresses`**
-- —dos tablas centrales—, no sólo las que usen los campos nuevos.
--
--   1. `identifiers.issuer_administrative_area_concept_id` — departamento de
--      expedición del documento (la «extensión» del carnet: SC, LP, CB…).
--      **Colisión de nombres resuelta acá:** dos carriles declararon esta misma
--      columna con nombres distintos —v4.1.4 la escribió `issuing_` y `ceba7c4d`
--      la escribió `issuer_`—. Se unificó en `issuer_`, el que el código ya
--      usaba, para no arrastrar el conflicto. Por eso el primer bloque es un
--      RENOMBRE guardado por existencia: en una base que aplicó el patch
--      v4.1.4 la columna ya existe con el nombre viejo y hay que moverla (con
--      su índice y su constraint); en una que no lo aplicó, no hay nada que
--      renombrar y la crea el bloque siguiente.
--
--   2. `addresses.municipality_concept_id` — municipio.
--      `administrative_area_concept_id` sigue siendo el departamento; éste es el
--      nivel de detalle que `city` (texto libre) no puede garantizar
--      consistente.
--
-- Este archivo es la salida de gen_ddl.py 02 más los guardas del renombre, no
-- DDL escrito a mano: las columnas se declaran en `Mantra Core Health Context/
-- modules/diagram_02_common.puml` (entidad + su bloque <<INDEX_SET>>) y los
-- destinos de FK en `SALUD/FK/FK common.{identifiers,addresses}.*.md`.
--
-- PENDIENTE que este patch NO cubre: los value sets. La columna del
-- departamento se resuelve contra `VS_ADMINISTRATIVE_AREA`, que el paquete ya
-- siembra (hace falta `load_seeds.py --refresh` para que llegue a esta base).
-- La del municipio se resuelve contra `vs_bo_municipality` —340 conceptos— que
-- **todavía no existe en ninguna capa**: hasta que se siembre, la columna es
-- utilizable pero no hay catálogo que ofrecer. Ambas son nullable, así que eso
-- no rompe nada.
-- ============================================================================

-- --- 1a. Renombre, sólo donde exista el nombre viejo (v4.1.4) ---------------

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'common' AND table_name = 'identifiers'
          AND column_name = 'issuing_administrative_area_concept_id'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'common' AND table_name = 'identifiers'
          AND column_name = 'issuer_administrative_area_concept_id'
    ) THEN
        ALTER TABLE "common"."identifiers"
            RENAME COLUMN "issuing_administrative_area_concept_id"
                       TO "issuer_administrative_area_concept_id";
    END IF;
END $$;

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'common'
          AND indexname = 'ix_identifiers_issuing_administrative_area_concept_id'
    ) THEN
        ALTER INDEX "common"."ix_identifiers_issuing_administrative_area_concept_id"
            RENAME TO "ix_identifiers_issuer_administrative_area_concept_id";
    END IF;
END $$;

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_identifiers_issuing_administrative_area_concept_id'
    ) THEN
        ALTER TABLE "common"."identifiers"
            RENAME CONSTRAINT "fk_identifiers_issuing_administrative_area_concept_id"
                           TO "fk_identifiers_issuer_administrative_area_concept_id";
    END IF;
END $$;

-- --- 1b. Alta, para la base que nunca tuvo el nombre viejo ------------------

ALTER TABLE "common"."identifiers"
    ADD COLUMN IF NOT EXISTS "issuer_administrative_area_concept_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_identifiers_issuer_administrative_area_concept_id"
    ON "common"."identifiers" ("issuer_administrative_area_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "common"."identifiers"
        ADD CONSTRAINT "fk_identifiers_issuer_administrative_area_concept_id" FOREIGN KEY ("issuer_administrative_area_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --- 2. El municipio -------------------------------------------------------

ALTER TABLE "common"."addresses"
    ADD COLUMN IF NOT EXISTS "municipality_concept_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_addresses_municipality_concept_id"
    ON "common"."addresses" ("municipality_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "common"."addresses"
        ADD CONSTRAINT "fk_addresses_municipality_concept_id" FOREIGN KEY ("municipality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
