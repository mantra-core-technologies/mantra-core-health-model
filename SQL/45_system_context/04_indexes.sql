-- SALUD v4.0.10 · módulo 45 · schema system_context
-- Generado de diagram_45_system_context.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_system_contexts_code" ON "system_context"."system_contexts" ("code");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_context_type_concept_id" ON "system_context"."system_contexts" ("context_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_scope_type_concept_id" ON "system_context"."system_contexts" ("scope_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_tenant_id" ON "system_context"."system_contexts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_country_concept_id" ON "system_context"."system_contexts" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_locale_concept_id" ON "system_context"."system_contexts" ("locale_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_current_version_id" ON "system_context"."system_contexts" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_refresh_policy_concept_id" ON "system_context"."system_contexts" ("refresh_policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_status_concept_id" ON "system_context"."system_contexts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_created_by_user_id" ON "system_context"."system_contexts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_updated_by_user_id" ON "system_context"."system_contexts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_system_contexts_tenant_id_status_concept_id" ON "system_context"."system_contexts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_system_context_refresh_runs_idempotency_key" ON "system_context"."system_context_refresh_runs" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_system_context_refresh_runs_system_context_id" ON "system_context"."system_context_refresh_runs" ("system_context_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_refresh_runs_trigger_concept_id" ON "system_context"."system_context_refresh_runs" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_refresh_runs_status_concept_id" ON "system_context"."system_context_refresh_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_refresh_runs_recorded_by_user_id" ON "system_context"."system_context_refresh_runs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_system_context_refresh_runs_recorded_at" ON "system_context"."system_context_refresh_runs" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_system_context_versions_system_context_id" ON "system_context"."system_context_versions" ("system_context_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_versions_refresh_run_id" ON "system_context"."system_context_versions" ("refresh_run_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_versions_generated_by_agent_id" ON "system_context"."system_context_versions" ("generated_by_agent_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_versions_status_concept_id" ON "system_context"."system_context_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_versions_recorded_by_user_id" ON "system_context"."system_context_versions" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_system_context_versions_system_context_id_version_number" ON "system_context"."system_context_versions" ("system_context_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_system_context_inputs_system_context_version_id" ON "system_context"."system_context_inputs" ("system_context_version_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_inputs_source_type_concept_id" ON "system_context"."system_context_inputs" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_inputs_recorded_by_user_id" ON "system_context"."system_context_inputs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_system_context_inputs_recorded_at" ON "system_context"."system_context_inputs" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_system_context_id" ON "system_context"."system_context_bindings" ("system_context_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_consumer_type_concept_id" ON "system_context"."system_context_bindings" ("consumer_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_tenant_id" ON "system_context"."system_context_bindings" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_country_concept_id" ON "system_context"."system_context_bindings" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_status_concept_id" ON "system_context"."system_context_bindings" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_created_by_user_id" ON "system_context"."system_context_bindings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_updated_by_user_id" ON "system_context"."system_context_bindings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_system_context_bindings_tenant_id_status_concept_id" ON "system_context"."system_context_bindings" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_dynamic_enum_definitions_code" ON "system_context"."dynamic_enum_definitions" ("code");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_value_set_id" ON "system_context"."dynamic_enum_definitions" ("value_set_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_scope_type_concept_id" ON "system_context"."dynamic_enum_definitions" ("scope_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_tenant_id" ON "system_context"."dynamic_enum_definitions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_country_concept_id" ON "system_context"."dynamic_enum_definitions" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_selection_mode_concept_id" ON "system_context"."dynamic_enum_definitions" ("selection_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_status_concept_id" ON "system_context"."dynamic_enum_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_created_by_user_id" ON "system_context"."dynamic_enum_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_updated_by_user_id" ON "system_context"."dynamic_enum_definitions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_definitions_tenant_id_status_concept_id" ON "system_context"."dynamic_enum_definitions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_versions_dynamic_enum_definition_id" ON "system_context"."dynamic_enum_versions" ("dynamic_enum_definition_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_versions_value_set_version_id" ON "system_context"."dynamic_enum_versions" ("value_set_version_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_versions_status_concept_id" ON "system_context"."dynamic_enum_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_versions_recorded_by_user_id" ON "system_context"."dynamic_enum_versions" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_dynamic_enum_versions_dynamic_enum_definition_id_ve_fe5c676f" ON "system_context"."dynamic_enum_versions" ("dynamic_enum_definition_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_options_dynamic_enum_version_id" ON "system_context"."dynamic_enum_options" ("dynamic_enum_version_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_options_concept_id" ON "system_context"."dynamic_enum_options" ("concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_options_recorded_by_user_id" ON "system_context"."dynamic_enum_options" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_dynamic_enum_options_recorded_at" ON "system_context"."dynamic_enum_options" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_bindings_dynamic_enum_definition_id" ON "system_context"."dynamic_enum_bindings" ("dynamic_enum_definition_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_bindings_system_context_id" ON "system_context"."dynamic_enum_bindings" ("system_context_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_bindings_fallback_concept_id" ON "system_context"."dynamic_enum_bindings" ("fallback_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_bindings_validation_mode_concept_id" ON "system_context"."dynamic_enum_bindings" ("validation_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_bindings_status_concept_id" ON "system_context"."dynamic_enum_bindings" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_bindings_created_by_user_id" ON "system_context"."dynamic_enum_bindings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dynamic_enum_bindings_updated_by_user_id" ON "system_context"."dynamic_enum_bindings" ("updated_by_user_id");
