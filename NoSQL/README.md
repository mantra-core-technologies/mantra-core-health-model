# NoSQL — SALUD v4.0.1 (stores especializados en formato nativo)

Los 5 stores no relacionales del modelo, materializados en el **formato nativo de cada motor**
(generados fielmente desde los `.puml` por `salud-db/gen_nosql.py`). Complementan la base
relacional de [`../SQL/`](../SQL/).

| Carpeta | Motor | Artefacto | Cómo se aplica |
|---------|-------|-----------|----------------|
| `55_document_store_mongodb/` | **MongoDB** | `*.mongodb.js` | `mongosh <db> < document_store.mongodb.js` |
| `56_redis_runtime_redis/` | **Redis** | `*.keyspaces.md` | Spec de diseño (Redis es schemaless) — guía de claves/TTL para el runtime |
| `57_search_platform_opensearch/` | **OpenSearch** | `*.mapping.json` (1 por índice) + `*.index-config.md` | `PUT /<índice>` con el body de cada `.mapping.json` |
| `58_time_series_timescaledb/` | **TimescaleDB** | `*.timescaledb.sql` | `psql` (requiere extensión `timescaledb`) |
| `59_vector_rag_pgvector/` | **pgvector** | `*.pgvector.sql` | `psql` (requiere extensión `vector`) |

## Traducciones de fidelidad

- **MongoDB:** cada entidad → `createCollection` con validador `$jsonSchema` (`required` = campos
  `*`, `bsonType` mapeado) + `createIndex` por índice. `UNIQUE`→`unique`, `PARTIAL x exists`→
  `partialFilterExpression`, `TTL`/`expireAfterSeconds`→índice TTL, `TEXT`→índice de texto.
- **Redis:** documenta patrón de clave, tipo de valor, TTL y estructuras (`KEY/SET/ZSET/HASH/
  STREAM/PUBSUB/COUNTER`) y políticas. No es DDL (Redis no tiene esquema).
- **OpenSearch:** `mappings.properties` por índice con tipos ES (`keyword/text/date/long/nested/
  flattened/geo_point/...`). Routing/alias/pattern/lifecycle van en `index-config.md`.
- **TimescaleDB:** `CREATE TABLE` + `create_hypertable` (de `PARTITION`, con `chunk_time_interval`)
  + `add_dimension` (space) + índices `ORDER`/`UK`/`BRIN`. Políticas avanzadas
  (`RETENTION/COMPRESSION/ROLLUP/SKIP`) van comentadas (definir intervalos concretos).
- **pgvector:** `CREATE EXTENSION vector` + tablas con columnas `vector` + índices
  `UK/IX/GIN/HNSW` (HNSW con `vector_cosine_ops` — ajustar según `distance_metric`).

## Nota

58 (Timescale) y 59 (pgvector) son extensiones de PostgreSQL: pueden vivir en la MISMA
instancia que la base relacional de `../SQL/`, con sus propios schemas (`time_series`,
`vector_rag`). MongoDB, Redis y OpenSearch son motores aparte.
