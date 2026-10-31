-- SALUD v4.2.68 · perfil pay · módulo 71 · base pay_edge
-- Generado de diagram_71_pay_edge.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

ALTER TABLE "api_key_replica" DROP CONSTRAINT IF EXISTS "api_key_replica_mode_check";
ALTER TABLE "api_key_replica" ADD CONSTRAINT "api_key_replica_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "api_key_replica" DROP CONSTRAINT IF EXISTS "api_key_replica_hash_check";
ALTER TABLE "api_key_replica" ADD CONSTRAINT "api_key_replica_hash_check" CHECK (key_hash IS NULL OR key_hash ~ '^sha256\$[0-9a-f]{64}$');

ALTER TABLE "merchant_replica" DROP CONSTRAINT IF EXISTS "merchant_replica_status_check";
ALTER TABLE "merchant_replica" ADD CONSTRAINT "merchant_replica_status_check" CHECK (status IN ('active', 'suspended', 'closed'));
