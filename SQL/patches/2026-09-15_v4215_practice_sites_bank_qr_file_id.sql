-- ============================================================================
-- SALUD · patch v4.2.15 (practice · el QR de cobro de la sede) sobre BD viva
-- Fecha: 2026-09-15
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo IF NOT EXISTS).
-- UNA sola pasada. No hay backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/14_practice/ desde que el
-- .puml la declara, así que en un rebuild desde cero este patch NO hace falta.
-- Existe únicamente para una base ya aplicada y poblada. gen_apply.py no
-- escanea SQL/patches/ (sólo directorios NN_schema), así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. Subtarea A.1 del plan maestro: soporte de modelo para el cobro
-- por QR bancario de la sede (P33). La sede va a poder guardar el archivo de
-- su QR de cobro, igual que ya guarda otros archivos del producto: no se
-- almacena el binario en la fila, se guarda en `common.files` y acá queda
-- sólo su identificador. El endpoint que expone este campo (`PUT
-- /practitioners/me/sites/:siteId/bank-qr`) es de otra tarjeta; este patch
-- entrega la columna y el mapeo, no el endpoint.
--
-- POR QUÉ ES NULLABLE. No toda sede cobra por QR: exigir el archivo obligaría
-- a inventar uno por defecto para las sedes que no usan ese medio de cobro.
--
-- POR QUÉ NO HAY BACKFILL. No existe ninguna fila viva con este dato: recién
-- se agrega la posibilidad de adjuntarlo. No hay qué migrar.
--
-- POR QUÉ `common.files` Y NO UN BYTEA. Mismo destino que
-- `professional_credentials.file_id` y `jurisdiction_authorizations.file_id`:
-- la subida tiene su propio camino, con escaneo antivirus y deducción del
-- tipo real a partir de los bytes. Una segunda puerta con otras reglas es una
-- segunda puerta que auditar.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de practice.practice_sites  17 → 18
--   FKs                                   +1  (fk_practice_sites_bank_qr_file_id)
--   índices                               +1  (ix_practice_sites_bank_qr_file_id)
--   tablas                                ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columna
ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "bank_qr_file_id" uuid;

-- ------------------------------------------------------------------ B. índice
CREATE INDEX IF NOT EXISTS "ix_practice_sites_bank_qr_file_id"
    ON "practice"."practice_sites" ("bank_qr_file_id");

-- ---------------------------------------------------------------------- C. FK
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_practice_sites_bank_qr_file_id'
    ) THEN
        ALTER TABLE "practice"."practice_sites"
            ADD CONSTRAINT "fk_practice_sites_bank_qr_file_id"
            FOREIGN KEY ("bank_qr_file_id")
            REFERENCES "common"."files" ("id");
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
    -- 1: la columna nueva está.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'practice'
      AND table_name = 'practice_sites'
      AND column_name = 'bank_qr_file_id';

    -- 1: la FK existe y está validada (no `NOT VALID`).
    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname = 'fk_practice_sites_bank_qr_file_id'
      AND convalidated;

    -- 1: el índice existe.
    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'practice'
      AND indexname = 'ix_practice_sites_bank_qr_file_id';

    IF n_columnas <> 1 OR n_fk <> 1 OR n_indices <> 1 THEN
        RAISE EXCEPTION
            'v4.2.15 incompleto: columnas=% (esperado 1), fk=% (esperado 1), indices=% (esperado 1)',
            n_columnas, n_fk, n_indices;
    END IF;

    RAISE NOTICE 'v4.2.15 aplicado: 1 columna, 1 FK validada, 1 índice.';
END $$;

COMMIT;
