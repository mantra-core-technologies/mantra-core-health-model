-- ============================================================================
-- SALUD · patch (diagnostic_units · visitadores del laboratorio médico) sobre BD viva
-- Fecha: 2026-10-24 · issue #56 LAB-VIS-001..014 / LAB-RSL-008
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. Cinco tablas nuevas en diagnostic_units que replican el patrón de pharma_lab para
-- una unidad diagnóstica: unit_medical_visitors, unit_visit_requests, unit_visit_request_events,
-- unit_visit_records y unit_visit_ratings. Ninguna columna existente cambia. Las políticas y
-- ventanas de visita del doctor (pharma_lab.doctor_visit_policies / doctor_visit_windows) se
-- reusan sin copia. Ninguna de las cinco apunta a paciente, encuentro, receta ni resultado
-- (LAB-VIS-012 / LAB-RSL-008). Solo tablas nuevas: no hay nada que backfillear.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +5 · columnas +0 · NOT NULL quitados 0 · FKs +40 · índices +40 (-0) · constraints +0
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "diagnostic_units"."unit_medical_visitors" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "full_name" varchar NOT NULL,
    "photo_url" varchar,
    "internal_code" varchar NOT NULL,
    "position" varchar,
    "supervisor_user_id" uuid,
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
    CONSTRAINT "pk_unit_medical_visitors" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_supervisor_user_id" FOREIGN KEY ("supervisor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.branches (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_branch_id" FOREIGN KEY ("branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_identity_verification_concept_id" FOREIGN KEY ("identity_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_contract_verification_concept_id" FOREIGN KEY ("contract_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_credential_verification_concept_id" FOREIGN KEY ("credential_verification_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_medical_visitors"
        ADD CONSTRAINT "fk_unit_medical_visitors_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE UNIQUE INDEX IF NOT EXISTS "ux_unit_medical_visitors_user_id" ON "diagnostic_units"."unit_medical_visitors" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_diagnostic_unit_id" ON "diagnostic_units"."unit_medical_visitors" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_supervisor_user_id" ON "diagnostic_units"."unit_medical_visitors" ("supervisor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_branch_id" ON "diagnostic_units"."unit_medical_visitors" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_identity_verification_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("identity_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_contract_verification_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("contract_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_credential_verification_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("credential_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_status_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_created_by_user_id" ON "diagnostic_units"."unit_medical_visitors" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_updated_by_user_id" ON "diagnostic_units"."unit_medical_visitors" ("updated_by_user_id");

CREATE TABLE IF NOT EXISTS "diagnostic_units"."unit_visit_requests" (
    "id" uuid NOT NULL,
    "unit_medical_visitor_id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
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
    CONSTRAINT "pk_unit_visit_requests" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_unit_medical_visitor_id" FOREIGN KEY ("unit_medical_visitor_id")
        REFERENCES "diagnostic_units"."unit_medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_rescheduled_from_id" FOREIGN KEY ("rescheduled_from_id")
        REFERENCES "diagnostic_units"."unit_visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_doctor_tenant_id" FOREIGN KEY ("doctor_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_requests"
        ADD CONSTRAINT "fk_unit_visit_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_unit_medical_visitor_id" ON "diagnostic_units"."unit_visit_requests" ("unit_medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_diagnostic_unit_id" ON "diagnostic_units"."unit_visit_requests" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_doctor_user_id" ON "diagnostic_units"."unit_visit_requests" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_doctor_tenant_id" ON "diagnostic_units"."unit_visit_requests" ("doctor_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_modality_concept_id" ON "diagnostic_units"."unit_visit_requests" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_status_concept_id" ON "diagnostic_units"."unit_visit_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_rescheduled_from_id" ON "diagnostic_units"."unit_visit_requests" ("rescheduled_from_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_created_by_user_id" ON "diagnostic_units"."unit_visit_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_updated_by_user_id" ON "diagnostic_units"."unit_visit_requests" ("updated_by_user_id");

CREATE TABLE IF NOT EXISTS "diagnostic_units"."unit_visit_request_events" (
    "id" uuid NOT NULL,
    "unit_visit_request_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "previous_status_concept_id" uuid NOT NULL,
    "new_status_concept_id" uuid NOT NULL,
    "proposed_start_at" timestamptz,
    "note" text,
    "actor_user_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_unit_visit_request_events" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_request_events"
        ADD CONSTRAINT "fk_unit_visit_request_events_unit_visit_request_id" FOREIGN KEY ("unit_visit_request_id")
        REFERENCES "diagnostic_units"."unit_visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_request_events"
        ADD CONSTRAINT "fk_unit_visit_request_events_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_request_events"
        ADD CONSTRAINT "fk_unit_visit_request_events_previous_status_concept_id" FOREIGN KEY ("previous_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_request_events"
        ADD CONSTRAINT "fk_unit_visit_request_events_new_status_concept_id" FOREIGN KEY ("new_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_request_events"
        ADD CONSTRAINT "fk_unit_visit_request_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_request_events"
        ADD CONSTRAINT "fk_unit_visit_request_events_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_unit_visit_request_id" ON "diagnostic_units"."unit_visit_request_events" ("unit_visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_action_concept_id" ON "diagnostic_units"."unit_visit_request_events" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_previous_status_concept_id" ON "diagnostic_units"."unit_visit_request_events" ("previous_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_new_status_concept_id" ON "diagnostic_units"."unit_visit_request_events" ("new_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_actor_user_id" ON "diagnostic_units"."unit_visit_request_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_created_by_user_id" ON "diagnostic_units"."unit_visit_request_events" ("created_by_user_id");

CREATE TABLE IF NOT EXISTS "diagnostic_units"."unit_visit_records" (
    "id" uuid NOT NULL,
    "unit_visit_request_id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "unit_medical_visitor_id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
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
    CONSTRAINT "pk_unit_visit_records" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_unit_visit_request_id" FOREIGN KEY ("unit_visit_request_id")
        REFERENCES "diagnostic_units"."unit_visit_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_unit_medical_visitor_id" FOREIGN KEY ("unit_medical_visitor_id")
        REFERENCES "diagnostic_units"."unit_medical_visitors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_diagnostic_unit_id" FOREIGN KEY ("diagnostic_unit_id")
        REFERENCES "diagnostic_units"."diagnostic_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_modality_concept_id" FOREIGN KEY ("modality_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_visitor_attendance_concept_id" FOREIGN KEY ("visitor_attendance_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_doctor_attendance_concept_id" FOREIGN KEY ("doctor_attendance_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_confirmation_concept_id" FOREIGN KEY ("confirmation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_records"
        ADD CONSTRAINT "fk_unit_visit_records_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE UNIQUE INDEX IF NOT EXISTS "ux_unit_visit_records_unit_visit_request_id" ON "diagnostic_units"."unit_visit_records" ("unit_visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_doctor_user_id" ON "diagnostic_units"."unit_visit_records" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_unit_medical_visitor_id" ON "diagnostic_units"."unit_visit_records" ("unit_medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_diagnostic_unit_id" ON "diagnostic_units"."unit_visit_records" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_modality_concept_id" ON "diagnostic_units"."unit_visit_records" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_visitor_attendance_concept_id" ON "diagnostic_units"."unit_visit_records" ("visitor_attendance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_doctor_attendance_concept_id" ON "diagnostic_units"."unit_visit_records" ("doctor_attendance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_confirmation_concept_id" ON "diagnostic_units"."unit_visit_records" ("confirmation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_created_by_user_id" ON "diagnostic_units"."unit_visit_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_updated_by_user_id" ON "diagnostic_units"."unit_visit_records" ("updated_by_user_id");

CREATE TABLE IF NOT EXISTS "diagnostic_units"."unit_visit_ratings" (
    "id" uuid NOT NULL,
    "unit_visit_record_id" uuid NOT NULL,
    "doctor_user_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "punctuality" integer,
    "information_quality" integer,
    "clarity" integer,
    "relevance" integer,
    "professional_conduct" integer,
    "overall_satisfaction" integer,
    "comment" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_unit_visit_ratings" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_ratings"
        ADD CONSTRAINT "fk_unit_visit_ratings_unit_visit_record_id" FOREIGN KEY ("unit_visit_record_id")
        REFERENCES "diagnostic_units"."unit_visit_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_ratings"
        ADD CONSTRAINT "fk_unit_visit_ratings_doctor_user_id" FOREIGN KEY ("doctor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_ratings"
        ADD CONSTRAINT "fk_unit_visit_ratings_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_ratings"
        ADD CONSTRAINT "fk_unit_visit_ratings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "diagnostic_units"."unit_visit_ratings"
        ADD CONSTRAINT "fk_unit_visit_ratings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_unit_visit_record_id" ON "diagnostic_units"."unit_visit_ratings" ("unit_visit_record_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_doctor_user_id" ON "diagnostic_units"."unit_visit_ratings" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_kind_concept_id" ON "diagnostic_units"."unit_visit_ratings" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_created_by_user_id" ON "diagnostic_units"."unit_visit_ratings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_updated_by_user_id" ON "diagnostic_units"."unit_visit_ratings" ("updated_by_user_id");

COMMIT;
