-- SALUD v4.0.10 · módulo 32 · schema workflow
-- Generado de diagram_32_workflow.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_state_machine_definitions_machine_code" ON "workflow"."state_machine_definitions" ("machine_code");

CREATE INDEX IF NOT EXISTS "ix_state_machine_definitions_state_value_set_id" ON "workflow"."state_machine_definitions" ("state_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_state_machine_definitions_status_concept_id" ON "workflow"."state_machine_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_machine_definitions_created_by_user_id" ON "workflow"."state_machine_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_state_machine_definitions_updated_by_user_id" ON "workflow"."state_machine_definitions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_state_machine_definitions_state_value_set_id_version_number" ON "workflow"."state_machine_definitions" ("state_value_set_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_state_definitions_state_machine_definition_id" ON "workflow"."state_definitions" ("state_machine_definition_id");

CREATE INDEX IF NOT EXISTS "ix_state_definitions_state_concept_id" ON "workflow"."state_definitions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_definitions_status_concept_id" ON "workflow"."state_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_definitions_created_by_user_id" ON "workflow"."state_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_state_definitions_updated_by_user_id" ON "workflow"."state_definitions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_state_machine_definition_id" ON "workflow"."state_transition_definitions" ("state_machine_definition_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_from_state_concept_id" ON "workflow"."state_transition_definitions" ("from_state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_to_state_concept_id" ON "workflow"."state_transition_definitions" ("to_state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_required_permission_id" ON "workflow"."state_transition_definitions" ("required_permission_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_purpose_of_use_concept_id" ON "workflow"."state_transition_definitions" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_status_concept_id" ON "workflow"."state_transition_definitions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_created_by_user_id" ON "workflow"."state_transition_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_definitions_updated_by_user_id" ON "workflow"."state_transition_definitions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_transition_guards_state_transition_definition_id" ON "workflow"."transition_guards" ("state_transition_definition_id");

CREATE INDEX IF NOT EXISTS "ix_transition_guards_guard_type_concept_id" ON "workflow"."transition_guards" ("guard_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transition_guards_status_concept_id" ON "workflow"."transition_guards" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transition_guards_created_by_user_id" ON "workflow"."transition_guards" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_transition_guards_updated_by_user_id" ON "workflow"."transition_guards" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_transition_side_effects_state_transition_definition_id" ON "workflow"."transition_side_effects" ("state_transition_definition_id");

CREATE INDEX IF NOT EXISTS "ix_transition_side_effects_side_effect_type_concept_id" ON "workflow"."transition_side_effects" ("side_effect_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transition_side_effects_execution_mode_concept_id" ON "workflow"."transition_side_effects" ("execution_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transition_side_effects_status_concept_id" ON "workflow"."transition_side_effects" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_transition_side_effects_created_by_user_id" ON "workflow"."transition_side_effects" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_transition_side_effects_updated_by_user_id" ON "workflow"."transition_side_effects" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_events_state_machine_definition_id" ON "workflow"."state_transition_events" ("state_machine_definition_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_events_transition_definition_id" ON "workflow"."state_transition_events" ("transition_definition_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_events_from_state_concept_id" ON "workflow"."state_transition_events" ("from_state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_events_to_state_concept_id" ON "workflow"."state_transition_events" ("to_state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_events_actor_user_id" ON "workflow"."state_transition_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_events_actor_tenant_id" ON "workflow"."state_transition_events" ("actor_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_state_transition_events_reason_concept_id" ON "workflow"."state_transition_events" ("reason_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_state_transition_events_idempotency" ON "workflow"."state_transition_events" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "brin_state_transition_events_occurred_at" ON "workflow"."state_transition_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_state_transition_idempotency" ON "workflow"."state_transition_events" ("state_machine_definition_id", "aggregate_id", "idempotency_key") WHERE idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_workflow_instances_subject_type_concept_id" ON "workflow"."workflow_instances" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_instances_tenant_id" ON "workflow"."workflow_instances" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_instances_current_state_concept_id" ON "workflow"."workflow_instances" ("current_state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_instances_status_concept_id" ON "workflow"."workflow_instances" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_instances_created_by_user_id" ON "workflow"."workflow_instances" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_instances_updated_by_user_id" ON "workflow"."workflow_instances" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_instances_tenant_id_status_concept_id" ON "workflow"."workflow_instances" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_workflow_instance_id" ON "workflow"."workflow_tasks" ("workflow_instance_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_task_type_concept_id" ON "workflow"."workflow_tasks" ("task_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_assigned_user_id" ON "workflow"."workflow_tasks" ("assigned_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_assigned_role_concept_id" ON "workflow"."workflow_tasks" ("assigned_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_required_permission_id" ON "workflow"."workflow_tasks" ("required_permission_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_status_concept_id" ON "workflow"."workflow_tasks" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_created_by_user_id" ON "workflow"."workflow_tasks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_tasks_updated_by_user_id" ON "workflow"."workflow_tasks" ("updated_by_user_id");
