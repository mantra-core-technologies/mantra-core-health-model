-- ============================================================================
-- SALUD · patch v4.2.32 (scheduling · reserva de servicios con duración dinámica)
-- sobre una BD viva
-- Fecha: 2026-10-01
-- Idempotente (CREATE TABLE / ADD COLUMN / CREATE INDEX IF NOT EXISTS · FK con
-- EXCEPTION WHEN duplicate_object · CHECK con DROP CONSTRAINT IF EXISTS).
-- UNA sola pasada: no hay backfill — toda columna nueva es nullable y NULL conserva el
-- significado de antes.
--
-- Contexto: gen_ddl.py ya emite todo esto en SQL/41_scheduling/ desde que el .puml lo
-- declara, así que en un rebuild desde cero este patch NO hace falta. Existe únicamente
-- para una base ya aplicada y poblada. gen_apply.py no escanea SQL/patches/.
--
-- QUÉ AGREGA
--   1 · scheduling.practitioner_service_offerings — cómo ofrece ESTE profesional ESTE
--       servicio del catálogo (duración mín/máx, colchones, reservable por el paciente,
--       requiere aprobación). El catálogo es por práctica: la duración no puede vivir ahí.
--   2 · scheduling.schedule_rules.booking_mode_concept_id — qué admite la franja
--       (CONSULTATIONS · SERVICES · MIXED). NULL ≡ «sólo consultas».
--   3 · scheduling.appointment_bookings.practitioner_service_offering_id y
--       service_snapshot — la reserva de un servicio y lo que el paciente aceptó.
--   4 · 2 CHECK de la matriz del módulo 33 sobre la oferta.
--
-- ⚠️ ACOPLE CON EL CATÁLOGO ORM: los índices y FKs nuevos viajan en el catálogo
-- (`yarn orm:catalog`) en el mismo PR de la API.
--
-- Este archivo es salida de gen_ddl.py 41 y gen_integrity.py, no DDL escrito a mano.
-- Correlo con `psql -v ON_ERROR_STOP=1 -f`. Con `rebuild_stack.py --yes` no hace falta.
--
-- Delta esperado: +1 tabla · +8 FK · +8 índices (6 de la tabla nueva sin su PK + 2) · +3 columnas
-- (1 en schedule_rules, 2 en appointment_bookings) · +2 CHECK.
-- ============================================================================

-- 1 · la oferta de servicio (de SQL/41_scheduling/02_tables.sql)
CREATE TABLE IF NOT EXISTS "scheduling"."practitioner_service_offerings" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "service_catalog_id" uuid NOT NULL,
    "min_duration_minutes" integer NOT NULL,
    "max_duration_minutes" integer NOT NULL,
    "prep_minutes" integer,
    "cleanup_minutes" integer,
    "is_patient_bookable" boolean NOT NULL,
    "requires_approval" boolean NOT NULL,
    "channel_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_service_offerings" PRIMARY KEY ("id")
);

-- 2 · el modo de la franja
ALTER TABLE "scheduling"."schedule_rules" ADD COLUMN IF NOT EXISTS "booking_mode_concept_id" uuid;

-- 3 · la reserva de un servicio
ALTER TABLE "scheduling"."appointment_bookings" ADD COLUMN IF NOT EXISTS "practitioner_service_offering_id" uuid;
ALTER TABLE "scheduling"."appointment_bookings" ADD COLUMN IF NOT EXISTS "service_snapshot" jsonb;

-- índices (de SQL/41_scheduling/04_indexes.sql)
CREATE UNIQUE INDEX IF NOT EXISTS "ux_practitioner_service_offerings_practitioner_service" ON "scheduling"."practitioner_service_offerings" ("practitioner_profile_id", "service_catalog_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_service_catalog_id" ON "scheduling"."practitioner_service_offerings" ("service_catalog_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_channel_concept_id" ON "scheduling"."practitioner_service_offerings" ("channel_concept_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_status_concept_id" ON "scheduling"."practitioner_service_offerings" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_created_by_user_id" ON "scheduling"."practitioner_service_offerings" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_updated_by_user_id" ON "scheduling"."practitioner_service_offerings" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_schedule_rules_booking_mode_concept_id" ON "scheduling"."schedule_rules" ("booking_mode_concept_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_practitioner_service_offering_id" ON "scheduling"."appointment_bookings" ("practitioner_service_offering_id");

-- FK (de SQL/41_scheduling/03_fk_intra.sql y 90_fk_deferred.sql)
DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_practitioner_service_offering_id" FOREIGN KEY ("practitioner_service_offering_id")
        REFERENCES "scheduling"."practitioner_service_offerings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_rules"
        ADD CONSTRAINT "fk_schedule_rules_booking_mode_concept_id" FOREIGN KEY ("booking_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "scheduling"."practitioner_service_offerings"
        ADD CONSTRAINT "fk_practitioner_service_offerings_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.service_catalog (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "scheduling"."practitioner_service_offerings"
        ADD CONSTRAINT "fk_practitioner_service_offerings_service_catalog_id" FOREIGN KEY ("service_catalog_id")
        REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "scheduling"."practitioner_service_offerings"
        ADD CONSTRAINT "fk_practitioner_service_offerings_channel_concept_id" FOREIGN KEY ("channel_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "scheduling"."practitioner_service_offerings"
        ADD CONSTRAINT "fk_practitioner_service_offerings_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "scheduling"."practitioner_service_offerings"
        ADD CONSTRAINT "fk_practitioner_service_offerings_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "scheduling"."practitioner_service_offerings"
        ADD CONSTRAINT "fk_practitioner_service_offerings_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)


-- CHECK (de SQL/41_scheduling/05_constraints.sql)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."practitioner_service_offerings" DROP CONSTRAINT IF EXISTS "ck_practitioner_service_offerings_duration_range";
ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "ck_practitioner_service_offerings_duration_range" CHECK (("min_duration_minutes" > 0 AND "min_duration_minutes" <= "max_duration_minutes" AND "max_duration_minutes" <= 720));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."practitioner_service_offerings" DROP CONSTRAINT IF EXISTS "ck_practitioner_service_offerings_buffers";
ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "ck_practitioner_service_offerings_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));
