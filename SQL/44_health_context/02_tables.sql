-- SALUD v4.0.10 · módulo 44 · schema health_context
-- Generado de diagram_44_health_context.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "health_context"."context_agents" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "agent_type_concept_id" uuid NOT NULL,
    "provider_id" uuid,
    "implementation_ref" varchar,
    "owner_tenant_id" uuid,
    "last_heartbeat_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_context_agents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."country_context_schedules" (
    "id" uuid NOT NULL,
    "country_concept_id" uuid NOT NULL,
    "agent_id" uuid NOT NULL,
    "schedule_expression" varchar NOT NULL,
    "timezone_concept_id" uuid,
    "lookback_days" integer,
    "freshness_ttl_seconds" integer,
    "next_run_at" timestamptz,
    "last_success_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_country_context_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."health_context_sources" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "owner_name" varchar,
    "canonical_url" text,
    "country_concept_id" uuid,
    "license_text" text,
    "trust_tier_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_context_sources" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."context_collection_runs" (
    "id" uuid NOT NULL,
    "schedule_id" uuid,
    "agent_id" uuid NOT NULL,
    "country_concept_id" uuid NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "trigger_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz NOT NULL,
    "finished_at" timestamptz,
    "source_count" integer,
    "observations_read" bigint,
    "observations_accepted" bigint,
    "observations_rejected" bigint,
    "continuation_cursor_json" jsonb,
    "error_summary" text,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_context_collection_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."context_source_observations" (
    "id" uuid NOT NULL,
    "collection_run_id" uuid NOT NULL,
    "source_id" uuid NOT NULL,
    "country_concept_id" uuid NOT NULL,
    "source_locator" text NOT NULL,
    "published_at" timestamptz,
    "retrieved_at" timestamptz NOT NULL,
    "media_type" varchar,
    "raw_payload_file_id" uuid,
    "extracted_payload_json" jsonb,
    "content_hash" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_context_source_observations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."country_health_contexts" (
    "id" uuid NOT NULL,
    "country_concept_id" uuid NOT NULL,
    "context_domain_concept_id" uuid NOT NULL,
    "context_key" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "current_version_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_country_health_contexts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."country_health_context_versions" (
    "id" uuid NOT NULL,
    "country_health_context_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "collection_run_id" uuid NOT NULL,
    "schema_version" varchar NOT NULL,
    "summary" text,
    "context_payload_json" jsonb NOT NULL,
    "observed_at" timestamptz NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "expires_at" timestamptz,
    "confidence_score" numeric,
    "content_hash" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_country_health_context_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."health_context_facts" (
    "id" uuid NOT NULL,
    "context_version_id" uuid NOT NULL,
    "fact_key" varchar NOT NULL,
    "metric_concept_id" uuid NOT NULL,
    "value_type" "terminology"."technical_data_type" NOT NULL,
    "value_json" jsonb NOT NULL,
    "unit_concept_id" uuid,
    "period_start" date,
    "period_end" date,
    "confidence_score" numeric,
    "status_concept_id" uuid NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_health_context_facts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."context_fact_evidence" (
    "id" uuid NOT NULL,
    "health_context_fact_id" uuid NOT NULL,
    "source_observation_id" uuid NOT NULL,
    "evidence_locator_json" jsonb,
    "relevance_score" numeric,
    "evidence_hash" varchar,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_context_fact_evidence" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "health_context"."context_quality_reviews" (
    "id" uuid NOT NULL,
    "context_version_id" uuid NOT NULL,
    "reviewer_agent_id" uuid,
    "reviewed_by_user_id" uuid,
    "review_type_concept_id" uuid NOT NULL,
    "outcome_concept_id" uuid NOT NULL,
    "issues_json" jsonb,
    "notes" text,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_context_quality_reviews" PRIMARY KEY ("id")
);
