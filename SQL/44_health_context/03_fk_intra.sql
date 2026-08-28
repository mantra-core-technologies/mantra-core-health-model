-- SALUD v4.0.10 · módulo 44 · schema health_context
-- Generado de diagram_44_health_context.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "health_context"."context_collection_runs"
        ADD CONSTRAINT "fk_context_collection_runs_schedule_id" FOREIGN KEY ("schedule_id")
        REFERENCES "health_context"."country_context_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."context_source_observations"
        ADD CONSTRAINT "fk_context_source_observations_collection_run_id" FOREIGN KEY ("collection_run_id")
        REFERENCES "health_context"."context_collection_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."context_source_observations"
        ADD CONSTRAINT "fk_context_source_observations_source_id" FOREIGN KEY ("source_id")
        REFERENCES "health_context"."health_context_sources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_contexts"
        ADD CONSTRAINT "fk_country_health_contexts_current_version_id" FOREIGN KEY ("current_version_id")
        REFERENCES "health_context"."country_health_context_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_context_versions"
        ADD CONSTRAINT "fk_country_health_context_versions_country_health_context_id" FOREIGN KEY ("country_health_context_id")
        REFERENCES "health_context"."country_health_contexts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_context_versions"
        ADD CONSTRAINT "fk_country_health_context_versions_collection_run_id" FOREIGN KEY ("collection_run_id")
        REFERENCES "health_context"."context_collection_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_facts"
        ADD CONSTRAINT "fk_health_context_facts_context_version_id" FOREIGN KEY ("context_version_id")
        REFERENCES "health_context"."country_health_context_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."context_fact_evidence"
        ADD CONSTRAINT "fk_context_fact_evidence_health_context_fact_id" FOREIGN KEY ("health_context_fact_id")
        REFERENCES "health_context"."health_context_facts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "health_context"."context_quality_reviews"
        ADD CONSTRAINT "fk_context_quality_reviews_context_version_id" FOREIGN KEY ("context_version_id")
        REFERENCES "health_context"."country_health_context_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
