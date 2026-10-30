-- SALUD v4.0.10 · módulo 77 · schema pay_schedules
-- Generado de diagram_77_pay_schedules.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "merchant_replica" (
    "merchant_id" text NOT NULL,
    "status" text NOT NULL,
    "as_of" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_merchant_replica" PRIMARY KEY ("merchant_id")
);

CREATE TABLE IF NOT EXISTS "mandates" (
    "id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "mode" text NOT NULL,
    "kind" text NOT NULL,
    "beneficiary_merchant_id" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL DEFAULT 'BOB',
    "frequency" text NOT NULL DEFAULT 'monthly',
    "day_of_month" smallint NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date,
    "description" text,
    "status" text NOT NULL DEFAULT 'active',
    "next_run_on" date,
    "created_at" timestamptz NOT NULL,
    "canceled_at" timestamptz,
    CONSTRAINT "pk_mandates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduled_payments" (
    "id" text NOT NULL,
    "mandate_id" text NOT NULL,
    "period" text NOT NULL,
    "due_on" date NOT NULL,
    "status" text NOT NULL DEFAULT 'due',
    "phase" text NOT NULL DEFAULT 'hold',
    "attempts" integer NOT NULL DEFAULT 0,
    "ledger_attempt" integer NOT NULL DEFAULT 1,
    "hold_id" text,
    "ledger_transaction_id" text,
    "ledger_transfer_id" text,
    "next_attempt_at" timestamptz NOT NULL,
    "lease_until" timestamptz,
    "last_failure_code" text,
    "needs_review" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL,
    "executed_at" timestamptz,
    CONSTRAINT "pk_scheduled_payments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "outbox_events" (
    "id" uuid NOT NULL,
    "seq" bigserial NOT NULL,
    "aggregate_type" text NOT NULL,
    "aggregate_id" text NOT NULL,
    "type" text NOT NULL,
    "subject" text NOT NULL,
    "envelope" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "published_at" timestamptz,
    "attempts" integer NOT NULL DEFAULT 0,
    "last_error" text,
    CONSTRAINT "pk_outbox_events" PRIMARY KEY ("id")
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
