-- SALUD v4.0.10 · módulo 45 · schema system_context
-- Generado de diagram_45_system_context.puml — NO editar a mano.


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_context_type_concept_id" FOREIGN KEY ("context_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_scope_type_concept_id" FOREIGN KEY ("scope_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_locale_concept_id" FOREIGN KEY ("locale_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_refresh_policy_concept_id" FOREIGN KEY ("refresh_policy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_refresh_runs"
        ADD CONSTRAINT "fk_system_context_refresh_runs_trigger_concept_id" FOREIGN KEY ("trigger_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_refresh_runs"
        ADD CONSTRAINT "fk_system_context_refresh_runs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_refresh_runs"
        ADD CONSTRAINT "fk_system_context_refresh_runs_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: automation.agents (requiere schema automation)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_versions"
        ADD CONSTRAINT "fk_system_context_versions_generated_by_agent_id" FOREIGN KEY ("generated_by_agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_versions"
        ADD CONSTRAINT "fk_system_context_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_versions"
        ADD CONSTRAINT "fk_system_context_versions_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_inputs"
        ADD CONSTRAINT "fk_system_context_inputs_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_inputs"
        ADD CONSTRAINT "fk_system_context_inputs_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_bindings"
        ADD CONSTRAINT "fk_system_context_bindings_consumer_type_concept_id" FOREIGN KEY ("consumer_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_bindings"
        ADD CONSTRAINT "fk_system_context_bindings_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_bindings"
        ADD CONSTRAINT "fk_system_context_bindings_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_bindings"
        ADD CONSTRAINT "fk_system_context_bindings_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_bindings"
        ADD CONSTRAINT "fk_system_context_bindings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_bindings"
        ADD CONSTRAINT "fk_system_context_bindings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_value_set_id" FOREIGN KEY ("value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_scope_type_concept_id" FOREIGN KEY ("scope_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_selection_mode_concept_id" FOREIGN KEY ("selection_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_definitions"
        ADD CONSTRAINT "fk_dynamic_enum_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_set_versions (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_versions"
        ADD CONSTRAINT "fk_dynamic_enum_versions_value_set_version_id" FOREIGN KEY ("value_set_version_id")
        REFERENCES "terminology"."value_set_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_versions"
        ADD CONSTRAINT "fk_dynamic_enum_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_versions"
        ADD CONSTRAINT "fk_dynamic_enum_versions_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_options"
        ADD CONSTRAINT "fk_dynamic_enum_options_concept_id" FOREIGN KEY ("concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_options"
        ADD CONSTRAINT "fk_dynamic_enum_options_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_bindings"
        ADD CONSTRAINT "fk_dynamic_enum_bindings_fallback_concept_id" FOREIGN KEY ("fallback_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_bindings"
        ADD CONSTRAINT "fk_dynamic_enum_bindings_validation_mode_concept_id" FOREIGN KEY ("validation_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_bindings"
        ADD CONSTRAINT "fk_dynamic_enum_bindings_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_bindings"
        ADD CONSTRAINT "fk_dynamic_enum_bindings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_bindings"
        ADD CONSTRAINT "fk_dynamic_enum_bindings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
