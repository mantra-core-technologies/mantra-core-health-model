-- SALUD v4.0.10 · módulo 54 · schema polyglot_storage
-- Generado de diagram_54_polyglot_storage.puml — NO editar a mano.


-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."dataset_versions"
        ADD CONSTRAINT "fk_dataset_versions_schema_document_file_id" FOREIGN KEY ("schema_document_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."tenant_storage_bindings"
        ADD CONSTRAINT "fk_tenant_storage_bindings_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "polyglot_storage"."storage_cost_snapshots"
        ADD CONSTRAINT "fk_storage_cost_snapshots_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
