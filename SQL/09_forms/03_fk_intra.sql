-- SALUD v4.0.10 · módulo 09 · schema forms
-- Generado de diagram_09_forms.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "forms"."dynamic_field_sections"
        ADD CONSTRAINT "fk_dynamic_field_sections_parent_section_id" FOREIGN KEY ("parent_section_id")
        REFERENCES "forms"."dynamic_field_sections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_assignments"
        ADD CONSTRAINT "fk_field_assignments_field_id" FOREIGN KEY ("field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_assignments"
        ADD CONSTRAINT "fk_field_assignments_section_id" FOREIGN KEY ("section_id")
        REFERENCES "forms"."dynamic_field_sections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_validation_rules"
        ADD CONSTRAINT "fk_field_validation_rules_field_id" FOREIGN KEY ("field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_dependencies"
        ADD CONSTRAINT "fk_field_dependencies_target_field_id" FOREIGN KEY ("target_field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_dependencies"
        ADD CONSTRAINT "fk_field_dependencies_source_field_id" FOREIGN KEY ("source_field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_values"
        ADD CONSTRAINT "fk_field_values_form_instance_id" FOREIGN KEY ("form_instance_id")
        REFERENCES "forms"."form_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_values"
        ADD CONSTRAINT "fk_field_values_field_id" FOREIGN KEY ("field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_values"
        ADD CONSTRAINT "fk_field_values_assignment_id" FOREIGN KEY ("assignment_id")
        REFERENCES "forms"."field_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_values"
        ADD CONSTRAINT "fk_field_values_supersedes_value_id" FOREIGN KEY ("supersedes_value_id")
        REFERENCES "forms"."field_values" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_value_audit"
        ADD CONSTRAINT "fk_field_value_audit_field_value_id" FOREIGN KEY ("field_value_id")
        REFERENCES "forms"."field_values" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_definition_set_versions"
        ADD CONSTRAINT "fk_field_definition_set_versions_definition_set_id" FOREIGN KEY ("definition_set_id")
        REFERENCES "forms"."field_definition_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_set_members"
        ADD CONSTRAINT "fk_field_set_members_definition_set_version_id" FOREIGN KEY ("definition_set_version_id")
        REFERENCES "forms"."field_definition_set_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_set_members"
        ADD CONSTRAINT "fk_field_set_members_field_id" FOREIGN KEY ("field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_set_members"
        ADD CONSTRAINT "fk_field_set_members_section_id" FOREIGN KEY ("section_id")
        REFERENCES "forms"."dynamic_field_sections" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_definition_localizations"
        ADD CONSTRAINT "fk_field_definition_localizations_field_id" FOREIGN KEY ("field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_value_provenance"
        ADD CONSTRAINT "fk_field_value_provenance_field_value_id" FOREIGN KEY ("field_value_id")
        REFERENCES "forms"."field_values" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_value_access_rules"
        ADD CONSTRAINT "fk_field_value_access_rules_field_id" FOREIGN KEY ("field_id")
        REFERENCES "forms"."dynamic_field_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_value_access_rules"
        ADD CONSTRAINT "fk_field_value_access_rules_assignment_id" FOREIGN KEY ("assignment_id")
        REFERENCES "forms"."field_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_schema_migrations"
        ADD CONSTRAINT "fk_field_schema_migrations_definition_set_id" FOREIGN KEY ("definition_set_id")
        REFERENCES "forms"."field_definition_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_schema_migrations"
        ADD CONSTRAINT "fk_field_schema_migrations_from_version_id" FOREIGN KEY ("from_version_id")
        REFERENCES "forms"."field_definition_set_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."field_schema_migrations"
        ADD CONSTRAINT "fk_field_schema_migrations_to_version_id" FOREIGN KEY ("to_version_id")
        REFERENCES "forms"."field_definition_set_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "forms"."extension_target_policies"
        ADD CONSTRAINT "fk_extension_target_policies_definition_set_id" FOREIGN KEY ("definition_set_id")
        REFERENCES "forms"."field_definition_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
