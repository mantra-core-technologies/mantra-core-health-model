-- SALUD v4.0.10 · módulo 48 · schema automation
-- Generado de diagram_48_automation.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "automation"."agent_versions"
        ADD CONSTRAINT "fk_agent_versions_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_tool_bindings"
        ADD CONSTRAINT "fk_agent_tool_bindings_agent_version_id" FOREIGN KEY ("agent_version_id")
        REFERENCES "automation"."agent_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_tool_bindings"
        ADD CONSTRAINT "fk_agent_tool_bindings_agent_tool_id" FOREIGN KEY ("agent_tool_id")
        REFERENCES "automation"."agent_tools" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_guardrails"
        ADD CONSTRAINT "fk_agent_guardrails_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_guardrails"
        ADD CONSTRAINT "fk_agent_guardrails_guardrail_policy_id" FOREIGN KEY ("guardrail_policy_id")
        REFERENCES "automation"."guardrail_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."workflow_steps"
        ADD CONSTRAINT "fk_workflow_steps_workflow_id" FOREIGN KEY ("workflow_id")
        REFERENCES "automation"."workflows" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."workflow_steps"
        ADD CONSTRAINT "fk_workflow_steps_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."workflow_steps"
        ADD CONSTRAINT "fk_workflow_steps_agent_tool_id" FOREIGN KEY ("agent_tool_id")
        REFERENCES "automation"."agent_tools" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."workflow_steps"
        ADD CONSTRAINT "fk_workflow_steps_on_success_step_id" FOREIGN KEY ("on_success_step_id")
        REFERENCES "automation"."workflow_steps" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."workflow_steps"
        ADD CONSTRAINT "fk_workflow_steps_on_failure_step_id" FOREIGN KEY ("on_failure_step_id")
        REFERENCES "automation"."workflow_steps" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."automation_triggers"
        ADD CONSTRAINT "fk_automation_triggers_workflow_id" FOREIGN KEY ("workflow_id")
        REFERENCES "automation"."workflows" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."record_automations"
        ADD CONSTRAINT "fk_record_automations_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."record_automations"
        ADD CONSTRAINT "fk_record_automations_workflow_id" FOREIGN KEY ("workflow_id")
        REFERENCES "automation"."workflows" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."workflow_runs"
        ADD CONSTRAINT "fk_workflow_runs_workflow_id" FOREIGN KEY ("workflow_id")
        REFERENCES "automation"."workflows" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."workflow_runs"
        ADD CONSTRAINT "fk_workflow_runs_trigger_id" FOREIGN KEY ("trigger_id")
        REFERENCES "automation"."automation_triggers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_runs"
        ADD CONSTRAINT "fk_agent_runs_workflow_run_id" FOREIGN KEY ("workflow_run_id")
        REFERENCES "automation"."workflow_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_runs"
        ADD CONSTRAINT "fk_agent_runs_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_runs"
        ADD CONSTRAINT "fk_agent_runs_agent_version_id" FOREIGN KEY ("agent_version_id")
        REFERENCES "automation"."agent_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_run_steps"
        ADD CONSTRAINT "fk_agent_run_steps_agent_run_id" FOREIGN KEY ("agent_run_id")
        REFERENCES "automation"."agent_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_run_steps"
        ADD CONSTRAINT "fk_agent_run_steps_agent_tool_id" FOREIGN KEY ("agent_tool_id")
        REFERENCES "automation"."agent_tools" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."automation_approvals"
        ADD CONSTRAINT "fk_automation_approvals_agent_run_id" FOREIGN KEY ("agent_run_id")
        REFERENCES "automation"."agent_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."automation_approvals"
        ADD CONSTRAINT "fk_automation_approvals_agent_run_step_id" FOREIGN KEY ("agent_run_step_id")
        REFERENCES "automation"."agent_run_steps" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "automation"."agent_memory"
        ADD CONSTRAINT "fk_agent_memory_agent_id" FOREIGN KEY ("agent_id")
        REFERENCES "automation"."agents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
