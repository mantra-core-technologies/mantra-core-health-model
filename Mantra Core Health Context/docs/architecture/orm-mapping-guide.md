# Guía de mapeo del modelo → ORM (MikroORM) — SALUD v4.0

Documento de contexto para el equipo que construya la capa de persistencia. NO es DDL
ni implementación: fija cómo se interpreta el modelo lógico al generar entidades y
migraciones. La fuente de verdad sigue siendo el PlantUML por módulo.

## 0. ORM elegido: MikroORM

MikroORM es el ORM objetivo para la capa relacional PostgreSQL, por:

- **Unit of Work + Identity Map**: encaja con transacciones por caso de uso y con la
  regla "un caso de uso = una transacción".
- **`@Version` nativo**: mapea directo el campo `row_version` que el modelo declara en
  toda tabla de negocio (locking optimista sin código manual).
- **Multi-schema**: el modelo usa >40 esquemas PostgreSQL; MikroORM los soporta por
  entidad (`@Entity({ schema: '...' })`).
- **Subscribers/hooks**: permiten materializar el patrón outbox y las guardas de
  aplicación sin ensuciar el dominio.

**Salvedad honesta sobre PostGIS.** Ni MikroORM ni la mayoría de ORMs de TS tienen
soporte espacial nativo de primera clase. El geoespacial (radar de 5 km, CU-07/20) se
resuelve con **tipos custom** (`geography(Point,4326)`) y, para las consultas
`ST_DWithin`/`ST_Distance`, con **SQL crudo a través del QueryBuilder de MikroORM** —
no forzando el mapeo espacial dentro del ORM. Esto es esperado y correcto: el ORM
gestiona las entidades de negocio; el SQL espacial vive explícito donde se necesita.

## 1. Convenciones que el generador debe respetar (verificadas en el modelo)

- **PK**: `id : uuid <<PK>>` en toda tabla de negocio → `@PrimaryKey()` uuid v4.
- **Subtipos (perfiles)**: `profile_id : uuid <<PK,FK>>` → Class Table Inheritance.
  Mapear como relación 1:1 con la tabla base compartiendo PK, NO como tabla independiente.
  (Ver los 7 perfiles en `diagram_05_profiles.puml`.)
- **Bloque de auditoría** (en tablas de negocio): `created_at`, `updated_at` (timestamptz),
  `created_by_user_id`, `updated_by_user_id` (uuid FK), `row_version` (integer).
  → `@Property()` + `@Version()` para `row_version`.
- **Multi-tenencia**: las tablas con `tenant_id` requieren filtro por tenant SIEMPRE.
  Aplicar vía **filtro global de MikroORM** (`@Filter`) + RLS a nivel PostgreSQL (la RLS
  es la barrera dura; el filtro del ORM es conveniencia, no la defensa).

## 2. Las tres decisiones de mapeo (resolver antes de generar)

### 2.1 `row_version` → optimistic locking
El modelo declara `row_version` en 52 de 64 módulos (los 12 sin él son stores NoSQL, que
no lo necesitan). Mapear con `@Version()`; el ORM incrementa y valida en cada UPDATE.
Los servicios NO deben tocar este campo a mano.

### 2.2 Terminología-como-enum → FK uuid, NO enum tipado
Toda columna `*_concept_id` es FK a `terminology.catalog_concepts` (es el motor de enums
del sistema; regla del modelo: no usar enums nativos de PostgreSQL salvo
`technical_data_type`). Consecuencia para el ORM:
- Se mapean como `@ManyToOne` (o FK uuid simple) — **no** como enum de TypeScript.
- El ORM NO puede dar type-safety de "qué concepto es válido en este campo": esa
  restricción vive en el `value_set` ligado a la columna (CHECK/trigger a nivel BD), no
  en el tipo. Documentar esta limitación para no esperar enums tipados donde no los hay.
- Para DX, se puede generar un catálogo de constantes por value_set, pero es ayuda de
  desarrollo, no una garantía del motor.

### 2.3 Codegen sobre mapeo a mano
Son ~2214 tablas relacionales. Escribirlas a mano es inviable sin error. Estrategia
vigente (ADR-0022 del repo API, 2026-08-06 — este apartado decía «la base genera las
entidades» por introspección, y nunca fue lo que ocurrió):
1. Generar el DDL desde el PlantUML (generador determinista, `gen_ddl.py`).
2. Generar el **cuerpo** de las entidades desde el mismo PlantUML
   (`salud-db/gen_entities.py`, que preserva el JSDoc existente) + `prettier`.
3. Rellenar la **documentación** faltante con `yarn docs:tsdoc` (aditivo; la prosa a
   mano tiene prioridad).
El modelo genera el DDL **y** las entidades — misma fuente, dos artefactos, cero
oportunidad de que diverjan por introspectar una base desincronizada
(`ORM_SCHEMA_SYNC=off`). Mantener a mano solo lo que el modelo no declara (filtros,
subscribers, tipos custom PostGIS) y el JSDoc de negocio, que la regeneración respeta.

## 3. Stereotypes → comportamiento de persistencia

| Stereotype | Cómo mapear |
|---|---|
| `<<LOG>>`, `<<APPEND_ONLY>>` | Solo INSERT. Barrera física en BD (REVOKE UPDATE/DELETE + trigger). El ORM no expone update/delete para estas entidades. |
| `<<IMMUTABLE>>` | Igual que append-only: corrección por nuevo registro, nunca UPDATE. |
| `<<HISTORY>>` | Versionado SCD-2 en schema `audit`. No sobrescribir; insertar snapshot. |
| `<<VERSIONED>>` | Conserva versiones + vigencia. No mapear como fila única mutable. |
| `<<VIEW>>`, `<<MATERIALIZED_VIEW>>` | Entidad de solo lectura (`@Entity({ expression })` o vista). Nunca escribir. |
| `<<REFERENCE_ONLY>>` | Stub de otro módulo. NO generar una segunda entidad; referenciar la real. |
| Stores NoSQL (`<<MONGODB_COLLECTION>>`, `<<REDIS_KEYSPACE>>`, etc.) | Fuera del ORM relacional. Son proyecciones vía outbox (ver §4). |

### Registro atómico de subtipos CTI (regla 11 · v4.0.7)

Los subtipos CTI (`*_profiles` con `profile_id <<PK,FK>> → profiles.persons`) se registran
**padre e hija en la misma transacción** (`persons → person_profiles → *_profiles`); si algo
falla, no se persiste nada. Una clase hija **jamás** exige el id de un padre ya registrado —
el único caso legítimo de recibir un id previo es añadir un rol adicional a una persona
existente (UC-05-04). Auditoría de los 68 casos de uso: 0 violaciones
(`cti-registration-audit`, regla 11 de `data-modeling-standards.md`).

## 4. Frontera relacional ↔ stores especializados

MikroORM mapea SOLO la capa relacional PostgreSQL (fuente de verdad). Los módulos 54–63
(document, redis, search, time-series, vector, object, graph, lakehouse) **no se mapean
como entidades del ORM**: se alimentan por outbox + workers idempotentes desde PostgreSQL
(`docs/architecture/nosql-storage-allocation.md`). El ORM escribe la tabla canónica y el
evento outbox en la misma transacción; el worker proyecta al store especializado.

## 5. Verificación de "casa única" del dato clínico (hacer al mapear)

Con el pivote políglota, cada dato clínico canónico debe tener UNA sola casa. Al mapear,
verificar tabla por tabla que no haya doble fuente de verdad. Casos a confirmar:

- **Signos vitales**: lectura cruda de dispositivo → `<<TIMESERIES_MEASUREMENT>>`
  (`normalized_vital_series`, módulo 58); observación clínicamente validada →
  `clinical.observations` (PostgreSQL). Están separadas por diseño: confirmar que el ORM
  solo trata la observación validada como fuente de verdad, y la serie como telemetría.
- **Documento FHIR completo**: original/versionado → `document_envelopes` (módulo 55, Mongo);
  los campos estructurados validados → tablas `clinical`/`health_data`. La proyección Mongo
  NO es fuente de verdad de un valor codificable.
- **Imágenes/DICOM**: binario → `<<OBJECT_CATALOG>>` (módulo 60); metadatos y relaciones →
  PostgreSQL. La BD guarda el puntero, no el binario.

Regla: si un valor codificable (diagnóstico, observación, medicación) aparece como "verdad"
en un store no relacional Y en PostgreSQL, es un error de mapeo — corregir antes de generar.

## 6. Lo que este documento NO decide (queda para el ADR del ORM)

- Versión exacta de MikroORM y driver.
- Estrategia de migraciones (MikroORM migrations vs SQL crudo versionado).
- Diseño concreto de los filtros de tenant y su interacción con RLS.
- Tipos custom PostGIS y su serialización.
- Política de generación/regeneración de entidades ante cambios del modelo.
