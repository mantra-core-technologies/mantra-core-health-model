-- SALUD v4.2.82 · módulo 71 · schema pay_edge
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
