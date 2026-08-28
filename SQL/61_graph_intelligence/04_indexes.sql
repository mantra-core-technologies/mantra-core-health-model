-- SALUD v4.0.10 · módulo 61 · schema graph_intelligence
-- Generado de diagram_61_graph_intelligence.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_node_source" ON "graph_intelligence"."graph_nodes" ("tenant_id", "source_entity_type", "source_entity_id");

CREATE INDEX IF NOT EXISTS "ix_graph_node_type_state" ON "graph_intelligence"."graph_nodes" ("tenant_id", "node_type", "lifecycle_state");

CREATE INDEX IF NOT EXISTS "ft_graph_node_label" ON "graph_intelligence"."graph_nodes" USING gin (to_tsvector('simple', "display_label_redacted"));

CREATE INDEX IF NOT EXISTS "lookup_graph_node_id" ON "graph_intelligence"."graph_nodes" ("node_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_identifier" ON "graph_intelligence"."graph_node_identifiers" ("node_id", "identifier_system", "identifier_value_hash");

CREATE INDEX IF NOT EXISTS "ix_graph_identifier_hash" ON "graph_intelligence"."graph_node_identifiers" ("identifier_system", "identifier_value_hash");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_edge_source" ON "graph_intelligence"."graph_edges" ("tenant_id", "source_entity_type", "source_entity_id", "relationship_type");

CREATE INDEX IF NOT EXISTS "ix_graph_edge_out" ON "graph_intelligence"."graph_edges" ("tenant_id", "from_node_id", "relationship_type", "effective_from" DESC);

CREATE INDEX IF NOT EXISTS "ix_graph_edge_in" ON "graph_intelligence"."graph_edges" ("tenant_id", "to_node_id", "relationship_type", "effective_from" DESC);

CREATE INDEX IF NOT EXISTS "ix_graph_edge_active" ON "graph_intelligence"."graph_edges" ("tenant_id", "relationship_type", "lifecycle_state");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_edge_evidence_hash" ON "graph_intelligence"."graph_edge_evidence" ("edge_id", "evidence_hash");

CREATE INDEX IF NOT EXISTS "ix_graph_edge_evidence_time" ON "graph_intelligence"."graph_edge_evidence" ("edge_id", "observed_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_scope_code" ON "graph_intelligence"."graph_access_scopes" ("tenant_id", "scope_code");

CREATE INDEX IF NOT EXISTS "ix_graph_scope_state" ON "graph_intelligence"."graph_access_scopes" ("tenant_id", "state");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_projection_version" ON "graph_intelligence"."graph_projection_definitions" ("tenant_id", "code", "projection_version");

CREATE INDEX IF NOT EXISTS "ix_graph_projection_state" ON "graph_intelligence"."graph_projection_definitions" ("tenant_id", "state");

CREATE INDEX IF NOT EXISTS "ix_graph_projection_run_status" ON "graph_intelligence"."graph_projection_runs" ("tenant_id", "status", "started_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_graph_projection_run_definition" ON "graph_intelligence"."graph_projection_runs" ("graph_projection_definition_id", "started_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_risk_node_type_model" ON "graph_intelligence"."graph_risk_scores" ("tenant_id", "node_id", "risk_type", "model_version");

CREATE INDEX IF NOT EXISTS "ix_graph_risk_high" ON "graph_intelligence"."graph_risk_scores" ("tenant_id", "risk_type", "score" DESC);

-- TTL "ttl_graph_risk" (expires_at): sin índice TTL en PG; usar job de retención.

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_path_cache" ON "graph_intelligence"."graph_path_cache" ("tenant_id", "start_node_id", "end_node_id", "relationship_filter_hash", "max_hops");

-- TTL "ttl_graph_path" (expires_at): sin índice TTL en PG; usar job de retención.

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_community_algorithm" ON "graph_intelligence"."graph_communities" ("tenant_id", "community_type", "algorithm_version", "id");

CREATE INDEX IF NOT EXISTS "ix_graph_community_member" ON "graph_intelligence"."graph_communities" USING gin ("member_node_ids");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_rule_version" ON "graph_intelligence"."graph_rule_definitions" ("tenant_id", "code", "version");

CREATE INDEX IF NOT EXISTS "ix_graph_rule_state" ON "graph_intelligence"."graph_rule_definitions" ("tenant_id", "state", "severity");

CREATE INDEX IF NOT EXISTS "ix_graph_rule_hit_status" ON "graph_intelligence"."graph_rule_hits" ("tenant_id", "status", "detected_at" ASC);

CREATE INDEX IF NOT EXISTS "ix_graph_rule_hit_node" ON "graph_intelligence"."graph_rule_hits" ("tenant_id", "primary_node_id", "detected_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_graph_delete_status" ON "graph_intelligence"."graph_deletion_jobs" ("tenant_id", "status", "requested_at" ASC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_graph_delete_source_active" ON "graph_intelligence"."graph_deletion_jobs" ("tenant_id", "source_entity_type", "source_entity_id", "status");
