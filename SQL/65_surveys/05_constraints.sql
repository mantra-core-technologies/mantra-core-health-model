-- SALUD v4.2.83 · schema surveys · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ survey_templates ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "surveys"."survey_templates" DROP CONSTRAINT IF EXISTS "ck_survey_templates_single_owner";
ALTER TABLE "surveys"."survey_templates" ADD CONSTRAINT "ck_survey_templates_single_owner" CHECK (("owner_practitioner_id" IS NOT NULL AND "owner_type_concept_id" IS NULL AND "owner_id" IS NULL) OR ("owner_practitioner_id" IS NULL AND "owner_type_concept_id" IS NOT NULL AND "owner_id" IS NOT NULL));


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
