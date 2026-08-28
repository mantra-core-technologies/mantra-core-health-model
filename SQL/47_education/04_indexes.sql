-- SALUD v4.0.10 · módulo 47 · schema education
-- Generado de diagram_47_education.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_courses_code" ON "education"."courses" ("code");

CREATE INDEX IF NOT EXISTS "ix_courses_tenant_id" ON "education"."courses" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_courses_course_type_concept_id" ON "education"."courses" ("course_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_specialty_concept_id" ON "education"."courses" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_level_concept_id" ON "education"."courses" ("level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_language_concept_id" ON "education"."courses" ("language_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_cover_file_id" ON "education"."courses" ("cover_file_id");

CREATE INDEX IF NOT EXISTS "ix_courses_accrediting_body_concept_id" ON "education"."courses" ("accrediting_body_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_currency_concept_id" ON "education"."courses" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_status_concept_id" ON "education"."courses" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_courses_created_by_user_id" ON "education"."courses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_courses_updated_by_user_id" ON "education"."courses" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_courses_tenant_id_status_concept_id" ON "education"."courses" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_courses_search" ON "education"."courses" USING gin (to_tsvector('simple', (coalesce(title, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_course_versions_course_id" ON "education"."course_versions" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_course_versions_status_concept_id" ON "education"."course_versions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_course_versions_created_by_user_id" ON "education"."course_versions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_versions_updated_by_user_id" ON "education"."course_versions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_course_versions_course_id_version" ON "education"."course_versions" ("course_id", "version");

CREATE INDEX IF NOT EXISTS "ix_course_modules_course_id" ON "education"."course_modules" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_course_modules_status_concept_id" ON "education"."course_modules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_course_modules_created_by_user_id" ON "education"."course_modules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_modules_updated_by_user_id" ON "education"."course_modules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_course_modules_search" ON "education"."course_modules" USING gin (to_tsvector('simple', (coalesce(title, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_lessons_course_module_id" ON "education"."lessons" ("course_module_id");

CREATE INDEX IF NOT EXISTS "ix_lessons_content_type_concept_id" ON "education"."lessons" ("content_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lessons_media_file_id" ON "education"."lessons" ("media_file_id");

CREATE INDEX IF NOT EXISTS "ix_lessons_status_concept_id" ON "education"."lessons" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lessons_created_by_user_id" ON "education"."lessons" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lessons_updated_by_user_id" ON "education"."lessons" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_lessons_search" ON "education"."lessons" USING gin (to_tsvector('simple', (coalesce(title, ''))));

CREATE INDEX IF NOT EXISTS "ix_instructors_tenant_id" ON "education"."instructors" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_instructors_practitioner_profile_id" ON "education"."instructors" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_instructors_user_id" ON "education"."instructors" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_instructors_photo_file_id" ON "education"."instructors" ("photo_file_id");

CREATE INDEX IF NOT EXISTS "ix_instructors_status_concept_id" ON "education"."instructors" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_instructors_created_by_user_id" ON "education"."instructors" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_instructors_updated_by_user_id" ON "education"."instructors" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_instructors_tenant_id_status_concept_id" ON "education"."instructors" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_instructors_search" ON "education"."instructors" USING gin (to_tsvector('simple', (coalesce(display_name, ''))));

CREATE INDEX IF NOT EXISTS "ix_course_instructors_course_id" ON "education"."course_instructors" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_course_instructors_instructor_id" ON "education"."course_instructors" ("instructor_id");

CREATE INDEX IF NOT EXISTS "ix_course_instructors_role_concept_id" ON "education"."course_instructors" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_course_instructors_created_by_user_id" ON "education"."course_instructors" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_instructors_updated_by_user_id" ON "education"."course_instructors" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_cohorts_course_id" ON "education"."course_cohorts" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_course_cohorts_delivery_mode_concept_id" ON "education"."course_cohorts" ("delivery_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_course_cohorts_status_concept_id" ON "education"."course_cohorts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_course_cohorts_created_by_user_id" ON "education"."course_cohorts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_cohorts_updated_by_user_id" ON "education"."course_cohorts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_course_cohorts_search" ON "education"."course_cohorts" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_enrollments_course_id" ON "education"."enrollments" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_cohort_id" ON "education"."enrollments" ("cohort_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_learner_type_concept_id" ON "education"."enrollments" ("learner_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_enrollment_source_concept_id" ON "education"."enrollments" ("enrollment_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_payment_intent_id" ON "education"."enrollments" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_status_concept_id" ON "education"."enrollments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_created_by_user_id" ON "education"."enrollments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_enrollments_updated_by_user_id" ON "education"."enrollments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lesson_progress_enrollment_id" ON "education"."lesson_progress" ("enrollment_id");

CREATE INDEX IF NOT EXISTS "ix_lesson_progress_lesson_id" ON "education"."lesson_progress" ("lesson_id");

CREATE INDEX IF NOT EXISTS "ix_lesson_progress_status_concept_id" ON "education"."lesson_progress" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lesson_progress_recorded_by_user_id" ON "education"."lesson_progress" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_lesson_progress_recorded_at" ON "education"."lesson_progress" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_assessments_course_id" ON "education"."assessments" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_assessments_course_module_id" ON "education"."assessments" ("course_module_id");

CREATE INDEX IF NOT EXISTS "ix_assessments_assessment_type_concept_id" ON "education"."assessments" ("assessment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessments_status_concept_id" ON "education"."assessments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessments_created_by_user_id" ON "education"."assessments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessments_updated_by_user_id" ON "education"."assessments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_assessments_search" ON "education"."assessments" USING gin (to_tsvector('simple', (coalesce(title, ''))));

CREATE INDEX IF NOT EXISTS "ix_assessment_questions_assessment_id" ON "education"."assessment_questions" ("assessment_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_questions_question_type_concept_id" ON "education"."assessment_questions" ("question_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_questions_created_by_user_id" ON "education"."assessment_questions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_questions_updated_by_user_id" ON "education"."assessment_questions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_attempts_assessment_id" ON "education"."assessment_attempts" ("assessment_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_attempts_enrollment_id" ON "education"."assessment_attempts" ("enrollment_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_attempts_graded_by_user_id" ON "education"."assessment_attempts" ("graded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_attempts_status_concept_id" ON "education"."assessment_attempts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_attempts_created_by_user_id" ON "education"."assessment_attempts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_assessment_attempts_updated_by_user_id" ON "education"."assessment_attempts" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_assessment_attempts_assessment_id_attempt_number" ON "education"."assessment_attempts" ("assessment_id", "attempt_number");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_certificates_certificate_number" ON "education"."certificates" ("certificate_number");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_certificates_verification_code" ON "education"."certificates" ("verification_code");

CREATE INDEX IF NOT EXISTS "ix_certificates_enrollment_id" ON "education"."certificates" ("enrollment_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_course_id" ON "education"."certificates" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_file_id" ON "education"."certificates" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_status_concept_id" ON "education"."certificates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_created_by_user_id" ON "education"."certificates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_certificates_updated_by_user_id" ON "education"."certificates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_practitioner_profile_id" ON "education"."cme_credit_records" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_certificate_id" ON "education"."cme_credit_records" ("certificate_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_accrediting_body_concept_id" ON "education"."cme_credit_records" ("accrediting_body_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_specialty_concept_id" ON "education"."cme_credit_records" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_jurisdiction_concept_id" ON "education"."cme_credit_records" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_status_concept_id" ON "education"."cme_credit_records" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_created_by_user_id" ON "education"."cme_credit_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cme_credit_records_updated_by_user_id" ON "education"."cme_credit_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_reviews_course_id" ON "education"."course_reviews" ("course_id");

CREATE INDEX IF NOT EXISTS "ix_course_reviews_status_concept_id" ON "education"."course_reviews" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_course_reviews_created_by_user_id" ON "education"."course_reviews" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_course_reviews_updated_by_user_id" ON "education"."course_reviews" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_course_reviews_search" ON "education"."course_reviews" USING gin (to_tsvector('simple', (coalesce(review_text, ''))));
