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

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practices_tenant_id_id" ON "practice"."practices" ("tenant_id", "id");

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

CREATE INDEX IF NOT EXISTS "ix_practice_sites_logo_file_id" ON "practice"."practice_sites" ("logo_file_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_tenant_id" ON "practice"."practice_sites" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_subsector_concept_id" ON "practice"."practice_sites" ("subsector_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_care_level_concept_id" ON "practice"."practice_sites" ("care_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_facility_typology_concept_id" ON "practice"."practice_sites" ("facility_typology_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_sedes_department_concept_id" ON "practice"."practice_sites" ("sedes_department_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practice_sites_snis_code" ON "practice"."practice_sites" ("snis_code") WHERE snis_code IS NOT NULL AND snis_verified_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_practice_sites_tenant_id_snis_code" ON "practice"."practice_sites" ("tenant_id", "snis_code");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_snis_verified_by_user_id" ON "practice"."practice_sites" ("snis_verified_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practice_sites_tenant_id_id" ON "practice"."practice_sites" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_practice_site_id" ON "practice"."clinical_units" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_parent_unit_id" ON "practice"."clinical_units" ("parent_unit_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_unit_type_concept_id" ON "practice"."clinical_units" ("unit_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_specialty_concept_id" ON "practice"."clinical_units" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_service_mode_concept_id" ON "practice"."clinical_units" ("service_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_status_concept_id" ON "practice"."clinical_units" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_created_by_user_id" ON "practice"."clinical_units" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_updated_by_user_id" ON "practice"."clinical_units" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_responsible_user_id" ON "practice"."clinical_units" ("responsible_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_units_tenant_id" ON "practice"."clinical_units" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_clinical_units_tenant_id_id" ON "practice"."clinical_units" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_practice_site_id" ON "practice"."care_spaces" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_clinical_unit_id" ON "practice"."care_spaces" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_parent_space_id" ON "practice"."care_spaces" ("parent_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_space_type_concept_id" ON "practice"."care_spaces" ("space_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_operational_status_concept_id" ON "practice"."care_spaces" ("operational_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_status_concept_id" ON "practice"."care_spaces" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_created_by_user_id" ON "practice"."care_spaces" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_updated_by_user_id" ON "practice"."care_spaces" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_tenant_id" ON "practice"."care_spaces" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_form_concept_id" ON "practice"."care_spaces" ("form_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_asepsis_concept_id" ON "practice"."care_spaces" ("asepsis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_pressure_concept_id" ON "practice"."care_spaces" ("pressure_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_sex_restriction_concept_id" ON "practice"."care_spaces" ("sex_restriction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_age_group_concept_id" ON "practice"."care_spaces" ("age_group_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_bed_category_concept_id" ON "practice"."care_spaces" ("bed_category_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_spaces_site_code" ON "practice"."care_spaces" ("practice_site_id", "code");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_spaces_tenant_id_id" ON "practice"."care_spaces" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_availability_reason_concept_id" ON "practice"."care_spaces" ("availability_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_hygiene_status_concept_id" ON "practice"."care_spaces" ("hygiene_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_isolation_concept_id" ON "practice"."care_spaces" ("isolation_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_spaces_site_id_id" ON "practice"."care_spaces" ("practice_site_id", "id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_tenant_id" ON "practice"."space_unit_assignments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_care_space_id" ON "practice"."space_unit_assignments" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_clinical_unit_id" ON "practice"."space_unit_assignments" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_role_concept_id" ON "practice"."space_unit_assignments" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_created_by_user_id" ON "practice"."space_unit_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_updated_by_user_id" ON "practice"."space_unit_assignments" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_unit_assignments_current" ON "practice"."space_unit_assignments" ("care_space_id", "clinical_unit_id") WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_tenant_id" ON "practice"."site_declared_capacities" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_practice_site_id" ON "practice"."site_declared_capacities" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_capacity_kind_concept_id" ON "practice"."site_declared_capacities" ("capacity_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_created_by_user_id" ON "practice"."site_declared_capacities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_updated_by_user_id" ON "practice"."site_declared_capacities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_site_kind_as_of" ON "practice"."site_declared_capacities" ("practice_site_id", "capacity_kind_concept_id", "as_of" DESC);

CREATE INDEX IF NOT EXISTS "ix_space_form_parent_rules_child_form_concept_id" ON "practice"."space_form_parent_rules" ("child_form_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_form_parent_rules_created_by_user_id" ON "practice"."space_form_parent_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_space_form_parent_rules_updated_by_user_id" ON "practice"."space_form_parent_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_space_function_concept_id" ON "practice"."facility_typology_rules" ("space_function_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_rule_concept_id" ON "practice"."facility_typology_rules" ("rule_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_created_by_user_id" ON "practice"."facility_typology_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_updated_by_user_id" ON "practice"."facility_typology_rules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_tenant_id_id" ON "practice"."floor_plans" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_site_code" ON "practice"."floor_plans" ("practice_site_id", "code");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_anchor_current" ON "practice"."floor_plans" ("anchor_space_id") WHERE anchor_space_id IS NOT NULL AND valid_to IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_site_campus_current" ON "practice"."floor_plans" ("practice_site_id") WHERE anchor_space_id IS NULL AND valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_floor_plans_tenant_id" ON "practice"."floor_plans" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_floor_plans_practice_site_id" ON "practice"."floor_plans" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_floor_plans_anchor_space_id" ON "practice"."floor_plans" ("anchor_space_id");

CREATE INDEX IF NOT EXISTS "ix_floor_plans_background_file_id" ON "practice"."floor_plans" ("background_file_id");

CREATE INDEX IF NOT EXISTS "ix_floor_plans_background_file_version_id" ON "practice"."floor_plans" ("background_file_version_id");

CREATE INDEX IF NOT EXISTS "ix_floor_plans_created_by_user_id" ON "practice"."floor_plans" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_floor_plans_updated_by_user_id" ON "practice"."floor_plans" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_placements_tenant_id_id" ON "practice"."space_placements" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_placements_care_space" ON "practice"."space_placements" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_space_placements_tenant_id" ON "practice"."space_placements" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_space_placements_floor_plan_id" ON "practice"."space_placements" ("floor_plan_id");

CREATE INDEX IF NOT EXISTS "ix_space_placements_sibling_group_id" ON "practice"."space_placements" ("sibling_group_id");

CREATE INDEX IF NOT EXISTS "ix_space_placements_created_by_user_id" ON "practice"."space_placements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_space_placements_updated_by_user_id" ON "practice"."space_placements" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_plan_elements_tenant_id_id" ON "practice"."plan_elements" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_tenant_id" ON "practice"."plan_elements" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_floor_plan_id" ON "practice"."plan_elements" ("floor_plan_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_host_element_id" ON "practice"."plan_elements" ("host_element_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_connects_space_a_id" ON "practice"."plan_elements" ("connects_space_a_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_connects_space_b_id" ON "practice"."plan_elements" ("connects_space_b_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_created_by_user_id" ON "practice"."plan_elements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_updated_by_user_id" ON "practice"."plan_elements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_vertical_link" ON "practice"."plan_elements" ("vertical_link_code") WHERE vertical_link_code IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_practice_id" ON "practice"."healthcare_services" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_practice_site_id" ON "practice"."healthcare_services" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_clinical_unit_id" ON "practice"."healthcare_services" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_service_concept_id" ON "practice"."healthcare_services" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_specialty_concept_id" ON "practice"."healthcare_services" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_status_concept_id" ON "practice"."healthcare_services" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_service_catalog_id" ON "practice"."healthcare_services" ("service_catalog_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_healthcare_services_site_service" ON "practice"."healthcare_services" ("practice_site_id", "service_concept_id");

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

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_tenant_id" ON "practice"."care_space_status_events" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_practice_site_id" ON "practice"."care_space_status_events" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_care_space_id" ON "practice"."care_space_status_events" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_axis_concept_id" ON "practice"."care_space_status_events" ("axis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_from_concept_id" ON "practice"."care_space_status_events" ("from_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_to_concept_id" ON "practice"."care_space_status_events" ("to_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_reason_concept_id" ON "practice"."care_space_status_events" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_source_concept_id" ON "practice"."care_space_status_events" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_recorded_by_user_id" ON "practice"."care_space_status_events" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_space_occurred_at" ON "practice"."care_space_status_events" ("care_space_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_status_events_site_occurred_at" ON "practice"."care_space_status_events" ("practice_site_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_tenant_id" ON "practice"."care_space_blocks" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_care_space_id" ON "practice"."care_space_blocks" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_kind_concept_id" ON "practice"."care_space_blocks" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_reason_concept_id" ON "practice"."care_space_blocks" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_ended_by_user_id" ON "practice"."care_space_blocks" ("ended_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_created_by_user_id" ON "practice"."care_space_blocks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_blocks_updated_by_user_id" ON "practice"."care_space_blocks" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_space_blocks_tenant_id_id" ON "practice"."care_space_blocks" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_tenant_id" ON "practice"."cleaning_orders" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_practice_site_id" ON "practice"."cleaning_orders" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_care_space_id" ON "practice"."cleaning_orders" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_clinical_unit_id" ON "practice"."cleaning_orders" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_cleaning_type_concept_id" ON "practice"."cleaning_orders" ("cleaning_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_trigger_concept_id" ON "practice"."cleaning_orders" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_previous_order_id" ON "practice"."cleaning_orders" ("previous_order_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_priority_concept_id" ON "practice"."cleaning_orders" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_status_concept_id" ON "practice"."cleaning_orders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_assigned_user_id" ON "practice"."cleaning_orders" ("assigned_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_started_by_user_id" ON "practice"."cleaning_orders" ("started_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_finished_by_user_id" ON "practice"."cleaning_orders" ("finished_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_inspected_by_user_id" ON "practice"."cleaning_orders" ("inspected_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_inspection_result_concept_id" ON "practice"."cleaning_orders" ("inspection_result_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_created_by_user_id" ON "practice"."cleaning_orders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_updated_by_user_id" ON "practice"."cleaning_orders" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cleaning_orders_site_status_requested" ON "practice"."cleaning_orders" ("practice_site_id", "status_concept_id", "requested_at");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cleaning_orders_tenant_id_id" ON "practice"."cleaning_orders" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_cleaning_orders_one_open_per_space" ON "practice"."cleaning_orders" ("care_space_id") WHERE status_concept_id IN ('c0c5918f-cf97-51e1-9ede-72d856e61c93', '60ff8df8-4ba5-591c-b092-e8da81187539', '334b9e1f-b123-5477-a22e-2dd1b838c2fa');

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_tenant_id" ON "practice"."care_space_category_periods" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_care_space_id" ON "practice"."care_space_category_periods" ("care_space_id", "valid_from" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_bed_category_concept_id" ON "practice"."care_space_category_periods" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_created_by_user_id" ON "practice"."care_space_category_periods" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_space_category_periods_updated_by_user_id" ON "practice"."care_space_category_periods" ("updated_by_user_id");
