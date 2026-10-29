-- ============================================================================
-- SALUD · patch v4.2.67 (profiles · admisiones de profesionales: verificación del
-- alta de médicos) sobre BD viva
-- Fecha: 2026-10-29
-- Idempotente (ADD COLUMN / CREATE TABLE / CREATE INDEX IF NOT EXISTS, FKs con
-- duplicate_object, backfill con NOT EXISTS). Se puede aplicar N veces.
--
-- Contexto: gen_ddl.py ya emite estas tablas, columnas, FKs e índices en
-- SQL/05_profiles/ (y el guard append-only en SQL/05_profiles/05_constraints.sql)
-- desde que diagram_05_profiles.puml y diagram_33_integrity.puml los declaran
-- (v4.2.67), así que en un rebuild desde cero este patch NO hace falta. Existe
-- para una base ya aplicada y poblada. gen_apply.py no escanea SQL/patches/.
--
-- QUÉ AGREGA. Pedido del 29/10/2026: «falta la VERIFICACIÓN» del alta de médicos,
-- visible en el portal admin, pestaña ADMISIONES, tipo «Alta de doctor».
--   profiles.practitioner_admissions         solicitud de admisión (estado, SLA, asignación,
--                                            decisión). Fuente de verdad; PRACT_VERIF_* del
--                                            perfil es su proyección. ENVIADA ≡ PRACT_VERIF_PENDING.
--   profiles.admission_requirements          catálogo de requisitos por tipo de admisión
--                                            (obligatorio o no, profesión, documento o dato,
--                                            fuente obligatoria). Lo siembra la API al arrancar.
--   profiles.practitioner_admission_reviews  estado vigente de cada requisito/ítem
--                                            (PENDIENTE|VERIFICADO|RECHAZADO|INFO_REQUERIDA).
--   profiles.practitioner_admission_events   bitácora APPEND-ONLY (trigger de inmutabilidad).
--   jurisdiction_authorizations  +verified_by_user_id, verified_at, verification_source_uri,
--                                 rejection_reason_text
--   professional_credentials     +rejection_reason_text
--   practitioner_specialties     +verified_at
--
-- ORDEN DE APLICACIÓN. (1) SQL/_integrity/00_integrity_functions.sql debe existir
-- (el guard usa integrity.forbid_mutation()). (2) Los conceptos de la admisión
-- (profiles:ADMISSION_*) los siembra la API al arrancar: desplegar la API ANTES de
-- este patch si hay médicos pendientes, porque el backfill los referencia. La guarda
-- del final lo comprueba y falla con un mensaje explícito en vez de morir con una
-- violación de FK. En una base sin médicos pendientes el backfill es no-op.
--
-- LA FOTO DEL FORMULARIO. practitioner_admissions.submitted_snapshot (jsonb) guarda lo que
-- el médico envió; la API la toma al enviar y al reenviar. Las admisiones del backfill la
-- tienen nula hasta que la API la toma (el detalle lo marca como lectura viva).
--
-- BACKFILL. Una admisión ENVIADA (más su evento CREATED) por cada perfil profesional
-- hoy en PRACT_VERIF_PENDING que no tenga admisión. NO se migran filas: el estado del
-- perfil no cambia (ENVIADA ≡ PRACT_VERIF_PENDING). `due_at` = `submitted_at` (la
-- creación del perfil) + 3 días hábiles (lunes a viernes, UTC, sin feriados): la misma
-- cuenta que hace la API (PRACTITIONER_ADMISSION_SLA_BUSINESS_DAYS = 3). Los perfiles
-- ya VERIFICADOS quedan sin admisión: la API les crea una VERIFICADA al primer acceso
-- que la necesite y NO toca su verificación. El checklist de requisitos
-- (practitioner_admission_reviews) lo materializa la API al abrir el detalle de la
-- admisión (ensureChecklist, idempotente): no se rellena acá.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +4 · columnas +6 en tablas existentes · FKs +28 · índices +32 (28 + 4 PK)
--   · CHECK +3 · trigger append-only +1. Verificado en PostgreSQL 16: base del modelo
--   anterior + este patch dos veces y SQL nuevo desde cero dan el mismo pg_dump -s
--   (salvo el orden de columnas): 1265 tablas.
--
-- REVERSA (si hiciera falta; pierde la bitácora, por eso exige quitar el guard):
--   DROP TRIGGER IF EXISTS trg_forbid_mutation ON "profiles"."practitioner_admission_events";
--   DROP TABLE IF EXISTS "profiles"."practitioner_admission_events",
--                        "profiles"."practitioner_admission_reviews",
--                        "profiles"."practitioner_admissions",
--                        "profiles"."admission_requirements";
--   ALTER TABLE "profiles"."jurisdiction_authorizations"
--       DROP COLUMN IF EXISTS "verified_by_user_id", DROP COLUMN IF EXISTS "verified_at",
--       DROP COLUMN IF EXISTS "verification_source_uri", DROP COLUMN IF EXISTS "rejection_reason_text";
--   ALTER TABLE "profiles"."professional_credentials" DROP COLUMN IF EXISTS "rejection_reason_text";
--   ALTER TABLE "profiles"."practitioner_specialties" DROP COLUMN IF EXISTS "verified_at";
-- ============================================================================


BEGIN;


-- ─── Columnas nuevas en tablas existentes ──────────────────────────────────────────────

ALTER TABLE "profiles"."jurisdiction_authorizations"
    ADD COLUMN IF NOT EXISTS "verified_by_user_id" uuid,
    ADD COLUMN IF NOT EXISTS "verified_at" timestamptz,
    ADD COLUMN IF NOT EXISTS "verification_source_uri" text,
    ADD COLUMN IF NOT EXISTS "rejection_reason_text" text;

ALTER TABLE "profiles"."professional_credentials"
    ADD COLUMN IF NOT EXISTS "rejection_reason_text" text;

ALTER TABLE "profiles"."practitioner_specialties"
    ADD COLUMN IF NOT EXISTS "verified_at" timestamptz;


-- ─── Tablas nuevas ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "profiles"."admission_requirements" (
    "id" uuid NOT NULL,
    "admission_type_concept_id" uuid NOT NULL,
    "requirement_code" varchar NOT NULL,
    "label" varchar NOT NULL,
    "description" text,
    "item_type_concept_id" uuid NOT NULL,
    "item_subtype_code" varchar,
    "evidence_kind_concept_id" uuid NOT NULL,
    "verification_method_concept_id" uuid NOT NULL,
    "is_required" boolean NOT NULL DEFAULT true,
    "requires_source_uri" boolean NOT NULL DEFAULT true,
    "applies_to_profession_group" varchar,
    "min_items" smallint,
    "max_items" smallint,
    "sort_order" integer NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_admission_requirements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_admissions" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "admission_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "submitted_at" timestamptz NOT NULL,
    "due_at" timestamptz NOT NULL,
    "assigned_to_user_id" uuid,
    "decided_at" timestamptz,
    "decided_by_user_id" uuid,
    "decision_reason_text" text,
    "info_requested_text" text,
    "resubmission_count" integer NOT NULL,
    "valid_until" date,
    "closed_at" timestamptz,
    "submitted_snapshot" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_admissions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_admission_reviews" (
    "id" uuid NOT NULL,
    "admission_id" uuid NOT NULL,
    "requirement_id" uuid NOT NULL,
    "item_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "file_id" uuid,
    "verification_source_uri" text,
    "reason_text" text,
    "reviewed_by_user_id" uuid,
    "reviewed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_admission_reviews" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "profiles"."practitioner_admission_events" (
    "id" uuid NOT NULL,
    "admission_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "from_status_concept_id" uuid,
    "to_status_concept_id" uuid,
    "item_type_concept_id" uuid,
    "item_id" uuid,
    "requirement_id" uuid,
    "verification_source_uri" text,
    "reason_text" text,
    "actor_user_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_practitioner_admission_events" PRIMARY KEY ("id")
);

-- ─── FKs (mismo schema) ────────────────────────────────────────────────────────────────

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admissions"
        ADD CONSTRAINT "fk_practitioner_admissions_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_reviews"
        ADD CONSTRAINT "fk_practitioner_admission_reviews_admission_id" FOREIGN KEY ("admission_id")
        REFERENCES "profiles"."practitioner_admissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_reviews"
        ADD CONSTRAINT "fk_practitioner_admission_reviews_requirement_id" FOREIGN KEY ("requirement_id")
        REFERENCES "profiles"."admission_requirements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_events"
        ADD CONSTRAINT "fk_practitioner_admission_events_admission_id" FOREIGN KEY ("admission_id")
        REFERENCES "profiles"."practitioner_admissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_events"
        ADD CONSTRAINT "fk_practitioner_admission_events_requirement_id" FOREIGN KEY ("requirement_id")
        REFERENCES "profiles"."admission_requirements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ─── FKs (otros schemas) ───────────────────────────────────────────────────────────────

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."jurisdiction_authorizations"
        ADD CONSTRAINT "fk_jurisdiction_authorizations_verified_by_user_id" FOREIGN KEY ("verified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."admission_requirements"
        ADD CONSTRAINT "fk_admission_requirements_admission_type_concept_id" FOREIGN KEY ("admission_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."admission_requirements"
        ADD CONSTRAINT "fk_admission_requirements_item_type_concept_id" FOREIGN KEY ("item_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."admission_requirements"
        ADD CONSTRAINT "fk_admission_requirements_evidence_kind_concept_id" FOREIGN KEY ("evidence_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."admission_requirements"
        ADD CONSTRAINT "fk_admission_requirements_verification_method_concept_id" FOREIGN KEY ("verification_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."admission_requirements"
        ADD CONSTRAINT "fk_admission_requirements_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."admission_requirements"
        ADD CONSTRAINT "fk_admission_requirements_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admissions"
        ADD CONSTRAINT "fk_practitioner_admissions_admission_type_concept_id" FOREIGN KEY ("admission_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admissions"
        ADD CONSTRAINT "fk_practitioner_admissions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admissions"
        ADD CONSTRAINT "fk_practitioner_admissions_assigned_to_user_id" FOREIGN KEY ("assigned_to_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admissions"
        ADD CONSTRAINT "fk_practitioner_admissions_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admissions"
        ADD CONSTRAINT "fk_practitioner_admissions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admissions"
        ADD CONSTRAINT "fk_practitioner_admissions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_reviews"
        ADD CONSTRAINT "fk_practitioner_admission_reviews_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_reviews"
        ADD CONSTRAINT "fk_practitioner_admission_reviews_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_reviews"
        ADD CONSTRAINT "fk_practitioner_admission_reviews_reviewed_by_user_id" FOREIGN KEY ("reviewed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_reviews"
        ADD CONSTRAINT "fk_practitioner_admission_reviews_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_reviews"
        ADD CONSTRAINT "fk_practitioner_admission_reviews_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_events"
        ADD CONSTRAINT "fk_practitioner_admission_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_events"
        ADD CONSTRAINT "fk_practitioner_admission_events_from_status_concept_id" FOREIGN KEY ("from_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_events"
        ADD CONSTRAINT "fk_practitioner_admission_events_to_status_concept_id" FOREIGN KEY ("to_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_events"
        ADD CONSTRAINT "fk_practitioner_admission_events_item_type_concept_id" FOREIGN KEY ("item_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_admission_events"
        ADD CONSTRAINT "fk_practitioner_admission_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ─── Índices ───────────────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS "ix_jurisdiction_authorizations_verified_by_user_id" ON "profiles"."jurisdiction_authorizations" ("verified_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_admission_requirements_type_code" ON "profiles"."admission_requirements" ("admission_type_concept_id", "requirement_code");

CREATE INDEX IF NOT EXISTS "ix_admission_requirements_admission_type_concept_id" ON "profiles"."admission_requirements" ("admission_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_admission_requirements_item_type_concept_id" ON "profiles"."admission_requirements" ("item_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_admission_requirements_evidence_kind_concept_id" ON "profiles"."admission_requirements" ("evidence_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_admission_requirements_verification_method_concept_id" ON "profiles"."admission_requirements" ("verification_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_admission_requirements_created_by_user_id" ON "profiles"."admission_requirements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_admission_requirements_updated_by_user_id" ON "profiles"."admission_requirements" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_practitioner_admissions_open" ON "profiles"."practitioner_admissions" ("practitioner_profile_id", "admission_type_concept_id") WHERE closed_at IS NULL;

CREATE INDEX IF NOT EXISTS "ix_practitioner_admissions_inbox" ON "profiles"."practitioner_admissions" ("status_concept_id", "due_at", "id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admissions_assigned_to_user_id" ON "profiles"."practitioner_admissions" ("assigned_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admissions_admission_type_concept_id" ON "profiles"."practitioner_admissions" ("admission_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admissions_decided_by_user_id" ON "profiles"."practitioner_admissions" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admissions_created_by_user_id" ON "profiles"."practitioner_admissions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admissions_updated_by_user_id" ON "profiles"."practitioner_admissions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admissions_valid_until" ON "profiles"."practitioner_admissions" ("valid_until") WHERE valid_until IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_practitioner_admission_reviews_item" ON "profiles"."practitioner_admission_reviews" ("admission_id", "requirement_id", "item_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_reviews_requirement_id" ON "profiles"."practitioner_admission_reviews" ("requirement_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_reviews_admission_status" ON "profiles"."practitioner_admission_reviews" ("admission_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_reviews_file_id" ON "profiles"."practitioner_admission_reviews" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_reviews_reviewed_by_user_id" ON "profiles"."practitioner_admission_reviews" ("reviewed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_reviews_created_by_user_id" ON "profiles"."practitioner_admission_reviews" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_reviews_updated_by_user_id" ON "profiles"."practitioner_admission_reviews" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_events_admission_occurred" ON "profiles"."practitioner_admission_events" ("admission_id", "occurred_at");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_events_event_type_concept_id" ON "profiles"."practitioner_admission_events" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_events_actor_user_id" ON "profiles"."practitioner_admission_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_admission_events_requirement_id" ON "profiles"."practitioner_admission_events" ("requirement_id");

-- ─── Constraints de integridad y guarda append-only (módulo 33) ────────────────────────

-- Requiere SQL/_integrity/00_integrity_functions.sql (schema integrity + forbid_mutation()).

-- ═══ practitioner_admission_events ═══
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "profiles"."practitioner_admission_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "profiles"."practitioner_admission_events";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "profiles"."practitioner_admission_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ═══ practitioner_admissions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "profiles"."practitioner_admissions" DROP CONSTRAINT IF EXISTS "ck_practitioner_admissions_resubmission_count";
ALTER TABLE "profiles"."practitioner_admissions" ADD CONSTRAINT "ck_practitioner_admissions_resubmission_count" CHECK (("resubmission_count" >= 0));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "profiles"."practitioner_admissions" DROP CONSTRAINT IF EXISTS "ck_practitioner_admissions_due_after_submit";
ALTER TABLE "profiles"."practitioner_admissions" ADD CONSTRAINT "ck_practitioner_admissions_due_after_submit" CHECK (("due_at" >= "submitted_at"));

-- ═══ admission_requirements ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "profiles"."admission_requirements" DROP CONSTRAINT IF EXISTS "ck_admission_requirements_item_range";
ALTER TABLE "profiles"."admission_requirements" ADD CONSTRAINT "ck_admission_requirements_item_range" CHECK ((COALESCE("min_items", 0) >= 0 AND ("max_items" IS NULL OR "max_items" >= COALESCE("min_items", 0))));

-- ─── Backfill: una admisión ENVIADA por cada perfil PRACT_VERIF_PENDING ────────────────
-- Guarda vacío-safe y de orden: los conceptos los siembra la API, no este patch. Si no
-- hay perfiles pendientes sin admisión, no se necesita terminología y termina como no-op.
DO $$
DECLARE
    v_pending integer;
    v_missing integer;
BEGIN
    SELECT count(*) INTO v_pending
      FROM "profiles"."health_practitioner_profiles" p
     WHERE p."verification_status_concept_id" = 'ed8371fb-89a7-5bb4-af21-a83710587a20'  -- profiles:PRACT_VERIF_PENDING
       AND NOT EXISTS (
            SELECT 1 FROM "profiles"."practitioner_admissions" a
             WHERE a."practitioner_profile_id" = p."profile_id"
               AND a."admission_type_concept_id" = 'afabdae4-7669-5fd4-b8d3-219f755c203b'  -- profiles:ADMISSION_TYPE_PRACTITIONER_ONBOARDING
               AND a."closed_at" IS NULL);
    IF v_pending > 0 THEN
        SELECT count(*) INTO v_missing
          FROM (VALUES
                ('afabdae4-7669-5fd4-b8d3-219f755c203b'::uuid),  -- ADMISSION_TYPE_PRACTITIONER_ONBOARDING
                ('7aefea65-34a7-5451-91a4-40e59963d3d2'::uuid),  -- ADMISSION_STATUS_SUBMITTED
                ('5bd15a74-4222-5da9-97c9-f340dfc4287d'::uuid)   -- ADMISSION_EVENT_CREATED
          ) AS c(id)
         WHERE NOT EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" cc WHERE cc."id" = c.id);
        IF v_missing > 0 THEN
            RAISE EXCEPTION 'Faltan % concepto(s) de admisión en terminology.catalog_concepts: desplegar la API (siembra profiles:ADMISSION_*) y volver a ejecutar este patch', v_missing;
        END IF;
    END IF;
END $$;

-- 3 días hábiles (lunes a viernes, UTC) a partir del día siguiente a la creación del perfil,
-- conservando la hora. Misma cuenta que la API (addBusinessDays).
INSERT INTO "profiles"."practitioner_admissions"
    ("id", "practitioner_profile_id", "admission_type_concept_id", "status_concept_id",
     "submitted_at", "due_at", "resubmission_count", "created_at", "updated_at",
     "created_by_user_id", "updated_by_user_id", "row_version")
SELECT gen_random_uuid(), p."profile_id",
       'afabdae4-7669-5fd4-b8d3-219f755c203b',  -- ADMISSION_TYPE_PRACTITIONER_ONBOARDING
       '7aefea65-34a7-5451-91a4-40e59963d3d2',  -- ADMISSION_STATUS_SUBMITTED
       p."created_at",
       ((SELECT d FROM generate_series(((p."created_at" AT TIME ZONE 'UTC')::date + 1)::timestamp,
                                       ((p."created_at" AT TIME ZONE 'UTC')::date + 10)::timestamp,
                                       interval '1 day') AS d
          WHERE extract(isodow FROM d) < 6
          ORDER BY d OFFSET 2 LIMIT 1)
         + (p."created_at" AT TIME ZONE 'UTC')::time) AT TIME ZONE 'UTC',
       0, now(), now(), p."created_by_user_id", p."created_by_user_id", 1
  FROM "profiles"."health_practitioner_profiles" p
 WHERE p."verification_status_concept_id" = 'ed8371fb-89a7-5bb4-af21-a83710587a20'  -- PRACT_VERIF_PENDING
   AND NOT EXISTS (
        SELECT 1 FROM "profiles"."practitioner_admissions" a
         WHERE a."practitioner_profile_id" = p."profile_id"
           AND a."admission_type_concept_id" = 'afabdae4-7669-5fd4-b8d3-219f755c203b'
           AND a."closed_at" IS NULL);

INSERT INTO "profiles"."practitioner_admission_events"
    ("id", "admission_id", "event_type_concept_id", "from_status_concept_id", "to_status_concept_id",
     "reason_text", "actor_user_id", "occurred_at")
SELECT gen_random_uuid(), a."id",
       '5bd15a74-4222-5da9-97c9-f340dfc4287d',  -- ADMISSION_EVENT_CREATED
       NULL, a."status_concept_id",
       'Backfill v4.2.67: perfil que ya estaba pendiente de verificación',
       a."created_by_user_id", a."submitted_at"
  FROM "profiles"."practitioner_admissions" a
 WHERE NOT EXISTS (SELECT 1 FROM "profiles"."practitioner_admission_events" e WHERE e."admission_id" = a."id");


COMMIT;
