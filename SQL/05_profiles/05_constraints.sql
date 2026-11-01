-- SALUD v4.2.83 · schema profiles · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ practitioner_admission_events ═══
--   UPDATE_DELETE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "profiles"."practitioner_admission_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "profiles"."practitioner_admission_events";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "profiles"."practitioner_admission_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ practitioner_admissions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "profiles"."practitioner_admissions" DROP CONSTRAINT IF EXISTS "ck_practitioner_admissions_resubmission_count";
ALTER TABLE "profiles"."practitioner_admissions" ADD CONSTRAINT "ck_practitioner_admissions_resubmission_count" CHECK (("resubmission_count" >= 0));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "profiles"."practitioner_admissions" DROP CONSTRAINT IF EXISTS "ck_practitioner_admissions_due_after_submit";
ALTER TABLE "profiles"."practitioner_admissions" ADD CONSTRAINT "ck_practitioner_admissions_due_after_submit" CHECK (("due_at" >= "submitted_at"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "profiles"."practitioner_admissions" DROP CONSTRAINT IF EXISTS "ck_practitioner_admissions_attestation_version";
ALTER TABLE "profiles"."practitioner_admissions" ADD CONSTRAINT "ck_practitioner_admissions_attestation_version" CHECK (("attested_at" IS NULL OR "attestation_text_version" IS NOT NULL));


-- ═══ admission_requirements ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "profiles"."admission_requirements" DROP CONSTRAINT IF EXISTS "ck_admission_requirements_item_range";
ALTER TABLE "profiles"."admission_requirements" ADD CONSTRAINT "ck_admission_requirements_item_range" CHECK ((COALESCE("min_items", 0) >= 0 AND ("max_items" IS NULL OR "max_items" >= COALESCE("min_items", 0))));
