-- SALUD v4.0.10 · schema pharmacy_inventory · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ inventory_stock_positions ═══
--   PK: id  (ya en 02_tables/04_indexes)
-- TODO UK (location + product + lot): ALTER TABLE "pharmacy_inventory"."inventory_stock_positions" ADD CONSTRAINT "uq_inventory_stock_positions_..." UNIQUE (...);
-- TODO CHECK (quantities >= 0): ALTER TABLE "pharmacy_inventory"."inventory_stock_positions" ADD CONSTRAINT "ck_inventory_stock_positions_..." CHECK (...);
--   LOCK: SELECT FOR UPDATE
--   VERSION: row_version  (ya en 02_tables/04_indexes)

-- ═══ inventory_ledger_entries ═══
-- TODO UK (pharmacy + idempotency_key): ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries" ADD CONSTRAINT "uq_inventory_ledger_entries_..." UNIQUE (...);
-- TODO UK (pharmacy + ledger_sequence): ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries" ADD CONSTRAINT "uq_inventory_ledger_entries_..." UNIQUE (...);
-- TODO CHECK (non-zero delta): ALTER TABLE "pharmacy_inventory"."inventory_ledger_entries" ADD CONSTRAINT "ck_inventory_ledger_entries_..." CHECK (...);
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "pharmacy_inventory"."inventory_ledger_entries" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "pharmacy_inventory"."inventory_ledger_entries";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "pharmacy_inventory"."inventory_ledger_entries"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ inventory_reservations ═══
-- TODO UK (pharmacy + idempotency_key): ALTER TABLE "pharmacy_inventory"."inventory_reservations" ADD CONSTRAINT "uq_inventory_reservations_..." UNIQUE (...);
-- TODO EXCLUDE (active allocation overlap when required): ALTER TABLE "pharmacy_inventory"."inventory_reservations" ADD CONSTRAINT "ex_inventory_reservations_..." EXCLUDE USING gist (... WITH =, tstzrange(...) WITH &&) [WHERE ...];
--   WORKER: expiration release
