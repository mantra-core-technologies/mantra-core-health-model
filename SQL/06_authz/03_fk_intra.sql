-- SALUD v4.0.10 · módulo 06 · schema authz
-- Generado de diagram_06_authz.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "authz"."permissions"
        ADD CONSTRAINT "fk_permissions_category_id" FOREIGN KEY ("category_id")
        REFERENCES "authz"."permission_categories" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."roles"
        ADD CONSTRAINT "fk_roles_parent_role_id" FOREIGN KEY ("parent_role_id")
        REFERENCES "authz"."roles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."role_permissions"
        ADD CONSTRAINT "fk_role_permissions_role_id" FOREIGN KEY ("role_id")
        REFERENCES "authz"."roles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."role_permissions"
        ADD CONSTRAINT "fk_role_permissions_permission_id" FOREIGN KEY ("permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."user_role_assignments"
        ADD CONSTRAINT "fk_user_role_assignments_role_id" FOREIGN KEY ("role_id")
        REFERENCES "authz"."roles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."user_permission_grants"
        ADD CONSTRAINT "fk_user_permission_grants_permission_id" FOREIGN KEY ("permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."field_permissions"
        ADD CONSTRAINT "fk_field_permissions_role_id" FOREIGN KEY ("role_id")
        REFERENCES "authz"."roles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."resource_scope_grants"
        ADD CONSTRAINT "fk_resource_scope_grants_permission_id" FOREIGN KEY ("permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "authz"."break_glass_sessions"
        ADD CONSTRAINT "fk_break_glass_sessions_granted_by_policy_id" FOREIGN KEY ("granted_by_policy_id")
        REFERENCES "authz"."access_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
