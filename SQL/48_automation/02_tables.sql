-- SALUD v4.0.10 · módulo 48 · schema automation
-- Generado de diagram_48_automation.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "automation"."agents" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "agent_type_concept_id" uuid NOT NULL,
    "description" text,
    "default_model_concept_id" uuid,
    "system_service_component_id" uuid,
    "autonomy_level_concept_id" uuid NOT NULL,
    "acts_as_user_id" uuid,
    "current_version" integer NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_agents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."agent_versions" (
    "id" uuid NOT NULL,
    "agent_id" uuid NOT NULL,
    "version" integer NOT NULL,
    "prompt_template" text NOT NULL,
    "model_concept_id" uuid,
    "model_params_json" jsonb,
    "input_schema_json" jsonb,
    "output_schema_json" jsonb,
    "changelog" text,
    "status_concept_id" uuid NOT NULL,
    "published_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_agent_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."agent_tools" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "tool_type_concept_id" uuid NOT NULL,
    "target_resource" varchar,
    "input_schema_json" jsonb,
    "output_schema_json" jsonb,
    "integration_endpoint_id" uuid,
    "is_write" boolean,
    "requires_approval" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_agent_tools" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."agent_tool_bindings" (
    "id" uuid NOT NULL,
    "agent_version_id" uuid NOT NULL,
    "agent_tool_id" uuid NOT NULL,
    "scope_json" jsonb,
    "max_calls_per_run" integer,
    "permission_effect_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_agent_tool_bindings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."guardrail_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "policy_type_concept_id" uuid NOT NULL,
    "rule_json" jsonb,
    "pii_phi_handling_concept_id" uuid,
    "max_cost_amount" numeric,
    "enforcement_concept_id" uuid NOT NULL,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_guardrail_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."agent_guardrails" (
    "id" uuid NOT NULL,
    "agent_id" uuid NOT NULL,
    "guardrail_policy_id" uuid NOT NULL,
    "is_enabled" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_agent_guardrails" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."workflows" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "orchestration_type_concept_id" uuid NOT NULL,
    "definition_json" jsonb,
    "current_version" integer NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_workflows" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."workflow_steps" (
    "id" uuid NOT NULL,
    "workflow_id" uuid NOT NULL,
    "step_code" varchar NOT NULL,
    "step_type_concept_id" uuid NOT NULL,
    "agent_id" uuid,
    "agent_tool_id" uuid,
    "on_success_step_id" uuid,
    "on_failure_step_id" uuid,
    "config_json" jsonb,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_workflow_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."automation_triggers" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "trigger_type_concept_id" uuid NOT NULL,
    "event_type" varchar,
    "target_resource_type" varchar,
    "condition_json" jsonb,
    "schedule_cron" varchar,
    "workflow_id" uuid NOT NULL,
    "is_enabled" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    "campaign_schedule_id" uuid,
    "schedule_source_concept_id" uuid NOT NULL,
    CONSTRAINT "pk_automation_triggers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."record_automations" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "name" varchar NOT NULL,
    "target_resource_type" varchar NOT NULL,
    "automation_action_concept_id" uuid NOT NULL,
    "field_mapping_json" jsonb,
    "validation_json" jsonb,
    "agent_id" uuid,
    "workflow_id" uuid,
    "write_mode_concept_id" uuid NOT NULL,
    "dedupe_key_expr" varchar,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_record_automations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."workflow_runs" (
    "id" uuid NOT NULL,
    "workflow_id" uuid NOT NULL,
    "trigger_id" uuid,
    "tenant_id" uuid,
    "run_number" varchar NOT NULL,
    "trigger_source_concept_id" uuid NOT NULL,
    "input_json" jsonb,
    "context_ref_type" varchar,
    "context_ref_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "total_cost_amount" numeric,
    "error_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_workflow_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."agent_runs" (
    "id" uuid NOT NULL,
    "workflow_run_id" uuid,
    "agent_id" uuid NOT NULL,
    "agent_version_id" uuid NOT NULL,
    "task_type_concept_id" uuid NOT NULL,
    "input_json" jsonb,
    "output_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "input_tokens" integer,
    "output_tokens" integer,
    "cost_amount" numeric,
    "latency_ms" integer,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_agent_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."agent_run_steps" (
    "id" uuid NOT NULL,
    "agent_run_id" uuid NOT NULL,
    "sequence_no" integer NOT NULL,
    "step_kind_concept_id" uuid NOT NULL,
    "agent_tool_id" uuid,
    "thought_text" text,
    "tool_input_json" jsonb,
    "tool_output_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "error_text" text,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_agent_run_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."automation_approvals" (
    "id" uuid NOT NULL,
    "agent_run_id" uuid NOT NULL,
    "agent_run_step_id" uuid,
    "approval_type_concept_id" uuid NOT NULL,
    "requested_action_json" jsonb,
    "target_resource_type" varchar,
    "target_ref_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "decided_by_user_id" uuid,
    "decided_at" timestamptz,
    "decision_note" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_automation_approvals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."agent_memory" (
    "id" uuid NOT NULL,
    "agent_id" uuid NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "scope_ref_id" uuid,
    "memory_type_concept_id" uuid NOT NULL,
    "content_text" text NOT NULL,
    "embedding_ref" varchar,
    "importance" numeric,
    "expires_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_agent_memory" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "automation"."knowledge_sources" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "name" varchar NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "uri" text,
    "file_id" uuid,
    "index_ref" varchar,
    "last_indexed_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_knowledge_sources" PRIMARY KEY ("id")
);
