-- SALUD v4.0.10 · módulo 40 · schema auth_providers
-- Generado de diagram_40_auth_providers.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "auth_providers"."identity_providers" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "protocol_concept_id" uuid NOT NULL,
    "provider_category_concept_id" uuid NOT NULL,
    "issuer" varchar,
    "logo_file_id" uuid,
    "is_global" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_identity_providers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."provider_protocol_configs" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "environment_concept_id" uuid NOT NULL,
    "client_id" varchar,
    "client_secret_ref" varchar,
    "authorize_url" text,
    "token_url" text,
    "userinfo_url" text,
    "jwks_uri" text,
    "metadata_url" text,
    "saml_entity_id" varchar,
    "saml_acs_url" text,
    "scopes" varchar,
    "response_type" varchar,
    "token_endpoint_auth_concept_id" uuid,
    "pkce_required" boolean,
    "extra_config_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_protocol_configs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."provider_signing_keys" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "key_id" varchar NOT NULL,
    "key_use_concept_id" uuid NOT NULL,
    "algorithm" varchar NOT NULL,
    "public_key" text NOT NULL,
    "certificate" text,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_signing_keys" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."provider_tenant_bindings" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "is_enabled" boolean NOT NULL,
    "auto_provision" boolean,
    "default_role_concept_id" uuid,
    "allowed_email_domains" varchar,
    "just_in_time_provisioning" boolean,
    "ordinal" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_tenant_bindings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."provider_attribute_mappings" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "source_claim" varchar NOT NULL,
    "target_attribute" varchar NOT NULL,
    "is_identifier" boolean,
    "transform_json" jsonb,
    "required" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_attribute_mappings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."provisioning_rules" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "tenant_id" uuid,
    "priority" integer NOT NULL,
    "condition_json" jsonb,
    "assign_role_concept_id" uuid,
    "assign_tenant_id" uuid,
    "effect_concept_id" uuid,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provisioning_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."federated_identities" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "external_subject" varchar NOT NULL,
    "external_email" varchar,
    "display_name" varchar,
    "linked_at" timestamptz,
    "last_login_at" timestamptz,
    "raw_claims_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_federated_identities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."account_link_requests" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "user_id" uuid,
    "external_subject" varchar NOT NULL,
    "link_token_hash" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "expires_at" timestamptz,
    "completed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_account_link_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "auth_providers"."federated_login_attempts" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "tenant_id" uuid,
    "user_id" uuid,
    "external_subject" varchar,
    "outcome_concept_id" uuid NOT NULL,
    "failure_reason_concept_id" uuid,
    "ip" inet,
    "user_agent" varchar,
    "request_id" varchar,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_federated_login_attempts" PRIMARY KEY ("id")
);
