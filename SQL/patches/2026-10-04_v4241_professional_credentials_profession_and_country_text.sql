-- ============================================================================
-- SALUD · patch v4.2.41 (profiles · la profesión y el país del título) sobre BD viva
-- Fecha: 2026-10-04 · correcciones del propietario sobre el alta del médico
-- Idempotente (IF NOT EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py ya emite estas columnas, su índice y su FK en
-- SQL/05_profiles/ desde que el .puml las declara, así que en un rebuild desde
-- cero este patch NO hace falta. Existe únicamente para una base ya aplicada y
-- poblada. gen_apply.py no escanea SQL/patches/, así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. El alta del médico pide, por cada título, la profesión («Otra
-- profesión»), el país y la ciudad, y la API descartaba los tres. La ciudad ya
-- tenía columna (v4.2.29); faltaban:
--
--   - `profession_concept_id`: qué profesión acredita el título, como miembro
--     de VS_BO_PROFESSION (COB-2023 del INE, grandes grupos 2 y 3, lo publica
--     la API al arrancar). Era texto escrito a mano; el propietario pidió lista
--     normalizada (2026-10-04).
--   - `issuing_country_text`: el país como texto. `issuing_country_concept_id`
--     no alcanza porque VS_COUNTRY tiene un solo miembro. El concepto gana
--     cuando vienen los dos, igual que la ocupación de `persons`.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de profiles.professional_credentials  +2
--   FKs +1 (fk_professional_credentials_profession_concept_id)
--   índices +1 (ix_professional_credentials_profession_concept_id) · tablas ±0
-- ============================================================================

BEGIN;

ALTER TABLE "profiles"."professional_credentials"
    ADD COLUMN IF NOT EXISTS "issuing_country_text" varchar;

ALTER TABLE "profiles"."professional_credentials"
    ADD COLUMN IF NOT EXISTS "profession_concept_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_professional_credentials_profession_concept_id"
    ON "profiles"."professional_credentials" ("profession_concept_id");

DO $$ BEGIN
    ALTER TABLE "profiles"."professional_credentials"
        ADD CONSTRAINT "fk_professional_credentials_profession_concept_id"
        FOREIGN KEY ("profession_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
DECLARE
    n_columnas integer;
    n_fk integer;
    n_ix integer;
BEGIN
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'profiles'
      AND table_name = 'professional_credentials'
      AND column_name IN ('issuing_country_text', 'profession_concept_id')
      AND is_nullable = 'YES';

    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname = 'fk_professional_credentials_profession_concept_id';

    SELECT count(*) INTO n_ix
    FROM pg_indexes
    WHERE schemaname = 'profiles'
      AND indexname = 'ix_professional_credentials_profession_concept_id';

    IF n_columnas <> 2 OR n_fk <> 1 OR n_ix <> 1 THEN
        RAISE EXCEPTION
            'v4.2.41 incompleto: columnas=% fk=% índices=% (esperado 2/1/1)',
            n_columnas, n_fk, n_ix;
    END IF;

    RAISE NOTICE 'v4.2.41 aplicado: 2 columnas, 1 FK, 1 índice.';
END $$;

COMMIT;
