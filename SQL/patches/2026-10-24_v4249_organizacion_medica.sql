-- ============================================================================
-- SALUD · patch (organización médica · jornada y responsable, preparación/limpieza, solape de quirófano, cargo por cancelación) sobre BD viva
-- Fecha: 2026-10-24 · issue #58 ORG-PER-003 / ORG-ARE-002 / ORG-QUI-002 / ORG-QUI-005 / DOC-POL-001 / PAC-CITA-011
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA.
--   - directory.tenant_memberships y branch_memberships: workday_concept_id y responsible_user_id.
--   - practice.clinical_units.responsible_user_id.
--   - practice.care_spaces y procedures_perioperative.procedure_cases: prep_minutes y
--     cleanup_minutes (>= 0).
--   - procedure_cases: EXCLUDE ex_procedure_cases_operating_room_time. La base rechaza dos casos
--     en estado que ocupa el quirófano (programado, listo, en curso) cuyos rangos [inicio, fin)
--     se solapan en el mismo operating_room_id: lo que periop-cases.service ya comprobaba.
--   - scheduling.booking_policies: no_show_fee_percentage (0..100) y no_show_retains_deposit.
--   - scheduling.practitioner_service_offerings.pre_visit_instructions y
--     appointment_bookings.pre_visit_instructions_snapshot.
--
-- PRECONDICIÓN: el EXCLUDE falla si hoy hay dos casos solapados en la misma sala en un estado que
-- ocupa el quirófano. El patch lo comprueba antes y aborta con un mensaje; el BEGIN hace rollback
-- de todo. Resolver (reprogramar o cancelar uno de los dos) y volver a aplicar. SIN BACKFILL.
-- No se declara el solape de consultorios (ORG-CON-004): clinical.appointments no tiene espacio y
-- el recurso de un cupo (scheduling.bookable_slots.resource_id) puede ser un profesional o una
-- sala con capacidad mayor que 1; un EXCLUDE ahí cambiaría reglas de agenda. Sigue en el issue #58.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +13 · NOT NULL quitados 0 · FKs +5 · índices +5 (-0) · constraints +4
-- ============================================================================

BEGIN;

DO $$
DECLARE
    solapados integer;
BEGIN
    SELECT count(*) INTO solapados
      FROM "procedures_perioperative"."procedure_cases" a
      JOIN "procedures_perioperative"."procedure_cases" b
        ON a."operating_room_id" = b."operating_room_id"
       AND a."id" < b."id"
       AND tstzrange(a."scheduled_start_at", a."scheduled_end_at", '[)') && tstzrange(b."scheduled_start_at", b."scheduled_end_at", '[)')
     WHERE a."operating_room_id" IS NOT NULL
       AND a."scheduled_start_at" IS NOT NULL AND a."scheduled_end_at" IS NOT NULL
       AND b."scheduled_start_at" IS NOT NULL AND b."scheduled_end_at" IS NOT NULL
       AND a."status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203')
       AND b."status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203');
    IF solapados > 0 THEN
        RAISE EXCEPTION 'procedure_cases tiene % par(es) de casos solapados en el mismo quirófano: resolverlos antes de crear el EXCLUDE', solapados;
    END IF;
END $$;

ALTER TABLE "directory"."tenant_memberships"
    ADD COLUMN IF NOT EXISTS "workday_concept_id" uuid;

ALTER TABLE "directory"."tenant_memberships"
    ADD COLUMN IF NOT EXISTS "responsible_user_id" uuid;

ALTER TABLE "directory"."branch_memberships"
    ADD COLUMN IF NOT EXISTS "workday_concept_id" uuid;

ALTER TABLE "directory"."branch_memberships"
    ADD COLUMN IF NOT EXISTS "responsible_user_id" uuid;

ALTER TABLE "practice"."clinical_units"
    ADD COLUMN IF NOT EXISTS "responsible_user_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "prep_minutes" integer;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "cleanup_minutes" integer;

ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "prep_minutes" integer;

ALTER TABLE "procedures_perioperative"."procedure_cases"
    ADD COLUMN IF NOT EXISTS "cleanup_minutes" integer;

ALTER TABLE "scheduling"."booking_policies"
    ADD COLUMN IF NOT EXISTS "no_show_fee_percentage" numeric;

ALTER TABLE "scheduling"."booking_policies"
    ADD COLUMN IF NOT EXISTS "no_show_retains_deposit" boolean DEFAULT false;

ALTER TABLE "scheduling"."practitioner_service_offerings"
    ADD COLUMN IF NOT EXISTS "pre_visit_instructions" text;

ALTER TABLE "scheduling"."appointment_bookings"
    ADD COLUMN IF NOT EXISTS "pre_visit_instructions_snapshot" text;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_workday_concept_id" FOREIGN KEY ("workday_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_workday_concept_id" ON "directory"."tenant_memberships" ("workday_concept_id");

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_responsible_user_id" FOREIGN KEY ("responsible_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_responsible_user_id" ON "directory"."tenant_memberships" ("responsible_user_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_workday_concept_id" FOREIGN KEY ("workday_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_workday_concept_id" ON "directory"."branch_memberships" ("workday_concept_id");

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."branch_memberships"
        ADD CONSTRAINT "fk_branch_memberships_responsible_user_id" FOREIGN KEY ("responsible_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_branch_memberships_responsible_user_id" ON "directory"."branch_memberships" ("responsible_user_id");

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."clinical_units"
        ADD CONSTRAINT "fk_clinical_units_responsible_user_id" FOREIGN KEY ("responsible_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_clinical_units_responsible_user_id" ON "practice"."clinical_units" ("responsible_user_id");

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ═══ care_spaces ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_buffers";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."procedure_cases" DROP CONSTRAINT IF EXISTS "ck_procedure_cases_buffers";
ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ck_procedure_cases_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));

-- ═══ procedure_cases ═══
--   EXCLUDE: operating room time overlap  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "procedures_perioperative"."procedure_cases" DROP CONSTRAINT IF EXISTS "ex_procedure_cases_operating_room_time";
ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ex_procedure_cases_operating_room_time"
    EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("scheduled_start_at", "scheduled_end_at", '[)') WITH &&) WHERE ("operating_room_id" IS NOT NULL AND "scheduled_start_at" IS NOT NULL AND "scheduled_end_at" IS NOT NULL AND "status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'));

-- ═══ booking_policies ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "scheduling"."booking_policies" DROP CONSTRAINT IF EXISTS "ck_booking_policies_no_show_fee_percentage";
ALTER TABLE "scheduling"."booking_policies" ADD CONSTRAINT "ck_booking_policies_no_show_fee_percentage" CHECK (("no_show_fee_percentage" IS NULL OR ("no_show_fee_percentage" >= 0 AND "no_show_fee_percentage" <= 100)));

COMMIT;
