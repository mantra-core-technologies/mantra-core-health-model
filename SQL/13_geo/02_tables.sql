-- SALUD v4.0.10 · módulo 13 · schema geo
-- Generado de diagram_13_geo.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "geo"."tracked_subjects" (
    "id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_id" uuid NOT NULL,
    "device_id" uuid,
    "tenant_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tracked_subjects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "geo"."location_pings" (
    "id" uuid NOT NULL,
    "tracked_subject_id" uuid NOT NULL,
    "device_id" uuid,
    "latitude" numeric NOT NULL,
    "longitude" numeric NOT NULL,
    "accuracy_m" numeric,
    "altitude_m" numeric,
    "speed_mps" numeric,
    "heading_deg" numeric,
    "battery_pct" integer,
    "network_concept_id" uuid,
    "captured_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_location_pings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "geo"."tracking_sessions" (
    "id" uuid NOT NULL,
    "tracked_subject_id" uuid NOT NULL,
    "purpose_concept_id" uuid,
    "related_resource_type" varchar,
    "related_resource_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "ended_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tracking_sessions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "geo"."geofences" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "shape_type_concept_id" uuid NOT NULL,
    "geometry_json" jsonb,
    "radius_m" numeric,
    "center_lat" numeric,
    "center_lng" numeric,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_geofences" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "geo"."geofence_events" (
    "id" uuid NOT NULL,
    "geofence_id" uuid NOT NULL,
    "tracked_subject_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "location_ping_id" uuid,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_geofence_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "geo"."trips" (
    "id" uuid NOT NULL,
    "tracking_session_id" uuid,
    "origin_address_id" uuid,
    "destination_address_id" uuid,
    "distance_m" numeric,
    "duration_s" integer,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "ended_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_trips" PRIMARY KEY ("id")
);
