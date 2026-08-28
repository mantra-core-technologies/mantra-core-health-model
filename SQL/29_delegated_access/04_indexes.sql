-- SALUD v4.0.10 · módulo 29 · schema delegated_access
-- Generado de diagram_29_delegated_access.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_tenant_membership_id" ON "delegated_access"."organization_user_assignments" ("tenant_membership_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_practice_id" ON "delegated_access"."organization_user_assignments" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_practice_site_id" ON "delegated_access"."organization_user_assignments" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_clinical_unit_id" ON "delegated_access"."organization_user_assignments" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_care_space_id" ON "delegated_access"."organization_user_assignments" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_diagnostic_unit_id" ON "delegated_access"."organization_user_assignments" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_pharmacy_id" ON "delegated_access"."organization_user_assignments" ("pharmacy_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_assignment_role_concept_id" ON "delegated_access"."organization_user_assignments" ("assignment_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_access_scope_concept_id" ON "delegated_access"."organization_user_assignments" ("access_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_supervisor_user_id" ON "delegated_access"."organization_user_assignments" ("supervisor_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_status_concept_id" ON "delegated_access"."organization_user_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_created_by_user_id" ON "delegated_access"."organization_user_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_updated_by_user_id" ON "delegated_access"."organization_user_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_organization_user_assignments_effective_period" ON "delegated_access"."organization_user_assignments" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_tenant_id" ON "delegated_access"."delegated_permission_sets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_delegate_type_concept_id" ON "delegated_access"."delegated_permission_sets" ("delegate_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_status_concept_id" ON "delegated_access"."delegated_permission_sets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_created_by_user_id" ON "delegated_access"."delegated_permission_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_updated_by_user_id" ON "delegated_access"."delegated_permission_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_tenant_id_status_concept_id" ON "delegated_access"."delegated_permission_sets" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_set_items_delegated_permission_set_id" ON "delegated_access"."delegated_permission_set_items" ("delegated_permission_set_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_set_items_permission_id" ON "delegated_access"."delegated_permission_set_items" ("permission_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_practitioner_role_5ab23b12" ON "delegated_access"."practitioner_delegate_assignments" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_delegate_user_ass_52dcb36c" ON "delegated_access"."practitioner_delegate_assignments" ("delegate_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_delegated_permiss_e45e3818" ON "delegated_access"."practitioner_delegate_assignments" ("delegated_permission_set_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_delegate_role_concept_id" ON "delegated_access"."practitioner_delegate_assignments" ("delegate_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_patient_scope_concept_id" ON "delegated_access"."practitioner_delegate_assignments" ("patient_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_appointment_scope_692488ef" ON "delegated_access"."practitioner_delegate_assignments" ("appointment_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_status_concept_id" ON "delegated_access"."practitioner_delegate_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_created_by_user_id" ON "delegated_access"."practitioner_delegate_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_updated_by_user_id" ON "delegated_access"."practitioner_delegate_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_practitioner_delegate_assignments_effective_period" ON "delegated_access"."practitioner_delegate_assignments" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_practitioner_delegate_assignment_id" ON "delegated_access"."delegated_access_grants" ("practitioner_delegate_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_grant_type_concept_id" ON "delegated_access"."delegated_access_grants" ("grant_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_purpose_of_use_concept_id" ON "delegated_access"."delegated_access_grants" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_patient_profile_id" ON "delegated_access"."delegated_access_grants" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_encounter_id" ON "delegated_access"."delegated_access_grants" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_resource_type_concept_id" ON "delegated_access"."delegated_access_grants" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_approved_by_user_id" ON "delegated_access"."delegated_access_grants" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_status_concept_id" ON "delegated_access"."delegated_access_grants" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_created_by_user_id" ON "delegated_access"."delegated_access_grants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_updated_by_user_id" ON "delegated_access"."delegated_access_grants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_grants_patient_profile_id_updated_at" ON "delegated_access"."delegated_access_grants" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_practitioner_del_01d90a86" ON "delegated_access"."delegated_access_approval_requests" ("practitioner_delegate_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_requested_permission_id" ON "delegated_access"."delegated_access_approval_requests" ("requested_permission_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_patient_profile_id" ON "delegated_access"."delegated_access_approval_requests" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_encounter_id" ON "delegated_access"."delegated_access_approval_requests" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_decided_by_user_id" ON "delegated_access"."delegated_access_approval_requests" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_decision_concept_id" ON "delegated_access"."delegated_access_approval_requests" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_status_concept_id" ON "delegated_access"."delegated_access_approval_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_access_approval_requests_patient_profile__beb5e078" ON "delegated_access"."delegated_access_approval_requests" ("patient_profile_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_delegation_events_practitioner_delegate_assignment_id" ON "delegated_access"."delegation_events" ("practitioner_delegate_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_delegation_events_event_type_concept_id" ON "delegated_access"."delegation_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegation_events_actor_user_id" ON "delegated_access"."delegation_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegation_events_target_user_id" ON "delegated_access"."delegation_events" ("target_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegation_events_reason_concept_id" ON "delegated_access"."delegation_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_delegation_events_created_at" ON "delegated_access"."delegation_events" USING brin ("created_at") WITH (pages_per_range=128);
