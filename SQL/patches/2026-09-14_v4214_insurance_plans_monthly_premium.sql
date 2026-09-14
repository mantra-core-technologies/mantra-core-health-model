-- ============================================================================
-- SALUD · patch v4.2.14 (insurance · prima de lista mensual del plan)
-- Fecha: 2026-09-14
-- Idempotente (ADD COLUMN IF NOT EXISTS). UNA sola pasada. SIN backfill.
--
-- Contexto: subtarea 3.1 (tablero de siniestralidad, gasto per cápita y
-- métricas de salud de la aseguradora). El registro de procesos del
-- stakeholder (MÓDULO ASEGURADORA · 6.3) pide "información de siniestralidad
-- de todos nuestros usuarios" y "gastos por persona de forma mensual, anual".
-- Brecha §22 "Reportes y data agregada", tarjeta T-25 "Indicadores de
-- siniestralidad y uso", que ya lo diagnosticaba: "falta el denominador:
-- patient_coverages no guarda el monto de la prima".
--
-- QUÉ ENTRA Y QUÉ NO. Una columna nullable en insurance.insurance_plans:
-- `monthly_premium_amount` (numeric), la prima de lista MENSUAL del plan, en
-- la moneda del plan (`currency_concept_id`). Es el denominador ESTIMADO del
-- loss ratio: primas devengadas = coberturas vigentes × prima × meses
-- prorrateados. T-25 proponía la prima en `patient_coverages` (por póliza);
-- se decidió con el negocio el 2026-09-14 ponerla en el PLAN: la consola de
-- planes ya existe para cargarla, el tablero filtra por plan, y la prima por
-- póliza puede sumarse después como refinamiento sin deshacer esto.
--
-- POR QUÉ NO HAY BACKFILL. Nadie conoce las primas de lista de las
-- aseguradoras: inventarlas violaría la regla 70 (datos "reales" ficticios).
-- Las carga cada aseguradora por `POST /insurance-products/:id/plans`
-- (campo nuevo `monthlyPremiumAmount`) o `PUT /insurance-plans/:id/premium`.
-- Mientras un plan no tenga prima, el tablero informa "sin prima registrada"
-- y el loss ratio es null, nunca cero.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de insurance.insurance_plans   15 → 16
--   FKs                                     ±0
--   índices                                 ±0
--   tablas                                  ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "insurance"."insurance_plans"
    ADD COLUMN IF NOT EXISTS "monthly_premium_amount" numeric;

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. La consulta tiene que
-- devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
    n_planes integer;
    n_con_prima integer;
BEGIN
    -- 1: la columna nueva está.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'insurance'
      AND table_name = 'insurance_plans'
      AND column_name = 'monthly_premium_amount';

    IF n_columnas <> 1 THEN
        RAISE EXCEPTION
            'v4.2.14 incompleto: columnas=% (esperado 1)',
            n_columnas;
    END IF;

    SELECT count(*), count("monthly_premium_amount")
      INTO n_planes, n_con_prima
    FROM "insurance"."insurance_plans";

    RAISE NOTICE 'v4.2.14 aplicado: monthly_premium_amount en insurance.insurance_plans; % plan(es), % con prima (esperado 0: sin backfill).',
        n_planes, n_con_prima;
END $$;

COMMIT;
