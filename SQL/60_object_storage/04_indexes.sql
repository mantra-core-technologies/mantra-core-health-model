-- SALUD v4.0.10 · módulo 60 · schema object_storage
-- Generado de diagram_60_object_storage.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "uq_object_namespace_code" ON "object_storage"."object_namespaces" ("code");

CREATE INDEX IF NOT EXISTS "uq_object_namespace_location" ON "object_storage"."object_namespaces" ("backend_code", "region_code", "bucket_or_container", "object_key_prefix");

CREATE INDEX IF NOT EXISTS "uq_object_manifest_logical" ON "object_storage"."object_manifests" ("tenant_id", "logical_object_id");

CREATE INDEX IF NOT EXISTS "ix_object_manifest_patient" ON "object_storage"."object_manifests" ("tenant_id", "patient_profile_id", "updated_at" DESC) WHERE patient_profile_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_object_manifest_state" ON "object_storage"."object_manifests" ("tenant_id", "lifecycle_state", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_object_version_number" ON "object_storage"."object_versions" ("object_manifest_id", "version_number");

CREATE INDEX IF NOT EXISTS "uq_object_version_provider" ON "object_storage"."object_versions" ("object_manifest_id", "provider_version_id");

CREATE INDEX IF NOT EXISTS "uq_object_version_sha" ON "object_storage"."object_versions" ("object_manifest_id", "sha256");

CREATE INDEX IF NOT EXISTS "ix_object_version_created" ON "object_storage"."object_versions" ("object_manifest_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_object_location_role" ON "object_storage"."object_locations" ("object_version_id", "namespace_id", "placement_role");

CREATE INDEX IF NOT EXISTS "ix_object_location_replication" ON "object_storage"."object_locations" ("namespace_id", "replication_state", "verified_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_object_checksum_algorithm_source" ON "object_storage"."object_checksums" ("object_version_id", "algorithm", "source");

CREATE INDEX IF NOT EXISTS "ix_object_checksum_status" ON "object_storage"."object_checksums" ("verification_status", "verified_at" ASC);

CREATE INDEX IF NOT EXISTS "uq_object_encryption_version" ON "object_storage"."object_encryption_envelopes" ("object_version_id");

CREATE INDEX IF NOT EXISTS "ix_object_encryption_key_version" ON "object_storage"."object_encryption_envelopes" ("key_management_provider", "key_version");

CREATE INDEX IF NOT EXISTS "uq_object_retention_active" ON "object_storage"."object_retention_locks" ("object_version_id") WHERE released_at IS NULL;

CREATE INDEX IF NOT EXISTS "ix_object_retention_until" ON "object_storage"."object_retention_locks" ("retain_until");

CREATE INDEX IF NOT EXISTS "ix_object_hold_active" ON "object_storage"."object_legal_holds" ("object_version_id", "hold_state");

CREATE INDEX IF NOT EXISTS "ix_object_hold_case" ON "object_storage"."object_legal_holds" ("legal_case_reference", "hold_state");

CREATE INDEX IF NOT EXISTS "uq_multipart_provider_upload" ON "object_storage"."multipart_uploads" ("namespace_id", "provider_upload_id");

CREATE INDEX IF NOT EXISTS "ix_multipart_expiry" ON "object_storage"."multipart_uploads" ("status", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_multipart_tenant_created" ON "object_storage"."multipart_uploads" ("tenant_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "uq_large_payload_source" ON "object_storage"."large_payload_manifests" ("tenant_id", "source_entity_type", "source_entity_id", "payload_type");

CREATE INDEX IF NOT EXISTS "ix_large_payload_object" ON "object_storage"."large_payload_manifests" ("object_manifest_id");

CREATE INDEX IF NOT EXISTS "uq_dicom_study_uid" ON "object_storage"."dicom_study_manifests" ("tenant_id", "study_instance_uid");

CREATE INDEX IF NOT EXISTS "ix_dicom_study_patient_date" ON "object_storage"."dicom_study_manifests" ("tenant_id", "patient_profile_id", "study_date" DESC);

CREATE INDEX IF NOT EXISTS "ix_dicom_study_accession" ON "object_storage"."dicom_study_manifests" ("tenant_id", "accession_number");

CREATE INDEX IF NOT EXISTS "uq_dicom_series_uid" ON "object_storage"."dicom_series_manifests" ("dicom_study_manifest_id", "series_instance_uid");

CREATE INDEX IF NOT EXISTS "ix_dicom_series_modality" ON "object_storage"."dicom_series_manifests" ("modality", "body_part_examined");

CREATE INDEX IF NOT EXISTS "uq_dicom_instance_uid" ON "object_storage"."dicom_instance_manifests" ("dicom_series_manifest_id", "sop_instance_uid");

CREATE INDEX IF NOT EXISTS "ix_dicom_instance_number" ON "object_storage"."dicom_instance_manifests" ("dicom_series_manifest_id", "instance_number");

CREATE INDEX IF NOT EXISTS "gin_dicom_instance_metadata" ON "object_storage"."dicom_instance_manifests" USING gin (metadata_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS "ix_dicomweb_principal_time" ON "object_storage"."dicomweb_access_logs" ("tenant_id", "principal_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_dicomweb_study_time" ON "object_storage"."dicomweb_access_logs" ("tenant_id", "study_instance_uid", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_dicomweb_occurred" ON "object_storage"."dicomweb_access_logs" USING brin ("occurred_at");

CREATE INDEX IF NOT EXISTS "uq_archive_manifest_hash" ON "object_storage"."archive_manifests" ("tenant_id", "manifest_hash");

CREATE INDEX IF NOT EXISTS "ix_archive_manifest_created" ON "object_storage"."archive_manifests" ("tenant_id", "archive_type", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_object_integrity_version_time" ON "object_storage"."object_integrity_checks" ("object_version_id", "checked_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_object_integrity_status" ON "object_storage"."object_integrity_checks" ("status", "checked_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_object_delete_manifest" ON "object_storage"."object_deletion_markers" ("object_manifest_id", "requested_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_object_delete_verification" ON "object_storage"."object_deletion_markers" ("verification_status", "requested_at" ASC);
