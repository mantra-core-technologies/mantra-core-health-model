-- ============================================================================
-- SALUD · patch de la sonda de ajuste de la catalogación (data_catalog.catalog_fit_runs) sobre BD viva
-- Fecha: 2026-11-01
-- Escrito a mano a partir de la propuesta de DDL de mantra-core-health-api/src/modules/data_catalog/application/fit/README.md
-- (la tabla aún no está declarada en el .puml del modelo: ver «PENDIENTE DEL MODELO» abajo). Idempotente (CREATE ... IF NOT EXISTS,
-- CHECK con DROP IF EXISTS + ADD, trigger con DROP IF EXISTS + CREATE). UNA sola transacción; se puede volver a correr.
--
-- Qué guarda: el desenlace de cada corrida de la sonda de ajuste (tick del worker cada 5 min o pedido manual desde la consola),
-- con el informe completo en `report_json`. Antes vivía sólo en la memoria del proceso (TTL 24 h): un reinicio vaciaba el historial
-- y cada réplica veía sólo sus propias corridas.
--
-- MUTABILIDAD: APPEND_ONLY_PURGEABLE. Una corrida terminada no cambia (trigger `trg_forbid_update` + REVOKE UPDATE); la API
-- purga por retención (DELETE de filas con `finished_at` más viejo que su ventana, hoy 30 días). Las corridas EN_CURSO no se
-- escriben: sólo se inserta el desenlace, por eso no hace falta UPDATE.
--
-- PREREQUISITOS: schema data_catalog y la función integrity.forbid_mutation (2026-10-24_v4248_data_catalog_operaciones_y_worm.sql).
--
-- QUE AGREGA
--   data_catalog.catalog_fit_runs  1 tabla · 2 índices (1 único parcial de idempotencia) · 4 CHECK · 1 trigger
--   RLS: sin columna tenant_id; es dato de plataforma (la sonda es @TenantAgnostic en la API).
--
-- PENDIENTE DEL MODELO: declarar la tabla en el diagrama del esquema 67 y regenerar (gen_ddl.py / gen_entities.py) para que el
-- rebuild desde cero la traiga; mientras tanto sólo la trae este parche y la API la lee con SQL parametrizado (sin entidad ORM,
-- para no abrir una deriva ORM ↔ modelo).
--
-- REVERSA (el parche sólo agrega; la API cae a memoria si la tabla no existe):
--   DROP TABLE IF EXISTS "data_catalog"."catalog_fit_runs";
-- ============================================================================

BEGIN;

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'data_catalog') THEN
        RAISE EXCEPTION 'falta el schema data_catalog: aplicar antes apply_all.sql';
    END IF;
    IF to_regprocedure('integrity.forbid_mutation()') IS NULL THEN
        RAISE EXCEPTION 'falta integrity.forbid_mutation(): aplicar antes 2026-10-24_v4248_data_catalog_operaciones_y_worm.sql';
    END IF;
END $$;

-- ---- 1. tabla ----
CREATE TABLE IF NOT EXISTS "data_catalog"."catalog_fit_runs" (
    "id" uuid NOT NULL,
    "source_code" varchar(40) NOT NULL DEFAULT 'primary',
    "trigger_kind" varchar(10) NOT NULL,
    "requested_by_user_id" uuid,
    "idempotency_key" varchar(128),
    "status" varchar(12) NOT NULL,
    "model_version" varchar(40) NOT NULL,
    "verdict" varchar(12),
    "code_fingerprint" varchar(64),
    "deployed_commit" varchar(64),
    "report_json" jsonb,
    "error_code" varchar(80),
    "requested_at" timestamptz NOT NULL,
    "finished_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "pk_catalog_fit_runs" PRIMARY KEY ("id")
);

COMMENT ON TABLE "data_catalog"."catalog_fit_runs" IS
    'Desenlace de cada corrida de la sonda de ajuste de la catalogación (append-only, purgable por retención). report_json = FitReport completo.';

-- ---- 2. índices ----
CREATE UNIQUE INDEX IF NOT EXISTS "ux_data_catalog_fit_runs_idempotency"
    ON "data_catalog"."catalog_fit_runs" ("trigger_kind", "idempotency_key") WHERE idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_data_catalog_fit_runs_finished"
    ON "data_catalog"."catalog_fit_runs" ("source_code", "finished_at" DESC);

-- ---- 3. integridad: CHECK de vocabularios y de forma ----
ALTER TABLE "data_catalog"."catalog_fit_runs" DROP CONSTRAINT IF EXISTS "ck_catalog_fit_runs_trigger_kind";
ALTER TABLE "data_catalog"."catalog_fit_runs" ADD CONSTRAINT "ck_catalog_fit_runs_trigger_kind"
    CHECK ("trigger_kind" IN ('TICK', 'MANUAL'));

ALTER TABLE "data_catalog"."catalog_fit_runs" DROP CONSTRAINT IF EXISTS "ck_catalog_fit_runs_status";
ALTER TABLE "data_catalog"."catalog_fit_runs" ADD CONSTRAINT "ck_catalog_fit_runs_status"
    CHECK ("status" IN ('COMPLETADA', 'FALLIDA'));

ALTER TABLE "data_catalog"."catalog_fit_runs" DROP CONSTRAINT IF EXISTS "ck_catalog_fit_runs_verdict";
ALTER TABLE "data_catalog"."catalog_fit_runs" ADD CONSTRAINT "ck_catalog_fit_runs_verdict"
    CHECK ("verdict" IS NULL OR "verdict" IN ('AJUSTADA', 'CON_AVISOS', 'DESAJUSTADA', 'SIN_DATOS'));

-- Una corrida COMPLETADA trae veredicto e informe y no trae error; una FALLIDA trae error y no trae informe.
ALTER TABLE "data_catalog"."catalog_fit_runs" DROP CONSTRAINT IF EXISTS "ck_catalog_fit_runs_outcome_shape";
ALTER TABLE "data_catalog"."catalog_fit_runs" ADD CONSTRAINT "ck_catalog_fit_runs_outcome_shape"
    CHECK (
        ("status" = 'COMPLETADA' AND "verdict" IS NOT NULL AND "report_json" IS NOT NULL AND "error_code" IS NULL)
     OR ("status" = 'FALLIDA' AND "error_code" IS NOT NULL AND "report_json" IS NULL)
    );

-- ---- 4. append-only (purgable): UPDATE prohibido; DELETE queda para la purga por retención ----
REVOKE UPDATE ON "data_catalog"."catalog_fit_runs" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "data_catalog"."catalog_fit_runs";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "data_catalog"."catalog_fit_runs"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ---- 5. permisos de la aplicación (sólo si existe el rol) ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT SELECT, INSERT, DELETE ON "data_catalog"."catalog_fit_runs" TO mantra_app;
        REVOKE UPDATE, TRUNCATE ON "data_catalog"."catalog_fit_runs" FROM mantra_app;
    END IF;
END $$;

-- ---- 6. verificación (aborta la transacción si algo no quedó como se espera) ----
DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables
     WHERE table_schema = 'data_catalog' AND table_name = 'catalog_fit_runs';
    IF n <> 1 THEN RAISE EXCEPTION 'falta data_catalog.catalog_fit_runs'; END IF;
    SELECT count(*) INTO n FROM information_schema.columns
     WHERE table_schema = 'data_catalog' AND table_name = 'catalog_fit_runs';
    IF n <> 15 THEN RAISE EXCEPTION 'catalog_fit_runs deberia tener 15 columnas y tiene %', n; END IF;
    SELECT count(*) INTO n FROM pg_indexes
     WHERE schemaname = 'data_catalog' AND tablename = 'catalog_fit_runs'
       AND indexname IN ('ux_data_catalog_fit_runs_idempotency', 'ix_data_catalog_fit_runs_finished');
    IF n <> 2 THEN RAISE EXCEPTION 'deberia haber 2 indices en catalog_fit_runs y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid JOIN pg_namespace s ON s.oid = t.relnamespace
     WHERE c.contype = 'c' AND s.nspname = 'data_catalog' AND t.relname = 'catalog_fit_runs';
    IF n <> 4 THEN RAISE EXCEPTION 'deberia haber 4 CHECK en catalog_fit_runs y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_trigger tg JOIN pg_class t ON t.oid = tg.tgrelid JOIN pg_namespace s ON s.oid = t.relnamespace
     WHERE NOT tg.tgisinternal AND s.nspname = 'data_catalog' AND t.relname = 'catalog_fit_runs' AND tg.tgname = 'trg_forbid_update';
    IF n <> 1 THEN RAISE EXCEPTION 'falta el trigger trg_forbid_update en catalog_fit_runs'; END IF;
END $$;

COMMIT;
