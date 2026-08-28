-- SALUD v4.0.10 · módulo 35 · schema messaging
-- Generado de diagram_35_messaging.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_domain_events_tenant_id" ON "messaging"."domain_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_domain_events_causation_id" ON "messaging"."domain_events" ("causation_id");

CREATE INDEX IF NOT EXISTS "ix_domain_events_recorded_by_user_id" ON "messaging"."domain_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_domain_events_tenant_id_recorded_at" ON "messaging"."domain_events" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_domain_events_recorded_at" ON "messaging"."domain_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_outbox_messages_idempotency_key" ON "messaging"."outbox_messages" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_outbox_messages_tenant_id" ON "messaging"."outbox_messages" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_outbox_messages_domain_event_id" ON "messaging"."outbox_messages" ("domain_event_id");

CREATE INDEX IF NOT EXISTS "ix_outbox_messages_status_concept_id" ON "messaging"."outbox_messages" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_outbox_messages_created_by_user_id" ON "messaging"."outbox_messages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_outbox_messages_updated_by_user_id" ON "messaging"."outbox_messages" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_outbox_messages_tenant_id_status_concept_id" ON "messaging"."outbox_messages" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_tenant_id" ON "messaging"."event_subscriptions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_delivery_mode_concept_id" ON "messaging"."event_subscriptions" ("delivery_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_state_concept_id" ON "messaging"."event_subscriptions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_created_by_user_id" ON "messaging"."event_subscriptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_updated_by_user_id" ON "messaging"."event_subscriptions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_event_subscriptions_tenant_id_state_concept_id" ON "messaging"."event_subscriptions" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_event_deliveries_domain_event_id" ON "messaging"."event_deliveries" ("domain_event_id");

CREATE INDEX IF NOT EXISTS "ix_event_deliveries_subscription_id" ON "messaging"."event_deliveries" ("subscription_id");

CREATE INDEX IF NOT EXISTS "ix_event_deliveries_status_concept_id" ON "messaging"."event_deliveries" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_event_deliveries_recorded_by_user_id" ON "messaging"."event_deliveries" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_event_deliveries_domain_event_id_attempt_number" ON "messaging"."event_deliveries" ("domain_event_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "brin_event_deliveries_recorded_at" ON "messaging"."event_deliveries" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_message_queues_code" ON "messaging"."message_queues" ("code");

CREATE INDEX IF NOT EXISTS "ix_message_queues_dead_letter_queue_id" ON "messaging"."message_queues" ("dead_letter_queue_id");

CREATE INDEX IF NOT EXISTS "ix_message_queues_state_concept_id" ON "messaging"."message_queues" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_queues_created_by_user_id" ON "messaging"."message_queues" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_queues_updated_by_user_id" ON "messaging"."message_queues" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_queued_jobs_dedupe_key" ON "messaging"."queued_jobs" ("dedupe_key");

CREATE INDEX IF NOT EXISTS "ix_queued_jobs_queue_id" ON "messaging"."queued_jobs" ("queue_id");

CREATE INDEX IF NOT EXISTS "ix_queued_jobs_tenant_id" ON "messaging"."queued_jobs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_queued_jobs_status_concept_id" ON "messaging"."queued_jobs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_queued_jobs_created_by_user_id" ON "messaging"."queued_jobs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_queued_jobs_updated_by_user_id" ON "messaging"."queued_jobs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_queued_jobs_tenant_id_status_concept_id" ON "messaging"."queued_jobs" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_dead_letter_jobs_queue_id" ON "messaging"."dead_letter_jobs" ("queue_id");

CREATE INDEX IF NOT EXISTS "ix_dead_letter_jobs_original_job_id" ON "messaging"."dead_letter_jobs" ("original_job_id");

CREATE INDEX IF NOT EXISTS "ix_dead_letter_jobs_recorded_by_user_id" ON "messaging"."dead_letter_jobs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_dead_letter_jobs_recorded_at" ON "messaging"."dead_letter_jobs" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_recipient_user_id" ON "messaging"."in_app_notifications" ("recipient_user_id");

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_tenant_id" ON "messaging"."in_app_notifications" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_channel_concept_id" ON "messaging"."in_app_notifications" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_category_concept_id" ON "messaging"."in_app_notifications" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_status_concept_id" ON "messaging"."in_app_notifications" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_created_by_user_id" ON "messaging"."in_app_notifications" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_updated_by_user_id" ON "messaging"."in_app_notifications" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_in_app_notifications_tenant_id_status_concept_id" ON "messaging"."in_app_notifications" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_message_channels_code" ON "messaging"."message_channels" ("code");

CREATE INDEX IF NOT EXISTS "ix_message_channels_channel_type_concept_id" ON "messaging"."message_channels" ("channel_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_channels_state_concept_id" ON "messaging"."message_channels" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_channels_created_by_user_id" ON "messaging"."message_channels" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_channels_updated_by_user_id" ON "messaging"."message_channels" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_messaging_providers_code" ON "messaging"."messaging_providers" ("code");

CREATE INDEX IF NOT EXISTS "ix_messaging_providers_provider_type_concept_id" ON "messaging"."messaging_providers" ("provider_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_messaging_providers_external_provider_id" ON "messaging"."messaging_providers" ("external_provider_id");

CREATE INDEX IF NOT EXISTS "ix_messaging_providers_state_concept_id" ON "messaging"."messaging_providers" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_messaging_providers_created_by_user_id" ON "messaging"."messaging_providers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_messaging_providers_updated_by_user_id" ON "messaging"."messaging_providers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_provider_id" ON "messaging"."provider_channel_configs" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_channel_id" ON "messaging"."provider_channel_configs" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_tenant_id" ON "messaging"."provider_channel_configs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_credential_id" ON "messaging"."provider_channel_configs" ("credential_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_state_concept_id" ON "messaging"."provider_channel_configs" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_created_by_user_id" ON "messaging"."provider_channel_configs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_updated_by_user_id" ON "messaging"."provider_channel_configs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_channel_configs_tenant_id_state_concept_id" ON "messaging"."provider_channel_configs" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_message_templates_tenant_id" ON "messaging"."message_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_channel_id" ON "messaging"."message_templates" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_language_concept_id" ON "messaging"."message_templates" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_status_concept_id" ON "messaging"."message_templates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_created_by_user_id" ON "messaging"."message_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_updated_by_user_id" ON "messaging"."message_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_templates_tenant_id_status_concept_id" ON "messaging"."message_templates" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_message_templates_channel_id_version" ON "messaging"."message_templates" ("channel_id", "version");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_tenant_id" ON "messaging"."notification_requests" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_recipient_user_id" ON "messaging"."notification_requests" ("recipient_user_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_channel_id" ON "messaging"."notification_requests" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_template_id" ON "messaging"."notification_requests" ("template_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_domain_event_id" ON "messaging"."notification_requests" ("domain_event_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_category_concept_id" ON "messaging"."notification_requests" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_status_concept_id" ON "messaging"."notification_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_consent_id" ON "messaging"."notification_requests" ("consent_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_created_by_user_id" ON "messaging"."notification_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_updated_by_user_id" ON "messaging"."notification_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_notification_requests_tenant_id_status_concept_id" ON "messaging"."notification_requests" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_notification_deliveries_notification_request_id" ON "messaging"."notification_deliveries" ("notification_request_id");

CREATE INDEX IF NOT EXISTS "ix_notification_deliveries_provider_id" ON "messaging"."notification_deliveries" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_notification_deliveries_channel_id" ON "messaging"."notification_deliveries" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_notification_deliveries_status_concept_id" ON "messaging"."notification_deliveries" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_notification_deliveries_currency_concept_id" ON "messaging"."notification_deliveries" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_notification_deliveries_created_by_user_id" ON "messaging"."notification_deliveries" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_notification_deliveries_updated_by_user_id" ON "messaging"."notification_deliveries" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_notification_deliveries_notification_request_id_att_f36b3e5c" ON "messaging"."notification_deliveries" ("notification_request_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "ix_delivery_receipts_delivery_id" ON "messaging"."delivery_receipts" ("delivery_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_receipts_receipt_type_concept_id" ON "messaging"."delivery_receipts" ("receipt_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_receipts_recorded_by_user_id" ON "messaging"."delivery_receipts" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_delivery_receipts_recorded_at" ON "messaging"."delivery_receipts" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_user_id" ON "messaging"."recipient_preferences" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_tenant_id" ON "messaging"."recipient_preferences" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_channel_id" ON "messaging"."recipient_preferences" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_category_concept_id" ON "messaging"."recipient_preferences" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_language_concept_id" ON "messaging"."recipient_preferences" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_created_by_user_id" ON "messaging"."recipient_preferences" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_updated_by_user_id" ON "messaging"."recipient_preferences" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_recipient_preferences_tenant_id_updated_at" ON "messaging"."recipient_preferences" ("tenant_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_adapter_event_mappings_provider_id" ON "messaging"."adapter_event_mappings" ("provider_id", "channel_id", "mapping_version", "external_event_code");

CREATE INDEX IF NOT EXISTS "ix_adapter_event_mappings_provider_id" ON "messaging"."adapter_event_mappings" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_event_mappings_channel_id" ON "messaging"."adapter_event_mappings" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_event_mappings_canonical_event_type_concept_id" ON "messaging"."adapter_event_mappings" ("canonical_event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_event_mappings_canonical_delivery_status_concept_id" ON "messaging"."adapter_event_mappings" ("canonical_delivery_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_event_mappings_state_concept_id" ON "messaging"."adapter_event_mappings" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_event_mappings_created_by_user_id" ON "messaging"."adapter_event_mappings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_event_mappings_updated_by_user_id" ON "messaging"."adapter_event_mappings" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_adapter_inbound_events_provider_id" ON "messaging"."adapter_inbound_events" ("provider_id", "external_event_id");

-- OMITIDO "uq_adapter_inbound_events_provider_id" (provider_id, payload_sha256, received_time_bucket) btree: columna(s) ['received_time_bucket'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_provider_id" ON "messaging"."adapter_inbound_events" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_provider_channel_config_id" ON "messaging"."adapter_inbound_events" ("provider_channel_config_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_channel_id" ON "messaging"."adapter_inbound_events" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_ingestion_type_concept_id" ON "messaging"."adapter_inbound_events" ("ingestion_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_signature_status_concept_id" ON "messaging"."adapter_inbound_events" ("signature_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_replay_status_concept_id" ON "messaging"."adapter_inbound_events" ("replay_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_processing_status_concept_id" ON "messaging"."adapter_inbound_events" ("processing_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_inbound_events_delivery_id" ON "messaging"."adapter_inbound_events" ("delivery_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_provider_id" ON "messaging"."adapter_tracking_capabilities" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_channel_id" ON "messaging"."adapter_tracking_capabilities" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_canonical_event_type__3130fd8b" ON "messaging"."adapter_tracking_capabilities" ("canonical_event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_support_level_concept_id" ON "messaging"."adapter_tracking_capabilities" ("support_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_evidence_source_concept_id" ON "messaging"."adapter_tracking_capabilities" ("evidence_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_state_concept_id" ON "messaging"."adapter_tracking_capabilities" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_created_by_user_id" ON "messaging"."adapter_tracking_capabilities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_adapter_tracking_capabilities_updated_by_user_id" ON "messaging"."adapter_tracking_capabilities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_reconciliation_runs_provider_channel_config_id" ON "messaging"."delivery_reconciliation_runs" ("provider_channel_config_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_reconciliation_runs_status_concept_id" ON "messaging"."delivery_reconciliation_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_reconciliation_runs_created_by_user_id" ON "messaging"."delivery_reconciliation_runs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_transitions_from_status_concept_id" ON "messaging"."delivery_status_transitions" ("from_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_transitions_event_type_concept_id" ON "messaging"."delivery_status_transitions" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_transitions_to_status_concept_id" ON "messaging"."delivery_status_transitions" ("to_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_transitions_channel_type_concept_id" ON "messaging"."delivery_status_transitions" ("channel_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_status_transitions_state_concept_id" ON "messaging"."delivery_status_transitions" ("state_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_delivery_tracking_events_delivery_id" ON "messaging"."delivery_tracking_events" ("delivery_id", "source_concept_id", "provider_event_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_delivery_tracking_events_delivery_id" ON "messaging"."delivery_tracking_events" ("delivery_id", "canonical_event_type_concept_id", "sequence_number");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_delivery_id" ON "messaging"."delivery_tracking_events" ("delivery_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_notification_request_id" ON "messaging"."delivery_tracking_events" ("notification_request_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_dispatch_id" ON "messaging"."delivery_tracking_events" ("dispatch_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_dispatch_recipient_id" ON "messaging"."delivery_tracking_events" ("dispatch_recipient_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_inbound_event_id" ON "messaging"."delivery_tracking_events" ("inbound_event_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_canonical_event_type_concept_id" ON "messaging"."delivery_tracking_events" ("canonical_event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_resulting_status_concept_id" ON "messaging"."delivery_tracking_events" ("resulting_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_source_concept_id" ON "messaging"."delivery_tracking_events" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_tracking_events_recorded_by_user_id" ON "messaging"."delivery_tracking_events" ("recorded_by_user_id");
