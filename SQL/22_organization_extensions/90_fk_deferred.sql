-- SALUD v4.0.10 · módulo 22 · schema organization_extensions
-- Generado de diagram_22_organization_extensions.puml — NO editar a mano.


-- FK sin destino canónico (no forzadas, temperatura-0):
--   organization_affiliations.data_use_agreement_id


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_primary_practice_site_id" FOREIGN KEY ("primary_practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.public_profiles (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_public_profile_id" FOREIGN KEY ("public_profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_hospital_type_concept_id" FOREIGN KEY ("hospital_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_care_level_concept_id" FOREIGN KEY ("care_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_ownership_type_concept_id" FOREIGN KEY ("ownership_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_teaching_status_concept_id" FOREIGN KEY ("teaching_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_emergency_capability_concept_id" FOREIGN KEY ("emergency_capability_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospitals"
        ADD CONSTRAINT "fk_hospitals_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_service_line_concept_id" FOREIGN KEY ("service_line_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_specialty_concept_id" FOREIGN KEY ("specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_acuity_level_concept_id" FOREIGN KEY ("acuity_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."hospital_service_lines"
        ADD CONSTRAINT "fk_hospital_service_lines_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_facility_type_concept_id" FOREIGN KEY ("facility_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_license_type_concept_id" FOREIGN KEY ("license_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_issuing_authority_tenant_id" FOREIGN KEY ("issuing_authority_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."facility_licenses"
        ADD CONSTRAINT "fk_facility_licenses_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_primary_tenant_id" FOREIGN KEY ("primary_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_participating_tenant_id" FOREIGN KEY ("participating_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_affiliation_type_concept_id" FOREIGN KEY ("affiliation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_host_practice_site_id" FOREIGN KEY ("host_practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_affiliations"
        ADD CONSTRAINT "fk_organization_affiliations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_boundary_type_concept_id" FOREIGN KEY ("boundary_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_data_controller_tenant_id" FOREIGN KEY ("data_controller_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_data_processor_tenant_id" FOREIGN KEY ("data_processor_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_jurisdiction_concept_id" FOREIGN KEY ("jurisdiction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_residency_region_concept_id" FOREIGN KEY ("residency_region_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_allowed_purpose_value_set_id" FOREIGN KEY ("allowed_purpose_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "organization_extensions"."organization_data_boundaries"
        ADD CONSTRAINT "fk_organization_data_boundaries_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
