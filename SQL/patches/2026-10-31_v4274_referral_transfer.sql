-- 2026-10-31 · v4274 · Datos de traslado en la derivación (brecha B8).
--
-- La Norma Nacional de Referencia y Contrarreferencia (MSD Bolivia, 2.ª ed. 2013) pide que la
-- hoja de referencia registre el medio de transporte, quién acompaña (familiar y personal de
-- salud), el estado y los signos vitales del paciente al salir, y la comunicación previa con el
-- establecimiento receptor en la referencia de urgencia; el receptor anota la llegada y el estado
-- en que llegó el paciente. clinical_ext.referrals suma esas columnas.
--
-- Todas las columnas son NULLABLE: las filas existentes siguen siendo válidas. Las enumeraciones
-- son varchar + CHECK y los signos vitales llevan un CHECK de rango fisiológico plausible; un
-- NULL pasa cada CHECK. Coherencia: diastólica < sistólica y llegada ≥ salida, cuando vienen los
-- dos valores. Las reglas cruzadas (ambulancia y personal de salud si el paciente sale inestable,
-- aviso al receptor en la urgencia) las exige la API. Mismos nombres que el modelo (diagram_18 y
-- diagram_33 v4.2.74). Idempotente: se puede aplicar N veces.

-- ─── clinical_ext.referrals ─────────────────────────────────────────────────────────────

ALTER TABLE "clinical_ext"."referrals"
    ADD COLUMN IF NOT EXISTS "transfer_required" boolean,
    ADD COLUMN IF NOT EXISTS "transport_mode" varchar(24),
    ADD COLUMN IF NOT EXISTS "transport_detail" varchar(200),
    ADD COLUMN IF NOT EXISTS "companion_name" varchar(200),
    ADD COLUMN IF NOT EXISTS "companion_relationship" varchar(80),
    ADD COLUMN IF NOT EXISTS "companion_phone" varchar(40),
    ADD COLUMN IF NOT EXISTS "escort_professional_name" varchar(200),
    ADD COLUMN IF NOT EXISTS "escort_professional_role" varchar(80),
    ADD COLUMN IF NOT EXISTS "departure_condition" varchar(16),
    ADD COLUMN IF NOT EXISTS "vitals_recorded_at" timestamptz,
    ADD COLUMN IF NOT EXISTS "vital_systolic_bp" smallint,
    ADD COLUMN IF NOT EXISTS "vital_diastolic_bp" smallint,
    ADD COLUMN IF NOT EXISTS "vital_heart_rate" smallint,
    ADD COLUMN IF NOT EXISTS "vital_respiratory_rate" smallint,
    ADD COLUMN IF NOT EXISTS "vital_temperature_c" numeric(4,1),
    ADD COLUMN IF NOT EXISTS "vital_oxygen_saturation" smallint,
    ADD COLUMN IF NOT EXISTS "vital_glasgow" smallint,
    ADD COLUMN IF NOT EXISTS "receiver_contacted" boolean,
    ADD COLUMN IF NOT EXISTS "receiver_contact_name" varchar(200),
    ADD COLUMN IF NOT EXISTS "receiver_contacted_at" timestamptz,
    ADD COLUMN IF NOT EXISTS "departed_at" timestamptz,
    ADD COLUMN IF NOT EXISTS "arrived_at" timestamptz,
    ADD COLUMN IF NOT EXISTS "arrival_condition" varchar(16),
    ADD COLUMN IF NOT EXISTS "arrival_notes" text;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_transport_mode"
        CHECK ("transport_mode" IN ('AMBULANCE_BASIC','AMBULANCE_ADVANCED','AIR_AMBULANCE','RIVER','PRIVATE_VEHICLE','PUBLIC_TRANSPORT','ON_FOOT','OTHER'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_departure_condition"
        CHECK ("departure_condition" IN ('STABLE','UNSTABLE','CRITICAL'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_arrival_condition"
        CHECK ("arrival_condition" IN ('STABLE','UNSTABLE','CRITICAL','DECEASED'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_systolic_bp_range"
        CHECK ("vital_systolic_bp" BETWEEN 40 AND 300);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_diastolic_bp_range"
        CHECK ("vital_diastolic_bp" BETWEEN 20 AND 200);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_heart_rate_range"
        CHECK ("vital_heart_rate" BETWEEN 20 AND 300);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_respiratory_rate_range"
        CHECK ("vital_respiratory_rate" BETWEEN 4 AND 80);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_temperature_c_range"
        CHECK ("vital_temperature_c" BETWEEN 30.0 AND 45.0);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_oxygen_saturation_range"
        CHECK ("vital_oxygen_saturation" BETWEEN 50 AND 100);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_glasgow_range"
        CHECK ("vital_glasgow" BETWEEN 3 AND 15);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_vital_bp_order"
        CHECK (("vital_diastolic_bp" IS NULL OR "vital_systolic_bp" IS NULL OR "vital_diastolic_bp" < "vital_systolic_bp"));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "ck_referrals_arrival_after_departure"
        CHECK (("arrived_at" IS NULL OR "departed_at" IS NULL OR "arrived_at" >= "departed_at"));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
