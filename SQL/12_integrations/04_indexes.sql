-- SALUD v4.0.10 · módulo 12 · schema integrations
-- Generado de diagram_12_integrations.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_external_providers_code" ON "integrations"."external_providers" ("code");

CREATE INDEX IF NOT EXISTS "ix_external_providers_provider_type_concept_id" ON "integrations"."external_providers" ("provider_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_external_providers_auth_type_concept_id" ON "integrations"."external_providers" ("auth_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_external_providers_state_concept_id" ON "integrations"."external_providers" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_external_providers_created_by_user_id" ON "integrations"."external_providers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_external_providers_updated_by_user_id" ON "integrations"."external_providers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_provider_id" ON "integrations"."provider_connections" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_tenant_id" ON "integrations"."provider_connections" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_environment_concept_id" ON "integrations"."provider_connections" ("environment_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_credential_id" ON "integrations"."provider_connections" ("credential_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_state_concept_id" ON "integrations"."provider_connections" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_created_by_user_id" ON "integrations"."provider_connections" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_updated_by_user_id" ON "integrations"."provider_connections" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_connections_tenant_id_state_concept_id" ON "integrations"."provider_connections" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_provider_credentials_connection_id" ON "integrations"."provider_credentials" ("connection_id");

CREATE INDEX IF NOT EXISTS "ix_provider_credentials_secret_type_concept_id" ON "integrations"."provider_credentials" ("secret_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_credentials_state_concept_id" ON "integrations"."provider_credentials" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_credentials_created_by_user_id" ON "integrations"."provider_credentials" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_credentials_updated_by_user_id" ON "integrations"."provider_credentials" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_provider_id" ON "integrations"."integration_endpoints" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_http_method_concept_id" ON "integrations"."integration_endpoints" ("http_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_state_concept_id" ON "integrations"."integration_endpoints" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_created_by_user_id" ON "integrations"."integration_endpoints" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_endpoints_updated_by_user_id" ON "integrations"."integration_endpoints" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_integration_endpoints_provider_id_version" ON "integrations"."integration_endpoints" ("provider_id", "version");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_outbound_messages_idempotency_key" ON "integrations"."outbound_messages" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_connection_id" ON "integrations"."outbound_messages" ("connection_id");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_endpoint_id" ON "integrations"."outbound_messages" ("endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_status_concept_id" ON "integrations"."outbound_messages" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_created_by_user_id" ON "integrations"."outbound_messages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_outbound_messages_updated_by_user_id" ON "integrations"."outbound_messages" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_connection_id" ON "integrations"."inbound_messages" ("connection_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_endpoint_id" ON "integrations"."inbound_messages" ("endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_status_concept_id" ON "integrations"."inbound_messages" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_created_by_user_id" ON "integrations"."inbound_messages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inbound_messages_updated_by_user_id" ON "integrations"."inbound_messages" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_responses_outbound_message_id" ON "integrations"."message_responses" ("outbound_message_id");

CREATE INDEX IF NOT EXISTS "ix_message_responses_created_by_user_id" ON "integrations"."message_responses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_responses_updated_by_user_id" ON "integrations"."message_responses" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_retries_outbound_message_id" ON "integrations"."message_retries" ("outbound_message_id");

CREATE INDEX IF NOT EXISTS "ix_message_retries_status_concept_id" ON "integrations"."message_retries" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_retries_created_by_user_id" ON "integrations"."message_retries" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_message_retries_updated_by_user_id" ON "integrations"."message_retries" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_message_retries_outbound_message_id_attempt_number" ON "integrations"."message_retries" ("outbound_message_id", "attempt_number");

CREATE INDEX IF NOT EXISTS "ix_webhook_subscriptions_provider_id" ON "integrations"."webhook_subscriptions" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_subscriptions_tenant_id" ON "integrations"."webhook_subscriptions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_subscriptions_state_concept_id" ON "integrations"."webhook_subscriptions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_subscriptions_created_by_user_id" ON "integrations"."webhook_subscriptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_subscriptions_updated_by_user_id" ON "integrations"."webhook_subscriptions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_webhook_subscriptions_tenant_id_state_concept_id" ON "integrations"."webhook_subscriptions" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_integration_field_mappings_endpoint_id" ON "integrations"."integration_field_mappings" ("endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_integration_field_mappings_concept_map_id" ON "integrations"."integration_field_mappings" ("concept_map_id");

CREATE INDEX IF NOT EXISTS "ix_integration_field_mappings_direction_concept_id" ON "integrations"."integration_field_mappings" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_integration_field_mappings_created_by_user_id" ON "integrations"."integration_field_mappings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_integration_field_mappings_updated_by_user_id" ON "integrations"."integration_field_mappings" ("updated_by_user_id");
