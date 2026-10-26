-- ============================================================================
-- SALUD · patch v4.2.53 (clinical · P40, carril C2) sobre BD viva
-- Fecha: 2026-10-26
--
-- QUÉ ENTRA. Tabla puente nueva `clinical.service_request_notes`: las notas
-- médicas (`chart.clinical_note_headers`) que motivan una orden de análisis
-- (`clinical.service_requests`). Es el `basedOnNoteIds` de
-- `POST /clinical/service-requests`. Append-only, con la forma de
-- `clinical.observation_performers`: id, las dos FK, `ordinal` (el orden en que
-- el médico citó las notas), `created_at` y `created_by_user_id`.
--
-- POR QUÉ TABLA Y NO `uuid[]`. Un arreglo no admite FK: una nota borrada o
-- inventada quedaría colgando sin que la base lo note. El modelo ya usa tablas
-- hijas para las relaciones N:M de una observación (performers, notes).
--
-- QUÉ NO VA ACÁ. Que la nota sea del mismo paciente y del mismo encuentro que
-- la orden lo valida la API (422), igual que `form_instance_id` (P43): cruzar
-- dos esquemas en un CHECK exigiría un trigger que el modelo no declara.
-- La categoría textual (`LAB | IMAGING | OTHER`) tampoco: se resuelve contra
-- `category_concept_id`, que ya existe; el concepto `SR_OTHER` lo siembra el
-- catálogo de conceptos de la API (`seed:boot`), no un DDL.
--
-- MODELO. Declarado en `diagram_08_clinical.puml`; un rebuild desde cero lo trae
-- en SQL/08_clinical/0{2,3,4}_*.sql y 90_fk_deferred.sql. Este patch es sólo para
-- bases ya aplicadas. Idempotente: cada sentencia es IF NOT EXISTS o tolera
-- duplicate_object.
--
-- DELTAS ESPERADOS: tablas +1 · FKs +3 · índices +5 (PK + UNIQUE + 3 IX)
-- ============================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS "clinical"."service_request_notes" (
    "id" uuid NOT NULL,
    "service_request_id" uuid NOT NULL,
    "clinical_note_header_id" uuid NOT NULL,
    "ordinal" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_service_request_notes" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "clinical"."service_request_notes"
        ADD CONSTRAINT "fk_service_request_notes_service_request_id" FOREIGN KEY ("service_request_id")
        REFERENCES "clinical"."service_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_request_notes"
        ADD CONSTRAINT "fk_service_request_notes_clinical_note_header_id" FOREIGN KEY ("clinical_note_header_id")
        REFERENCES "chart"."clinical_note_headers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_request_notes"
        ADD CONSTRAINT "fk_service_request_notes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_service_request_notes_request_note" ON "clinical"."service_request_notes" ("service_request_id", "clinical_note_header_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_notes_service_request_id" ON "clinical"."service_request_notes" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_notes_clinical_note_header_id" ON "clinical"."service_request_notes" ("clinical_note_header_id");

CREATE INDEX IF NOT EXISTS "ix_service_request_notes_created_by_user_id" ON "clinical"."service_request_notes" ("created_by_user_id");

COMMIT;
