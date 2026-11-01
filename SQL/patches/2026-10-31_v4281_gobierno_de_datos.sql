-- ============================================================================
-- SALUD · patch v4.2.81 (franja F1b del portal de observabilidad y gobierno: gobierno de datos, módulos 67 y 11) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_v4281_patches.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a mano
-- salvo la guarda de columnas de las revisiones de política (sección 6) y los permisos/comprobaciones. Idempotente (CREATE ... IF NOT
-- EXISTS, ADD COLUMN IF NOT EXISTS, FK con duplicate_object, CHECK con DROP IF EXISTS + ADD, disparadores con DROP IF EXISTS + CREATE).
-- UNA sola transacción; se puede volver a correr. Solo AGREGA: no cambia ni borra nada existente.
--
-- Contexto: 04-catalogo-y-gobierno.md §3 (H1.S1.M1–M4) del plan docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo del front).
--
-- QUE AGREGA
--   data_catalog (módulo 67)  +12 tablas: catalog_stewardships, catalog_glossary_terms, catalog_glossary_term_revisions, catalog_glossary_term_links, quality_rules, quality_rule_runs, quality_issues, quality_issue_events, quality_score_snapshots, catalog_lineage_edges, catalog_certifications, catalog_change_acknowledgements
--                             + catalog_objects.domain_id (columna nullable, ADD COLUMN IF NOT EXISTS: no reescribe la tabla ni toma bloqueo largo)
--   system_ops (módulo 11)    +1 tabla: governance_policy_revisions; + índice ix_governance_change_log_target_recorded en la bitácora
--                             (CREATE INDEX normal: governance_change_log es chica; en una base grande, crearlo antes con CONCURRENTLY)
--   48 FK (las que van a iam.users, system_ops.data_domains, read_models y reporting son diferidas: sección 4), 51 índices, 9 CHECK,
--   4 disparadores de inmutabilidad (+1 de columnas en governance_policy_revisions)
--
-- DECISIONES (detalle en el .puml 67 y 11)
--   * Sin RLS, a propósito: ninguna tabla nueva tiene columna `tenant_id` ni `actor_tenant_id`. El catálogo y el gobierno son datos de PLATAFORMA
--     (`@TenantAgnostic()` en el API; los actores son `*_user_id`). 2026-08-05_tenant_rls.sql solo alcanza columnas `tenant_id`: la sección 8
--     aborta si aparece una. Si una tabla de este bloque llegara a llevar el tenant de un actor, debe llamarse `actor_tenant_id` y recibir
--     políticas explícitas (patrón del v4280).
--   * Inmutables (UPDATE prohibido por `integrity.forbid_mutation`): catalog_glossary_term_revisions, quality_issue_events,
--     quality_score_snapshots, catalog_change_acknowledgements. `mantra_app` pierde UPDATE/TRUNCATE sobre ellas.
--   * governance_policy_revisions NO usa forbid_mutation (D-F1b-7): su ciclo de vida vive en la misma fila y aprobar es un UPDATE. Un
--     disparador de columnas (sección 6) congela lo propuesto, no reescribe una decisión tomada, impide retroceder el estado y prohíbe el
--     DELETE; ck_governance_policy_revisions_not_self impone en la base que quien decide no es quien propuso.
--   * quality_rules.threshold_pct no lleva DEFAULT 0 (D-F1b-4): el API debe enviar el umbral.
--
-- REVERSA (solo agrega; un rollback de la API deja datos inertes). Orden: primero las tablas con FK hacia otras.
--   DROP TABLE IF EXISTS data_catalog.catalog_change_acknowledgements, data_catalog.catalog_certifications, data_catalog.catalog_lineage_edges,
--     data_catalog.quality_score_snapshots, data_catalog.quality_issue_events, data_catalog.quality_issues, data_catalog.quality_rule_runs,
--     data_catalog.quality_rules, data_catalog.catalog_glossary_term_links, data_catalog.catalog_glossary_term_revisions,
--     data_catalog.catalog_glossary_terms, data_catalog.catalog_stewardships, system_ops.governance_policy_revisions;
--   DROP FUNCTION IF EXISTS system_ops.guard_governance_policy_revision();
--   ALTER TABLE data_catalog.catalog_objects DROP COLUMN IF EXISTS domain_id;
--   DROP INDEX IF EXISTS system_ops.ix_governance_change_log_target_recorded;
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '15s';

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regprocedure('integrity.forbid_mutation()') IS NULL THEN
        RAISE EXCEPTION 'falta integrity.forbid_mutation(): aplicar antes SQL/_integrity/00_integrity_functions.sql';
    END IF;
    IF to_regclass('iam.users') IS NULL OR to_regclass('system_ops.data_domains') IS NULL OR to_regclass('system_ops.governance_change_log') IS NULL
       OR to_regclass('data_catalog.catalog_objects') IS NULL OR to_regclass('data_catalog.catalog_columns') IS NULL
       OR to_regclass('data_catalog.catalog_change_events') IS NULL
       OR to_regclass('read_models.read_model_definitions') IS NULL OR to_regclass('reporting.report_definitions') IS NULL THEN
        RAISE EXCEPTION 'faltan tablas base (iam.users, system_ops.data_domains/governance_change_log, data_catalog.catalog_objects/columns/change_events, read_models.read_model_definitions, reporting.report_definitions): aplicar antes apply_all.sql';
    END IF;
END $$;

-- ---- 1. tablas (SQL/67_data_catalog/02_tables.sql y SQL/11_system_ops/02_tables.sql) ----
CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_stewardships" (
    "id" uuid NOT NULL,
    "scope_kind" varchar NOT NULL,
    "domain_id" uuid,
    "object_id" uuid,
    "role_kind" varchar NOT NULL,
    "user_id" uuid,
    "team_code" varchar,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_stewardships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_glossary_terms" (
    "id" uuid NOT NULL,
    "term_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "definition" text NOT NULL,
    "domain_id" uuid,
    "synonyms" jsonb,
    "status" varchar NOT NULL,
    "current_revision_no" integer NOT NULL,
    "approved_revision_no" integer,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_glossary_terms" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_glossary_term_revisions" (
    "id" uuid NOT NULL,
    "term_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "content_json" jsonb NOT NULL,
    "content_hash" varchar NOT NULL,
    "change_reason" text,
    "author_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_glossary_term_revisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_glossary_term_links" (
    "id" uuid NOT NULL,
    "term_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "link_kind" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_catalog_glossary_term_links" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_rules" (
    "id" uuid NOT NULL,
    "rule_code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "rule_kind" varchar NOT NULL,
    "params_json" jsonb NOT NULL,
    "severity" varchar NOT NULL,
    "threshold_pct" numeric(5,2) NOT NULL,
    "schedule_minutes" integer,
    "sample_limit" integer NOT NULL DEFAULT 20,
    "enabled" boolean NOT NULL DEFAULT true,
    "owner_user_id" uuid,
    "version" integer NOT NULL DEFAULT 1,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quality_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_rule_runs" (
    "id" uuid NOT NULL,
    "rule_id" uuid NOT NULL,
    "trigger" varchar NOT NULL,
    "status" varchar NOT NULL,
    "idempotency_key" varchar,
    "requested_by_user_id" uuid,
    "lease_owner" varchar,
    "lease_expires_at" timestamptz,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "evaluated_rows" bigint,
    "failed_rows" bigint,
    "failed_pct" numeric(7,4),
    "passed" boolean,
    "sample_ids_json" jsonb,
    "error_code" varchar,
    "error_message" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_quality_rule_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_issues" (
    "id" uuid NOT NULL,
    "rule_id" uuid NOT NULL,
    "object_id" uuid NOT NULL,
    "column_id" uuid,
    "fingerprint" varchar NOT NULL,
    "severity" varchar NOT NULL,
    "status" varchar NOT NULL,
    "first_seen_run_id" uuid NOT NULL,
    "last_seen_run_id" uuid NOT NULL,
    "occurrences" integer NOT NULL DEFAULT 1,
    "failed_rows_last" bigint,
    "failed_pct_last" numeric(7,4),
    "acknowledged_by_user_id" uuid,
    "acknowledged_at" timestamptz,
    "resolved_by_user_id" uuid,
    "resolved_at" timestamptz,
    "resolution_kind" varchar,
    "ignored_until" timestamptz,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quality_issues" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_issue_events" (
    "id" uuid NOT NULL,
    "issue_id" uuid NOT NULL,
    "event_kind" varchar NOT NULL,
    "run_id" uuid,
    "actor_user_id" uuid,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_quality_issue_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."quality_score_snapshots" (
    "id" uuid NOT NULL,
    "scope_kind" varchar NOT NULL,
    "object_id" uuid,
    "domain_id" uuid,
    "as_of" timestamptz NOT NULL,
    "score" numeric(5,2) NOT NULL,
    "components_json" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_quality_score_snapshots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_lineage_edges" (
    "id" uuid NOT NULL,
    "source_kind" varchar NOT NULL,
    "source_ref" varchar NOT NULL,
    "target_kind" varchar NOT NULL,
    "target_ref" varchar NOT NULL,
    "edge_kind" varchar NOT NULL,
    "origin" varchar NOT NULL,
    "confidence" varchar,
    "is_official" boolean NOT NULL DEFAULT false,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "observation_status" varchar NOT NULL,
    "first_seen_at" timestamptz NOT NULL,
    "last_seen_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_lineage_edges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_certifications" (
    "id" uuid NOT NULL,
    "target_kind" varchar NOT NULL,
    "object_id" uuid,
    "read_model_definition_id" uuid,
    "report_definition_id" uuid,
    "kpi_code" varchar,
    "status" varchar NOT NULL,
    "basis_json" jsonb NOT NULL,
    "requested_by_user_id" uuid NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "certified_by_user_id" uuid,
    "certified_at" timestamptz,
    "expires_at" timestamptz,
    "revoked_by_user_id" uuid,
    "revoked_at" timestamptz,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_catalog_certifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_change_acknowledgements" (
    "id" uuid NOT NULL,
    "change_event_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "reason" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_catalog_change_acknowledgements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."governance_policy_revisions" (
    "id" uuid NOT NULL,
    "policy_type" varchar NOT NULL,
    "policy_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "content_json" jsonb NOT NULL,
    "content_hash" varchar NOT NULL,
    "status" varchar NOT NULL,
    "change_reason" text NOT NULL,
    "submitted_by_user_id" uuid NOT NULL,
    "submitted_at" timestamptz NOT NULL,
    "decided_by_user_id" uuid,
    "decided_at" timestamptz,
    "decision_comment" text,
    "effective_from" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_governance_policy_revisions" PRIMARY KEY ("id")
);

-- la unica columna nueva en una tabla que ya existia (nullable: ADD COLUMN IF NOT EXISTS no reescribe ni bloquea)
ALTER TABLE "data_catalog"."catalog_objects" ADD COLUMN IF NOT EXISTS "domain_id" uuid;

-- ---- 2. FK dentro del schema data_catalog (SQL/67_data_catalog/03_fk_intra.sql) ----
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_revisions"
        ADD CONSTRAINT "fk_catalog_glossary_term_revisions_term_id" FOREIGN KEY ("term_id")
        REFERENCES "data_catalog"."catalog_glossary_terms" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_links"
        ADD CONSTRAINT "fk_catalog_glossary_term_links_term_id" FOREIGN KEY ("term_id")
        REFERENCES "data_catalog"."catalog_glossary_terms" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_links"
        ADD CONSTRAINT "fk_catalog_glossary_term_links_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_links"
        ADD CONSTRAINT "fk_catalog_glossary_term_links_column_id" FOREIGN KEY ("column_id")
        REFERENCES "data_catalog"."catalog_columns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_column_id" FOREIGN KEY ("column_id")
        REFERENCES "data_catalog"."catalog_columns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rule_runs"
        ADD CONSTRAINT "fk_quality_rule_runs_rule_id" FOREIGN KEY ("rule_id")
        REFERENCES "data_catalog"."quality_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_rule_id" FOREIGN KEY ("rule_id")
        REFERENCES "data_catalog"."quality_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_column_id" FOREIGN KEY ("column_id")
        REFERENCES "data_catalog"."catalog_columns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_first_seen_run_id" FOREIGN KEY ("first_seen_run_id")
        REFERENCES "data_catalog"."quality_rule_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_last_seen_run_id" FOREIGN KEY ("last_seen_run_id")
        REFERENCES "data_catalog"."quality_rule_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issue_events"
        ADD CONSTRAINT "fk_quality_issue_events_issue_id" FOREIGN KEY ("issue_id")
        REFERENCES "data_catalog"."quality_issues" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issue_events"
        ADD CONSTRAINT "fk_quality_issue_events_run_id" FOREIGN KEY ("run_id")
        REFERENCES "data_catalog"."quality_rule_runs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_score_snapshots"
        ADD CONSTRAINT "fk_quality_score_snapshots_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_object_id" FOREIGN KEY ("object_id")
        REFERENCES "data_catalog"."catalog_objects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_change_acknowledgements"
        ADD CONSTRAINT "fk_catalog_change_acknowledgements_change_event_id" FOREIGN KEY ("change_event_id")
        REFERENCES "data_catalog"."catalog_change_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---- 3. indices (SQL/67_data_catalog/04_indexes.sql y SQL/11_system_ops/04_indexes.sql) ----
CREATE INDEX IF NOT EXISTS "ix_data_catalog_objects_domain_id" ON "data_catalog"."catalog_objects" ("domain_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_stewardships_active_role" ON "data_catalog"."catalog_stewardships" ("scope_kind", COALESCE(domain_id, object_id), "role_kind") WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_stewardships_user_id" ON "data_catalog"."catalog_stewardships" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_stewardships_object_id" ON "data_catalog"."catalog_stewardships" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_stewardships_domain_id" ON "data_catalog"."catalog_stewardships" ("domain_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_glossary_terms_code" ON "data_catalog"."catalog_glossary_terms" ("term_code");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_terms_status" ON "data_catalog"."catalog_glossary_terms" ("status");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_terms_domain_id" ON "data_catalog"."catalog_glossary_terms" ("domain_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_glossary_term_revisions_no" ON "data_catalog"."catalog_glossary_term_revisions" ("term_id", "revision_no");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_glossary_term_links_pair" ON "data_catalog"."catalog_glossary_term_links" ("term_id", "object_id", COALESCE(column_id, '00000000-0000-0000-0000-000000000000'::uuid));

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_term_links_column_id" ON "data_catalog"."catalog_glossary_term_links" ("column_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_glossary_term_links_object_id" ON "data_catalog"."catalog_glossary_term_links" ("object_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_rules_code" ON "data_catalog"."quality_rules" ("rule_code");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_object_id" ON "data_catalog"."quality_rules" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_column_id" ON "data_catalog"."quality_rules" ("column_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_due" ON "data_catalog"."quality_rules" ("enabled", "schedule_minutes") WHERE enabled;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rules_owner_user_id" ON "data_catalog"."quality_rules" ("owner_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_rule_runs_one_active" ON "data_catalog"."quality_rule_runs" ("rule_id") WHERE status IN ('QUEUED', 'RUNNING');

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_rule_runs_idempotency" ON "data_catalog"."quality_rule_runs" ("requested_by_user_id", "idempotency_key") WHERE idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rule_runs_rule_created" ON "data_catalog"."quality_rule_runs" ("rule_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_rule_runs_status_created" ON "data_catalog"."quality_rule_runs" ("status", "created_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_issues_live" ON "data_catalog"."quality_issues" ("fingerprint") WHERE status IN ('OPEN', 'ACKNOWLEDGED');

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_status_severity" ON "data_catalog"."quality_issues" ("status", "severity");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_object_id" ON "data_catalog"."quality_issues" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_rule_id" ON "data_catalog"."quality_issues" ("rule_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_column_id" ON "data_catalog"."quality_issues" ("column_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_first_seen_run_id" ON "data_catalog"."quality_issues" ("first_seen_run_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issues_last_seen_run_id" ON "data_catalog"."quality_issues" ("last_seen_run_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issue_events_issue_created" ON "data_catalog"."quality_issue_events" ("issue_id", "created_at");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_issue_events_run_id" ON "data_catalog"."quality_issue_events" ("run_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_quality_score_snapshots_scope_asof" ON "data_catalog"."quality_score_snapshots" ("scope_kind", COALESCE(object_id, domain_id, '00000000-0000-0000-0000-000000000000'::uuid), "as_of");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_score_snapshots_object_asof" ON "data_catalog"."quality_score_snapshots" ("object_id", "as_of" DESC);

CREATE INDEX IF NOT EXISTS "ix_data_catalog_quality_score_snapshots_domain_asof" ON "data_catalog"."quality_score_snapshots" ("domain_id", "as_of" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_lineage_edges_identity" ON "data_catalog"."catalog_lineage_edges" ("source_kind", "source_ref", "target_kind", "target_ref", "edge_kind", "origin");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_lineage_edges_source" ON "data_catalog"."catalog_lineage_edges" ("source_kind", "source_ref");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_lineage_edges_target" ON "data_catalog"."catalog_lineage_edges" ("target_kind", "target_ref");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_lineage_edges_official" ON "data_catalog"."catalog_lineage_edges" ("source_kind", "source_ref") WHERE is_official;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_certifications_live" ON "data_catalog"."catalog_certifications" ("target_kind", COALESCE(object_id, read_model_definition_id, report_definition_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(kpi_code, '')) WHERE status IN ('REQUESTED', 'CERTIFIED');

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_status_expires" ON "data_catalog"."catalog_certifications" ("status", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_object_id" ON "data_catalog"."catalog_certifications" ("object_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_read_model_definition_id" ON "data_catalog"."catalog_certifications" ("read_model_definition_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_report_definition_id" ON "data_catalog"."catalog_certifications" ("report_definition_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_certifications_requested_by_user_id" ON "data_catalog"."catalog_certifications" ("requested_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_change_acknowledgements_event" ON "data_catalog"."catalog_change_acknowledgements" ("change_event_id");

CREATE INDEX IF NOT EXISTS "ix_data_catalog_change_acknowledgements_user_id" ON "data_catalog"."catalog_change_acknowledgements" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_governance_change_log_target_recorded" ON "system_ops"."governance_change_log" ("target_type", "target_id", "recorded_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_governance_policy_revisions_no" ON "system_ops"."governance_policy_revisions" ("policy_type", "policy_id", "revision_no");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_governance_policy_revisions_one_pending" ON "system_ops"."governance_policy_revisions" ("policy_type", "policy_id") WHERE status = 'PENDING_APPROVAL';

CREATE INDEX IF NOT EXISTS "ix_governance_policy_revisions_status_submitted" ON "system_ops"."governance_policy_revisions" ("status", "submitted_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_governance_policy_revisions_submitted_by_user_id" ON "system_ops"."governance_policy_revisions" ("submitted_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_governance_policy_revisions_decided_by_user_id" ON "system_ops"."governance_policy_revisions" ("decided_by_user_id");

-- ---- 4. FK entre schemas: iam.users, system_ops.data_domains, read_models, reporting (90_fk_deferred.sql de los modulos 67 y 11) ----
-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_objects"
        ADD CONSTRAINT "fk_catalog_objects_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_revisions"
        ADD CONSTRAINT "fk_catalog_glossary_term_revisions_author_user_id" FOREIGN KEY ("author_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_links"
        ADD CONSTRAINT "fk_catalog_glossary_term_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rule_runs"
        ADD CONSTRAINT "fk_quality_rule_runs_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_acknowledged_by_user_id" FOREIGN KEY ("acknowledged_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_resolved_by_user_id" FOREIGN KEY ("resolved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issue_events"
        ADD CONSTRAINT "fk_quality_issue_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_score_snapshots"
        ADD CONSTRAINT "fk_quality_score_snapshots_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_lineage_edges"
        ADD CONSTRAINT "fk_catalog_lineage_edges_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_lineage_edges"
        ADD CONSTRAINT "fk_catalog_lineage_edges_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_lineage_edges"
        ADD CONSTRAINT "fk_catalog_lineage_edges_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: read_models.read_model_definitions (requiere schema read_models)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_read_model_definition_id" FOREIGN KEY ("read_model_definition_id")
        REFERENCES "read_models"."read_model_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: reporting.report_definitions (requiere schema reporting)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_certified_by_user_id" FOREIGN KEY ("certified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_revoked_by_user_id" FOREIGN KEY ("revoked_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_change_acknowledgements"
        ADD CONSTRAINT "fk_catalog_change_acknowledgements_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_ops"."governance_policy_revisions"
        ADD CONSTRAINT "fk_governance_policy_revisions_submitted_by_user_id" FOREIGN KEY ("submitted_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_ops"."governance_policy_revisions"
        ADD CONSTRAINT "fk_governance_policy_revisions_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---- 5. integridad: CHECK de gobierno y UPDATE prohibido (05_constraints.sql de los modulos 67 y 11) ----
-- ═══ catalog_stewardships ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_stewardships" DROP CONSTRAINT IF EXISTS "ck_catalog_stewardships_scope";
ALTER TABLE "data_catalog"."catalog_stewardships" ADD CONSTRAINT "ck_catalog_stewardships_scope" CHECK ((("scope_kind" = 'DOMAIN' AND "domain_id" IS NOT NULL AND "object_id" IS NULL) OR ("scope_kind" = 'OBJECT' AND "object_id" IS NOT NULL AND "domain_id" IS NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_stewardships" DROP CONSTRAINT IF EXISTS "ck_catalog_stewardships_holder";
ALTER TABLE "data_catalog"."catalog_stewardships" ADD CONSTRAINT "ck_catalog_stewardships_holder" CHECK (("user_id" IS NOT NULL OR "team_code" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_stewardships" DROP CONSTRAINT IF EXISTS "ck_catalog_stewardships_period";
ALTER TABLE "data_catalog"."catalog_stewardships" ADD CONSTRAINT "ck_catalog_stewardships_period" CHECK (("valid_to" IS NULL OR "valid_to" >= "valid_from"));

-- ═══ catalog_glossary_term_revisions ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_glossary_term_revisions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_glossary_term_revisions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_glossary_term_revisions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ═══ quality_rules ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."quality_rules" DROP CONSTRAINT IF EXISTS "ck_quality_rules_threshold";
ALTER TABLE "data_catalog"."quality_rules" ADD CONSTRAINT "ck_quality_rules_threshold" CHECK (("threshold_pct" BETWEEN 0 AND 100));

-- ═══ quality_issue_events ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."quality_issue_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."quality_issue_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."quality_issue_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ═══ quality_score_snapshots ═══
--   UPDATE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."quality_score_snapshots" DROP CONSTRAINT IF EXISTS "ck_quality_score_snapshots_score";
ALTER TABLE "data_catalog"."quality_score_snapshots" ADD CONSTRAINT "ck_quality_score_snapshots_score" CHECK (("score" BETWEEN 0 AND 100));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."quality_score_snapshots" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."quality_score_snapshots";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."quality_score_snapshots"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ═══ catalog_certifications ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_certifications" DROP CONSTRAINT IF EXISTS "ck_catalog_certifications_not_self";
ALTER TABLE "data_catalog"."catalog_certifications" ADD CONSTRAINT "ck_catalog_certifications_not_self" CHECK (("certified_by_user_id" IS NULL OR "certified_by_user_id" <> "requested_by_user_id"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "data_catalog"."catalog_certifications" DROP CONSTRAINT IF EXISTS "ck_catalog_certifications_target";
ALTER TABLE "data_catalog"."catalog_certifications" ADD CONSTRAINT "ck_catalog_certifications_target" CHECK ((num_nonnulls("object_id", "read_model_definition_id", "report_definition_id", "kpi_code") = 1));

-- ═══ catalog_change_acknowledgements ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "data_catalog"."catalog_change_acknowledgements" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_change_acknowledgements";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_change_acknowledgements"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ═══ governance_policy_revisions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."governance_policy_revisions" DROP CONSTRAINT IF EXISTS "ck_governance_policy_revisions_not_self";
ALTER TABLE "system_ops"."governance_policy_revisions" ADD CONSTRAINT "ck_governance_policy_revisions_not_self" CHECK (("decided_by_user_id" IS NULL OR "decided_by_user_id" <> "submitted_by_user_id"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."governance_policy_revisions" DROP CONSTRAINT IF EXISTS "ck_governance_policy_revisions_decision";
ALTER TABLE "system_ops"."governance_policy_revisions" ADD CONSTRAINT "ck_governance_policy_revisions_decision" CHECK (("status" NOT IN ('APPROVED', 'REJECTED') OR ("decided_by_user_id" IS NOT NULL AND "decided_at" IS NOT NULL)));

-- ---- 6. guarda de columnas de governance_policy_revisions ----
-- Guarda de columnas de las revisiones de politica (D-F1b-7 del .puml 11). No es expresable en el .puml: vive en este generador, como las
-- politicas RLS de los parches v4278/v4280. Un UPDATE solo puede mover el ciclo de vida (status, decided_*, decision_comment, effective_from);
-- lo propuesto no cambia nunca, una decision tomada no se reescribe, el estado no retrocede y la historia no se borra.
CREATE OR REPLACE FUNCTION "system_ops"."guard_governance_policy_revision"() RETURNS trigger
LANGUAGE plpgsql AS $fn$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'append-only/immutable: DELETE no permitido en %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
    END IF;
    IF ROW(NEW.id, NEW.policy_type, NEW.policy_id, NEW.revision_no, NEW.content_json, NEW.content_hash, NEW.change_reason,
           NEW.submitted_by_user_id, NEW.submitted_at, NEW.created_at)
       IS DISTINCT FROM
       ROW(OLD.id, OLD.policy_type, OLD.policy_id, OLD.revision_no, OLD.content_json, OLD.content_hash, OLD.change_reason,
           OLD.submitted_by_user_id, OLD.submitted_at, OLD.created_at) THEN
        RAISE EXCEPTION 'append-only/immutable: lo propuesto de una revision de politica (contenido, hash, motivo, autor) no se modifica en %.%',
            TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
    END IF;
    IF OLD.decided_at IS NOT NULL
       AND ROW(NEW.decided_by_user_id, NEW.decided_at, NEW.decision_comment)
           IS DISTINCT FROM ROW(OLD.decided_by_user_id, OLD.decided_at, OLD.decision_comment) THEN
        RAISE EXCEPTION 'append-only/immutable: una decision ya tomada sobre una revision de politica no se reescribe (%.%)',
            TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
    END IF;
    IF (OLD.status IN ('REJECTED', 'SUPERSEDED') AND NEW.status <> OLD.status)
       OR (OLD.status = 'APPROVED' AND NEW.status NOT IN ('APPROVED', 'SUPERSEDED')) THEN
        RAISE EXCEPTION 'append-only/immutable: el estado de una revision de politica no retrocede (% -> %)', OLD.status, NEW.status
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS trg_guard_policy_revision ON "system_ops"."governance_policy_revisions";
CREATE TRIGGER trg_guard_policy_revision BEFORE UPDATE OR DELETE ON "system_ops"."governance_policy_revisions"
    FOR EACH ROW EXECUTE FUNCTION "system_ops"."guard_governance_policy_revision"();

-- ---- 7. permisos de la aplicacion (solo si existe el rol; 2026-08-05_tenant_rls.sql vuelve a conceder DML, el disparador sigue frenando) ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT SELECT, INSERT, DELETE ON "data_catalog"."catalog_glossary_term_revisions" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "data_catalog"."catalog_glossary_term_revisions" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "data_catalog"."quality_issue_events" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "data_catalog"."quality_issue_events" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "data_catalog"."quality_score_snapshots" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "data_catalog"."quality_score_snapshots" FROM mantra_app;
        GRANT SELECT, INSERT, DELETE ON "data_catalog"."catalog_change_acknowledgements" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "data_catalog"."catalog_change_acknowledgements" FROM mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."catalog_stewardships" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."catalog_glossary_terms" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."catalog_glossary_term_links" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."quality_rules" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."quality_rule_runs" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."quality_issues" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."catalog_lineage_edges" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "data_catalog"."catalog_certifications" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE ON "system_ops"."governance_policy_revisions" TO mantra_app;
        REVOKE DELETE, TRUNCATE ON "system_ops"."governance_policy_revisions" FROM mantra_app;
    END IF;
END $$;

-- ---- 8. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'data_catalog' AND table_type = 'BASE TABLE' AND table_name IN ('catalog_stewardships', 'catalog_glossary_terms', 'catalog_glossary_term_revisions', 'catalog_glossary_term_links', 'quality_rules', 'quality_rule_runs', 'quality_issues', 'quality_issue_events', 'quality_score_snapshots', 'catalog_lineage_edges', 'catalog_certifications', 'catalog_change_acknowledgements');
    IF n <> 12 THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber 12 tablas nuevas en data_catalog y hay %', n; END IF;
    IF to_regclass('system_ops.governance_policy_revisions') IS NULL THEN RAISE EXCEPTION 'v4281 gobierno: falta system_ops.governance_policy_revisions'; END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'data_catalog' AND table_name = 'catalog_objects' AND column_name = 'domain_id') THEN
        RAISE EXCEPTION 'v4281 gobierno: falta catalog_objects.domain_id';
    END IF;
    IF to_regclass('system_ops.ix_governance_change_log_target_recorded') IS NULL THEN RAISE EXCEPTION 'v4281 gobierno: falta ix_governance_change_log_target_recorded'; END IF;
    -- D-F1b-1: ninguna tabla nueva lleva tenant (el RLS global las alcanzaria y la escritura de plataforma dejaria de funcionar)
    SELECT count(*) INTO n FROM information_schema.columns
     WHERE column_name IN ('tenant_id', 'actor_tenant_id')
       AND ((table_schema = 'data_catalog' AND table_name IN ('catalog_stewardships', 'catalog_glossary_terms', 'catalog_glossary_term_revisions', 'catalog_glossary_term_links', 'quality_rules', 'quality_rule_runs', 'quality_issues', 'quality_issue_events', 'quality_score_snapshots', 'catalog_lineage_edges', 'catalog_certifications', 'catalog_change_acknowledgements')) OR (table_schema = 'system_ops' AND table_name = 'governance_policy_revisions'));
    IF n <> 0 THEN RAISE EXCEPTION 'v4281 gobierno: las tablas nuevas no deben tener columna de tenant (decision D-F1b-1): %', n; END IF;
    SELECT count(*) INTO n FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE t.tgname = 'trg_forbid_update' AND NOT t.tgisinternal AND s.nspname = 'data_catalog' AND c.relname IN ('catalog_glossary_term_revisions', 'quality_issue_events', 'quality_score_snapshots', 'catalog_change_acknowledgements');
    IF n <> 4 THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber 4 disparadores trg_forbid_update y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE t.tgname = 'trg_guard_policy_revision' AND NOT t.tgisinternal AND s.nspname = 'system_ops' AND c.relname = 'governance_policy_revisions';
    IF n <> 1 THEN RAISE EXCEPTION 'v4281 gobierno: falta el disparador de columnas de governance_policy_revisions'; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'c' AND ((s.nspname = 'data_catalog' AND c.relname IN ('catalog_stewardships', 'catalog_glossary_terms', 'catalog_glossary_term_revisions', 'catalog_glossary_term_links', 'quality_rules', 'quality_rule_runs', 'quality_issues', 'quality_issue_events', 'quality_score_snapshots', 'catalog_lineage_edges', 'catalog_certifications', 'catalog_change_acknowledgements')) OR (s.nspname = 'system_ops' AND c.relname = 'governance_policy_revisions'));
    IF n <> 9 THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber 9 CHECK y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'f' AND ((s.nspname = 'data_catalog' AND (c.relname IN ('catalog_stewardships', 'catalog_glossary_terms', 'catalog_glossary_term_revisions', 'catalog_glossary_term_links', 'quality_rules', 'quality_rule_runs', 'quality_issues', 'quality_issue_events', 'quality_score_snapshots', 'catalog_lineage_edges', 'catalog_certifications', 'catalog_change_acknowledgements') OR k.conname = 'fk_catalog_objects_domain_id'))
                              OR (s.nspname = 'system_ops' AND c.relname = 'governance_policy_revisions'));
    IF n <> 48 THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber 48 FK y hay %', n; END IF;
    RAISE NOTICE 'v4281 gobierno: 13 tablas, 48 FK, 51 indices, 9 CHECK, 4+1 disparadores';
END $$;

COMMIT;
