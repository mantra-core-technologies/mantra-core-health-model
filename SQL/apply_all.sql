-- apply_all.sql — GENERADO por gen_apply.py. Aplica todo el SQL relacional
-- MENOS los 90_fk_deferred (aplicar esos al final, con todos los schemas creados).
-- Uso:  psql -v ON_ERROR_STOP=1 -U salud -d salud -f SQL/apply_all.sql
\set ON_ERROR_STOP on
\timing on

\echo >>> 00_shared/00_types.sql
\ir 00_shared/00_types.sql
\echo >>> _integrity/00_integrity_functions.sql
\ir _integrity/00_integrity_functions.sql

-- ═══ módulo 00_platform ═══
\echo >>> 00_platform/01_schema.sql
\ir 00_platform/01_schema.sql
\echo >>> 00_platform/02_tables.sql
\ir 00_platform/02_tables.sql
\echo >>> 00_platform/03_fk_intra.sql
\ir 00_platform/03_fk_intra.sql
\echo >>> 00_platform/04_indexes.sql
\ir 00_platform/04_indexes.sql

-- ═══ módulo 01_iam ═══
\echo >>> 01_iam/01_schema.sql
\ir 01_iam/01_schema.sql
\echo >>> 01_iam/02_tables.sql
\ir 01_iam/02_tables.sql
\echo >>> 01_iam/03_fk_intra.sql
\ir 01_iam/03_fk_intra.sql
\echo >>> 01_iam/04_indexes.sql
\ir 01_iam/04_indexes.sql

-- ═══ módulo 02_common ═══
\echo >>> 02_common/01_schema.sql
\ir 02_common/01_schema.sql
\echo >>> 02_common/02_tables.sql
\ir 02_common/02_tables.sql
\echo >>> 02_common/03_fk_intra.sql
\ir 02_common/03_fk_intra.sql
\echo >>> 02_common/04_indexes.sql
\ir 02_common/04_indexes.sql

-- ═══ módulo 03_terminology ═══
\echo >>> 03_terminology/01_schema.sql
\ir 03_terminology/01_schema.sql
\echo >>> 03_terminology/02_tables.sql
\ir 03_terminology/02_tables.sql
\echo >>> 03_terminology/03_fk_intra.sql
\ir 03_terminology/03_fk_intra.sql
\echo >>> 03_terminology/04_indexes.sql
\ir 03_terminology/04_indexes.sql

-- ═══ módulo 04_directory ═══
\echo >>> 04_directory/01_schema.sql
\ir 04_directory/01_schema.sql
\echo >>> 04_directory/02_tables.sql
\ir 04_directory/02_tables.sql
\echo >>> 04_directory/03_fk_intra.sql
\ir 04_directory/03_fk_intra.sql
\echo >>> 04_directory/04_indexes.sql
\ir 04_directory/04_indexes.sql

-- ═══ módulo 05_profiles ═══
\echo >>> 05_profiles/01_schema.sql
\ir 05_profiles/01_schema.sql
\echo >>> 05_profiles/02_tables.sql
\ir 05_profiles/02_tables.sql
\echo >>> 05_profiles/03_fk_intra.sql
\ir 05_profiles/03_fk_intra.sql
\echo >>> 05_profiles/04_indexes.sql
\ir 05_profiles/04_indexes.sql

-- ═══ módulo 06_authz ═══
\echo >>> 06_authz/01_schema.sql
\ir 06_authz/01_schema.sql
\echo >>> 06_authz/02_tables.sql
\ir 06_authz/02_tables.sql
\echo >>> 06_authz/03_fk_intra.sql
\ir 06_authz/03_fk_intra.sql
\echo >>> 06_authz/04_indexes.sql
\ir 06_authz/04_indexes.sql

-- ═══ módulo 07_consent ═══
\echo >>> 07_consent/01_schema.sql
\ir 07_consent/01_schema.sql
\echo >>> 07_consent/02_tables.sql
\ir 07_consent/02_tables.sql
\echo >>> 07_consent/03_fk_intra.sql
\ir 07_consent/03_fk_intra.sql
\echo >>> 07_consent/04_indexes.sql
\ir 07_consent/04_indexes.sql

-- ═══ módulo 08_clinical ═══
\echo >>> 08_clinical/01_schema.sql
\ir 08_clinical/01_schema.sql
\echo >>> 08_clinical/02_tables.sql
\ir 08_clinical/02_tables.sql
\echo >>> 08_clinical/03_fk_intra.sql
\ir 08_clinical/03_fk_intra.sql
\echo >>> 08_clinical/04_indexes.sql
\ir 08_clinical/04_indexes.sql
\echo >>> 08_clinical/05_constraints.sql
\ir 08_clinical/05_constraints.sql

-- ═══ módulo 09_forms ═══
\echo >>> 09_forms/01_schema.sql
\ir 09_forms/01_schema.sql
\echo >>> 09_forms/02_tables.sql
\ir 09_forms/02_tables.sql
\echo >>> 09_forms/03_fk_intra.sql
\ir 09_forms/03_fk_intra.sql
\echo >>> 09_forms/04_indexes.sql
\ir 09_forms/04_indexes.sql

-- ═══ módulo 10_audit ═══
\echo >>> 10_audit/01_schema.sql
\ir 10_audit/01_schema.sql
\echo >>> 10_audit/02_tables.sql
\ir 10_audit/02_tables.sql
\echo >>> 10_audit/03_fk_intra.sql
\ir 10_audit/03_fk_intra.sql
\echo >>> 10_audit/04_indexes.sql
\ir 10_audit/04_indexes.sql
\echo >>> 10_audit/05_constraints.sql
\ir 10_audit/05_constraints.sql

-- ═══ módulo 11_system_ops ═══
\echo >>> 11_system_ops/01_schema.sql
\ir 11_system_ops/01_schema.sql
\echo >>> 11_system_ops/02_tables.sql
\ir 11_system_ops/02_tables.sql
\echo >>> 11_system_ops/03_fk_intra.sql
\ir 11_system_ops/03_fk_intra.sql
\echo >>> 11_system_ops/04_indexes.sql
\ir 11_system_ops/04_indexes.sql

-- ═══ módulo 12_integrations ═══
\echo >>> 12_integrations/01_schema.sql
\ir 12_integrations/01_schema.sql
\echo >>> 12_integrations/02_tables.sql
\ir 12_integrations/02_tables.sql
\echo >>> 12_integrations/03_fk_intra.sql
\ir 12_integrations/03_fk_intra.sql
\echo >>> 12_integrations/04_indexes.sql
\ir 12_integrations/04_indexes.sql

-- ═══ módulo 13_geo ═══
\echo >>> 13_geo/01_schema.sql
\ir 13_geo/01_schema.sql
\echo >>> 13_geo/02_tables.sql
\ir 13_geo/02_tables.sql
\echo >>> 13_geo/03_fk_intra.sql
\ir 13_geo/03_fk_intra.sql
\echo >>> 13_geo/04_indexes.sql
\ir 13_geo/04_indexes.sql

-- ═══ módulo 14_practice ═══
\echo >>> 14_practice/01_schema.sql
\ir 14_practice/01_schema.sql
\echo >>> 14_practice/02_tables.sql
\ir 14_practice/02_tables.sql
\echo >>> 14_practice/03_fk_intra.sql
\ir 14_practice/03_fk_intra.sql
\echo >>> 14_practice/04_indexes.sql
\ir 14_practice/04_indexes.sql

-- ═══ módulo 15_chart ═══
\echo >>> 15_chart/01_schema.sql
\ir 15_chart/01_schema.sql
\echo >>> 15_chart/02_tables.sql
\ir 15_chart/02_tables.sql
\echo >>> 15_chart/03_fk_intra.sql
\ir 15_chart/03_fk_intra.sql
\echo >>> 15_chart/04_indexes.sql
\ir 15_chart/04_indexes.sql

-- ═══ módulo 16_accounting ═══
\echo >>> 16_accounting/01_schema.sql
\ir 16_accounting/01_schema.sql
\echo >>> 16_accounting/02_tables.sql
\ir 16_accounting/02_tables.sql
\echo >>> 16_accounting/03_fk_intra.sql
\ir 16_accounting/03_fk_intra.sql
\echo >>> 16_accounting/04_indexes.sql
\ir 16_accounting/04_indexes.sql

-- ═══ módulo 17_billing ═══
\echo >>> 17_billing/01_schema.sql
\ir 17_billing/01_schema.sql
\echo >>> 17_billing/02_tables.sql
\ir 17_billing/02_tables.sql
\echo >>> 17_billing/03_fk_intra.sql
\ir 17_billing/03_fk_intra.sql
\echo >>> 17_billing/04_indexes.sql
\ir 17_billing/04_indexes.sql

-- ═══ módulo 18_clinical_ext ═══
\echo >>> 18_clinical_ext/01_schema.sql
\ir 18_clinical_ext/01_schema.sql
\echo >>> 18_clinical_ext/02_tables.sql
\ir 18_clinical_ext/02_tables.sql
\echo >>> 18_clinical_ext/03_fk_intra.sql
\ir 18_clinical_ext/03_fk_intra.sql
\echo >>> 18_clinical_ext/04_indexes.sql
\ir 18_clinical_ext/04_indexes.sql

-- ═══ módulo 19_community ═══
\echo >>> 19_community/01_schema.sql
\ir 19_community/01_schema.sql
\echo >>> 19_community/02_tables.sql
\ir 19_community/02_tables.sql
\echo >>> 19_community/03_fk_intra.sql
\ir 19_community/03_fk_intra.sql
\echo >>> 19_community/04_indexes.sql
\ir 19_community/04_indexes.sql

-- ═══ módulo 20_diagnostics ═══
\echo >>> 20_diagnostics/01_schema.sql
\ir 20_diagnostics/01_schema.sql
\echo >>> 20_diagnostics/02_tables.sql
\ir 20_diagnostics/02_tables.sql
\echo >>> 20_diagnostics/03_fk_intra.sql
\ir 20_diagnostics/03_fk_intra.sql
\echo >>> 20_diagnostics/04_indexes.sql
\ir 20_diagnostics/04_indexes.sql

-- ═══ módulo 22_organization_extensions ═══
\echo >>> 22_organization_extensions/01_schema.sql
\ir 22_organization_extensions/01_schema.sql
\echo >>> 22_organization_extensions/02_tables.sql
\ir 22_organization_extensions/02_tables.sql
\echo >>> 22_organization_extensions/03_fk_intra.sql
\ir 22_organization_extensions/03_fk_intra.sql
\echo >>> 22_organization_extensions/04_indexes.sql
\ir 22_organization_extensions/04_indexes.sql

-- ═══ módulo 23_diagnostic_units ═══
\echo >>> 23_diagnostic_units/01_schema.sql
\ir 23_diagnostic_units/01_schema.sql
\echo >>> 23_diagnostic_units/02_tables.sql
\ir 23_diagnostic_units/02_tables.sql
\echo >>> 23_diagnostic_units/03_fk_intra.sql
\ir 23_diagnostic_units/03_fk_intra.sql
\echo >>> 23_diagnostic_units/04_indexes.sql
\ir 23_diagnostic_units/04_indexes.sql
\echo >>> 23_diagnostic_units/05_constraints.sql
\ir 23_diagnostic_units/05_constraints.sql

-- ═══ módulo 24_pharmacy ═══
\echo >>> 24_pharmacy/01_schema.sql
\ir 24_pharmacy/01_schema.sql
\echo >>> 24_pharmacy/02_tables.sql
\ir 24_pharmacy/02_tables.sql
\echo >>> 24_pharmacy/03_fk_intra.sql
\ir 24_pharmacy/03_fk_intra.sql
\echo >>> 24_pharmacy/04_indexes.sql
\ir 24_pharmacy/04_indexes.sql

-- ═══ módulo 25_pharmacy_inventory ═══
\echo >>> 25_pharmacy_inventory/01_schema.sql
\ir 25_pharmacy_inventory/01_schema.sql
\echo >>> 25_pharmacy_inventory/02_tables.sql
\ir 25_pharmacy_inventory/02_tables.sql
\echo >>> 25_pharmacy_inventory/03_fk_intra.sql
\ir 25_pharmacy_inventory/03_fk_intra.sql
\echo >>> 25_pharmacy_inventory/04_indexes.sql
\ir 25_pharmacy_inventory/04_indexes.sql
\echo >>> 25_pharmacy_inventory/05_constraints.sql
\ir 25_pharmacy_inventory/05_constraints.sql

-- ═══ módulo 26_insurance ═══
\echo >>> 26_insurance/01_schema.sql
\ir 26_insurance/01_schema.sql
\echo >>> 26_insurance/02_tables.sql
\ir 26_insurance/02_tables.sql
\echo >>> 26_insurance/03_fk_intra.sql
\ir 26_insurance/03_fk_intra.sql
\echo >>> 26_insurance/04_indexes.sql
\ir 26_insurance/04_indexes.sql
\echo >>> 26_insurance/05_constraints.sql
\ir 26_insurance/05_constraints.sql

-- ═══ módulo 27_identity_assurance ═══
\echo >>> 27_identity_assurance/01_schema.sql
\ir 27_identity_assurance/01_schema.sql
\echo >>> 27_identity_assurance/02_tables.sql
\ir 27_identity_assurance/02_tables.sql
\echo >>> 27_identity_assurance/03_fk_intra.sql
\ir 27_identity_assurance/03_fk_intra.sql
\echo >>> 27_identity_assurance/04_indexes.sql
\ir 27_identity_assurance/04_indexes.sql
\echo >>> 27_identity_assurance/05_constraints.sql
\ir 27_identity_assurance/05_constraints.sql

-- ═══ módulo 28_telemetry ═══
\echo >>> 28_telemetry/01_schema.sql
\ir 28_telemetry/01_schema.sql
\echo >>> 28_telemetry/02_tables.sql
\ir 28_telemetry/02_tables.sql
\echo >>> 28_telemetry/03_fk_intra.sql
\ir 28_telemetry/03_fk_intra.sql
\echo >>> 28_telemetry/04_indexes.sql
\ir 28_telemetry/04_indexes.sql
\echo >>> 28_telemetry/05_constraints.sql
\ir 28_telemetry/05_constraints.sql

-- ═══ módulo 29_delegated_access ═══
\echo >>> 29_delegated_access/01_schema.sql
\ir 29_delegated_access/01_schema.sql
\echo >>> 29_delegated_access/02_tables.sql
\ir 29_delegated_access/02_tables.sql
\echo >>> 29_delegated_access/03_fk_intra.sql
\ir 29_delegated_access/03_fk_intra.sql
\echo >>> 29_delegated_access/04_indexes.sql
\ir 29_delegated_access/04_indexes.sql
\echo >>> 29_delegated_access/05_constraints.sql
\ir 29_delegated_access/05_constraints.sql

-- ═══ módulo 30_read_models ═══
\echo >>> 30_read_models/01_schema.sql
\ir 30_read_models/01_schema.sql
\echo >>> 30_read_models/02_tables.sql
\ir 30_read_models/02_tables.sql
\echo >>> 30_read_models/03_fk_intra.sql
\ir 30_read_models/03_fk_intra.sql
\echo >>> 30_read_models/04_indexes.sql
\ir 30_read_models/04_indexes.sql

-- ═══ módulo 31_integration_contracts ═══
\echo >>> 31_integration_contracts/01_schema.sql
\ir 31_integration_contracts/01_schema.sql
\echo >>> 31_integration_contracts/02_tables.sql
\ir 31_integration_contracts/02_tables.sql
\echo >>> 31_integration_contracts/03_fk_intra.sql
\ir 31_integration_contracts/03_fk_intra.sql
\echo >>> 31_integration_contracts/04_indexes.sql
\ir 31_integration_contracts/04_indexes.sql

-- ═══ módulo 32_workflow ═══
\echo >>> 32_workflow/01_schema.sql
\ir 32_workflow/01_schema.sql
\echo >>> 32_workflow/02_tables.sql
\ir 32_workflow/02_tables.sql
\echo >>> 32_workflow/03_fk_intra.sql
\ir 32_workflow/03_fk_intra.sql
\echo >>> 32_workflow/04_indexes.sql
\ir 32_workflow/04_indexes.sql

-- ═══ módulo 35_messaging ═══
\echo >>> 35_messaging/01_schema.sql
\ir 35_messaging/01_schema.sql
\echo >>> 35_messaging/02_tables.sql
\ir 35_messaging/02_tables.sql
\echo >>> 35_messaging/03_fk_intra.sql
\ir 35_messaging/03_fk_intra.sql
\echo >>> 35_messaging/04_indexes.sql
\ir 35_messaging/04_indexes.sql

-- ═══ módulo 36_qa_lab ═══
\echo >>> 36_qa_lab/01_schema.sql
\ir 36_qa_lab/01_schema.sql
\echo >>> 36_qa_lab/02_tables.sql
\ir 36_qa_lab/02_tables.sql
\echo >>> 36_qa_lab/03_fk_intra.sql
\ir 36_qa_lab/03_fk_intra.sql
\echo >>> 36_qa_lab/04_indexes.sql
\ir 36_qa_lab/04_indexes.sql

-- ═══ módulo 37_tracking ═══
\echo >>> 37_tracking/01_schema.sql
\ir 37_tracking/01_schema.sql
\echo >>> 37_tracking/02_tables.sql
\ir 37_tracking/02_tables.sql
\echo >>> 37_tracking/03_fk_intra.sql
\ir 37_tracking/03_fk_intra.sql
\echo >>> 37_tracking/04_indexes.sql
\ir 37_tracking/04_indexes.sql

-- ═══ módulo 38_erp ═══
\echo >>> 38_erp/01_schema.sql
\ir 38_erp/01_schema.sql
\echo >>> 38_erp/02_tables.sql
\ir 38_erp/02_tables.sql
\echo >>> 38_erp/03_fk_intra.sql
\ir 38_erp/03_fk_intra.sql
\echo >>> 38_erp/04_indexes.sql
\ir 38_erp/04_indexes.sql

-- ═══ módulo 39_reporting ═══
\echo >>> 39_reporting/01_schema.sql
\ir 39_reporting/01_schema.sql
\echo >>> 39_reporting/02_tables.sql
\ir 39_reporting/02_tables.sql
\echo >>> 39_reporting/03_fk_intra.sql
\ir 39_reporting/03_fk_intra.sql
\echo >>> 39_reporting/04_indexes.sql
\ir 39_reporting/04_indexes.sql

-- ═══ módulo 40_auth_providers ═══
\echo >>> 40_auth_providers/01_schema.sql
\ir 40_auth_providers/01_schema.sql
\echo >>> 40_auth_providers/02_tables.sql
\ir 40_auth_providers/02_tables.sql
\echo >>> 40_auth_providers/03_fk_intra.sql
\ir 40_auth_providers/03_fk_intra.sql
\echo >>> 40_auth_providers/04_indexes.sql
\ir 40_auth_providers/04_indexes.sql

-- ═══ módulo 41_scheduling ═══
\echo >>> 41_scheduling/01_schema.sql
\ir 41_scheduling/01_schema.sql
\echo >>> 41_scheduling/02_tables.sql
\ir 41_scheduling/02_tables.sql
\echo >>> 41_scheduling/03_fk_intra.sql
\ir 41_scheduling/03_fk_intra.sql
\echo >>> 41_scheduling/04_indexes.sql
\ir 41_scheduling/04_indexes.sql

-- ═══ módulo 42_payments ═══
\echo >>> 42_payments/01_schema.sql
\ir 42_payments/01_schema.sql
\echo >>> 42_payments/02_tables.sql
\ir 42_payments/02_tables.sql
\echo >>> 42_payments/03_fk_intra.sql
\ir 42_payments/03_fk_intra.sql
\echo >>> 42_payments/04_indexes.sql
\ir 42_payments/04_indexes.sql

-- ═══ módulo 43_ads ═══
\echo >>> 43_ads/01_schema.sql
\ir 43_ads/01_schema.sql
\echo >>> 43_ads/02_tables.sql
\ir 43_ads/02_tables.sql
\echo >>> 43_ads/03_fk_intra.sql
\ir 43_ads/03_fk_intra.sql
\echo >>> 43_ads/04_indexes.sql
\ir 43_ads/04_indexes.sql

-- ═══ módulo 44_health_context ═══
\echo >>> 44_health_context/01_schema.sql
\ir 44_health_context/01_schema.sql
\echo >>> 44_health_context/02_tables.sql
\ir 44_health_context/02_tables.sql
\echo >>> 44_health_context/03_fk_intra.sql
\ir 44_health_context/03_fk_intra.sql
\echo >>> 44_health_context/04_indexes.sql
\ir 44_health_context/04_indexes.sql

-- ═══ módulo 45_system_context ═══
\echo >>> 45_system_context/01_schema.sql
\ir 45_system_context/01_schema.sql
\echo >>> 45_system_context/02_tables.sql
\ir 45_system_context/02_tables.sql
\echo >>> 45_system_context/03_fk_intra.sql
\ir 45_system_context/03_fk_intra.sql
\echo >>> 45_system_context/04_indexes.sql
\ir 45_system_context/04_indexes.sql

-- ═══ módulo 46_platform_ops ═══
\echo >>> 46_platform_ops/01_schema.sql
\ir 46_platform_ops/01_schema.sql
\echo >>> 46_platform_ops/02_tables.sql
\ir 46_platform_ops/02_tables.sql
\echo >>> 46_platform_ops/03_fk_intra.sql
\ir 46_platform_ops/03_fk_intra.sql
\echo >>> 46_platform_ops/04_indexes.sql
\ir 46_platform_ops/04_indexes.sql

-- ═══ módulo 47_education ═══
\echo >>> 47_education/01_schema.sql
\ir 47_education/01_schema.sql
\echo >>> 47_education/02_tables.sql
\ir 47_education/02_tables.sql
\echo >>> 47_education/03_fk_intra.sql
\ir 47_education/03_fk_intra.sql
\echo >>> 47_education/04_indexes.sql
\ir 47_education/04_indexes.sql

-- ═══ módulo 48_automation ═══
\echo >>> 48_automation/01_schema.sql
\ir 48_automation/01_schema.sql
\echo >>> 48_automation/02_tables.sql
\ir 48_automation/02_tables.sql
\echo >>> 48_automation/03_fk_intra.sql
\ir 48_automation/03_fk_intra.sql
\echo >>> 48_automation/04_indexes.sql
\ir 48_automation/04_indexes.sql

-- ═══ módulo 49_crm ═══
\echo >>> 49_crm/01_schema.sql
\ir 49_crm/01_schema.sql
\echo >>> 49_crm/02_tables.sql
\ir 49_crm/02_tables.sql
\echo >>> 49_crm/03_fk_intra.sql
\ir 49_crm/03_fk_intra.sql
\echo >>> 49_crm/04_indexes.sql
\ir 49_crm/04_indexes.sql

-- ═══ módulo 50_marketing ═══
\echo >>> 50_marketing/01_schema.sql
\ir 50_marketing/01_schema.sql
\echo >>> 50_marketing/02_tables.sql
\ir 50_marketing/02_tables.sql
\echo >>> 50_marketing/03_fk_intra.sql
\ir 50_marketing/03_fk_intra.sql
\echo >>> 50_marketing/04_indexes.sql
\ir 50_marketing/04_indexes.sql

-- ═══ módulo 51_promotions ═══
\echo >>> 51_promotions/01_schema.sql
\ir 51_promotions/01_schema.sql
\echo >>> 51_promotions/02_tables.sql
\ir 51_promotions/02_tables.sql
\echo >>> 51_promotions/03_fk_intra.sql
\ir 51_promotions/03_fk_intra.sql
\echo >>> 51_promotions/04_indexes.sql
\ir 51_promotions/04_indexes.sql

-- ═══ módulo 52_health_data ═══
\echo >>> 52_health_data/01_schema.sql
\ir 52_health_data/01_schema.sql
\echo >>> 52_health_data/02_tables.sql
\ir 52_health_data/02_tables.sql
\echo >>> 52_health_data/03_fk_intra.sql
\ir 52_health_data/03_fk_intra.sql
\echo >>> 52_health_data/04_indexes.sql
\ir 52_health_data/04_indexes.sql

-- ═══ módulo 53_procedures_perioperative ═══
\echo >>> 53_procedures_perioperative/01_schema.sql
\ir 53_procedures_perioperative/01_schema.sql
\echo >>> 53_procedures_perioperative/02_tables.sql
\ir 53_procedures_perioperative/02_tables.sql
\echo >>> 53_procedures_perioperative/03_fk_intra.sql
\ir 53_procedures_perioperative/03_fk_intra.sql
\echo >>> 53_procedures_perioperative/04_indexes.sql
\ir 53_procedures_perioperative/04_indexes.sql

-- ═══ módulo 54_polyglot_storage ═══
\echo >>> 54_polyglot_storage/01_schema.sql
\ir 54_polyglot_storage/01_schema.sql
\echo >>> 54_polyglot_storage/02_tables.sql
\ir 54_polyglot_storage/02_tables.sql
\echo >>> 54_polyglot_storage/03_fk_intra.sql
\ir 54_polyglot_storage/03_fk_intra.sql
\echo >>> 54_polyglot_storage/04_indexes.sql
\ir 54_polyglot_storage/04_indexes.sql

-- ═══ módulo 60_object_storage ═══
\echo >>> 60_object_storage/01_schema.sql
\ir 60_object_storage/01_schema.sql
\echo >>> 60_object_storage/02_tables.sql
\ir 60_object_storage/02_tables.sql
\echo >>> 60_object_storage/03_fk_intra.sql
\ir 60_object_storage/03_fk_intra.sql
\echo >>> 60_object_storage/04_indexes.sql
\ir 60_object_storage/04_indexes.sql

-- ═══ módulo 61_graph_intelligence ═══
\echo >>> 61_graph_intelligence/01_schema.sql
\ir 61_graph_intelligence/01_schema.sql
\echo >>> 61_graph_intelligence/02_tables.sql
\ir 61_graph_intelligence/02_tables.sql
\echo >>> 61_graph_intelligence/03_fk_intra.sql
\ir 61_graph_intelligence/03_fk_intra.sql
\echo >>> 61_graph_intelligence/04_indexes.sql
\ir 61_graph_intelligence/04_indexes.sql

-- ═══ módulo 62_cross_store_consistency ═══
\echo >>> 62_cross_store_consistency/01_schema.sql
\ir 62_cross_store_consistency/01_schema.sql
\echo >>> 62_cross_store_consistency/02_tables.sql
\ir 62_cross_store_consistency/02_tables.sql
\echo >>> 62_cross_store_consistency/03_fk_intra.sql
\ir 62_cross_store_consistency/03_fk_intra.sql
\echo >>> 62_cross_store_consistency/04_indexes.sql
\ir 62_cross_store_consistency/04_indexes.sql

-- ═══ módulo 63_lakehouse ═══
\echo >>> 63_lakehouse/01_schema.sql
\ir 63_lakehouse/01_schema.sql
\echo >>> 63_lakehouse/02_tables.sql
\ir 63_lakehouse/02_tables.sql
\echo >>> 63_lakehouse/03_fk_intra.sql
\ir 63_lakehouse/03_fk_intra.sql
\echo >>> 63_lakehouse/04_indexes.sql
\ir 63_lakehouse/04_indexes.sql

-- ═══ módulo 64_audio_assets ═══
\echo >>> 64_audio_assets/01_schema.sql
\ir 64_audio_assets/01_schema.sql
\echo >>> 64_audio_assets/02_tables.sql
\ir 64_audio_assets/02_tables.sql
\echo >>> 64_audio_assets/03_fk_intra.sql
\ir 64_audio_assets/03_fk_intra.sql
\echo >>> 64_audio_assets/04_indexes.sql
\ir 64_audio_assets/04_indexes.sql

-- ═══ módulo 65_surveys ═══
\echo >>> 65_surveys/01_schema.sql
\ir 65_surveys/01_schema.sql
\echo >>> 65_surveys/02_tables.sql
\ir 65_surveys/02_tables.sql
\echo >>> 65_surveys/03_fk_intra.sql
\ir 65_surveys/03_fk_intra.sql
\echo >>> 65_surveys/04_indexes.sql
\ir 65_surveys/04_indexes.sql

-- 90_fk_deferred.sql OMITIDOS a propósito.
\echo === apply_all completado (sin 90_fk_deferred) ===
