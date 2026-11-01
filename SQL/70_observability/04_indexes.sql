-- SALUD v4.2.83 · módulo 70 · schema observability
-- Generado de diagram_70_observability.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_instances_kind_last_seen" ON "observability"."instances" ("kind", "last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_instances_name" ON "observability"."instances" ("name");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_error_groups_fingerprint" ON "observability"."error_groups" ("fingerprint");

CREATE INDEX IF NOT EXISTS "ix_error_groups_state_last_seen" ON "observability"."error_groups" ("state_concept_id", "last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_groups_module_last_seen" ON "observability"."error_groups" ("module_code", "last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_groups_code" ON "observability"."error_groups" ("error_code", "error_reason");

CREATE INDEX IF NOT EXISTS "ix_error_groups_assigned_to_user_id" ON "observability"."error_groups" ("assigned_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_groups_resolved_by_user_id" ON "observability"."error_groups" ("resolved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_groups_created_by_user_id" ON "observability"."error_groups" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_groups_updated_by_user_id" ON "observability"."error_groups" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_events_group_time" ON "observability"."error_events" ("error_group_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_events_module_time" ON "observability"."error_events" ("module_code", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_events_request_id" ON "observability"."error_events" ("request_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_events_instance_time" ON "observability"."error_events" ("instance_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_error_events_time" ON "observability"."error_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_http_minute_module_time" ON "observability"."http_request_minute_series" ("module_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_http_minute_route_time" ON "observability"."http_request_minute_series" ("route_template", "http_method", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_http_minute_time" ON "observability"."http_request_minute_series" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_sql_statements_primary_table" ON "observability"."sql_statements" ("primary_table");

CREATE INDEX IF NOT EXISTS "ix_sql_statements_last_seen" ON "observability"."sql_statements" ("last_seen_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_sql_minute_hash_time" ON "observability"."sql_statement_minute_series" ("query_hash", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_sql_minute_module_time" ON "observability"."sql_statement_minute_series" ("module_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_sql_minute_time" ON "observability"."sql_statement_minute_series" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_worker_tick_worker_time" ON "observability"."worker_tick_minute_series" ("worker_name", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_worker_tick_time" ON "observability"."worker_tick_minute_series" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_slow_request_request_id" ON "observability"."slow_request_samples" ("request_id");

CREATE INDEX IF NOT EXISTS "ix_slow_request_module_time" ON "observability"."slow_request_samples" ("module_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "brin_slow_request_time" ON "observability"."slow_request_samples" USING brin ("time") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_dependency_probe_code_time" ON "observability"."dependency_probe_runs" ("dependency_code", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_dependency_probe_service_component_id" ON "observability"."dependency_probe_runs" ("service_component_id");

CREATE INDEX IF NOT EXISTS "brin_dependency_probe_time" ON "observability"."dependency_probe_runs" USING brin ("time") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_alert_rules_code" ON "observability"."alert_rules" ("code");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_severity_concept_id" ON "observability"."alert_rules" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_enabled_module" ON "observability"."alert_rules" ("enabled", "module_code");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_created_by_user_id" ON "observability"."alert_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_alert_rules_updated_by_user_id" ON "observability"."alert_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_alert_evaluations_rule_time" ON "observability"."alert_evaluations" ("alert_rule_id", "time" DESC);

CREATE INDEX IF NOT EXISTS "ix_alert_evaluations_health_incident_id" ON "observability"."alert_evaluations" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "brin_alert_evaluations_time" ON "observability"."alert_evaluations" USING brin ("time") WITH (pages_per_range=128);
