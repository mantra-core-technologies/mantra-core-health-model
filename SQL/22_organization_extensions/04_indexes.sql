-- SALUD v4.0.10 · módulo 22 · schema organization_extensions
-- Generado de diagram_22_organization_extensions.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_hospitals_tenant_id" ON "organization_extensions"."hospitals" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_hospitals_practice_id" ON "organization_extensions"."hospitals" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_tenant_id" ON "organization_extensions"."hospitals" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_practice_id" ON "organization_extensions"."hospitals" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_primary_practice_site_id" ON "organization_extensions"."hospitals" ("primary_practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_public_profile_id" ON "organization_extensions"."hospitals" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_hospital_type_concept_id" ON "organization_extensions"."hospitals" ("hospital_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_care_level_concept_id" ON "organization_extensions"."hospitals" ("care_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_ownership_type_concept_id" ON "organization_extensions"."hospitals" ("ownership_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_teaching_status_concept_id" ON "organization_extensions"."hospitals" ("teaching_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_emergency_capability_concept_id" ON "organization_extensions"."hospitals" ("emergency_capability_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_status_concept_id" ON "organization_extensions"."hospitals" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_created_by_user_id" ON "organization_extensions"."hospitals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_updated_by_user_id" ON "organization_extensions"."hospitals" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_hospitals_tenant_id_status_concept_id" ON "organization_extensions"."hospitals" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_hospital_id" ON "organization_extensions"."hospital_service_lines" ("hospital_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_clinical_unit_id" ON "organization_extensions"."hospital_service_lines" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_healthcare_service_id" ON "organization_extensions"."hospital_service_lines" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_service_line_concept_id" ON "organization_extensions"."hospital_service_lines" ("service_line_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_specialty_concept_id" ON "organization_extensions"."hospital_service_lines" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_acuity_level_concept_id" ON "organization_extensions"."hospital_service_lines" ("acuity_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_status_concept_id" ON "organization_extensions"."hospital_service_lines" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_created_by_user_id" ON "organization_extensions"."hospital_service_lines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_hospital_service_lines_updated_by_user_id" ON "organization_extensions"."hospital_service_lines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_tenant_id" ON "organization_extensions"."facility_licenses" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_practice_site_id" ON "organization_extensions"."facility_licenses" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_facility_type_concept_id" ON "organization_extensions"."facility_licenses" ("facility_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_license_type_concept_id" ON "organization_extensions"."facility_licenses" ("license_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_issuing_authority_tenant_id" ON "organization_extensions"."facility_licenses" ("issuing_authority_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_jurisdiction_concept_id" ON "organization_extensions"."facility_licenses" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_evidence_file_id" ON "organization_extensions"."facility_licenses" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_verification_status_concept_id" ON "organization_extensions"."facility_licenses" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_created_by_user_id" ON "organization_extensions"."facility_licenses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_updated_by_user_id" ON "organization_extensions"."facility_licenses" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_facility_licenses_tenant_id_updated_at" ON "organization_extensions"."facility_licenses" ("tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_primary_tenant_id" ON "organization_extensions"."organization_affiliations" ("primary_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_participating_tenant_id" ON "organization_extensions"."organization_affiliations" ("participating_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_affiliation_type_concept_id" ON "organization_extensions"."organization_affiliations" ("affiliation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_host_practice_site_id" ON "organization_extensions"."organization_affiliations" ("host_practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_healthcare_service_id" ON "organization_extensions"."organization_affiliations" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_data_use_agreement_id" ON "organization_extensions"."organization_affiliations" ("data_use_agreement_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_status_concept_id" ON "organization_extensions"."organization_affiliations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_created_by_user_id" ON "organization_extensions"."organization_affiliations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_affiliations_updated_by_user_id" ON "organization_extensions"."organization_affiliations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_tenant_id" ON "organization_extensions"."organization_data_boundaries" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_boundary_type_concept_id" ON "organization_extensions"."organization_data_boundaries" ("boundary_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_data_controller_tenant_id" ON "organization_extensions"."organization_data_boundaries" ("data_controller_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_data_processor_tenant_id" ON "organization_extensions"."organization_data_boundaries" ("data_processor_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_jurisdiction_concept_id" ON "organization_extensions"."organization_data_boundaries" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_residency_region_concept_id" ON "organization_extensions"."organization_data_boundaries" ("residency_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_allowed_purpose_value_set_id" ON "organization_extensions"."organization_data_boundaries" ("allowed_purpose_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_status_concept_id" ON "organization_extensions"."organization_data_boundaries" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_created_by_user_id" ON "organization_extensions"."organization_data_boundaries" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_updated_by_user_id" ON "organization_extensions"."organization_data_boundaries" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_data_boundaries_tenant_id_status_concept_id" ON "organization_extensions"."organization_data_boundaries" ("tenant_id", "status_concept_id", "updated_at" DESC);
