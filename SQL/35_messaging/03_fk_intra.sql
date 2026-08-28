-- SALUD v4.0.10 · módulo 35 · schema messaging
-- Generado de diagram_35_messaging.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "messaging"."domain_events"
        ADD CONSTRAINT "fk_domain_events_causation_id" FOREIGN KEY ("causation_id")
        REFERENCES "messaging"."domain_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."outbox_messages"
        ADD CONSTRAINT "fk_outbox_messages_domain_event_id" FOREIGN KEY ("domain_event_id")
        REFERENCES "messaging"."domain_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."event_deliveries"
        ADD CONSTRAINT "fk_event_deliveries_domain_event_id" FOREIGN KEY ("domain_event_id")
        REFERENCES "messaging"."domain_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."message_queues"
        ADD CONSTRAINT "fk_message_queues_dead_letter_queue_id" FOREIGN KEY ("dead_letter_queue_id")
        REFERENCES "messaging"."message_queues" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."queued_jobs"
        ADD CONSTRAINT "fk_queued_jobs_queue_id" FOREIGN KEY ("queue_id")
        REFERENCES "messaging"."message_queues" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."dead_letter_jobs"
        ADD CONSTRAINT "fk_dead_letter_jobs_queue_id" FOREIGN KEY ("queue_id")
        REFERENCES "messaging"."message_queues" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."dead_letter_jobs"
        ADD CONSTRAINT "fk_dead_letter_jobs_original_job_id" FOREIGN KEY ("original_job_id")
        REFERENCES "messaging"."queued_jobs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_notification_request_id" FOREIGN KEY ("notification_request_id")
        REFERENCES "messaging"."notification_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."in_app_notifications"
        ADD CONSTRAINT "fk_in_app_notifications_notification_delivery_id" FOREIGN KEY ("notification_delivery_id")
        REFERENCES "messaging"."notification_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "messaging"."messaging_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."provider_channel_configs"
        ADD CONSTRAINT "fk_provider_channel_configs_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."message_templates"
        ADD CONSTRAINT "fk_message_templates_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_template_id" FOREIGN KEY ("template_id")
        REFERENCES "messaging"."message_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_requests"
        ADD CONSTRAINT "fk_notification_requests_domain_event_id" FOREIGN KEY ("domain_event_id")
        REFERENCES "messaging"."domain_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_notification_request_id" FOREIGN KEY ("notification_request_id")
        REFERENCES "messaging"."notification_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "messaging"."messaging_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_provider_channel_config_id" FOREIGN KEY ("provider_channel_config_id")
        REFERENCES "messaging"."provider_channel_configs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."notification_deliveries"
        ADD CONSTRAINT "fk_notification_deliveries_last_event_id" FOREIGN KEY ("last_event_id")
        REFERENCES "messaging"."delivery_tracking_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_receipts"
        ADD CONSTRAINT "fk_delivery_receipts_delivery_id" FOREIGN KEY ("delivery_id")
        REFERENCES "messaging"."notification_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."recipient_preferences"
        ADD CONSTRAINT "fk_recipient_preferences_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_event_mappings"
        ADD CONSTRAINT "fk_adapter_event_mappings_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "messaging"."messaging_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_event_mappings"
        ADD CONSTRAINT "fk_adapter_event_mappings_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "messaging"."messaging_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_provider_channel_config_id" FOREIGN KEY ("provider_channel_config_id")
        REFERENCES "messaging"."provider_channel_configs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_inbound_events"
        ADD CONSTRAINT "fk_adapter_inbound_events_delivery_id" FOREIGN KEY ("delivery_id")
        REFERENCES "messaging"."notification_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "messaging"."messaging_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."adapter_tracking_capabilities"
        ADD CONSTRAINT "fk_adapter_tracking_capabilities_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_reconciliation_runs"
        ADD CONSTRAINT "fk_delivery_reconciliation_runs_provider_channel_config_id" FOREIGN KEY ("provider_channel_config_id")
        REFERENCES "messaging"."provider_channel_configs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_delivery_id" FOREIGN KEY ("delivery_id")
        REFERENCES "messaging"."notification_deliveries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_notification_request_id" FOREIGN KEY ("notification_request_id")
        REFERENCES "messaging"."notification_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "messaging"."delivery_tracking_events"
        ADD CONSTRAINT "fk_delivery_tracking_events_inbound_event_id" FOREIGN KEY ("inbound_event_id")
        REFERENCES "messaging"."adapter_inbound_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
