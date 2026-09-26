-- SALUD v4.0.10 · módulo 69 · schema pharma_lab
-- Generado de diagram_69_pharma_lab.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_doctor_visit_blocks_doctor_user_id" ON "pharma_lab"."doctor_visit_blocks" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_blocks_pharma_lab_id" ON "pharma_lab"."doctor_visit_blocks" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_blocks_medical_visitor_id" ON "pharma_lab"."doctor_visit_blocks" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_blocks_status_concept_id" ON "pharma_lab"."doctor_visit_blocks" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_blocks_created_by_user_id" ON "pharma_lab"."doctor_visit_blocks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_blocks_updated_by_user_id" ON "pharma_lab"."doctor_visit_blocks" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_doctor_visit_policies_doctor_user_id" ON "pharma_lab"."doctor_visit_policies" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_policies_tenant_id" ON "pharma_lab"."doctor_visit_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_policies_status_concept_id" ON "pharma_lab"."doctor_visit_policies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_policies_created_by_user_id" ON "pharma_lab"."doctor_visit_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_policies_updated_by_user_id" ON "pharma_lab"."doctor_visit_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_windows_doctor_visit_policy_id" ON "pharma_lab"."doctor_visit_windows" ("doctor_visit_policy_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_windows_modality_concept_id" ON "pharma_lab"."doctor_visit_windows" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_windows_created_by_user_id" ON "pharma_lab"."doctor_visit_windows" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_doctor_visit_windows_updated_by_user_id" ON "pharma_lab"."doctor_visit_windows" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_pharma_lab_id" ON "pharma_lab"."informational_materials" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_pharma_product_id" ON "pharma_lab"."informational_materials" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_specialty_concept_id" ON "pharma_lab"."informational_materials" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_medical_visitor_id" ON "pharma_lab"."informational_materials" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_kind_concept_id" ON "pharma_lab"."informational_materials" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_approver_staff_id" ON "pharma_lab"."informational_materials" ("approver_staff_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_status_concept_id" ON "pharma_lab"."informational_materials" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_disclosure_level_concept_id" ON "pharma_lab"."informational_materials" ("disclosure_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_created_by_user_id" ON "pharma_lab"."informational_materials" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_updated_by_user_id" ON "pharma_lab"."informational_materials" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_material_approvals_informational_material_id" ON "pharma_lab"."material_approvals" ("informational_material_id");

CREATE INDEX IF NOT EXISTS "ix_material_approvals_decision_concept_id" ON "pharma_lab"."material_approvals" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_material_approvals_reviewer_staff_id" ON "pharma_lab"."material_approvals" ("reviewer_staff_id");

CREATE INDEX IF NOT EXISTS "ix_material_approvals_created_by_user_id" ON "pharma_lab"."material_approvals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_material_assets_informational_material_id" ON "pharma_lab"."material_assets" ("informational_material_id");

CREATE INDEX IF NOT EXISTS "ix_material_assets_kind_concept_id" ON "pharma_lab"."material_assets" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_material_assets_created_by_user_id" ON "pharma_lab"."material_assets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitor_products_medical_visitor_id" ON "pharma_lab"."medical_visitor_products" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitor_products_pharma_product_id" ON "pharma_lab"."medical_visitor_products" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitor_products_created_by_user_id" ON "pharma_lab"."medical_visitor_products" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitor_specialties_medical_visitor_id" ON "pharma_lab"."medical_visitor_specialties" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitor_specialties_specialty_concept_id" ON "pharma_lab"."medical_visitor_specialties" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitor_specialties_created_by_user_id" ON "pharma_lab"."medical_visitor_specialties" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_medical_visitors_user_id" ON "pharma_lab"."medical_visitors" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_pharma_lab_id" ON "pharma_lab"."medical_visitors" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_staff_id" ON "pharma_lab"."medical_visitors" ("staff_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_supervisor_staff_id" ON "pharma_lab"."medical_visitors" ("supervisor_staff_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_branch_id" ON "pharma_lab"."medical_visitors" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_identity_verification_concept_id" ON "pharma_lab"."medical_visitors" ("identity_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_contract_verification_concept_id" ON "pharma_lab"."medical_visitors" ("contract_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_credential_verification_concept_id" ON "pharma_lab"."medical_visitors" ("credential_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_status_concept_id" ON "pharma_lab"."medical_visitors" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_created_by_user_id" ON "pharma_lab"."medical_visitors" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_updated_by_user_id" ON "pharma_lab"."medical_visitors" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_pharma_lab_id" ON "pharma_lab"."pharma_cost_allocations" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_journal_transaction_id" ON "pharma_lab"."pharma_cost_allocations" ("journal_transaction_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_cost_type_concept_id" ON "pharma_lab"."pharma_cost_allocations" ("cost_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_currency_concept_id" ON "pharma_lab"."pharma_cost_allocations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_pharma_product_id" ON "pharma_lab"."pharma_cost_allocations" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_branch_id" ON "pharma_lab"."pharma_cost_allocations" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_medical_visitor_id" ON "pharma_lab"."pharma_cost_allocations" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_created_by_user_id" ON "pharma_lab"."pharma_cost_allocations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_cost_allocations_updated_by_user_id" ON "pharma_lab"."pharma_cost_allocations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_link_events_pharma_lab_id" ON "pharma_lab"."pharma_lab_link_events" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_link_events_staff_id" ON "pharma_lab"."pharma_lab_link_events" ("staff_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_link_events_medical_visitor_id" ON "pharma_lab"."pharma_lab_link_events" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_link_events_subject_user_id" ON "pharma_lab"."pharma_lab_link_events" ("subject_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_link_events_event_type_concept_id" ON "pharma_lab"."pharma_lab_link_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_link_events_created_by_user_id" ON "pharma_lab"."pharma_lab_link_events" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_notices_recipient_user_id" ON "pharma_lab"."pharma_lab_notices" ("recipient_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_notices_tenant_id" ON "pharma_lab"."pharma_lab_notices" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_notices_created_by_user_id" ON "pharma_lab"."pharma_lab_notices" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_notices_updated_by_user_id" ON "pharma_lab"."pharma_lab_notices" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_pharma_lab_id" ON "pharma_lab"."pharma_lab_staff" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_user_id" ON "pharma_lab"."pharma_lab_staff" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_staff_type_concept_id" ON "pharma_lab"."pharma_lab_staff" ("staff_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_branch_id" ON "pharma_lab"."pharma_lab_staff" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_credential_verification_concept_id" ON "pharma_lab"."pharma_lab_staff" ("credential_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_status_concept_id" ON "pharma_lab"."pharma_lab_staff" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_created_by_user_id" ON "pharma_lab"."pharma_lab_staff" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_updated_by_user_id" ON "pharma_lab"."pharma_lab_staff" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_pharma_labs_tenant_id" ON "pharma_lab"."pharma_labs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_lab_type_concept_id" ON "pharma_lab"."pharma_labs" ("lab_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_status_concept_id" ON "pharma_lab"."pharma_labs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_created_by_user_id" ON "pharma_lab"."pharma_labs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_updated_by_user_id" ON "pharma_lab"."pharma_labs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_pharma_lab_id" ON "pharma_lab"."pharma_products" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_regulatory_status_concept_id" ON "pharma_lab"."pharma_products" ("regulatory_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_disclosure_level_concept_id" ON "pharma_lab"."pharma_products" ("disclosure_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_created_by_user_id" ON "pharma_lab"."pharma_products" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_updated_by_user_id" ON "pharma_lab"."pharma_products" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_actions_pharmacovigilance_report_id" ON "pharma_lab"."pharmacovigilance_actions" ("pharmacovigilance_report_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_actions_action_concept_id" ON "pharma_lab"."pharmacovigilance_actions" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_actions_previous_status_concept_id" ON "pharma_lab"."pharmacovigilance_actions" ("previous_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_actions_new_status_concept_id" ON "pharma_lab"."pharmacovigilance_actions" ("new_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_actions_actor_user_id" ON "pharma_lab"."pharmacovigilance_actions" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_actions_created_by_user_id" ON "pharma_lab"."pharmacovigilance_actions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_pharma_lab_id" ON "pharma_lab"."pharmacovigilance_reports" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_pharma_product_id" ON "pharma_lab"."pharmacovigilance_reports" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_event_type_concept_id" ON "pharma_lab"."pharmacovigilance_reports" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_severity_concept_id" ON "pharma_lab"."pharmacovigilance_reports" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_status_concept_id" ON "pharma_lab"."pharmacovigilance_reports" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_reporter_type_concept_id" ON "pharma_lab"."pharmacovigilance_reports" ("reporter_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_reporter_user_id" ON "pharma_lab"."pharmacovigilance_reports" ("reporter_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_reporter_tenant_id" ON "pharma_lab"."pharmacovigilance_reports" ("reporter_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_subject_sex_concept_id" ON "pharma_lab"."pharmacovigilance_reports" ("subject_sex_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_created_by_user_id" ON "pharma_lab"."pharmacovigilance_reports" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_updated_by_user_id" ON "pharma_lab"."pharmacovigilance_reports" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_document_access_log_regulatory_document_id" ON "pharma_lab"."regulatory_document_access_log" ("regulatory_document_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_document_access_log_regulatory_document__388a7b7d" ON "pharma_lab"."regulatory_document_access_log" ("regulatory_document_version_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_document_access_log_actor_user_id" ON "pharma_lab"."regulatory_document_access_log" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_document_versions_regulatory_document_id" ON "pharma_lab"."regulatory_document_versions" ("regulatory_document_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_document_versions_status_concept_id" ON "pharma_lab"."regulatory_document_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_document_versions_created_by_user_id" ON "pharma_lab"."regulatory_document_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_document_versions_updated_by_user_id" ON "pharma_lab"."regulatory_document_versions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_pharma_lab_id" ON "pharma_lab"."regulatory_documents" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_pharma_product_id" ON "pharma_lab"."regulatory_documents" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_medical_visitor_id" ON "pharma_lab"."regulatory_documents" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_document_type_concept_id" ON "pharma_lab"."regulatory_documents" ("document_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_status_concept_id" ON "pharma_lab"."regulatory_documents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_owner_staff_id" ON "pharma_lab"."regulatory_documents" ("owner_staff_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_disclosure_level_concept_id" ON "pharma_lab"."regulatory_documents" ("disclosure_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_created_by_user_id" ON "pharma_lab"."regulatory_documents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_updated_by_user_id" ON "pharma_lab"."regulatory_documents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_ratings_visit_record_id" ON "pharma_lab"."visit_ratings" ("visit_record_id");

CREATE INDEX IF NOT EXISTS "ix_visit_ratings_doctor_user_id" ON "pharma_lab"."visit_ratings" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_ratings_kind_concept_id" ON "pharma_lab"."visit_ratings" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_ratings_created_by_user_id" ON "pharma_lab"."visit_ratings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_ratings_updated_by_user_id" ON "pharma_lab"."visit_ratings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_record_materials_visit_record_id" ON "pharma_lab"."visit_record_materials" ("visit_record_id");

CREATE INDEX IF NOT EXISTS "ix_visit_record_materials_informational_material_id" ON "pharma_lab"."visit_record_materials" ("informational_material_id");

CREATE INDEX IF NOT EXISTS "ix_visit_record_materials_created_by_user_id" ON "pharma_lab"."visit_record_materials" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_visit_records_visit_request_id" ON "pharma_lab"."visit_records" ("visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_doctor_user_id" ON "pharma_lab"."visit_records" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_medical_visitor_id" ON "pharma_lab"."visit_records" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_pharma_lab_id" ON "pharma_lab"."visit_records" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_modality_concept_id" ON "pharma_lab"."visit_records" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_visitor_attendance_concept_id" ON "pharma_lab"."visit_records" ("visitor_attendance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_doctor_attendance_concept_id" ON "pharma_lab"."visit_records" ("doctor_attendance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_confirmation_concept_id" ON "pharma_lab"."visit_records" ("confirmation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_created_by_user_id" ON "pharma_lab"."visit_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_records_updated_by_user_id" ON "pharma_lab"."visit_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_events_visit_request_id" ON "pharma_lab"."visit_request_events" ("visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_events_action_concept_id" ON "pharma_lab"."visit_request_events" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_events_previous_status_concept_id" ON "pharma_lab"."visit_request_events" ("previous_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_events_new_status_concept_id" ON "pharma_lab"."visit_request_events" ("new_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_events_actor_user_id" ON "pharma_lab"."visit_request_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_events_created_by_user_id" ON "pharma_lab"."visit_request_events" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_topics_visit_request_id" ON "pharma_lab"."visit_request_topics" ("visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_topics_pharma_product_id" ON "pharma_lab"."visit_request_topics" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_visit_request_topics_created_by_user_id" ON "pharma_lab"."visit_request_topics" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_medical_visitor_id" ON "pharma_lab"."visit_requests" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_pharma_lab_id" ON "pharma_lab"."visit_requests" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_doctor_user_id" ON "pharma_lab"."visit_requests" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_doctor_tenant_id" ON "pharma_lab"."visit_requests" ("doctor_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_modality_concept_id" ON "pharma_lab"."visit_requests" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_status_concept_id" ON "pharma_lab"."visit_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_rescheduled_from_id" ON "pharma_lab"."visit_requests" ("rescheduled_from_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_created_by_user_id" ON "pharma_lab"."visit_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_updated_by_user_id" ON "pharma_lab"."visit_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_answers_visit_survey_response_id" ON "pharma_lab"."visit_survey_answers" ("visit_survey_response_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_answers_visit_survey_question_id" ON "pharma_lab"."visit_survey_answers" ("visit_survey_question_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_answers_created_by_user_id" ON "pharma_lab"."visit_survey_answers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_questions_visit_survey_id" ON "pharma_lab"."visit_survey_questions" ("visit_survey_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_questions_answer_type_concept_id" ON "pharma_lab"."visit_survey_questions" ("answer_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_questions_created_by_user_id" ON "pharma_lab"."visit_survey_questions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_responses_visit_survey_id" ON "pharma_lab"."visit_survey_responses" ("visit_survey_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_responses_visit_record_id" ON "pharma_lab"."visit_survey_responses" ("visit_record_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_responses_doctor_user_id" ON "pharma_lab"."visit_survey_responses" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_responses_status_concept_id" ON "pharma_lab"."visit_survey_responses" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_responses_created_by_user_id" ON "pharma_lab"."visit_survey_responses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_survey_responses_updated_by_user_id" ON "pharma_lab"."visit_survey_responses" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_surveys_pharma_lab_id" ON "pharma_lab"."visit_surveys" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_visit_surveys_medical_visitor_id" ON "pharma_lab"."visit_surveys" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_visit_surveys_pharma_product_id" ON "pharma_lab"."visit_surveys" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_visit_surveys_specialty_concept_id" ON "pharma_lab"."visit_surveys" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_surveys_status_concept_id" ON "pharma_lab"."visit_surveys" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_surveys_created_by_user_id" ON "pharma_lab"."visit_surveys" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_surveys_updated_by_user_id" ON "pharma_lab"."visit_surveys" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_pharma_lab_id" ON "pharma_lab"."visitor_post_submissions" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_medical_visitor_id" ON "pharma_lab"."visitor_post_submissions" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_informational_material_id" ON "pharma_lab"."visitor_post_submissions" ("informational_material_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_status_concept_id" ON "pharma_lab"."visitor_post_submissions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_decided_by_user_id" ON "pharma_lab"."visitor_post_submissions" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_social_post_id" ON "pharma_lab"."visitor_post_submissions" ("social_post_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_created_by_user_id" ON "pharma_lab"."visitor_post_submissions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visitor_post_submissions_updated_by_user_id" ON "pharma_lab"."visitor_post_submissions" ("updated_by_user_id");
