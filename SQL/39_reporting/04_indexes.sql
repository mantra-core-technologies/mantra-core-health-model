-- SALUD v4.0.10 · módulo 39 · schema reporting
-- Generado de diagram_39_reporting.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_report_data_sources_code" ON "reporting"."report_data_sources" ("code");

CREATE INDEX IF NOT EXISTS "ix_report_data_sources_tenant_id" ON "reporting"."report_data_sources" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_report_data_sources_source_type_concept_id" ON "reporting"."report_data_sources" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_data_sources_read_model_definition_id" ON "reporting"."report_data_sources" ("read_model_definition_id");

CREATE INDEX IF NOT EXISTS "ix_report_data_sources_state_concept_id" ON "reporting"."report_data_sources" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_data_sources_created_by_user_id" ON "reporting"."report_data_sources" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_data_sources_updated_by_user_id" ON "reporting"."report_data_sources" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_data_sources_tenant_id_state_concept_id" ON "reporting"."report_data_sources" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_report_data_sources_search" ON "reporting"."report_data_sources" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_report_definitions_code" ON "reporting"."report_definitions" ("code");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_tenant_id" ON "reporting"."report_definitions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_category_concept_id" ON "reporting"."report_definitions" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_data_source_id" ON "reporting"."report_definitions" ("data_source_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_default_output_format_concept_id" ON "reporting"."report_definitions" ("default_output_format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_required_permission_id" ON "reporting"."report_definitions" ("required_permission_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_state_concept_id" ON "reporting"."report_definitions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_created_by_user_id" ON "reporting"."report_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_updated_by_user_id" ON "reporting"."report_definitions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_definitions_tenant_id_state_concept_id" ON "reporting"."report_definitions" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_report_definitions_search" ON "reporting"."report_definitions" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_report_versions_report_definition_id" ON "reporting"."report_versions" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_report_versions_status_concept_id" ON "reporting"."report_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_versions_created_by_user_id" ON "reporting"."report_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_versions_updated_by_user_id" ON "reporting"."report_versions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_report_versions_report_definition_id_version" ON "reporting"."report_versions" ("report_definition_id", "version");

CREATE INDEX IF NOT EXISTS "ix_report_parameters_report_definition_id" ON "reporting"."report_parameters" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_report_parameters_value_set_id" ON "reporting"."report_parameters" ("value_set_id");

CREATE INDEX IF NOT EXISTS "ix_report_parameters_created_by_user_id" ON "reporting"."report_parameters" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_parameters_updated_by_user_id" ON "reporting"."report_parameters" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_report_parameters_search" ON "reporting"."report_parameters" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_report_columns_report_definition_id" ON "reporting"."report_columns" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_report_columns_aggregation_concept_id" ON "reporting"."report_columns" ("aggregation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_columns_created_by_user_id" ON "reporting"."report_columns" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_columns_updated_by_user_id" ON "reporting"."report_columns" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_report_columns_search" ON "reporting"."report_columns" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_report_schedules_report_definition_id" ON "reporting"."report_schedules" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_tenant_id" ON "reporting"."report_schedules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_output_format_concept_id" ON "reporting"."report_schedules" ("output_format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_state_concept_id" ON "reporting"."report_schedules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_created_by_user_id" ON "reporting"."report_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_updated_by_user_id" ON "reporting"."report_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_schedules_tenant_id_state_concept_id" ON "reporting"."report_schedules" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_report_schedules_search" ON "reporting"."report_schedules" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_report_executions_report_definition_id" ON "reporting"."report_executions" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_report_version_id" ON "reporting"."report_executions" ("report_version_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_schedule_id" ON "reporting"."report_executions" ("schedule_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_tenant_id" ON "reporting"."report_executions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_trigger_concept_id" ON "reporting"."report_executions" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_requested_by_user_id" ON "reporting"."report_executions" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_status_concept_id" ON "reporting"."report_executions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_output_format_concept_id" ON "reporting"."report_executions" ("output_format_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_output_file_id" ON "reporting"."report_executions" ("output_file_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_created_by_user_id" ON "reporting"."report_executions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_updated_by_user_id" ON "reporting"."report_executions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_executions_tenant_id_status_concept_id" ON "reporting"."report_executions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_report_snapshots_report_execution_id" ON "reporting"."report_snapshots" ("report_execution_id");

CREATE INDEX IF NOT EXISTS "ix_report_snapshots_created_by_user_id" ON "reporting"."report_snapshots" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_snapshots_updated_by_user_id" ON "reporting"."report_snapshots" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_schedule_id" ON "reporting"."report_distributions" ("schedule_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_report_execution_id" ON "reporting"."report_distributions" ("report_execution_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_recipient_type_concept_id" ON "reporting"."report_distributions" ("recipient_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_recipient_user_id" ON "reporting"."report_distributions" ("recipient_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_channel_id" ON "reporting"."report_distributions" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_status_concept_id" ON "reporting"."report_distributions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_created_by_user_id" ON "reporting"."report_distributions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_distributions_updated_by_user_id" ON "reporting"."report_distributions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_subscriptions_report_schedule_id" ON "reporting"."report_subscriptions" ("report_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_report_subscriptions_subscriber_user_id" ON "reporting"."report_subscriptions" ("subscriber_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_subscriptions_channel_id" ON "reporting"."report_subscriptions" ("channel_id");

CREATE INDEX IF NOT EXISTS "ix_report_subscriptions_created_by_user_id" ON "reporting"."report_subscriptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_report_subscriptions_updated_by_user_id" ON "reporting"."report_subscriptions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_dashboards_code" ON "reporting"."dashboards" ("code");

CREATE INDEX IF NOT EXISTS "ix_dashboards_tenant_id" ON "reporting"."dashboards" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_dashboards_required_permission_id" ON "reporting"."dashboards" ("required_permission_id");

CREATE INDEX IF NOT EXISTS "ix_dashboards_state_concept_id" ON "reporting"."dashboards" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dashboards_created_by_user_id" ON "reporting"."dashboards" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dashboards_updated_by_user_id" ON "reporting"."dashboards" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dashboards_tenant_id_state_concept_id" ON "reporting"."dashboards" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_dashboards_search" ON "reporting"."dashboards" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_dashboard_widgets_dashboard_id" ON "reporting"."dashboard_widgets" ("dashboard_id");

CREATE INDEX IF NOT EXISTS "ix_dashboard_widgets_report_definition_id" ON "reporting"."dashboard_widgets" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_dashboard_widgets_widget_type_concept_id" ON "reporting"."dashboard_widgets" ("widget_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dashboard_widgets_visualization_concept_id" ON "reporting"."dashboard_widgets" ("visualization_concept_id");

CREATE INDEX IF NOT EXISTS "ix_dashboard_widgets_created_by_user_id" ON "reporting"."dashboard_widgets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_dashboard_widgets_updated_by_user_id" ON "reporting"."dashboard_widgets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_dashboard_widgets_search" ON "reporting"."dashboard_widgets" USING gin (to_tsvector('simple', (coalesce(title, ''))));
