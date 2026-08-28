-- ============================================================================
-- SALUD · patch v4.0.10 → v4.0.11 sobre una BD viva · Fecha: 2026-08-10
-- Idempotente (ADD COLUMN ... IF NOT EXISTS)
--
-- Contexto: gen_ddl.py solo emite CREATE TABLE IF NOT EXISTS, así que en un
-- rebuild desde cero estas columnas ya vienen en SQL/05_profiles/02_tables.sql y
-- este patch no hace falta. Existe únicamente para una base ya aplicada y
-- poblada. gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así
-- que no entra en apply_all.sql.
--
-- Desdobla el nombre de una persona en sus cuatro partes. `profiles.persons`
-- guardaba únicamente `display_name`, un texto libre: para saber si dos personas
-- comparten apellido paterno había que adivinarlo partiendo la cadena, y partir
-- un nombre es una conjetura que falla con los nombres compuestos y con los
-- apellidos de más de una palabra.
--
-- Las cuatro son NULLABLE y `display_name` se conserva:
--   * las 1.4 M de filas ya cargadas siguen siendo válidas y no hay que
--     inventarles un desdoble que nadie declaró;
--   * `display_name` sigue siendo lo que pinta cada pantalla y contra lo que
--     busca el buscador, ahora derivado de las partes en vez de tecleado;
--   * un recién nacido, una urgencia sin identificar o un registro importado
--     pueden llegar sin ninguna de las cinco.
--
-- IMPORTANTE: aplicar con el rol propietario (mantra).
-- ============================================================================

ALTER TABLE "profiles"."persons"
    ADD COLUMN IF NOT EXISTS "name" varchar,
    ADD COLUMN IF NOT EXISTS "middle_name" varchar,
    ADD COLUMN IF NOT EXISTS "last_name" varchar,
    ADD COLUMN IF NOT EXISTS "mother_last_name" varchar;

-- Comprobación: 5 columnas de nombre y ninguna obligatoria.
--   SELECT column_name, is_nullable
--     FROM information_schema.columns
--    WHERE table_schema = 'profiles' AND table_name = 'persons'
--      AND column_name IN ('name','middle_name','last_name','mother_last_name','display_name')
--    ORDER BY ordinal_position;
