-- SALUD v4.0.10 · módulo 30 · schema read_models
-- Generado de diagram_30_read_models.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_routes"
        ADD CONSTRAINT "fk_frontend_routes_portal_surface_id" FOREIGN KEY ("portal_surface_id")
        REFERENCES "read_models"."portal_surfaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_dependencies"
        ADD CONSTRAINT "fk_read_model_dependencies_read_model_definition_id" FOREIGN KEY ("read_model_definition_id")
        REFERENCES "read_models"."read_model_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_page_views"
        ADD CONSTRAINT "fk_frontend_page_views_frontend_route_id" FOREIGN KEY ("frontend_route_id")
        REFERENCES "read_models"."frontend_routes" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_page_views"
        ADD CONSTRAINT "fk_frontend_page_views_read_model_definition_id" FOREIGN KEY ("read_model_definition_id")
        REFERENCES "read_models"."read_model_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_fields"
        ADD CONSTRAINT "fk_frontend_view_fields_frontend_page_view_id" FOREIGN KEY ("frontend_page_view_id")
        REFERENCES "read_models"."frontend_page_views" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_frontend_page_view_id" FOREIGN KEY ("frontend_page_view_id")
        REFERENCES "read_models"."frontend_page_views" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_sort_options"
        ADD CONSTRAINT "fk_frontend_view_sort_options_frontend_page_view_id" FOREIGN KEY ("frontend_page_view_id")
        REFERENCES "read_models"."frontend_page_views" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_frontend_page_view_id" FOREIGN KEY ("frontend_page_view_id")
        REFERENCES "read_models"."frontend_page_views" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_kpis"
        ADD CONSTRAINT "fk_frontend_view_kpis_frontend_page_view_id" FOREIGN KEY ("frontend_page_view_id")
        REFERENCES "read_models"."frontend_page_views" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_states"
        ADD CONSTRAINT "fk_frontend_view_states_frontend_page_view_id" FOREIGN KEY ("frontend_page_view_id")
        REFERENCES "read_models"."frontend_page_views" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."user_view_preferences"
        ADD CONSTRAINT "fk_user_view_preferences_frontend_page_view_id" FOREIGN KEY ("frontend_page_view_id")
        REFERENCES "read_models"."frontend_page_views" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_refresh_runs"
        ADD CONSTRAINT "fk_read_model_refresh_runs_read_model_definition_id" FOREIGN KEY ("read_model_definition_id")
        REFERENCES "read_models"."read_model_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
