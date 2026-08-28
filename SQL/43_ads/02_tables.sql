-- SALUD v4.0.10 · módulo 43 · schema ads
-- Generado de diagram_43_ads.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "ads"."business_managers" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "name" varchar NOT NULL,
    "external_business_ref" varchar NOT NULL,
    "owner_user_id" uuid NOT NULL,
    "vertical_concept_id" uuid,
    "primary_country_concept_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_business_managers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_partners" (
    "id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "partner_type_concept_id" uuid NOT NULL,
    "external_partner_ref" varchar,
    "tenant_id" uuid,
    "contact_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_partners" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."partner_relationships" (
    "id" uuid NOT NULL,
    "business_manager_id" uuid NOT NULL,
    "partner_id" uuid NOT NULL,
    "relationship_type_concept_id" uuid NOT NULL,
    "permissions_json" jsonb,
    "shared_asset_scope_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_partner_relationships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_accounts" (
    "id" uuid NOT NULL,
    "business_manager_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "external_account_ref" varchar NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "time_zone" varchar,
    "account_status_concept_id" uuid NOT NULL,
    "spend_cap_amount" numeric,
    "amount_spent" numeric,
    "funding_payment_method_id" uuid,
    "disable_reason_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_account_users" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "user_id" uuid,
    "partner_id" uuid,
    "role_concept_id" uuid NOT NULL,
    "tasks_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_account_users" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."campaigns" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "objective_concept_id" uuid NOT NULL,
    "buying_type_concept_id" uuid NOT NULL,
    "special_ad_categories_json" jsonb,
    "daily_budget" numeric,
    "lifetime_budget" numeric,
    "spend_cap" numeric,
    "bid_strategy_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "effective_status_concept_id" uuid,
    "start_at" timestamptz,
    "stop_at" timestamptz,
    "external_campaign_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_campaigns" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_sets" (
    "id" uuid NOT NULL,
    "campaign_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "optimization_goal_concept_id" uuid NOT NULL,
    "billing_event_concept_id" uuid NOT NULL,
    "bid_amount" numeric,
    "bid_strategy_concept_id" uuid,
    "daily_budget" numeric,
    "lifetime_budget" numeric,
    "targeting_spec_id" uuid,
    "promoted_object_json" jsonb,
    "pacing_type_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "effective_status_concept_id" uuid,
    "start_at" timestamptz,
    "end_at" timestamptz,
    "external_adset_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ads" (
    "id" uuid NOT NULL,
    "ad_set_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "creative_id" uuid NOT NULL,
    "tracking_specs_json" jsonb,
    "conversion_domain" varchar,
    "status_concept_id" uuid NOT NULL,
    "effective_status_concept_id" uuid,
    "review_feedback_json" jsonb,
    "external_ad_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ads" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_creatives" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "format_concept_id" uuid NOT NULL,
    "body" text,
    "call_to_action_concept_id" uuid,
    "link_url" text,
    "display_url" varchar,
    "object_story_json" jsonb,
    "primary_media_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_creatives" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."creative_assets" (
    "id" uuid NOT NULL,
    "ad_creative_id" uuid NOT NULL,
    "asset_type_concept_id" uuid NOT NULL,
    "file_id" uuid,
    "external_asset_ref" varchar,
    "hash" varchar,
    "width" integer,
    "height" integer,
    "duration_s" integer,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_creative_assets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."custom_audiences" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "audience_type_concept_id" uuid NOT NULL,
    "subtype_concept_id" uuid,
    "source_concept_id" uuid,
    "rule_json" jsonb,
    "lookalike_source_audience_id" uuid,
    "lookalike_spec_json" jsonb,
    "approximate_count" bigint,
    "data_source_pixel_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "external_audience_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_custom_audiences" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."targeting_specs" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar,
    "geo_locations_json" jsonb,
    "excluded_geo_locations_json" jsonb,
    "age_min" integer,
    "age_max" integer,
    "genders_json" jsonb,
    "interests_json" jsonb,
    "behaviors_json" jsonb,
    "demographics_json" jsonb,
    "custom_audience_ids_json" jsonb,
    "excluded_custom_audience_ids_json" jsonb,
    "locales_json" jsonb,
    "device_platforms_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_targeting_specs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_placements" (
    "id" uuid NOT NULL,
    "ad_set_id" uuid NOT NULL,
    "platform_concept_id" uuid NOT NULL,
    "position_concept_id" uuid NOT NULL,
    "device_concept_id" uuid,
    "is_enabled" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_placements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."tracking_pixels" (
    "id" uuid NOT NULL,
    "business_manager_id" uuid NOT NULL,
    "ad_account_id" uuid,
    "name" varchar NOT NULL,
    "pixel_code" varchar NOT NULL,
    "external_pixel_ref" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tracking_pixels" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."delivery_status_snapshots" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "entity_type_concept_id" uuid NOT NULL,
    "entity_ref_id" uuid NOT NULL,
    "effective_status_concept_id" uuid NOT NULL,
    "review_status_concept_id" uuid,
    "issues_json" jsonb,
    "captured_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_delivery_status_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."insights_daily" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "entity_type_concept_id" uuid NOT NULL,
    "entity_ref_id" uuid NOT NULL,
    "stat_date" date NOT NULL,
    "impressions" bigint,
    "reach" bigint,
    "clicks" bigint,
    "unique_clicks" bigint,
    "spend" numeric,
    "currency_concept_id" uuid,
    "conversions" bigint,
    "conversion_value" numeric,
    "ctr" numeric,
    "cpc" numeric,
    "cpm" numeric,
    "frequency" numeric,
    "video_views" bigint,
    "breakdown_json" jsonb,
    "source_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_insights_daily" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."attribution_settings" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "click_window_days" integer NOT NULL,
    "view_window_days" integer NOT NULL,
    "attribution_model_concept_id" uuid,
    "is_default" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_attribution_settings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."pixel_events" (
    "id" uuid NOT NULL,
    "pixel_id" uuid NOT NULL,
    "event_name" varchar NOT NULL,
    "event_source_concept_id" uuid NOT NULL,
    "event_source_url" text,
    "action_source_concept_id" uuid,
    "user_data_hash_json" jsonb,
    "custom_data_json" jsonb,
    "value_amount" numeric,
    "currency_concept_id" uuid,
    "event_id" varchar,
    "dedupe_key" varchar,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_pixel_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."conversion_attributions" (
    "id" uuid NOT NULL,
    "pixel_event_id" uuid NOT NULL,
    "ad_ref_id" uuid,
    "campaign_ref_id" uuid,
    "attribution_type_concept_id" uuid NOT NULL,
    "attributed_value" numeric,
    "currency_concept_id" uuid,
    "attributed_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_conversion_attributions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."budget_schedules" (
    "id" uuid NOT NULL,
    "entity_type_concept_id" uuid NOT NULL,
    "entity_ref_id" uuid NOT NULL,
    "budget_type_concept_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_budget_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_billing_events" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "billing_event_type_concept_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "period_start" date,
    "period_end" date,
    "external_billing_ref" varchar,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_ad_billing_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_invoices" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "invoice_number" varchar NOT NULL,
    "period_start" date NOT NULL,
    "period_end" date NOT NULL,
    "subtotal" numeric,
    "tax_total" numeric,
    "total" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "payment_intent_id" uuid,
    "issued_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_invoices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_invoice_lines" (
    "id" uuid NOT NULL,
    "ad_invoice_id" uuid NOT NULL,
    "campaign_ref_id" uuid NOT NULL,
    "description" varchar,
    "impressions" bigint,
    "clicks" bigint,
    "amount" numeric NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_invoice_lines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."product_catalogs" (
    "id" uuid NOT NULL,
    "business_manager_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "vertical_concept_id" uuid NOT NULL,
    "default_currency_concept_id" uuid,
    "item_count" integer,
    "external_catalog_ref" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_product_catalogs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."catalog_feeds" (
    "id" uuid NOT NULL,
    "product_catalog_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "feed_source_concept_id" uuid NOT NULL,
    "feed_url" text,
    "schedule_cron" varchar,
    "file_id" uuid,
    "last_run_at" timestamptz,
    "last_status_concept_id" uuid,
    "total_items" integer,
    "error_count" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_feeds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."catalog_products" (
    "id" uuid NOT NULL,
    "product_catalog_id" uuid NOT NULL,
    "retailer_product_id" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "availability_concept_id" uuid NOT NULL,
    "condition_concept_id" uuid NOT NULL,
    "price" numeric,
    "sale_price" numeric,
    "currency_concept_id" uuid,
    "brand" varchar,
    "category_concept_id" uuid,
    "image_url" text,
    "link_url" text,
    "source_product_type" varchar,
    "source_product_ref_id" uuid,
    "gtin" varchar,
    "custom_labels_json" jsonb,
    "inventory_count" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_products" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."product_localizations" (
    "id" uuid NOT NULL,
    "catalog_product_id" uuid NOT NULL,
    "language_concept_id" uuid NOT NULL,
    "country_concept_id" uuid,
    "description" text,
    "price" numeric,
    "currency_concept_id" uuid,
    "image_url" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_product_localizations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."product_sets" (
    "id" uuid NOT NULL,
    "product_catalog_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "filter_json" jsonb,
    "is_dynamic" boolean,
    "product_count" integer,
    "external_set_ref" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_product_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."product_set_members" (
    "id" uuid NOT NULL,
    "product_set_id" uuid NOT NULL,
    "catalog_product_id" uuid NOT NULL,
    "added_by_rule" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_product_set_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."dynamic_ad_templates" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "product_set_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "format_concept_id" uuid NOT NULL,
    "title_template" varchar,
    "description_template" text,
    "call_to_action_concept_id" uuid,
    "creative_id" uuid,
    "template_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dynamic_ad_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."collection_ads" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "layout_concept_id" uuid NOT NULL,
    "hero_creative_id" uuid,
    "product_set_id" uuid,
    "instant_experience_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_collection_ads" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."feed_run_logs" (
    "id" uuid NOT NULL,
    "catalog_feed_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "items_read" integer,
    "items_upserted" integer,
    "items_errored" integer,
    "error_sample_json" jsonb,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_feed_run_logs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."saved_audiences" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "targeting_spec_json" jsonb,
    "approximate_reach" bigint,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_saved_audiences" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."lookalike_specs" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "source_audience_id" uuid NOT NULL,
    "country_concept_id" uuid NOT NULL,
    "ratio_percent" numeric NOT NULL,
    "similarity_concept_id" uuid,
    "generated_audience_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lookalike_specs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."automated_rules" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "entity_filter_json" jsonb,
    "condition_json" jsonb NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "action_params_json" jsonb,
    "evaluation_schedule_concept_id" uuid NOT NULL,
    "is_enabled" boolean,
    "last_evaluated_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_automated_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."rule_executions" (
    "id" uuid NOT NULL,
    "automated_rule_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "entities_evaluated" integer,
    "entities_affected" integer,
    "actions_json" jsonb,
    "error_text" text,
    "evaluated_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_rule_executions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_experiments" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "experiment_type_concept_id" uuid NOT NULL,
    "objective_metric_concept_id" uuid NOT NULL,
    "hypothesis" text,
    "holdout_percent" numeric,
    "start_at" timestamptz,
    "end_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "winner_variant_id" uuid,
    "confidence_level" numeric,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_experiments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."experiment_variants" (
    "id" uuid NOT NULL,
    "ad_experiment_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "variant_ref_type" varchar NOT NULL,
    "variant_ref_id" uuid NOT NULL,
    "traffic_split_percent" numeric,
    "is_control" boolean,
    "result_metric_value" numeric,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_experiment_variants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."custom_conversions" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "pixel_id" uuid,
    "name" varchar NOT NULL,
    "conversion_category_concept_id" uuid NOT NULL,
    "rule_json" jsonb,
    "default_value" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_custom_conversions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."offline_conversion_sets" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "upload_source_concept_id" uuid NOT NULL,
    "total_events" integer,
    "matched_events" integer,
    "match_rate" numeric,
    "attributed_value" numeric,
    "file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "uploaded_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_offline_conversion_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."offline_conversion_events" (
    "id" uuid NOT NULL,
    "offline_conversion_set_id" uuid NOT NULL,
    "event_name" varchar NOT NULL,
    "event_time" timestamptz,
    "match_keys_hash_json" jsonb,
    "value_amount" numeric,
    "currency_concept_id" uuid,
    "order_ref" varchar,
    "is_matched" boolean,
    "attributed_campaign_ref_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_offline_conversion_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."frequency_caps" (
    "id" uuid NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "scope_ref_id" uuid NOT NULL,
    "max_impressions" integer NOT NULL,
    "time_window_concept_id" uuid NOT NULL,
    "window_count" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frequency_caps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."brand_lift_studies" (
    "id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "campaign_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "metric_concept_id" uuid NOT NULL,
    "poll_question" text,
    "lift_percent" numeric,
    "confidence" numeric,
    "start_at" timestamptz,
    "end_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_brand_lift_studies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_platform_connections" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "business_manager_id" uuid NOT NULL,
    "ad_account_id" uuid,
    "platform_concept_id" uuid NOT NULL,
    "connection_name" varchar NOT NULL,
    "credential_id" uuid NOT NULL,
    "api_version" varchar,
    "external_business_id" varchar,
    "external_ad_account_id" varchar,
    "webhook_verification_secret_id" uuid,
    "token_expires_at" timestamptz,
    "last_successful_sync_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_platform_connections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_identity_assets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "identity_type_concept_id" uuid NOT NULL,
    "external_identity_id" varchar NOT NULL,
    "display_name" varchar NOT NULL,
    "username" varchar,
    "profile_url" varchar,
    "metadata_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_identity_assets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_identity_asset_assignments" (
    "id" uuid NOT NULL,
    "ad_identity_asset_id" uuid NOT NULL,
    "assignable_type_concept_id" uuid NOT NULL,
    "assignable_id" uuid NOT NULL,
    "assignment_role_concept_id" uuid NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_identity_asset_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."conversion_datasets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "dataset_type_concept_id" uuid NOT NULL,
    "external_dataset_id" varchar,
    "data_use_case_concept_id" uuid,
    "default_attribution_setting_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_conversion_datasets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."dataset_connections" (
    "id" uuid NOT NULL,
    "conversion_dataset_id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "tracking_pixel_id" uuid,
    "connection_type_concept_id" uuid NOT NULL,
    "external_connection_id" varchar,
    "test_event_code_secret_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_dataset_connections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."server_conversion_events" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "conversion_dataset_id" uuid NOT NULL,
    "event_name" varchar NOT NULL,
    "event_id" varchar NOT NULL,
    "event_time" timestamptz NOT NULL,
    "action_source_concept_id" uuid NOT NULL,
    "event_source_url" varchar,
    "external_order_id" varchar,
    "payment_transaction_id" uuid,
    "crm_lead_id" uuid,
    "crm_opportunity_id" uuid,
    "consent_directive_id" uuid,
    "data_processing_options_json" jsonb,
    "test_event_code_used" boolean,
    "processing_status_concept_id" uuid NOT NULL,
    "blocked_reason_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_server_conversion_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."conversion_event_user_data" (
    "id" uuid NOT NULL,
    "server_conversion_event_id" uuid NOT NULL,
    "external_user_id_hash" varchar,
    "email_hash_sha256" varchar,
    "phone_hash_sha256" varchar,
    "first_name_hash_sha256" varchar,
    "last_name_hash_sha256" varchar,
    "city_hash_sha256" varchar,
    "country_code_hash_sha256" varchar,
    "client_ip_address_encrypted" text,
    "client_user_agent_encrypted" text,
    "click_id" varchar,
    "browser_id" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conversion_event_user_data" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."conversion_event_custom_data" (
    "id" uuid NOT NULL,
    "server_conversion_event_id" uuid NOT NULL,
    "currency_code" char(3),
    "value_amount" numeric(20,6),
    "content_ids_json" jsonb,
    "content_type" varchar,
    "contents_json" jsonb,
    "num_items" integer,
    "order_id" varchar,
    "custom_properties_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conversion_event_custom_data" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."conversion_event_delivery_attempts" (
    "id" uuid NOT NULL,
    "server_conversion_event_id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "attempted_at" timestamptz NOT NULL,
    "result_concept_id" uuid NOT NULL,
    "http_status" integer,
    "external_trace_id" varchar,
    "response_json_redacted" jsonb,
    "retry_at" timestamptz,
    "error_code" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conversion_event_delivery_attempts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."conversion_event_deduplication" (
    "id" uuid NOT NULL,
    "conversion_dataset_id" uuid NOT NULL,
    "event_name" varchar NOT NULL,
    "event_id" varchar NOT NULL,
    "browser_event_reference" varchar,
    "server_conversion_event_id" uuid,
    "first_seen_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz,
    "duplicate_count" integer NOT NULL,
    "resolution_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conversion_event_deduplication" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."dataset_quality_snapshots" (
    "id" uuid NOT NULL,
    "conversion_dataset_id" uuid NOT NULL,
    "measured_at" timestamptz NOT NULL,
    "event_match_quality_score" numeric(8,4),
    "deduplicated_event_percent" numeric(8,4),
    "rejected_event_percent" numeric(8,4),
    "freshness_seconds" bigint,
    "diagnostics_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_dataset_quality_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."lead_forms" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "ad_identity_asset_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "external_form_id" varchar,
    "form_type_concept_id" uuid NOT NULL,
    "privacy_policy_url" varchar,
    "completion_message" text,
    "destination_crm_pipeline_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lead_forms" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."lead_form_questions" (
    "id" uuid NOT NULL,
    "lead_form_id" uuid NOT NULL,
    "question_key" varchar NOT NULL,
    "question_type_concept_id" uuid NOT NULL,
    "label" varchar NOT NULL,
    "options_json" jsonb,
    "display_order" integer NOT NULL,
    "is_required" boolean NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lead_form_questions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."lead_submissions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "lead_form_id" uuid NOT NULL,
    "ad_id" uuid,
    "ad_set_id" uuid,
    "campaign_id" uuid,
    "external_lead_id" varchar NOT NULL,
    "submitted_at" timestamptz NOT NULL,
    "crm_lead_id" uuid,
    "consent_directive_id" uuid,
    "processing_status_concept_id" uuid NOT NULL,
    "raw_payload_hash" varchar,
    "source_ip_hash" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_lead_submissions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."lead_answers" (
    "id" uuid NOT NULL,
    "lead_submission_id" uuid NOT NULL,
    "lead_form_question_id" uuid NOT NULL,
    "answer_text_encrypted" text,
    "answer_json_encrypted" text,
    "normalized_value_hash" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_lead_answers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."lead_delivery_events" (
    "id" uuid NOT NULL,
    "lead_submission_id" uuid NOT NULL,
    "destination_type_concept_id" uuid NOT NULL,
    "destination_reference" varchar,
    "attempted_at" timestamptz NOT NULL,
    "attempt_number" integer NOT NULL,
    "result_concept_id" uuid NOT NULL,
    "response_reference" varchar,
    "retry_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_lead_delivery_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."insight_metric_definitions" (
    "id" uuid NOT NULL,
    "platform_concept_id" uuid NOT NULL,
    "metric_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "data_type_concept_id" uuid NOT NULL,
    "aggregation_concept_id" uuid,
    "description" text,
    "is_estimated" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insight_metric_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."insight_breakdown_definitions" (
    "id" uuid NOT NULL,
    "platform_concept_id" uuid NOT NULL,
    "breakdown_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "compatible_metrics_json" jsonb,
    "privacy_threshold_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insight_breakdown_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."insight_query_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "date_start" date,
    "date_end" date,
    "object_level_concept_id" uuid,
    "metric_codes_json" jsonb,
    "breakdown_codes_json" jsonb,
    "filtering_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "external_report_id" varchar,
    "completed_at" timestamptz,
    "row_count" bigint,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insight_query_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."insight_fact_rows" (
    "id" uuid NOT NULL,
    "insight_query_run_id" uuid NOT NULL,
    "fact_date" date NOT NULL,
    "object_type_concept_id" uuid NOT NULL,
    "external_object_id" varchar NOT NULL,
    "campaign_id" uuid,
    "ad_set_id" uuid,
    "ad_id" uuid,
    "dimensions_json" jsonb,
    "metrics_json" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_insight_fact_rows" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_review_events" (
    "id" uuid NOT NULL,
    "ad_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "review_event_type_concept_id" uuid NOT NULL,
    "review_status_concept_id" uuid NOT NULL,
    "external_review_id" varchar,
    "reasons_json" jsonb,
    "source_payload_hash" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ad_review_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_policy_violations" (
    "id" uuid NOT NULL,
    "ad_id" uuid NOT NULL,
    "ad_review_event_id" uuid,
    "policy_code" varchar NOT NULL,
    "policy_category_concept_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "explanation" text,
    "status_concept_id" uuid NOT NULL,
    "detected_at" timestamptz,
    "resolved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_policy_violations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_policy_appeals" (
    "id" uuid NOT NULL,
    "ad_policy_violation_id" uuid NOT NULL,
    "submitted_at" timestamptz NOT NULL,
    "submitted_by_user_id" uuid,
    "appeal_reason" text NOT NULL,
    "evidence_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "external_appeal_id" varchar,
    "decided_at" timestamptz,
    "decision_reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_policy_appeals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."adset_learning_snapshots" (
    "id" uuid NOT NULL,
    "ad_set_id" uuid NOT NULL,
    "measured_at" timestamptz NOT NULL,
    "learning_status_concept_id" uuid NOT NULL,
    "optimization_events_count" bigint,
    "estimated_learning_exit_at" timestamptz,
    "limited_reason_concept_id" uuid,
    "recommendations_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_adset_learning_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_event_data_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "jurisdiction_concept_id" uuid NOT NULL,
    "purpose_of_use_concept_id" uuid NOT NULL,
    "requires_consent" boolean,
    "consent_scope_concept_id" uuid,
    "default_action_concept_id" uuid NOT NULL,
    "prohibited_data_classes_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_event_data_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_event_field_rules" (
    "id" uuid NOT NULL,
    "ad_event_data_policy_id" uuid NOT NULL,
    "event_name_pattern" varchar NOT NULL,
    "field_path" varchar NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "transformation_concept_id" uuid,
    "rationale" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ad_event_field_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."blocked_ad_events" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "ad_event_data_policy_id" uuid NOT NULL,
    "source_event_reference" varchar,
    "event_name" varchar NOT NULL,
    "blocked_at" timestamptz NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "blocked_field_paths_json" jsonb,
    "payload_hash" varchar,
    "review_status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_blocked_ad_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."external_ad_object_snapshots" (
    "id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "object_type_concept_id" uuid NOT NULL,
    "external_object_id" varchar NOT NULL,
    "external_updated_at" timestamptz NOT NULL,
    "snapshot_at" timestamptz NOT NULL,
    "payload_json" jsonb NOT NULL,
    "payload_hash" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_external_ad_object_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_sync_runs" (
    "id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "sync_direction_concept_id" uuid NOT NULL,
    "object_type_concept_id" uuid NOT NULL,
    "started_at" timestamptz NOT NULL,
    "ended_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "objects_read" bigint,
    "objects_written" bigint,
    "objects_failed" bigint,
    "error_summary_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ad_sync_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ads"."ad_sync_checkpoints" (
    "id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "object_type_concept_id" uuid NOT NULL,
    "checkpoint_key" varchar NOT NULL,
    "checkpoint_value_encrypted" text,
    "checkpoint_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_ad_sync_checkpoints" PRIMARY KEY ("id")
);
