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
| `delegated_access.shared_access_link_uses` | `LOG, REFERENCE_ONLY` | **UPDATE** forbidden |

### Módulo 23 · `diagnostic_units`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `diagnostic_study_prices` | `VERSIONED, REFERENCE_ONLY` | **UK** schedule + offering + version; **EXCLUDE** no overlapping active effective periods; **CHECK** amounts >= 0 |

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
