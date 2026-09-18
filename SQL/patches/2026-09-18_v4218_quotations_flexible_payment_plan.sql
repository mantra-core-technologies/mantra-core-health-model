-- ============================================================================
-- SALUD · patch v4.2.18 (billing · plan de pagos flexible, SIN interés) sobre BD viva
-- Fecha: 2026-09-18
-- Idempotente (ADD/DROP COLUMN IF EXISTS / constraints bajo guarda). UNA sola
-- pasada, en UNA transacción.
--
-- Contexto: T24 (cotizaciones). El propietario pidió quitar por completo la
-- tasa de interés y la simulación de crédito: un consultorio no financia,
-- reparte el precio de un tratamiento en cuotas a medida de la persona, cada
-- una con su propia fecha y su propio monto. Ver P35 en
-- mantra-core-health/PENDIENTES-BACKEND.md.
--
-- QUÉ CAMBIA.
--   billing.quotations
--     - interest_rate_percent, interest_calculation_method   (fuera)
--     - chk_quotations_interest_method                       (fuera)
--     + down_payment_amount numeric NOT NULL   (lo que se paga el día de la atención)
--     + payment_frequency  varchar NOT NULL    (WEEKLY · BIWEEKLY · MONTHLY)
--     + chk_quotations_payment_frequency, chk_quotations_down_payment_range
--   billing.quotation_installments
--     - principal_amount, interest_amount, total_amount      (fuera)
--     + amount numeric NOT NULL
--     + chk_quotation_installments_amount_positive
--
-- BACKFILL de filas ya existentes (si las hay):
--   down_payment_amount = 0            — el simulador viejo no tenía anticipo.
--   payment_frequency   = 'MONTHLY'    — el simulador viejo vencía mes a mes.
--   amount              = total_amount — lo que se le ofreció pagar por cuota.
-- Ojo: en una cotización vieja con interés, la suma de las cuotas queda por
-- encima del precio. Es el dato que se le mostró a la persona; no se reescribe.
--
-- ⚠ DESTRUCTIVO: las columnas de interés se BORRAN con sus datos. Hacé un
-- respaldo de billing.quotations y billing.quotation_installments antes, si
-- la base tiene cotizaciones que importen.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de billing.quotations              ±0 (−2 +2)
--   columnas de billing.quotation_installments  −2 (−3 +1)
--   CHECK                                       +2 (−1 +3)
--   tablas / FKs / índices                      ±0
-- ============================================================================

BEGIN;

-- ----------------------------------------------------- A. columnas nuevas + backfill
ALTER TABLE "billing"."quotations"
    ADD COLUMN IF NOT EXISTS "down_payment_amount" numeric,
    ADD COLUMN IF NOT EXISTS "payment_frequency" varchar;

UPDATE "billing"."quotations" SET "down_payment_amount" = 0 WHERE "down_payment_amount" IS NULL;
UPDATE "billing"."quotations" SET "payment_frequency" = 'MONTHLY' WHERE "payment_frequency" IS NULL;

ALTER TABLE "billing"."quotations"
    ALTER COLUMN "down_payment_amount" SET NOT NULL,
    ALTER COLUMN "payment_frequency" SET NOT NULL;

ALTER TABLE "billing"."quotation_installments"
    ADD COLUMN IF NOT EXISTS "amount" numeric;

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'billing' AND table_name = 'quotation_installments'
          AND column_name = 'total_amount'
    ) THEN
        UPDATE "billing"."quotation_installments" SET "amount" = "total_amount" WHERE "amount" IS NULL;
    END IF;
END $$;

ALTER TABLE "billing"."quotation_installments"
    ALTER COLUMN "amount" SET NOT NULL;

-- ------------------------------------------------------------- B. fuera el interés
ALTER TABLE "billing"."quotations" DROP CONSTRAINT IF EXISTS "chk_quotations_interest_method";
ALTER TABLE "billing"."quotations"
    DROP COLUMN IF EXISTS "interest_rate_percent",
    DROP COLUMN IF EXISTS "interest_calculation_method";

ALTER TABLE "billing"."quotation_installments"
    DROP COLUMN IF EXISTS "principal_amount",
    DROP COLUMN IF EXISTS "interest_amount",
    DROP COLUMN IF EXISTS "total_amount";

-- ------------------------------------------------------------------- C. CHECKs
-- Los mismos que emite gen_integrity.py en SQL/17_billing/05_constraints.sql.
ALTER TABLE "billing"."quotations" DROP CONSTRAINT IF EXISTS "chk_quotations_payment_frequency";
ALTER TABLE "billing"."quotations" ADD CONSTRAINT "chk_quotations_payment_frequency"
    CHECK ("payment_frequency" IN ('WEEKLY', 'BIWEEKLY', 'MONTHLY'));

ALTER TABLE "billing"."quotations" DROP CONSTRAINT IF EXISTS "chk_quotations_down_payment_range";
ALTER TABLE "billing"."quotations" ADD CONSTRAINT "chk_quotations_down_payment_range"
    CHECK (("down_payment_amount" >= 0 AND "down_payment_amount" <= "offered_price"));

ALTER TABLE "billing"."quotation_installments" DROP CONSTRAINT IF EXISTS "chk_quotation_installments_amount_positive";
ALTER TABLE "billing"."quotation_installments" ADD CONSTRAINT "chk_quotation_installments_amount_positive"
    CHECK ("amount" > 0);

-- ------------------------------------------------------------ D. verificación
-- Si alguna comprobación falla, la transacción entera se deshace.
DO $$
DECLARE
    n_interes integer;
    n_nuevas  integer;
    n_cuota   integer;
    n_checks  integer;
BEGIN
    SELECT count(*) INTO n_interes FROM information_schema.columns
    WHERE table_schema = 'billing'
      AND table_name IN ('quotations', 'quotation_installments')
      AND column_name IN ('interest_rate_percent', 'interest_calculation_method',
                          'principal_amount', 'interest_amount', 'total_amount');
    IF n_interes <> 0 THEN RAISE EXCEPTION 'quedan % columnas de interés', n_interes; END IF;

    SELECT count(*) INTO n_nuevas FROM information_schema.columns
    WHERE table_schema = 'billing' AND table_name = 'quotations'
      AND column_name IN ('down_payment_amount', 'payment_frequency') AND is_nullable = 'NO';
    IF n_nuevas <> 2 THEN RAISE EXCEPTION 'quotations: esperaba 2 columnas nuevas NOT NULL, hay %', n_nuevas; END IF;

    SELECT count(*) INTO n_cuota FROM information_schema.columns
    WHERE table_schema = 'billing' AND table_name = 'quotation_installments'
      AND column_name = 'amount' AND is_nullable = 'NO';
    IF n_cuota <> 1 THEN RAISE EXCEPTION 'quotation_installments.amount no quedó NOT NULL'; END IF;

    SELECT count(*) INTO n_checks FROM pg_constraint
    WHERE conname IN ('chk_quotations_payment_frequency', 'chk_quotations_down_payment_range',
                      'chk_quotation_installments_amount_positive');
    IF n_checks <> 3 THEN RAISE EXCEPTION 'esperaba 3 CHECK, hay %', n_checks; END IF;
END $$;

COMMIT;
