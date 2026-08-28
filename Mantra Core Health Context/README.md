# SALUD v4.0.10 — Arquitectura políglota y módulos NoSQL

Versión **aditiva** respecto de SALUD v3.9. Conserva los 54 módulos relacionales previos y los 10 módulos NoSQL (gobierno políglota, documentos, Redis, búsqueda, series temporales, vectores/RAG, object storage/PACS, grafos, consistencia entre stores y lakehouse), para un total de **64 módulos**.

La versión canónica la declara `model-manifest.yaml` (`version: 4.0.10`) y los generadores la
leen de ahí — no la repitas cableada en código ni en cabeceras.

> **v4.0.10 — Endurecimiento del pipeline (2026-08-06). Sin tablas ni columnas nuevas.**
> Cierra las tres deudas de generador que destapó v4.0.9: (1) los **identificadores de más
> de 63 bytes** que PostgreSQL truncaba en silencio —`gen_ddl.py` ganó `pg_ident()`, puerto
> byte-idéntico del acortador del ORM, y `SQL/` renombró 58 FKs + 1 índice; (2) el **WORM de
> auditoría** promovido a la matriz del módulo 33, con el caso asimétrico que el generador no
> sabía expresar (`audit_log` prohíbe UPDATE+DELETE; `data_access_log` solo UPDATE, porque su
> DELETE es la purga de retención de UC-10-09); (3) **regenerar entidades volvió a ser seguro**
> — `gen_entities.py` preserva el JSDoc y el barrel conserva exports ajenos, así que la
> documentación dejó de destruirse en cada regeneración (`orm:gen` quedó retirado).
> Detalle en [`physical-materialization.md`](docs/architecture/physical-materialization.md) § v4.0.10.
>
> **v4.0.9 — Promoción de la verificación de correo y el restablecimiento (2026-08-05).**
> Segunda corrección de deriva del mismo origen que v4.0.8 y por la misma causa: un merge
> devolvió `mantra-core-health-api/database/` y encima se siguieron escribiendo migraciones.
> Esta vez el efecto **sí se consumó**: `iam.email_verifications` no existía en base limpia
> y los 27 casos de registro del smoke respondían 500. Se promovieron 2 tablas, 1 columna y
> 2 índices únicos parciales; `database/` se eliminó y ahora hay un chequeo
> (`salud-db/check_ddl_sources.py`) que impide su regreso silencioso. Política:
> [`docs/architecture/ddl-sources.md`](docs/architecture/ddl-sources.md).
>
> **v4.0.8 — Promoción de las reglas de negocio REDESA (corrección de deriva).**
> El backend (`mantra-core-health-api`) había declarado DDL propio en `database/SQL/`,
> fuera de los `.puml` y de `SQL/`: una segunda fuente de verdad del esquema. No había
> llegado a la base (se verificó antes del rebuild: las tablas no existían), pero el
> siguiente arranque las habría creado solo, porque `ORM_SCHEMA_SYNC` tiene default
> `safe` y las entidades ya estaban en el ORM — la dirección de cambio prohibida.
> Se promovieron al modelo **5 tablas** + **5 index sets** + **11 extensiones** de
> columnas en los módulos 01/06/08/16/41, y se eliminó `database/`.
> Detalle en [`physical-materialization.md`](docs/architecture/physical-materialization.md) § v4.0.8.

## Entrega (inventario real, reconteado de los `.puml`)

Reproducible con `python tools/model_inventory.py` — es la fuente única de los conteos.

- Módulos PUML: **64** · Schemas: **52**.
- Declaraciones `entity` (líneas literales): **2671**.
  - Elementos tipo tabla/store (`table_like_elements`): **1245**.
  - Vistas / read models (`<<VIEW>>` + `<<MATERIALIZED_VIEW>>`): **81**.
  - Stubs `<<REFERENCE_ONLY>>`: **120**.
  - Conjuntos de índices `<<INDEX_SET>>`: **1225**.
- Referencias `<<FK>>`: **6672**.
- Entidades originales de v3.7 eliminadas: 0. Grupos de campos eliminados: 0.

> Recontado el **2026-08-07** ejecutando `python tools/model_inventory.py`; coincide exactamente
> con el bloque `inventory:` de `model-manifest.yaml`. Los valores que estaban acá antes
> (2665 / 1241 / 1223 / 6664) eran del corte v4.0.8 y quedaron atrás al promoverse v4.0.9 y
> v4.0.10 — el manifest sí se había actualizado; este README no.
>
> Cifras de versiones **anteriores** ("2607 / 1212 / 1194 / 6452" de v4.0.1, "2519 entidades
> / 2214 tablas", "1024 entidades / 54 PUML") quedaron congeladas al evolucionar el
> modelo: no las cites. El inventario canónico vive en el bloque `inventory:` de
> `model-manifest.yaml` y lo produce `tools/model_inventory.py`. El desglose **por módulo** de
> `docs/validation/validation-report.md` está congelado en v4.0.1: sirve como registro de
> aquella validación, no como inventario actual.

## Módulos clave

- `diagram_11_system_ops.puml`
- `diagram_46_platform_ops.puml`
- `diagram_43_ads.puml`
- `diagram_42_payments.puml`
- `diagram_20_diagnostics.puml`
- `diagram_52_health_data_platform.puml`
- `diagram_53_procedures_perioperative.puml`
- `diagram_30_read_models.puml`

## Validación

Se ejecutó el validador estático, la verificación de preservación v3.7 → v4.0, cobertura de índices y controles semánticos de entidades obligatorias. El render gráfico completo no se ejecutó porque el runtime/JAR de PlantUML no está instalado en el entorno; no se afirma compilación visual.

## Materialización física

El modelo se materializa de forma determinista desde estos `.puml` con los generadores de
`salud-db/`, con salidas en `SQL/` y `NoSQL/`. Tras v4.0.10, `SQL/` declara **1 154 tablas**
(1 180 contando los stores PG `time_series` y `vector_rag`) · **7 878 índices secundarios** ·
**6 661 FKs**, en 52 schemas del modelo. v4.0.10 **no movió ninguno de estos conteos**: renombró
58 FKs + 1 índice que superaban los 63 bytes de PostgreSQL (contados sobre `SQL/` el 2026-08-07).

> El stack dev (`mantra_redesa_health` en `localhost:5433`) se **reconstruyó y verificó**
> el 2026-08-05 con `python salud-db/rebuild_stack.py` (veredicto **PASS**): **1 180 tablas ·
> 6 661 FKs · 9 107 índices · 1 465 927 filas · huérfanos 0**. La base coincide exactamente
> con lo que declara `SQL/` — el script deriva los esperados de `SQL/` en el momento y asevera
> las igualdades, en vez de compararlos contra números fijos.

Estrategia, reglas de fidelidad y estado completo en [`docs/architecture/physical-materialization.md`](docs/architecture/physical-materialization.md). Los principios de código que rigen el backend y los generadores están en [`docs/architecture/development-principles.md`](docs/architecture/development-principles.md).

## Módulos NoSQL y especializados

- `diagram_54_polyglot_storage.puml`
- `diagram_55_document_store.puml`
- `diagram_56_redis_runtime.puml`
- `diagram_57_search_platform.puml`
- `diagram_58_time_series.puml`
- `diagram_59_vector_rag.puml`
- `diagram_60_object_storage.puml`
- `diagram_61_graph_intelligence.puml`
- `diagram_62_cross_store_consistency.puml`
- `diagram_63_lakehouse.puml`

PostgreSQL continúa siendo la fuente canónica. Los stores especializados se actualizan mediante outbox y workers persistentes idempotentes.
