-- ============================================================================
-- SALUD · patch (scheduling · la factura de la cita, M-01) sobre BD viva
-- Fecha: 2026-10-29 · FAC-01 «El pago de la agenda llega a facturación»
-- Idempotente (IF NOT EXISTS / duplicate_object). Una sola pasada alcanza; dos no fallan. Sin backfill.
-- Contexto: gen_ddl.py ya emite esto en SQL/41_scheduling/ desde que el .puml lo declara, así que en
-- un rebuild desde cero este patch NO hace falta. Existe para una base ya aplicada y poblada: un
-- CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que ya existe.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se copiaron de
-- los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA.
--   Ninguna columna unía la cita con facturación. El estado de pago de la cita
--   (scheduling.appointment_payment_states) suma invoice_id: la cuenta por cobrar que crea el primer
--   pago confirmado con monto. Los pagos siguientes se asignan a esa misma factura. Nullable: las
--   filas que ya existen no tienen factura, y una marca sin monto, una cita sin práctica o una
--   práctica sin precio tampoco la generan (CONTRATO S-2, S-5).
--   El índice único parcial asegura que una factura sea de una sola cita.
--   La FK sale diferida y SIN ON DELETE (NO ACTION): no deja borrar una factura referenciada. Una
--   factura no se borra; se anula con nota de crédito. El generador sólo sabe emitir la cascada
--   (gen_ddl.py), así que se queda con el comportamiento por defecto, que es el que se quiere.
--
-- PRECONDICIÓN: el schema billing y billing.invoices existen (módulo 17).
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas +1 · FKs +1 · índices +1
-- ============================================================================

BEGIN;
-- Un ALTER TABLE toma un lock exclusivo: en una base viva, mejor fallar a los 5 s que encolar la agenda.
SET LOCAL lock_timeout = '5s';

ALTER TABLE "scheduling"."appointment_payment_states"
    ADD COLUMN IF NOT EXISTS "invoice_id" uuid;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_appointment_payment_states_invoice" ON "scheduling"."appointment_payment_states" ("invoice_id") WHERE invoice_id IS NOT NULL;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_states"
        ADD CONSTRAINT "fk_appointment_payment_states_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
