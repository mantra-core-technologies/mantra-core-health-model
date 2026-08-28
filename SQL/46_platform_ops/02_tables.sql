-- SALUD v4.0.10 · módulo 46 · schema platform_ops
-- Generado de diagram_46_platform_ops.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "platform_ops"."service_components" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "component_type_concept_id" uuid NOT NULL,
    "criticality_concept_id" uuid,
    "repository_url" varchar,
    "owner_team" varchar,
    "description" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_components" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."tool_registry" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "tool_type_concept_id" uuid NOT NULL,
    "vendor" varchar,
    "current_version" varchar,
    "purpose" text,
    "homepage_url" varchar,
    "is_approved" boolean,
    "approved_by_user_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tool_registry" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."component_tools" (
    "id" uuid NOT NULL,
    "service_component_id" uuid NOT NULL,
    "tool_id" uuid NOT NULL,
    "usage_concept_id" uuid NOT NULL,
    "pinned_version" varchar,
    "is_primary" boolean,
    "notes" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_component_tools" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."artifacts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid,
    "produced_by_tool_id" uuid,
    "artifact_ref" varchar NOT NULL,
    "artifact_type_concept_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "version" varchar,
    "semver" varchar,
    "git_ref" varchar,
    "commit_sha" varchar,
    "content_hash" varchar,
    "storage_uri" text,
    "file_id" uuid,
    "size_bytes" integer,
    "is_immutable" boolean,
    "built_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_artifacts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."deployments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid NOT NULL,
    "artifact_id" uuid NOT NULL,
    "environment_concept_id" uuid NOT NULL,
    "deployment_number" varchar NOT NULL,
    "strategy_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "deployed_by_user_id" uuid,
    "git_ref" varchar,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "is_current" boolean,
    "rollback_of_deployment_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_deployments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."health_checks" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "check_type_concept_id" uuid NOT NULL,
    "target_kind_concept_id" uuid NOT NULL,
    "target_ref" text,
    "expected_result" text,
    "interval_seconds" integer,
    "timeout_ms" integer,
    "healthy_threshold" integer,
    "unhealthy_threshold" integer,
    "severity_concept_id" uuid,
    "is_enabled" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_checks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."health_check_runs" (
    "id" uuid NOT NULL,
    "health_check_id" uuid NOT NULL,
    "service_component_id" uuid,
    "deployment_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "latency_ms" integer,
    "http_status" integer,
    "observed_value" varchar,
    "message" text,
    "run_source_concept_id" uuid,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_health_check_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."health_incidents" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid NOT NULL,
    "health_check_id" uuid,
    "incident_number" varchar NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "detected_by_run_id" uuid,
    "opened_at" timestamptz,
    "acknowledged_at" timestamptz,
    "resolved_at" timestamptz,
    "root_cause_text" text,
    "resolution_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_health_incidents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."operational_teams" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "team_type_concept_id" uuid NOT NULL,
    "manager_user_id" uuid,
    "contact_channel_uri" varchar,
    "time_zone" varchar,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operational_teams" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."service_ownerships" (
    "id" uuid NOT NULL,
    "service_component_id" uuid NOT NULL,
    "operational_team_id" uuid NOT NULL,
    "ownership_role_concept_id" uuid NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "escalation_policy_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_ownerships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."service_dependencies" (
    "id" uuid NOT NULL,
    "upstream_service_component_id" uuid NOT NULL,
    "downstream_service_component_id" uuid NOT NULL,
    "dependency_type_concept_id" uuid NOT NULL,
    "criticality_concept_id" uuid,
    "timeout_ms" integer,
    "failure_mode_text" text,
    "fallback_strategy_text" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_dependencies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."on_call_schedules" (
    "id" uuid NOT NULL,
    "operational_team_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "time_zone" varchar NOT NULL,
    "rotation_rule_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_on_call_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."on_call_shifts" (
    "id" uuid NOT NULL,
    "on_call_schedule_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "starts_at" timestamptz NOT NULL,
    "ends_at" timestamptz NOT NULL,
    "override_reason" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_on_call_shifts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."escalation_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_escalation_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."escalation_policy_steps" (
    "id" uuid NOT NULL,
    "escalation_policy_id" uuid NOT NULL,
    "step_number" integer NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "operational_team_id" uuid,
    "on_call_schedule_id" uuid,
    "target_user_id" uuid,
    "delay_seconds" integer NOT NULL,
    "notification_channels_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_escalation_policy_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."operational_readiness_reviews" (
    "id" uuid NOT NULL,
    "service_component_id" uuid NOT NULL,
    "deployment_id" uuid,
    "review_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "facilitator_user_id" uuid,
    "planned_at" timestamptz,
    "completed_at" timestamptz,
    "decision_concept_id" uuid,
    "evidence_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operational_readiness_reviews" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."readiness_review_findings" (
    "id" uuid NOT NULL,
    "operational_readiness_review_id" uuid NOT NULL,
    "finding_code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "severity_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "owner_user_id" uuid,
    "due_at" timestamptz,
    "resolved_at" timestamptz,
    "evidence_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_readiness_review_findings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."service_level_indicators" (
    "id" uuid NOT NULL,
    "service_component_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "indicator_type_concept_id" uuid NOT NULL,
    "query_definition_json" jsonb NOT NULL,
    "unit_concept_id" uuid NOT NULL,
    "good_event_definition" text,
    "total_event_definition" text,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_level_indicators" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."service_level_objectives" (
    "id" uuid NOT NULL,
    "service_level_indicator_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "target_value" numeric(12,8) NOT NULL,
    "rolling_window_seconds" bigint NOT NULL,
    "warning_threshold" numeric(12,8),
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_level_objectives" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."slo_measurements" (
    "id" uuid NOT NULL,
    "service_level_objective_id" uuid NOT NULL,
    "measured_at" timestamptz NOT NULL,
    "window_start" timestamptz NOT NULL,
    "window_end" timestamptz NOT NULL,
    "good_events" bigint NOT NULL,
    "total_events" bigint NOT NULL,
    "attained_value" numeric(12,8) NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "source_reference" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_slo_measurements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."error_budget_policies" (
    "id" uuid NOT NULL,
    "service_level_objective_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "budget_percent" numeric(8,5) NOT NULL,
    "burn_rate_warning" numeric(12,6),
    "burn_rate_critical" numeric(12,6),
    "deployment_freeze_on_exhaustion" boolean,
    "required_approval_role_concept_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_error_budget_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."error_budget_burn_events" (
    "id" uuid NOT NULL,
    "error_budget_policy_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "window_seconds" bigint NOT NULL,
    "burn_rate" numeric(12,6) NOT NULL,
    "remaining_budget_percent" numeric(8,5) NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "health_incident_id" uuid,
    "action_taken_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_error_budget_burn_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."runbooks" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "runbook_type_concept_id" uuid NOT NULL,
    "current_version_id" uuid,
    "owner_team_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_runbooks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."runbook_versions" (
    "id" uuid NOT NULL,
    "runbook_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "content_markdown" text NOT NULL,
    "automation_definition_json" jsonb,
    "checksum_sha256" varchar,
    "approved_by_user_id" uuid NOT NULL,
    "approved_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_runbook_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."runbook_executions" (
    "id" uuid NOT NULL,
    "runbook_version_id" uuid NOT NULL,
    "health_incident_id" uuid,
    "change_request_id" uuid,
    "execution_mode_concept_id" uuid NOT NULL,
    "started_at" timestamptz NOT NULL,
    "ended_at" timestamptz,
    "result_concept_id" uuid NOT NULL,
    "initiated_by_user_id" uuid,
    "execution_log_uri" varchar,
    "output_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_runbook_executions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."change_requests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid NOT NULL,
    "deployment_id" uuid,
    "change_number" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "change_type_concept_id" uuid NOT NULL,
    "risk_level_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "requested_by_user_id" uuid,
    "planned_start_at" timestamptz,
    "planned_end_at" timestamptz,
    "rollback_plan_text" text,
    "validation_plan_text" text,
    "maintenance_window_id" uuid,
    "implemented_at" timestamptz,
    "closed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_change_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."change_approvals" (
    "id" uuid NOT NULL,
    "change_request_id" uuid NOT NULL,
    "approval_step" integer NOT NULL,
    "approver_user_id" uuid NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "decision_reason" text,
    "decided_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_change_approvals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."maintenance_windows" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "starts_at" timestamptz NOT NULL,
    "ends_at" timestamptz NOT NULL,
    "recurrence_rule" text,
    "affected_services_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_maintenance_windows" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."incident_responders" (
    "id" uuid NOT NULL,
    "health_incident_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "responder_role_concept_id" uuid NOT NULL,
    "joined_at" timestamptz NOT NULL,
    "left_at" timestamptz,
    "acknowledged_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_incident_responders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."incident_timeline_events" (
    "id" uuid NOT NULL,
    "health_incident_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "actor_user_id" uuid,
    "summary" text NOT NULL,
    "details_json" jsonb,
    "source_reference" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_incident_timeline_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."incident_communications" (
    "id" uuid NOT NULL,
    "health_incident_id" uuid NOT NULL,
    "communication_type_concept_id" uuid NOT NULL,
    "audience_concept_id" uuid NOT NULL,
    "published_at" timestamptz NOT NULL,
    "published_by_user_id" uuid,
    "message_text" text NOT NULL,
    "channel_reference" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_incident_communications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."postmortems" (
    "id" uuid NOT NULL,
    "health_incident_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "impact_summary" text,
    "detection_summary" text,
    "response_summary" text,
    "root_cause_summary" text,
    "contributing_factors_json" jsonb,
    "lessons_learned" text,
    "owner_user_id" uuid,
    "reviewed_by_user_id" uuid,
    "reviewed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_postmortems" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."postmortem_action_items" (
    "id" uuid NOT NULL,
    "postmortem_id" uuid NOT NULL,
    "action_code" varchar NOT NULL,
    "description" text NOT NULL,
    "action_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "owner_user_id" uuid,
    "due_at" timestamptz,
    "completed_at" timestamptz,
    "verification_evidence_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_postmortem_action_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."recovery_objectives" (
    "id" uuid NOT NULL,
    "service_component_id" uuid NOT NULL,
    "objective_type_concept_id" uuid NOT NULL,
    "rto_seconds" bigint NOT NULL,
    "rpo_seconds" bigint NOT NULL,
    "maximum_tolerable_downtime_seconds" bigint,
    "recovery_tier_concept_id" uuid,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_recovery_objectives" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."resilience_exercises" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid NOT NULL,
    "exercise_type_concept_id" uuid NOT NULL,
    "scenario_name" varchar NOT NULL,
    "hypothesis_text" text,
    "planned_at" timestamptz,
    "started_at" timestamptz,
    "ended_at" timestamptz,
    "result_concept_id" uuid NOT NULL,
    "observed_rto_seconds" bigint,
    "observed_rpo_seconds" bigint,
    "evidence_uri" varchar,
    "findings_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_resilience_exercises" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."capacity_plans" (
    "id" uuid NOT NULL,
    "service_component_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "planning_horizon_start" date NOT NULL,
    "planning_horizon_end" date NOT NULL,
    "demand_forecast_json" jsonb,
    "scaling_policy_json" jsonb,
    "cost_guardrails_json" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_capacity_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."capacity_measurements" (
    "id" uuid NOT NULL,
    "capacity_plan_id" uuid NOT NULL,
    "measured_at" timestamptz NOT NULL,
    "metric_concept_id" uuid NOT NULL,
    "observed_value" numeric(20,6) NOT NULL,
    "capacity_value" numeric(20,6) NOT NULL,
    "utilization_percent" numeric(8,5) NOT NULL,
    "source_reference" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_capacity_measurements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "platform_ops"."operational_improvement_items" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service_component_id" uuid,
    "postmortem_action_item_id" uuid,
    "readiness_review_finding_id" uuid,
    "source_type_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "priority_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "owner_user_id" uuid,
    "due_at" timestamptz,
    "completed_at" timestamptz,
    "outcome_evidence_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operational_improvement_items" PRIMARY KEY ("id")
);
