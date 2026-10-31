-- SALUD v4.2.80 · módulo 70 · schema pay_connectors
-- Generado de diagram_70_pay_connectors.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "connector_charges" (
    "id" text NOT NULL,
    "caller" text NOT NULL,
    "idempotency_key" text NOT NULL,
    "payment_intent_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "pay_mode" text NOT NULL,
    "connector" text NOT NULL,
    "connector_mode" text NOT NULL,
    "method" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL,
    "provider_status" text NOT NULL DEFAULT 'pending',
    "next_action" jsonb,
    "provider_reference" text,
    "failure_code" text,
    "ambiguous" boolean NOT NULL DEFAULT false,
    "send_claims" integer NOT NULL DEFAULT 0,
    "routing_version" integer NOT NULL,
    "routing_rule" text,
    "expires_at" timestamptz NOT NULL,
    "last_provider_event_at" timestamptz,
    "poll_attempts" integer NOT NULL DEFAULT 0,
    "next_poll_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_connector_charges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "connector_refunds" (
    "id" text NOT NULL,
    "charge_id" text NOT NULL,
    "refund_id" text,
    "pay_mode" text NOT NULL,
    "caller" text NOT NULL,
    "idempotency_key" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL,
    "status" text NOT NULL DEFAULT 'pending',
    "provider_reference" text,
    "failure_code" text,
    "may_have_reached_provider" boolean NOT NULL DEFAULT false,
    "send_claims" integer NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_connector_refunds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "connector_callback_events" (
    "id" bigserial NOT NULL,
    "connector" text NOT NULL,
    "provider_event_id" text NOT NULL,
    "charge_id" text,
    "pay_mode" text,
    "status" text NOT NULL,
    "result" text NOT NULL,
    "observed_via" text NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "received_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_connector_callback_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "connector_api_attempts" (
    "id" bigserial NOT NULL,
    "subject_id" text NOT NULL,
    "connector" text NOT NULL,
    "operation" text NOT NULL,
    "outcome" text NOT NULL,
    "latency_ms" integer NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_connector_api_attempts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "connector_health" (
    "connector" text NOT NULL,
    "connector_mode" text NOT NULL,
    "status" text NOT NULL,
    "consecutive_failures" integer NOT NULL DEFAULT 0,
    "last_reason" text,
    "degraded_since" timestamptz,
    "latency_ms" integer,
    "last_success_at" timestamptz,
    "checked_at" timestamptz NOT NULL,
    CONSTRAINT "pk_connector_health" PRIMARY KEY ("connector")
);

CREATE TABLE IF NOT EXISTS "connector_callback_endpoints" (
    "id" bigserial NOT NULL,
    "connector" text NOT NULL,
    "callback_path" text NOT NULL,
    "active" boolean NOT NULL DEFAULT true,
    "allowed_source_cidrs" jsonb,
    "replay_window_seconds" integer,
    CONSTRAINT "pk_connector_callback_endpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "routing_rule_sets" (
    "version" integer NOT NULL,
    "rules" jsonb NOT NULL,
    "active" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_routing_rule_sets" PRIMARY KEY ("version")
);

CREATE TABLE IF NOT EXISTS "bank_transfer_references" (
    "reference" text NOT NULL,
    "charge_id" text NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_bank_transfer_references" PRIMARY KEY ("reference")
);

CREATE TABLE IF NOT EXISTS "statement_exceptions" (
    "id" bigserial NOT NULL,
    "connector" text NOT NULL,
    "provider_reference" text NOT NULL,
    "kind" text NOT NULL,
    "charge_id" text,
    "expected_minor" bigint,
    "actual_minor" bigint NOT NULL,
    "detected_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_statement_exceptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "connector_transfers" (
    "id" text NOT NULL,
    "business_ref" text NOT NULL,
    "attempt" integer NOT NULL,
    "pay_mode" text NOT NULL,
    "caller" text NOT NULL,
    "connector" text NOT NULL,
    "connector_mode" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL,
    "destination_ref" text NOT NULL,
    "status" text NOT NULL DEFAULT 'pending',
    "provider_reference" text,
    "failure_code" text,
    "may_have_reached_provider" boolean NOT NULL DEFAULT false,
    "send_claims" integer NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_connector_transfers" PRIMARY KEY ("id")
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
