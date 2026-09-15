-- SALUD v4.0.10 · módulo 14 · schema practice
-- Generado de diagram_14_practice.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_inventory_items_practice_id" ON "practice"."inventory_items" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_items_product_concept_id" ON "practice"."inventory_items" ("product_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_items_unit_concept_id" ON "practice"."inventory_items" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_items_status_concept_id" ON "practice"."inventory_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_items_created_by_user_id" ON "practice"."inventory_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_items_updated_by_user_id" ON "practice"."inventory_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_movements_inventory_item_id" ON "practice"."inventory_movements" ("inventory_item_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_movements_movement_type_concept_id" ON "practice"."inventory_movements" ("movement_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inventory_movements_recorded_by_user_id" ON "practice"."inventory_movements" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_inventory_movements_recorded_at" ON "practice"."inventory_movements" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_practices_tenant_id" ON "practice"."practices" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_practices_type_concept_id" ON "practice"."practices" ("type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practices_admin_user_id" ON "practice"."practices" ("admin_user_id");

CREATE INDEX IF NOT EXISTS "ix_practices_currency_concept_id" ON "practice"."practices" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practices_status_concept_id" ON "practice"."practices" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practices_created_by_user_id" ON "practice"."practices" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practices_updated_by_user_id" ON "practice"."practices" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practices_tenant_id_status_concept_id" ON "practice"."practices" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_practice_sites_practice_id" ON "practice"."practice_sites" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_branch_id" ON "practice"."practice_sites" ("branch_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_site_type_concept_id" ON "practice"."practice_sites" ("site_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_physical_type_concept_id" ON "practice"."practice_sites" ("physical_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_operational_status_concept_id" ON "practice"."practice_sites" ("operational_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_address_id" ON "practice"."practice_sites" ("address_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_managing_tenant_id" ON "practice"."practice_sites" ("managing_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_status_concept_id" ON "practice"."practice_sites" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_created_by_user_id" ON "practice"."practice_sites" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_updated_by_user_id" ON "practice"."practice_sites" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_bank_qr_file_id" ON "practice"."practice_sites" ("bank_qr_file_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_practice_site_id" ON "practice"."clinical_units" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_parent_unit_id" ON "practice"."clinical_units" ("parent_unit_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_unit_type_concept_id" ON "practice"."clinical_units" ("unit_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_specialty_concept_id" ON "practice"."clinical_units" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_service_mode_concept_id" ON "practice"."clinical_units" ("service_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_status_concept_id" ON "practice"."clinical_units" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_created_by_user_id" ON "practice"."clinical_units" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_updated_by_user_id" ON "practice"."clinical_units" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_practice_site_id" ON "practice"."care_spaces" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_clinical_unit_id" ON "practice"."care_spaces" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_parent_space_id" ON "practice"."care_spaces" ("parent_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_space_type_concept_id" ON "practice"."care_spaces" ("space_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_operational_status_concept_id" ON "practice"."care_spaces" ("operational_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_status_concept_id" ON "practice"."care_spaces" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_created_by_user_id" ON "practice"."care_spaces" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_updated_by_user_id" ON "practice"."care_spaces" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_practice_id" ON "practice"."healthcare_services" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_practice_site_id" ON "practice"."healthcare_services" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_clinical_unit_id" ON "practice"."healthcare_services" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_service_concept_id" ON "practice"."healthcare_services" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_specialty_concept_id" ON "practice"."healthcare_services" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_status_concept_id" ON "practice"."healthcare_services" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_created_by_user_id" ON "practice"."healthcare_services" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_updated_by_user_id" ON "practice"."healthcare_services" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_practitioner_profile_id" ON "practice"."practitioner_role_assignments" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_practice_id" ON "practice"."practitioner_role_assignments" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_practice_site_id" ON "practice"."practitioner_role_assignments" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_clinical_unit_id" ON "practice"."practitioner_role_assignments" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_healthcare_service_id" ON "practice"."practitioner_role_assignments" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_role_concept_id" ON "practice"."practitioner_role_assignments" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_specialty_concept_id" ON "practice"."practitioner_role_assignments" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_supervisor_practition_4d201e89" ON "practice"."practitioner_role_assignments" ("supervisor_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_status_concept_id" ON "practice"."practitioner_role_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_created_by_user_id" ON "practice"."practitioner_role_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_role_assignments_updated_by_user_id" ON "practice"."practitioner_role_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_practitioner_role_assignments_effective_period" ON "practice"."practitioner_role_assignments" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_practitioner_support_assignments_practitioner_role__d1c4a67d" ON "practice"."practitioner_support_assignments" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_support_assignments_support_profile_id" ON "practice"."practitioner_support_assignments" ("support_profile_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_support_assignments_support_role_concept_id" ON "practice"."practitioner_support_assignments" ("support_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_support_assignments_scope_concept_id" ON "practice"."practitioner_support_assignments" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_support_assignments_status_concept_id" ON "practice"."practitioner_support_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_support_assignments_created_by_user_id" ON "practice"."practitioner_support_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_support_assignments_updated_by_user_id" ON "practice"."practitioner_support_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_practitioner_support_assignments_effective_period" ON "practice"."practitioner_support_assignments" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_practice_id" ON "practice"."practice_accreditations" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_practice_site_id" ON "practice"."practice_accreditations" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_accreditation_type_concept_id" ON "practice"."practice_accreditations" ("accreditation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_issuer_tenant_id" ON "practice"."practice_accreditations" ("issuer_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_evidence_file_id" ON "practice"."practice_accreditations" ("evidence_file_id");

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_verification_status_concept_id" ON "practice"."practice_accreditations" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_created_by_user_id" ON "practice"."practice_accreditations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practice_accreditations_updated_by_user_id" ON "practice"."practice_accreditations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practice_settings_practice_id" ON "practice"."practice_settings" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practice_settings_category_concept_id" ON "practice"."practice_settings" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_settings_created_by_user_id" ON "practice"."practice_settings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practice_settings_updated_by_user_id" ON "practice"."practice_settings" ("updated_by_user_id");
