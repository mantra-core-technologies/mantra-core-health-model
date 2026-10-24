-- SALUD v4.0.10 · schema pharmacy_inventory · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ inventory_stock_positions ═══
--   PK: id  (ya en 02_tables/04_indexes)
--   UK: location + product + lot  (en prosa; el módulo 33 no declara su expresión SQL)
--   CHECK: quantities >= 0  (en prosa; el módulo 33 no declara su expresión SQL)
--   LOCK: SELECT FOR UPDATE
--   VERSION: row_version  (ya en 02_tables/04_indexes)

-- ═══ inventory_ledger_entries ═══
--   UK: pharmacy + idempotency_key  (en prosa; el módulo 33 no declara su expresión SQL)
--   UK: pharmacy + ledger_sequence  (en prosa; el módulo 33 no declara su expresión SQL)
--   CHECK: non-zero delta  (en prosa; el módulo 33 no declara su expresión SQL)
--   UPDATE_DELETE: forbidden
--   índices únicos que la tabla ya tiene en 04_indexes: uq_inventory_ledger_entries_pharmacy_id_ledger_sequence, uq_inventory_ledger_entries_idempotency, uq_inventory_ledger_idempotency
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "pharmacy_inventory"."inventory_ledger_entries" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "pharmacy_inventory"."inventory_ledger_entries";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "pharmacy_inventory"."inventory_ledger_entries"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ inventory_reservations ═══
--   UK: pharmacy + idempotency_key  (en prosa; el módulo 33 no declara su expresión SQL)
--   EXCLUDE: active allocation overlap when required  (en prosa; el módulo 33 no declara su expresión SQL)
--   WORKER: expiration release
--   índices únicos que la tabla ya tiene en 04_indexes: uq_inventory_reservations_idempotency, ux_inventory_reservations_pharmacy_site_pickup_code
