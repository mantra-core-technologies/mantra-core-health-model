-- ============================================================================
-- SALUD · patch (billing · vínculo canónico factura ↔ reclamo de aseguradora) sobre BD viva
-- Fecha: 2026-10-23 · carril 16 (Aseguradora), corte 2 · REQ-16-028 / REQ-16-029
-- Idempotente (IF NOT EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py ya emite esta columna, sus índices y sus FKs en
-- SQL/17_billing/ desde que diagram_17_billing.puml las declara, así que en un
-- rebuild desde cero este patch NO hace falta. Existe para una base ya aplicada y
-- poblada: docker/db-init/init-postgres.sh se salta apply_deferred.sql cuando ya
-- existe la base, y la columna nueva no entra por un CREATE TABLE IF NOT EXISTS.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias
-- se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA.
--   1. billing.invoice_lines.insurance_claim_line_id (nullable): la línea de factura
--      al paciente apunta a la línea del reclamo que la origina. Único cuando no es
--      NULL: una línea de reclamo se factura una sola vez (relación 1:1, decidida
--      por el propietario el 2026-10-23).
--   2. billing.billing_document_links.claim_id y billing.reimbursements.claim_id
--      dejan de ser «FK sin destino canónico» y pasan a ser FK reales hacia
--      insurance.insurance_claims.
--
-- ON DELETE CASCADE en las tres FK: decisión del propietario (2026-10-23). Borrar
-- un reclamo o una línea de reclamo borra los documentos de facturación vinculados.
--
-- PRECONDICIÓN: no debe haber filas con claim_id que no exista en
-- insurance.insurance_claims; si las hubiera, el ALTER de la FK falla y el BEGIN
-- hace rollback de todo el patch. Comprobar antes (solo lectura):
--   SELECT count(*) FROM billing.billing_document_links l
--    WHERE l.claim_id IS NOT NULL
--      AND NOT EXISTS (SELECT 1 FROM insurance.insurance_claims c WHERE c.id = l.claim_id);
--   SELECT count(*) FROM billing.reimbursements r
--    WHERE NOT EXISTS (SELECT 1 FROM insurance.insurance_claims c WHERE c.id = r.claim_id);
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +1 · FKs +3 · índices +2
-- ============================================================================

BEGIN;

ALTER TABLE "billing"."invoice_lines"
    ADD COLUMN IF NOT EXISTS "insurance_claim_line_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_invoice_lines_insurance_claim_line_id" ON "billing"."invoice_lines" ("insurance_claim_line_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_invoice_lines_insurance_claim_line_id" ON "billing"."invoice_lines" ("insurance_claim_line_id") WHERE insurance_claim_line_id IS NOT NULL;

-- destino: insurance.insurance_claim_lines (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "billing"."invoice_lines"
        ADD CONSTRAINT "fk_invoice_lines_insurance_claim_line_id" FOREIGN KEY ("insurance_claim_line_id")
        REFERENCES "insurance"."insurance_claim_lines" ("id") ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.insurance_claims (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "billing"."reimbursements"
        ADD CONSTRAINT "fk_reimbursements_claim_id" FOREIGN KEY ("claim_id")
        REFERENCES "insurance"."insurance_claims" ("id") ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: insurance.insurance_claims (requiere schema insurance)
DO $$ BEGIN
    ALTER TABLE "billing"."billing_document_links"
        ADD CONSTRAINT "fk_billing_document_links_claim_id" FOREIGN KEY ("claim_id")
        REFERENCES "insurance"."insurance_claims" ("id") ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
