-- SALUD v4.0.10 · módulo 13 · schema geo
-- Generado de diagram_13_geo.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "geo"."location_pings"
        ADD CONSTRAINT "fk_location_pings_tracked_subject_id" FOREIGN KEY ("tracked_subject_id")
        REFERENCES "geo"."tracked_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "geo"."tracking_sessions"
        ADD CONSTRAINT "fk_tracking_sessions_tracked_subject_id" FOREIGN KEY ("tracked_subject_id")
        REFERENCES "geo"."tracked_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "geo"."geofence_events"
        ADD CONSTRAINT "fk_geofence_events_geofence_id" FOREIGN KEY ("geofence_id")
        REFERENCES "geo"."geofences" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "geo"."geofence_events"
        ADD CONSTRAINT "fk_geofence_events_tracked_subject_id" FOREIGN KEY ("tracked_subject_id")
        REFERENCES "geo"."tracked_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "geo"."geofence_events"
        ADD CONSTRAINT "fk_geofence_events_location_ping_id" FOREIGN KEY ("location_ping_id")
        REFERENCES "geo"."location_pings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "geo"."trips"
        ADD CONSTRAINT "fk_trips_tracking_session_id" FOREIGN KEY ("tracking_session_id")
        REFERENCES "geo"."tracking_sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
