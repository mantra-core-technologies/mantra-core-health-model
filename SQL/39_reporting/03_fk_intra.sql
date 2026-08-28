-- SALUD v4.0.10 · módulo 39 · schema reporting
-- Generado de diagram_39_reporting.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "reporting"."report_definitions"
        ADD CONSTRAINT "fk_report_definitions_data_source_id" FOREIGN KEY ("data_source_id")
        REFERENCES "reporting"."report_data_sources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_versions"
        ADD CONSTRAINT "fk_report_versions_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_parameters"
        ADD CONSTRAINT "fk_report_parameters_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_columns"
        ADD CONSTRAINT "fk_report_columns_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_schedules"
        ADD CONSTRAINT "fk_report_schedules_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_report_version_id" FOREIGN KEY ("report_version_id")
        REFERENCES "reporting"."report_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_executions"
        ADD CONSTRAINT "fk_report_executions_schedule_id" FOREIGN KEY ("schedule_id")
        REFERENCES "reporting"."report_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_snapshots"
        ADD CONSTRAINT "fk_report_snapshots_report_execution_id" FOREIGN KEY ("report_execution_id")
        REFERENCES "reporting"."report_executions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_schedule_id" FOREIGN KEY ("schedule_id")
        REFERENCES "reporting"."report_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_distributions"
        ADD CONSTRAINT "fk_report_distributions_report_execution_id" FOREIGN KEY ("report_execution_id")
        REFERENCES "reporting"."report_executions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."report_subscriptions"
        ADD CONSTRAINT "fk_report_subscriptions_report_schedule_id" FOREIGN KEY ("report_schedule_id")
        REFERENCES "reporting"."report_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."dashboard_widgets"
        ADD CONSTRAINT "fk_dashboard_widgets_dashboard_id" FOREIGN KEY ("dashboard_id")
        REFERENCES "reporting"."dashboards" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "reporting"."dashboard_widgets"
        ADD CONSTRAINT "fk_dashboard_widgets_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
