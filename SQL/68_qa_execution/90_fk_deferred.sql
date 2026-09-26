-- SALUD v4.0.10 · módulo 68 · schema qa_execution
-- Generado de diagram_68_qa_execution.puml — NO editar a mano.


-- destino: qa_lab.test_environments (requiere schema qa_lab)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_targets"
        ADD CONSTRAINT "fk_execution_targets_environment_id" FOREIGN KEY ("environment_id")
        REFERENCES "qa_lab"."test_environments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_targets"
        ADD CONSTRAINT "fk_execution_targets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_targets"
        ADD CONSTRAINT "fk_execution_targets_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: qa_lab.test_runs (requiere schema qa_lab)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_plans"
        ADD CONSTRAINT "fk_execution_plans_run_id" FOREIGN KEY ("run_id")
        REFERENCES "qa_lab"."test_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: qa_lab.test_suites (requiere schema qa_lab)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_plans"
        ADD CONSTRAINT "fk_execution_plans_suite_id" FOREIGN KEY ("suite_id")
        REFERENCES "qa_lab"."test_suites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: qa_lab.test_environments (requiere schema qa_lab)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_plans"
        ADD CONSTRAINT "fk_execution_plans_environment_id" FOREIGN KEY ("environment_id")
        REFERENCES "qa_lab"."test_environments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_plans"
        ADD CONSTRAINT "fk_execution_plans_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_plans"
        ADD CONSTRAINT "fk_execution_plans_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."execution_plans"
        ADD CONSTRAINT "fk_execution_plans_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."plan_approvals"
        ADD CONSTRAINT "fk_plan_approvals_approver_user_id" FOREIGN KEY ("approver_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: qa_lab.test_cases (requiere schema qa_lab)
DO $$ BEGIN
    ALTER TABLE "qa_execution"."plan_events"
        ADD CONSTRAINT "fk_plan_events_case_id" FOREIGN KEY ("case_id")
        REFERENCES "qa_lab"."test_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
