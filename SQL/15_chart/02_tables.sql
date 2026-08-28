-- SALUD v4.0.10 · módulo 15 · schema chart
-- Generado de diagram_15_chart.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "chart"."clinical_note_headers" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "note_type_concept_id" uuid NOT NULL,
    "lifecycle_status_concept_id" uuid NOT NULL,
    "current_version_id" uuid,
    "current_released_version_id" uuid,
    "patient_release_status_concept_id" uuid,
    "confidentiality_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_clinical_note_headers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."clinical_note_versions" (
    "id" uuid NOT NULL,
    "clinical_note_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "author_profile_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "chief_complaint_text" text,
    "subjective_text" text,
    "objective_text" text,
    "assessment_text" text,
    "plan_text" text,
    "supersedes_version_id" uuid,
    "amendment_reason_concept_id" uuid,
    "amendment_reason_text" text,
    "signed_by_profile_id" uuid,
    "signed_at" timestamptz,
    "content_hash" varchar,
    "release_eligibility_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_clinical_note_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."clinical_note_signatures" (
    "id" uuid NOT NULL,
    "clinical_note_version_id" uuid NOT NULL,
    "signer_profile_id" uuid NOT NULL,
    "signature_type_concept_id" uuid NOT NULL,
    "signature_value_encrypted" text,
    "certificate_thumbprint" varchar,
    "signed_content_hash" varchar,
    "signed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_clinical_note_signatures" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."note_release_events" (
    "id" uuid NOT NULL,
    "clinical_note_version_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "resulting_visibility_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "policy_version" varchar,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_note_release_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."physical_exam_findings" (
    "id" uuid NOT NULL,
    "clinical_note_version_id" uuid NOT NULL,
    "body_system_concept_id" uuid NOT NULL,
    "finding_concept_id" uuid,
    "is_normal" boolean,
    "finding_text" text,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_physical_exam_findings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."care_plans" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "condition_id" uuid,
    "encounter_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "intent_concept_id" uuid,
    "goal_text" text,
    "start_date" date,
    "end_date" date,
    "author_profile_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."care_plan_activities" (
    "id" uuid NOT NULL,
    "care_plan_id" uuid NOT NULL,
    "activity_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "scheduled_at" timestamptz,
    "detail_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_plan_activities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."document_records" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "encounter_id" uuid,
    "category_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "source_concept_id" uuid,
    "document_date" date,
    "author_text" varchar,
    "is_external" boolean,
    "status_concept_id" uuid NOT NULL,
    "confidentiality_concept_id" uuid,
    "patient_visibility_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_document_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."document_record_files" (
    "id" uuid NOT NULL,
    "document_record_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "content_role_concept_id" uuid NOT NULL,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_document_record_files" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."specialty_chart_templates" (
    "id" uuid NOT NULL,
    "specialty_concept_id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "section_id" uuid,
    "version" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_specialty_chart_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "chart"."chart_template_assignments" (
    "id" uuid NOT NULL,
    "template_id" uuid NOT NULL,
    "practice_id" uuid,
    "practitioner_profile_id" uuid,
    "is_default" boolean NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_chart_template_assignments" PRIMARY KEY ("id")
);
