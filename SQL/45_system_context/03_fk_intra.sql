-- SALUD v4.0.10 · módulo 45 · schema system_context
-- Generado de diagram_45_system_context.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "system_context"."system_contexts"
        ADD CONSTRAINT "fk_system_contexts_current_version_id" FOREIGN KEY ("current_version_id")
        REFERENCES "system_context"."system_context_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_refresh_runs"
        ADD CONSTRAINT "fk_system_context_refresh_runs_system_context_id" FOREIGN KEY ("system_context_id")
        REFERENCES "system_context"."system_contexts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_versions"
        ADD CONSTRAINT "fk_system_context_versions_system_context_id" FOREIGN KEY ("system_context_id")
        REFERENCES "system_context"."system_contexts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_versions"
        ADD CONSTRAINT "fk_system_context_versions_refresh_run_id" FOREIGN KEY ("refresh_run_id")
        REFERENCES "system_context"."system_context_refresh_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_inputs"
        ADD CONSTRAINT "fk_system_context_inputs_system_context_version_id" FOREIGN KEY ("system_context_version_id")
        REFERENCES "system_context"."system_context_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."system_context_bindings"
        ADD CONSTRAINT "fk_system_context_bindings_system_context_id" FOREIGN KEY ("system_context_id")
        REFERENCES "system_context"."system_contexts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_versions"
        ADD CONSTRAINT "fk_dynamic_enum_versions_dynamic_enum_definition_id" FOREIGN KEY ("dynamic_enum_definition_id")
        REFERENCES "system_context"."dynamic_enum_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_options"
        ADD CONSTRAINT "fk_dynamic_enum_options_dynamic_enum_version_id" FOREIGN KEY ("dynamic_enum_version_id")
        REFERENCES "system_context"."dynamic_enum_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_bindings"
        ADD CONSTRAINT "fk_dynamic_enum_bindings_dynamic_enum_definition_id" FOREIGN KEY ("dynamic_enum_definition_id")
        REFERENCES "system_context"."dynamic_enum_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "system_context"."dynamic_enum_bindings"
        ADD CONSTRAINT "fk_dynamic_enum_bindings_system_context_id" FOREIGN KEY ("system_context_id")
        REFERENCES "system_context"."system_contexts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
