-- SALUD v4.0.10 · módulo 35 · schema messaging
-- Generado de diagram_35_messaging.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."domain_events"
        ADD CONSTRAINT "fk_domain_events_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."domain_events"
        ADD CONSTRAINT "fk_domain_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."outbox_messages"
        ADD CONSTRAINT "fk_outbox_messages_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."outbox_messages"
        ADD CONSTRAINT "fk_outbox_messages_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."outbox_messages"
        ADD CONSTRAINT "fk_outbox_messages_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."outbox_messages"
        ADD CONSTRAINT "fk_outbox_messages_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_subscriptions"
        ADD CONSTRAINT "fk_event_subscriptions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_subscriptions"
        ADD CONSTRAINT "fk_event_subscriptions_delivery_mode_concept_id" FOREIGN KEY ("delivery_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_subscriptions"
        ADD CONSTRAINT "fk_event_subscriptions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_subscriptions"
        ADD CONSTRAINT "fk_event_subscriptions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_subscriptions"
        ADD CONSTRAINT "fk_event_subscriptions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: payments.subscriptions (requiere schema payments)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_deliveries"
        ADD CONSTRAINT "fk_event_deliveries_subscription_id" FOREIGN KEY ("subscription_id")
        REFERENCES "payments"."subscriptions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_deliveries"
        ADD CONSTRAINT "fk_event_deliveries_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."event_deliveries"
        ADD CONSTRAINT "fk_event_deliveries_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_queues"
        ADD CONSTRAINT "fk_message_queues_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_queues"
        ADD CONSTRAINT "fk_message_queues_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_queues"
        ADD CONSTRAINT "fk_message_queues_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."queued_jobs"
        ADD CONSTRAINT "fk_queued_jobs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."queued_jobs"
        ADD CONSTRAINT "fk_queued_jobs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."queued_jobs"
        ADD CONSTRAINT "fk_queued_jobs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."queued_jobs"
        ADD CONSTRAINT "fk_queued_jobs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."dead_letter_jobs"
        ADD CONSTRAINT "fk_dead_letter_jobs_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_recipient_user_id" FOREIGN KEY ("recipient_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: marketing.campaign_dispatch_recipients (requiere schema marketing)
DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_dispatch_recipient_id" FOREIGN KEY ("dispatch_recipient_id")
        REFERENCES "marketing"."campaign_dispatch_recipients" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_channels"
        ADD CONSTRAINT "fk_message_channels_channel_type_concept_id" FOREIGN KEY ("channel_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_channels"
        ADD CONSTRAINT "fk_message_channels_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_channels"
        ADD CONSTRAINT "fk_message_channels_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_channels"
        ADD CONSTRAINT "fk_message_channels_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."messaging_providers"
        ADD CONSTRAINT "fk_messaging_providers_provider_type_concept_id" FOREIGN KEY ("provider_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.external_providers (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "messaging"."messaging_providers"
        ADD CONSTRAINT "fk_messaging_providers_external_provider_id" FOREIGN KEY ("external_provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."messaging_providers"
        ADD CONSTRAINT "fk_messaging_providers_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."messaging_providers"
        ADD CONSTRAINT "fk_messaging_providers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."messaging_providers"
        ADD CONSTRAINT "fk_messaging_providers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."messaging_providers"
        ADD CONSTRAINT "fk_messaging_providers_provider_time_semantics_concept_id" FOREIGN KEY ("provider_time_semantics_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.provider_credentials (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_credential_id" FOREIGN KEY ("credential_id")
        REFERENCES "integrations"."provider_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.provider_credentials (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_webhook_secret_credential_id" FOREIGN KEY ("webhook_secret_credential_id")
        REFERENCES "integrations"."provider_credentials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_webhook_signature_scheme_concept_id" FOREIGN KEY ("webhook_signature_scheme_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_tracking_mode_concept_id" FOREIGN KEY ("tracking_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_enabled_by_user_id" FOREIGN KEY ("enabled_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_disabled_by_user_id" FOREIGN KEY ("disabled_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_templates"
        ADD CONSTRAINT "fk_message_templates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_templates"
        ADD CONSTRAINT "fk_message_templates_language_concept_id" FOREIGN KEY ("language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_templates"
        ADD CONSTRAINT "fk_message_templates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_templates"
        ADD CONSTRAINT "fk_message_templates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."message_templates"
        ADD CONSTRAINT "fk_message_templates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_recipient_user_id" FOREIGN KEY ("recipient_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: consent.consents (requiere schema consent)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_consent_id" FOREIGN KEY ("consent_id")
        REFERENCES "consent"."consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: marketing.campaign_dispatches (requiere schema marketing)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_dispatch_id" FOREIGN KEY ("dispatch_id")
        REFERENCES "marketing"."campaign_dispatches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: marketing.campaign_dispatch_recipients (requiere schema marketing)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_dispatch_recipient_id" FOREIGN KEY ("dispatch_recipient_id")
        REFERENCES "marketing"."campaign_dispatch_recipients" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_recipient_type_concept_id" FOREIGN KEY ("recipient_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: crm.contact_channel_endpoints (requiere schema crm)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_recipient_endpoint_id" FOREIGN KEY ("recipient_endpoint_id")
        REFERENCES "crm"."contact_channel_endpoints" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_authorized_by_user_id" FOREIGN KEY ("authorized_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_receipts"
        ADD CONSTRAINT "fk_delivery_receipts_receipt_type_concept_id" FOREIGN KEY ("receipt_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_receipts"
        ADD CONSTRAINT "fk_delivery_receipts_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."recipient_preferences"
        ADD CONSTRAINT "fk_recipient_preferences_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "messaging"."recipient_preferences"
        ADD CONSTRAINT "fk_recipient_preferences_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."recipient_preferences"
        ADD CONSTRAINT "fk_recipient_preferences_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."recipient_preferences"
        ADD CONSTRAINT "fk_recipient_preferences_language_concept_id" FOREIGN KEY ("language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."recipient_preferences"
        ADD CONSTRAINT "fk_recipient_preferences_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."recipient_preferences"
        ADD CONSTRAINT "fk_recipient_preferences_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_event_mappings"
        ADD CONSTRAINT "fk_adapter_event_mappings_canonical_event_type_concept_id" FOREIGN KEY ("canonical_event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_event_mappings"
        ADD CONSTRAINT "fk_adapter_event_mappings_canonical_delivery_status_concept_id" FOREIGN KEY ("canonical_delivery_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_event_mappings"
        ADD CONSTRAINT "fk_adapter_event_mappings_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_event_mappings"
        ADD CONSTRAINT "fk_adapter_event_mappings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_event_mappings"
        ADD CONSTRAINT "fk_adapter_event_mappings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_ingestion_type_concept_id" FOREIGN KEY ("ingestion_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_signature_status_concept_id" FOREIGN KEY ("signature_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_replay_status_concept_id" FOREIGN KEY ("replay_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_processing_status_concept_id" FOREIGN KEY ("processing_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_canonical_event_type__d17e0ee5" FOREIGN KEY ("canonical_event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_support_level_concept_id" FOREIGN KEY ("support_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_evidence_source_concept_id" FOREIGN KEY ("evidence_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_reconciliation_runs"
        ADD CONSTRAINT "fk_delivery_reconciliation_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_reconciliation_runs"
        ADD CONSTRAINT "fk_delivery_reconciliation_runs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_status_transitions"
        ADD CONSTRAINT "fk_delivery_status_transitions_from_status_concept_id" FOREIGN KEY ("from_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_status_transitions"
        ADD CONSTRAINT "fk_delivery_status_transitions_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_status_transitions"
        ADD CONSTRAINT "fk_delivery_status_transitions_to_status_concept_id" FOREIGN KEY ("to_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_status_transitions"
        ADD CONSTRAINT "fk_delivery_status_transitions_channel_type_concept_id" FOREIGN KEY ("channel_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_status_transitions"
        ADD CONSTRAINT "fk_delivery_status_transitions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: marketing.campaign_dispatches (requiere schema marketing)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_dispatch_id" FOREIGN KEY ("dispatch_id")
        REFERENCES "marketing"."campaign_dispatches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: marketing.campaign_dispatch_recipients (requiere schema marketing)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_dispatch_recipient_id" FOREIGN KEY ("dispatch_recipient_id")
        REFERENCES "marketing"."campaign_dispatch_recipients" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_canonical_event_type_concept_id" FOREIGN KEY ("canonical_event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_resulting_status_concept_id" FOREIGN KEY ("resulting_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
