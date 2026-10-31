-- ============================================================================
-- SALUD · patch v4.2.68 (infraestructura hospitalaria F2 · operación de espacios)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §F2.1, con los «Desvíos» de M-F2 (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1b_seguridad.sql y de
-- 2026-10-29_infraestructura_f1c_servicios.sql. Idempotente: se puede aplicar N veces.
--
-- QUÉ AGREGA
--   practice.care_spaces: tres ejes manuales del estado operativo (disponibilidad =
--     operational_status_concept_id + motivo/fin estimado/momento; higiene; aislamiento),
--     terminal_cleaning_required (NOT NULL DEFAULT false) y ops_version (NOT NULL DEFAULT 1,
--     versión operativa separada de row_version).
--   practice.care_space_status_events (A20): append-only — guarda de inmutabilidad
--     (integrity.forbid_mutation), CHECK del código v2-0116, mantra_app sólo SELECT/INSERT.
--   practice.care_space_blocks: EXCLUDE sin solapes por espacio (no cancelados; fin NULL =
--     abierto), mantenimiento con fecha estimada obligatoria, fin posterior al inicio.
--   practice.cleaning_orders: una sola orden abierta (PENDING|IN_PROGRESS|DONE) por espacio
--     (índice único parcial) e inspector ≠ quien terminó.
--   audit.care_space_blocks_history y audit.cleaning_orders_history con el patrón de F1b.
--   FK compuestas (tenant_id, x_id) hacia practice.* (mismo tenant), RLS tenant_isolation.
--
-- Lo que expresa el .puml (tablas, columnas, FK simples, índices) se copió del SQL generado
-- (SQL/14_practice, SQL/10_audit); CHECK/EXCLUDE/guardas, de SQL/14_practice/05_constraints.sql
-- (módulo 33). Lo que ningún generador expresa va sólo acá: FK compuestas, DEFAULT de
-- ops_version, backfills, triggers de historia, privilegios y RLS.
--
-- Conceptos (UUID = deterministicId('practice:<NOMBRE>') de common/seed/concept-seed.ts):
--   7ce5a926-1c46-56d4-8ca8-679e7429fa1d  SPACE_OP_AVAILABLE
--   7874b037-177f-5cac-adad-e7ba679d9ad3  HYG_CLEAN
--   f2ead1d9-06f7-59a3-b26f-a3642a164f47  ISO_NONE
--   b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0  BLOCK_MAINTENANCE
--   c0c5918f-cf97-51e1-9ede-72d856e61c93  CLN_PENDING
--   60ff8df8-4ba5-591c-b092-e8da81187539  CLN_IN_PROGRESS
--   334b9e1f-b123-5477-a22e-2dd1b838c2fa  CLN_DONE
-- Los backfills de disponibilidad/higiene/aislamiento sólo corren si el concepto ya está
-- sembrado en terminology.catalog_concepts (la FK lo exige; los siembra la API). Si no está,
-- la columna queda NULL y la API la completa: reaplicar este patch después del seed también
-- la completa.
--
-- PRECONDICIONES (abortan sin tocar nada): solapes de bloqueos existentes, más de una orden de
-- limpieza abierta por espacio, referencias a un padre de otro tenant.
-- ============================================================================

BEGIN;

SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 1. care_spaces: columnas
ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "availability_reason_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "availability_expected_until" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "availability_changed_at" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "hygiene_status_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "hygiene_changed_at" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "terminal_cleaning_required" boolean;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "isolation_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "isolation_organism_text" varchar;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "isolation_changed_at" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "ops_version" integer;

-- DEFAULT explícitos (en una base creada desde SQL/ la columna ya existe sin DEFAULT de
-- ops_version: gen_ddl sólo emite el de row_version y los booleanos declarados).
ALTER TABLE "practice"."care_spaces" ALTER COLUMN "terminal_cleaning_required" SET DEFAULT false;
ALTER TABLE "practice"."care_spaces" ALTER COLUMN "ops_version" SET DEFAULT 1;
UPDATE "practice"."care_spaces" SET "terminal_cleaning_required" = false WHERE "terminal_cleaning_required" IS NULL;
UPDATE "practice"."care_spaces" SET "ops_version" = 1 WHERE "ops_version" IS NULL;
ALTER TABLE "practice"."care_spaces" ALTER COLUMN "terminal_cleaning_required" SET NOT NULL;
ALTER TABLE "practice"."care_spaces" ALTER COLUMN "ops_version" SET NOT NULL;

-- Backfill condicionado a que el concepto exista (ver cabecera).
UPDATE "practice"."care_spaces"
   SET "operational_status_concept_id" = '7ce5a926-1c46-56d4-8ca8-679e7429fa1d'  -- SPACE_OP_AVAILABLE
 WHERE "operational_status_concept_id" IS NULL
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" WHERE "id" = '7ce5a926-1c46-56d4-8ca8-679e7429fa1d');
UPDATE "practice"."care_spaces"
   SET "hygiene_status_concept_id" = '7874b037-177f-5cac-adad-e7ba679d9ad3'  -- HYG_CLEAN
 WHERE "hygiene_status_concept_id" IS NULL
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" WHERE "id" = '7874b037-177f-5cac-adad-e7ba679d9ad3');
UPDATE "practice"."care_spaces"
   SET "isolation_concept_id" = 'f2ead1d9-06f7-59a3-b26f-a3642a164f47'  -- ISO_NONE
 WHERE "isolation_concept_id" IS NULL
   AND EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" WHERE "id" = 'f2ead1d9-06f7-59a3-b26f-a3642a164f47');

-- ------------------------------------------------------------- 2. tablas nuevas (copiadas de 02_tables)
CREATE TABLE IF NOT EXISTS "practice"."care_space_status_events" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "axis_concept_id" uuid NOT NULL,
    "from_concept_id" uuid,
    "to_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "reason_text" varchar,
    "expected_until" timestamptz,
    "v2_0116_code" char(1) NOT NULL,
    "source_concept_id" uuid NOT NULL,
    "source_ref_id" uuid,
    "occurred_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    "request_id" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_care_space_status_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."care_space_blocks" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "reason_text" varchar,
    "starts_at" timestamptz NOT NULL,
    "expected_end_at" timestamptz,
    "ended_at" timestamptz,
    "ended_by_user_id" uuid,
    "end_note" varchar,
    "cancelled_at" timestamptz,
    "cancel_reason" varchar,
    "work_order_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_space_blocks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."cleaning_orders" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "clinical_unit_id" uuid,
    "cleaning_type_concept_id" uuid NOT NULL,
    "trigger_concept_id" uuid NOT NULL,
    "source_ref_id" uuid,
    "previous_order_id" uuid,
    "priority_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "due_at" timestamptz,
    "assigned_user_id" uuid,
    "started_at" timestamptz,
    "started_by_user_id" uuid,
    "finished_at" timestamptz,
    "finished_by_user_id" uuid,
    "inspected_at" timestamptz,
    "inspected_by_user_id" uuid,
    "inspection_result_concept_id" uuid,
    "rejection_reason" varchar,
    "cancel_reason" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_cleaning_orders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."care_space_blocks_history" (
    "history_id" uuid NOT NULL,
    "care_space_block_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_care_space_blocks_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."cleaning_orders_history" (
    "history_id" uuid NOT NULL,
    "cleaning_order_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_cleaning_orders_history" PRIMARY KEY ("history_id")
);

-- ------------------------------------------------------------- 3. precondiciones
DO $$
DECLARE
    n integer;
BEGIN
    SELECT count(*) INTO n
      FROM "practice"."care_space_blocks" a
      JOIN "practice"."care_space_blocks" b ON a."id" < b."id" AND a."care_space_id" = b."care_space_id"
     WHERE tstzrange(a."starts_at", a."ended_at", '[)') && tstzrange(b."starts_at", b."ended_at", '[)') AND a."cancelled_at" IS NULL AND b."cancelled_at" IS NULL;
    IF n > 0 THEN
        RAISE EXCEPTION 'v4.2.68 ex_care_space_blocks_time: % par(es) de filas se solapan en "practice"."care_space_blocks"; corregirlos a mano y volver a aplicar.', n
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

DO $$
DECLARE
    n integer;
BEGIN
    SELECT count(*) INTO n FROM (
        SELECT "care_space_id" FROM "practice"."cleaning_orders"
         WHERE "status_concept_id" IN ('c0c5918f-cf97-51e1-9ede-72d856e61c93', '60ff8df8-4ba5-591c-b092-e8da81187539', '334b9e1f-b123-5477-a22e-2dd1b838c2fa')
         GROUP BY 1 HAVING count(*) > 1) d;
    IF n > 0 THEN
        RAISE EXCEPTION 'v4.2.68 ux_cleaning_orders_one_open_per_space: % espacio(s) con más de una orden de limpieza abierta; cerrarlas a mano y volver a aplicar.', n
            USING ERRCODE = 'unique_violation';
    END IF;
END $$;

DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'care_space_status_events.care_space_id', c."id" FROM "practice"."care_space_status_events" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_space_status_events.practice_site_id', c."id" FROM "practice"."care_space_status_events" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'care_space_blocks.care_space_id', c."id" FROM "practice"."care_space_blocks" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.care_space_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.practice_site_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.clinical_unit_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'cleaning_orders.previous_order_id', c."id" FROM "practice"."cleaning_orders" c
          JOIN "practice"."cleaning_orders" p ON p."id" = c."previous_order_id" WHERE p."tenant_id" <> c."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'v4.2.68: hay referencias a un padre de OTRO tenant en % relación(es): %. Corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- ------------------------------------------------------------- 4. índices (copiados de 04_indexes)
CREATE INDEX IF NOT EXISTS "ix_care_spaces_availability_reason_concept_id" ON "practice"."care_spaces" ("availability_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_hygiene_status_concept_id" ON "practice"."care_spaces" ("hygiene_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_isolation_concept_id" ON "practice"."care_spaces" ("isolation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_tenant_id" ON "practice"."care_space_status_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_space_occurred" ON "practice"."care_space_status_events" ("care_space_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_site_occurred" ON "practice"."care_space_status_events" ("practice_site_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_axis_concept_id" ON "practice"."care_space_status_events" ("axis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_from_concept_id" ON "practice"."care_space_status_events" ("from_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_to_concept_id" ON "practice"."care_space_status_events" ("to_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_reason_concept_id" ON "practice"."care_space_status_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_source_concept_id" ON "practice"."care_space_status_events" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_recorded_by_user_id" ON "practice"."care_space_status_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_tenant_id" ON "practice"."care_space_blocks" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_care_space_id" ON "practice"."care_space_blocks" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_kind_concept_id" ON "practice"."care_space_blocks" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_reason_concept_id" ON "practice"."care_space_blocks" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_ended_by_user_id" ON "practice"."care_space_blocks" ("ended_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_created_by_user_id" ON "practice"."care_space_blocks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_updated_by_user_id" ON "practice"."care_space_blocks" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_space_blocks_tenant_id_id" ON "practice"."care_space_blocks" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_tenant_id" ON "practice"."cleaning_orders" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_practice_site_id" ON "practice"."cleaning_orders" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_care_space_id" ON "practice"."cleaning_orders" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_clinical_unit_id" ON "practice"."cleaning_orders" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_cleaning_type_concept_id" ON "practice"."cleaning_orders" ("cleaning_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_trigger_concept_id" ON "practice"."cleaning_orders" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_previous_order_id" ON "practice"."cleaning_orders" ("previous_order_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_priority_concept_id" ON "practice"."cleaning_orders" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_status_concept_id" ON "practice"."cleaning_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_assigned_user_id" ON "practice"."cleaning_orders" ("assigned_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_started_by_user_id" ON "practice"."cleaning_orders" ("started_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_finished_by_user_id" ON "practice"."cleaning_orders" ("finished_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_inspected_by_user_id" ON "practice"."cleaning_orders" ("inspected_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_inspection_result_concept_id" ON "practice"."cleaning_orders" ("inspection_result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_created_by_user_id" ON "practice"."cleaning_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_updated_by_user_id" ON "practice"."cleaning_orders" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_site_status_requested" ON "practice"."cleaning_orders" ("practice_site_id", "status_concept_id", "requested_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cleaning_orders_tenant_id_id" ON "practice"."cleaning_orders" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cleaning_orders_one_open_per_space" ON "practice"."cleaning_orders" ("care_space_id") WHERE status_concept_id IN ('c0c5918f-cf97-51e1-9ede-72d856e61c93', '60ff8df8-4ba5-591c-b092-e8da81187539', '334b9e1f-b123-5477-a22e-2dd1b838c2fa');

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_care_space_block_id" ON "audit"."care_space_blocks_history" ("care_space_block_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_operation_concept_id" ON "audit"."care_space_blocks_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_changed_by_user_id" ON "audit"."care_space_blocks_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_change_reason_concept_id" ON "audit"."care_space_blocks_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_care_space_blocks_history_recorded_at" ON "audit"."care_space_blocks_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_history_tenant_id" ON "audit"."care_space_blocks_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_cleaning_order_id" ON "audit"."cleaning_orders_history" ("cleaning_order_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_operation_concept_id" ON "audit"."cleaning_orders_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_changed_by_user_id" ON "audit"."cleaning_orders_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_change_reason_concept_id" ON "audit"."cleaning_orders_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_cleaning_orders_history_recorded_at" ON "audit"."cleaning_orders_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_history_tenant_id" ON "audit"."cleaning_orders_history" ("tenant_id");

-- ------------------------------------------------------------- 5. FK simples (copiadas de 03_fk_intra / 90_fk_deferred)
-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_availability_reason_concept_id" FOREIGN KEY ("availability_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_hygiene_status_concept_id" FOREIGN KEY ("hygiene_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_isolation_concept_id" FOREIGN KEY ("isolation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_axis_concept_id" FOREIGN KEY ("axis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_from_concept_id" FOREIGN KEY ("from_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_to_concept_id" FOREIGN KEY ("to_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_status_events"
        ADD CONSTRAINT "fk_care_space_status_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_ended_by_user_id" FOREIGN KEY ("ended_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_blocks"
        ADD CONSTRAINT "fk_care_space_blocks_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_previous_order_id" FOREIGN KEY ("previous_order_id")
        REFERENCES "practice"."cleaning_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_cleaning_type_concept_id" FOREIGN KEY ("cleaning_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_trigger_concept_id" FOREIGN KEY ("trigger_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_assigned_user_id" FOREIGN KEY ("assigned_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_started_by_user_id" FOREIGN KEY ("started_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_finished_by_user_id" FOREIGN KEY ("finished_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_inspected_by_user_id" FOREIGN KEY ("inspected_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_inspection_result_concept_id" FOREIGN KEY ("inspection_result_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."cleaning_orders"
        ADD CONSTRAINT "fk_cleaning_orders_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_space_blocks (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_care_space_block_id" FOREIGN KEY ("care_space_block_id")
        REFERENCES "practice"."care_space_blocks" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_blocks_history"
        ADD CONSTRAINT "fk_care_space_blocks_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.cleaning_orders (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_cleaning_order_id" FOREIGN KEY ("cleaning_order_id")
        REFERENCES "practice"."cleaning_orders" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."cleaning_orders_history"
        ADD CONSTRAINT "fk_cleaning_orders_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 6. FK compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id). MATCH SIMPLE: si x_id es NULL no se exige nada.
-- Conviven con la FK simple generada (mismo mecanismo que 2026-10-29_infraestructura_f1b_seguridad.sql).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.care_space_status_events','fk_care_space_status_events_tenant_space',  'care_space_id',      'practice.care_spaces'),
            ('practice.care_space_status_events','fk_care_space_status_events_tenant_site',   'practice_site_id',   'practice.practice_sites'),
            ('practice.care_space_blocks',       'fk_care_space_blocks_tenant_space',         'care_space_id',      'practice.care_spaces'),
            ('practice.cleaning_orders',         'fk_cleaning_orders_tenant_space',           'care_space_id',      'practice.care_spaces'),
            ('practice.cleaning_orders',         'fk_cleaning_orders_tenant_site',            'practice_site_id',   'practice.practice_sites'),
            ('practice.cleaning_orders',         'fk_cleaning_orders_tenant_unit',            'clinical_unit_id',   'practice.clinical_units'),
            ('practice.cleaning_orders',         'fk_cleaning_orders_tenant_previous',        'previous_order_id',  'practice.cleaning_orders'),
            ('audit.care_space_blocks_history',  'fk_care_space_blocks_history_tenant_source','care_space_block_id','practice.care_space_blocks'),
            ('audit.cleaning_orders_history',    'fk_cleaning_orders_history_tenant_source',  'cleaning_order_id',  'practice.cleaning_orders')
        ) AS v(hijo, nombre, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 7. integridad (copiada de 05_constraints, módulo 33)
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ═══ care_space_status_events ═══
--   UPDATE_DELETE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_status_events" DROP CONSTRAINT IF EXISTS "ck_care_space_status_events_v2_0116_code";
ALTER TABLE "practice"."care_space_status_events" ADD CONSTRAINT "ck_care_space_status_events_v2_0116_code" CHECK ("v2_0116_code" IN ('C','H','I','K','O','U','R'));

-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "practice"."care_space_status_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "practice"."care_space_status_events";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "practice"."care_space_status_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ═══ care_space_blocks ═══
--   EXCLUDE: one non-cancelled block per space and time  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ex_care_space_blocks_time";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ex_care_space_blocks_time"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("starts_at", "ended_at", '[)') WITH &&) WHERE ("cancelled_at" IS NULL);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ck_care_space_blocks_maintenance_eta";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ck_care_space_blocks_maintenance_eta" CHECK (("kind_concept_id" <> 'b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0' OR "expected_end_at" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ck_care_space_blocks_end_after_start";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ck_care_space_blocks_end_after_start" CHECK ((("ended_at" IS NULL OR "ended_at" > "starts_at") AND ("expected_end_at" IS NULL OR "expected_end_at" > "starts_at")));

-- ═══ cleaning_orders ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."cleaning_orders" DROP CONSTRAINT IF EXISTS "ck_cleaning_orders_inspector_differs";
ALTER TABLE "practice"."cleaning_orders" ADD CONSTRAINT "ck_cleaning_orders_inspector_differs" CHECK (("inspected_by_user_id" IS NULL OR "inspected_by_user_id" <> "finished_by_user_id"));

-- ------------------------------------------------------------- 8. historia: tenant por defecto y sólo inserción
-- Funciones de F1b: audit.structure_history_fill_tenant (tenant desde el origen si la API no
-- lo manda) y audit.structure_history_close_only (sin DELETE; UPDATE sólo para cerrar valid_to una vez).
DO $$
DECLARE
    r record;
BEGIN
    IF to_regprocedure('audit.structure_history_fill_tenant()') IS NULL
       OR to_regprocedure('audit.structure_history_close_only()') IS NULL THEN
        RAISE EXCEPTION 'faltan las funciones de historia de F1b: aplicar antes 2026-10-29_infraestructura_f1b_seguridad.sql';
    END IF;
    FOR r IN
        SELECT * FROM (VALUES
            ('care_space_blocks_history', 'practice.care_space_blocks', 'care_space_block_id'),
            ('cleaning_orders_history', 'practice.cleaning_orders', 'cleaning_order_id')
        ) AS v(historia, origen, columna)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_fill_tenant ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_fill_tenant BEFORE INSERT ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_fill_tenant"(%L, %L)',
                       r.historia, r.origen, r.columna);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_close_only ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_close_only BEFORE UPDATE OR DELETE ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_close_only"()',
                       r.historia);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 9. privilegios y RLS
DO $$
DECLARE
    t text;
    tablas text[] := ARRAY[
        'practice.care_space_status_events',
        'practice.care_space_blocks',
        'practice.cleaning_orders',
        'audit.care_space_blocks_history',
        'audit.cleaning_orders_history'
    ];
    completas text[] := ARRAY[
        'practice.care_space_blocks',
        'practice.cleaning_orders'
    ]::text[];
    solo_insercion text[] := ARRAY[
        'practice.care_space_status_events'
    ]::text[];
    historias text[] := ARRAY[
        'audit.care_space_blocks_history',
        'audit.cleaning_orders_history'
    ]::text[];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY completas LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %s TO mantra_app', t);
        END LOOP;
        -- append-only: SELECT e INSERT; nada de UPDATE/DELETE/TRUNCATE (la guarda de
        -- inmutabilidad también los rechaza, incluso al dueño).
        FOREACH t IN ARRAY solo_insercion LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
        END LOOP;
        -- historia: SELECT, INSERT y UPDATE sólo de valid_to (mismo criterio que F1b).
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    FOREACH t IN ARRAY tablas LOOP
        EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %s FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %s', t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %s
          USING (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, t);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 10. verificación
DO $$
DECLARE
    n_cols integer;
    n_nn   integer;
    n_def  integer;
    n_tab  integer;
    n_fkc  integer;
    n_con  integer;
    n_ux   integer;
    n_trg  integer;
    n_rls  integer;
    n_upd  integer;
BEGIN
    SELECT count(*) INTO n_cols FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'care_spaces'
       AND column_name IN ('availability_reason_concept_id', 'availability_expected_until', 'availability_changed_at',
            'hygiene_status_concept_id', 'hygiene_changed_at', 'terminal_cleaning_required', 'isolation_concept_id',
            'isolation_organism_text', 'isolation_changed_at', 'ops_version');
    SELECT count(*) INTO n_nn FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'care_spaces' AND is_nullable = 'NO'
       AND column_name IN ('terminal_cleaning_required', 'ops_version');
    SELECT count(*) INTO n_def FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'care_spaces'
       AND ((column_name = 'terminal_cleaning_required' AND column_default = 'false')
         OR (column_name = 'ops_version' AND column_default = '1'));
    SELECT count(*) INTO n_tab FROM unnest(ARRAY['practice.care_space_status_events', 'practice.care_space_blocks',
            'practice.cleaning_orders', 'audit.care_space_blocks_history', 'audit.cleaning_orders_history']) t
     WHERE to_regclass(t) IS NOT NULL;
    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_care_space_status_events_tenant_space', 'fk_care_space_status_events_tenant_site',
            'fk_care_space_blocks_tenant_space', 'fk_cleaning_orders_tenant_space', 'fk_cleaning_orders_tenant_site',
            'fk_cleaning_orders_tenant_unit', 'fk_cleaning_orders_tenant_previous',
            'fk_care_space_blocks_history_tenant_source', 'fk_cleaning_orders_history_tenant_source');
    SELECT count(*) INTO n_con FROM pg_constraint
     WHERE conname IN ('ck_care_space_status_events_v2_0116_code', 'ex_care_space_blocks_time',
            'ck_care_space_blocks_maintenance_eta', 'ck_care_space_blocks_end_after_start',
            'ck_cleaning_orders_inspector_differs');
    SELECT count(*) INTO n_ux FROM pg_indexes
     WHERE schemaname = 'practice' AND indexname IN ('ux_cleaning_orders_one_open_per_space',
            'ux_cleaning_orders_tenant_id_id', 'ux_care_space_blocks_tenant_id_id');
    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal
       AND ((tgname = 'trg_forbid_mutation' AND tgrelid = 'practice.care_space_status_events'::regclass)
         OR (tgname IN ('trg_fill_tenant', 'trg_close_only')
             AND tgrelid IN ('audit.care_space_blocks_history'::regclass, 'audit.cleaning_orders_history'::regclass)));
    SELECT count(*) INTO n_rls FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE (n.nspname, c.relname) IN (('practice', 'care_space_status_events'), ('practice', 'care_space_blocks'),
            ('practice', 'cleaning_orders'), ('audit', 'care_space_blocks_history'), ('audit', 'cleaning_orders_history'))
       AND c.relrowsecurity AND c.relforcerowsecurity;
    n_upd := 0;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_upd FROM unnest(ARRAY['practice.care_space_status_events',
                'audit.care_space_blocks_history', 'audit.cleaning_orders_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE') OR has_table_privilege('mantra_app', t, 'DELETE');
    END IF;
    IF n_cols <> 10 OR n_nn <> 2 OR n_def <> 2 OR n_tab <> 5 OR n_fkc <> 9 OR n_con <> 5 OR n_ux <> 3
       OR n_trg <> 5 OR n_rls <> 5 OR n_upd <> 0 THEN
        RAISE EXCEPTION 'v4.2.68 F2 incompleto: columnas=% (10), NOT NULL=% (2), DEFAULT=% (2), tablas=% (5), FK compuestas=% (9), CHECK/EXCLUDE=% (5), únicos=% (3), triggers=% (5), RLS=% (5), UPDATE/DELETE de mantra_app en append-only/historia=% (0)',
            n_cols, n_nn, n_def, n_tab, n_fkc, n_con, n_ux, n_trg, n_rls, n_upd;
    END IF;
    RAISE NOTICE 'v4.2.68 F2 aplicado: ejes operativos en care_spaces, eventos A20 append-only, bloqueos sin solape, una orden de limpieza abierta por espacio, 9 FK compuestas por tenant y RLS.';
END $$;

COMMIT;
