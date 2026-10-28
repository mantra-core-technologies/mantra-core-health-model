-- ============================================================================
-- SALUD · patch (surveys · encuesta base del sistema + extensión del profesional) sobre BD viva
-- Fecha: 2026-10-28 · REC 65.8 · F3 (encuesta base, emisión automática, asociación a servicio)
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/65_surveys/ desde que el .puml lo
-- declara, así que en un rebuild desde cero este patch NO hace falta. Existe para una base ya
-- aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que ya existe.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se copiaron de
-- los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA.
--   Una invitación puede llevar, además de la versión base (survey_version_id), la versión del
--   profesional que atendió (extension_survey_version_id): el paciente responde UNA encuesta con
--   las preguntas del sistema primero y las del médico después. La base del sistema no necesita
--   columnas nuevas: es una plantilla con dueño tipado (owner_type_concept_id + owner_id, v4249) y
--   su asignación usa un target_type propio (concepto, no DDL).
--   La extensión es nullable: las invitaciones ya emitidas, y las que no tienen encuesta del
--   profesional, no la llevan. Nunca puede ser la misma versión que la base.
--
-- PRECONDICIÓN: ninguna. La columna es nueva y nullable, y el CHECK se agrega sobre filas que todas
-- la tienen en NULL.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas +1 · FKs +1 · índices +1 · constraints +1
-- ============================================================================

BEGIN;

ALTER TABLE "surveys"."survey_invitations"
    ADD COLUMN IF NOT EXISTS "extension_survey_version_id" uuid;

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_extension_survey_version_id" FOREIGN KEY ("extension_survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_extension_version" ON "surveys"."survey_invitations" ("extension_survey_version_id");

-- ═══ survey_invitations ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_invitations" DROP CONSTRAINT IF EXISTS "ck_survey_invitations_extension_distinct";
ALTER TABLE "surveys"."survey_invitations" ADD CONSTRAINT "ck_survey_invitations_extension_distinct" CHECK ("extension_survey_version_id" IS NULL OR "extension_survey_version_id" <> "survey_version_id");

COMMIT;
