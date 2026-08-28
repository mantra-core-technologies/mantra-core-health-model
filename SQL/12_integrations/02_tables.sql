-- SALUD v4.0.10 · módulo 12 · schema integrations
-- Generado de diagram_12_integrations.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "integrations"."external_providers" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "provider_type_concept_id" uuid NOT NULL,
    "base_url" text,
    "auth_type_concept_id" uuid,
    "doc_url" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_external_providers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."provider_connections" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "environment_concept_id" uuid,
    "config_json" jsonb,
    "credential_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_connections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."provider_credentials" (
    "id" uuid NOT NULL,
    "connection_id" uuid NOT NULL,
    "secret_type_concept_id" uuid NOT NULL,
    "secret_ref" varchar,
    "encrypted" boolean,
    "rotated_at" timestamptz,
    "expires_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_provider_credentials" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."integration_endpoints" (
    "id" uuid NOT NULL,
    "provider_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "operation" varchar NOT NULL,
    "http_method_concept_id" uuid,
    "path" text,
    "request_schema_json" jsonb,
    "response_schema_json" jsonb,
    "version" varchar NOT NULL,
    "timeout_ms" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_integration_endpoints" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."outbound_messages" (
    "id" uuid NOT NULL,
    "connection_id" uuid NOT NULL,
    "endpoint_id" uuid,
    "correlation_id" varchar NOT NULL,
    "idempotency_key" varchar,
    "request_payload_json" jsonb NOT NULL,
    "headers_json" jsonb,
    "payload_version" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "scheduled_at" timestamptz,
    "sent_at" timestamptz,
    "source_resource_type" varchar,
    "source_resource_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_outbound_messages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."inbound_messages" (
    "id" uuid NOT NULL,
    "connection_id" uuid NOT NULL,
    "endpoint_id" uuid,
    "correlation_id" varchar,
    "payload_json" jsonb NOT NULL,
    "signature" varchar,
    "payload_version" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "received_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inbound_messages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."message_responses" (
    "id" uuid NOT NULL,
    "outbound_message_id" uuid NOT NULL,
    "http_status" integer,
    "response_payload_json" jsonb NOT NULL,
    "latency_ms" integer,
    "is_success" boolean,
    "received_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_message_responses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."message_retries" (
    "id" uuid NOT NULL,
    "outbound_message_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "error_text" text,
    "request_snapshot_json" jsonb,
    "payload_version" integer NOT NULL,
    "attempted_at" timestamptz,
    "next_retry_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_message_retries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."webhook_subscriptions" (
    "id" uuid NOT NULL,
    "provider_id" uuid,
    "tenant_id" uuid,
    "event_type" varchar NOT NULL,
    "callback_url" text NOT NULL,
    "secret_ref" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_webhook_subscriptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "integrations"."integration_field_mappings" (
    "id" uuid NOT NULL,
    "endpoint_id" uuid NOT NULL,
    "source_path" varchar NOT NULL,
    "target_field" varchar NOT NULL,
    "concept_map_id" uuid,
    "transform_json" jsonb,
    "direction_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_integration_field_mappings" PRIMARY KEY ("id")
);
