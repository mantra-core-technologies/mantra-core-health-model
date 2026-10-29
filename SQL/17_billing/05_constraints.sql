-- SALUD v4.0.10 · schema billing · constraints de integridad (módulo 33)
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
--   EXCLUDE: space tariffs cannot overlap per practice, kind, category and care space  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ex_space_tariffs_validity";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ex_space_tariffs_validity"
    EXCLUDE USING gist ("practice_id" WITH =, "tariff_kind_concept_id" WITH =, (COALESCE("bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid)) WITH =, (COALESCE("care_space_id", '00000000-0000-0000-0000-000000000000'::uuid)) WITH =, daterange("valid_from", "valid_to", '[)') WITH &&);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_kind";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_kind" CHECK ("tariff_kind_concept_id" IN ('1ae01bf6-a061-52ed-aa26-590705cb2202', '25eb53f6-8006-5959-bee9-65b16117bc9b'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_period";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_period" CHECK ("valid_to" IS NULL OR "valid_to" > "valid_from");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_price";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_price" CHECK ("unit_price" >= 0);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_or_time_unit";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_or_time_unit" CHECK ("tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR ("unit_minutes" IS NOT NULL AND "unit_minutes" > 0));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_bed_day_whole_days";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_bed_day_whole_days" CHECK ("tariff_kind_concept_id" <> '1ae01bf6-a061-52ed-aa26-590705cb2202' OR ("unit_minutes" IS NULL AND "minimum_units" IS NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_minimum_units";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_minimum_units" CHECK ("minimum_units" IS NULL OR "minimum_units" >= 1);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_scope";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_scope" CHECK (("tariff_kind_concept_id" <> '1ae01bf6-a061-52ed-aa26-590705cb2202' OR "bed_category_concept_id" IS NOT NULL OR "care_space_id" IS NOT NULL) AND ("tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR "bed_category_concept_id" IS NULL));


-- ═══ charge_captures ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_source_kind";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_source_kind" CHECK ("source_kind_concept_id" IN ('5f84ea44-b0d3-582c-86c1-32c81e422d30', 'a79361f6-8787-56a5-9a90-a9436d02e217'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_status";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_status" CHECK ("status_concept_id" IN ('17def99a-0cb5-586c-a440-59d809709c0d', '9af061be-6a80-51ed-bcbd-52533037c272', 'f2f59654-d912-5eeb-b619-814e50a3c4d0'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_quantity";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_quantity" CHECK ("quantity" > 0);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_bed_day_whole";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_bed_day_whole" CHECK ("source_kind_concept_id" <> '5f84ea44-b0d3-582c-86c1-32c81e422d30' OR ("quantity" = 1 AND "care_space_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_minimum_stay";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_minimum_stay" CHECK ("minimum_stay_charge" = false OR "source_kind_concept_id" = '5f84ea44-b0d3-582c-86c1-32c81e422d30');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_idempotency_key";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_idempotency_key" CHECK (btrim("idempotency_key") <> '');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_void";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_void" CHECK (("status_concept_id" = 'f2f59654-d912-5eeb-b619-814e50a3c4d0' AND "void_reason" IS NOT NULL AND btrim("void_reason") <> '') OR ("status_concept_id" <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0' AND "void_reason" IS NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_invoice_link";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_invoice_link" CHECK (("status_concept_id" <> '17def99a-0cb5-586c-a440-59d809709c0d' OR "invoice_line_id" IS NULL) AND ("status_concept_id" <> '9af061be-6a80-51ed-bcbd-52533037c272' OR "invoice_line_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_price_photo";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_price_photo" CHECK ("unit_price" IS NULL OR ("unit_price" >= 0 AND "space_tariff_id" IS NOT NULL AND "service_catalog_id" IS NOT NULL AND "currency_concept_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."charge_captures" DROP CONSTRAINT IF EXISTS "ck_charge_captures_invoiced_priced";
ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_invoiced_priced" CHECK ("status_concept_id" <> '9af061be-6a80-51ed-bcbd-52533037c272' OR "unit_price" IS NOT NULL);
