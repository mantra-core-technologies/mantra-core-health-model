-- SALUD v4.0.10 · módulo 43 · schema ads
-- Generado de diagram_43_ads.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_business_managers_external_business_ref" ON "ads"."business_managers" ("external_business_ref");

CREATE INDEX IF NOT EXISTS "ix_business_managers_tenant_id" ON "ads"."business_managers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_business_managers_owner_user_id" ON "ads"."business_managers" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_managers_vertical_concept_id" ON "ads"."business_managers" ("vertical_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_managers_primary_country_concept_id" ON "ads"."business_managers" ("primary_country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_managers_state_concept_id" ON "ads"."business_managers" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_business_managers_created_by_user_id" ON "ads"."business_managers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_managers_updated_by_user_id" ON "ads"."business_managers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_business_managers_tenant_id_state_concept_id" ON "ads"."business_managers" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_business_managers_search" ON "ads"."business_managers" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_ad_partners_partner_type_concept_id" ON "ads"."ad_partners" ("partner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_partners_tenant_id" ON "ads"."ad_partners" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_ad_partners_state_concept_id" ON "ads"."ad_partners" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_partners_created_by_user_id" ON "ads"."ad_partners" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_partners_updated_by_user_id" ON "ads"."ad_partners" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_partners_tenant_id_state_concept_id" ON "ads"."ad_partners" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_ad_partners_search" ON "ads"."ad_partners" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_partner_relationships_business_manager_id" ON "ads"."partner_relationships" ("business_manager_id");

CREATE INDEX IF NOT EXISTS "ix_partner_relationships_partner_id" ON "ads"."partner_relationships" ("partner_id");

CREATE INDEX IF NOT EXISTS "ix_partner_relationships_relationship_type_concept_id" ON "ads"."partner_relationships" ("relationship_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partner_relationships_status_concept_id" ON "ads"."partner_relationships" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partner_relationships_created_by_user_id" ON "ads"."partner_relationships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_partner_relationships_updated_by_user_id" ON "ads"."partner_relationships" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_ad_accounts_external_account_ref" ON "ads"."ad_accounts" ("external_account_ref");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_business_manager_id" ON "ads"."ad_accounts" ("business_manager_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_currency_concept_id" ON "ads"."ad_accounts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_account_status_concept_id" ON "ads"."ad_accounts" ("account_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_funding_payment_method_id" ON "ads"."ad_accounts" ("funding_payment_method_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_disable_reason_concept_id" ON "ads"."ad_accounts" ("disable_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_created_by_user_id" ON "ads"."ad_accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_accounts_updated_by_user_id" ON "ads"."ad_accounts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_ad_accounts_search" ON "ads"."ad_accounts" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_ad_account_users_ad_account_id" ON "ads"."ad_account_users" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_account_users_user_id" ON "ads"."ad_account_users" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_account_users_partner_id" ON "ads"."ad_account_users" ("partner_id");

CREATE INDEX IF NOT EXISTS "ix_ad_account_users_role_concept_id" ON "ads"."ad_account_users" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_account_users_status_concept_id" ON "ads"."ad_account_users" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_account_users_created_by_user_id" ON "ads"."ad_account_users" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_account_users_updated_by_user_id" ON "ads"."ad_account_users" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_ad_account_id" ON "ads"."campaigns" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_objective_concept_id" ON "ads"."campaigns" ("objective_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_buying_type_concept_id" ON "ads"."campaigns" ("buying_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_bid_strategy_concept_id" ON "ads"."campaigns" ("bid_strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_status_concept_id" ON "ads"."campaigns" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_effective_status_concept_id" ON "ads"."campaigns" ("effective_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_created_by_user_id" ON "ads"."campaigns" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaigns_updated_by_user_id" ON "ads"."campaigns" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_campaigns_search" ON "ads"."campaigns" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_ad_sets_campaign_id" ON "ads"."ad_sets" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_optimization_goal_concept_id" ON "ads"."ad_sets" ("optimization_goal_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_billing_event_concept_id" ON "ads"."ad_sets" ("billing_event_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_bid_strategy_concept_id" ON "ads"."ad_sets" ("bid_strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_targeting_spec_id" ON "ads"."ad_sets" ("targeting_spec_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_pacing_type_concept_id" ON "ads"."ad_sets" ("pacing_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_status_concept_id" ON "ads"."ad_sets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_effective_status_concept_id" ON "ads"."ad_sets" ("effective_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_created_by_user_id" ON "ads"."ad_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sets_updated_by_user_id" ON "ads"."ad_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_ad_sets_search" ON "ads"."ad_sets" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_ads_ad_set_id" ON "ads"."ads" ("ad_set_id");

CREATE INDEX IF NOT EXISTS "ix_ads_creative_id" ON "ads"."ads" ("creative_id");

CREATE INDEX IF NOT EXISTS "ix_ads_status_concept_id" ON "ads"."ads" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ads_effective_status_concept_id" ON "ads"."ads" ("effective_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ads_created_by_user_id" ON "ads"."ads" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ads_updated_by_user_id" ON "ads"."ads" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_ads_search" ON "ads"."ads" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_ad_account_id" ON "ads"."ad_creatives" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_format_concept_id" ON "ads"."ad_creatives" ("format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_call_to_action_concept_id" ON "ads"."ad_creatives" ("call_to_action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_primary_media_file_id" ON "ads"."ad_creatives" ("primary_media_file_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_status_concept_id" ON "ads"."ad_creatives" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_created_by_user_id" ON "ads"."ad_creatives" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_creatives_updated_by_user_id" ON "ads"."ad_creatives" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_ad_creatives_search" ON "ads"."ad_creatives" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_creative_assets_ad_creative_id" ON "ads"."creative_assets" ("ad_creative_id");

CREATE INDEX IF NOT EXISTS "ix_creative_assets_asset_type_concept_id" ON "ads"."creative_assets" ("asset_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_creative_assets_file_id" ON "ads"."creative_assets" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_creative_assets_created_by_user_id" ON "ads"."creative_assets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_creative_assets_updated_by_user_id" ON "ads"."creative_assets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_ad_account_id" ON "ads"."custom_audiences" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_audience_type_concept_id" ON "ads"."custom_audiences" ("audience_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_subtype_concept_id" ON "ads"."custom_audiences" ("subtype_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_source_concept_id" ON "ads"."custom_audiences" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_lookalike_source_audience_id" ON "ads"."custom_audiences" ("lookalike_source_audience_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_data_source_pixel_id" ON "ads"."custom_audiences" ("data_source_pixel_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_status_concept_id" ON "ads"."custom_audiences" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_created_by_user_id" ON "ads"."custom_audiences" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_custom_audiences_updated_by_user_id" ON "ads"."custom_audiences" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_custom_audiences_search" ON "ads"."custom_audiences" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_targeting_specs_ad_account_id" ON "ads"."targeting_specs" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_targeting_specs_created_by_user_id" ON "ads"."targeting_specs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_targeting_specs_updated_by_user_id" ON "ads"."targeting_specs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_targeting_specs_search" ON "ads"."targeting_specs" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_ad_placements_ad_set_id" ON "ads"."ad_placements" ("ad_set_id");

CREATE INDEX IF NOT EXISTS "ix_ad_placements_platform_concept_id" ON "ads"."ad_placements" ("platform_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_placements_position_concept_id" ON "ads"."ad_placements" ("position_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_placements_device_concept_id" ON "ads"."ad_placements" ("device_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_placements_created_by_user_id" ON "ads"."ad_placements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_placements_updated_by_user_id" ON "ads"."ad_placements" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_tracking_pixels_pixel_code" ON "ads"."tracking_pixels" ("pixel_code");

CREATE INDEX IF NOT EXISTS "ix_tracking_pixels_business_manager_id" ON "ads"."tracking_pixels" ("business_manager_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_pixels_ad_account_id" ON "ads"."tracking_pixels" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_pixels_state_concept_id" ON "ads"."tracking_pixels" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_pixels_created_by_user_id" ON "ads"."tracking_pixels" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_pixels_updated_by_user_id" ON "ads"."tracking_pixels" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_tracking_pixels_search" ON "ads"."tracking_pixels" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_delivery_status_snapshots_ad_account_id" ON "ads"."delivery_status_snapshots" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_snapshots_entity_type_concept_id" ON "ads"."delivery_status_snapshots" ("entity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_snapshots_effective_status_concept_id" ON "ads"."delivery_status_snapshots" ("effective_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_snapshots_review_status_concept_id" ON "ads"."delivery_status_snapshots" ("review_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_snapshots_recorded_by_user_id" ON "ads"."delivery_status_snapshots" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_delivery_status_snapshots_recorded_at" ON "ads"."delivery_status_snapshots" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_insights_daily_ad_account_id" ON "ads"."insights_daily" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_insights_daily_entity_type_concept_id" ON "ads"."insights_daily" ("entity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_daily_currency_concept_id" ON "ads"."insights_daily" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_daily_source_concept_id" ON "ads"."insights_daily" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insights_daily_recorded_by_user_id" ON "ads"."insights_daily" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_insights_daily_recorded_at" ON "ads"."insights_daily" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_attribution_settings_ad_account_id" ON "ads"."attribution_settings" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_settings_attribution_model_concept_id" ON "ads"."attribution_settings" ("attribution_model_concept_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_settings_created_by_user_id" ON "ads"."attribution_settings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_settings_updated_by_user_id" ON "ads"."attribution_settings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pixel_events_pixel_id" ON "ads"."pixel_events" ("pixel_id");

CREATE INDEX IF NOT EXISTS "ix_pixel_events_event_source_concept_id" ON "ads"."pixel_events" ("event_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pixel_events_action_source_concept_id" ON "ads"."pixel_events" ("action_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pixel_events_currency_concept_id" ON "ads"."pixel_events" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pixel_events_recorded_by_user_id" ON "ads"."pixel_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_pixel_events_recorded_at" ON "ads"."pixel_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_conversion_attributions_pixel_event_id" ON "ads"."conversion_attributions" ("pixel_event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_attributions_attribution_type_concept_id" ON "ads"."conversion_attributions" ("attribution_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_attributions_currency_concept_id" ON "ads"."conversion_attributions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_attributions_recorded_by_user_id" ON "ads"."conversion_attributions" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_conversion_attributions_recorded_at" ON "ads"."conversion_attributions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_budget_schedules_entity_type_concept_id" ON "ads"."budget_schedules" ("entity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_budget_schedules_budget_type_concept_id" ON "ads"."budget_schedules" ("budget_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_budget_schedules_currency_concept_id" ON "ads"."budget_schedules" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_budget_schedules_status_concept_id" ON "ads"."budget_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_budget_schedules_created_by_user_id" ON "ads"."budget_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_budget_schedules_updated_by_user_id" ON "ads"."budget_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_budget_schedules_effective_period" ON "ads"."budget_schedules" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_ad_billing_events_ad_account_id" ON "ads"."ad_billing_events" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_billing_events_billing_event_type_concept_id" ON "ads"."ad_billing_events" ("billing_event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_billing_events_currency_concept_id" ON "ads"."ad_billing_events" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_billing_events_recorded_by_user_id" ON "ads"."ad_billing_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_ad_billing_events_recorded_at" ON "ads"."ad_billing_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_ad_invoices_invoice_number" ON "ads"."ad_invoices" ("invoice_number");

CREATE INDEX IF NOT EXISTS "ix_ad_invoices_ad_account_id" ON "ads"."ad_invoices" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoices_currency_concept_id" ON "ads"."ad_invoices" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoices_status_concept_id" ON "ads"."ad_invoices" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoices_payment_intent_id" ON "ads"."ad_invoices" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoices_created_by_user_id" ON "ads"."ad_invoices" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoices_updated_by_user_id" ON "ads"."ad_invoices" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoice_lines_ad_invoice_id" ON "ads"."ad_invoice_lines" ("ad_invoice_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoice_lines_created_by_user_id" ON "ads"."ad_invoice_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_invoice_lines_updated_by_user_id" ON "ads"."ad_invoice_lines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_ad_invoice_lines_search" ON "ads"."ad_invoice_lines" USING gin (to_tsvector('simple', (coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_business_manager_id" ON "ads"."product_catalogs" ("business_manager_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_vertical_concept_id" ON "ads"."product_catalogs" ("vertical_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_default_currency_concept_id" ON "ads"."product_catalogs" ("default_currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_state_concept_id" ON "ads"."product_catalogs" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_created_by_user_id" ON "ads"."product_catalogs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_product_catalogs_updated_by_user_id" ON "ads"."product_catalogs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_product_catalogs_search" ON "ads"."product_catalogs" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_catalog_feeds_product_catalog_id" ON "ads"."catalog_feeds" ("product_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_feeds_feed_source_concept_id" ON "ads"."catalog_feeds" ("feed_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_feeds_file_id" ON "ads"."catalog_feeds" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_feeds_last_status_concept_id" ON "ads"."catalog_feeds" ("last_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_feeds_state_concept_id" ON "ads"."catalog_feeds" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_feeds_created_by_user_id" ON "ads"."catalog_feeds" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_feeds_updated_by_user_id" ON "ads"."catalog_feeds" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_catalog_feeds_search" ON "ads"."catalog_feeds" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_catalog_products_product_catalog_id" ON "ads"."catalog_products" ("product_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_availability_concept_id" ON "ads"."catalog_products" ("availability_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_condition_concept_id" ON "ads"."catalog_products" ("condition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_currency_concept_id" ON "ads"."catalog_products" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_category_concept_id" ON "ads"."catalog_products" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_status_concept_id" ON "ads"."catalog_products" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_created_by_user_id" ON "ads"."catalog_products" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_catalog_products_updated_by_user_id" ON "ads"."catalog_products" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_catalog_products_search" ON "ads"."catalog_products" USING gin (to_tsvector('simple', (coalesce(title, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_product_localizations_catalog_product_id" ON "ads"."product_localizations" ("catalog_product_id");

CREATE INDEX IF NOT EXISTS "ix_product_localizations_language_concept_id" ON "ads"."product_localizations" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_localizations_country_concept_id" ON "ads"."product_localizations" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_localizations_currency_concept_id" ON "ads"."product_localizations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_localizations_created_by_user_id" ON "ads"."product_localizations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_product_localizations_updated_by_user_id" ON "ads"."product_localizations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_product_localizations_search" ON "ads"."product_localizations" USING gin (to_tsvector('simple', (coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_product_sets_product_catalog_id" ON "ads"."product_sets" ("product_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_product_sets_state_concept_id" ON "ads"."product_sets" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_product_sets_created_by_user_id" ON "ads"."product_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_product_sets_updated_by_user_id" ON "ads"."product_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_product_sets_search" ON "ads"."product_sets" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_product_set_members_product_set_id" ON "ads"."product_set_members" ("product_set_id");

CREATE INDEX IF NOT EXISTS "ix_product_set_members_catalog_product_id" ON "ads"."product_set_members" ("catalog_product_id");

CREATE INDEX IF NOT EXISTS "ix_product_set_members_created_by_user_id" ON "ads"."product_set_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_product_set_members_updated_by_user_id" ON "ads"."product_set_members" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_ad_account_id" ON "ads"."dynamic_ad_templates" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_product_set_id" ON "ads"."dynamic_ad_templates" ("product_set_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_format_concept_id" ON "ads"."dynamic_ad_templates" ("format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_call_to_action_concept_id" ON "ads"."dynamic_ad_templates" ("call_to_action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_creative_id" ON "ads"."dynamic_ad_templates" ("creative_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_status_concept_id" ON "ads"."dynamic_ad_templates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_created_by_user_id" ON "ads"."dynamic_ad_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_ad_templates_updated_by_user_id" ON "ads"."dynamic_ad_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_dynamic_ad_templates_search" ON "ads"."dynamic_ad_templates" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_collection_ads_ad_account_id" ON "ads"."collection_ads" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_collection_ads_layout_concept_id" ON "ads"."collection_ads" ("layout_concept_id");

CREATE INDEX IF NOT EXISTS "ix_collection_ads_hero_creative_id" ON "ads"."collection_ads" ("hero_creative_id");

CREATE INDEX IF NOT EXISTS "ix_collection_ads_product_set_id" ON "ads"."collection_ads" ("product_set_id");

CREATE INDEX IF NOT EXISTS "ix_collection_ads_status_concept_id" ON "ads"."collection_ads" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_collection_ads_created_by_user_id" ON "ads"."collection_ads" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_collection_ads_updated_by_user_id" ON "ads"."collection_ads" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_collection_ads_search" ON "ads"."collection_ads" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_feed_run_logs_catalog_feed_id" ON "ads"."feed_run_logs" ("catalog_feed_id");

CREATE INDEX IF NOT EXISTS "ix_feed_run_logs_status_concept_id" ON "ads"."feed_run_logs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feed_run_logs_recorded_by_user_id" ON "ads"."feed_run_logs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_feed_run_logs_recorded_at" ON "ads"."feed_run_logs" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_saved_audiences_ad_account_id" ON "ads"."saved_audiences" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_saved_audiences_status_concept_id" ON "ads"."saved_audiences" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_saved_audiences_created_by_user_id" ON "ads"."saved_audiences" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_saved_audiences_updated_by_user_id" ON "ads"."saved_audiences" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_saved_audiences_search" ON "ads"."saved_audiences" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_ad_account_id" ON "ads"."lookalike_specs" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_source_audience_id" ON "ads"."lookalike_specs" ("source_audience_id");

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_country_concept_id" ON "ads"."lookalike_specs" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_similarity_concept_id" ON "ads"."lookalike_specs" ("similarity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_generated_audience_id" ON "ads"."lookalike_specs" ("generated_audience_id");

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_status_concept_id" ON "ads"."lookalike_specs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_created_by_user_id" ON "ads"."lookalike_specs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lookalike_specs_updated_by_user_id" ON "ads"."lookalike_specs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_ad_account_id" ON "ads"."automated_rules" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_scope_concept_id" ON "ads"."automated_rules" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_action_concept_id" ON "ads"."automated_rules" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_evaluation_schedule_concept_id" ON "ads"."automated_rules" ("evaluation_schedule_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_state_concept_id" ON "ads"."automated_rules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_created_by_user_id" ON "ads"."automated_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_automated_rules_updated_by_user_id" ON "ads"."automated_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_automated_rules_search" ON "ads"."automated_rules" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_rule_executions_automated_rule_id" ON "ads"."rule_executions" ("automated_rule_id");

CREATE INDEX IF NOT EXISTS "ix_rule_executions_status_concept_id" ON "ads"."rule_executions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_rule_executions_recorded_by_user_id" ON "ads"."rule_executions" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_rule_executions_recorded_at" ON "ads"."rule_executions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_ad_account_id" ON "ads"."ad_experiments" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_experiment_type_concept_id" ON "ads"."ad_experiments" ("experiment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_objective_metric_concept_id" ON "ads"."ad_experiments" ("objective_metric_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_status_concept_id" ON "ads"."ad_experiments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_winner_variant_id" ON "ads"."ad_experiments" ("winner_variant_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_created_by_user_id" ON "ads"."ad_experiments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_experiments_updated_by_user_id" ON "ads"."ad_experiments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_ad_experiments_search" ON "ads"."ad_experiments" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_experiment_variants_ad_experiment_id" ON "ads"."experiment_variants" ("ad_experiment_id");

CREATE INDEX IF NOT EXISTS "ix_experiment_variants_created_by_user_id" ON "ads"."experiment_variants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_experiment_variants_updated_by_user_id" ON "ads"."experiment_variants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_experiment_variants_search" ON "ads"."experiment_variants" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_ad_account_id" ON "ads"."custom_conversions" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_pixel_id" ON "ads"."custom_conversions" ("pixel_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_conversion_category_concept_id" ON "ads"."custom_conversions" ("conversion_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_currency_concept_id" ON "ads"."custom_conversions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_status_concept_id" ON "ads"."custom_conversions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_created_by_user_id" ON "ads"."custom_conversions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_custom_conversions_updated_by_user_id" ON "ads"."custom_conversions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_custom_conversions_search" ON "ads"."custom_conversions" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_sets_ad_account_id" ON "ads"."offline_conversion_sets" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_sets_upload_source_concept_id" ON "ads"."offline_conversion_sets" ("upload_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_sets_file_id" ON "ads"."offline_conversion_sets" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_sets_status_concept_id" ON "ads"."offline_conversion_sets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_sets_created_by_user_id" ON "ads"."offline_conversion_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_sets_updated_by_user_id" ON "ads"."offline_conversion_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_offline_conversion_sets_search" ON "ads"."offline_conversion_sets" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_events_offline_conversion_set_id" ON "ads"."offline_conversion_events" ("offline_conversion_set_id");

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_events_currency_concept_id" ON "ads"."offline_conversion_events" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_offline_conversion_events_recorded_by_user_id" ON "ads"."offline_conversion_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_offline_conversion_events_recorded_at" ON "ads"."offline_conversion_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_frequency_caps_scope_concept_id" ON "ads"."frequency_caps" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frequency_caps_time_window_concept_id" ON "ads"."frequency_caps" ("time_window_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frequency_caps_created_by_user_id" ON "ads"."frequency_caps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frequency_caps_updated_by_user_id" ON "ads"."frequency_caps" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_brand_lift_studies_ad_account_id" ON "ads"."brand_lift_studies" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_brand_lift_studies_campaign_id" ON "ads"."brand_lift_studies" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_brand_lift_studies_metric_concept_id" ON "ads"."brand_lift_studies" ("metric_concept_id");

CREATE INDEX IF NOT EXISTS "ix_brand_lift_studies_status_concept_id" ON "ads"."brand_lift_studies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_brand_lift_studies_created_by_user_id" ON "ads"."brand_lift_studies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_brand_lift_studies_updated_by_user_id" ON "ads"."brand_lift_studies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_brand_lift_studies_search" ON "ads"."brand_lift_studies" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_tenant_id" ON "ads"."ad_platform_connections" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_business_manager_id" ON "ads"."ad_platform_connections" ("business_manager_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_ad_account_id" ON "ads"."ad_platform_connections" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_platform_concept_id" ON "ads"."ad_platform_connections" ("platform_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_credential_id" ON "ads"."ad_platform_connections" ("credential_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_external_business_id" ON "ads"."ad_platform_connections" ("external_business_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_external_ad_account_id" ON "ads"."ad_platform_connections" ("external_ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_webhook_verification_secret_id" ON "ads"."ad_platform_connections" ("webhook_verification_secret_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_status_concept_id" ON "ads"."ad_platform_connections" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_created_by_user_id" ON "ads"."ad_platform_connections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_updated_by_user_id" ON "ads"."ad_platform_connections" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_platform_connections_tenant_status" ON "ads"."ad_platform_connections" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_ad_platform_connections_tenant_platform_external" ON "ads"."ad_platform_connections" ("tenant_id", "platform_concept_id", "external_ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_tenant_id" ON "ads"."ad_identity_assets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_platform_connection_id" ON "ads"."ad_identity_assets" ("platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_identity_type_concept_id" ON "ads"."ad_identity_assets" ("identity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_external_identity_id" ON "ads"."ad_identity_assets" ("external_identity_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_status_concept_id" ON "ads"."ad_identity_assets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_created_by_user_id" ON "ads"."ad_identity_assets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_updated_by_user_id" ON "ads"."ad_identity_assets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assets_tenant_status" ON "ads"."ad_identity_assets" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_ad_identity_assets_connection_external" ON "ads"."ad_identity_assets" ("platform_connection_id", "identity_type_concept_id", "external_identity_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_asset_assignments_ad_identity_asset_id" ON "ads"."ad_identity_asset_assignments" ("ad_identity_asset_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_asset_assignments_assignable_type_concept_id" ON "ads"."ad_identity_asset_assignments" ("assignable_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_asset_assignments_assignable_id" ON "ads"."ad_identity_asset_assignments" ("assignable_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_asset_assignments_assignment_role_concept_id" ON "ads"."ad_identity_asset_assignments" ("assignment_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_asset_assignments_created_by_user_id" ON "ads"."ad_identity_asset_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_asset_assignments_updated_by_user_id" ON "ads"."ad_identity_asset_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_identity_assignments_target" ON "ads"."ad_identity_asset_assignments" ("assignable_type_concept_id", "assignable_id", "effective_to");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_tenant_id" ON "ads"."conversion_datasets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_ad_account_id" ON "ads"."conversion_datasets" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_dataset_type_concept_id" ON "ads"."conversion_datasets" ("dataset_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_external_dataset_id" ON "ads"."conversion_datasets" ("external_dataset_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_data_use_case_concept_id" ON "ads"."conversion_datasets" ("data_use_case_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_default_attribution_setting_id" ON "ads"."conversion_datasets" ("default_attribution_setting_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_status_concept_id" ON "ads"."conversion_datasets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_created_by_user_id" ON "ads"."conversion_datasets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_updated_by_user_id" ON "ads"."conversion_datasets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_datasets_tenant_status" ON "ads"."conversion_datasets" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_conversion_datasets_account_code" ON "ads"."conversion_datasets" ("ad_account_id", "code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_conversion_datasets_external" ON "ads"."conversion_datasets" ("ad_account_id", "external_dataset_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_conversion_dataset_id" ON "ads"."dataset_connections" ("conversion_dataset_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_platform_connection_id" ON "ads"."dataset_connections" ("platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_tracking_pixel_id" ON "ads"."dataset_connections" ("tracking_pixel_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_connection_type_concept_id" ON "ads"."dataset_connections" ("connection_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_external_connection_id" ON "ads"."dataset_connections" ("external_connection_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_test_event_code_secret_id" ON "ads"."dataset_connections" ("test_event_code_secret_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_status_concept_id" ON "ads"."dataset_connections" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_created_by_user_id" ON "ads"."dataset_connections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_connections_updated_by_user_id" ON "ads"."dataset_connections" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_dataset_connections_dataset_type" ON "ads"."dataset_connections" ("conversion_dataset_id", "connection_type_concept_id", "platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_tenant_id" ON "ads"."server_conversion_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_conversion_dataset_id" ON "ads"."server_conversion_events" ("conversion_dataset_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_event_id" ON "ads"."server_conversion_events" ("event_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_action_source_concept_id" ON "ads"."server_conversion_events" ("action_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_external_order_id" ON "ads"."server_conversion_events" ("external_order_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_payment_transaction_id" ON "ads"."server_conversion_events" ("payment_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_crm_lead_id" ON "ads"."server_conversion_events" ("crm_lead_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_crm_opportunity_id" ON "ads"."server_conversion_events" ("crm_opportunity_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_consent_directive_id" ON "ads"."server_conversion_events" ("consent_directive_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_processing_status_concept_id" ON "ads"."server_conversion_events" ("processing_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_blocked_reason_concept_id" ON "ads"."server_conversion_events" ("blocked_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_tenant_created" ON "ads"."server_conversion_events" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_server_conversion_events_created_at" ON "ads"."server_conversion_events" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_server_conversion_events_dataset_event" ON "ads"."server_conversion_events" ("conversion_dataset_id", "event_name", "event_id");

CREATE INDEX IF NOT EXISTS "ix_server_conversion_events_order" ON "ads"."server_conversion_events" ("tenant_id", "external_order_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_user_data_server_conversion_event_id" ON "ads"."conversion_event_user_data" ("server_conversion_event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_user_data_click_id" ON "ads"."conversion_event_user_data" ("click_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_user_data_browser_id" ON "ads"."conversion_event_user_data" ("browser_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_conversion_event_user_data_event" ON "ads"."conversion_event_user_data" ("server_conversion_event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_custom_data_server_conversion_event_id" ON "ads"."conversion_event_custom_data" ("server_conversion_event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_custom_data_order_id" ON "ads"."conversion_event_custom_data" ("order_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_conversion_event_custom_data_event" ON "ads"."conversion_event_custom_data" ("server_conversion_event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_delivery_attempts_server_conversio_755102a2" ON "ads"."conversion_event_delivery_attempts" ("server_conversion_event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_delivery_attempts_platform_connection_id" ON "ads"."conversion_event_delivery_attempts" ("platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_delivery_attempts_result_concept_id" ON "ads"."conversion_event_delivery_attempts" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_delivery_attempts_external_trace_id" ON "ads"."conversion_event_delivery_attempts" ("external_trace_id");

CREATE INDEX IF NOT EXISTS "brin_conversion_event_delivery_attempts_created_at" ON "ads"."conversion_event_delivery_attempts" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_conversion_delivery_attempt_event_attempt" ON "ads"."conversion_event_delivery_attempts" ("server_conversion_event_id", "platform_connection_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_deduplication_conversion_dataset_id" ON "ads"."conversion_event_deduplication" ("conversion_dataset_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_deduplication_event_id" ON "ads"."conversion_event_deduplication" ("event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_deduplication_server_conversion_event_id" ON "ads"."conversion_event_deduplication" ("server_conversion_event_id");

CREATE INDEX IF NOT EXISTS "ix_conversion_event_deduplication_resolution_concept_id" ON "ads"."conversion_event_deduplication" ("resolution_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_conversion_event_dedup_key" ON "ads"."conversion_event_deduplication" ("conversion_dataset_id", "event_name", "event_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_quality_snapshots_conversion_dataset_id" ON "ads"."dataset_quality_snapshots" ("conversion_dataset_id");

CREATE INDEX IF NOT EXISTS "ix_dataset_quality_snapshots_status_concept_id" ON "ads"."dataset_quality_snapshots" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_dataset_quality_snapshots_created_at" ON "ads"."dataset_quality_snapshots" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_lead_forms_tenant_id" ON "ads"."lead_forms" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_ad_account_id" ON "ads"."lead_forms" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_ad_identity_asset_id" ON "ads"."lead_forms" ("ad_identity_asset_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_external_form_id" ON "ads"."lead_forms" ("external_form_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_form_type_concept_id" ON "ads"."lead_forms" ("form_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_destination_crm_pipeline_id" ON "ads"."lead_forms" ("destination_crm_pipeline_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_status_concept_id" ON "ads"."lead_forms" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_created_by_user_id" ON "ads"."lead_forms" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_updated_by_user_id" ON "ads"."lead_forms" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lead_forms_tenant_status" ON "ads"."lead_forms" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lead_forms_account_code" ON "ads"."lead_forms" ("ad_account_id", "code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lead_forms_external" ON "ads"."lead_forms" ("ad_account_id", "external_form_id");

CREATE INDEX IF NOT EXISTS "ix_lead_form_questions_lead_form_id" ON "ads"."lead_form_questions" ("lead_form_id");

CREATE INDEX IF NOT EXISTS "ix_lead_form_questions_question_type_concept_id" ON "ads"."lead_form_questions" ("question_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lead_form_questions_status_concept_id" ON "ads"."lead_form_questions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lead_form_questions_created_by_user_id" ON "ads"."lead_form_questions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lead_form_questions_updated_by_user_id" ON "ads"."lead_form_questions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lead_form_questions_form_key" ON "ads"."lead_form_questions" ("lead_form_id", "question_key");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_tenant_id" ON "ads"."lead_submissions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_lead_form_id" ON "ads"."lead_submissions" ("lead_form_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_ad_id" ON "ads"."lead_submissions" ("ad_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_ad_set_id" ON "ads"."lead_submissions" ("ad_set_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_campaign_id" ON "ads"."lead_submissions" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_external_lead_id" ON "ads"."lead_submissions" ("external_lead_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_crm_lead_id" ON "ads"."lead_submissions" ("crm_lead_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_consent_directive_id" ON "ads"."lead_submissions" ("consent_directive_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_processing_status_concept_id" ON "ads"."lead_submissions" ("processing_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_tenant_created" ON "ads"."lead_submissions" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_lead_submissions_created_at" ON "ads"."lead_submissions" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lead_submissions_form_external" ON "ads"."lead_submissions" ("lead_form_id", "external_lead_id");

CREATE INDEX IF NOT EXISTS "ix_lead_submissions_tenant_submitted" ON "ads"."lead_submissions" ("tenant_id", "submitted_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_lead_answers_lead_submission_id" ON "ads"."lead_answers" ("lead_submission_id");

CREATE INDEX IF NOT EXISTS "ix_lead_answers_lead_form_question_id" ON "ads"."lead_answers" ("lead_form_question_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lead_answers_submission_question" ON "ads"."lead_answers" ("lead_submission_id", "lead_form_question_id");

CREATE INDEX IF NOT EXISTS "ix_lead_delivery_events_lead_submission_id" ON "ads"."lead_delivery_events" ("lead_submission_id");

CREATE INDEX IF NOT EXISTS "ix_lead_delivery_events_destination_type_concept_id" ON "ads"."lead_delivery_events" ("destination_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lead_delivery_events_result_concept_id" ON "ads"."lead_delivery_events" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "brin_lead_delivery_events_created_at" ON "ads"."lead_delivery_events" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_lead_delivery_submission_attempt" ON "ads"."lead_delivery_events" ("lead_submission_id", "destination_type_concept_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "ix_insight_metric_definitions_platform_concept_id" ON "ads"."insight_metric_definitions" ("platform_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_metric_definitions_data_type_concept_id" ON "ads"."insight_metric_definitions" ("data_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_metric_definitions_aggregation_concept_id" ON "ads"."insight_metric_definitions" ("aggregation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_metric_definitions_state_concept_id" ON "ads"."insight_metric_definitions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_metric_definitions_created_by_user_id" ON "ads"."insight_metric_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insight_metric_definitions_updated_by_user_id" ON "ads"."insight_metric_definitions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_insight_metric_definitions_platform_code" ON "ads"."insight_metric_definitions" ("platform_concept_id", "metric_code");

CREATE INDEX IF NOT EXISTS "ix_insight_breakdown_definitions_platform_concept_id" ON "ads"."insight_breakdown_definitions" ("platform_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_breakdown_definitions_state_concept_id" ON "ads"."insight_breakdown_definitions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_breakdown_definitions_created_by_user_id" ON "ads"."insight_breakdown_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_insight_breakdown_definitions_updated_by_user_id" ON "ads"."insight_breakdown_definitions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_insight_breakdown_platform_code" ON "ads"."insight_breakdown_definitions" ("platform_concept_id", "breakdown_code");

CREATE INDEX IF NOT EXISTS "ix_insight_query_runs_tenant_id" ON "ads"."insight_query_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_insight_query_runs_ad_account_id" ON "ads"."insight_query_runs" ("ad_account_id");

CREATE INDEX IF NOT EXISTS "ix_insight_query_runs_platform_connection_id" ON "ads"."insight_query_runs" ("platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_insight_query_runs_object_level_concept_id" ON "ads"."insight_query_runs" ("object_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_query_runs_status_concept_id" ON "ads"."insight_query_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_query_runs_external_report_id" ON "ads"."insight_query_runs" ("external_report_id");

CREATE INDEX IF NOT EXISTS "ix_insight_query_runs_tenant_status" ON "ads"."insight_query_runs" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_insight_query_runs_created_at" ON "ads"."insight_query_runs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_insight_fact_rows_insight_query_run_id" ON "ads"."insight_fact_rows" ("insight_query_run_id");

CREATE INDEX IF NOT EXISTS "ix_insight_fact_rows_object_type_concept_id" ON "ads"."insight_fact_rows" ("object_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_insight_fact_rows_external_object_id" ON "ads"."insight_fact_rows" ("external_object_id");

CREATE INDEX IF NOT EXISTS "ix_insight_fact_rows_campaign_id" ON "ads"."insight_fact_rows" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_insight_fact_rows_ad_set_id" ON "ads"."insight_fact_rows" ("ad_set_id");

CREATE INDEX IF NOT EXISTS "ix_insight_fact_rows_ad_id" ON "ads"."insight_fact_rows" ("ad_id");

CREATE INDEX IF NOT EXISTS "brin_insight_fact_rows_created_at" ON "ads"."insight_fact_rows" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_insight_fact_rows_query_date" ON "ads"."insight_fact_rows" ("insight_query_run_id", "fact_date", "external_object_id");

CREATE INDEX IF NOT EXISTS "ix_ad_review_events_ad_id" ON "ads"."ad_review_events" ("ad_id");

CREATE INDEX IF NOT EXISTS "ix_ad_review_events_review_event_type_concept_id" ON "ads"."ad_review_events" ("review_event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_review_events_review_status_concept_id" ON "ads"."ad_review_events" ("review_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_review_events_external_review_id" ON "ads"."ad_review_events" ("external_review_id");

CREATE INDEX IF NOT EXISTS "brin_ad_review_events_occurred_at" ON "ads"."ad_review_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_policy_violations_ad_id" ON "ads"."ad_policy_violations" ("ad_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_violations_ad_review_event_id" ON "ads"."ad_policy_violations" ("ad_review_event_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_violations_policy_category_concept_id" ON "ads"."ad_policy_violations" ("policy_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_violations_severity_concept_id" ON "ads"."ad_policy_violations" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_violations_status_concept_id" ON "ads"."ad_policy_violations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_violations_created_by_user_id" ON "ads"."ad_policy_violations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_violations_updated_by_user_id" ON "ads"."ad_policy_violations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_appeals_ad_policy_violation_id" ON "ads"."ad_policy_appeals" ("ad_policy_violation_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_appeals_submitted_by_user_id" ON "ads"."ad_policy_appeals" ("submitted_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_appeals_evidence_file_id" ON "ads"."ad_policy_appeals" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_appeals_status_concept_id" ON "ads"."ad_policy_appeals" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_appeals_external_appeal_id" ON "ads"."ad_policy_appeals" ("external_appeal_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_appeals_created_by_user_id" ON "ads"."ad_policy_appeals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_policy_appeals_updated_by_user_id" ON "ads"."ad_policy_appeals" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_adset_learning_snapshots_ad_set_id" ON "ads"."adset_learning_snapshots" ("ad_set_id");

CREATE INDEX IF NOT EXISTS "ix_adset_learning_snapshots_learning_status_concept_id" ON "ads"."adset_learning_snapshots" ("learning_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adset_learning_snapshots_limited_reason_concept_id" ON "ads"."adset_learning_snapshots" ("limited_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_adset_learning_snapshots_created_at" ON "ads"."adset_learning_snapshots" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_tenant_id" ON "ads"."ad_event_data_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_jurisdiction_concept_id" ON "ads"."ad_event_data_policies" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_purpose_of_use_concept_id" ON "ads"."ad_event_data_policies" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_consent_scope_concept_id" ON "ads"."ad_event_data_policies" ("consent_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_default_action_concept_id" ON "ads"."ad_event_data_policies" ("default_action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_state_concept_id" ON "ads"."ad_event_data_policies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_created_by_user_id" ON "ads"."ad_event_data_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_updated_by_user_id" ON "ads"."ad_event_data_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_data_policies_tenant_created" ON "ads"."ad_event_data_policies" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_ad_event_data_policies_tenant_code" ON "ads"."ad_event_data_policies" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_ad_event_field_rules_ad_event_data_policy_id" ON "ads"."ad_event_field_rules" ("ad_event_data_policy_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_field_rules_action_concept_id" ON "ads"."ad_event_field_rules" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_field_rules_transformation_concept_id" ON "ads"."ad_event_field_rules" ("transformation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_field_rules_state_concept_id" ON "ads"."ad_event_field_rules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_field_rules_created_by_user_id" ON "ads"."ad_event_field_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_ad_event_field_rules_updated_by_user_id" ON "ads"."ad_event_field_rules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_ad_event_field_rules_policy_event_field" ON "ads"."ad_event_field_rules" ("ad_event_data_policy_id", "event_name_pattern", "field_path");

CREATE INDEX IF NOT EXISTS "ix_blocked_ad_events_tenant_id" ON "ads"."blocked_ad_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_blocked_ad_events_ad_event_data_policy_id" ON "ads"."blocked_ad_events" ("ad_event_data_policy_id");

CREATE INDEX IF NOT EXISTS "ix_blocked_ad_events_reason_concept_id" ON "ads"."blocked_ad_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_blocked_ad_events_review_status_concept_id" ON "ads"."blocked_ad_events" ("review_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_blocked_ad_events_tenant_created" ON "ads"."blocked_ad_events" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_blocked_ad_events_created_at" ON "ads"."blocked_ad_events" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_external_ad_object_snapshots_platform_connection_id" ON "ads"."external_ad_object_snapshots" ("platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_external_ad_object_snapshots_object_type_concept_id" ON "ads"."external_ad_object_snapshots" ("object_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_external_ad_object_snapshots_external_object_id" ON "ads"."external_ad_object_snapshots" ("external_object_id");

CREATE INDEX IF NOT EXISTS "brin_external_ad_object_snapshots_created_at" ON "ads"."external_ad_object_snapshots" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_external_ad_snapshots_version" ON "ads"."external_ad_object_snapshots" ("platform_connection_id", "object_type_concept_id", "external_object_id", "external_updated_at");

CREATE INDEX IF NOT EXISTS "ix_ad_sync_runs_platform_connection_id" ON "ads"."ad_sync_runs" ("platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sync_runs_sync_direction_concept_id" ON "ads"."ad_sync_runs" ("sync_direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sync_runs_object_type_concept_id" ON "ads"."ad_sync_runs" ("object_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sync_runs_status_concept_id" ON "ads"."ad_sync_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_ad_sync_runs_created_at" ON "ads"."ad_sync_runs" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_ad_sync_checkpoints_platform_connection_id" ON "ads"."ad_sync_checkpoints" ("platform_connection_id");

CREATE INDEX IF NOT EXISTS "ix_ad_sync_checkpoints_object_type_concept_id" ON "ads"."ad_sync_checkpoints" ("object_type_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_ad_sync_checkpoints_connection_object_key" ON "ads"."ad_sync_checkpoints" ("platform_connection_id", "object_type_concept_id", "checkpoint_key");
