-- ============================================================================
-- SALUD · patch v4.2.48 (data_catalog · módulo 67 + módulo 33) sobre una BD viva
-- Fecha: 2026-10-24
--
-- Sigue la convención de `2026-09-26_v4224_data_catalog.sql`: parche escrito a mano,
-- fuera de `apply_all.sql`, idempotente (IF NOT EXISTS, FK con duplicate_object,
-- DROP TRIGGER IF EXISTS) y en UNA sola pasada. Una base nueva sale con todo esto
-- desde `SQL/67_data_catalog/` (02_tables, 03_fk_intra, 04_indexes, 05_constraints,
-- 90_fk_deferred), generado de `diagram_67_data_catalog.puml` y
-- `diagram_33_integrity.puml`.
--
-- QUÉ CIERRA (centro de datos del portal administrativo).
--  1. Mapa operaciones <-> datos: +5 tablas (catalog_operations,
--     catalog_operation_impacts, catalog_processes, catalog_process_steps,
--     catalog_process_step_operations: puente etapa <-> operaciones). Guardan
--     lo que el inventario de la API ya produce: qué operación HTTP existe, qué
--     objetos del catálogo toca y con qué acceso, y los procesos que las agrupan.
--     Sin CHECK sobre los textos acotados (access_kind, risk_level, kind,
--     observation_status), por el mismo motivo que `catalog_annotations.sensitivity`
--     en el parche v4.2.24: el ORM crea las tablas sin CHECKs y ponerlos sólo aquí
--     haría que dos bases «iguales» validen distinto.
--  2. Barrera WORM de las cuatro <<LOG>> del módulo 67 (decisión D3, opción b):
--     UPDATE prohibido y DELETE permitido, igual que audit.data_access_log. La
--     función `integrity.forbid_mutation()` es la del módulo 33.
--
-- LO QUE ESTE PARCHE NO HACE.
--  - No siembra ni toca `system_ops.data_classifications`: el vocabulario de nueve
--    niveles (ANONYMIZED ... CREDENTIAL) viaja en el paquete de seeds y se carga con
--    `load_seeds.py --refresh`. Esa carga no borra los códigos viejos (CONFIDENTIAL,
--    RESTRICTED, PII, PHI, FINANCIAL, SECRET, PUBLIC_009 y los de mock): las FK de
--    entity_registry, field_registry, data_residency_policies y security_incidents
--    pueden apuntarlos. Retirarlos es una decisión aparte, con las filas
--    repuntadas antes.
--  - No tiene backfill: las cinco tablas nacen vacías y las puebla el importador
--    del inventario desde la API.
--
-- Delta esperado: +5 tablas · +16 FK · +9 índices · +4 triggers (trg_forbid_update).
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_operations" (
    "id" uuid NOT NULL,
    "source_code" varchar NOT NULL,
    "operation_key" varchar NOT NULL,
    "http_method" varchar NOT NULL,
    "route_template" varchar NOT NULL,
    "module_code" varchar,
    "controller_name" varchar,
    "handler_name" varchar,
    "source_ref" varchar,
    "is_public" boolean NOT NULL,
    "required_roles" jsonb,
    "risk_level" varchar NOT NULL,
    "observation_status" varchar NOT NULL,
    "technical_hash" varchar,
    "first_seen_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_operations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_operation_impacts" (
    "id" uuid NOT NULL,
    "operation_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "access_kind" varchar NOT NULL,
    "access_detail" varchar,
    "confidence" varchar,
    "call_path" jsonb,
    "source_ref" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_operation_impacts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_processes" (
    "id" uuid NOT NULL,
    "process_code" varchar NOT NULL,
    "kind" varchar NOT NULL,
    "name" varchar NOT NULL,
    "module_code" varchar,
    "purpose" text,
    "source_ref" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_processes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_process_steps" (
    "id" uuid NOT NULL,
    "process_id" uuid NOT NULL,
    "ordinal" integer NOT NULL,
    "step_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_process_steps" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_process_step_operations" (
    "id" uuid NOT NULL,
    "step_id" uuid NOT NULL,
    "operation_id" uuid NOT NULL,
    "ordinal" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_process_step_operations" PRIMARY KEY ("id")
);

-- ---------------------------------------------------------------------------
-- Índices (espejo de SQL/67_data_catalog/04_indexes.sql)
-- ---------------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_operations_key" ON "data_catalog"."catalog_operations" ("operation_key");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_operation_impacts_operation_id" ON "data_catalog"."catalog_operation_impacts" ("operation_id");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_operation_impacts_object_id" ON "data_catalog"."catalog_operation_impacts" ("object_id");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_operation_impacts_column_id" ON "data_catalog"."catalog_operation_impacts" ("column_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_processes_code" ON "data_catalog"."catalog_processes" ("process_code");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_process_steps_ordinal" ON "data_catalog"."catalog_process_steps" ("process_id", "ordinal");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_process_step_operations_pair" ON "data_catalog"."catalog_process_step_operations" ("step_id", "operation_id");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_process_step_operations_step_id" ON "data_catalog"."catalog_process_step_operations" ("step_id");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_process_step_operations_operation_id" ON "data_catalog"."catalog_process_step_operations" ("operation_id");

-- ---------------------------------------------------------------------------
-- Claves foráneas (espejo de 03_fk_intra.sql y 90_fk_deferred.sql). Sin CASCADE.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    fk record;
BEGIN
    FOR fk IN
        SELECT * FROM (VALUES
            ('catalog_operation_impacts', 'operation_id', 'data_catalog', 'catalog_operations'),
            ('catalog_operation_impacts', 'object_id', 'data_catalog', 'catalog_objects'),
            ('catalog_operation_impacts', 'column_id', 'data_catalog', 'catalog_columns'),
            ('catalog_process_steps', 'process_id', 'data_catalog', 'catalog_processes'),
            ('catalog_process_step_operations', 'step_id', 'data_catalog', 'catalog_process_steps'),
            ('catalog_process_step_operations', 'operation_id', 'data_catalog', 'catalog_operations'),
            ('catalog_operations', 'created_by_user_id', 'iam', 'users'),
            ('catalog_operations', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_operation_impacts', 'created_by_user_id', 'iam', 'users'),
            ('catalog_operation_impacts', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_processes', 'created_by_user_id', 'iam', 'users'),
            ('catalog_processes', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_process_steps', 'created_by_user_id', 'iam', 'users'),
            ('catalog_process_steps', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_process_step_operations', 'created_by_user_id', 'iam', 'users'),
            ('catalog_process_step_operations', 'updated_by_user_id', 'iam', 'users')
        ) AS t(src_table, src_column, dst_schema, dst_table)
    LOOP
        BEGIN
            EXECUTE format(
                'ALTER TABLE data_catalog.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I (id)',
                fk.src_table,
                left('fk_' || fk.src_table || '_' || fk.src_column, 63),
                fk.src_column,
                fk.dst_schema,
                fk.dst_table
            );
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- Barrera WORM (módulo 33): UPDATE prohibido en las cuatro <<LOG>> del 67.
-- Espejo de SQL/67_data_catalog/05_constraints.sql. DELETE queda permitido a
-- propósito (decisión D3 b): la limpieza de datos de prueba de la integración del
-- catálogo borra estas tablas.
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS "integrity";

CREATE OR REPLACE FUNCTION "integrity"."forbid_mutation"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'append-only/immutable: % no permitido en %.%',
        TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
END $$;

REVOKE UPDATE ON "data_catalog"."catalog_change_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_change_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_change_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

REVOKE UPDATE ON "data_catalog"."catalog_annotation_revisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_annotation_revisions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_annotation_revisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

REVOKE UPDATE ON "data_catalog"."catalog_review_decisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_review_decisions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_review_decisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

REVOKE UPDATE ON "data_catalog"."catalog_evidence_items" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_evidence_items";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_evidence_items"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

COMMIT;
