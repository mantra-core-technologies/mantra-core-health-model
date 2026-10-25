-- ============================================================================
-- SALUD · patch (accounting · número de asiento único por práctica) sobre BD viva
-- Fecha: 2026-10-24 · hallazgo ACC-02 (API #778)
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. accounting.journal_transactions: la unicidad de transaction_number deja de ser
-- global y pasa a ser (practice_id, transaction_number). El servicio (ledger.service.ts,
-- findByTransactionNumber(practiceId, number)) ya la entendía por práctica; el índice global
-- hacía fallar el alta de una segunda práctica con un número ya usado en otra.
--
-- PRECONDICIÓN: ninguna. Pasar de UNIQUE(transaction_number) a UNIQUE(practice_id,
-- transaction_number) solo relaja la restricción: toda base que cumplía la anterior cumple la
-- nueva. Primero se crea el índice nuevo, después se retira el global: no hay ventana sin
-- unicidad. Solo lectura (debe devolver 0 filas):
--   SELECT practice_id, transaction_number, count(*) FROM accounting.journal_transactions
--    GROUP BY 1, 2 HAVING count(*) > 1;
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +0 · NOT NULL quitados 0 · FKs +0 · índices +1 (-1) · constraints +0
-- ============================================================================

BEGIN;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_journal_transactions_practice_id_transaction_number" ON "accounting"."journal_transactions" ("practice_id", "transaction_number");

DROP INDEX IF EXISTS "accounting"."uq_journal_transactions_transaction_number";

COMMIT;
