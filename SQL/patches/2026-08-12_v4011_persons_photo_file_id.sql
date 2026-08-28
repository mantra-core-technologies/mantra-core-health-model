-- ============================================================================
-- SALUD · patch v4.0.11 (persons.photo_file_id) sobre una BD viva · Fecha: 2026-08-12
-- Idempotente (ADD COLUMN ... IF NOT EXISTS / duplicate_object / IF NOT EXISTS)
--
-- Contexto: gen_ddl.py solo emite CREATE TABLE IF NOT EXISTS, así que en un
-- rebuild desde cero esta columna ya viene en SQL/05_profiles/02_tables.sql, el
-- índice en 04_indexes.sql y la FK en 90_fk_deferred.sql; este patch no hace
-- falta. Existe únicamente para una base ya aplicada y poblada. gen_apply.py no
-- escanea SQL/patches/ (solo directorios NN_schema), así que no entra en
-- apply_all.sql.
--
-- Completa el desdoble de identidad de v4.0.11: `profiles.persons` gana la foto
-- de la persona, con el mismo patrón que ya usa
-- `health_practitioner_profiles.photo_file_id` — un uuid NULLABLE que apunta a
-- `common.files`, porque el binario vive en el object store y acá solo se
-- referencia su registro. Es de la persona y no del perfil de paciente: la foto
-- identifica a quien entra por la puerta, cualquiera sea el rol con el que lo
-- haga, y duplicarla por perfil obligaría a elegir cuál manda cuando difieren.
--
-- IMPORTANTE: aplicar con el rol propietario (mantra).
-- ============================================================================

ALTER TABLE "profiles"."persons"
    ADD COLUMN IF NOT EXISTS "photo_file_id" uuid;

DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_photo_file_id" FOREIGN KEY ("photo_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_persons_photo_file_id" ON "profiles"."persons" ("photo_file_id");

-- Comprobación: la columna existe, es opcional, y la FK quedó validada.
--   SELECT column_name, is_nullable
--     FROM information_schema.columns
--    WHERE table_schema = 'profiles' AND table_name = 'persons'
--      AND column_name = 'photo_file_id';
--   SELECT conname, convalidated FROM pg_constraint
--    WHERE conname = 'fk_persons_photo_file_id';
