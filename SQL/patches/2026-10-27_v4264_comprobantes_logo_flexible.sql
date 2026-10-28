-- ============================================================================
-- SALUD · patch v4.2.64 (comprobantes de pago, logo de la sede y horario
-- flexible por franja) sobre BD viva
-- Fecha: 2026-10-27
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / constraints
-- bajo IF NOT EXISTS o `duplicate_object`). Se puede aplicar N veces.
--
-- Contexto: gen_ddl.py ya emite todo esto en SQL/14_practice/ y
-- SQL/41_scheduling/ desde que los .puml lo declaran, así que en un rebuild desde
-- cero este patch NO hace falta. Existe únicamente para una base ya aplicada y
-- poblada. gen_apply.py no escanea SQL/patches/, así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. Tres cambios de modelo de las correcciones del rol médico:
--
--   A. practice.practice_sites.logo_file_id — el logo del consultorio que sale
--      en el membrete de sus PDF. Mismo camino que `bank_qr_file_id` (v4.2.15):
--      el binario vive en `common.files` y acá queda solo su id. Nullable, sin
--      backfill: ninguna sede tiene logo todavía.
--   B. scheduling.schedule_rules.flexible_hours — horario flexible POR FRANJA.
--      NOT NULL DEFAULT false, como `telemedicine_enabled` (v4.2.61): toda franja
--      existente sigue de turnos fijos. `true` en la plantilla sigue implicando
--      `true` en todas sus franjas. `ADD COLUMN … DEFAULT <constante>` no
--      reescribe la tabla en PG 11+.
--      SOLO para bases de la rama `dev`: `test` no tiene el horario flexible
--      (P36). En `test` se omite la sección B.
--   C. scheduling.appointment_payment_receipts — el comprobante que sube el
--      paciente y revisa el médico de la agenda. DDL idéntico al que generó
--      gen_ddl.py, con sus índices y FKs.
--
-- Canónico: `Mantra Core Health Context/modules/diagram_14_practice.puml` y
--           `Mantra Core Health Context/modules/diagram_41_scheduling.puml`
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de practice.practice_sites   +1  (logo_file_id)
--   columnas de scheduling.schedule_rules +1  (flexible_hours)
--   tablas                                +1  (scheduling.appointment_payment_receipts)
--   FKs                                   +9  (1 de la sede, 8 del comprobante)
--   índices                              +11  (1 de la sede, PK + 9 del comprobante)
--   políticas RLS                         +1  (tenant_isolation del comprobante)
--
-- Reversible:
--   DROP TABLE IF EXISTS "scheduling"."appointment_payment_receipts";
--   ALTER TABLE "scheduling"."schedule_rules" DROP COLUMN IF EXISTS "flexible_hours";
--   ALTER TABLE "practice"."practice_sites" DROP COLUMN IF EXISTS "logo_file_id";
-- ============================================================================

BEGIN;

-- ------------------------------------------------ A. logo de la sede (M-01)
ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "logo_file_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_practice_sites_logo_file_id"
    ON "practice"."practice_sites" ("logo_file_id");

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_practice_sites_logo_file_id'
    ) THEN
        ALTER TABLE "practice"."practice_sites"
            ADD CONSTRAINT "fk_practice_sites_logo_file_id"
            FOREIGN KEY ("logo_file_id")
            REFERENCES "common"."files" ("id");
    END IF;
END $$;

-- ------------------------------- B. horario flexible por franja (M-02, dev)
ALTER TABLE "scheduling"."schedule_rules"
    ADD COLUMN IF NOT EXISTS "flexible_hours" boolean NOT NULL DEFAULT false;

-- ------------------------------------------ C. comprobantes de pago (M-03)
CREATE TABLE IF NOT EXISTS "scheduling"."appointment_payment_receipts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "appointment_booking_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "amount" numeric(12,2),
    "paid_at" timestamptz,
    "note" varchar(500),
    "uploaded_by_user_id" uuid NOT NULL,
    "uploaded_at" timestamptz NOT NULL,
    "review_status_concept_id" uuid NOT NULL,
    "reviewed_by_user_id" uuid,
    "reviewed_at" timestamptz,
    "rejection_reason" varchar(500),
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_appointment_payment_receipts" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_tenant_id" ON "scheduling"."appointment_payment_receipts" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_appointment_booking_id" ON "scheduling"."appointment_payment_receipts" ("appointment_booking_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_file_id" ON "scheduling"."appointment_payment_receipts" ("file_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_uploaded_by_user_id" ON "scheduling"."appointment_payment_receipts" ("uploaded_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_review_status_concept_id" ON "scheduling"."appointment_payment_receipts" ("review_status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_reviewed_by_user_id" ON "scheduling"."appointment_payment_receipts" ("reviewed_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_created_by_user_id" ON "scheduling"."appointment_payment_receipts" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_updated_by_user_id" ON "scheduling"."appointment_payment_receipts" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_receipts_booking_uploaded" ON "scheduling"."appointment_payment_receipts" ("appointment_booking_id", "uploaded_at");

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_appointment_booking_id" FOREIGN KEY ("appointment_booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_uploaded_by_user_id" FOREIGN KEY ("uploaded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_review_status_concept_id" FOREIGN KEY ("review_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_reviewed_by_user_id" FOREIGN KEY ("reviewed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_receipts"
        ADD CONSTRAINT "fk_appointment_payment_receipts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- RLS: la tabla tiene `tenant_id`, así que lleva la política `tenant_isolation` con
-- el texto exacto de 2026-08-05_tenant_rls.sql. Ese patch descubre toda tabla con
-- `tenant_id` y, si se vuelve a ejecutar, deja la misma política: no hay ventana en
-- la que la tabla exista sin aislamiento por tenant.
ALTER TABLE "scheduling"."appointment_payment_receipts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "scheduling"."appointment_payment_receipts" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation ON "scheduling"."appointment_payment_receipts";
CREATE POLICY tenant_isolation ON "scheduling"."appointment_payment_receipts"
    USING (
        tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
        OR current_setting('app.system_context', true) = 'true'
    )
    WITH CHECK (
        tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
        OR current_setting('app.system_context', true) = 'true'
    );

-- ------------------------------------------------------------- D. verificación
DO $$
DECLARE
    n_columnas integer;
    n_tabla    integer;
    n_fk       integer;
    n_rls      integer;
BEGIN
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE (table_schema, table_name, column_name) IN (
        ('practice', 'practice_sites', 'logo_file_id'),
        ('scheduling', 'schedule_rules', 'flexible_hours'));

    SELECT count(*) INTO n_tabla
    FROM information_schema.tables
    WHERE table_schema = 'scheduling' AND table_name = 'appointment_payment_receipts';

    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE (conname LIKE 'fk\_appointment\_payment\_receipts\_%'
           OR conname = 'fk_practice_sites_logo_file_id')
      AND convalidated;

    SELECT count(*) INTO n_rls
    FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'scheduling' AND c.relname = 'appointment_payment_receipts'
      AND c.relrowsecurity AND c.relforcerowsecurity;

    IF n_columnas <> 2 OR n_tabla <> 1 OR n_fk <> 9 OR n_rls <> 1 THEN
        RAISE EXCEPTION
            'v4.2.64 incompleto: columnas=% (2), tabla=% (1), fk=% (9), rls=% (1)',
            n_columnas, n_tabla, n_fk, n_rls;
    END IF;

    RAISE NOTICE 'v4.2.64 aplicado: 2 columnas, 1 tabla con RLS, 9 FKs validadas.';
END $$;

COMMIT;
