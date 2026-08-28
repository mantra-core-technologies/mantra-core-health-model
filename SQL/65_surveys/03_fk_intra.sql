-- SALUD v4.0.10 · módulo 65 · schema surveys
-- Generado de diagram_65_surveys.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "surveys"."survey_versions"
        ADD CONSTRAINT "fk_survey_versions_survey_template_id" FOREIGN KEY ("survey_template_id")
        REFERENCES "surveys"."survey_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_questions"
        ADD CONSTRAINT "fk_survey_questions_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_assignments"
        ADD CONSTRAINT "fk_survey_assignments_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_invitations"
        ADD CONSTRAINT "fk_survey_invitations_survey_assignment_id" FOREIGN KEY ("survey_assignment_id")
        REFERENCES "surveys"."survey_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_survey_invitation_id" FOREIGN KEY ("survey_invitation_id")
        REFERENCES "surveys"."survey_invitations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_responses"
        ADD CONSTRAINT "fk_survey_responses_survey_version_id" FOREIGN KEY ("survey_version_id")
        REFERENCES "surveys"."survey_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_answers"
        ADD CONSTRAINT "fk_survey_answers_survey_response_id" FOREIGN KEY ("survey_response_id")
        REFERENCES "surveys"."survey_responses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "surveys"."survey_answers"
        ADD CONSTRAINT "fk_survey_answers_survey_question_id" FOREIGN KEY ("survey_question_id")
        REFERENCES "surveys"."survey_questions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)
