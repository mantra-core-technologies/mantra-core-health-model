-- SALUD v4.2.83 · schema billing · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ siat_simulated_invoices ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_invoices" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_invoices_simulated";
ALTER TABLE "billing"."siat_simulated_invoices" ADD CONSTRAINT "ck_siat_simulated_invoices_simulated" CHECK ("simulated" = true);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_invoices" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_invoices_status";
ALTER TABLE "billing"."siat_simulated_invoices" ADD CONSTRAINT "ck_siat_simulated_invoices_status" CHECK ("status" IN ('VALIDATED','OBSERVED','REJECTED','ANNULLED'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_invoices" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_invoices_siat_mode";
ALTER TABLE "billing"."siat_simulated_invoices" ADD CONSTRAINT "ck_siat_simulated_invoices_siat_mode" CHECK ("siat_mode" IN ('simulated','real'));


-- ═══ siat_simulated_outbox ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_outbox" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_outbox_status";
ALTER TABLE "billing"."siat_simulated_outbox" ADD CONSTRAINT "ck_siat_simulated_outbox_status" CHECK ("status" = 'NOT_SENT_SIMULATED');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."siat_simulated_outbox" DROP CONSTRAINT IF EXISTS "ck_siat_simulated_outbox_siat_mode";
ALTER TABLE "billing"."siat_simulated_outbox" ADD CONSTRAINT "ck_siat_simulated_outbox_siat_mode" CHECK ("siat_mode" IN ('simulated','real'));


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


-- ═══ space_tariffs ═══
--   EXCLUDE: one tariff per practice, kind, bed category, room and date  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ex_space_tariffs_validity";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ex_space_tariffs_validity"
    EXCLUDE USING gist ("practice_id" WITH =, "tariff_kind_concept_id" WITH =, coalesce("bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid) WITH =, coalesce("care_space_id", '00000000-0000-0000-0000-000000000000'::uuid) WITH =, daterange("valid_from", "valid_to", '[)') WITH &&);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_or_time_unit_minutes";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_or_time_unit_minutes" CHECK (("tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR ("unit_minutes" IS NOT NULL AND "unit_minutes" > 0)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_valid_period";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_valid_period" CHECK (("valid_to" IS NULL OR "valid_to" > "valid_from"));
