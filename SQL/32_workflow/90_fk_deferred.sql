-- SALUD v4.0.10 · módulo 32 · schema workflow
-- Generado de diagram_32_workflow.puml — NO editar a mano.


-- destino: terminology.value_sets (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_machine_definitions"
        ADD CONSTRAINT "fk_state_machine_definitions_state_value_set_id" FOREIGN KEY ("state_value_set_id")
        REFERENCES "terminology"."value_sets" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_machine_definitions"
        ADD CONSTRAINT "fk_state_machine_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_machine_definitions"
        ADD CONSTRAINT "fk_state_machine_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_machine_definitions"
        ADD CONSTRAINT "fk_state_machine_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_definitions"
        ADD CONSTRAINT "fk_state_definitions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_definitions"
        ADD CONSTRAINT "fk_state_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_definitions"
        ADD CONSTRAINT "fk_state_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_definitions"
        ADD CONSTRAINT "fk_state_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_from_state_concept_id" FOREIGN KEY ("from_state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_to_state_concept_id" FOREIGN KEY ("to_state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_required_permission_id" FOREIGN KEY ("required_permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_definitions"
        ADD CONSTRAINT "fk_state_transition_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_guards"
        ADD CONSTRAINT "fk_transition_guards_guard_type_concept_id" FOREIGN KEY ("guard_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_guards"
        ADD CONSTRAINT "fk_transition_guards_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_guards"
        ADD CONSTRAINT "fk_transition_guards_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_guards"
        ADD CONSTRAINT "fk_transition_guards_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_side_effects"
        ADD CONSTRAINT "fk_transition_side_effects_side_effect_type_concept_id" FOREIGN KEY ("side_effect_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_side_effects"
        ADD CONSTRAINT "fk_transition_side_effects_execution_mode_concept_id" FOREIGN KEY ("execution_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_side_effects"
        ADD CONSTRAINT "fk_transition_side_effects_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_side_effects"
        ADD CONSTRAINT "fk_transition_side_effects_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."transition_side_effects"
        ADD CONSTRAINT "fk_transition_side_effects_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_events"
        ADD CONSTRAINT "fk_state_transition_events_from_state_concept_id" FOREIGN KEY ("from_state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_events"
        ADD CONSTRAINT "fk_state_transition_events_to_state_concept_id" FOREIGN KEY ("to_state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_events"
        ADD CONSTRAINT "fk_state_transition_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_events"
        ADD CONSTRAINT "fk_state_transition_events_actor_tenant_id" FOREIGN KEY ("actor_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."state_transition_events"
        ADD CONSTRAINT "fk_state_transition_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_instances"
        ADD CONSTRAINT "fk_workflow_instances_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_instances"
        ADD CONSTRAINT "fk_workflow_instances_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_instances"
        ADD CONSTRAINT "fk_workflow_instances_current_state_concept_id" FOREIGN KEY ("current_state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_instances"
        ADD CONSTRAINT "fk_workflow_instances_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_instances"
        ADD CONSTRAINT "fk_workflow_instances_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_instances"
        ADD CONSTRAINT "fk_workflow_instances_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_task_type_concept_id" FOREIGN KEY ("task_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_assigned_user_id" FOREIGN KEY ("assigned_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_assigned_role_concept_id" FOREIGN KEY ("assigned_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_required_permission_id" FOREIGN KEY ("required_permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "workflow"."workflow_tasks"
        ADD CONSTRAINT "fk_workflow_tasks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
