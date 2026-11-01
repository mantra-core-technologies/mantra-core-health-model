-- ============================================================================
-- SALUD · patch v4.2.68 (infraestructura hospitalaria F5e/F5f · facturación y contabilidad por espacio)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §F5e y §F5f, con los «Desvíos» de M-F2 (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1c_servicios.sql (usa su función
-- practice.fill_tenant_from_practice) y de 2026-10-29_infraestructura_f2_operacion.sql.
-- Un solo patch para los schemas practice, billing, accounting y audit (en lugar de los
-- …_f5_practice/_f5_billing/_f5_accounting de §6.3; ver «Desvíos»). Idempotente.
--
-- QUÉ AGREGA
--   practice.care_space_category_periods: categoría de cama por período, sin solapes por
--     espacio (EXCLUDE). Backfill: una fila por cama con bed_category_concept_id, desde su
--     created_at (sólo si el espacio no tiene ningún período).
--   billing.space_tariffs: tarifa día-cama / quirófano por tiempo con vigencia sin solapes
--     (EXCLUDE por práctica, tipo, categoría y sala), TARIFF_OR_TIME ⇒ unit_minutes > 0.
--     Su ítem de service_catalog es de la MISMA práctica (FK compuesta (practice_id,
--     service_catalog_id), SCOPED_BY del .puml, con UNIQUE (practice_id, id) en service_catalog).
--   billing.charge_captures: cargos devengados con idempotency_key único.
--   accounting.cost_centers.clinical_unit_id (+ un solo centro ACTIVO por unidad) y
--   accounting.infrastructure_items.care_space_id.
--   tenant_id en space_tariffs, cost_centers e infrastructure_items (no estaba en el contrato:
--     hace falta para atar las referencias a practice.* con FK compuesta (tenant_id, x_id),
--     el mismo mecanismo de F1b). Backfill desde practices.tenant_id; un trigger lo completa en
--     INSERT si la API no lo manda; (tenant_id, practice_id) → practices lo mantiene coherente.
--   audit.care_space_category_periods_history, space_tariffs_history, charge_captures_history
--     con el patrón de F1b. RLS tenant_isolation en todas las tablas con tenant_id nuevas.
--   charge_captures: encounters y invoice_lines no exponen (tenant_id, id); un trigger exige
--     que el encuentro sea del mismo tenant y paciente y que la línea de factura sea de una
--     factura de la misma práctica.
--
-- Conceptos (UUID literales; deterministicId de common/seed/concept-seed.ts):
--   25eb53f6-8006-5959-bee9-65b16117bc9b  billing:TARIFF_OR_TIME
--   38a1d301-f40d-5b17-a695-5e6d605f8b19  state:active (CONCEPTS.STATE_ACTIVE, estado activo
--                                         del centro de costo; ver «Desvíos»)
--
-- PRECONDICIONES (abortan sin tocar nada): filas sin tenant tras el backfill, referencias a
-- otro tenant, solapes de períodos/tarifas existentes, dos centros de costo activos por unidad.
-- ============================================================================

BEGIN;

SET LOCAL app.system_context = 'true';

DO $$
BEGIN
    IF to_regprocedure('practice.fill_tenant_from_practice()') IS NULL THEN
        RAISE EXCEPTION 'falta practice.fill_tenant_from_practice(): aplicar antes 2026-10-29_infraestructura_f1c_servicios.sql';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. columnas en tablas existentes
ALTER TABLE "accounting"."cost_centers"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

ALTER TABLE "accounting"."cost_centers"
    ADD COLUMN IF NOT EXISTS "clinical_unit_id" uuid;

ALTER TABLE "accounting"."infrastructure_items"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

ALTER TABLE "accounting"."infrastructure_items"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

-- ------------------------------------------------------------- 2. tablas nuevas (copiadas de 02_tables)
CREATE TABLE IF NOT EXISTS "practice"."care_space_category_periods" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "bed_category_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_space_category_periods" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."space_tariffs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "tariff_kind_concept_id" uuid NOT NULL,
    "bed_category_concept_id" uuid,
    "care_space_id" uuid,
    "service_catalog_id" uuid NOT NULL,
    "unit_minutes" integer,
    "minimum_units" integer,
    "unit_price" numeric(20,6),
    "currency_concept_id" uuid,
    "valid_from" date NOT NULL,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_space_tariffs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "billing"."charge_captures" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "source_kind_concept_id" uuid NOT NULL,
    "source_ref_id" uuid NOT NULL,
    "service_date" date NOT NULL,
    "care_space_id" uuid,
    "bed_category_concept_id" uuid,
    "space_tariff_id" uuid,
    "service_catalog_id" uuid,
    "quantity" numeric NOT NULL,
    "unit_price" numeric(20,6),
    "currency_concept_id" uuid,
    "cost_center_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "invoice_line_id" uuid,
    "void_reason" varchar,
    "idempotency_key" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_charge_captures" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."care_space_category_periods_history" (
    "history_id" uuid NOT NULL,
    "care_space_category_period_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_care_space_category_periods_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."space_tariffs_history" (
    "history_id" uuid NOT NULL,
    "space_tariff_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_space_tariffs_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."charge_captures_history" (
    "history_id" uuid NOT NULL,
    "charge_capture_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_charge_captures_history" PRIMARY KEY ("history_id")
);

-- ------------------------------------------------------------- 3. backfill
UPDATE "accounting"."cost_centers" c
   SET "tenant_id" = p."tenant_id"
  FROM "practice"."practices" p
 WHERE p."id" = c."practice_id" AND c."tenant_id" IS NULL;

UPDATE "accounting"."infrastructure_items" c
   SET "tenant_id" = p."tenant_id"
  FROM "practice"."practices" p
 WHERE p."id" = c."practice_id" AND c."tenant_id" IS NULL;

UPDATE "billing"."space_tariffs" c
   SET "tenant_id" = p."tenant_id"
  FROM "practice"."practices" p
 WHERE p."id" = c."practice_id" AND c."tenant_id" IS NULL;

-- Período inicial por cama con categoría (sólo espacios sin ningún período: idempotente).
INSERT INTO "practice"."care_space_category_periods"
       ("id", "tenant_id", "care_space_id", "bed_category_concept_id", "valid_from", "valid_to",
        "created_at", "updated_at", "row_version")
SELECT gen_random_uuid(), cs."tenant_id", cs."id", cs."bed_category_concept_id", cs."created_at", NULL,
       now(), now(), 1
  FROM "practice"."care_spaces" cs
 WHERE cs."bed_category_concept_id" IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM "practice"."care_space_category_periods" p WHERE p."care_space_id" = cs."id");

-- ------------------------------------------------------------- 4. precondiciones
DO $$
DECLARE
    n_null  integer;
    detalle text;
BEGIN
    SELECT string_agg(format('%s: %s', tabla, n), '; '), coalesce(sum(n), 0)
      INTO detalle, n_null
      FROM (SELECT 'accounting.cost_centers' AS tabla, count(*) AS n FROM "accounting"."cost_centers" WHERE "tenant_id" IS NULL
            UNION ALL
            SELECT 'accounting.infrastructure_items', count(*) FROM "accounting"."infrastructure_items" WHERE "tenant_id" IS NULL
            UNION ALL
            SELECT 'billing.space_tariffs', count(*) FROM "billing"."space_tariffs" WHERE "tenant_id" IS NULL) x
     WHERE n > 0;
    IF n_null > 0 THEN
        RAISE EXCEPTION 'v4.2.68 F5: % fila(s) sin tenant_id tras el backfill desde su práctica (%); corregirlas a mano y volver a aplicar.', n_null, detalle
            USING ERRCODE = 'not_null_violation';
    END IF;
END $$;

DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'cost_centers.clinical_unit_id', c."id" FROM "accounting"."cost_centers" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'infrastructure_items.care_space_id', c."id" FROM "accounting"."infrastructure_items" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'space_tariffs.care_space_id', c."id" FROM "billing"."space_tariffs" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'space_tariffs.service_catalog_id', c."id" FROM "billing"."space_tariffs" c
          JOIN "billing"."service_catalog" p ON p."id" = c."service_catalog_id" WHERE p."practice_id" <> c."practice_id"
        UNION ALL
        SELECT 'charge_captures.practice_id', c."id" FROM "billing"."charge_captures" c
          JOIN "practice"."practices" p ON p."id" = c."practice_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'charge_captures.care_space_id', c."id" FROM "billing"."charge_captures" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'charge_captures.space_tariff_id', c."id" FROM "billing"."charge_captures" c
          JOIN "billing"."space_tariffs" p ON p."id" = c."space_tariff_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'charge_captures.cost_center_id', c."id" FROM "billing"."charge_captures" c
          JOIN "accounting"."cost_centers" p ON p."id" = c."cost_center_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'charge_captures.encounter_id', c."id" FROM "billing"."charge_captures" c
          JOIN "clinical"."encounters" p ON p."id" = c."encounter_id" WHERE p."tenant_id" IS DISTINCT FROM c."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'v4.2.68 F5: hay referencias a un padre de OTRO tenant o práctica en % relación(es): %. Corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

DO $$
DECLARE
    n integer;
BEGIN
    SELECT count(*) INTO n
      FROM "practice"."care_space_category_periods" a
      JOIN "practice"."care_space_category_periods" b ON a."id" < b."id" AND a."care_space_id" = b."care_space_id"
     WHERE tstzrange(a."valid_from", a."valid_to", '[)') && tstzrange(b."valid_from", b."valid_to", '[)');
    IF n > 0 THEN
        RAISE EXCEPTION 'v4.2.68 ex_care_space_category_periods_validity: % par(es) de filas se solapan en "practice"."care_space_category_periods"; corregirlos a mano y volver a aplicar.', n
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

DO $$
DECLARE
    n integer;
BEGIN
    SELECT count(*) INTO n
      FROM "billing"."space_tariffs" a
      JOIN "billing"."space_tariffs" b ON a."id" < b."id" AND a."practice_id" = b."practice_id" AND a."tariff_kind_concept_id" = b."tariff_kind_concept_id" AND coalesce(a."bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid) = coalesce(b."bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid) AND coalesce(a."care_space_id", '00000000-0000-0000-0000-000000000000'::uuid) = coalesce(b."care_space_id", '00000000-0000-0000-0000-000000000000'::uuid)
     WHERE daterange(a."valid_from", a."valid_to", '[)') && daterange(b."valid_from", b."valid_to", '[)');
    IF n > 0 THEN
        RAISE EXCEPTION 'v4.2.68 ex_space_tariffs_validity: % par(es) de filas se solapan en "billing"."space_tariffs"; corregirlos a mano y volver a aplicar.', n
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

DO $$
DECLARE
    n integer;
BEGIN
    SELECT count(*) INTO n FROM (
        SELECT "clinical_unit_id" FROM "accounting"."cost_centers"
         WHERE "clinical_unit_id" IS NOT NULL AND "status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
         GROUP BY 1 HAVING count(*) > 1) d;
    IF n > 0 THEN
        RAISE EXCEPTION 'v4.2.68 ux_cost_centers_unit_active: % unidad(es) con más de un centro de costo activo; resolver a mano y volver a aplicar.', n
            USING ERRCODE = 'unique_violation';
    END IF;
END $$;

ALTER TABLE "accounting"."cost_centers" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "accounting"."infrastructure_items" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- 5. índices (copiados de 04_indexes)
CREATE INDEX IF NOT EXISTS "ix_cost_centers_tenant_id" ON "accounting"."cost_centers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cost_centers_clinical_unit_id" ON "accounting"."cost_centers" ("clinical_unit_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cost_centers_tenant_id_id" ON "accounting"."cost_centers" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cost_centers_unit_active" ON "accounting"."cost_centers" ("clinical_unit_id") WHERE clinical_unit_id IS NOT NULL AND status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_tenant_id" ON "accounting"."infrastructure_items" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_infrastructure_items_care_space_id" ON "accounting"."infrastructure_items" ("care_space_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_service_catalog_practice_id_id" ON "billing"."service_catalog" ("practice_id", "id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_tenant_id" ON "practice"."care_space_category_periods" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_care_space_id" ON "practice"."care_space_category_periods" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_bed_category_concept_id" ON "practice"."care_space_category_periods" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_created_by_user_id" ON "practice"."care_space_category_periods" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_updated_by_user_id" ON "practice"."care_space_category_periods" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_space_category_periods_tenant_id_id" ON "practice"."care_space_category_periods" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_tenant_id" ON "billing"."space_tariffs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_practice_id" ON "billing"."space_tariffs" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_tariff_kind_concept_id" ON "billing"."space_tariffs" ("tariff_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_bed_category_concept_id" ON "billing"."space_tariffs" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_care_space_id" ON "billing"."space_tariffs" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_service_catalog_id" ON "billing"."space_tariffs" ("service_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_currency_concept_id" ON "billing"."space_tariffs" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_status_concept_id" ON "billing"."space_tariffs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_created_by_user_id" ON "billing"."space_tariffs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_updated_by_user_id" ON "billing"."space_tariffs" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_tariffs_tenant_id_id" ON "billing"."space_tariffs" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_charge_captures_idempotency_key" ON "billing"."charge_captures" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_tenant_id" ON "billing"."charge_captures" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_practice_id" ON "billing"."charge_captures" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_patient_profile_id" ON "billing"."charge_captures" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_encounter_id" ON "billing"."charge_captures" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_source_kind_concept_id" ON "billing"."charge_captures" ("source_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_care_space_id" ON "billing"."charge_captures" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_bed_category_concept_id" ON "billing"."charge_captures" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_space_tariff_id" ON "billing"."charge_captures" ("space_tariff_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_service_catalog_id" ON "billing"."charge_captures" ("service_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_currency_concept_id" ON "billing"."charge_captures" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_cost_center_id" ON "billing"."charge_captures" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_status_concept_id" ON "billing"."charge_captures" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_invoice_line_id" ON "billing"."charge_captures" ("invoice_line_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_created_by_user_id" ON "billing"."charge_captures" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_updated_by_user_id" ON "billing"."charge_captures" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_encounter_status" ON "billing"."charge_captures" ("encounter_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_charge_captures_tenant_id_id" ON "billing"."charge_captures" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_history_care_space_cate_fc6e2c97" ON "audit"."care_space_category_periods_history" ("care_space_category_period_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_history_operation_concept_id" ON "audit"."care_space_category_periods_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_history_changed_by_user_id" ON "audit"."care_space_category_periods_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_history_change_reason_concept_id" ON "audit"."care_space_category_periods_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_care_space_category_periods_history_recorded_at" ON "audit"."care_space_category_periods_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_history_tenant_id" ON "audit"."care_space_category_periods_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_history_space_tariff_id" ON "audit"."space_tariffs_history" ("space_tariff_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_history_operation_concept_id" ON "audit"."space_tariffs_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_history_changed_by_user_id" ON "audit"."space_tariffs_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_history_change_reason_concept_id" ON "audit"."space_tariffs_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_space_tariffs_history_recorded_at" ON "audit"."space_tariffs_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_history_tenant_id" ON "audit"."space_tariffs_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_history_charge_capture_id" ON "audit"."charge_captures_history" ("charge_capture_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_history_operation_concept_id" ON "audit"."charge_captures_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_history_changed_by_user_id" ON "audit"."charge_captures_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_history_change_reason_concept_id" ON "audit"."charge_captures_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_charge_captures_history_recorded_at" ON "audit"."charge_captures_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_charge_captures_history_tenant_id" ON "audit"."charge_captures_history" ("tenant_id");

-- ------------------------------------------------------------- 6. FK simples y SCOPED_BY (copiadas de 03_fk_intra / 90_fk_deferred)
-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."cost_centers"
        ADD CONSTRAINT "fk_cost_centers_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "accounting"."infrastructure_items"
        ADD CONSTRAINT "fk_infrastructure_items_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."care_space_category_periods"
        ADD CONSTRAINT "fk_care_space_category_periods_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_tariff_kind_concept_id" FOREIGN KEY ("tariff_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- compuesta: billing.space_tariffs sólo apunta a billing.service_catalog del mismo practice_id
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_service_catalog_id" FOREIGN KEY ("practice_id", "service_catalog_id")
        REFERENCES "billing"."service_catalog" ("practice_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_space_tariff_id" FOREIGN KEY ("space_tariff_id")
        REFERENCES "billing"."space_tariffs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_invoice_line_id" FOREIGN KEY ("invoice_line_id")
        REFERENCES "billing"."invoice_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practices (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_source_kind_concept_id" FOREIGN KEY ("source_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: billing.charge_captures sólo apunta a billing.service_catalog del mismo practice_id
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_service_catalog_id" FOREIGN KEY ("practice_id", "service_catalog_id")
        REFERENCES "billing"."service_catalog" ("practice_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: accounting.cost_centers (requiere schema accounting)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_cost_center_id" FOREIGN KEY ("cost_center_id")
        REFERENCES "accounting"."cost_centers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_space_category_periods (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_category_periods_history"
        ADD CONSTRAINT "fk_care_space_category_periods_history_care_space_cate_9048acce" FOREIGN KEY ("care_space_category_period_id")
        REFERENCES "practice"."care_space_category_periods" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_category_periods_history"
        ADD CONSTRAINT "fk_care_space_category_periods_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_category_periods_history"
        ADD CONSTRAINT "fk_care_space_category_periods_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_category_periods_history"
        ADD CONSTRAINT "fk_care_space_category_periods_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."care_space_category_periods_history"
        ADD CONSTRAINT "fk_care_space_category_periods_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: billing.space_tariffs (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "audit"."space_tariffs_history"
        ADD CONSTRAINT "fk_space_tariffs_history_space_tariff_id" FOREIGN KEY ("space_tariff_id")
        REFERENCES "billing"."space_tariffs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."space_tariffs_history"
        ADD CONSTRAINT "fk_space_tariffs_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."space_tariffs_history"
        ADD CONSTRAINT "fk_space_tariffs_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."space_tariffs_history"
        ADD CONSTRAINT "fk_space_tariffs_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."space_tariffs_history"
        ADD CONSTRAINT "fk_space_tariffs_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: billing.charge_captures (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "audit"."charge_captures_history"
        ADD CONSTRAINT "fk_charge_captures_history_charge_capture_id" FOREIGN KEY ("charge_capture_id")
        REFERENCES "billing"."charge_captures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."charge_captures_history"
        ADD CONSTRAINT "fk_charge_captures_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."charge_captures_history"
        ADD CONSTRAINT "fk_charge_captures_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."charge_captures_history"
        ADD CONSTRAINT "fk_charge_captures_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."charge_captures_history"
        ADD CONSTRAINT "fk_charge_captures_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 7. FK compuestas por tenant (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id). MATCH SIMPLE: si x_id es NULL no se exige nada.
-- Conviven con la FK simple generada (mismo mecanismo que 2026-10-29_infraestructura_f1b_seguridad.sql).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.care_space_category_periods',     'fk_care_space_category_periods_tenant_space',         'care_space_id',                'practice.care_spaces'),
            ('billing.space_tariffs',                    'fk_space_tariffs_tenant_practice',                    'practice_id',                  'practice.practices'),
            ('billing.space_tariffs',                    'fk_space_tariffs_tenant_space',                       'care_space_id',                'practice.care_spaces'),
            ('billing.charge_captures',                  'fk_charge_captures_tenant_practice',                  'practice_id',                  'practice.practices'),
            ('billing.charge_captures',                  'fk_charge_captures_tenant_space',                     'care_space_id',                'practice.care_spaces'),
            ('billing.charge_captures',                  'fk_charge_captures_tenant_tariff',                    'space_tariff_id',              'billing.space_tariffs'),
            ('billing.charge_captures',                  'fk_charge_captures_tenant_cost_center',               'cost_center_id',               'accounting.cost_centers'),
            ('accounting.cost_centers',                  'fk_cost_centers_tenant_practice',                     'practice_id',                  'practice.practices'),
            ('accounting.cost_centers',                  'fk_cost_centers_tenant_unit',                         'clinical_unit_id',             'practice.clinical_units'),
            ('accounting.infrastructure_items',          'fk_infrastructure_items_tenant_practice',             'practice_id',                  'practice.practices'),
            ('accounting.infrastructure_items',          'fk_infrastructure_items_tenant_space',                'care_space_id',                'practice.care_spaces'),
            ('audit.care_space_category_periods_history','fk_care_space_category_periods_history_tenant_source','care_space_category_period_id','practice.care_space_category_periods'),
            ('audit.space_tariffs_history',              'fk_space_tariffs_history_tenant_source',              'space_tariff_id',              'billing.space_tariffs'),
            ('audit.charge_captures_history',            'fk_charge_captures_history_tenant_source',            'charge_capture_id',            'billing.charge_captures')
        ) AS v(hijo, nombre, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 8. integridad (copiada de 05_constraints, módulo 33)
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ═══ care_space_category_periods ═══
--   EXCLUDE: one bed category per space and time  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "practice"."care_space_category_periods" DROP CONSTRAINT IF EXISTS "ex_care_space_category_periods_validity";
ALTER TABLE "practice"."care_space_category_periods" ADD CONSTRAINT "ex_care_space_category_periods_validity"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH &&);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_category_periods" DROP CONSTRAINT IF EXISTS "ck_care_space_category_periods_valid_period";
ALTER TABLE "practice"."care_space_category_periods" ADD CONSTRAINT "ck_care_space_category_periods_valid_period" CHECK (("valid_to" IS NULL OR "valid_to" > "valid_from"));

-- ═══ space_tariffs ═══
--   EXCLUDE: one tariff per practice, kind, bed category, room and date  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ex_space_tariffs_validity";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ex_space_tariffs_validity"
    EXCLUDE USING gist ("practice_id" WITH =, "tariff_kind_concept_id" WITH =, coalesce("bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid) WITH =, coalesce("care_space_id", '00000000-0000-0000-0000-000000000000'::uuid) WITH =, daterange("valid_from", "valid_to", '[)') WITH &&);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_or_time_unit_minutes";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_or_time_unit_minutes" CHECK (("tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR ("unit_minutes" IS NOT NULL AND "unit_minutes" > 0)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "billing"."space_tariffs" DROP CONSTRAINT IF EXISTS "ck_space_tariffs_valid_period";
ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_valid_period" CHECK (("valid_to" IS NULL OR "valid_to" > "valid_from"));

-- ------------------------------------------------------------- 9. triggers
-- 9a. tenant por defecto desde la práctica (función de F1c).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN SELECT * FROM (VALUES
            ('accounting.cost_centers'),
            ('accounting.infrastructure_items'),
            ('billing.space_tariffs'),
            ('billing.charge_captures')
        ) AS v(tabla)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_fill_tenant_from_practice ON %s', r.tabla);
        EXECUTE format('CREATE TRIGGER trg_fill_tenant_from_practice BEFORE INSERT ON %s FOR EACH ROW EXECUTE FUNCTION "practice"."fill_tenant_from_practice"()', r.tabla);
    END LOOP;
END $$;

-- 9b. charge_captures: referencias sin (tenant_id, id) en el destino. SECURITY INVOKER: con RLS,
-- un encuentro de otro tenant no se ve y cae en el mismo error genérico (23503).
CREATE OR REPLACE FUNCTION "billing"."charge_captures_assert_refs"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    t_enc uuid;
    p_enc uuid;
    pr_inv uuid;
BEGIN
    IF NEW."encounter_id" IS NOT NULL THEN
        SELECT e."tenant_id", e."patient_profile_id" INTO t_enc, p_enc
          FROM "clinical"."encounters" e WHERE e."id" = NEW."encounter_id";
        IF t_enc IS DISTINCT FROM NEW."tenant_id" OR p_enc IS DISTINCT FROM NEW."patient_profile_id" THEN
            RAISE EXCEPTION 'charge_captures.encounter_id: el encuentro no existe para ese paciente en el tenant del cargo'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    IF NEW."invoice_line_id" IS NOT NULL THEN
        SELECT i."practice_id" INTO pr_inv
          FROM "billing"."invoice_lines" il
          JOIN "billing"."invoices" i ON i."id" = il."invoice_id"
         WHERE il."id" = NEW."invoice_line_id";
        IF pr_inv IS DISTINCT FROM NEW."practice_id" THEN
            RAISE EXCEPTION 'charge_captures.invoice_line_id: la línea no es de una factura de la práctica del cargo'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_charge_captures_refs" ON "billing"."charge_captures";
CREATE TRIGGER "trg_charge_captures_refs"
    BEFORE INSERT OR UPDATE OF "tenant_id", "practice_id", "patient_profile_id", "encounter_id", "invoice_line_id"
    ON "billing"."charge_captures"
    FOR EACH ROW EXECUTE FUNCTION "billing"."charge_captures_assert_refs"();

-- 9c. historia: tenant por defecto y sólo inserción.
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
            ('care_space_category_periods_history', 'practice.care_space_category_periods', 'care_space_category_period_id'),
            ('space_tariffs_history', 'billing.space_tariffs', 'space_tariff_id'),
            ('charge_captures_history', 'billing.charge_captures', 'charge_capture_id')
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

-- ------------------------------------------------------------- 10. privilegios y RLS
DO $$
DECLARE
    t text;
    tablas text[] := ARRAY[
        'practice.care_space_category_periods',
        'billing.space_tariffs',
        'billing.charge_captures',
        'accounting.cost_centers',
        'accounting.infrastructure_items',
        'audit.care_space_category_periods_history',
        'audit.space_tariffs_history',
        'audit.charge_captures_history'
    ];
    completas text[] := ARRAY[
        'practice.care_space_category_periods',
        'billing.space_tariffs',
        'billing.charge_captures'
    ]::text[];
    solo_insercion text[] := ARRAY[]::text[];
    historias text[] := ARRAY[
        'audit.care_space_category_periods_history',
        'audit.space_tariffs_history',
        'audit.charge_captures_history'
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

-- ------------------------------------------------------------- 11. verificación
DO $$
DECLARE
    n_tab integer;
    n_nn  integer;
    n_fkc integer;
    n_sco integer;
    n_con integer;
    n_ux  integer;
    n_trg integer;
    n_rls integer;
    n_upd integer;
BEGIN
    SELECT count(*) INTO n_tab FROM unnest(ARRAY['practice.care_space_category_periods', 'billing.space_tariffs',
            'billing.charge_captures', 'audit.care_space_category_periods_history', 'audit.space_tariffs_history',
            'audit.charge_captures_history']) t WHERE to_regclass(t) IS NOT NULL;
    SELECT count(*) INTO n_nn FROM information_schema.columns
     WHERE column_name = 'tenant_id' AND is_nullable = 'NO'
       AND (table_schema, table_name) IN (('accounting', 'cost_centers'), ('accounting', 'infrastructure_items'),
            ('billing', 'space_tariffs'), ('billing', 'charge_captures'), ('practice', 'care_space_category_periods'));
    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_care_space_category_periods_tenant_space', 'fk_space_tariffs_tenant_practice',
            'fk_space_tariffs_tenant_space', 'fk_charge_captures_tenant_practice', 'fk_charge_captures_tenant_space',
            'fk_charge_captures_tenant_tariff', 'fk_charge_captures_tenant_cost_center', 'fk_cost_centers_tenant_practice',
            'fk_cost_centers_tenant_unit', 'fk_infrastructure_items_tenant_practice', 'fk_infrastructure_items_tenant_space',
            'fk_care_space_category_periods_history_tenant_source', 'fk_space_tariffs_history_tenant_source',
            'fk_charge_captures_history_tenant_source');
    SELECT count(*) INTO n_sco FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_space_tariffs_service_catalog_id', 'fk_charge_captures_service_catalog_id');
    SELECT count(*) INTO n_con FROM pg_constraint
     WHERE conname IN ('ex_care_space_category_periods_validity', 'ck_care_space_category_periods_valid_period',
            'ex_space_tariffs_validity', 'ck_space_tariffs_or_time_unit_minutes', 'ck_space_tariffs_valid_period');
    SELECT count(*) INTO n_ux FROM pg_indexes
     WHERE indexname IN ('ux_service_catalog_practice_id_id', 'ux_cost_centers_unit_active', 'ux_cost_centers_tenant_id_id',
            'uq_charge_captures_idempotency_key', 'ux_space_tariffs_tenant_id_id', 'ux_charge_captures_tenant_id_id',
            'ux_care_space_category_periods_tenant_id_id');
    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal
       AND ((tgname = 'trg_fill_tenant_from_practice' AND tgrelid IN ('accounting.cost_centers'::regclass,
                'accounting.infrastructure_items'::regclass, 'billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass))
         OR (tgname = 'trg_charge_captures_refs')
         OR (tgname IN ('trg_fill_tenant', 'trg_close_only') AND tgrelid IN ('audit.care_space_category_periods_history'::regclass,
                'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass)));
    SELECT count(*) INTO n_rls FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE (n.nspname, c.relname) IN (('practice', 'care_space_category_periods'), ('billing', 'space_tariffs'),
            ('billing', 'charge_captures'), ('accounting', 'cost_centers'), ('accounting', 'infrastructure_items'),
            ('audit', 'care_space_category_periods_history'), ('audit', 'space_tariffs_history'), ('audit', 'charge_captures_history'))
       AND c.relrowsecurity AND c.relforcerowsecurity;
    n_upd := 0;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_upd FROM unnest(ARRAY['audit.care_space_category_periods_history',
                'audit.space_tariffs_history', 'audit.charge_captures_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE') OR has_table_privilege('mantra_app', t, 'DELETE');
    END IF;
    IF n_tab <> 6 OR n_nn <> 5 OR n_fkc <> 14 OR n_sco <> 2 OR n_con <> 5 OR n_ux <> 7 OR n_trg <> 11
       OR n_rls <> 8 OR n_upd <> 0 THEN
        RAISE EXCEPTION 'v4.2.68 F5 incompleto: tablas=% (6), tenant NOT NULL=% (5), FK compuestas por tenant=% (14), FK por práctica=% (2), CHECK/EXCLUDE=% (5), únicos=% (7), triggers=% (11), RLS=% (8), historia con UPDATE/DELETE=% (0)',
            n_tab, n_nn, n_fkc, n_sco, n_con, n_ux, n_trg, n_rls, n_upd;
    END IF;
    RAISE NOTICE 'v4.2.68 F5 aplicado: períodos de categoría, tarifas de espacio sin solape, cargos devengados idempotentes, centro de costo por unidad y activo por espacio; 14 FK compuestas por tenant y RLS.';
END $$;

COMMIT;
