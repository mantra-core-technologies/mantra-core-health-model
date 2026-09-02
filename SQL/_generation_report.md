# Reporte de generación SQL — SALUD v4.0.10

Generado fielmente desde los `.puml`. Solo se emiten tablas PostgreSQL; las vistas, stubs de cruce y stores no-SQL (Redis/Mongo/OpenSearch/vector/timeseries) se listan como *saltados*. Graph (61) y Lakehouse (63) SÍ se materializan como tablas PG (catálogo del plano de control). Las FK marcadas *inferidas* se resolvieron por convención cuando el vault no tenía destino.

| Mód | Schema | Tablas PG | FK | (inferidas) | Índices | Saltadas |
|-----|--------|-----------|----|-------------|---------|----------|
| 00 | platform _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 0 |
| 01 | iam | 14 | 75 | 13 | 65 | 0 |
| 02 | common | 7 | 48 | 0 | 52 | 0 |
| 03 | terminology | 15 | 69 | 0 | 88 | 0 |
| 04 | directory | 7 | 55 | 0 | 51 | 0 |
| 05 | profiles | 19 | 125 | 0 | 134 | 0 |
| 06 | authz | 15 | 100 | 15 | 90 | 0 |
| 07 | consent | 10 | 81 | 0 | 101 | 0 |
| 08 | clinical | 22 | 214 | 6 | 236 | 0 |
| 09 | forms | 16 | 103 | 0 | 113 | 1 |
| 10 | audit | 123 | 513 | 0 | 653 | 0 |
| 11 | system_ops | 29 | 169 | 0 | 178 | 0 |
| 12 | integrations | 10 | 49 | 0 | 55 | 0 |
| 13 | geo | 6 | 31 | 0 | 35 | 0 |
| 14 | practice | 11 | 80 | 0 | 84 | 0 |
| 15 | chart | 11 | 70 | 0 | 80 | 1 |
| 16 | accounting | 42 | 304 | 1 | 356 | 13 |
| 17 | billing | 20 | 140 | 0 | 156 | 17 |
| 18 | clinical_ext | 13 | 91 | 0 | 101 | 1 |
| 19 | community | 38 | 233 | 0 | 244 | 1 |
| 20 | diagnostics | 36 | 251 | 0 | 301 | 0 |
| 21 | deployment _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 0 |
| 22 | organization_extensions | 5 | 49 | 0 | 55 | 0 |
| 23 | diagnostic_units | 10 | 69 | 0 | 77 | 0 |
| 24 | pharmacy | 9 | 64 | 0 | 72 | 0 |
| 25 | pharmacy_inventory | 20 | 141 | 0 | 154 | 6 |
| 26 | insurance | 29 | 187 | 0 | 206 | 0 |
| 27 | identity_assurance | 11 | 69 | 0 | 76 | 0 |
| 28 | telemetry | 14 | 73 | 0 | 83 | 0 |
| 29 | delegated_access | 7 | 51 | 0 | 57 | 0 |
| 30 | read_models | 13 | 74 | 0 | 89 | 76 |
| 31 | integration_contracts | 9 | 47 | 0 | 55 | 0 |
| 32 | workflow | 8 | 49 | 0 | 55 | 9 |
| 33 | integrity _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 15 |
| 34 | portal_catalog _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 0 |
| 35 | messaging | 22 | 142 | 0 | 150 | 0 |
| 36 | qa_lab | 13 | 79 | 0 | 92 | 0 |
| 37 | tracking | 8 | 51 | 0 | 61 | 0 |
| 38 | erp | 51 | 429 | 0 | 494 | 14 |
| 39 | reporting | 12 | 70 | 0 | 86 | 0 |
| 40 | auth_providers | 9 | 50 | 0 | 58 | 1 |
| 41 | scheduling | 17 | 115 | 11 | 118 | 1 |
| 42 | payments | 52 | 349 | 0 | 404 | 6 |
| 43 | ads | 73 | 388 | 0 | 497 | 0 |
| 44 | health_context | 10 | 53 | 0 | 62 | 0 |
| 45 | system_context | 9 | 51 | 0 | 62 | 0 |
| 46 | platform_ops | 38 | 214 | 0 | 265 | 0 |
| 47 | education | 15 | 88 | 0 | 103 | 0 |
| 48 | automation | 16 | 100 | 0 | 113 | 0 |
| 49 | crm | 32 | 227 | 0 | 278 | 5 |
| 50 | marketing | 14 | 121 | 0 | 130 | 0 |
| 51 | promotions | 11 | 71 | 0 | 87 | 0 |
| 52 | health_data | 34 | 178 | 0 | 254 | 9 |
| 53 | procedures_perioperative | 35 | 220 | 0 | 262 | 8 |
| 54 | polyglot_storage | 20 | 29 | 0 | 35 | 4 |
| 55 | document_store _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 18 |
| 56 | redis_runtime _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 18 |
| 57 | search_platform _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 17 |
| 58 | time_series _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 16 |
| 59 | vector_rag _(especializado/no-SQL)_ | 0 | 0 | 0 | 0 | 18 |
| 60 | object_storage | 17 | 0 | 0 | 41 | 4 |
| 61 | graph_intelligence | 13 | 0 | 0 | 29 | 5 |
| 62 | cross_store_consistency | 20 | 0 | 0 | 43 | 4 |
| 63 | lakehouse | 18 | 0 | 0 | 42 | 4 |
| 64 | audio_assets | 4 | 1 | 0 | 10 | 0 |
| 65 | surveys | 7 | 36 | 35 | 17 | 0 |
| **Σ** | **64** | **1169** | | **81** | | **292** |

## Detalle de entidades saltadas y avisos

### 02 · common
- ⚠ índice 'gist_addresses_location' omitido: columna(s) inexistente(s) ['geography_point'] en addresses (¿tipo no-SQL descartado? requiere PostGIS)

### 04 · directory
- ⚠ índice 'gist_branches_location' omitido: columna(s) inexistente(s) ['geography_point'] en branches (¿tipo no-SQL descartado? requiere PostGIS)

### 05 · profiles
- ⚠ índice 'uq_person_account_links_active_user': predicado referencia función(es) placeholder del modelo → emitido COMENTADO (definir función o reemplazar por IDs).

### 08 · clinical
- ⚠ índice 'gist_appointments_practitioner_time': predicado referencia función(es) placeholder del modelo → emitido COMENTADO (definir función o reemplazar por IDs).

### 09 · forms
- `resource_fields_view` — vista (sin SELECT en el .puml)

### 13 · geo
- ⚠ índice 'gist_location_pings_location' omitido: columna(s) inexistente(s) ['geography_point'] en location_pings (¿tipo no-SQL descartado? requiere PostGIS)

### 15 · chart
- `patient_timeline_view` — vista (sin SELECT en el .puml)

### 16 · accounting
- `erp_business_partners` — stub de cruce (tabla real en su módulo dueño)
- `erp_contracts` — stub de cruce (tabla real en su módulo dueño)
- `erp_projects` — stub de cruce (tabla real en su módulo dueño)
- `erp_wbs_elements` — stub de cruce (tabla real en su módulo dueño)
- `erp_purchase_order_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_goods_receipt_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_sales_order_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_departments` — stub de cruce (tabla real en su módulo dueño)
- `erp_employees` — stub de cruce (tabla real en su módulo dueño)
- `billing_invoices` — stub de cruce (tabla real en su módulo dueño)
- `billing_bills` — stub de cruce (tabla real en su módulo dueño)
- `payments_payment_transactions` — stub de cruce (tabla real en su módulo dueño)
- `directory_branches` — stub de cruce (tabla real en su módulo dueño)

### 17 · billing
- `erp_business_partners` — stub de cruce (tabla real en su módulo dueño)
- `erp_contracts` — stub de cruce (tabla real en su módulo dueño)
- `erp_contract_line_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_purchase_orders` — stub de cruce (tabla real en su módulo dueño)
- `erp_purchase_order_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_goods_receipt_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_service_entry_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_sales_orders` — stub de cruce (tabla real en su módulo dueño)
- `erp_sales_order_items` — stub de cruce (tabla real en su módulo dueño)
- `accounting_subledger_accounts` — stub de cruce (tabla real en su módulo dueño)
- `accounting_open_items` — stub de cruce (tabla real en su módulo dueño)
- `accounting_clearing_documents` — stub de cruce (tabla real en su módulo dueño)
- `accounting_clearing_items` — stub de cruce (tabla real en su módulo dueño)
- `accounting_company_bank_accounts` — stub de cruce (tabla real en su módulo dueño)
- `payments_payment_transactions` — stub de cruce (tabla real en su módulo dueño)
- `insurance_claims` — stub de cruce (tabla real en su módulo dueño)
- `receivables_aging_view` — vista (sin SELECT en el .puml)

### 18 · clinical_ext
- `vital_signs_view` — vista (sin SELECT en el .puml)

### 19 · community
- `rating_aggregates` — vista materializada (sin SELECT en el .puml)

### 25 · pharmacy_inventory
- `erp_business_partners` — stub de cruce (tabla real en su módulo dueño)
- `erp_purchase_orders` — stub de cruce (tabla real en su módulo dueño)
- `erp_purchase_order_items` — stub de cruce (tabla real en su módulo dueño)
- `erp_goods_receipts` — stub de cruce (tabla real en su módulo dueño)
- `erp_goods_receipt_items` — stub de cruce (tabla real en su módulo dueño)
- `accounting_ledger_entries` — stub de cruce (tabla real en su módulo dueño)
- ⚠ índice 'uq_inventory_position_lot' omitido: columna(s) inexistente(s) ['pharmacy_site_id', 'product_id', 'lot_id'] en inventory_stock_positions (¿tipo no-SQL descartado? requiere PostGIS)

### 30 · read_models
- `system_admin_dashboard_v` — vista (sin SELECT en el .puml)
- `system_admin_tenant_list_v` — vista (sin SELECT en el .puml)
- `system_admin_verification_queue_v` — vista (sin SELECT en el .puml)
- `system_admin_integration_health_v` — vista (sin SELECT en el .puml)
- `erp_financial_summary_v` — vista (sin SELECT en el .puml)
- `erp_general_ledger_balance_v` — vista (sin SELECT en el .puml)
- `erp_accounts_receivable_queue_v` — vista (sin SELECT en el .puml)
- `erp_accounts_payable_queue_v` — vista (sin SELECT en el .puml)
- `erp_inventory_valuation_v` — vista materializada (sin SELECT en el .puml)
- `infrastructure_operations_dashboard_v` — vista (sin SELECT en el .puml)
- `hospital_bed_board_v` — vista (sin SELECT en el .puml)
- `workforce_shift_board_v` — vista (sin SELECT en el .puml)
- `diagnostic_worklist_v` — vista (sin SELECT en el .puml)
- `diagnostic_result_release_queue_v` — vista (sin SELECT en el .puml)
- `diagnostic_unit_public_catalog_v` — vista materializada (sin SELECT en el .puml)
- `pharmacy_inventory_dashboard_v` — vista (sin SELECT en el .puml)
- `pharmacy_dispensing_queue_v` — vista (sin SELECT en el .puml)
- `pharmacy_public_stock_offer_v` — vista materializada (sin SELECT en el .puml)
- `doctor_daily_workspace_v` — vista (sin SELECT en el .puml)
- `doctor_patient_summary_v` — vista (sin SELECT en el .puml)
- `doctor_result_inbox_v` — vista (sin SELECT en el .puml)
- `doctor_note_history_v` — vista (sin SELECT en el .puml)
- `patient_home_dashboard_v` — vista (sin SELECT en el .puml)
- `patient_health_timeline_v` — vista (sin SELECT en el .puml)
- `patient_appointments_v` — vista (sin SELECT en el .puml)
- `patient_orders_results_v` — vista (sin SELECT en el .puml)
- `patient_medication_summary_v` — vista (sin SELECT en el .puml)
- `patient_billing_wallet_v` — vista (sin SELECT en el .puml)
- `patient_consent_center_v` — vista (sin SELECT en el .puml)
- `patient_provider_search_v` — vista materializada (sin SELECT en el .puml)
- `insurer_authorization_queue_v` — vista (sin SELECT en el .puml)
- `insurer_claim_reconciliation_v` — vista (sin SELECT en el .puml)
- `insurer_network_performance_v` — vista materializada (sin SELECT en el .puml)
- `broker_portfolio_v` — vista (sin SELECT en el .puml)
- `broker_commission_statement_v` — vista (sin SELECT en el .puml)
- `public_provider_directory_v` — vista materializada (sin SELECT en el .puml)
- `public_profile_detail_v` — vista materializada (sin SELECT en el .puml)
- `public_feed_v` — vista (sin SELECT en el .puml)
- `education_learner_dashboard_v` — vista (sin SELECT en el .puml)
- `crm_pipeline_board_v` — vista (sin SELECT en el .puml)
- `marketing_campaign_performance_v` — vista materializada (sin SELECT en el .puml)
- `erp_business_partner_360_v` — vista (sin SELECT en el .puml)
- `erp_contract_lifecycle_queue_v` — vista (sin SELECT en el .puml)
- `erp_contract_obligation_queue_v` — vista (sin SELECT en el .puml)
- `erp_procure_to_pay_match_queue_v` — vista (sin SELECT en el .puml)
- `erp_asset_rollforward_mv` — vista materializada (sin SELECT en el .puml)
- `erp_liability_maturity_v` — vista (sin SELECT en el .puml)
- `erp_journal_line_trace_v` — vista (sin SELECT en el .puml)
- `crm_account_360_v` — vista (sin SELECT en el .puml)
- `crm_activity_timeline_mv` — vista materializada (sin SELECT en el .puml)
- `crm_task_queue_v` — vista (sin SELECT en el .puml)
- `crm_calendar_v` — vista (sin SELECT en el .puml)
- `crm_case_queue_v` — vista (sin SELECT en el .puml)
- `crm_opportunity_forecast_v` — vista (sin SELECT en el .puml)
- `ops_service_health_overview_v` — vista (sin SELECT en el .puml)
- `ops_incident_command_center_v` — vista (sin SELECT en el .puml)
- `ops_slo_error_budget_mv` — vista materializada (sin SELECT en el .puml)
- `ops_change_calendar_v` — vista (sin SELECT en el .puml)
- `ads_campaign_delivery_dashboard_v` — vista (sin SELECT en el .puml)
- `ads_conversion_quality_mv` — vista materializada (sin SELECT en el .puml)
- `ads_lead_inbox_v` — vista (sin SELECT en el .puml)
- `ads_policy_review_queue_v` — vista (sin SELECT en el .puml)
- `payments_gateway_operations_v` — vista (sin SELECT en el .puml)
- `payments_reconciliation_queue_v` — vista (sin SELECT en el .puml)
- `payments_debt_checkout_v` — vista (sin SELECT en el .puml)
- `patient_diagnostic_timeline_v` — vista (sin SELECT en el .puml)
- `lab_specimen_trace_v` — vista (sin SELECT en el .puml)
- `imaging_study_viewer_manifest_v` — vista (sin SELECT en el .puml)
- `health_data_ingestion_quality_v` — vista (sin SELECT en el .puml)
- `patient_longitudinal_record_v` — vista (sin SELECT en el .puml)
- `procedure_case_command_center_v` — vista (sin SELECT en el .puml)
- `operating_room_schedule_v` — vista (sin SELECT en el .puml)
- `postoperative_followup_queue_v` — vista (sin SELECT en el .puml)
- `adapter_health_summary` — vista materializada (sin SELECT en el .puml)
- `campaign_dispatch_summary` — vista materializada (sin SELECT en el .puml)
- `recipient_delivery_timeline` — vista (sin SELECT en el .puml)

### 32 · workflow
- `appointment_machine` — máquina de estados (metadata, no es tabla)
- `encounter_machine` — máquina de estados (metadata, no es tabla)
- `service_request_machine` — máquina de estados (metadata, no es tabla)
- `diagnostic_report_machine` — máquina de estados (metadata, no es tabla)
- `payment_intent_machine` — máquina de estados (metadata, no es tabla)
- `insurance_claim_machine` — máquina de estados (metadata, no es tabla)
- `consent_machine` — máquina de estados (metadata, no es tabla)
- `identity_verification_machine` — máquina de estados (metadata, no es tabla)
- `automation_run_machine` — máquina de estados (metadata, no es tabla)

### 33 · integrity
- `inventory_stock_positions` — stub de cruce (tabla real en su módulo dueño)
- `inventory_ledger_entries` — stub de cruce (tabla real en su módulo dueño)
- `inventory_reservations` — stub de cruce (tabla real en su módulo dueño)
- `diagnostic_study_prices` — stub de cruce (tabla real en su módulo dueño)
- `patient_coverages` — stub de cruce (tabla real en su módulo dueño)
- `claim_adjudication_versions` — stub de cruce (tabla real en su módulo dueño)
- `identity_verification_attempts` — stub de cruce (tabla real en su módulo dueño)
- `user_activity_events` — stub de cruce (tabla real en su módulo dueño)
- `practitioner_delegate_assignments` — stub de cruce (tabla real en su módulo dueño)
- `appointments` — stub de cruce (tabla real en su módulo dueño)
- `claim_appeal_decisions` — stub de cruce (tabla real en su módulo dueño)
- `claim_reversals` — stub de cruce (tabla real en su módulo dueño)
- `coordination_of_benefits` — stub de cruce (tabla real en su módulo dueño)
- `audit_log` — stub de cruce (tabla real en su módulo dueño)
- `data_access_log` — stub de cruce (tabla real en su módulo dueño)

### 35 · messaging
- ⚠ índice 'uq_adapter_inbound_events_provider_id' omitido: columna(s) inexistente(s) ['received_time_bucket'] en adapter_inbound_events (¿tipo no-SQL descartado? requiere PostGIS)

### 37 · tracking
- ⚠ índice 'gist_tracking_events_location' omitido: columna(s) inexistente(s) ['geography_point'] en tracking_events (¿tipo no-SQL descartado? requiere PostGIS)
- ⚠ índice 'gist_delivery_proofs_location' omitido: columna(s) inexistente(s) ['geography_point'] en delivery_proofs (¿tipo no-SQL descartado? requiere PostGIS)

### 38 · erp
- `accounting_accounts` — stub de cruce (tabla real en su módulo dueño)
- `accounting_cost_centers` — stub de cruce (tabla real en su módulo dueño)
- `accounting_profit_centers` — stub de cruce (tabla real en su módulo dueño)
- `accounting_assets` — stub de cruce (tabla real en su módulo dueño)
- `accounting_liabilities` — stub de cruce (tabla real en su módulo dueño)
- `accounting_journal_transactions` — stub de cruce (tabla real en su módulo dueño)
- `billing_bills` — stub de cruce (tabla real en su módulo dueño)
- `billing_bill_lines` — stub de cruce (tabla real en su módulo dueño)
- `billing_invoices` — stub de cruce (tabla real en su módulo dueño)
- `payments_payment_transactions` — stub de cruce (tabla real en su módulo dueño)
- `crm_opportunities` — stub de cruce (tabla real en su módulo dueño)
- `workflow_instances` — stub de cruce (tabla real en su módulo dueño)
- `pharmacy_inventory_ledger_entries` — stub de cruce (tabla real en su módulo dueño)
- `vendors` — entidad externa

### 40 · auth_providers
- `iam_users` — entidad externa

### 41 · scheduling
- `appointments` — entidad externa

### 42 · payments
- `erp_business_partners` — stub de cruce (tabla real en su módulo dueño)
- `erp_contracts` — stub de cruce (tabla real en su módulo dueño)
- `accounting_company_bank_accounts` — stub de cruce (tabla real en su módulo dueño)
- `accounting_clearing_documents` — stub de cruce (tabla real en su módulo dueño)
- `invoices` — entidad externa
- `journal_transactions` — entidad externa
- ⚠ índice 'uq_payment_provider_transaction' omitido: columna(s) inexistente(s) ['payment_gateway_id', 'provider_transaction_id'] en payment_transactions (¿tipo no-SQL descartado? requiere PostGIS)

### 49 · crm
- `erp_business_partners` — stub de cruce (tabla real en su módulo dueño)
- `erp_sales_orders` — stub de cruce (tabla real en su módulo dueño)
- `billing_invoices` — stub de cruce (tabla real en su módulo dueño)
- `contracts` — entidad externa
- `ad_partners` — entidad externa
- ⚠ índice 'uq_contact_channel_endpoints_endpoint_type_concept_id' omitido: columna(s) inexistente(s) ['tenant_scope_normalizado'] en contact_channel_endpoints (¿tipo no-SQL descartado? requiere PostGIS)

### 52 · health_data
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `clinical_encounters` — stub de cruce (tabla real en su módulo dueño)
- `clinical_service_requests` — stub de cruce (tabla real en su módulo dueño)
- `clinical_observations` — stub de cruce (tabla real en su módulo dueño)
- `clinical_diagnostic_reports` — stub de cruce (tabla real en su módulo dueño)
- `clinical_procedures` — stub de cruce (tabla real en su módulo dueño)
- `diagnostics_specimens` — stub de cruce (tabla real en su módulo dueño)
- `diagnostics_imaging_studies` — stub de cruce (tabla real en su módulo dueño)
- `consent_consent_directives` — stub de cruce (tabla real en su módulo dueño)

### 53 · procedures_perioperative
- `clinical_procedures` — stub de cruce (tabla real en su módulo dueño)
- `clinical_service_requests` — stub de cruce (tabla real en su módulo dueño)
- `clinical_encounters` — stub de cruce (tabla real en su módulo dueño)
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `practice_care_spaces` — stub de cruce (tabla real en su módulo dueño)
- `diagnostics_specimens` — stub de cruce (tabla real en su módulo dueño)
- `clinical_observations` — stub de cruce (tabla real en su módulo dueño)
- `common_files` — stub de cruce (tabla real en su módulo dueño)

### 54 · polyglot_storage
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `common_files` — stub de cruce (tabla real en su módulo dueño)
- `iam_users` — stub de cruce (tabla real en su módulo dueño)
- `system_ops_retention_policies` — stub de cruce (tabla real en su módulo dueño)

### 55 · document_store
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `health_data_canonical_resources` — stub de cruce (tabla real en su módulo dueño)
- `common_files` — stub de cruce (tabla real en su módulo dueño)
- `polyglot_collection_definitions` — stub de cruce (tabla real en su módulo dueño)
- `document_envelopes` — colección MongoDB (otro motor)
- `document_version_documents` — colección MongoDB (otro motor)
- `fhir_resource_documents` — colección MongoDB (otro motor)
- `fhir_bundle_documents` — colección MongoDB (otro motor)
- `external_payload_documents` — colección MongoDB (otro motor)
- `webhook_payload_documents` — colección MongoDB (otro motor)
- `dynamic_form_snapshot_documents` — colección MongoDB (otro motor)
- `context_documents` — colección MongoDB (otro motor)
- `workflow_definition_documents` — colección MongoDB (otro motor)
- `ai_execution_documents` — colección MongoDB (otro motor)
- `cms_content_documents` — colección MongoDB (otro motor)
- `document_quarantine_documents` — colección MongoDB (otro motor)
- `document_schema_registry` — colección MongoDB (otro motor)

### 56 · redis_runtime
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `iam_users` — stub de cruce (tabla real en su módulo dueño)
- `scheduling_appointments` — stub de cruce (tabla real en su módulo dueño)
- `messaging_outbox_events` — stub de cruce (tabla real en su módulo dueño)
- `session_cache_entries` — store Redis (otro motor)
- `refresh_family_cache_entries` — store Redis (otro motor)
- `mfa_challenge_entries` — store Redis (otro motor)
- `password_reset_entries` — store Redis (otro motor)
- `rate_limit_buckets` — store Redis (otro motor)
- `idempotency_entries` — store Redis (otro motor)
- `authorization_cache_entries` — store Redis (otro motor)
- `availability_cache_entries` — store Redis (otro motor)
- `distributed_lock_entries` — store Redis (otro motor)
- `realtime_presence_entries` — store Redis (otro motor)
- `job_progress_entries` — store Redis (otro motor)
- `notification_debounce_entries` — store Redis (otro motor)
- `cache_invalidation_stream` — store Redis (otro motor)
- `outbox_delivery_dedup_entries` — store Redis (otro motor)

### 57 · search_platform
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `authz_policies` — stub de cruce (tabla real en su módulo dueño)
- `polyglot_collection_definitions` — stub de cruce (tabla real en su módulo dueño)
- `search_index_templates` — índice OpenSearch (otro motor)
- `provider_directory_search_docs` — índice OpenSearch (otro motor)
- `organization_directory_search_docs` — índice OpenSearch (otro motor)
- `terminology_search_docs` — índice OpenSearch (otro motor)
- `medication_catalog_search_docs` — índice OpenSearch (otro motor)
- `education_content_search_docs` — índice OpenSearch (otro motor)
- `community_content_search_docs` — índice OpenSearch (otro motor)
- `contract_search_docs` — índice OpenSearch (otro motor)
- `crm_activity_search_docs` — índice OpenSearch (otro motor)
- `authorized_patient_record_search_docs` — índice OpenSearch (otro motor)
- `technical_log_search_docs` — índice OpenSearch (otro motor)
- `audit_event_search_docs` — índice OpenSearch (otro motor)
- `ads_insight_search_docs` — índice OpenSearch (otro motor)

### 58 · time_series
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `diagnostics_medical_devices` — stub de cruce (tabla real en su módulo dueño)
- `platform_ops_services` — stub de cruce (tabla real en su módulo dueño)
- `device_raw_reading_series` — medición time-series (otro motor)
- `normalized_vital_series` — medición time-series (otro motor)
- `telemetry_event_series` — medición time-series (otro motor)
- `location_ping_series` — medición time-series (otro motor)
- `application_tracking_series` — medición time-series (otro motor)
- `ads_delivery_event_series` — medición time-series (otro motor)
- `ai_runtime_metric_series` — medición time-series (otro motor)
- `payment_gateway_metric_series` — medición time-series (otro motor)
- `lab_analyzer_event_series` — medición time-series (otro motor)
- `ingestion_pipeline_metric_series` — medición time-series (otro motor)
- `service_sli_series` — medición time-series (otro motor)
- `audit_access_metric_series` — medición time-series (otro motor)

### 59 · vector_rag
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `common_files` — stub de cruce (tabla real en su módulo dueño)
- `consent_directives` — stub de cruce (tabla real en su módulo dueño)
- `automation_agents` — stub de cruce (tabla real en su módulo dueño)
- `vector_collections` — vector store (otro motor)
- `vector_documents` — vector store (otro motor)
- `vector_chunks` — vector store (otro motor)
- `vector_embeddings` — vector store (otro motor)
- `embedding_model_versions` — vector store (otro motor)
- `embedding_jobs` — vector store (otro motor)
- `rag_access_policies` — vector store (otro motor)
- `vector_tenant_bindings` — vector store (otro motor)
- `retrieval_sessions` — vector store (otro motor)
- `retrieval_candidates` — vector store (otro motor)
- `retrieval_evidence` — vector store (otro motor)
- `retrieval_feedback_events` — vector store (otro motor)
- `vector_deletion_jobs` — vector store (otro motor)
- `vector_reconciliation_runs` — vector store (otro motor)

### 60 · object_storage
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `diagnostics_imaging_studies` — stub de cruce (tabla real en su módulo dueño)
- `common_files` — stub de cruce (tabla real en su módulo dueño)

### 61 · graph_intelligence
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `profiles_persons` — stub de cruce (tabla real en su módulo dueño)
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `directory_organizations` — stub de cruce (tabla real en su módulo dueño)
- `erp_business_partners` — stub de cruce (tabla real en su módulo dueño)

### 62 · cross_store_consistency
- `messaging_outbox_events` — stub de cruce (tabla real en su módulo dueño)
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `polyglot_dataset_definitions` — stub de cruce (tabla real en su módulo dueño)
- `audit_audit_events` — stub de cruce (tabla real en su módulo dueño)

### 63 · lakehouse
- `directory_tenants` — stub de cruce (tabla real en su módulo dueño)
- `health_data_ingestion_batches` — stub de cruce (tabla real en su módulo dueño)
- `health_data_deidentification_runs` — stub de cruce (tabla real en su módulo dueño)
- `common_files` — stub de cruce (tabla real en su módulo dueño)
