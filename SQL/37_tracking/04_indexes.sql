-- SALUD v4.0.10 · módulo 37 · schema tracking
-- Generado de diagram_37_tracking.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_trackable_subjects_tracking_number" ON "tracking"."trackable_subjects" ("tracking_number");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_tenant_id" ON "tracking"."trackable_subjects" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_subject_type_concept_id" ON "tracking"."trackable_subjects" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_current_status_concept_id" ON "tracking"."trackable_subjects" ("current_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_current_milestone_id" ON "tracking"."trackable_subjects" ("current_milestone_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_priority_concept_id" ON "tracking"."trackable_subjects" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_state_concept_id" ON "tracking"."trackable_subjects" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_created_by_user_id" ON "tracking"."trackable_subjects" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_updated_by_user_id" ON "tracking"."trackable_subjects" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_trackable_subjects_tenant_id_state_concept_id" ON "tracking"."trackable_subjects" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_milestone_definitions_tenant_id" ON "tracking"."milestone_definitions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_milestone_definitions_subject_type_concept_id" ON "tracking"."milestone_definitions" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_milestone_definitions_milestone_status_concept_id" ON "tracking"."milestone_definitions" ("milestone_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_milestone_definitions_state_concept_id" ON "tracking"."milestone_definitions" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_milestone_definitions_created_by_user_id" ON "tracking"."milestone_definitions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_milestone_definitions_updated_by_user_id" ON "tracking"."milestone_definitions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_milestone_definitions_tenant_id_state_concept_id" ON "tracking"."milestone_definitions" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_tracking_events_trackable_subject_id" ON "tracking"."tracking_events" ("trackable_subject_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_events_milestone_definition_id" ON "tracking"."tracking_events" ("milestone_definition_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_events_status_concept_id" ON "tracking"."tracking_events" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_events_location_ping_id" ON "tracking"."tracking_events" ("location_ping_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_events_actor_user_id" ON "tracking"."tracking_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_events_source_concept_id" ON "tracking"."tracking_events" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_events_recorded_by_user_id" ON "tracking"."tracking_events" ("recorded_by_user_id");

-- OMITIDO "gist_tracking_events_location" (geography_point) gist: columna(s) ['geography_point'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "brin_tracking_events_recorded_at" ON "tracking"."tracking_events" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_tracking_carriers_code" ON "tracking"."tracking_carriers" ("code");

CREATE INDEX IF NOT EXISTS "ix_tracking_carriers_tenant_id" ON "tracking"."tracking_carriers" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_carriers_carrier_type_concept_id" ON "tracking"."tracking_carriers" ("carrier_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_carriers_external_provider_id" ON "tracking"."tracking_carriers" ("external_provider_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_carriers_state_concept_id" ON "tracking"."tracking_carriers" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_carriers_created_by_user_id" ON "tracking"."tracking_carriers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_carriers_updated_by_user_id" ON "tracking"."tracking_carriers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_tracking_carriers_tenant_id_state_concept_id" ON "tracking"."tracking_carriers" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_shipments_shipment_number" ON "tracking"."shipments" ("shipment_number");

CREATE INDEX IF NOT EXISTS "ix_shipments_trackable_subject_id" ON "tracking"."shipments" ("trackable_subject_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_carrier_id" ON "tracking"."shipments" ("carrier_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_tenant_id" ON "tracking"."shipments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_origin_address_id" ON "tracking"."shipments" ("origin_address_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_destination_address_id" ON "tracking"."shipments" ("destination_address_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_assigned_courier_user_id" ON "tracking"."shipments" ("assigned_courier_user_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_tracked_subject_id" ON "tracking"."shipments" ("tracked_subject_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_status_concept_id" ON "tracking"."shipments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_created_by_user_id" ON "tracking"."shipments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_updated_by_user_id" ON "tracking"."shipments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shipments_tenant_id_status_concept_id" ON "tracking"."shipments" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_shipment_handoffs_shipment_id" ON "tracking"."shipment_handoffs" ("shipment_id");

CREATE INDEX IF NOT EXISTS "ix_shipment_handoffs_handoff_type_concept_id" ON "tracking"."shipment_handoffs" ("handoff_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shipment_handoffs_recorded_by_user_id" ON "tracking"."shipment_handoffs" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_shipment_handoffs_recorded_at" ON "tracking"."shipment_handoffs" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_eta_estimates_trackable_subject_id" ON "tracking"."eta_estimates" ("trackable_subject_id");

CREATE INDEX IF NOT EXISTS "ix_eta_estimates_shipment_id" ON "tracking"."eta_estimates" ("shipment_id");

CREATE INDEX IF NOT EXISTS "ix_eta_estimates_method_concept_id" ON "tracking"."eta_estimates" ("method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_eta_estimates_recorded_by_user_id" ON "tracking"."eta_estimates" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_eta_estimates_recorded_at" ON "tracking"."eta_estimates" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_delivery_proofs_shipment_id" ON "tracking"."delivery_proofs" ("shipment_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_proofs_proof_type_concept_id" ON "tracking"."delivery_proofs" ("proof_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_proofs_signature_file_id" ON "tracking"."delivery_proofs" ("signature_file_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_proofs_photo_file_id" ON "tracking"."delivery_proofs" ("photo_file_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_proofs_status_concept_id" ON "tracking"."delivery_proofs" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_proofs_created_by_user_id" ON "tracking"."delivery_proofs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_delivery_proofs_updated_by_user_id" ON "tracking"."delivery_proofs" ("updated_by_user_id");

-- OMITIDO "gist_delivery_proofs_location" (geography_point) gist: columna(s) ['geography_point'] no existe(n) — requiere PostGIS/otro tipo.
