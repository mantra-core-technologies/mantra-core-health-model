-- ============================================================================
-- SALUD · patch v4.1.4 (common.identifiers.issuing_administrative_area_concept_id)
-- sobre una BD viva
-- Fecha: 2026-08-20
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS · duplicate_object en la FK)
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/02_common/ desde que el
-- .puml del módulo 02 la declara, así que en un rebuild desde cero este patch
-- NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Qué agrega: el departamento de expedición del documento de identidad — la
-- «extensión» del carnet boliviano (SC, LP, CB, OR, PT, TJ, BE, PA, CH).
-- Decisión de producto (2026-08-20): es dato INFORMATIVO del registro, no del
-- login — el paciente sigue entrando con su número de documento a secas, la
-- columna no entra en ninguna clave única y es nullable a propósito (un
-- documento cuyo departamento no se registró es un dato legítimo, no un olvido
-- que convenga rellenar). Como todo valor de terminología, viaja por
-- `*_concept_id` contra `terminology.catalog_concepts`, nunca por un enum
-- nativo: los 9 conceptos los siembra `vs_administrative_area` (gen_seeds.py,
-- nota en `SALUD/Patch v4.1.4/Value sets/vs_administrative_area.md`), el mismo
-- catálogo que `common.addresses.administrative_area_concept_id` referencia.
--
-- Este archivo es la salida de gen_ddl.py 02, no DDL escrito a mano: la columna
-- se declara en `Mantra Core Health Context/modules/diagram_02_common.puml`
-- (entidad `identifiers` + su bloque <<INDEX_SET>>) y el destino de la FK en
-- `SALUD/FK/FK common.identifiers.issuing_administrative_area_concept_id.md`.
-- ============================================================================

ALTER TABLE "common"."identifiers"
    ADD COLUMN IF NOT EXISTS "issuing_administrative_area_concept_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_identifiers_issuing_administrative_area_concept_id"
    ON "common"."identifiers" ("issuing_administrative_area_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "common"."identifiers"
        ADD CONSTRAINT "fk_identifiers_issuing_administrative_area_concept_id" FOREIGN KEY ("issuing_administrative_area_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
