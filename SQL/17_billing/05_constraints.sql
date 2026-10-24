-- SALUD v4.0.10 · schema billing · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ siat_simulated_invoices ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_invoices" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_invoices_simulated";
ALTER TABLE "billing"."siat_simulated_invoices" ADD CONSTRAINT "ck_siat_simulated_invoices_simulated" CHECK ("simulated" = true);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_invoices" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_invoices_status";
ALTER TABLE "billing"."siat_simulated_invoices" ADD CONSTRAINT "ck_siat_simulated_invoices_status" CHECK ("status" IN ('VALIDATED','OBSERVED','REJECTED','ANNULLED'));


-- ═══ siat_simulated_outbox ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_outbox" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_outbox_status";
ALTER TABLE "billing"."siat_simulated_outbox" ADD CONSTRAINT "ck_siat_simulated_outbox_status" CHECK ("status" = 'NOT_SENT_SIMULATED');


-- ═══ quotations ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."quotations" DROP CONSTRAINT IF EXISTS "chk_quotations_payment_frequency";
ALTER TABLE "billing"."quotations" ADD CONSTRAINT "chk_quotations_payment_frequency" CHECK ("payment_frequency" IN ('WEEKLY', 'BIWEEKLY', 'MONTHLY'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."quotations" DROP CONSTRAINT IF EXISTS "chk_quotations_down_payment_range";
ALTER TABLE "billing"."quotations" ADD CONSTRAINT "chk_quotations_down_payment_range" CHECK (("down_payment_amount" >= 0 AND "down_payment_amount" <= "offered_price"));


-- ═══ quotation_installments ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."quotation_installments" DROP CONSTRAINT IF EXISTS "chk_quotation_installments_amount_positive";
ALTER TABLE "billing"."quotation_installments" ADD CONSTRAINT "chk_quotation_installments_amount_positive" CHECK ("amount" > 0);
