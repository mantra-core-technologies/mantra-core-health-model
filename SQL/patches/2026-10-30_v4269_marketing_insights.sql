-- ============================================================================
-- SALUD · patch v4.2.69 (marketing · AloVida Insights · módulo 50) sobre una BD viva
-- Fecha: 2026-10-30 · franja F2 del programa «AloVida Insights» (carril M)
--
-- QUÉ CIERRA. El portal `/insights` (marketing) lee de la API endpoints dedicados
-- `/marketing/insights/*`. Esos endpoints necesitan 22 tablas `marketing.insights_*`
-- (campañas, creativos, hitos, fuentes, hechos diarios/horarios, redes, uso de la app,
-- menciones, señales de búsqueda, entorno, tendencias, alertas con reglas y transiciones,
-- preferencias, informes y vistas guardadas). Son dataset de PLATAFORMA: NO llevan `tenant_id`.
-- La autoridad es la API (roles + PlatformTenantOptional), no la fila.
-- Promovido por la ruta canónica: `diagram_50_marketing.puml` -> `gen_ddl.py 50` -> SQL/50_marketing/.
-- Este patch es el mismo DDL ejecutable: las sentencias se copiaron de los archivos generados, no se
-- escribieron a mano. Idempotente (IF NOT EXISTS / duplicate_object): una pasada alcanza; dos no fallan.
-- Sin backfill ni semillas: las semillas (reglas, fuentes, campañas…) llegan por `load_seeds.py`.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. En un rebuild desde cero este
-- patch NO hace falta (SQL/50_marketing/ ya lo trae); existe para una base ya aplicada y poblada.
--
-- PRECONDICIÓN: existen los schemas `marketing`, `iam` (iam.users) y `terminology`
-- (terminology.catalog_concepts), y la tabla marketing.marketing_campaigns (módulo 50).
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +22 · columnas +308 (incluye PK) · FKs +47 (7 intra-schema + 40 diferidas) · índices +72 (PK excluida)
--   Verificación: tablas  = SELECT count(*) FROM information_schema.tables WHERE table_schema='marketing' AND table_name LIKE 'insights\_%';
--                 índices = SELECT count(*) FROM pg_indexes WHERE schemaname='marketing' AND tablename LIKE 'insights\_%' AND indexname NOT LIKE 'pk\_%';
--                 FKs     = SELECT count(*) FROM pg_constraint c JOIN pg_class r ON r.oid=c.conrelid JOIN pg_namespace n ON n.oid=r.relnamespace WHERE n.nspname='marketing' AND r.relname LIKE 'insights\_%' AND c.contype='f';
-- ============================================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS "marketing";

CREATE TABLE IF NOT EXISTS "marketing"."insights_campaigns" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "short_name" varchar NOT NULL,
    "kind_code" varchar NOT NULL,
    "objective_text" text,
    "audience_text" varchar,
    "start_on" date NOT NULL,
    "end_on" date,
    "budget_cents" bigint,
    "currency_concept_id" uuid,
    "ltv_cents" bigint,
    "revenue_per_conversion_cents" bigint,
    "owner_team_code" varchar,
    "targets_json" jsonb,
    "marketing_campaign_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_campaigns" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_creatives" (
    "id" uuid NOT NULL,
    "campaign_id" uuid NOT NULL,
    "channel_code" varchar NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "format_code" varchar,
    "audience_code" varchar,
    "cta_code" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_creatives" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_milestones" (
    "id" uuid NOT NULL,
    "occurred_on" date NOT NULL,
    "label" varchar NOT NULL,
    "campaign_id" uuid,
    "kind_code" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_milestones" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_data_sources" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "last_received_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "dataset_code" varchar NOT NULL DEFAULT 'demo',
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_data_sources" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_campaign_daily_facts" (
    "id" uuid NOT NULL,
    "fact_date" date NOT NULL,
    "campaign_id" uuid NOT NULL,
    "channel_code" varchar NOT NULL,
    "creative_id" uuid,
    "impressions" bigint,
    "reach" bigint,
    "engagements" bigint,
    "clicks" bigint,
    "video_views" bigint,
    "watch_seconds" bigint,
    "visits" bigint,
    "leads" bigint,
    "registrations" bigint,
    "activations" bigint,
    "first_uses" bigint,
    "conversions" bigint,
    "spend_cents" bigint,
    "revenue_cents" bigint,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_campaign_daily_facts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_campaign_hourly_facts" (
    "id" uuid NOT NULL,
    "fact_date" date NOT NULL,
    "hour" smallint NOT NULL,
    "campaign_id" uuid NOT NULL,
    "channel_code" varchar NOT NULL,
    "impressions" bigint,
    "clicks" bigint,
    "registrations" bigint,
    "conversions" bigint,
    "spend_cents" bigint,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_campaign_hourly_facts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_social_daily_facts" (
    "id" uuid NOT NULL,
    "fact_date" date NOT NULL,
    "platform_code" varchar NOT NULL,
    "followers" bigint,
    "new_followers" bigint,
    "reach" bigint,
    "impressions" bigint,
    "engagements" bigint,
    "saves" bigint,
    "shares" bigint,
    "comments" bigint,
    "clicks" bigint,
    "video_views" bigint,
    "watch_seconds" bigint,
    "completions" bigint,
    "viewed_pct_numerator" numeric(18,4),
    "viewed_pct_denominator" bigint,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_social_daily_facts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_social_posts" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "platform_code" varchar NOT NULL,
    "published_at" timestamptz NOT NULL,
    "format_code" varchar NOT NULL,
    "topic_code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "impressions" bigint,
    "reach" bigint,
    "engagements" bigint,
    "video_views" bigint,
    "shares" bigint,
    "saves" bigint,
    "comments" bigint,
    "clicks" bigint,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_social_posts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_app_daily_facts" (
    "id" uuid NOT NULL,
    "fact_date" date NOT NULL,
    "platform_code" varchar NOT NULL,
    "dau" bigint,
    "wau" bigint,
    "mau" bigint,
    "sessions" bigint,
    "total_session_seconds" bigint,
    "new_users" bigint,
    "returning_users" bigint,
    "searches" bigint,
    "bookings_started" bigint,
    "bookings_completed" bigint,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_app_daily_facts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_app_screen_daily_facts" (
    "id" uuid NOT NULL,
    "fact_date" date NOT NULL,
    "platform_code" varchar NOT NULL,
    "screen_code" varchar NOT NULL,
    "views" bigint,
    "exits" bigint,
    "rage_taps" bigint,
    "avg_seconds" integer,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_app_screen_daily_facts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_app_onboarding_facts" (
    "id" uuid NOT NULL,
    "app_version" varchar NOT NULL,
    "step_code" varchar NOT NULL,
    "step_order" integer NOT NULL,
    "users_reached" bigint,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_app_onboarding_facts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_mentions" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "mentioned_at" timestamptz NOT NULL,
    "brand_code" varchar NOT NULL,
    "source_code" varchar NOT NULL,
    "topic_code" varchar NOT NULL,
    "sentiment_code" varchar NOT NULL,
    "kind_code" varchar NOT NULL,
    "department_code" varchar,
    "body_text" text NOT NULL,
    "reach" bigint,
    "confidence" numeric(5,4),
    "needs_response" boolean NOT NULL DEFAULT false,
    "responded_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_mentions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_search_signals" (
    "id" uuid NOT NULL,
    "week_start" date NOT NULL,
    "query_text" varchar NOT NULL,
    "kind_code" varchar NOT NULL,
    "volume" bigint NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_search_signals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_environment_items" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "published_on" date NOT NULL,
    "domain_code" varchar NOT NULL,
    "category_code" varchar NOT NULL,
    "scope_code" varchar NOT NULL,
    "kind_code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "source_name" varchar,
    "affects_text" text,
    "relevance" integer NOT NULL,
    "impact_text" text,
    "action_text" text,
    "monitor_text" text,
    "campaign_effects_json" jsonb,
    "analysis_json" jsonb,
    "trend_seed" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_environment_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_sector_trends" (
    "id" uuid NOT NULL,
    "week_start" date NOT NULL,
    "trend_code" varchar NOT NULL,
    "value" numeric(18,4) NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_sector_trends" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_alert_rules" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "severity_concept_id" uuid NOT NULL,
    "unit" varchar NOT NULL,
    "default_threshold" numeric(18,4) NOT NULL,
    "threshold" numeric(18,4) NOT NULL,
    "direction" varchar NOT NULL,
    "enabled" boolean NOT NULL DEFAULT true,
    "min_sample_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_alert_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_alerts" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "fingerprint" varchar NOT NULL,
    "rule_code" varchar,
    "severity_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "what_text" text NOT NULL,
    "detected_on" date NOT NULL,
    "magnitude" numeric(18,4),
    "magnitude_unit" varchar,
    "source_text" varchar,
    "module_code" varchar,
    "context_json" jsonb,
    "cause_text" text,
    "impact_text" text,
    "recommendation_text" text,
    "confidence_code" varchar,
    "priority" smallint NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "owner_team_code" varchar,
    "evidence_json" jsonb,
    "series_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_alerts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_alert_transitions" (
    "id" uuid NOT NULL,
    "alert_id" uuid NOT NULL,
    "from_status_concept_id" uuid,
    "to_status_concept_id" uuid NOT NULL,
    "from_owner_team_code" varchar,
    "to_owner_team_code" varchar,
    "note" text,
    "recorded_by_user_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insights_alert_transitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_notification_preferences" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "matrix_json" jsonb NOT NULL,
    "frequency_code" varchar NOT NULL,
    "digest_hour" smallint,
    "quiet_from" time,
    "quiet_to" time,
    "quiet_exempt_critical" boolean NOT NULL DEFAULT true,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_notification_preferences" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_user_preferences" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "density_code" varchar NOT NULL,
    "theme_code" varchar NOT NULL,
    "nav_collapsed" boolean NOT NULL DEFAULT false,
    "timezone" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_user_preferences" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_reports" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "type_code" varchar NOT NULL,
    "audience_code" varchar NOT NULL,
    "period_from" date NOT NULL,
    "period_to" date NOT NULL,
    "campaign_ids_json" jsonb,
    "channels_json" jsonb,
    "sections_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_reports" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."insights_saved_views" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "module_code" varchar NOT NULL,
    "filters_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insights_saved_views" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaigns"
        ADD CONSTRAINT "fk_insights_campaigns_marketing_campaign_id" FOREIGN KEY ("marketing_campaign_id")
        REFERENCES "marketing"."marketing_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "marketing"."insights_creatives"
        ADD CONSTRAINT "fk_insights_creatives_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "marketing"."insights_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "marketing"."insights_milestones"
        ADD CONSTRAINT "fk_insights_milestones_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "marketing"."insights_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaign_daily_facts"
        ADD CONSTRAINT "fk_insights_campaign_daily_facts_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "marketing"."insights_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaign_daily_facts"
        ADD CONSTRAINT "fk_insights_campaign_daily_facts_creative_id" FOREIGN KEY ("creative_id")
        REFERENCES "marketing"."insights_creatives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaign_hourly_facts"
        ADD CONSTRAINT "fk_insights_campaign_hourly_facts_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "marketing"."insights_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alert_transitions"
        ADD CONSTRAINT "fk_insights_alert_transitions_alert_id" FOREIGN KEY ("alert_id")
        REFERENCES "marketing"."insights_alerts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaigns"
        ADD CONSTRAINT "fk_insights_campaigns_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaigns"
        ADD CONSTRAINT "fk_insights_campaigns_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaigns"
        ADD CONSTRAINT "fk_insights_campaigns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_campaigns"
        ADD CONSTRAINT "fk_insights_campaigns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_creatives"
        ADD CONSTRAINT "fk_insights_creatives_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_creatives"
        ADD CONSTRAINT "fk_insights_creatives_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_creatives"
        ADD CONSTRAINT "fk_insights_creatives_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_milestones"
        ADD CONSTRAINT "fk_insights_milestones_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_milestones"
        ADD CONSTRAINT "fk_insights_milestones_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_data_sources"
        ADD CONSTRAINT "fk_insights_data_sources_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_data_sources"
        ADD CONSTRAINT "fk_insights_data_sources_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_data_sources"
        ADD CONSTRAINT "fk_insights_data_sources_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_social_posts"
        ADD CONSTRAINT "fk_insights_social_posts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_social_posts"
        ADD CONSTRAINT "fk_insights_social_posts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_mentions"
        ADD CONSTRAINT "fk_insights_mentions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_mentions"
        ADD CONSTRAINT "fk_insights_mentions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_environment_items"
        ADD CONSTRAINT "fk_insights_environment_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_environment_items"
        ADD CONSTRAINT "fk_insights_environment_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alert_rules"
        ADD CONSTRAINT "fk_insights_alert_rules_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alert_rules"
        ADD CONSTRAINT "fk_insights_alert_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alert_rules"
        ADD CONSTRAINT "fk_insights_alert_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alerts"
        ADD CONSTRAINT "fk_insights_alerts_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alerts"
        ADD CONSTRAINT "fk_insights_alerts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alerts"
        ADD CONSTRAINT "fk_insights_alerts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alerts"
        ADD CONSTRAINT "fk_insights_alerts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alert_transitions"
        ADD CONSTRAINT "fk_insights_alert_transitions_from_status_concept_id" FOREIGN KEY ("from_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alert_transitions"
        ADD CONSTRAINT "fk_insights_alert_transitions_to_status_concept_id" FOREIGN KEY ("to_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_alert_transitions"
        ADD CONSTRAINT "fk_insights_alert_transitions_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_notification_preferences"
        ADD CONSTRAINT "fk_insights_notification_preferences_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_notification_preferences"
        ADD CONSTRAINT "fk_insights_notification_preferences_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_notification_preferences"
        ADD CONSTRAINT "fk_insights_notification_preferences_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_user_preferences"
        ADD CONSTRAINT "fk_insights_user_preferences_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_user_preferences"
        ADD CONSTRAINT "fk_insights_user_preferences_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_user_preferences"
        ADD CONSTRAINT "fk_insights_user_preferences_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_reports"
        ADD CONSTRAINT "fk_insights_reports_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_reports"
        ADD CONSTRAINT "fk_insights_reports_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_reports"
        ADD CONSTRAINT "fk_insights_reports_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_saved_views"
        ADD CONSTRAINT "fk_insights_saved_views_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_saved_views"
        ADD CONSTRAINT "fk_insights_saved_views_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."insights_saved_views"
        ADD CONSTRAINT "fk_insights_saved_views_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_campaigns_code" ON "marketing"."insights_campaigns" ("code");

CREATE INDEX IF NOT EXISTS "ix_insights_campaigns_marketing_campaign_id" ON "marketing"."insights_campaigns" ("marketing_campaign_id");

CREATE INDEX IF NOT EXISTS "ix_insights_campaigns_start_on" ON "marketing"."insights_campaigns" ("start_on");

CREATE INDEX IF NOT EXISTS "ix_insights_campaigns_currency_concept_id" ON "marketing"."insights_campaigns" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_campaigns_status_concept_id" ON "marketing"."insights_campaigns" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_campaigns_created_by_user_id" ON "marketing"."insights_campaigns" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_campaigns_updated_by_user_id" ON "marketing"."insights_campaigns" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_creatives_campaign_id_code" ON "marketing"."insights_creatives" ("campaign_id", "code");

CREATE INDEX IF NOT EXISTS "ix_insights_creatives_status_concept_id" ON "marketing"."insights_creatives" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_creatives_created_by_user_id" ON "marketing"."insights_creatives" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_creatives_updated_by_user_id" ON "marketing"."insights_creatives" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_milestones_occurred_on" ON "marketing"."insights_milestones" ("occurred_on");

CREATE INDEX IF NOT EXISTS "ix_insights_milestones_campaign_id" ON "marketing"."insights_milestones" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_insights_milestones_created_by_user_id" ON "marketing"."insights_milestones" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_milestones_updated_by_user_id" ON "marketing"."insights_milestones" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_data_sources_code" ON "marketing"."insights_data_sources" ("code");

CREATE INDEX IF NOT EXISTS "ix_insights_data_sources_status_concept_id" ON "marketing"."insights_data_sources" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_data_sources_created_by_user_id" ON "marketing"."insights_data_sources" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_data_sources_updated_by_user_id" ON "marketing"."insights_data_sources" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_campaign_daily_facts_natural_key" ON "marketing"."insights_campaign_daily_facts" ("fact_date", "campaign_id", "channel_code", "creative_id");

CREATE INDEX IF NOT EXISTS "ix_insights_campaign_daily_facts_campaign_id_fact_date" ON "marketing"."insights_campaign_daily_facts" ("campaign_id", "fact_date");

CREATE INDEX IF NOT EXISTS "ix_insights_campaign_daily_facts_creative_id" ON "marketing"."insights_campaign_daily_facts" ("creative_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_campaign_hourly_facts_natural_key" ON "marketing"."insights_campaign_hourly_facts" ("fact_date", "hour", "campaign_id", "channel_code");

CREATE INDEX IF NOT EXISTS "ix_insights_campaign_hourly_facts_campaign_id" ON "marketing"."insights_campaign_hourly_facts" ("campaign_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_social_daily_facts_natural_key" ON "marketing"."insights_social_daily_facts" ("fact_date", "platform_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_social_posts_code" ON "marketing"."insights_social_posts" ("code");

CREATE INDEX IF NOT EXISTS "ix_insights_social_posts_platform_code_published_at" ON "marketing"."insights_social_posts" ("platform_code", "published_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_insights_social_posts_created_by_user_id" ON "marketing"."insights_social_posts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_social_posts_updated_by_user_id" ON "marketing"."insights_social_posts" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_app_daily_facts_natural_key" ON "marketing"."insights_app_daily_facts" ("fact_date", "platform_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_app_screen_daily_facts_natural_key" ON "marketing"."insights_app_screen_daily_facts" ("fact_date", "platform_code", "screen_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_app_onboarding_facts_natural_key" ON "marketing"."insights_app_onboarding_facts" ("app_version", "step_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_mentions_code" ON "marketing"."insights_mentions" ("code");

CREATE INDEX IF NOT EXISTS "ix_insights_mentions_mentioned_at" ON "marketing"."insights_mentions" ("mentioned_at");

CREATE INDEX IF NOT EXISTS "ix_insights_mentions_sentiment_code_mentioned_at" ON "marketing"."insights_mentions" ("sentiment_code", "mentioned_at");

CREATE INDEX IF NOT EXISTS "gin_insights_mentions_search" ON "marketing"."insights_mentions" USING gin (to_tsvector('simple', body_text));

CREATE INDEX IF NOT EXISTS "ix_insights_mentions_created_by_user_id" ON "marketing"."insights_mentions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_mentions_updated_by_user_id" ON "marketing"."insights_mentions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_search_signals_natural_key" ON "marketing"."insights_search_signals" ("week_start", "query_text");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_environment_items_code" ON "marketing"."insights_environment_items" ("code");

CREATE INDEX IF NOT EXISTS "ix_insights_environment_items_relevance" ON "marketing"."insights_environment_items" ("relevance" DESC);

CREATE INDEX IF NOT EXISTS "ix_insights_environment_items_published_on" ON "marketing"."insights_environment_items" ("published_on" DESC);

CREATE INDEX IF NOT EXISTS "ix_insights_environment_items_created_by_user_id" ON "marketing"."insights_environment_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_environment_items_updated_by_user_id" ON "marketing"."insights_environment_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_sector_trends_natural_key" ON "marketing"."insights_sector_trends" ("week_start", "trend_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_alert_rules_code" ON "marketing"."insights_alert_rules" ("code");

CREATE INDEX IF NOT EXISTS "ix_insights_alert_rules_severity_concept_id" ON "marketing"."insights_alert_rules" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_alert_rules_created_by_user_id" ON "marketing"."insights_alert_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_alert_rules_updated_by_user_id" ON "marketing"."insights_alert_rules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_alerts_code" ON "marketing"."insights_alerts" ("code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_alerts_fingerprint" ON "marketing"."insights_alerts" ("fingerprint");

CREATE INDEX IF NOT EXISTS "ix_insights_alerts_status_concept_id_priority" ON "marketing"."insights_alerts" ("status_concept_id", "priority");

CREATE INDEX IF NOT EXISTS "ix_insights_alerts_detected_on" ON "marketing"."insights_alerts" ("detected_on" DESC);

CREATE INDEX IF NOT EXISTS "ix_insights_alerts_severity_concept_id" ON "marketing"."insights_alerts" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_alerts_created_by_user_id" ON "marketing"."insights_alerts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_alerts_updated_by_user_id" ON "marketing"."insights_alerts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_alert_transitions_alert_id_recorded_at" ON "marketing"."insights_alert_transitions" ("alert_id", "recorded_at");

CREATE INDEX IF NOT EXISTS "ix_insights_alert_transitions_from_status_concept_id" ON "marketing"."insights_alert_transitions" ("from_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_alert_transitions_to_status_concept_id" ON "marketing"."insights_alert_transitions" ("to_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_alert_transitions_recorded_by_user_id" ON "marketing"."insights_alert_transitions" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_notification_preferences_user_id" ON "marketing"."insights_notification_preferences" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_notification_preferences_created_by_user_id" ON "marketing"."insights_notification_preferences" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_notification_preferences_updated_by_user_id" ON "marketing"."insights_notification_preferences" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_user_preferences_user_id" ON "marketing"."insights_user_preferences" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_user_preferences_created_by_user_id" ON "marketing"."insights_user_preferences" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_user_preferences_updated_by_user_id" ON "marketing"."insights_user_preferences" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_reports_user_id_updated_at" ON "marketing"."insights_reports" ("user_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_insights_reports_created_by_user_id" ON "marketing"."insights_reports" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_reports_updated_by_user_id" ON "marketing"."insights_reports" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_insights_saved_views_user_id_name" ON "marketing"."insights_saved_views" ("user_id", "name");

CREATE INDEX IF NOT EXISTS "ix_insights_saved_views_created_by_user_id" ON "marketing"."insights_saved_views" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insights_saved_views_updated_by_user_id" ON "marketing"."insights_saved_views" ("updated_by_user_id");

COMMIT;
