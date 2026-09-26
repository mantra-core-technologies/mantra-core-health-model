-- ============================================================================
-- SALUD · patch v4.2.25 (qa_execution · módulo 68) sobre una BD viva
-- Fecha original: 2026-09-18 (API, v4.2.20) · promovido al modelo: 2026-09-26
--
-- PROMOCIÓN AL MODELO (carril M1, reparto de 6 máquinas). Colisionaba con
-- v4.2.20 de restore_test_runs.objective_status (dos parches distintos,
-- mismo número). Se renumera a v4.2.25.
--
-- `diagram_68_qa_execution.puml` YA EXISTE, transcribiendo estas mismas 4
-- tablas: verificado regenerando con `gen_ddl.py 68` y diffeando columna por
-- columna contra este patch — 0 diferencias en las 4 tablas, y los 6 nombres
-- de índice, idénticos. Decisiones en ADR-0025-qa-runner-en-servidor.md (API).
-- Idempotente. UNA sola pasada: módulo nuevo, cero filas.
--
-- QUÉ CIERRA. El laboratorio de QA (módulo 36) sólo registraba lo que el
-- cliente decía haber enviado y recibido. Este schema es el plano de ejecución
-- del servidor: destinos aprobados por entorno, planes con hash, aprobaciones
-- ligadas a ese hash y bitácora de progreso. Sin CHECK sobre estados (se
-- validan en el dominio, igual que en v4.2.19).
--
-- Delta esperado: +1 schema · +4 tablas · +14 FK · +6 índices.
-- ============================================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS "qa_execution";

CREATE TABLE IF NOT EXISTS "qa_execution"."execution_targets" (
    "id" uuid NOT NULL,
    "environment_id" uuid NOT NULL,
    "scheme" varchar NOT NULL,
    "host" varchar NOT NULL,
    "port" int NOT NULL,
    "allowed_path_prefixes" jsonb NOT NULL,
    "allow_private_network" boolean NOT NULL,
    "allow_mutations" boolean NOT NULL,
    "auth_secret_ref" varchar,
    "auth_header_name" varchar,
    "max_requests" int NOT NULL,
    "max_duration_seconds" int NOT NULL,
    "request_timeout_ms" int NOT NULL,
    "min_interval_ms" int NOT NULL,
    "status" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" int NOT NULL DEFAULT 1,
    CONSTRAINT "execution_targets_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_execution"."execution_plans" (
    "id" uuid NOT NULL,
    "run_id" uuid NOT NULL,
    "suite_id" uuid NOT NULL,
    "suite_version" int NOT NULL,
    "environment_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "plan_hash" varchar NOT NULL,
    "plan_json" jsonb NOT NULL,
    "limits_json" jsonb NOT NULL,
    "requires_approval" boolean NOT NULL,
    "approval_reasons" jsonb,
    "status" varchar NOT NULL,
    "requested_by_user_id" uuid,
    "idempotency_key" varchar,
    "lease_owner" varchar,
    "lease_expires_at" timestamptz,
    "attempt" int NOT NULL,
    "cancel_requested_at" timestamptz,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "requests_sent" int NOT NULL,
    "cases_passed" int NOT NULL,
    "cases_failed" int NOT NULL,
    "cases_not_run" int NOT NULL,
    "error_code" varchar,
    "error_message" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" int NOT NULL DEFAULT 1,
    CONSTRAINT "execution_plans_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_execution"."plan_approvals" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "plan_hash" varchar NOT NULL,
    "decision" varchar NOT NULL,
    "reason" text NOT NULL,
    "approver_user_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "plan_approvals_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "qa_execution"."plan_events" (
    "id" uuid NOT NULL,
    "plan_id" uuid NOT NULL,
    "seq" int NOT NULL,
    "kind" varchar NOT NULL,
    "case_id" uuid,
    "detail_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "plan_events_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_qa_execution_targets_environment"
    ON "qa_execution"."execution_targets" ("environment_id");
CREATE INDEX IF NOT EXISTS "ix_qa_execution_plans_status_created"
    ON "qa_execution"."execution_plans" ("status", "created_at");
CREATE INDEX IF NOT EXISTS "ix_qa_execution_plans_run_id"
    ON "qa_execution"."execution_plans" ("run_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_qa_execution_plans_idempotency"
    ON "qa_execution"."execution_plans" ("requested_by_user_id", "idempotency_key")
    WHERE idempotency_key IS NOT NULL;
CREATE INDEX IF NOT EXISTS "ix_qa_execution_plan_approvals_plan"
    ON "qa_execution"."plan_approvals" ("plan_id", "created_at");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_qa_execution_plan_events_seq"
    ON "qa_execution"."plan_events" ("plan_id", "seq");

DO $$
DECLARE
    fk record;
BEGIN
    FOR fk IN
        SELECT * FROM (VALUES
            ('execution_targets', 'environment_id', 'qa_lab', 'test_environments'),
            ('execution_targets', 'created_by_user_id', 'iam', 'users'),
            ('execution_targets', 'updated_by_user_id', 'iam', 'users'),
            ('execution_plans', 'run_id', 'qa_lab', 'test_runs'),
            ('execution_plans', 'suite_id', 'qa_lab', 'test_suites'),
            ('execution_plans', 'environment_id', 'qa_lab', 'test_environments'),
            ('execution_plans', 'target_id', 'qa_execution', 'execution_targets'),
            ('execution_plans', 'requested_by_user_id', 'iam', 'users'),
            ('execution_plans', 'created_by_user_id', 'iam', 'users'),
            ('execution_plans', 'updated_by_user_id', 'iam', 'users'),
            ('plan_approvals', 'plan_id', 'qa_execution', 'execution_plans'),
            ('plan_approvals', 'approver_user_id', 'iam', 'users'),
            ('plan_events', 'plan_id', 'qa_execution', 'execution_plans'),
            ('plan_events', 'case_id', 'qa_lab', 'test_cases')
        ) AS t(src_table, src_column, dst_schema, dst_table)
    LOOP
        BEGIN
            EXECUTE format(
                'ALTER TABLE qa_execution.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I (id)',
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
