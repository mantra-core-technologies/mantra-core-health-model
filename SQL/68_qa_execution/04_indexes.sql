-- SALUD v4.0.10 · módulo 68 · schema qa_execution
-- Generado de diagram_68_qa_execution.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "ux_qa_execution_targets_environment" ON "qa_execution"."execution_targets" ("environment_id");

CREATE INDEX IF NOT EXISTS "ix_qa_execution_plans_status_created" ON "qa_execution"."execution_plans" ("status", "created_at");

CREATE INDEX IF NOT EXISTS "ix_qa_execution_plans_run_id" ON "qa_execution"."execution_plans" ("run_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_qa_execution_plans_idempotency" ON "qa_execution"."execution_plans" ("requested_by_user_id", "idempotency_key") WHERE idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_qa_execution_plan_approvals_plan" ON "qa_execution"."plan_approvals" ("plan_id", "created_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_qa_execution_plan_events_seq" ON "qa_execution"."plan_events" ("plan_id", "seq");
