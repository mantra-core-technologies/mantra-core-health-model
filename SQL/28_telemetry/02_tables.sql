-- SALUD v4.0.10 · módulo 28 · schema telemetry
-- Generado de diagram_28_telemetry.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "telemetry"."tracking_purpose_definitions" (
    "id" uuid NOT NULL,
    "purpose_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "purpose_category_concept_id" uuid NOT NULL,
    "legal_basis_concept_id" uuid,
    "requires_consent" boolean,
    "permits_marketing_use" boolean,
    "permits_cross_tenant_aggregation" boolean,
    "default_retention_days" integer,
    "version_number" integer NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_tracking_purpose_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."activity_event_schema_definitions" (
    "id" uuid NOT NULL,
    "event_name" varchar NOT NULL,
    "schema_version" integer NOT NULL,
    "purpose_definition_id" uuid NOT NULL,
    "portal_type_concept_id" uuid NOT NULL,
    "property_schema_json" jsonb,
    "prohibited_property_patterns_json" jsonb,
    "pii_classification_concept_id" uuid,
    "phi_allowed" boolean,
    "status_concept_id" uuid NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_activity_event_schema_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."analytics_subjects" (
    "id" uuid NOT NULL,
    "user_id" uuid,
    "patient_profile_id" uuid,
    "pseudonymous_subject_key" varchar NOT NULL,
    "key_version" integer,
    "rotated_from_subject_id" uuid,
    "created_from_consent_id" uuid,
    "deactivated_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_analytics_subjects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."tracking_consents" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "purpose_definition_id" uuid NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "jurisdiction_concept_id" uuid,
    "consent_version" varchar,
    "granted_at" timestamptz,
    "withdrawn_at" timestamptz,
    "evidence_hash" varchar,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_tracking_consents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."tracking_disclosure_versions" (
    "id" uuid NOT NULL,
    "document_code" varchar NOT NULL,
    "version_number" integer NOT NULL,
    "jurisdiction_concept_id" uuid NOT NULL,
    "file_id" uuid,
    "content_hash" varchar,
    "effective_from" timestamptz,
    "effective_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_tracking_disclosure_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."tracking_disclosure_acceptances" (
    "id" uuid NOT NULL,
    "tracking_disclosure_version_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "session_id" uuid,
    "accepted_at" timestamptz,
    "ip_prefix_hash" varchar,
    "user_agent_hash" varchar,
    "acceptance_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_tracking_disclosure_acceptances" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."user_activity_events" (
    "id" uuid NOT NULL,
    "event_schema_definition_id" uuid NOT NULL,
    "analytics_subject_id" uuid,
    "user_id" uuid,
    "session_id" uuid,
    "device_id" uuid,
    "tenant_id" uuid,
    "portal_type_concept_id" uuid NOT NULL,
    "event_name" varchar NOT NULL,
    "event_idempotency_key" varchar NOT NULL,
    "route_template" varchar,
    "target_type_concept_id" uuid,
    "target_entity_id" uuid,
    "occurred_at" timestamptz,
    "received_at" timestamptz,
    "correlation_id" uuid,
    "consent_snapshot_id" uuid,
    "security_audit_event_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_user_activity_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."user_activity_event_properties" (
    "id" uuid NOT NULL,
    "user_activity_event_id" uuid NOT NULL,
    "property_name" varchar NOT NULL,
    "value_type_concept_id" uuid NOT NULL,
    "value_string" text,
    "value_number" numeric,
    "value_boolean" boolean,
    "value_timestamp" timestamptz,
    "value_concept_id" uuid,
    "value_hash" varchar,
    "data_classification_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_user_activity_event_properties" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."session_journeys" (
    "id" uuid NOT NULL,
    "session_id" uuid NOT NULL,
    "analytics_subject_id" uuid,
    "portal_type_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "ended_at" timestamptz,
    "entry_event_id" uuid,
    "exit_event_id" uuid,
    "event_count" integer,
    "journey_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_session_journeys" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."funnel_definitions" (
    "id" uuid NOT NULL,
    "funnel_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "portal_type_concept_id" uuid NOT NULL,
    "purpose_definition_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_funnel_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."funnel_steps" (
    "id" uuid NOT NULL,
    "funnel_definition_id" uuid NOT NULL,
    "step_number" integer NOT NULL,
    "event_schema_definition_id" uuid NOT NULL,
    "qualification_rule_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_funnel_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."conversion_events" (
    "id" uuid NOT NULL,
    "funnel_definition_id" uuid NOT NULL,
    "analytics_subject_id" uuid NOT NULL,
    "session_journey_id" uuid,
    "completion_event_id" uuid,
    "converted_at" timestamptz,
    "attribution_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conversion_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."client_contexts" (
    "id" uuid NOT NULL,
    "session_journey_id" uuid,
    "analytics_subject_id" uuid,
    "session_id" uuid,
    "portal_type_concept_id" uuid NOT NULL,
    "device_type_concept_id" uuid,
    "os_family_concept_id" uuid,
    "browser_family_concept_id" uuid,
    "app_version" varchar,
    "screen_class" varchar,
    "viewport_bucket" varchar,
    "locale" varchar,
    "timezone_offset_minutes" integer,
    "country_concept_id" uuid,
    "region_coarse" varchar,
    "ip_prefix_hash" varchar,
    "user_agent_hash" varchar,
    "is_bot" boolean,
    "data_classification_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_client_contexts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "telemetry"."web_vitals" (
    "id" uuid NOT NULL,
    "user_activity_event_id" uuid,
    "session_journey_id" uuid,
    "analytics_subject_id" uuid,
    "client_context_id" uuid,
    "portal_type_concept_id" uuid NOT NULL,
    "route_template" varchar,
    "metric_concept_id" uuid NOT NULL,
    "metric_value" numeric,
    "rating_concept_id" uuid,
    "navigation_type_concept_id" uuid,
    "measured_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_web_vitals" PRIMARY KEY ("id")
);
