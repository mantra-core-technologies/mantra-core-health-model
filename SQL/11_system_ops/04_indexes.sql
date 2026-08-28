-- SALUD v4.0.10 · módulo 11 · schema system_ops
-- Generado de diagram_11_system_ops.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_data_classifications_code" ON "system_ops"."data_classifications" ("code");

CREATE INDEX IF NOT EXISTS "ix_data_classifications_state_concept_id" ON "system_ops"."data_classifications" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_data_classifications_created_by_user_id" ON "system_ops"."data_classifications" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_data_classifications_updated_by_user_id" ON "system_ops"."data_classifications" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_data_domains_code" ON "system_ops"."data_domains" ("code");

CREATE INDEX IF NOT EXISTS "ix_data_domains_created_by_user_id" ON "system_ops"."data_domains" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_data_domains_updated_by_user_id" ON "system_ops"."data_domains" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_entity_registry_domain_id" ON "system_ops"."entity_registry" ("domain_id");

CREATE INDEX IF NOT EXISTS "ix_entity_registry_classification_id" ON "system_ops"."entity_registry" ("classification_id");

CREATE INDEX IF NOT EXISTS "ix_entity_registry_retention_policy_id" ON "system_ops"."entity_registry" ("retention_policy_id");

CREATE INDEX IF NOT EXISTS "ix_entity_registry_write_policy_id" ON "system_ops"."entity_registry" ("write_policy_id");

CREATE INDEX IF NOT EXISTS "ix_entity_registry_state_concept_id" ON "system_ops"."entity_registry" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_entity_registry_created_by_user_id" ON "system_ops"."entity_registry" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_entity_registry_updated_by_user_id" ON "system_ops"."entity_registry" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_registry_entity_registry_id" ON "system_ops"."field_registry" ("entity_registry_id");

CREATE INDEX IF NOT EXISTS "ix_field_registry_classification_id" ON "system_ops"."field_registry" ("classification_id");

CREATE INDEX IF NOT EXISTS "ix_field_registry_masking_strategy_concept_id" ON "system_ops"."field_registry" ("masking_strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_field_registry_anonymization_rule_id" ON "system_ops"."field_registry" ("anonymization_rule_id");

CREATE INDEX IF NOT EXISTS "ix_field_registry_created_by_user_id" ON "system_ops"."field_registry" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_field_registry_updated_by_user_id" ON "system_ops"."field_registry" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_write_policies_code" ON "system_ops"."write_policies" ("code");

CREATE INDEX IF NOT EXISTS "ix_write_policies_insert_mode_concept_id" ON "system_ops"."write_policies" ("insert_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_write_policies_update_mode_concept_id" ON "system_ops"."write_policies" ("update_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_write_policies_delete_mode_concept_id" ON "system_ops"."write_policies" ("delete_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_write_policies_state_concept_id" ON "system_ops"."write_policies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_write_policies_created_by_user_id" ON "system_ops"."write_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_write_policies_updated_by_user_id" ON "system_ops"."write_policies" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_retention_policies_code" ON "system_ops"."retention_policies" ("code");

CREATE INDEX IF NOT EXISTS "ix_retention_policies_legal_basis_concept_id" ON "system_ops"."retention_policies" ("legal_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_retention_policies_disposition_concept_id" ON "system_ops"."retention_policies" ("disposition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_retention_policies_jurisdiction_concept_id" ON "system_ops"."retention_policies" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_retention_policies_state_concept_id" ON "system_ops"."retention_policies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_retention_policies_created_by_user_id" ON "system_ops"."retention_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_retention_policies_updated_by_user_id" ON "system_ops"."retention_policies" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_anonymization_rules_code" ON "system_ops"."anonymization_rules" ("code");

CREATE INDEX IF NOT EXISTS "ix_anonymization_rules_technique_concept_id" ON "system_ops"."anonymization_rules" ("technique_concept_id");

CREATE INDEX IF NOT EXISTS "ix_anonymization_rules_created_by_user_id" ON "system_ops"."anonymization_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_anonymization_rules_updated_by_user_id" ON "system_ops"."anonymization_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_retention_executions_retention_policy_id" ON "system_ops"."retention_executions" ("retention_policy_id");

CREATE INDEX IF NOT EXISTS "ix_retention_executions_entity_registry_id" ON "system_ops"."retention_executions" ("entity_registry_id");

CREATE INDEX IF NOT EXISTS "ix_retention_executions_status_concept_id" ON "system_ops"."retention_executions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_retention_executions_recorded_by_user_id" ON "system_ops"."retention_executions" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_retention_executions_recorded_at" ON "system_ops"."retention_executions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_governance_change_log_action_concept_id" ON "system_ops"."governance_change_log" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_governance_change_log_changed_by_user_id" ON "system_ops"."governance_change_log" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_governance_change_log_recorded_by_user_id" ON "system_ops"."governance_change_log" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_governance_change_log_recorded_at" ON "system_ops"."governance_change_log" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_record_revisions_operation_concept_id" ON "system_ops"."record_revisions" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_record_revisions_changed_by_user_id" ON "system_ops"."record_revisions" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_record_revisions_change_reason_concept_id" ON "system_ops"."record_revisions" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_record_revisions_recorded_by_user_id" ON "system_ops"."record_revisions" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_record_revisions_recorded_at" ON "system_ops"."record_revisions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_draft_records_owner_user_id" ON "system_ops"."draft_records" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_draft_records_tenant_id" ON "system_ops"."draft_records" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_draft_records_status_concept_id" ON "system_ops"."draft_records" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_draft_records_created_by_user_id" ON "system_ops"."draft_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_draft_records_updated_by_user_id" ON "system_ops"."draft_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_draft_records_tenant_id_status_concept_id" ON "system_ops"."draft_records" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_data_residency_policies_code" ON "system_ops"."data_residency_policies" ("code");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_jurisdiction_concept_id" ON "system_ops"."data_residency_policies" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_data_classification_id" ON "system_ops"."data_residency_policies" ("data_classification_id");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_allowed_storage_region_value_set_id" ON "system_ops"."data_residency_policies" ("allowed_storage_region_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_allowed_processing_region_v_e59a2240" ON "system_ops"."data_residency_policies" ("allowed_processing_region_value_set_id");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_cross_border_transfer_basis_1b4c4437" ON "system_ops"."data_residency_policies" ("cross_border_transfer_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_status_concept_id" ON "system_ops"."data_residency_policies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_created_by_user_id" ON "system_ops"."data_residency_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_data_residency_policies_updated_by_user_id" ON "system_ops"."data_residency_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_tenant_id" ON "system_ops"."tenant_residency_bindings" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_residency_policy_id" ON "system_ops"."tenant_residency_bindings" ("residency_policy_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_primary_region_concept_id" ON "system_ops"."tenant_residency_bindings" ("primary_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_disaster_recovery_region__5ff5dc29" ON "system_ops"."tenant_residency_bindings" ("disaster_recovery_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_status_concept_id" ON "system_ops"."tenant_residency_bindings" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_created_by_user_id" ON "system_ops"."tenant_residency_bindings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_updated_by_user_id" ON "system_ops"."tenant_residency_bindings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_residency_bindings_tenant_id_status_concept_id" ON "system_ops"."tenant_residency_bindings" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_legal_holds_tenant_id" ON "system_ops"."legal_holds" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_legal_holds_target_type_concept_id" ON "system_ops"."legal_holds" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_legal_holds_reason_concept_id" ON "system_ops"."legal_holds" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_legal_holds_status_concept_id" ON "system_ops"."legal_holds" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_legal_holds_created_by_user_id" ON "system_ops"."legal_holds" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_legal_holds_updated_by_user_id" ON "system_ops"."legal_holds" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_legal_holds_tenant_id_status_concept_id" ON "system_ops"."legal_holds" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_backup_policies_tenant_id" ON "system_ops"."backup_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_backup_policies_resource_scope_concept_id" ON "system_ops"."backup_policies" ("resource_scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_backup_policies_backup_type_concept_id" ON "system_ops"."backup_policies" ("backup_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_backup_policies_status_concept_id" ON "system_ops"."backup_policies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_backup_policies_created_by_user_id" ON "system_ops"."backup_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_backup_policies_updated_by_user_id" ON "system_ops"."backup_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_backup_policies_tenant_id_status_concept_id" ON "system_ops"."backup_policies" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_restore_test_runs_backup_policy_id" ON "system_ops"."restore_test_runs" ("backup_policy_id");

CREATE INDEX IF NOT EXISTS "ix_restore_test_runs_outcome_concept_id" ON "system_ops"."restore_test_runs" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_restore_test_runs_evidence_file_id" ON "system_ops"."restore_test_runs" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_restore_test_runs_recorded_by_user_id" ON "system_ops"."restore_test_runs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_restore_test_runs_started_at" ON "system_ops"."restore_test_runs" USING brin ("started_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_tenant_id" ON "system_ops"."cross_border_transfer_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_data_category_concept_id" ON "system_ops"."cross_border_transfer_events" ("data_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_source_region_concept_id" ON "system_ops"."cross_border_transfer_events" ("source_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_destination_region_concept_id" ON "system_ops"."cross_border_transfer_events" ("destination_region_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_transfer_basis_concept_id" ON "system_ops"."cross_border_transfer_events" ("transfer_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_recipient_tenant_id" ON "system_ops"."cross_border_transfer_events" ("recipient_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_approved_by_user_id" ON "system_ops"."cross_border_transfer_events" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cross_border_transfer_events_tenant_id_recorded_at" ON "system_ops"."cross_border_transfer_events" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_cross_border_transfer_events_recorded_at" ON "system_ops"."cross_border_transfer_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_operational_frameworks_provider_concept_id" ON "system_ops"."operational_frameworks" ("provider_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_frameworks_state_concept_id" ON "system_ops"."operational_frameworks" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_frameworks_created_by_user_id" ON "system_ops"."operational_frameworks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_frameworks_updated_by_user_id" ON "system_ops"."operational_frameworks" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_operational_frameworks_code_version" ON "system_ops"."operational_frameworks" ("code", "version");

CREATE INDEX IF NOT EXISTS "ix_operational_framework_controls_operational_framework_id" ON "system_ops"."operational_framework_controls" ("operational_framework_id");

CREATE INDEX IF NOT EXISTS "ix_operational_framework_controls_parent_control_id" ON "system_ops"."operational_framework_controls" ("parent_control_id");

CREATE INDEX IF NOT EXISTS "ix_operational_framework_controls_pillar_concept_id" ON "system_ops"."operational_framework_controls" ("pillar_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_framework_controls_state_concept_id" ON "system_ops"."operational_framework_controls" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_operational_framework_controls_created_by_user_id" ON "system_ops"."operational_framework_controls" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_operational_framework_controls_updated_by_user_id" ON "system_ops"."operational_framework_controls" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_operational_framework_controls_framework_code" ON "system_ops"."operational_framework_controls" ("operational_framework_id", "control_code");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_tenant_id" ON "system_ops"."workload_assessments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_operational_framework_id" ON "system_ops"."workload_assessments" ("operational_framework_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_service_component_id" ON "system_ops"."workload_assessments" ("service_component_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_assessment_type_concept_id" ON "system_ops"."workload_assessments" ("assessment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_status_concept_id" ON "system_ops"."workload_assessments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_facilitator_user_id" ON "system_ops"."workload_assessments" ("facilitator_user_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_approved_by_user_id" ON "system_ops"."workload_assessments" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_created_by_user_id" ON "system_ops"."workload_assessments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_updated_by_user_id" ON "system_ops"."workload_assessments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_tenant_status" ON "system_ops"."workload_assessments" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_workload_assessments_tenant_workload" ON "system_ops"."workload_assessments" ("tenant_id", "workload_code", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_workload_assessment_id" ON "system_ops"."assessment_control_results" ("workload_assessment_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_operational_framework_control_id" ON "system_ops"."assessment_control_results" ("operational_framework_control_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_result_concept_id" ON "system_ops"."assessment_control_results" ("result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_maturity_level_concept_id" ON "system_ops"."assessment_control_results" ("maturity_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_assessor_user_id" ON "system_ops"."assessment_control_results" ("assessor_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_accepted_risk_id" ON "system_ops"."assessment_control_results" ("accepted_risk_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_created_by_user_id" ON "system_ops"."assessment_control_results" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_control_results_updated_by_user_id" ON "system_ops"."assessment_control_results" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_assessment_control_results_assessment_control" ON "system_ops"."assessment_control_results" ("workload_assessment_id", "operational_framework_control_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_findings_workload_assessment_id" ON "system_ops"."assessment_findings" ("workload_assessment_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_findings_assessment_control_result_id" ON "system_ops"."assessment_findings" ("assessment_control_result_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_findings_severity_concept_id" ON "system_ops"."assessment_findings" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_findings_status_concept_id" ON "system_ops"."assessment_findings" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_findings_created_by_user_id" ON "system_ops"."assessment_findings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_findings_updated_by_user_id" ON "system_ops"."assessment_findings" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_assessment_findings_assessment_code" ON "system_ops"."assessment_findings" ("workload_assessment_id", "finding_code");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_tenant_id" ON "system_ops"."remediation_plans" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_workload_assessment_id" ON "system_ops"."remediation_plans" ("workload_assessment_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_status_concept_id" ON "system_ops"."remediation_plans" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_owner_user_id" ON "system_ops"."remediation_plans" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_approved_by_user_id" ON "system_ops"."remediation_plans" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_created_by_user_id" ON "system_ops"."remediation_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_updated_by_user_id" ON "system_ops"."remediation_plans" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_plans_tenant_status" ON "system_ops"."remediation_plans" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uk_remediation_plans_tenant_code" ON "system_ops"."remediation_plans" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_remediation_actions_remediation_plan_id" ON "system_ops"."remediation_actions" ("remediation_plan_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_actions_assessment_finding_id" ON "system_ops"."remediation_actions" ("assessment_finding_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_actions_status_concept_id" ON "system_ops"."remediation_actions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_actions_assigned_user_id" ON "system_ops"."remediation_actions" ("assigned_user_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_actions_verification_user_id" ON "system_ops"."remediation_actions" ("verification_user_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_actions_created_by_user_id" ON "system_ops"."remediation_actions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_remediation_actions_updated_by_user_id" ON "system_ops"."remediation_actions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_remediation_actions_plan_code" ON "system_ops"."remediation_actions" ("remediation_plan_id", "action_code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_partition_specs_code" ON "system_ops"."partition_specs" ("code");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_partition_specs_table" ON "system_ops"."partition_specs" ("schema_name", "table_name");

CREATE INDEX IF NOT EXISTS "ix_partition_specs_entity_registry_id" ON "system_ops"."partition_specs" ("entity_registry_id");

CREATE INDEX IF NOT EXISTS "ix_partition_specs_strategy_concept_id" ON "system_ops"."partition_specs" ("partition_strategy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partition_specs_retention_policy_id" ON "system_ops"."partition_specs" ("retention_policy_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_encryption_keys_key_alias" ON "system_ops"."encryption_keys" ("key_alias");

CREATE INDEX IF NOT EXISTS "ix_encryption_keys_purpose_concept_id" ON "system_ops"."encryption_keys" ("key_purpose_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encryption_keys_next_rotation_at" ON "system_ops"."encryption_keys" ("next_rotation_at");

CREATE INDEX IF NOT EXISTS "ix_encryption_keys_state_concept_id" ON "system_ops"."encryption_keys" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_key_rotation_events_encryption_key_id" ON "system_ops"."key_rotation_events" ("encryption_key_id");

CREATE INDEX IF NOT EXISTS "ix_key_rotation_events_occurred_at" ON "system_ops"."key_rotation_events" ("occurred_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_security_incidents_code" ON "system_ops"."security_incidents" ("code");

CREATE INDEX IF NOT EXISTS "ix_security_incidents_severity_concept_id" ON "system_ops"."security_incidents" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_security_incidents_status_concept_id" ON "system_ops"."security_incidents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_security_incidents_detected_at" ON "system_ops"."security_incidents" ("detected_at");

CREATE INDEX IF NOT EXISTS "ix_breach_notifications_security_incident_id" ON "system_ops"."breach_notifications" ("security_incident_id");

CREATE INDEX IF NOT EXISTS "ix_breach_notifications_authority_concept_id" ON "system_ops"."breach_notifications" ("authority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_breach_notifications_deadline_at" ON "system_ops"."breach_notifications" ("deadline_at");

CREATE INDEX IF NOT EXISTS "ix_breach_notifications_status_concept_id" ON "system_ops"."breach_notifications" ("status_concept_id");
