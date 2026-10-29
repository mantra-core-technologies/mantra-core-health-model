-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5 (integración · schema clinical)
-- sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §F5b (puntos de toma) y §F5d (agenda de consultorios)
-- Requiere: 2026-10-29_infraestructura_f1.sql. Se aplica después del patch F3 de clinical.
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS / FK con
-- `duplicate_object` / DROP CONSTRAINT IF EXISTS antes del EXCLUDE). Se puede aplicar N veces.
--
-- Contexto: gen_ddl.py / gen_integrity.py ya emiten esto en SQL/08_clinical/ desde que
-- diagram_08 y diagram_33 lo declaran. Columnas, FKs, índices y EXCLUDE copiados de los
-- archivos generados; lo escrito a mano es la precondición y la verificación.
--
-- QUÉ CIERRA.
--   A. clinical.service_requests.suggested_care_space_id (F5b): punto de toma sugerido
--      (función SAMPLE_COLLECTION; la API valida sede y función, 422 COLLECTION_POINT_INVALID).
--   B. clinical.appointments.care_space_id (F5d) y ex_appointments_care_space_time: la
--      mitad «location» del EXCLUDE que en v4.2.3 quedó en prosa. Mismos dos estados que
--      ex_appointments_practitioner_time:
--        51530fd7-05b1-5c29-80c4-da740ede4d27  clinical:APPOINTMENT_BOOKED
--        37dded87-7a7a-5a24-86f6-0ef48cccb482  clinical:APPOINTMENT_CHECKED_IN
--      La API no escribe care_space_id en espacios allowOverlap (salas de espera,
--      gimnasio), así que el EXCLUDE no cambia reglas de recursos con capacidad > 1.
--
-- PRECONDICIÓN. La columna nace sin backfill, así que en el primer despliegue no puede
-- haber solapes. En una re-aplicación sí podría (si alguien escribió care_space_id con el
-- EXCLUDE caído): se cuentan y se aborta con RAISE EXCEPTION; el BEGIN hace rollback.
--
-- DELTAS ESPERADOS: columnas +2 · FKs +2 · índices +2 (+1 del EXCLUDE) · EXCLUDE +1
-- ============================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "suggested_care_space_id" uuid;

ALTER TABLE "clinical"."appointments"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

-- ------------------------------------------------------------- FKs (copiadas de 90_fk_deferred)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_suggested_care_space_id" FOREIGN KEY ("suggested_care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."appointments"
        ADD CONSTRAINT "fk_appointments_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- índices (copiados de 04_indexes)

CREATE INDEX IF NOT EXISTS "ix_service_requests_suggested_care_space_id" ON "clinical"."service_requests" ("suggested_care_space_id");

CREATE INDEX IF NOT EXISTS "ix_appointments_care_space_id" ON "clinical"."appointments" ("care_space_id");

-- ------------------------------------------------------------- precondición del EXCLUDE
DO $$
DECLARE
    n       bigint;
    detalle text;
BEGIN
    SELECT count(*), string_agg(format('espacio %s: %s × %s', a."care_space_id", a."id", b."id"), '; ')
      INTO n, detalle
      FROM "clinical"."appointments" a
      JOIN "clinical"."appointments" b
        ON b."care_space_id" = a."care_space_id" AND a."id" < b."id"
       AND tstzrange(a."start_at", a."end_at", '[)') && tstzrange(b."start_at", b."end_at", '[)')
     WHERE a."care_space_id" IS NOT NULL AND a."end_at" IS NOT NULL AND b."end_at" IS NOT NULL
       AND a."status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482')
       AND b."status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482');
    IF n > 0 THEN
        RAISE EXCEPTION 'clinical.appointments: % par(es) de citas vivas solapadas en el mismo espacio; no se crea ex_appointments_care_space_time. Detalle: %', n, left(detalle, 2000)
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

-- ------------------------------------------------------------- EXCLUDE (copiado de 05_constraints)
ALTER TABLE "clinical"."appointments" DROP CONSTRAINT IF EXISTS "ex_appointments_care_space_time";
ALTER TABLE "clinical"."appointments" ADD CONSTRAINT "ex_appointments_care_space_time"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH &&) WHERE ("care_space_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'));

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_col integer;
    n_fk  integer;
    n_ix  integer;
    n_ex  integer;
BEGIN
    SELECT count(*) INTO n_col FROM information_schema.columns
     WHERE table_schema = 'clinical'
       AND (table_name, column_name) IN (('service_requests', 'suggested_care_space_id'),
                                         ('appointments', 'care_space_id'));
    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_service_requests_suggested_care_space_id', 'fk_appointments_care_space_id');
    SELECT count(*) INTO n_ix FROM pg_indexes
     WHERE schemaname = 'clinical'
       AND indexname IN ('ix_service_requests_suggested_care_space_id', 'ix_appointments_care_space_id');
    SELECT count(*) INTO n_ex FROM pg_constraint
     WHERE contype = 'x' AND conname = 'ex_appointments_care_space_time';
    IF n_col <> 2 OR n_fk <> 2 OR n_ix <> 2 OR n_ex <> 1 THEN
        RAISE EXCEPTION 'F5 clinical incompleto: columnas=% (2), fk=% (2), índices=% (2), exclude=% (1)', n_col, n_fk, n_ix, n_ex;
    END IF;
    RAISE NOTICE 'F5 clinical aplicado: 2 columnas, 2 FKs validadas, 2 índices, ex_appointments_care_space_time.';
END $$;

COMMIT;
