-- SALUD v4.0.10 · módulo 46 · schema platform_ops
-- Generado de diagram_46_platform_ops.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "platform_ops"."component_tools"
        ADD CONSTRAINT "fk_component_tools_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."component_tools"
        ADD CONSTRAINT "fk_component_tools_tool_id" FOREIGN KEY ("tool_id")
        REFERENCES "platform_ops"."tool_registry" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."artifacts"
        ADD CONSTRAINT "fk_artifacts_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."artifacts"
        ADD CONSTRAINT "fk_artifacts_produced_by_tool_id" FOREIGN KEY ("produced_by_tool_id")
        REFERENCES "platform_ops"."tool_registry" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."deployments"
        ADD CONSTRAINT "fk_deployments_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."deployments"
        ADD CONSTRAINT "fk_deployments_artifact_id" FOREIGN KEY ("artifact_id")
        REFERENCES "platform_ops"."artifacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."deployments"
        ADD CONSTRAINT "fk_deployments_rollback_of_deployment_id" FOREIGN KEY ("rollback_of_deployment_id")
        REFERENCES "platform_ops"."deployments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."health_checks"
        ADD CONSTRAINT "fk_health_checks_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."health_check_runs"
        ADD CONSTRAINT "fk_health_check_runs_health_check_id" FOREIGN KEY ("health_check_id")
        REFERENCES "platform_ops"."health_checks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."health_check_runs"
        ADD CONSTRAINT "fk_health_check_runs_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."health_check_runs"
        ADD CONSTRAINT "fk_health_check_runs_deployment_id" FOREIGN KEY ("deployment_id")
        REFERENCES "platform_ops"."deployments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."health_incidents"
        ADD CONSTRAINT "fk_health_incidents_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."health_incidents"
        ADD CONSTRAINT "fk_health_incidents_health_check_id" FOREIGN KEY ("health_check_id")
        REFERENCES "platform_ops"."health_checks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."health_incidents"
        ADD CONSTRAINT "fk_health_incidents_detected_by_run_id" FOREIGN KEY ("detected_by_run_id")
        REFERENCES "platform_ops"."health_check_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."service_ownerships"
        ADD CONSTRAINT "fk_service_ownerships_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."service_ownerships"
        ADD CONSTRAINT "fk_service_ownerships_operational_team_id" FOREIGN KEY ("operational_team_id")
        REFERENCES "platform_ops"."operational_teams" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."service_ownerships"
        ADD CONSTRAINT "fk_service_ownerships_escalation_policy_id" FOREIGN KEY ("escalation_policy_id")
        REFERENCES "platform_ops"."escalation_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."service_dependencies"
        ADD CONSTRAINT "fk_service_dependencies_upstream_service_component_id" FOREIGN KEY ("upstream_service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."service_dependencies"
        ADD CONSTRAINT "fk_service_dependencies_downstream_service_component_id" FOREIGN KEY ("downstream_service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."on_call_schedules"
        ADD CONSTRAINT "fk_on_call_schedules_operational_team_id" FOREIGN KEY ("operational_team_id")
        REFERENCES "platform_ops"."operational_teams" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."on_call_shifts"
        ADD CONSTRAINT "fk_on_call_shifts_on_call_schedule_id" FOREIGN KEY ("on_call_schedule_id")
        REFERENCES "platform_ops"."on_call_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."escalation_policy_steps"
        ADD CONSTRAINT "fk_escalation_policy_steps_escalation_policy_id" FOREIGN KEY ("escalation_policy_id")
        REFERENCES "platform_ops"."escalation_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."escalation_policy_steps"
        ADD CONSTRAINT "fk_escalation_policy_steps_operational_team_id" FOREIGN KEY ("operational_team_id")
        REFERENCES "platform_ops"."operational_teams" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."escalation_policy_steps"
        ADD CONSTRAINT "fk_escalation_policy_steps_on_call_schedule_id" FOREIGN KEY ("on_call_schedule_id")
        REFERENCES "platform_ops"."on_call_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."operational_readiness_reviews"
        ADD CONSTRAINT "fk_operational_readiness_reviews_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."operational_readiness_reviews"
        ADD CONSTRAINT "fk_operational_readiness_reviews_deployment_id" FOREIGN KEY ("deployment_id")
        REFERENCES "platform_ops"."deployments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."readiness_review_findings"
        ADD CONSTRAINT "fk_readiness_review_findings_operational_readiness_review_id" FOREIGN KEY ("operational_readiness_review_id")
        REFERENCES "platform_ops"."operational_readiness_reviews" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."service_level_indicators"
        ADD CONSTRAINT "fk_service_level_indicators_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."service_level_objectives"
        ADD CONSTRAINT "fk_service_level_objectives_service_level_indicator_id" FOREIGN KEY ("service_level_indicator_id")
        REFERENCES "platform_ops"."service_level_indicators" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."slo_measurements"
        ADD CONSTRAINT "fk_slo_measurements_service_level_objective_id" FOREIGN KEY ("service_level_objective_id")
        REFERENCES "platform_ops"."service_level_objectives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."error_budget_policies"
        ADD CONSTRAINT "fk_error_budget_policies_service_level_objective_id" FOREIGN KEY ("service_level_objective_id")
        REFERENCES "platform_ops"."service_level_objectives" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."error_budget_burn_events"
        ADD CONSTRAINT "fk_error_budget_burn_events_error_budget_policy_id" FOREIGN KEY ("error_budget_policy_id")
        REFERENCES "platform_ops"."error_budget_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."error_budget_burn_events"
        ADD CONSTRAINT "fk_error_budget_burn_events_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."runbooks"
        ADD CONSTRAINT "fk_runbooks_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."runbooks"
        ADD CONSTRAINT "fk_runbooks_current_version_id" FOREIGN KEY ("current_version_id")
        REFERENCES "platform_ops"."runbook_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."runbooks"
        ADD CONSTRAINT "fk_runbooks_owner_team_id" FOREIGN KEY ("owner_team_id")
        REFERENCES "platform_ops"."operational_teams" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."runbook_versions"
        ADD CONSTRAINT "fk_runbook_versions_runbook_id" FOREIGN KEY ("runbook_id")
        REFERENCES "platform_ops"."runbooks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."runbook_executions"
        ADD CONSTRAINT "fk_runbook_executions_runbook_version_id" FOREIGN KEY ("runbook_version_id")
        REFERENCES "platform_ops"."runbook_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."runbook_executions"
        ADD CONSTRAINT "fk_runbook_executions_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."runbook_executions"
        ADD CONSTRAINT "fk_runbook_executions_change_request_id" FOREIGN KEY ("change_request_id")
        REFERENCES "platform_ops"."change_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."change_requests"
        ADD CONSTRAINT "fk_change_requests_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."change_requests"
        ADD CONSTRAINT "fk_change_requests_deployment_id" FOREIGN KEY ("deployment_id")
        REFERENCES "platform_ops"."deployments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."change_requests"
        ADD CONSTRAINT "fk_change_requests_maintenance_window_id" FOREIGN KEY ("maintenance_window_id")
        REFERENCES "platform_ops"."maintenance_windows" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."change_approvals"
        ADD CONSTRAINT "fk_change_approvals_change_request_id" FOREIGN KEY ("change_request_id")
        REFERENCES "platform_ops"."change_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."incident_responders"
        ADD CONSTRAINT "fk_incident_responders_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."incident_timeline_events"
        ADD CONSTRAINT "fk_incident_timeline_events_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."incident_communications"
        ADD CONSTRAINT "fk_incident_communications_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."postmortems"
        ADD CONSTRAINT "fk_postmortems_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."postmortem_action_items"
        ADD CONSTRAINT "fk_postmortem_action_items_postmortem_id" FOREIGN KEY ("postmortem_id")
        REFERENCES "platform_ops"."postmortems" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."recovery_objectives"
        ADD CONSTRAINT "fk_recovery_objectives_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."resilience_exercises"
        ADD CONSTRAINT "fk_resilience_exercises_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."capacity_plans"
        ADD CONSTRAINT "fk_capacity_plans_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."capacity_measurements"
        ADD CONSTRAINT "fk_capacity_measurements_capacity_plan_id" FOREIGN KEY ("capacity_plan_id")
        REFERENCES "platform_ops"."capacity_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."operational_improvement_items"
        ADD CONSTRAINT "fk_operational_improvement_items_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."operational_improvement_items"
        ADD CONSTRAINT "fk_operational_improvement_items_postmortem_action_item_id" FOREIGN KEY ("postmortem_action_item_id")
        REFERENCES "platform_ops"."postmortem_action_items" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "platform_ops"."operational_improvement_items"
        ADD CONSTRAINT "fk_operational_improvement_items_readiness_review_finding_id" FOREIGN KEY ("readiness_review_finding_id")
        REFERENCES "platform_ops"."readiness_review_findings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
