-- ============================================================================
-- SALUD · patch v4.2.7 (profiles · empleador de la persona) sobre BD viva
-- Fecha: 2026-09-06
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo IF NOT EXISTS).
-- UNA sola pasada. No hay backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite estas dos columnas en SQL/05_profiles/ desde
-- que el .puml las declara, así que en un rebuild desde cero este patch NO
-- hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (sólo directorios NN_schema), así que
-- no entra en apply_all.sql.
--
-- QUÉ CIERRA. El commit a90f3207 ("Seed VS_BO_EMPLOYER and accept the
-- employer on patient sign-up") agregó `work_employer_concept_id` y
-- `work_employer_free_text` a la entidad MikroORM `Persons` y al único punto
-- de inserción de la tabla (`PersonsRepository.create()`, usado por el alta
-- de paciente Y de profesional) sin que el modelo canónico llegara a
-- declararlas: deriva ORM-por-delante-del-modelo, detectada el 2026-09-06
-- porque el alta de CUALQUIER persona (paciente o profesional) fallaba con
-- `InvalidFieldNameException: column "work_employer_concept_id" of relation
-- "persons" does not exist` (SQLSTATE 42703) — `work_employer_free_text` es
-- la misma columna faltante, sólo que MikroORM reporta la primera que
-- encuentra. El `.puml` ya está corregido (diagram_05_profiles.puml, v4.2.7)
-- y el DDL de rebuild-desde-cero ya la emite (SQL/05_profiles/); este patch
-- es sólo para no tener que reconstruir el stack para seguir probando altas.
--
-- POR QUÉ SON DOS COLUMNAS Y NO UNA. Mismo patrón que `occupation_concept_id`
-- / `occupation_free_text` en la misma tabla: el catálogo (`VS_BO_EMPLOYER`)
-- con una entrada libre al final para cuando la empresa no está en el
-- catálogo. El concepto gana cuando vienen los dos.
--
-- POR QUÉ NO HAY BACKFILL. No existe ninguna fila viva con este dato: recién
-- se agrega la posibilidad de declararlo. No hay qué migrar.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de profiles.persons  17 → 19
--   FKs                            +1  (fk_persons_work_employer_concept_id)
--   índices                        +1  (ix_persons_work_employer_concept_id)
--   tablas                         ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "profiles"."persons"
    ADD COLUMN IF NOT EXISTS "work_employer_concept_id" uuid;

ALTER TABLE "profiles"."persons"
    ADD COLUMN IF NOT EXISTS "work_employer_free_text" varchar;

-- ------------------------------------------------------------------ B. índice
CREATE INDEX IF NOT EXISTS "ix_persons_work_employer_concept_id"
    ON "profiles"."persons" ("work_employer_concept_id");

-- ---------------------------------------------------------------------- C. FK
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_persons_work_employer_concept_id'
    ) THEN
        ALTER TABLE "profiles"."persons"
            ADD CONSTRAINT "fk_persons_work_employer_concept_id"
            FOREIGN KEY ("work_employer_concept_id")
            REFERENCES "terminology"."catalog_concepts" ("id");
    END IF;
END $$;

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. Las tres consultas
-- tienen que devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
    n_fk       integer;
    n_indices  integer;
BEGIN
    -- 2: las dos columnas nuevas están.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'profiles'
      AND table_name = 'persons'
      AND column_name IN ('work_employer_concept_id', 'work_employer_free_text');

    -- 1: la FK existe y está validada (no `NOT VALID`).
    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname = 'fk_persons_work_employer_concept_id'
      AND convalidated;

    -- 1: el índice existe.
    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'profiles'
      AND indexname = 'ix_persons_work_employer_concept_id';

    IF n_columnas <> 2 OR n_fk <> 1 OR n_indices <> 1 THEN
        RAISE EXCEPTION
            'v4.2.7 incompleto: columnas=% (esperado 2), fk=% (esperado 1), indices=% (esperado 1)',
            n_columnas, n_fk, n_indices;
    END IF;

    RAISE NOTICE 'v4.2.7 aplicado: 2 columnas, 1 FK validada, 1 índice.';
END $$;

COMMIT;
