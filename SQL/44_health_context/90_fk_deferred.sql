-- SALUD v4.0.10 · módulo 44 · schema health_context
-- Generado de diagram_44_health_context.puml — NO editar a mano.


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_agents"
        ADD CONSTRAINT "fk_context_agents_agent_type_concept_id" FOREIGN KEY ("agent_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.external_providers (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_agents"
        ADD CONSTRAINT "fk_context_agents_provider_id" FOREIGN KEY ("provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_agents"
        ADD CONSTRAINT "fk_context_agents_owner_tenant_id" FOREIGN KEY ("owner_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_agents"
        ADD CONSTRAINT "fk_context_agents_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_agents"
        ADD CONSTRAINT "fk_context_agents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_agents"
        ADD CONSTRAINT "fk_context_agents_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_context_schedules"
        ADD CONSTRAINT "fk_country_context_schedules_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.agents (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_context_schedules"
        ADD CONSTRAINT "fk_country_context_schedules_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_context_schedules"
        ADD CONSTRAINT "fk_country_context_schedules_timezone_concept_id" FOREIGN KEY ("timezone_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_context_schedules"
        ADD CONSTRAINT "fk_country_context_schedules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_context_schedules"
        ADD CONSTRAINT "fk_country_context_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_context_schedules"
        ADD CONSTRAINT "fk_country_context_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_sources"
        ADD CONSTRAINT "fk_health_context_sources_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_sources"
        ADD CONSTRAINT "fk_health_context_sources_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_sources"
        ADD CONSTRAINT "fk_health_context_sources_trust_tier_concept_id" FOREIGN KEY ("trust_tier_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_sources"
        ADD CONSTRAINT "fk_health_context_sources_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_sources"
        ADD CONSTRAINT "fk_health_context_sources_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_sources"
        ADD CONSTRAINT "fk_health_context_sources_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.agents (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_collection_runs"
        ADD CONSTRAINT "fk_context_collection_runs_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_collection_runs"
        ADD CONSTRAINT "fk_context_collection_runs_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_collection_runs"
        ADD CONSTRAINT "fk_context_collection_runs_trigger_concept_id" FOREIGN KEY ("trigger_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_collection_runs"
        ADD CONSTRAINT "fk_context_collection_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_collection_runs"
        ADD CONSTRAINT "fk_context_collection_runs_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_source_observations"
        ADD CONSTRAINT "fk_context_source_observations_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_source_observations"
        ADD CONSTRAINT "fk_context_source_observations_raw_payload_file_id" FOREIGN KEY ("raw_payload_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_source_observations"
        ADD CONSTRAINT "fk_context_source_observations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_source_observations"
        ADD CONSTRAINT "fk_context_source_observations_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_contexts"
        ADD CONSTRAINT "fk_country_health_contexts_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_contexts"
        ADD CONSTRAINT "fk_country_health_contexts_context_domain_concept_id" FOREIGN KEY ("context_domain_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_contexts"
        ADD CONSTRAINT "fk_country_health_contexts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_contexts"
        ADD CONSTRAINT "fk_country_health_contexts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_contexts"
        ADD CONSTRAINT "fk_country_health_contexts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_context_versions"
        ADD CONSTRAINT "fk_country_health_context_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."country_health_context_versions"
        ADD CONSTRAINT "fk_country_health_context_versions_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_facts"
        ADD CONSTRAINT "fk_health_context_facts_metric_concept_id" FOREIGN KEY ("metric_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_facts"
        ADD CONSTRAINT "fk_health_context_facts_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_facts"
        ADD CONSTRAINT "fk_health_context_facts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."health_context_facts"
        ADD CONSTRAINT "fk_health_context_facts_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.observations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_fact_evidence"
        ADD CONSTRAINT "fk_context_fact_evidence_source_observation_id" FOREIGN KEY ("source_observation_id")
        REFERENCES "clinical"."observations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_fact_evidence"
        ADD CONSTRAINT "fk_context_fact_evidence_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.agents (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_quality_reviews"
        ADD CONSTRAINT "fk_context_quality_reviews_reviewer_agent_id" FOREIGN KEY ("reviewer_agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_quality_reviews"
        ADD CONSTRAINT "fk_context_quality_reviews_reviewed_by_user_id" FOREIGN KEY ("reviewed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_quality_reviews"
        ADD CONSTRAINT "fk_context_quality_reviews_review_type_concept_id" FOREIGN KEY ("review_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "health_context"."context_quality_reviews"
        ADD CONSTRAINT "fk_context_quality_reviews_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
