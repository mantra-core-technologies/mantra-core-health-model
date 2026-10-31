-- SALUD v4.2.81 · módulo 70 · schema observability
-- Generado de diagram_70_observability.puml — NO editar a mano.


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_assigned_to_user_id" FOREIGN KEY ("assigned_to_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_resolved_by_user_id" FOREIGN KEY ("resolved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."error_groups"
        ADD CONSTRAINT "fk_error_groups_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: platform_ops.service_components (requiere schema platform_ops)
DO $$ BEGIN
    ALTER TABLE "observability"."dependency_probe_runs"
        ADD CONSTRAINT "fk_dependency_probe_runs_service_component_id" FOREIGN KEY ("service_component_id")
        REFERENCES "platform_ops"."service_components" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_rules"
        ADD CONSTRAINT "fk_alert_rules_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_rules"
        ADD CONSTRAINT "fk_alert_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_rules"
        ADD CONSTRAINT "fk_alert_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: platform_ops.health_incidents (requiere schema platform_ops)
DO $$ BEGIN
    ALTER TABLE "observability"."alert_evaluations"
        ADD CONSTRAINT "fk_alert_evaluations_health_incident_id" FOREIGN KEY ("health_incident_id")
        REFERENCES "platform_ops"."health_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
