-- ============================================================================
-- SALUD · patch «Admisión crea el vínculo» (b) — revisión de seguridad
-- sobre BD viva · Fecha: 2026-10-31 · Va DESPUÉS de 2026-10-31_admision_crea_el_vinculo.sql.
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con `duplicate_object`
-- / DROP COLUMN IF EXISTS). Se puede aplicar N veces.
--
-- QUÉ CIERRA.
--   1. referral_id: la FK simple admitía la derivación de OTRO paciente o de OTRO tenant.
--      FK compuesta (referral_id, patient_profile_id, tenant_id) → clinical_ext.referrals
--      (id, patient_profile_id, target_tenant_id): la derivación tiene que ser del mismo
--      paciente y estar dirigida a este tenant (target_tenant_id). MATCH SIMPLE: sin
--      referral_id no se exige nada. Destino: UNIQUE ux_referrals_id_patient_target (trivial:
--      id ya es PK). Si no se cumple, 23503 (la API lo traduce a 404 sin detalle).
--   2. identity_document_reference guardaba el número del documento en claro en una tabla
--      de sólo inserción. Se reemplaza por identity_document_type, identity_document_last4 e
--      identity_document_hmac (HMAC-SHA256 hex del número normalizado, calculado por la API
--      con ADMISSION_ID_HMAC_KEY, clave que NO vive en la base). Se elimina la columna vieja.
--
-- FILAS EXISTENTES. El HMAC sólo lo puede calcular quien tiene la clave (la API), no este
-- patch. Si hubiera filas con el número en claro, el patch aborta sin tocar nada y pide
-- migrarlas con la API (que deshabilita la guarda append-only sólo para esa migración).
-- En el primer despliegue la tabla está vacía (nació en el patch anterior).
-- ============================================================================

BEGIN;

DO $$
DECLARE
    n bigint;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'clinical' AND table_name = 'patient_admission_footprints'
                  AND column_name = 'identity_document_reference') THEN
        EXECUTE 'SELECT count(*) FROM "clinical"."patient_admission_footprints"' INTO n;
        IF n > 0 THEN
            RAISE EXCEPTION 'admision_crea_el_vinculo_b: % fila(s) con el número de documento en claro; migrarlas con la API (HMAC con ADMISSION_ID_HMAC_KEY) antes de aplicar este patch', n
                USING ERRCODE = 'object_not_in_prerequisite_state';
        END IF;
    END IF;
END $$;

-- ------------------------------------------------------------- 2. documento sin el número en claro
ALTER TABLE "clinical"."patient_admission_footprints"
    ADD COLUMN IF NOT EXISTS "identity_document_type" varchar(32),
    ADD COLUMN IF NOT EXISTS "identity_document_last4" varchar(4),
    ADD COLUMN IF NOT EXISTS "identity_document_hmac" varchar(64);
ALTER TABLE "clinical"."patient_admission_footprints"
    ALTER COLUMN "identity_document_type" SET NOT NULL,
    ALTER COLUMN "identity_document_last4" SET NOT NULL,
    ALTER COLUMN "identity_document_hmac" SET NOT NULL;
ALTER TABLE "clinical"."patient_admission_footprints"
    DROP COLUMN IF EXISTS "identity_document_reference";

-- ------------------------------------------------------------- 1. derivación del mismo paciente y para este tenant
CREATE UNIQUE INDEX IF NOT EXISTS "ux_referrals_id_patient_target"
    ON "clinical_ext"."referrals" ("id", "patient_profile_id", "target_tenant_id");

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_referral_patient_tenant"
        FOREIGN KEY ("referral_id", "patient_profile_id", "tenant_id")
        REFERENCES "clinical_ext"."referrals" ("id", "patient_profile_id", "target_tenant_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- verificación
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'clinical' AND table_name = 'patient_admission_footprints'
                  AND column_name = 'identity_document_reference')
       OR NOT EXISTS (SELECT 1 FROM pg_constraint
                       WHERE conname = 'fk_patient_admission_footprints_referral_patient_tenant')
       OR (SELECT count(*) FROM information_schema.columns
            WHERE table_schema = 'clinical' AND table_name = 'patient_admission_footprints'
              AND column_name IN ('identity_document_type', 'identity_document_last4', 'identity_document_hmac')
              AND is_nullable = 'NO') <> 3 THEN
        RAISE EXCEPTION 'admision_crea_el_vinculo_b: verificación fallida';
    END IF;
END $$;

COMMIT;
