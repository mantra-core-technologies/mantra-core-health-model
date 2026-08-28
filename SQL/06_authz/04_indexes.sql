-- SALUD v4.0.10 · módulo 06 · schema authz
-- Generado de diagram_06_authz.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_permission_categories_code" ON "authz"."permission_categories" ("code");

CREATE INDEX IF NOT EXISTS "ix_permission_categories_created_by_user_id" ON "authz"."permission_categories" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_permission_categories_updated_by_user_id" ON "authz"."permission_categories" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_permissions_code" ON "authz"."permissions" ("code");

CREATE INDEX IF NOT EXISTS "ix_permissions_category_id" ON "authz"."permissions" ("category_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_action_concept_id" ON "authz"."permissions" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_default_scope_concept_id" ON "authz"."permissions" ("default_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_state_concept_id" ON "authz"."permissions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_created_by_user_id" ON "authz"."permissions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_updated_by_user_id" ON "authz"."permissions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_roles_tenant_id" ON "authz"."roles" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_roles_parent_role_id" ON "authz"."roles" ("parent_role_id");

CREATE INDEX IF NOT EXISTS "ix_roles_base_role_concept_id" ON "authz"."roles" ("base_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_roles_scope_concept_id" ON "authz"."roles" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_roles_state_concept_id" ON "authz"."roles" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_roles_created_by_user_id" ON "authz"."roles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_roles_updated_by_user_id" ON "authz"."roles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_roles_tenant_id_state_concept_id" ON "authz"."roles" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_role_permissions_role_id" ON "authz"."role_permissions" ("role_id");

CREATE INDEX IF NOT EXISTS "ix_role_permissions_permission_id" ON "authz"."role_permissions" ("permission_id");

CREATE INDEX IF NOT EXISTS "ix_role_permissions_effect_concept_id" ON "authz"."role_permissions" ("effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_role_permissions_scope_concept_id" ON "authz"."role_permissions" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_role_permissions_field_value_set_id" ON "authz"."role_permissions" ("field_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_role_permissions_state_concept_id" ON "authz"."role_permissions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_role_permissions_created_by_user_id" ON "authz"."role_permissions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_role_permissions_updated_by_user_id" ON "authz"."role_permissions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_user_id" ON "authz"."user_role_assignments" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_role_id" ON "authz"."user_role_assignments" ("role_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_tenant_id" ON "authz"."user_role_assignments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_branch_id" ON "authz"."user_role_assignments" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_practice_id" ON "authz"."user_role_assignments" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_assigned_by_user_id" ON "authz"."user_role_assignments" ("assigned_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_status_concept_id" ON "authz"."user_role_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_created_by_user_id" ON "authz"."user_role_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_updated_by_user_id" ON "authz"."user_role_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_role_assignments_tenant_id_status_concept_id" ON "authz"."user_role_assignments" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_user_role_assignments_effective_period" ON "authz"."user_role_assignments" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_user_id" ON "authz"."user_permission_grants" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_permission_id" ON "authz"."user_permission_grants" ("permission_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_effect_concept_id" ON "authz"."user_permission_grants" ("effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_scope_concept_id" ON "authz"."user_permission_grants" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_tenant_id" ON "authz"."user_permission_grants" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_state_concept_id" ON "authz"."user_permission_grants" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_created_by_user_id" ON "authz"."user_permission_grants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_updated_by_user_id" ON "authz"."user_permission_grants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_permission_grants_tenant_id_state_concept_id" ON "authz"."user_permission_grants" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_field_permissions_role_id" ON "authz"."field_permissions" ("role_id");

CREATE INDEX IF NOT EXISTS "ix_field_permissions_mask_strategy_concept_id" ON "authz"."field_permissions" ("mask_strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_permissions_created_by_user_id" ON "authz"."field_permissions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_permissions_updated_by_user_id" ON "authz"."field_permissions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_subject_type_concept_id" ON "authz"."resource_scope_grants" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_permission_id" ON "authz"."resource_scope_grants" ("permission_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_resource_type_concept_id" ON "authz"."resource_scope_grants" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_effect_concept_id" ON "authz"."resource_scope_grants" ("effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_tenant_id" ON "authz"."resource_scope_grants" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_created_by_user_id" ON "authz"."resource_scope_grants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_updated_by_user_id" ON "authz"."resource_scope_grants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_resource_scope_grants_tenant_id_updated_at" ON "authz"."resource_scope_grants" ("tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_access_policies_tenant_id" ON "authz"."access_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_access_policies_effect_concept_id" ON "authz"."access_policies" ("effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_policies_state_concept_id" ON "authz"."access_policies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_policies_created_by_user_id" ON "authz"."access_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_policies_updated_by_user_id" ON "authz"."access_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_policies_tenant_id_state_concept_id" ON "authz"."access_policies" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_patient_profile_id" ON "authz"."clinical_access_grants" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_granted_user_id" ON "authz"."clinical_access_grants" ("granted_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_tenant_id" ON "authz"."clinical_access_grants" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_branch_id" ON "authz"."clinical_access_grants" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_encounter_id" ON "authz"."clinical_access_grants" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_consent_id" ON "authz"."clinical_access_grants" ("consent_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_reason_concept_id" ON "authz"."clinical_access_grants" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_access_level_concept_id" ON "authz"."clinical_access_grants" ("access_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_state_concept_id" ON "authz"."clinical_access_grants" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_created_by_user_id" ON "authz"."clinical_access_grants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_updated_by_user_id" ON "authz"."clinical_access_grants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_tenant_id_state_concept_id" ON "authz"."clinical_access_grants" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_clinical_access_grants_patient_profile_id_updated_at" ON "authz"."clinical_access_grants" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_break_glass_sessions_user_id" ON "authz"."break_glass_sessions" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_break_glass_sessions_tenant_id" ON "authz"."break_glass_sessions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_break_glass_sessions_patient_ref_id" ON "authz"."break_glass_sessions" ("patient_ref_id");

CREATE INDEX IF NOT EXISTS "ix_break_glass_sessions_status_concept_id" ON "authz"."break_glass_sessions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_break_glass_sessions_review_outcome_concept_id" ON "authz"."break_glass_sessions" ("review_outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ip_access_rules_tenant_id" ON "authz"."ip_access_rules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_ip_access_rules_scope_concept_id" ON "authz"."ip_access_rules" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_ip_access_rules_rule_type_concept_id" ON "authz"."ip_access_rules" ("rule_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_relationships_tenant_id" ON "authz"."care_relationships" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_relationships_patient_profile_id" ON "authz"."care_relationships" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_care_relationships_practitioner_profile_id" ON "authz"."care_relationships" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_legal_representations_tenant_id" ON "authz"."patient_legal_representations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_patient_legal_representations_patient_profile_id" ON "authz"."patient_legal_representations" ("patient_profile_id");
