-- SALUD v4.0.10 · módulo 61 · schema graph_intelligence
-- Generado de diagram_61_graph_intelligence.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_nodes" (
    "node_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "node_type" varchar NOT NULL,
    "source_entity_type" varchar NOT NULL,
    "source_entity_id" uuid NOT NULL,
    "source_version" bigint NOT NULL,
    "display_label_redacted" varchar NOT NULL,
    "properties" jsonb NOT NULL,
    "security_labels" varchar[] NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_graph_nodes" PRIMARY KEY ("node_id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_node_identifiers" (
    "id" uuid NOT NULL,
    "node_id" uuid NOT NULL,
    "identifier_system" varchar NOT NULL,
    "identifier_value_hash" varchar NOT NULL,
    "identifier_type" varchar NOT NULL,
    "is_primary" boolean NOT NULL,
    CONSTRAINT "pk_graph_node_identifiers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_edges" (
    "edge_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "from_node_id" uuid NOT NULL,
    "to_node_id" uuid NOT NULL,
    "relationship_type" varchar NOT NULL,
    "directionality" varchar NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "confidence_score" double precision NOT NULL,
    "source_entity_type" varchar NOT NULL,
    "source_entity_id" uuid NOT NULL,
    "properties" jsonb NOT NULL,
    "lifecycle_state" varchar NOT NULL,
    CONSTRAINT "pk_graph_edges" PRIMARY KEY ("edge_id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_edge_evidence" (
    "id" uuid NOT NULL,
    "edge_id" uuid NOT NULL,
    "evidence_type" varchar NOT NULL,
    "source_reference" varchar NOT NULL,
    "evidence_hash" varchar NOT NULL,
    "observed_at" timestamptz NOT NULL,
    "confidence_delta" double precision NOT NULL,
    CONSTRAINT "pk_graph_edge_evidence" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_access_scopes" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "scope_code" varchar NOT NULL,
    "allowed_node_types" varchar[] NOT NULL,
    "allowed_relationship_types" varchar[] NOT NULL,
    "purpose_of_use_codes" varchar[] NOT NULL,
    "max_hops" smallint NOT NULL,
    "requires_patient_context" boolean NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_graph_access_scopes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_projection_definitions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "source_dataset_codes" varchar[] NOT NULL,
    "node_mapping_rules" jsonb NOT NULL,
    "edge_mapping_rules" jsonb NOT NULL,
    "projection_version" varchar NOT NULL,
    "state" varchar NOT NULL,
    CONSTRAINT "pk_graph_projection_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_projection_runs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "graph_projection_definition_id" uuid NOT NULL,
    "status" varchar NOT NULL,
    "source_checkpoint" varchar NOT NULL,
    "nodes_written" bigint NOT NULL,
    "edges_written" bigint NOT NULL,
    "started_at" timestamptz NOT NULL,
    "completed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_graph_projection_runs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_risk_scores" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "node_id" uuid NOT NULL,
    "risk_type" varchar NOT NULL,
    "score" double precision NOT NULL,
    "model_version" varchar NOT NULL,
    "explanation_redacted" text NOT NULL,
    "calculated_at" timestamptz NOT NULL,
    "expires_at" timestamptz NOT NULL,
    CONSTRAINT "pk_graph_risk_scores" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_path_cache" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "start_node_id" uuid NOT NULL,
    "end_node_id" uuid NOT NULL,
    "relationship_filter_hash" varchar NOT NULL,
    "max_hops" smallint NOT NULL,
    "path_nodes" uuid[] NOT NULL,
    "path_edges" uuid[] NOT NULL,
    "calculated_at" timestamptz NOT NULL,
    "expires_at" timestamptz NOT NULL,
    CONSTRAINT "pk_graph_path_cache" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_communities" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "community_type" varchar NOT NULL,
    "algorithm_version" varchar NOT NULL,
    "member_node_ids" uuid[] NOT NULL,
    "score" double precision NOT NULL,
    "calculated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_graph_communities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_rule_definitions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "rule_type" varchar NOT NULL,
    "traversal_expression" text NOT NULL,
    "severity" varchar NOT NULL,
    "state" varchar NOT NULL,
    "version" varchar NOT NULL,
    CONSTRAINT "pk_graph_rule_definitions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_rule_hits" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "graph_rule_definition_id" uuid NOT NULL,
    "primary_node_id" uuid NOT NULL,
    "related_node_ids" uuid[] NOT NULL,
    "evidence_edge_ids" uuid[] NOT NULL,
    "status" varchar NOT NULL,
    "detected_at" timestamptz NOT NULL,
    "resolved_at" timestamptz NOT NULL,
    CONSTRAINT "pk_graph_rule_hits" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "graph_intelligence"."graph_deletion_jobs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "source_entity_type" varchar NOT NULL,
    "source_entity_id" uuid NOT NULL,
    "status" varchar NOT NULL,
    "nodes_deleted" integer NOT NULL,
    "edges_deleted" integer NOT NULL,
    "requested_at" timestamptz NOT NULL,
    "verified_at" timestamptz NOT NULL,
    CONSTRAINT "pk_graph_deletion_jobs" PRIMARY KEY ("id")
);
