-- SALUD v4.0.10 · módulo 36 · schema qa_lab
-- Generado de diagram_36_qa_lab.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_test_environments_code" ON "qa_lab"."test_environments" ("code");

CREATE INDEX IF NOT EXISTS "ix_test_environments_environment_concept_id" ON "qa_lab"."test_environments" ("environment_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_environments_tenant_id" ON "qa_lab"."test_environments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_test_environments_state_concept_id" ON "qa_lab"."test_environments" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_environments_created_by_user_id" ON "qa_lab"."test_environments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_environments_updated_by_user_id" ON "qa_lab"."test_environments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_environments_tenant_id_state_concept_id" ON "qa_lab"."test_environments" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_test_suites_code" ON "qa_lab"."test_suites" ("code");

CREATE INDEX IF NOT EXISTS "ix_test_suites_tenant_id" ON "qa_lab"."test_suites" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_target_system_concept_id" ON "qa_lab"."test_suites" ("target_system_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_suite_type_concept_id" ON "qa_lab"."test_suites" ("suite_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_state_concept_id" ON "qa_lab"."test_suites" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_created_by_user_id" ON "qa_lab"."test_suites" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_updated_by_user_id" ON "qa_lab"."test_suites" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_suites_tenant_id_state_concept_id" ON "qa_lab"."test_suites" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_test_cases_suite_id" ON "qa_lab"."test_cases" ("suite_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_case_type_concept_id" ON "qa_lab"."test_cases" ("case_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_endpoint_id" ON "qa_lab"."test_cases" ("endpoint_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_http_method_concept_id" ON "qa_lab"."test_cases" ("http_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_state_concept_id" ON "qa_lab"."test_cases" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_created_by_user_id" ON "qa_lab"."test_cases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_cases_updated_by_user_id" ON "qa_lab"."test_cases" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_assertions_test_case_id" ON "qa_lab"."test_assertions" ("test_case_id");

CREATE INDEX IF NOT EXISTS "ix_test_assertions_assertion_type_concept_id" ON "qa_lab"."test_assertions" ("assertion_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_assertions_operator_concept_id" ON "qa_lab"."test_assertions" ("operator_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_assertions_created_by_user_id" ON "qa_lab"."test_assertions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_assertions_updated_by_user_id" ON "qa_lab"."test_assertions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_fixtures_suite_id" ON "qa_lab"."test_fixtures" ("suite_id");

CREATE INDEX IF NOT EXISTS "ix_test_fixtures_test_case_id" ON "qa_lab"."test_fixtures" ("test_case_id");

CREATE INDEX IF NOT EXISTS "ix_test_fixtures_file_id" ON "qa_lab"."test_fixtures" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_test_fixtures_fixture_type_concept_id" ON "qa_lab"."test_fixtures" ("fixture_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_fixtures_created_by_user_id" ON "qa_lab"."test_fixtures" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_fixtures_updated_by_user_id" ON "qa_lab"."test_fixtures" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_test_runs_run_number" ON "qa_lab"."test_runs" ("run_number");

CREATE INDEX IF NOT EXISTS "ix_test_runs_suite_id" ON "qa_lab"."test_runs" ("suite_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_environment_id" ON "qa_lab"."test_runs" ("environment_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_tenant_id" ON "qa_lab"."test_runs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_trigger_concept_id" ON "qa_lab"."test_runs" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_triggered_by_user_id" ON "qa_lab"."test_runs" ("triggered_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_status_concept_id" ON "qa_lab"."test_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_created_by_user_id" ON "qa_lab"."test_runs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_updated_by_user_id" ON "qa_lab"."test_runs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_runs_tenant_id_status_concept_id" ON "qa_lab"."test_runs" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_test_case_results_test_run_id" ON "qa_lab"."test_case_results" ("test_run_id");

CREATE INDEX IF NOT EXISTS "ix_test_case_results_test_case_id" ON "qa_lab"."test_case_results" ("test_case_id");

CREATE INDEX IF NOT EXISTS "ix_test_case_results_status_concept_id" ON "qa_lab"."test_case_results" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_case_results_error_type_concept_id" ON "qa_lab"."test_case_results" ("error_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_case_results_created_by_user_id" ON "qa_lab"."test_case_results" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_case_results_updated_by_user_id" ON "qa_lab"."test_case_results" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assertion_results_test_case_result_id" ON "qa_lab"."assertion_results" ("test_case_result_id");

CREATE INDEX IF NOT EXISTS "ix_assertion_results_test_assertion_id" ON "qa_lab"."assertion_results" ("test_assertion_id");

CREATE INDEX IF NOT EXISTS "ix_assertion_results_recorded_by_user_id" ON "qa_lab"."assertion_results" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_assertion_results_recorded_at" ON "qa_lab"."assertion_results" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_request_payloads_test_case_result_id" ON "qa_lab"."request_payloads" ("test_case_result_id");

CREATE INDEX IF NOT EXISTS "ix_request_payloads_direction_concept_id" ON "qa_lab"."request_payloads" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_request_payloads_http_method_concept_id" ON "qa_lab"."request_payloads" ("http_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_request_payloads_recorded_by_user_id" ON "qa_lab"."request_payloads" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_request_payloads_recorded_at" ON "qa_lab"."request_payloads" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_response_payloads_test_case_result_id" ON "qa_lab"."response_payloads" ("test_case_result_id");

CREATE INDEX IF NOT EXISTS "ix_response_payloads_request_payload_id" ON "qa_lab"."response_payloads" ("request_payload_id");

CREATE INDEX IF NOT EXISTS "ix_response_payloads_recorded_by_user_id" ON "qa_lab"."response_payloads" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_response_payloads_recorded_at" ON "qa_lab"."response_payloads" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_run_artifacts_test_run_id" ON "qa_lab"."run_artifacts" ("test_run_id");

CREATE INDEX IF NOT EXISTS "ix_run_artifacts_test_case_result_id" ON "qa_lab"."run_artifacts" ("test_case_result_id");

CREATE INDEX IF NOT EXISTS "ix_run_artifacts_artifact_type_concept_id" ON "qa_lab"."run_artifacts" ("artifact_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_run_artifacts_file_id" ON "qa_lab"."run_artifacts" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_run_artifacts_created_by_user_id" ON "qa_lab"."run_artifacts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_run_artifacts_updated_by_user_id" ON "qa_lab"."run_artifacts" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_test_schedules_code" ON "qa_lab"."test_schedules" ("code");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_suite_id" ON "qa_lab"."test_schedules" ("suite_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_environment_id" ON "qa_lab"."test_schedules" ("environment_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_tenant_id" ON "qa_lab"."test_schedules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_trigger_concept_id" ON "qa_lab"."test_schedules" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_concurrency_policy_concept_id" ON "qa_lab"."test_schedules" ("concurrency_policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_last_run_id" ON "qa_lab"."test_schedules" ("last_run_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_notify_channel_concept_id" ON "qa_lab"."test_schedules" ("notify_channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_state_concept_id" ON "qa_lab"."test_schedules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_created_by_user_id" ON "qa_lab"."test_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_updated_by_user_id" ON "qa_lab"."test_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_schedules_tenant_id_state_concept_id" ON "qa_lab"."test_schedules" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_test_defects_defect_number" ON "qa_lab"."test_defects" ("defect_number");

CREATE INDEX IF NOT EXISTS "ix_test_defects_tenant_id" ON "qa_lab"."test_defects" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_test_case_id" ON "qa_lab"."test_defects" ("test_case_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_test_case_result_id" ON "qa_lab"."test_defects" ("test_case_result_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_defect_type_concept_id" ON "qa_lab"."test_defects" ("defect_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_severity_concept_id" ON "qa_lab"."test_defects" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_status_concept_id" ON "qa_lab"."test_defects" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_assigned_to_user_id" ON "qa_lab"."test_defects" ("assigned_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_state_concept_id" ON "qa_lab"."test_defects" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_created_by_user_id" ON "qa_lab"."test_defects" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_updated_by_user_id" ON "qa_lab"."test_defects" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_test_defects_tenant_id_status_concept_id" ON "qa_lab"."test_defects" ("tenant_id", "status_concept_id", "updated_at" DESC);
