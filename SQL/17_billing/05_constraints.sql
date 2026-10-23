-- SALUD v4.0.10 · schema billing · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ payment_proofs ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."payment_proofs" DROP CONSTRAINT IF EXISTS "ck_payment_proofs_qr_requires_file";
ALTER TABLE "billing"."payment_proofs" ADD CONSTRAINT "ck_payment_proofs_qr_requires_file" CHECK (("method_concept_id" <> '78a2a1c8-5e68-5aaa-b43f-b23d00f69e95' OR "file_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."payment_proofs" DROP CONSTRAINT IF EXISTS "ck_payment_proofs_rejected_requires_reason";
ALTER TABLE "billing"."payment_proofs" ADD CONSTRAINT "ck_payment_proofs_rejected_requires_reason" CHECK (("status_concept_id" <> 'c487d958-3cbf-5082-8b6a-735cb2186cd8' OR NULLIF(BTRIM("rejection_reason"), '') IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."payment_proofs" DROP CONSTRAINT IF EXISTS "ck_payment_proofs_amount_positive";
ALTER TABLE "billing"."payment_proofs" ADD CONSTRAINT "ck_payment_proofs_amount_positive" CHECK (("amount_minor" > 0));


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
