-- SALUD v4.0.10 · módulo 30 · schema read_models
-- Generado de diagram_30_read_models.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "read_models"."portal_surfaces" (
    "id" uuid NOT NULL,
    "portal_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "portal_type_concept_id" uuid NOT NULL,
    "audience_role_value_set_id" uuid,
    "tenant_scoped" boolean,
    "patient_scoped" boolean,
    "default_route" varchar,
    "description" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_portal_surfaces" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_routes" (
    "id" uuid NOT NULL,
    "portal_surface_id" uuid NOT NULL,
    "route_code" varchar NOT NULL,
    "route_pattern" varchar NOT NULL,
    "page_title" varchar NOT NULL,
    "navigation_group" varchar,
    "navigation_icon_key" varchar,
    "breadcrumb_json" jsonb,
    "required_permission_id" uuid,
    "purpose_of_use_concept_id" uuid,
    "feature_flag_code" varchar,
    "requires_patient_context" boolean,
    "requires_tenant_context" boolean,
    "cache_policy_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_routes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."read_model_definitions" (
    "id" uuid NOT NULL,
    "schema_name" varchar NOT NULL,
    "object_name" varchar NOT NULL,
    "object_type_concept_id" uuid NOT NULL,
    "owning_module" varchar,
    "purpose_text" text,
    "refresh_mode_concept_id" uuid,
    "maximum_staleness_seconds" integer,
    "default_page_size" integer,
    "maximum_page_size" integer,
    "stable_cursor_columns_json" jsonb,
    "contains_pii" boolean,
    "contains_phi" boolean,
    "security_barrier_required" boolean,
    "row_level_security_required" boolean,
    "definition_hash" varchar,
    "version_number" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_read_model_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."read_model_dependencies" (
    "id" uuid NOT NULL,
    "read_model_definition_id" uuid NOT NULL,
    "source_schema_name" varchar NOT NULL,
    "source_object_name" varchar NOT NULL,
    "dependency_type_concept_id" uuid NOT NULL,
    "selected_columns_json" jsonb,
    "filtering_rule_summary" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_read_model_dependencies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_page_views" (
    "id" uuid NOT NULL,
    "frontend_route_id" uuid NOT NULL,
    "read_model_definition_id" uuid NOT NULL,
    "view_code" varchar NOT NULL,
    "view_type_concept_id" uuid NOT NULL,
    "title" varchar,
    "description" text,
    "field_mask_policy_id" uuid,
    "default_sort_code" varchar,
    "polling_interval_seconds" integer,
    "supports_cursor_pagination" boolean,
    "supports_export" boolean,
    "supports_saved_filters" boolean,
    "layout_spec_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_page_views" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_view_fields" (
    "id" uuid NOT NULL,
    "frontend_page_view_id" uuid NOT NULL,
    "field_code" varchar NOT NULL,
    "source_column" varchar NOT NULL,
    "label" varchar NOT NULL,
    "data_type" "terminology"."technical_data_type" NOT NULL,
    "display_component_concept_id" uuid,
    "format_mask" varchar,
    "responsive_priority" integer,
    "sortable" boolean,
    "filterable" boolean,
    "searchable" boolean,
    "sensitive" boolean,
    "permission_id" uuid,
    "empty_display_text" varchar,
    "metadata_json" jsonb,
    "ordinal" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_view_fields" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_view_filters" (
    "id" uuid NOT NULL,
    "frontend_page_view_id" uuid NOT NULL,
    "filter_code" varchar NOT NULL,
    "label" varchar NOT NULL,
    "operator_value_set_id" uuid NOT NULL,
    "input_type_concept_id" uuid NOT NULL,
    "value_set_id" uuid,
    "dynamic_enum_definition_id" uuid,
    "source_column" varchar,
    "default_value_json" jsonb,
    "required" boolean,
    "url_parameter_name" varchar,
    "ordinal" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_view_filters" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_view_sort_options" (
    "id" uuid NOT NULL,
    "frontend_page_view_id" uuid NOT NULL,
    "sort_code" varchar NOT NULL,
    "label" varchar NOT NULL,
    "sort_expression" varchar NOT NULL,
    "direction_concept_id" uuid NOT NULL,
    "nulls_position_concept_id" uuid NOT NULL,
    "stable_tie_breaker_expression" varchar,
    "ordinal" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_view_sort_options" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_view_actions" (
    "id" uuid NOT NULL,
    "frontend_page_view_id" uuid NOT NULL,
    "action_code" varchar NOT NULL,
    "label" varchar NOT NULL,
    "action_type_concept_id" uuid NOT NULL,
    "route_template" varchar,
    "required_permission_id" uuid,
    "allowed_state_value_set_id" uuid,
    "confirmation_policy_concept_id" uuid,
    "idempotency_required" boolean,
    "icon_key" varchar,
    "prominence_concept_id" uuid,
    "ordinal" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_view_actions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_view_kpis" (
    "id" uuid NOT NULL,
    "frontend_page_view_id" uuid NOT NULL,
    "kpi_code" varchar NOT NULL,
    "label" varchar NOT NULL,
    "value_column" varchar NOT NULL,
    "comparison_column" varchar NOT NULL,
    "unit_concept_id" uuid,
    "format_mask" varchar,
    "threshold_rules_json" jsonb,
    "drilldown_route_template" varchar,
    "ordinal" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_view_kpis" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."frontend_view_states" (
    "id" uuid NOT NULL,
    "frontend_page_view_id" uuid NOT NULL,
    "state_type_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "message" varchar NOT NULL,
    "illustration_key" varchar,
    "recovery_action_code" varchar,
    "telemetry_event_code" varchar,
    "retry_allowed" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_frontend_view_states" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."user_view_preferences" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "frontend_page_view_id" uuid NOT NULL,
    "tenant_id" uuid,
    "visible_fields_json" jsonb,
    "field_order_json" jsonb,
    "active_filter_json" jsonb,
    "sort_code" varchar,
    "density_concept_id" uuid,
    "page_size" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_user_view_preferences" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "read_models"."read_model_refresh_runs" (
    "id" uuid NOT NULL,
    "read_model_definition_id" uuid NOT NULL,
    "refresh_type_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "completed_at" timestamptz,
    "rows_affected" bigint,
    "source_watermark" varchar,
    "result_concept_id" uuid,
    "error_code" varchar,
    "correlation_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_read_model_refresh_runs" PRIMARY KEY ("id")
);
