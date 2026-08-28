-- SALUD v4.0.10 · módulo 60 · schema object_storage
-- Generado de diagram_60_object_storage.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "object_storage"."object_namespaces" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "backend_code" varchar NOT NULL,
    "region_code" varchar NOT NULL,
    "bucket_or_container" varchar NOT NULL,
    "object_key_prefix" varchar NOT NULL,
    "default_storage_class" varchar NOT NULL,
    "versioning_enabled" boolean NOT NULL,
    "object_lock_enabled" boolean NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_object_namespaces" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_manifests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "namespace_id" uuid NOT NULL,
    "logical_object_id" uuid NOT NULL,
    "object_type" varchar NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "current_version_id" uuid NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    "retention_policy_code" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_object_manifests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_versions" (
    "id" uuid NOT NULL,
    "object_manifest_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "provider_version_id" varchar NOT NULL,
    "object_key" varchar NOT NULL,
    "mime_type" varchar NOT NULL,
    "size_bytes" bigint NOT NULL,
    "sha256" varchar NOT NULL,
    "etag" varchar NOT NULL,
    "compression" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "supersedes_version_id" uuid NOT NULL,
    CONSTRAINT "pk_object_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_locations" (
    "id" uuid NOT NULL,
    "object_version_id" uuid NOT NULL,
    "namespace_id" uuid NOT NULL,
    "placement_role" varchar NOT NULL,
    "provider_uri" varchar NOT NULL,
    "storage_class" varchar NOT NULL,
    "replication_state" varchar NOT NULL,
    "verified_at" timestamptz NOT NULL,
    CONSTRAINT "pk_object_locations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_checksums" (
    "id" uuid NOT NULL,
    "object_version_id" uuid NOT NULL,
    "algorithm" varchar NOT NULL,
    "checksum" varchar NOT NULL,
    "source" varchar NOT NULL,
    "verified_at" timestamptz NOT NULL,
    "verification_status" varchar NOT NULL,
    CONSTRAINT "pk_object_checksums" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_encryption_envelopes" (
    "id" uuid NOT NULL,
    "object_version_id" uuid NOT NULL,
    "algorithm" varchar NOT NULL,
    "key_management_provider" varchar NOT NULL,
    "encrypted_data_key" bytea NOT NULL,
    "key_version" varchar NOT NULL,
    "encryption_context_hash" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_object_encryption_envelopes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_retention_locks" (
    "id" uuid NOT NULL,
    "object_version_id" uuid NOT NULL,
    "lock_mode" varchar NOT NULL,
    "retain_until" timestamptz NOT NULL,
    "policy_code" varchar NOT NULL,
    "applied_at" timestamptz NOT NULL,
    "released_at" timestamptz NOT NULL,
    CONSTRAINT "pk_object_retention_locks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_legal_holds" (
    "id" uuid NOT NULL,
    "object_version_id" uuid NOT NULL,
    "legal_case_reference" varchar NOT NULL,
    "hold_state" varchar NOT NULL,
    "placed_by_user_id" uuid NOT NULL,
    "placed_at" timestamptz NOT NULL,
    "released_at" timestamptz NOT NULL,
    CONSTRAINT "pk_object_legal_holds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."multipart_uploads" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "namespace_id" uuid NOT NULL,
    "provider_upload_id" varchar NOT NULL,
    "target_object_key" varchar NOT NULL,
    "expected_size_bytes" bigint NOT NULL,
    "received_size_bytes" bigint NOT NULL,
    "status" varchar NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_multipart_uploads" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."large_payload_manifests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "payload_type" varchar NOT NULL,
    "source_entity_type" varchar NOT NULL,
    "source_entity_id" uuid NOT NULL,
    "object_manifest_id" uuid NOT NULL,
    "content_hash" varchar NOT NULL,
    "contains_phi" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_large_payload_manifests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."dicom_study_manifests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "imaging_study_id" uuid NOT NULL,
    "study_instance_uid" varchar NOT NULL,
    "accession_number" varchar NOT NULL,
    "study_date" date NOT NULL,
    "modality_codes" varchar[] NOT NULL,
    "series_count" integer NOT NULL,
    "instance_count" integer NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    CONSTRAINT "pk_dicom_study_manifests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."dicom_series_manifests" (
    "id" uuid NOT NULL,
    "dicom_study_manifest_id" uuid NOT NULL,
    "series_instance_uid" varchar NOT NULL,
    "modality" varchar NOT NULL,
    "series_number" integer NOT NULL,
    "body_part_examined" varchar NOT NULL,
    "instance_count" integer NOT NULL,
    "thumbnail_object_manifest_id" uuid NOT NULL,
    CONSTRAINT "pk_dicom_series_manifests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."dicom_instance_manifests" (
    "id" uuid NOT NULL,
    "dicom_series_manifest_id" uuid NOT NULL,
    "sop_instance_uid" varchar NOT NULL,
    "sop_class_uid" varchar NOT NULL,
    "instance_number" integer NOT NULL,
    "transfer_syntax_uid" varchar NOT NULL,
    "object_manifest_id" uuid NOT NULL,
    "frame_count" integer NOT NULL,
    "metadata_json" jsonb NOT NULL,
    CONSTRAINT "pk_dicom_instance_manifests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."dicomweb_access_logs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "principal_id" uuid NOT NULL,
    "operation" varchar NOT NULL,
    "study_instance_uid" varchar NOT NULL,
    "series_instance_uid" varchar,
    "sop_instance_uid" varchar,
    "purpose_of_use_code" varchar NOT NULL,
    "outcome" varchar NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_dicomweb_access_logs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."archive_manifests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "archive_type" varchar NOT NULL,
    "source_scope_json" jsonb NOT NULL,
    "object_manifest_id" uuid NOT NULL,
    "record_count" bigint NOT NULL,
    "manifest_hash" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    "verified_at" timestamptz NOT NULL,
    CONSTRAINT "pk_archive_manifests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_integrity_checks" (
    "id" uuid NOT NULL,
    "object_version_id" uuid NOT NULL,
    "check_type" varchar NOT NULL,
    "expected_hash" varchar NOT NULL,
    "actual_hash" varchar NOT NULL,
    "status" varchar NOT NULL,
    "checked_at" timestamptz NOT NULL,
    "repair_job_id" uuid NOT NULL,
    CONSTRAINT "pk_object_integrity_checks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "object_storage"."object_deletion_markers" (
    "id" uuid NOT NULL,
    "object_manifest_id" uuid NOT NULL,
    "requested_by_job_id" uuid NOT NULL,
    "provider_delete_marker" varchar NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "effective_at" timestamptz NOT NULL,
    "verification_status" varchar NOT NULL,
    CONSTRAINT "pk_object_deletion_markers" PRIMARY KEY ("id")
);
