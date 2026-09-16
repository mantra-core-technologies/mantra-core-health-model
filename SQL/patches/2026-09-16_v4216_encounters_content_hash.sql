-- ============================================================================
-- SALUD · patch v4.2.16 (clinical · sello de cierre del encuentro) sobre BD viva
-- Fecha: 2026-09-16
-- Idempotente (ADD COLUMN IF NOT EXISTS).
-- UNA sola pasada. No hay backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite estas columnas en SQL/08_clinical/ desde que
-- el .puml las declara, así que en un rebuild desde cero este patch NO hace
-- falta. Existe únicamente para una base ya aplicada y poblada. gen_apply.py
-- no escanea SQL/patches/ (sólo directorios NN_schema), así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. Subtarea C.4 del plan maestro: sello SHA-256 inmutable del
-- encuentro clínico, calculado y guardado al cerrarlo. `content_hash` guarda
-- el hash hexadecimal del JSON canónico del contenido del encuentro en el
-- momento del cierre; `sealed_at` guarda cuándo se calculó ese sello.
--
-- POR QUÉ NULLABLE. Un encuentro en curso todavía no tiene sello: recién se
-- calcula cuando `EncountersService.close()` lo pasa a `ENCOUNTER_FINISHED`.
-- Exigir el valor obligaría a inventar un sello para todo encuentro abierto.
--
-- POR QUÉ NO HAY BACKFILL. Los encuentros cerrados antes de v4.2.16 no tienen
-- un sello verificable: sellarlos ahora sería firmar sin haber estado
-- presente en el cierre real. Quedan sin sello, y su PDF oficial lo declara
-- (422) en vez de inventar uno.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de clinical.encounters  18 → 20
--   FKs                               ±0
--   índices                           ±0
--   tablas                            ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "content_hash" varchar;

ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "sealed_at" timestamptz;

-- ------------------------------------------------------------ B. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. La consulta tiene
-- que devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
BEGIN
    -- 20: el total de columnas de clinical.encounters tras sumar las 2 nuevas.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'clinical'
      AND table_name = 'encounters';

    IF n_columnas <> 20 THEN
        RAISE EXCEPTION
            'v4.2.16 incompleto: columnas=% (esperado 20)',
            n_columnas;
    END IF;

    RAISE NOTICE 'v4.2.16 aplicado: 2 columnas nuevas en clinical.encounters.';
END $$;

COMMIT;
