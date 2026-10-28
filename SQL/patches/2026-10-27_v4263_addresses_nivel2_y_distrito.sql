-- ============================================================================
-- SALUD · patch v4.2.63 (common.addresses.administrative_area_2_concept_id
-- + common.addresses.district_text) sobre una BD viva
-- Fecha: 2026-10-27
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS · duplicate_object en
-- la FK)
--
-- Contexto: ADR-0028 de la API (direcciones multipaís), aprobado el
-- 2026-10-27. gen_ddl.py ya emite las dos columnas en SQL/02_common/ desde que
-- el .puml del módulo 02 las declara, así que en un rebuild desde cero este
-- patch NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/, así que no entra en apply_all.sql.
--
--   1. `administrative_area_2_concept_id` — el nivel 2 (provincia, condado) de
--      cualquier país: concepto de `VS_ADMIN_DIVISION`, hijo del nivel 1 que
--      guarda `administrative_area_concept_id`.
--   2. `district_text` — el distrito o zona, como texto. Ningún catálogo
--      oficial cubre los distritos de todos los países y no se inventa uno.
--      Hasta acá viajaba pegado al final de `lines`.
--
-- Este archivo es la salida de gen_ddl.py 02, no DDL escrito a mano: las
-- columnas se declaran en `Mantra Core Health Context/modules/
-- diagram_02_common.puml` (entidad + su bloque <<INDEX_SET>>) y el destino de
-- la FK en `SALUD/FK/FK common.addresses.administrative_area_2_concept_id.md`.
--
-- Las dos columnas son nullable: una dirección sin provincia ni distrito
-- sigue siendo válida, y ninguna lectura existente cambia.
-- ============================================================================

ALTER TABLE "common"."addresses"
    ADD COLUMN IF NOT EXISTS "administrative_area_2_concept_id" uuid;
ALTER TABLE "common"."addresses"
    ADD COLUMN IF NOT EXISTS "district_text" varchar;

CREATE INDEX IF NOT EXISTS "ix_addresses_administrative_area_2_concept_id"
    ON "common"."addresses" ("administrative_area_2_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "common"."addresses"
        ADD CONSTRAINT "fk_addresses_administrative_area_2_concept_id" FOREIGN KEY ("administrative_area_2_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
