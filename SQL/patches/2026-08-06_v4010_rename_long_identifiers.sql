-- ============================================================================
-- SALUD · patch v4.0.9 → v4.0.10 sobre una BD viva · Fecha: 2026-08-06
-- Renombra los identificadores que PostgreSQL habia truncado EN SILENCIO a 63
-- bytes, al nombre canonico acortado con hash (prefijo 54 + '_' + sha1-8) que
-- ahora emite gen_ddl.py — el mismo algoritmo que shortenIdentifier en
-- mantra-core-health-api/src/orm/bootstrap/identifier.ts. Con esto la capa 06
-- del bootstrap deja de proponer 58 FKs "ausentes" en cada arranque: eran estas,
-- con el nombre truncado.
--
-- Idempotente: cada rename se guarda con IF EXISTS sobre el nombre viejo. En un
-- rebuild desde cero este patch no hace falta (SQL/ ya emite el nombre nuevo).
-- gen_apply.py no escanea SQL/patches/, asi que no entra en apply_all.sql.
-- ============================================================================

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='ads' AND t.relname='conversion_event_delivery_attempts' AND c.conname='fk_conversion_event_delivery_attempts_server_conversion_event_i') THEN
        ALTER TABLE "ads"."conversion_event_delivery_attempts" RENAME CONSTRAINT "fk_conversion_event_delivery_attempts_server_conversion_event_i" TO "fk_conversion_event_delivery_attempts_server_conversio_0b5ca799";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='delegated_access_audit_log' AND c.conname='fk_delegated_access_audit_log_delegating_practitioner_profile_i') THEN
        ALTER TABLE "audit"."delegated_access_audit_log" RENAME CONSTRAINT "fk_delegated_access_audit_log_delegating_practitioner_profile_i" TO "fk_delegated_access_audit_log_delegating_practitioner__652b7b85";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='health_practitioner_profiles_history' AND c.conname='fk_health_practitioner_profiles_history_change_reason_concept_i') THEN
        ALTER TABLE "audit"."health_practitioner_profiles_history" RENAME CONSTRAINT "fk_health_practitioner_profiles_history_change_reason_concept_i" TO "fk_health_practitioner_profiles_history_change_reason__8785974d";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='health_practitioner_profiles_history' AND c.conname='fk_health_practitioner_profiles_history_health_practitioner_pro') THEN
        ALTER TABLE "audit"."health_practitioner_profiles_history" RENAME CONSTRAINT "fk_health_practitioner_profiles_history_health_practitioner_pro" TO "fk_health_practitioner_profiles_history_health_practit_b2903f37";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='jurisdiction_authorizations_history' AND c.conname='fk_jurisdiction_authorizations_history_jurisdiction_authorizati') THEN
        ALTER TABLE "audit"."jurisdiction_authorizations_history" RENAME CONSTRAINT "fk_jurisdiction_authorizations_history_jurisdiction_authorizati" TO "fk_jurisdiction_authorizations_history_jurisdiction_au_5b12cb5b";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='organization_affiliations_history' AND c.conname='fk_organization_affiliations_history_organization_affiliation_i') THEN
        ALTER TABLE "audit"."organization_affiliations_history" RENAME CONSTRAINT "fk_organization_affiliations_history_organization_affiliation_i" TO "fk_organization_affiliations_history_organization_affi_000fda2f";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='practitioner_role_assignments_history' AND c.conname='fk_practitioner_role_assignments_history_change_reason_concept_') THEN
        ALTER TABLE "audit"."practitioner_role_assignments_history" RENAME CONSTRAINT "fk_practitioner_role_assignments_history_change_reason_concept_" TO "fk_practitioner_role_assignments_history_change_reason_a26f251f";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='practitioner_role_assignments_history' AND c.conname='fk_practitioner_role_assignments_history_practitioner_role_assi') THEN
        ALTER TABLE "audit"."practitioner_role_assignments_history" RENAME CONSTRAINT "fk_practitioner_role_assignments_history_practitioner_role_assi" TO "fk_practitioner_role_assignments_history_practitioner__baff3e62";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='audit' AND t.relname='provider_protocol_configs_history' AND c.conname='fk_provider_protocol_configs_history_provider_protocol_config_i') THEN
        ALTER TABLE "audit"."provider_protocol_configs_history" RENAME CONSTRAINT "fk_provider_protocol_configs_history_provider_protocol_config_i" TO "fk_provider_protocol_configs_history_provider_protocol_e11b566a";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='delegated_access' AND t.relname='delegated_access_approval_requests' AND c.conname='fk_delegated_access_approval_requests_practitioner_delegate_ass') THEN
        ALTER TABLE "delegated_access"."delegated_access_approval_requests" RENAME CONSTRAINT "fk_delegated_access_approval_requests_practitioner_delegate_ass" TO "fk_delegated_access_approval_requests_practitioner_del_a6db1929";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='delegated_access' AND t.relname='practitioner_delegate_assignments' AND c.conname='fk_practitioner_delegate_assignments_appointment_scope_concept_') THEN
        ALTER TABLE "delegated_access"."practitioner_delegate_assignments" RENAME CONSTRAINT "fk_practitioner_delegate_assignments_appointment_scope_concept_" TO "fk_practitioner_delegate_assignments_appointment_scope_5c233325";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='delegated_access' AND t.relname='practitioner_delegate_assignments' AND c.conname='fk_practitioner_delegate_assignments_delegate_user_assignment_i') THEN
        ALTER TABLE "delegated_access"."practitioner_delegate_assignments" RENAME CONSTRAINT "fk_practitioner_delegate_assignments_delegate_user_assignment_i" TO "fk_practitioner_delegate_assignments_delegate_user_ass_501b9011";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='delegated_access' AND t.relname='practitioner_delegate_assignments' AND c.conname='fk_practitioner_delegate_assignments_delegated_permission_set_i') THEN
        ALTER TABLE "delegated_access"."practitioner_delegate_assignments" RENAME CONSTRAINT "fk_practitioner_delegate_assignments_delegated_permission_set_i" TO "fk_practitioner_delegate_assignments_delegated_permiss_f69e2298";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='delegated_access' AND t.relname='practitioner_delegate_assignments' AND c.conname='fk_practitioner_delegate_assignments_practitioner_role_assignme') THEN
        ALTER TABLE "delegated_access"."practitioner_delegate_assignments" RENAME CONSTRAINT "fk_practitioner_delegate_assignments_practitioner_role_assignme" TO "fk_practitioner_delegate_assignments_practitioner_role_7e0ebecf";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='diagnostic_units' AND t.relname='diagnostic_unit_accreditations' AND c.conname='fk_diagnostic_unit_accreditations_verification_status_concept_i') THEN
        ALTER TABLE "diagnostic_units"."diagnostic_unit_accreditations" RENAME CONSTRAINT "fk_diagnostic_unit_accreditations_verification_status_concept_i" TO "fk_diagnostic_unit_accreditations_verification_status__ca2f963c";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='diagnostic_units' AND t.relname='diagnostic_unit_practitioner_assignments' AND c.conname='fk_diagnostic_unit_practitioner_assignments_assignment_role_con') THEN
        ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments" RENAME CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_assignment_role_con" TO "fk_diagnostic_unit_practitioner_assignments_assignment_e7e914be";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='diagnostic_units' AND t.relname='diagnostic_unit_practitioner_assignments' AND c.conname='fk_diagnostic_unit_practitioner_assignments_diagnostic_unit_sit') THEN
        ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments" RENAME CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_diagnostic_unit_sit" TO "fk_diagnostic_unit_practitioner_assignments_diagnostic_1163bc0c";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='diagnostic_units' AND t.relname='diagnostic_unit_practitioner_assignments' AND c.conname='fk_diagnostic_unit_practitioner_assignments_practitioner_role_a') THEN
        ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments" RENAME CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_practitioner_role_a" TO "fk_diagnostic_unit_practitioner_assignments_practition_d05600aa";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='diagnostic_units' AND t.relname='diagnostic_unit_practitioner_assignments' AND c.conname='fk_diagnostic_unit_practitioner_assignments_specialty_concept_i') THEN
        ALTER TABLE "diagnostic_units"."diagnostic_unit_practitioner_assignments" RENAME CONSTRAINT "fk_diagnostic_unit_practitioner_assignments_specialty_concept_i" TO "fk_diagnostic_unit_practitioner_assignments_specialty__f8946881";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='diagnostics' AND t.relname='specimen_chain_of_custody_events' AND c.conname='fk_specimen_chain_of_custody_events_custody_event_type_concept_') THEN
        ALTER TABLE "diagnostics"."specimen_chain_of_custody_events" RENAME CONSTRAINT "fk_specimen_chain_of_custody_events_custody_event_type_concept_" TO "fk_specimen_chain_of_custody_events_custody_event_type_464b802a";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='erp' AND t.relname='business_partner_bank_accounts' AND c.conname='fk_business_partner_bank_accounts_verification_status_concept_i') THEN
        ALTER TABLE "erp"."business_partner_bank_accounts" RENAME CONSTRAINT "fk_business_partner_bank_accounts_verification_status_concept_i" TO "fk_business_partner_bank_accounts_verification_status__769cb0dc";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='health_data' AND t.relname='canonical_health_resource_versions' AND c.conname='fk_canonical_health_resource_versions_canonical_health_resource') THEN
        ALTER TABLE "health_data"."canonical_health_resource_versions" RENAME CONSTRAINT "fk_canonical_health_resource_versions_canonical_health_resource" TO "fk_canonical_health_resource_versions_canonical_health_97ff4d77";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='health_data' AND t.relname='canonical_health_resource_versions' AND c.conname='fk_canonical_health_resource_versions_health_ingestion_record_i') THEN
        ALTER TABLE "health_data"."canonical_health_resource_versions" RENAME CONSTRAINT "fk_canonical_health_resource_versions_health_ingestion_record_i" TO "fk_canonical_health_resource_versions_health_ingestion_196b9e10";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='health_data' AND t.relname='canonical_resource_relationships' AND c.conname='fk_canonical_resource_relationships_relationship_role_concept_i') THEN
        ALTER TABLE "health_data"."canonical_resource_relationships" RENAME CONSTRAINT "fk_canonical_resource_relationships_relationship_role_concept_i" TO "fk_canonical_resource_relationships_relationship_role__a1ad800f";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='health_data' AND t.relname='canonical_resource_relationships' AND c.conname='fk_canonical_resource_relationships_relationship_type_concept_i') THEN
        ALTER TABLE "health_data"."canonical_resource_relationships" RENAME CONSTRAINT "fk_canonical_resource_relationships_relationship_type_concept_i" TO "fk_canonical_resource_relationships_relationship_type__919725f6";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='health_data' AND t.relname='health_deidentification_profiles' AND c.conname='fk_health_deidentification_profiles_reidentification_key_secret') THEN
        ALTER TABLE "health_data"."health_deidentification_profiles" RENAME CONSTRAINT "fk_health_deidentification_profiles_reidentification_key_secret" TO "fk_health_deidentification_profiles_reidentification_k_76ae9fd3";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='health_data' AND t.relname='health_deidentification_runs' AND c.conname='fk_health_deidentification_runs_health_deidentification_profile') THEN
        ALTER TABLE "health_data"."health_deidentification_runs" RENAME CONSTRAINT "fk_health_deidentification_runs_health_deidentification_profile" TO "fk_health_deidentification_runs_health_deidentificatio_32e15d81";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='health_data' AND t.relname='health_terminology_mapping_rules' AND c.conname='fk_health_terminology_mapping_rules_health_terminology_mapping_') THEN
        ALTER TABLE "health_data"."health_terminology_mapping_rules" RENAME CONSTRAINT "fk_health_terminology_mapping_rules_health_terminology_mapping_" TO "fk_health_terminology_mapping_rules_health_terminology_8892ed0e";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='identity_assurance' AND t.relname='identity_verification_attempts' AND c.conname='fk_identity_verification_attempts_identity_authority_endpoint_i') THEN
        ALTER TABLE "identity_assurance"."identity_verification_attempts" RENAME CONSTRAINT "fk_identity_verification_attempts_identity_authority_endpoint_i" TO "fk_identity_verification_attempts_identity_authority_e_91da2d59";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='identity_assurance' AND t.relname='identity_verification_cases' AND c.conname='fk_identity_verification_cases_requested_assurance_level_concep') THEN
        ALTER TABLE "identity_assurance"."identity_verification_cases" RENAME CONSTRAINT "fk_identity_verification_cases_requested_assurance_level_concep" TO "fk_identity_verification_cases_requested_assurance_lev_ee8e6b18";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='identity_assurance' AND t.relname='identity_verification_policies' AND c.conname='fk_identity_verification_policies_required_authenticator_assura') THEN
        ALTER TABLE "identity_assurance"."identity_verification_policies" RENAME CONSTRAINT "fk_identity_verification_policies_required_authenticator_assura" TO "fk_identity_verification_policies_required_authenticat_3b11417d";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='identity_assurance' AND t.relname='identity_verification_policies' AND c.conname='fk_identity_verification_policies_required_federation_assurance') THEN
        ALTER TABLE "identity_assurance"."identity_verification_policies" RENAME CONSTRAINT "fk_identity_verification_policies_required_federation_assurance" TO "fk_identity_verification_policies_required_federation__a77e7044";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='identity_assurance' AND t.relname='identity_verification_policies' AND c.conname='fk_identity_verification_policies_required_identity_assurance_l') THEN
        ALTER TABLE "identity_assurance"."identity_verification_policies" RENAME CONSTRAINT "fk_identity_verification_policies_required_identity_assurance_l" TO "fk_identity_verification_policies_required_identity_as_75460293";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='insurance' AND t.relname='coverage_eligibility_requests' AND c.conname='fk_coverage_eligibility_requests_requesting_provider_type_conce') THEN
        ALTER TABLE "insurance"."coverage_eligibility_requests" RENAME CONSTRAINT "fk_coverage_eligibility_requests_requesting_provider_type_conce" TO "fk_coverage_eligibility_requests_requesting_provider_t_48adc63f";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='insurance' AND t.relname='coverage_eligibility_responses' AND c.conname='fk_coverage_eligibility_responses_coverage_eligibility_request_') THEN
        ALTER TABLE "insurance"."coverage_eligibility_responses" RENAME CONSTRAINT "fk_coverage_eligibility_responses_coverage_eligibility_request_" TO "fk_coverage_eligibility_responses_coverage_eligibility_13062047";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='insurance' AND t.relname='insurance_reconciliation_items' AND c.conname='fk_insurance_reconciliation_items_insurance_reconciliation_batc') THEN
        ALTER TABLE "insurance"."insurance_reconciliation_items" RENAME CONSTRAINT "fk_insurance_reconciliation_items_insurance_reconciliation_batc" TO "fk_insurance_reconciliation_items_insurance_reconcilia_c4896cd0";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='insurance' AND t.relname='patient_explanations_of_benefit' AND c.conname='fk_patient_explanations_of_benefit_claim_adjudication_version_i') THEN
        ALTER TABLE "insurance"."patient_explanations_of_benefit" RENAME CONSTRAINT "fk_patient_explanations_of_benefit_claim_adjudication_version_i" TO "fk_patient_explanations_of_benefit_claim_adjudication__6194b135";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='insurance' AND t.relname='prior_authorization_determinations' AND c.conname='fk_prior_authorization_determinations_prior_authorization_item_') THEN
        ALTER TABLE "insurance"."prior_authorization_determinations" RENAME CONSTRAINT "fk_prior_authorization_determinations_prior_authorization_item_" TO "fk_prior_authorization_determinations_prior_authorizat_cbb60fad";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='insurance' AND t.relname='prior_authorization_determinations' AND c.conname='fk_prior_authorization_determinations_prior_authorization_reque') THEN
        ALTER TABLE "insurance"."prior_authorization_determinations" RENAME CONSTRAINT "fk_prior_authorization_determinations_prior_authorization_reque" TO "fk_prior_authorization_determinations_prior_authorizat_e32a5f15";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='insurance' AND t.relname='prior_authorization_requests' AND c.conname='fk_prior_authorization_requests_requesting_provider_type_concep') THEN
        ALTER TABLE "insurance"."prior_authorization_requests" RENAME CONSTRAINT "fk_prior_authorization_requests_requesting_provider_type_concep" TO "fk_prior_authorization_requests_requesting_provider_ty_cccf5fb5";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='messaging' AND t.relname='adapter_tracking_capabilities' AND c.conname='fk_adapter_tracking_capabilities_canonical_event_type_concept_i') THEN
        ALTER TABLE "messaging"."adapter_tracking_capabilities" RENAME CONSTRAINT "fk_adapter_tracking_capabilities_canonical_event_type_concept_i" TO "fk_adapter_tracking_capabilities_canonical_event_type__d17e0ee5";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='pharmacy' AND t.relname='pharmacy_external_product_mappings' AND c.conname='fk_pharmacy_external_product_mappings_pharmacy_integration_conn') THEN
        ALTER TABLE "pharmacy"."pharmacy_external_product_mappings" RENAME CONSTRAINT "fk_pharmacy_external_product_mappings_pharmacy_integration_conn" TO "fk_pharmacy_external_product_mappings_pharmacy_integra_79e91ab7";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='pharmacy' AND t.relname='pharmacy_external_product_mappings' AND c.conname='fk_pharmacy_external_product_mappings_verification_status_conce') THEN
        ALTER TABLE "pharmacy"."pharmacy_external_product_mappings" RENAME CONSTRAINT "fk_pharmacy_external_product_mappings_verification_status_conce" TO "fk_pharmacy_external_product_mappings_verification_sta_0e29f411";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='pharmacy' AND t.relname='pharmacy_integration_connections' AND c.conname='fk_pharmacy_integration_connections_inventory_authority_concept') THEN
        ALTER TABLE "pharmacy"."pharmacy_integration_connections" RENAME CONSTRAINT "fk_pharmacy_integration_connections_inventory_authority_concept" TO "fk_pharmacy_integration_connections_inventory_authorit_3c66cc96";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='pharmacy_inventory' AND t.relname='pharmacy_inventory_sync_batches' AND c.conname='fk_pharmacy_inventory_sync_batches_pharmacy_integration_connect') THEN
        ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_batches" RENAME CONSTRAINT "fk_pharmacy_inventory_sync_batches_pharmacy_integration_connect" TO "fk_pharmacy_inventory_sync_batches_pharmacy_integratio_81168ea5";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='pharmacy_inventory' AND t.relname='pharmacy_inventory_sync_items' AND c.conname='fk_pharmacy_inventory_sync_items_pharmacy_inventory_sync_batch_') THEN
        ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_items" RENAME CONSTRAINT "fk_pharmacy_inventory_sync_items_pharmacy_inventory_sync_batch_" TO "fk_pharmacy_inventory_sync_items_pharmacy_inventory_sy_5a88ae55";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='pharmacy_inventory' AND t.relname='pharmacy_inventory_sync_items' AND c.conname='fk_pharmacy_inventory_sync_items_reconciliation_status_concept_') THEN
        ALTER TABLE "pharmacy_inventory"."pharmacy_inventory_sync_items" RENAME CONSTRAINT "fk_pharmacy_inventory_sync_items_reconciliation_status_concept_" TO "fk_pharmacy_inventory_sync_items_reconciliation_status_d2a662cb";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='practice' AND t.relname='practitioner_role_assignments' AND c.conname='fk_practitioner_role_assignments_supervisor_practitioner_profil') THEN
        ALTER TABLE "practice"."practitioner_role_assignments" RENAME CONSTRAINT "fk_practitioner_role_assignments_supervisor_practitioner_profil" TO "fk_practitioner_role_assignments_supervisor_practition_9edea495";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='practice' AND t.relname='practitioner_support_assignments' AND c.conname='fk_practitioner_support_assignments_practitioner_role_assignmen') THEN
        ALTER TABLE "practice"."practitioner_support_assignments" RENAME CONSTRAINT "fk_practitioner_support_assignments_practitioner_role_assignmen" TO "fk_practitioner_support_assignments_practitioner_role__75362a27";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='procedures_perioperative' AND t.relname='operating_room_utilization_events' AND c.conname='fk_operating_room_utilization_events_turnover_category_concept_') THEN
        ALTER TABLE "procedures_perioperative"."operating_room_utilization_events" RENAME CONSTRAINT "fk_operating_room_utilization_events_turnover_category_concept_" TO "fk_operating_room_utilization_events_turnover_category_c499a812";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='profiles' AND t.relname='health_practitioner_profiles' AND c.conname='fk_health_practitioner_profiles_practitioner_category_concept_i') THEN
        ALTER TABLE "profiles"."health_practitioner_profiles" RENAME CONSTRAINT "fk_health_practitioner_profiles_practitioner_category_concept_i" TO "fk_health_practitioner_profiles_practitioner_category__93fc9ab7";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='profiles' AND t.relname='insurance_representative_profiles' AND c.conname='fk_insurance_representative_profiles_representative_type_concep') THEN
        ALTER TABLE "profiles"."insurance_representative_profiles" RENAME CONSTRAINT "fk_insurance_representative_profiles_representative_type_concep" TO "fk_insurance_representative_profiles_representative_ty_fcc1b52f";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='system_ops' AND t.relname='data_residency_policies' AND c.conname='fk_data_residency_policies_allowed_processing_region_value_set_') THEN
        ALTER TABLE "system_ops"."data_residency_policies" RENAME CONSTRAINT "fk_data_residency_policies_allowed_processing_region_value_set_" TO "fk_data_residency_policies_allowed_processing_region_v_a1fd58dd";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='system_ops' AND t.relname='data_residency_policies' AND c.conname='fk_data_residency_policies_cross_border_transfer_basis_concept_') THEN
        ALTER TABLE "system_ops"."data_residency_policies" RENAME CONSTRAINT "fk_data_residency_policies_cross_border_transfer_basis_concept_" TO "fk_data_residency_policies_cross_border_transfer_basis_0c78b8b0";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='system_ops' AND t.relname='tenant_residency_bindings' AND c.conname='fk_tenant_residency_bindings_disaster_recovery_region_concept_i') THEN
        ALTER TABLE "system_ops"."tenant_residency_bindings" RENAME CONSTRAINT "fk_tenant_residency_bindings_disaster_recovery_region_concept_i" TO "fk_tenant_residency_bindings_disaster_recovery_region__6263dcd1";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='telemetry' AND t.relname='activity_event_schema_definitions' AND c.conname='fk_activity_event_schema_definitions_pii_classification_concept') THEN
        ALTER TABLE "telemetry"."activity_event_schema_definitions" RENAME CONSTRAINT "fk_activity_event_schema_definitions_pii_classification_concept" TO "fk_activity_event_schema_definitions_pii_classificatio_cf444a2d";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='telemetry' AND t.relname='tracking_disclosure_acceptances' AND c.conname='fk_tracking_disclosure_acceptances_tracking_disclosure_version_') THEN
        ALTER TABLE "telemetry"."tracking_disclosure_acceptances" RENAME CONSTRAINT "fk_tracking_disclosure_acceptances_tracking_disclosure_version_" TO "fk_tracking_disclosure_acceptances_tracking_disclosure_fc01b619";
    END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid
               JOIN pg_namespace n ON n.oid=t.relnamespace
               WHERE n.nspname='telemetry' AND t.relname='user_activity_event_properties' AND c.conname='fk_user_activity_event_properties_data_classification_concept_i') THEN
        ALTER TABLE "telemetry"."user_activity_event_properties" RENAME CONSTRAINT "fk_user_activity_event_properties_data_classification_concept_i" TO "fk_user_activity_event_properties_data_classification__e558232d";
    END IF;
END $$;

ALTER INDEX IF EXISTS "messaging"."ix_adapter_tracking_capabilities_canonical_event_type_concept_i" RENAME TO "ix_adapter_tracking_capabilities_canonical_event_type__3130fd8b";
