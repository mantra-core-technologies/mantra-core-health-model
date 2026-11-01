-- SALUD v4.2.83 · módulo 67 · schema data_catalog
-- Generado de diagram_67_data_catalog.puml — NO editar a mano.


-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_scan_runs"
        ADD CONSTRAINT "fk_catalog_scan_runs_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_scan_runs"
        ADD CONSTRAINT "fk_catalog_scan_runs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_scan_runs"
        ADD CONSTRAINT "fk_catalog_scan_runs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_objects"
        ADD CONSTRAINT "fk_catalog_objects_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_objects"
        ADD CONSTRAINT "fk_catalog_objects_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_objects"
        ADD CONSTRAINT "fk_catalog_objects_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_columns"
        ADD CONSTRAINT "fk_catalog_columns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_columns"
        ADD CONSTRAINT "fk_catalog_columns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_annotations"
        ADD CONSTRAINT "fk_catalog_annotations_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_annotations"
        ADD CONSTRAINT "fk_catalog_annotations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_annotations"
        ADD CONSTRAINT "fk_catalog_annotations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_annotation_revisions"
        ADD CONSTRAINT "fk_catalog_annotation_revisions_author_user_id" FOREIGN KEY ("author_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_review_decisions"
        ADD CONSTRAINT "fk_catalog_review_decisions_reviewer_user_id" FOREIGN KEY ("reviewer_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_evidence_items"
        ADD CONSTRAINT "fk_catalog_evidence_items_added_by_user_id" FOREIGN KEY ("added_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_operations"
        ADD CONSTRAINT "fk_catalog_operations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_operations"
        ADD CONSTRAINT "fk_catalog_operations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_operation_impacts"
        ADD CONSTRAINT "fk_catalog_operation_impacts_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_operation_impacts"
        ADD CONSTRAINT "fk_catalog_operation_impacts_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_processes"
        ADD CONSTRAINT "fk_catalog_processes_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_processes"
        ADD CONSTRAINT "fk_catalog_processes_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_process_steps"
        ADD CONSTRAINT "fk_catalog_process_steps_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_process_steps"
        ADD CONSTRAINT "fk_catalog_process_steps_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_process_step_operations"
        ADD CONSTRAINT "fk_catalog_process_step_operations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_process_step_operations"
        ADD CONSTRAINT "fk_catalog_process_step_operations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_stewardships"
        ADD CONSTRAINT "fk_catalog_stewardships_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_terms"
        ADD CONSTRAINT "fk_catalog_glossary_terms_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_revisions"
        ADD CONSTRAINT "fk_catalog_glossary_term_revisions_author_user_id" FOREIGN KEY ("author_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_glossary_term_links"
        ADD CONSTRAINT "fk_catalog_glossary_term_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rules"
        ADD CONSTRAINT "fk_quality_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_rule_runs"
        ADD CONSTRAINT "fk_quality_rule_runs_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_acknowledged_by_user_id" FOREIGN KEY ("acknowledged_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issues"
        ADD CONSTRAINT "fk_quality_issues_resolved_by_user_id" FOREIGN KEY ("resolved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_issue_events"
        ADD CONSTRAINT "fk_quality_issue_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: system_ops.data_domains (requiere schema system_ops)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."quality_score_snapshots"
        ADD CONSTRAINT "fk_quality_score_snapshots_domain_id" FOREIGN KEY ("domain_id")
        REFERENCES "system_ops"."data_domains" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_lineage_edges"
        ADD CONSTRAINT "fk_catalog_lineage_edges_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_lineage_edges"
        ADD CONSTRAINT "fk_catalog_lineage_edges_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_lineage_edges"
        ADD CONSTRAINT "fk_catalog_lineage_edges_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: read_models.read_model_definitions (requiere schema read_models)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_read_model_definition_id" FOREIGN KEY ("read_model_definition_id")
        REFERENCES "read_models"."read_model_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: reporting.report_definitions (requiere schema reporting)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_report_definition_id" FOREIGN KEY ("report_definition_id")
        REFERENCES "reporting"."report_definitions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_requested_by_user_id" FOREIGN KEY ("requested_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_certified_by_user_id" FOREIGN KEY ("certified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_certifications"
        ADD CONSTRAINT "fk_catalog_certifications_revoked_by_user_id" FOREIGN KEY ("revoked_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "data_catalog"."catalog_change_acknowledgements"
        ADD CONSTRAINT "fk_catalog_change_acknowledgements_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
