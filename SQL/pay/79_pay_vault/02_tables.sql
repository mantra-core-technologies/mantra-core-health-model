-- SALUD v4.2.83 · módulo 79 · schema pay_vault
-- Generado de diagram_79_pay_vault.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "capture_sessions" (
    "id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "payment_intent_id" text,
    "save_card" boolean NOT NULL DEFAULT false,
    "status" text NOT NULL DEFAULT 'open',
    "capture_url" text NOT NULL,
    "token" text,
    "expires_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "completed_at" timestamptz,
    CONSTRAINT "pk_capture_sessions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "card_tokens" (
    "token" text NOT NULL,
    "merchant_id" text NOT NULL,
    "brand" text NOT NULL,
    "last4" text NOT NULL,
    "exp_month" smallint NOT NULL,
    "exp_year" smallint NOT NULL,
    "fingerprint" text NOT NULL,
    "single_use" boolean NOT NULL,
    "bound_charge_id" text,
    "deleted_at" timestamptz,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_card_tokens" PRIMARY KEY ("token")
);

CREATE TABLE IF NOT EXISTS "reveal_audit" (
    "id" bigserial NOT NULL,
    "token" text NOT NULL,
    "merchant_id" text NOT NULL,
    "charge_id" text NOT NULL,
    "caller" text NOT NULL,
    "outcome" text NOT NULL,
    "idempotency_key" text,
    "at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_reveal_audit" PRIMARY KEY ("id")
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
