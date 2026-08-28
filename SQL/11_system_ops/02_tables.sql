-- SALUD v4.0.10 · módulo 11 · schema system_ops
-- Generado de diagram_11_system_ops.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "system_ops"."data_classifications" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "rank" integer,
    "is_pii" boolean,
    "is_phi" boolean,
    "handling_rules_json" jsonb NOT NULL,
    "state_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_data_classifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."data_domains" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "owner_team" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_data_domains" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."entity_registry" (
    "id" uuid NOT NULL,
    "schema_name" varchar NOT NULL,
    "table_name" varchar NOT NULL,
    "domain_id" uuid,
    "classification_id" uuid,
    "is_append_only" boolean NOT NULL,
    "is_soft_delete" boolean NOT NULL,
    "has_history" boolean NOT NULL,
    "history_table" varchar,
    "retention_policy_id" uuid,
    "partition_spec_id" uuid,
    "write_policy_id" uuid,
    "owner_team" varchar,
    "contains_pii" boolean,
    "contains_phi" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_entity_registry" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."field_registry" (
    "id" uuid NOT NULL,
    "entity_registry_id" uuid NOT NULL,
    "column_name" varchar NOT NULL,
    "classification_id" uuid,
    "is_pii" boolean,
    "is_phi" boolean,
    "masking_strategy_concept_id" uuid,
    "anonymization_rule_id" uuid,
    "notes" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_registry" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."write_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "insert_mode_concept_id" uuid NOT NULL,
    "update_mode_concept_id" uuid NOT NULL,
    "delete_mode_concept_id" uuid NOT NULL,
    "requires_reason" boolean,
    "requires_approval" boolean,
    "max_batch_size" integer,
    "dual_control" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_write_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."retention_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "retention_period_days" integer,
    "legal_basis_concept_id" uuid,
    "disposition_concept_id" uuid,
    "jurisdiction_concept_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_retention_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."anonymization_rules" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "technique_concept_id" uuid NOT NULL,
    "parameters_json" jsonb,
    "description" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_anonymization_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."retention_executions" (
    "id" uuid NOT NULL,
    "retention_policy_id" uuid NOT NULL,
    "entity_registry_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "total_scanned" bigint,
    "total_deleted" bigint,
    "total_anonymized" bigint,
    "total_archived" bigint,
    "error_text" text,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_retention_executions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."governance_change_log" (
    "id" uuid NOT NULL,
    "target_type" varchar NOT NULL,
    "target_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "changed_by_user_id" uuid NOT NULL,
    "previous_snapshot_json" jsonb,
    "new_snapshot_json" jsonb,
    "reason" text,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_governance_change_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."record_revisions" (
    "id" uuid NOT NULL,
    "schema_name" varchar NOT NULL,
    "table_name" varchar NOT NULL,
    "record_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    "operation_concept_id" uuid NOT NULL,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_record_revisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."draft_records" (
    "id" uuid NOT NULL,
    "schema_name" varchar NOT NULL,
    "table_name" varchar NOT NULL,
    "target_record_id" uuid,
    "owner_user_id" uuid NOT NULL,
    "tenant_id" uuid,
    "draft_label" varchar,
    "payload_json" jsonb NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "schema_version" integer,
    "published_record_id" uuid,
    "expires_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_draft_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."data_residency_policies" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "jurisdiction_concept_id" uuid NOT NULL,
    "data_classification_id" uuid NOT NULL,
    "allowed_storage_region_value_set_id" uuid NOT NULL,
    "allowed_processing_region_value_set_id" uuid,
    "cross_border_transfer_basis_concept_id" uuid,
    "transfer_impact_assessment_required" boolean,
    "encryption_key_region_locked" boolean,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_data_residency_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."tenant_residency_bindings" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "residency_policy_id" uuid NOT NULL,
    "primary_region_concept_id" uuid NOT NULL,
    "disaster_recovery_region_concept_id" uuid,
    "effective_from" timestamptz,
    "effective_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_tenant_residency_bindings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."legal_holds" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "authority_reference" varchar,
    "starts_at" timestamptz,
    "ends_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_legal_holds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."backup_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "resource_scope_concept_id" uuid NOT NULL,
    "backup_type_concept_id" uuid NOT NULL,
    "rpo_seconds" integer,
    "rto_seconds" integer,
    "retention_days" integer,
    "immutable_copy_required" boolean,
    "encryption_required" boolean,
    "restore_test_frequency_days" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_backup_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."restore_test_runs" (
    "id" uuid NOT NULL,
    "backup_policy_id" uuid NOT NULL,
    "backup_reference" varchar,
    "outcome_concept_id" uuid NOT NULL,
    "measured_rpo_seconds" integer,
    "measured_rto_seconds" integer,
    "integrity_check_passed" boolean,
    "evidence_file_id" uuid,
    "started_at" timestamptz NOT NULL,
    "finished_at" timestamptz,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_restore_test_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."cross_border_transfer_events" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "data_category_concept_id" uuid NOT NULL,
    "source_region_concept_id" uuid NOT NULL,
    "destination_region_concept_id" uuid NOT NULL,
    "transfer_basis_concept_id" uuid NOT NULL,
    "recipient_tenant_id" uuid,
    "transfer_reference" varchar,
    "approved_by_user_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_cross_border_transfer_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."operational_frameworks" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "provider_concept_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "source_url" varchar,
    "published_at" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operational_frameworks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."operational_framework_controls" (
    "id" uuid NOT NULL,
    "operational_framework_id" uuid NOT NULL,
    "parent_control_id" uuid,
    "control_code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "pillar_concept_id" uuid,
    "objective_text" text,
    "evidence_requirements_json" jsonb,
    "assessment_guidance_json" jsonb,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_operational_framework_controls" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."workload_assessments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "operational_framework_id" uuid NOT NULL,
    "workload_code" varchar NOT NULL,
    "workload_name" varchar NOT NULL,
    "service_component_id" uuid,
    "assessment_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "assessment_period_start" date,
    "assessment_period_end" date,
    "facilitator_user_id" uuid,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "summary_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_workload_assessments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."assessment_control_results" (
    "id" uuid NOT NULL,
    "workload_assessment_id" uuid NOT NULL,
    "operational_framework_control_id" uuid NOT NULL,
    "result_concept_id" uuid NOT NULL,
    "maturity_level_concept_id" uuid,
    "evidence_summary" text,
    "evidence_links_json" jsonb,
    "assessor_user_id" uuid,
    "assessed_at" timestamptz NOT NULL,
    "risk_score" numeric(8,4),
    "accepted_risk_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_assessment_control_results" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."assessment_findings" (
    "id" uuid NOT NULL,
    "workload_assessment_id" uuid NOT NULL,
    "assessment_control_result_id" uuid,
    "finding_code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "severity_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "owner_team" varchar,
    "due_at" timestamptz,
    "risk_acceptance_expires_at" timestamptz,
    "closed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_assessment_findings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."remediation_plans" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "workload_assessment_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "owner_user_id" uuid,
    "target_completion_at" timestamptz,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "notes" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_remediation_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."remediation_actions" (
    "id" uuid NOT NULL,
    "remediation_plan_id" uuid NOT NULL,
    "assessment_finding_id" uuid NOT NULL,
    "action_code" varchar NOT NULL,
    "description" text NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "assigned_user_id" uuid,
    "assigned_team" varchar,
    "due_at" timestamptz,
    "completed_at" timestamptz,
    "verification_user_id" uuid,
    "verification_at" timestamptz,
    "verification_evidence_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_remediation_actions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."partition_specs" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "schema_name" varchar NOT NULL,
    "table_name" varchar NOT NULL,
    "entity_registry_id" uuid,
    "partition_strategy_concept_id" uuid NOT NULL,
    "partition_key" varchar,
    "partition_interval_concept_id" uuid,
    "subpartition_key" varchar,
    "hot_tier_days" integer,
    "warm_tier_days" integer,
    "cold_tier_days" integer,
    "archive_target_concept_id" uuid,
    "retention_policy_id" uuid,
    "is_time_series" boolean,
    "enforces_tenant_isolation" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_partition_specs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."encryption_keys" (
    "id" uuid NOT NULL,
    "key_alias" varchar NOT NULL,
    "key_purpose_concept_id" uuid NOT NULL,
    "algorithm_concept_id" uuid NOT NULL,
    "provider_concept_id" uuid,
    "external_key_ref" varchar,
    "key_version" integer,
    "is_primary" boolean,
    "rotation_period_days" integer,
    "last_rotated_at" timestamptz,
    "next_rotation_at" timestamptz,
    "retention_policy_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_encryption_keys" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."key_rotation_events" (
    "id" uuid NOT NULL,
    "encryption_key_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "from_version" integer,
    "to_version" integer,
    "reason" varchar,
    "performed_by_user_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_key_rotation_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."security_incidents" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "tenant_id" uuid,
    "severity_concept_id" uuid NOT NULL,
    "category_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "vector_concept_id" uuid,
    "detected_at" timestamptz,
    "contained_at" timestamptz,
    "resolved_at" timestamptz,
    "affected_records_estimate" bigint,
    "is_reportable" boolean,
    "assigned_to_user_id" uuid,
    "data_classification_id" uuid,
    "summary" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_security_incidents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."breach_notifications" (
    "id" uuid NOT NULL,
    "security_incident_id" uuid NOT NULL,
    "authority_concept_id" uuid NOT NULL,
    "jurisdiction_concept_id" uuid,
    "regulation_concept_id" uuid,
    "deadline_at" timestamptz,
    "notified_at" timestamptz,
    "affected_subjects" integer,
    "notification_channel_concept_id" uuid,
    "reference_number" varchar,
    "subjects_notified" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_breach_notifications" PRIMARY KEY ("id")
);
