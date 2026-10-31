-- ============================================================================
-- SALUD · patch v4.2.80 (clinical · detalle de la orden de estudios) sobre BD viva
-- Fecha: 2026-11-01
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE ... IF NOT EXISTS / FK y CHECK
-- bajo guarda / DROP POLICY IF EXISTS). UNA sola pasada. SIN backfill.
--
-- Contexto: el médico pide hoy UN estudio por orden y nada más: ni qué muestra se
-- analiza, ni qué componentes de un panel (hemoglobina dentro del hemograma), ni la
-- modalidad, la parte del cuerpo, la lateralidad o el contraste de una imagen. El
-- laboratorio o el centro de imagen que recibe la orden no ve esa granularidad.
-- Plan: docs/trabajo/2026-10-31-solicitud-estudios-catalogo-completo/ (front).
--
-- QUÉ ENTRA.
--   clinical.service_requests  +6 columnas nullable:
--     requisition_id            agrupa los renglones pedidos juntos (sin FK: identificador de grupo)
--     specimen_type_concept_id  laboratorio · tipo de muestra (HL7 v2-0487)
--     modality_concept_id       imagen · modalidad (DICOM CID 29)
--     body_site_concept_id      imagen · parte del cuerpo (concepto del catálogo de regiones)
--     laterality_concept_id     imagen · izquierda / derecha / bilateral
--     contrast_concept_id       imagen · sin / con / sin y con contraste
--   clinical.service_request_components  tabla nueva: los componentes marcados de un panel.
--   3 CHECK que el modelo puede decir sin leer conceptos (el cruce con la categoría de la
--   orden lo valida la API: muestra sólo en laboratorio, imagen sólo en imagenología).
--   Índices de bandeja del ejecutor y de agrupación por solicitud.
--   Política RLS: el ejecutor de la orden lee sus componentes (espejo de v4.2.36).
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Una orden anterior no declaró muestra ni región y
-- reconstruirlas sería fabricar un dato clínico. La API las expone como "estudio completo,
-- sin detalle". Las órdenes nuevas sí escriben su detalle.
--
-- DESPUÉS de aplicar este parche, re-ejecutar 2026-09-26_v4226_custodian_tenant_rls.sql
-- (descubre dinámicamente las tablas con custodian_tenant_id y cubre la nueva).
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de clinical.service_requests              +6
--   tablas                                             +1 (clinical.service_request_components)
--   FKs                                                +8 (5 en service_requests, 3 en la tabla nueva) +1 intra
--   índices                                            +12
--   CHECK                                              +3
--   políticas RLS                                      +1 (service_request_components_performer_read, si el RLS está habilitado en la tabla)
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "requisition_id" uuid,
    ADD COLUMN IF NOT EXISTS "specimen_type_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "modality_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "body_site_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "laterality_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "contrast_concept_id" uuid;

-- ------------------------------------------------------- B. tabla de componentes
CREATE TABLE IF NOT EXISTS "clinical"."service_request_components" (
    "id" uuid NOT NULL,
    "service_request_id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "component_concept_id" uuid NOT NULL,
    "ordinal" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_service_request_components" PRIMARY KEY ("id")
);

-- ------------------------------------------------------------------ C. índices
CREATE INDEX IF NOT EXISTS "ix_service_requests_specimen_type_concept_id" ON "clinical"."service_requests" ("specimen_type_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_requests_modality_concept_id" ON "clinical"."service_requests" ("modality_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_requests_body_site_concept_id" ON "clinical"."service_requests" ("body_site_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_requests_laterality_concept_id" ON "clinical"."service_requests" ("laterality_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_requests_contrast_concept_id" ON "clinical"."service_requests" ("contrast_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_requests_requisition_id" ON "clinical"."service_requests" ("custodian_tenant_id", "requisition_id");
CREATE INDEX IF NOT EXISTS "ix_service_requests_performer_inbox" ON "clinical"."service_requests" ("performer_tenant_id", "status_concept_id", "created_at", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_service_request_components_request_component" ON "clinical"."service_request_components" ("service_request_id", "component_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_components_service_request_id" ON "clinical"."service_request_components" ("service_request_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_components_custodian_tenant_id" ON "clinical"."service_request_components" ("custodian_tenant_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_components_component_concept_id" ON "clinical"."service_request_components" ("component_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_request_components_created_by_user_id" ON "clinical"."service_request_components" ("created_by_user_id");

-- ---------------------------------------------------------------------- D. FK
DO $$
DECLARE
    f record;
BEGIN
    FOR f IN
        SELECT * FROM (VALUES
            ('service_requests',           'specimen_type_concept_id', 'terminology', 'catalog_concepts'),
            ('service_requests',           'modality_concept_id',      'terminology', 'catalog_concepts'),
            ('service_requests',           'body_site_concept_id',     'terminology', 'catalog_concepts'),
            ('service_requests',           'laterality_concept_id',    'terminology', 'catalog_concepts'),
            ('service_requests',           'contrast_concept_id',      'terminology', 'catalog_concepts'),
            ('service_request_components', 'service_request_id',       'clinical',    'service_requests'),
            ('service_request_components', 'custodian_tenant_id',      'directory',   'tenants'),
            ('service_request_components', 'component_concept_id',     'terminology', 'catalog_concepts'),
            ('service_request_components', 'created_by_user_id',       'iam',         'users')
        ) AS t(tab, col, dst_schema, dst_tab)
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = format('fk_%s_%s', f.tab, f.col)
        ) THEN
            EXECUTE format(
                'ALTER TABLE "clinical".%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I ("id")',
                f.tab, format('fk_%s_%s', f.tab, f.col), f.col, f.dst_schema, f.dst_tab);
        END IF;
    END LOOP;
END $$;

-- ------------------------------------------------------------------- E. CHECK
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_specimen_xor_imaging";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_specimen_xor_imaging"
    CHECK (("specimen_type_concept_id" IS NULL OR ("modality_concept_id" IS NULL AND "body_site_concept_id" IS NULL AND "laterality_concept_id" IS NULL AND "contrast_concept_id" IS NULL)));
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_laterality_requires_site";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_laterality_requires_site"
    CHECK (("laterality_concept_id" IS NULL OR "body_site_concept_id" IS NOT NULL));
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_contrast_requires_modality";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_contrast_requires_modality"
    CHECK (("contrast_concept_id" IS NULL OR "modality_concept_id" IS NOT NULL));

-- ------------------------------------------------------------------- F. RLS
-- El ejecutor de la orden lee los componentes de las órdenes que puede leer
-- (espejo de service_requests_performer_read, v4.2.36). Sólo SELECT. La política de
-- aislamiento por custodio la crea v4.2.26 al re-ejecutarse; esta sólo agrega la lectura.
-- Si la tabla todavía no tiene RLS habilitado la política queda definida y se aplica
-- cuando v4.2.26 lo habilite.
DROP POLICY IF EXISTS service_request_components_performer_read ON clinical.service_request_components;
CREATE POLICY service_request_components_performer_read ON clinical.service_request_components
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM clinical.service_requests sr
            WHERE sr.id = service_request_components.service_request_id
              AND sr.performer_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
        )
        OR current_setting('app.system_context', true) = 'true'
    );

-- ------------------------------------------------------------ G. verificación
DO $$
DECLARE
    faltan text := '';
    c text;
BEGIN
    FOREACH c IN ARRAY ARRAY['requisition_id','specimen_type_concept_id','modality_concept_id',
                             'body_site_concept_id','laterality_concept_id','contrast_concept_id']
    LOOP
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                       WHERE table_schema = 'clinical' AND table_name = 'service_requests' AND column_name = c) THEN
            faltan := faltan || ' columna:' || c;
        END IF;
    END LOOP;
    IF to_regclass('clinical.service_request_components') IS NULL THEN
        faltan := faltan || ' tabla:service_request_components';
    END IF;
    FOREACH c IN ARRAY ARRAY['ck_service_requests_specimen_xor_imaging',
                             'ck_service_requests_laterality_requires_site',
                             'ck_service_requests_contrast_requires_modality']
    LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c) THEN
            faltan := faltan || ' check:' || c;
        END IF;
    END LOOP;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'clinical'
                   AND tablename = 'service_request_components'
                   AND policyname = 'service_request_components_performer_read') THEN
        faltan := faltan || ' politica:service_request_components_performer_read';
    END IF;
    IF faltan <> '' THEN
        RAISE EXCEPTION 'v4.2.80 incompleto:%', faltan;
    END IF;
    RAISE NOTICE 'v4.2.80 aplicado: clinical.service_requests con detalle de la orden y service_request_components.';
END $$;

COMMIT;
