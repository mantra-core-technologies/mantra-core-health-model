// SALUD v4.0.1 · módulo 55 document_store · MongoDB (mongosh) — generado de los .puml

db.createCollection("document_envelopes", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "document_type",
        "lifecycle_state",
        "payload_ref"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "document_type": {
          "bsonType": "string"
        },
        "lifecycle_state": {
          "bsonType": "string"
        },
        "payload_ref": {
          "bsonType": "object"
        },
        "security_labels": {
          "bsonType": "array"
        },
        "purpose_restrictions": {
          "bsonType": "array"
        },
        "lineage": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.document_envelopes.createIndex({"tenant_id": 1, "document_id": 1}, {"name": "uq_doc_tenant_id", "unique": true});
db.document_envelopes.createIndex({"tenant_id": 1, "document_type": 1, "updated_at": -1}, {"name": "ix_doc_tenant_type_updated"});
db.document_envelopes.createIndex({"tenant_id": 1, "patient_profile_id": 1, "updated_at": -1}, {"name": "ix_doc_patient_updated", "partialFilterExpression": {"patient_profile_id": {"$exists": true}}});
db.document_envelopes.createIndex({"tenant_id": 1, "source_system": 1, "external_id": 1}, {"name": "ix_doc_external", "partialFilterExpression": {"external_id": {"$exists": true}}});
db.document_envelopes.createIndex({"expires_at": 1}, {"name": "ttl_doc_expiry", "partialFilterExpression": {"expires_at": {"$exists": true}}, "expireAfterSeconds": 0});

db.createCollection("document_version_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "logical_document_id",
        "version_number",
        "change_type",
        "payload"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "logical_document_id": {
          "bsonType": "binData"
        },
        "version_number": {
          "bsonType": "int"
        },
        "supersedes_version_id": {
          "bsonType": "binData"
        },
        "change_type": {
          "bsonType": "string"
        },
        "payload": {
          "bsonType": "object"
        },
        "provenance": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.document_version_documents.createIndex({"tenant_id": 1, "logical_document_id": 1, "version_number": 1}, {"name": "uq_docver_logical_version", "unique": true});
db.document_version_documents.createIndex({"tenant_id": 1, "logical_document_id": 1, "created_at": -1}, {"name": "ix_docver_logical_created"});
db.document_version_documents.createIndex({"tenant_id": 1, "content_hash": 1}, {"name": "ix_docver_hash"});

db.createCollection("fhir_resource_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "resource_type",
        "logical_id",
        "fhir_version",
        "version_id",
        "last_updated_at",
        "resource"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "resource_type": {
          "bsonType": "string"
        },
        "logical_id": {
          "bsonType": "string"
        },
        "fhir_version": {
          "bsonType": "string"
        },
        "version_id": {
          "bsonType": "string"
        },
        "last_updated_at": {
          "bsonType": "date"
        },
        "encounter_id": {
          "bsonType": "binData"
        },
        "profile_urls": {
          "bsonType": "array"
        },
        "identifiers": {
          "bsonType": "array"
        },
        "references": {
          "bsonType": "array"
        },
        "resource": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.fhir_resource_documents.createIndex({"tenant_id": 1, "resource_type": 1, "logical_id": 1, "version_id": 1}, {"name": "uq_fhir_logical_version", "unique": true});
db.fhir_resource_documents.createIndex({"tenant_id": 1, "patient_profile_id": 1, "last_updated_at": -1}, {"name": "ix_fhir_patient_updated"});
db.fhir_resource_documents.createIndex({"tenant_id": 1, "encounter_id": 1, "resource_type": 1}, {"name": "ix_fhir_encounter_type", "partialFilterExpression": {"encounter_id": {"$exists": true}}});
db.fhir_resource_documents.createIndex({"tenant_id": 1, "identifiers.system": 1, "identifiers.value": 1}, {"name": "ix_fhir_identifiers"});
db.fhir_resource_documents.createIndex({"tenant_id": 1, "references.reference": 1}, {"name": "ix_fhir_references"});

db.createCollection("fhir_bundle_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "bundle_type",
        "bundle_identifier",
        "entry_count",
        "bundle"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "bundle_type": {
          "bsonType": "string"
        },
        "bundle_identifier": {
          "bsonType": "string"
        },
        "entry_count": {
          "bsonType": "int"
        },
        "patient_profile_ids": {
          "bsonType": "array"
        },
        "source_batch_id": {
          "bsonType": "binData"
        },
        "bundle": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.fhir_bundle_documents.createIndex({"tenant_id": 1, "bundle_identifier": 1}, {"name": "uq_fhir_bundle_identifier", "unique": true});
db.fhir_bundle_documents.createIndex({"tenant_id": 1, "source_batch_id": 1, "created_at": -1}, {"name": "ix_fhir_bundle_batch"});
db.fhir_bundle_documents.createIndex({"tenant_id": 1, "patient_profile_ids": 1}, {"name": "ix_fhir_bundle_patients"});

db.createCollection("external_payload_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "integration_contract_id",
        "operation_code",
        "direction",
        "correlation_id",
        "payload"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "integration_contract_id": {
          "bsonType": "binData"
        },
        "operation_code": {
          "bsonType": "string"
        },
        "direction": {
          "bsonType": "string"
        },
        "correlation_id": {
          "bsonType": "string"
        },
        "request_metadata": {
          "bsonType": "object"
        },
        "response_metadata": {
          "bsonType": "object"
        },
        "payload": {
          "bsonType": "object"
        },
        "transport_headers_redacted": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.external_payload_documents.createIndex({"tenant_id": 1, "integration_contract_id": 1, "correlation_id": 1, "direction": 1}, {"name": "uq_ext_payload_correlation", "unique": true});
db.external_payload_documents.createIndex({"tenant_id": 1, "operation_code": 1, "created_at": -1}, {"name": "ix_ext_payload_operation_created"});
db.external_payload_documents.createIndex({"expires_at": 1}, {"name": "ttl_ext_payload_expiry", "partialFilterExpression": {"expires_at": {"$exists": true}}, "expireAfterSeconds": 0});

db.createCollection("webhook_payload_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "provider_code",
        "event_type",
        "provider_event_id",
        "received_at",
        "verification_status",
        "payload"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "provider_code": {
          "bsonType": "string"
        },
        "event_type": {
          "bsonType": "string"
        },
        "provider_event_id": {
          "bsonType": "string"
        },
        "received_at": {
          "bsonType": "date"
        },
        "verification_status": {
          "bsonType": "string"
        },
        "signature_metadata": {
          "bsonType": "object"
        },
        "payload": {
          "bsonType": "object"
        },
        "processing_outcome": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.webhook_payload_documents.createIndex({"tenant_id": 1, "provider_code": 1, "provider_event_id": 1}, {"name": "uq_webhook_provider_event", "unique": true});
db.webhook_payload_documents.createIndex({"tenant_id": 1, "event_type": 1, "received_at": -1}, {"name": "ix_webhook_type_received"});
db.webhook_payload_documents.createIndex({"tenant_id": 1, "verification_status": 1, "received_at": 1}, {"name": "ix_webhook_verification"});

db.createCollection("dynamic_form_snapshot_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "form_definition_id",
        "form_version",
        "response_id",
        "answers"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "form_definition_id": {
          "bsonType": "binData"
        },
        "form_version": {
          "bsonType": "string"
        },
        "response_id": {
          "bsonType": "binData"
        },
        "encounter_id": {
          "bsonType": "binData"
        },
        "answers": {
          "bsonType": "array"
        },
        "computed_fields": {
          "bsonType": "object"
        },
        "validation_result": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.dynamic_form_snapshot_documents.createIndex({"tenant_id": 1, "response_id": 1, "schema_version": 1}, {"name": "uq_form_snapshot_response_version", "unique": true});
db.dynamic_form_snapshot_documents.createIndex({"tenant_id": 1, "patient_profile_id": 1, "created_at": -1}, {"name": "ix_form_snapshot_patient"});
db.dynamic_form_snapshot_documents.createIndex({"tenant_id": 1, "encounter_id": 1, "created_at": -1}, {"name": "ix_form_snapshot_encounter", "partialFilterExpression": {"encounter_id": {"$exists": true}}});

db.createCollection("context_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "context_scope",
        "country_code",
        "context_code",
        "effective_from",
        "facts"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "context_scope": {
          "bsonType": "string"
        },
        "country_code": {
          "bsonType": "string"
        },
        "organization_id": {
          "bsonType": "binData"
        },
        "context_code": {
          "bsonType": "string"
        },
        "effective_from": {
          "bsonType": "date"
        },
        "effective_to": {
          "bsonType": "date"
        },
        "facts": {
          "bsonType": "object"
        },
        "sources": {
          "bsonType": "array"
        }
      }
    }
  }
});

db.context_documents.createIndex({"tenant_id": 1, "context_scope": 1, "context_code": 1, "effective_from": 1}, {"name": "uq_context_scope_code_effective", "unique": true});
db.context_documents.createIndex({"country_code": 1, "effective_from": -1}, {"name": "ix_context_country_effective"});
db.context_documents.createIndex({"tenant_id": 1, "organization_id": 1, "effective_from": -1}, {"name": "ix_context_org_effective", "partialFilterExpression": {"organization_id": {"$exists": true}}});

db.createCollection("workflow_definition_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "workflow_code",
        "workflow_version",
        "trigger_definition",
        "nodes",
        "edges",
        "guards"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "workflow_code": {
          "bsonType": "string"
        },
        "workflow_version": {
          "bsonType": "string"
        },
        "trigger_definition": {
          "bsonType": "object"
        },
        "nodes": {
          "bsonType": "array"
        },
        "edges": {
          "bsonType": "array"
        },
        "guards": {
          "bsonType": "array"
        },
        "compensation_rules": {
          "bsonType": "array"
        }
      }
    }
  }
});

db.workflow_definition_documents.createIndex({"tenant_id": 1, "workflow_code": 1, "workflow_version": 1}, {"name": "uq_workflow_code_version", "unique": true});
db.workflow_definition_documents.createIndex({"tenant_id": 1, "lifecycle_state": 1, "updated_at": -1}, {"name": "ix_workflow_state_updated"});
db.workflow_definition_documents.createIndex({"tenant_id": 1, "nodes.type": 1}, {"name": "ix_workflow_nodes_type"});

db.createCollection("ai_execution_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "agent_definition_id",
        "execution_id",
        "model_provider",
        "model_id",
        "model_version"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "agent_definition_id": {
          "bsonType": "binData"
        },
        "execution_id": {
          "bsonType": "binData"
        },
        "model_provider": {
          "bsonType": "string"
        },
        "model_id": {
          "bsonType": "string"
        },
        "model_version": {
          "bsonType": "string"
        },
        "prompt_version_id": {
          "bsonType": "binData"
        },
        "input_redacted": {
          "bsonType": "object"
        },
        "retrieved_context": {
          "bsonType": "array"
        },
        "output_redacted": {
          "bsonType": "object"
        },
        "token_usage": {
          "bsonType": "object"
        },
        "latency_ms": {
          "bsonType": "int"
        },
        "evaluation_summary": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.ai_execution_documents.createIndex({"tenant_id": 1, "execution_id": 1}, {"name": "uq_ai_execution", "unique": true});
db.ai_execution_documents.createIndex({"tenant_id": 1, "agent_definition_id": 1, "created_at": -1}, {"name": "ix_ai_agent_created"});
db.ai_execution_documents.createIndex({"tenant_id": 1, "model_provider": 1, "model_id": 1, "created_at": -1}, {"name": "ix_ai_model_created"});
db.ai_execution_documents.createIndex({"expires_at": 1}, {"name": "ttl_ai_expiry", "partialFilterExpression": {"expires_at": {"$exists": true}}, "expireAfterSeconds": 0});

db.createCollection("cms_content_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "content_type",
        "slug",
        "locale",
        "publication_state",
        "title",
        "body_blocks"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "content_type": {
          "bsonType": "string"
        },
        "slug": {
          "bsonType": "string"
        },
        "locale": {
          "bsonType": "string"
        },
        "publication_state": {
          "bsonType": "string"
        },
        "author_user_id": {
          "bsonType": "binData"
        },
        "title": {
          "bsonType": "string"
        },
        "summary": {
          "bsonType": "string"
        },
        "body_blocks": {
          "bsonType": "array"
        },
        "seo_metadata": {
          "bsonType": "object"
        },
        "publication_window": {
          "bsonType": "object"
        }
      }
    }
  }
});

db.cms_content_documents.createIndex({"tenant_id": 1, "slug": 1, "locale": 1}, {"name": "uq_cms_slug_locale", "unique": true});
db.cms_content_documents.createIndex({"tenant_id": 1, "content_type": 1, "publication_state": 1, "publication_window.start_at": 1}, {"name": "ix_cms_type_state_window"});
db.cms_content_documents.createIndex({"title": "text", "summary": "text", "body_blocks.text": "text"}, {"name": "text_cms_content"});

db.createCollection("document_quarantine_documents", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "original_collection",
        "quarantine_reason",
        "validation_errors",
        "original_payload"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "original_collection": {
          "bsonType": "string"
        },
        "quarantine_reason": {
          "bsonType": "string"
        },
        "validation_errors": {
          "bsonType": "array"
        },
        "original_payload": {
          "bsonType": "object"
        },
        "remediation_state": {
          "bsonType": "string"
        },
        "remediated_document_id": {
          "bsonType": "binData"
        }
      }
    }
  }
});

db.document_quarantine_documents.createIndex({"tenant_id": 1, "quarantine_reason": 1, "remediation_state": 1, "created_at": 1}, {"name": "ix_quarantine_reason_state"});
db.document_quarantine_documents.createIndex({"tenant_id": 1, "original_collection": 1, "created_at": -1}, {"name": "ix_quarantine_original"});
db.document_quarantine_documents.createIndex({"expires_at": 1}, {"name": "ttl_quarantine_expiry", "partialFilterExpression": {"expires_at": {"$exists": true}}, "expireAfterSeconds": 0});

db.createCollection("document_schema_registry", {
  "validator": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "document_id",
        "tenant_id",
        "schema_version",
        "source_system",
        "content_hash",
        "contains_phi",
        "encryption_profile_code",
        "created_at",
        "retention_class",
        "collection_code",
        "governed_schema_version",
        "json_schema",
        "compatibility_mode",
        "state"
      ],
      "properties": {
        "_id": {
          "bsonType": "objectId"
        },
        "document_id": {
          "bsonType": "binData"
        },
        "tenant_id": {
          "bsonType": "binData"
        },
        "patient_profile_id": {
          "bsonType": "binData"
        },
        "schema_version": {
          "bsonType": "string"
        },
        "source_system": {
          "bsonType": "string"
        },
        "external_id": {
          "bsonType": "string"
        },
        "content_hash": {
          "bsonType": "string"
        },
        "contains_phi": {
          "bsonType": "bool"
        },
        "encryption_profile_code": {
          "bsonType": "string"
        },
        "created_at": {
          "bsonType": "date"
        },
        "updated_at": {
          "bsonType": "date"
        },
        "expires_at": {
          "bsonType": "date"
        },
        "retention_class": {
          "bsonType": "string"
        },
        "collection_code": {
          "bsonType": "string"
        },
        "governed_schema_version": {
          "bsonType": "string"
        },
        "json_schema": {
          "bsonType": "object"
        },
        "compatibility_mode": {
          "bsonType": "string"
        },
        "state": {
          "bsonType": "string"
        }
      }
    }
  }
});

db.document_schema_registry.createIndex({"tenant_id": 1, "collection_code": 1, "governed_schema_version": 1}, {"name": "uq_schema_collection_version", "unique": true});
db.document_schema_registry.createIndex({"tenant_id": 1, "collection_code": 1, "lifecycle_state": 1}, {"name": "ix_schema_collection_state"});
