-- SALUD v4.0.10 · módulo 44 · schema health_context
-- Generado de diagram_44_health_context.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_context_agents_code" ON "health_context"."context_agents" ("code");

CREATE INDEX IF NOT EXISTS "ix_context_agents_agent_type_concept_id" ON "health_context"."context_agents" ("agent_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_agents_provider_id" ON "health_context"."context_agents" ("provider_id");

CREATE INDEX IF NOT EXISTS "ix_context_agents_owner_tenant_id" ON "health_context"."context_agents" ("owner_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_context_agents_status_concept_id" ON "health_context"."context_agents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_agents_created_by_user_id" ON "health_context"."context_agents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_context_agents_updated_by_user_id" ON "health_context"."context_agents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_country_context_schedules_country_concept_id" ON "health_context"."country_context_schedules" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_country_context_schedules_agent_id" ON "health_context"."country_context_schedules" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_country_context_schedules_timezone_concept_id" ON "health_context"."country_context_schedules" ("timezone_concept_id");

CREATE INDEX IF NOT EXISTS "ix_country_context_schedules_status_concept_id" ON "health_context"."country_context_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_country_context_schedules_created_by_user_id" ON "health_context"."country_context_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_country_context_schedules_updated_by_user_id" ON "health_context"."country_context_schedules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_health_context_sources_code" ON "health_context"."health_context_sources" ("code");

CREATE INDEX IF NOT EXISTS "ix_health_context_sources_source_type_concept_id" ON "health_context"."health_context_sources" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_sources_country_concept_id" ON "health_context"."health_context_sources" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_sources_trust_tier_concept_id" ON "health_context"."health_context_sources" ("trust_tier_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_sources_status_concept_id" ON "health_context"."health_context_sources" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_sources_created_by_user_id" ON "health_context"."health_context_sources" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_sources_updated_by_user_id" ON "health_context"."health_context_sources" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_context_collection_runs_idempotency_key" ON "health_context"."context_collection_runs" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_context_collection_runs_schedule_id" ON "health_context"."context_collection_runs" ("schedule_id");

CREATE INDEX IF NOT EXISTS "ix_context_collection_runs_agent_id" ON "health_context"."context_collection_runs" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_context_collection_runs_country_concept_id" ON "health_context"."context_collection_runs" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_collection_runs_trigger_concept_id" ON "health_context"."context_collection_runs" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_collection_runs_status_concept_id" ON "health_context"."context_collection_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_collection_runs_recorded_by_user_id" ON "health_context"."context_collection_runs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_context_collection_runs_recorded_at" ON "health_context"."context_collection_runs" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_context_source_observations_collection_run_id" ON "health_context"."context_source_observations" ("collection_run_id");

CREATE INDEX IF NOT EXISTS "ix_context_source_observations_source_id" ON "health_context"."context_source_observations" ("source_id");

CREATE INDEX IF NOT EXISTS "ix_context_source_observations_country_concept_id" ON "health_context"."context_source_observations" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_source_observations_raw_payload_file_id" ON "health_context"."context_source_observations" ("raw_payload_file_id");

CREATE INDEX IF NOT EXISTS "ix_context_source_observations_status_concept_id" ON "health_context"."context_source_observations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_source_observations_recorded_by_user_id" ON "health_context"."context_source_observations" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_context_source_observations_recorded_at" ON "health_context"."context_source_observations" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_country_health_contexts_country_concept_id" ON "health_context"."country_health_contexts" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_contexts_context_domain_concept_id" ON "health_context"."country_health_contexts" ("context_domain_concept_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_contexts_current_version_id" ON "health_context"."country_health_contexts" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_contexts_status_concept_id" ON "health_context"."country_health_contexts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_contexts_created_by_user_id" ON "health_context"."country_health_contexts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_contexts_updated_by_user_id" ON "health_context"."country_health_contexts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_context_versions_country_health_context_id" ON "health_context"."country_health_context_versions" ("country_health_context_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_context_versions_collection_run_id" ON "health_context"."country_health_context_versions" ("collection_run_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_context_versions_status_concept_id" ON "health_context"."country_health_context_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_country_health_context_versions_recorded_by_user_id" ON "health_context"."country_health_context_versions" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_country_health_context_versions_country_health_cont_2ef6a520" ON "health_context"."country_health_context_versions" ("country_health_context_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_health_context_facts_context_version_id" ON "health_context"."health_context_facts" ("context_version_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_facts_metric_concept_id" ON "health_context"."health_context_facts" ("metric_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_facts_unit_concept_id" ON "health_context"."health_context_facts" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_facts_status_concept_id" ON "health_context"."health_context_facts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_context_facts_recorded_by_user_id" ON "health_context"."health_context_facts" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_health_context_facts_recorded_at" ON "health_context"."health_context_facts" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_context_fact_evidence_health_context_fact_id" ON "health_context"."context_fact_evidence" ("health_context_fact_id");

CREATE INDEX IF NOT EXISTS "ix_context_fact_evidence_source_observation_id" ON "health_context"."context_fact_evidence" ("source_observation_id");

CREATE INDEX IF NOT EXISTS "ix_context_fact_evidence_recorded_by_user_id" ON "health_context"."context_fact_evidence" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_context_fact_evidence_recorded_at" ON "health_context"."context_fact_evidence" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_context_quality_reviews_context_version_id" ON "health_context"."context_quality_reviews" ("context_version_id");

CREATE INDEX IF NOT EXISTS "ix_context_quality_reviews_reviewer_agent_id" ON "health_context"."context_quality_reviews" ("reviewer_agent_id");

CREATE INDEX IF NOT EXISTS "ix_context_quality_reviews_reviewed_by_user_id" ON "health_context"."context_quality_reviews" ("reviewed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_context_quality_reviews_review_type_concept_id" ON "health_context"."context_quality_reviews" ("review_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_context_quality_reviews_outcome_concept_id" ON "health_context"."context_quality_reviews" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "brin_context_quality_reviews_recorded_at" ON "health_context"."context_quality_reviews" USING brin ("recorded_at") WITH (pages_per_range=128);
