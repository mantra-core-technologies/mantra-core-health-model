-- ============================================================================
-- SALUD · patch de columnas v4.0.2 → v4.0.7 sobre la BD viva (mantra_redesa_health)
-- Fecha: 2026-07-24 · Idempotente (ADD COLUMN IF NOT EXISTS / ON CONFLICT DO NOTHING)
--
-- Contexto: gen_ddl.py solo emite CREATE TABLE IF NOT EXISTS; en un rebuild desde
-- cero estas columnas ya vienen en el CREATE TABLE de cada tabla. Este patch existe
-- únicamente para la base ya aplicada y poblada en v4.0.1. gen_apply.py no escanea
-- SQL/patches/ (solo directorios NN_schema), así que no entra en apply_all.sql.
--
-- IMPORTANTE: aplicar ANTES que los 03_fk_intra/90_fk_deferred regenerados de los
-- módulos 11 y 42 — esos archivos crean FKs sobre partition_spec_id/tier_concept_id
-- y un undefined_column no lo atrapa el handler duplicate_object de los DO $$.
-- ============================================================================

-- v4.0.4 — system_ops.entity_registry: vínculo con la spec de particionado
ALTER TABLE "system_ops"."entity_registry"
    ADD COLUMN IF NOT EXISTS "partition_spec_id" uuid;

-- v4.0.4 — titular de cuenta bancaria (cierre de huecos de afiliación)
ALTER TABLE "accounting"."company_bank_accounts"
    ADD COLUMN IF NOT EXISTS "account_holder_name" varchar,
    ADD COLUMN IF NOT EXISTS "account_holder_tax_id" varchar;

ALTER TABLE "erp"."business_partner_bank_accounts"
    ADD COLUMN IF NOT EXISTS "account_holder_name" varchar,
    ADD COLUMN IF NOT EXISTS "account_holder_tax_id" varchar;

-- v4.0.5 — payments.subscription_plans: tier / default / visibilidad
ALTER TABLE "payments"."subscription_plans"
    ADD COLUMN IF NOT EXISTS "tier_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "is_default" boolean,
    ADD COLUMN IF NOT EXISTS "is_public" boolean;

-- ----------------------------------------------------------------------------
-- Backfill de tier_concept_id (el modelo lo declara NOT NULL; hay 22 filas seed).
-- Concepto boot 'FREE' del value set vs_subscription_plan_tier (Patch v4.0.5).
-- id determinista: uuid5(9e475ed5-d2a0-40db-b9ea-319a67158d7a,
--   'SALUD|4.0.5|boot|42|terminology.catalog_concepts|vs_subscription_plan_tier|FREE')
-- (mismo NAMESPACE que seedsGenerales/tools/generate-deep-seeds.py::stable_uuid).
-- code_system_version / state_concept / created_by: los mismos boot rows que usan
-- los conceptos de arranque del módulo 03 (p. ej. el concepto ACTIVE).
-- Los conceptos PRO y MAX quedan a cargo del generador de seeds (TODO documentado
-- en physical-materialization.md — no se siembran aquí porque el backfill solo
-- necesita el tier por defecto).
-- ----------------------------------------------------------------------------
-- Las filas de las que este bloque cuelga se buscan POR SU CLAVE NATURAL, no
-- por un uuid escrito acá. Los ids literales que tenía antes —la versión
-- `4cbf27de-…`, el concepto ACTIVE `d0f53ea3-…`, el usuario `499d0869-…`— los
-- derivaba `generate-deep-seeds.py` con su propio uuid5, y los seeds que hoy
-- pueblan la base usan otra derivación: ninguno de los tres existe. El parche
-- moría con `violates foreign key constraint fk_catalog_concepts_code_system_version_id`
-- y, como es el primero de la serie, se llevaba por delante a los otros 22.
--
-- `state_concept_id` y `created_by_user_id` son NULLABLE, así que si no están se
-- omiten en vez de inventarlos. `code_system_version_id` no lo es: sin versión
-- interna no hay dónde colgar el concepto y el bloque se salta entero,
-- diciéndolo.
BEGIN;

DO $$
DECLARE
    v_version uuid;
    v_activo  uuid;
    v_free    uuid;
BEGIN
    SELECT v.id INTO v_version
      FROM "terminology"."code_system_versions" v
      JOIN "terminology"."code_systems" s ON s.id = v.code_system_id
     WHERE s.internal_code = 'mantra-core-internal'
     ORDER BY v.version DESC
     LIMIT 1;

    IF v_version IS NULL THEN
        RAISE NOTICE 'v4.0.5: no está el code system mantra-core-internal; se omite el tier FREE';
        RETURN;
    END IF;

    SELECT id INTO v_activo
      FROM "terminology"."catalog_concepts"
     WHERE code = 'ACTIVE' AND code_system_version_id = v_version
     LIMIT 1;

    -- La clave natural de un concepto es (versión, código); el id se deja al
    -- generador por defecto salvo que la fila ya esté.
    SELECT id INTO v_free
      FROM "terminology"."catalog_concepts"
     WHERE code = 'FREE' AND code_system_version_id = v_version;

    IF v_free IS NULL THEN
        v_free := gen_random_uuid();
        INSERT INTO "terminology"."catalog_concepts"
            ("id", "code_system_version_id", "code", "display", "definition",
             "abstract", "selectable", "valid_from", "state_concept_id",
             "created_at", "updated_at", "row_version")
        VALUES
            (v_free, v_version, 'FREE', 'Free',
             'Tier Free del value set vs_subscription_plan_tier (Patch v4.0.5): plan de suscripción por defecto para consultorios y enfermerías.',
             false, true, '2026-07-24T00:00:00Z', v_activo,
             '2026-07-24T00:00:00Z', '2026-07-24T00:00:00Z', 1);
    END IF;

    UPDATE "payments"."subscription_plans"
       SET "tier_concept_id" = v_free
     WHERE "tier_concept_id" IS NULL;

    -- Sólo se exige NOT NULL si de verdad no quedó ninguna sin tier: si el
    -- backfill no pudo con todas, es mejor dejar la columna como está que
    -- abortar la serie entera de parches.
    IF NOT EXISTS (
        SELECT 1 FROM "payments"."subscription_plans" WHERE "tier_concept_id" IS NULL
    ) THEN
        ALTER TABLE "payments"."subscription_plans"
            ALTER COLUMN "tier_concept_id" SET NOT NULL;
    ELSE
        RAISE NOTICE 'v4.0.5: quedan planes sin tier; no se fuerza NOT NULL';
    END IF;
END $$;

COMMIT;
