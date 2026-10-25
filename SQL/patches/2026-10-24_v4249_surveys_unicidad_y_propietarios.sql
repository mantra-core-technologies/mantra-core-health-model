-- ============================================================================
-- SALUD · patch (surveys · unicidad respaldada por la base y dueños que no son un profesional) sobre BD viva
-- Fecha: 2026-10-24 · hallazgo SURV-02 (API #806) · issue #55 CAN-SURVEY-001
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA.
--   1. SURV-02: la idempotencia que el servicio comprobaba leyendo antes de escribir queda
--      respaldada por índices únicos: (survey_template_id, version_number) en survey_versions;
--      (survey_version_id, target_type_concept_id, target_id) mientras la asignación está activa;
--      (appointment_booking_id, survey_version_id) en survey_invitations; (survey_invitation_id)
--      en survey_responses; (survey_response_id, survey_question_id) en survey_answers. Los dos
--      índices planos ix_survey_versions_template_number e ix_survey_responses_invitation
--      quedan reemplazados por su versión única (mismas columnas). Y el CHECK de exactamente
--      una columna value_* con valor en survey_answers.
--   2. CAN-SURVEY-001: survey_templates.owner_practitioner_id y survey_invitations.
--      appointment_booking_id dejan de ser NOT NULL; el dueño alterno (owner_type_concept_id +
--      owner_id) y el sujeto alterno (subject_type_concept_id + subject_id) son pares nullable,
--      con un CHECK cada uno que conserva la invariante (un solo dueño; al menos un ancla).
--      survey_versions.max_reminders y la tabla survey_invitation_reminders cubren los
--      recordatorios con tope.
--
-- PRECONDICIÓN: no debe haber filas que ya incumplan una regla nueva. El patch lo comprueba
-- antes de tocar nada y aborta con un mensaje; el BEGIN hace rollback de todo. Resolver los
-- duplicados (conservar la fila más antigua y repuntar o archivar las demás) y volver a aplicar.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +1 · columnas +5 · NOT NULL quitados 2 · FKs +5 · índices +10 (-2) · constraints +5
-- ============================================================================

BEGIN;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "surveys"."survey_versions"
         GROUP BY "survey_template_id", "version_number"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'surveys.survey_versions (survey_template_id, version_number) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "surveys"."survey_assignments"
         WHERE "active" = true
         GROUP BY "survey_version_id", "target_type_concept_id", "target_id"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'surveys.survey_assignments activas (survey_version_id, target_type_concept_id, target_id) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "surveys"."survey_invitations"
         WHERE "appointment_booking_id" IS NOT NULL
         GROUP BY "appointment_booking_id", "survey_version_id"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'surveys.survey_invitations (appointment_booking_id, survey_version_id) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "surveys"."survey_responses"
         GROUP BY "survey_invitation_id"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'surveys.survey_responses (survey_invitation_id) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "surveys"."survey_answers"
         GROUP BY "survey_response_id", "survey_question_id"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'surveys.survey_answers (survey_response_id, survey_question_id) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

DO $$
DECLARE
    violan integer;
BEGIN
    SELECT count(*) INTO violan FROM "surveys"."survey_answers"
     WHERE NOT COALESCE((num_nonnulls("value_text", "value_number", "value_boolean", "value_choices") = 1), true);
    IF violan > 0 THEN
        RAISE EXCEPTION 'surveys.survey_answers: exactamente una columna value_*: % fila(s) incumplen la regla: corregirlas antes de aplicar el patch', violan;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_versions_template_number" ON "surveys"."survey_versions" ("survey_template_id", "version_number");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_assignments_active_target" ON "surveys"."survey_assignments" ("survey_version_id", "target_type_concept_id", "target_id") WHERE active = true;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_invitations_booking_version" ON "surveys"."survey_invitations" ("appointment_booking_id", "survey_version_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_responses_invitation" ON "surveys"."survey_responses" ("survey_invitation_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_answers_response_question" ON "surveys"."survey_answers" ("survey_response_id", "survey_question_id");

DROP INDEX IF EXISTS "surveys"."ix_survey_versions_template_number";

DROP INDEX IF EXISTS "surveys"."ix_survey_responses_invitation";

ALTER TABLE "surveys"."survey_templates"
    ALTER COLUMN "owner_practitioner_id" DROP NOT NULL;

ALTER TABLE "surveys"."survey_invitations"
    ALTER COLUMN "appointment_booking_id" DROP NOT NULL;

ALTER TABLE "surveys"."survey_templates"
    ADD COLUMN IF NOT EXISTS "owner_type_concept_id" uuid;

ALTER TABLE "surveys"."survey_templates"
    ADD COLUMN IF NOT EXISTS "owner_id" uuid;

ALTER TABLE "surveys"."survey_versions"
    ADD COLUMN IF NOT EXISTS "max_reminders" integer;

ALTER TABLE "surveys"."survey_invitations"
    ADD COLUMN IF NOT EXISTS "subject_type_concept_id" uuid;

ALTER TABLE "surveys"."survey_invitations"
    ADD COLUMN IF NOT EXISTS "subject_id" uuid;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_templates"
        ADD CONSTRAINT "fk_survey_templates_owner_type_concept_id" FOREIGN KEY ("owner_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_survey_templates_owner_party" ON "surveys"."survey_templates" ("owner_type_concept_id", "owner_id", "created_at" DESC);

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_subject" ON "surveys"."survey_invitations" ("subject_type_concept_id", "subject_id");

CREATE TABLE IF NOT EXISTS "surveys"."survey_invitation_reminders" (
    "id" uuid NOT NULL,
    "survey_invitation_id" uuid NOT NULL,
    "reminder_number" integer NOT NULL,
    "sent_at" timestamptz NOT NULL,
    "channel_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_survey_invitation_reminders" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitation_reminders"
        ADD CONSTRAINT "fk_survey_invitation_reminders_survey_invitation_id" FOREIGN KEY ("survey_invitation_id")
        REFERENCES "surveys"."survey_invitations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitation_reminders"
        ADD CONSTRAINT "fk_survey_invitation_reminders_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitation_reminders"
        ADD CONSTRAINT "fk_survey_invitation_reminders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_invitation_reminders_number" ON "surveys"."survey_invitation_reminders" ("survey_invitation_id", "reminder_number");

CREATE INDEX IF NOT EXISTS "ix_survey_invitation_reminders_channel_concept_id" ON "surveys"."survey_invitation_reminders" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitation_reminders_created_by_user_id" ON "surveys"."survey_invitation_reminders" ("created_by_user_id");

-- ═══ survey_invitation_reminders ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_invitation_reminders" DROP CONSTRAINT IF EXISTS "ck_survey_invitation_reminders_number";
ALTER TABLE "surveys"."survey_invitation_reminders" ADD CONSTRAINT "ck_survey_invitation_reminders_number" CHECK ("reminder_number" >= 1);

-- ═══ survey_templates ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_templates" DROP CONSTRAINT IF EXISTS "ck_survey_templates_single_owner";
ALTER TABLE "surveys"."survey_templates" ADD CONSTRAINT "ck_survey_templates_single_owner" CHECK (("owner_practitioner_id" IS NOT NULL AND "owner_type_concept_id" IS NULL AND "owner_id" IS NULL) OR ("owner_practitioner_id" IS NULL AND "owner_type_concept_id" IS NOT NULL AND "owner_id" IS NOT NULL));

-- ═══ survey_versions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_versions" DROP CONSTRAINT IF EXISTS "ck_survey_versions_max_reminders";
ALTER TABLE "surveys"."survey_versions" ADD CONSTRAINT "ck_survey_versions_max_reminders" CHECK (("max_reminders" IS NULL OR "max_reminders" >= 0));

-- ═══ survey_invitations ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_invitations" DROP CONSTRAINT IF EXISTS "ck_survey_invitations_anchor";
ALTER TABLE "surveys"."survey_invitations" ADD CONSTRAINT "ck_survey_invitations_anchor" CHECK (("appointment_booking_id" IS NOT NULL OR "subject_id" IS NOT NULL) AND (("subject_type_concept_id" IS NULL) = ("subject_id" IS NULL)));

-- ═══ survey_answers ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_answers" DROP CONSTRAINT IF EXISTS "ck_survey_answers_single_value";
ALTER TABLE "surveys"."survey_answers" ADD CONSTRAINT "ck_survey_answers_single_value" CHECK (num_nonnulls("value_text", "value_number", "value_boolean", "value_choices") = 1);

COMMIT;
