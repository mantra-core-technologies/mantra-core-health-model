-- ============================================================================
-- SALUD · patch v4.2.91 · surveys · una encuesta activa por servicio y profesional + procedencia del catálogo estándar
-- Fecha: 2026-11-06 · REC 65.9 · contrato «Encuestas estandarizadas por servicio»
-- Idempotente (IF NOT EXISTS / DROP ... IF EXISTS / duplicate_object). UNA transacción, re-ejecutable.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten las columnas, la FK, los índices y el CHECK en
-- SQL/65_surveys/ desde que diagram_65_surveys.puml y diagram_33_integrity.puml los declaran; esas
-- sentencias se copiaron de los archivos generados. Desde v4.2.93 el disparador que mantiene
-- owner_practitioner_id igual al de la plantilla también se genera (TRIGGER_SQL en
-- diagram_33_integrity.puml → SQL/65_surveys/05_constraints.sql); sobre una base nueva este patch es
-- no-op. Lo que sólo vive acá es el respaldo de owner_practitioner_id y la desactivación de duplicados
-- de una base existente.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
--
-- QUÉ CAMBIA.
--   1. surveys.survey_assignments.owner_practitioner_id (uuid, nullable, FK a
--      profiles.health_practitioner_profiles.profile_id): copia del dueño de la plantilla de la versión
--      asignada. Hace falta porque un destino SERVICE es billing.service_catalog.id, una identidad que
--      comparten todos los profesionales que ofrecen ese servicio, y un índice único no alcanza otra
--      tabla. NULL en las asignaciones de plantillas de sistema o de dueño tipado.
--      El disparador trg_survey_assignments_owner_from_template lo completa desde la plantilla si llega
--      NULL y rechaza (check_violation) un valor distinto del de la plantilla.
--   2. uq_survey_assignments_active_service_owner: a lo sumo UNA asignación activa de tipo SERVICE por
--      (tenant_id, target_type_concept_id, target_id, owner_practitioner_id). Reemplazar la encuesta de un
--      servicio es desactivar la vigente y crear la nueva en la misma transacción, en ese orden.
--      El UUID del predicado es SURVEYS.TARGET_SERVICE = deterministicId('surveys:TARGET_SERVICE').
--   3. surveys.survey_templates.standard_catalog_code (text, nullable): de qué entrada STD_* del catálogo
--      estándar se materializó la plantilla. Único por tenant y dueño, para cada forma de dueño
--      (uq_survey_templates_practitioner_catalog_code, uq_survey_templates_party_catalog_code), así que
--      importar dos veces la misma entrada reutiliza la plantilla. Formato: ck_survey_templates_standard_catalog_code.
--
-- PRECONDICIÓN / DATOS. Antes de crear el índice único se DESACTIVAN (active = false; no se borra nada)
-- las asignaciones SERVICE activas que repiten (tenant, servicio, profesional), conservando la más nueva
-- (created_at, y el id como desempate). Las invitaciones ya emitidas siguen apuntando a su asignación.
-- Aborta si alguna asignación tiene un owner_practitioner_id distinto del de su plantilla.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas +2 · FKs +1 · índices +4 · constraints +1 · funciones +1 · disparadores +1 ·
--   asignaciones SERVICE duplicadas desactivadas: las que haya (se informa con NOTICE)
-- ============================================================================

BEGIN;

-- Si la tabla está en uso, el ALTER espera un candado: mejor fallar rápido que encolar escrituras.
SET LOCAL lock_timeout = '5s';

-- --------------------------------------------------- A. columnas (copiado de 02_tables.sql)
ALTER TABLE "surveys"."survey_templates"
    ADD COLUMN IF NOT EXISTS "standard_catalog_code" text;

ALTER TABLE "surveys"."survey_assignments"
    ADD COLUMN IF NOT EXISTS "owner_practitioner_id" uuid;

-- --------------------------------------------------- B. FK (copiado de 90_fk_deferred.sql)
-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "surveys"."survey_assignments"
        ADD CONSTRAINT "fk_survey_assignments_owner_practitioner_id" FOREIGN KEY ("owner_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --------------------------------------------------- C. respaldo del dueño desde la plantilla
UPDATE "surveys"."survey_assignments" a
   SET "owner_practitioner_id" = t."owner_practitioner_id"
  FROM "surveys"."survey_versions" v
  JOIN "surveys"."survey_templates" t ON t."id" = v."survey_template_id"
 WHERE v."id" = a."survey_version_id"
   AND a."owner_practitioner_id" IS NULL
   AND t."owner_practitioner_id" IS NOT NULL;

DO $$
DECLARE
    distintos integer;
BEGIN
    SELECT count(*) INTO distintos
      FROM "surveys"."survey_assignments" a
      JOIN "surveys"."survey_versions" v ON v."id" = a."survey_version_id"
      JOIN "surveys"."survey_templates" t ON t."id" = v."survey_template_id"
     WHERE a."owner_practitioner_id" IS DISTINCT FROM t."owner_practitioner_id";
    IF distintos > 0 THEN
        RAISE EXCEPTION 'surveys.survey_assignments: % fila(s) con owner_practitioner_id distinto del de su plantilla: corregirlas antes de aplicar el patch', distintos;
    END IF;
END $$;

-- --------------------------------------------------- D. el dueño de la asignación es el de la plantilla
-- SECURITY DEFINER para leer la plantilla aunque el RLS del que escribe no la deje ver; search_path fijo.
CREATE OR REPLACE FUNCTION "integrity"."survey_assignment_owner_from_template"()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public AS $$
DECLARE
    template_owner uuid;
    template_tenant uuid;
BEGIN
    -- SECURITY DEFINER bypasses RLS: never trust a version from another tenant and
    -- never echo the template owner back in an error message.
    SELECT t.owner_practitioner_id, t.tenant_id INTO template_owner, template_tenant
      FROM surveys.survey_versions v
      JOIN surveys.survey_templates t ON t.id = v.survey_template_id
     WHERE v.id = NEW.survey_version_id;
    IF NOT FOUND OR template_tenant IS DISTINCT FROM NEW.tenant_id THEN
        RAISE EXCEPTION 'survey_assignments: la versión % no existe en el tenant de la asignación',
            NEW.survey_version_id
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    IF NEW.owner_practitioner_id IS NULL THEN
        NEW.owner_practitioner_id := template_owner;
    ELSIF NEW.owner_practitioner_id IS DISTINCT FROM template_owner THEN
        RAISE EXCEPTION 'survey_assignments: owner_practitioner_id no es el dueño de la plantilla de la versión %',
            NEW.survey_version_id
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION "integrity"."survey_assignment_owner_from_template"() FROM PUBLIC;

DROP TRIGGER IF EXISTS trg_survey_assignments_owner_from_template ON "surveys"."survey_assignments";
CREATE TRIGGER trg_survey_assignments_owner_from_template
    BEFORE INSERT OR UPDATE OF "survey_version_id", "owner_practitioner_id" ON "surveys"."survey_assignments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."survey_assignment_owner_from_template"();

-- --------------------------------------------------- E. duplicados activos: se conserva la más nueva
DO $$
DECLARE
    desactivadas integer;
BEGIN
    WITH ranked AS (
        SELECT a."id",
               row_number() OVER (
                   PARTITION BY a."tenant_id", a."target_type_concept_id", a."target_id", a."owner_practitioner_id"
                   ORDER BY a."created_at" DESC, a."id" DESC) AS rn
          FROM "surveys"."survey_assignments" a
         WHERE a."active" = true
           AND a."owner_practitioner_id" IS NOT NULL
           AND a."target_type_concept_id" = '0a48774c-6a99-50f7-b485-71899fba56c5'
    )
    UPDATE "surveys"."survey_assignments" a
       SET "active" = false, "updated_at" = now(), "row_version" = a."row_version" + 1
      FROM ranked r
     WHERE r."id" = a."id" AND r.rn > 1;
    GET DIAGNOSTICS desactivadas = ROW_COUNT;
    RAISE NOTICE 'surveys.survey_assignments: % asignación(es) SERVICE duplicada(s) desactivada(s)', desactivadas;
END $$;

-- --------------------------------------------------- F. índices (copiado de 04_indexes.sql)
CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_templates_practitioner_catalog_code" ON "surveys"."survey_templates" ("tenant_id", "owner_practitioner_id", "standard_catalog_code") WHERE standard_catalog_code IS NOT NULL AND owner_practitioner_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_templates_party_catalog_code" ON "surveys"."survey_templates" ("tenant_id", "owner_type_concept_id", "owner_id", "standard_catalog_code") WHERE standard_catalog_code IS NOT NULL AND owner_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_assignments_active_service_owner" ON "surveys"."survey_assignments" ("tenant_id", "target_type_concept_id", "target_id", "owner_practitioner_id") WHERE active = true AND owner_practitioner_id IS NOT NULL AND target_type_concept_id = '0a48774c-6a99-50f7-b485-71899fba56c5';

CREATE INDEX IF NOT EXISTS "ix_survey_assignments_owner_practitioner_id" ON "surveys"."survey_assignments" ("owner_practitioner_id");

-- --------------------------------------------------- G. CHECK (copiado de 05_constraints.sql)
-- ═══ survey_templates ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_templates" DROP CONSTRAINT IF EXISTS "ck_survey_templates_standard_catalog_code";
ALTER TABLE "surveys"."survey_templates" ADD CONSTRAINT "ck_survey_templates_standard_catalog_code" CHECK ("standard_catalog_code" IS NULL OR "standard_catalog_code" ~ '^STD_[A-Z0-9_]+$');

COMMIT;
