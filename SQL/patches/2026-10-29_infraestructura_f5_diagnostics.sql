-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5 (integración · schema diagnostics)
-- sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §F5a (imagenología, Scheduled Procedure Step) y §F5b (toma)
-- Requiere: 2026-10-29_infraestructura_f1.sql. Idempotente (ADD COLUMN IF NOT EXISTS /
-- CREATE INDEX IF NOT EXISTS / FK con `duplicate_object`). Se puede aplicar N veces.
--
-- Contexto: gen_ddl.py ya emite esto en SQL/20_diagnostics/ desde que diagram_20 lo
-- declara. Columnas, FKs e índices copiados de los archivos generados; a mano sólo la
-- verificación. Sin backfill: columnas nuevas y nulas (collection_site_id se conserva).
--
-- QUÉ CIERRA.
--   A. diagnostics.specimen_collection_events.collection_care_space_id (F5b): espacio
--      físico de la toma.
--   B. diagnostics.imaging_procedure_steps.scheduled_equipment_id, scheduled_care_space_id,
--      scheduled_start_at (F5a): Scheduled Procedure Step para la Modality Worklist.
--
-- DELTAS ESPERADOS: columnas +4 · FKs +3 · índices +3
-- ============================================================================

BEGIN;

ALTER TABLE "diagnostics"."specimen_collection_events"
    ADD COLUMN IF NOT EXISTS "collection_care_space_id" uuid;

ALTER TABLE "diagnostics"."imaging_procedure_steps"
    ADD COLUMN IF NOT EXISTS "scheduled_equipment_id" uuid;

ALTER TABLE "diagnostics"."imaging_procedure_steps"
    ADD COLUMN IF NOT EXISTS "scheduled_care_space_id" uuid;

ALTER TABLE "diagnostics"."imaging_procedure_steps"
    ADD COLUMN IF NOT EXISTS "scheduled_start_at" timestamptz;

-- ------------------------------------------------------------- FKs (copiadas de 90_fk_deferred)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."specimen_collection_events"
        ADD CONSTRAINT "fk_specimen_collection_events_collection_care_space_id" FOREIGN KEY ("collection_care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: diagnostic_units.diagnostic_equipment (requiere schema diagnostic_units)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_scheduled_equipment_id" FOREIGN KEY ("scheduled_equipment_id")
        REFERENCES "diagnostic_units"."diagnostic_equipment" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "diagnostics"."imaging_procedure_steps"
        ADD CONSTRAINT "fk_imaging_procedure_steps_scheduled_care_space_id" FOREIGN KEY ("scheduled_care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- índices (copiados de 04_indexes)

CREATE INDEX IF NOT EXISTS "ix_specimen_collection_events_collection_care_space_id" ON "diagnostics"."specimen_collection_events" ("collection_care_space_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_scheduled_equipment_id" ON "diagnostics"."imaging_procedure_steps" ("scheduled_equipment_id");

CREATE INDEX IF NOT EXISTS "ix_imaging_procedure_steps_scheduled_care_space_id" ON "diagnostics"."imaging_procedure_steps" ("scheduled_care_space_id", "scheduled_start_at");

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_col integer;
    n_fk  integer;
    n_ix  integer;
BEGIN
    SELECT count(*) INTO n_col FROM information_schema.columns
     WHERE table_schema = 'diagnostics'
       AND (table_name, column_name) IN (('specimen_collection_events', 'collection_care_space_id'),
                                         ('imaging_procedure_steps', 'scheduled_equipment_id'),
                                         ('imaging_procedure_steps', 'scheduled_care_space_id'),
                                         ('imaging_procedure_steps', 'scheduled_start_at'));
    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_specimen_collection_events_collection_care_space_id',
                       'fk_imaging_procedure_steps_scheduled_equipment_id',
                       'fk_imaging_procedure_steps_scheduled_care_space_id');
    SELECT count(*) INTO n_ix FROM pg_indexes
     WHERE schemaname = 'diagnostics'
       AND indexname IN ('ix_specimen_collection_events_collection_care_space_id',
                         'ix_imaging_procedure_steps_scheduled_equipment_id',
                         'ix_imaging_procedure_steps_scheduled_care_space_id');
    IF n_col <> 4 OR n_fk <> 3 OR n_ix <> 3 THEN
        RAISE EXCEPTION 'F5 diagnostics incompleto: columnas=% (4), fk=% (3), índices=% (3)', n_col, n_fk, n_ix;
    END IF;
    RAISE NOTICE 'F5 diagnostics aplicado: 4 columnas, 3 FKs validadas, 3 índices.';
END $$;

COMMIT;
