-- SALUD v4.0.1 · módulo 59 vector_rag · pgvector — generado de los .puml

CREATE EXTENSION IF NOT EXISTS vector;

CREATE SCHEMA IF NOT EXISTS "vector_rag";

CREATE TABLE IF NOT EXISTS "vector_rag"."vector_collections" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "dimension" integer NOT NULL,
    "distance_metric" varchar NOT NULL,
    "embedding_model_version_id" uuid NOT NULL,
    "contains_phi" boolean NOT NULL,
    "access_policy_id" uuid NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_vector_collections" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."vector_documents" (
    "id" uuid NOT NULL,
    "vector_collection_id" uuid NOT NULL,
    "source_document_id" uuid NOT NULL,
    "source_version_id" uuid NOT NULL,
    "document_type" varchar NOT NULL,
    "language" varchar NOT NULL,
    "title" varchar NOT NULL,
    "content_hash" varchar NOT NULL,
    "contains_phi" boolean NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "security_labels" varchar[] NOT NULL,
    "purpose_of_use_codes" varchar[] NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_vector_documents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."vector_chunks" (
    "id" uuid NOT NULL,
    "vector_document_id" uuid NOT NULL,
    "chunk_number" integer NOT NULL,
    "chunk_text_redacted" text NOT NULL,
    "token_count" integer NOT NULL,
    "chunk_hash" varchar NOT NULL,
    "section_path" varchar NOT NULL,
    "metadata" jsonb NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_vector_chunks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."vector_embeddings" (
    "id" uuid NOT NULL,
    "vector_chunk_id" uuid NOT NULL,
    "embedding_model_version_id" uuid NOT NULL,
    "embedding" vector(1536) NOT NULL,
    "embedding_hash" varchar NOT NULL,
    "generated_at" timestamptz NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    CONSTRAINT "pk_vector_embeddings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."embedding_model_versions" (
    "id" uuid NOT NULL,
    "provider_code" varchar NOT NULL,
    "model_id" varchar NOT NULL,
    "model_version" varchar NOT NULL,
    "dimension" integer NOT NULL,
    "distance_metric" varchar NOT NULL,
    "tokenizer_version" varchar NOT NULL,
    "approved_for_phi" boolean NOT NULL,
    "approved_at" timestamptz,
    "retired_at" timestamptz,
    CONSTRAINT "pk_embedding_model_versions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."embedding_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "vector_collection_id" uuid NOT NULL,
    "job_type" varchar NOT NULL,
    "source_scope" jsonb NOT NULL,
    "requested_by_user_id" uuid NOT NULL,
    "status" varchar NOT NULL,
    "total_chunks" integer NOT NULL,
    "completed_chunks" integer NOT NULL,
    "failed_chunks" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_embedding_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."rag_access_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "allowed_principal_types" varchar[] NOT NULL,
    "allowed_purpose_codes" varchar[] NOT NULL,
    "allowed_security_labels" varchar[] NOT NULL,
    "patient_scope_required" boolean NOT NULL,
    "consent_required" boolean NOT NULL,
    "field_redaction_profile" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_rag_access_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."vector_tenant_bindings" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "vector_collection_id" uuid NOT NULL,
    "namespace" varchar NOT NULL,
    "encryption_profile_code" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_vector_tenant_bindings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."retrieval_sessions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "principal_id" uuid NOT NULL,
    "agent_id" uuid NOT NULL,
    "purpose_of_use_code" varchar NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "consent_directive_id" uuid NOT NULL,
    "query_text_redacted" text NOT NULL,
    "query_hash" varchar NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    "status" varchar NOT NULL,
    CONSTRAINT "pk_retrieval_sessions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."retrieval_candidates" (
    "id" uuid NOT NULL,
    "retrieval_session_id" uuid NOT NULL,
    "vector_chunk_id" uuid NOT NULL,
    "rank" integer NOT NULL,
    "vector_score" double precision NOT NULL,
    "lexical_score" double precision NOT NULL,
    "reranker_score" double precision NOT NULL,
    "authorization_decision" varchar NOT NULL,
    "selected" boolean NOT NULL,
    CONSTRAINT "pk_retrieval_candidates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."retrieval_evidence" (
    "id" uuid NOT NULL,
    "retrieval_session_id" uuid NOT NULL,
    "vector_chunk_id" uuid NOT NULL,
    "citation_number" integer NOT NULL,
    "quoted_text_redacted" text NOT NULL,
    "source_uri" varchar NOT NULL,
    "source_version_id" uuid NOT NULL,
    "evidence_hash" varchar NOT NULL,
    CONSTRAINT "pk_retrieval_evidence" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."retrieval_feedback_events" (
    "id" uuid NOT NULL,
    "retrieval_session_id" uuid NOT NULL,
    "principal_id" uuid NOT NULL,
    "feedback_type" varchar NOT NULL,
    "relevance_score" smallint NOT NULL,
    "safety_issue_code" varchar NOT NULL,
    "comment_redacted" text,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_retrieval_feedback_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."vector_deletion_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "source_document_id" uuid NOT NULL,
    "deletion_reason" varchar NOT NULL,
    "status" varchar NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "verified_at" timestamptz NOT NULL,
    CONSTRAINT "pk_vector_deletion_jobs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "vector_rag"."vector_reconciliation_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "vector_collection_id" uuid NOT NULL,
    "canonical_manifest_hash" varchar NOT NULL,
    "vector_manifest_hash" varchar NOT NULL,
    "missing_count" integer NOT NULL,
    "orphan_count" integer NOT NULL,
    "mismatched_count" integer NOT NULL,
    "status" varchar NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_vector_reconciliation_runs" PRIMARY KEY ("id")
);


-- Índices

CREATE UNIQUE INDEX IF NOT EXISTS "uq_vector_collection_tenant_code" ON "vector_rag"."vector_collections" ("tenant_id", "code");
CREATE INDEX IF NOT EXISTS "ix_vector_collection_state" ON "vector_rag"."vector_collections" ("tenant_id", "lifecycle_state");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vector_doc_source_version" ON "vector_rag"."vector_documents" ("vector_collection_id", "source_document_id", "source_version_id");
CREATE INDEX IF NOT EXISTS "ix_vector_doc_patient" ON "vector_rag"."vector_documents" ("vector_collection_id", "patient_profile_id", "created_at");
CREATE INDEX IF NOT EXISTS "gin_vector_doc_labels" ON "vector_rag"."vector_documents" USING gin ("security_labels", "purpose_of_use_codes");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vector_chunk_number" ON "vector_rag"."vector_chunks" ("vector_document_id", "chunk_number");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vector_chunk_hash" ON "vector_rag"."vector_chunks" ("vector_document_id", "chunk_hash");
CREATE INDEX IF NOT EXISTS "gin_vector_chunk_metadata" ON "vector_rag"."vector_chunks" USING gin ("metadata");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vector_embedding_chunk_model" ON "vector_rag"."vector_embeddings" ("vector_chunk_id", "embedding_model_version_id");
CREATE INDEX IF NOT EXISTS "hnsw_vector_embedding" ON "vector_rag"."vector_embeddings" USING hnsw ("embedding" vector_cosine_ops);  -- ajustar ops según distance_metric
CREATE INDEX IF NOT EXISTS "ix_vector_embedding_state" ON "vector_rag"."vector_embeddings" ("lifecycle_state", "generated_at");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_embedding_model_version" ON "vector_rag"."embedding_model_versions" ("provider_code", "model_id", "model_version");
CREATE INDEX IF NOT EXISTS "ix_embedding_model_approval" ON "vector_rag"."embedding_model_versions" ("approved_for_phi", "retired_at");
CREATE INDEX IF NOT EXISTS "ix_embedding_jobs_tenant_status" ON "vector_rag"."embedding_jobs" ("tenant_id", "status", "created_at");
CREATE INDEX IF NOT EXISTS "ix_embedding_jobs_collection" ON "vector_rag"."embedding_jobs" ("vector_collection_id", "created_at");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_rag_policy_tenant_code" ON "vector_rag"."rag_access_policies" ("tenant_id", "code");
CREATE INDEX IF NOT EXISTS "gin_rag_policy_purposes" ON "vector_rag"."rag_access_policies" USING gin ("allowed_purpose_codes");
CREATE INDEX IF NOT EXISTS "gin_rag_policy_labels" ON "vector_rag"."rag_access_policies" USING gin ("allowed_security_labels");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vector_binding_tenant_collection" ON "vector_rag"."vector_tenant_bindings" ("tenant_id", "vector_collection_id");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vector_binding_namespace" ON "vector_rag"."vector_tenant_bindings" ("namespace");
CREATE INDEX IF NOT EXISTS "ix_retrieval_session_principal" ON "vector_rag"."retrieval_sessions" ("tenant_id", "principal_id", "started_at");
CREATE INDEX IF NOT EXISTS "ix_retrieval_session_patient" ON "vector_rag"."retrieval_sessions" ("tenant_id", "patient_profile_id", "started_at");
CREATE INDEX IF NOT EXISTS "ix_retrieval_session_hash" ON "vector_rag"."retrieval_sessions" ("tenant_id", "query_hash", "started_at");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_retrieval_candidate_rank" ON "vector_rag"."retrieval_candidates" ("retrieval_session_id", "rank");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_retrieval_candidate_chunk" ON "vector_rag"."retrieval_candidates" ("retrieval_session_id", "vector_chunk_id");
CREATE INDEX IF NOT EXISTS "ix_retrieval_candidate_selected" ON "vector_rag"."retrieval_candidates" ("retrieval_session_id", "selected", "rank");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_retrieval_evidence_citation" ON "vector_rag"."retrieval_evidence" ("retrieval_session_id", "citation_number");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_retrieval_evidence_hash" ON "vector_rag"."retrieval_evidence" ("retrieval_session_id", "evidence_hash");
CREATE INDEX IF NOT EXISTS "ix_retrieval_feedback_session" ON "vector_rag"."retrieval_feedback_events" ("retrieval_session_id", "created_at");
CREATE INDEX IF NOT EXISTS "ix_retrieval_feedback_safety" ON "vector_rag"."retrieval_feedback_events" ("safety_issue_code", "created_at");
CREATE INDEX IF NOT EXISTS "ix_vector_delete_tenant_status" ON "vector_rag"."vector_deletion_jobs" ("tenant_id", "status", "requested_at");
CREATE INDEX IF NOT EXISTS "ix_vector_delete_patient" ON "vector_rag"."vector_deletion_jobs" ("tenant_id", "patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_vector_reconcile_collection_time" ON "vector_rag"."vector_reconciliation_runs" ("vector_collection_id", "started_at");
CREATE INDEX IF NOT EXISTS "ix_vector_reconcile_status" ON "vector_rag"."vector_reconciliation_runs" ("tenant_id", "status", "started_at");
