-- SALUD v4.0.10 · módulo 43 · schema ads
-- Generado de diagram_43_ads.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "ads"."partner_relationships"
        ADD CONSTRAINT "fk_partner_relationships_business_manager_id" FOREIGN KEY ("business_manager_id")
        REFERENCES "ads"."business_managers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."partner_relationships"
        ADD CONSTRAINT "fk_partner_relationships_partner_id" FOREIGN KEY ("partner_id")
        REFERENCES "ads"."ad_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_accounts"
        ADD CONSTRAINT "fk_ad_accounts_business_manager_id" FOREIGN KEY ("business_manager_id")
        REFERENCES "ads"."business_managers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_account_users"
        ADD CONSTRAINT "fk_ad_account_users_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_account_users"
        ADD CONSTRAINT "fk_ad_account_users_partner_id" FOREIGN KEY ("partner_id")
        REFERENCES "ads"."ad_partners" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_targeting_spec_id" FOREIGN KEY ("targeting_spec_id")
        REFERENCES "ads"."targeting_specs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ads"
        ADD CONSTRAINT "fk_ads_ad_set_id" FOREIGN KEY ("ad_set_id")
        REFERENCES "ads"."ad_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ads"
        ADD CONSTRAINT "fk_ads_creative_id" FOREIGN KEY ("creative_id")
        REFERENCES "ads"."ad_creatives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_creatives"
        ADD CONSTRAINT "fk_ad_creatives_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."creative_assets"
        ADD CONSTRAINT "fk_creative_assets_ad_creative_id" FOREIGN KEY ("ad_creative_id")
        REFERENCES "ads"."ad_creatives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_lookalike_source_audience_id" FOREIGN KEY ("lookalike_source_audience_id")
        REFERENCES "ads"."custom_audiences" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_data_source_pixel_id" FOREIGN KEY ("data_source_pixel_id")
        REFERENCES "ads"."tracking_pixels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."targeting_specs"
        ADD CONSTRAINT "fk_targeting_specs_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_placements"
        ADD CONSTRAINT "fk_ad_placements_ad_set_id" FOREIGN KEY ("ad_set_id")
        REFERENCES "ads"."ad_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."tracking_pixels"
        ADD CONSTRAINT "fk_tracking_pixels_business_manager_id" FOREIGN KEY ("business_manager_id")
        REFERENCES "ads"."business_managers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."tracking_pixels"
        ADD CONSTRAINT "fk_tracking_pixels_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."delivery_status_snapshots"
        ADD CONSTRAINT "fk_delivery_status_snapshots_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."insights_daily"
        ADD CONSTRAINT "fk_insights_daily_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."attribution_settings"
        ADD CONSTRAINT "fk_attribution_settings_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."pixel_events"
        ADD CONSTRAINT "fk_pixel_events_pixel_id" FOREIGN KEY ("pixel_id")
        REFERENCES "ads"."tracking_pixels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_attributions"
        ADD CONSTRAINT "fk_conversion_attributions_pixel_event_id" FOREIGN KEY ("pixel_event_id")
        REFERENCES "ads"."pixel_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_billing_events"
        ADD CONSTRAINT "fk_ad_billing_events_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoices"
        ADD CONSTRAINT "fk_ad_invoices_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoice_lines"
        ADD CONSTRAINT "fk_ad_invoice_lines_ad_invoice_id" FOREIGN KEY ("ad_invoice_id")
        REFERENCES "ads"."ad_invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."product_catalogs"
        ADD CONSTRAINT "fk_product_catalogs_business_manager_id" FOREIGN KEY ("business_manager_id")
        REFERENCES "ads"."business_managers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."catalog_feeds"
        ADD CONSTRAINT "fk_catalog_feeds_product_catalog_id" FOREIGN KEY ("product_catalog_id")
        REFERENCES "ads"."product_catalogs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_product_catalog_id" FOREIGN KEY ("product_catalog_id")
        REFERENCES "ads"."product_catalogs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."product_localizations"
        ADD CONSTRAINT "fk_product_localizations_catalog_product_id" FOREIGN KEY ("catalog_product_id")
        REFERENCES "ads"."catalog_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."product_sets"
        ADD CONSTRAINT "fk_product_sets_product_catalog_id" FOREIGN KEY ("product_catalog_id")
        REFERENCES "ads"."product_catalogs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."product_set_members"
        ADD CONSTRAINT "fk_product_set_members_product_set_id" FOREIGN KEY ("product_set_id")
        REFERENCES "ads"."product_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."product_set_members"
        ADD CONSTRAINT "fk_product_set_members_catalog_product_id" FOREIGN KEY ("catalog_product_id")
        REFERENCES "ads"."catalog_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_product_set_id" FOREIGN KEY ("product_set_id")
        REFERENCES "ads"."product_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_creative_id" FOREIGN KEY ("creative_id")
        REFERENCES "ads"."ad_creatives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."collection_ads"
        ADD CONSTRAINT "fk_collection_ads_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."collection_ads"
        ADD CONSTRAINT "fk_collection_ads_hero_creative_id" FOREIGN KEY ("hero_creative_id")
        REFERENCES "ads"."ad_creatives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."collection_ads"
        ADD CONSTRAINT "fk_collection_ads_product_set_id" FOREIGN KEY ("product_set_id")
        REFERENCES "ads"."product_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."feed_run_logs"
        ADD CONSTRAINT "fk_feed_run_logs_catalog_feed_id" FOREIGN KEY ("catalog_feed_id")
        REFERENCES "ads"."catalog_feeds" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."saved_audiences"
        ADD CONSTRAINT "fk_saved_audiences_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_source_audience_id" FOREIGN KEY ("source_audience_id")
        REFERENCES "ads"."custom_audiences" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_generated_audience_id" FOREIGN KEY ("generated_audience_id")
        REFERENCES "ads"."custom_audiences" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."automated_rules"
        ADD CONSTRAINT "fk_automated_rules_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."rule_executions"
        ADD CONSTRAINT "fk_rule_executions_automated_rule_id" FOREIGN KEY ("automated_rule_id")
        REFERENCES "ads"."automated_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_experiments"
        ADD CONSTRAINT "fk_ad_experiments_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_experiments"
        ADD CONSTRAINT "fk_ad_experiments_winner_variant_id" FOREIGN KEY ("winner_variant_id")
        REFERENCES "ads"."experiment_variants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."experiment_variants"
        ADD CONSTRAINT "fk_experiment_variants_ad_experiment_id" FOREIGN KEY ("ad_experiment_id")
        REFERENCES "ads"."ad_experiments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."custom_conversions"
        ADD CONSTRAINT "fk_custom_conversions_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."custom_conversions"
        ADD CONSTRAINT "fk_custom_conversions_pixel_id" FOREIGN KEY ("pixel_id")
        REFERENCES "ads"."tracking_pixels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_sets"
        ADD CONSTRAINT "fk_offline_conversion_sets_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_events"
        ADD CONSTRAINT "fk_offline_conversion_events_offline_conversion_set_id" FOREIGN KEY ("offline_conversion_set_id")
        REFERENCES "ads"."offline_conversion_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."brand_lift_studies"
        ADD CONSTRAINT "fk_brand_lift_studies_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."brand_lift_studies"
        ADD CONSTRAINT "fk_brand_lift_studies_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_business_manager_id" FOREIGN KEY ("business_manager_id")
        REFERENCES "ads"."business_managers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_assets"
        ADD CONSTRAINT "fk_ad_identity_assets_platform_connection_id" FOREIGN KEY ("platform_connection_id")
        REFERENCES "ads"."ad_platform_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_asset_assignments"
        ADD CONSTRAINT "fk_ad_identity_asset_assignments_ad_identity_asset_id" FOREIGN KEY ("ad_identity_asset_id")
        REFERENCES "ads"."ad_identity_assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_default_attribution_setting_id" FOREIGN KEY ("default_attribution_setting_id")
        REFERENCES "ads"."attribution_settings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_conversion_dataset_id" FOREIGN KEY ("conversion_dataset_id")
        REFERENCES "ads"."conversion_datasets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_platform_connection_id" FOREIGN KEY ("platform_connection_id")
        REFERENCES "ads"."ad_platform_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_tracking_pixel_id" FOREIGN KEY ("tracking_pixel_id")
        REFERENCES "ads"."tracking_pixels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_conversion_dataset_id" FOREIGN KEY ("conversion_dataset_id")
        REFERENCES "ads"."conversion_datasets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_user_data"
        ADD CONSTRAINT "fk_conversion_event_user_data_server_conversion_event_id" FOREIGN KEY ("server_conversion_event_id")
        REFERENCES "ads"."server_conversion_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_custom_data"
        ADD CONSTRAINT "fk_conversion_event_custom_data_server_conversion_event_id" FOREIGN KEY ("server_conversion_event_id")
        REFERENCES "ads"."server_conversion_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_delivery_attempts"
        ADD CONSTRAINT "fk_conversion_event_delivery_attempts_server_conversio_0b5ca799" FOREIGN KEY ("server_conversion_event_id")
        REFERENCES "ads"."server_conversion_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_delivery_attempts"
        ADD CONSTRAINT "fk_conversion_event_delivery_attempts_platform_connection_id" FOREIGN KEY ("platform_connection_id")
        REFERENCES "ads"."ad_platform_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_deduplication"
        ADD CONSTRAINT "fk_conversion_event_deduplication_conversion_dataset_id" FOREIGN KEY ("conversion_dataset_id")
        REFERENCES "ads"."conversion_datasets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_deduplication"
        ADD CONSTRAINT "fk_conversion_event_deduplication_server_conversion_event_id" FOREIGN KEY ("server_conversion_event_id")
        REFERENCES "ads"."server_conversion_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."dataset_quality_snapshots"
        ADD CONSTRAINT "fk_dataset_quality_snapshots_conversion_dataset_id" FOREIGN KEY ("conversion_dataset_id")
        REFERENCES "ads"."conversion_datasets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_ad_identity_asset_id" FOREIGN KEY ("ad_identity_asset_id")
        REFERENCES "ads"."ad_identity_assets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_form_questions"
        ADD CONSTRAINT "fk_lead_form_questions_lead_form_id" FOREIGN KEY ("lead_form_id")
        REFERENCES "ads"."lead_forms" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_submissions"
        ADD CONSTRAINT "fk_lead_submissions_lead_form_id" FOREIGN KEY ("lead_form_id")
        REFERENCES "ads"."lead_forms" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_submissions"
        ADD CONSTRAINT "fk_lead_submissions_ad_id" FOREIGN KEY ("ad_id")
        REFERENCES "ads"."ads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_submissions"
        ADD CONSTRAINT "fk_lead_submissions_ad_set_id" FOREIGN KEY ("ad_set_id")
        REFERENCES "ads"."ad_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_submissions"
        ADD CONSTRAINT "fk_lead_submissions_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_answers"
        ADD CONSTRAINT "fk_lead_answers_lead_submission_id" FOREIGN KEY ("lead_submission_id")
        REFERENCES "ads"."lead_submissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_answers"
        ADD CONSTRAINT "fk_lead_answers_lead_form_question_id" FOREIGN KEY ("lead_form_question_id")
        REFERENCES "ads"."lead_form_questions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."lead_delivery_events"
        ADD CONSTRAINT "fk_lead_delivery_events_lead_submission_id" FOREIGN KEY ("lead_submission_id")
        REFERENCES "ads"."lead_submissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."insight_query_runs"
        ADD CONSTRAINT "fk_insight_query_runs_ad_account_id" FOREIGN KEY ("ad_account_id")
        REFERENCES "ads"."ad_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."insight_query_runs"
        ADD CONSTRAINT "fk_insight_query_runs_platform_connection_id" FOREIGN KEY ("platform_connection_id")
        REFERENCES "ads"."ad_platform_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."insight_fact_rows"
        ADD CONSTRAINT "fk_insight_fact_rows_insight_query_run_id" FOREIGN KEY ("insight_query_run_id")
        REFERENCES "ads"."insight_query_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."insight_fact_rows"
        ADD CONSTRAINT "fk_insight_fact_rows_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."insight_fact_rows"
        ADD CONSTRAINT "fk_insight_fact_rows_ad_set_id" FOREIGN KEY ("ad_set_id")
        REFERENCES "ads"."ad_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."insight_fact_rows"
        ADD CONSTRAINT "fk_insight_fact_rows_ad_id" FOREIGN KEY ("ad_id")
        REFERENCES "ads"."ads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_review_events"
        ADD CONSTRAINT "fk_ad_review_events_ad_id" FOREIGN KEY ("ad_id")
        REFERENCES "ads"."ads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_violations"
        ADD CONSTRAINT "fk_ad_policy_violations_ad_id" FOREIGN KEY ("ad_id")
        REFERENCES "ads"."ads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_violations"
        ADD CONSTRAINT "fk_ad_policy_violations_ad_review_event_id" FOREIGN KEY ("ad_review_event_id")
        REFERENCES "ads"."ad_review_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_appeals"
        ADD CONSTRAINT "fk_ad_policy_appeals_ad_policy_violation_id" FOREIGN KEY ("ad_policy_violation_id")
        REFERENCES "ads"."ad_policy_violations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."adset_learning_snapshots"
        ADD CONSTRAINT "fk_adset_learning_snapshots_ad_set_id" FOREIGN KEY ("ad_set_id")
        REFERENCES "ads"."ad_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_field_rules"
        ADD CONSTRAINT "fk_ad_event_field_rules_ad_event_data_policy_id" FOREIGN KEY ("ad_event_data_policy_id")
        REFERENCES "ads"."ad_event_data_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."blocked_ad_events"
        ADD CONSTRAINT "fk_blocked_ad_events_ad_event_data_policy_id" FOREIGN KEY ("ad_event_data_policy_id")
        REFERENCES "ads"."ad_event_data_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."external_ad_object_snapshots"
        ADD CONSTRAINT "fk_external_ad_object_snapshots_platform_connection_id" FOREIGN KEY ("platform_connection_id")
        REFERENCES "ads"."ad_platform_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_sync_runs"
        ADD CONSTRAINT "fk_ad_sync_runs_platform_connection_id" FOREIGN KEY ("platform_connection_id")
        REFERENCES "ads"."ad_platform_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "ads"."ad_sync_checkpoints"
        ADD CONSTRAINT "fk_ad_sync_checkpoints_platform_connection_id" FOREIGN KEY ("platform_connection_id")
        REFERENCES "ads"."ad_platform_connections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
