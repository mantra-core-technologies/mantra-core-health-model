-- SALUD v4.0.10 · módulo 04 · schema directory
-- Generado de diagram_04_directory.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_parent_tenant_id" FOREIGN KEY ("parent_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."branches"
        ADD CONSTRAINT "fk_branches_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_primary_branch_id" FOREIGN KEY ("primary_branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_tenant_membership_id" FOREIGN KEY ("tenant_membership_id")
        REFERENCES "directory"."tenant_memberships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_power_of_attorney_document_id" FOREIGN KEY ("power_of_attorney_document_id")
        REFERENCES "directory"."tenant_affiliation_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."tenant_web_configs"
        ADD CONSTRAINT "fk_tenant_web_configs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
