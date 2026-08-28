-- ============================================================================
-- SALUD · patch v4.1.1 (schema surveys · módulo 65) sobre una BD viva
-- Fecha: 2026-08-18
-- Idempotente (CREATE SCHEMA/TABLE/INDEX IF NOT EXISTS · duplicate_object en FK)
--
-- Contexto: gen_ddl.py ya emite estas 7 tablas en SQL/65_surveys/ desde que el
-- .puml del módulo 65 las declara, así que en un rebuild desde cero este patch
-- NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Qué cierra: el bloqueante B-7. El carril 10 (2026-08-15) trajo las 7 entidades
-- de `surveys` —templates, versions, questions, assignments, invitations,
-- responses, answers— con sus repositorios, servicios, DTOs y endpoints, pero
-- sin .puml y sin una línea en SQL/. Con ORM_SCHEMA_SYNC=off las tablas nunca
-- nacían y TODO endpoint del módulo moría con
-- `relation "surveys.*" does not exist`. El primero que lo vio un usuario fue
-- F-14: «Mis cuestionarios» devolvía 500 sin haber hecho nada. Mientras tanto
-- `listInvitationsOf` degrada a `200 []` con un TODO(F-14) que este patch
-- habilita a quitar.
--
-- Es la misma familia que audio_assets (módulo 64): un módulo que vivía sólo en
-- el código. El .puml TRANSCRIBE lo que las entidades ya declaraban —columna,
-- tipo y obligatoriedad— y no agrega reglas: el índice único de idempotencia que
-- el README del módulo afirma, y el CHECK de las columnas value_*, quedan como
-- decisión de producto anotada en el diagrama (REC 65.3 y 65.4), no inventados
-- acá.
--
-- Este archivo es la salida de gen_ddl.py 65, no DDL escrito a mano.
-- ============================================================================


-- ---------------------------------------------------------------- 01_schema

CREATE SCHEMA IF NOT EXISTS "surveys";

-- ---------------------------------------------------------------- 02_tables


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

-- ---------------------------------------------------------------- 04_indexes


CREATE INDEX IF NOT EXISTS "ix_survey_templates_owner" ON "surveys"."survey_templates" ("owner_practitioner_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_survey_templates_tenant_id" ON "surveys"."survey_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_survey_versions_template_number" ON "surveys"."survey_versions" ("survey_template_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_survey_questions_version_position" ON "surveys"."survey_questions" ("survey_version_id", "position");

CREATE INDEX IF NOT EXISTS "ix_survey_assignments_tenant_target" ON "surveys"."survey_assignments" ("tenant_id", "target_id", "active");

CREATE INDEX IF NOT EXISTS "ix_survey_assignments_version" ON "surveys"."survey_assignments" ("survey_version_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_patient_issued" ON "surveys"."survey_invitations" ("patient_profile_id", "issued_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_booking" ON "surveys"."survey_invitations" ("appointment_booking_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_version" ON "surveys"."survey_invitations" ("survey_version_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_assignment" ON "surveys"."survey_invitations" ("survey_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_tenant_id" ON "surveys"."survey_invitations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_survey_responses_invitation" ON "surveys"."survey_responses" ("survey_invitation_id");

CREATE INDEX IF NOT EXISTS "ix_survey_responses_patient_submitted" ON "surveys"."survey_responses" ("patient_profile_id", "submitted_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_survey_responses_version" ON "surveys"."survey_responses" ("survey_version_id");

CREATE INDEX IF NOT EXISTS "ix_survey_responses_tenant_id" ON "surveys"."survey_responses" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_survey_answers_response" ON "surveys"."survey_answers" ("survey_response_id");

CREATE INDEX IF NOT EXISTS "ix_survey_answers_question" ON "surveys"."survey_answers" ("survey_question_id");

-- ---------------------------------------------------------------- 03_fk_intra


DO $$ BEGIN
    ALTER TABLE "surveys"."survey_versions"
        ADD CONSTRAINT "fk_survey_versions_survey_template_id" FOREIGN KEY ("survey_template_id")
        REFERENCES "surveys"."survey_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_questions"
        ADD CONSTRAINT "fk_survey_questions_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_assignments"
        ADD CONSTRAINT "fk_survey_assignments_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_survey_assignment_id" FOREIGN KEY ("survey_assignment_id")
        REFERENCES "surveys"."survey_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_survey_invitation_id" FOREIGN KEY ("survey_invitation_id")
        REFERENCES "surveys"."survey_invitations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_answers"
        ADD CONSTRAINT "fk_survey_answers_survey_response_id" FOREIGN KEY ("survey_response_id")
        REFERENCES "surveys"."survey_responses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_answers"
        ADD CONSTRAINT "fk_survey_answers_survey_question_id" FOREIGN KEY ("survey_question_id")
        REFERENCES "surveys"."survey_questions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ---------------------------------------------------------------- 90_fk_deferred


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_templates"
        ADD CONSTRAINT "fk_survey_templates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_templates"
        ADD CONSTRAINT "fk_survey_templates_owner_practitioner_id" FOREIGN KEY ("owner_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_templates"
        ADD CONSTRAINT "fk_survey_templates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_templates"
        ADD CONSTRAINT "fk_survey_templates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_templates"
        ADD CONSTRAINT "fk_survey_templates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_versions"
        ADD CONSTRAINT "fk_survey_versions_publication_status_concept_id" FOREIGN KEY ("publication_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_versions"
        ADD CONSTRAINT "fk_survey_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_versions"
        ADD CONSTRAINT "fk_survey_versions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_questions"
        ADD CONSTRAINT "fk_survey_questions_answer_type_concept_id" FOREIGN KEY ("answer_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_questions"
        ADD CONSTRAINT "fk_survey_questions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_questions"
        ADD CONSTRAINT "fk_survey_questions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_assignments"
        ADD CONSTRAINT "fk_survey_assignments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_assignments"
        ADD CONSTRAINT "fk_survey_assignments_target_type_concept_id" FOREIGN KEY ("target_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_assignments"
        ADD CONSTRAINT "fk_survey_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_assignments"
        ADD CONSTRAINT "fk_survey_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: scheduling.appointment_bookings (requiere schema scheduling)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_appointment_booking_id" FOREIGN KEY ("appointment_booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_answers"
        ADD CONSTRAINT "fk_survey_answers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_answers"
        ADD CONSTRAINT "fk_survey_answers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)
