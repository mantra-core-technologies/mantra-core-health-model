# Matriz de integridad y concurrencia — SALUD v4.2.81 (módulo 33)

El módulo 33 (`integrity`) **no posee tablas**: es una matriz de verificación cross-dominio. Cada regla se implementa en la **migración de la tabla dueña** (su módulo) y se repite aquí como referencia. Extraído fielmente del `.puml`.

## Política transaccional

```
  TRANSACTION POLICY
  - Use READ COMMITTED plus explicit row locks for narrow stock mutations.
  - Use SERIALIZABLE for cross-row invariants that cannot be safely locked by a
    deterministic key; retry the full transaction on SQLSTATE 40001.
  - Keep external API calls outside database lock windows. Persist intent/outbox,
    then reconcile asynchronous results with idempotency.
  - SKIP LOCKED is valid for workers and queues, not for business availability.
```

## Compuertas físicas de base de datos

```
  PHYSICAL DATABASE GATES
  Named CHECK/UNIQUE/EXCLUDE/FK constraints, partial unique indexes, immutable
  triggers, partitioning plans, index evidence and concurrency tests are required
  before migrations are approved. Application validation is never the only guard.
```

## Matriz por módulo dueño

### Módulo 16 · `accounting`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `accounting.practitioner_simple_accounts` | `REFERENCE_ONLY` | **CHECK_SQL** ck_practitioner_simple_accounts_class \| "account_class" IN ('ASSET', 'LIABILITY', 'EQUITY', 'INCOME', 'EXPENSE') |
| `accounting.practitioner_simple_records` | `REFERENCE_ONLY` | **CHECK_SQL** ck_practitioner_simple_records_kind \| "kind" IN ('EXPENSE', 'ASSET', 'DEBT'); **CHECK_SQL** ck_practitioner_simple_records_amount \| "amount" > 0 |
| `accounting.practitioner_simple_transactions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_practitioner_simple_transactions_distinct \| "debit_account_id" <> "credit_account_id"; **CHECK_SQL** ck_practitioner_simple_transactions_amount \| "amount" > 0 |

### Módulo 10 · `audit`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `audit_log` | `IMMUTABLE, REFERENCE_ONLY` | **UPDATE_DELETE** forbidden |
| `data_access_log` | `APPEND_ONLY, REFERENCE_ONLY` | **UPDATE** forbidden; **DELETE** retention purge only (UC-10-09) |

### Módulo 06 · `authz`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `authz.permissions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_permissions_approval_needs_sensitivity \| ("approval_mode_concept_id" IS NULL OR "sensitivity_concept_id" IS NOT NULL) |

### Módulo 17 · `billing`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `siat_simulated_invoices` | `REFERENCE_ONLY` | **CHECK_SQL** ck_siat_simulated_invoices_simulated \| "simulated" = true; **CHECK_SQL** ck_siat_simulated_invoices_status \| "status" IN ('VALIDATED','OBSERVED','REJECTED','ANNULLED'); **CHECK_SQL** ck_siat_simulated_invoices_siat_mode \| "siat_mode" IN ('simulated','real') |
| `siat_simulated_outbox` | `REFERENCE_ONLY` | **CHECK_SQL** ck_siat_simulated_outbox_status \| "status" = 'NOT_SENT_SIMULATED'; **CHECK_SQL** ck_siat_simulated_outbox_siat_mode \| "siat_mode" IN ('simulated','real') |
| `billing.quotations` | `REFERENCE_ONLY` | **CHECK_SQL** chk_quotations_payment_frequency \| "payment_frequency" IN ('WEEKLY', 'BIWEEKLY', 'MONTHLY'); **CHECK_SQL** chk_quotations_down_payment_range \| ("down_payment_amount" >= 0 AND "down_payment_amount" <= "offered_price") |
| `billing.quotation_installments` | `REFERENCE_ONLY` | **CHECK_SQL** chk_quotation_installments_amount_positive \| "amount" > 0 |

### Módulo 08 · `clinical`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `service_requests` | `REFERENCE_ONLY` | **CHECK_SQL** ck_service_requests_override_reason_requires_previous_report \| ("duplicate_override_reason" IS NULL OR "previous_diagnostic_report_id" IS NOT NULL) |
| `received_services` | `REFERENCE_ONLY` | **CHECK_SQL** ck_received_services_has_source \| ("source_procedure_id" IS NOT NULL OR "source_immunization_id" IS NOT NULL OR "procedure_case_id" IS NOT NULL) |
| `appointments` | `REFERENCE_ONLY` | **EXCLUDE** practitioner/location time overlap; **EXCLUDE_SQL** ex_appointments_practitioner_time \| "practitioner_profile_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH && \| "practitioner_profile_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'); **LOCK** reservation confirmation transaction |

### Módulo 18 · `clinical_ext`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `clinical_ext.cds_rule_versions` | `REFERENCE_ONLY` | **UPDATE** forbidden; **CHECK_SQL** ck_cds_rule_versions_number \| "version_number" >= 1 |
| `clinical_ext.referrals` | `REFERENCE_ONLY` | **CHECK_SQL** ck_referrals_transport_mode \| "transport_mode" IN ('AMBULANCE_BASIC','AMBULANCE_ADVANCED','AIR_AMBULANCE','RIVER','PRIVATE_VEHICLE','PUBLIC_TRANSPORT','ON_FOOT','OTHER'); **CHECK_SQL** ck_referrals_departure_condition \| "departure_condition" IN ('STABLE','UNSTABLE','CRITICAL'); **CHECK_SQL** ck_referrals_arrival_condition \| "arrival_condition" IN ('STABLE','UNSTABLE','CRITICAL','DECEASED'); **CHECK_SQL** ck_referrals_vital_systolic_bp_range \| "vital_systolic_bp" BETWEEN 40 AND 300; **CHECK_SQL** ck_referrals_vital_diastolic_bp_range \| "vital_diastolic_bp" BETWEEN 20 AND 200; **CHECK_SQL** ck_referrals_vital_heart_rate_range \| "vital_heart_rate" BETWEEN 20 AND 300; **CHECK_SQL** ck_referrals_vital_respiratory_rate_range \| "vital_respiratory_rate" BETWEEN 4 AND 80; **CHECK_SQL** ck_referrals_vital_temperature_c_range \| "vital_temperature_c" BETWEEN 30.0 AND 45.0; **CHECK_SQL** ck_referrals_vital_oxygen_saturation_range \| "vital_oxygen_saturation" BETWEEN 50 AND 100; **CHECK_SQL** ck_referrals_vital_glasgow_range \| "vital_glasgow" BETWEEN 3 AND 15; **CHECK_SQL** ck_referrals_vital_bp_order \| ("vital_diastolic_bp" IS NULL OR "vital_systolic_bp" IS NULL OR "vital_diastolic_bp" < "vital_systolic_bp"); **CHECK_SQL** ck_referrals_arrival_after_departure \| ("arrived_at" IS NULL OR "departed_at" IS NULL OR "arrived_at" >= "departed_at") |

### Módulo 19 · `community`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `community.direct_messages` | `REFERENCE_ONLY` | **CHECK_SQL** ck_direct_messages_on_behalf_has_author \| ("on_behalf_of_profile_id" IS NULL OR "authored_by_user_id" IS NOT NULL) |

### Módulo 07 · `consent`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `consent.treatment_informed_consents` | `REFERENCE_ONLY` | **CHECK_SQL** ck_treatment_informed_consents_target_type \| "target_type" IN ('MEDICATION_REQUEST','SERVICE_REQUEST','REFERRAL','PROCEDURE','CARE_PLAN'); **CHECK_SQL** ck_treatment_informed_consents_granted_by \| "granted_by" IN ('PATIENT','LEGAL_REPRESENTATIVE','GUARDIAN','SUBSTITUTE_RELATIVE'); **CHECK_SQL** ck_treatment_informed_consents_channel \| "channel" IN ('IN_PERSON','TELEHEALTH'); **CHECK_SQL** ck_treatment_informed_consents_exception_type \| "exception_type" IN ('EMERGENCY','PUBLIC_HEALTH_RISK','PATIENT_WAIVER') |

### Módulo 67 · `data_catalog`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `catalog_change_events` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `catalog_annotation_revisions` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `catalog_review_decisions` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `catalog_evidence_items` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `data_catalog.catalog_glossary_term_revisions` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `data_catalog.quality_issue_events` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `data_catalog.quality_score_snapshots` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **CHECK_SQL** ck_quality_score_snapshots_score \| ("score" BETWEEN 0 AND 100) |
| `data_catalog.catalog_change_acknowledgements` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `data_catalog.catalog_stewardships` | `REFERENCE_ONLY` | **CHECK_SQL** ck_catalog_stewardships_scope \| (("scope_kind" = 'DOMAIN' AND "domain_id" IS NOT NULL AND "object_id" IS NULL) OR ("scope_kind" = 'OBJECT' AND "object_id" IS NOT NULL AND "domain_id" IS NULL)); **CHECK_SQL** ck_catalog_stewardships_holder \| ("user_id" IS NOT NULL OR "team_code" IS NOT NULL); **CHECK_SQL** ck_catalog_stewardships_period \| ("valid_to" IS NULL OR "valid_to" >= "valid_from") |
| `data_catalog.quality_rules` | `REFERENCE_ONLY` | **CHECK_SQL** ck_quality_rules_threshold \| ("threshold_pct" BETWEEN 0 AND 100) |
| `data_catalog.catalog_certifications` | `REFERENCE_ONLY` | **CHECK_SQL** ck_catalog_certifications_not_self \| ("certified_by_user_id" IS NULL OR "certified_by_user_id" <> "requested_by_user_id"); **CHECK_SQL** ck_catalog_certifications_target \| (num_nonnulls("object_id", "read_model_definition_id", "report_definition_id", "kpi_code") = 1) |

### Módulo 29 · `delegated_access`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `practitioner_delegate_assignments` | `REFERENCE_ONLY` | **EXCLUDE** incompatible overlapping assignments; **CHECK** signature permission requires authorized role |
| `delegated_access.organization_user_assignments` | `REFERENCE_ONLY` | **CHECK_SQL** ck_org_user_assignments_scope_target \| ("access_scope_concept_id" <> '928c884d-ff91-584c-8aa6-68535085e078' OR "clinical_unit_id" IS NOT NULL) AND ("access_scope_concept_id" <> '4df1a147-cb37-55ba-94e8-ab469e9cccb0' OR "care_space_id" IS NOT NULL) AND ("access_scope_concept_id" <> 'e69a4c95-fe59-5c3e-b826-222af123adb9' OR "practice_site_id" IS NOT NULL); **EXCLUDE_SQL** ex_org_user_assignments_unit_head \| "clinical_unit_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH && \| "assignment_role_concept_id" = 'ce54425b-5479-57f1-8bb2-274a8617723c' AND "status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19' |
| `delegated_access.shared_access_link_uses` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |
| `delegated_access.support_scope_grants` | `REFERENCE_ONLY` | **CHECK_SQL** ck_support_scope_grants_target_coherent \| ("target_kind_concept_id" = '785d1671-5754-58d3-b1a3-e3cd467b82b7' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '953e4408-5e19-521b-a25a-3d062d788911' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '10510d38-c6cf-5243-9327-5cefc6c3aee5' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '19ff6b5b-b998-54bb-af93-573b96764a6c' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '81f2ac43-a9ba-5043-b455-ed71b2d7e59f' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '3df7a566-22b8-512d-85a7-4b89604cb26b' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'cf4de420-16da-57f8-8c3a-f6ff717fc59e' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'b1330928-a076-5348-bffd-154144fadc85' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL); **CHECK_SQL** ck_support_scope_grants_valid_period \| ("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to"); **CHECK_SQL** ck_support_scope_grants_fixed_snapshot \| ("expansion_mode_concept_id" <> '4f47115f-54ad-564f-bcd4-f06a0a0c13cd' OR (jsonb_typeof("fixed_snapshot_json" -> 'rows') = 'array' AND jsonb_array_length("fixed_snapshot_json" -> 'rows') > 0 AND NOT jsonb_path_exists("fixed_snapshot_json", '$.rows[*] ? (@.type() != "object" \|\| exists(@.keyvalue() ? (@.key != "practitionerRoleAssignmentId" && @.key != "practitionerProfileId" && @.key != "healthcareServiceId" && @.key != "careSpaceId" \|\| @.value.type() != "null" && !(@.value.type() == "string" && @.value like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$"))) \|\| !(exists(@.practitionerRoleAssignmentId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$")) \|\| exists(@.healthcareServiceId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$")) \|\| exists(@.careSpaceId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$"))))')) IS TRUE) |
| `delegated_access.engagement_request_items` | `REFERENCE_ONLY` | **CHECK_SQL** ck_engagement_request_items_target_coherent \| ("target_kind_concept_id" = '785d1671-5754-58d3-b1a3-e3cd467b82b7' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '953e4408-5e19-521b-a25a-3d062d788911' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '10510d38-c6cf-5243-9327-5cefc6c3aee5' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '19ff6b5b-b998-54bb-af93-573b96764a6c' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '81f2ac43-a9ba-5043-b455-ed71b2d7e59f' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '3df7a566-22b8-512d-85a7-4b89604cb26b' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'cf4de420-16da-57f8-8c3a-f6ff717fc59e' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'b1330928-a076-5348-bffd-154144fadc85' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) |
| `delegated_access.engagement_requests` | `REFERENCE_ONLY` | **CHECK_SQL** ck_engagement_requests_expires_after_created \| "expires_at" > "created_at" |
| `delegated_access.role_templates` | `REFERENCE_ONLY` | **CHECK_SQL** ck_role_templates_version_number \| "version_number" >= 1 |
| `delegated_access.organization_user_assignments` | `REFERENCE_ONLY` | **CHECK_SQL** ck_organization_user_assignments_recertify_months \| ("recertify_every_months" IS NULL OR "recertify_every_months" IN (6, 12)) |
| `delegated_access.support_scope_grants` | `REFERENCE_ONLY` | **CHECK_SQL** ck_support_scope_grants_effect_valid \| ("effect_concept_id" IN ('6905e0db-1650-5d49-adca-8b2688ac049c', 'b038e546-a6ba-5848-9cd2-04b02ccb22b0')); **CHECK_SQL** ck_support_scope_grants_condition \| (("condition_json" IS NULL AND "condition_schema_version" IS NULL) OR (jsonb_typeof("condition_json") = 'object' AND "condition_schema_version" IS NOT NULL AND ("condition_json" ->> 'schemaVersion') = ("condition_schema_version")::text AND octet_length("condition_json"::text) <= 8192)) |
| `delegated_access.support_grant_actions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_support_grant_actions_condition \| (("condition_json" IS NULL AND "condition_schema_version" IS NULL) OR (jsonb_typeof("condition_json") = 'object' AND "condition_schema_version" IS NOT NULL AND ("condition_json" ->> 'schemaVersion') = ("condition_schema_version")::text AND octet_length("condition_json"::text) <= 8192)) |
| `delegated_access.role_templates` | `REFERENCE_ONLY` | **CHECK_SQL** ck_role_templates_ceiling_array \| ("ceiling_actions_json" IS NULL OR jsonb_typeof("ceiling_actions_json") = 'array'); **CHECK_SQL** ck_role_templates_default_conditions_object \| ("default_conditions_json" IS NULL OR jsonb_typeof("default_conditions_json") = 'object') |
| `delegated_access.governance_rules` | `REFERENCE_ONLY` | **CHECK_SQL** ck_governance_rules_pattern \| ("permission_pattern" ~ '^([a-z_]+(\.[a-z_]+){2,3}\|[a-z_]+(\.[a-z_]+){0,2}\.\*)$'); **CHECK_SQL** ck_governance_rules_kind_shape \| (("rule_kind_concept_id" <> 'ce906685-7a58-54e7-b4d2-458062c0c303' OR "role_template_code" IS NOT NULL) AND ("rule_kind_concept_id" <> '1b6db045-2cc5-5985-9c89-18b8ac0969be' OR COALESCE("rule_json" ? 'condition', false)) AND ("rule_kind_concept_id" <> 'f2534b4a-a8cc-5fb1-a431-30e1a750274b' OR COALESCE("rule_json" ->> 'maxVisibility' IN ('PARTIAL', 'REDACT', 'NULLIFY'), false))); **CHECK_SQL** ck_governance_rules_valid_period \| ("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to") |
| `delegated_access.sod_rules` | `REFERENCE_ONLY` | **CHECK_SQL** ck_sod_rules_sets \| (jsonb_typeof("atoms_a_json") = 'array' AND jsonb_typeof("atoms_b_json") = 'array'); **CHECK_SQL** ck_sod_rules_exception_days \| ("max_exception_days" IS NULL OR "max_exception_days" BETWEEN 1 AND 180); **CHECK_SQL** ck_sod_rules_hard_no_exception \| (NOT ("is_hard" AND "max_exception_days" IS NOT NULL)); **CHECK_SQL** ck_sod_rules_version_number \| ("version_number" >= 1) |
| `delegated_access.sod_exceptions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_sod_exceptions_period \| ("valid_to" > "valid_from" AND "valid_to" <= "valid_from" + interval '180 days'); **CHECK_SQL** ck_sod_exceptions_justification \| (char_length("justification_text") >= 30) |
| `delegated_access.four_eyes_requests` | `REFERENCE_ONLY` | **CHECK_SQL** ck_four_eyes_requests_not_self \| ("decided_by_user_id" IS NULL OR ("decided_by_user_id" <> "requester_user_id" AND ("subject_user_id" IS NULL OR "decided_by_user_id" <> "subject_user_id"))); **CHECK_SQL** ck_four_eyes_requests_hash \| ("payload_hash" ~ '^[0-9a-f]{64}$'); **CHECK_SQL** ck_four_eyes_requests_expiry \| ("expires_at" > "created_at"); **CHECK_SQL** ck_four_eyes_requests_decision \| (("status_concept_id" <> 'a977935a-9073-5113-9644-7df96732e776' OR ("decided_at" IS NULL AND "decided_by_user_id" IS NULL)) AND ("status_concept_id" NOT IN ('1627143e-d273-5fcb-b289-9e59b8b096f2', 'de15c53d-1aa0-5709-8ebd-69e9fd323e31', '013d578f-38af-564c-aff1-e36d1fdec6dd') OR ("decided_at" IS NOT NULL AND "decided_by_user_id" IS NOT NULL))); **CHECK_SQL** ck_four_eyes_requests_reject_comment \| ("status_concept_id" <> 'de15c53d-1aa0-5709-8ebd-69e9fd323e31' OR COALESCE(char_length("decision_comment_text"), 0) >= 5) |
| `delegated_access.access_review_campaigns` | `REFERENCE_ONLY` | **CHECK_SQL** ck_access_review_campaigns_grace \| ("grace_days" BETWEEN 0 AND 30); **CHECK_SQL** ck_access_review_campaigns_escalate \| ("escalate_after_days" BETWEEN 1 AND 30); **CHECK_SQL** ck_access_review_campaigns_reminders \| (jsonb_typeof("reminder_days_before_json") = 'array'); **CHECK_SQL** ck_access_review_campaigns_due \| ("launched_at" IS NULL OR "due_at" > "launched_at") |
| `delegated_access.access_review_items` | `REFERENCE_ONLY` | **CHECK_SQL** ck_access_review_items_decided \| (("decision_concept_id" = '55a6db07-19e7-5bb4-978a-3d246492f49d' AND "decided_at" IS NULL) OR ("decision_concept_id" <> '55a6db07-19e7-5bb4-978a-3d246492f49d' AND "decided_at" IS NOT NULL)); **CHECK_SQL** ck_access_review_items_comment \| ("decision_concept_id" NOT IN ('bce72e9a-b3bb-5fab-8e79-85d411ba692c', '26f790b1-6d77-5286-89d5-0e82a4dcfb81') OR COALESCE(char_length("decision_comment_text"), 0) >= 10); **CHECK_SQL** ck_access_review_items_hash \| ("evidence_hash" ~ '^[0-9a-f]{64}$') |
| `delegated_access.lifecycle_cases` | `REFERENCE_ONLY` | **CHECK_SQL** ck_lifecycle_cases_checklist \| (jsonb_typeof("checklist_json") = 'array'); **CHECK_SQL** ck_lifecycle_cases_completed \| ("status_concept_id" <> '4734035e-72cf-519f-8e27-e6cf25ba557f' OR "completed_at" IS NOT NULL) |
| `delegated_access.handover_items` | `REFERENCE_ONLY` | **CHECK_SQL** ck_handover_items_reassigned \| ("status_concept_id" <> '57d9c373-5a94-5fd6-bf9c-bd6a95cb2a91' OR ("to_user_id" IS NOT NULL AND "reassigned_at" IS NOT NULL)); **CHECK_SQL** ck_handover_items_not_self \| ("to_user_id" IS NULL OR "to_user_id" <> "from_user_id") |
| `delegated_access.patient_restriction_flags` | `REFERENCE_ONLY` | **CHECK_SQL** ck_patient_restriction_flags_reason \| (char_length("reason_text") >= 10) |
| `delegated_access.access_decision_log` | `IMMUTABLE, REFERENCE_ONLY` | **UPDATE_DELETE** forbidden; **TRUNCATE** forbidden |
| `delegated_access.grant_usage_stats` | `REFERENCE_ONLY` | **CHECK_SQL** ck_grant_usage_stats_counts \| ("permit_count" >= 0 AND "deny_count" >= 0 AND "challenge_count" >= 0 AND "off_hours_count" >= 0 AND "distinct_patients_in_bucket" >= 0) |
| `delegated_access.access_anomalies` | `REFERENCE_ONLY` | **CHECK_SQL** ck_access_anomalies_window \| ("window_end" > "window_start"); **CHECK_SQL** ck_access_anomalies_dismiss_comment \| ("status_concept_id" <> '1c8f5b91-371b-5967-b8fd-98d08f80ac9c' OR COALESCE(char_length("resolution_comment_text"), 0) >= 10) |

### Módulo 23 · `diagnostic_units`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `diagnostic_study_prices` | `VERSIONED, REFERENCE_ONLY` | **UK** schedule + offering + version; **EXCLUDE** no overlapping active effective periods; **CHECK** amounts >= 0 |
| `diagnostic_units.diagnostic_equipment` | `REFERENCE_ONLY` | **CHECK_SQL** ck_diagnostic_equipment_ae_title \| "ae_title" IS NULL OR ("ae_title" ~ '^[\x20-\x7E]{1,16}$' AND btrim("ae_title") <> '' AND "ae_title" !~ '\\') |

### Módulo 04 · `directory`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `directory.affiliation_invitations` | `REFERENCE_ONLY` | **CHECK_SQL** ck_affiliation_invitations_uses \| ("max_uses" >= 1 AND "uses_count" >= 0 AND "uses_count" <= "max_uses") |

### Módulo 01 · `iam`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `iam.session_policies` | `REFERENCE_ONLY` | **CHECK_SQL** ck_session_policies_idle_timeout \| ("idle_timeout_minutes" > 0 AND "idle_timeout_minutes" <= 1440); **CHECK_SQL** ck_session_policies_allowed_hours \| ("allowed_hours_json" IS NULL OR (jsonb_typeof("allowed_hours_json") = 'object' AND jsonb_path_exists("allowed_hours_json", '$ ? (@.from.type() == "string" && @.from like_regex "^([01][0-9]\|2[0-3]):[0-5][0-9]$" && @.to.type() == "string" && @.to like_regex "^([01][0-9]\|2[0-3]):[0-5][0-9]$")') AND ("allowed_hours_json" -> 'days' IS NULL OR jsonb_typeof("allowed_hours_json" -> 'days') = 'array') AND NOT jsonb_path_exists("allowed_hours_json", '$.days[*] ? (@.type() != "number" \|\| @ < 0 \|\| @ > 6 \|\| @ != @.floor())') AND ("allowed_hours_json" -> 'timeZone' IS NULL OR jsonb_typeof("allowed_hours_json" -> 'timeZone') IN ('string', 'null'))) IS TRUE); **CHECK_SQL** ck_session_policies_role_code \| (("scope_concept_id" = 'b9137390-37e5-5de6-95cf-fc53860563fe') = ("role_code" IS NOT NULL)) |

### Módulo 27 · `identity_assurance`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `identity_verification_attempts` | `REFERENCE_ONLY` | **UK** case + endpoint + attempt number; **UK** endpoint + idempotency key; **RETRY** bounded policy only |

### Módulo 26 · `insurance`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `patient_coverages` | `REFERENCE_ONLY` | **UK** insurer + member identifier + effective period; **EXCLUDE** conflicting primary coverage periods |
| `claim_adjudication_versions` | `IMMUTABLE, REFERENCE_ONLY` | **UK** claim + adjudication version; **UPDATE_DELETE** forbidden |
| `insurance_claims` | `REFERENCE_ONLY` | **CHECK_SQL** ck_insurance_claims_single_order_origin \| ("inventory_reservation_id" IS NULL OR "service_request_id" IS NULL) |
| `prior_authorization_requests` | `REFERENCE_ONLY` | **CHECK_SQL** ck_prior_authorizations_single_order_origin \| ("inventory_reservation_id" IS NULL OR "service_request_id" IS NULL) |
| `insurance_campaigns` | `REFERENCE_ONLY` | **CHECK_SQL** ck_insurance_campaigns_valid_period \| ("valid_from" <= "valid_to"); **CHECK_SQL** ck_insurance_campaigns_copay_bonus_range \| ("copay_bonus_percentage" >= 0 AND "copay_bonus_percentage" <= 100) |
| `claim_appeal_decisions` | `IMMUTABLE, REFERENCE_ONLY` | **UK** dispute + decision version; **UPDATE_DELETE** forbidden |
| `claim_reversals` | `IMMUTABLE, REFERENCE_ONLY` | **UK** claim + idempotency_key; **UPDATE_DELETE** forbidden |
| `coordination_of_benefits` | `VERSIONED, REFERENCE_ONLY` | **UK** patient + determination version; **EXCLUDE** overlapping active COB periods |
| `insurance.insurance_products` | `REFERENCE_ONLY` | **CHECK_SQL** ck_insurance_products_age_range \| (COALESCE("min_age_years", 0) >= 0 AND ("max_age_years" IS NULL OR "max_age_years" >= COALESCE("min_age_years", 0))); **CHECK_SQL** ck_insurance_products_valid_period \| ("effective_from" IS NULL OR "effective_to" IS NULL OR "effective_from" <= "effective_to") |

### Módulo 66 · `medical_groups`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `medical_groups.groups` | `REFERENCE_ONLY` | **CHECK_SQL** ck_medical_groups_groups_status \| "status" IN ('PENDING_TEAM', 'SCHEDULED', 'RESCHEDULE_PENDING', 'CLOSED') |
| `medical_groups.group_members` | `REFERENCE_ONLY` | **CHECK_SQL** ck_medical_groups_group_members_invitation_status \| "invitation_status" IN ('PENDING', 'ACCEPTED', 'REJECTED') |

### Módulo 70 · `observability`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `observability.error_events` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 90 days (drop_chunks; DELETE allowed); **CHECK_SQL** ck_error_events_source \| "source" IN ('api', 'worker', 'web') |
| `observability.http_request_minute_series` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 14 days raw (drop_chunks; DELETE allowed) |
| `observability.sql_statement_minute_series` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 14 days (drop_chunks; DELETE allowed) |
| `observability.worker_tick_minute_series` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 30 days (drop_chunks; DELETE allowed) |
| `observability.slow_request_samples` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 30 days (drop_chunks; DELETE allowed); **CHECK_SQL** ck_slow_request_samples_sampled_because \| "sampled_because" IN ('slow', 'error', 'random') |
| `observability.dependency_probe_runs` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 30 days (drop_chunks; DELETE allowed); **CHECK_SQL** ck_dependency_probe_runs_status \| "status" IN ('up', 'degraded', 'down', 'not_probed') |
| `observability.alert_evaluations` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 400 days (purge job; DELETE allowed) |
| `observability.error_groups` | `REFERENCE_ONLY` | **CHECK_SQL** ck_error_groups_source \| "source" IN ('api', 'worker', 'web') |
| `observability.instances` | `REFERENCE_ONLY` | **CHECK_SQL** ck_instances_kind \| "kind" IN ('API', 'WORKER'); **CHECK_SQL** ck_instances_status \| "status" IN ('starting', 'running', 'draining', 'stopped') |

### Módulo 24 · `pharmacy`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `pharmacy_on_call_shifts` | `REFERENCE_ONLY` | **CHECK_SQL** ck_pharmacy_on_call_shifts_window \| ("ends_at" > "starts_at" AND "ends_at" - "starts_at" <= interval '72 hours'); **EXCLUDE_SQL** ex_pharmacy_on_call_shifts_site_overlap \| "pharmacy_site_id" WITH =, tstzrange("starts_at", "ends_at", '[)') WITH && \| "status_concept_id" = '14c92252-2ad8-576c-bc34-3ae2bbdb950d' |

### Módulo 25 · `pharmacy_inventory`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `inventory_stock_positions` | `REFERENCE_ONLY` | **PK** id; **UK** location + product + lot; **CHECK** quantities >= 0; **LOCK** SELECT FOR UPDATE; **VERSION** row_version |
| `inventory_ledger_entries` | `IMMUTABLE, REFERENCE_ONLY` | **UK** pharmacy + idempotency_key; **UK** pharmacy + ledger_sequence; **CHECK** non-zero delta; **UPDATE_DELETE** forbidden |
| `inventory_reservations` | `REFERENCE_ONLY` | **UK** pharmacy + idempotency_key; **EXCLUDE** active allocation overlap when required; **WORKER** expiration release |

### Módulo 14 · `practice`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `practice.care_spaces` | `REFERENCE_ONLY` | **CHECK_SQL** ck_care_spaces_buffers \| (COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0); **CHECK_SQL** ck_care_spaces_location_path \| ("location_path" IS NULL OR "location_path" ~ '^/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)+$') |
| `practice.practitioner_location_assignments` | `REFERENCE_ONLY` | **CHECK_SQL** ck_practitioner_location_assignments_period \| ("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to") |

### Módulo 53 · `procedures_perioperative`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `procedures_perioperative.procedure_cases` | `REFERENCE_ONLY` | **EXCLUDE** operating room time overlap; **EXCLUDE_SQL** ex_procedure_cases_operating_room_time \| "operating_room_id" WITH =, tstzrange("scheduled_start_at", "scheduled_end_at", '[)') WITH && \| "operating_room_id" IS NOT NULL AND "scheduled_start_at" IS NOT NULL AND "scheduled_end_at" IS NOT NULL AND "status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'); **CHECK_SQL** ck_procedure_cases_buffers \| (COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0) |

### Módulo 41 · `scheduling`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `practitioner_service_offerings` | `REFERENCE_ONLY` | **CHECK_SQL** ck_practitioner_service_offerings_duration_range \| ("min_duration_minutes" > 0 AND "min_duration_minutes" <= "max_duration_minutes" AND "max_duration_minutes" <= 720); **CHECK_SQL** ck_practitioner_service_offerings_buffers \| (COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0) |
| `scheduling.booking_policies` | `REFERENCE_ONLY` | **CHECK_SQL** ck_booking_policies_no_show_fee_percentage \| ("no_show_fee_percentage" IS NULL OR ("no_show_fee_percentage" >= 0 AND "no_show_fee_percentage" <= 100)) |

### Módulo 65 · `surveys`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `surveys.survey_templates` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_templates_single_owner \| ("owner_practitioner_id" IS NOT NULL AND "owner_type_concept_id" IS NULL AND "owner_id" IS NULL) OR ("owner_practitioner_id" IS NULL AND "owner_type_concept_id" IS NOT NULL AND "owner_id" IS NOT NULL) |
| `surveys.survey_versions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_versions_max_reminders \| ("max_reminders" IS NULL OR "max_reminders" >= 0) |
| `surveys.survey_invitations` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_invitations_anchor \| ("appointment_booking_id" IS NOT NULL OR "subject_id" IS NOT NULL) AND (("subject_type_concept_id" IS NULL) = ("subject_id" IS NULL)); **CHECK_SQL** ck_survey_invitations_extension_distinct \| "extension_survey_version_id" IS NULL OR "extension_survey_version_id" <> "survey_version_id" |
| `surveys.survey_invitation_reminders` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_invitation_reminders_number \| "reminder_number" >= 1 |
| `surveys.survey_answers` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_answers_single_value \| num_nonnulls("value_text", "value_number", "value_boolean", "value_choices") = 1 |

### Módulo 11 · `system_ops`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `system_ops.governance_policy_revisions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_governance_policy_revisions_not_self \| ("decided_by_user_id" IS NULL OR "decided_by_user_id" <> "submitted_by_user_id"); **CHECK_SQL** ck_governance_policy_revisions_decision \| ("status" NOT IN ('APPROVED', 'REJECTED') OR ("decided_by_user_id" IS NOT NULL AND "decided_at" IS NOT NULL)) |
| `system_ops.restore_test_runs` | `REFERENCE_ONLY` | **CHECK_SQL** ck_system_ops_restore_test_runs_objective_status \| "objective_status" IN ('PASSED', 'FAILED', 'NOT_MEASURED') |

### Módulo 28 · `telemetry`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `user_activity_events` | `APPEND_ONLY, REFERENCE_ONLY` | **UK** event schema + event idempotency key; **PARTITION** received_at; **RETENTION** purpose-specific |
| `telemetry.client_error_events` | `APPEND_ONLY, REFERENCE_ONLY` | **UPDATE** forbidden; **RETENTION** 90 days (purge job on received_at; DELETE allowed) |

## Relaciones de integridad declaradas

- `inventory_stock_positions` → `inventory_ledger_entries` — atomic projection
- `inventory_reservations` → `inventory_ledger_entries` — reserve/release
- `patient_coverages` → `claim_adjudication_versions` — adjudication basis
- `identity_verification_attempts` → `practitioner_delegate_assignments` — verified actor

## Cómo se materializa

- **`SQL/_integrity/00_integrity_functions.sql`** — schema `integrity` + `forbid_mutation()` (guarda de inmutabilidad).
- **`SQL/<NN>_<schema>/05_constraints.sql`** — por módulo dueño: guarda concreta para `UPDATE_DELETE: forbidden`, `CHECK_SQL` y `EXCLUDE_SQL`; las UK/CHECK/EXCLUDE en prosa quedan como comentario con la regla textual (el modelo no declara su expresión SQL) y la lista de índices únicos que la tabla ya tiene.
- **Concurrencia** (`LOCK`/`SERIALIZABLE`/`SKIP LOCKED`/outbox) → capa de servicio (MikroORM Unit of Work + retry en `SQLSTATE 40001`), ver orm-mapping-guide §0.
