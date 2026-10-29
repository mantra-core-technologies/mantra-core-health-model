# Matriz de integridad y concurrencia — SALUD v4.0.10 (módulo 33)

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

### Módulo 17 · `billing`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `siat_simulated_invoices` | `REFERENCE_ONLY` | **CHECK_SQL** ck_siat_simulated_invoices_simulated \| "simulated" = true; **CHECK_SQL** ck_siat_simulated_invoices_status \| "status" IN ('VALIDATED','OBSERVED','REJECTED','ANNULLED'); **CHECK_SQL** ck_siat_simulated_invoices_siat_mode \| "siat_mode" IN ('simulated','real') |
| `siat_simulated_outbox` | `REFERENCE_ONLY` | **CHECK_SQL** ck_siat_simulated_outbox_status \| "status" = 'NOT_SENT_SIMULATED'; **CHECK_SQL** ck_siat_simulated_outbox_siat_mode \| "siat_mode" IN ('simulated','real') |
| `billing.quotations` | `REFERENCE_ONLY` | **CHECK_SQL** chk_quotations_payment_frequency \| "payment_frequency" IN ('WEEKLY', 'BIWEEKLY', 'MONTHLY'); **CHECK_SQL** chk_quotations_down_payment_range \| ("down_payment_amount" >= 0 AND "down_payment_amount" <= "offered_price") |
| `billing.quotation_installments` | `REFERENCE_ONLY` | **CHECK_SQL** chk_quotation_installments_amount_positive \| "amount" > 0 |
| `billing.space_tariffs` | `REFERENCE_ONLY` | **EXCLUDE** space tariffs cannot overlap per practice, kind, category and care space; **EXCLUDE_SQL** ex_space_tariffs_validity \| "practice_id" WITH =, "tariff_kind_concept_id" WITH =, (COALESCE("bed_category_concept_id", '00000000-0000-0000-0000-000000000000'::uuid)) WITH =, (COALESCE("care_space_id", '00000000-0000-0000-0000-000000000000'::uuid)) WITH =, daterange("valid_from", "valid_to", '[)') WITH &&; **CHECK_SQL** ck_space_tariffs_kind \| "tariff_kind_concept_id" IN ('1ae01bf6-a061-52ed-aa26-590705cb2202', '25eb53f6-8006-5959-bee9-65b16117bc9b'); **CHECK_SQL** ck_space_tariffs_period \| "valid_to" IS NULL OR "valid_to" > "valid_from"; **CHECK_SQL** ck_space_tariffs_price \| "unit_price" >= 0; **CHECK_SQL** ck_space_tariffs_or_time_unit \| "tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR ("unit_minutes" IS NOT NULL AND "unit_minutes" > 0); **CHECK_SQL** ck_space_tariffs_bed_day_whole_days \| "tariff_kind_concept_id" <> '1ae01bf6-a061-52ed-aa26-590705cb2202' OR ("unit_minutes" IS NULL AND "minimum_units" IS NULL); **CHECK_SQL** ck_space_tariffs_minimum_units \| "minimum_units" IS NULL OR "minimum_units" >= 1; **CHECK_SQL** ck_space_tariffs_scope \| ("tariff_kind_concept_id" <> '1ae01bf6-a061-52ed-aa26-590705cb2202' OR "bed_category_concept_id" IS NOT NULL OR "care_space_id" IS NOT NULL) AND ("tariff_kind_concept_id" <> '25eb53f6-8006-5959-bee9-65b16117bc9b' OR "bed_category_concept_id" IS NULL) |
| `billing.charge_captures` | `REFERENCE_ONLY` | **CHECK_SQL** ck_charge_captures_source_kind \| "source_kind_concept_id" IN ('5f84ea44-b0d3-582c-86c1-32c81e422d30', 'a79361f6-8787-56a5-9a90-a9436d02e217'); **CHECK_SQL** ck_charge_captures_status \| "status_concept_id" IN ('17def99a-0cb5-586c-a440-59d809709c0d', '9af061be-6a80-51ed-bcbd-52533037c272', 'f2f59654-d912-5eeb-b619-814e50a3c4d0'); **CHECK_SQL** ck_charge_captures_quantity \| "quantity" > 0; **CHECK_SQL** ck_charge_captures_bed_day_whole \| "source_kind_concept_id" <> '5f84ea44-b0d3-582c-86c1-32c81e422d30' OR ("quantity" = 1 AND "care_space_id" IS NOT NULL); **CHECK_SQL** ck_charge_captures_minimum_stay \| "minimum_stay_charge" = false OR "source_kind_concept_id" = '5f84ea44-b0d3-582c-86c1-32c81e422d30'; **CHECK_SQL** ck_charge_captures_idempotency_key \| btrim("idempotency_key") <> ''; **CHECK_SQL** ck_charge_captures_void \| ("status_concept_id" = 'f2f59654-d912-5eeb-b619-814e50a3c4d0' AND "void_reason" IS NOT NULL AND btrim("void_reason") <> '') OR ("status_concept_id" <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0' AND "void_reason" IS NULL); **CHECK_SQL** ck_charge_captures_invoice_link \| ("status_concept_id" <> '17def99a-0cb5-586c-a440-59d809709c0d' OR "invoice_line_id" IS NULL) AND ("status_concept_id" <> '9af061be-6a80-51ed-bcbd-52533037c272' OR "invoice_line_id" IS NOT NULL); **CHECK_SQL** ck_charge_captures_price_photo \| "unit_price" IS NULL OR ("unit_price" >= 0 AND "space_tariff_id" IS NOT NULL AND "service_catalog_id" IS NOT NULL AND "currency_concept_id" IS NOT NULL); **CHECK_SQL** ck_charge_captures_invoiced_priced \| "status_concept_id" <> '9af061be-6a80-51ed-bcbd-52533037c272' OR "unit_price" IS NOT NULL |

### Módulo 08 · `clinical`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `service_requests` | `REFERENCE_ONLY` | **CHECK_SQL** ck_service_requests_override_reason_requires_previous_report \| ("duplicate_override_reason" IS NULL OR "previous_diagnostic_report_id" IS NOT NULL); **CHECK_SQL** ck_service_requests_suggested_care_space_requires_site \| "suggested_care_space_id" IS NULL OR "suggested_practice_site_id" IS NOT NULL |
| `received_services` | `REFERENCE_ONLY` | **CHECK_SQL** ck_received_services_has_source \| ("source_procedure_id" IS NOT NULL OR "source_immunization_id" IS NOT NULL OR "procedure_case_id" IS NOT NULL) |
| `appointments` | `REFERENCE_ONLY` | **EXCLUDE** practitioner/location time overlap; **EXCLUDE_SQL** ex_appointments_practitioner_time \| "practitioner_profile_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH && \| "practitioner_profile_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'); **EXCLUDE_SQL** ex_appointments_care_space_time \| "care_space_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH && \| "care_space_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'); **LOCK** reservation confirmation transaction |
| `clinical.encounter_locations` | `REFERENCE_ONLY` | **CHECK_SQL** ck_encounter_locations_bed_period \| NOT "is_bed_assignment" OR ("period_start" IS NOT NULL AND "care_space_id" IS NOT NULL); **CHECK_SQL** ck_encounter_locations_bed_period_order \| NOT "is_bed_assignment" OR "period_end" IS NULL OR "period_end" >= "period_start"; **EXCLUDE_SQL** ex_encounter_locations_bed_occupancy \| "care_space_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH && \| "is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c') \| DEFERRABLE INITIALLY IMMEDIATE; **EXCLUDE_SQL** ex_encounter_locations_encounter_single_bed \| "encounter_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH && \| "is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c') \| DEFERRABLE INITIALLY IMMEDIATE; **EXCLUDE_SQL** ex_encounter_locations_encounter_one_active_bed \| "encounter_id" WITH = \| "is_bed_assignment" AND "location_status_concept_id" = '809db700-0627-5fe3-8278-4f038f4475b3' \| DEFERRABLE INITIALLY IMMEDIATE |
| `clinical.placement_incidents` | `REFERENCE_ONLY` | **CHECK_SQL** ck_placement_incidents_justification_length \| length(btrim("justification_text")) >= 20; **CHECK_SQL** ck_placement_incidents_violations_array \| jsonb_typeof("violations_json") = 'array' |
| `clinical.inpatient_census_days` | `REFERENCE_ONLY` | **CHECK_SQL** ck_inpatient_census_days_counts \| "beds_censable" >= 0 AND "beds_available" >= 0 AND "beds_blocked" >= 0 AND "patients_at_cutoff" >= 0 AND "admissions" >= 0 AND "discharges" >= 0 AND "deaths" >= 0 AND "transfers_in" >= 0 AND "transfers_out" >= 0 AND "same_day_stays" >= 0 AND "patient_days" >= 0 AND "discharge_stay_days" >= 0 AND "beds_available" + "beds_blocked" = "beds_censable"; **CHECK_SQL** ck_inpatient_census_days_closed_has_hash \| "closed_at" IS NULL OR "content_hash" IS NOT NULL |
| `clinical.inpatient_census_entries` | `IMMUTABLE, REFERENCE_ONLY` | **UPDATE_DELETE** forbidden |
| `clinical.inpatient_census_adjustments` | `IMMUTABLE, REFERENCE_ONLY` | **UPDATE_DELETE** forbidden; **CHECK_SQL** ck_inpatient_census_adjustments_field_code \| "field_code" IN ('beds_censable', 'beds_available', 'beds_blocked', 'patients_at_cutoff', 'admissions', 'discharges', 'deaths', 'transfers_in', 'transfers_out', 'same_day_stays', 'patient_days', 'discharge_stay_days'); **CHECK_SQL** ck_inpatient_census_adjustments_reason \| btrim("reason_text") <> '' AND "new_value" >= 0 |

### Módulo 18 · `clinical_ext`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `clinical_ext.cds_rule_versions` | `REFERENCE_ONLY` | **UPDATE** forbidden; **CHECK_SQL** ck_cds_rule_versions_number \| "version_number" >= 1 |

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

### Módulo 29 · `delegated_access`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `practitioner_delegate_assignments` | `REFERENCE_ONLY` | **EXCLUDE** incompatible overlapping assignments; **CHECK** signature permission requires authorized role |
| `delegated_access.organization_user_assignments` | `REFERENCE_ONLY` | **CHECK_SQL** ck_org_user_assignments_scope_target \| ("access_scope_concept_id" <> '928c884d-ff91-584c-8aa6-68535085e078' OR "clinical_unit_id" IS NOT NULL) AND ("access_scope_concept_id" <> '4df1a147-cb37-55ba-94e8-ab469e9cccb0' OR "care_space_id" IS NOT NULL) AND ("access_scope_concept_id" <> 'e69a4c95-fe59-5c3e-b826-222af123adb9' OR "practice_site_id" IS NOT NULL); **EXCLUDE_SQL** ex_org_user_assignments_unit_head \| "clinical_unit_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH && \| "assignment_role_concept_id" = 'ce54425b-5479-57f1-8bb2-274a8617723c' AND "status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19' |
| `delegated_access.shared_access_link_uses` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |

### Módulo 23 · `diagnostic_units`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `diagnostic_study_prices` | `VERSIONED, REFERENCE_ONLY` | **UK** schedule + offering + version; **EXCLUDE** no overlapping active effective periods; **CHECK** amounts >= 0 |
| `diagnostic_units.diagnostic_equipment` | `REFERENCE_ONLY` | **CHECK_SQL** ck_diagnostic_equipment_ae_title \| "ae_title" IS NULL OR ("ae_title" ~ '^[\x20-\x7E]{1,16}$' AND btrim("ae_title") <> '' AND "ae_title" !~ '\\') |

### Módulo 20 · `diagnostics`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `specimen_collection_events` | `REFERENCE_ONLY` | **CHECK_SQL** ck_specimen_collection_events_care_space_requires_site \| "collection_care_space_id" IS NULL OR "collection_site_id" IS NOT NULL |
| `imaging_procedure_steps` | `REFERENCE_ONLY` | **CHECK_SQL** ck_imaging_procedure_steps_scheduled_space_requires_equipment \| "scheduled_care_space_id" IS NULL OR "scheduled_equipment_id" IS NOT NULL |

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
| `practice.care_spaces` | `REFERENCE_ONLY` | **CHECK_SQL** ck_care_spaces_buffers \| (COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0) |
| `care_space_status_events` | `IMMUTABLE, REFERENCE_ONLY` | **UPDATE_DELETE** forbidden |
| `practice.care_space_status_events` | `REFERENCE_ONLY` | **CHECK_SQL** ck_care_space_status_events_v2_code \| "v2_0116_code" IN ('C','H','I','K','O','U','R') |
| `practice.care_space_blocks` | `REFERENCE_ONLY` | **EXCLUDE** overlapping non-cancelled blocks of the same care space; **EXCLUDE_SQL** ex_care_space_blocks_time \| "care_space_id" WITH =, tstzrange("starts_at", "ended_at", '[)') WITH && \| "cancelled_at" IS NULL; **CHECK_SQL** ck_care_space_blocks_maintenance_eta \| ("kind_concept_id" <> 'b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0' OR "expected_end_at" IS NOT NULL); **CHECK_SQL** ck_care_space_blocks_end_after_start \| (("ended_at" IS NULL OR "ended_at" >= "starts_at") AND ("expected_end_at" IS NULL OR "expected_end_at" >= "starts_at")) |
| `practice.cleaning_orders` | `REFERENCE_ONLY` | **CHECK_SQL** ck_cleaning_orders_inspector_differs \| ("inspected_by_user_id" IS NULL OR "inspected_by_user_id" <> "finished_by_user_id") |
| `practice.care_space_category_periods` | `REFERENCE_ONLY` | **CHECK_SQL** ck_care_space_category_periods_range \| "valid_to" IS NULL OR "valid_to" > "valid_from"; **EXCLUDE** bed category periods cannot overlap per care space; **EXCLUDE_SQL** ex_care_space_category_periods_validity \| "care_space_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH && |

### Módulo 53 · `procedures_perioperative`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `procedures_perioperative.procedure_cases` | `REFERENCE_ONLY` | **EXCLUDE** operating room reserved window overlap; **EXCLUDE_SQL** ex_procedure_cases_operating_room_reserved_time \| "operating_room_id" WITH =, tstzrange("reserved_start_at", "reserved_end_at", '[)') WITH && \| "operating_room_id" IS NOT NULL AND "reserved_start_at" IS NOT NULL AND "reserved_end_at" IS NOT NULL AND "status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'); **CHECK_SQL** ck_procedure_cases_buffers \| (COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0) |
| `procedures_perioperative.operating_room_block_series` | `REFERENCE_ONLY` | **CHECK_SQL** ck_operating_room_block_series_owner \| "owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL); **CHECK_SQL** ck_operating_room_block_series_schedule \| cardinality("weekdays") >= 1 AND "weekdays" <@ ARRAY[0,1,2,3,4,5,6]::smallint[] AND "end_time" > "start_time" AND ("valid_to" IS NULL OR "valid_to" >= "valid_from") AND "release_hours" >= 0 |
| `procedures_perioperative.operating_room_blocks` | `REFERENCE_ONLY` | **EXCLUDE** operating room block overlap; **EXCLUDE_SQL** ex_operating_room_blocks_time \| "operating_room_id" WITH =, tstzrange("starts_at", "ends_at", '[)') WITH && \| "status_concept_id" = '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8'; **CHECK_SQL** ck_operating_room_blocks_owner \| "owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL); **CHECK_SQL** ck_operating_room_blocks_window \| "ends_at" > "starts_at" AND "release_at" <= "starts_at"; **CHECK_SQL** ck_operating_room_blocks_status \| "status_concept_id" IN ('762dc30b-3e3c-5e1e-8504-5c511fd1d4a8', 'c3225706-ef13-5cbe-af6d-caaf25437458', 'e420cc84-8fd2-5887-a9bd-faf77d561508'); **CHECK_SQL** ck_operating_room_blocks_release_state \| ("status_concept_id" <> 'c3225706-ef13-5cbe-af6d-caaf25437458' OR "released_at" IS NOT NULL) AND ("status_concept_id" <> '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8' OR "released_at" IS NULL) AND ("released_minutes" IS NULL OR "released_minutes" >= 0) AND ("status_concept_id" <> 'c3225706-ef13-5cbe-af6d-caaf25437458' OR "released_by_user_id" IS NULL OR btrim(coalesce("release_reason", '')) <> '') |
| `procedures_perioperative.surgical_safety_checklists` | `REFERENCE_ONLY` | **CHECK_SQL** ck_surgical_safety_checklists_phase_order \| ("time_out_completed_at" IS NULL OR "sign_in_completed_at" IS NOT NULL) AND ("sign_out_completed_at" IS NULL OR "time_out_completed_at" IS NOT NULL) |

### Módulo 41 · `scheduling`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `practitioner_service_offerings` | `REFERENCE_ONLY` | **CHECK_SQL** ck_practitioner_service_offerings_duration_range \| ("min_duration_minutes" > 0 AND "min_duration_minutes" <= "max_duration_minutes" AND "max_duration_minutes" <= 720); **CHECK_SQL** ck_practitioner_service_offerings_buffers \| (COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0) |
| `scheduling.booking_policies` | `REFERENCE_ONLY` | **CHECK_SQL** ck_booking_policies_no_show_fee_percentage \| ("no_show_fee_percentage" IS NULL OR ("no_show_fee_percentage" >= 0 AND "no_show_fee_percentage" <= 100)) |
| `scheduling.availability_exceptions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_availability_exceptions_source_ref_needs_kind \| ("source_ref_id" IS NULL OR "source_kind_concept_id" IS NOT NULL) |
| `scheduling.schedulable_resources` | `REFERENCE_ONLY` | **CHECK_SQL** ck_schedulable_resources_care_space_ref \| ("resource_ref_type" = 'care_spaces') = ("care_space_id" IS NOT NULL) AND ("care_space_id" IS NULL OR "care_space_id" = "resource_ref_id") |

### Módulo 65 · `surveys`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `surveys.survey_templates` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_templates_single_owner \| ("owner_practitioner_id" IS NOT NULL AND "owner_type_concept_id" IS NULL AND "owner_id" IS NULL) OR ("owner_practitioner_id" IS NULL AND "owner_type_concept_id" IS NOT NULL AND "owner_id" IS NOT NULL) |
| `surveys.survey_versions` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_versions_max_reminders \| ("max_reminders" IS NULL OR "max_reminders" >= 0) |
| `surveys.survey_invitations` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_invitations_anchor \| ("appointment_booking_id" IS NOT NULL OR "subject_id" IS NOT NULL) AND (("subject_type_concept_id" IS NULL) = ("subject_id" IS NULL)) |
| `surveys.survey_invitation_reminders` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_invitation_reminders_number \| "reminder_number" >= 1 |
| `surveys.survey_answers` | `REFERENCE_ONLY` | **CHECK_SQL** ck_survey_answers_single_value \| num_nonnulls("value_text", "value_number", "value_boolean", "value_choices") = 1 |

### Módulo 11 · `system_ops`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `system_ops.restore_test_runs` | `REFERENCE_ONLY` | **CHECK_SQL** ck_system_ops_restore_test_runs_objective_status \| "objective_status" IN ('PASSED', 'FAILED', 'NOT_MEASURED') |

### Módulo 28 · `telemetry`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `user_activity_events` | `APPEND_ONLY, REFERENCE_ONLY` | **UK** event schema + event idempotency key; **PARTITION** received_at; **RETENTION** purpose-specific |

## Relaciones de integridad declaradas

- `inventory_stock_positions` → `inventory_ledger_entries` — atomic projection
- `inventory_reservations` → `inventory_ledger_entries` — reserve/release
- `patient_coverages` → `claim_adjudication_versions` — adjudication basis
- `identity_verification_attempts` → `practitioner_delegate_assignments` — verified actor

## Cómo se materializa

- **`SQL/_integrity/00_integrity_functions.sql`** — schema `integrity` + `forbid_mutation()` (guarda de inmutabilidad).
- **`SQL/<NN>_<schema>/05_constraints.sql`** — por módulo dueño: guarda concreta para `UPDATE_DELETE: forbidden`, `CHECK_SQL` y `EXCLUDE_SQL`; las UK/CHECK/EXCLUDE en prosa quedan como comentario con la regla textual (el modelo no declara su expresión SQL) y la lista de índices únicos que la tabla ya tiene.
- **Concurrencia** (`LOCK`/`SERIALIZABLE`/`SKIP LOCKED`/outbox) → capa de servicio (MikroORM Unit of Work + retry en `SQLSTATE 40001`), ver orm-mapping-guide §0.
