-- ============================================================================
-- SALUD · patch v4.2.23 (insurance · campañas preventivas de aseguradora, Tarea 4 / M-06)
-- Fecha: 2026-09-25
-- Idempotente (CREATE TABLE IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo EXCEPTION duplicate_object / DROP CONSTRAINT IF EXISTS
-- antes de cada CHECK). UNA sola pasada. Sin backfill: no hay campañas previas.
--
-- Contexto: `gen_ddl.py 26` y `gen_integrity.py` ya emiten estas dos tablas, sus
-- índices, sus FK y sus dos CHECK en SQL/26_insurance/ desde que
-- `diagram_26_insurance.puml` y `diagram_33_integrity.puml` las declaran, así
-- que en un rebuild desde cero este patch NO hace falta. Existe únicamente para
-- una base ya aplicada y poblada. `gen_apply.py` no escanea SQL/patches/.
--
-- QUÉ CIERRA. Registro de procesos del cliente, módulo Aseguradora de salud,
-- «MODULO DE PROMOCIONES» (§6.4): campañas de prevención de la aseguradora en
-- alianza con importadoras, fabricantes de medicamentos y laboratorios, para que
-- no suban las primas ni el seguro erogue por enfermedades evitables. La
-- verificación 2026-09-25 lo marca FALTA (anexo E, A4.1/A4.2).
--
--   insurance.insurance_campaigns          la campaña: aseguradora, código único
--                                          por aseguradora, tipo, patología
--                                          (CIE-10, sólo descriptiva), bonificación
--                                          de copago 0..100, vigencia y estado.
--   insurance.insurance_campaign_partners  aliados: SPONSOR (importadora o
--                                          fabricante) o PROVIDER (laboratorio,
--                                          farmacia, centro). `partner_tenant_id`
--                                          es referencia blanda, SIN FK: las
--                                          importadoras no son tenants del sistema
--                                          (precedente: provider_entity_id).
--
-- DECISIÓN D4 (verificación 2026-09-25): `target_condition_concept_id` describe la
-- patología que la campaña previene; NUNCA se usa para filtrar afiliados por su
-- historia clínica. Eso exigiría un consentimiento específico que no existe.
--
-- Las FK de las 12 columnas nuevas quedan «inferidas por convención» porque no
-- tienen ficha en la bóveda; ninguna FK preexistente cambió de etiqueta.
-- ============================================================================

BEGIN;

-- 1. Tablas
CREATE TABLE IF NOT EXISTS "insurance"."insurance_campaigns" (
    "id" uuid NOT NULL,
    "insurance_carrier_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "title" varchar NOT NULL,
    "description" text,
    "campaign_type_concept_id" uuid NOT NULL,
    "target_condition_concept_id" uuid,
    "copay_bonus_percentage" numeric NOT NULL,
    "valid_from" date NOT NULL,
    "valid_to" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "activated_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_campaigns" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "insurance"."insurance_campaign_partners" (
    "id" uuid NOT NULL,
    "insurance_campaign_id" uuid NOT NULL,
    "partner_role_concept_id" uuid NOT NULL,
    "partner_type_concept_id" uuid NOT NULL,
    "partner_name" varchar NOT NULL,
    "partner_tenant_id" uuid,
    "network_provider_membership_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_insurance_campaign_partners" PRIMARY KEY ("id")
);

-- 2. Índices
CREATE UNIQUE INDEX IF NOT EXISTS "uq_insurance_campaigns_carrier_code" ON "insurance"."insurance_campaigns" ("insurance_carrier_id", "code");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaigns_carrier_status_validity" ON "insurance"."insurance_campaigns" ("insurance_carrier_id", "status_concept_id", "valid_from", "valid_to");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaigns_campaign_type_concept_id" ON "insurance"."insurance_campaigns" ("campaign_type_concept_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaigns_target_condition_concept_id" ON "insurance"."insurance_campaigns" ("target_condition_concept_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaigns_created_by_user_id" ON "insurance"."insurance_campaigns" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaigns_updated_by_user_id" ON "insurance"."insurance_campaigns" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaign_partners_insurance_campaign_id" ON "insurance"."insurance_campaign_partners" ("insurance_campaign_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaign_partners_partner_role_concept_id" ON "insurance"."insurance_campaign_partners" ("partner_role_concept_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaign_partners_partner_type_concept_id" ON "insurance"."insurance_campaign_partners" ("partner_type_concept_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaign_partners_network_provider_membership_id" ON "insurance"."insurance_campaign_partners" ("network_provider_membership_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaign_partners_created_by_user_id" ON "insurance"."insurance_campaign_partners" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_insurance_campaign_partners_updated_by_user_id" ON "insurance"."insurance_campaign_partners" ("updated_by_user_id");

-- 3. Claves foráneas
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_insurance_carrier_id" FOREIGN KEY ("insurance_carrier_id")
        REFERENCES "insurance"."insurance_carriers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_insurance_campaign_id" FOREIGN KEY ("insurance_campaign_id")
        REFERENCES "insurance"."insurance_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_network_provider_membership_id" FOREIGN KEY ("network_provider_membership_id")
        REFERENCES "insurance"."network_provider_memberships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_campaign_type_concept_id" FOREIGN KEY ("campaign_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_target_condition_concept_id" FOREIGN KEY ("target_condition_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaigns"
        ADD CONSTRAINT "fk_insurance_campaigns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_partner_role_concept_id" FOREIGN KEY ("partner_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_partner_type_concept_id" FOREIGN KEY ("partner_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "insurance"."insurance_campaign_partners"
        ADD CONSTRAINT "fk_insurance_campaign_partners_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- 4. CHECK (respaldo en base de datos; el servicio valida antes y responde 400)
ALTER TABLE "insurance"."insurance_campaigns" DROP CONSTRAINT IF EXISTS "ck_insurance_campaigns_valid_period";
ALTER TABLE "insurance"."insurance_campaigns" ADD CONSTRAINT "ck_insurance_campaigns_valid_period" CHECK (("valid_from" <= "valid_to"));
ALTER TABLE "insurance"."insurance_campaigns" DROP CONSTRAINT IF EXISTS "ck_insurance_campaigns_copay_bonus_range";
ALTER TABLE "insurance"."insurance_campaigns" ADD CONSTRAINT "ck_insurance_campaigns_copay_bonus_range" CHECK (("copay_bonus_percentage" >= 0 AND "copay_bonus_percentage" <= 100));

-- 5. Aserción: si algo no quedó, la transacción entera falla.
DO $$
DECLARE
    v_tables int; v_fks int; v_checks int;
BEGIN
    SELECT count(*) INTO v_tables FROM information_schema.tables
     WHERE table_schema = 'insurance'
       AND table_name IN ('insurance_campaigns', 'insurance_campaign_partners');
    SELECT count(*) INTO v_fks FROM pg_constraint
     WHERE contype = 'f'
       AND conrelid IN ('"insurance"."insurance_campaigns"'::regclass,
                        '"insurance"."insurance_campaign_partners"'::regclass);
    SELECT count(*) INTO v_checks FROM pg_constraint
     WHERE contype = 'c'
       AND conrelid = '"insurance"."insurance_campaigns"'::regclass
       AND conname IN ('ck_insurance_campaigns_valid_period',
                       'ck_insurance_campaigns_copay_bonus_range');
    IF v_tables <> 2 OR v_fks <> 12 OR v_checks <> 2 THEN
        RAISE EXCEPTION 'v4223: esperaba 2 tablas, 12 FK y 2 CHECK; hay % / % / %',
            v_tables, v_fks, v_checks;
    END IF;
END $$;

COMMIT;

-- ============================================================================
-- Comprobación manual (debe devolver 2 tablas, 14 índices —7 por tabla, PK
-- incluida—, 12 FK y 2 CHECK):
--
--   SELECT count(*) FROM information_schema.tables
--    WHERE table_schema = 'insurance'
--      AND table_name IN ('insurance_campaigns', 'insurance_campaign_partners');
--
--   SELECT count(*) FROM pg_indexes
--    WHERE schemaname = 'insurance'
--      AND tablename IN ('insurance_campaigns', 'insurance_campaign_partners');
--
--   SELECT count(*) FROM pg_constraint WHERE contype = 'f'
--      AND conrelid IN ('"insurance"."insurance_campaigns"'::regclass,
--                       '"insurance"."insurance_campaign_partners"'::regclass);
--
--   SELECT count(*) FROM pg_constraint WHERE contype = 'c'
--      AND conrelid = '"insurance"."insurance_campaigns"'::regclass;
-- ============================================================================
