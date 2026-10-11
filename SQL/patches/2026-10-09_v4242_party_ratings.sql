-- ============================================================================
-- SALUD · patch v4.2.42 (community · calificación en malla) sobre BD viva
-- Fecha: 2026-10-09 · pedido del propietario del 2026-10-08
-- Idempotente (IF NOT EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py ya emite esta tabla, sus índices y sus FKs en
-- SQL/19_community/ desde que el .puml la declara, así que en un rebuild desde
-- cero este patch NO hace falta. Existe para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las
-- sentencias se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. Médico, paciente y organización se califican entre sí con
-- estrellas 1–5 (community.party_ratings). Respaldo: atención terminada cuando
-- hay un paciente de por medio; vínculo de trabajo entre médico y organización.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +1 · FKs +11 · índices +13 (12 declarados + PK)
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "community"."party_ratings" (
    "id" uuid NOT NULL,
    "reviewer_patient_profile_id" uuid,
    "reviewer_practitioner_profile_id" uuid,
    "reviewer_practice_id" uuid,
    "target_patient_profile_id" uuid,
    "target_practitioner_profile_id" uuid,
    "target_practice_id" uuid,
    "verified_encounter_id" uuid,
    "verified_role_assignment_id" uuid,
    "overall_rating" smallint NOT NULL,
    "comment_text" text,
    "moderation_status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_party_ratings" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "ix_party_ratings_reviewer_patient_profile_id" ON "community"."party_ratings" ("reviewer_patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_reviewer_practitioner_profile_id" ON "community"."party_ratings" ("reviewer_practitioner_profile_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_reviewer_practice_id" ON "community"."party_ratings" ("reviewer_practice_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_target_patient_profile_id" ON "community"."party_ratings" ("target_patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_target_practitioner_profile_id" ON "community"."party_ratings" ("target_practitioner_profile_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_target_practice_id" ON "community"."party_ratings" ("target_practice_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_verified_encounter_id" ON "community"."party_ratings" ("verified_encounter_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_verified_role_assignment_id" ON "community"."party_ratings" ("verified_role_assignment_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_moderation_status_concept_id" ON "community"."party_ratings" ("moderation_status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_created_by_user_id" ON "community"."party_ratings" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_party_ratings_updated_by_user_id" ON "community"."party_ratings" ("updated_by_user_id");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_party_ratings_basis" ON "community"."party_ratings" (coalesce(reviewer_patient_profile_id, reviewer_practitioner_profile_id, reviewer_practice_id), coalesce(target_patient_profile_id, target_practitioner_profile_id, target_practice_id), coalesce(verified_encounter_id, verified_role_assignment_id));

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_reviewer_patient_profile_id" FOREIGN KEY ("reviewer_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_reviewer_practitioner_profile_id" FOREIGN KEY ("reviewer_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_reviewer_practice_id" FOREIGN KEY ("reviewer_practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_target_patient_profile_id" FOREIGN KEY ("target_patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_target_practitioner_profile_id" FOREIGN KEY ("target_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_target_practice_id" FOREIGN KEY ("target_practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_verified_encounter_id" FOREIGN KEY ("verified_encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_verified_role_assignment_id" FOREIGN KEY ("verified_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_moderation_status_concept_id" FOREIGN KEY ("moderation_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."party_ratings"
        ADD CONSTRAINT "fk_party_ratings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
