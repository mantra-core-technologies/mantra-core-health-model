-- ============================================================================
-- SALUD · patch v4.2.97 · script de preguntas y preguntas frecuentes del profesional (módulo 09 forms) sobre BD viva
-- Fecha: 2026-11-06
-- Idempotente (CREATE ... IF NOT EXISTS / FK bajo duplicate_object / DROP CONSTRAINT IF EXISTS + ADD).
-- UNA sola transacción, re-ejecutable. SIN backfill: son tablas nuevas.
--
-- Contexto: el médico necesita dos herramientas que no existían en ningún repo.
--   forms.question_scripts        guion ordenado de preguntas que el médico usa durante la atención.
--   forms.question_script_items   las preguntas del guion (position único por guion, ON DELETE CASCADE).
--   forms.faq_entries             preguntas y respuestas frecuentes que el médico publica para sus pacientes.
-- Dueño: owner_practitioner_id → profiles.health_practitioner_profiles(profile_id), el mismo destino que
-- surveys.survey_templates y surveys.survey_assignments.
--
-- Contexto de generación: gen_ddl.py y gen_integrity.py ya emiten todo esto en SQL/09_forms/ desde que
-- diagram_09_forms.puml (tablas, aristas, índices) y diagram_33_integrity.puml (CHECK_SQL y el nuevo
-- UNIQUE_SQL) lo declaran, así que sobre una base nueva este parche es no-op salvo los COMMENT ON y el
-- GRANT. gen_apply.py no escanea SQL/patches/. Las sentencias se copiaron de los archivos generados.
--
-- DECISIONES.
--   - position es único por lista con un UNIQUE DEFERRABLE INITIALLY IMMEDIATE (no un índice único):
--     reordenar intercambia posiciones. En una sola sentencia funciona tal cual; si la API reordena con
--     varias sentencias, hace SET CONSTRAINTS <nombre> DEFERRED en la transacción. La violación sigue
--     siendo 23505 (unique_violation). Limitación: un UNIQUE diferible no sirve de árbitro de
--     INSERT ... ON CONFLICT.
--   - status y answer_type son códigos de texto cerrados con CHECK (contrato con la API y el front), no
--     conceptos del catálogo.
--   - options: arreglo JSON de textos no vacíos; obligatorio con ≥ 2 en single_choice/multiple_choice.
--   - created_at/updated_at con DEFAULT now(); row_version (bloqueo optimista) DEFAULT 1, como el resto.
--
-- RLS: ninguna. Las tablas no tienen tenant_id —igual que dynamic_field_definitions y las demás de
-- forms sin tenant— así que la política tenant_isolation de 2026-08-05_tenant_rls.sql no las alcanza.
-- La autorización por dueño (sólo el profesional edita lo suyo; sólo las FAQ publicadas se leen afuera)
-- la hace la API. GRANT DML a mantra_app explícito, por si el dueño que corre esto no es el que fijó los
-- ALTER DEFAULT PRIVILEGES.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +3 · FKs +9 (1 intra, 8 entre schemas) · índices +9 · CHECK +9 · UNIQUE +2 · comentarios +6
--
-- Reversible (sin datos que perder fuera de estas tablas):
--   DROP TABLE IF EXISTS "forms"."question_script_items", "forms"."question_scripts", "forms"."faq_entries";
-- ============================================================================

BEGIN;

-- --------------------------------------------------------------- 0. prerrequisitos
DO $$
BEGIN
    IF to_regnamespace('forms') IS NULL
       OR to_regclass('profiles.health_practitioner_profiles') IS NULL
       OR to_regclass('iam.users') IS NULL THEN
        RAISE EXCEPTION 'v4.2.97: faltan el schema forms o las tablas base (profiles, iam); aplicar antes el modelo base';
    END IF;
END $$;

-- --------------------------------------------------------------------- A. tablas
CREATE TABLE IF NOT EXISTS "forms"."question_scripts" (
    "id" uuid NOT NULL,
    "owner_practitioner_id" uuid NOT NULL,
    "title" text NOT NULL,
    "description" text,
    "specialty_code" text,
    "status" text NOT NULL DEFAULT 'active',
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_question_scripts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."question_script_items" (
    "id" uuid NOT NULL,
    "script_id" uuid NOT NULL,
    "position" integer NOT NULL,
    "question_text" text NOT NULL,
    "help_text" text,
    "answer_type" text NOT NULL,
    "options" jsonb,
    "required" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_question_script_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "forms"."faq_entries" (
    "id" uuid NOT NULL,
    "owner_practitioner_id" uuid NOT NULL,
    "question" text NOT NULL,
    "answer" text NOT NULL,
    "category" text,
    "position" integer NOT NULL,
    "is_published" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_faq_entries" PRIMARY KEY ("id")
);

-- ---------------------------------------------------------------------- B. FK
-- intra-schema (SQL/09_forms/03_fk_intra.sql)
DO $$ BEGIN
    ALTER TABLE "forms"."question_script_items"
        ADD CONSTRAINT "fk_question_script_items_script_id" FOREIGN KEY ("script_id")
        REFERENCES "forms"."question_scripts" ("id") ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- entre schemas (SQL/09_forms/90_fk_deferred.sql)
-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "forms"."question_scripts"
        ADD CONSTRAINT "fk_question_scripts_owner_practitioner_id" FOREIGN KEY ("owner_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "forms"."question_scripts"
        ADD CONSTRAINT "fk_question_scripts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "forms"."question_scripts"
        ADD CONSTRAINT "fk_question_scripts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "forms"."question_script_items"
        ADD CONSTRAINT "fk_question_script_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "forms"."question_script_items"
        ADD CONSTRAINT "fk_question_script_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "forms"."faq_entries"
        ADD CONSTRAINT "fk_faq_entries_owner_practitioner_id" FOREIGN KEY ("owner_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "forms"."faq_entries"
        ADD CONSTRAINT "fk_faq_entries_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "forms"."faq_entries"
        ADD CONSTRAINT "fk_faq_entries_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------------ C. índices
CREATE INDEX IF NOT EXISTS "ix_question_scripts_owner_practitioner_id" ON "forms"."question_scripts" ("owner_practitioner_id", "status", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_question_scripts_created_by_user_id" ON "forms"."question_scripts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_question_scripts_updated_by_user_id" ON "forms"."question_scripts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_question_script_items_created_by_user_id" ON "forms"."question_script_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_question_script_items_updated_by_user_id" ON "forms"."question_script_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_faq_entries_owner_practitioner_id" ON "forms"."faq_entries" ("owner_practitioner_id");

CREATE INDEX IF NOT EXISTS "ix_faq_entries_owner_published" ON "forms"."faq_entries" ("owner_practitioner_id", "position") WHERE is_published = true;

CREATE INDEX IF NOT EXISTS "ix_faq_entries_created_by_user_id" ON "forms"."faq_entries" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_faq_entries_updated_by_user_id" ON "forms"."faq_entries" ("updated_by_user_id");

-- ------------------------------------- D. CHECK y UNIQUE (SQL/09_forms/05_constraints.sql)
-- ═══ question_scripts ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_scripts" DROP CONSTRAINT IF EXISTS "ck_question_scripts_title";
ALTER TABLE "forms"."question_scripts" ADD CONSTRAINT "ck_question_scripts_title" CHECK (char_length(btrim("title")) >= 1 AND char_length("title") <= 160);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_scripts" DROP CONSTRAINT IF EXISTS "ck_question_scripts_status";
ALTER TABLE "forms"."question_scripts" ADD CONSTRAINT "ck_question_scripts_status" CHECK ("status" IN ('active', 'archived'));


-- ═══ question_script_items ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_question_text";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_question_text" CHECK (char_length(btrim("question_text")) >= 1 AND char_length("question_text") <= 500);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_answer_type";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_answer_type" CHECK ("answer_type" IN ('free_text', 'yes_no', 'single_choice', 'multiple_choice', 'number', 'date'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_position";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_position" CHECK ("position" >= 0);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_options";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_options" CHECK (("options" IS NULL OR (jsonb_typeof("options") = 'array' AND NOT jsonb_path_exists("options", '$[*] ? (@.type() != "string" || @ like_regex "^ *$")'))) AND ("answer_type" NOT IN ('single_choice', 'multiple_choice') OR ("options" IS NOT NULL AND jsonb_array_length("options") >= 2)));

-- UNIQUE concreto declarado por el modelo (UNIQUE_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "uq_question_script_items_script_position";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "uq_question_script_items_script_position"
    UNIQUE ("script_id", "position") DEFERRABLE INITIALLY IMMEDIATE;


-- ═══ faq_entries ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "ck_faq_entries_question";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "ck_faq_entries_question" CHECK (char_length(btrim("question")) >= 1 AND char_length("question") <= 300);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "ck_faq_entries_answer";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "ck_faq_entries_answer" CHECK (char_length(btrim("answer")) >= 1 AND char_length("answer") <= 4000);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "ck_faq_entries_position";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "ck_faq_entries_position" CHECK ("position" >= 0);

-- UNIQUE concreto declarado por el modelo (UNIQUE_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "uq_faq_entries_owner_position";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "uq_faq_entries_owner_position"
    UNIQUE ("owner_practitioner_id", "position") DEFERRABLE INITIALLY IMMEDIATE;

-- --------------------------------------------------------------- E. significado
COMMENT ON TABLE "forms"."question_scripts" IS
    'Guion ordenado de preguntas que un profesional usa durante la atención. Dueño: owner_practitioner_id. status active|archived (archivar oculta sin borrar los ítems). API: QuestionScript.';
COMMENT ON TABLE "forms"."question_script_items" IS
    'Pregunta de un guion. position único por guion (UNIQUE diferible para reordenar). answer_type free_text|yes_no|single_choice|multiple_choice|number|date; options es un arreglo de textos, obligatorio con 2 o más en las de opción. Se borra con el guion. API: QuestionScriptItem.';
COMMENT ON TABLE "forms"."faq_entries" IS
    'Pregunta y respuesta frecuente que un profesional publica para sus pacientes. Nace sin publicar; sólo is_published = true se lee fuera del panel del profesional. position único por dueño (UNIQUE diferible para reordenar). API: FaqEntry.';
COMMENT ON COLUMN "forms"."question_scripts"."owner_practitioner_id" IS
    'Profesional dueño (profiles.health_practitioner_profiles.profile_id). La API lo fija desde el actor; no se acepta del cliente.';
COMMENT ON COLUMN "forms"."question_scripts"."specialty_code" IS
    'Código de especialidad opcional para filtrar guiones; texto libre del catálogo de la API, sin FK.';
COMMENT ON COLUMN "forms"."faq_entries"."owner_practitioner_id" IS
    'Profesional dueño (profiles.health_practitioner_profiles.profile_id). La API lo fija desde el actor; no se acepta del cliente.';

-- --------------------------------------------------------------------- F. grants
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT USAGE ON SCHEMA "forms" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE
            ON "forms"."question_scripts", "forms"."question_script_items", "forms"."faq_entries"
            TO mantra_app;
    END IF;
END $$;

COMMIT;
