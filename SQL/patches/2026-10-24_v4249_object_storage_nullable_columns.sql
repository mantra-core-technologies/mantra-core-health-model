-- ============================================================================
-- SALUD · patch (object_storage · columnas que el modelo declaraba obligatorias y no lo son) sobre BD viva
-- Fecha: 2026-10-24 · hallazgo SCH-01 (API #815)
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. diagram_60_object_storage.puml marcaba TODAS las columnas como obligatorias (*),
-- incluidas las que por naturaleza no tienen valor al insertar o no aplican a todo objeto:
--   - object_manifests.patient_profile_id y retention_policy_code: un objeto NO clínico
--     (administrativo) no tiene paciente ni política de retención clínica;
--   - object_manifests.current_version_id: el manifiesto y su versión se referencian entre sí,
--     así que al insertar el manifiesto todavía no hay versión vigente;
--   - verified_at (object_locations, object_checksums, archive_manifests) y released_at
--     (object_legal_holds, object_retention_locks): son NULL hasta que se verifica o libera;
--     con released_at NOT NULL, uq_object_retention_active (WHERE released_at IS NULL) nunca
--     cubría ninguna fila;
--   - metadatos DICOM que se completan al parsear (dicom_study/series/instance_manifests).
-- Las 17 columnas pasan a admitir NULL, como ya las declaraba la entidad ORM de la API.
-- Relajar un NOT NULL no puede invalidar una fila existente; DROP NOT NULL es idempotente.
--
-- Fuera de alcance, sin cambios: las diferencias de polyglot_storage que lista fidelity-audit.json
-- (collection_definitions, residency_policies, storage_capabilities).
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +0 · NOT NULL quitados 17 · FKs +0 · índices +0 (-0) · constraints +0
-- ============================================================================

BEGIN;

ALTER TABLE "object_storage"."object_manifests"
    ALTER COLUMN "patient_profile_id" DROP NOT NULL;

ALTER TABLE "object_storage"."object_manifests"
    ALTER COLUMN "current_version_id" DROP NOT NULL;

ALTER TABLE "object_storage"."object_manifests"
    ALTER COLUMN "retention_policy_code" DROP NOT NULL;

ALTER TABLE "object_storage"."object_locations"
    ALTER COLUMN "verified_at" DROP NOT NULL;

ALTER TABLE "object_storage"."object_checksums"
    ALTER COLUMN "verified_at" DROP NOT NULL;

ALTER TABLE "object_storage"."object_retention_locks"
    ALTER COLUMN "released_at" DROP NOT NULL;

ALTER TABLE "object_storage"."object_legal_holds"
    ALTER COLUMN "released_at" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_study_manifests"
    ALTER COLUMN "study_date" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_study_manifests"
    ALTER COLUMN "modality_codes" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_series_manifests"
    ALTER COLUMN "body_part_examined" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_series_manifests"
    ALTER COLUMN "thumbnail_object_manifest_id" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_instance_manifests"
    ALTER COLUMN "sop_class_uid" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_instance_manifests"
    ALTER COLUMN "instance_number" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_instance_manifests"
    ALTER COLUMN "transfer_syntax_uid" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_instance_manifests"
    ALTER COLUMN "frame_count" DROP NOT NULL;

ALTER TABLE "object_storage"."dicom_instance_manifests"
    ALTER COLUMN "metadata_json" DROP NOT NULL;

ALTER TABLE "object_storage"."archive_manifests"
    ALTER COLUMN "verified_at" DROP NOT NULL;

COMMIT;
