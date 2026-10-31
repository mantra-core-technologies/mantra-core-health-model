-- SALUD v4.2.80 · perfil pay · base pay_edge · DDL completo en orden (generado de diagram_71_pay_edge.puml)
-- Archivo SQL plano, apto para `pool.query(readFileSync(...))`. NO editar a mano.

-- >>> 02_tables.sql
-- SALUD v4.2.80 · módulo 71 · schema pay_edge
-- Generado de diagram_71_pay_edge.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "api_key_replica" (
    "key_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "mode" text NOT NULL,
    "key_hash" text,
    "revoked_at" timestamptz,
    "last_event_id" text NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_api_key_replica" PRIMARY KEY ("key_id")
);

CREATE TABLE IF NOT EXISTS "merchant_replica" (
    "merchant_id" text NOT NULL,
    "status" text NOT NULL,
    "status_at" timestamptz NOT NULL,
    "last_event_id" text NOT NULL,
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_merchant_replica" PRIMARY KEY ("merchant_id")
);

CREATE TABLE IF NOT EXISTS "inbox_events" (
    "consumer" text NOT NULL,
    "event_id" text NOT NULL,
    "processed_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_inbox_events" PRIMARY KEY ("consumer", "event_id")
);

-- >>> 03_fk_intra.sql
-- SALUD v4.2.80 · módulo 71 · schema pay_edge
-- Generado de diagram_71_pay_edge.puml — NO editar a mano.


-- >>> 04_indexes.sql
-- SALUD v4.2.80 · módulo 71 · schema pay_edge
-- Generado de diagram_71_pay_edge.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "api_key_replica_merchant_idx" ON "api_key_replica" ("merchant_id");

-- >>> 05_constraints.sql
-- SALUD v4.2.80 · perfil pay · módulo 71 · base pay_edge
-- Generado de diagram_71_pay_edge.puml — NO editar a mano.

-- Complementos del perfil pay (gen_ddl_pay.py): funciones, CHECK, FK compuestas y triggers.
-- Aplicar DESPUÉS de 04_indexes.sql. Idempotente.

ALTER TABLE "api_key_replica" DROP CONSTRAINT IF EXISTS "api_key_replica_mode_check";
ALTER TABLE "api_key_replica" ADD CONSTRAINT "api_key_replica_mode_check" CHECK (mode IN ('test', 'live'));

ALTER TABLE "api_key_replica" DROP CONSTRAINT IF EXISTS "api_key_replica_hash_check";
ALTER TABLE "api_key_replica" ADD CONSTRAINT "api_key_replica_hash_check" CHECK (key_hash IS NULL OR key_hash ~ '^sha256\$[0-9a-f]{64}$');

ALTER TABLE "merchant_replica" DROP CONSTRAINT IF EXISTS "merchant_replica_status_check";
ALTER TABLE "merchant_replica" ADD CONSTRAINT "merchant_replica_status_check" CHECK (status IN ('active', 'suspended', 'closed'));
