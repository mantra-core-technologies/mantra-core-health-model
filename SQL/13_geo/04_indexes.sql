-- SALUD v4.0.10 · módulo 13 · schema geo
-- Generado de diagram_13_geo.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_tracked_subjects_subject_type_concept_id" ON "geo"."tracked_subjects" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_subjects_device_id" ON "geo"."tracked_subjects" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_subjects_tenant_id" ON "geo"."tracked_subjects" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_subjects_state_concept_id" ON "geo"."tracked_subjects" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_subjects_created_by_user_id" ON "geo"."tracked_subjects" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_subjects_updated_by_user_id" ON "geo"."tracked_subjects" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracked_subjects_tenant_id_state_concept_id" ON "geo"."tracked_subjects" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_location_pings_tracked_subject_id" ON "geo"."location_pings" ("tracked_subject_id");

CREATE INDEX IF NOT EXISTS "ix_location_pings_device_id" ON "geo"."location_pings" ("device_id");

CREATE INDEX IF NOT EXISTS "ix_location_pings_network_concept_id" ON "geo"."location_pings" ("network_concept_id");

CREATE INDEX IF NOT EXISTS "ix_location_pings_recorded_by_user_id" ON "geo"."location_pings" ("recorded_by_user_id");

-- OMITIDO "gist_location_pings_location" (geography_point) gist: columna(s) ['geography_point'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "brin_location_pings_recorded_at" ON "geo"."location_pings" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_tracking_sessions_tracked_subject_id" ON "geo"."tracking_sessions" ("tracked_subject_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_sessions_purpose_concept_id" ON "geo"."tracking_sessions" ("purpose_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_sessions_status_concept_id" ON "geo"."tracking_sessions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_sessions_created_by_user_id" ON "geo"."tracking_sessions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_sessions_updated_by_user_id" ON "geo"."tracking_sessions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_geofences_tenant_id" ON "geo"."geofences" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_geofences_shape_type_concept_id" ON "geo"."geofences" ("shape_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_geofences_state_concept_id" ON "geo"."geofences" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_geofences_created_by_user_id" ON "geo"."geofences" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_geofences_updated_by_user_id" ON "geo"."geofences" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_geofences_tenant_id_state_concept_id" ON "geo"."geofences" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_geofence_events_geofence_id" ON "geo"."geofence_events" ("geofence_id");

CREATE INDEX IF NOT EXISTS "ix_geofence_events_tracked_subject_id" ON "geo"."geofence_events" ("tracked_subject_id");

CREATE INDEX IF NOT EXISTS "ix_geofence_events_event_type_concept_id" ON "geo"."geofence_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_geofence_events_location_ping_id" ON "geo"."geofence_events" ("location_ping_id");

CREATE INDEX IF NOT EXISTS "ix_geofence_events_recorded_by_user_id" ON "geo"."geofence_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_geofence_events_recorded_at" ON "geo"."geofence_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_trips_tracking_session_id" ON "geo"."trips" ("tracking_session_id");

CREATE INDEX IF NOT EXISTS "ix_trips_origin_address_id" ON "geo"."trips" ("origin_address_id");

CREATE INDEX IF NOT EXISTS "ix_trips_destination_address_id" ON "geo"."trips" ("destination_address_id");

CREATE INDEX IF NOT EXISTS "ix_trips_status_concept_id" ON "geo"."trips" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_trips_created_by_user_id" ON "geo"."trips" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_trips_updated_by_user_id" ON "geo"."trips" ("updated_by_user_id");
