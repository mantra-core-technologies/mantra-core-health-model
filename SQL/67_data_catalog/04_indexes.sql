-- SALUD v4.2.82 · módulo 67 · schema data_catalog
-- Generado de diagram_67_data_catalog.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_data_catalog_scan_runs_status_requested_at" ON "data_catalog"."catalog_scan_runs" ("status", "requested_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_scan_runs_one_active" ON "data_catalog"."catalog_scan_runs" ("source_code") WHERE status IN ('QUEUED', 'RUNNING');

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_scan_runs_idempotency" ON "data_catalog"."catalog_scan_runs" ("requested_by_user_id", "idempotency_key") WHERE idempotency_key IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_objects_identity" ON "data_catalog"."catalog_objects" ("source_code", "schema_name", "object_name");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_objects_observation_status" ON "data_catalog"."catalog_objects" ("observation_status");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_objects_domain_id" ON "data_catalog"."catalog_objects" ("domain_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_columns_identity" ON "data_catalog"."catalog_columns" ("object_id", "column_name");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_events_scan_run_id" ON "data_catalog"."catalog_change_events" ("scan_run_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_events_object_created" ON "data_catalog"."catalog_change_events" ("object_id", "created_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotations_object" ON "data_catalog"."catalog_annotations" ("object_id") WHERE target_kind = 'OBJECT';

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotations_column" ON "data_catalog"."catalog_annotations" ("column_id") WHERE column_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_annotations_review_status" ON "data_catalog"."catalog_annotations" ("review_status");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotation_revisions_no" ON "data_catalog"."catalog_annotation_revisions" ("annotation_id", "revision_no");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_review_decisions_annotation" ON "data_catalog"."catalog_review_decisions" ("annotation_id", "revision_no");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_evidence_items_object_id" ON "data_catalog"."catalog_evidence_items" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_evidence_items_column_id" ON "data_catalog"."catalog_evidence_items" ("column_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_operations_key" ON "data_catalog"."catalog_operations" ("operation_key");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_operation_impacts_operation_id" ON "data_catalog"."catalog_operation_impacts" ("operation_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_operation_impacts_object_id" ON "data_catalog"."catalog_operation_impacts" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_operation_impacts_column_id" ON "data_catalog"."catalog_operation_impacts" ("column_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_processes_code" ON "data_catalog"."catalog_processes" ("process_code");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_process_steps_ordinal" ON "data_catalog"."catalog_process_steps" ("process_id", "ordinal");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_process_step_operations_pair" ON "data_catalog"."catalog_process_step_operations" ("step_id", "operation_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_process_step_operations_step_id" ON "data_catalog"."catalog_process_step_operations" ("step_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_process_step_operations_operation_id" ON "data_catalog"."catalog_process_step_operations" ("operation_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_stewardships_active_role" ON "data_catalog"."catalog_stewardships" ("scope_kind", COALESCE(domain_id, object_id), "role_kind") WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_stewardships_user_id" ON "data_catalog"."catalog_stewardships" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_stewardships_object_id" ON "data_catalog"."catalog_stewardships" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_stewardships_domain_id" ON "data_catalog"."catalog_stewardships" ("domain_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_glossary_terms_code" ON "data_catalog"."catalog_glossary_terms" ("term_code");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_terms_status" ON "data_catalog"."catalog_glossary_terms" ("status");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_terms_domain_id" ON "data_catalog"."catalog_glossary_terms" ("domain_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_glossary_term_revisions_no" ON "data_catalog"."catalog_glossary_term_revisions" ("term_id", "revision_no");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_glossary_term_links_pair" ON "data_catalog"."catalog_glossary_term_links" ("term_id", "object_id", COALESCE(column_id, '00000000-0000-0000-0000-000000000000'::uuid));

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_term_links_column_id" ON "data_catalog"."catalog_glossary_term_links" ("column_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_term_links_object_id" ON "data_catalog"."catalog_glossary_term_links" ("object_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_rules_code" ON "data_catalog"."quality_rules" ("rule_code");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_object_id" ON "data_catalog"."quality_rules" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_column_id" ON "data_catalog"."quality_rules" ("column_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_due" ON "data_catalog"."quality_rules" ("enabled", "schedule_minutes") WHERE enabled;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_owner_user_id" ON "data_catalog"."quality_rules" ("owner_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_rule_runs_one_active" ON "data_catalog"."quality_rule_runs" ("rule_id") WHERE status IN ('QUEUED', 'RUNNING');

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_rule_runs_idempotency" ON "data_catalog"."quality_rule_runs" ("requested_by_user_id", "idempotency_key") WHERE idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rule_runs_rule_created" ON "data_catalog"."quality_rule_runs" ("rule_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rule_runs_status_created" ON "data_catalog"."quality_rule_runs" ("status", "created_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_issues_live" ON "data_catalog"."quality_issues" ("fingerprint") WHERE status IN ('OPEN', 'ACKNOWLEDGED');

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_status_severity" ON "data_catalog"."quality_issues" ("status", "severity");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_object_id" ON "data_catalog"."quality_issues" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_rule_id" ON "data_catalog"."quality_issues" ("rule_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_column_id" ON "data_catalog"."quality_issues" ("column_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_first_seen_run_id" ON "data_catalog"."quality_issues" ("first_seen_run_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_last_seen_run_id" ON "data_catalog"."quality_issues" ("last_seen_run_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issue_events_issue_created" ON "data_catalog"."quality_issue_events" ("issue_id", "created_at");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issue_events_run_id" ON "data_catalog"."quality_issue_events" ("run_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_score_snapshots_scope_asof" ON "data_catalog"."quality_score_snapshots" ("scope_kind", COALESCE(object_id, domain_id, '00000000-0000-0000-0000-000000000000'::uuid), "as_of");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_score_snapshots_object_asof" ON "data_catalog"."quality_score_snapshots" ("object_id", "as_of" DESC);

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_score_snapshots_domain_asof" ON "data_catalog"."quality_score_snapshots" ("domain_id", "as_of" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_lineage_edges_identity" ON "data_catalog"."catalog_lineage_edges" ("source_kind", "source_ref", "target_kind", "target_ref", "edge_kind", "origin");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_lineage_edges_source" ON "data_catalog"."catalog_lineage_edges" ("source_kind", "source_ref");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_lineage_edges_target" ON "data_catalog"."catalog_lineage_edges" ("target_kind", "target_ref");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_lineage_edges_official" ON "data_catalog"."catalog_lineage_edges" ("source_kind", "source_ref") WHERE is_official;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_certifications_live" ON "data_catalog"."catalog_certifications" ("target_kind", COALESCE(object_id, read_model_definition_id, report_definition_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(kpi_code, '')) WHERE status IN ('REQUESTED', 'CERTIFIED');

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_status_expires" ON "data_catalog"."catalog_certifications" ("status", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_object_id" ON "data_catalog"."catalog_certifications" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_read_model_definition_id" ON "data_catalog"."catalog_certifications" ("read_model_definition_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_report_definition_id" ON "data_catalog"."catalog_certifications" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_requested_by_user_id" ON "data_catalog"."catalog_certifications" ("requested_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_change_acknowledgements_event" ON "data_catalog"."catalog_change_acknowledgements" ("change_event_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_acknowledgements_user_id" ON "data_catalog"."catalog_change_acknowledgements" ("user_id");
