-- SALUD v4.0.10 · módulo 36 · schema qa_lab
-- Generado de diagram_36_qa_lab.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_cases"
        ADD CONSTRAINT "fk_test_cases_suite_id" FOREIGN KEY ("suite_id")
        REFERENCES "qa_lab"."test_suites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_assertions"
        ADD CONSTRAINT "fk_test_assertions_test_case_id" FOREIGN KEY ("test_case_id")
        REFERENCES "qa_lab"."test_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_fixtures"
        ADD CONSTRAINT "fk_test_fixtures_suite_id" FOREIGN KEY ("suite_id")
        REFERENCES "qa_lab"."test_suites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_fixtures"
        ADD CONSTRAINT "fk_test_fixtures_test_case_id" FOREIGN KEY ("test_case_id")
        REFERENCES "qa_lab"."test_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_runs"
        ADD CONSTRAINT "fk_test_runs_suite_id" FOREIGN KEY ("suite_id")
        REFERENCES "qa_lab"."test_suites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_runs"
        ADD CONSTRAINT "fk_test_runs_environment_id" FOREIGN KEY ("environment_id")
        REFERENCES "qa_lab"."test_environments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_case_results"
        ADD CONSTRAINT "fk_test_case_results_test_run_id" FOREIGN KEY ("test_run_id")
        REFERENCES "qa_lab"."test_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_case_results"
        ADD CONSTRAINT "fk_test_case_results_test_case_id" FOREIGN KEY ("test_case_id")
        REFERENCES "qa_lab"."test_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."assertion_results"
        ADD CONSTRAINT "fk_assertion_results_test_case_result_id" FOREIGN KEY ("test_case_result_id")
        REFERENCES "qa_lab"."test_case_results" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."assertion_results"
        ADD CONSTRAINT "fk_assertion_results_test_assertion_id" FOREIGN KEY ("test_assertion_id")
        REFERENCES "qa_lab"."test_assertions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."request_payloads"
        ADD CONSTRAINT "fk_request_payloads_test_case_result_id" FOREIGN KEY ("test_case_result_id")
        REFERENCES "qa_lab"."test_case_results" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."response_payloads"
        ADD CONSTRAINT "fk_response_payloads_test_case_result_id" FOREIGN KEY ("test_case_result_id")
        REFERENCES "qa_lab"."test_case_results" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."response_payloads"
        ADD CONSTRAINT "fk_response_payloads_request_payload_id" FOREIGN KEY ("request_payload_id")
        REFERENCES "qa_lab"."request_payloads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."run_artifacts"
        ADD CONSTRAINT "fk_run_artifacts_test_run_id" FOREIGN KEY ("test_run_id")
        REFERENCES "qa_lab"."test_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."run_artifacts"
        ADD CONSTRAINT "fk_run_artifacts_test_case_result_id" FOREIGN KEY ("test_case_result_id")
        REFERENCES "qa_lab"."test_case_results" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_schedules"
        ADD CONSTRAINT "fk_test_schedules_suite_id" FOREIGN KEY ("suite_id")
        REFERENCES "qa_lab"."test_suites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_schedules"
        ADD CONSTRAINT "fk_test_schedules_environment_id" FOREIGN KEY ("environment_id")
        REFERENCES "qa_lab"."test_environments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_schedules"
        ADD CONSTRAINT "fk_test_schedules_last_run_id" FOREIGN KEY ("last_run_id")
        REFERENCES "qa_lab"."test_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_defects"
        ADD CONSTRAINT "fk_test_defects_test_case_id" FOREIGN KEY ("test_case_id")
        REFERENCES "qa_lab"."test_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "qa_lab"."test_defects"
        ADD CONSTRAINT "fk_test_defects_test_case_result_id" FOREIGN KEY ("test_case_result_id")
        REFERENCES "qa_lab"."test_case_results" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
