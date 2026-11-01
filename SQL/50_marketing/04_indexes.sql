-- SALUD v4.2.83 · módulo 50 · schema marketing
-- Generado de diagram_50_marketing.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_segments_tenant_id_code" ON "marketing"."segments" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_segments_tenant_id" ON "marketing"."segments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_segments_segment_type_concept_id" ON "marketing"."segments" ("segment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_segments_source_read_model_id" ON "marketing"."segments" ("source_read_model_id");

CREATE INDEX IF NOT EXISTS "ix_segments_state_concept_id" ON "marketing"."segments" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_segments_created_by_user_id" ON "marketing"."segments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_segments_updated_by_user_id" ON "marketing"."segments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_segments_tenant_id_state_concept_id" ON "marketing"."segments" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_segments_search" ON "marketing"."segments" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_segment_members_segment_id" ON "marketing"."segment_members" ("segment_id");

CREATE INDEX IF NOT EXISTS "ix_segment_members_member_type_concept_id" ON "marketing"."segment_members" ("member_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_segment_members_status_concept_id" ON "marketing"."segment_members" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_segment_members_created_by_user_id" ON "marketing"."segment_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_segment_members_updated_by_user_id" ON "marketing"."segment_members" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_marketing_campaigns_tenant_id_code" ON "marketing"."marketing_campaigns" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_tenant_id" ON "marketing"."marketing_campaigns" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_campaign_type_concept_id" ON "marketing"."marketing_campaigns" ("campaign_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_objective_concept_id" ON "marketing"."marketing_campaigns" ("objective_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_channel_concept_id" ON "marketing"."marketing_campaigns" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_segment_id" ON "marketing"."marketing_campaigns" ("segment_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_currency_concept_id" ON "marketing"."marketing_campaigns" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_promotion_id" ON "marketing"."marketing_campaigns" ("promotion_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_owner_user_id" ON "marketing"."marketing_campaigns" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_status_concept_id" ON "marketing"."marketing_campaigns" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_created_by_user_id" ON "marketing"."marketing_campaigns" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_updated_by_user_id" ON "marketing"."marketing_campaigns" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_campaigns_tenant_id_status_concept_id" ON "marketing"."marketing_campaigns" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_marketing_campaigns_search" ON "marketing"."marketing_campaigns" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_campaign_members_campaign_id" ON "marketing"."campaign_members" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_members_member_type_concept_id" ON "marketing"."campaign_members" ("member_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_members_member_status_concept_id" ON "marketing"."campaign_members" ("member_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_members_created_by_user_id" ON "marketing"."campaign_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_members_updated_by_user_id" ON "marketing"."campaign_members" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_tenant_id" ON "marketing"."content_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_channel_concept_id" ON "marketing"."content_templates" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_language_concept_id" ON "marketing"."content_templates" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_messaging_template_id" ON "marketing"."content_templates" ("messaging_template_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_status_concept_id" ON "marketing"."content_templates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_created_by_user_id" ON "marketing"."content_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_updated_by_user_id" ON "marketing"."content_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_content_templates_tenant_id_status_concept_id" ON "marketing"."content_templates" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_content_templates_messaging_template_id_version" ON "marketing"."content_templates" ("messaging_template_id", "version");

CREATE INDEX IF NOT EXISTS "gin_content_templates_search" ON "marketing"."content_templates" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_journeys_tenant_id_code" ON "marketing"."journeys" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_journeys_tenant_id" ON "marketing"."journeys" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_entry_trigger_concept_id" ON "marketing"."journeys" ("entry_trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_entry_segment_id" ON "marketing"."journeys" ("entry_segment_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_goal_metric_concept_id" ON "marketing"."journeys" ("goal_metric_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_state_concept_id" ON "marketing"."journeys" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_created_by_user_id" ON "marketing"."journeys" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_updated_by_user_id" ON "marketing"."journeys" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journeys_tenant_id_state_concept_id" ON "marketing"."journeys" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_journeys_search" ON "marketing"."journeys" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_journey_steps_journey_id" ON "marketing"."journey_steps" ("journey_id");

CREATE INDEX IF NOT EXISTS "ix_journey_steps_step_type_concept_id" ON "marketing"."journey_steps" ("step_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journey_steps_channel_concept_id" ON "marketing"."journey_steps" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journey_steps_content_template_id" ON "marketing"."journey_steps" ("content_template_id");

CREATE INDEX IF NOT EXISTS "ix_journey_steps_next_step_id" ON "marketing"."journey_steps" ("next_step_id");

CREATE INDEX IF NOT EXISTS "ix_journey_steps_branch_step_id" ON "marketing"."journey_steps" ("branch_step_id");

CREATE INDEX IF NOT EXISTS "ix_journey_steps_created_by_user_id" ON "marketing"."journey_steps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journey_steps_updated_by_user_id" ON "marketing"."journey_steps" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journey_enrollments_journey_id" ON "marketing"."journey_enrollments" ("journey_id");

CREATE INDEX IF NOT EXISTS "ix_journey_enrollments_member_type_concept_id" ON "marketing"."journey_enrollments" ("member_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journey_enrollments_current_step_id" ON "marketing"."journey_enrollments" ("current_step_id");

CREATE INDEX IF NOT EXISTS "ix_journey_enrollments_status_concept_id" ON "marketing"."journey_enrollments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journey_enrollments_exit_reason_concept_id" ON "marketing"."journey_enrollments" ("exit_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_journey_enrollments_created_by_user_id" ON "marketing"."journey_enrollments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_journey_enrollments_updated_by_user_id" ON "marketing"."journey_enrollments" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_tracked_links_code" ON "marketing"."tracked_links" ("code");

CREATE INDEX IF NOT EXISTS "ix_tracked_links_campaign_id" ON "marketing"."tracked_links" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_links_state_concept_id" ON "marketing"."tracked_links" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_links_created_by_user_id" ON "marketing"."tracked_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_links_updated_by_user_id" ON "marketing"."tracked_links" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_tracked_links_search" ON "marketing"."tracked_links" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_campaign_id" ON "marketing"."marketing_touchpoints" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_journey_id" ON "marketing"."marketing_touchpoints" ("journey_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_tracked_link_id" ON "marketing"."marketing_touchpoints" ("tracked_link_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_member_type_concept_id" ON "marketing"."marketing_touchpoints" ("member_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_touch_type_concept_id" ON "marketing"."marketing_touchpoints" ("touch_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_channel_concept_id" ON "marketing"."marketing_touchpoints" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_content_template_id" ON "marketing"."marketing_touchpoints" ("content_template_id");

CREATE INDEX IF NOT EXISTS "ix_marketing_touchpoints_recorded_by_user_id" ON "marketing"."marketing_touchpoints" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_marketing_touchpoints_recorded_at" ON "marketing"."marketing_touchpoints" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_attribution_touches_marketing_touchpoint_id" ON "marketing"."attribution_touches" ("marketing_touchpoint_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_touches_attribution_model_concept_id" ON "marketing"."attribution_touches" ("attribution_model_concept_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_touches_currency_concept_id" ON "marketing"."attribution_touches" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_touches_position_concept_id" ON "marketing"."attribution_touches" ("position_concept_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_touches_created_by_user_id" ON "marketing"."attribution_touches" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_attribution_touches_updated_by_user_id" ON "marketing"."attribution_touches" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_campaign_dispatches_idempotency_key" ON "marketing"."campaign_dispatches" ("idempotency_key");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_campaign_dispatches_schedule_id" ON "marketing"."campaign_dispatches" ("schedule_id", "occurrence_key");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_tenant_id" ON "marketing"."campaign_dispatches" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_campaign_id" ON "marketing"."campaign_dispatches" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_schedule_id" ON "marketing"."campaign_dispatches" ("schedule_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_journey_id" ON "marketing"."campaign_dispatches" ("journey_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_journey_step_id" ON "marketing"."campaign_dispatches" ("journey_step_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_status_concept_id" ON "marketing"."campaign_dispatches" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_source_concept_id" ON "marketing"."campaign_dispatches" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_content_template_id" ON "marketing"."campaign_dispatches" ("content_template_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_authorized_by_user_id" ON "marketing"."campaign_dispatches" ("authorized_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_created_by_user_id" ON "marketing"."campaign_dispatches" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatches_updated_by_user_id" ON "marketing"."campaign_dispatches" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_campaign_dispatch_recipients_dispatch_id" ON "marketing"."campaign_dispatch_recipients" ("dispatch_id", "member_type_concept_id", "member_ref_id", "channel_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_campaign_dispatch_recipients_idempotency_key" ON "marketing"."campaign_dispatch_recipients" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_dispatch_id" ON "marketing"."campaign_dispatch_recipients" ("dispatch_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_member_type_concept_id" ON "marketing"."campaign_dispatch_recipients" ("member_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_recipient_endpoint_id" ON "marketing"."campaign_dispatch_recipients" ("recipient_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_recipient_user_id" ON "marketing"."campaign_dispatch_recipients" ("recipient_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_channel_id" ON "marketing"."campaign_dispatch_recipients" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_language_concept_id" ON "marketing"."campaign_dispatch_recipients" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_consent_id" ON "marketing"."campaign_dispatch_recipients" ("consent_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_consent_status_concept_id" ON "marketing"."campaign_dispatch_recipients" ("consent_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_eligibility_status_concept_id" ON "marketing"."campaign_dispatch_recipients" ("eligibility_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_suppression_reason_concept_id" ON "marketing"."campaign_dispatch_recipients" ("suppression_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_notification_request_id" ON "marketing"."campaign_dispatch_recipients" ("notification_request_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_current_delivery_id" ON "marketing"."campaign_dispatch_recipients" ("current_delivery_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_current_status_concept_id" ON "marketing"."campaign_dispatch_recipients" ("current_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_created_by_user_id" ON "marketing"."campaign_dispatch_recipients" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_dispatch_recipients_updated_by_user_id" ON "marketing"."campaign_dispatch_recipients" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_campaign_schedules_campaign_id" ON "marketing"."campaign_schedules" ("campaign_id", "schedule_version");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_tenant_id" ON "marketing"."campaign_schedules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_campaign_id" ON "marketing"."campaign_schedules" ("campaign_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_journey_id" ON "marketing"."campaign_schedules" ("journey_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_schedule_type_concept_id" ON "marketing"."campaign_schedules" ("schedule_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_missed_run_policy_concept_id" ON "marketing"."campaign_schedules" ("missed_run_policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_overlap_policy_concept_id" ON "marketing"."campaign_schedules" ("overlap_policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_status_concept_id" ON "marketing"."campaign_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_authorized_by_user_id" ON "marketing"."campaign_schedules" ("authorized_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_created_by_user_id" ON "marketing"."campaign_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_campaign_schedules_updated_by_user_id" ON "marketing"."campaign_schedules" ("updated_by_user_id");

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
