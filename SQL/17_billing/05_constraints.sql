-- SALUD v4.0.10 · schema billing · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


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
