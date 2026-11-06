-- ============================================================================
-- SALUD · patch v4.2.89 (informe diagnóstico redactado: borrador → publicado) sobre BD viva
-- Fecha: 2026-11-05
-- Idempotente (CREATE ... IF NOT EXISTS / FK bajo guarda / DROP POLICY|TRIGGER IF EXISTS).
-- UNA sola transacción, SIN backfill.
--
-- QUÉ ENTRA.
--   diagnostics.report_drafts          borrador del informe de UNA orden (un estudio) en el tenant que
--                                      la informa: laboratorio/imagen ejecutor o el médico que la emitió.
--                                      Documento estructurado (body_json), firmante, visibilidad al
--                                      publicar. Al publicarse queda congelado: la versión inmutable
--                                      del informe la escribe la API en diagnostic_report_versions.
--   diagnostics.report_draft_files     archivos del borrador: documento fuente (PDF/Word), audio
--                                      original (respaldo, nunca visible al paciente) y anexos.
--   diagnostics.report_issuer_settings firma, sello y responsable de la organización que emite
--                                      informes («firma del laboratorio» en el PDF oficial).
--
-- POR QUÉ SIN BACKFILL. Son tablas nuevas; nada existente cambia de significado.
--
-- RLS: aislamiento por custodio (ENABLE+FORCE) en las tres, igual que v4.2.26.
-- Inmutabilidad: un borrador PUBLISHED y sus archivos no se editan ni se borran (disparador).
-- ============================================================================

BEGIN;

-- --------------------------------------------------------------- 0. prerrequisitos
DO $$
BEGIN
    IF to_regclass('diagnostics.diagnostic_report_versions') IS NULL
       OR to_regclass('clinical.service_requests') IS NULL
       OR to_regclass('clinical.diagnostic_reports') IS NULL
       OR to_regclass('common.files') IS NULL
       OR to_regclass('profiles.health_practitioner_profiles') IS NULL THEN
        RAISE EXCEPTION 'v4.2.89: faltan tablas base (diagnostics, clinical, common, profiles); aplicar antes el modelo base';
    END IF;
END $$;

-- --------------------------------------------------------------------- A. tablas
CREATE TABLE IF NOT EXISTS "diagnostics"."report_drafts" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "service_request_id" uuid NOT NULL,
    "diagnostic_report_id" uuid,
    "body_json" jsonb NOT NULL,
    "conclusion_text" text,
    "signer_profile_id" uuid,
    "patient_visibility_code" varchar(8) NOT NULL,
    "status_code" varchar(10) NOT NULL,
    "published_version_id" uuid,
    "published_at" timestamptz,
    "published_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_drafts" PRIMARY KEY ("id"),
    CONSTRAINT "ck_report_drafts_visibility" CHECK ("patient_visibility_code" IN ('VISIBLE', 'HELD')),
    CONSTRAINT "ck_report_drafts_status" CHECK ("status_code" IN ('DRAFT', 'PUBLISHED')),
    CONSTRAINT "ck_report_drafts_published" CHECK (
        "status_code" = 'DRAFT'
        OR ("published_version_id" IS NOT NULL AND "published_at" IS NOT NULL AND "signer_profile_id" IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS "diagnostics"."report_draft_files" (
    "id" uuid NOT NULL,
    "report_draft_id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "role_code" varchar(10) NOT NULL,
    "ordinal" integer NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_report_draft_files" PRIMARY KEY ("id"),
    CONSTRAINT "ck_report_draft_files_role" CHECK ("role_code" IN ('DOCUMENT', 'AUDIO', 'ANNEX'))
);

CREATE TABLE IF NOT EXISTS "diagnostics"."report_issuer_settings" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "signature_file_id" uuid,
    "seal_file_id" uuid,
    "responsible_name" varchar(120),
    "responsible_title" varchar(120),
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_report_issuer_settings" PRIMARY KEY ("id")
);

-- ------------------------------------------------------------------- B. índices
CREATE UNIQUE INDEX IF NOT EXISTS "ux_report_drafts_tenant_request" ON "diagnostics"."report_drafts" ("custodian_tenant_id", "service_request_id");
CREATE INDEX IF NOT EXISTS "ix_report_drafts_service_request_id" ON "diagnostics"."report_drafts" ("service_request_id");
CREATE INDEX IF NOT EXISTS "ix_report_drafts_diagnostic_report_id" ON "diagnostics"."report_drafts" ("diagnostic_report_id");
CREATE INDEX IF NOT EXISTS "ix_report_drafts_signer_profile_id" ON "diagnostics"."report_drafts" ("signer_profile_id");
CREATE INDEX IF NOT EXISTS "ix_report_drafts_published_version_id" ON "diagnostics"."report_drafts" ("published_version_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_report_draft_files_draft_file" ON "diagnostics"."report_draft_files" ("report_draft_id", "file_id");
CREATE INDEX IF NOT EXISTS "ix_report_draft_files_file_id" ON "diagnostics"."report_draft_files" ("file_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_report_issuer_settings_tenant" ON "diagnostics"."report_issuer_settings" ("custodian_tenant_id");

-- ---------------------------------------------------------------------- C. FK
DO $$
DECLARE
    f record;
BEGIN
    FOR f IN
        SELECT * FROM (VALUES
            ('report_drafts',          'custodian_tenant_id',   'directory',   'tenants',                    'id'),
            ('report_drafts',          'service_request_id',    'clinical',    'service_requests',           'id'),
            ('report_drafts',          'diagnostic_report_id',  'clinical',    'diagnostic_reports',         'id'),
            ('report_drafts',          'signer_profile_id',     'profiles',    'health_practitioner_profiles', 'profile_id'),
            ('report_drafts',          'published_version_id',  'diagnostics', 'diagnostic_report_versions', 'id'),
            ('report_drafts',          'published_by_user_id',  'iam',         'users',                      'id'),
            ('report_drafts',          'created_by_user_id',    'iam',         'users',                      'id'),
            ('report_drafts',          'updated_by_user_id',    'iam',         'users',                      'id'),
            ('report_draft_files',     'report_draft_id',       'diagnostics', 'report_drafts',              'id'),
            ('report_draft_files',     'custodian_tenant_id',   'directory',   'tenants',                    'id'),
            ('report_draft_files',     'file_id',               'common',      'files',                      'id'),
            ('report_draft_files',     'created_by_user_id',    'iam',         'users',                      'id'),
            ('report_issuer_settings', 'custodian_tenant_id',   'directory',   'tenants',                    'id'),
            ('report_issuer_settings', 'signature_file_id',     'common',      'files',                      'id'),
            ('report_issuer_settings', 'seal_file_id',          'common',      'files',                      'id'),
            ('report_issuer_settings', 'created_by_user_id',    'iam',         'users',                      'id'),
            ('report_issuer_settings', 'updated_by_user_id',    'iam',         'users',                      'id')
        ) AS t(tab, col, dst_schema, dst_tab, dst_col)
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint c
              JOIN pg_class r ON r.oid = c.conrelid
              JOIN pg_namespace n ON n.oid = r.relnamespace
             WHERE c.conname = format('fk_%s_%s', f.tab, f.col)
               AND n.nspname = 'diagnostics' AND r.relname = f.tab
        ) THEN
            EXECUTE format(
                'ALTER TABLE diagnostics.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I (%I)',
                f.tab, format('fk_%s_%s', f.tab, f.col), f.col, f.dst_schema, f.dst_tab, f.dst_col);
        END IF;
    END LOOP;
END $$;

-- ------------------------------------------------------------------- D. RLS
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['report_drafts', 'report_draft_files', 'report_issuer_settings'] LOOP
        EXECUTE format('ALTER TABLE diagnostics.%I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE diagnostics.%I FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('DROP POLICY IF EXISTS custodian_tenant_isolation ON diagnostics.%I', t);
        EXECUTE format($p$CREATE POLICY custodian_tenant_isolation ON diagnostics.%I
            USING (
                custodian_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
                OR current_setting('app.system_context', true) = 'true'
            )
            WITH CHECK (
                custodian_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
                OR current_setting('app.system_context', true) = 'true'
            )$p$, t);
    END LOOP;
END $$;

-- --------------------------------------------------- E. publicado = inmutable
-- Un borrador publicado ya es el informe del paciente: no se edita ni se borra, y sus archivos tampoco
-- (ni se agregan, ni se mueven a otro borrador). SECURITY DEFINER para que el estado del borrador padre
-- se lea aunque el RLS del que escribe no lo deje ver; search_path fijo.
CREATE OR REPLACE FUNCTION "integrity"."report_draft_published_is_final"()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public AS $$
BEGIN
    IF TG_TABLE_NAME = 'report_drafts' THEN
        -- UPDATE/DELETE de un publicado; un INSERT ya publicado lo cubre ck_report_drafts_published.
        IF TG_OP <> 'INSERT' AND OLD.status_code = 'PUBLISHED' THEN
            RAISE EXCEPTION 'report_drafts: el informe ya fue publicado y no se puede modificar'
                USING ERRCODE = 'check_violation';
        END IF;
    ELSE
        IF EXISTS (
            SELECT 1 FROM diagnostics.report_drafts d
             WHERE d.status_code = 'PUBLISHED'
               AND d.id IN (
                   CASE WHEN TG_OP <> 'INSERT' THEN OLD.report_draft_id END,
                   CASE WHEN TG_OP <> 'DELETE' THEN NEW.report_draft_id END)
        ) THEN
            RAISE EXCEPTION 'report_draft_files: el informe ya fue publicado y no se puede modificar'
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION "integrity"."report_draft_published_is_final"() FROM PUBLIC;

DROP TRIGGER IF EXISTS trg_report_draft_published_is_final ON "diagnostics"."report_drafts";
CREATE TRIGGER trg_report_draft_published_is_final
    BEFORE UPDATE OR DELETE ON "diagnostics"."report_drafts"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."report_draft_published_is_final"();

DROP TRIGGER IF EXISTS trg_report_draft_published_is_final ON "diagnostics"."report_draft_files";
CREATE TRIGGER trg_report_draft_published_is_final
    BEFORE INSERT OR UPDATE OR DELETE ON "diagnostics"."report_draft_files"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."report_draft_published_is_final"();

-- ------------------------------------------- E2. archivo y borrador del mismo custodio
-- FK compuesta: un archivo de borrador no puede declarar un custodio distinto al de su borrador.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_report_drafts_id_tenant" ON "diagnostics"."report_drafts" ("id", "custodian_tenant_id");
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_report_draft_files_draft_tenant') THEN
        ALTER TABLE diagnostics.report_draft_files
            ADD CONSTRAINT fk_report_draft_files_draft_tenant
            FOREIGN KEY (report_draft_id, custodian_tenant_id)
            REFERENCES diagnostics.report_drafts (id, custodian_tenant_id);
    END IF;
END $$;

-- ------------------------------------------------------------ F. verificación
DO $$
DECLARE
    faltan text := '';
    c text;
BEGIN
    FOREACH c IN ARRAY ARRAY['report_drafts', 'report_draft_files', 'report_issuer_settings'] LOOP
        IF to_regclass('diagnostics.' || c) IS NULL THEN
            faltan := faltan || ' tabla:' || c;
        ELSIF NOT EXISTS (SELECT 1 FROM pg_class r JOIN pg_namespace n ON n.oid = r.relnamespace
                          WHERE n.nspname = 'diagnostics' AND r.relname = c
                            AND r.relrowsecurity AND r.relforcerowsecurity) THEN
            faltan := faltan || ' rls:' || c;
        END IF;
    END LOOP;
    FOREACH c IN ARRAY ARRAY['ux_report_drafts_tenant_request', 'ux_report_draft_files_draft_file',
                             'ux_report_issuer_settings_tenant'] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = c) THEN
            faltan := faltan || ' indice:' || c;
        END IF;
    END LOOP;
    FOREACH c IN ARRAY ARRAY['fk_report_drafts_signer_profile_id', 'fk_report_draft_files_draft_tenant'] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c) THEN
            faltan := faltan || ' fk:' || c;
        END IF;
    END LOOP;
    IF faltan <> '' THEN
        RAISE EXCEPTION 'v4.2.89 incompleto:%', faltan;
    END IF;
    RAISE NOTICE 'v4.2.89 aplicado: borradores de informe, sus archivos y la firma/sello del emisor.';
END $$;

COMMIT;
