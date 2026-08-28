-- SALUD v4.0.10 · módulo 02 · schema common
-- Generado de diagram_02_common.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "common"."files"
        ADD CONSTRAINT "fk_files_current_version_id" FOREIGN KEY ("current_version_id")
        REFERENCES "common"."file_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "common"."file_versions"
        ADD CONSTRAINT "fk_file_versions_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "common"."file_links"
        ADD CONSTRAINT "fk_file_links_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "common"."file_derivatives"
        ADD CONSTRAINT "fk_file_derivatives_source_file_version_id" FOREIGN KEY ("source_file_version_id")
        REFERENCES "common"."file_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "common"."file_derivatives"
        ADD CONSTRAINT "fk_file_derivatives_derivative_file_version_id" FOREIGN KEY ("derivative_file_version_id")
        REFERENCES "common"."file_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
