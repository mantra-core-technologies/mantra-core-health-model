-- SALUD v4.0.10 · módulo 15 · schema chart
-- Generado de diagram_15_chart.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "chart"."clinical_note_headers"
        ADD CONSTRAINT "fk_clinical_note_headers_current_version_id" FOREIGN KEY ("current_version_id")
        REFERENCES "chart"."clinical_note_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."clinical_note_headers"
        ADD CONSTRAINT "fk_clinical_note_headers_current_released_version_id" FOREIGN KEY ("current_released_version_id")
        REFERENCES "chart"."clinical_note_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."clinical_note_versions"
        ADD CONSTRAINT "fk_clinical_note_versions_clinical_note_id" FOREIGN KEY ("clinical_note_id")
        REFERENCES "chart"."clinical_note_headers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."clinical_note_versions"
        ADD CONSTRAINT "fk_clinical_note_versions_supersedes_version_id" FOREIGN KEY ("supersedes_version_id")
        REFERENCES "chart"."clinical_note_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."clinical_note_signatures"
        ADD CONSTRAINT "fk_clinical_note_signatures_clinical_note_version_id" FOREIGN KEY ("clinical_note_version_id")
        REFERENCES "chart"."clinical_note_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."note_release_events"
        ADD CONSTRAINT "fk_note_release_events_clinical_note_version_id" FOREIGN KEY ("clinical_note_version_id")
        REFERENCES "chart"."clinical_note_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."physical_exam_findings"
        ADD CONSTRAINT "fk_physical_exam_findings_clinical_note_version_id" FOREIGN KEY ("clinical_note_version_id")
        REFERENCES "chart"."clinical_note_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."care_plan_activities"
        ADD CONSTRAINT "fk_care_plan_activities_care_plan_id" FOREIGN KEY ("care_plan_id")
        REFERENCES "chart"."care_plans" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."document_record_files"
        ADD CONSTRAINT "fk_document_record_files_document_record_id" FOREIGN KEY ("document_record_id")
        REFERENCES "chart"."document_records" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "chart"."chart_template_assignments"
        ADD CONSTRAINT "fk_chart_template_assignments_template_id" FOREIGN KEY ("template_id")
        REFERENCES "chart"."specialty_chart_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
