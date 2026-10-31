-- ============================================================================
-- SALUD · patch v4.2.81 (franja F1b del portal de observabilidad y gobierno: cargas masivas, lote persistente de bulk_import) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_v4281_patches.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a mano
-- salvo las políticas RLS, los permisos y las comprobaciones. Idempotente (CREATE ... IF NOT EXISTS, FK con duplicate_object, CHECK con DROP IF
-- EXISTS + ADD). UNA sola transacción; se puede volver a correr. Solo AGREGA.
--
-- Contexto: 06-cargas-masivas-aprobacion-gobierno-usuarios.md H2.S1.M1 del plan docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo del
-- front). Contrato del API que estas tablas calzan: src/modules/bulk_import/ports/bulk-import.ports.ts (BatchRecord, StoredRow, ReportRow,
-- BulkImportBatchRepository), bulk-import.constants.ts (estados y resultados) y bulk-import.error-reasons.ts (motivos).
--
-- QUE AGREGA (system_ops, módulo 11)
--   bulk_import_batches     el lote: tipo y versión, estado, formato y tamaño del archivo, hash del archivo, declaración (motivo, organización de origen,
--                           base legal, fecha de carga), contadores, hallazgos de la vista previa, clave de confirmación UNICA por (organización, clave),
--                           quién y cuándo confirmó, solicitud de aprobación (FK a delegated_access.four_eyes_requests), informe final
--   bulk_import_batch_rows  una fila por fila del archivo: resultado, motivo (código estable), columna, entidad creada (target_entity, target_id)
--                           7 FK, 12 índices, 3 CHECK en total
--   RLS: tenant_isolation en las 2 tablas (llevan `tenant_id`, a propósito)
--
-- DECISIONES (detalle en el .puml 11)
--   * Viven en system_ops, no en un módulo nuevo: no hay número libre (55-59 NoSQL, 70 observability, 71-89 PAY) y se evita un schema con
--     USAGE/GRANT propios.
--   * SIN PII en las columnas de resultado. Lo único con datos personales es bulk_import_batch_rows.row_data_json y su row_key (hash de
--     tenant+tipo+clave natural, seudónimo), ambos TRANSITORIOS: ck_bulk_import_batch_rows_closed_no_data impide que una fila con resultado los
--     conserve. El archivo original no se guarda, solo su hash. Para comprobar que no queda nada sobre un lote cerrado:
--       SELECT count(*) FROM system_ops.bulk_import_batch_rows r JOIN system_ops.bulk_import_batches b ON b.id = r.batch_id
--        WHERE b.status IN ('COMPLETADO','FALLIDO','RECHAZADO') AND (r.row_data_json IS NOT NULL OR r.row_key IS NOT NULL);   -- debe ser 0
--   * Estados y resultados son texto (los valores en español del enum del API) sin CHECK de vocabulario: el API los gobierna con
--     BATCH_TRANSITIONS y un estado nuevo no debe exigir un parche del modelo. La espera de aprobación (06 H3) se modela con approval_request_id.
--
-- REVERSA (solo agrega):
--   DROP TABLE IF EXISTS system_ops.bulk_import_batch_rows, system_ops.bulk_import_batches;
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '15s';

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regclass('delegated_access.four_eyes_requests') IS NULL OR to_regclass('directory.tenants') IS NULL OR to_regclass('iam.users') IS NULL THEN
        RAISE EXCEPTION 'faltan tablas base (delegated_access.four_eyes_requests (parche v4278), directory.tenants, iam.users): aplicar antes apply_all.sql y los parches v4275/v4278';
    END IF;
END $$;

-- ---- 1. tablas del lote (SQL/11_system_ops/02_tables.sql) ----
CREATE TABLE IF NOT EXISTS "system_ops"."bulk_import_batches" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "kind" varchar NOT NULL,
    "kind_version" varchar NOT NULL,
    "kind_group" varchar NOT NULL,
    "status" varchar NOT NULL,
    "source_format" varchar NOT NULL,
    "source_byte_size" integer NOT NULL,
    "file_sha256" varchar(64),
    "declared_reason" text,
    "declared_source_organization" varchar,
    "declared_legal_basis" varchar,
    "declared_loaded_on" date,
    "rows_total" integer NOT NULL,
    "rows_valid" integer NOT NULL,
    "rows_rejected" integer NOT NULL,
    "issues_total" integer NOT NULL DEFAULT 0,
    "processed_rows" integer NOT NULL DEFAULT 0,
    "file_issues_json" jsonb,
    "preview_issues_json" jsonb,
    "confirm_key" varchar(128),
    "confirmed_at" timestamptz,
    "confirmed_by_user_id" uuid,
    "approval_request_id" uuid,
    "started_at" timestamptz,
    "finished_at" timestamptz,
    "failure_reason" varchar,
    "report_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_bulk_import_batches" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "system_ops"."bulk_import_batch_rows" (
    "id" uuid NOT NULL,
    "batch_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "row_no" integer NOT NULL,
    "outcome" varchar,
    "reason_code" varchar,
    "field_name" varchar,
    "target_entity" varchar,
    "target_id" uuid,
    "processed_at" timestamptz,
    "row_key" varchar(64),
    "row_data_json" jsonb,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_bulk_import_batch_rows" PRIMARY KEY ("id")
);

-- ---- 2. FK dentro de system_ops (SQL/11_system_ops/03_fk_intra.sql) ----


-- ---- 3. indices (SQL/11_system_ops/04_indexes.sql; el UNIQUE (tenant_id, id) de four_eyes_requests es el destino de la FK compuesta) ----
CREATE UNIQUE INDEX IF NOT EXISTS "uq_bulk_import_batches_tenant_id_id" ON "system_ops"."bulk_import_batches" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_bulk_import_batches_confirm_key" ON "system_ops"."bulk_import_batches" ("tenant_id", "confirm_key") WHERE confirm_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batches_tenant_created" ON "system_ops"."bulk_import_batches" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batches_active" ON "system_ops"."bulk_import_batches" ("status", "created_at") WHERE status IN ('EN_COLA', 'PROCESANDO');

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batches_file_hash" ON "system_ops"."bulk_import_batches" ("tenant_id", "kind", "file_sha256") WHERE file_sha256 IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batches_approval_request_id" ON "system_ops"."bulk_import_batches" ("approval_request_id") WHERE approval_request_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batches_confirmed_by_user_id" ON "system_ops"."bulk_import_batches" ("confirmed_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_bulk_import_batch_rows_row" ON "system_ops"."bulk_import_batch_rows" ("batch_id", "row_no");

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batch_rows_outcome" ON "system_ops"."bulk_import_batch_rows" ("batch_id", "outcome");

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batch_rows_tenant_id" ON "system_ops"."bulk_import_batch_rows" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batch_rows_target" ON "system_ops"."bulk_import_batch_rows" ("target_entity", "target_id") WHERE target_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_bulk_import_batch_rows_pending_data" ON "system_ops"."bulk_import_batch_rows" ("batch_id") WHERE row_data_json IS NOT NULL OR row_key IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_four_eyes_requests_tenant_id_id" ON "delegated_access"."four_eyes_requests" ("tenant_id", "id");

-- ---- 3b. FK simples anteriores (primer borrador de este parche) -> se sustituyen por las compuestas por tenant; no-op si ya son compuestas ----
DO $$
DECLARE r record;
BEGIN
    FOR r IN SELECT k.conname, c.relname FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
              WHERE k.contype = 'f' AND s.nspname = 'system_ops' AND array_length(k.conkey, 1) = 1
                AND k.conname IN ('fk_bulk_import_batch_rows_batch_id', 'fk_bulk_import_batches_approval_request_id') LOOP
        EXECUTE format('ALTER TABLE system_ops.%I DROP CONSTRAINT %I', r.relname, r.conname);
    END LOOP;
END $$;

-- ---- 4. FK entre schemas y COMPUESTAS POR TENANT (una fila del tenant A no puede apuntar a un lote ni a una aprobacion del tenant B): SQL/11_system_ops/90_fk_deferred.sql ----
-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "system_ops"."bulk_import_batches"
        ADD CONSTRAINT "fk_bulk_import_batches_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_ops"."bulk_import_batches"
        ADD CONSTRAINT "fk_bulk_import_batches_confirmed_by_user_id" FOREIGN KEY ("confirmed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: system_ops.bulk_import_batches sólo apunta a delegated_access.four_eyes_requests del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "system_ops"."bulk_import_batches"
        ADD CONSTRAINT "fk_bulk_import_batches_approval_request_id" FOREIGN KEY ("tenant_id", "approval_request_id")
        REFERENCES "delegated_access"."four_eyes_requests" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_ops"."bulk_import_batches"
        ADD CONSTRAINT "fk_bulk_import_batches_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "system_ops"."bulk_import_batches"
        ADD CONSTRAINT "fk_bulk_import_batches_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- compuesta: system_ops.bulk_import_batch_rows sólo apunta a system_ops.bulk_import_batches del mismo tenant_id
DO $$ BEGIN
    ALTER TABLE "system_ops"."bulk_import_batch_rows"
        ADD CONSTRAINT "fk_bulk_import_batch_rows_batch_id" FOREIGN KEY ("tenant_id", "batch_id")
        REFERENCES "system_ops"."bulk_import_batches" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "system_ops"."bulk_import_batch_rows"
        ADD CONSTRAINT "fk_bulk_import_batch_rows_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ---- 5. integridad: contadores y «sin datos personales en una fila cerrada» (SQL/11_system_ops/05_constraints.sql) ----
-- ═══ bulk_import_batches ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."bulk_import_batches" DROP CONSTRAINT IF EXISTS "ck_bulk_import_batches_counts";
ALTER TABLE "system_ops"."bulk_import_batches" ADD CONSTRAINT "ck_bulk_import_batches_counts" CHECK (("rows_total" >= 0 AND "rows_valid" >= 0 AND "rows_rejected" >= 0 AND "rows_total" = "rows_valid" + "rows_rejected" AND "processed_rows" BETWEEN 0 AND "rows_total" AND "issues_total" >= 0));

-- ═══ bulk_import_batch_rows ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."bulk_import_batch_rows" DROP CONSTRAINT IF EXISTS "ck_bulk_import_batch_rows_row_no";
ALTER TABLE "system_ops"."bulk_import_batch_rows" ADD CONSTRAINT "ck_bulk_import_batch_rows_row_no" CHECK (("row_no" >= 1));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "system_ops"."bulk_import_batch_rows" DROP CONSTRAINT IF EXISTS "ck_bulk_import_batch_rows_closed_no_data";
ALTER TABLE "system_ops"."bulk_import_batch_rows" ADD CONSTRAINT "ck_bulk_import_batch_rows_closed_no_data" CHECK (("outcome" IS NULL OR ("row_data_json" IS NULL AND "row_key" IS NULL)));

-- ---- 6. RLS: tenant_isolation en las tablas del lote (mismo patron que 2026-08-05_tenant_rls.sql y el v4278; la fila repite el tenant del lote) ----
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN SELECT * FROM (VALUES ('system_ops', 'bulk_import_batches'), ('system_ops', 'bulk_import_batch_rows')) AS v(s, t) LOOP
        EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I.%I', r.s, r.t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %I.%I
          USING (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, r.s, r.t);
    END LOOP;
END $$;

-- ---- 7. permisos de la aplicacion (solo si existe el rol) ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT SELECT, INSERT, UPDATE, DELETE ON "system_ops"."bulk_import_batches" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON "system_ops"."bulk_import_batch_rows" TO mantra_app;
    END IF;
END $$;

-- ---- 8. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'system_ops' AND table_type = 'BASE TABLE' AND table_name IN ('bulk_import_batches', 'bulk_import_batch_rows');
    IF n <> 2 THEN RAISE EXCEPTION 'v4281 cargas: deberia haber 2 tablas del lote y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_indexes WHERE schemaname = 'system_ops' AND indexname = 'ux_bulk_import_batches_confirm_key' AND indexdef LIKE 'CREATE UNIQUE INDEX%';
    IF n <> 1 THEN RAISE EXCEPTION 'v4281 cargas: falta el indice unico de la clave de confirmacion por organizacion'; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'c' AND s.nspname = 'system_ops' AND c.relname IN ('bulk_import_batches', 'bulk_import_batch_rows');
    IF n <> 3 THEN RAISE EXCEPTION 'v4281 cargas: deberia haber 3 CHECK y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'f' AND s.nspname = 'system_ops' AND c.relname IN ('bulk_import_batches', 'bulk_import_batch_rows');
    IF n <> 7 THEN RAISE EXCEPTION 'v4281 cargas: deberia haber 7 FK y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint k WHERE k.contype = 'f' AND array_length(k.conkey, 1) = 2
       AND k.conname IN ('fk_bulk_import_batch_rows_batch_id', 'fk_bulk_import_batches_approval_request_id');
    IF n <> 2 THEN RAISE EXCEPTION 'v4281 cargas: las FK batch_id y approval_request_id deben ser compuestas con tenant_id'; END IF;
    SELECT count(*) INTO n FROM pg_policies WHERE schemaname = 'system_ops' AND tablename IN ('bulk_import_batches', 'bulk_import_batch_rows') AND policyname = 'tenant_isolation';
    IF n <> 2 THEN RAISE EXCEPTION 'v4281 cargas: deberia haber 2 politicas tenant_isolation y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_class c JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE s.nspname = 'system_ops' AND c.relname IN ('bulk_import_batches', 'bulk_import_batch_rows') AND c.relrowsecurity AND c.relforcerowsecurity;
    IF n <> 2 THEN RAISE EXCEPTION 'v4281 cargas: las tablas del lote deben tener RLS forzada'; END IF;
    RAISE NOTICE 'v4281 cargas: 2 tablas, 7 FK, 12 indices, 3 CHECK, RLS forzada';
END $$;

COMMIT;
