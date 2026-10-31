-- SALUD v4.2.81 · módulo 75 · schema pay_qr
-- Generado de diagram_75_pay_qr.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "qr_codes" (
    "id" text NOT NULL,
    "kind" text NOT NULL,
    "pay_mode" text NOT NULL,
    "merchant_id" text NOT NULL,
    "payment_intent_id" text,
    "reference" text NOT NULL,
    "amount_minor" bigint,
    "currency" text NOT NULL,
    "payload" text NOT NULL,
    "expires_at" timestamptz,
    "canceled_at" timestamptz,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_qr_codes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "idempotency_keys" (
    "scope" text NOT NULL,
    "key" text NOT NULL,
    "request_hash" text NOT NULL,
    "state" text NOT NULL,
    "recovery_point" text NOT NULL DEFAULT 'started',
    "response_status" integer,
    "response_body" jsonb,
    "locked_at" timestamptz,
    "lock_token" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "expires_at" timestamptz NOT NULL,
    CONSTRAINT "pk_idempotency_keys" PRIMARY KEY ("scope", "key")
);
