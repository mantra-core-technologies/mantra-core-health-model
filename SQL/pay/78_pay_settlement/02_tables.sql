-- SALUD v4.2.81 · módulo 78 · schema pay_settlement
-- Generado de diagram_78_pay_settlement.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "settlement_merchants" (
    "merchant_id" text NOT NULL,
    "first_seen_at" timestamptz NOT NULL DEFAULT now(),
    "last_activity_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_settlement_merchants" PRIMARY KEY ("merchant_id")
);

CREATE TABLE IF NOT EXISTS "settlement_merchant_marks" (
    "mode" text NOT NULL,
    "merchant_id" text NOT NULL,
    "watermark_at" timestamptz,
    "residual_minor" bigint NOT NULL DEFAULT 0,
    CONSTRAINT "pk_settlement_merchant_marks" PRIMARY KEY ("mode", "merchant_id")
);

CREATE TABLE IF NOT EXISTS "settlement_fee_plans" (
    "merchant_id" text NOT NULL,
    "version" integer NOT NULL,
    "monthly_fee_minor" bigint NOT NULL DEFAULT 0,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_settlement_fee_plans" PRIMARY KEY ("merchant_id")
);

CREATE TABLE IF NOT EXISTS "settlement_batches" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "cutoff_date" date NOT NULL,
    "release_days" integer NOT NULL,
    "release_before" timestamptz NOT NULL,
    "period_from" timestamptz NOT NULL,
    "status" text NOT NULL,
    "merchants_count" integer NOT NULL DEFAULT 0,
    "released_minor" bigint NOT NULL DEFAULT 0,
    "payouts_count" integer NOT NULL DEFAULT 0,
    "failed_count" integer NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "completed_at" timestamptz,
    CONSTRAINT "pk_settlement_batches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "settlement_batch_items" (
    "batch_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "status" text NOT NULL,
    "window_from" timestamptz,
    "planned_release_minor" bigint,
    "new_residual_minor" bigint,
    "ledger_attempt" integer NOT NULL DEFAULT 1,
    "release_ref" text,
    "released_minor" bigint NOT NULL DEFAULT 0,
    "netting_minor" bigint,
    "netting_attempt" integer NOT NULL DEFAULT 1,
    "payout_id" text,
    "failure_code" text,
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_settlement_batch_items" PRIMARY KEY ("batch_id", "merchant_id")
);

CREATE TABLE IF NOT EXISTS "settlement_payouts" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "merchant_id" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" char(3) NOT NULL,
    "rail" text NOT NULL,
    "simulated" boolean NOT NULL,
    "reason" text NOT NULL,
    "status" text NOT NULL,
    "step" text NOT NULL,
    "hold_id" text,
    "hold_business_ref" text NOT NULL,
    "rail_reference" text,
    "batch_id" text,
    "requested_by" text NOT NULL,
    "failure_code" text,
    "period_from" timestamptz NOT NULL,
    "period_to" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "paid_at" timestamptz,
    CONSTRAINT "pk_settlement_payouts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "settlement_charges" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "merchant_id" text NOT NULL,
    "kind" text NOT NULL,
    "period_key" text NOT NULL,
    "credit_account" text NOT NULL,
    "ledger_code" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "collected_minor" bigint NOT NULL DEFAULT 0,
    "status" text NOT NULL,
    "requested_by" text NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "collected_at" timestamptz,
    CONSTRAINT "pk_settlement_charges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "settlement_charge_collections" (
    "charge_id" text NOT NULL,
    "seq" integer NOT NULL,
    "amount_minor" bigint NOT NULL,
    "ledger_ref" text NOT NULL,
    "status" text NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_settlement_charge_collections" PRIMARY KEY ("charge_id", "seq")
);

CREATE TABLE IF NOT EXISTS "settlement_reconciliation_runs" (
    "id" text NOT NULL,
    "mode" text NOT NULL,
    "connector" text NOT NULL,
    "period_from" timestamptz NOT NULL,
    "period_to" timestamptz NOT NULL,
    "source" text NOT NULL,
    "status" text NOT NULL,
    "matched_count" integer NOT NULL DEFAULT 0,
    "exception_count" integer NOT NULL DEFAULT 0,
    "ignored_count" integer NOT NULL DEFAULT 0,
    "failure_code" text,
    "requested_by" text NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "completed_at" timestamptz,
    CONSTRAINT "pk_settlement_reconciliation_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "settlement_statement_lines" (
    "run_id" text NOT NULL,
    "line_ref" text NOT NULL,
    "provider_reference" text NOT NULL,
    "our_reference" text,
    "direction" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "value_date" date NOT NULL,
    "booked_at" timestamptz,
    "outcome" text NOT NULL,
    CONSTRAINT "pk_settlement_statement_lines" PRIMARY KEY ("run_id", "line_ref")
);

CREATE TABLE IF NOT EXISTS "settlement_exceptions" (
    "id" text NOT NULL,
    "mode" text,
    "run_id" text,
    "connector" text,
    "kind" text NOT NULL,
    "provider_reference" text,
    "business_ref" text,
    "statement_amount_minor" bigint,
    "ledger_amount_minor" bigint,
    "difference_minor" bigint NOT NULL,
    "statement_line_ref" text NOT NULL,
    "merchant_id" text,
    "payment_intent_id" text,
    "source_detail" jsonb,
    "status" text NOT NULL,
    "resolution" text,
    "resolved_by" text,
    "resolution_note" text,
    "resolved_at" timestamptz,
    "dedupe_key" char(64) NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_settlement_exceptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "settlement_adjustment_requests" (
    "id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    "exception_id" text NOT NULL,
    "requested_by" text NOT NULL,
    "difference_minor" bigint NOT NULL,
    "note" text NOT NULL,
    "status" text NOT NULL DEFAULT 'requested',
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_settlement_adjustment_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "settlement_audit" (
    "id" bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    "actor" text NOT NULL,
    "role" text NOT NULL,
    "action" text NOT NULL,
    "subject" text NOT NULL,
    "detail" jsonb NOT NULL DEFAULT '{}'::jsonb,
    "at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_settlement_audit" PRIMARY KEY ("id")
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
