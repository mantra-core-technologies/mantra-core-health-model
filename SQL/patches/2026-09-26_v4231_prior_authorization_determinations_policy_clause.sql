-- ============================================================================
-- SALUD · patch v4.2.31 (insurance · cláusula y justificación del rechazo por
-- ítem en la autorización previa)
-- Fecha: 2026-09-26
-- Idempotente (ADD COLUMN IF NOT EXISTS).
-- UNA sola pasada. Sin backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: el registro de procesos del stakeholder (MODULO ASEGURADORA ·
-- Recepción de solicitudes de órdenes de Aprobación · 3) exige que la app
-- responda "APROBADO y NO APROBADO indicando por qué no está APROBADO según la
-- clausula del contrato". Y el módulo paciente (receta, laboratorio, análisis)
-- pide que por cada ítem no aprobado se detalle "el motivo porque NO fueron
-- aprobados según póliza (este detalle envía el seguro)".
--
-- `insurance.prior_authorization_determinations` ya admite una determinación
-- POR ÍTEM (`prior_authorization_item_id`) y un motivo TIPIFICADO
-- (`denial_reason_concept_id`), pero no tiene dónde guardar la cita de la
-- cláusula ni la justificación en texto. Es el mismo hueco que v4.2.9 cerró en
-- `claim_line_adjudications`, con los mismos nombres de columna.
--
-- POR QUÉ NO HAY BACKFILL. La tabla es <<IMMUTABLE>>: una determinación
-- anterior a este patch queda con las dos columnas en NULL para siempre.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de insurance.prior_authorization_determinations   13 → 15
--   FKs                                                        ±0
--   índices                                                    ±0
--   tablas                                                     ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "insurance"."prior_authorization_determinations"
    ADD COLUMN IF NOT EXISTS "policy_clause_reference" varchar;

ALTER TABLE "insurance"."prior_authorization_determinations"
    ADD COLUMN IF NOT EXISTS "denial_rationale" text;

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. La consulta tiene que
-- devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
BEGIN
    -- 2: las dos columnas nuevas están.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'insurance'
      AND table_name = 'prior_authorization_determinations'
      AND column_name IN ('policy_clause_reference', 'denial_rationale');

    IF n_columnas <> 2 THEN
        RAISE EXCEPTION
            'v4.2.31 incompleto: columnas=% (esperado 2)',
            n_columnas;
    END IF;

    RAISE NOTICE 'v4.2.31 aplicado: 2 columnas nuevas en insurance.prior_authorization_determinations.';
END $$;

COMMIT;
