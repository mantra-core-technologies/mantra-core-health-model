-- SALUD v4.0.10 · módulo 47 · schema education
-- Generado de diagram_47_education.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "education"."courses" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "course_type_concept_id" uuid NOT NULL,
    "specialty_concept_id" uuid,
    "level_concept_id" uuid,
    "language_concept_id" uuid,
    "cover_file_id" uuid,
    "is_accredited" boolean,
    "cme_credit_hours" numeric,
    "accrediting_body_concept_id" uuid,
    "price" numeric,
    "currency_concept_id" uuid,
    "duration_minutes" integer,
    "current_version" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_courses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."course_versions" (
    "id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "version" integer NOT NULL,
    "changelog" text,
    "status_concept_id" uuid NOT NULL,
    "published_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_course_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."course_modules" (
    "id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "ordinal" integer,
    "description" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_course_modules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."lessons" (
    "id" uuid NOT NULL,
    "course_module_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "content_type_concept_id" uuid NOT NULL,
    "body_richtext_json" jsonb,
    "media_file_id" uuid,
    "external_url" text,
    "duration_minutes" integer,
    "ordinal" integer,
    "is_preview" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lessons" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."instructors" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "practitioner_profile_id" uuid,
    "user_id" uuid,
    "display_name" varchar NOT NULL,
    "bio" text,
    "credentials_text" varchar,
    "photo_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_instructors" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."course_instructors" (
    "id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "instructor_id" uuid NOT NULL,
    "role_concept_id" uuid NOT NULL,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_course_instructors" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."course_cohorts" (
    "id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "delivery_mode_concept_id" uuid NOT NULL,
    "start_date" date,
    "end_date" date,
    "capacity" integer,
    "enrolled_count" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_course_cohorts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."enrollments" (
    "id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "cohort_id" uuid,
    "learner_type_concept_id" uuid NOT NULL,
    "learner_ref_id" uuid NOT NULL,
    "enrollment_source_concept_id" uuid NOT NULL,
    "payment_intent_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "progress_percent" numeric,
    "enrolled_at" timestamptz,
    "completed_at" timestamptz,
    "expires_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_enrollments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."lesson_progress" (
    "id" uuid NOT NULL,
    "enrollment_id" uuid NOT NULL,
    "lesson_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "seconds_watched" integer,
    "completion_percent" numeric,
    "completed_at" timestamptz,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_lesson_progress" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."assessments" (
    "id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "course_module_id" uuid,
    "title" varchar NOT NULL,
    "assessment_type_concept_id" uuid NOT NULL,
    "passing_score" numeric,
    "max_attempts" integer,
    "time_limit_minutes" integer,
    "is_graded" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_assessments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."assessment_questions" (
    "id" uuid NOT NULL,
    "assessment_id" uuid NOT NULL,
    "question_type_concept_id" uuid NOT NULL,
    "prompt_text" text NOT NULL,
    "options_json" jsonb,
    "correct_answer_json" jsonb,
    "points" numeric,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_assessment_questions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."assessment_attempts" (
    "id" uuid NOT NULL,
    "assessment_id" uuid NOT NULL,
    "enrollment_id" uuid NOT NULL,
    "attempt_number" integer NOT NULL,
    "score" numeric,
    "passed" boolean,
    "responses_json" jsonb,
    "started_at" timestamptz,
    "submitted_at" timestamptz,
    "graded_by_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_assessment_attempts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."certificates" (
    "id" uuid NOT NULL,
    "enrollment_id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "certificate_number" varchar NOT NULL,
    "learner_ref_id" uuid,
    "cme_credits_awarded" numeric,
    "issued_at" timestamptz,
    "expires_at" timestamptz,
    "verification_code" varchar,
    "file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_certificates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."cme_credit_records" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "certificate_id" uuid,
    "credit_hours" numeric NOT NULL,
    "accrediting_body_concept_id" uuid NOT NULL,
    "specialty_concept_id" uuid,
    "jurisdiction_concept_id" uuid,
    "awarded_on" date,
    "period_year" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_cme_credit_records" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "education"."course_reviews" (
    "id" uuid NOT NULL,
    "course_id" uuid NOT NULL,
    "reviewer_ref_id" uuid NOT NULL,
    "rating" integer NOT NULL,
    "review_text" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_course_reviews" PRIMARY KEY ("id")
);
