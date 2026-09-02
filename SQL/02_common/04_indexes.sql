-- SALUD v4.0.10 · módulo 02 · schema common
-- Generado de diagram_02_common.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_identifiers_owner_type_concept_id" ON "common"."identifiers" ("owner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_use_concept_id" ON "common"."identifiers" ("use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_type_concept_id" ON "common"."identifiers" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_type_concept_id_value" ON "common"."identifiers" ("type_concept_id", "value");

CREATE INDEX IF NOT EXISTS "ix_identifiers_issuer_country_concept_id" ON "common"."identifiers" ("issuer_country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_issuer_administrative_area_concept_id" ON "common"."identifiers" ("issuer_administrative_area_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_assigner_tenant_id" ON "common"."identifiers" ("assigner_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_state_concept_id" ON "common"."identifiers" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_created_by_user_id" ON "common"."identifiers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_identifiers_updated_by_user_id" ON "common"."identifiers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contact_points_owner_type_concept_id" ON "common"."contact_points" ("owner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_points_system_concept_id" ON "common"."contact_points" ("system_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_points_use_concept_id" ON "common"."contact_points" ("use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_points_created_by_user_id" ON "common"."contact_points" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contact_points_updated_by_user_id" ON "common"."contact_points" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_owner_type_concept_id" ON "common"."addresses" ("owner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_use_concept_id" ON "common"."addresses" ("use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_type_concept_id" ON "common"."addresses" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_administrative_area_concept_id" ON "common"."addresses" ("administrative_area_concept_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_municipality_concept_id" ON "common"."addresses" ("municipality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_country_concept_id" ON "common"."addresses" ("country_concept_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_created_by_user_id" ON "common"."addresses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_addresses_updated_by_user_id" ON "common"."addresses" ("updated_by_user_id");

-- OMITIDO "gist_addresses_location" (geography_point) gist: columna(s) ['geography_point'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "ix_files_tenant_id" ON "common"."files" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_files_category_concept_id" ON "common"."files" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_files_sensitivity_concept_id" ON "common"."files" ("sensitivity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_files_lifecycle_status_concept_id" ON "common"."files" ("lifecycle_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_files_current_version_id" ON "common"."files" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_files_retention_class_concept_id" ON "common"."files" ("retention_class_concept_id");

CREATE INDEX IF NOT EXISTS "ix_files_created_by_user_id" ON "common"."files" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_files_updated_by_user_id" ON "common"."files" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_files_tenant_id_lifecycle_status_concept_id" ON "common"."files" ("tenant_id", "lifecycle_status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_file_versions_file_id" ON "common"."file_versions" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_file_versions_storage_provider_concept_id" ON "common"."file_versions" ("storage_provider_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_versions_storage_region_concept_id" ON "common"."file_versions" ("storage_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_versions_checksum_algorithm_concept_id" ON "common"."file_versions" ("checksum_algorithm_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_versions_encryption_status_concept_id" ON "common"."file_versions" ("encryption_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_versions_malware_scan_status_concept_id" ON "common"."file_versions" ("malware_scan_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_versions_integrity_status_concept_id" ON "common"."file_versions" ("integrity_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_versions_recorded_by_user_id" ON "common"."file_versions" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_file_versions_file_id_version_number" ON "common"."file_versions" ("file_id", "version_number");

CREATE INDEX IF NOT EXISTS "brin_file_versions_recorded_at" ON "common"."file_versions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_file_links_file_id" ON "common"."file_links" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_file_links_owner_type_concept_id" ON "common"."file_links" ("owner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_links_link_role_concept_id" ON "common"."file_links" ("link_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_links_visibility_concept_id" ON "common"."file_links" ("visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_links_created_by_user_id" ON "common"."file_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_file_links_updated_by_user_id" ON "common"."file_links" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_file_derivatives_source_file_version_id" ON "common"."file_derivatives" ("source_file_version_id");

CREATE INDEX IF NOT EXISTS "ix_file_derivatives_derivative_file_version_id" ON "common"."file_derivatives" ("derivative_file_version_id");

CREATE INDEX IF NOT EXISTS "ix_file_derivatives_derivative_type_concept_id" ON "common"."file_derivatives" ("derivative_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_file_derivatives_created_by_user_id" ON "common"."file_derivatives" ("created_by_user_id");
