# H0.M2 — Inventario por sentencia normalizada (API database/SQL vs modelo SQL)

## Archivos con diferencia real (stmt-diff.py)
```text
## 04_directory/02_tables.sql: solo API 1 · solo modelo 1 · comunes 6
   API   : CREATE TABLE IF NOT EXISTS "directory"."branches" ( "id" uuid NOT NULL, "tenant_id" uuid NOT NULL, "code" varchar NOT NULL, "name" varchar NOT NULL, " …
   MODELO: CREATE TABLE IF NOT EXISTS "directory"."branches" ( "id" uuid NOT NULL, "tenant_id" uuid NOT NULL, "code" varchar NOT NULL, "name" varchar NOT NULL, " …
## 08_clinical/02_tables.sql: solo API 1 · solo modelo 1 · comunes 21
   API   : CREATE TABLE IF NOT EXISTS "clinical"."medication_requests" ( "id" uuid NOT NULL, "custodian_tenant_id" uuid NOT NULL, "patient_profile_id" uuid NOT N …
   MODELO: CREATE TABLE IF NOT EXISTS "clinical"."medication_requests" ( "id" uuid NOT NULL, "custodian_tenant_id" uuid NOT NULL, "patient_profile_id" uuid NOT N …
## 11_system_ops/02_tables.sql: solo API 1 · solo modelo 1 · comunes 28
   API   : CREATE TABLE IF NOT EXISTS "system_ops"."restore_test_runs" ( "id" uuid NOT NULL, "backup_policy_id" uuid NOT NULL, "backup_reference" varchar, "outco …
   MODELO: CREATE TABLE IF NOT EXISTS "system_ops"."restore_test_runs" ( "id" uuid NOT NULL, "backup_policy_id" uuid NOT NULL, "backup_reference" varchar, "outco …
## 17_billing/02_tables.sql: solo API 3 · solo modelo 1 · comunes 21
   API   : CREATE TABLE IF NOT EXISTS "billing"."invoice_lines" ( "id" uuid NOT NULL, "invoice_id" uuid NOT NULL, "service_id" uuid, "description" varchar, "quan …
   API   : CREATE TABLE IF NOT EXISTS "billing"."siat_simulated_invoices" ( "id" uuid NOT NULL DEFAULT gen_random_uuid(), "invoice_id" uuid NOT NULL, "encounter_ …
   API   : CREATE TABLE IF NOT EXISTS "billing"."siat_simulated_outbox" ( "id" uuid NOT NULL DEFAULT gen_random_uuid(), "siat_invoice_id" uuid NOT NULL, "to_emai …
   MODELO: CREATE TABLE IF NOT EXISTS "billing"."invoice_lines" ( "id" uuid NOT NULL, "invoice_id" uuid NOT NULL, "service_id" uuid, "insurance_claim_line_id" uu …
## 17_billing/03_fk_intra.sql: solo API 2 · solo modelo 0 · comunes 19
   API   : DO $$ BEGIN ALTER TABLE "billing"."siat_simulated_invoices" ADD CONSTRAINT "fk_siat_simulated_invoices_invoice_id" FOREIGN KEY ("invoice_id") REFERENC …
   API   : DO $$ BEGIN ALTER TABLE "billing"."siat_simulated_outbox" ADD CONSTRAINT "fk_siat_simulated_outbox_siat_invoice_id" FOREIGN KEY ("siat_invoice_id") RE …
## 17_billing/04_indexes.sql: solo API 5 · solo modelo 2 · comunes 167
   API   : CREATE INDEX IF NOT EXISTS "ix_siat_simulated_invoices_encounter_id" ON "billing"."siat_simulated_invoices" ("encounter_id");
   API   : CREATE INDEX IF NOT EXISTS "ix_siat_simulated_invoices_invoice_id" ON "billing"."siat_simulated_invoices" ("invoice_id");
   API   : CREATE INDEX IF NOT EXISTS "ix_siat_simulated_invoices_patient_profile_id" ON "billing"."siat_simulated_invoices" ("patient_profile_id");
   API   : CREATE INDEX IF NOT EXISTS "ix_siat_simulated_outbox_siat_invoice_id" ON "billing"."siat_simulated_outbox" ("siat_invoice_id");
   API   : CREATE UNIQUE INDEX IF NOT EXISTS "uk_siat_simulated_invoices_practice_number" ON "billing"."siat_simulated_invoices" ("practice_id", "invoice_number" …
   MODELO: CREATE INDEX IF NOT EXISTS "ix_invoice_lines_insurance_claim_line_id" ON "billing"."invoice_lines" ("insurance_claim_line_id");
   MODELO: CREATE UNIQUE INDEX IF NOT EXISTS "uq_invoice_lines_insurance_claim_line_id" ON "billing"."invoice_lines" ("insurance_claim_line_id") WHERE insurance_ …
## 17_billing/90_fk_deferred.sql: solo API 1 · solo modelo 3 · comunes 131
   API   : DO $$ BEGIN ALTER TABLE "billing"."siat_simulated_invoices" ADD CONSTRAINT "fk_siat_simulated_invoices_practice_id" FOREIGN KEY ("practice_id") REFERE …
   MODELO: DO $$ BEGIN ALTER TABLE "billing"."billing_document_links" ADD CONSTRAINT "fk_billing_document_links_claim_id" FOREIGN KEY ("claim_id") REFERENCES "in …
   MODELO: DO $$ BEGIN ALTER TABLE "billing"."invoice_lines" ADD CONSTRAINT "fk_invoice_lines_insurance_claim_line_id" FOREIGN KEY ("insurance_claim_line_id") RE …
   MODELO: DO $$ BEGIN ALTER TABLE "billing"."reimbursements" ADD CONSTRAINT "fk_reimbursements_claim_id" FOREIGN KEY ("claim_id") REFERENCES "insurance"."insura …
## 19_community/04_indexes.sql: solo API 0 · solo modelo 12 · comunes 254
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_created_by_user_id" ON "community"."party_ratings" ("created_by_user_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_moderation_status_concept_id" ON "community"."party_ratings" ("moderation_status_concept_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_reviewer_patient_profile_id" ON "community"."party_ratings" ("reviewer_patient_profile_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_reviewer_practice_id" ON "community"."party_ratings" ("reviewer_practice_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_reviewer_practitioner_profile_id" ON "community"."party_ratings" ("reviewer_practitioner_profile_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_target_patient_profile_id" ON "community"."party_ratings" ("target_patient_profile_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_target_practice_id" ON "community"."party_ratings" ("target_practice_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_target_practitioner_profile_id" ON "community"."party_ratings" ("target_practitioner_profile_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_updated_by_user_id" ON "community"."party_ratings" ("updated_by_user_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_verified_encounter_id" ON "community"."party_ratings" ("verified_encounter_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_party_ratings_verified_role_assignment_id" ON "community"."party_ratings" ("verified_role_assignment_id");
   MODELO: CREATE UNIQUE INDEX IF NOT EXISTS "uq_party_ratings_basis" ON "community"."party_ratings" (coalesce(reviewer_patient_profile_id, reviewer_practitioner …
## 41_scheduling/04_indexes.sql: solo API 0 · solo modelo 8 · comunes 119
   MODELO: CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_practitioner_service_offering_id" ON "scheduling"."appointment_bookings" ("practitioner_service_of …
   MODELO: CREATE INDEX IF NOT EXISTS "ix_bookable_slots_practitioner_service_offering_id" ON "scheduling"."bookable_slots" ("practitioner_service_offering_id");
   MODELO: CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_channel_concept_id" ON "scheduling"."practitioner_service_offerings" ("channel_concept_i …
   MODELO: CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_created_by_user_id" ON "scheduling"."practitioner_service_offerings" ("created_by_user_i …
   MODELO: CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_service_catalog_id" ON "scheduling"."practitioner_service_offerings" ("service_catalog_i …
   MODELO: CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_status_concept_id" ON "scheduling"."practitioner_service_offerings" ("status_concept_id" …
   MODELO: CREATE INDEX IF NOT EXISTS "ix_practitioner_service_offerings_updated_by_user_id" ON "scheduling"."practitioner_service_offerings" ("updated_by_user_i …
   MODELO: CREATE UNIQUE INDEX IF NOT EXISTS "ux_practitioner_service_offerings_practitioner_service" ON "scheduling"."practitioner_service_offerings" ("practiti …
## 41_scheduling/90_fk_deferred.sql: solo API 0 · solo modelo 6 · comunes 95
   MODELO: DO $$ BEGIN ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "fk_practitioner_service_offerings_channel_concept_id" FOREIGN KE …
   MODELO: DO $$ BEGIN ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "fk_practitioner_service_offerings_created_by_user_id" FOREIGN KE …
   MODELO: DO $$ BEGIN ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "fk_practitioner_service_offerings_practitioner_profile_id" FOREI …
   MODELO: DO $$ BEGIN ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "fk_practitioner_service_offerings_service_catalog_id" FOREIGN KE …
   MODELO: DO $$ BEGIN ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "fk_practitioner_service_offerings_status_concept_id" FOREIGN KEY …
   MODELO: DO $$ BEGIN ALTER TABLE "scheduling"."practitioner_service_offerings" ADD CONSTRAINT "fk_practitioner_service_offerings_updated_by_user_id" FOREIGN KE …
## 65_surveys/03_fk_intra.sql: solo API 0 · solo modelo 0 · comunes 9
## 65_surveys/90_fk_deferred.sql: solo API 0 · solo modelo 0 · comunes 27
```

## Parches que solo tiene la API (patch-inventory.py)

Nota: «ya en el modelo» compara por nombre; para parches de datos (INSERT/UPDATE) solo indica que la tabla existe, no que los datos estén. Por eso cada parche se revisó a mano (ver PLAN.md, secciones A/B/C).

```text
### 2026-09-18_v4219_data_catalog.sql  (318 líneas)
  [TABLA     ] data_catalog.catalog_scan_runs                                         ya en el modelo
  [TABLA     ] data_catalog.catalog_objects                                           ya en el modelo
  [TABLA     ] data_catalog.catalog_columns                                           ya en el modelo
  [TABLA     ] data_catalog.catalog_change_events                                     ya en el modelo
  [TABLA     ] data_catalog.catalog_annotations                                       ya en el modelo
  [TABLA     ] data_catalog.catalog_annotation_revisions                              ya en el modelo
  [TABLA     ] data_catalog.catalog_review_decisions                                  ya en el modelo
  [TABLA     ] data_catalog.catalog_evidence_items                                    ya en el modelo
  [ÍNDICE    ] ix_data_catalog_scan_runs_status_requested_at                          ya en el modelo
  [ÍNDICE    ] ux_data_catalog_scan_runs_one_active                                   ya en el modelo
  [ÍNDICE    ] ux_data_catalog_scan_runs_idempotency                                  ya en el modelo
  [ÍNDICE    ] ux_data_catalog_objects_identity                                       ya en el modelo
  [ÍNDICE    ] ix_data_catalog_objects_observation_status                             ya en el modelo
  [ÍNDICE    ] ux_data_catalog_columns_identity                                       ya en el modelo
  [ÍNDICE    ] ix_data_catalog_change_events_scan_run_id                              ya en el modelo
  [ÍNDICE    ] ix_data_catalog_change_events_object_created                           ya en el modelo
  [ÍNDICE    ] ux_data_catalog_annotations_object                                     ya en el modelo
  [ÍNDICE    ] ux_data_catalog_annotations_column                                     ya en el modelo
  [ÍNDICE    ] ix_data_catalog_annotations_review_status                              ya en el modelo
  [ÍNDICE    ] ux_data_catalog_annotation_revisions_no                                ya en el modelo
  [ÍNDICE    ] ix_data_catalog_review_decisions_annotation                            ya en el modelo
  [ÍNDICE    ] ix_data_catalog_evidence_items_object_id                               ya en el modelo
  [ÍNDICE    ] ix_data_catalog_evidence_items_column_id                               ya en el modelo

### 2026-09-18_v4220_qa_execution.sql  (157 líneas)
  [TABLA     ] qa_execution.execution_targets                                         ya en el modelo
  [TABLA     ] qa_execution.execution_plans                                           ya en el modelo
  [TABLA     ] qa_execution.plan_approvals                                            ya en el modelo
  [TABLA     ] qa_execution.plan_events                                               ya en el modelo
  [ÍNDICE    ] ux_qa_execution_targets_environment                                    ya en el modelo
  [ÍNDICE    ] ix_qa_execution_plans_status_created                                   ya en el modelo
  [ÍNDICE    ] ix_qa_execution_plans_run_id                                           ya en el modelo
  [ÍNDICE    ] ux_qa_execution_plans_idempotency                                      ya en el modelo
  [ÍNDICE    ] ix_qa_execution_plan_approvals_plan                                    ya en el modelo
  [ÍNDICE    ] ux_qa_execution_plan_events_seq                                        ya en el modelo

### 2026-09-19_v4219_custodian_tenant_rls.sql  (118 líneas)
  [POLÍTICA  ] custodian_tenant_isolation                                             FALTA en el modelo

### 2026-09-19_v4220_restore_test_runs_objective_status.sql  (115 líneas)
  [COLUMNA   ] objective_status                                                       ya en el modelo
  [CONSTRAINT] ck_restore_test_runs_objective_status                                  FALTA en el modelo

### 2026-09-26_v4232_form_instance_id.sql  (82 líneas)
  [COLUMNA   ] form_instance_id                                                       ya en el modelo
  [ÍNDICE    ] ix_medication_requests_form_instance_id                                FALTA en el modelo
  [ÍNDICE    ] ix_service_requests_form_instance_id                                   FALTA en el modelo
  [ÍNDICE    ] ix_care_plans_form_instance_id                                         FALTA en el modelo
  [ÍNDICE    ] ix_appointment_bookings_form_instance_id                               FALTA en el modelo
  [CONSTRAINT] bajo                                                                   ya en el modelo
  [CONSTRAINT] fk_medication_requests_form_instance_id                                FALTA en el modelo
  [CONSTRAINT] fk_service_requests_form_instance_id                                   FALTA en el modelo
  [CONSTRAINT] fk_care_plans_form_instance_id                                         FALTA en el modelo
  [CONSTRAINT] fk_appointment_bookings_form_instance_id                               FALTA en el modelo

### 2026-09-26_v4236_service_requests_performer_read_rls.sql  (64 líneas)
  [POLÍTICA  ] service_requests_performer_read                                        FALTA en el modelo

### 2026-09-26_v4237_appointment_follow_up_of.sql  (46 líneas)
  [COLUMNA   ] follow_up_of_booking_id                                                FALTA en el modelo
  [ÍNDICE    ] ix_appointment_bookings_follow_up_of_booking_id                        FALTA en el modelo
  [CONSTRAINT] bajo                                                                   ya en el modelo
  [CONSTRAINT] fk_appointment_bookings_follow_up_of_booking_id                        FALTA en el modelo

### 2026-10-11_v4238_medication_requests_indication_text.sql  (9 líneas)
  [COLUMNA   ] indication_text                                                        FALTA en el modelo

### 2026-10-11_v4239_agenda_centros_diagnosticos.sql  (55 líneas)
  [DATOS     ] INSERT INTOscheduling.schedulable_resources                            ya en el modelo
  [DATOS     ] INSERT INTOscheduling.schedule_templates                               ya en el modelo
  [DATOS     ] INSERT INTOscheduling.schedule_rules                                   ya en el modelo
  [DATOS     ] INSERT INTOscheduling.bookable_slots                                   ya en el modelo

### 2026-10-11_v4240_farmacia_paracetamol_vademecum_y_stock.sql  (24 líneas)
  [DATOS     ] UPDATEpharmacy.pharmacy_products                                       ya en el modelo
  [DATOS     ] INSERT INTOpharmacy_inventory.inventory_stock_positions                ya en el modelo

### 2026-10-11_v4241_unifica_medicina_general.sql  (15 líneas)
  [DATOS     ] UPDATEprofiles.practitioner_specialties                                ya en el modelo

### 2026-10-11_v4242_diagnostic_sites_geolocalizadas.sql  (33 líneas)
  [DATOS     ] INSERT INTOcommon.addresses                                            ya en el modelo
  [DATOS     ] UPDATEpractice.practice_sites                                          ya en el modelo

### 2026-10-11_v4243_branches_description_location_url.sql  (11 líneas)
  [COLUMNA   ] description                                                            ya en el modelo
  [COLUMNA   ] location_url                                                           FALTA en el modelo

### 2026-10-11_v4244_billing_siat_simulated.sql  (75 líneas)
  [TABLA     ] billing.siat_simulated_invoices                                        FALTA en el modelo
  [TABLA     ] billing.siat_simulated_outbox                                          FALTA en el modelo
  [ÍNDICE    ] ix_siat_simulated_invoices_invoice_id                                  FALTA en el modelo
  [ÍNDICE    ] ix_siat_simulated_invoices_encounter_id                                FALTA en el modelo
  [ÍNDICE    ] ix_siat_simulated_invoices_patient_profile_id                          FALTA en el modelo
  [ÍNDICE    ] uk_siat_simulated_invoices_practice_number                             FALTA en el modelo
  [ÍNDICE    ] ix_siat_simulated_outbox_siat_invoice_id                               FALTA en el modelo
  [CONSTRAINT] fk_siat_simulated_invoices_invoice_id                                  FALTA en el modelo
  [CONSTRAINT] fk_siat_simulated_invoices_practice_id                                 FALTA en el modelo
  [CONSTRAINT] fk_siat_simulated_outbox_siat_invoice_id                               FALTA en el modelo

### 2026-10-11_v4245_schedule_rules_booking_mode_concept.sql  (17 líneas)
  [COLUMNA   ] booking_mode_concept_id                                                ya en el modelo
  [ÍNDICE    ] ix_schedule_rules_booking_mode_concept_id                              ya en el modelo
  [CONSTRAINT] fk_schedule_rules_booking_mode_concept_id                              ya en el modelo

### 2026-10-11_v4246_designaciones_es_prioridades_orden.sql  (19 líneas)
  [DATOS     ] UPDATEterminology.concept_designations                                 ya en el modelo
```
