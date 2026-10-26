-- ============================================================================
-- SALUD · patch v4.2.60 (pharmacy · P34 farmacias 24 h y de turno) sobre BD viva
-- Fecha: 2026-10-26
--
-- QUÉ ENTRA.
--   1. `pharmacy.pharmacy_sites.open_24h boolean NULL`. Nullable a propósito:
--      NULL es «no lo declaró», nunca «cierra de noche». Sin backfill: un `false`
--      por defecto convertiría el silencio de todo el padrón en una afirmación
--      falsa sobre cada farmacia.
--   2. Tabla nueva `pharmacy.pharmacy_on_call_shifts`: el turno de guardia de UNA
--      sede (no de una zona), con inicio y fin `timestamptz`, procedencia
--      (`source_concept_id`: la farmacia o la plataforma) y estado (activo /
--      cancelado). Se publica sólo mientras `starts_at <= now() < ends_at`.
--   3. CHECK `ck_pharmacy_on_call_shifts_window` (fin > inicio, ≤ 72 h) y EXCLUDE
--      `ex_pharmacy_on_call_shifts_site_overlap` (dos turnos activos de la misma sede
--      no se solapan). El UUID del estado activo es el determinista de
--      `pharmacy:ON_CALL_SHIFT_ACTIVE` (lo siembra la API al arrancar).
--
-- MODELO. Declarado en `diagram_24_pharmacy.puml` y `diagram_33_integrity.puml`; un
-- rebuild desde cero lo trae en SQL/24_pharmacy/0{2,3,4,5}_*.sql y 90_fk_deferred.
-- Este patch es sólo para bases ya aplicadas. Idempotente: IF NOT EXISTS, tolerancia
-- a duplicate_object, o DROP ... IF EXISTS + ADD para el CHECK y el EXCLUDE.
-- Requiere `btree_gist` (ya la usa `ex_appointments_practitioner_time`).
--
-- DELTAS ESPERADOS: columnas +1 · tablas +1 · FKs +5 · índices +8 (7 + PK) ·
-- constraints +2 (CHECK, EXCLUDE)
-- ============================================================================
BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE "pharmacy"."pharmacy_sites"
    ADD COLUMN IF NOT EXISTS "open_24h" boolean;

CREATE TABLE IF NOT EXISTS "pharmacy"."pharmacy_on_call_shifts" (
    "id" uuid NOT NULL,
    "pharmacy_site_id" uuid NOT NULL,
    "starts_at" timestamptz NOT NULL,
    "ends_at" timestamptz NOT NULL,
    "source_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pharmacy_on_call_shifts" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_on_call_shifts"
        ADD CONSTRAINT "fk_pharmacy_on_call_shifts_pharmacy_site_id" FOREIGN KEY ("pharmacy_site_id")
        REFERENCES "pharmacy"."pharmacy_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)


DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_on_call_shifts"
        ADD CONSTRAINT "fk_pharmacy_on_call_shifts_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_on_call_shifts"
        ADD CONSTRAINT "fk_pharmacy_on_call_shifts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_on_call_shifts"
        ADD CONSTRAINT "fk_pharmacy_on_call_shifts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacy_on_call_shifts"
        ADD CONSTRAINT "fk_pharmacy_on_call_shifts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_pharmacy_on_call_shifts_pharmacy_site_id" ON "pharmacy"."pharmacy_on_call_shifts" ("pharmacy_site_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_on_call_shifts_source_concept_id" ON "pharmacy"."pharmacy_on_call_shifts" ("source_concept_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_on_call_shifts_status_concept_id" ON "pharmacy"."pharmacy_on_call_shifts" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_on_call_shifts_created_by_user_id" ON "pharmacy"."pharmacy_on_call_shifts" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_on_call_shifts_updated_by_user_id" ON "pharmacy"."pharmacy_on_call_shifts" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_pharmacy_on_call_shifts_site_window" ON "pharmacy"."pharmacy_on_call_shifts" ("pharmacy_site_id", "ends_at" DESC, "starts_at");
CREATE INDEX IF NOT EXISTS "gist_pharmacy_on_call_shifts_window" ON "pharmacy"."pharmacy_on_call_shifts" USING gist (tstzrange(starts_at, ends_at, '[)'));

-- ═══ pharmacy_on_call_shifts ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" DROP CONSTRAINT IF EXISTS "ck_pharmacy_on_call_shifts_window";
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" ADD CONSTRAINT "ck_pharmacy_on_call_shifts_window" CHECK (("ends_at" > "starts_at" AND "ends_at" - "starts_at" <= interval '72 hours'));

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" DROP CONSTRAINT IF EXISTS "ex_pharmacy_on_call_shifts_site_overlap";
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" ADD CONSTRAINT "ex_pharmacy_on_call_shifts_site_overlap"
    EXCLUDE USING gist ("pharmacy_site_id" WITH =, tstzrange("starts_at", "ends_at", '[)') WITH &&) WHERE ("status_concept_id" = '14c92252-2ad8-576c-bc34-3ae2bbdb950d');

COMMIT;
