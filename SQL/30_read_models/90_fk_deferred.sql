-- SALUD v4.0.10 · módulo 30 · schema read_models
-- Generado de diagram_30_read_models.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   frontend_page_views.field_mask_policy_id


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."portal_surfaces"
        ADD CONSTRAINT "fk_portal_surfaces_portal_type_concept_id" FOREIGN KEY ("portal_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."portal_surfaces"
        ADD CONSTRAINT "fk_portal_surfaces_audience_role_value_set_id" FOREIGN KEY ("audience_role_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."portal_surfaces"
        ADD CONSTRAINT "fk_portal_surfaces_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."portal_surfaces"
        ADD CONSTRAINT "fk_portal_surfaces_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."portal_surfaces"
        ADD CONSTRAINT "fk_portal_surfaces_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_routes"
        ADD CONSTRAINT "fk_frontend_routes_required_permission_id" FOREIGN KEY ("required_permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_routes"
        ADD CONSTRAINT "fk_frontend_routes_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_routes"
        ADD CONSTRAINT "fk_frontend_routes_cache_policy_concept_id" FOREIGN KEY ("cache_policy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_routes"
        ADD CONSTRAINT "fk_frontend_routes_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_routes"
        ADD CONSTRAINT "fk_frontend_routes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_routes"
        ADD CONSTRAINT "fk_frontend_routes_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_definitions"
        ADD CONSTRAINT "fk_read_model_definitions_object_type_concept_id" FOREIGN KEY ("object_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_definitions"
        ADD CONSTRAINT "fk_read_model_definitions_refresh_mode_concept_id" FOREIGN KEY ("refresh_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_definitions"
        ADD CONSTRAINT "fk_read_model_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_definitions"
        ADD CONSTRAINT "fk_read_model_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_definitions"
        ADD CONSTRAINT "fk_read_model_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_dependencies"
        ADD CONSTRAINT "fk_read_model_dependencies_dependency_type_concept_id" FOREIGN KEY ("dependency_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_page_views"
        ADD CONSTRAINT "fk_frontend_page_views_view_type_concept_id" FOREIGN KEY ("view_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_page_views"
        ADD CONSTRAINT "fk_frontend_page_views_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_page_views"
        ADD CONSTRAINT "fk_frontend_page_views_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_page_views"
        ADD CONSTRAINT "fk_frontend_page_views_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_fields"
        ADD CONSTRAINT "fk_frontend_view_fields_display_component_concept_id" FOREIGN KEY ("display_component_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_fields"
        ADD CONSTRAINT "fk_frontend_view_fields_permission_id" FOREIGN KEY ("permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_fields"
        ADD CONSTRAINT "fk_frontend_view_fields_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_fields"
        ADD CONSTRAINT "fk_frontend_view_fields_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_fields"
        ADD CONSTRAINT "fk_frontend_view_fields_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_operator_value_set_id" FOREIGN KEY ("operator_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_input_type_concept_id" FOREIGN KEY ("input_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_value_set_id" FOREIGN KEY ("value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_context.dynamic_enum_definitions (requiere schema system_context)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_dynamic_enum_definition_id" FOREIGN KEY ("dynamic_enum_definition_id")
        REFERENCES "system_context"."dynamic_enum_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_filters"
        ADD CONSTRAINT "fk_frontend_view_filters_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_sort_options"
        ADD CONSTRAINT "fk_frontend_view_sort_options_direction_concept_id" FOREIGN KEY ("direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_sort_options"
        ADD CONSTRAINT "fk_frontend_view_sort_options_nulls_position_concept_id" FOREIGN KEY ("nulls_position_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_sort_options"
        ADD CONSTRAINT "fk_frontend_view_sort_options_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_sort_options"
        ADD CONSTRAINT "fk_frontend_view_sort_options_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_sort_options"
        ADD CONSTRAINT "fk_frontend_view_sort_options_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_action_type_concept_id" FOREIGN KEY ("action_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_required_permission_id" FOREIGN KEY ("required_permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_allowed_state_value_set_id" FOREIGN KEY ("allowed_state_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_confirmation_policy_concept_id" FOREIGN KEY ("confirmation_policy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_prominence_concept_id" FOREIGN KEY ("prominence_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_actions"
        ADD CONSTRAINT "fk_frontend_view_actions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_kpis"
        ADD CONSTRAINT "fk_frontend_view_kpis_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_kpis"
        ADD CONSTRAINT "fk_frontend_view_kpis_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_kpis"
        ADD CONSTRAINT "fk_frontend_view_kpis_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_kpis"
        ADD CONSTRAINT "fk_frontend_view_kpis_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_states"
        ADD CONSTRAINT "fk_frontend_view_states_state_type_concept_id" FOREIGN KEY ("state_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_states"
        ADD CONSTRAINT "fk_frontend_view_states_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_states"
        ADD CONSTRAINT "fk_frontend_view_states_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."frontend_view_states"
        ADD CONSTRAINT "fk_frontend_view_states_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."user_view_preferences"
        ADD CONSTRAINT "fk_user_view_preferences_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "read_models"."user_view_preferences"
        ADD CONSTRAINT "fk_user_view_preferences_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."user_view_preferences"
        ADD CONSTRAINT "fk_user_view_preferences_density_concept_id" FOREIGN KEY ("density_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."user_view_preferences"
        ADD CONSTRAINT "fk_user_view_preferences_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."user_view_preferences"
        ADD CONSTRAINT "fk_user_view_preferences_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "read_models"."user_view_preferences"
        ADD CONSTRAINT "fk_user_view_preferences_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_refresh_runs"
        ADD CONSTRAINT "fk_read_model_refresh_runs_refresh_type_concept_id" FOREIGN KEY ("refresh_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "read_models"."read_model_refresh_runs"
        ADD CONSTRAINT "fk_read_model_refresh_runs_result_concept_id" FOREIGN KEY ("result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
