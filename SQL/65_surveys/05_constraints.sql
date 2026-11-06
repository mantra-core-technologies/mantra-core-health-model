-- SALUD v4.2.94 · schema surveys · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL, EXCLUDE_SQL y TRIGGER_SQL sí se materializan con el SQL del modelo.


-- ═══ survey_templates ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_templates" DROP CONSTRAINT IF EXISTS "ck_survey_templates_single_owner";
ALTER TABLE "surveys"."survey_templates" ADD CONSTRAINT "ck_survey_templates_single_owner" CHECK (("owner_practitioner_id" IS NOT NULL AND "owner_type_concept_id" IS NULL AND "owner_id" IS NULL) OR ("owner_practitioner_id" IS NULL AND "owner_type_concept_id" IS NOT NULL AND "owner_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_templates" DROP CONSTRAINT IF EXISTS "ck_survey_templates_standard_catalog_code";
ALTER TABLE "surveys"."survey_templates" ADD CONSTRAINT "ck_survey_templates_standard_catalog_code" CHECK ("standard_catalog_code" IS NULL OR "standard_catalog_code" ~ '^STD_[A-Z0-9_]+$');


-- ═══ survey_versions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_versions" DROP CONSTRAINT IF EXISTS "ck_survey_versions_max_reminders";
ALTER TABLE "surveys"."survey_versions" ADD CONSTRAINT "ck_survey_versions_max_reminders" CHECK (("max_reminders" IS NULL OR "max_reminders" >= 0));


-- ═══ survey_invitations ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_invitations" DROP CONSTRAINT IF EXISTS "ck_survey_invitations_anchor";
ALTER TABLE "surveys"."survey_invitations" ADD CONSTRAINT "ck_survey_invitations_anchor" CHECK (("appointment_booking_id" IS NOT NULL OR "subject_id" IS NOT NULL) AND (("subject_type_concept_id" IS NULL) = ("subject_id" IS NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_invitations" DROP CONSTRAINT IF EXISTS "ck_survey_invitations_extension_distinct";
ALTER TABLE "surveys"."survey_invitations" ADD CONSTRAINT "ck_survey_invitations_extension_distinct" CHECK ("extension_survey_version_id" IS NULL OR "extension_survey_version_id" <> "survey_version_id");


-- ═══ survey_invitation_reminders ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_invitation_reminders" DROP CONSTRAINT IF EXISTS "ck_survey_invitation_reminders_number";
ALTER TABLE "surveys"."survey_invitation_reminders" ADD CONSTRAINT "ck_survey_invitation_reminders_number" CHECK ("reminder_number" >= 1);


-- ═══ survey_answers ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_answers" DROP CONSTRAINT IF EXISTS "ck_survey_answers_single_value";
ALTER TABLE "surveys"."survey_answers" ADD CONSTRAINT "ck_survey_answers_single_value" CHECK (num_nonnulls("value_text", "value_number", "value_boolean", "value_choices") = 1);


-- ═══ survey_assignments ═══
-- Disparador concreto declarado por el modelo (TRIGGER_SQL + FUNCTION_SQL_).
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
