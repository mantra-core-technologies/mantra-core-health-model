-- apply_deferred.sql — GENERADO por gen_apply.py. Aplica SOLO los 90_fk_deferred
-- (FK cross-schema). Requiere apply_all.sql ya aplicado (todos los schemas creados).
-- Uso:  psql -v ON_ERROR_STOP=1 -U salud -d salud -f SQL/apply_deferred.sql
\set ON_ERROR_STOP on
\timing on

\echo >>> 00_platform/90_fk_deferred.sql
\ir 00_platform/90_fk_deferred.sql
\echo >>> 01_iam/90_fk_deferred.sql
\ir 01_iam/90_fk_deferred.sql
\echo >>> 02_common/90_fk_deferred.sql
\ir 02_common/90_fk_deferred.sql
\echo >>> 03_terminology/90_fk_deferred.sql
\ir 03_terminology/90_fk_deferred.sql
\echo >>> 04_directory/90_fk_deferred.sql
\ir 04_directory/90_fk_deferred.sql
\echo >>> 05_profiles/90_fk_deferred.sql
\ir 05_profiles/90_fk_deferred.sql
\echo >>> 06_authz/90_fk_deferred.sql
\ir 06_authz/90_fk_deferred.sql
\echo >>> 07_consent/90_fk_deferred.sql
\ir 07_consent/90_fk_deferred.sql
\echo >>> 08_clinical/90_fk_deferred.sql
\ir 08_clinical/90_fk_deferred.sql
\echo >>> 09_forms/90_fk_deferred.sql
\ir 09_forms/90_fk_deferred.sql
\echo >>> 10_audit/90_fk_deferred.sql
\ir 10_audit/90_fk_deferred.sql
\echo >>> 11_system_ops/90_fk_deferred.sql
\ir 11_system_ops/90_fk_deferred.sql
\echo >>> 12_integrations/90_fk_deferred.sql
\ir 12_integrations/90_fk_deferred.sql
\echo >>> 13_geo/90_fk_deferred.sql
\ir 13_geo/90_fk_deferred.sql
\echo >>> 14_practice/90_fk_deferred.sql
\ir 14_practice/90_fk_deferred.sql
\echo >>> 15_chart/90_fk_deferred.sql
\ir 15_chart/90_fk_deferred.sql
\echo >>> 16_accounting/90_fk_deferred.sql
\ir 16_accounting/90_fk_deferred.sql
\echo >>> 17_billing/90_fk_deferred.sql
\ir 17_billing/90_fk_deferred.sql
\echo >>> 18_clinical_ext/90_fk_deferred.sql
\ir 18_clinical_ext/90_fk_deferred.sql
\echo >>> 19_community/90_fk_deferred.sql
\ir 19_community/90_fk_deferred.sql
\echo >>> 20_diagnostics/90_fk_deferred.sql
\ir 20_diagnostics/90_fk_deferred.sql
\echo >>> 22_organization_extensions/90_fk_deferred.sql
\ir 22_organization_extensions/90_fk_deferred.sql
\echo >>> 23_diagnostic_units/90_fk_deferred.sql
\ir 23_diagnostic_units/90_fk_deferred.sql
\echo >>> 24_pharmacy/90_fk_deferred.sql
\ir 24_pharmacy/90_fk_deferred.sql
\echo >>> 25_pharmacy_inventory/90_fk_deferred.sql
\ir 25_pharmacy_inventory/90_fk_deferred.sql
\echo >>> 26_insurance/90_fk_deferred.sql
\ir 26_insurance/90_fk_deferred.sql
\echo >>> 27_identity_assurance/90_fk_deferred.sql
\ir 27_identity_assurance/90_fk_deferred.sql
\echo >>> 28_telemetry/90_fk_deferred.sql
\ir 28_telemetry/90_fk_deferred.sql
\echo >>> 29_delegated_access/90_fk_deferred.sql
\ir 29_delegated_access/90_fk_deferred.sql
\echo >>> 30_read_models/90_fk_deferred.sql
\ir 30_read_models/90_fk_deferred.sql
\echo >>> 31_integration_contracts/90_fk_deferred.sql
\ir 31_integration_contracts/90_fk_deferred.sql
\echo >>> 32_workflow/90_fk_deferred.sql
\ir 32_workflow/90_fk_deferred.sql
\echo >>> 35_messaging/90_fk_deferred.sql
\ir 35_messaging/90_fk_deferred.sql
\echo >>> 36_qa_lab/90_fk_deferred.sql
\ir 36_qa_lab/90_fk_deferred.sql
\echo >>> 37_tracking/90_fk_deferred.sql
\ir 37_tracking/90_fk_deferred.sql
\echo >>> 38_erp/90_fk_deferred.sql
\ir 38_erp/90_fk_deferred.sql
\echo >>> 39_reporting/90_fk_deferred.sql
\ir 39_reporting/90_fk_deferred.sql
\echo >>> 40_auth_providers/90_fk_deferred.sql
\ir 40_auth_providers/90_fk_deferred.sql
\echo >>> 41_scheduling/90_fk_deferred.sql
\ir 41_scheduling/90_fk_deferred.sql
\echo >>> 42_payments/90_fk_deferred.sql
\ir 42_payments/90_fk_deferred.sql
\echo >>> 43_ads/90_fk_deferred.sql
\ir 43_ads/90_fk_deferred.sql
\echo >>> 44_health_context/90_fk_deferred.sql
\ir 44_health_context/90_fk_deferred.sql
\echo >>> 45_system_context/90_fk_deferred.sql
\ir 45_system_context/90_fk_deferred.sql
\echo >>> 46_platform_ops/90_fk_deferred.sql
\ir 46_platform_ops/90_fk_deferred.sql
\echo >>> 47_education/90_fk_deferred.sql
\ir 47_education/90_fk_deferred.sql
\echo >>> 48_automation/90_fk_deferred.sql
\ir 48_automation/90_fk_deferred.sql
\echo >>> 49_crm/90_fk_deferred.sql
\ir 49_crm/90_fk_deferred.sql
\echo >>> 50_marketing/90_fk_deferred.sql
\ir 50_marketing/90_fk_deferred.sql
\echo >>> 51_promotions/90_fk_deferred.sql
\ir 51_promotions/90_fk_deferred.sql
\echo >>> 52_health_data/90_fk_deferred.sql
\ir 52_health_data/90_fk_deferred.sql
\echo >>> 53_procedures_perioperative/90_fk_deferred.sql
\ir 53_procedures_perioperative/90_fk_deferred.sql
\echo >>> 54_polyglot_storage/90_fk_deferred.sql
\ir 54_polyglot_storage/90_fk_deferred.sql
\echo >>> 60_object_storage/90_fk_deferred.sql
\ir 60_object_storage/90_fk_deferred.sql
\echo >>> 61_graph_intelligence/90_fk_deferred.sql
\ir 61_graph_intelligence/90_fk_deferred.sql
\echo >>> 62_cross_store_consistency/90_fk_deferred.sql
\ir 62_cross_store_consistency/90_fk_deferred.sql
\echo >>> 63_lakehouse/90_fk_deferred.sql
\ir 63_lakehouse/90_fk_deferred.sql
\echo >>> 64_audio_assets/90_fk_deferred.sql
\ir 64_audio_assets/90_fk_deferred.sql
\echo >>> 65_surveys/90_fk_deferred.sql
\ir 65_surveys/90_fk_deferred.sql
\echo === apply_deferred completado ===
