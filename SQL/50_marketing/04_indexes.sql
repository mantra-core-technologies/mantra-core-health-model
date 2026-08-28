-- SALUD v4.0.10 · módulo 50 · schema marketing
-- Generado de diagram_50_marketing.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_segments_code" ON "marketing"."segments" ("code");

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

CREATE UNIQUE INDEX IF NOT EXISTS "uq_marketing_campaigns_code" ON "marketing"."marketing_campaigns" ("code");

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

CREATE UNIQUE INDEX IF NOT EXISTS "uq_journeys_code" ON "marketing"."journeys" ("code");

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
