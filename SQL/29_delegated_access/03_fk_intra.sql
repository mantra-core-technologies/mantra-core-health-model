-- SALUD v4.0.10 · módulo 29 · schema delegated_access
-- Generado de diagram_29_delegated_access.puml — NO editar a mano.


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
