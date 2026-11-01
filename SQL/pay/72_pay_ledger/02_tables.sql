-- SALUD v4.2.83 · módulo 72 · schema pay_ledger
-- Generado de diagram_72_pay_ledger.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "ledger_accounts" (
    "mode" text NOT NULL,
    "account" text NOT NULL,
    "kind" text NOT NULL,
    "tb_id" char(32) NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_ledger_accounts" PRIMARY KEY ("mode", "account")
);

CREATE TABLE IF NOT EXISTS "ledger_transactions" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "business_ref" text NOT NULL,
    "attempt" integer NOT NULL,
    "content_hash" char(64) NOT NULL,
    "status" text NOT NULL,
    "reject_code" text,
    "currency" char(3) NOT NULL,
    "legs" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_ledger_transactions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ledger_legs" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "source" text NOT NULL,
    "source_id" text NOT NULL,
    "business_ref" text NOT NULL,
    "attempt" integer NOT NULL,
    "leg_index" integer NOT NULL,
    "debit_account" text NOT NULL,
    "credit_account" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "code" text NOT NULL,
    "posted_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_ledger_legs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ledger_statement_lines" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "account" text NOT NULL,
    "leg_id" text NOT NULL,
    "business_ref" text NOT NULL,
    "attempt" integer NOT NULL,
    "leg_index" integer NOT NULL,
    "direction" text NOT NULL,
    "counterparty_account" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "code" text NOT NULL,
    "posted_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ledger_statement_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ledger_holds" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "business_ref" text NOT NULL,
    "attempt" integer NOT NULL,
    "content_hash" char(64) NOT NULL,
    "status" text NOT NULL,
    "reject_code" text,
    "debit_account" text NOT NULL,
    "credit_account" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "posted_amount_minor" bigint,
    "currency" char(3) NOT NULL,
    "void_reason" text,
    "expires_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "resolved_at" timestamptz,
    CONSTRAINT "pk_ledger_holds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ledger_rejections" (
    "id" bigserial NOT NULL,
    "mode" text NOT NULL,
    "kind" text NOT NULL,
    "business_ref" text NOT NULL,
    "attempt" integer NOT NULL,
    "reject_code" text NOT NULL,
    "tb_status" text NOT NULL,
    "caller" text NOT NULL,
    "rejected_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_ledger_rejections" PRIMARY KEY ("id")
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
