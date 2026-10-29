-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F5e · facturación de día-cama por regla de
-- medianoche y de uso de quirófano por tiempo (tarifas versionadas y cargos devengados)
-- sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §F5e, procesos/11-facturacion-dia-cama-y-uso-de-quirofano.md
--   (repositorio de documentación) · agente M-F5-fin
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1b_seguridad.sql (UNIQUE (tenant_id, id) de
-- practices y care_spaces; funciones audit.structure_history_*) y de
-- 2026-10-29_infraestructura_f5_accounting.sql (ux_cost_centers_practice_id_id): lo comprueba y
-- aborta. En orden alfabético (el de postgres-init) accounting < billing. Idempotente (CREATE …
-- IF NOT EXISTS / FK con `duplicate_object` / CHECK y EXCLUDE sólo si faltan / CREATE OR
-- REPLACE / DROP TRIGGER IF EXISTS). Se puede aplicar N veces; la segunda pasada no cambia nada.
--
-- Contexto: tablas, índices y FK los emite gen_ddl.py en SQL/17_billing y SQL/10_audit desde
-- que diagram_17 y diagram_10 los declaran; los CHECK y el EXCLUDE los emite gen_integrity.py
-- en SQL/17_billing/05_constraints.sql desde diagram_33. Esas sentencias se copiaron del
-- generador. Lo escrito a mano: las comprobaciones previas, los triggers de guarda, los de
-- historia, el RLS y la verificación final. gen_apply.py no escanea SQL/patches/: no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA.
--   billing.space_tariffs: tarifa versionada de día-cama (por categoría de cama o de una sala) y
--     de quirófano por tiempo. Una tarifa vigente por (práctica, tipo, categoría, sala) en cada
--     fecha (ex_space_tariffs_validity). tenant_id para el RLS; FK compuestas (tenant_id,
--     practice_id), (tenant_id, care_space_id) y (practice_id, service_catalog_id): no cruza
--     tenants ni toma un servicio de otra práctica.
--   billing.charge_captures: cargo devengado, ANTES de facturar. Lo genera el sistema desde la
--     ocupación (un día-cama por cada medianoche) o desde el caso quirúrgico; unit_price es la
--     foto de la tarifa vigente. Doble cobro imposible en la base:
--       ux_charge_captures_idempotency_key  (tenant_id, idempotency_key)
--       ux_charge_captures_encounter_bed_day (encounter_id, service_date)  — un día-cama por
--                                            encuentro y noche mientras no esté anulado
--       ux_charge_captures_bed_night        (care_space_id, service_date)  — una cama no se cobra
--                                            dos veces la misma noche (el mínimo de «ingreso y
--                                            egreso el mismo día», minimum_stay_charge, no es una
--                                            noche y queda fuera)
--       ux_charge_captures_or_case          (source_ref_id) — un cargo de quirófano por caso
--   audit.space_tariffs_history y audit.charge_captures_history: mismo molde endurecido que
--     care_spaces_history (F1b): tenant_id NOT NULL con RLS, FK compuesta al origen, trigger que
--     completa el tenant, solo inserción más cierre de valid_to.
--   ux_service_catalog_practice_id_id: la FK compuesta (practice_id, service_catalog_id).
--   Triggers de guarda (billing.space_tariffs_guard, billing.charge_captures_guard): ver cada
--     función. Resumen: nada se borra; una tarifa usada no se reescribe; un cargo emitido no se
--     edita (sólo se anula con motivo); el cargo trae la foto exacta de su tarifa, vigente en
--     service_date; encuentro, paciente, cama y línea de factura son del mismo tenant/práctica.
--   RLS tenant_isolation (texto exacto de 2026-08-05_tenant_rls.sql) y GRANT sin DELETE.
--
-- UUID literales (el predicado de un índice parcial / CHECK debe ser IMMUTABLE), todos
-- `deterministicId('billing:<NOMBRE>')` de la API (common/constants/concepts.ts), verificados con
-- el algoritmo de la API. Los conceptos los define billing.concepts.ts con ESAS claves; si la API
-- usa otras, estos literales cambian JUNTO con diagram_17 / diagram_33:
--   1ae01bf6-a061-52ed-aa26-590705cb2202  billing:TARIFF_BED_DAY
--   25eb53f6-8006-5959-bee9-65b16117bc9b  billing:TARIFF_OR_TIME
--   5f84ea44-b0d3-582c-86c1-32c81e422d30  billing:CHG_SRC_BED_DAY
--   a79361f6-8787-56a5-9a90-a9436d02e217  billing:CHG_SRC_OR_TIME
--   17def99a-0cb5-586c-a440-59d809709c0d  billing:CHG_PENDING
--   9af061be-6a80-51ed-bcbd-52533037c272  billing:CHG_INVOICED
--   f2f59654-d912-5eeb-b619-814e50a3c4d0  billing:CHG_VOIDED
--
-- LO QUE ESTE PATCH NO HACE.
--   - No genera cargos: la regla de medianoche, la categoría vigente en cada medianoche, el
--     mínimo de un día, el redondeo del quirófano y el centro de costo los calcula el servicio
--     (POST /internal/billing/bed-day-charges/run). Aquí sólo se garantiza que no haya doble
--     cobro y que cada cargo sea coherente con su tarifa.
--   - No comprueba que service_date/care_space_id/bed_category_concept_id de un día-cama
--     coincidan con la ocupación (encounter_locations) ni con el período de categoría de esa
--     medianoche: source_ref_id es polimórfico (ocupación o caso) y no admite FK.
--   - No siembra conceptos (TARIFF_*, CHG_*) ni valores de billing.bed_day_min_one.
--   - No toca billing.invoices ni invoice_lines (sólo las referencia).
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - falta ux_cost_centers_practice_id_id (aplicar antes …_f5_accounting.sql) o las funciones
--     audit.structure_history_fill_tenant / structure_history_close_only (aplicar antes F1b);
--   - tarifas existentes que se solapan en la misma clase.
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   tablas +4 (2 de negocio, 2 de historia) · FK +35 (10 compuestas) · CHECK +17 · EXCLUDE +1
--   índices únicos parciales +3 · triggers +6 · políticas RLS +4
-- ============================================================================

BEGIN;

-- Las comprobaciones leen tablas con RLS forzada (practice.*, clinical.*, billing.*).
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ------------------------------------------------------------- 0. dependencias de otros patches
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'accounting'
                    AND indexname = 'ux_cost_centers_practice_id_id') THEN
        RAISE EXCEPTION 'F5e facturación: falta accounting.ux_cost_centers_practice_id_id; aplicar antes 2026-10-29_infraestructura_f5_accounting.sql'
            USING ERRCODE = 'undefined_object';
    END IF;
    IF to_regprocedure('audit.structure_history_fill_tenant()') IS NULL
       OR to_regprocedure('audit.structure_history_close_only()') IS NULL THEN
        RAISE EXCEPTION 'F5e facturación: faltan las funciones audit.structure_history_*; aplicar antes 2026-10-29_infraestructura_f1b_seguridad.sql'
            USING ERRCODE = 'undefined_function';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. único (practice_id, id) del catálogo
-- (de SQL/17_billing/04_indexes.sql) La FK compuesta de las tarifas lo necesita; es trivialmente
-- único porque id ya lo es.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_service_catalog_practice_id_id" ON "billing"."service_catalog" ("practice_id", "id");

-- ------------------------------------------------------------- 2. tablas
-- (de SQL/17_billing/02_tables.sql y SQL/10_audit/02_tables.sql)
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
    "unit_price" numeric(20,6) NOT NULL,
    "currency_concept_id" uuid NOT NULL,
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
    "encounter_id" uuid NOT NULL,
    "source_kind_concept_id" uuid NOT NULL,
    "source_ref_id" uuid NOT NULL,
    "service_date" date NOT NULL,
    "care_space_id" uuid,
    "bed_category_concept_id" uuid,
    "space_tariff_id" uuid,
    "service_catalog_id" uuid,
    "minimum_stay_charge" boolean NOT NULL,
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

-- ------------------------------------------------------------- 3. índices
-- (de SQL/17_billing/04_indexes.sql y SQL/10_audit/04_indexes.sql)
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

CREATE INDEX IF NOT EXISTS "ix_space_tariffs_lookup" ON "billing"."space_tariffs" ("practice_id", "tariff_kind_concept_id", "valid_from" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_tariffs_practice_id_id" ON "billing"."space_tariffs" ("practice_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_tariffs_tenant_id_id" ON "billing"."space_tariffs" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_tenant_id" ON "billing"."charge_captures" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_practice_id" ON "billing"."charge_captures" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_patient_profile_id" ON "billing"."charge_captures" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_encounter_status" ON "billing"."charge_captures" ("encounter_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_source_kind_concept_id" ON "billing"."charge_captures" ("source_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_source_ref_id" ON "billing"."charge_captures" ("source_ref_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_care_space_id" ON "billing"."charge_captures" ("care_space_id", "service_date");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_bed_category_concept_id" ON "billing"."charge_captures" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_space_tariff_id" ON "billing"."charge_captures" ("space_tariff_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_service_catalog_id" ON "billing"."charge_captures" ("service_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_currency_concept_id" ON "billing"."charge_captures" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_cost_center_id" ON "billing"."charge_captures" ("cost_center_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_status_concept_id" ON "billing"."charge_captures" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_invoice_line_id" ON "billing"."charge_captures" ("invoice_line_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_created_by_user_id" ON "billing"."charge_captures" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_charge_captures_updated_by_user_id" ON "billing"."charge_captures" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_charge_captures_tenant_id_id" ON "billing"."charge_captures" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_charge_captures_idempotency_key" ON "billing"."charge_captures" ("tenant_id", "idempotency_key");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_charge_captures_bed_night" ON "billing"."charge_captures" ("care_space_id", "service_date") WHERE source_kind_concept_id = '5f84ea44-b0d3-582c-86c1-32c81e422d30' AND minimum_stay_charge = false AND status_concept_id <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0';

CREATE UNIQUE INDEX IF NOT EXISTS "ux_charge_captures_encounter_bed_day" ON "billing"."charge_captures" ("encounter_id", "service_date") WHERE source_kind_concept_id = '5f84ea44-b0d3-582c-86c1-32c81e422d30' AND status_concept_id <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0';

CREATE UNIQUE INDEX IF NOT EXISTS "ux_charge_captures_or_case" ON "billing"."charge_captures" ("source_ref_id") WHERE source_kind_concept_id = 'a79361f6-8787-56a5-9a90-a9436d02e217' AND status_concept_id <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0';

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

-- ------------------------------------------------------------- 4. FKs
-- (de SQL/17_billing/90_fk_deferred.sql y SQL/10_audit/90_fk_deferred.sql; las «compuestas» exigen
--  los UNIQUE (tenant_id, id) / (practice_id, id) creados arriba y en F1b / F5 contabilidad)
-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: billing.space_tariffs sólo apunta a practice.practices del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_practice_id" FOREIGN KEY ("tenant_id", "practice_id")
        REFERENCES "practice"."practices" ("tenant_id", "id");
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

-- compuesta: billing.space_tariffs sólo apunta a practice.care_spaces del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "billing"."space_tariffs"
        ADD CONSTRAINT "fk_space_tariffs_care_space_id" FOREIGN KEY ("tenant_id", "care_space_id")
        REFERENCES "practice"."care_spaces" ("tenant_id", "id");
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
        ADD CONSTRAINT "fk_charge_captures_invoice_line_id" FOREIGN KEY ("invoice_line_id")
        REFERENCES "billing"."invoice_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: billing.charge_captures sólo apunta a practice.practices del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_practice_id" FOREIGN KEY ("tenant_id", "practice_id")
        REFERENCES "practice"."practices" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_source_kind_concept_id" FOREIGN KEY ("source_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: billing.charge_captures sólo apunta a practice.care_spaces del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_care_space_id" FOREIGN KEY ("tenant_id", "care_space_id")
        REFERENCES "practice"."care_spaces" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: billing.charge_captures sólo apunta a billing.space_tariffs del mismo practice_id
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_space_tariff_id" FOREIGN KEY ("practice_id", "space_tariff_id")
        REFERENCES "billing"."space_tariffs" ("practice_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

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

-- compuesta: billing.charge_captures sólo apunta a accounting.cost_centers del mismo practice_id
DO $$ BEGIN
    ALTER TABLE "billing"."charge_captures"
        ADD CONSTRAINT "fk_charge_captures_cost_center_id" FOREIGN KEY ("practice_id", "cost_center_id")
        REFERENCES "accounting"."cost_centers" ("practice_id", "id");
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

-- compuesta: audit.space_tariffs_history sólo apunta a billing.space_tariffs del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "audit"."space_tariffs_history"
        ADD CONSTRAINT "fk_space_tariffs_history_space_tariff_id" FOREIGN KEY ("tenant_id", "space_tariff_id")
        REFERENCES "billing"."space_tariffs" ("tenant_id", "id");
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

-- compuesta: audit.charge_captures_history sólo apunta a billing.charge_captures del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "audit"."charge_captures_history"
        ADD CONSTRAINT "fk_charge_captures_history_charge_capture_id" FOREIGN KEY ("tenant_id", "charge_capture_id")
        REFERENCES "billing"."charge_captures" ("tenant_id", "id");
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

-- ------------------------------------------------------------- 5. precondición, CHECK y EXCLUDE
DO $$
DECLARE
    n_solapes integer;
BEGIN
    SELECT count(*) INTO n_solapes
      FROM "billing"."space_tariffs" a
      JOIN "billing"."space_tariffs" b
        ON a."practice_id" = b."practice_id"
       AND a."tariff_kind_concept_id" = b."tariff_kind_concept_id"
       AND COALESCE(a."bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid)
         = COALESCE(b."bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid)
       AND COALESCE(a."care_space_id", '00000000-0000-0000-0000-000000000000'::uuid)
         = COALESCE(b."care_space_id", '00000000-0000-0000-0000-000000000000'::uuid)
       AND a."id" < b."id"
       AND daterange(a."valid_from", a."valid_to", '[)') && daterange(b."valid_from", b."valid_to", '[)');
    IF n_solapes > 0 THEN
        RAISE EXCEPTION 'F5e facturación: % par(es) de tarifas se solapan en la misma clase (práctica, tipo, categoría, sala). No se toca ningún dato; cerrar o corregir las tarifas a mano y volver a aplicar.', n_solapes
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

-- (de SQL/17_billing/05_constraints.sql) Sólo se agregan si faltan: reaplicar no reconstruye el gist.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ex_space_tariffs_validity') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ex_space_tariffs_validity"
            EXCLUDE USING gist ("practice_id" WITH =, "tariff_kind_concept_id" WITH =, (COALESCE("bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid)) WITH =, (COALESCE("care_space_id", '00000000-0000-0000-0000-000000000000'::uuid)) WITH =, daterange("valid_from", "valid_to", '[)') WITH &&);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ck_space_tariffs_kind') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_kind" CHECK ("tariff_kind_concept_id" IN ('1ae01bf6-a061-52ed-aa26-590705cb2202', '25eb53f6-8006-5959-bee9-65b16117bc9b'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ck_space_tariffs_period') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_period" CHECK ("valid_to" IS NULL OR "valid_to" > "valid_from");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ck_space_tariffs_price') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_price" CHECK ("unit_price" >= 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ck_space_tariffs_or_time_unit') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_or_time_unit" CHECK ("tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR ("unit_minutes" IS NOT NULL AND "unit_minutes" > 0));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ck_space_tariffs_bed_day_whole_days') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_bed_day_whole_days" CHECK ("tariff_kind_concept_id" <> '1ae01bf6-a061-52ed-aa26-590705cb2202' OR ("unit_minutes" IS NULL AND "minimum_units" IS NULL));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ck_space_tariffs_minimum_units') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_minimum_units" CHECK ("minimum_units" IS NULL OR "minimum_units" >= 1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.space_tariffs'::regclass
                      AND conname = 'ck_space_tariffs_scope') THEN
        ALTER TABLE "billing"."space_tariffs" ADD CONSTRAINT "ck_space_tariffs_scope" CHECK (("tariff_kind_concept_id" <> '1ae01bf6-a061-52ed-aa26-590705cb2202' OR "bed_category_concept_id" IS NOT NULL OR "care_space_id" IS NOT NULL) AND ("tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR "bed_category_concept_id" IS NULL));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_source_kind') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_source_kind" CHECK ("source_kind_concept_id" IN ('5f84ea44-b0d3-582c-86c1-32c81e422d30', 'a79361f6-8787-56a5-9a90-a9436d02e217'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_status') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_status" CHECK ("status_concept_id" IN ('17def99a-0cb5-586c-a440-59d809709c0d', '9af061be-6a80-51ed-bcbd-52533037c272', 'f2f59654-d912-5eeb-b619-814e50a3c4d0'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_quantity') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_quantity" CHECK ("quantity" > 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_bed_day_whole') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_bed_day_whole" CHECK ("source_kind_concept_id" <> '5f84ea44-b0d3-582c-86c1-32c81e422d30' OR ("quantity" = 1 AND "care_space_id" IS NOT NULL));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_minimum_stay') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_minimum_stay" CHECK ("minimum_stay_charge" = false OR "source_kind_concept_id" = '5f84ea44-b0d3-582c-86c1-32c81e422d30');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_idempotency_key') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_idempotency_key" CHECK (btrim("idempotency_key") <> '');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_void') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_void" CHECK (("status_concept_id" = 'f2f59654-d912-5eeb-b619-814e50a3c4d0' AND "void_reason" IS NOT NULL AND btrim("void_reason") <> '') OR ("status_concept_id" <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0' AND "void_reason" IS NULL));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_invoice_link') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_invoice_link" CHECK (("status_concept_id" <> '17def99a-0cb5-586c-a440-59d809709c0d' OR "invoice_line_id" IS NULL) AND ("status_concept_id" <> '9af061be-6a80-51ed-bcbd-52533037c272' OR "invoice_line_id" IS NOT NULL));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_price_photo') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_price_photo" CHECK ("unit_price" IS NULL OR ("unit_price" >= 0 AND "space_tariff_id" IS NOT NULL AND "service_catalog_id" IS NOT NULL AND "currency_concept_id" IS NOT NULL));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'billing.charge_captures'::regclass
                      AND conname = 'ck_charge_captures_invoiced_priced') THEN
        ALTER TABLE "billing"."charge_captures" ADD CONSTRAINT "ck_charge_captures_invoiced_priced" CHECK ("status_concept_id" <> '9af061be-6a80-51ed-bcbd-52533037c272' OR "unit_price" IS NOT NULL);
    END IF;
END $$;

-- ------------------------------------------------------------- 6. trigger de guarda de las tarifas
-- SECURITY INVOKER (como F1b / F5 operaciones). Una tarifa se cierra, no se borra, y una tarifa
-- con cargos devengados no se reescribe: el cargo guarda la foto del precio, pero la tarifa sigue
-- siendo la evidencia de por qué ese precio. Sólo valid_to y status pueden cambiar cuando está en uso.
CREATE OR REPLACE FUNCTION "billing"."space_tariffs_guard"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    k_audit    CONSTANT text[] := ARRAY['updated_at', 'updated_by_user_id', 'row_version'];
    x_practice uuid;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'billing.space_tariffs: una tarifa no se borra; se cierra con valid_to y se abre otra'
            USING ERRCODE = 'restrict_violation';
    END IF;

    -- La sala de una tarifa propia es de una sede de la misma práctica de la tarifa.
    IF NEW."care_space_id" IS NOT NULL THEN
        SELECT ps."practice_id" INTO x_practice
          FROM "practice"."care_spaces" cs
          JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
         WHERE cs."id" = NEW."care_space_id";
        IF x_practice IS DISTINCT FROM NEW."practice_id" THEN
            RAISE EXCEPTION 'space_tariffs.care_space_id: la sala no existe en la práctica de la tarifa'
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF (to_jsonb(NEW) - (k_audit || ARRAY['valid_to', 'status_concept_id']))
           IS DISTINCT FROM (to_jsonb(OLD) - (k_audit || ARRAY['valid_to', 'status_concept_id'])) THEN
            IF EXISTS (SELECT 1 FROM "billing"."charge_captures" c WHERE c."space_tariff_id" = OLD."id") THEN
                RAISE EXCEPTION 'billing.space_tariffs: la tarifa ya tiene cargos devengados; sólo se puede cerrar (valid_to) o cambiar su estado, no reescribir'
                    USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;
        IF NEW."valid_to" IS NOT NULL AND NEW."valid_to" IS DISTINCT FROM OLD."valid_to"
           AND EXISTS (SELECT 1 FROM "billing"."charge_captures" c
                        WHERE c."space_tariff_id" = OLD."id" AND c."service_date" >= NEW."valid_to") THEN
            RAISE EXCEPTION 'billing.space_tariffs: no se puede cerrar la tarifa antes de una fecha ya devengada con ella'
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_space_tariffs_guard" ON "billing"."space_tariffs";
CREATE TRIGGER "trg_space_tariffs_guard"
    BEFORE INSERT OR UPDATE OR DELETE
    ON "billing"."space_tariffs"
    FOR EACH ROW EXECUTE FUNCTION "billing"."space_tariffs_guard"();

-- ------------------------------------------------------------- 7. trigger de guarda de los cargos
-- SECURITY INVOKER. ERRCODE: foreign_key_violation (23503) para referencias de otro tenant /
-- práctica; check_violation (23514) para incoherencias con la tarifa; restrict_violation (23001)
-- para identidad o estados que no se tocan.
--
-- Máquina de estados (proceso 11: «nunca se edita un cargo emitido», corrección por nota de crédito):
--   PENDING  → PENDING   sólo se re-calcula: cantidad, categoría, tarifa, servicio, precio, moneda, centro de costo
--   PENDING  → INVOICED  sólo cambian estado y línea de factura
--   PENDING  → VOIDED    sólo cambian estado y motivo
--   INVOICED → VOIDED    sólo cambian estado y motivo (el cargo conserva su línea: nota de crédito)
--   VOIDED   → (nada)    terminal
-- Identidad inmutable: id, tenant, práctica, paciente, encuentro, origen, fecha de servicio, cama,
-- marca de mínimo y clave de idempotencia.
CREATE OR REPLACE FUNCTION "billing"."charge_captures_guard"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    k_src_bed  CONSTANT uuid := '5f84ea44-b0d3-582c-86c1-32c81e422d30';  -- billing:CHG_SRC_BED_DAY
    k_src_or   CONSTANT uuid := 'a79361f6-8787-56a5-9a90-a9436d02e217';  -- billing:CHG_SRC_OR_TIME
    k_pending  CONSTANT uuid := '17def99a-0cb5-586c-a440-59d809709c0d';  -- billing:CHG_PENDING
    k_invoiced CONSTANT uuid := '9af061be-6a80-51ed-bcbd-52533037c272';  -- billing:CHG_INVOICED
    k_voided   CONSTANT uuid := 'f2f59654-d912-5eeb-b619-814e50a3c4d0';  -- billing:CHG_VOIDED
    k_tar_bed  CONSTANT uuid := '1ae01bf6-a061-52ed-aa26-590705cb2202';  -- billing:TARIFF_BED_DAY
    k_tar_or   CONSTANT uuid := '25eb53f6-8006-5959-bee9-65b16117bc9b';  -- billing:TARIFF_OR_TIME
    k_audit    CONSTANT text[] := ARRAY['updated_at', 'updated_by_user_id', 'row_version'];
    v_old      jsonb;
    v_new      jsonb;
    t          record;
    x_tenant   uuid;
    x_practice uuid;
    x_patient  uuid;
    revisar    boolean;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'billing.charge_captures: un cargo devengado no se borra; se anula con motivo'
            USING ERRCODE = 'restrict_violation';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW."id" IS DISTINCT FROM OLD."id"
           OR NEW."tenant_id" IS DISTINCT FROM OLD."tenant_id"
           OR NEW."practice_id" IS DISTINCT FROM OLD."practice_id"
           OR NEW."patient_profile_id" IS DISTINCT FROM OLD."patient_profile_id"
           OR NEW."encounter_id" IS DISTINCT FROM OLD."encounter_id"
           OR NEW."source_kind_concept_id" IS DISTINCT FROM OLD."source_kind_concept_id"
           OR NEW."source_ref_id" IS DISTINCT FROM OLD."source_ref_id"
           OR NEW."service_date" IS DISTINCT FROM OLD."service_date"
           OR NEW."care_space_id" IS DISTINCT FROM OLD."care_space_id"
           OR NEW."minimum_stay_charge" IS DISTINCT FROM OLD."minimum_stay_charge"
           OR NEW."idempotency_key" IS DISTINCT FROM OLD."idempotency_key" THEN
            RAISE EXCEPTION 'billing.charge_captures: la identidad del cargo (paciente, encuentro, origen, fecha, cama, clave) no cambia'
                USING ERRCODE = 'restrict_violation';
        END IF;

        v_old := to_jsonb(OLD) - k_audit;
        v_new := to_jsonb(NEW) - k_audit;

        IF OLD."status_concept_id" = k_voided THEN
            IF v_new IS DISTINCT FROM v_old THEN
                RAISE EXCEPTION 'billing.charge_captures: un cargo anulado no se modifica'
                    USING ERRCODE = 'restrict_violation';
            END IF;
        ELSIF OLD."status_concept_id" = k_invoiced THEN
            IF NEW."status_concept_id" = k_invoiced THEN
                IF v_new IS DISTINCT FROM v_old THEN
                    RAISE EXCEPTION 'billing.charge_captures: un cargo emitido no se edita; se anula con motivo (nota de crédito)'
                        USING ERRCODE = 'restrict_violation';
                END IF;
            ELSIF NEW."status_concept_id" = k_voided THEN
                IF (v_new - ARRAY['status_concept_id', 'void_reason']) IS DISTINCT FROM (v_old - ARRAY['status_concept_id', 'void_reason']) THEN
                    RAISE EXCEPTION 'billing.charge_captures: al anular un cargo emitido sólo cambian el estado y el motivo'
                        USING ERRCODE = 'restrict_violation';
                END IF;
            ELSE
                RAISE EXCEPTION 'billing.charge_captures: un cargo emitido sólo puede anularse'
                    USING ERRCODE = 'restrict_violation';
            END IF;
        ELSIF OLD."status_concept_id" = k_pending THEN
            IF NEW."status_concept_id" = k_invoiced THEN
                IF (v_new - ARRAY['status_concept_id', 'invoice_line_id']) IS DISTINCT FROM (v_old - ARRAY['status_concept_id', 'invoice_line_id']) THEN
                    RAISE EXCEPTION 'billing.charge_captures: al emitir un cargo sólo cambian el estado y la línea de factura'
                        USING ERRCODE = 'restrict_violation';
                END IF;
            ELSIF NEW."status_concept_id" = k_voided THEN
                IF (v_new - ARRAY['status_concept_id', 'void_reason']) IS DISTINCT FROM (v_old - ARRAY['status_concept_id', 'void_reason']) THEN
                    RAISE EXCEPTION 'billing.charge_captures: al anular un cargo sólo cambian el estado y el motivo'
                        USING ERRCODE = 'restrict_violation';
                END IF;
            ELSIF NEW."status_concept_id" = k_pending THEN
                IF (v_new - ARRAY['quantity', 'bed_category_concept_id', 'space_tariff_id', 'service_catalog_id',
                                  'unit_price', 'currency_concept_id', 'cost_center_id'])
                   IS DISTINCT FROM
                   (v_old - ARRAY['quantity', 'bed_category_concept_id', 'space_tariff_id', 'service_catalog_id',
                                  'unit_price', 'currency_concept_id', 'cost_center_id']) THEN
                    RAISE EXCEPTION 'billing.charge_captures: de un cargo pendiente sólo se recalculan cantidad, categoría, tarifa, servicio, precio, moneda y centro de costo'
                        USING ERRCODE = 'restrict_violation';
                END IF;
            ELSE
                RAISE EXCEPTION 'billing.charge_captures: transición de estado no permitida'
                    USING ERRCODE = 'restrict_violation';
            END IF;
        ELSE
            RAISE EXCEPTION 'billing.charge_captures: estado de origen desconocido'
                USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;

    -- Referencias que la FK compuesta no alcanza (el encuentro y la línea de factura no tienen
    -- UNIQUE (tenant_id, id) / (practice_id, id), y la sede de la cama no tiene practice_id propio).
    IF TG_OP = 'INSERT' THEN
        SELECT e."tenant_id", e."patient_profile_id" INTO x_tenant, x_patient
          FROM "clinical"."encounters" e
         WHERE e."id" = NEW."encounter_id";
        IF x_tenant IS DISTINCT FROM NEW."tenant_id" OR x_patient IS DISTINCT FROM NEW."patient_profile_id" THEN
            RAISE EXCEPTION 'charge_captures.encounter_id: el encuentro no existe en el tenant del cargo o no es del paciente del cargo'
                USING ERRCODE = 'foreign_key_violation';
        END IF;

        IF NEW."care_space_id" IS NOT NULL THEN
            SELECT ps."practice_id" INTO x_practice
              FROM "practice"."care_spaces" cs
              JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
             WHERE cs."id" = NEW."care_space_id";
            IF x_practice IS DISTINCT FROM NEW."practice_id" THEN
                RAISE EXCEPTION 'charge_captures.care_space_id: la cama no existe en la práctica del cargo'
                    USING ERRCODE = 'foreign_key_violation';
            END IF;
        END IF;
    END IF;

    IF NEW."invoice_line_id" IS NOT NULL THEN
        revisar := true;
        IF TG_OP = 'UPDATE' THEN
            revisar := NEW."invoice_line_id" IS DISTINCT FROM OLD."invoice_line_id";
        END IF;
        IF revisar THEN
            SELECT i."practice_id", i."patient_profile_id" INTO x_practice, x_patient
              FROM "billing"."invoice_lines" l
              JOIN "billing"."invoices" i ON i."id" = l."invoice_id"
             WHERE l."id" = NEW."invoice_line_id";
            IF x_practice IS DISTINCT FROM NEW."practice_id" OR x_patient IS DISTINCT FROM NEW."patient_profile_id" THEN
                RAISE EXCEPTION 'charge_captures.invoice_line_id: la línea no existe en la práctica del cargo o su factura es de otro paciente'
                    USING ERRCODE = 'foreign_key_violation';
            END IF;
        END IF;
    END IF;

    -- Coherencia con la tarifa: al crear, o cuando se recalcula el precio de un pendiente.
    IF NEW."space_tariff_id" IS NOT NULL THEN
        revisar := true;
        IF TG_OP = 'UPDATE' THEN
            revisar := NEW."space_tariff_id" IS DISTINCT FROM OLD."space_tariff_id"
                    OR NEW."unit_price" IS DISTINCT FROM OLD."unit_price"
                    OR NEW."service_catalog_id" IS DISTINCT FROM OLD."service_catalog_id"
                    OR NEW."currency_concept_id" IS DISTINCT FROM OLD."currency_concept_id"
                    OR NEW."bed_category_concept_id" IS DISTINCT FROM OLD."bed_category_concept_id";
        END IF;
        IF revisar THEN
            SELECT * INTO t FROM "billing"."space_tariffs" st WHERE st."id" = NEW."space_tariff_id";
            IF NOT FOUND THEN
                RAISE EXCEPTION 'charge_captures.space_tariff_id: la tarifa no existe'
                    USING ERRCODE = 'foreign_key_violation';
            END IF;
            IF NOT ((NEW."source_kind_concept_id" = k_src_bed AND t."tariff_kind_concept_id" = k_tar_bed)
                 OR (NEW."source_kind_concept_id" = k_src_or  AND t."tariff_kind_concept_id" = k_tar_or)) THEN
                RAISE EXCEPTION 'charge_captures.space_tariff_id: la tarifa no es del tipo del cargo (día-cama / quirófano)'
                    USING ERRCODE = 'check_violation';
            END IF;
            IF NEW."service_date" < t."valid_from" OR (t."valid_to" IS NOT NULL AND NEW."service_date" >= t."valid_to") THEN
                RAISE EXCEPTION 'charge_captures.space_tariff_id: la tarifa no está vigente en la fecha de servicio del cargo'
                    USING ERRCODE = 'check_violation';
            END IF;
            IF NEW."service_catalog_id" IS DISTINCT FROM t."service_catalog_id"
               OR NEW."unit_price" IS DISTINCT FROM t."unit_price"
               OR NEW."currency_concept_id" IS DISTINCT FROM t."currency_concept_id" THEN
                RAISE EXCEPTION 'charge_captures: servicio, precio y moneda del cargo tienen que ser la foto exacta de su tarifa'
                    USING ERRCODE = 'check_violation';
            END IF;
            IF (t."care_space_id" IS NOT NULL AND t."care_space_id" IS DISTINCT FROM NEW."care_space_id")
               OR (t."bed_category_concept_id" IS NOT NULL
                   AND t."bed_category_concept_id" IS DISTINCT FROM NEW."bed_category_concept_id") THEN
                RAISE EXCEPTION 'charge_captures.space_tariff_id: la tarifa no aplica a la sala / categoría de este cargo'
                    USING ERRCODE = 'check_violation';
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_charge_captures_guard" ON "billing"."charge_captures";
CREATE TRIGGER "trg_charge_captures_guard"
    BEFORE INSERT OR UPDATE OR DELETE
    ON "billing"."charge_captures"
    FOR EACH ROW EXECUTE FUNCTION "billing"."charge_captures_guard"();

-- ------------------------------------------------------------- 8. triggers de la historia
-- Las funciones son las de F1b: tenant por defecto desde el origen y «sólo inserción + cierre de
-- valid_to». TG_ARGV: tabla de origen, columna de origen.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('space_tariffs_history',   'billing.space_tariffs',   'space_tariff_id'),
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

-- ------------------------------------------------------------- 9. privilegios y RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql. Las tablas de negocio no llevan
-- DELETE (los triggers lo rechazan igual, también para el dueño); la historia, SELECT, INSERT y
-- UPDATE sólo de valid_to, como las de F1b. Si 2026-08-05_tenant_rls.sql se reaplica después
-- (GRANT … ON ALL TABLES), vuelve a dar DML completo: los triggers siguen rechazando DELETE y
-- todo UPDATE que no sea cerrar valid_to; reaplicar este patch deja otra vez los mínimos.
DO $$
DECLARE
    t text;
    negocio  text[] := ARRAY['billing.space_tariffs', 'billing.charge_captures'];
    historia text[] := ARRAY['audit.space_tariffs_history', 'audit.charge_captures_history'];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY negocio LOOP
            EXECUTE format('REVOKE DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT, UPDATE ON %s TO mantra_app', t);
        END LOOP;
        FOREACH t IN ARRAY historia LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    FOREACH t IN ARRAY negocio || historia LOOP
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
    n_tablas integer;
    n_fk     integer;
    n_fkc    integer;
    n_ck     integer;
    n_ex     integer;
    n_ux     integer;
    n_trg    integer;
    n_rls    integer;
    n_priv   integer;
BEGIN
    SELECT count(*) INTO n_tablas FROM unnest(ARRAY['billing.space_tariffs', 'billing.charge_captures',
            'audit.space_tariffs_history', 'audit.charge_captures_history']) t
     WHERE to_regclass(t) IS NOT NULL;

    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conrelid IN ('billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass,
                        'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass);

    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conrelid IN ('billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass,
                        'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass);

    SELECT count(*) INTO n_ck FROM pg_constraint
     WHERE contype = 'c'
       AND conrelid IN ('billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass)
       AND conname LIKE 'ck\_%';

    SELECT count(*) INTO n_ex FROM pg_constraint
     WHERE contype = 'x' AND conname = 'ex_space_tariffs_validity'
       AND conrelid = 'billing.space_tariffs'::regclass;

    SELECT count(*) INTO n_ux FROM pg_indexes
     WHERE schemaname = 'billing'
       AND indexname IN ('ux_service_catalog_practice_id_id', 'ux_space_tariffs_practice_id_id',
                         'ux_space_tariffs_tenant_id_id', 'ux_charge_captures_tenant_id_id',
                         'ux_charge_captures_idempotency_key', 'ux_charge_captures_bed_night',
                         'ux_charge_captures_encounter_bed_day', 'ux_charge_captures_or_case')
       AND indexdef LIKE 'CREATE UNIQUE INDEX%';

    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal
       AND ((tgname = 'trg_space_tariffs_guard' AND tgrelid = 'billing.space_tariffs'::regclass)
         OR (tgname = 'trg_charge_captures_guard' AND tgrelid = 'billing.charge_captures'::regclass)
         OR (tgname IN ('trg_fill_tenant', 'trg_close_only')
             AND tgrelid IN ('audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass)));

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE (n.nspname, c.relname) IN (('billing', 'space_tariffs'), ('billing', 'charge_captures'),
                                      ('audit', 'space_tariffs_history'), ('audit', 'charge_captures_history'))
       AND c.relrowsecurity AND c.relforcerowsecurity;

    n_priv := 0;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_priv FROM unnest(ARRAY['billing.space_tariffs', 'billing.charge_captures',
                'audit.space_tariffs_history', 'audit.charge_captures_history']) t
         WHERE has_table_privilege('mantra_app', t, 'DELETE')
            OR (t LIKE 'audit.%' AND has_table_privilege('mantra_app', t, 'UPDATE'));
    END IF;

    IF n_tablas <> 4 OR n_fk <> 35 OR n_fkc <> 10 OR n_ck <> 17 OR n_ex <> 1
       OR n_ux <> 8 OR n_trg <> 6 OR n_rls <> 4 OR n_priv <> 0 THEN
        RAISE EXCEPTION 'F5e facturación incompleto: tablas=% (4), FK=% (35), FK compuestas=% (10), CHECK=% (17), EXCLUDE=% (1), únicos=% (8), triggers=% (6), RLS=% (4), privilegios de DELETE/UPDATE de más para mantra_app=% (0)',
            n_tablas, n_fk, n_fkc, n_ck, n_ex, n_ux, n_trg, n_rls, n_priv;
    END IF;

    RAISE NOTICE 'F5e facturación aplicado: space_tariffs y charge_captures (+ historias) con FK compuestas por tenant/práctica, EXCLUDE de vigencias, únicos anti doble cobro (clave, encuentro+noche, cama+noche, caso), guardas, RLS.';
END $$;

COMMIT;
