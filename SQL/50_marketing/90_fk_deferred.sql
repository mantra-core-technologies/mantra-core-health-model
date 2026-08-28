-- SALUD v4.0.10 · módulo 50 · schema marketing
-- Generado de diagram_50_marketing.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "marketing"."segments"
        ADD CONSTRAINT "fk_segments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."segments"
        ADD CONSTRAINT "fk_segments_segment_type_concept_id" FOREIGN KEY ("segment_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: read_models.read_model_definitions (requiere schema read_models)
DO $$ BEGIN
    ALTER TABLE "marketing"."segments"
        ADD CONSTRAINT "fk_segments_source_read_model_id" FOREIGN KEY ("source_read_model_id")
        REFERENCES "read_models"."read_model_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."segments"
        ADD CONSTRAINT "fk_segments_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."segments"
        ADD CONSTRAINT "fk_segments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."segments"
        ADD CONSTRAINT "fk_segments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."segment_members"
        ADD CONSTRAINT "fk_segment_members_member_type_concept_id" FOREIGN KEY ("member_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."segment_members"
        ADD CONSTRAINT "fk_segment_members_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."segment_members"
        ADD CONSTRAINT "fk_segment_members_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."segment_members"
        ADD CONSTRAINT "fk_segment_members_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_campaign_type_concept_id" FOREIGN KEY ("campaign_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_objective_concept_id" FOREIGN KEY ("objective_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: promotions.promotions (requiere schema promotions)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_promotion_id" FOREIGN KEY ("promotion_id")
        REFERENCES "promotions"."promotions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_governance_scope_concept_id" FOREIGN KEY ("governance_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_published_by_user_id" FOREIGN KEY ("published_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_campaigns"
        ADD CONSTRAINT "fk_marketing_campaigns_cancelled_by_user_id" FOREIGN KEY ("cancelled_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.campaigns (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_members"
        ADD CONSTRAINT "fk_campaign_members_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_members"
        ADD CONSTRAINT "fk_campaign_members_member_type_concept_id" FOREIGN KEY ("member_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_members"
        ADD CONSTRAINT "fk_campaign_members_member_status_concept_id" FOREIGN KEY ("member_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_members"
        ADD CONSTRAINT "fk_campaign_members_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_members"
        ADD CONSTRAINT "fk_campaign_members_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "marketing"."content_templates"
        ADD CONSTRAINT "fk_content_templates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."content_templates"
        ADD CONSTRAINT "fk_content_templates_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."content_templates"
        ADD CONSTRAINT "fk_content_templates_language_concept_id" FOREIGN KEY ("language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.message_templates (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "marketing"."content_templates"
        ADD CONSTRAINT "fk_content_templates_messaging_template_id" FOREIGN KEY ("messaging_template_id")
        REFERENCES "messaging"."message_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."content_templates"
        ADD CONSTRAINT "fk_content_templates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."content_templates"
        ADD CONSTRAINT "fk_content_templates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."content_templates"
        ADD CONSTRAINT "fk_content_templates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "marketing"."journeys"
        ADD CONSTRAINT "fk_journeys_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journeys"
        ADD CONSTRAINT "fk_journeys_entry_trigger_concept_id" FOREIGN KEY ("entry_trigger_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journeys"
        ADD CONSTRAINT "fk_journeys_goal_metric_concept_id" FOREIGN KEY ("goal_metric_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journeys"
        ADD CONSTRAINT "fk_journeys_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."journeys"
        ADD CONSTRAINT "fk_journeys_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."journeys"
        ADD CONSTRAINT "fk_journeys_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_steps"
        ADD CONSTRAINT "fk_journey_steps_step_type_concept_id" FOREIGN KEY ("step_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_steps"
        ADD CONSTRAINT "fk_journey_steps_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_steps"
        ADD CONSTRAINT "fk_journey_steps_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_steps"
        ADD CONSTRAINT "fk_journey_steps_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_enrollments"
        ADD CONSTRAINT "fk_journey_enrollments_member_type_concept_id" FOREIGN KEY ("member_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_enrollments"
        ADD CONSTRAINT "fk_journey_enrollments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_enrollments"
        ADD CONSTRAINT "fk_journey_enrollments_exit_reason_concept_id" FOREIGN KEY ("exit_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_enrollments"
        ADD CONSTRAINT "fk_journey_enrollments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."journey_enrollments"
        ADD CONSTRAINT "fk_journey_enrollments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.campaigns (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "marketing"."tracked_links"
        ADD CONSTRAINT "fk_tracked_links_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."tracked_links"
        ADD CONSTRAINT "fk_tracked_links_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."tracked_links"
        ADD CONSTRAINT "fk_tracked_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."tracked_links"
        ADD CONSTRAINT "fk_tracked_links_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.campaigns (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_member_type_concept_id" FOREIGN KEY ("member_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_touch_type_concept_id" FOREIGN KEY ("touch_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.notification_requests (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_notification_request_id" FOREIGN KEY ("notification_request_id")
        REFERENCES "messaging"."notification_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.notification_deliveries (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_notification_delivery_id" FOREIGN KEY ("notification_delivery_id")
        REFERENCES "messaging"."notification_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: tracking.tracking_events (requiere schema tracking)
DO $$ BEGIN
    ALTER TABLE "marketing"."marketing_touchpoints"
        ADD CONSTRAINT "fk_marketing_touchpoints_tracking_event_id" FOREIGN KEY ("tracking_event_id")
        REFERENCES "tracking"."tracking_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."attribution_touches"
        ADD CONSTRAINT "fk_attribution_touches_attribution_model_concept_id" FOREIGN KEY ("attribution_model_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."attribution_touches"
        ADD CONSTRAINT "fk_attribution_touches_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."attribution_touches"
        ADD CONSTRAINT "fk_attribution_touches_position_concept_id" FOREIGN KEY ("position_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."attribution_touches"
        ADD CONSTRAINT "fk_attribution_touches_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."attribution_touches"
        ADD CONSTRAINT "fk_attribution_touches_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatches"
        ADD CONSTRAINT "fk_campaign_dispatches_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.campaigns (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatches"
        ADD CONSTRAINT "fk_campaign_dispatches_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatches"
        ADD CONSTRAINT "fk_campaign_dispatches_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatches"
        ADD CONSTRAINT "fk_campaign_dispatches_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatches"
        ADD CONSTRAINT "fk_campaign_dispatches_authorized_by_user_id" FOREIGN KEY ("authorized_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatches"
        ADD CONSTRAINT "fk_campaign_dispatches_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatches"
        ADD CONSTRAINT "fk_campaign_dispatches_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_member_type_concept_id" FOREIGN KEY ("member_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.contact_channel_endpoints (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_recipient_endpoint_id" FOREIGN KEY ("recipient_endpoint_id")
        REFERENCES "crm"."contact_channel_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_recipient_user_id" FOREIGN KEY ("recipient_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.message_channels (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_language_concept_id" FOREIGN KEY ("language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: consent.consents (requiere schema consent)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_consent_id" FOREIGN KEY ("consent_id")
        REFERENCES "consent"."consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_consent_status_concept_id" FOREIGN KEY ("consent_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_eligibility_status_concept_id" FOREIGN KEY ("eligibility_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_suppression_reason_concept_id" FOREIGN KEY ("suppression_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.notification_requests (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_notification_request_id" FOREIGN KEY ("notification_request_id")
        REFERENCES "messaging"."notification_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.notification_deliveries (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_current_delivery_id" FOREIGN KEY ("current_delivery_id")
        REFERENCES "messaging"."notification_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_current_status_concept_id" FOREIGN KEY ("current_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_dispatch_recipients"
        ADD CONSTRAINT "fk_campaign_dispatch_recipients_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: ads.campaigns (requiere schema ads)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_campaign_id" FOREIGN KEY ("campaign_id")
        REFERENCES "ads"."campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_schedule_type_concept_id" FOREIGN KEY ("schedule_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_missed_run_policy_concept_id" FOREIGN KEY ("missed_run_policy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_overlap_policy_concept_id" FOREIGN KEY ("overlap_policy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_authorized_by_user_id" FOREIGN KEY ("authorized_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "marketing"."campaign_schedules"
        ADD CONSTRAINT "fk_campaign_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
