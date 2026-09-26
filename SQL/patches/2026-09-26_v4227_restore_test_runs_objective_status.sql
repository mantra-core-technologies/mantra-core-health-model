-- ============================================================================
-- SALUD · patch v4.2.27 (system_ops · estado trivalente de la prueba de restore)
-- Fecha original: 2026-09-19 (API, v4.2.20) · promovido al modelo: 2026-09-26
--
-- PROMOCIÓN AL MODELO (carril M1). Colisionaba con v4.2.20 de qa_execution (dos
-- parches distintos con el mismo número). Se renumera a v4.2.27. La columna y
-- el CHECK ya están declarados en el modelo: `objective_status` en
-- `restore_test_runs` (diagram_11_system_ops.puml) y
-- `ck_system_ops_restore_test_runs_objective_status` (diagram_33_integrity.puml,
-- CHECK_SQL). Este patch es el camino de ALTER para una base YA viva; una base
-- nueva ya sale con la columna desde `02_tables.sql`. Contenido SIN CAMBIOS
-- salvo la numeración.
-- Idempotente (ADD COLUMN IF NOT EXISTS). UNA sola pasada. Backfill honesto.
--
-- Contexto: MCH-023. `recordRestoreTest` devolvía un booleano `objectiveBreached`
-- calculado con comparaciones condicionadas a que las mediciones existieran. Si
-- llegaban ausentes daba `false` — "no incumple" — y cualquier consumidor lo lee
-- como "cumple". Una restauración de la que no se midió nada quedaba
-- indistinguible de una medida y aprobada, y eso en continuidad es exactamente
-- la confusión que no se puede permitir.
--
-- QUÉ ENTRA. Una columna en system_ops.restore_test_runs: `objective_status`
-- varchar NOT NULL con CHECK sobre los tres valores del contrato
-- ('PASSED' | 'FAILED' | 'NOT_MEASURED') y DEFAULT 'NOT_MEASURED'. El mismo
-- contrato que expone el DTO y que calcula
-- `src/modules/system_ops/policies/restore-assessment.policy.ts`.
--
-- POR QUÉ EL BACKFILL ES 'NOT_MEASURED' PARA TODO. Las filas anteriores se
-- registraron con un sistema que no sabía distinguir "no se midió" de "no
-- incumple": su booleano no es evidencia de nada. Derivar 'PASSED' de ellas
-- sería inventar una aprobación que nunca se demostró. Se las marca como no
-- medidas, que es lo único cierto que se sabe de ellas. Si alguna tuviera
-- mediciones completas, vuelve a evaluarse registrando una corrida nueva: la
-- tabla es append-only.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de system_ops.restore_test_runs   11 → 12
--   CHECK constraints                          +1
--   FKs                                        ±0
--   índices                                    ±0
--   tablas                                     ±0
--
-- ROLLBACK:
--   ALTER TABLE "system_ops"."restore_test_runs"
--       DROP CONSTRAINT IF EXISTS "ck_restore_test_runs_objective_status";
--   ALTER TABLE "system_ops"."restore_test_runs"
--       DROP COLUMN IF EXISTS "objective_status";
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "system_ops"."restore_test_runs"
    ADD COLUMN IF NOT EXISTS "objective_status" varchar NOT NULL
        DEFAULT 'NOT_MEASURED';

-- ------------------------------------------------------------ B. restricción
-- El mismo contrato de tres estados que el DTO y el servicio. Sin esto la base
-- aceptaría cualquier cadena y el "mismo contrato en los tres" sería de palabra.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_restore_test_runs_objective_status'
          AND conrelid = '"system_ops"."restore_test_runs"'::regclass
    ) THEN
        ALTER TABLE "system_ops"."restore_test_runs"
            ADD CONSTRAINT "ck_restore_test_runs_objective_status"
            CHECK ("objective_status" IN ('PASSED', 'FAILED', 'NOT_MEASURED'));
    END IF;
END $$;

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. La consulta tiene que
-- devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
    n_checks integer;
    n_corridas integer;
    n_sin_medir integer;
BEGIN
    -- 1: la columna nueva está y es NOT NULL.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'system_ops'
      AND table_name = 'restore_test_runs'
      AND column_name = 'objective_status'
      AND is_nullable = 'NO';

    IF n_columnas <> 1 THEN
        RAISE EXCEPTION
            'v4.2.20 incompleto: columnas NOT NULL=% (esperado 1)',
            n_columnas;
    END IF;

    -- 2: el CHECK de los tres estados está.
    SELECT count(*) INTO n_checks
    FROM pg_constraint
    WHERE conname = 'ck_restore_test_runs_objective_status'
      AND conrelid = '"system_ops"."restore_test_runs"'::regclass;

    IF n_checks <> 1 THEN
        RAISE EXCEPTION
            'v4.2.20 incompleto: CHECK de objective_status=% (esperado 1)',
            n_checks;
    END IF;

    -- 3: ninguna fila heredada quedó declarada como aprobada.
    SELECT count(*), count(*) FILTER (WHERE "objective_status" = 'NOT_MEASURED')
      INTO n_corridas, n_sin_medir
    FROM "system_ops"."restore_test_runs";

    IF n_corridas <> n_sin_medir THEN
        RAISE EXCEPTION
            'v4.2.20 incompleto: % corrida(s) heredada(s) no quedaron como NOT_MEASURED (% marcadas)',
            n_corridas, n_sin_medir;
    END IF;

    RAISE NOTICE 'v4.2.20 aplicado: objective_status en system_ops.restore_test_runs; % corrida(s) heredada(s) marcadas NOT_MEASURED (lo único cierto que se sabe de ellas).',
        n_corridas;
END $$;

COMMIT;
