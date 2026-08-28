-- SALUD v4.0.10 · módulo 01 · schema iam
-- Generado de diagram_01_iam.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "ux_account_activations_token_hash" ON "iam"."account_activations" ("token_hash");

CREATE INDEX IF NOT EXISTS "ix_account_activations_user" ON "iam"."account_activations" ("user_id", "state_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_email_verifications_token_hash" ON "iam"."email_verifications" ("token_hash");

CREATE INDEX IF NOT EXISTS "ix_email_verifications_user" ON "iam"."email_verifications" ("user_id", "state_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_password_resets_token_hash" ON "iam"."password_resets" ("token_hash");

CREATE INDEX IF NOT EXISTS "ix_password_resets_user_state" ON "iam"."password_resets" ("user_id", "state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_status_concept_id" ON "iam"."users" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_preferred_language_concept_id" ON "iam"."users" ("preferred_language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_residence_country_concept_id" ON "iam"."users" ("residence_country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_data_residency_region_concept_id" ON "iam"."users" ("data_residency_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_mfa_status_concept_id" ON "iam"."users" ("mfa_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_legal_basis_concept_id" ON "iam"."users" ("legal_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_users_created_by_user_id" ON "iam"."users" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_users_updated_by_user_id" ON "iam"."users" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_authentication_credentials_user_id" ON "iam"."authentication_credentials" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_authentication_credentials_method_concept_id" ON "iam"."authentication_credentials" ("method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_authentication_credentials_hash_algorithm_concept_id" ON "iam"."authentication_credentials" ("hash_algorithm_concept_id");

CREATE INDEX IF NOT EXISTS "ix_authentication_credentials_state_concept_id" ON "iam"."authentication_credentials" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_authentication_credentials_created_by_user_id" ON "iam"."authentication_credentials" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_authentication_credentials_updated_by_user_id" ON "iam"."authentication_credentials" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_authentication_credentials_live_password_subject" ON "iam"."authentication_credentials" ("external_subject") WHERE method_concept_id = '37da1281-cc62-5032-b598-1eb39dc46060' AND external_subject IS NOT NULL AND state_concept_id IN ('38a1d301-f40d-5b17-a695-5e6d605f8b19', '2e38dae4-c0c2-52ff-b1c9-a954ff880a38');

CREATE INDEX IF NOT EXISTS "ix_mfa_factors_user_id" ON "iam"."mfa_factors" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_mfa_factors_factor_type_concept_id" ON "iam"."mfa_factors" ("factor_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_mfa_factors_state_concept_id" ON "iam"."mfa_factors" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_mfa_factors_created_by_user_id" ON "iam"."mfa_factors" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_mfa_factors_updated_by_user_id" ON "iam"."mfa_factors" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_devices_device_fingerprint" ON "iam"."devices" ("device_fingerprint");

CREATE INDEX IF NOT EXISTS "ix_devices_user_id" ON "iam"."devices" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_devices_platform_concept_id" ON "iam"."devices" ("platform_concept_id");

CREATE INDEX IF NOT EXISTS "ix_devices_created_by_user_id" ON "iam"."devices" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_devices_updated_by_user_id" ON "iam"."devices" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sessions_token_id" ON "iam"."sessions" ("token_id");

CREATE INDEX IF NOT EXISTS "ix_sessions_user_id" ON "iam"."sessions" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_sessions_device_id" ON "iam"."sessions" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_sessions_state_concept_id" ON "iam"."sessions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sessions_created_by_user_id" ON "iam"."sessions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sessions_updated_by_user_id" ON "iam"."sessions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sessions_user_state_expiry" ON "iam"."sessions" ("user_id", "state_concept_id", "expires_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_refresh_tokens_token_hash" ON "iam"."refresh_tokens" ("token_hash");

CREATE INDEX IF NOT EXISTS "ix_refresh_tokens_session_id" ON "iam"."refresh_tokens" ("session_id");

CREATE INDEX IF NOT EXISTS "ix_refresh_tokens_state_concept_id" ON "iam"."refresh_tokens" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_refresh_tokens_replaced_by_id" ON "iam"."refresh_tokens" ("replaced_by_id");

CREATE INDEX IF NOT EXISTS "ix_refresh_tokens_created_by_user_id" ON "iam"."refresh_tokens" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_refresh_tokens_updated_by_user_id" ON "iam"."refresh_tokens" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_refresh_tokens_session_state" ON "iam"."refresh_tokens" ("session_id", "state_concept_id", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_user_global_roles_user_id" ON "iam"."user_global_roles" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_user_global_roles_role_concept_id" ON "iam"."user_global_roles" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_global_roles_state_concept_id" ON "iam"."user_global_roles" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_global_roles_created_by_user_id" ON "iam"."user_global_roles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_global_roles_updated_by_user_id" ON "iam"."user_global_roles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_security_events_user_id" ON "iam"."security_events" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_security_events_event_type_concept_id" ON "iam"."security_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_security_events_outcome_concept_id" ON "iam"."security_events" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_security_events_recorded_by_user_id" ON "iam"."security_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_security_events_recorded_at" ON "iam"."security_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_api_keys_key_prefix" ON "iam"."api_keys" ("key_prefix");

CREATE INDEX IF NOT EXISTS "ix_api_keys_tenant_id" ON "iam"."api_keys" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_api_keys_owner_user_id" ON "iam"."api_keys" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_api_keys_service_principal_id" ON "iam"."api_keys" ("service_principal_id");

CREATE INDEX IF NOT EXISTS "ix_api_keys_status_concept_id" ON "iam"."api_keys" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_api_key_scopes_api_key_id" ON "iam"."api_key_scopes" ("api_key_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_api_key_scopes_key_scope" ON "iam"."api_key_scopes" ("api_key_id", "scope_concept_id", "resource");

CREATE INDEX IF NOT EXISTS "ix_account_lockouts_user_id" ON "iam"."account_lockouts" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_account_lockouts_status_concept_id" ON "iam"."account_lockouts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_lockouts_locked_until" ON "iam"."account_lockouts" ("locked_until");
