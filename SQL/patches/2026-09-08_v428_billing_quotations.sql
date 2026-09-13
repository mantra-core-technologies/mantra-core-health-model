-- ============================================================================
-- SALUD · patch v4.2.8 (billing · cotizaciones, T24/FT-24) sobre BD viva
-- Fecha: 2026-09-08
-- Idempotente (CREATE TABLE IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo IF NOT EXISTS).
-- UNA sola pasada. No hay backfill: no existe ninguna fila viva de cotización.
--
-- Contexto: gen_ddl.py ya emite estas dos tablas en SQL/17_billing/ desde que
-- el .puml las declara, así que en un rebuild desde cero este patch NO hace
-- falta. Existe únicamente para una base ya aplicada y poblada. gen_apply.py
-- no escanea SQL/patches/ (sólo directorios NN_schema), así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. T24 «Creación de cotizaciones» (FT-24) ya tiene implementación
-- mergeada en la API (commit 6d6b95df, PR #345, 2026-09-05) y en el front
-- (PR #352): un profesional cotiza un servicio del catálogo con un plan de
-- pagos simulado (tasa, plazo, método FLAT/FRENCH), fija la validez de la
-- oferta y exporta a PDF. Las dos tablas nunca se declararon en el modelo
-- canónico — sólo existían en las entidades ORM y en la copia vendida
-- `mantra-core-health-api/database/SQL/17_billing/` —, así que un stack
-- reconstruido desde el modelo no las tenía y `yarn db:vendor` las habría
-- borrado de la copia vendida. Este patch, y el cambio de `.puml` que lo
-- generó, cierran ese hueco. No hay decisión de producto de por medio: las
-- columnas, tipos y obligatoriedad son exactamente los del DDL ya mergeado.
--
-- DIFERENCIA REAL ENTRE LO GENERADO Y LO MERGEADO (no resuelta, registrada
-- para Ender/dueño del modelo, según pide 02-CAMBIO-DE-MODELO-REQUERIDO.md).
-- `gen_ddl.py` no tiene mecanismo para emitir `CHECK` — no hay ninguna
-- columna `CHECK` en las 65 tablas que sí genera. La API mergeada declara
-- `interest_calculation_method varchar NOT NULL CHECK IN ('FLAT','FRENCH')`.
-- Este patch SÍ agrega ese `CHECK` a mano (no lo agrega el generador), para
-- no dejar la base viva más laxa que la API que ya corre contra ella. Si el
-- pipeline llegara a ganar soporte de `CHECK` más adelante, este patch queda
-- redundante con lo generado, no contradictorio.
--
-- POR QUÉ `appointment_id` NO LLEVA FK. Así está en el DDL mergeado, con el
-- comentario propio del autor original: «sin destino canónico, evita anillo»
-- (scheduling → billing → scheduling). Se declara igual, uuid nullable, sin
-- forzar destino — temperatura-0, no se inventa la relación que falta.
--
-- POR QUÉ NO HAY BACKFILL. No existe ninguna fila viva con este dato: recién
-- se agrega la posibilidad de declararlo.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas de billing            20 → 22   (+2: quotations, quotation_installments)
--   FKs intra-schema             +2  (quotations→service_catalog, quotation_installments→quotations)
--   FKs diferidas (otro schema)  +7  (practice_id, patient_profile_id,
--                                     created_by_practitioner_profile_id,
--                                     currency_concept_id, status_concept_id,
--                                     created_by_user_id, updated_by_user_id)
--   FK que ENTRA a billing       +1  (pharmacy_inventory.inventory_reservations
--                                      .quotation_id, que estaba sin destino
--                                      hasta que existió billing.quotations)
--   índices                      +10 (9 en quotations + 1 en quotation_installments,
--                                      sin contar las 2 PK que ya cuenta CREATE TABLE)
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. tablas
CREATE TABLE IF NOT EXISTS "billing"."quotations" (
    "id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "created_by_practitioner_profile_id" uuid NOT NULL,
    "attention_date" date NOT NULL,
    "appointment_id" uuid,
    "service_catalog_id" uuid NOT NULL,
    "service_name_snapshot" varchar NOT NULL,
    "offered_price" numeric NOT NULL,
    "currency_concept_id" uuid,
    "payment_plan_installment_count" integer NOT NULL,
    "interest_rate_percent" numeric NOT NULL,
    "interest_calculation_method" varchar NOT NULL,
    "valid_until" date NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quotations" PRIMARY KEY ("id"),
    CONSTRAINT "ck_quotations_interest_calculation_method"
        CHECK ("interest_calculation_method" IN ('FLAT', 'FRENCH'))
);

CREATE TABLE IF NOT EXISTS "billing"."quotation_installments" (
    "id" uuid NOT NULL,
    "quotation_id" uuid NOT NULL,
    "installment_number" integer NOT NULL,
    "due_date" date NOT NULL,
    "principal_amount" numeric NOT NULL,
    "interest_amount" numeric NOT NULL,
    "total_amount" numeric NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_quotation_installments" PRIMARY KEY ("id")
);

-- ------------------------------------------------------------------ B. índices
CREATE INDEX IF NOT EXISTS "ix_quotations_practice_id" ON "billing"."quotations" ("practice_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_patient_profile_id" ON "billing"."quotations" ("patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_created_by_practitioner_profile_id" ON "billing"."quotations" ("created_by_practitioner_profile_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_appointment_id" ON "billing"."quotations" ("appointment_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_service_catalog_id" ON "billing"."quotations" ("service_catalog_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_currency_concept_id" ON "billing"."quotations" ("currency_concept_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_status_concept_id" ON "billing"."quotations" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_created_by_user_id" ON "billing"."quotations" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_quotations_updated_by_user_id" ON "billing"."quotations" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_quotation_installments_quotation_id" ON "billing"."quotation_installments" ("quotation_id");

-- ---------------------------------------------------------------------- C. FK
DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_service_catalog_id" FOREIGN KEY ("service_catalog_id")
        REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotation_installments"
        ADD CONSTRAINT "fk_quotation_installments_quotation_id" FOREIGN KEY ("quotation_id")
        REFERENCES "billing"."quotations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_created_by_practitioner_profile_id" FOREIGN KEY ("created_by_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_currency_concept_id" FOREIGN KEY ("currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."quotations"
        ADD CONSTRAINT "fk_quotations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- La décima FK NO es de billing: es la que billing DESBLOQUEA.
-- `pharmacy_inventory.inventory_reservations.quotation_id` estaba sin destino
-- desde el 2026-07-21 —apuntaba a `pharmacy_inventory.purchase_quotations`, que
-- no existe en el modelo— y `gen_ddl.py` no la forzaba. Con `billing.quotations`
-- creada, el destino existe y es el correcto: una reserva de inventario se hace
-- contra una cotización. Queda declarada en la nota del vault, así que el
-- generador ya la emite en `SQL/25_pharmacy_inventory/90_fk_deferred.sql` para
-- una base nueva; acá va para que una base VIVA no quede sin ella, que es como
-- las dos rutas dejan de coincidir.
DO $$ BEGIN
    ALTER TABLE "pharmacy_inventory"."inventory_reservations"
        ADD CONSTRAINT "fk_inventory_reservations_quotation_id" FOREIGN KEY ("quotation_id")
        REFERENCES "billing"."quotations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. Las cuatro consultas
-- tienen que devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_tablas   integer;
    n_fk       integer;
    n_indices  integer;
    n_check    integer;
BEGIN
    -- 2: las dos tablas nuevas están.
    SELECT count(*) INTO n_tablas
    FROM information_schema.tables
    WHERE table_schema = 'billing'
      AND table_name IN ('quotations', 'quotation_installments');

    -- 10: las diez FK nuevas existen y están validadas (no `NOT VALID`).
    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname IN (
        'fk_quotations_service_catalog_id', 'fk_quotation_installments_quotation_id',
        'fk_quotations_practice_id', 'fk_quotations_patient_profile_id',
        'fk_quotations_created_by_practitioner_profile_id',
        'fk_quotations_currency_concept_id', 'fk_quotations_status_concept_id',
        'fk_quotations_created_by_user_id', 'fk_quotations_updated_by_user_id',
        'fk_inventory_reservations_quotation_id'
    ) AND convalidated;

    -- 10: los diez índices nuevos existen.
    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'billing'
      AND indexname LIKE 'ix_quotation%';

    -- 1: el CHECK del método de interés existe.
    SELECT count(*) INTO n_check
    FROM pg_constraint
    WHERE conname = 'ck_quotations_interest_calculation_method';

    IF n_tablas <> 2 OR n_fk <> 10 OR n_indices <> 10 OR n_check <> 1 THEN
        RAISE EXCEPTION
            'v4.2.8 incompleto: tablas=% (esperado 2), fk=% (esperado 10), indices=% (esperado 10), check=% (esperado 1)',
            n_tablas, n_fk, n_indices, n_check;
    END IF;

    RAISE NOTICE 'v4.2.8 aplicado: 2 tablas, 10 FK validadas, 10 índices, 1 CHECK.';
END $$;

COMMIT;
