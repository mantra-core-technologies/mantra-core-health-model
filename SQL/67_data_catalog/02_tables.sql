-- SALUD v4.2.81 · módulo 67 · schema data_catalog
-- Generado de diagram_67_data_catalog.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_scan_runs" (
    "id" uuid NOT NULL,
    "source_code" varchar NOT NULL,
    "mode" varchar NOT NULL,
    "status" varchar NOT NULL,
    "idempotency_key" varchar,
    "requested_by_user_id" uuid,
    "requested_at" timestamptz NOT NULL,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "cancel_requested_at" timestamptz,
    "lease_owner" varchar,
    "lease_expires_at" timestamptz,
    "attempt" integer NOT NULL,
    "engine_version" varchar,
    "connector_version" varchar NOT NULL,
    "excluded_schemas" jsonb,
    "limitations" jsonb,
    "objects_observed" integer,
    "columns_observed" integer,
    "objects_added" integer,
    "objects_changed" integer,
    "objects_not_observed" integer,
    "objects_reappeared" integer,
    "columns_added" integer,
    "columns_changed" integer,
    "columns_not_observed" integer,
    "snapshot_hash" varchar,
    "error_code" varchar,
    "error_message" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_scan_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_objects" (
    "id" uuid NOT NULL,
    "source_code" varchar NOT NULL,
    "schema_name" varchar NOT NULL,
    "object_name" varchar NOT NULL,
    "object_kind" varchar NOT NULL,
    "observation_status" varchar NOT NULL,
    "table_comment" text,
    "estimated_rows" bigint,
    "total_bytes" bigint,
    "stats_observed_at" timestamptz,
    "column_count" integer NOT NULL,
    "primary_key_columns" jsonb,
    "technical_hash" varchar NOT NULL,
    "first_seen_scan_id" uuid NOT NULL,
    "last_seen_scan_id" uuid NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "not_observed_since" timestamptz,
    "domain_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_objects" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_columns" (
    "id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_name" varchar NOT NULL,
    "ordinal" integer NOT NULL,
    "native_type" varchar NOT NULL,
    "is_nullable" boolean NOT NULL,
    "default_expression" text,
    "is_identity" boolean NOT NULL,
    "is_generated" boolean NOT NULL,
    "is_primary_key" boolean NOT NULL,
    "is_unique" boolean NOT NULL,
    "foreign_key" jsonb,
    "column_comment" text,
    "observation_status" varchar NOT NULL,
    "technical_hash" varchar NOT NULL,
    "first_seen_scan_id" uuid NOT NULL,
    "last_seen_scan_id" uuid NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "not_observed_since" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_columns" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_change_events" (
    "id" uuid NOT NULL,
    "scan_run_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "change_kind" varchar NOT NULL,
    "before_json" jsonb,
    "after_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_change_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_annotations" (
    "id" uuid NOT NULL,
    "target_kind" varchar NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "business_name" varchar,
    "definition" text,
    "purpose" text,
    "existence_rationale" text,
    "row_grain" text,
    "alternatives_rationale" text,
    "process_supported" text,
    "source_of_truth" text,
    "producers" jsonb,
    "consumers" jsonb,
    "deletion_impact" text,
    "business_owner" varchar,
    "data_steward" varchar,
    "technical_owner" varchar,
    "unit" varchar,
    "value_domain" text,
    "null_semantics" text,
    "sensitivity" varchar NOT NULL,
    "open_questions" jsonb,
    "review_status" varchar NOT NULL,
    "origin" varchar NOT NULL,
    "current_revision_no" integer NOT NULL,
    "approved_revision_no" integer,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_annotations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_annotation_revisions" (
    "id" uuid NOT NULL,
    "annotation_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "content_json" jsonb NOT NULL,
    "content_hash" varchar NOT NULL,
    "origin" varchar NOT NULL,
    "submitted_status" varchar NOT NULL,
    "change_reason" text,
    "author_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_annotation_revisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_review_decisions" (
    "id" uuid NOT NULL,
    "annotation_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "decision" varchar NOT NULL,
    "comment" text,
    "reviewer_user_id" uuid NOT NULL,
    "decided_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_review_decisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_evidence_items" (
    "id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "kind" varchar NOT NULL,
    "reference" text NOT NULL,
    "excerpt" text,
    "source_revision" varchar,
    "added_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_evidence_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_operations" (
    "id" uuid NOT NULL,
    "source_code" varchar NOT NULL,
    "operation_key" varchar NOT NULL,
    "http_method" varchar NOT NULL,
    "route_template" varchar NOT NULL,
    "module_code" varchar,
    "controller_name" varchar,
    "handler_name" varchar,
    "source_ref" varchar,
    "is_public" boolean NOT NULL,
    "required_roles" jsonb,
    "risk_level" varchar NOT NULL,
    "observation_status" varchar NOT NULL,
    "technical_hash" varchar,
    "first_seen_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_operations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_operation_impacts" (
    "id" uuid NOT NULL,
    "operation_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "access_kind" varchar NOT NULL,
    "access_detail" varchar,
    "confidence" varchar,
    "call_path" jsonb,
    "source_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_operation_impacts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_processes" (
    "id" uuid NOT NULL,
    "process_code" varchar NOT NULL,
    "kind" varchar NOT NULL,
    "name" varchar NOT NULL,
    "module_code" varchar,
    "purpose" text,
    "source_ref" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_processes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_process_steps" (
    "id" uuid NOT NULL,
    "process_id" uuid NOT NULL,
    "ordinal" integer NOT NULL,
    "step_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_process_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_process_step_operations" (
    "id" uuid NOT NULL,
    "step_id" uuid NOT NULL,
    "operation_id" uuid NOT NULL,
    "ordinal" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_process_step_operations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_stewardships" (
    "id" uuid NOT NULL,
    "scope_kind" varchar NOT NULL,
    "domain_id" uuid,
    "object_id" uuid,
    "role_kind" varchar NOT NULL,
    "user_id" uuid,
    "team_code" varchar,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_stewardships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_glossary_terms" (
    "id" uuid NOT NULL,
    "term_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "definition" text NOT NULL,
    "domain_id" uuid,
    "synonyms" jsonb,
    "status" varchar NOT NULL,
    "current_revision_no" integer NOT NULL,
    "approved_revision_no" integer,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_glossary_terms" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_glossary_term_revisions" (
    "id" uuid NOT NULL,
    "term_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "content_json" jsonb NOT NULL,
    "content_hash" varchar NOT NULL,
    "change_reason" text,
    "author_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_glossary_term_revisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_glossary_term_links" (
    "id" uuid NOT NULL,
    "term_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "link_kind" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_catalog_glossary_term_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_rules" (
    "id" uuid NOT NULL,
    "rule_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "rule_kind" varchar NOT NULL,
    "params_json" jsonb NOT NULL,
    "severity" varchar NOT NULL,
    "threshold_pct" numeric(5,2) NOT NULL,
    "schedule_minutes" integer,
    "sample_limit" integer NOT NULL DEFAULT 20,
    "enabled" boolean NOT NULL DEFAULT true,
    "owner_user_id" uuid,
    "version" integer NOT NULL DEFAULT 1,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quality_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_rule_runs" (
    "id" uuid NOT NULL,
    "rule_id" uuid NOT NULL,
    "trigger" varchar NOT NULL,
    "status" varchar NOT NULL,
    "idempotency_key" varchar,
    "requested_by_user_id" uuid,
    "lease_owner" varchar,
    "lease_expires_at" timestamptz,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "evaluated_rows" bigint,
    "failed_rows" bigint,
    "failed_pct" numeric(7,4),
    "passed" boolean,
    "sample_ids_json" jsonb,
    "error_code" varchar,
    "error_message" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_quality_rule_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_issues" (
    "id" uuid NOT NULL,
    "rule_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "fingerprint" varchar NOT NULL,
    "severity" varchar NOT NULL,
    "status" varchar NOT NULL,
    "first_seen_run_id" uuid NOT NULL,
    "last_seen_run_id" uuid NOT NULL,
    "occurrences" integer NOT NULL DEFAULT 1,
    "failed_rows_last" bigint,
    "failed_pct_last" numeric(7,4),
    "acknowledged_by_user_id" uuid,
    "acknowledged_at" timestamptz,
    "resolved_by_user_id" uuid,
    "resolved_at" timestamptz,
    "resolution_kind" varchar,
    "ignored_until" timestamptz,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quality_issues" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_issue_events" (
    "id" uuid NOT NULL,
    "issue_id" uuid NOT NULL,
    "event_kind" varchar NOT NULL,
    "run_id" uuid,
    "actor_user_id" uuid,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_quality_issue_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_score_snapshots" (
    "id" uuid NOT NULL,
    "scope_kind" varchar NOT NULL,
    "object_id" uuid,
    "domain_id" uuid,
    "as_of" timestamptz NOT NULL,
    "score" numeric(5,2) NOT NULL,
    "components_json" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_quality_score_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_lineage_edges" (
    "id" uuid NOT NULL,
    "source_kind" varchar NOT NULL,
    "source_ref" varchar NOT NULL,
    "target_kind" varchar NOT NULL,
    "target_ref" varchar NOT NULL,
    "edge_kind" varchar NOT NULL,
    "origin" varchar NOT NULL,
    "confidence" varchar,
    "is_official" boolean NOT NULL DEFAULT false,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "observation_status" varchar NOT NULL,
    "first_seen_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_lineage_edges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_certifications" (
    "id" uuid NOT NULL,
    "target_kind" varchar NOT NULL,
    "object_id" uuid,
    "read_model_definition_id" uuid,
    "report_definition_id" uuid,
    "kpi_code" varchar,
    "status" varchar NOT NULL,
    "basis_json" jsonb NOT NULL,
    "requested_by_user_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "certified_by_user_id" uuid,
    "certified_at" timestamptz,
    "expires_at" timestamptz,
    "revoked_by_user_id" uuid,
    "revoked_at" timestamptz,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_certifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_change_acknowledgements" (
    "id" uuid NOT NULL,
    "change_event_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_change_acknowledgements" PRIMARY KEY ("id")
);
