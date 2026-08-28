-- SALUD v4.0.10 · módulo 46 · schema platform_ops
-- Generado de diagram_46_platform_ops.puml — NO editar a mano.


-- Requerida por índices GiST sobre columnas escalares (uuid/int/…):
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_service_components_code" ON "platform_ops"."service_components" ("code");

CREATE INDEX IF NOT EXISTS "ix_service_components_tenant_id" ON "platform_ops"."service_components" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_service_components_component_type_concept_id" ON "platform_ops"."service_components" ("component_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_components_criticality_concept_id" ON "platform_ops"."service_components" ("criticality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_components_state_concept_id" ON "platform_ops"."service_components" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_components_created_by_user_id" ON "platform_ops"."service_components" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_components_updated_by_user_id" ON "platform_ops"."service_components" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_components_tenant_id_state_concept_id" ON "platform_ops"."service_components" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_tool_registry_code" ON "platform_ops"."tool_registry" ("code");

CREATE INDEX IF NOT EXISTS "ix_tool_registry_tenant_id" ON "platform_ops"."tool_registry" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tool_registry_tool_type_concept_id" ON "platform_ops"."tool_registry" ("tool_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tool_registry_approved_by_user_id" ON "platform_ops"."tool_registry" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tool_registry_state_concept_id" ON "platform_ops"."tool_registry" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tool_registry_created_by_user_id" ON "platform_ops"."tool_registry" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tool_registry_updated_by_user_id" ON "platform_ops"."tool_registry" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tool_registry_tenant_id_state_concept_id" ON "platform_ops"."tool_registry" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_component_tools_service_component_id" ON "platform_ops"."component_tools" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_component_tools_tool_id" ON "platform_ops"."component_tools" ("tool_id");

CREATE INDEX IF NOT EXISTS "ix_component_tools_usage_concept_id" ON "platform_ops"."component_tools" ("usage_concept_id");

CREATE INDEX IF NOT EXISTS "ix_component_tools_created_by_user_id" ON "platform_ops"."component_tools" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_component_tools_updated_by_user_id" ON "platform_ops"."component_tools" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_artifacts_artifact_ref" ON "platform_ops"."artifacts" ("artifact_ref");

CREATE INDEX IF NOT EXISTS "ix_artifacts_tenant_id" ON "platform_ops"."artifacts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_service_component_id" ON "platform_ops"."artifacts" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_produced_by_tool_id" ON "platform_ops"."artifacts" ("produced_by_tool_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_artifact_type_concept_id" ON "platform_ops"."artifacts" ("artifact_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_file_id" ON "platform_ops"."artifacts" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_state_concept_id" ON "platform_ops"."artifacts" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_created_by_user_id" ON "platform_ops"."artifacts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_updated_by_user_id" ON "platform_ops"."artifacts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_artifacts_tenant_id_state_concept_id" ON "platform_ops"."artifacts" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_artifacts_service_component_id_version" ON "platform_ops"."artifacts" ("service_component_id", "version");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_deployments_deployment_number" ON "platform_ops"."deployments" ("deployment_number");

CREATE INDEX IF NOT EXISTS "ix_deployments_tenant_id" ON "platform_ops"."deployments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_service_component_id" ON "platform_ops"."deployments" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_artifact_id" ON "platform_ops"."deployments" ("artifact_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_environment_concept_id" ON "platform_ops"."deployments" ("environment_concept_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_strategy_concept_id" ON "platform_ops"."deployments" ("strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_status_concept_id" ON "platform_ops"."deployments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_deployed_by_user_id" ON "platform_ops"."deployments" ("deployed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_rollback_of_deployment_id" ON "platform_ops"."deployments" ("rollback_of_deployment_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_created_by_user_id" ON "platform_ops"."deployments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_updated_by_user_id" ON "platform_ops"."deployments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_deployments_tenant_id_status_concept_id" ON "platform_ops"."deployments" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_health_checks_code" ON "platform_ops"."health_checks" ("code");

CREATE INDEX IF NOT EXISTS "ix_health_checks_tenant_id" ON "platform_ops"."health_checks" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_service_component_id" ON "platform_ops"."health_checks" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_check_type_concept_id" ON "platform_ops"."health_checks" ("check_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_target_kind_concept_id" ON "platform_ops"."health_checks" ("target_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_severity_concept_id" ON "platform_ops"."health_checks" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_state_concept_id" ON "platform_ops"."health_checks" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_created_by_user_id" ON "platform_ops"."health_checks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_updated_by_user_id" ON "platform_ops"."health_checks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_checks_tenant_id_state_concept_id" ON "platform_ops"."health_checks" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_health_check_runs_health_check_id" ON "platform_ops"."health_check_runs" ("health_check_id");

CREATE INDEX IF NOT EXISTS "ix_health_check_runs_service_component_id" ON "platform_ops"."health_check_runs" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_health_check_runs_deployment_id" ON "platform_ops"."health_check_runs" ("deployment_id");

CREATE INDEX IF NOT EXISTS "ix_health_check_runs_status_concept_id" ON "platform_ops"."health_check_runs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_check_runs_run_source_concept_id" ON "platform_ops"."health_check_runs" ("run_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_check_runs_recorded_by_user_id" ON "platform_ops"."health_check_runs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_health_check_runs_recorded_at" ON "platform_ops"."health_check_runs" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_health_incidents_incident_number" ON "platform_ops"."health_incidents" ("incident_number");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_tenant_id" ON "platform_ops"."health_incidents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_service_component_id" ON "platform_ops"."health_incidents" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_health_check_id" ON "platform_ops"."health_incidents" ("health_check_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_severity_concept_id" ON "platform_ops"."health_incidents" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_status_concept_id" ON "platform_ops"."health_incidents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_detected_by_run_id" ON "platform_ops"."health_incidents" ("detected_by_run_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_created_by_user_id" ON "platform_ops"."health_incidents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_updated_by_user_id" ON "platform_ops"."health_incidents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_health_incidents_tenant_id_status_concept_id" ON "platform_ops"."health_incidents" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_operational_teams_tenant_id" ON "platform_ops"."operational_teams" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_operational_teams_team_type_concept_id" ON "platform_ops"."operational_teams" ("team_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_teams_manager_user_id" ON "platform_ops"."operational_teams" ("manager_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_teams_state_concept_id" ON "platform_ops"."operational_teams" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_teams_created_by_user_id" ON "platform_ops"."operational_teams" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_teams_updated_by_user_id" ON "platform_ops"."operational_teams" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_teams_tenant_created" ON "platform_ops"."operational_teams" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_operational_teams_tenant_code" ON "platform_ops"."operational_teams" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_service_component_id" ON "platform_ops"."service_ownerships" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_operational_team_id" ON "platform_ops"."service_ownerships" ("operational_team_id");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_ownership_role_concept_id" ON "platform_ops"."service_ownerships" ("ownership_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_escalation_policy_id" ON "platform_ops"."service_ownerships" ("escalation_policy_id");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_state_concept_id" ON "platform_ops"."service_ownerships" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_created_by_user_id" ON "platform_ops"."service_ownerships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_updated_by_user_id" ON "platform_ops"."service_ownerships" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_ownerships_active" ON "platform_ops"."service_ownerships" ("service_component_id", "ownership_role_concept_id", "effective_to");

CREATE INDEX IF NOT EXISTS "ix_service_dependencies_upstream_service_component_id" ON "platform_ops"."service_dependencies" ("upstream_service_component_id");

CREATE INDEX IF NOT EXISTS "ix_service_dependencies_downstream_service_component_id" ON "platform_ops"."service_dependencies" ("downstream_service_component_id");

CREATE INDEX IF NOT EXISTS "ix_service_dependencies_dependency_type_concept_id" ON "platform_ops"."service_dependencies" ("dependency_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_dependencies_criticality_concept_id" ON "platform_ops"."service_dependencies" ("criticality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_dependencies_state_concept_id" ON "platform_ops"."service_dependencies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_dependencies_created_by_user_id" ON "platform_ops"."service_dependencies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_dependencies_updated_by_user_id" ON "platform_ops"."service_dependencies" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_service_dependencies_pair_type" ON "platform_ops"."service_dependencies" ("upstream_service_component_id", "downstream_service_component_id", "dependency_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_schedules_operational_team_id" ON "platform_ops"."on_call_schedules" ("operational_team_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_schedules_state_concept_id" ON "platform_ops"."on_call_schedules" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_schedules_created_by_user_id" ON "platform_ops"."on_call_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_schedules_updated_by_user_id" ON "platform_ops"."on_call_schedules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_on_call_schedules_team_code" ON "platform_ops"."on_call_schedules" ("operational_team_id", "code");

CREATE INDEX IF NOT EXISTS "ix_on_call_shifts_on_call_schedule_id" ON "platform_ops"."on_call_shifts" ("on_call_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_shifts_user_id" ON "platform_ops"."on_call_shifts" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_shifts_state_concept_id" ON "platform_ops"."on_call_shifts" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_shifts_created_by_user_id" ON "platform_ops"."on_call_shifts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_on_call_shifts_updated_by_user_id" ON "platform_ops"."on_call_shifts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_on_call_shifts_schedule_range" ON "platform_ops"."on_call_shifts" USING gist ("on_call_schedule_id", tstzrange(starts_at, ends_at, '[)'));

CREATE INDEX IF NOT EXISTS "ix_escalation_policies_tenant_id" ON "platform_ops"."escalation_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policies_state_concept_id" ON "platform_ops"."escalation_policies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policies_created_by_user_id" ON "platform_ops"."escalation_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policies_updated_by_user_id" ON "platform_ops"."escalation_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policies_tenant_created" ON "platform_ops"."escalation_policies" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_escalation_policies_tenant_code" ON "platform_ops"."escalation_policies" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_escalation_policy_steps_escalation_policy_id" ON "platform_ops"."escalation_policy_steps" ("escalation_policy_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policy_steps_target_type_concept_id" ON "platform_ops"."escalation_policy_steps" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policy_steps_operational_team_id" ON "platform_ops"."escalation_policy_steps" ("operational_team_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policy_steps_on_call_schedule_id" ON "platform_ops"."escalation_policy_steps" ("on_call_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policy_steps_target_user_id" ON "platform_ops"."escalation_policy_steps" ("target_user_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policy_steps_created_by_user_id" ON "platform_ops"."escalation_policy_steps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_escalation_policy_steps_updated_by_user_id" ON "platform_ops"."escalation_policy_steps" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_escalation_policy_steps_policy_step" ON "platform_ops"."escalation_policy_steps" ("escalation_policy_id", "step_number");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_service_component_id" ON "platform_ops"."operational_readiness_reviews" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_deployment_id" ON "platform_ops"."operational_readiness_reviews" ("deployment_id");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_review_type_concept_id" ON "platform_ops"."operational_readiness_reviews" ("review_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_status_concept_id" ON "platform_ops"."operational_readiness_reviews" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_facilitator_user_id" ON "platform_ops"."operational_readiness_reviews" ("facilitator_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_decision_concept_id" ON "platform_ops"."operational_readiness_reviews" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_created_by_user_id" ON "platform_ops"."operational_readiness_reviews" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_readiness_reviews_updated_by_user_id" ON "platform_ops"."operational_readiness_reviews" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_readiness_review_findings_operational_readiness_review_id" ON "platform_ops"."readiness_review_findings" ("operational_readiness_review_id");

CREATE INDEX IF NOT EXISTS "ix_readiness_review_findings_severity_concept_id" ON "platform_ops"."readiness_review_findings" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_readiness_review_findings_status_concept_id" ON "platform_ops"."readiness_review_findings" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_readiness_review_findings_owner_user_id" ON "platform_ops"."readiness_review_findings" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_readiness_review_findings_created_by_user_id" ON "platform_ops"."readiness_review_findings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_readiness_review_findings_updated_by_user_id" ON "platform_ops"."readiness_review_findings" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_readiness_review_findings_review_code" ON "platform_ops"."readiness_review_findings" ("operational_readiness_review_id", "finding_code");

CREATE INDEX IF NOT EXISTS "ix_service_level_indicators_service_component_id" ON "platform_ops"."service_level_indicators" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_indicators_indicator_type_concept_id" ON "platform_ops"."service_level_indicators" ("indicator_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_indicators_unit_concept_id" ON "platform_ops"."service_level_indicators" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_indicators_state_concept_id" ON "platform_ops"."service_level_indicators" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_indicators_created_by_user_id" ON "platform_ops"."service_level_indicators" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_indicators_updated_by_user_id" ON "platform_ops"."service_level_indicators" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_service_level_indicators_service_code" ON "platform_ops"."service_level_indicators" ("service_component_id", "code");

CREATE INDEX IF NOT EXISTS "ix_service_level_objectives_service_level_indicator_id" ON "platform_ops"."service_level_objectives" ("service_level_indicator_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_objectives_state_concept_id" ON "platform_ops"."service_level_objectives" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_objectives_created_by_user_id" ON "platform_ops"."service_level_objectives" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_level_objectives_updated_by_user_id" ON "platform_ops"."service_level_objectives" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_service_level_objectives_indicator_code" ON "platform_ops"."service_level_objectives" ("service_level_indicator_id", "code", "effective_from");

CREATE INDEX IF NOT EXISTS "ix_slo_measurements_service_level_objective_id" ON "platform_ops"."slo_measurements" ("service_level_objective_id");

CREATE INDEX IF NOT EXISTS "ix_slo_measurements_status_concept_id" ON "platform_ops"."slo_measurements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "brin_slo_measurements_created_at" ON "platform_ops"."slo_measurements" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_slo_measurements_objective_window" ON "platform_ops"."slo_measurements" ("service_level_objective_id", "window_end" DESC);

CREATE INDEX IF NOT EXISTS "ix_error_budget_policies_service_level_objective_id" ON "platform_ops"."error_budget_policies" ("service_level_objective_id");

CREATE INDEX IF NOT EXISTS "ix_error_budget_policies_required_approval_role_concept_id" ON "platform_ops"."error_budget_policies" ("required_approval_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_error_budget_policies_state_concept_id" ON "platform_ops"."error_budget_policies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_error_budget_policies_created_by_user_id" ON "platform_ops"."error_budget_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_error_budget_policies_updated_by_user_id" ON "platform_ops"."error_budget_policies" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_error_budget_policies_slo_code" ON "platform_ops"."error_budget_policies" ("service_level_objective_id", "code");

CREATE INDEX IF NOT EXISTS "ix_error_budget_burn_events_error_budget_policy_id" ON "platform_ops"."error_budget_burn_events" ("error_budget_policy_id");

CREATE INDEX IF NOT EXISTS "ix_error_budget_burn_events_severity_concept_id" ON "platform_ops"."error_budget_burn_events" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_error_budget_burn_events_health_incident_id" ON "platform_ops"."error_budget_burn_events" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "brin_error_budget_burn_events_occurred_at" ON "platform_ops"."error_budget_burn_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_runbooks_tenant_id" ON "platform_ops"."runbooks" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_service_component_id" ON "platform_ops"."runbooks" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_runbook_type_concept_id" ON "platform_ops"."runbooks" ("runbook_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_current_version_id" ON "platform_ops"."runbooks" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_owner_team_id" ON "platform_ops"."runbooks" ("owner_team_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_state_concept_id" ON "platform_ops"."runbooks" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_created_by_user_id" ON "platform_ops"."runbooks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_updated_by_user_id" ON "platform_ops"."runbooks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_runbooks_tenant_created" ON "platform_ops"."runbooks" ("tenant_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_runbooks_service_code" ON "platform_ops"."runbooks" ("service_component_id", "code");

CREATE INDEX IF NOT EXISTS "ix_runbook_versions_runbook_id" ON "platform_ops"."runbook_versions" ("runbook_id");

CREATE INDEX IF NOT EXISTS "ix_runbook_versions_approved_by_user_id" ON "platform_ops"."runbook_versions" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_runbook_versions_created_at" ON "platform_ops"."runbook_versions" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_runbook_versions_runbook_version" ON "platform_ops"."runbook_versions" ("runbook_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_runbook_executions_runbook_version_id" ON "platform_ops"."runbook_executions" ("runbook_version_id");

CREATE INDEX IF NOT EXISTS "ix_runbook_executions_health_incident_id" ON "platform_ops"."runbook_executions" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "ix_runbook_executions_change_request_id" ON "platform_ops"."runbook_executions" ("change_request_id");

CREATE INDEX IF NOT EXISTS "ix_runbook_executions_execution_mode_concept_id" ON "platform_ops"."runbook_executions" ("execution_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_runbook_executions_result_concept_id" ON "platform_ops"."runbook_executions" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_runbook_executions_initiated_by_user_id" ON "platform_ops"."runbook_executions" ("initiated_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_runbook_executions_created_at" ON "platform_ops"."runbook_executions" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_change_requests_tenant_id" ON "platform_ops"."change_requests" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_service_component_id" ON "platform_ops"."change_requests" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_deployment_id" ON "platform_ops"."change_requests" ("deployment_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_change_type_concept_id" ON "platform_ops"."change_requests" ("change_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_risk_level_concept_id" ON "platform_ops"."change_requests" ("risk_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_status_concept_id" ON "platform_ops"."change_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_requested_by_user_id" ON "platform_ops"."change_requests" ("requested_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_maintenance_window_id" ON "platform_ops"."change_requests" ("maintenance_window_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_created_by_user_id" ON "platform_ops"."change_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_updated_by_user_id" ON "platform_ops"."change_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_change_requests_tenant_status" ON "platform_ops"."change_requests" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_change_requests_tenant_number" ON "platform_ops"."change_requests" ("tenant_id", "change_number");

CREATE INDEX IF NOT EXISTS "ix_change_approvals_change_request_id" ON "platform_ops"."change_approvals" ("change_request_id");

CREATE INDEX IF NOT EXISTS "ix_change_approvals_approver_user_id" ON "platform_ops"."change_approvals" ("approver_user_id");

CREATE INDEX IF NOT EXISTS "ix_change_approvals_decision_concept_id" ON "platform_ops"."change_approvals" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "brin_change_approvals_created_at" ON "platform_ops"."change_approvals" USING brin ("created_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_change_approvals_change_step_approver" ON "platform_ops"."change_approvals" ("change_request_id", "approval_step", "approver_user_id");

CREATE INDEX IF NOT EXISTS "ix_maintenance_windows_tenant_id" ON "platform_ops"."maintenance_windows" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_maintenance_windows_status_concept_id" ON "platform_ops"."maintenance_windows" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_maintenance_windows_created_by_user_id" ON "platform_ops"."maintenance_windows" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_maintenance_windows_updated_by_user_id" ON "platform_ops"."maintenance_windows" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_maintenance_windows_tenant_status" ON "platform_ops"."maintenance_windows" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gist_maintenance_windows_range" ON "platform_ops"."maintenance_windows" USING gist (tstzrange(starts_at, ends_at, '[)'));

CREATE INDEX IF NOT EXISTS "ix_incident_responders_health_incident_id" ON "platform_ops"."incident_responders" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "ix_incident_responders_user_id" ON "platform_ops"."incident_responders" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_incident_responders_responder_role_concept_id" ON "platform_ops"."incident_responders" ("responder_role_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_incident_responders_incident_user_role" ON "platform_ops"."incident_responders" ("health_incident_id", "user_id", "responder_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_incident_timeline_events_health_incident_id" ON "platform_ops"."incident_timeline_events" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "ix_incident_timeline_events_event_type_concept_id" ON "platform_ops"."incident_timeline_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_incident_timeline_events_actor_user_id" ON "platform_ops"."incident_timeline_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "brin_incident_timeline_events_occurred_at" ON "platform_ops"."incident_timeline_events" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_incident_timeline_incident_occurred" ON "platform_ops"."incident_timeline_events" ("health_incident_id", "occurred_at");

CREATE INDEX IF NOT EXISTS "ix_incident_communications_health_incident_id" ON "platform_ops"."incident_communications" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "ix_incident_communications_communication_type_concept_id" ON "platform_ops"."incident_communications" ("communication_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_incident_communications_audience_concept_id" ON "platform_ops"."incident_communications" ("audience_concept_id");

CREATE INDEX IF NOT EXISTS "ix_incident_communications_published_by_user_id" ON "platform_ops"."incident_communications" ("published_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_incident_communications_created_at" ON "platform_ops"."incident_communications" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_postmortems_health_incident_id" ON "platform_ops"."postmortems" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "ix_postmortems_status_concept_id" ON "platform_ops"."postmortems" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postmortems_owner_user_id" ON "platform_ops"."postmortems" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_postmortems_reviewed_by_user_id" ON "platform_ops"."postmortems" ("reviewed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_postmortems_created_by_user_id" ON "platform_ops"."postmortems" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_postmortems_updated_by_user_id" ON "platform_ops"."postmortems" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_postmortems_incident" ON "platform_ops"."postmortems" ("health_incident_id");

CREATE INDEX IF NOT EXISTS "ix_postmortem_action_items_postmortem_id" ON "platform_ops"."postmortem_action_items" ("postmortem_id");

CREATE INDEX IF NOT EXISTS "ix_postmortem_action_items_action_type_concept_id" ON "platform_ops"."postmortem_action_items" ("action_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postmortem_action_items_status_concept_id" ON "platform_ops"."postmortem_action_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_postmortem_action_items_owner_user_id" ON "platform_ops"."postmortem_action_items" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_postmortem_action_items_created_by_user_id" ON "platform_ops"."postmortem_action_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_postmortem_action_items_updated_by_user_id" ON "platform_ops"."postmortem_action_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_postmortem_action_items_postmortem_code" ON "platform_ops"."postmortem_action_items" ("postmortem_id", "action_code");

CREATE INDEX IF NOT EXISTS "ix_recovery_objectives_service_component_id" ON "platform_ops"."recovery_objectives" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_recovery_objectives_objective_type_concept_id" ON "platform_ops"."recovery_objectives" ("objective_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_recovery_objectives_recovery_tier_concept_id" ON "platform_ops"."recovery_objectives" ("recovery_tier_concept_id");

CREATE INDEX IF NOT EXISTS "ix_recovery_objectives_state_concept_id" ON "platform_ops"."recovery_objectives" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_recovery_objectives_created_by_user_id" ON "platform_ops"."recovery_objectives" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_recovery_objectives_updated_by_user_id" ON "platform_ops"."recovery_objectives" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_resilience_exercises_tenant_id" ON "platform_ops"."resilience_exercises" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_resilience_exercises_service_component_id" ON "platform_ops"."resilience_exercises" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_resilience_exercises_exercise_type_concept_id" ON "platform_ops"."resilience_exercises" ("exercise_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_resilience_exercises_result_concept_id" ON "platform_ops"."resilience_exercises" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_resilience_exercises_created_by_user_id" ON "platform_ops"."resilience_exercises" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_resilience_exercises_updated_by_user_id" ON "platform_ops"."resilience_exercises" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_resilience_exercises_tenant_created" ON "platform_ops"."resilience_exercises" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_capacity_plans_service_component_id" ON "platform_ops"."capacity_plans" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_capacity_plans_status_concept_id" ON "platform_ops"."capacity_plans" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_capacity_plans_created_by_user_id" ON "platform_ops"."capacity_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_capacity_plans_updated_by_user_id" ON "platform_ops"."capacity_plans" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_capacity_plans_service_code_horizon" ON "platform_ops"."capacity_plans" ("service_component_id", "code", "planning_horizon_start");

CREATE INDEX IF NOT EXISTS "ix_capacity_measurements_capacity_plan_id" ON "platform_ops"."capacity_measurements" ("capacity_plan_id");

CREATE INDEX IF NOT EXISTS "ix_capacity_measurements_metric_concept_id" ON "platform_ops"."capacity_measurements" ("metric_concept_id");

CREATE INDEX IF NOT EXISTS "brin_capacity_measurements_created_at" ON "platform_ops"."capacity_measurements" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_tenant_id" ON "platform_ops"."operational_improvement_items" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_service_component_id" ON "platform_ops"."operational_improvement_items" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_postmortem_action_item_id" ON "platform_ops"."operational_improvement_items" ("postmortem_action_item_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_readiness_review_finding_id" ON "platform_ops"."operational_improvement_items" ("readiness_review_finding_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_source_type_concept_id" ON "platform_ops"."operational_improvement_items" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_priority_concept_id" ON "platform_ops"."operational_improvement_items" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_status_concept_id" ON "platform_ops"."operational_improvement_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_owner_user_id" ON "platform_ops"."operational_improvement_items" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_created_by_user_id" ON "platform_ops"."operational_improvement_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_updated_by_user_id" ON "platform_ops"."operational_improvement_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_improvement_items_tenant_status" ON "platform_ops"."operational_improvement_items" ("tenant_id", "status_concept_id", "updated_at" DESC);
