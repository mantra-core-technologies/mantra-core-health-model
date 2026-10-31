-- SALUD v4.2.79 · schema consent · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ treatment_informed_consents ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "consent"."treatment_informed_consents" DROP CONSTRAINT IF EXISTS "ck_treatment_informed_consents_target_type";
ALTER TABLE "consent"."treatment_informed_consents" ADD CONSTRAINT "ck_treatment_informed_consents_target_type" CHECK ("target_type" IN ('MEDICATION_REQUEST','SERVICE_REQUEST','REFERRAL','PROCEDURE','CARE_PLAN'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "consent"."treatment_informed_consents" DROP CONSTRAINT IF EXISTS "ck_treatment_informed_consents_granted_by";
ALTER TABLE "consent"."treatment_informed_consents" ADD CONSTRAINT "ck_treatment_informed_consents_granted_by" CHECK ("granted_by" IN ('PATIENT','LEGAL_REPRESENTATIVE','GUARDIAN','SUBSTITUTE_RELATIVE'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "consent"."treatment_informed_consents" DROP CONSTRAINT IF EXISTS "ck_treatment_informed_consents_channel";
ALTER TABLE "consent"."treatment_informed_consents" ADD CONSTRAINT "ck_treatment_informed_consents_channel" CHECK ("channel" IN ('IN_PERSON','TELEHEALTH'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "consent"."treatment_informed_consents" DROP CONSTRAINT IF EXISTS "ck_treatment_informed_consents_exception_type";
ALTER TABLE "consent"."treatment_informed_consents" ADD CONSTRAINT "ck_treatment_informed_consents_exception_type" CHECK ("exception_type" IN ('EMERGENCY','PUBLIC_HEALTH_RISK','PATIENT_WAIVER'));
