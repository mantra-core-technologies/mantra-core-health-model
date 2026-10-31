-- SALUD v4.2.81 · módulo 29 · schema delegated_access
-- Generado de diagram_29_delegated_access.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_role_template_id" FOREIGN KEY ("role_template_id")
        REFERENCES "delegated_access"."role_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_permission_set_items"
        ADD CONSTRAINT "fk_delegated_permission_set_items_delegated_permission_set_id" FOREIGN KEY ("delegated_permission_set_id")
        REFERENCES "delegated_access"."delegated_permission_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_delegate_user_ass_501b9011" FOREIGN KEY ("delegate_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_delegated_permiss_f69e2298" FOREIGN KEY ("delegated_permission_set_id")
        REFERENCES "delegated_access"."delegated_permission_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_link_uses"
        ADD CONSTRAINT "fk_shared_access_link_uses_shared_access_link_id" FOREIGN KEY ("shared_access_link_id")
        REFERENCES "delegated_access"."shared_access_links" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_grants"
        ADD CONSTRAINT "fk_delegated_access_grants_practitioner_delegate_assignment_id" FOREIGN KEY ("practitioner_delegate_assignment_id")
        REFERENCES "delegated_access"."practitioner_delegate_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegated_access_approval_requests"
        ADD CONSTRAINT "fk_delegated_access_approval_requests_practitioner_del_a6db1929" FOREIGN KEY ("practitioner_delegate_assignment_id")
        REFERENCES "delegated_access"."practitioner_delegate_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."delegation_events"
        ADD CONSTRAINT "fk_delegation_events_practitioner_delegate_assignment_id" FOREIGN KEY ("practitioner_delegate_assignment_id")
        REFERENCES "delegated_access"."practitioner_delegate_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_source_role_template_id" FOREIGN KEY ("source_role_template_id")
        REFERENCES "delegated_access"."role_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_grant_actions"
        ADD CONSTRAINT "fk_support_grant_actions_support_scope_grant_id" FOREIGN KEY ("support_scope_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_role_template_id" FOREIGN KEY ("role_template_id")
        REFERENCES "delegated_access"."role_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_parent_assignment_id" FOREIGN KEY ("parent_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_engagement_request_id" FOREIGN KEY ("engagement_request_id")
        REFERENCES "delegated_access"."engagement_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_resulting_grant_id" FOREIGN KEY ("resulting_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."effective_support_access"
        ADD CONSTRAINT "fk_effective_support_access_grant_id" FOREIGN KEY ("grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_base_rule_id" FOREIGN KEY ("base_rule_id")
        REFERENCES "delegated_access"."sod_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_sod_rule_id" FOREIGN KEY ("sod_rule_id")
        REFERENCES "delegated_access"."sod_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_four_eyes_request_id" FOREIGN KEY ("four_eyes_request_id")
        REFERENCES "delegated_access"."four_eyes_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_access_review_campaign_id" FOREIGN KEY ("access_review_campaign_id")
        REFERENCES "delegated_access"."access_review_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_support_scope_grant_id" FOREIGN KEY ("support_scope_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_lifecycle_case_id" FOREIGN KEY ("lifecycle_case_id")
        REFERENCES "delegated_access"."lifecycle_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_grant_id" FOREIGN KEY ("grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_approval_id" FOREIGN KEY ("approval_id")
        REFERENCES "delegated_access"."four_eyes_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."grant_usage_stats"
        ADD CONSTRAINT "fk_grant_usage_stats_support_scope_grant_id" FOREIGN KEY ("support_scope_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
