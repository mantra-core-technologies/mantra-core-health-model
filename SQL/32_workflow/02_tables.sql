-- SALUD v4.0.10 · módulo 32 · schema workflow
-- Generado de diagram_32_workflow.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "workflow"."state_machine_definitions" (
    "id" uuid NOT NULL,
    "machine_code" varchar NOT NULL,
    "aggregate_schema_name" varchar NOT NULL,
    "aggregate_entity_name" varchar NOT NULL,
    "status_field_name" varchar NOT NULL,
    "state_value_set_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "effective_from" timestamptz,
    "effective_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_state_machine_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "workflow"."state_definitions" (
    "id" uuid NOT NULL,
    "state_machine_definition_id" uuid NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "state_code_snapshot" varchar NOT NULL,
    "is_initial" boolean NOT NULL,
    "is_terminal" boolean NOT NULL,
    "allows_edit" boolean NOT NULL,
    "ordinal" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_state_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "workflow"."state_transition_definitions" (
    "id" uuid NOT NULL,
    "state_machine_definition_id" uuid NOT NULL,
    "transition_code" varchar NOT NULL,
    "from_state_concept_id" uuid NOT NULL,
    "to_state_concept_id" uuid NOT NULL,
    "command_code" varchar NOT NULL,
    "required_permission_id" uuid NOT NULL,
    "purpose_of_use_concept_id" uuid NOT NULL,
    "idempotency_required" boolean,
    "optimistic_lock_required" boolean,
    "reason_required" boolean,
    "transition_timeout_seconds" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_state_transition_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "workflow"."transition_guards" (
    "id" uuid NOT NULL,
    "state_transition_definition_id" uuid NOT NULL,
    "guard_code" varchar NOT NULL,
    "guard_type_concept_id" uuid NOT NULL,
    "evaluation_order" integer NOT NULL,
    "expression_json" jsonb,
    "failure_code" varchar,
    "failure_message_key" varchar,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_transition_guards" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "workflow"."transition_side_effects" (
    "id" uuid NOT NULL,
    "state_transition_definition_id" uuid NOT NULL,
    "side_effect_code" varchar NOT NULL,
    "side_effect_type_concept_id" uuid NOT NULL,
    "execution_mode_concept_id" uuid NOT NULL,
    "execution_order" integer NOT NULL,
    "outbox_event_type" varchar,
    "action_spec_json" jsonb,
    "compensation_spec_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_transition_side_effects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "workflow"."state_transition_events" (
    "id" uuid NOT NULL,
    "state_machine_definition_id" uuid NOT NULL,
    "transition_definition_id" uuid NOT NULL,
    "aggregate_id" uuid NOT NULL,
    "from_state_concept_id" uuid NOT NULL,
    "to_state_concept_id" uuid NOT NULL,
    "actor_user_id" uuid NOT NULL,
    "actor_tenant_id" uuid,
    "reason_concept_id" uuid,
    "reason_text" text,
    "idempotency_key" varchar,
    "correlation_id" uuid,
    "causation_id" uuid,
    "aggregate_row_version_before" integer,
    "aggregate_row_version_after" integer,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_state_transition_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "workflow"."workflow_instances" (
    "id" uuid NOT NULL,
    "workflow_code" varchar NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "current_state_concept_id" uuid NOT NULL,
    "current_step_code" varchar,
    "context_json" jsonb,
    "due_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_workflow_instances" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "workflow"."workflow_tasks" (
    "id" uuid NOT NULL,
    "workflow_instance_id" uuid NOT NULL,
    "task_code" varchar NOT NULL,
    "task_type_concept_id" uuid NOT NULL,
    "assigned_user_id" uuid,
    "assigned_role_concept_id" uuid,
    "required_permission_id" uuid,
    "due_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_workflow_tasks" PRIMARY KEY ("id")
);
