-- SALUD v4.0.10 · módulo 04 · schema directory
-- Generado de diagram_04_directory.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_tenants_code" ON "directory"."tenants" ("code");

CREATE INDEX IF NOT EXISTS "ix_tenants_tenant_type_concept_id" ON "directory"."tenants" ("tenant_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_legal_entity_type_concept_id" ON "directory"."tenants" ("legal_entity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_status_concept_id" ON "directory"."tenants" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_verification_status_concept_id" ON "directory"."tenants" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_country_concept_id" ON "directory"."tenants" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_jurisdiction_concept_id" ON "directory"."tenants" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_data_residency_region_concept_id" ON "directory"."tenants" ("data_residency_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_currency_concept_id" ON "directory"."tenants" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_parent_tenant_id" ON "directory"."tenants" ("parent_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_created_by_user_id" ON "directory"."tenants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenants_updated_by_user_id" ON "directory"."tenants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_tenants_search" ON "directory"."tenants" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_branches_tenant_id" ON "directory"."branches" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_branches_branch_type_concept_id" ON "directory"."branches" ("branch_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_branches_status_concept_id" ON "directory"."branches" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_branches_created_by_user_id" ON "directory"."branches" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_branches_updated_by_user_id" ON "directory"."branches" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_branches_tenant_id_status_concept_id" ON "directory"."branches" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_branches_search" ON "directory"."branches" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

-- OMITIDO "gist_branches_location" (geography_point) gist: columna(s) ['geography_point'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_user_id" ON "directory"."tenant_memberships" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_tenant_id" ON "directory"."tenant_memberships" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_primary_branch_id" ON "directory"."tenant_memberships" ("primary_branch_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_tenant_role_concept_id" ON "directory"."tenant_memberships" ("tenant_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_status_concept_id" ON "directory"."tenant_memberships" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_access_scope_concept_id" ON "directory"."tenant_memberships" ("access_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_invited_by_user_id" ON "directory"."tenant_memberships" ("invited_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_created_by_user_id" ON "directory"."tenant_memberships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_updated_by_user_id" ON "directory"."tenant_memberships" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_tenant_id_status_concept_id" ON "directory"."tenant_memberships" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_tenant_membership_id" ON "directory"."branch_memberships" ("tenant_membership_id");

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_branch_id" ON "directory"."branch_memberships" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_local_role_concept_id" ON "directory"."branch_memberships" ("local_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_status_concept_id" ON "directory"."branch_memberships" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_created_by_user_id" ON "directory"."branch_memberships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_updated_by_user_id" ON "directory"."branch_memberships" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_affiliation_documents_tenant_id" ON "directory"."tenant_affiliation_documents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_affiliation_documents_document_type_concept_id" ON "directory"."tenant_affiliation_documents" ("document_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_affiliation_documents_issuing_authority_concept_id" ON "directory"."tenant_affiliation_documents" ("issuing_authority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_affiliation_documents_verification_status_concept_id" ON "directory"."tenant_affiliation_documents" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_affiliation_documents_file_id" ON "directory"."tenant_affiliation_documents" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_affiliation_documents_identifier_id" ON "directory"."tenant_affiliation_documents" ("identifier_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_affiliation_documents_valid_to" ON "directory"."tenant_affiliation_documents" ("valid_to");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_tenant_affiliation_documents_tenant_type_file" ON "directory"."tenant_affiliation_documents" ("tenant_id", "document_type_concept_id", "file_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_legal_representatives_tenant_id" ON "directory"."tenant_legal_representatives" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_legal_representatives_person_id" ON "directory"."tenant_legal_representatives" ("person_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_legal_representatives_role_concept_id" ON "directory"."tenant_legal_representatives" ("representative_role_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_tenant_legal_representatives_primary" ON "directory"."tenant_legal_representatives" ("tenant_id", "is_primary");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_tenant_web_configs_domain" ON "directory"."tenant_web_configs" ("domain");

CREATE INDEX IF NOT EXISTS "ix_tenant_web_configs_tenant_id" ON "directory"."tenant_web_configs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_web_configs_primary_language_concept_id" ON "directory"."tenant_web_configs" ("primary_language_concept_id");
