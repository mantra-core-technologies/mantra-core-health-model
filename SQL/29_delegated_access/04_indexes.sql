-- SALUD v4.2.83 · módulo 29 · schema delegated_access
-- Generado de diagram_29_delegated_access.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_tenant_id" ON "delegated_access"."organization_user_assignments" ("tenant_id", "status_concept_id");

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

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_origin_concept_id" ON "delegated_access"."organization_user_assignments" ("origin_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_owner_kind_concept_id" ON "delegated_access"."organization_user_assignments" ("owner_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_role_template_id" ON "delegated_access"."organization_user_assignments" ("role_template_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_next_recertification" ON "delegated_access"."organization_user_assignments" ("next_recertification_at") WHERE next_recertification_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_org_user_assignments_initiated_by_party" ON "delegated_access"."organization_user_assignments" ("initiated_by_party_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_organization_user_assignments_active_template" ON "delegated_access"."organization_user_assignments" ("tenant_membership_id", "role_template_id") WHERE role_template_id IS NOT NULL AND status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_identity_verified_by_user_id" ON "delegated_access"."organization_user_assignments" ("identity_verified_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_identity_method_concept_id" ON "delegated_access"."organization_user_assignments" ("identity_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_suspension_reason_concept_id" ON "delegated_access"."organization_user_assignments" ("suspension_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_supervisor" ON "delegated_access"."organization_user_assignments" ("supervisor_user_id") WHERE supervisor_user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_tenant_id" ON "delegated_access"."delegated_permission_sets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_delegate_type_concept_id" ON "delegated_access"."delegated_permission_sets" ("delegate_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_status_concept_id" ON "delegated_access"."delegated_permission_sets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_created_by_user_id" ON "delegated_access"."delegated_permission_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_updated_by_user_id" ON "delegated_access"."delegated_permission_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_sets_tenant_id_status_concept_id" ON "delegated_access"."delegated_permission_sets" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_set_items_delegated_permission_set_id" ON "delegated_access"."delegated_permission_set_items" ("delegated_permission_set_id");

CREATE INDEX IF NOT EXISTS "ix_delegated_permission_set_items_permission_id" ON "delegated_access"."delegated_permission_set_items" ("permission_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_tenant_id" ON "delegated_access"."practitioner_delegate_assignments" ("tenant_id", "status_concept_id");

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

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_reply_disclosure__69a0ebfe" ON "delegated_access"."practitioner_delegate_assignments" ("reply_disclosure_concept_id");

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

CREATE UNIQUE INDEX IF NOT EXISTS "uq_shared_access_links_token_hash" ON "delegated_access"."shared_access_links" ("token_hash");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_tenant_id" ON "delegated_access"."shared_access_links" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_patient_profile_id" ON "delegated_access"."shared_access_links" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_resource" ON "delegated_access"."shared_access_links" ("resource_type_concept_id", "resource_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_scope_concept_id" ON "delegated_access"."shared_access_links" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_recipient_kind_concept_id" ON "delegated_access"."shared_access_links" ("recipient_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_purpose_of_use_concept_id" ON "delegated_access"."shared_access_links" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_revoked_by_user_id" ON "delegated_access"."shared_access_links" ("revoked_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_status_concept_id" ON "delegated_access"."shared_access_links" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_created_by_user_id" ON "delegated_access"."shared_access_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_updated_by_user_id" ON "delegated_access"."shared_access_links" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_live_expiry" ON "delegated_access"."shared_access_links" ("expires_at") WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_patient_profile_id_created_at" ON "delegated_access"."shared_access_links" ("patient_profile_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_shared_access_link_uses_link_occurred" ON "delegated_access"."shared_access_link_uses" ("shared_access_link_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_shared_access_link_uses_action_concept_id" ON "delegated_access"."shared_access_link_uses" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_link_uses_outcome_concept_id" ON "delegated_access"."shared_access_link_uses" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "brin_shared_access_link_uses_occurred_at" ON "delegated_access"."shared_access_link_uses" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_role_templates_tenant_id" ON "delegated_access"."role_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_role_templates_status_concept_id" ON "delegated_access"."role_templates" ("status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_role_templates_platform_code_version" ON "delegated_access"."role_templates" ("code", "version_number") WHERE tenant_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_role_templates_tenant_code_version" ON "delegated_access"."role_templates" ("tenant_id", "code", "version_number") WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_role_templates_created_by_user_id" ON "delegated_access"."role_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_role_templates_updated_by_user_id" ON "delegated_access"."role_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_tenant_id" ON "delegated_access"."support_scope_grants" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_org_user_assignment_id" ON "delegated_access"."support_scope_grants" ("organization_user_assignment_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_target_kind_concept_id" ON "delegated_access"."support_scope_grants" ("target_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_practitioner_role_assignment_id" ON "delegated_access"."support_scope_grants" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_healthcare_service_id" ON "delegated_access"."support_scope_grants" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_care_space_id" ON "delegated_access"."support_scope_grants" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_practice_site_id" ON "delegated_access"."support_scope_grants" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_expansion_mode_concept_id" ON "delegated_access"."support_scope_grants" ("expansion_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_status_concept_id" ON "delegated_access"."support_scope_grants" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_approved_by_user_id" ON "delegated_access"."support_scope_grants" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_support_scope_grants_effective_period" ON "delegated_access"."support_scope_grants" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_created_by_user_id" ON "delegated_access"."support_scope_grants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_updated_by_user_id" ON "delegated_access"."support_scope_grants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_effect" ON "delegated_access"."support_scope_grants" ("tenant_id", "effect_concept_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_source_role_template_id" ON "delegated_access"."support_scope_grants" ("source_role_template_id");

CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_tenant_id" ON "delegated_access"."support_grant_actions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_permission_id" ON "delegated_access"."support_grant_actions" ("permission_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_support_grant_actions_grant_permission" ON "delegated_access"."support_grant_actions" ("support_scope_grant_id", "permission_id");

CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_updated_by_user_id" ON "delegated_access"."support_grant_actions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_active" ON "delegated_access"."support_grant_actions" ("support_scope_grant_id") WHERE superseded_at IS NULL;

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_tenant_id" ON "delegated_access"."engagement_requests" ("tenant_id", "status_concept_id", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_requester_user_id" ON "delegated_access"."engagement_requests" ("requester_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_direction_concept_id" ON "delegated_access"."engagement_requests" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_role_template_id" ON "delegated_access"."engagement_requests" ("role_template_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_parent_assignment_id" ON "delegated_access"."engagement_requests" ("parent_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_status_concept_id" ON "delegated_access"."engagement_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_decided_by_user_id" ON "delegated_access"."engagement_requests" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_created_by_user_id" ON "delegated_access"."engagement_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_updated_by_user_id" ON "delegated_access"."engagement_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_tenant_id" ON "delegated_access"."engagement_request_items" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_engagement_request_id" ON "delegated_access"."engagement_request_items" ("engagement_request_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_target_kind_concept_id" ON "delegated_access"."engagement_request_items" ("target_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_practitioner_role_assign_id" ON "delegated_access"."engagement_request_items" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_healthcare_service_id" ON "delegated_access"."engagement_request_items" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_care_space_id" ON "delegated_access"."engagement_request_items" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_practice_site_id" ON "delegated_access"."engagement_request_items" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_decision_concept_id" ON "delegated_access"."engagement_request_items" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_resulting_grant_id" ON "delegated_access"."engagement_request_items" ("resulting_grant_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_lookup" ON "delegated_access"."effective_support_access" ("user_id", "tenant_id", "permission_code");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_tenant_id" ON "delegated_access"."effective_support_access" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_grant_id" ON "delegated_access"."effective_support_access" ("grant_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_practitioner_role_assign_id" ON "delegated_access"."effective_support_access" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_healthcare_service_id" ON "delegated_access"."effective_support_access" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_care_space_id" ON "delegated_access"."effective_support_access" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_governance_rules_tenant_id" ON "delegated_access"."governance_rules" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_governance_rules_active" ON "delegated_access"."governance_rules" ("tenant_id", "rule_kind_concept_id", COALESCE(role_template_code, ''), "permission_pattern") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_governance_rules_rule_kind_concept_id" ON "delegated_access"."governance_rules" ("rule_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_governance_rules_status_concept_id" ON "delegated_access"."governance_rules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_governance_rules_created_by_user_id" ON "delegated_access"."governance_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_governance_rules_updated_by_user_id" ON "delegated_access"."governance_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_tenant_id" ON "delegated_access"."sod_rules" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sod_rules_platform_code_version" ON "delegated_access"."sod_rules" ("code", "version_number") WHERE tenant_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sod_rules_tenant_code_version" ON "delegated_access"."sod_rules" ("tenant_id", "code", "version_number") WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_sod_rules_base_rule_id" ON "delegated_access"."sod_rules" ("base_rule_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_scope_concept_id" ON "delegated_access"."sod_rules" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_action_concept_id" ON "delegated_access"."sod_rules" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_status_concept_id" ON "delegated_access"."sod_rules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_created_by_user_id" ON "delegated_access"."sod_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_updated_by_user_id" ON "delegated_access"."sod_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_tenant_id" ON "delegated_access"."sod_exceptions" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sod_exceptions_active" ON "delegated_access"."sod_exceptions" ("sod_rule_id", "organization_user_assignment_id") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_valid_to" ON "delegated_access"."sod_exceptions" ("valid_to") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_organization_user_assignment_id" ON "delegated_access"."sod_exceptions" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_four_eyes_request_id" ON "delegated_access"."sod_exceptions" ("four_eyes_request_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_status_concept_id" ON "delegated_access"."sod_exceptions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_revoked_by_user_id" ON "delegated_access"."sod_exceptions" ("revoked_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_created_by_user_id" ON "delegated_access"."sod_exceptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_updated_by_user_id" ON "delegated_access"."sod_exceptions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_four_eyes_requests_tenant_id_id" ON "delegated_access"."four_eyes_requests" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_tenant_id" ON "delegated_access"."four_eyes_requests" ("tenant_id", "status_concept_id", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_requester" ON "delegated_access"."four_eyes_requests" ("requester_user_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_four_eyes_requests_pending_payload" ON "delegated_access"."four_eyes_requests" ("tenant_id", "kind_concept_id", "requester_user_id", COALESCE(permission_code, ''), "payload_hash") WHERE status_concept_id = 'a977935a-9073-5113-9644-7df96732e776';

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_kind_concept_id" ON "delegated_access"."four_eyes_requests" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_subject_user_id" ON "delegated_access"."four_eyes_requests" ("subject_user_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_subject" ON "delegated_access"."four_eyes_requests" ("subject_entity", "subject_id") WHERE subject_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_organization_user_assignment_id" ON "delegated_access"."four_eyes_requests" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_approver_kind_concept_id" ON "delegated_access"."four_eyes_requests" ("approver_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_status_concept_id" ON "delegated_access"."four_eyes_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_decided_by_user_id" ON "delegated_access"."four_eyes_requests" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_created_by_user_id" ON "delegated_access"."four_eyes_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_updated_by_user_id" ON "delegated_access"."four_eyes_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_tenant_id" ON "delegated_access"."access_review_campaigns" ("tenant_id", "status_concept_id", "due_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_review_campaigns_recert_month" ON "delegated_access"."access_review_campaigns" ("tenant_id", "name") WHERE kind_concept_id = '9f831109-61d2-54d4-8e67-7ad04ac9a315' AND status_concept_id IN ('743d9f11-b186-5547-ae3d-cc44d94724bd', 'faa5c9bf-5300-5e43-8829-19a9f0e94fef');

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_kind_concept_id" ON "delegated_access"."access_review_campaigns" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_uncertified_action_concept_id" ON "delegated_access"."access_review_campaigns" ("uncertified_action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_owner_user_id" ON "delegated_access"."access_review_campaigns" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_status_concept_id" ON "delegated_access"."access_review_campaigns" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_created_by_user_id" ON "delegated_access"."access_review_campaigns" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_updated_by_user_id" ON "delegated_access"."access_review_campaigns" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_tenant_id" ON "delegated_access"."access_review_items" ("tenant_id", "decision_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_review_items_campaign_grant" ON "delegated_access"."access_review_items" ("access_review_campaign_id", "organization_user_assignment_id", COALESCE(support_scope_grant_id, '00000000-0000-0000-0000-000000000000'::uuid));

CREATE INDEX IF NOT EXISTS "ix_access_review_items_reviewer_pending" ON "delegated_access"."access_review_items" ("reviewer_user_id", "due_at") WHERE decision_concept_id = '55a6db07-19e7-5bb4-978a-3d246492f49d';

CREATE INDEX IF NOT EXISTS "ix_access_review_items_organization_user_assignment_id" ON "delegated_access"."access_review_items" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_reviewer_kind_concept_id" ON "delegated_access"."access_review_items" ("reviewer_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_decision_concept_id" ON "delegated_access"."access_review_items" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_decided_by_user_id" ON "delegated_access"."access_review_items" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_escalated_to_user_id" ON "delegated_access"."access_review_items" ("escalated_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_created_by_user_id" ON "delegated_access"."access_review_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_updated_by_user_id" ON "delegated_access"."access_review_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_tenant_id" ON "delegated_access"."lifecycle_cases" ("tenant_id", "kind_concept_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_lifecycle_cases_open_joiner" ON "delegated_access"."lifecycle_cases" ("organization_user_assignment_id") WHERE kind_concept_id = 'c2a9a59d-c88c-5e87-9065-1e0e068c479d' AND status_concept_id = '4f73e30c-25ba-52ff-969e-862e588cce13';

CREATE UNIQUE INDEX IF NOT EXISTS "uq_lifecycle_cases_open_suspension" ON "delegated_access"."lifecycle_cases" ("organization_user_assignment_id") WHERE kind_concept_id = '767afaf6-3161-56ee-8c96-5e9386804fc0' AND status_concept_id = '4f73e30c-25ba-52ff-969e-862e588cce13';

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_subject_user_id" ON "delegated_access"."lifecycle_cases" ("subject_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_kind_concept_id" ON "delegated_access"."lifecycle_cases" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_status_concept_id" ON "delegated_access"."lifecycle_cases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_opened_by_user_id" ON "delegated_access"."lifecycle_cases" ("opened_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_created_by_user_id" ON "delegated_access"."lifecycle_cases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_updated_by_user_id" ON "delegated_access"."lifecycle_cases" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_tenant_id" ON "delegated_access"."handover_items" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_handover_items_case_source" ON "delegated_access"."handover_items" ("lifecycle_case_id", "item_kind_concept_id", "source_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_item_kind_concept_id" ON "delegated_access"."handover_items" ("item_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_from_user_id" ON "delegated_access"."handover_items" ("from_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_to_user_id" ON "delegated_access"."handover_items" ("to_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_status_concept_id" ON "delegated_access"."handover_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_reassigned_by_user_id" ON "delegated_access"."handover_items" ("reassigned_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_created_by_user_id" ON "delegated_access"."handover_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_updated_by_user_id" ON "delegated_access"."handover_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_patient_restriction_flags_active" ON "delegated_access"."patient_restriction_flags" ("tenant_id", "patient_profile_id", "flag_concept_id") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_lookup" ON "delegated_access"."patient_restriction_flags" ("tenant_id", "patient_profile_id") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_patient_profile_id" ON "delegated_access"."patient_restriction_flags" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_flag_concept_id" ON "delegated_access"."patient_restriction_flags" ("flag_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_status_concept_id" ON "delegated_access"."patient_restriction_flags" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_created_by_user_id" ON "delegated_access"."patient_restriction_flags" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_updated_by_user_id" ON "delegated_access"."patient_restriction_flags" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_tenant_time" ON "delegated_access"."access_decision_log" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_user_time" ON "delegated_access"."access_decision_log" ("user_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_grant" ON "delegated_access"."access_decision_log" ("grant_id") WHERE grant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_effect" ON "delegated_access"."access_decision_log" ("tenant_id", "effect_concept_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_effect_concept_id" ON "delegated_access"."access_decision_log" ("effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_approval_id" ON "delegated_access"."access_decision_log" ("approval_id");

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_recorded_by_user_id" ON "delegated_access"."access_decision_log" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_grant_usage_stats_bucket" ON "delegated_access"."grant_usage_stats" ("tenant_id", "support_scope_grant_id", "permission_code", "bucket_start");

CREATE INDEX IF NOT EXISTS "ix_grant_usage_stats_user" ON "delegated_access"."grant_usage_stats" ("tenant_id", "user_id", "bucket_start");

CREATE INDEX IF NOT EXISTS "ix_grant_usage_stats_grant" ON "delegated_access"."grant_usage_stats" ("support_scope_grant_id", "last_used_at");

CREATE INDEX IF NOT EXISTS "ix_grant_usage_stats_user_id" ON "delegated_access"."grant_usage_stats" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_tenant_id" ON "delegated_access"."access_anomalies" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_anomalies_window" ON "delegated_access"."access_anomalies" ("tenant_id", "user_id", "kind_concept_id", "window_start");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_user_id" ON "delegated_access"."access_anomalies" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_organization_user_assignment_id" ON "delegated_access"."access_anomalies" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_kind_concept_id" ON "delegated_access"."access_anomalies" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_status_concept_id" ON "delegated_access"."access_anomalies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_acknowledged_by_user_id" ON "delegated_access"."access_anomalies" ("acknowledged_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_created_by_user_id" ON "delegated_access"."access_anomalies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_updated_by_user_id" ON "delegated_access"."access_anomalies" ("updated_by_user_id");
