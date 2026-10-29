-- SALUD v4.0.10 · schema clinical · constraints de integridad (módulo 33)
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
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_suggested_care_space_requires_site";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_suggested_care_space_requires_site" CHECK ("suggested_care_space_id" IS NULL OR "suggested_practice_site_id" IS NOT NULL);


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

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."appointments" DROP CONSTRAINT IF EXISTS "ex_appointments_care_space_time";
ALTER TABLE "clinical"."appointments" ADD CONSTRAINT "ex_appointments_care_space_time"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("start_at", "end_at", '[)') WITH &&) WHERE ("care_space_id" IS NOT NULL AND "end_at" IS NOT NULL AND "status_concept_id" IN ('51530fd7-05b1-5c29-80c4-da740ede4d27', '37dded87-7a7a-5a24-86f6-0ef48cccb482'));

--   LOCK: reservation confirmation transaction

-- ═══ encounter_locations ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ck_encounter_locations_bed_period";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ck_encounter_locations_bed_period" CHECK (NOT "is_bed_assignment" OR ("period_start" IS NOT NULL AND "care_space_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ck_encounter_locations_bed_period_order";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ck_encounter_locations_bed_period_order" CHECK (NOT "is_bed_assignment" OR "period_end" IS NULL OR "period_end" >= "period_start");

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ex_encounter_locations_bed_occupancy";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_bed_occupancy"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&) WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')) DEFERRABLE INITIALLY IMMEDIATE;

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ex_encounter_locations_encounter_single_bed";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_encounter_single_bed"
    EXCLUDE USING gist ("encounter_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&) WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')) DEFERRABLE INITIALLY IMMEDIATE;

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ex_encounter_locations_encounter_one_active_bed";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_encounter_one_active_bed"
    EXCLUDE USING gist ("encounter_id" WITH =) WHERE ("is_bed_assignment" AND "location_status_concept_id" = '809db700-0627-5fe3-8278-4f038f4475b3') DEFERRABLE INITIALLY IMMEDIATE;


-- ═══ placement_incidents ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."placement_incidents" DROP CONSTRAINT IF EXISTS "ck_placement_incidents_justification_length";
ALTER TABLE "clinical"."placement_incidents" ADD CONSTRAINT "ck_placement_incidents_justification_length" CHECK (length(btrim("justification_text")) >= 20);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."placement_incidents" DROP CONSTRAINT IF EXISTS "ck_placement_incidents_violations_array";
ALTER TABLE "clinical"."placement_incidents" ADD CONSTRAINT "ck_placement_incidents_violations_array" CHECK (jsonb_typeof("violations_json") = 'array');


-- ═══ inpatient_census_days ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."inpatient_census_days" DROP CONSTRAINT IF EXISTS "ck_inpatient_census_days_counts";
ALTER TABLE "clinical"."inpatient_census_days" ADD CONSTRAINT "ck_inpatient_census_days_counts" CHECK ("beds_censable" >= 0 AND "beds_available" >= 0 AND "beds_blocked" >= 0 AND "patients_at_cutoff" >= 0 AND "admissions" >= 0 AND "discharges" >= 0 AND "deaths" >= 0 AND "transfers_in" >= 0 AND "transfers_out" >= 0 AND "same_day_stays" >= 0 AND "patient_days" >= 0 AND "discharge_stay_days" >= 0 AND "beds_available" + "beds_blocked" = "beds_censable");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."inpatient_census_days" DROP CONSTRAINT IF EXISTS "ck_inpatient_census_days_closed_has_hash";
ALTER TABLE "clinical"."inpatient_census_days" ADD CONSTRAINT "ck_inpatient_census_days_closed_has_hash" CHECK ("closed_at" IS NULL OR "content_hash" IS NOT NULL);


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

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical"."inpatient_census_adjustments" DROP CONSTRAINT IF EXISTS "ck_inpatient_census_adjustments_reason";
ALTER TABLE "clinical"."inpatient_census_adjustments" ADD CONSTRAINT "ck_inpatient_census_adjustments_reason" CHECK (btrim("reason_text") <> '' AND "new_value" >= 0);

-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "clinical"."inpatient_census_adjustments" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical"."inpatient_census_adjustments";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."inpatient_census_adjustments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();
