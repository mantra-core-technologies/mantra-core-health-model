-- SALUD v4.2.80 · módulo 80 · schema pay_webhooks
-- Generado de diagram_80_pay_webhooks.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "webhook_endpoints" (
    "id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "url" text NOT NULL,
    "description" text,
    "enabled_events" text[] NOT NULL,
    "signature_scheme" text NOT NULL DEFAULT 'v1',
    "status" text NOT NULL DEFAULT 'enabled',
    "disabled_reason" text,
    "consecutive_failures" integer NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "deleted_at" timestamptz,
    CONSTRAINT "pk_webhook_endpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "webhook_secrets" (
    "endpoint_id" text NOT NULL,
    "version" integer NOT NULL,
    "sealed_secret" text NOT NULL,
    "public_key" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "expires_at" timestamptz,
    CONSTRAINT "pk_webhook_secrets" PRIMARY KEY ("endpoint_id", "version")
);

CREATE TABLE IF NOT EXISTS "webhook_deliveries" (
    "id" text NOT NULL,
    "endpoint_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "event_id" text NOT NULL,
    "event_type" text NOT NULL,
    "payload" text NOT NULL,
    "status" text NOT NULL DEFAULT 'pending',
    "attempts" integer NOT NULL DEFAULT 0,
    "next_attempt_at" timestamptz NOT NULL,
    "last_status" integer,
    "last_error" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "delivered_at" timestamptz,
    CONSTRAINT "pk_webhook_deliveries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "webhook_delivery_attempts" (
    "delivery_id" text NOT NULL,
    "attempt" integer NOT NULL,
    "attempted_at" timestamptz NOT NULL,
    "status_code" integer,
    "error_code" text,
    "duration_ms" integer NOT NULL,
    CONSTRAINT "pk_webhook_delivery_attempts" PRIMARY KEY ("delivery_id", "attempt")
);

CREATE TABLE IF NOT EXISTS "inbox_events" (
    "consumer" text NOT NULL,
    "event_id" text NOT NULL,
    "processed_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_inbox_events" PRIMARY KEY ("consumer", "event_id")
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
