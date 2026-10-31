-- SALUD v4.2.80 · módulo 76 · schema pay_risk
-- Generado de diagram_76_pay_risk.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "risk_rule_sets" (
    "version" integer NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "max_amount_minor" bigint,
    "merchant_daily_amount_minor" bigint,
    "payer_daily_amount_minor" bigint,
    "payer_velocity_max" integer,
    "payer_velocity_window_seconds" integer,
    "merchant_velocity_max" integer,
    "merchant_velocity_window_seconds" integer,
    "hours_from" smallint,
    "hours_to" smallint,
    "published_by" text NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_risk_rule_sets" PRIMARY KEY ("version")
);

CREATE TABLE IF NOT EXISTS "risk_assessments" (
    "id" text NOT NULL,
    "caller_service" text NOT NULL,
    "request_key" text NOT NULL,
    "merchant_id" text NOT NULL,
    "payment_intent_id" text NOT NULL,
    "amount_minor" bigint NOT NULL,
    "currency" text NOT NULL,
    "method" text NOT NULL,
    "payer_hash" text,
    "decision" text NOT NULL,
    "reason_code" text NOT NULL,
    "reason_codes" text[] NOT NULL,
    "rule_version" integer NOT NULL,
    "screened" boolean NOT NULL,
    "screening_top_score" numeric(8,6),
    "screening_list" text,
    "screening_source_id" text,
    "screening_party" text,
    "duration_ms" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_risk_assessments" PRIMARY KEY ("id")
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
