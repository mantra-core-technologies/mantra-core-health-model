-- ============================================================================
-- SALUD · patch v4.2.64 (profiles · médico de cabecera) sobre BD viva
-- Fecha: 2026-10-28
-- Idempotente (CREATE TABLE / INDEX IF NOT EXISTS, FKs con duplicate_object).
-- UNA sola pasada. Sin backfill — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite esta tabla, sus FKs y sus índices en
-- SQL/05_profiles/ desde que el .puml la declara (diagram_05_profiles.puml,
-- v4.2.64), así que en un rebuild desde cero este patch NO hace falta. Existe
-- para una base ya aplicada y poblada. gen_apply.py no escanea SQL/patches/.
--
-- QUÉ AGREGA. Pedido del 28/10/2026: el paciente elige, con un botón, a UN
-- profesional como su médico de cabecera, y el profesional ve quiénes lo
-- eligieron. `profiles.patient_primary_practitioners` guarda cada elección
-- como un período:
--   - `valid_from` la abre; `valid_to` la cierra cuando el paciente lo cambia
--     o lo quita. Nada se borra: «quién era mi médico en tal fecha» sigue
--     teniendo respuesta.
--   - A lo sumo UNA elección vigente por paciente, garantizada por la base
--     (`uq_patient_primary_practitioners_current`, índice único parcial), no
--     por un SELECT previo en el servicio.
--   - `ix_patient_primary_practitioners_practitioner_current` lista los
--     pacientes vigentes de un profesional, los más recientes primero.
-- La elección NO concede acceso clínico: eso sigue siendo del consentimiento
-- y de authz.
--
-- POR QUÉ NO HAY BACKFILL. Nadie eligió todavía, y asignar un médico por
-- defecto sería decidir por el paciente.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas                +1  (profiles.patient_primary_practitioners)
--   FKs                   +4  (paciente, profesional, created_by, updated_by)
--   índices               +7  (pk, 4 por columna, uq vigente, ix vigentes del profesional)
--
-- REVERSA (si hiciera falta):
--   DROP TABLE IF EXISTS "profiles"."patient_primary_practitioners";
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "profiles"."patient_primary_practitioners" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_primary_practitioners" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_primary_practitioners"
        ADD CONSTRAINT "fk_patient_primary_practitioners_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_primary_practitioners"
        ADD CONSTRAINT "fk_patient_primary_practitioners_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_primary_practitioners"
        ADD CONSTRAINT "fk_patient_primary_practitioners_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."patient_primary_practitioners"
        ADD CONSTRAINT "fk_patient_primary_practitioners_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_patient_primary_practitioners_patient_profile_id"
    ON "profiles"."patient_primary_practitioners" ("patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_patient_primary_practitioners_practitioner_profile_id"
    ON "profiles"."patient_primary_practitioners" ("practitioner_profile_id");
CREATE INDEX IF NOT EXISTS "ix_patient_primary_practitioners_created_by_user_id"
    ON "profiles"."patient_primary_practitioners" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_patient_primary_practitioners_updated_by_user_id"
    ON "profiles"."patient_primary_practitioners" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_patient_primary_practitioners_current"
    ON "profiles"."patient_primary_practitioners" ("patient_profile_id")
    WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_patient_primary_practitioners_practitioner_current"
    ON "profiles"."patient_primary_practitioners" ("practitioner_profile_id", "valid_from" DESC)
    WHERE valid_to IS NULL;

COMMIT;
