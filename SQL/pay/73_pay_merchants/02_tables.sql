-- SALUD v4.2.80 · módulo 73 · schema pay_merchants
-- Generado de diagram_73_pay_merchants.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "merchants" (
    "id" text NOT NULL,
    "display_name" text NOT NULL,
    "legal_name" text NOT NULL,
    "legal_type" text NOT NULL,
    "tax_id" text NOT NULL,
    "directory_tenant_ref" text,
    "status" text NOT NULL DEFAULT 'pending',
    "suspension_reason" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "activated_at" timestamptz,
    "suspended_at" timestamptz,
    "closed_at" timestamptz,
    CONSTRAINT "pk_merchants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "merchant_kyc" (
    "merchant_id" text NOT NULL,
    "status" text NOT NULL DEFAULT 'pending',
    "risk_level" text,
    "reviewed_by" text,
    "reviewed_at" timestamptz,
    "review_note" text,
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_merchant_kyc" PRIMARY KEY ("merchant_id")
);

CREATE TABLE IF NOT EXISTS "kyc_documents" (
    "id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "kind" text NOT NULL,
    "object_key" text NOT NULL,
    "sha256" text NOT NULL,
    "size_bytes" integer NOT NULL,
    "detected_type" text NOT NULL,
    "uploaded_by" text NOT NULL,
    "uploaded_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_kyc_documents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "contract_versions" (
    "version" integer NOT NULL,
    "text_sha256" text NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "published_by" text NOT NULL,
    "published_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_contract_versions" PRIMARY KEY ("version")
);

CREATE TABLE IF NOT EXISTS "contract_acceptances" (
    "id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "version" integer NOT NULL,
    "text_sha256" text NOT NULL,
    "accepted_by_ref" text NOT NULL,
    "recorded_by" text NOT NULL,
    "accepted_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_contract_acceptances" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "fee_schedule_versions" (
    "merchant_id" text NOT NULL,
    "version" integer NOT NULL,
    "currency" text NOT NULL DEFAULT 'BOB',
    "effective_from" timestamptz NOT NULL,
    "monthly_fee_minor" bigint NOT NULL DEFAULT 0,
    "published_by" text NOT NULL,
    "published_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_fee_schedule_versions" PRIMARY KEY ("merchant_id", "version")
);

CREATE TABLE IF NOT EXISTS "fee_schedule_channels" (
    "merchant_id" text NOT NULL,
    "version" integer NOT NULL,
    "channel" text NOT NULL,
    "percent" text NOT NULL,
    "fixed_minor" bigint NOT NULL DEFAULT 0,
    "min_minor" bigint,
    "cap_minor" bigint,
    CONSTRAINT "pk_fee_schedule_channels" PRIMARY KEY ("merchant_id", "version", "channel")
);

CREATE TABLE IF NOT EXISTS "api_keys" (
    "key_id" text NOT NULL,
    "merchant_id" text NOT NULL,
    "mode" text NOT NULL,
    "label" text,
    "last4" text NOT NULL,
    "key_hash" text NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "grace_ends_at" timestamptz,
    "revoked_at" timestamptz,
    "revoke_reason" text,
    CONSTRAINT "pk_api_keys" PRIMARY KEY ("key_id")
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
