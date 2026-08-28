-- SALUD v4.0.10 · módulo 39 · schema reporting
-- Generado de diagram_39_reporting.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_data_sources"
        ADD CONSTRAINT "fk_report_data_sources_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_data_sources"
        ADD CONSTRAINT "fk_report_data_sources_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: read_models.read_model_definitions (requiere schema read_models)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_data_sources"
        ADD CONSTRAINT "fk_report_data_sources_read_model_definition_id" FOREIGN KEY ("read_model_definition_id")
        REFERENCES "read_models"."read_model_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_data_sources"
        ADD CONSTRAINT "fk_report_data_sources_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_data_sources"
        ADD CONSTRAINT "fk_report_data_sources_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_data_sources"
        ADD CONSTRAINT "fk_report_data_sources_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_default_output_format_concept_id" FOREIGN KEY ("default_output_format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_required_permission_id" FOREIGN KEY ("required_permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_versions"
        ADD CONSTRAINT "fk_report_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_versions"
        ADD CONSTRAINT "fk_report_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_versions"
        ADD CONSTRAINT "fk_report_versions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_parameters"
        ADD CONSTRAINT "fk_report_parameters_value_set_id" FOREIGN KEY ("value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_parameters"
        ADD CONSTRAINT "fk_report_parameters_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_parameters"
        ADD CONSTRAINT "fk_report_parameters_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_columns"
        ADD CONSTRAINT "fk_report_columns_aggregation_concept_id" FOREIGN KEY ("aggregation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_columns"
        ADD CONSTRAINT "fk_report_columns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_columns"
        ADD CONSTRAINT "fk_report_columns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_schedules"
        ADD CONSTRAINT "fk_report_schedules_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_schedules"
        ADD CONSTRAINT "fk_report_schedules_output_format_concept_id" FOREIGN KEY ("output_format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_schedules"
        ADD CONSTRAINT "fk_report_schedules_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_schedules"
        ADD CONSTRAINT "fk_report_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_schedules"
        ADD CONSTRAINT "fk_report_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_trigger_concept_id" FOREIGN KEY ("trigger_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_output_format_concept_id" FOREIGN KEY ("output_format_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_output_file_id" FOREIGN KEY ("output_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_snapshots"
        ADD CONSTRAINT "fk_report_snapshots_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_snapshots"
        ADD CONSTRAINT "fk_report_snapshots_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_recipient_type_concept_id" FOREIGN KEY ("recipient_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_recipient_user_id" FOREIGN KEY ("recipient_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.message_channels (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_subscriptions"
        ADD CONSTRAINT "fk_report_subscriptions_subscriber_user_id" FOREIGN KEY ("subscriber_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: messaging.message_channels (requiere schema messaging)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_subscriptions"
        ADD CONSTRAINT "fk_report_subscriptions_channel_id" FOREIGN KEY ("channel_id")
        REFERENCES "messaging"."message_channels" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_subscriptions"
        ADD CONSTRAINT "fk_report_subscriptions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."report_subscriptions"
        ADD CONSTRAINT "fk_report_subscriptions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboards"
        ADD CONSTRAINT "fk_dashboards_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboards"
        ADD CONSTRAINT "fk_dashboards_required_permission_id" FOREIGN KEY ("required_permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboards"
        ADD CONSTRAINT "fk_dashboards_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboards"
        ADD CONSTRAINT "fk_dashboards_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboards"
        ADD CONSTRAINT "fk_dashboards_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboard_widgets"
        ADD CONSTRAINT "fk_dashboard_widgets_widget_type_concept_id" FOREIGN KEY ("widget_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboard_widgets"
        ADD CONSTRAINT "fk_dashboard_widgets_visualization_concept_id" FOREIGN KEY ("visualization_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboard_widgets"
        ADD CONSTRAINT "fk_dashboard_widgets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "reporting"."dashboard_widgets"
        ADD CONSTRAINT "fk_dashboard_widgets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
