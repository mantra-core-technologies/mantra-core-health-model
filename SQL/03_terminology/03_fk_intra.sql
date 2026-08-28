-- SALUD v4.0.10 · módulo 03 · schema terminology
-- Generado de diagram_03_terminology.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "terminology"."terminology_sources"
        ADD CONSTRAINT "fk_terminology_sources_source_type_concept_id" FOREIGN KEY ("source_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."terminology_sources"
        ADD CONSTRAINT "fk_terminology_sources_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."terminology_sources"
        ADD CONSTRAINT "fk_terminology_sources_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."code_systems"
        ADD CONSTRAINT "fk_code_systems_source_id" FOREIGN KEY ("source_id")
        REFERENCES "terminology"."terminology_sources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."code_systems"
        ADD CONSTRAINT "fk_code_systems_content_type_concept_id" FOREIGN KEY ("content_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."code_systems"
        ADD CONSTRAINT "fk_code_systems_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."code_system_versions"
        ADD CONSTRAINT "fk_code_system_versions_code_system_id" FOREIGN KEY ("code_system_id")
        REFERENCES "terminology"."code_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."code_system_versions"
        ADD CONSTRAINT "fk_code_system_versions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."catalog_concepts"
        ADD CONSTRAINT "fk_catalog_concepts_code_system_version_id" FOREIGN KEY ("code_system_version_id")
        REFERENCES "terminology"."code_system_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."catalog_concepts"
        ADD CONSTRAINT "fk_catalog_concepts_replaced_by_concept_id" FOREIGN KEY ("replaced_by_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."catalog_concepts"
        ADD CONSTRAINT "fk_catalog_concepts_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_designations"
        ADD CONSTRAINT "fk_concept_designations_concept_id" FOREIGN KEY ("concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_designations"
        ADD CONSTRAINT "fk_concept_designations_language_concept_id" FOREIGN KEY ("language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_designations"
        ADD CONSTRAINT "fk_concept_designations_designation_type_concept_id" FOREIGN KEY ("designation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_properties"
        ADD CONSTRAINT "fk_concept_properties_concept_id" FOREIGN KEY ("concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationships"
        ADD CONSTRAINT "fk_concept_relationships_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationships"
        ADD CONSTRAINT "fk_concept_relationships_target_concept_id" FOREIGN KEY ("target_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationships"
        ADD CONSTRAINT "fk_concept_relationships_relationship_type_concept_id" FOREIGN KEY ("relationship_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_sets"
        ADD CONSTRAINT "fk_value_sets_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_sets"
        ADD CONSTRAINT "fk_value_sets_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_set_versions"
        ADD CONSTRAINT "fk_value_set_versions_value_set_id" FOREIGN KEY ("value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_set_versions"
        ADD CONSTRAINT "fk_value_set_versions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_set_members"
        ADD CONSTRAINT "fk_value_set_members_value_set_version_id" FOREIGN KEY ("value_set_version_id")
        REFERENCES "terminology"."value_set_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_set_members"
        ADD CONSTRAINT "fk_value_set_members_concept_id" FOREIGN KEY ("concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_set_rules"
        ADD CONSTRAINT "fk_value_set_rules_value_set_version_id" FOREIGN KEY ("value_set_version_id")
        REFERENCES "terminology"."value_set_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_set_rules"
        ADD CONSTRAINT "fk_value_set_rules_code_system_id" FOREIGN KEY ("code_system_id")
        REFERENCES "terminology"."code_systems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."value_set_rules"
        ADD CONSTRAINT "fk_value_set_rules_operator_concept_id" FOREIGN KEY ("operator_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_maps"
        ADD CONSTRAINT "fk_concept_maps_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_maps"
        ADD CONSTRAINT "fk_concept_maps_target_concept_id" FOREIGN KEY ("target_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_maps"
        ADD CONSTRAINT "fk_concept_maps_equivalence_concept_id" FOREIGN KEY ("equivalence_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_maps"
        ADD CONSTRAINT "fk_concept_maps_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."catalog_import_batches"
        ADD CONSTRAINT "fk_catalog_import_batches_source_id" FOREIGN KEY ("source_id")
        REFERENCES "terminology"."terminology_sources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."catalog_import_batches"
        ADD CONSTRAINT "fk_catalog_import_batches_code_system_version_id" FOREIGN KEY ("code_system_version_id")
        REFERENCES "terminology"."code_system_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."catalog_import_batches"
        ADD CONSTRAINT "fk_catalog_import_batches_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."tenant_catalog_policies"
        ADD CONSTRAINT "fk_tenant_catalog_policies_value_set_id" FOREIGN KEY ("value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."tenant_catalog_policies"
        ADD CONSTRAINT "fk_tenant_catalog_policies_mode_concept_id" FOREIGN KEY ("mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."tenant_concept_config"
        ADD CONSTRAINT "fk_tenant_concept_config_concept_id" FOREIGN KEY ("concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
