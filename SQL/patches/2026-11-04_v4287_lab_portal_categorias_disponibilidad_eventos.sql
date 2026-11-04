-- ============================================================================
-- SALUD · patch v4.2.87 (portal de laboratorio/imagenología: categorías de servicios,
--                         "disponible hoy", tipo de muestra en texto y cancelación /
--                         rechazo de la orden por el ejecutor) sobre BD viva
-- Fecha: 2026-11-04 · Issue: mantra-core-technologies/mantra-core-health-model#116
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE ... IF NOT EXISTS / FK bajo guarda /
-- DROP POLICY|TRIGGER IF EXISTS). UNA sola transacción, SIN backfill.
--
-- QUÉ ENTRA.
--   diagnostic_units.diagnostic_study_offerings  +3 columnas
--     specimen_description  text NULL                 tipo de muestra en texto libre del laboratorio
--     service_category_id   uuid NULL  -> categoría   (sin ON DELETE: una categoría con servicios no se borra)
--     available             boolean NOT NULL DEFAULT true   "disponible hoy"; false = el paciente no lo ve ni lo reserva
--   diagnostic_units.diagnostic_service_categories  tabla nueva: categorías propias de cada unidad,
--     únicas por (unidad, lower(nombre)).
--   diagnostics.service_request_performer_events    tabla nueva, append-only: la respuesta del ejecutor
--     (laboratorio / centro de imagen) a una orden que NO emitió. clinical.service_requests es del tenant
--     solicitante (custodian_tenant_id, v4.2.26) y el ejecutor sólo puede leerla; para cancelarla o
--     rechazarla agrega aquí una fila propia con su motivo. El evento más reciente de una orden es su
--     desenlace del lado del ejecutor. La fila de la orden no se toca.
--
-- POR QUÉ SIN BACKFILL. Los servicios existentes quedan sin categoría, disponibles y sin texto de muestra:
-- es exactamente lo que la API devolvía hasta hoy. Inventar una categoría sería fabricar un dato.
--
-- RLS de service_request_performer_events: aislamiento por custodio (ENABLE+FORCE) en ESTA transacción,
-- con la misma política que v4.2.26 —el ejecutor es el custodio de sus filas—, y un disparador que exige
-- que quien escribe sea el ejecutor de la orden (performer_tenant_id): sin él cualquier tenant podría
-- anotar un desenlace sobre la orden de otro. La tabla de categorías no lleva tenant_id: igual que el
-- resto del módulo 23 (ofertas, sedes, precios), la API la acota por la unidad del tenant activo.
--
-- v4.2.26 sigue descubriendo la tabla de eventos en una reconstrucción completa (tiene
-- custodian_tenant_id); no hace falta re-ejecutarlo tras este parche.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de diagnostic_study_offerings                       +3
--   tablas                                                       +2
--   FKs                                                          +8 (1 oferta->categoría, 3 categorías, 4 eventos)
--   índices (sin contar las PK)                                  +8 (1 oferta, 3 categorías, 4 eventos)
--   RLS en eventos                                               ENABLE+FORCE, política +1 (custodian_tenant_isolation)
--   disparadores                                                 +2 (coherencia ejecutor, inmutabilidad)
-- ============================================================================

BEGIN;

-- --------------------------------------------------------------- 0. prerrequisitos
DO $$
BEGIN
    IF to_regclass('diagnostic_units.diagnostic_study_offerings') IS NULL
       OR to_regclass('diagnostic_units.diagnostic_units') IS NULL THEN
        RAISE EXCEPTION 'v4.2.87: falta el módulo 23 (diagnostic_units); aplicar antes el modelo base';
    END IF;
    IF to_regclass('clinical.service_requests') IS NULL OR to_regclass('directory.tenants') IS NULL THEN
        RAISE EXCEPTION 'v4.2.87: faltan clinical.service_requests / directory.tenants; aplicar antes el modelo base';
    END IF;
    IF to_regprocedure('integrity.forbid_mutation()') IS NULL THEN
        RAISE EXCEPTION 'v4.2.87: falta integrity.forbid_mutation(); aplicar antes _integrity/00_integrity_functions.sql';
    END IF;
END $$;

-- ------------------------------------------------------------------ A. columnas
ALTER TABLE "diagnostic_units"."diagnostic_study_offerings"
    ADD COLUMN IF NOT EXISTS "specimen_description" text,
    ADD COLUMN IF NOT EXISTS "service_category_id" uuid,
    ADD COLUMN IF NOT EXISTS "available" boolean NOT NULL DEFAULT true;

-- --------------------------------------------------------------------- B. tablas
CREATE TABLE IF NOT EXISTS "diagnostic_units"."diagnostic_service_categories" (
    "id" uuid NOT NULL,
    "diagnostic_unit_id" uuid NOT NULL,
    "name" varchar(60) NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_diagnostic_service_categories" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "diagnostics"."service_request_performer_events" (
    "id" uuid NOT NULL,
    "service_request_id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "reason_text" text,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid NOT NULL,
    CONSTRAINT "pk_service_request_performer_events" PRIMARY KEY ("id")
);

-- ------------------------------------------------------------------- C. índices
CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_service_category_id" ON "diagnostic_units"."diagnostic_study_offerings" ("service_category_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_diagnostic_service_categories_unit_name" ON "diagnostic_units"."diagnostic_service_categories" ("diagnostic_unit_id", lower(name));
CREATE INDEX IF NOT EXISTS "ix_diagnostic_service_categories_created_by_user_id" ON "diagnostic_units"."diagnostic_service_categories" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_diagnostic_service_categories_updated_by_user_id" ON "diagnostic_units"."diagnostic_service_categories" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_performer_events_service_request_id" ON "diagnostics"."service_request_performer_events" ("service_request_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_performer_events_event_type_concept_id" ON "diagnostics"."service_request_performer_events" ("event_type_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_performer_events_recorded_by_user_id" ON "diagnostics"."service_request_performer_events" ("recorded_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_performer_events_tenant_request" ON "diagnostics"."service_request_performer_events" ("custodian_tenant_id", "service_request_id", "recorded_at" DESC);

-- ---------------------------------------------------------------------- D. FK
-- Mismos nombres y destinos que el DDL generado (SQL/23_diagnostic_units, SQL/20_diagnostics).
DO $$
DECLARE
    f record;
BEGIN
    FOR f IN
        SELECT * FROM (VALUES
            ('diagnostic_units', 'diagnostic_study_offerings',        'service_category_id',   'diagnostic_units', 'diagnostic_service_categories'),
            ('diagnostic_units', 'diagnostic_service_categories',     'diagnostic_unit_id',    'diagnostic_units', 'diagnostic_units'),
            ('diagnostic_units', 'diagnostic_service_categories',     'created_by_user_id',    'iam',              'users'),
            ('diagnostic_units', 'diagnostic_service_categories',     'updated_by_user_id',    'iam',              'users'),
            ('diagnostics',      'service_request_performer_events',  'service_request_id',    'clinical',         'service_requests'),
            ('diagnostics',      'service_request_performer_events',  'custodian_tenant_id',   'directory',        'tenants'),
            ('diagnostics',      'service_request_performer_events',  'event_type_concept_id', 'terminology',      'catalog_concepts'),
            ('diagnostics',      'service_request_performer_events',  'recorded_by_user_id',   'iam',              'users')
        ) AS t(src_schema, tab, col, dst_schema, dst_tab)
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint c
              JOIN pg_class r ON r.oid = c.conrelid
              JOIN pg_namespace n ON n.oid = r.relnamespace
             WHERE c.conname = format('fk_%s_%s', f.tab, f.col)
               AND n.nspname = f.src_schema AND r.relname = f.tab
        ) THEN
            EXECUTE format(
                'ALTER TABLE %I.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I ("id")',
                f.src_schema, f.tab, format('fk_%s_%s', f.tab, f.col), f.col, f.dst_schema, f.dst_tab);
        END IF;
    END LOOP;
END $$;

-- ------------------------------------------------------------------- E. RLS
-- Aislamiento por custodio en ESTA transacción (la tabla no queda abierta ni un instante).
-- Misma política que v4.2.26: el ejecutor es el custodio de sus filas; el solicitante de la
-- orden no las ve (el filtro de reserva del paciente corre bajo el contexto de sistema).
ALTER TABLE "diagnostics"."service_request_performer_events" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "diagnostics"."service_request_performer_events" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS custodian_tenant_isolation ON diagnostics.service_request_performer_events;
CREATE POLICY custodian_tenant_isolation ON diagnostics.service_request_performer_events
    USING (
        custodian_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
        OR current_setting('app.system_context', true) = 'true'
    )
    WITH CHECK (
        custodian_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
        OR current_setting('app.system_context', true) = 'true'
    );

-- --------------------------------------------- F. coherencia: sólo el ejecutor escribe
-- custodian_tenant_id del evento DEBE ser el ejecutor de la orden (performer_tenant_id). Sin esto,
-- un tenant podría anotar un desenlace sobre la orden de otro y bloquearle la reserva al paciente.
-- SECURITY DEFINER para leer la orden aunque el RLS del que escribe no la deje ver; search_path fijo.
-- Antes de consultar con derechos de definidor se compara contra la sesión, y todos los rechazos
-- usan el MISMO mensaje: la función no sirve para averiguar de quién es una orden ajena.
CREATE OR REPLACE FUNCTION "integrity"."service_request_performer_event_tenant"()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public AS $$
DECLARE
    ejecutor uuid;
    sesion uuid := NULLIF(current_setting('app.current_tenant_id', true), '')::uuid;
BEGIN
    IF current_setting('app.system_context', true) IS DISTINCT FROM 'true'
       AND NEW.custodian_tenant_id IS DISTINCT FROM sesion THEN
        RAISE EXCEPTION 'service_request_performer_events: el custodio no es el ejecutor de la orden'
            USING ERRCODE = 'check_violation';
    END IF;
    SELECT sr.performer_tenant_id INTO ejecutor
      FROM clinical.service_requests sr WHERE sr.id = NEW.service_request_id;
    IF ejecutor IS NULL OR ejecutor IS DISTINCT FROM NEW.custodian_tenant_id THEN
        RAISE EXCEPTION 'service_request_performer_events: el custodio no es el ejecutor de la orden'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION "integrity"."service_request_performer_event_tenant"() FROM PUBLIC;

DROP TRIGGER IF EXISTS trg_service_request_performer_event_tenant ON "diagnostics"."service_request_performer_events";
CREATE TRIGGER trg_service_request_performer_event_tenant
    BEFORE INSERT ON "diagnostics"."service_request_performer_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."service_request_performer_event_tenant"();

-- ------------------------------------------------------------- G. append-only
-- Un desenlace ya anotado no se edita ni se borra: se corrige agregando otro evento.
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "diagnostics"."service_request_performer_events";
CREATE TRIGGER trg_forbid_mutation
    BEFORE UPDATE OR DELETE ON "diagnostics"."service_request_performer_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        REVOKE UPDATE, DELETE, TRUNCATE ON "diagnostics"."service_request_performer_events" FROM mantra_app;
    END IF;
END $$;

-- ------------------------------------------------------------ H. verificación
DO $$
DECLARE
    faltan text := '';
    c text;
BEGIN
    FOREACH c IN ARRAY ARRAY['specimen_description', 'service_category_id', 'available'] LOOP
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                       WHERE table_schema = 'diagnostic_units'
                         AND table_name = 'diagnostic_study_offerings' AND column_name = c) THEN
            faltan := faltan || ' columna:' || c;
        END IF;
    END LOOP;
    IF to_regclass('diagnostic_units.diagnostic_service_categories') IS NULL THEN
        faltan := faltan || ' tabla:diagnostic_service_categories';
    END IF;
    IF to_regclass('diagnostics.service_request_performer_events') IS NULL THEN
        faltan := faltan || ' tabla:service_request_performer_events';
    END IF;
    FOREACH c IN ARRAY ARRAY['ux_diagnostic_service_categories_unit_name',
                             'ix_diagnostic_study_offerings_service_category_id',
                             'ix_service_request_performer_events_tenant_request'] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = c) THEN
            faltan := faltan || ' indice:' || c;
        END IF;
    END LOOP;
    FOREACH c IN ARRAY ARRAY['fk_diagnostic_study_offerings_service_category_id',
                             'fk_diagnostic_service_categories_diagnostic_unit_id',
                             'fk_service_request_performer_events_service_request_id',
                             'fk_service_request_performer_events_custodian_tenant_id'] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c) THEN
            faltan := faltan || ' fk:' || c;
        END IF;
    END LOOP;
    IF NOT EXISTS (SELECT 1 FROM pg_class r JOIN pg_namespace n ON n.oid = r.relnamespace
                   WHERE n.nspname = 'diagnostics' AND r.relname = 'service_request_performer_events'
                     AND r.relrowsecurity AND r.relforcerowsecurity) THEN
        faltan := faltan || ' rls:service_request_performer_events(enable+force)';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'diagnostics'
                   AND tablename = 'service_request_performer_events'
                   AND policyname = 'custodian_tenant_isolation') THEN
        faltan := faltan || ' politica:custodian_tenant_isolation';
    END IF;
    FOREACH c IN ARRAY ARRAY['trg_service_request_performer_event_tenant', 'trg_forbid_mutation'] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_trigger tg JOIN pg_class r ON r.oid = tg.tgrelid
                       JOIN pg_namespace n ON n.oid = r.relnamespace
                       WHERE NOT tg.tgisinternal AND tg.tgname = c AND n.nspname = 'diagnostics'
                         AND r.relname = 'service_request_performer_events') THEN
            faltan := faltan || ' trigger:' || c;
        END IF;
    END LOOP;
    IF faltan <> '' THEN
        RAISE EXCEPTION 'v4.2.87 incompleto:%', faltan;
    END IF;
    RAISE NOTICE 'v4.2.87 aplicado: categorías, disponibilidad y muestra en texto de las ofertas, y desenlaces del ejecutor de la orden.';
END $$;

COMMIT;
