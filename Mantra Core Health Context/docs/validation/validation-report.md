# Validation Report — SALUD v4.0.1

> **Documento congelado en v4.0.1 — no es el inventario actual.** (Nota agregada el
> 2026-08-07.) Registra la validación que se ejecutó para aquella versión y su desglose por
> módulo de entonces. El modelo va por **v4.0.10** y sus conteos vigentes son
> **2 671 declaraciones `entity` · 1 245 tablas/stores · 1 225 index sets · 6 672 FKs**,
> reproducibles con `python tools/model_inventory.py` y declarados en el bloque `inventory:`
> de `model-manifest.yaml`. Para el estado del build (tablas, índices y FKs realmente
> materializados) ver `docs/architecture/physical-materialization.md`.
>
> **v4.0.1** incorpora los patches de envíos programados / Administración del sitio / tracking
> **materializados en el ER** (§24 del plan). Se añadieron 14 entidades (11 tablas + 3 read models),
> 10 extensiones de columnas y 11 index sets en los módulos 06/30/35/48/49/50, de forma **aditiva
> (0 líneas borradas)**. El inventario de abajo ya refleja v4.0.1.

## Resultado

**PASS (validación estática y semántica).** No se afirma compilación gráfica: el
render PlantUML requiere runtime/JAR no disponible en el entorno de generación.

## Inventario real (v4.0.1, reconteado de los .puml entregados)

- PUML (módulos): **64** · Schemas: **52**
- Declaraciones `entity` totales (líneas literales): **2607**
  - Elementos tipo tabla/store (`table_like_elements`, suma por módulo): **1212**
  - Vistas / read models (`<<VIEW>>` + `<<MATERIALIZED_VIEW>>`): **81**
  - Stubs de referencia cruzada (`<<REFERENCE_ONLY>>`): **120**
  - Conjuntos de índices (`<<INDEX_SET>>`): **1194**
- Referencias `<<FK>>` declaradas: **6452**
- Delta v4.0 → v4.0.1: +14 entidades · +10 extensiones · +11 index sets · +116 FK (módulos 06/30/35/48/49/50).

> **Fuente única y reproducible.** Estas cifras las produce `tools/model_inventory.py`
> (determinista: clasifica cada `entity` en una sola clase, de modo que
> `tables_stores + views + reference_only + index_sets == entity_declarations_total`).
> Reproducir con: `python tools/model_inventory.py` (o `--json`). El bloque
> `inventory:` y los conteos por módulo de `model-manifest.yaml` se generan con el
> mismo script; ya no hay tres métodos distintos.

> NOTA DE CORRECCIÓN: las cifras previas "2519 / 2214 / 24 / 127", "1024 / 54 / 1029",
> y el subconteo de tablas "1178/1189" (método viejo que omitía LOG/STATE_MACHINE en
> 7 módulos) quedan **obsoletas**. El conteo canónico reproducible es
> **2607 entity · 1212 tablas · 81 vistas · 120 ref · 1194 index · 6452 FK · 52 schemas**.
> Cualquier documento que muestre otras cifras se subordina a `tools/model_inventory.py`.

## Desglose de entidades de store especializado (módulos 54–63)

| Stereotype | Conteo | Módulo(s) |
|---|---:|---|
| `<<MONGODB_COLLECTION>>` | 13 | 55 document_store |
| `<<REDIS_KEYSPACE>>` | 14 | 56 redis_runtime |
| `<<OPENSEARCH_INDEX>>` | 13 | 57 search_platform |
| `<<TIMESERIES_MEASUREMENT>>` | 12 | 58 time_series |
| `<<VECTOR_STORE>>` | 14 | 59 vector_rag |
| `<<OBJECT_CATALOG>>` | 17 | 60 object_storage |
| `<<GRAPH_COLLECTION>>` | 13 | 61 graph_intelligence |
| `<<LAKEHOUSE_CATALOG>>` | 18 | 63 lakehouse |

## Preservación v3.7 → v4.0

- Entidades originales eliminadas: 0
- Grupos de campos originales eliminados: 0
- Módulos relacionales base preservados: 54; módulos NoSQL/especializados: 10 (módulos 54–63)

## Controles ejecutados

- Validador estático (`tools/validate_puml_static.py`), 64 archivos: PASS
- Aliases duplicados por archivo: 0
- Llaves/bloques balanceados: OK
- Nombres de índice > 63 caracteres: 0
- Nombres de índice repetidos dentro de un mismo PUML: 0
- Cobertura de `<<INDEX_SET>>` por módulo de datos: completa
- Integridad del paquete: `SHA256SUMS.txt` verificado (`sha256sum -c` → OK)

## Límite explícito de la evidencia

La validación confirmada es **estática y semántica**: forma de los `.puml`,
convenciones, conteos e integridad de checksums. **No** constituye evidencia de
DDL desplegado, RLS aplicada, índices creados, ni compilación gráfica. El paso a
producción exige materializar la base y ejecutar los controles físicos y operativos
(ver `docs/physical/` y el checklist de mapeo del ORM).
