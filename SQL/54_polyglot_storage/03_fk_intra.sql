-- SALUD v4.0.10 · módulo 54 · schema polyglot_storage
-- Generado de diagram_54_polyglot_storage.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."storage_backend_regions"
        ADD CONSTRAINT "fk_storage_backend_regions_storage_backend_id" FOREIGN KEY ("storage_backend_id")
        REFERENCES "polyglot_storage"."storage_backends" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."storage_capabilities"
        ADD CONSTRAINT "fk_storage_capabilities_storage_backend_id" FOREIGN KEY ("storage_backend_id")
        REFERENCES "polyglot_storage"."storage_backends" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."data_classifications"
        ADD CONSTRAINT "fk_data_classifications_default_encryption_profile_id" FOREIGN KEY ("default_encryption_profile_id")
        REFERENCES "polyglot_storage"."encryption_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."data_classifications"
        ADD CONSTRAINT "fk_data_classifications_default_retention_policy_id" FOREIGN KEY ("default_retention_policy_id")
        REFERENCES "polyglot_storage"."retention_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_definitions"
        ADD CONSTRAINT "fk_dataset_definitions_data_classification_id" FOREIGN KEY ("data_classification_id")
        REFERENCES "polyglot_storage"."data_classifications" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_versions"
        ADD CONSTRAINT "fk_dataset_versions_dataset_definition_id" FOREIGN KEY ("dataset_definition_id")
        REFERENCES "polyglot_storage"."dataset_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."collection_definitions"
        ADD CONSTRAINT "fk_collection_definitions_storage_backend_id" FOREIGN KEY ("storage_backend_id")
        REFERENCES "polyglot_storage"."storage_backends" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."collection_definitions"
        ADD CONSTRAINT "fk_collection_definitions_dataset_definition_id" FOREIGN KEY ("dataset_definition_id")
        REFERENCES "polyglot_storage"."dataset_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."collection_schema_versions"
        ADD CONSTRAINT "fk_collection_schema_versions_collection_definition_id" FOREIGN KEY ("collection_definition_id")
        REFERENCES "polyglot_storage"."collection_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."collection_schema_versions"
        ADD CONSTRAINT "fk_collection_schema_versions_dataset_version_id" FOREIGN KEY ("dataset_version_id")
        REFERENCES "polyglot_storage"."dataset_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_placements"
        ADD CONSTRAINT "fk_dataset_placements_dataset_version_id" FOREIGN KEY ("dataset_version_id")
        REFERENCES "polyglot_storage"."dataset_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_placements"
        ADD CONSTRAINT "fk_dataset_placements_storage_backend_region_id" FOREIGN KEY ("storage_backend_region_id")
        REFERENCES "polyglot_storage"."storage_backend_regions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_placements"
        ADD CONSTRAINT "fk_dataset_placements_collection_definition_id" FOREIGN KEY ("collection_definition_id")
        REFERENCES "polyglot_storage"."collection_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_placements"
        ADD CONSTRAINT "fk_dataset_placements_residency_policy_id" FOREIGN KEY ("residency_policy_id")
        REFERENCES "polyglot_storage"."residency_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_placements"
        ADD CONSTRAINT "fk_dataset_placements_replication_policy_id" FOREIGN KEY ("replication_policy_id")
        REFERENCES "polyglot_storage"."replication_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_placements"
        ADD CONSTRAINT "fk_dataset_placements_consistency_policy_id" FOREIGN KEY ("consistency_policy_id")
        REFERENCES "polyglot_storage"."consistency_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_placements"
        ADD CONSTRAINT "fk_dataset_placements_encryption_profile_id" FOREIGN KEY ("encryption_profile_id")
        REFERENCES "polyglot_storage"."encryption_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."tenant_storage_bindings"
        ADD CONSTRAINT "fk_tenant_storage_bindings_dataset_definition_id" FOREIGN KEY ("dataset_definition_id")
        REFERENCES "polyglot_storage"."dataset_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."tenant_storage_bindings"
        ADD CONSTRAINT "fk_tenant_storage_bindings_primary_placement_id" FOREIGN KEY ("primary_placement_id")
        REFERENCES "polyglot_storage"."dataset_placements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."tenant_storage_bindings"
        ADD CONSTRAINT "fk_tenant_storage_bindings_secondary_placement_id" FOREIGN KEY ("secondary_placement_id")
        REFERENCES "polyglot_storage"."dataset_placements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."encryption_profiles"
        ADD CONSTRAINT "fk_encryption_profiles_rotation_policy_id" FOREIGN KEY ("rotation_policy_id")
        REFERENCES "polyglot_storage"."key_rotation_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."data_access_policies"
        ADD CONSTRAINT "fk_data_access_policies_dataset_definition_id" FOREIGN KEY ("dataset_definition_id")
        REFERENCES "polyglot_storage"."dataset_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."store_health_checks"
        ADD CONSTRAINT "fk_store_health_checks_storage_backend_region_id" FOREIGN KEY ("storage_backend_region_id")
        REFERENCES "polyglot_storage"."storage_backend_regions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."storage_cost_snapshots"
        ADD CONSTRAINT "fk_storage_cost_snapshots_storage_backend_region_id" FOREIGN KEY ("storage_backend_region_id")
        REFERENCES "polyglot_storage"."storage_backend_regions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."storage_cost_snapshots"
        ADD CONSTRAINT "fk_storage_cost_snapshots_dataset_definition_id" FOREIGN KEY ("dataset_definition_id")
        REFERENCES "polyglot_storage"."dataset_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."storage_integrity_policies"
        ADD CONSTRAINT "fk_storage_integrity_policies_dataset_definition_id" FOREIGN KEY ("dataset_definition_id")
        REFERENCES "polyglot_storage"."dataset_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
