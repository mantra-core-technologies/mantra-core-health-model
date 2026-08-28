-- SALUD v4.0.10 · módulo 37 · schema tracking
-- Generado de diagram_37_tracking.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "tracking"."trackable_subjects" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_ref_type" varchar NOT NULL,
    "subject_ref_id" uuid NOT NULL,
    "tracking_number" varchar NOT NULL,
    "current_status_concept_id" uuid,
    "current_milestone_id" uuid,
    "priority_concept_id" uuid,
    "opened_at" timestamptz,
    "closed_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_trackable_subjects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "tracking"."milestone_definitions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "subject_type_concept_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "milestone_status_concept_id" uuid NOT NULL,
    "ordinal" integer,
    "is_terminal" boolean,
    "sla_minutes" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_milestone_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "tracking"."tracking_events" (
    "id" uuid NOT NULL,
    "trackable_subject_id" uuid NOT NULL,
    "milestone_definition_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "description" text,
    "location_text" varchar,
    "latitude" numeric,
    "longitude" numeric,
    "location_ping_id" uuid,
    "actor_user_id" uuid,
    "source_concept_id" uuid,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_tracking_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "tracking"."tracking_carriers" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "carrier_type_concept_id" uuid NOT NULL,
    "contact_json" jsonb,
    "external_provider_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tracking_carriers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "tracking"."shipments" (
    "id" uuid NOT NULL,
    "trackable_subject_id" uuid NOT NULL,
    "carrier_id" uuid,
    "tenant_id" uuid,
    "shipment_number" varchar NOT NULL,
    "origin_address_id" uuid,
    "destination_address_id" uuid,
    "assigned_courier_user_id" uuid,
    "tracked_subject_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "dispatched_at" timestamptz,
    "estimated_arrival_at" timestamptz,
    "delivered_at" timestamptz,
    "distance_m" numeric,
    "temperature_controlled" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_shipments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "tracking"."shipment_handoffs" (
    "id" uuid NOT NULL,
    "shipment_id" uuid NOT NULL,
    "handoff_type_concept_id" uuid NOT NULL,
    "from_party_type" varchar,
    "from_party_id" uuid,
    "to_party_type" varchar,
    "to_party_id" uuid,
    "location_text" varchar,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_shipment_handoffs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "tracking"."eta_estimates" (
    "id" uuid NOT NULL,
    "trackable_subject_id" uuid NOT NULL,
    "shipment_id" uuid,
    "estimated_arrival_at" timestamptz NOT NULL,
    "confidence_pct" integer,
    "method_concept_id" uuid,
    "computed_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_eta_estimates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "tracking"."delivery_proofs" (
    "id" uuid NOT NULL,
    "shipment_id" uuid NOT NULL,
    "proof_type_concept_id" uuid NOT NULL,
    "recipient_name" varchar,
    "signature_file_id" uuid,
    "photo_file_id" uuid,
    "latitude" numeric,
    "longitude" numeric,
    "captured_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_delivery_proofs" PRIMARY KEY ("id")
);
