-- SALUD v4.0.10 · módulo 65 · schema surveys
-- Generado de diagram_65_surveys.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "surveys"."survey_templates" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "owner_practitioner_id" uuid NOT NULL,
    "title" text NOT NULL,
    "description" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_survey_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "surveys"."survey_versions" (
    "id" uuid NOT NULL,
    "survey_template_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "publication_status_concept_id" uuid NOT NULL,
    "effective_from" timestamptz,
    "effective_to" timestamptz,
    "response_window_days" integer NOT NULL,
    "published_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_survey_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "surveys"."survey_questions" (
    "id" uuid NOT NULL,
    "survey_version_id" uuid NOT NULL,
    "position" integer NOT NULL,
    "question_text" text NOT NULL,
    "answer_type_concept_id" uuid NOT NULL,
    "required" boolean NOT NULL,
    "options" jsonb,
    "scale_min" integer,
    "scale_max" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_survey_questions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "surveys"."survey_assignments" (
    "id" uuid NOT NULL,
    "survey_version_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_survey_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "surveys"."survey_invitations" (
    "id" uuid NOT NULL,
    "survey_version_id" uuid NOT NULL,
    "survey_assignment_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "appointment_booking_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "issued_at" timestamptz NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "answered_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_survey_invitations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "surveys"."survey_responses" (
    "id" uuid NOT NULL,
    "survey_invitation_id" uuid NOT NULL,
    "survey_version_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "submitted_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_survey_responses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "surveys"."survey_answers" (
    "id" uuid NOT NULL,
    "survey_response_id" uuid NOT NULL,
    "survey_question_id" uuid NOT NULL,
    "value_text" text,
    "value_number" integer,
    "value_boolean" boolean,
    "value_choices" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_survey_answers" PRIMARY KEY ("id")
);
