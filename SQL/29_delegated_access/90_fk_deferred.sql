-- SALUD v4.0.10 · módulo 29 · schema delegated_access
-- Generado de diagram_29_delegated_access.puml — NO editar a mano.


-- destino: directory.tenant_memberships (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_tenant_membership_id" FOREIGN KEY ("tenant_membership_id")
        REFERENCES "directory"."tenant_memberships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_units (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: pharmacy.pharmacies (requiere schema pharmacy)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_pharmacy_id" FOREIGN KEY ("pharmacy_id")
        REFERENCES "pharmacy"."pharmacies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_assignment_role_concept_id" FOREIGN KEY ("assignment_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_access_scope_concept_id" FOREIGN KEY ("access_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_supervisor_user_id" FOREIGN KEY ("supervisor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_permission_sets"
        ADD CONSTRAINT "fk_delegated_permission_sets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_permission_sets"
        ADD CONSTRAINT "fk_delegated_permission_sets_delegate_type_concept_id" FOREIGN KEY ("delegate_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_permission_sets"
        ADD CONSTRAINT "fk_delegated_permission_sets_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_permission_sets"
        ADD CONSTRAINT "fk_delegated_permission_sets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_permission_sets"
        ADD CONSTRAINT "fk_delegated_permission_sets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_permission_set_items"
        ADD CONSTRAINT "fk_delegated_permission_set_items_permission_id" FOREIGN KEY ("permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practitioner_role_assignments (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_practitioner_role_7e0ebecf" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_delegate_role_concept_id" FOREIGN KEY ("delegate_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_patient_scope_concept_id" FOREIGN KEY ("patient_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_appointment_scope_5c233325" FOREIGN KEY ("appointment_scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_grant_type_concept_id" FOREIGN KEY ("grant_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_approval_requests"
        ADD CONSTRAINT "fk_delegated_access_approval_requests_requested_permission_id" FOREIGN KEY ("requested_permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_approval_requests"
        ADD CONSTRAINT "fk_delegated_access_approval_requests_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_approval_requests"
        ADD CONSTRAINT "fk_delegated_access_approval_requests_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_approval_requests"
        ADD CONSTRAINT "fk_delegated_access_approval_requests_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_approval_requests"
        ADD CONSTRAINT "fk_delegated_access_approval_requests_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_approval_requests"
        ADD CONSTRAINT "fk_delegated_access_approval_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegation_events"
        ADD CONSTRAINT "fk_delegation_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegation_events"
        ADD CONSTRAINT "fk_delegation_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegation_events"
        ADD CONSTRAINT "fk_delegation_events_target_user_id" FOREIGN KEY ("target_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegation_events"
        ADD CONSTRAINT "fk_delegation_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
