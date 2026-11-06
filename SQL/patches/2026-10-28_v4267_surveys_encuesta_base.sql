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
--   Y desactiva las asignaciones heredadas de FT-31 (ver DATOS, abajo).
--
-- PRECONDICIÓN: ninguna. La columna es nueva y nullable, y el CHECK se agrega sobre filas que todas
-- la tienen en NULL.
--
-- DATOS (no sale de los .puml; sólo este patch lo hace). FT-31 creaba, con cada servicio nuevo,
-- una plantilla «Satisfacción — <servicio>» de UNA pregunta y la asociaba al servicio
-- (target SERVICE = billing.service_catalog.id). Esas asignaciones nunca emitieron nada (la emisión
-- buscaba por otro identificador); con la emisión corregida empezarían a coincidir y competirían con
-- la encuesta que el médico asocia a propósito. Se DESACTIVAN (active = false; no se borra nada) las
-- que cumplen TODO esto: destino SERVICE, plantilla de un profesional titulada «Satisfacción — …»,
-- cuya versión tiene exactamente la pregunta «¿Qué tan satisfecho quedó con la atención?», y que NO
-- tiene invitaciones ni respuestas. Una plantilla que ya se repartió o respondió no se toca.
-- Idempotente: sólo mira asignaciones activas. El UUID es SURVEYS.TARGET_SERVICE
-- (deterministicId('surveys:TARGET_SERVICE')) de surveys.concepts.ts.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas +1 · FKs +1 · índices +1 · constraints +1 · asignaciones FT-31 desactivadas: las que haya
-- ============================================================================

BEGIN;

-- Si la tabla está en uso, el ALTER espera un candado: mejor fallar rápido que encolar escrituras.
SET LOCAL lock_timeout = '5s';

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

-- ═══ datos: asignaciones heredadas de FT-31 ═══
UPDATE "surveys"."survey_assignments" a
   SET "active" = false, "updated_at" = now(), "row_version" = a."row_version" + 1
 WHERE a."active" = true
   AND a."target_type_concept_id" = '0a48774c-6a99-50f7-b485-71899fba56c5'
   AND EXISTS (
       SELECT 1
         FROM "surveys"."survey_versions" v
         JOIN "surveys"."survey_templates" t ON t."id" = v."survey_template_id"
        WHERE v."id" = a."survey_version_id"
          AND t."owner_practitioner_id" IS NOT NULL
          AND t."title" LIKE 'Satisfacción — %'
          AND (SELECT count(*) FROM "surveys"."survey_questions" q WHERE q."survey_version_id" = v."id") = 1
          AND EXISTS (SELECT 1 FROM "surveys"."survey_questions" q
                       WHERE q."survey_version_id" = v."id"
                         AND q."question_text" = '¿Qué tan satisfecho quedó con la atención?'))
   AND NOT EXISTS (SELECT 1 FROM "surveys"."survey_invitations" i
                    WHERE i."survey_version_id" = a."survey_version_id"
                       OR i."extension_survey_version_id" = a."survey_version_id")
   AND NOT EXISTS (SELECT 1 FROM "surveys"."survey_responses" r
                    WHERE r."survey_version_id" = a."survey_version_id");

COMMIT;
