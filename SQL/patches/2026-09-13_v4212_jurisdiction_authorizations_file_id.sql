-- ============================================================================
-- SALUD · patch v4.2.12 (profiles · el adjunto de la matrícula) sobre BD viva
-- Fecha: 2026-09-13
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo IF NOT EXISTS).
-- UNA sola pasada. No hay backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/05_profiles/ desde que el
-- .puml la declara, así que en un rebuild desde cero este patch NO hace falta.
-- Existe únicamente para una base ya aplicada y poblada. gen_apply.py no
-- escanea SQL/patches/ (sólo directorios NN_schema), así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. El bloqueo «Las matrículas no pueden llevar adjunto: falta el
-- campo en el contrato», anotado en mantra-core-health/docs/progress/BLOCKERS.md
-- el 2026-09-10. El propietario pidió poder cargar matrículas **con su
-- respaldo** desde «Editar perfil» del médico, con el mismo criterio del alta.
-- La mitad que existía se entregó: el título declara `file_id` y el diploma se
-- sube con `POST /common/files/upload`. La matrícula no tenía dónde llevarlo:
-- `jurisdiction_authorizations` no tiene columna de archivo, así que un
-- selector en el formulario habría aceptado el PDF y lo habría tirado en
-- silencio al guardar. Esta columna es la otra mitad.
--
-- POR QUÉ ES NULLABLE. El padrón se **declara**, no se prueba: quien se
-- registra escribe su número de matrícula y la plataforma lo verifica después.
-- Exigir el archivo dejaría fuera del alta a cualquiera que todavía no lo tenga
-- escaneado, y convertiría un trámite de un minuto en uno de una tarde.
--
-- POR QUÉ NO HAY BACKFILL. No existe ninguna fila viva con este dato: recién se
-- agrega la posibilidad de adjuntarlo. No hay qué migrar. Las matrículas ya
-- cargadas quedan sin respaldo, que es exactamente lo que son hoy.
--
-- POR QUÉ `common.files` Y NO UN BYTEA. Mismo destino que
-- `professional_credentials.file_id`: la subida tiene su propio camino, con
-- escaneo antivirus y deducción del tipo real a partir de los bytes. Una
-- segunda puerta con otras reglas es una segunda puerta que auditar.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de profiles.jurisdiction_authorizations  14 → 15
--   FKs                                                +1  (fk_jurisdiction_authorizations_file_id)
--   índices                                            +1  (ix_jurisdiction_authorizations_file_id)
--   tablas                                             ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columna
ALTER TABLE "profiles"."jurisdiction_authorizations"
    ADD COLUMN IF NOT EXISTS "file_id" uuid;

-- ------------------------------------------------------------------ B. índice
CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_file_id"
    ON "profiles"."jurisdiction_authorizations" ("file_id");

-- ---------------------------------------------------------------------- C. FK
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_jurisdiction_authorizations_file_id'
    ) THEN
        ALTER TABLE "profiles"."jurisdiction_authorizations"
            ADD CONSTRAINT "fk_jurisdiction_authorizations_file_id"
            FOREIGN KEY ("file_id")
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
    WHERE table_schema = 'profiles'
      AND table_name = 'jurisdiction_authorizations'
      AND column_name = 'file_id';

    -- 1: la FK existe y está validada (no `NOT VALID`).
    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname = 'fk_jurisdiction_authorizations_file_id'
      AND convalidated;

    -- 1: el índice existe.
    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'profiles'
      AND indexname = 'ix_jurisdiction_authorizations_file_id';

    IF n_columnas <> 1 OR n_fk <> 1 OR n_indices <> 1 THEN
        RAISE EXCEPTION
            'v4.2.12 incompleto: columnas=% (esperado 1), fk=% (esperado 1), indices=% (esperado 1)',
            n_columnas, n_fk, n_indices;
    END IF;

    RAISE NOTICE 'v4.2.12 aplicado: 1 columna, 1 FK validada, 1 índice.';
END $$;

COMMIT;
