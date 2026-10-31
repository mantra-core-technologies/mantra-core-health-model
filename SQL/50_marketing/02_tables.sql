-- SALUD v4.2.79 · módulo 50 · schema marketing
-- Generado de diagram_50_marketing.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "marketing"."segments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "segment_type_concept_id" uuid NOT NULL,
    "definition_json" jsonb,
    "source_read_model_id" uuid,
    "estimated_size" bigint,
    "last_refreshed_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    "version_number" integer,
    CONSTRAINT "pk_segments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."segment_members" (
    "id" uuid NOT NULL,
    "segment_id" uuid NOT NULL,
    "member_type_concept_id" uuid NOT NULL,
    "member_ref_id" uuid NOT NULL,
    "score" numeric,
    "added_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_segment_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."marketing_campaigns" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "campaign_type_concept_id" uuid NOT NULL,
    "objective_concept_id" uuid NOT NULL,
    "channel_concept_id" uuid,
    "segment_id" uuid,
    "budget_amount" numeric,
    "currency_concept_id" uuid,
    "ad_campaign_ref_id" uuid,
    "promotion_id" uuid,
    "start_at" timestamptz,
    "end_at" timestamptz,
    "owner_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    "governance_scope_concept_id" uuid,
    "requires_explicit_publish" boolean,
    "published_version" integer,
    "published_at" timestamptz,
    "published_by_user_id" uuid,
    "approved_content_hash" varchar,
    "approved_audience_hash" varchar,
    "cancellation_reason" varchar,
    "cancelled_at" timestamptz,
    "cancelled_by_user_id" uuid,
    CONSTRAINT "pk_marketing_campaigns" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."campaign_members" (
    "id" uuid NOT NULL,
    "campaign_id" uuid NOT NULL,
    "member_type_concept_id" uuid NOT NULL,
    "member_ref_id" uuid NOT NULL,
    "member_status_concept_id" uuid NOT NULL,
    "added_at" timestamptz,
    "responded_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    "source_segment_member_id" uuid,
    "first_dispatch_id" uuid,
    "last_dispatch_id" uuid,
    "total_dispatches" integer,
    CONSTRAINT "pk_campaign_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."content_templates" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "channel_concept_id" uuid NOT NULL,
    "language_concept_id" uuid,
    "subject" varchar,
    "body_template" text,
    "variables_json" jsonb,
    "messaging_template_id" uuid,
    "version" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_content_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."journeys" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "entry_trigger_concept_id" uuid NOT NULL,
    "entry_segment_id" uuid,
    "goal_metric_concept_id" uuid,
    "definition_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_journeys" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."journey_steps" (
    "id" uuid NOT NULL,
    "journey_id" uuid NOT NULL,
    "step_code" varchar NOT NULL,
    "step_type_concept_id" uuid NOT NULL,
    "channel_concept_id" uuid,
    "content_template_id" uuid,
    "wait_duration_minutes" integer,
    "condition_json" jsonb,
    "next_step_id" uuid,
    "branch_step_id" uuid,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_journey_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."journey_enrollments" (
    "id" uuid NOT NULL,
    "journey_id" uuid NOT NULL,
    "member_type_concept_id" uuid NOT NULL,
    "member_ref_id" uuid NOT NULL,
    "current_step_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "entered_at" timestamptz,
    "exited_at" timestamptz,
    "exit_reason_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_journey_enrollments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."tracked_links" (
    "id" uuid NOT NULL,
    "campaign_id" uuid,
    "code" varchar NOT NULL,
    "target_url" text NOT NULL,
    "utm_source" varchar,
    "utm_medium" varchar,
    "utm_campaign" varchar,
    "utm_content" varchar,
    "click_count" bigint,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tracked_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."marketing_touchpoints" (
    "id" uuid NOT NULL,
    "campaign_id" uuid,
    "journey_id" uuid,
    "tracked_link_id" uuid,
    "member_type_concept_id" uuid NOT NULL,
    "member_ref_id" uuid NOT NULL,
    "touch_type_concept_id" uuid NOT NULL,
    "channel_concept_id" uuid NOT NULL,
    "content_template_id" uuid,
    "metadata_json" jsonb,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    "dispatch_id" uuid,
    "dispatch_recipient_id" uuid,
    "notification_request_id" uuid,
    "notification_delivery_id" uuid,
    "tracking_event_id" uuid,
    CONSTRAINT "pk_marketing_touchpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."attribution_touches" (
    "id" uuid NOT NULL,
    "conversion_ref_type" varchar NOT NULL,
    "conversion_ref_id" uuid NOT NULL,
    "marketing_touchpoint_id" uuid NOT NULL,
    "attribution_model_concept_id" uuid NOT NULL,
    "weight" numeric NOT NULL,
    "attributed_value" numeric,
    "currency_concept_id" uuid,
    "position_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_attribution_touches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."campaign_dispatches" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "campaign_id" uuid NOT NULL,
    "schedule_id" uuid,
    "journey_id" uuid,
    "journey_step_id" uuid,
    "occurrence_key" varchar NOT NULL,
    "planned_at" timestamptz NOT NULL,
    "audience_snapshot_at" timestamptz,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "source_concept_id" uuid NOT NULL,
    "content_template_id" uuid NOT NULL,
    "content_template_version" integer NOT NULL,
    "content_hash" varchar NOT NULL,
    "audience_definition_hash" varchar NOT NULL,
    "total_candidates" bigint NOT NULL,
    "total_eligible" bigint NOT NULL,
    "total_suppressed" bigint NOT NULL,
    "total_requests" bigint NOT NULL,
    "total_accepted" bigint NOT NULL,
    "total_delivered" bigint NOT NULL,
    "total_seen" bigint NOT NULL,
    "total_read" bigint NOT NULL,
    "total_failed" bigint NOT NULL,
    "total_cancelled" bigint NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "authorized_by_user_id" uuid NOT NULL,
    "authorization_snapshot_json" jsonb NOT NULL,
    "failure_code" varchar,
    "failure_detail" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid NOT NULL,
    "updated_by_user_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_campaign_dispatches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."campaign_dispatch_recipients" (
    "id" uuid NOT NULL,
    "dispatch_id" uuid NOT NULL,
    "member_type_concept_id" uuid NOT NULL,
    "member_ref_id" uuid NOT NULL,
    "recipient_endpoint_id" uuid,
    "recipient_user_id" uuid,
    "channel_id" uuid NOT NULL,
    "language_concept_id" uuid,
    "timezone_name" varchar,
    "consent_id" uuid,
    "consent_status_concept_id" uuid NOT NULL,
    "preference_snapshot_json" jsonb,
    "eligibility_status_concept_id" uuid NOT NULL,
    "suppression_reason_concept_id" uuid,
    "suppression_detail" varchar,
    "scheduled_at" timestamptz NOT NULL,
    "notification_request_id" uuid,
    "current_delivery_id" uuid,
    "current_status_concept_id" uuid NOT NULL,
    "idempotency_key" varchar NOT NULL,
    "snapshot_json" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid NOT NULL,
    "updated_by_user_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_campaign_dispatch_recipients" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "marketing"."campaign_schedules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "campaign_id" uuid,
    "journey_id" uuid,
    "schedule_type_concept_id" uuid NOT NULL,
    "timezone_name" varchar NOT NULL,
    "scheduled_once_at" timestamptz,
    "cron_expression" varchar,
    "recurrence_rule_json" jsonb,
    "valid_from" timestamptz NOT NULL,
    "valid_until" timestamptz,
    "allowed_weekdays_json" jsonb,
    "allowed_time_window_json" jsonb,
    "missed_run_policy_concept_id" uuid NOT NULL,
    "overlap_policy_concept_id" uuid NOT NULL,
    "next_run_at" timestamptz,
    "last_run_at" timestamptz,
    "max_occurrences" integer,
    "completed_occurrences" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "schedule_version" integer NOT NULL,
    "published_content_hash" varchar NOT NULL,
    "published_audience_hash" varchar NOT NULL,
    "authorized_by_user_id" uuid NOT NULL,
    "authorized_at" timestamptz NOT NULL,
    "authorization_snapshot_json" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid NOT NULL,
    "updated_by_user_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_campaign_schedules" PRIMARY KEY ("id")
);

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
