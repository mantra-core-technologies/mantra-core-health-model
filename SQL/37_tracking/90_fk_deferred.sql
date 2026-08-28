-- SALUD v4.0.10 · módulo 37 · schema tracking
-- Generado de diagram_37_tracking.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "tracking"."trackable_subjects"
        ADD CONSTRAINT "fk_trackable_subjects_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."trackable_subjects"
        ADD CONSTRAINT "fk_trackable_subjects_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."trackable_subjects"
        ADD CONSTRAINT "fk_trackable_subjects_current_status_concept_id" FOREIGN KEY ("current_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."trackable_subjects"
        ADD CONSTRAINT "fk_trackable_subjects_priority_concept_id" FOREIGN KEY ("priority_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."trackable_subjects"
        ADD CONSTRAINT "fk_trackable_subjects_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."trackable_subjects"
        ADD CONSTRAINT "fk_trackable_subjects_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."trackable_subjects"
        ADD CONSTRAINT "fk_trackable_subjects_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "tracking"."milestone_definitions"
        ADD CONSTRAINT "fk_milestone_definitions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."milestone_definitions"
        ADD CONSTRAINT "fk_milestone_definitions_subject_type_concept_id" FOREIGN KEY ("subject_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."milestone_definitions"
        ADD CONSTRAINT "fk_milestone_definitions_milestone_status_concept_id" FOREIGN KEY ("milestone_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."milestone_definitions"
        ADD CONSTRAINT "fk_milestone_definitions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."milestone_definitions"
        ADD CONSTRAINT "fk_milestone_definitions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."milestone_definitions"
        ADD CONSTRAINT "fk_milestone_definitions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_events"
        ADD CONSTRAINT "fk_tracking_events_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: geo.location_pings (requiere schema geo)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_events"
        ADD CONSTRAINT "fk_tracking_events_location_ping_id" FOREIGN KEY ("location_ping_id")
        REFERENCES "geo"."location_pings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_events"
        ADD CONSTRAINT "fk_tracking_events_actor_user_id" FOREIGN KEY ("actor_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_events"
        ADD CONSTRAINT "fk_tracking_events_source_concept_id" FOREIGN KEY ("source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_events"
        ADD CONSTRAINT "fk_tracking_events_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_carriers"
        ADD CONSTRAINT "fk_tracking_carriers_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_carriers"
        ADD CONSTRAINT "fk_tracking_carriers_carrier_type_concept_id" FOREIGN KEY ("carrier_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: integrations.external_providers (requiere schema integrations)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_carriers"
        ADD CONSTRAINT "fk_tracking_carriers_external_provider_id" FOREIGN KEY ("external_provider_id")
        REFERENCES "integrations"."external_providers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_carriers"
        ADD CONSTRAINT "fk_tracking_carriers_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_carriers"
        ADD CONSTRAINT "fk_tracking_carriers_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."tracking_carriers"
        ADD CONSTRAINT "fk_tracking_carriers_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.addresses (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_origin_address_id" FOREIGN KEY ("origin_address_id")
        REFERENCES "common"."addresses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.addresses (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_destination_address_id" FOREIGN KEY ("destination_address_id")
        REFERENCES "common"."addresses" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_assigned_courier_user_id" FOREIGN KEY ("assigned_courier_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: geo.tracked_subjects (requiere schema geo)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_tracked_subject_id" FOREIGN KEY ("tracked_subject_id")
        REFERENCES "geo"."tracked_subjects" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipments"
        ADD CONSTRAINT "fk_shipments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipment_handoffs"
        ADD CONSTRAINT "fk_shipment_handoffs_handoff_type_concept_id" FOREIGN KEY ("handoff_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."shipment_handoffs"
        ADD CONSTRAINT "fk_shipment_handoffs_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."eta_estimates"
        ADD CONSTRAINT "fk_eta_estimates_method_concept_id" FOREIGN KEY ("method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."eta_estimates"
        ADD CONSTRAINT "fk_eta_estimates_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."delivery_proofs"
        ADD CONSTRAINT "fk_delivery_proofs_proof_type_concept_id" FOREIGN KEY ("proof_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "tracking"."delivery_proofs"
        ADD CONSTRAINT "fk_delivery_proofs_signature_file_id" FOREIGN KEY ("signature_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: common.files (requiere schema common)
DO $$ BEGIN
    ALTER TABLE "tracking"."delivery_proofs"
        ADD CONSTRAINT "fk_delivery_proofs_photo_file_id" FOREIGN KEY ("photo_file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "tracking"."delivery_proofs"
        ADD CONSTRAINT "fk_delivery_proofs_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."delivery_proofs"
        ADD CONSTRAINT "fk_delivery_proofs_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "tracking"."delivery_proofs"
        ADD CONSTRAINT "fk_delivery_proofs_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
