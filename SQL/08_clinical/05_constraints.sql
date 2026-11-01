-- SALUD v4.2.83 · schema clinical · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ service_requests ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_override_reason_requires_previous_report";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_override_reason_requires_previous_report" CHECK (("duplicate_override_reason" IS NULL OR "previous_diagnostic_report_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_specimen_xor_imaging";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_specimen_xor_imaging" CHECK (("specimen_type_concept_id" IS NULL OR ("modality_concept_id" IS NULL AND "body_site_concept_id" IS NULL AND "laterality_concept_id" IS NULL AND "contrast_concept_id" IS NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_laterality_requires_site";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_laterality_requires_site" CHECK (("laterality_concept_id" IS NULL OR "body_site_concept_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_contrast_requires_modality";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_contrast_requires_modality" CHECK (("contrast_concept_id" IS NULL OR "modality_concept_id" IS NOT NULL));


-- ═══ received_services ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."received_services" DROP CONSTRAINT IF EXISTS "ck_received_services_has_source";
ALTER TABLE "clinical"."received_services" ADD CONSTRAINT "ck_received_services_has_source" CHECK (("source_procedure_id" IS NOT NULL OR "source_immunization_id" IS NOT NULL OR "procedure_case_id" IS NOT NULL));


-- ═══ appointments ═══
--   EXCLUDE: practitioner/location time overlap  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."appointments" DROP CONSTRAINT IF EXISTS "ex_appointments_practitioner_time";
ALTER TABLE "clinical"."appointments" ADD CONSTRAINT "ex_appointments_practitioner_time"
    EXCLUDE USING gist ("practitioner_profile_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH &&) WHERE ("practitioner_profile_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'));

--   LOCK: reservation confirmation transaction
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."appointments" DROP CONSTRAINT IF EXISTS "ex_appointments_care_space_time";
ALTER TABLE "clinical"."appointments" ADD CONSTRAINT "ex_appointments_care_space_time"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH &&) WHERE ("care_space_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'));


-- ═══ encounter_locations ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ck_encounter_locations_bed_period";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ck_encounter_locations_bed_period" CHECK ((NOT "is_bed_assignment" OR ("period_start" IS NOT NULL AND "care_space_id" IS NOT NULL)));

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ex_encounter_locations_bed_occupancy";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_bed_occupancy"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&) WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')) DEFERRABLE INITIALLY IMMEDIATE;

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ex_encounter_locations_encounter_single_bed";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_encounter_single_bed"
    EXCLUDE USING gist ("encounter_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&) WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')) DEFERRABLE INITIALLY IMMEDIATE;


-- ═══ placement_incidents ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."placement_incidents" DROP CONSTRAINT IF EXISTS "ck_placement_incidents_justification_length";
ALTER TABLE "clinical"."placement_incidents" ADD CONSTRAINT "ck_placement_incidents_justification_length" CHECK ((char_length("justification_text") >= 20));


-- ═══ inpatient_census_days ═══
--   UK: site + unit + census_date  (en prosa; el módulo 33 no declara su expresión SQL)
--   GUARD: UPDATE/DELETE rechazados cuando OLD.status_concept_id = CENSUS_CLOSED (trigger trg_inpatient_census_days_closed_guard, patch 2026-10-29_infraestructura_f3_clinical.sql)
--   índices únicos que la tabla ya tiene en 04_indexes: ux_inpatient_census_days_site_unit_date, ux_inpatient_census_days_tenant_id_id

-- ═══ inpatient_census_entries ═══
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "clinical"."inpatient_census_entries" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical"."inpatient_census_entries";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."inpatient_census_entries"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ inpatient_census_adjustments ═══
--   UPDATE_DELETE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."inpatient_census_adjustments" DROP CONSTRAINT IF EXISTS "ck_inpatient_census_adjustments_field_code";
ALTER TABLE "clinical"."inpatient_census_adjustments" ADD CONSTRAINT "ck_inpatient_census_adjustments_field_code" CHECK ("field_code" IN ('beds_censable', 'beds_available', 'beds_blocked', 'patients_at_cutoff', 'admissions', 'discharges', 'deaths', 'transfers_in', 'transfers_out', 'same_day_stays', 'patient_days', 'discharge_stay_days'));

-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "clinical"."inpatient_census_adjustments" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical"."inpatient_census_adjustments";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."inpatient_census_adjustments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ patient_admission_footprints ═══
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "clinical"."patient_admission_footprints" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical"."patient_admission_footprints";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."patient_admission_footprints"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();
