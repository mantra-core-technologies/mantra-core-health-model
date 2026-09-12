-- ============================================================================
-- SALUD · patch v4.2.9 (insurance · clausula y justificacion del rechazo por linea)
-- Fecha: 2026-09-12
-- Idempotente (ADD COLUMN IF NOT EXISTS).
-- UNA sola pasada. Sin backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: subtarea 2.2 del backlog de correcciones. El registro de procesos
-- del stakeholder (MODULO ASEGURADORA · 2 · 3) exige que la app "responda con
-- APROBADO y NO APROBADO indicando por qué no está APROBADO según la clausula
-- del contrato y porque tiene excepción de alguna enfermedad según su contrato
-- o póliza". Hoy `insurance.claim_line_adjudications` sólo tiene el motivo
-- TIPIFICADO (`reason_concept_id`, FK a terminology.catalog_concepts) y el
-- texto de la versión entera (`claim_adjudication_versions.disposition_text`);
-- no hay texto POR ÍTEM. La ficha TAREA-16 (P-16-3) ya había anticipado esta
-- columna y advertido que, al ser <<IMMUTABLE>>, las adjudicaciones ya escritas
-- quedarían sin ella para siempre.
--
-- QUÉ ENTRA Y QUÉ NO. Dos columnas nullable: `policy_clause_reference`
-- (la cita de la cláusula contractual, texto libre) y `denial_rationale`
-- (la justificación circunstanciada). NO se agrega un tercer código tipificado
-- de exclusión: el motivo tipificado YA es `reason_concept_id` — un value set
-- nuevo de "motivos de exclusión" en texto libre sería un segundo catálogo
-- para el mismo dato, contra la regla del proyecto de que todo catálogo es un
-- value set con `*_concept_id`, no un enum de texto (P-16-4: ese catálogo aún
-- no tiene miembros — es deuda ya fichada, no de esta subtarea).
--
-- POR QUÉ NO HAY BACKFILL. La tabla es <<IMMUTABLE>> (trigger
-- `integrity.forbid_mutation()`): ninguna fila existente puede escribirse de
-- nuevo para agregarle una cláusula que nadie citó en su momento. Una
-- adjudicación anterior a este patch queda con las dos columnas en NULL para
-- siempre; la pantalla lo distingue de "aprobado" o de "sin cláusula
-- registrada", nunca lo confunde con 0/'' vacío.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de insurance.claim_line_adjudications   9 → 11
--   FKs                                              ±0
--   índices                                          ±0
--   tablas                                           ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "insurance"."claim_line_adjudications"
    ADD COLUMN IF NOT EXISTS "policy_clause_reference" varchar;

ALTER TABLE "insurance"."claim_line_adjudications"
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
      AND table_name = 'claim_line_adjudications'
      AND column_name IN ('policy_clause_reference', 'denial_rationale');

    IF n_columnas <> 2 THEN
        RAISE EXCEPTION
            'v4.2.9 incompleto: columnas=% (esperado 2)',
            n_columnas;
    END IF;

    RAISE NOTICE 'v4.2.9 aplicado: 2 columnas nuevas en insurance.claim_line_adjudications.';
END $$;

COMMIT;
