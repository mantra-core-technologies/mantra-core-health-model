-- ============================================================================
-- SALUD · patch v4.2.28 (pharma_lab · módulo 69 + 8 historias en audit) sobre una BD viva
-- Fecha: 2026-09-26 · carril M7 (AG-30 / bloqueante B-8)
--
-- QUÉ CIERRA. `pharma_lab` (31 entidades) y sus 8 historias de auditoría
-- (`audit.{informational_materials,medical_visitors,pharmacovigilance_reports,
-- pharma_labs,pharma_lab_staff,pharma_products,regulatory_documents,
-- visit_requests}_history`) vivían SÓLO en el código de la API: ni diagrama ni
-- carpeta en SQL/, así que toda ruta de pharma_lab respondía 500
-- `relation "pharma_lab.…" does not exist` contra una base del pipeline.
-- Promovido por la ruta canónica: `diagram_69_pharma_lab.puml` +
-- `diagram_10_audit.puml` -> `gen_ddl.py all` -> SQL/. Este patch es el mismo DDL
-- ejecutable, idempotente (IF NOT EXISTS / duplicate_object), UNA sola pasada.
--
-- Delta esperado: +1 schema · +39 tablas (31 + 8) · +214 FK · +222 índices (PK excluida).
-- ============================================================================

BEGIN;


CREATE SCHEMA IF NOT EXISTS "pharma_lab";

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

CREATE TABLE IF NOT EXISTS "audit"."informational_materials_history" (
    "history_id" uuid NOT NULL,
    "informational_material_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_informational_materials_history" PRIMARY KEY ("history_id")
);


CREATE TABLE IF NOT EXISTS "audit"."medical_visitors_history" (
    "history_id" uuid NOT NULL,
    "medical_visitor_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_medical_visitors_history" PRIMARY KEY ("history_id")
);


CREATE TABLE IF NOT EXISTS "audit"."pharmacovigilance_reports_history" (
    "history_id" uuid NOT NULL,
    "pharmacovigilance_report_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_pharmacovigilance_reports_history" PRIMARY KEY ("history_id")
);


CREATE TABLE IF NOT EXISTS "audit"."pharma_labs_history" (
    "history_id" uuid NOT NULL,
    "pharma_lab_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_pharma_labs_history" PRIMARY KEY ("history_id")
);


CREATE TABLE IF NOT EXISTS "audit"."pharma_lab_staff_history" (
    "history_id" uuid NOT NULL,
    "pharma_lab_staff_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_pharma_lab_staff_history" PRIMARY KEY ("history_id")
);


CREATE TABLE IF NOT EXISTS "audit"."pharma_products_history" (
    "history_id" uuid NOT NULL,
    "pharma_product_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_pharma_products_history" PRIMARY KEY ("history_id")
);


CREATE TABLE IF NOT EXISTS "audit"."regulatory_documents_history" (
    "history_id" uuid NOT NULL,
    "regulatory_document_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_regulatory_documents_history" PRIMARY KEY ("history_id")
);


CREATE TABLE IF NOT EXISTS "audit"."visit_requests_history" (
    "history_id" uuid NOT NULL,
    "visit_request_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_visit_requests_history" PRIMARY KEY ("history_id")
);

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

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_blocks"
        ADD CONSTRAINT "fk_doctor_visit_blocks_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_blocks"
        ADD CONSTRAINT "fk_doctor_visit_blocks_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_blocks"
        ADD CONSTRAINT "fk_doctor_visit_blocks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_blocks"
        ADD CONSTRAINT "fk_doctor_visit_blocks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_policies"
        ADD CONSTRAINT "fk_doctor_visit_policies_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_policies"
        ADD CONSTRAINT "fk_doctor_visit_policies_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_policies"
        ADD CONSTRAINT "fk_doctor_visit_policies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_policies"
        ADD CONSTRAINT "fk_doctor_visit_policies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_policies"
        ADD CONSTRAINT "fk_doctor_visit_policies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_windows"
        ADD CONSTRAINT "fk_doctor_visit_windows_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_windows"
        ADD CONSTRAINT "fk_doctor_visit_windows_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."doctor_visit_windows"
        ADD CONSTRAINT "fk_doctor_visit_windows_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_specialty_concept_id" FOREIGN KEY ("specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_disclosure_level_concept_id" FOREIGN KEY ("disclosure_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."informational_materials"
        ADD CONSTRAINT "fk_informational_materials_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."material_approvals"
        ADD CONSTRAINT "fk_material_approvals_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."material_approvals"
        ADD CONSTRAINT "fk_material_approvals_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."material_assets"
        ADD CONSTRAINT "fk_material_assets_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."material_assets"
        ADD CONSTRAINT "fk_material_assets_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitor_products"
        ADD CONSTRAINT "fk_medical_visitor_products_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitor_specialties"
        ADD CONSTRAINT "fk_medical_visitor_specialties_specialty_concept_id" FOREIGN KEY ("specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitor_specialties"
        ADD CONSTRAINT "fk_medical_visitor_specialties_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_identity_verification_concept_id" FOREIGN KEY ("identity_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_contract_verification_concept_id" FOREIGN KEY ("contract_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_credential_verification_concept_id" FOREIGN KEY ("credential_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."medical_visitors"
        ADD CONSTRAINT "fk_medical_visitors_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: accounting.journal_transactions (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_journal_transaction_id" FOREIGN KEY ("journal_transaction_id")
        REFERENCES "accounting"."journal_transactions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_cost_type_concept_id" FOREIGN KEY ("cost_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_cost_allocations"
        ADD CONSTRAINT "fk_pharma_cost_allocations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_link_events"
        ADD CONSTRAINT "fk_pharma_lab_link_events_subject_user_id" FOREIGN KEY ("subject_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_link_events"
        ADD CONSTRAINT "fk_pharma_lab_link_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_link_events"
        ADD CONSTRAINT "fk_pharma_lab_link_events_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_notices"
        ADD CONSTRAINT "fk_pharma_lab_notices_recipient_user_id" FOREIGN KEY ("recipient_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_notices"
        ADD CONSTRAINT "fk_pharma_lab_notices_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_notices"
        ADD CONSTRAINT "fk_pharma_lab_notices_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_notices"
        ADD CONSTRAINT "fk_pharma_lab_notices_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_staff_type_concept_id" FOREIGN KEY ("staff_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_credential_verification_concept_id" FOREIGN KEY ("credential_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_lab_staff"
        ADD CONSTRAINT "fk_pharma_lab_staff_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_labs"
        ADD CONSTRAINT "fk_pharma_labs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_labs"
        ADD CONSTRAINT "fk_pharma_labs_lab_type_concept_id" FOREIGN KEY ("lab_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_labs"
        ADD CONSTRAINT "fk_pharma_labs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_labs"
        ADD CONSTRAINT "fk_pharma_labs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_labs"
        ADD CONSTRAINT "fk_pharma_labs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_products"
        ADD CONSTRAINT "fk_pharma_products_regulatory_status_concept_id" FOREIGN KEY ("regulatory_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_products"
        ADD CONSTRAINT "fk_pharma_products_disclosure_level_concept_id" FOREIGN KEY ("disclosure_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_products"
        ADD CONSTRAINT "fk_pharma_products_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharma_products"
        ADD CONSTRAINT "fk_pharma_products_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_actions"
        ADD CONSTRAINT "fk_pharmacovigilance_actions_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_actions"
        ADD CONSTRAINT "fk_pharmacovigilance_actions_previous_status_concept_id" FOREIGN KEY ("previous_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_actions"
        ADD CONSTRAINT "fk_pharmacovigilance_actions_new_status_concept_id" FOREIGN KEY ("new_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_actions"
        ADD CONSTRAINT "fk_pharmacovigilance_actions_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_actions"
        ADD CONSTRAINT "fk_pharmacovigilance_actions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_reporter_type_concept_id" FOREIGN KEY ("reporter_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_reporter_user_id" FOREIGN KEY ("reporter_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_reporter_tenant_id" FOREIGN KEY ("reporter_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_subject_sex_concept_id" FOREIGN KEY ("subject_sex_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."pharmacovigilance_reports"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_document_access_log"
        ADD CONSTRAINT "fk_regulatory_document_access_log_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_document_versions"
        ADD CONSTRAINT "fk_regulatory_document_versions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_document_versions"
        ADD CONSTRAINT "fk_regulatory_document_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_document_versions"
        ADD CONSTRAINT "fk_regulatory_document_versions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_document_type_concept_id" FOREIGN KEY ("document_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_disclosure_level_concept_id" FOREIGN KEY ("disclosure_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."regulatory_documents"
        ADD CONSTRAINT "fk_regulatory_documents_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_ratings"
        ADD CONSTRAINT "fk_visit_ratings_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_ratings"
        ADD CONSTRAINT "fk_visit_ratings_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_ratings"
        ADD CONSTRAINT "fk_visit_ratings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_ratings"
        ADD CONSTRAINT "fk_visit_ratings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_record_materials"
        ADD CONSTRAINT "fk_visit_record_materials_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_visitor_attendance_concept_id" FOREIGN KEY ("visitor_attendance_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_doctor_attendance_concept_id" FOREIGN KEY ("doctor_attendance_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_confirmation_concept_id" FOREIGN KEY ("confirmation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_records"
        ADD CONSTRAINT "fk_visit_records_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_events"
        ADD CONSTRAINT "fk_visit_request_events_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_events"
        ADD CONSTRAINT "fk_visit_request_events_previous_status_concept_id" FOREIGN KEY ("previous_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_events"
        ADD CONSTRAINT "fk_visit_request_events_new_status_concept_id" FOREIGN KEY ("new_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_events"
        ADD CONSTRAINT "fk_visit_request_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_events"
        ADD CONSTRAINT "fk_visit_request_events_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_request_topics"
        ADD CONSTRAINT "fk_visit_request_topics_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_doctor_tenant_id" FOREIGN KEY ("doctor_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_requests"
        ADD CONSTRAINT "fk_visit_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_answers"
        ADD CONSTRAINT "fk_visit_survey_answers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_questions"
        ADD CONSTRAINT "fk_visit_survey_questions_answer_type_concept_id" FOREIGN KEY ("answer_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_questions"
        ADD CONSTRAINT "fk_visit_survey_questions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_responses"
        ADD CONSTRAINT "fk_visit_survey_responses_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_responses"
        ADD CONSTRAINT "fk_visit_survey_responses_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_responses"
        ADD CONSTRAINT "fk_visit_survey_responses_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_survey_responses"
        ADD CONSTRAINT "fk_visit_survey_responses_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_surveys"
        ADD CONSTRAINT "fk_visit_surveys_specialty_concept_id" FOREIGN KEY ("specialty_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_surveys"
        ADD CONSTRAINT "fk_visit_surveys_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_surveys"
        ADD CONSTRAINT "fk_visit_surveys_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visit_surveys"
        ADD CONSTRAINT "fk_visit_surveys_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: community.social_posts (requiere schema community)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_social_post_id" FOREIGN KEY ("social_post_id")
        REFERENCES "community"."social_posts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "pharma_lab"."visitor_post_submissions"
        ADD CONSTRAINT "fk_visitor_post_submissions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.informational_materials (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."informational_materials_history"
        ADD CONSTRAINT "fk_informational_materials_history_informational_material_id" FOREIGN KEY ("informational_material_id")
        REFERENCES "pharma_lab"."informational_materials" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."informational_materials_history"
        ADD CONSTRAINT "fk_informational_materials_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."informational_materials_history"
        ADD CONSTRAINT "fk_informational_materials_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."informational_materials_history"
        ADD CONSTRAINT "fk_informational_materials_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.medical_visitors (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."medical_visitors_history"
        ADD CONSTRAINT "fk_medical_visitors_history_medical_visitor_id" FOREIGN KEY ("medical_visitor_id")
        REFERENCES "pharma_lab"."medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."medical_visitors_history"
        ADD CONSTRAINT "fk_medical_visitors_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."medical_visitors_history"
        ADD CONSTRAINT "fk_medical_visitors_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."medical_visitors_history"
        ADD CONSTRAINT "fk_medical_visitors_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.pharmacovigilance_reports (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacovigilance_reports_history"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_history_pharmacovigilance_696f10eb" FOREIGN KEY ("pharmacovigilance_report_id")
        REFERENCES "pharma_lab"."pharmacovigilance_reports" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacovigilance_reports_history"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacovigilance_reports_history"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharmacovigilance_reports_history"
        ADD CONSTRAINT "fk_pharmacovigilance_reports_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.pharma_labs (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_labs_history"
        ADD CONSTRAINT "fk_pharma_labs_history_pharma_lab_id" FOREIGN KEY ("pharma_lab_id")
        REFERENCES "pharma_lab"."pharma_labs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_labs_history"
        ADD CONSTRAINT "fk_pharma_labs_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_labs_history"
        ADD CONSTRAINT "fk_pharma_labs_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_labs_history"
        ADD CONSTRAINT "fk_pharma_labs_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.pharma_lab_staff (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_lab_staff_history"
        ADD CONSTRAINT "fk_pharma_lab_staff_history_pharma_lab_staff_id" FOREIGN KEY ("pharma_lab_staff_id")
        REFERENCES "pharma_lab"."pharma_lab_staff" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_lab_staff_history"
        ADD CONSTRAINT "fk_pharma_lab_staff_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_lab_staff_history"
        ADD CONSTRAINT "fk_pharma_lab_staff_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_lab_staff_history"
        ADD CONSTRAINT "fk_pharma_lab_staff_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.pharma_products (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_products_history"
        ADD CONSTRAINT "fk_pharma_products_history_pharma_product_id" FOREIGN KEY ("pharma_product_id")
        REFERENCES "pharma_lab"."pharma_products" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_products_history"
        ADD CONSTRAINT "fk_pharma_products_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_products_history"
        ADD CONSTRAINT "fk_pharma_products_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."pharma_products_history"
        ADD CONSTRAINT "fk_pharma_products_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.regulatory_documents (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."regulatory_documents_history"
        ADD CONSTRAINT "fk_regulatory_documents_history_regulatory_document_id" FOREIGN KEY ("regulatory_document_id")
        REFERENCES "pharma_lab"."regulatory_documents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."regulatory_documents_history"
        ADD CONSTRAINT "fk_regulatory_documents_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."regulatory_documents_history"
        ADD CONSTRAINT "fk_regulatory_documents_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."regulatory_documents_history"
        ADD CONSTRAINT "fk_regulatory_documents_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: pharma_lab.visit_requests (requiere schema pharma_lab)
DO $$ BEGIN
    ALTER TABLE "audit"."visit_requests_history"
        ADD CONSTRAINT "fk_visit_requests_history_visit_request_id" FOREIGN KEY ("visit_request_id")
        REFERENCES "pharma_lab"."visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."visit_requests_history"
        ADD CONSTRAINT "fk_visit_requests_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."visit_requests_history"
        ADD CONSTRAINT "fk_visit_requests_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."visit_requests_history"
        ADD CONSTRAINT "fk_visit_requests_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

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

CREATE INDEX IF NOT EXISTS "ix_informational_materials_history_informational_material_id" ON "audit"."informational_materials_history" ("informational_material_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_history_operation_concept_id" ON "audit"."informational_materials_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_history_changed_by_user_id" ON "audit"."informational_materials_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_informational_materials_history_change_reason_concept_id" ON "audit"."informational_materials_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_informational_materials_history_recorded_at" ON "audit"."informational_materials_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_history_medical_visitor_id" ON "audit"."medical_visitors_history" ("medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_history_operation_concept_id" ON "audit"."medical_visitors_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_history_changed_by_user_id" ON "audit"."medical_visitors_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_medical_visitors_history_change_reason_concept_id" ON "audit"."medical_visitors_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_medical_visitors_history_recorded_at" ON "audit"."medical_visitors_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_history_pharmacovigilance_60e5dded" ON "audit"."pharmacovigilance_reports_history" ("pharmacovigilance_report_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_history_operation_concept_id" ON "audit"."pharmacovigilance_reports_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_history_changed_by_user_id" ON "audit"."pharmacovigilance_reports_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharmacovigilance_reports_history_change_reason_concept_id" ON "audit"."pharmacovigilance_reports_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_pharmacovigilance_reports_history_recorded_at" ON "audit"."pharmacovigilance_reports_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_history_pharma_lab_id" ON "audit"."pharma_labs_history" ("pharma_lab_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_history_operation_concept_id" ON "audit"."pharma_labs_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_history_changed_by_user_id" ON "audit"."pharma_labs_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_labs_history_change_reason_concept_id" ON "audit"."pharma_labs_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_pharma_labs_history_recorded_at" ON "audit"."pharma_labs_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_history_pharma_lab_staff_id" ON "audit"."pharma_lab_staff_history" ("pharma_lab_staff_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_history_operation_concept_id" ON "audit"."pharma_lab_staff_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_history_changed_by_user_id" ON "audit"."pharma_lab_staff_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_lab_staff_history_change_reason_concept_id" ON "audit"."pharma_lab_staff_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_pharma_lab_staff_history_recorded_at" ON "audit"."pharma_lab_staff_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_pharma_products_history_pharma_product_id" ON "audit"."pharma_products_history" ("pharma_product_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_history_operation_concept_id" ON "audit"."pharma_products_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_history_changed_by_user_id" ON "audit"."pharma_products_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pharma_products_history_change_reason_concept_id" ON "audit"."pharma_products_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_pharma_products_history_recorded_at" ON "audit"."pharma_products_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_history_regulatory_document_id" ON "audit"."regulatory_documents_history" ("regulatory_document_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_history_operation_concept_id" ON "audit"."regulatory_documents_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_history_changed_by_user_id" ON "audit"."regulatory_documents_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_regulatory_documents_history_change_reason_concept_id" ON "audit"."regulatory_documents_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_regulatory_documents_history_recorded_at" ON "audit"."regulatory_documents_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_visit_requests_history_visit_request_id" ON "audit"."visit_requests_history" ("visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_history_operation_concept_id" ON "audit"."visit_requests_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_history_changed_by_user_id" ON "audit"."visit_requests_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_visit_requests_history_change_reason_concept_id" ON "audit"."visit_requests_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_visit_requests_history_recorded_at" ON "audit"."visit_requests_history" USING brin ("recorded_at") WITH (pages_per_range=128);

COMMIT;
