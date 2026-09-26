-- SALUD v4.0.10 · módulo 69 · schema pharma_lab
-- Generado de diagram_69_pharma_lab.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_blocks"
        ADD CONSTRAINT "fk_doctor_visit_blocks_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_blocks"
        ADD CONSTRAINT "fk_doctor_visit_blocks_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_windows"
        ADD CONSTRAINT "fk_doctor_visit_windows_doctor_visit_policy_id" FOREIGN KEY ("doctor_visit_policy_id")
        REFERENCES "pharma_lab"."doctor_visit_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_approver_staff_id" FOREIGN KEY ("approver_staff_id")
        REFERENCES "pharma_lab"."pharma_lab_staff" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."material_approvals"
        ADD CONSTRAINT "fk_material_approvals_informational_material_id" FOREIGN KEY ("informational_material_id")
        REFERENCES "pharma_lab"."informational_materials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."material_approvals"
        ADD CONSTRAINT "fk_material_approvals_reviewer_staff_id" FOREIGN KEY ("reviewer_staff_id")
        REFERENCES "pharma_lab"."pharma_lab_staff" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."material_assets"
        ADD CONSTRAINT "fk_material_assets_informational_material_id" FOREIGN KEY ("informational_material_id")
        REFERENCES "pharma_lab"."informational_materials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitor_products"
        ADD CONSTRAINT "fk_medical_visitor_products_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitor_products"
        ADD CONSTRAINT "fk_medical_visitor_products_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitor_specialties"
        ADD CONSTRAINT "fk_medical_visitor_specialties_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_staff_id" FOREIGN KEY ("staff_id")
        REFERENCES "pharma_lab"."pharma_lab_staff" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_supervisor_staff_id" FOREIGN KEY ("supervisor_staff_id")
        REFERENCES "pharma_lab"."pharma_lab_staff" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_link_events"
        ADD CONSTRAINT "fk_pharma_lab_link_events_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_link_events"
        ADD CONSTRAINT "fk_pharma_lab_link_events_staff_id" FOREIGN KEY ("staff_id")
        REFERENCES "pharma_lab"."pharma_lab_staff" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_link_events"
        ADD CONSTRAINT "fk_pharma_lab_link_events_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_products"
        ADD CONSTRAINT "fk_pharma_products_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_actions"
        ADD CONSTRAINT "fk_pharmacovigilance_actions_pharmacovigilance_report_id" FOREIGN KEY ("pharmacovigilance_report_id")
        REFERENCES "pharma_lab"."pharmacovigilance_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_document_access_log"
        ADD CONSTRAINT "fk_regulatory_document_access_log_regulatory_document_id" FOREIGN KEY ("regulatory_document_id")
        REFERENCES "pharma_lab"."regulatory_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_document_access_log"
        ADD CONSTRAINT "fk_regulatory_document_access_log_regulatory_document__19472d8c" FOREIGN KEY ("regulatory_document_version_id")
        REFERENCES "pharma_lab"."regulatory_document_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_document_versions"
        ADD CONSTRAINT "fk_regulatory_document_versions_regulatory_document_id" FOREIGN KEY ("regulatory_document_id")
        REFERENCES "pharma_lab"."regulatory_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_owner_staff_id" FOREIGN KEY ("owner_staff_id")
        REFERENCES "pharma_lab"."pharma_lab_staff" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_ratings"
        ADD CONSTRAINT "fk_visit_ratings_visit_record_id" FOREIGN KEY ("visit_record_id")
        REFERENCES "pharma_lab"."visit_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_record_materials"
        ADD CONSTRAINT "fk_visit_record_materials_visit_record_id" FOREIGN KEY ("visit_record_id")
        REFERENCES "pharma_lab"."visit_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_record_materials"
        ADD CONSTRAINT "fk_visit_record_materials_informational_material_id" FOREIGN KEY ("informational_material_id")
        REFERENCES "pharma_lab"."informational_materials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_visit_request_id" FOREIGN KEY ("visit_request_id")
        REFERENCES "pharma_lab"."visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_events"
        ADD CONSTRAINT "fk_visit_request_events_visit_request_id" FOREIGN KEY ("visit_request_id")
        REFERENCES "pharma_lab"."visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_topics"
        ADD CONSTRAINT "fk_visit_request_topics_visit_request_id" FOREIGN KEY ("visit_request_id")
        REFERENCES "pharma_lab"."visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_topics"
        ADD CONSTRAINT "fk_visit_request_topics_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_rescheduled_from_id" FOREIGN KEY ("rescheduled_from_id")
        REFERENCES "pharma_lab"."visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_answers"
        ADD CONSTRAINT "fk_visit_survey_answers_visit_survey_response_id" FOREIGN KEY ("visit_survey_response_id")
        REFERENCES "pharma_lab"."visit_survey_responses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_answers"
        ADD CONSTRAINT "fk_visit_survey_answers_visit_survey_question_id" FOREIGN KEY ("visit_survey_question_id")
        REFERENCES "pharma_lab"."visit_survey_questions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_questions"
        ADD CONSTRAINT "fk_visit_survey_questions_visit_survey_id" FOREIGN KEY ("visit_survey_id")
        REFERENCES "pharma_lab"."visit_surveys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_responses"
        ADD CONSTRAINT "fk_visit_survey_responses_visit_survey_id" FOREIGN KEY ("visit_survey_id")
        REFERENCES "pharma_lab"."visit_surveys" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_responses"
        ADD CONSTRAINT "fk_visit_survey_responses_visit_record_id" FOREIGN KEY ("visit_record_id")
        REFERENCES "pharma_lab"."visit_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_surveys"
        ADD CONSTRAINT "fk_visit_surveys_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_surveys"
        ADD CONSTRAINT "fk_visit_surveys_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_surveys"
        ADD CONSTRAINT "fk_visit_surveys_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_informational_material_id" FOREIGN KEY ("informational_material_id")
        REFERENCES "pharma_lab"."informational_materials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)
