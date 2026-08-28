# SALUD v4.0.1 · módulo 57 search_platform · OpenSearch

Un `.json` por índice con `mappings`. Config extra (routing/alias/pattern/lifecycle) documentada aquí por índice.

## `search_index_templates`
- **PATTERN** index_pattern: exact managed pattern
- **ALIAS** write_alias: one active write index per dataset

## `provider_directory_search_docs`
- **ROUTING** route_provider_tenant: tenant_id
- **SORT** sort_provider: rating_summary.average DESC, display_name.keyword ASC

## `organization_directory_search_docs`
- **ROUTING** route_org_tenant: tenant_id

## `terminology_search_docs`
- **ROUTING** route_terminology_tenant: tenant_id
- **PREFIX** prefix_term_code: code edge_ngram

## `medication_catalog_search_docs`
- **ROUTING** route_medication_tenant: tenant_id

## `education_content_search_docs`
- **ROUTING** route_education_tenant: tenant_id

## `community_content_search_docs`
- **ROUTING** route_community_tenant: tenant_id

## `contract_search_docs`
- **ROUTING** route_contract_tenant: tenant_id

## `crm_activity_search_docs`
- **ROUTING** route_crm_tenant: tenant_id

## `authorized_patient_record_search_docs`
- **ROUTING** route_patient_tenant: tenant_id
- **FILTER** filter_patient_authz: tenant_id + patient_profile_id + purpose_of_use_codes + allowed_principal_ids
- **POLICY** no_raw_phi: only preauthorized redacted projection

## `technical_log_search_docs`
- **ROUTING** route_log_service_day: service_name + event day
- **LIFECYCLE** ilm_logs: rollover by size/day and retention policy

## `audit_event_search_docs`
- **ROUTING** route_audit_tenant_month: tenant_id + event month
- **LIFECYCLE** ilm_audit: retention from legal policy, no silent deletion

## `ads_insight_search_docs`
- **ROUTING** route_ads_account: tenant_id + ad_account_id
