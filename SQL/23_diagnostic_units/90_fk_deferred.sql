-- SALUD v4.0.10 · módulo 23 · schema diagnostic_units
-- Generado de diagram_23_diagnostic_units.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_primary_practice_site_id" FOREIGN KEY ("primary_practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_diagnostic_unit_type_concept_id" FOREIGN KEY ("diagnostic_unit_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_ownership_type_concept_id" FOREIGN KEY ("ownership_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: community.public_profiles (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_public_profile_id" FOREIGN KEY ("public_profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_units"
        ADD CONSTRAINT "fk_diagnostic_units_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_sites"
        ADD CONSTRAINT "fk_diagnostic_unit_sites_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_sites"
        ADD CONSTRAINT "fk_diagnostic_unit_sites_site_role_concept_id" FOREIGN KEY ("site_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_sites"
        ADD CONSTRAINT "fk_diagnostic_unit_sites_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_sites"
        ADD CONSTRAINT "fk_diagnostic_unit_sites_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_sites"
        ADD CONSTRAINT "fk_diagnostic_unit_sites_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_specialties"
        ADD CONSTRAINT "fk_diagnostic_unit_specialties_specialty_concept_id" FOREIGN KEY ("specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_specialties"
        ADD CONSTRAINT "fk_diagnostic_unit_specialties_verification_status_concept_id" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_specialties"
        ADD CONSTRAINT "fk_diagnostic_unit_specialties_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_specialties"
        ADD CONSTRAINT "fk_diagnostic_unit_specialties_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practitioner_role_assignments (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_practition_d05600aa" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_specialty__f8946881" FOREIGN KEY ("specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_assignment_e7e914be" FOREIGN KEY ("assignment_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments"
        ADD CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_study_concept_id" FOREIGN KEY ("study_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_body_site_concept_id" FOREIGN KEY ("body_site_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_specimen_type_concept_id" FOREIGN KEY ("specimen_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
        ADD CONSTRAINT "fk_diagnostic_study_offerings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_components"
        ADD CONSTRAINT "fk_diagnostic_study_components_component_role_concept_id" FOREIGN KEY ("component_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_components"
        ADD CONSTRAINT "fk_diagnostic_study_components_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_price_schedule_type_concept_id" FOREIGN KEY ("price_schedule_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_insurer_tenant_id" FOREIGN KEY ("insurer_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_broker_tenant_id" FOREIGN KEY ("broker_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_price_schedules"
        ADD CONSTRAINT "fk_diagnostic_price_schedules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_prices"
        ADD CONSTRAINT "fk_diagnostic_study_prices_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_study_prices"
        ADD CONSTRAINT "fk_diagnostic_study_prices_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_equipment_type_concept_id" FOREIGN KEY ("equipment_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_operational_status_concept_id" FOREIGN KEY ("operational_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_equipment"
        ADD CONSTRAINT "fk_diagnostic_equipment_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_accreditation_concept_id" FOREIGN KEY ("accreditation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_issuer_tenant_id" FOREIGN KEY ("issuer_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_evidence_file_id" FOREIGN KEY ("evidence_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_verification_status__ca2f963c" FOREIGN KEY ("verification_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations"
        ADD CONSTRAINT "fk_diagnostic_unit_accreditations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
