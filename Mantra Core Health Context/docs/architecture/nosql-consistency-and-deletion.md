# Consistencia, reconciliación y eliminación entre stores

## Semántica

Las proyecciones son de consistencia eventual y entrega al menos una vez. La corrección se obtiene mediante idempotencia, versionado monotónico, hashes, checkpoints y reconciliación. No se declara exactamente una vez de extremo a extremo.

## Identidad de una proyección

Cada documento derivado debe conservar como mínimo:

- tenant_id;
- canonical_entity_id;
- canonical_version;
- source_event_id;
- projection_version;
- payload_hash;
- projected_at.

## Eliminación

Una solicitud se expande en targets para documentos, búsqueda, caché, vectores, objetos, series temporales, grafos y lakehouse. La solicitud termina únicamente cuando cada target está verificado como ausente, anonimizado según política, o bloqueado de manera explícita por retención/legal hold.

## Recuperación

Toda proyección debe poder reconstruirse desde la fuente canónica, outbox durable, archivos originales o manifests gobernados. Los workers mantienen dead-letter, reintentos limitados, alertas, métricas y apagado controlado.
