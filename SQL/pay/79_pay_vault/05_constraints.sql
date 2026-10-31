-- SALUD v4.2.81 · perfil pay · módulo 79 · base pay_vault
-- Generado de diagram_79_pay_vault.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

CREATE OR REPLACE FUNCTION forbid_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'la tabla % es inmutable (%)', TG_TABLE_NAME, TG_OP USING ERRCODE = 'integrity_constraint_violation';
END;
$$;

ALTER TABLE "capture_sessions" DROP CONSTRAINT IF EXISTS "capture_sessions_status_chk";
ALTER TABLE "capture_sessions" ADD CONSTRAINT "capture_sessions_status_chk" CHECK (status IN ('open', 'completed', 'expired', 'canceled'));

ALTER TABLE "capture_sessions" DROP CONSTRAINT IF EXISTS "capture_sessions_token_chk";
ALTER TABLE "capture_sessions" ADD CONSTRAINT "capture_sessions_token_chk" CHECK ((status = 'completed') = (token IS NOT NULL));

ALTER TABLE "card_tokens" DROP CONSTRAINT IF EXISTS "card_tokens_brand_chk";
ALTER TABLE "card_tokens" ADD CONSTRAINT "card_tokens_brand_chk" CHECK (brand IN ('visa', 'mastercard', 'other'));

ALTER TABLE "card_tokens" DROP CONSTRAINT IF EXISTS "card_tokens_last4_chk";
ALTER TABLE "card_tokens" ADD CONSTRAINT "card_tokens_last4_chk" CHECK (last4 ~ '^[0-9]{4}$');

ALTER TABLE "card_tokens" DROP CONSTRAINT IF EXISTS "card_tokens_exp_chk";
ALTER TABLE "card_tokens" ADD CONSTRAINT "card_tokens_exp_chk" CHECK (exp_month BETWEEN 1 AND 12 AND exp_year BETWEEN 2026 AND 2100);

ALTER TABLE "reveal_audit" DROP CONSTRAINT IF EXISTS "reveal_audit_outcome_chk";
ALTER TABLE "reveal_audit" ADD CONSTRAINT "reveal_audit_outcome_chk" CHECK (outcome IN ('granted', 'denied_not_found', 'denied_bound_to_other_charge', 'backend_error'));

ALTER TABLE "idempotency_keys" DROP CONSTRAINT IF EXISTS "idempotency_keys_state_check";
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_state_check" CHECK (state IN ('started', 'completed'));

-- Rastro de auditoría de cada revelado del PAN (granted / denied_*), de SOLO-AGREGAR: vault.repo.ts es el único que escribe (INSERT) y no hay UPDATE/DELETE/TRUNCATE sobre ella en
-- services/*/src, test/ ni e2e/. Borrarla o editarla permitiría esconder quién vio un PAN.
DROP TRIGGER IF EXISTS "reveal_audit_immutable" ON "reveal_audit";
CREATE TRIGGER reveal_audit_immutable BEFORE UPDATE OR DELETE ON reveal_audit FOR EACH ROW EXECUTE FUNCTION forbid_mutation();

DROP TRIGGER IF EXISTS "reveal_audit_no_truncate" ON "reveal_audit";
CREATE TRIGGER reveal_audit_no_truncate BEFORE TRUNCATE ON reveal_audit FOR EACH STATEMENT EXECUTE FUNCTION forbid_mutation();
