-- SALUD v4.0.10 · módulo 40 · schema auth_providers
-- Generado de diagram_40_auth_providers.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_identity_providers_code" ON "auth_providers"."identity_providers" ("code");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_tenant_id" ON "auth_providers"."identity_providers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_protocol_concept_id" ON "auth_providers"."identity_providers" ("protocol_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_provider_category_concept_id" ON "auth_providers"."identity_providers" ("provider_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_logo_file_id" ON "auth_providers"."identity_providers" ("logo_file_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_state_concept_id" ON "auth_providers"."identity_providers" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_created_by_user_id" ON "auth_providers"."identity_providers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_updated_by_user_id" ON "auth_providers"."identity_providers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identity_providers_tenant_id_state_concept_id" ON "auth_providers"."identity_providers" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_provider_id" ON "auth_providers"."provider_protocol_configs" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_environment_concept_id" ON "auth_providers"."provider_protocol_configs" ("environment_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_token_endpoint_auth_concept_id" ON "auth_providers"."provider_protocol_configs" ("token_endpoint_auth_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_state_concept_id" ON "auth_providers"."provider_protocol_configs" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_created_by_user_id" ON "auth_providers"."provider_protocol_configs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_protocol_configs_updated_by_user_id" ON "auth_providers"."provider_protocol_configs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_signing_keys_provider_id" ON "auth_providers"."provider_signing_keys" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_provider_signing_keys_key_use_concept_id" ON "auth_providers"."provider_signing_keys" ("key_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_signing_keys_state_concept_id" ON "auth_providers"."provider_signing_keys" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_signing_keys_created_by_user_id" ON "auth_providers"."provider_signing_keys" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_signing_keys_updated_by_user_id" ON "auth_providers"."provider_signing_keys" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_provider_id" ON "auth_providers"."provider_tenant_bindings" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_tenant_id" ON "auth_providers"."provider_tenant_bindings" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_default_role_concept_id" ON "auth_providers"."provider_tenant_bindings" ("default_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_state_concept_id" ON "auth_providers"."provider_tenant_bindings" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_created_by_user_id" ON "auth_providers"."provider_tenant_bindings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_updated_by_user_id" ON "auth_providers"."provider_tenant_bindings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_tenant_bindings_tenant_id_state_concept_id" ON "auth_providers"."provider_tenant_bindings" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_provider_attribute_mappings_provider_id" ON "auth_providers"."provider_attribute_mappings" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_provider_attribute_mappings_created_by_user_id" ON "auth_providers"."provider_attribute_mappings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provider_attribute_mappings_updated_by_user_id" ON "auth_providers"."provider_attribute_mappings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_provider_id" ON "auth_providers"."provisioning_rules" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_tenant_id" ON "auth_providers"."provisioning_rules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_assign_role_concept_id" ON "auth_providers"."provisioning_rules" ("assign_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_assign_tenant_id" ON "auth_providers"."provisioning_rules" ("assign_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_effect_concept_id" ON "auth_providers"."provisioning_rules" ("effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_created_by_user_id" ON "auth_providers"."provisioning_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_updated_by_user_id" ON "auth_providers"."provisioning_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_provisioning_rules_tenant_id_updated_at" ON "auth_providers"."provisioning_rules" ("tenant_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_federated_identities_external_subject" ON "auth_providers"."federated_identities" ("external_subject");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_provider_id" ON "auth_providers"."federated_identities" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_user_id" ON "auth_providers"."federated_identities" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_state_concept_id" ON "auth_providers"."federated_identities" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_created_by_user_id" ON "auth_providers"."federated_identities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_federated_identities_updated_by_user_id" ON "auth_providers"."federated_identities" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_account_link_requests_link_token_hash" ON "auth_providers"."account_link_requests" ("link_token_hash");

CREATE INDEX IF NOT EXISTS "ix_account_link_requests_provider_id" ON "auth_providers"."account_link_requests" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_account_link_requests_user_id" ON "auth_providers"."account_link_requests" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_account_link_requests_status_concept_id" ON "auth_providers"."account_link_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_link_requests_created_by_user_id" ON "auth_providers"."account_link_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_account_link_requests_updated_by_user_id" ON "auth_providers"."account_link_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_federated_login_attempts_provider_id" ON "auth_providers"."federated_login_attempts" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_federated_login_attempts_tenant_id" ON "auth_providers"."federated_login_attempts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_federated_login_attempts_user_id" ON "auth_providers"."federated_login_attempts" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_federated_login_attempts_outcome_concept_id" ON "auth_providers"."federated_login_attempts" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_federated_login_attempts_failure_reason_concept_id" ON "auth_providers"."federated_login_attempts" ("failure_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_federated_login_attempts_recorded_by_user_id" ON "auth_providers"."federated_login_attempts" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_federated_login_attempts_tenant_id_recorded_at" ON "auth_providers"."federated_login_attempts" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_federated_login_attempts_recorded_at" ON "auth_providers"."federated_login_attempts" USING brin ("recorded_at") WITH (pages_per_range=128);
