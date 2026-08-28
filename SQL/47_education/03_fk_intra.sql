-- SALUD v4.0.10 · módulo 47 · schema education
-- Generado de diagram_47_education.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "education"."course_versions"
        ADD CONSTRAINT "fk_course_versions_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."course_modules"
        ADD CONSTRAINT "fk_course_modules_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."lessons"
        ADD CONSTRAINT "fk_lessons_course_module_id" FOREIGN KEY ("course_module_id")
        REFERENCES "education"."course_modules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."course_instructors"
        ADD CONSTRAINT "fk_course_instructors_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."course_instructors"
        ADD CONSTRAINT "fk_course_instructors_instructor_id" FOREIGN KEY ("instructor_id")
        REFERENCES "education"."instructors" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."course_cohorts"
        ADD CONSTRAINT "fk_course_cohorts_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."enrollments"
        ADD CONSTRAINT "fk_enrollments_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."enrollments"
        ADD CONSTRAINT "fk_enrollments_cohort_id" FOREIGN KEY ("cohort_id")
        REFERENCES "education"."course_cohorts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."lesson_progress"
        ADD CONSTRAINT "fk_lesson_progress_enrollment_id" FOREIGN KEY ("enrollment_id")
        REFERENCES "education"."enrollments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."lesson_progress"
        ADD CONSTRAINT "fk_lesson_progress_lesson_id" FOREIGN KEY ("lesson_id")
        REFERENCES "education"."lessons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."assessments"
        ADD CONSTRAINT "fk_assessments_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."assessments"
        ADD CONSTRAINT "fk_assessments_course_module_id" FOREIGN KEY ("course_module_id")
        REFERENCES "education"."course_modules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."assessment_questions"
        ADD CONSTRAINT "fk_assessment_questions_assessment_id" FOREIGN KEY ("assessment_id")
        REFERENCES "education"."assessments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."assessment_attempts"
        ADD CONSTRAINT "fk_assessment_attempts_assessment_id" FOREIGN KEY ("assessment_id")
        REFERENCES "education"."assessments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."assessment_attempts"
        ADD CONSTRAINT "fk_assessment_attempts_enrollment_id" FOREIGN KEY ("enrollment_id")
        REFERENCES "education"."enrollments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."certificates"
        ADD CONSTRAINT "fk_certificates_enrollment_id" FOREIGN KEY ("enrollment_id")
        REFERENCES "education"."enrollments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."certificates"
        ADD CONSTRAINT "fk_certificates_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."cme_credit_records"
        ADD CONSTRAINT "fk_cme_credit_records_certificate_id" FOREIGN KEY ("certificate_id")
        REFERENCES "education"."certificates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "education"."course_reviews"
        ADD CONSTRAINT "fk_course_reviews_course_id" FOREIGN KEY ("course_id")
        REFERENCES "education"."courses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
