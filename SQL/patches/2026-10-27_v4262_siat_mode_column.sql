-- 2026-10-27 · v4262 · Columna siat_mode en tablas SIAT.
--
-- Agrega siat_mode varchar(12) CHECK ('simulated'|'real') DEFAULT 'simulated' a
-- billing.siat_simulated_invoices y billing.siat_simulated_outbox.
-- Prepara la base para distinguir facturas emitidas contra el SIN real de las
-- simuladas, sin perder compatibilidad con las filas existentes.
-- Idempotente: se puede aplicar N veces.

ALTER TABLE "billing"."siat_simulated_invoices"
    ADD COLUMN IF NOT EXISTS "siat_mode" varchar(12) NOT NULL DEFAULT 'simulated';

DO $$ BEGIN
    ALTER TABLE "billing"."siat_simulated_invoices"
        ADD CONSTRAINT "ck_siat_simulated_invoices_siat_mode"
        CHECK ("siat_mode" IN ('simulated', 'real'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

ALTER TABLE "billing"."siat_simulated_outbox"
    ADD COLUMN IF NOT EXISTS "siat_mode" varchar(12) NOT NULL DEFAULT 'simulated';

DO $$ BEGIN
    ALTER TABLE "billing"."siat_simulated_outbox"
        ADD CONSTRAINT "ck_siat_simulated_outbox_siat_mode"
        CHECK ("siat_mode" IN ('simulated', 'real'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
