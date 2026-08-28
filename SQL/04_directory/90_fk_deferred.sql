-- SALUD v4.0.10 · módulo 04 · schema directory
-- Generado de diagram_04_directory.puml — NO editar a mano.


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_tenant_type_concept_id" FOREIGN KEY ("tenant_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_legal_entity_type_concept_id" FOREIGN KEY ("legal_entity_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_country_concept_id" FOREIGN KEY ("country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_data_residency_region_concept_id" FOREIGN KEY ("data_residency_region_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenants"
        ADD CONSTRAINT "fk_tenants_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."branches"
        ADD CONSTRAINT "fk_branches_branch_type_concept_id" FOREIGN KEY ("branch_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."branches"
        ADD CONSTRAINT "fk_branches_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."branches"
        ADD CONSTRAINT "fk_branches_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."branches"
        ADD CONSTRAINT "fk_branches_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_tenant_role_concept_id" FOREIGN KEY ("tenant_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_access_scope_concept_id" FOREIGN KEY ("access_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_invited_by_user_id" FOREIGN KEY ("invited_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_local_role_concept_id" FOREIGN KEY ("local_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_document_type_concept_id" FOREIGN KEY ("document_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_issuing_authority_concept_id" FOREIGN KEY ("issuing_authority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.identifiers (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_identifier_id" FOREIGN KEY ("identifier_id")
        REFERENCES "common"."identifiers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.persons (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_related_person_id" FOREIGN KEY ("related_person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_verified_by_user_id" FOREIGN KEY ("verified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_affiliation_documents"
        ADD CONSTRAINT "fk_tenant_affiliation_documents_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.persons (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_person_id" FOREIGN KEY ("person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_representative_role_concept_id" FOREIGN KEY ("representative_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.identifiers (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_ci_identifier_id" FOREIGN KEY ("ci_identifier_id")
        REFERENCES "common"."identifiers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_legal_representatives"
        ADD CONSTRAINT "fk_tenant_legal_representatives_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_web_configs"
        ADD CONSTRAINT "fk_tenant_web_configs_primary_language_concept_id" FOREIGN KEY ("primary_language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_web_configs"
        ADD CONSTRAINT "fk_tenant_web_configs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_web_configs"
        ADD CONSTRAINT "fk_tenant_web_configs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_web_configs"
        ADD CONSTRAINT "fk_tenant_web_configs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
