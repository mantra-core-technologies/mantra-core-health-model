-- SALUD v4.0.10 · módulo 48 · schema automation
-- Generado de diagram_48_automation.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_agents_code" ON "automation"."agents" ("code");

CREATE INDEX IF NOT EXISTS "ix_agents_tenant_id" ON "automation"."agents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_agents_agent_type_concept_id" ON "automation"."agents" ("agent_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agents_default_model_concept_id" ON "automation"."agents" ("default_model_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agents_system_service_component_id" ON "automation"."agents" ("system_service_component_id");

CREATE INDEX IF NOT EXISTS "ix_agents_autonomy_level_concept_id" ON "automation"."agents" ("autonomy_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agents_acts_as_user_id" ON "automation"."agents" ("acts_as_user_id");

CREATE INDEX IF NOT EXISTS "ix_agents_state_concept_id" ON "automation"."agents" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agents_created_by_user_id" ON "automation"."agents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agents_updated_by_user_id" ON "automation"."agents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agents_tenant_id_state_concept_id" ON "automation"."agents" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_agent_versions_agent_id" ON "automation"."agent_versions" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_agent_versions_model_concept_id" ON "automation"."agent_versions" ("model_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_versions_status_concept_id" ON "automation"."agent_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_versions_created_by_user_id" ON "automation"."agent_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_versions_updated_by_user_id" ON "automation"."agent_versions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_agent_versions_agent_id_version" ON "automation"."agent_versions" ("agent_id", "version");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_agent_tools_code" ON "automation"."agent_tools" ("code");

CREATE INDEX IF NOT EXISTS "ix_agent_tools_tool_type_concept_id" ON "automation"."agent_tools" ("tool_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tools_integration_endpoint_id" ON "automation"."agent_tools" ("integration_endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tools_state_concept_id" ON "automation"."agent_tools" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tools_created_by_user_id" ON "automation"."agent_tools" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tools_updated_by_user_id" ON "automation"."agent_tools" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tool_bindings_agent_version_id" ON "automation"."agent_tool_bindings" ("agent_version_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tool_bindings_agent_tool_id" ON "automation"."agent_tool_bindings" ("agent_tool_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tool_bindings_permission_effect_concept_id" ON "automation"."agent_tool_bindings" ("permission_effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tool_bindings_created_by_user_id" ON "automation"."agent_tool_bindings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_tool_bindings_updated_by_user_id" ON "automation"."agent_tool_bindings" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_guardrail_policies_code" ON "automation"."guardrail_policies" ("code");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_tenant_id" ON "automation"."guardrail_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_policy_type_concept_id" ON "automation"."guardrail_policies" ("policy_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_pii_phi_handling_concept_id" ON "automation"."guardrail_policies" ("pii_phi_handling_concept_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_enforcement_concept_id" ON "automation"."guardrail_policies" ("enforcement_concept_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_created_by_user_id" ON "automation"."guardrail_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_updated_by_user_id" ON "automation"."guardrail_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_guardrail_policies_tenant_id_updated_at" ON "automation"."guardrail_policies" ("tenant_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_agent_guardrails_agent_id" ON "automation"."agent_guardrails" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_agent_guardrails_guardrail_policy_id" ON "automation"."agent_guardrails" ("guardrail_policy_id");

CREATE INDEX IF NOT EXISTS "ix_agent_guardrails_created_by_user_id" ON "automation"."agent_guardrails" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_guardrails_updated_by_user_id" ON "automation"."agent_guardrails" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_workflows_code" ON "automation"."workflows" ("code");

CREATE INDEX IF NOT EXISTS "ix_workflows_tenant_id" ON "automation"."workflows" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_orchestration_type_concept_id" ON "automation"."workflows" ("orchestration_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_state_concept_id" ON "automation"."workflows" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_created_by_user_id" ON "automation"."workflows" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_updated_by_user_id" ON "automation"."workflows" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflows_tenant_id_state_concept_id" ON "automation"."workflows" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_workflow_id" ON "automation"."workflow_steps" ("workflow_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_step_type_concept_id" ON "automation"."workflow_steps" ("step_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_agent_id" ON "automation"."workflow_steps" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_agent_tool_id" ON "automation"."workflow_steps" ("agent_tool_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_on_success_step_id" ON "automation"."workflow_steps" ("on_success_step_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_on_failure_step_id" ON "automation"."workflow_steps" ("on_failure_step_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_created_by_user_id" ON "automation"."workflow_steps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_steps_updated_by_user_id" ON "automation"."workflow_steps" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_automation_triggers_code" ON "automation"."automation_triggers" ("code");

CREATE INDEX IF NOT EXISTS "ix_automation_triggers_tenant_id" ON "automation"."automation_triggers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_automation_triggers_trigger_type_concept_id" ON "automation"."automation_triggers" ("trigger_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automation_triggers_workflow_id" ON "automation"."automation_triggers" ("workflow_id");

CREATE INDEX IF NOT EXISTS "ix_automation_triggers_state_concept_id" ON "automation"."automation_triggers" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automation_triggers_created_by_user_id" ON "automation"."automation_triggers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_automation_triggers_updated_by_user_id" ON "automation"."automation_triggers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_automation_triggers_tenant_id_state_concept_id" ON "automation"."automation_triggers" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_record_automations_tenant_id" ON "automation"."record_automations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_automation_action_concept_id" ON "automation"."record_automations" ("automation_action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_agent_id" ON "automation"."record_automations" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_workflow_id" ON "automation"."record_automations" ("workflow_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_write_mode_concept_id" ON "automation"."record_automations" ("write_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_created_by_user_id" ON "automation"."record_automations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_updated_by_user_id" ON "automation"."record_automations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_record_automations_tenant_id_updated_at" ON "automation"."record_automations" ("tenant_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_workflow_runs_run_number" ON "automation"."workflow_runs" ("run_number");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_workflow_id" ON "automation"."workflow_runs" ("workflow_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_trigger_id" ON "automation"."workflow_runs" ("trigger_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_tenant_id" ON "automation"."workflow_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_trigger_source_concept_id" ON "automation"."workflow_runs" ("trigger_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_status_concept_id" ON "automation"."workflow_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_created_by_user_id" ON "automation"."workflow_runs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_updated_by_user_id" ON "automation"."workflow_runs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workflow_runs_tenant_id_status_concept_id" ON "automation"."workflow_runs" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_agent_runs_workflow_run_id" ON "automation"."agent_runs" ("workflow_run_id");

CREATE INDEX IF NOT EXISTS "ix_agent_runs_agent_id" ON "automation"."agent_runs" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_agent_runs_agent_version_id" ON "automation"."agent_runs" ("agent_version_id");

CREATE INDEX IF NOT EXISTS "ix_agent_runs_task_type_concept_id" ON "automation"."agent_runs" ("task_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_runs_status_concept_id" ON "automation"."agent_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_runs_created_by_user_id" ON "automation"."agent_runs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_runs_updated_by_user_id" ON "automation"."agent_runs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_run_steps_agent_run_id" ON "automation"."agent_run_steps" ("agent_run_id");

CREATE INDEX IF NOT EXISTS "ix_agent_run_steps_step_kind_concept_id" ON "automation"."agent_run_steps" ("step_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_run_steps_agent_tool_id" ON "automation"."agent_run_steps" ("agent_tool_id");

CREATE INDEX IF NOT EXISTS "ix_agent_run_steps_status_concept_id" ON "automation"."agent_run_steps" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_run_steps_recorded_by_user_id" ON "automation"."agent_run_steps" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_agent_run_steps_recorded_at" ON "automation"."agent_run_steps" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_automation_approvals_agent_run_id" ON "automation"."automation_approvals" ("agent_run_id");

CREATE INDEX IF NOT EXISTS "ix_automation_approvals_agent_run_step_id" ON "automation"."automation_approvals" ("agent_run_step_id");

CREATE INDEX IF NOT EXISTS "ix_automation_approvals_approval_type_concept_id" ON "automation"."automation_approvals" ("approval_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automation_approvals_status_concept_id" ON "automation"."automation_approvals" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_automation_approvals_decided_by_user_id" ON "automation"."automation_approvals" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_automation_approvals_created_by_user_id" ON "automation"."automation_approvals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_automation_approvals_updated_by_user_id" ON "automation"."automation_approvals" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_memory_agent_id" ON "automation"."agent_memory" ("agent_id");

CREATE INDEX IF NOT EXISTS "ix_agent_memory_scope_concept_id" ON "automation"."agent_memory" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_memory_memory_type_concept_id" ON "automation"."agent_memory" ("memory_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_memory_status_concept_id" ON "automation"."agent_memory" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_agent_memory_created_by_user_id" ON "automation"."agent_memory" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_agent_memory_updated_by_user_id" ON "automation"."agent_memory" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_knowledge_sources_tenant_id" ON "automation"."knowledge_sources" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_knowledge_sources_source_type_concept_id" ON "automation"."knowledge_sources" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_knowledge_sources_file_id" ON "automation"."knowledge_sources" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_knowledge_sources_state_concept_id" ON "automation"."knowledge_sources" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_knowledge_sources_created_by_user_id" ON "automation"."knowledge_sources" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_knowledge_sources_updated_by_user_id" ON "automation"."knowledge_sources" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_knowledge_sources_tenant_id_state_concept_id" ON "automation"."knowledge_sources" ("tenant_id", "state_concept_id", "updated_at" DESC);
