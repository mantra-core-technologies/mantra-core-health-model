-- SALUD v4.2.82 · módulo 74 · schema pay_payments
-- Generado de diagram_74_pay_payments.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "payment_intents" (
    "id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "mode" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL DEFAULT 'BOB',
    "method" text NOT NULL,
    "status" text NOT NULL DEFAULT 'processing',
    "fee_minor" bigint NOT NULL,
    "net_minor" bigint NOT NULL,
    "description" text,
    "metadata" jsonb NOT NULL DEFAULT '{}'::jsonb,
    "next_action" jsonb,
    "failure_code" text,
    "failure_reason" text,
    "connector" text,
    "charge_id" text,
    "charge_status" text NOT NULL DEFAULT 'pending',
    "ledger_attempt" integer NOT NULL DEFAULT 1,
    "ledger_transfer_id" text,
    "card_token" text,
    "wallet_user_ref" text,
    "source" jsonb,
    "kind" text,
    "beneficiary_merchant_id" text,
    "payer_name" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "expires_at" timestamptz NOT NULL,
    "succeeded_at" timestamptz,
    "completed_at" timestamptz,
    CONSTRAINT "pk_payment_intents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "refunds" (
    "id" text NOT NULL,
    "payment_intent_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "mode" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL DEFAULT 'BOB',
    "status" text NOT NULL DEFAULT 'pending',
    "reason" text,
    "failure_code" text,
    "ledger_hold_id" text,
    "ledger_transfer_id" text,
    "connector_refund_id" text,
    "metadata" jsonb NOT NULL DEFAULT '{}'::jsonb,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "completed_at" timestamptz,
    CONSTRAINT "pk_refunds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "disputes" (
    "id" text NOT NULL,
    "payment_intent_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "mode" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL DEFAULT 'BOB',
    "status" text NOT NULL DEFAULT 'open',
    "evidence" jsonb NOT NULL DEFAULT '[]'::jsonb,
    "ledger_transfer_id" text,
    "opened_at" timestamptz NOT NULL DEFAULT now(),
    "resolved_at" timestamptz,
    CONSTRAINT "pk_disputes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "payment_cancellation_requests" (
    "id" bigserial NOT NULL,
    "payment_intent_id" text NOT NULL,
    "requested_at" timestamptz NOT NULL DEFAULT now(),
    "outcome" text NOT NULL,
    CONSTRAINT "pk_payment_cancellation_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "merchant_replica" (
    "merchant_id" text NOT NULL,
    "status" text NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "legal_name" text,
    CONSTRAINT "pk_merchant_replica" PRIMARY KEY ("merchant_id")
);

CREATE TABLE IF NOT EXISTS "fee_schedule_replica" (
    "merchant_id" text NOT NULL,
    "version" integer NOT NULL,
    "currency" text NOT NULL,
    "channels" jsonb NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "published_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_fee_schedule_replica" PRIMARY KEY ("merchant_id", "version")
);

CREATE TABLE IF NOT EXISTS "intent_contradictions" (
    "id" bigserial NOT NULL,
    "payment_intent_id" text NOT NULL,
    "current_status" text NOT NULL,
    "incoming_status" text NOT NULL,
    "source_event_id" text NOT NULL,
    "kind" text NOT NULL DEFAULT 'status_conflict',
    "reason" text NOT NULL DEFAULT '',
    "detected_at" timestamptz NOT NULL DEFAULT now(),
    "resolved_at" timestamptz,
    CONSTRAINT "pk_intent_contradictions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "wallet_authorizations_used" (
    "authorization_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "payment_intent_id" text NOT NULL,
    "used_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_wallet_authorizations_used" PRIMARY KEY ("authorization_id")
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
