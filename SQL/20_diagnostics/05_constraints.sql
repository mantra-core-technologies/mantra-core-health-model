-- SALUD v4.2.94 · schema diagnostics · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL, EXCLUDE_SQL y TRIGGER_SQL sí se materializan con el SQL del modelo.


-- ═══ report_drafts ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "diagnostics"."report_drafts" DROP CONSTRAINT IF EXISTS "ck_report_drafts_visibility";
ALTER TABLE "diagnostics"."report_drafts" ADD CONSTRAINT "ck_report_drafts_visibility" CHECK ("patient_visibility_code" IN ('VISIBLE', 'HELD'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "diagnostics"."report_drafts" DROP CONSTRAINT IF EXISTS "ck_report_drafts_status";
ALTER TABLE "diagnostics"."report_drafts" ADD CONSTRAINT "ck_report_drafts_status" CHECK ("status_code" IN ('DRAFT', 'PUBLISHED'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "diagnostics"."report_drafts" DROP CONSTRAINT IF EXISTS "ck_report_drafts_published";
ALTER TABLE "diagnostics"."report_drafts" ADD CONSTRAINT "ck_report_drafts_published" CHECK ("status_code" = 'DRAFT' OR ("published_version_id" IS NOT NULL AND "published_at" IS NOT NULL AND "signer_profile_id" IS NOT NULL));


-- ═══ report_draft_files ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "diagnostics"."report_draft_files" DROP CONSTRAINT IF EXISTS "ck_report_draft_files_role";
ALTER TABLE "diagnostics"."report_draft_files" ADD CONSTRAINT "ck_report_draft_files_role" CHECK ("role_code" IN ('DOCUMENT', 'AUDIO', 'ANNEX'));
