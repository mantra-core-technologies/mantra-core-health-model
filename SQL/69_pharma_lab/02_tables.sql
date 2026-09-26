-- SALUD v4.0.10 · módulo 69 · schema pharma_lab
-- Generado de diagram_69_pharma_lab.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "pharma_lab"."doctor_visit_blocks" (
    "id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "pharma_lab_id" uuid,
    "medical_visitor_id" uuid,
    "reason" text NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "lifted_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_doctor_visit_blocks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."doctor_visit_policies" (
    "id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "tenant_id" uuid,
    "time_zone" varchar,
    "auto_confirm" boolean NOT NULL DEFAULT false,
    "max_visits_per_day" integer,
    "min_notice_hours" integer NOT NULL,
    "reschedule_cutoff_hours" integer NOT NULL,
    "allowed_specialty_concept_ids" jsonb,
    "allowed_modality_concept_ids" jsonb,
    "max_duration_minutes" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_doctor_visit_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."doctor_visit_windows" (
    "id" uuid NOT NULL,
    "doctor_visit_policy_id" uuid NOT NULL,
    "weekday" integer NOT NULL,
    "start_time" time NOT NULL,
    "end_time" time NOT NULL,
    "slot_duration_minutes" integer NOT NULL,
    "modality_concept_id" uuid NOT NULL,
    "location" varchar,
    "max_visits" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_doctor_visit_windows" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."informational_materials" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "pharma_product_id" uuid,
    "campaign_code" varchar,
    "specialty_concept_id" uuid,
    "medical_visitor_id" uuid,
    "title" varchar NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "author_name" varchar,
    "approver_staff_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "disclosure_level_concept_id" uuid NOT NULL,
    "approved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_informational_materials" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."material_approvals" (
    "id" uuid NOT NULL,
    "informational_material_id" uuid NOT NULL,
    "material_version" varchar NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "reviewer_staff_id" uuid,
    "rationale" text,
    "decided_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_material_approvals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."material_assets" (
    "id" uuid NOT NULL,
    "informational_material_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "file_name" varchar NOT NULL,
    "storage_key" varchar NOT NULL,
    "content_type" varchar,
    "size_bytes" bigint,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_material_assets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."medical_visitor_products" (
    "id" uuid NOT NULL,
    "medical_visitor_id" uuid NOT NULL,
    "pharma_product_id" uuid NOT NULL,
    "authorized_from" date NOT NULL,
    "authorized_to" date,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_medical_visitor_products" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."medical_visitor_specialties" (
    "id" uuid NOT NULL,
    "medical_visitor_id" uuid NOT NULL,
    "specialty_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_medical_visitor_specialties" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."medical_visitors" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "staff_id" uuid,
    "full_name" varchar NOT NULL,
    "photo_url" varchar,
    "internal_code" varchar NOT NULL,
    "position" varchar,
    "supervisor_staff_id" uuid,
    "branch_id" uuid,
    "region" varchar,
    "commercial_area" varchar,
    "assigned_zone" varchar,
    "started_on" date NOT NULL,
    "ended_on" date,
    "identity_verification_concept_id" uuid NOT NULL,
    "contract_verification_concept_id" uuid NOT NULL,
    "credential_verification_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "publicly_listed" boolean NOT NULL DEFAULT true,
    "unlinked_at" timestamptz,
    "unlink_reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_medical_visitors" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharma_cost_allocations" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "journal_transaction_id" uuid NOT NULL,
    "cost_type_concept_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "pharma_product_id" uuid,
    "project_code" varchar,
    "branch_id" uuid,
    "area" varchar,
    "medical_visitor_id" uuid,
    "campaign_code" varchar,
    "allocated_on" date NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharma_cost_allocations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharma_lab_link_events" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "staff_id" uuid,
    "medical_visitor_id" uuid,
    "subject_user_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "reason" text,
    "previous_permissions" jsonb,
    "new_permissions" jsonb,
    "revoked_session_count" integer,
    "occurred_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_pharma_lab_link_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharma_lab_notices" (
    "id" uuid NOT NULL,
    "recipient_user_id" uuid NOT NULL,
    "tenant_id" uuid,
    "template_code" varchar NOT NULL,
    "subject" varchar NOT NULL,
    "body_text" text NOT NULL,
    "related_resource_type" varchar NOT NULL,
    "related_resource_id" uuid NOT NULL,
    "is_read" boolean NOT NULL DEFAULT false,
    "read_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharma_lab_notices" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharma_lab_staff" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "staff_type_concept_id" uuid NOT NULL,
    "role_code" varchar,
    "position" varchar,
    "area" varchar,
    "branch_id" uuid,
    "work_schedule" varchar,
    "hired_on" date NOT NULL,
    "ended_on" date,
    "permissions" jsonb,
    "credential_verification_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharma_lab_staff" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharma_labs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "lab_type_concept_id" uuid NOT NULL,
    "legal_name" varchar NOT NULL,
    "trade_name" varchar,
    "tax_id" varchar,
    "logo_url" varchar,
    "description" text,
    "research_areas" jsonb,
    "contacts" jsonb,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharma_labs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharma_products" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "trade_name" varchar NOT NULL,
    "active_ingredient" varchar NOT NULL,
    "presentation" varchar,
    "concentration" varchar,
    "pharmaceutical_form" varchar,
    "administration_route" varchar,
    "authorized_indication" text,
    "manufacturer_name" varchar,
    "regulatory_status_concept_id" uuid NOT NULL,
    "sanitary_registry_number" varchar,
    "approved_on" date,
    "registry_expires_on" date,
    "authorized_countries" jsonb,
    "technical_documentation" jsonb,
    "disclosure_level_concept_id" uuid NOT NULL,
    "version_no" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharma_products" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharmacovigilance_actions" (
    "id" uuid NOT NULL,
    "pharmacovigilance_report_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "previous_status_concept_id" uuid NOT NULL,
    "new_status_concept_id" uuid NOT NULL,
    "authority_name" varchar,
    "authority_reference" varchar,
    "detail" text NOT NULL,
    "actor_user_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_pharmacovigilance_actions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."pharmacovigilance_reports" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "pharma_product_id" uuid NOT NULL,
    "case_code" varchar NOT NULL,
    "batch_number" varchar,
    "event_date" date NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "description" text NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "reporter_type_concept_id" uuid NOT NULL,
    "reporter_user_id" uuid NOT NULL,
    "reporter_tenant_id" uuid,
    "subject_pseudonym" varchar,
    "subject_age_years" integer,
    "subject_sex_concept_id" uuid,
    "received_at" timestamptz NOT NULL,
    "closed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacovigilance_reports" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."regulatory_document_access_log" (
    "id" uuid NOT NULL,
    "regulatory_document_id" uuid NOT NULL,
    "regulatory_document_version_id" uuid,
    "access_kind" varchar NOT NULL,
    "actor_user_id" uuid NOT NULL,
    "accessed_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_regulatory_document_access_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."regulatory_document_versions" (
    "id" uuid NOT NULL,
    "regulatory_document_id" uuid NOT NULL,
    "version" varchar NOT NULL,
    "storage_key" varchar NOT NULL,
    "file_name" varchar NOT NULL,
    "content_type" varchar,
    "issued_on" date,
    "expires_on" date,
    "status_concept_id" uuid NOT NULL,
    "change_reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_regulatory_document_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."regulatory_documents" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "pharma_product_id" uuid,
    "medical_visitor_id" uuid,
    "name" varchar NOT NULL,
    "document_type_concept_id" uuid NOT NULL,
    "code" varchar,
    "current_version" varchar NOT NULL,
    "issuer_name" varchar,
    "issued_on" date,
    "expires_on" date,
    "status_concept_id" uuid NOT NULL,
    "owner_staff_id" uuid,
    "disclosure_level_concept_id" uuid NOT NULL,
    "expiry_alert_days" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_regulatory_documents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_ratings" (
    "id" uuid NOT NULL,
    "visit_record_id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "punctuality" integer,
    "information_quality" integer,
    "clarity" integer,
    "relevance" integer,
    "professional_conduct" integer,
    "material_usefulness" integer,
    "overall_satisfaction" integer,
    "comment" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_visit_ratings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_record_materials" (
    "id" uuid NOT NULL,
    "visit_record_id" uuid NOT NULL,
    "informational_material_id" uuid NOT NULL,
    "material_version" varchar NOT NULL,
    "was_handed_over" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_visit_record_materials" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_records" (
    "id" uuid NOT NULL,
    "visit_request_id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "medical_visitor_id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "location" varchar,
    "modality_concept_id" uuid NOT NULL,
    "topics_discussed" text,
    "questions" text,
    "commitments" text,
    "next_action" text,
    "observations" text,
    "visitor_attendance_concept_id" uuid NOT NULL,
    "doctor_attendance_concept_id" uuid NOT NULL,
    "confirmation_concept_id" uuid NOT NULL,
    "confirmed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_visit_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_request_events" (
    "id" uuid NOT NULL,
    "visit_request_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "previous_status_concept_id" uuid NOT NULL,
    "new_status_concept_id" uuid NOT NULL,
    "proposed_start_at" timestamptz,
    "note" text,
    "actor_user_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_visit_request_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_request_topics" (
    "id" uuid NOT NULL,
    "visit_request_id" uuid NOT NULL,
    "pharma_product_id" uuid,
    "topic" varchar,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_visit_request_topics" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_requests" (
    "id" uuid NOT NULL,
    "medical_visitor_id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "doctor_tenant_id" uuid,
    "reason" text NOT NULL,
    "requested_start_at" timestamptz NOT NULL,
    "duration_minutes" integer NOT NULL,
    "time_zone" varchar NOT NULL,
    "modality_concept_id" uuid NOT NULL,
    "location" varchar,
    "attachments" jsonb,
    "observations" text,
    "status_concept_id" uuid NOT NULL,
    "proposed_start_at" timestamptz,
    "confirmed_at" timestamptz,
    "closed_at" timestamptz,
    "rescheduled_from_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_visit_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_survey_answers" (
    "id" uuid NOT NULL,
    "visit_survey_response_id" uuid NOT NULL,
    "visit_survey_question_id" uuid NOT NULL,
    "numeric_value" integer,
    "boolean_value" boolean,
    "text_value" text,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_visit_survey_answers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_survey_questions" (
    "id" uuid NOT NULL,
    "visit_survey_id" uuid NOT NULL,
    "position" integer NOT NULL,
    "prompt" text NOT NULL,
    "answer_type_concept_id" uuid NOT NULL,
    "is_required" boolean NOT NULL DEFAULT false,
    "options" jsonb,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_visit_survey_questions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_survey_responses" (
    "id" uuid NOT NULL,
    "visit_survey_id" uuid NOT NULL,
    "visit_record_id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "issued_at" timestamptz NOT NULL,
    "submitted_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_visit_survey_responses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visit_surveys" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "medical_visitor_id" uuid,
    "pharma_product_id" uuid,
    "campaign_code" varchar,
    "specialty_concept_id" uuid,
    "valid_from" date NOT NULL,
    "valid_to" date,
    "send_delay_hours" integer NOT NULL,
    "reminder_count" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_visit_surveys" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "pharma_lab"."visitor_post_submissions" (
    "id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "medical_visitor_id" uuid NOT NULL,
    "body" text NOT NULL,
    "informational_material_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "decision_rationale" text,
    "decided_by_user_id" uuid,
    "decided_at" timestamptz,
    "social_post_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_visitor_post_submissions" PRIMARY KEY ("id")
);
