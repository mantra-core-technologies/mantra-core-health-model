-- SALUD v4.2.79 · schema clinical_ext · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ cds_rule_versions ═══
--   UPDATE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."cds_rule_versions" DROP CONSTRAINT IF EXISTS "ck_cds_rule_versions_number";
ALTER TABLE "clinical_ext"."cds_rule_versions" ADD CONSTRAINT "ck_cds_rule_versions_number" CHECK ("version_number" >= 1);

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "clinical_ext"."cds_rule_versions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "clinical_ext"."cds_rule_versions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "clinical_ext"."cds_rule_versions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ referrals ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_transport_mode";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_transport_mode" CHECK ("transport_mode" IN ('AMBULANCE_BASIC','AMBULANCE_ADVANCED','AIR_AMBULANCE','RIVER','PRIVATE_VEHICLE','PUBLIC_TRANSPORT','ON_FOOT','OTHER'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_departure_condition";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_departure_condition" CHECK ("departure_condition" IN ('STABLE','UNSTABLE','CRITICAL'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_arrival_condition";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_arrival_condition" CHECK ("arrival_condition" IN ('STABLE','UNSTABLE','CRITICAL','DECEASED'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_systolic_bp_range";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_systolic_bp_range" CHECK ("vital_systolic_bp" BETWEEN 40 AND 300);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_diastolic_bp_range";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_diastolic_bp_range" CHECK ("vital_diastolic_bp" BETWEEN 20 AND 200);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_heart_rate_range";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_heart_rate_range" CHECK ("vital_heart_rate" BETWEEN 20 AND 300);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_respiratory_rate_range";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_respiratory_rate_range" CHECK ("vital_respiratory_rate" BETWEEN 4 AND 80);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_temperature_c_range";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_temperature_c_range" CHECK ("vital_temperature_c" BETWEEN 30.0 AND 45.0);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_oxygen_saturation_range";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_oxygen_saturation_range" CHECK ("vital_oxygen_saturation" BETWEEN 50 AND 100);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_glasgow_range";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_glasgow_range" CHECK ("vital_glasgow" BETWEEN 3 AND 15);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_vital_bp_order";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_vital_bp_order" CHECK (("vital_diastolic_bp" IS NULL OR "vital_systolic_bp" IS NULL OR "vital_diastolic_bp" < "vital_systolic_bp"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."referrals" DROP CONSTRAINT IF EXISTS "ck_referrals_arrival_after_departure";
ALTER TABLE "clinical_ext"."referrals" ADD CONSTRAINT "ck_referrals_arrival_after_departure" CHECK (("arrived_at" IS NULL OR "departed_at" IS NULL OR "arrived_at" >= "departed_at"));
