-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5d (agenda de consultorios, parte
-- `scheduling`) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §F5d (repositorio de documentación)
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS / FK con
-- `duplicate_object`). Se puede aplicar N veces. Va DESPUÉS de
-- 2026-10-29_infraestructura_f4_quirofanos.sql (R0: schedulable_resources.care_space_id).
--
-- Contexto: gen_ddl.py ya emite esto en SQL/41_scheduling/ desde que diagram_41 lo declara.
-- Las sentencias de columnas, FKs e índices se copiaron de los archivos generados. Lo escrito a
-- mano: los ADD COLUMN y la verificación final.
--
-- QUÉ CIERRA.
--   A. scheduling.schedule_templates.care_space_id (FK → practice.care_spaces): horario por
--      espacio. NULL = la plantilla no reserva un espacio (lo de siempre). La API valida
--      tenant (404), función/perfil `schedulable` (422) y sede (422), y escribe
--      clinical.appointments.care_space_id desde la plantilla del cupo (la columna de la cita
--      y su EXCLUDE ex_appointments_care_space_time son de diagram_08 / M-F5-clin, no de acá).
--   B. scheduling.availability_exceptions.source_kind_concept_id (FK → catalog_concepts;
--      EXC_SRC_MANUAL | CARE_SPACE_BLOCK | EQUIPMENT_STATUS, conceptos de la API) y
--      source_ref_id (polimórfico: practice.care_space_blocks / diagnostic_units.
--      diagnostic_equipment; sin FK a propósito). Índice parcial por source_ref_id para que el
--      fin de un bloqueo encuentre sus excepciones.
--
-- LO QUE ESTE PATCH NO HACE.
--   - Sin backfill: las columnas son nuevas y NULL en todas las filas existentes, así que no
--     hay precondición que pueda fallar en el primer despliegue. Una excepción con
--     source_kind NULL se lee como manual (previa a este patch).
--   - No siembra conceptos EXC_SRC_* (los siembra la API).
--   - No toca RLS: schedule_templates no tiene tenant_id y availability_exceptions tampoco;
--     su aislamiento sigue siendo el del recurso (sin cambios).
--
-- DELTAS ESPERADOS: columnas +3 · FKs +2 · índices +3.
-- ============================================================================

BEGIN;

-- ------------------------------------------------------------- columnas
ALTER TABLE "scheduling"."schedule_templates"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "scheduling"."availability_exceptions"
    ADD COLUMN IF NOT EXISTS "source_kind_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "source_ref_id" uuid;

-- ------------------------------------------------------------- FKs
-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_templates"
        ADD CONSTRAINT "fk_schedule_templates_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "scheduling"."availability_exceptions"
        ADD CONSTRAINT "fk_availability_exceptions_source_kind_concept_id" FOREIGN KEY ("source_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- índices
CREATE INDEX IF NOT EXISTS "ix_schedule_templates_care_space_id" ON "scheduling"."schedule_templates" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_source_kind_concept_id" ON "scheduling"."availability_exceptions" ("source_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_source_ref" ON "scheduling"."availability_exceptions" ("source_ref_id") WHERE source_ref_id IS NOT NULL;

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_columnas integer;
    n_fk       integer;
    n_ix       integer;
BEGIN
    SELECT count(*) INTO n_columnas
      FROM information_schema.columns
     WHERE table_schema = 'scheduling'
       AND (table_name, column_name) IN (
            ('schedule_templates', 'care_space_id'),
            ('availability_exceptions', 'source_kind_concept_id'),
            ('availability_exceptions', 'source_ref_id'));

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname IN ('fk_schedule_templates_care_space_id',
                       'fk_availability_exceptions_source_kind_concept_id');

    SELECT count(*) INTO n_ix
      FROM pg_indexes
     WHERE schemaname = 'scheduling'
       AND indexname IN ('ix_schedule_templates_care_space_id',
                         'ix_availability_exceptions_source_kind_concept_id',
                         'ix_availability_exceptions_source_ref');

    IF n_columnas <> 3 OR n_fk <> 2 OR n_ix <> 3 THEN
        RAISE EXCEPTION 'F5d (agenda) incompleto: columnas=% (3), fk=% (2), índices=% (3)',
            n_columnas, n_fk, n_ix;
    END IF;

    RAISE NOTICE 'F5d (agenda) aplicado: 3 columnas, 2 FKs validadas, 3 índices.';
END $$;

COMMIT;
