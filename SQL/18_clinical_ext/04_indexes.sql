-- SALUD v4.0.10 · módulo 18 · schema clinical_ext
-- Generado de diagram_18_clinical_ext.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_care_teams_patient_profile_id" ON "clinical_ext"."care_teams" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_episode_id" ON "clinical_ext"."care_teams" ("episode_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_tenant_id" ON "clinical_ext"."care_teams" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_category_concept_id" ON "clinical_ext"."care_teams" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_status_concept_id" ON "clinical_ext"."care_teams" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_created_by_user_id" ON "clinical_ext"."care_teams" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_updated_by_user_id" ON "clinical_ext"."care_teams" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_teams_tenant_id_status_concept_id" ON "clinical_ext"."care_teams" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_teams_patient_profile_id_updated_at" ON "clinical_ext"."care_teams" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_team_members_care_team_id" ON "clinical_ext"."care_team_members" ("care_team_id");

CREATE INDEX IF NOT EXISTS "ix_care_team_members_practitioner_profile_id" ON "clinical_ext"."care_team_members" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_care_team_members_related_person_id" ON "clinical_ext"."care_team_members" ("related_person_id");

CREATE INDEX IF NOT EXISTS "ix_care_team_members_member_role_concept_id" ON "clinical_ext"."care_team_members" ("member_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_team_members_status_concept_id" ON "clinical_ext"."care_team_members" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_team_members_created_by_user_id" ON "clinical_ext"."care_team_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_team_members_updated_by_user_id" ON "clinical_ext"."care_team_members" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_patient_profile_id" ON "clinical_ext"."referrals" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_source_encounter_id" ON "clinical_ext"."referrals" ("source_encounter_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_referring_profile_id" ON "clinical_ext"."referrals" ("referring_profile_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_target_profile_id" ON "clinical_ext"."referrals" ("target_profile_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_target_tenant_id" ON "clinical_ext"."referrals" ("target_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_specialty_concept_id" ON "clinical_ext"."referrals" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_service_request_id" ON "clinical_ext"."referrals" ("service_request_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_reason_concept_id" ON "clinical_ext"."referrals" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_priority_concept_id" ON "clinical_ext"."referrals" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_status_concept_id" ON "clinical_ext"."referrals" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_created_by_user_id" ON "clinical_ext"."referrals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_updated_by_user_id" ON "clinical_ext"."referrals" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_patient_profile_id_updated_at" ON "clinical_ext"."referrals" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_patient_profile_id" ON "clinical_ext"."clinical_alerts" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_encounter_id" ON "clinical_ext"."clinical_alerts" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_alert_type_concept_id" ON "clinical_ext"."clinical_alerts" ("alert_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_severity_concept_id" ON "clinical_ext"."clinical_alerts" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_trigger_concept_id" ON "clinical_ext"."clinical_alerts" ("trigger_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_rule_id" ON "clinical_ext"."clinical_alerts" ("rule_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_status_concept_id" ON "clinical_ext"."clinical_alerts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_overridden_by_user_id" ON "clinical_ext"."clinical_alerts" ("overridden_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_created_by_user_id" ON "clinical_ext"."clinical_alerts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_updated_by_user_id" ON "clinical_ext"."clinical_alerts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_clinical_alerts_patient_profile_id_updated_at" ON "clinical_ext"."clinical_alerts" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_virtual_encounters_encounter_id" ON "clinical_ext"."virtual_encounters" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_virtual_encounters_platform_concept_id" ON "clinical_ext"."virtual_encounters" ("platform_concept_id");

CREATE INDEX IF NOT EXISTS "ix_virtual_encounters_recording_file_id" ON "clinical_ext"."virtual_encounters" ("recording_file_id");

CREATE INDEX IF NOT EXISTS "ix_virtual_encounters_status_concept_id" ON "clinical_ext"."virtual_encounters" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_virtual_encounters_created_by_user_id" ON "clinical_ext"."virtual_encounters" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_virtual_encounters_updated_by_user_id" ON "clinical_ext"."virtual_encounters" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_cds_rules_code" ON "clinical_ext"."cds_rules" ("code");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_tenant_id" ON "clinical_ext"."cds_rules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_rule_type_concept_id" ON "clinical_ext"."cds_rules" ("rule_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_severity_concept_id" ON "clinical_ext"."cds_rules" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_status_concept_id" ON "clinical_ext"."cds_rules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_created_by_user_id" ON "clinical_ext"."cds_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_updated_by_user_id" ON "clinical_ext"."cds_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rules_tenant_id_status_concept_id" ON "clinical_ext"."cds_rules" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_drug_interactions_substance_a_concept_id" ON "clinical_ext"."drug_interactions" ("substance_a_concept_id");

CREATE INDEX IF NOT EXISTS "ix_drug_interactions_substance_b_concept_id" ON "clinical_ext"."drug_interactions" ("substance_b_concept_id");

CREATE INDEX IF NOT EXISTS "ix_drug_interactions_severity_concept_id" ON "clinical_ext"."drug_interactions" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_drug_interactions_evidence_level_concept_id" ON "clinical_ext"."drug_interactions" ("evidence_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_drug_interactions_created_by_user_id" ON "clinical_ext"."drug_interactions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_drug_interactions_updated_by_user_id" ON "clinical_ext"."drug_interactions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reference_ranges_code_concept_id" ON "clinical_ext"."reference_ranges" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reference_ranges_unit_concept_id" ON "clinical_ext"."reference_ranges" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reference_ranges_sex_concept_id" ON "clinical_ext"."reference_ranges" ("sex_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reference_ranges_condition_concept_id" ON "clinical_ext"."reference_ranges" ("condition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reference_ranges_created_by_user_id" ON "clinical_ext"."reference_ranges" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reference_ranges_updated_by_user_id" ON "clinical_ext"."reference_ranges" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_tenant_id" ON "clinical_ext"."order_sets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_specialty_concept_id" ON "clinical_ext"."order_sets" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_condition_concept_id" ON "clinical_ext"."order_sets" ("condition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_status_concept_id" ON "clinical_ext"."order_sets" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_created_by_user_id" ON "clinical_ext"."order_sets" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_updated_by_user_id" ON "clinical_ext"."order_sets" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_order_sets_tenant_id_status_concept_id" ON "clinical_ext"."order_sets" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_order_set_items_order_set_id" ON "clinical_ext"."order_set_items" ("order_set_id");

CREATE INDEX IF NOT EXISTS "ix_order_set_items_item_type_concept_id" ON "clinical_ext"."order_set_items" ("item_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_order_set_items_code_concept_id" ON "clinical_ext"."order_set_items" ("code_concept_id");

CREATE INDEX IF NOT EXISTS "ix_order_set_items_default_route_concept_id" ON "clinical_ext"."order_set_items" ("default_route_concept_id");

CREATE INDEX IF NOT EXISTS "ix_order_set_items_created_by_user_id" ON "clinical_ext"."order_set_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_order_set_items_updated_by_user_id" ON "clinical_ext"."order_set_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_practitioner_profile_id" ON "clinical_ext"."prescription_favorites" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_medication_concept_id" ON "clinical_ext"."prescription_favorites" ("medication_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_substance_atc_concept_id" ON "clinical_ext"."prescription_favorites" ("substance_atc_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_route_concept_id" ON "clinical_ext"."prescription_favorites" ("route_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_unit_concept_id" ON "clinical_ext"."prescription_favorites" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_created_by_user_id" ON "clinical_ext"."prescription_favorites" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_updated_by_user_id" ON "clinical_ext"."prescription_favorites" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_prescription_favorites_practitioner_name" ON "clinical_ext"."prescription_favorites" ("practitioner_profile_id", "name");

CREATE INDEX IF NOT EXISTS "ix_immunization_schedules_tenant_id" ON "clinical_ext"."immunization_schedules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_immunization_schedules_vaccine_concept_id" ON "clinical_ext"."immunization_schedules" ("vaccine_concept_id");

CREATE INDEX IF NOT EXISTS "ix_immunization_schedules_jurisdiction_concept_id" ON "clinical_ext"."immunization_schedules" ("jurisdiction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_immunization_schedules_status_concept_id" ON "clinical_ext"."immunization_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_immunization_schedules_created_by_user_id" ON "clinical_ext"."immunization_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_immunization_schedules_updated_by_user_id" ON "clinical_ext"."immunization_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_immunization_schedules_tenant_id_status_concept_id" ON "clinical_ext"."immunization_schedules" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_care_gaps_patient_profile_id" ON "clinical_ext"."care_gaps" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_care_gaps_gap_type_concept_id" ON "clinical_ext"."care_gaps" ("gap_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_gaps_measure_concept_id" ON "clinical_ext"."care_gaps" ("measure_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_gaps_status_concept_id" ON "clinical_ext"."care_gaps" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_gaps_created_by_user_id" ON "clinical_ext"."care_gaps" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_gaps_updated_by_user_id" ON "clinical_ext"."care_gaps" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_care_gaps_patient_profile_id_updated_at" ON "clinical_ext"."care_gaps" ("patient_profile_id", "updated_at" DESC);
