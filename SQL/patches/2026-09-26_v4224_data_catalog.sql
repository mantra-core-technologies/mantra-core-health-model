-- ============================================================================
-- SALUD · patch v4.2.24 (data_catalog · módulo 67) sobre una BD viva
-- Fecha original: 2026-09-18 (API, v4.2.19) · promovido al modelo: 2026-09-26
--
-- PROMOCIÓN AL MODELO (carril M1, reparto de 6 máquinas). Colisionaba con
-- v4.2.19 de custodian_tenant_rls (dos parches distintos, mismo número, en
-- árboles distintos: éste vivía sólo en la copia vendorizada de la API).
-- Se renumera a v4.2.24, continuando la secuencia única del modelo (hasta
-- acá: v4.2.23).
--
-- `diagram_67_data_catalog.puml` YA EXISTE, transcribiendo estas mismas 8
-- tablas: verificado regenerando con `gen_ddl.py 67` y diffeando columna por
-- columna contra este patch — 0 diferencias en las 8 tablas (tipo y
-- obligatoriedad), y los 15 nombres de índice, idénticos. Este archivo sigue
-- siendo el único camino para una base YA viva; una base nueva sale con estas
-- tablas desde `SQL/67_data_catalog/`.
-- Idempotente (CREATE SCHEMA/TABLE/INDEX IF NOT EXISTS, FK con duplicate_object).
-- UNA sola pasada: no hay backfill (módulo nuevo, cero filas). El primer
-- escaneo del catálogo lo puebla desde la API.
--
-- QUÉ CIERRA. Portal administrativo (inspiración ATLAS, pilar "catálogo"):
-- responder por cada tabla y columna qué es, POR QUÉ EXISTE, qué significa una
-- fila, quién responde por ella y con qué evidencia — separando los hechos
-- técnicos observados (escaneo de pg_catalog) de la semántica curada, que un
-- escaneo nunca pisa. Se buscó reutilizar `system_ops.entity_registry` /
-- `field_registry`: son el registro de GOBIERNO (políticas, retención, PII/PHI)
-- y se leen desde el catálogo, pero no tienen dónde guardar la justificación,
-- las revisiones ni la evidencia, y sus entidades son generadas (no se editan).
--
-- Sin CHECK sobre los estados: el ORM crea estas tablas en una base vacía y no
-- emite CHECKs, así que ponerlos sólo aquí haría que dos bases "iguales"
-- validen distinto. Los estados se validan en el dominio del módulo.
--
-- Delta esperado: +1 schema · +8 tablas · +27 FK · +15 índices.
-- ============================================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS "data_catalog";

-- ---------------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_scan_runs" (
    "id" uuid NOT NULL,
    "source_code" varchar NOT NULL,
    "mode" varchar NOT NULL,
    -- QUEUED | RUNNING | SUCCEEDED | FAILED | CANCELLED
    "status" varchar NOT NULL,
    "idempotency_key" varchar,
    "requested_by_user_id" uuid,
    "requested_at" timestamptz NOT NULL,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "cancel_requested_at" timestamptz,
    "lease_owner" varchar,
    "lease_expires_at" timestamptz,
    "attempt" int NOT NULL,
    "engine_version" varchar,
    "connector_version" varchar NOT NULL,
    "excluded_schemas" jsonb,
    "limitations" jsonb,
    "objects_observed" int,
    "columns_observed" int,
    "objects_added" int,
    "objects_changed" int,
    "objects_not_observed" int,
    "objects_reappeared" int,
    "columns_added" int,
    "columns_changed" int,
    "columns_not_observed" int,
    "snapshot_hash" varchar,
    "error_code" varchar,
    "error_message" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" int NOT NULL DEFAULT 1,
    CONSTRAINT "catalog_scan_runs_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_objects" (
    "id" uuid NOT NULL,
    "source_code" varchar NOT NULL,
    "schema_name" varchar NOT NULL,
    "object_name" varchar NOT NULL,
    -- TABLE | PARTITIONED_TABLE | VIEW | MATERIALIZED_VIEW | FOREIGN_TABLE
    "object_kind" varchar NOT NULL,
    -- OBSERVED | NOT_OBSERVED | RETIRED (nunca se borra)
    "observation_status" varchar NOT NULL,
    "table_comment" text,
    "estimated_rows" bigint,
    "total_bytes" bigint,
    "stats_observed_at" timestamptz,
    "column_count" int NOT NULL,
    "primary_key_columns" jsonb,
    "technical_hash" varchar NOT NULL,
    "first_seen_scan_id" uuid NOT NULL,
    "last_seen_scan_id" uuid NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "not_observed_since" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" int NOT NULL DEFAULT 1,
    CONSTRAINT "catalog_objects_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_columns" (
    "id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_name" varchar NOT NULL,
    "ordinal" int NOT NULL,
    "native_type" varchar NOT NULL,
    "is_nullable" boolean NOT NULL,
    "default_expression" text,
    "is_identity" boolean NOT NULL,
    "is_generated" boolean NOT NULL,
    "is_primary_key" boolean NOT NULL,
    "is_unique" boolean NOT NULL,
    "foreign_key" jsonb,
    "column_comment" text,
    "observation_status" varchar NOT NULL,
    "technical_hash" varchar NOT NULL,
    "first_seen_scan_id" uuid NOT NULL,
    "last_seen_scan_id" uuid NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "not_observed_since" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" int NOT NULL DEFAULT 1,
    CONSTRAINT "catalog_columns_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_change_events" (
    "id" uuid NOT NULL,
    "scan_run_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    -- ADDED | CHANGED | NOT_OBSERVED | REAPPEARED
    "change_kind" varchar NOT NULL,
    "before_json" jsonb,
    "after_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "catalog_change_events_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_annotations" (
    "id" uuid NOT NULL,
    -- OBJECT | COLUMN
    "target_kind" varchar NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "business_name" varchar,
    "definition" text,
    "purpose" text,
    "existence_rationale" text,
    "row_grain" text,
    "alternatives_rationale" text,
    "process_supported" text,
    "source_of_truth" text,
    "producers" jsonb,
    "consumers" jsonb,
    "deletion_impact" text,
    "business_owner" varchar,
    "data_steward" varchar,
    "technical_owner" varchar,
    "unit" varchar,
    "value_domain" text,
    "null_semantics" text,
    -- UNKNOWN | NONE | INTERNAL | PII | PHI | SECRET (UNKNOWN ≠ NONE)
    "sensitivity" varchar NOT NULL,
    "open_questions" jsonb,
    -- DRAFT | NEEDS_REVIEW | APPROVED | REJECTED
    "review_status" varchar NOT NULL,
    -- MANUAL | IMPORTED_VAULT | AI_SUGGESTED
    "origin" varchar NOT NULL,
    "current_revision_no" int NOT NULL,
    "approved_revision_no" int,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" int NOT NULL DEFAULT 1,
    CONSTRAINT "catalog_annotations_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_annotation_revisions" (
    "id" uuid NOT NULL,
    "annotation_id" uuid NOT NULL,
    "revision_no" int NOT NULL,
    "content_json" jsonb NOT NULL,
    "content_hash" varchar NOT NULL,
    "origin" varchar NOT NULL,
    "submitted_status" varchar NOT NULL,
    "change_reason" text,
    "author_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "catalog_annotation_revisions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_review_decisions" (
    "id" uuid NOT NULL,
    "annotation_id" uuid NOT NULL,
    "revision_no" int NOT NULL,
    -- APPROVED | REJECTED
    "decision" varchar NOT NULL,
    "comment" text,
    "reviewer_user_id" uuid NOT NULL,
    "decided_at" timestamptz NOT NULL,
    CONSTRAINT "catalog_review_decisions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_evidence_items" (
    "id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "kind" varchar NOT NULL,
    "reference" text NOT NULL,
    "excerpt" text,
    "source_revision" varchar,
    "added_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "catalog_evidence_items_pkey" PRIMARY KEY ("id")
);

-- ---------------------------------------------------------------------------
-- Índices (espejo de src/orm/catalog/indexes/data_catalog.idx.ts)
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS "ix_data_catalog_scan_runs_status_requested_at"
    ON "data_catalog"."catalog_scan_runs" ("status", "requested_at");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_scan_runs_one_active"
    ON "data_catalog"."catalog_scan_runs" ("source_code")
    WHERE status IN ('QUEUED', 'RUNNING');
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_scan_runs_idempotency"
    ON "data_catalog"."catalog_scan_runs" ("requested_by_user_id", "idempotency_key")
    WHERE idempotency_key IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_objects_identity"
    ON "data_catalog"."catalog_objects" ("source_code", "schema_name", "object_name");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_objects_observation_status"
    ON "data_catalog"."catalog_objects" ("observation_status");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_columns_identity"
    ON "data_catalog"."catalog_columns" ("object_id", "column_name");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_events_scan_run_id"
    ON "data_catalog"."catalog_change_events" ("scan_run_id");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_events_object_created"
    ON "data_catalog"."catalog_change_events" ("object_id", "created_at");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotations_object"
    ON "data_catalog"."catalog_annotations" ("object_id")
    WHERE target_kind = 'OBJECT';
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotations_column"
    ON "data_catalog"."catalog_annotations" ("column_id")
    WHERE column_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS "ix_data_catalog_annotations_review_status"
    ON "data_catalog"."catalog_annotations" ("review_status");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_annotation_revisions_no"
    ON "data_catalog"."catalog_annotation_revisions" ("annotation_id", "revision_no");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_review_decisions_annotation"
    ON "data_catalog"."catalog_review_decisions" ("annotation_id", "revision_no");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_evidence_items_object_id"
    ON "data_catalog"."catalog_evidence_items" ("object_id");
CREATE INDEX IF NOT EXISTS "ix_data_catalog_evidence_items_column_id"
    ON "data_catalog"."catalog_evidence_items" ("column_id");

-- ---------------------------------------------------------------------------
-- Claves foráneas (espejo de src/orm/catalog/foreign-keys/data_catalog.fk.ts).
-- Sin CASCADE: el historial no desaparece porque se borre lo que describe.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    fk record;
BEGIN
    FOR fk IN
        SELECT * FROM (VALUES
            ('catalog_scan_runs', 'requested_by_user_id', 'iam', 'users'),
            ('catalog_scan_runs', 'created_by_user_id', 'iam', 'users'),
            ('catalog_scan_runs', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_objects', 'first_seen_scan_id', 'data_catalog', 'catalog_scan_runs'),
            ('catalog_objects', 'last_seen_scan_id', 'data_catalog', 'catalog_scan_runs'),
            ('catalog_objects', 'created_by_user_id', 'iam', 'users'),
            ('catalog_objects', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_columns', 'object_id', 'data_catalog', 'catalog_objects'),
            ('catalog_columns', 'first_seen_scan_id', 'data_catalog', 'catalog_scan_runs'),
            ('catalog_columns', 'last_seen_scan_id', 'data_catalog', 'catalog_scan_runs'),
            ('catalog_columns', 'created_by_user_id', 'iam', 'users'),
            ('catalog_columns', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_change_events', 'scan_run_id', 'data_catalog', 'catalog_scan_runs'),
            ('catalog_change_events', 'object_id', 'data_catalog', 'catalog_objects'),
            ('catalog_change_events', 'column_id', 'data_catalog', 'catalog_columns'),
            ('catalog_annotations', 'object_id', 'data_catalog', 'catalog_objects'),
            ('catalog_annotations', 'column_id', 'data_catalog', 'catalog_columns'),
            ('catalog_annotations', 'approved_by_user_id', 'iam', 'users'),
            ('catalog_annotations', 'created_by_user_id', 'iam', 'users'),
            ('catalog_annotations', 'updated_by_user_id', 'iam', 'users'),
            ('catalog_annotation_revisions', 'annotation_id', 'data_catalog', 'catalog_annotations'),
            ('catalog_annotation_revisions', 'author_user_id', 'iam', 'users'),
            ('catalog_review_decisions', 'annotation_id', 'data_catalog', 'catalog_annotations'),
            ('catalog_review_decisions', 'reviewer_user_id', 'iam', 'users'),
            ('catalog_evidence_items', 'object_id', 'data_catalog', 'catalog_objects'),
            ('catalog_evidence_items', 'column_id', 'data_catalog', 'catalog_columns'),
            ('catalog_evidence_items', 'added_by_user_id', 'iam', 'users')
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

COMMIT;
