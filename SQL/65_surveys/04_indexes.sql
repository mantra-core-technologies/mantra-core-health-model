-- SALUD v4.0.10 · módulo 65 · schema surveys
-- Generado de diagram_65_surveys.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_survey_templates_owner" ON "surveys"."survey_templates" ("owner_practitioner_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_survey_templates_tenant_id" ON "surveys"."survey_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_survey_templates_owner_party" ON "surveys"."survey_templates" ("owner_type_concept_id", "owner_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_versions_template_number" ON "surveys"."survey_versions" ("survey_template_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_survey_questions_version_position" ON "surveys"."survey_questions" ("survey_version_id", "position");

CREATE INDEX IF NOT EXISTS "ix_survey_assignments_tenant_target" ON "surveys"."survey_assignments" ("tenant_id", "target_id", "active");

CREATE INDEX IF NOT EXISTS "ix_survey_assignments_version" ON "surveys"."survey_assignments" ("survey_version_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_assignments_active_target" ON "surveys"."survey_assignments" ("survey_version_id", "target_type_concept_id", "target_id") WHERE active = true;

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_patient_issued" ON "surveys"."survey_invitations" ("patient_profile_id", "issued_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_booking" ON "surveys"."survey_invitations" ("appointment_booking_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_version" ON "surveys"."survey_invitations" ("survey_version_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_assignment" ON "surveys"."survey_invitations" ("survey_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_tenant_id" ON "surveys"."survey_invitations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitations_subject" ON "surveys"."survey_invitations" ("subject_type_concept_id", "subject_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_invitations_booking_version" ON "surveys"."survey_invitations" ("appointment_booking_id", "survey_version_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_invitation_reminders_number" ON "surveys"."survey_invitation_reminders" ("survey_invitation_id", "reminder_number");

CREATE INDEX IF NOT EXISTS "ix_survey_invitation_reminders_channel_concept_id" ON "surveys"."survey_invitation_reminders" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_survey_invitation_reminders_created_by_user_id" ON "surveys"."survey_invitation_reminders" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_responses_invitation" ON "surveys"."survey_responses" ("survey_invitation_id");

CREATE INDEX IF NOT EXISTS "ix_survey_responses_patient_submitted" ON "surveys"."survey_responses" ("patient_profile_id", "submitted_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_survey_responses_version" ON "surveys"."survey_responses" ("survey_version_id");

CREATE INDEX IF NOT EXISTS "ix_survey_responses_tenant_id" ON "surveys"."survey_responses" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_survey_answers_response" ON "surveys"."survey_answers" ("survey_response_id");

CREATE INDEX IF NOT EXISTS "ix_survey_answers_question" ON "surveys"."survey_answers" ("survey_question_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_survey_answers_response_question" ON "surveys"."survey_answers" ("survey_response_id", "survey_question_id");
