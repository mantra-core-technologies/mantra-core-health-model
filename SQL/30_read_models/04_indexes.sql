-- SALUD v4.0.10 · módulo 30 · schema read_models
-- Generado de diagram_30_read_models.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_portal_surfaces_portal_code" ON "read_models"."portal_surfaces" ("portal_code");

CREATE INDEX IF NOT EXISTS "ix_portal_surfaces_portal_type_concept_id" ON "read_models"."portal_surfaces" ("portal_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_portal_surfaces_audience_role_value_set_id" ON "read_models"."portal_surfaces" ("audience_role_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_portal_surfaces_status_concept_id" ON "read_models"."portal_surfaces" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_portal_surfaces_created_by_user_id" ON "read_models"."portal_surfaces" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_portal_surfaces_updated_by_user_id" ON "read_models"."portal_surfaces" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_portal_surfaces_search" ON "read_models"."portal_surfaces" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_frontend_routes_portal_surface_id" ON "read_models"."frontend_routes" ("portal_surface_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_routes_required_permission_id" ON "read_models"."frontend_routes" ("required_permission_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_routes_purpose_of_use_concept_id" ON "read_models"."frontend_routes" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_routes_cache_policy_concept_id" ON "read_models"."frontend_routes" ("cache_policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_routes_status_concept_id" ON "read_models"."frontend_routes" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_routes_created_by_user_id" ON "read_models"."frontend_routes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_routes_updated_by_user_id" ON "read_models"."frontend_routes" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_frontend_routes_portal_code" ON "read_models"."frontend_routes" ("portal_surface_id", "route_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_frontend_routes_pattern" ON "read_models"."frontend_routes" ("portal_surface_id", "route_pattern");

CREATE INDEX IF NOT EXISTS "ix_read_model_definitions_object_type_concept_id" ON "read_models"."read_model_definitions" ("object_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_read_model_definitions_refresh_mode_concept_id" ON "read_models"."read_model_definitions" ("refresh_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_read_model_definitions_status_concept_id" ON "read_models"."read_model_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_read_model_definitions_created_by_user_id" ON "read_models"."read_model_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_read_model_definitions_updated_by_user_id" ON "read_models"."read_model_definitions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_read_model_definition_version" ON "read_models"."read_model_definitions" ("schema_name", "object_name", "version_number");

CREATE INDEX IF NOT EXISTS "ix_read_model_dependencies_read_model_definition_id" ON "read_models"."read_model_dependencies" ("read_model_definition_id");

CREATE INDEX IF NOT EXISTS "ix_read_model_dependencies_dependency_type_concept_id" ON "read_models"."read_model_dependencies" ("dependency_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_page_views_frontend_route_id" ON "read_models"."frontend_page_views" ("frontend_route_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_page_views_read_model_definition_id" ON "read_models"."frontend_page_views" ("read_model_definition_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_page_views_view_type_concept_id" ON "read_models"."frontend_page_views" ("view_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_page_views_field_mask_policy_id" ON "read_models"."frontend_page_views" ("field_mask_policy_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_page_views_status_concept_id" ON "read_models"."frontend_page_views" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_page_views_created_by_user_id" ON "read_models"."frontend_page_views" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_page_views_updated_by_user_id" ON "read_models"."frontend_page_views" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_frontend_page_views_search" ON "read_models"."frontend_page_views" USING gin (to_tsvector('simple', (coalesce(title, '') || ' ' || coalesce(description, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_frontend_page_views_route_code" ON "read_models"."frontend_page_views" ("frontend_route_id", "view_code");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_fields_frontend_page_view_id" ON "read_models"."frontend_view_fields" ("frontend_page_view_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_fields_display_component_concept_id" ON "read_models"."frontend_view_fields" ("display_component_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_fields_permission_id" ON "read_models"."frontend_view_fields" ("permission_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_fields_status_concept_id" ON "read_models"."frontend_view_fields" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_fields_created_by_user_id" ON "read_models"."frontend_view_fields" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_fields_updated_by_user_id" ON "read_models"."frontend_view_fields" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_frontend_view_fields_code" ON "read_models"."frontend_view_fields" ("frontend_page_view_id", "field_code");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_frontend_page_view_id" ON "read_models"."frontend_view_filters" ("frontend_page_view_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_operator_value_set_id" ON "read_models"."frontend_view_filters" ("operator_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_input_type_concept_id" ON "read_models"."frontend_view_filters" ("input_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_value_set_id" ON "read_models"."frontend_view_filters" ("value_set_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_dynamic_enum_definition_id" ON "read_models"."frontend_view_filters" ("dynamic_enum_definition_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_status_concept_id" ON "read_models"."frontend_view_filters" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_created_by_user_id" ON "read_models"."frontend_view_filters" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_filters_updated_by_user_id" ON "read_models"."frontend_view_filters" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_frontend_view_filters_code" ON "read_models"."frontend_view_filters" ("frontend_page_view_id", "filter_code");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_sort_options_frontend_page_view_id" ON "read_models"."frontend_view_sort_options" ("frontend_page_view_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_sort_options_direction_concept_id" ON "read_models"."frontend_view_sort_options" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_sort_options_nulls_position_concept_id" ON "read_models"."frontend_view_sort_options" ("nulls_position_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_sort_options_status_concept_id" ON "read_models"."frontend_view_sort_options" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_sort_options_created_by_user_id" ON "read_models"."frontend_view_sort_options" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_sort_options_updated_by_user_id" ON "read_models"."frontend_view_sort_options" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_frontend_view_sort_code" ON "read_models"."frontend_view_sort_options" ("frontend_page_view_id", "sort_code");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_frontend_page_view_id" ON "read_models"."frontend_view_actions" ("frontend_page_view_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_action_type_concept_id" ON "read_models"."frontend_view_actions" ("action_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_required_permission_id" ON "read_models"."frontend_view_actions" ("required_permission_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_allowed_state_value_set_id" ON "read_models"."frontend_view_actions" ("allowed_state_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_confirmation_policy_concept_id" ON "read_models"."frontend_view_actions" ("confirmation_policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_prominence_concept_id" ON "read_models"."frontend_view_actions" ("prominence_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_status_concept_id" ON "read_models"."frontend_view_actions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_created_by_user_id" ON "read_models"."frontend_view_actions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_actions_updated_by_user_id" ON "read_models"."frontend_view_actions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_frontend_view_actions_code" ON "read_models"."frontend_view_actions" ("frontend_page_view_id", "action_code");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_kpis_frontend_page_view_id" ON "read_models"."frontend_view_kpis" ("frontend_page_view_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_kpis_unit_concept_id" ON "read_models"."frontend_view_kpis" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_kpis_status_concept_id" ON "read_models"."frontend_view_kpis" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_kpis_created_by_user_id" ON "read_models"."frontend_view_kpis" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_kpis_updated_by_user_id" ON "read_models"."frontend_view_kpis" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_states_frontend_page_view_id" ON "read_models"."frontend_view_states" ("frontend_page_view_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_states_state_type_concept_id" ON "read_models"."frontend_view_states" ("state_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_states_status_concept_id" ON "read_models"."frontend_view_states" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_states_created_by_user_id" ON "read_models"."frontend_view_states" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_frontend_view_states_updated_by_user_id" ON "read_models"."frontend_view_states" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_frontend_view_states_search" ON "read_models"."frontend_view_states" USING gin (to_tsvector('simple', (coalesce(title, ''))));

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_user_id" ON "read_models"."user_view_preferences" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_frontend_page_view_id" ON "read_models"."user_view_preferences" ("frontend_page_view_id");

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_tenant_id" ON "read_models"."user_view_preferences" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_density_concept_id" ON "read_models"."user_view_preferences" ("density_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_status_concept_id" ON "read_models"."user_view_preferences" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_created_by_user_id" ON "read_models"."user_view_preferences" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_updated_by_user_id" ON "read_models"."user_view_preferences" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_view_preferences_tenant_id_status_concept_id" ON "read_models"."user_view_preferences" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_read_model_refresh_runs_read_model_definition_id" ON "read_models"."read_model_refresh_runs" ("read_model_definition_id");

CREATE INDEX IF NOT EXISTS "ix_read_model_refresh_runs_refresh_type_concept_id" ON "read_models"."read_model_refresh_runs" ("refresh_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_read_model_refresh_runs_result_concept_id" ON "read_models"."read_model_refresh_runs" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "brin_read_model_refresh_runs_created_at" ON "read_models"."read_model_refresh_runs" USING brin ("created_at") WITH (pages_per_range=128);
