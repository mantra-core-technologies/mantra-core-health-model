-- SALUD v4.0.10 · perfil pay · módulo 75 · base pay_qr
-- Generado de diagram_75_pay_qr.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_id_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_id_check" CHECK (id ~ '^qr_[a-z0-9]{10,40}$');

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_kind_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_kind_check" CHECK (kind IN ('static', 'dynamic'));

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_pay_mode_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_pay_mode_check" CHECK (pay_mode IN ('test', 'live'));

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_merchant_id_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_merchant_id_check" CHECK (merchant_id ~ '^mc_[a-z0-9]{10,40}$');

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_payment_intent_id_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_payment_intent_id_check" CHECK (payment_intent_id IS NULL OR payment_intent_id ~ '^pi_[a-z0-9]{10,40}$');

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_reference_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_reference_check" CHECK (reference ~ '^[A-Za-z0-9]{1,25}$');

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_amount_minor_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_amount_minor_check" CHECK (amount_minor IS NULL OR amount_minor > 0);

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_currency_check";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_currency_check" CHECK (currency = 'BOB');

ALTER TABLE "qr_codes" DROP CONSTRAINT IF EXISTS "qr_codes_dynamic_fields_ck";
ALTER TABLE "qr_codes" ADD CONSTRAINT "qr_codes_dynamic_fields_ck" CHECK (kind = 'static' OR (payment_intent_id IS NOT NULL AND amount_minor IS NOT NULL AND expires_at IS NOT NULL));

ALTER TABLE "idempotency_keys" DROP CONSTRAINT IF EXISTS "idempotency_keys_state_check";
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_state_check" CHECK (state IN ('started', 'completed'));
