-- SALUD v4.2.80 · módulo 23 · schema diagnostic_units
-- Generado de diagram_23_diagnostic_units.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_diagnostic_units_tenant_id_code" ON "diagnostic_units"."diagnostic_units" ("tenant_id", "code");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_tenant_id" ON "diagnostic_units"."diagnostic_units" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_practice_id" ON "diagnostic_units"."diagnostic_units" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_primary_practice_site_id" ON "diagnostic_units"."diagnostic_units" ("primary_practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_diagnostic_unit_type_concept_id" ON "diagnostic_units"."diagnostic_units" ("diagnostic_unit_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_ownership_type_concept_id" ON "diagnostic_units"."diagnostic_units" ("ownership_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_public_profile_id" ON "diagnostic_units"."diagnostic_units" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_verification_status_concept_id" ON "diagnostic_units"."diagnostic_units" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_status_concept_id" ON "diagnostic_units"."diagnostic_units" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_created_by_user_id" ON "diagnostic_units"."diagnostic_units" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_updated_by_user_id" ON "diagnostic_units"."diagnostic_units" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_units_tenant_id_status_concept_id" ON "diagnostic_units"."diagnostic_units" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_diagnostic_units_search" ON "diagnostic_units"."diagnostic_units" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_sites_diagnostic_unit_id" ON "diagnostic_units"."diagnostic_unit_sites" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_sites_practice_site_id" ON "diagnostic_units"."diagnostic_unit_sites" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_sites_site_role_concept_id" ON "diagnostic_units"."diagnostic_unit_sites" ("site_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_sites_status_concept_id" ON "diagnostic_units"."diagnostic_unit_sites" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_sites_created_by_user_id" ON "diagnostic_units"."diagnostic_unit_sites" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_sites_updated_by_user_id" ON "diagnostic_units"."diagnostic_unit_sites" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_specialties_diagnostic_unit_id" ON "diagnostic_units"."diagnostic_unit_specialties" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_specialties_specialty_concept_id" ON "diagnostic_units"."diagnostic_unit_specialties" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_specialties_verification_status_concept_id" ON "diagnostic_units"."diagnostic_unit_specialties" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_specialties_created_by_user_id" ON "diagnostic_units"."diagnostic_unit_specialties" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_specialties_updated_by_user_id" ON "diagnostic_units"."diagnostic_unit_specialties" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_diagnostic_unit_id" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_practition_04f3585e" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_diagnostic_cf1d7558" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("diagnostic_unit_site_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_specialty__966d7ef4" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_assignment_7bb2e764" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("assignment_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_status_concept_id" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_created_by_user_id" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_practitioner_assignments_updated_by_user_id" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_diagnostic_unit_practitioner_assignments_effective_period" ON "diagnostic_units"."diagnostic_unit_practitioner_assignments" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_diagnostic_unit_id" ON "diagnostic_units"."diagnostic_study_offerings" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_diagnostic_unit_site_id" ON "diagnostic_units"."diagnostic_study_offerings" ("diagnostic_unit_site_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_study_concept_id" ON "diagnostic_units"."diagnostic_study_offerings" ("study_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_modality_concept_id" ON "diagnostic_units"."diagnostic_study_offerings" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_body_site_concept_id" ON "diagnostic_units"."diagnostic_study_offerings" ("body_site_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_specimen_type_concept_id" ON "diagnostic_units"."diagnostic_study_offerings" ("specimen_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_status_concept_id" ON "diagnostic_units"."diagnostic_study_offerings" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_created_by_user_id" ON "diagnostic_units"."diagnostic_study_offerings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_offerings_updated_by_user_id" ON "diagnostic_units"."diagnostic_study_offerings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_diagnostic_study_offerings_search" ON "diagnostic_units"."diagnostic_study_offerings" USING gin (to_tsvector('simple', (coalesce(display_name, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_components_parent_offering_id" ON "diagnostic_units"."diagnostic_study_components" ("parent_offering_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_components_component_offering_id" ON "diagnostic_units"."diagnostic_study_components" ("component_offering_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_components_component_role_concept_id" ON "diagnostic_units"."diagnostic_study_components" ("component_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_components_created_by_user_id" ON "diagnostic_units"."diagnostic_study_components" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_diagnostic_unit_id" ON "diagnostic_units"."diagnostic_price_schedules" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_diagnostic_unit_site_id" ON "diagnostic_units"."diagnostic_price_schedules" ("diagnostic_unit_site_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_price_schedule_type_concept_id" ON "diagnostic_units"."diagnostic_price_schedules" ("price_schedule_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_insurer_tenant_id" ON "diagnostic_units"."diagnostic_price_schedules" ("insurer_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_broker_tenant_id" ON "diagnostic_units"."diagnostic_price_schedules" ("broker_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_currency_concept_id" ON "diagnostic_units"."diagnostic_price_schedules" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_status_concept_id" ON "diagnostic_units"."diagnostic_price_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_created_by_user_id" ON "diagnostic_units"."diagnostic_price_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_price_schedules_updated_by_user_id" ON "diagnostic_units"."diagnostic_price_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_diagnostic_price_schedules_search" ON "diagnostic_units"."diagnostic_price_schedules" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "gist_diagnostic_price_schedules_effective_period" ON "diagnostic_units"."diagnostic_price_schedules" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_price_schedule_id" ON "diagnostic_units"."diagnostic_study_prices" ("price_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_diagnostic_study_offering_id" ON "diagnostic_units"."diagnostic_study_prices" ("diagnostic_study_offering_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_status_concept_id" ON "diagnostic_units"."diagnostic_study_prices" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_study_prices_recorded_by_user_id" ON "diagnostic_units"."diagnostic_study_prices" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_diagnostic_study_prices_price_schedule_id_version_number" ON "diagnostic_units"."diagnostic_study_prices" ("price_schedule_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_diagnostic_unit_site_id" ON "diagnostic_units"."diagnostic_equipment" ("diagnostic_unit_site_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_equipment_type_concept_id" ON "diagnostic_units"."diagnostic_equipment" ("equipment_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_modality_concept_id" ON "diagnostic_units"."diagnostic_equipment" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_operational_status_concept_id" ON "diagnostic_units"."diagnostic_equipment" ("operational_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_created_by_user_id" ON "diagnostic_units"."diagnostic_equipment" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_updated_by_user_id" ON "diagnostic_units"."diagnostic_equipment" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_care_space_id" ON "diagnostic_units"."diagnostic_equipment" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_equipment_schedulable_resource_id" ON "diagnostic_units"."diagnostic_equipment" ("schedulable_resource_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_diagnostic_equipment_site_ae_title" ON "diagnostic_units"."diagnostic_equipment" ("diagnostic_unit_site_id", "ae_title") WHERE ae_title IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_diagnostic_unit_id" ON "diagnostic_units"."diagnostic_unit_accreditations" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_diagnostic_unit_site_id" ON "diagnostic_units"."diagnostic_unit_accreditations" ("diagnostic_unit_site_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_accreditation_concept_id" ON "diagnostic_units"."diagnostic_unit_accreditations" ("accreditation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_issuer_tenant_id" ON "diagnostic_units"."diagnostic_unit_accreditations" ("issuer_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_evidence_file_id" ON "diagnostic_units"."diagnostic_unit_accreditations" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_verification_status__7e3d4f65" ON "diagnostic_units"."diagnostic_unit_accreditations" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_created_by_user_id" ON "diagnostic_units"."diagnostic_unit_accreditations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_diagnostic_unit_accreditations_updated_by_user_id" ON "diagnostic_units"."diagnostic_unit_accreditations" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_unit_medical_visitors_user_id" ON "diagnostic_units"."unit_medical_visitors" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_diagnostic_unit_id" ON "diagnostic_units"."unit_medical_visitors" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_supervisor_user_id" ON "diagnostic_units"."unit_medical_visitors" ("supervisor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_branch_id" ON "diagnostic_units"."unit_medical_visitors" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_identity_verification_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("identity_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_contract_verification_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("contract_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_credential_verification_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("credential_verification_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_status_concept_id" ON "diagnostic_units"."unit_medical_visitors" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_created_by_user_id" ON "diagnostic_units"."unit_medical_visitors" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_medical_visitors_updated_by_user_id" ON "diagnostic_units"."unit_medical_visitors" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_unit_medical_visitor_id" ON "diagnostic_units"."unit_visit_requests" ("unit_medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_diagnostic_unit_id" ON "diagnostic_units"."unit_visit_requests" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_doctor_user_id" ON "diagnostic_units"."unit_visit_requests" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_doctor_tenant_id" ON "diagnostic_units"."unit_visit_requests" ("doctor_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_modality_concept_id" ON "diagnostic_units"."unit_visit_requests" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_status_concept_id" ON "diagnostic_units"."unit_visit_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_rescheduled_from_id" ON "diagnostic_units"."unit_visit_requests" ("rescheduled_from_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_created_by_user_id" ON "diagnostic_units"."unit_visit_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_requests_updated_by_user_id" ON "diagnostic_units"."unit_visit_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_unit_visit_request_id" ON "diagnostic_units"."unit_visit_request_events" ("unit_visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_action_concept_id" ON "diagnostic_units"."unit_visit_request_events" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_previous_status_concept_id" ON "diagnostic_units"."unit_visit_request_events" ("previous_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_new_status_concept_id" ON "diagnostic_units"."unit_visit_request_events" ("new_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_actor_user_id" ON "diagnostic_units"."unit_visit_request_events" ("actor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_request_events_created_by_user_id" ON "diagnostic_units"."unit_visit_request_events" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_unit_visit_records_unit_visit_request_id" ON "diagnostic_units"."unit_visit_records" ("unit_visit_request_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_doctor_user_id" ON "diagnostic_units"."unit_visit_records" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_unit_medical_visitor_id" ON "diagnostic_units"."unit_visit_records" ("unit_medical_visitor_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_diagnostic_unit_id" ON "diagnostic_units"."unit_visit_records" ("diagnostic_unit_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_modality_concept_id" ON "diagnostic_units"."unit_visit_records" ("modality_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_visitor_attendance_concept_id" ON "diagnostic_units"."unit_visit_records" ("visitor_attendance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_doctor_attendance_concept_id" ON "diagnostic_units"."unit_visit_records" ("doctor_attendance_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_confirmation_concept_id" ON "diagnostic_units"."unit_visit_records" ("confirmation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_created_by_user_id" ON "diagnostic_units"."unit_visit_records" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_records_updated_by_user_id" ON "diagnostic_units"."unit_visit_records" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_unit_visit_record_id" ON "diagnostic_units"."unit_visit_ratings" ("unit_visit_record_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_doctor_user_id" ON "diagnostic_units"."unit_visit_ratings" ("doctor_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_kind_concept_id" ON "diagnostic_units"."unit_visit_ratings" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_created_by_user_id" ON "diagnostic_units"."unit_visit_ratings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_unit_visit_ratings_updated_by_user_id" ON "diagnostic_units"."unit_visit_ratings" ("updated_by_user_id");
