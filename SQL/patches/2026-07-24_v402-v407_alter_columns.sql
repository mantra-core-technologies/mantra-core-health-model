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
BEGIN;

INSERT INTO "terminology"."catalog_concepts"
    ("id", "code_system_version_id", "code", "display", "definition",
     "abstract", "selectable", "valid_from", "state_concept_id",
     "created_at", "updated_at", "created_by_user_id", "row_version")
VALUES
    ('f845c4f2-3f92-5a97-b76b-30f71c0cb43c',
     '4cbf27de-95c0-5fac-831a-9be6d26cd74c',
     'FREE', 'Free',
     'Tier Free del value set vs_subscription_plan_tier (Patch v4.0.5): plan de suscripción por defecto para consultorios y enfermerías.',
     false, true, '2026-07-24T00:00:00Z',
     'd0f53ea3-7e50-5578-add3-270341b1186c',
     '2026-07-24T00:00:00Z', '2026-07-24T00:00:00Z',
     '499d0869-90ee-5cdd-9b26-3c32c8518193', 1)
ON CONFLICT ("id") DO NOTHING;

UPDATE "payments"."subscription_plans"
   SET "tier_concept_id" = 'f845c4f2-3f92-5a97-b76b-30f71c0cb43c'
 WHERE "tier_concept_id" IS NULL;

ALTER TABLE "payments"."subscription_plans"
    ALTER COLUMN "tier_concept_id" SET NOT NULL;

COMMIT;
