-- SALUD v4.0.10 · módulo 15 · schema chart
-- Generado de diagram_15_chart.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_patient_profile_id" ON "chart"."clinical_note_headers" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_encounter_id" ON "chart"."clinical_note_headers" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_note_type_concept_id" ON "chart"."clinical_note_headers" ("note_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_lifecycle_status_concept_id" ON "chart"."clinical_note_headers" ("lifecycle_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_current_version_id" ON "chart"."clinical_note_headers" ("current_version_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_current_released_version_id" ON "chart"."clinical_note_headers" ("current_released_version_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_patient_release_status_concept_id" ON "chart"."clinical_note_headers" ("patient_release_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_confidentiality_concept_id" ON "chart"."clinical_note_headers" ("confidentiality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_created_by_user_id" ON "chart"."clinical_note_headers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_updated_by_user_id" ON "chart"."clinical_note_headers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_headers_patient_profile_id_updated_at" ON "chart"."clinical_note_headers" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_clinical_note_id" ON "chart"."clinical_note_versions" ("clinical_note_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_author_profile_id" ON "chart"."clinical_note_versions" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_status_concept_id" ON "chart"."clinical_note_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_supersedes_version_id" ON "chart"."clinical_note_versions" ("supersedes_version_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_amendment_reason_concept_id" ON "chart"."clinical_note_versions" ("amendment_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_signed_by_profile_id" ON "chart"."clinical_note_versions" ("signed_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_release_eligibility_concept_id" ON "chart"."clinical_note_versions" ("release_eligibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_versions_recorded_by_user_id" ON "chart"."clinical_note_versions" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_clinical_note_versions_clinical_note_id_version_number" ON "chart"."clinical_note_versions" ("clinical_note_id", "version_number");

CREATE INDEX IF NOT EXISTS "brin_clinical_note_versions_recorded_at" ON "chart"."clinical_note_versions" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_clinical_note_signatures_clinical_note_version_id" ON "chart"."clinical_note_signatures" ("clinical_note_version_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_signatures_signer_profile_id" ON "chart"."clinical_note_signatures" ("signer_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_note_signatures_signature_type_concept_id" ON "chart"."clinical_note_signatures" ("signature_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_note_release_events_clinical_note_version_id" ON "chart"."note_release_events" ("clinical_note_version_id");

CREATE INDEX IF NOT EXISTS "ix_note_release_events_action_concept_id" ON "chart"."note_release_events" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_note_release_events_patient_profile_id" ON "chart"."note_release_events" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_note_release_events_resulting_visibility_concept_id" ON "chart"."note_release_events" ("resulting_visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_note_release_events_reason_concept_id" ON "chart"."note_release_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_note_release_events_recorded_by_user_id" ON "chart"."note_release_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_note_release_events_patient_profile_id_recorded_at" ON "chart"."note_release_events" ("patient_profile_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_note_release_events_recorded_at" ON "chart"."note_release_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_physical_exam_findings_clinical_note_version_id" ON "chart"."physical_exam_findings" ("clinical_note_version_id");

CREATE INDEX IF NOT EXISTS "ix_physical_exam_findings_body_system_concept_id" ON "chart"."physical_exam_findings" ("body_system_concept_id");

CREATE INDEX IF NOT EXISTS "ix_physical_exam_findings_finding_concept_id" ON "chart"."physical_exam_findings" ("finding_concept_id");

CREATE INDEX IF NOT EXISTS "ix_physical_exam_findings_created_by_user_id" ON "chart"."physical_exam_findings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_patient_profile_id" ON "chart"."care_plans" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_condition_id" ON "chart"."care_plans" ("condition_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_encounter_id" ON "chart"."care_plans" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_status_concept_id" ON "chart"."care_plans" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_intent_concept_id" ON "chart"."care_plans" ("intent_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_author_profile_id" ON "chart"."care_plans" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_created_by_user_id" ON "chart"."care_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_updated_by_user_id" ON "chart"."care_plans" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_plans_patient_profile_id_updated_at" ON "chart"."care_plans" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_plan_activities_care_plan_id" ON "chart"."care_plan_activities" ("care_plan_id");

CREATE INDEX IF NOT EXISTS "ix_care_plan_activities_activity_concept_id" ON "chart"."care_plan_activities" ("activity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_plan_activities_status_concept_id" ON "chart"."care_plan_activities" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_plan_activities_created_by_user_id" ON "chart"."care_plan_activities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_plan_activities_updated_by_user_id" ON "chart"."care_plan_activities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_patient_profile_id" ON "chart"."document_records" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_tenant_id" ON "chart"."document_records" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_encounter_id" ON "chart"."document_records" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_category_concept_id" ON "chart"."document_records" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_source_concept_id" ON "chart"."document_records" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_status_concept_id" ON "chart"."document_records" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_confidentiality_concept_id" ON "chart"."document_records" ("confidentiality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_patient_visibility_concept_id" ON "chart"."document_records" ("patient_visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_created_by_user_id" ON "chart"."document_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_updated_by_user_id" ON "chart"."document_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_document_records_tenant_id_status_concept_id" ON "chart"."document_records" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_document_records_patient_profile_id_updated_at" ON "chart"."document_records" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_document_record_files_document_record_id" ON "chart"."document_record_files" ("document_record_id");

CREATE INDEX IF NOT EXISTS "ix_document_record_files_file_id" ON "chart"."document_record_files" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_document_record_files_content_role_concept_id" ON "chart"."document_record_files" ("content_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_document_record_files_created_by_user_id" ON "chart"."document_record_files" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_specialty_chart_templates_specialty_concept_id" ON "chart"."specialty_chart_templates" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specialty_chart_templates_tenant_id" ON "chart"."specialty_chart_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_specialty_chart_templates_section_id" ON "chart"."specialty_chart_templates" ("section_id");

CREATE INDEX IF NOT EXISTS "ix_specialty_chart_templates_status_concept_id" ON "chart"."specialty_chart_templates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_specialty_chart_templates_created_by_user_id" ON "chart"."specialty_chart_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_specialty_chart_templates_updated_by_user_id" ON "chart"."specialty_chart_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_specialty_chart_templates_tenant_id_status_concept_id" ON "chart"."specialty_chart_templates" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_specialty_chart_templates_section_id_version" ON "chart"."specialty_chart_templates" ("section_id", "version");

CREATE INDEX IF NOT EXISTS "ix_chart_template_assignments_template_id" ON "chart"."chart_template_assignments" ("template_id");

CREATE INDEX IF NOT EXISTS "ix_chart_template_assignments_practice_id" ON "chart"."chart_template_assignments" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_chart_template_assignments_practitioner_profile_id" ON "chart"."chart_template_assignments" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_chart_template_assignments_status_concept_id" ON "chart"."chart_template_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_chart_template_assignments_created_by_user_id" ON "chart"."chart_template_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_chart_template_assignments_updated_by_user_id" ON "chart"."chart_template_assignments" ("updated_by_user_id");
