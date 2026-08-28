-- SALUD v4.0.10 · módulo 64 · schema audio_assets
-- Generado de diagram_64_audio_assets.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "audio_assets"."audio_templates" (
    "id" uuid NOT NULL,
    "template_key" varchar NOT NULL,
    "version" integer NOT NULL,
    "strategy" varchar NOT NULL,
    "language" varchar NOT NULL,
    "text_template" text NOT NULL,
    "fallback_text" text,
    "dynamic_fields_json" jsonb NOT NULL,
    "voice_profile" varchar NOT NULL,
    "enabled" boolean NOT NULL,
    "metadata" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_audio_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audio_assets"."audio_assets" (
    "id" uuid NOT NULL,
    "asset_key" char(64) NOT NULL,
    "tenant_id" uuid,
    "template_key" varchar NOT NULL,
    "template_version" integer NOT NULL,
    "strategy" varchar NOT NULL,
    "language" varchar NOT NULL,
    "normalized_value_hash" char(64),
    "display_value_encrypted" text NOT NULL,
    "rendered_text_hash" char(64) NOT NULL,
    "provider" varchar NOT NULL,
    "provider_model" varchar NOT NULL,
    "voice_profile" varchar NOT NULL,
    "voice_provider_ref" varchar,
    "voice_version" integer NOT NULL,
    "normalizer_version" integer NOT NULL,
    "audio_format" varchar NOT NULL,
    "sample_rate" integer,
    "storage_provider" varchar,
    "storage_key" varchar,
    "bytes" integer,
    "duration_ms" integer,
    "checksum_sha256" char(64),
    "generation_status" varchar NOT NULL,
    "failure_code" varchar,
    "budget_reserved_units" integer,
    "budget_period_key" varchar(7),
    "generated_at" timestamptz,
    "last_used_at" timestamptz,
    "use_count" integer NOT NULL,
    "metadata" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_audio_assets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audio_assets"."audio_generation_events" (
    "id" uuid NOT NULL,
    "asset_key" char(64),
    "event_type" varchar NOT NULL,
    "provider" varchar,
    "template_key" varchar,
    "outcome" varchar NOT NULL,
    "error_code" varchar,
    "duration_ms" integer,
    "estimated_cost_units" integer,
    "correlation_id" varchar,
    "trace_id" varchar,
    "metadata" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_audio_generation_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audio_assets"."audio_generation_usage" (
    "id" uuid NOT NULL,
    "period_key" varchar NOT NULL,
    "provider" varchar NOT NULL,
    "estimated_credits" integer NOT NULL,
    "consumed_credits" integer,
    "request_count" integer NOT NULL,
    "success_count" integer NOT NULL,
    "failure_count" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_audio_generation_usage" PRIMARY KEY ("id")
);
