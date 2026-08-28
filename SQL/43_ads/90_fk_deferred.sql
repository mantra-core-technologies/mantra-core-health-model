-- SALUD v4.0.10 · módulo 43 · schema ads
-- Generado de diagram_43_ads.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   server_conversion_events.consent_directive_id
--   lead_submissions.consent_directive_id


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."business_managers"
        ADD CONSTRAINT "fk_business_managers_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."business_managers"
        ADD CONSTRAINT "fk_business_managers_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."business_managers"
        ADD CONSTRAINT "fk_business_managers_vertical_concept_id" FOREIGN KEY ("vertical_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."business_managers"
        ADD CONSTRAINT "fk_business_managers_primary_country_concept_id" FOREIGN KEY ("primary_country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."business_managers"
        ADD CONSTRAINT "fk_business_managers_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."business_managers"
        ADD CONSTRAINT "fk_business_managers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."business_managers"
        ADD CONSTRAINT "fk_business_managers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_partners"
        ADD CONSTRAINT "fk_ad_partners_partner_type_concept_id" FOREIGN KEY ("partner_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_partners"
        ADD CONSTRAINT "fk_ad_partners_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_partners"
        ADD CONSTRAINT "fk_ad_partners_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_partners"
        ADD CONSTRAINT "fk_ad_partners_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_partners"
        ADD CONSTRAINT "fk_ad_partners_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."partner_relationships"
        ADD CONSTRAINT "fk_partner_relationships_relationship_type_concept_id" FOREIGN KEY ("relationship_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."partner_relationships"
        ADD CONSTRAINT "fk_partner_relationships_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."partner_relationships"
        ADD CONSTRAINT "fk_partner_relationships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."partner_relationships"
        ADD CONSTRAINT "fk_partner_relationships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_accounts"
        ADD CONSTRAINT "fk_ad_accounts_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_accounts"
        ADD CONSTRAINT "fk_ad_accounts_account_status_concept_id" FOREIGN KEY ("account_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_methods (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_accounts"
        ADD CONSTRAINT "fk_ad_accounts_funding_payment_method_id" FOREIGN KEY ("funding_payment_method_id")
        REFERENCES "payments"."payment_methods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_accounts"
        ADD CONSTRAINT "fk_ad_accounts_disable_reason_concept_id" FOREIGN KEY ("disable_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_accounts"
        ADD CONSTRAINT "fk_ad_accounts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_accounts"
        ADD CONSTRAINT "fk_ad_accounts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_account_users"
        ADD CONSTRAINT "fk_ad_account_users_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_account_users"
        ADD CONSTRAINT "fk_ad_account_users_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_account_users"
        ADD CONSTRAINT "fk_ad_account_users_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_account_users"
        ADD CONSTRAINT "fk_ad_account_users_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_account_users"
        ADD CONSTRAINT "fk_ad_account_users_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_objective_concept_id" FOREIGN KEY ("objective_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_buying_type_concept_id" FOREIGN KEY ("buying_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_bid_strategy_concept_id" FOREIGN KEY ("bid_strategy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_effective_status_concept_id" FOREIGN KEY ("effective_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."campaigns"
        ADD CONSTRAINT "fk_campaigns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_optimization_goal_concept_id" FOREIGN KEY ("optimization_goal_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_billing_event_concept_id" FOREIGN KEY ("billing_event_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_bid_strategy_concept_id" FOREIGN KEY ("bid_strategy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_pacing_type_concept_id" FOREIGN KEY ("pacing_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_effective_status_concept_id" FOREIGN KEY ("effective_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sets"
        ADD CONSTRAINT "fk_ad_sets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ads"
        ADD CONSTRAINT "fk_ads_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ads"
        ADD CONSTRAINT "fk_ads_effective_status_concept_id" FOREIGN KEY ("effective_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ads"
        ADD CONSTRAINT "fk_ads_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ads"
        ADD CONSTRAINT "fk_ads_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_creatives"
        ADD CONSTRAINT "fk_ad_creatives_format_concept_id" FOREIGN KEY ("format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_creatives"
        ADD CONSTRAINT "fk_ad_creatives_call_to_action_concept_id" FOREIGN KEY ("call_to_action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_creatives"
        ADD CONSTRAINT "fk_ad_creatives_primary_media_file_id" FOREIGN KEY ("primary_media_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_creatives"
        ADD CONSTRAINT "fk_ad_creatives_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_creatives"
        ADD CONSTRAINT "fk_ad_creatives_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_creatives"
        ADD CONSTRAINT "fk_ad_creatives_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."creative_assets"
        ADD CONSTRAINT "fk_creative_assets_asset_type_concept_id" FOREIGN KEY ("asset_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "ads"."creative_assets"
        ADD CONSTRAINT "fk_creative_assets_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."creative_assets"
        ADD CONSTRAINT "fk_creative_assets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."creative_assets"
        ADD CONSTRAINT "fk_creative_assets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_audience_type_concept_id" FOREIGN KEY ("audience_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_subtype_concept_id" FOREIGN KEY ("subtype_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_audiences"
        ADD CONSTRAINT "fk_custom_audiences_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."targeting_specs"
        ADD CONSTRAINT "fk_targeting_specs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."targeting_specs"
        ADD CONSTRAINT "fk_targeting_specs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_placements"
        ADD CONSTRAINT "fk_ad_placements_platform_concept_id" FOREIGN KEY ("platform_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_placements"
        ADD CONSTRAINT "fk_ad_placements_position_concept_id" FOREIGN KEY ("position_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_placements"
        ADD CONSTRAINT "fk_ad_placements_device_concept_id" FOREIGN KEY ("device_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_placements"
        ADD CONSTRAINT "fk_ad_placements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_placements"
        ADD CONSTRAINT "fk_ad_placements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."tracking_pixels"
        ADD CONSTRAINT "fk_tracking_pixels_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."tracking_pixels"
        ADD CONSTRAINT "fk_tracking_pixels_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."tracking_pixels"
        ADD CONSTRAINT "fk_tracking_pixels_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."delivery_status_snapshots"
        ADD CONSTRAINT "fk_delivery_status_snapshots_entity_type_concept_id" FOREIGN KEY ("entity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."delivery_status_snapshots"
        ADD CONSTRAINT "fk_delivery_status_snapshots_effective_status_concept_id" FOREIGN KEY ("effective_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."delivery_status_snapshots"
        ADD CONSTRAINT "fk_delivery_status_snapshots_review_status_concept_id" FOREIGN KEY ("review_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."delivery_status_snapshots"
        ADD CONSTRAINT "fk_delivery_status_snapshots_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insights_daily"
        ADD CONSTRAINT "fk_insights_daily_entity_type_concept_id" FOREIGN KEY ("entity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insights_daily"
        ADD CONSTRAINT "fk_insights_daily_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insights_daily"
        ADD CONSTRAINT "fk_insights_daily_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."insights_daily"
        ADD CONSTRAINT "fk_insights_daily_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."attribution_settings"
        ADD CONSTRAINT "fk_attribution_settings_attribution_model_concept_id" FOREIGN KEY ("attribution_model_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."attribution_settings"
        ADD CONSTRAINT "fk_attribution_settings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."attribution_settings"
        ADD CONSTRAINT "fk_attribution_settings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."pixel_events"
        ADD CONSTRAINT "fk_pixel_events_event_source_concept_id" FOREIGN KEY ("event_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."pixel_events"
        ADD CONSTRAINT "fk_pixel_events_action_source_concept_id" FOREIGN KEY ("action_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."pixel_events"
        ADD CONSTRAINT "fk_pixel_events_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."pixel_events"
        ADD CONSTRAINT "fk_pixel_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_attributions"
        ADD CONSTRAINT "fk_conversion_attributions_attribution_type_concept_id" FOREIGN KEY ("attribution_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_attributions"
        ADD CONSTRAINT "fk_conversion_attributions_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_attributions"
        ADD CONSTRAINT "fk_conversion_attributions_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."budget_schedules"
        ADD CONSTRAINT "fk_budget_schedules_entity_type_concept_id" FOREIGN KEY ("entity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."budget_schedules"
        ADD CONSTRAINT "fk_budget_schedules_budget_type_concept_id" FOREIGN KEY ("budget_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."budget_schedules"
        ADD CONSTRAINT "fk_budget_schedules_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."budget_schedules"
        ADD CONSTRAINT "fk_budget_schedules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."budget_schedules"
        ADD CONSTRAINT "fk_budget_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."budget_schedules"
        ADD CONSTRAINT "fk_budget_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_billing_events"
        ADD CONSTRAINT "fk_ad_billing_events_billing_event_type_concept_id" FOREIGN KEY ("billing_event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_billing_events"
        ADD CONSTRAINT "fk_ad_billing_events_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_billing_events"
        ADD CONSTRAINT "fk_ad_billing_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoices"
        ADD CONSTRAINT "fk_ad_invoices_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoices"
        ADD CONSTRAINT "fk_ad_invoices_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_intents (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoices"
        ADD CONSTRAINT "fk_ad_invoices_payment_intent_id" FOREIGN KEY ("payment_intent_id")
        REFERENCES "payments"."payment_intents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoices"
        ADD CONSTRAINT "fk_ad_invoices_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoices"
        ADD CONSTRAINT "fk_ad_invoices_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoice_lines"
        ADD CONSTRAINT "fk_ad_invoice_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_invoice_lines"
        ADD CONSTRAINT "fk_ad_invoice_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."product_catalogs"
        ADD CONSTRAINT "fk_product_catalogs_vertical_concept_id" FOREIGN KEY ("vertical_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."product_catalogs"
        ADD CONSTRAINT "fk_product_catalogs_default_currency_concept_id" FOREIGN KEY ("default_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."product_catalogs"
        ADD CONSTRAINT "fk_product_catalogs_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_catalogs"
        ADD CONSTRAINT "fk_product_catalogs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_catalogs"
        ADD CONSTRAINT "fk_product_catalogs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_feeds"
        ADD CONSTRAINT "fk_catalog_feeds_feed_source_concept_id" FOREIGN KEY ("feed_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_feeds"
        ADD CONSTRAINT "fk_catalog_feeds_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_feeds"
        ADD CONSTRAINT "fk_catalog_feeds_last_status_concept_id" FOREIGN KEY ("last_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_feeds"
        ADD CONSTRAINT "fk_catalog_feeds_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_feeds"
        ADD CONSTRAINT "fk_catalog_feeds_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_feeds"
        ADD CONSTRAINT "fk_catalog_feeds_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_availability_concept_id" FOREIGN KEY ("availability_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_condition_concept_id" FOREIGN KEY ("condition_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."catalog_products"
        ADD CONSTRAINT "fk_catalog_products_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."product_localizations"
        ADD CONSTRAINT "fk_product_localizations_language_concept_id" FOREIGN KEY ("language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."product_localizations"
        ADD CONSTRAINT "fk_product_localizations_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."product_localizations"
        ADD CONSTRAINT "fk_product_localizations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_localizations"
        ADD CONSTRAINT "fk_product_localizations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_localizations"
        ADD CONSTRAINT "fk_product_localizations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."product_sets"
        ADD CONSTRAINT "fk_product_sets_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_sets"
        ADD CONSTRAINT "fk_product_sets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_sets"
        ADD CONSTRAINT "fk_product_sets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_set_members"
        ADD CONSTRAINT "fk_product_set_members_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."product_set_members"
        ADD CONSTRAINT "fk_product_set_members_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_format_concept_id" FOREIGN KEY ("format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_call_to_action_concept_id" FOREIGN KEY ("call_to_action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."dynamic_ad_templates"
        ADD CONSTRAINT "fk_dynamic_ad_templates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."collection_ads"
        ADD CONSTRAINT "fk_collection_ads_layout_concept_id" FOREIGN KEY ("layout_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."collection_ads"
        ADD CONSTRAINT "fk_collection_ads_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."collection_ads"
        ADD CONSTRAINT "fk_collection_ads_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."collection_ads"
        ADD CONSTRAINT "fk_collection_ads_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."feed_run_logs"
        ADD CONSTRAINT "fk_feed_run_logs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."feed_run_logs"
        ADD CONSTRAINT "fk_feed_run_logs_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."saved_audiences"
        ADD CONSTRAINT "fk_saved_audiences_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."saved_audiences"
        ADD CONSTRAINT "fk_saved_audiences_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."saved_audiences"
        ADD CONSTRAINT "fk_saved_audiences_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_similarity_concept_id" FOREIGN KEY ("similarity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."lookalike_specs"
        ADD CONSTRAINT "fk_lookalike_specs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."automated_rules"
        ADD CONSTRAINT "fk_automated_rules_scope_concept_id" FOREIGN KEY ("scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."automated_rules"
        ADD CONSTRAINT "fk_automated_rules_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."automated_rules"
        ADD CONSTRAINT "fk_automated_rules_evaluation_schedule_concept_id" FOREIGN KEY ("evaluation_schedule_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."automated_rules"
        ADD CONSTRAINT "fk_automated_rules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."automated_rules"
        ADD CONSTRAINT "fk_automated_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."automated_rules"
        ADD CONSTRAINT "fk_automated_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."rule_executions"
        ADD CONSTRAINT "fk_rule_executions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."rule_executions"
        ADD CONSTRAINT "fk_rule_executions_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_experiments"
        ADD CONSTRAINT "fk_ad_experiments_experiment_type_concept_id" FOREIGN KEY ("experiment_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_experiments"
        ADD CONSTRAINT "fk_ad_experiments_objective_metric_concept_id" FOREIGN KEY ("objective_metric_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_experiments"
        ADD CONSTRAINT "fk_ad_experiments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_experiments"
        ADD CONSTRAINT "fk_ad_experiments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_experiments"
        ADD CONSTRAINT "fk_ad_experiments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."experiment_variants"
        ADD CONSTRAINT "fk_experiment_variants_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."experiment_variants"
        ADD CONSTRAINT "fk_experiment_variants_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_conversions"
        ADD CONSTRAINT "fk_custom_conversions_conversion_category_concept_id" FOREIGN KEY ("conversion_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_conversions"
        ADD CONSTRAINT "fk_custom_conversions_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_conversions"
        ADD CONSTRAINT "fk_custom_conversions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_conversions"
        ADD CONSTRAINT "fk_custom_conversions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."custom_conversions"
        ADD CONSTRAINT "fk_custom_conversions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_sets"
        ADD CONSTRAINT "fk_offline_conversion_sets_upload_source_concept_id" FOREIGN KEY ("upload_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_sets"
        ADD CONSTRAINT "fk_offline_conversion_sets_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_sets"
        ADD CONSTRAINT "fk_offline_conversion_sets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_sets"
        ADD CONSTRAINT "fk_offline_conversion_sets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_sets"
        ADD CONSTRAINT "fk_offline_conversion_sets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_events"
        ADD CONSTRAINT "fk_offline_conversion_events_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."offline_conversion_events"
        ADD CONSTRAINT "fk_offline_conversion_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."frequency_caps"
        ADD CONSTRAINT "fk_frequency_caps_scope_concept_id" FOREIGN KEY ("scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."frequency_caps"
        ADD CONSTRAINT "fk_frequency_caps_time_window_concept_id" FOREIGN KEY ("time_window_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."frequency_caps"
        ADD CONSTRAINT "fk_frequency_caps_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."frequency_caps"
        ADD CONSTRAINT "fk_frequency_caps_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."brand_lift_studies"
        ADD CONSTRAINT "fk_brand_lift_studies_metric_concept_id" FOREIGN KEY ("metric_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."brand_lift_studies"
        ADD CONSTRAINT "fk_brand_lift_studies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."brand_lift_studies"
        ADD CONSTRAINT "fk_brand_lift_studies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."brand_lift_studies"
        ADD CONSTRAINT "fk_brand_lift_studies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_platform_concept_id" FOREIGN KEY ("platform_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.provider_credentials (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_credential_id" FOREIGN KEY ("credential_id")
        REFERENCES "integrations"."provider_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.encryption_keys (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_webhook_verification_secret_id" FOREIGN KEY ("webhook_verification_secret_id")
        REFERENCES "system_ops"."encryption_keys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_platform_connections"
        ADD CONSTRAINT "fk_ad_platform_connections_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_assets"
        ADD CONSTRAINT "fk_ad_identity_assets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_assets"
        ADD CONSTRAINT "fk_ad_identity_assets_identity_type_concept_id" FOREIGN KEY ("identity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_assets"
        ADD CONSTRAINT "fk_ad_identity_assets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_assets"
        ADD CONSTRAINT "fk_ad_identity_assets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_assets"
        ADD CONSTRAINT "fk_ad_identity_assets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_asset_assignments"
        ADD CONSTRAINT "fk_ad_identity_asset_assignments_assignable_type_concept_id" FOREIGN KEY ("assignable_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_asset_assignments"
        ADD CONSTRAINT "fk_ad_identity_asset_assignments_assignment_role_concept_id" FOREIGN KEY ("assignment_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_asset_assignments"
        ADD CONSTRAINT "fk_ad_identity_asset_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_identity_asset_assignments"
        ADD CONSTRAINT "fk_ad_identity_asset_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_dataset_type_concept_id" FOREIGN KEY ("dataset_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_data_use_case_concept_id" FOREIGN KEY ("data_use_case_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_datasets"
        ADD CONSTRAINT "fk_conversion_datasets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_connection_type_concept_id" FOREIGN KEY ("connection_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.encryption_keys (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_test_event_code_secret_id" FOREIGN KEY ("test_event_code_secret_id")
        REFERENCES "system_ops"."encryption_keys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."dataset_connections"
        ADD CONSTRAINT "fk_dataset_connections_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_action_source_concept_id" FOREIGN KEY ("action_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.payment_transactions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_payment_transaction_id" FOREIGN KEY ("payment_transaction_id")
        REFERENCES "payments"."payment_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.leads (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_crm_lead_id" FOREIGN KEY ("crm_lead_id")
        REFERENCES "crm"."leads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.opportunities (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_crm_opportunity_id" FOREIGN KEY ("crm_opportunity_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_processing_status_concept_id" FOREIGN KEY ("processing_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."server_conversion_events"
        ADD CONSTRAINT "fk_server_conversion_events_blocked_reason_concept_id" FOREIGN KEY ("blocked_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_delivery_attempts"
        ADD CONSTRAINT "fk_conversion_event_delivery_attempts_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."conversion_event_deduplication"
        ADD CONSTRAINT "fk_conversion_event_deduplication_resolution_concept_id" FOREIGN KEY ("resolution_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."dataset_quality_snapshots"
        ADD CONSTRAINT "fk_dataset_quality_snapshots_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_form_type_concept_id" FOREIGN KEY ("form_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.pipelines (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_destination_crm_pipeline_id" FOREIGN KEY ("destination_crm_pipeline_id")
        REFERENCES "crm"."pipelines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_forms"
        ADD CONSTRAINT "fk_lead_forms_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_form_questions"
        ADD CONSTRAINT "fk_lead_form_questions_question_type_concept_id" FOREIGN KEY ("question_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_form_questions"
        ADD CONSTRAINT "fk_lead_form_questions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_form_questions"
        ADD CONSTRAINT "fk_lead_form_questions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_form_questions"
        ADD CONSTRAINT "fk_lead_form_questions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_submissions"
        ADD CONSTRAINT "fk_lead_submissions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.leads (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_submissions"
        ADD CONSTRAINT "fk_lead_submissions_crm_lead_id" FOREIGN KEY ("crm_lead_id")
        REFERENCES "crm"."leads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_submissions"
        ADD CONSTRAINT "fk_lead_submissions_processing_status_concept_id" FOREIGN KEY ("processing_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_delivery_events"
        ADD CONSTRAINT "fk_lead_delivery_events_destination_type_concept_id" FOREIGN KEY ("destination_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."lead_delivery_events"
        ADD CONSTRAINT "fk_lead_delivery_events_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_metric_definitions"
        ADD CONSTRAINT "fk_insight_metric_definitions_platform_concept_id" FOREIGN KEY ("platform_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_metric_definitions"
        ADD CONSTRAINT "fk_insight_metric_definitions_data_type_concept_id" FOREIGN KEY ("data_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_metric_definitions"
        ADD CONSTRAINT "fk_insight_metric_definitions_aggregation_concept_id" FOREIGN KEY ("aggregation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_metric_definitions"
        ADD CONSTRAINT "fk_insight_metric_definitions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_metric_definitions"
        ADD CONSTRAINT "fk_insight_metric_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_metric_definitions"
        ADD CONSTRAINT "fk_insight_metric_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_breakdown_definitions"
        ADD CONSTRAINT "fk_insight_breakdown_definitions_platform_concept_id" FOREIGN KEY ("platform_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_breakdown_definitions"
        ADD CONSTRAINT "fk_insight_breakdown_definitions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_breakdown_definitions"
        ADD CONSTRAINT "fk_insight_breakdown_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_breakdown_definitions"
        ADD CONSTRAINT "fk_insight_breakdown_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_query_runs"
        ADD CONSTRAINT "fk_insight_query_runs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_query_runs"
        ADD CONSTRAINT "fk_insight_query_runs_object_level_concept_id" FOREIGN KEY ("object_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_query_runs"
        ADD CONSTRAINT "fk_insight_query_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."insight_fact_rows"
        ADD CONSTRAINT "fk_insight_fact_rows_object_type_concept_id" FOREIGN KEY ("object_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_review_events"
        ADD CONSTRAINT "fk_ad_review_events_review_event_type_concept_id" FOREIGN KEY ("review_event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_review_events"
        ADD CONSTRAINT "fk_ad_review_events_review_status_concept_id" FOREIGN KEY ("review_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_violations"
        ADD CONSTRAINT "fk_ad_policy_violations_policy_category_concept_id" FOREIGN KEY ("policy_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_violations"
        ADD CONSTRAINT "fk_ad_policy_violations_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_violations"
        ADD CONSTRAINT "fk_ad_policy_violations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_violations"
        ADD CONSTRAINT "fk_ad_policy_violations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_violations"
        ADD CONSTRAINT "fk_ad_policy_violations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_appeals"
        ADD CONSTRAINT "fk_ad_policy_appeals_submitted_by_user_id" FOREIGN KEY ("submitted_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_appeals"
        ADD CONSTRAINT "fk_ad_policy_appeals_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_appeals"
        ADD CONSTRAINT "fk_ad_policy_appeals_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_appeals"
        ADD CONSTRAINT "fk_ad_policy_appeals_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_policy_appeals"
        ADD CONSTRAINT "fk_ad_policy_appeals_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."adset_learning_snapshots"
        ADD CONSTRAINT "fk_adset_learning_snapshots_learning_status_concept_id" FOREIGN KEY ("learning_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."adset_learning_snapshots"
        ADD CONSTRAINT "fk_adset_learning_snapshots_limited_reason_concept_id" FOREIGN KEY ("limited_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_consent_scope_concept_id" FOREIGN KEY ("consent_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_default_action_concept_id" FOREIGN KEY ("default_action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_data_policies"
        ADD CONSTRAINT "fk_ad_event_data_policies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_field_rules"
        ADD CONSTRAINT "fk_ad_event_field_rules_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_field_rules"
        ADD CONSTRAINT "fk_ad_event_field_rules_transformation_concept_id" FOREIGN KEY ("transformation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_field_rules"
        ADD CONSTRAINT "fk_ad_event_field_rules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_field_rules"
        ADD CONSTRAINT "fk_ad_event_field_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_event_field_rules"
        ADD CONSTRAINT "fk_ad_event_field_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "ads"."blocked_ad_events"
        ADD CONSTRAINT "fk_blocked_ad_events_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."blocked_ad_events"
        ADD CONSTRAINT "fk_blocked_ad_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."blocked_ad_events"
        ADD CONSTRAINT "fk_blocked_ad_events_review_status_concept_id" FOREIGN KEY ("review_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."external_ad_object_snapshots"
        ADD CONSTRAINT "fk_external_ad_object_snapshots_object_type_concept_id" FOREIGN KEY ("object_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sync_runs"
        ADD CONSTRAINT "fk_ad_sync_runs_sync_direction_concept_id" FOREIGN KEY ("sync_direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sync_runs"
        ADD CONSTRAINT "fk_ad_sync_runs_object_type_concept_id" FOREIGN KEY ("object_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sync_runs"
        ADD CONSTRAINT "fk_ad_sync_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "ads"."ad_sync_checkpoints"
        ADD CONSTRAINT "fk_ad_sync_checkpoints_object_type_concept_id" FOREIGN KEY ("object_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
