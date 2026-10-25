-- ============================================================================
-- SALUD · patch (identity_assurance · tenant del caso de verificación de identidad) sobre BD viva
-- Fecha: 2026-10-24 · hallazgos IDA-01 / IDA-02 (API #751 y #794)
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. identity_assurance.identity_verification_cases.tenant_id (nullable, FK a
-- directory.tenants, con índice): el tenant al que pertenece el caso. Sin él, un caso y su
-- evidencia solo se podían resolver por UUID, sin comprobar de qué organización eran.
--
-- SIN BACKFILL. Los casos anteriores quedan con tenant_id NULL: el tenant no se puede inferir del
-- esquema (el sujeto es polimórfico: subject_type_concept_id + subject_entity_id). Los casos sin
-- tenant, solo lectura:
--   SELECT id, subject_type_concept_id, subject_entity_id
--     FROM identity_assurance.identity_verification_cases WHERE tenant_id IS NULL;
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +1 · NOT NULL quitados 0 · FKs +1 · índices +1 (-0) · constraints +0
-- ============================================================================

BEGIN;

ALTER TABLE "identity_assurance"."identity_verification_cases"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "identity_assurance"."identity_verification_cases"
        ADD CONSTRAINT "fk_identity_verification_cases_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_identity_verification_cases_tenant_id" ON "identity_assurance"."identity_verification_cases" ("tenant_id");

COMMIT;
