-- ============================================================================
-- SALUD · patch v4.2.65 (clinical_ext · derivación con tipo y servicio de destino) sobre BD viva
-- Fecha: 2026-10-28 · pedido: derivar a un servicio específico de otro doctor u
-- organización médica, indicando el tipo de derivación (tratamiento, consulta, …).
-- Idempotente (ADD COLUMN IF NOT EXISTS / IF NOT EXISTS / duplicate_object). Sin backfill.
--
-- Contexto: gen_ddl.py ya emite estas columnas, sus índices y sus FKs en
-- SQL/18_clinical_ext/ desde que diagram_18_clinical_ext.puml las declara, así que en un
-- rebuild desde cero este patch NO hace falta. Existe para una base ya aplicada y poblada:
-- un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que ya existe. gen_apply.py
-- no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se copiaron de los
-- archivos generados, no se escribieron a mano.
--
-- QUÉ AGREGA en clinical_ext.referrals (las dos columnas son opcionales: toda derivación
-- existente queda igual, con las dos en NULL):
--   - referral_type_concept_id → terminology.catalog_concepts(id). Qué se le pide al destino:
--     tratamiento, consulta, estudio diagnóstico, procedimiento o segunda opinión. Los
--     conceptos son de módulo y los siembra la API al arrancar (TerminologySeedService,
--     clinical_ext.concepts.ts: clinical_ext:REFERRAL_TYPE_*), igual que el estado y la
--     prioridad de la derivación; un tipo nuevo se agrega como concepto, sin migrar.
--   - target_service_catalog_id → billing.service_catalog(id). El servicio concreto que
--     ofrece el profesional (target_profile_id) o la organización (target_tenant_id) de
--     destino. La fila no copia precio ni nombre: billing.service_catalog sigue siendo dueño.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +2 · FKs +2 · índices +2 · filas 0
-- ============================================================================

BEGIN;

ALTER TABLE "clinical_ext"."referrals"
    ADD COLUMN IF NOT EXISTS "referral_type_concept_id" uuid;

ALTER TABLE "clinical_ext"."referrals"
    ADD COLUMN IF NOT EXISTS "target_service_catalog_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_referrals_referral_type_concept_id" ON "clinical_ext"."referrals" ("referral_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_target_service_catalog_id" ON "clinical_ext"."referrals" ("target_service_catalog_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "fk_referrals_referral_type_concept_id" FOREIGN KEY ("referral_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: billing.service_catalog (requiere schema billing)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "fk_referrals_target_service_catalog_id" FOREIGN KEY ("target_service_catalog_id")
        REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
