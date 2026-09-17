-- ============================================================================
-- SALUD · patch v4.2.17 (clinical · antiduplicación de estudios) sobre BD viva
-- Fecha: 2026-09-17
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo guarda). UNA sola pasada. SIN backfill.
--
-- Contexto: subtarea 3.2 (motor de alerta y prevención de duplicidad de
-- estudios de laboratorio e imagenología). El registro de procesos del
-- stakeholder (MÓDULO ASEGURADORA · 6.3, ítem 4) pide que la aseguradora no
-- pague dos veces el mismo estudio pedido en corto tiempo. Brecha §23
-- "Antiduplicación de estudios" y tarjeta T-26 "Vigencia del resultado y
-- antiduplicación" ya lo diagnosticaban: falta el enlace del pedido nuevo al
-- reporte previo que lo satisface.
--
-- QUÉ ENTRA. Dos columnas nullable en clinical.service_requests:
-- `previous_diagnostic_report_id` (FK → clinical.diagnostic_reports) y
-- `duplicate_override_reason` (text). El motor de duplicidad (API) busca, al
-- pedirse un estudio, un informe liberado o final del mismo paciente y del
-- mismo code_concept_id dentro de una ventana (30 días por defecto, no
-- declarada en el modelo). Si lo encuentra, la orden nueva queda enlazada:
-- con `duplicate_override_reason` NULL la orden nace en el estado dinámico
-- SR_SATISFIED_BY_PRIOR (satisfecha por ese informe, no facturable); con
-- texto, el médico insistió y repite el estudio con justificación clínica —
-- la orden sigue ACTIVE. Un CHECK físico cierra el estado imposible
-- "justificación sin informe previo enlazado".
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Ninguna orden viva tiene hoy un duplicado
-- que reconstruir retroactivamente: la regla empieza a aplicarse desde que se
-- despliega. Inventar enlaces para órdenes pasadas sería fabricar un dato
-- clínico que nadie declaró.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de clinical.service_requests   16 → 18
--   FKs                                      +1  (fk_service_requests_previous_diagnostic_report_id)
--   índices                                  +1  (ix_service_requests_previous_diagnostic_report_id)
--   CHECK                                    +1  (ck_service_requests_override_reason_requires_previous_report)
--   tablas                                   ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "previous_diagnostic_report_id" uuid,
    ADD COLUMN IF NOT EXISTS "duplicate_override_reason" text;

-- ------------------------------------------------------------------ B. índice
CREATE INDEX IF NOT EXISTS "ix_service_requests_previous_diagnostic_report_id"
    ON "clinical"."service_requests" ("previous_diagnostic_report_id");

-- ---------------------------------------------------------------------- C. FK
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_service_requests_previous_diagnostic_report_id'
    ) THEN
        ALTER TABLE "clinical"."service_requests"
            ADD CONSTRAINT "fk_service_requests_previous_diagnostic_report_id"
            FOREIGN KEY ("previous_diagnostic_report_id")
            REFERENCES "clinical"."diagnostic_reports" ("id");
    END IF;
END $$;

-- ------------------------------------------------------------------- C bis. CHECK
ALTER TABLE "clinical"."service_requests"
    DROP CONSTRAINT IF EXISTS "ck_service_requests_override_reason_requires_previous_report";
ALTER TABLE "clinical"."service_requests"
    ADD CONSTRAINT "ck_service_requests_override_reason_requires_previous_report"
    CHECK (("duplicate_override_reason" IS NULL OR "previous_diagnostic_report_id" IS NOT NULL));

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. Las cuatro consultas
-- tienen que devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
    n_fk       integer;
    n_indices  integer;
    n_check    integer;
BEGIN
    -- 2: las columnas nuevas están.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'clinical'
      AND table_name = 'service_requests'
      AND column_name IN ('previous_diagnostic_report_id', 'duplicate_override_reason');

    -- 1: la FK existe y está validada (no `NOT VALID`).
    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname = 'fk_service_requests_previous_diagnostic_report_id'
      AND convalidated;

    -- 1: el índice existe.
    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'clinical'
      AND indexname = 'ix_service_requests_previous_diagnostic_report_id';

    -- 1: el CHECK existe y está validado.
    SELECT count(*) INTO n_check
    FROM pg_constraint
    WHERE conname = 'ck_service_requests_override_reason_requires_previous_report'
      AND convalidated;

    IF n_columnas <> 2 OR n_fk <> 1 OR n_indices <> 1 OR n_check <> 1 THEN
        RAISE EXCEPTION
            'v4.2.17 incompleto: columnas=% (esperado 2), fk=% (esperado 1), indices=% (esperado 1), check=% (esperado 1)',
            n_columnas, n_fk, n_indices, n_check;
    END IF;

    RAISE NOTICE 'v4.2.17 aplicado: 2 columnas, 1 FK validada, 1 índice, 1 CHECK validado.';
END $$;

COMMIT;
