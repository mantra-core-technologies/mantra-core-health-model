# SQL — SALUD v4.0.8 (DDL PostgreSQL canónico)

DDL generado **fielmente** desde los 64 diagramas `.puml` de
`Mantra Core Health Context/modules/` (regla temperatura-0: nada inventado), con
`python salud-db/gen_ddl.py all`. La creación de la base y la aplicación de estos
scripts la hacés vos.

> **Esta carpeta es la única fuente de verdad del DDL.** No declares tablas ni
> columnas en ningún otro sitio: el flujo es `.puml` → `SQL/` → BD → ORM, y solo en
> esa dirección. Si algo falta, se arregla en el `.puml` y se regenera. En v4.0.8 hubo
> que revertir precisamente eso: el backend había creado su propio `database/SQL/`
> con 5 tablas que el modelo no declaraba. No habían llegado a la base todavía, pero
> con `ORM_SCHEMA_SYNC` en su default `safe` la aplicación las habría creado sola en el
> siguiente arranque, sin que ningún generador ni ningún script las declarara.

## Clasificación

```text
SQL/
└── <NN>_<schema>/          ← un directorio por módulo (NN = número de módulo)
    ├── 01_schema.sql       Fase 1 · CREATE SCHEMA
    ├── 02_tables.sql       Fase 2 · CREATE TABLE (columnas + NOT NULL + PRIMARY KEY)
    ├── 03_fk_intra.sql     Fase 3 · FK cuyo destino está en el MISMO schema
    ├── 04_indexes.sql      Fase 4 · índices IX / UK / BRIN (el índice PK lo crea PG solo)
    └── 90_fk_deferred.sql  Fase 5 · FK cross-schema — aplicar al final, cuando existan
                             los schemas destino (p. ej. terminology.catalog_concepts)
```

## Orden de aplicación (una base ya creada)

1. Por cada módulo, en orden: `01_schema` → `02_tables` → `03_fk_intra` → `04_indexes`.
2. `_integrity/00_integrity_functions.sql` (schema `integrity` + guarda de inmutabilidad),
   y luego los `05_constraints.sql` de los módulos dueños (7 módulos — ver `_integrity/`).
3. Recién cuando **todos** los módulos estén creados, aplicar los `90_fk_deferred`
   de cada uno (cierran las FK entre schemas, p. ej. `*_concept_id → terminology.catalog_concepts`).

### Integridad (módulo 33)

El módulo 33 (`integrity`) no tiene tablas: es la matriz de concurrencia/integridad. Se
materializó en `_integrity/integrity-matrix.md` (documento accionable + política transaccional)
y en un `05_constraints.sql` por módulo dueño. Las guardas de inmutabilidad
(`UPDATE_DELETE: forbidden`) son **concretas**; las `UK/CHECK/EXCLUDE` son **scaffold TODO**
con la regla textual del modelo (declaradas en prosa → no se inventa la expresión exacta).

Todos los scripts son **idempotentes** (`IF NOT EXISTS` / `IF NOT EXISTS` en índices),
así que reaplicarlos no rompe nada. Las sentencias `ALTER TABLE … ADD CONSTRAINT`
fallan si la constraint ya existe: aplicá el bloque FK una sola vez, o envolvé en
un bloque de reintento si necesitás re-correrlo.

## Notas de fidelidad

- Tipos, columnas, obligatoriedad (`NOT NULL`), PK/UK/FK e índices salen literalmente del `.puml`.
- Los **destinos** de cada FK se toman de las notas ya resueltas del vault (`Mantra Core Health Vault/SALUD/FK/`).
- Las FK marcadas *"Destino no resuelto"* en el vault **no se fuerzan** (van comentadas
  en `90_fk_deferred.sql`). Ej.: `refresh_tokens.replaced_by_id`.
- Sin `DEFAULT`s (política del modelo), **con una única excepción: `row_version DEFAULT 1`**
  en las 727 tablas que la declaran. No es un valor de negocio sino el contador de bloqueo
  optimista, y MikroORM **no** lo inicializa al crear la entidad: espera que lo aporte la
  base y, si no hay default, manda `NULL` contra una columna `NOT NULL` y el `INSERT` muere
  con `23502`. Antes esto se parcheaba en caliente desde la aplicación
  (`ALTER TABLE … SET DEFAULT 1` al arrancar, y solo sobre 4 de los 52 schemas), de modo que
  las escrituras del ORM contra los otros 48 fallaban; se declara acá para devolverlo al
  modelo y cerrar esa dirección de cambio. Lo emite `column_default()` en `gen_ddl.py`.
  Verificable: `select count(*) from information_schema.columns where column_default is not
  null and column_name <> 'row_version'` debe dar **0**.
- Único enum nativo: `terminology.technical_data_type` (ver `00_shared/00_types.sql`;
  valores pendientes de definir).
- **FK inferidas por convención** (32): cuando el vault no tenía destino, se resuelve por
  convención (`*_concept_id→terminology.catalog_concepts`, `*_user_id→iam.users`,
  `tenant_id→directory.tenants`, `<x>_id→<x>s` si es unívoco). Van marcadas
  `-- (inferida por convención)` en el SQL para que las audites.
- **FK sin destino canónico** (23): FKs ambiguas o autorreferenciales que ni el vault ni la
  convención resuelven. **No se fuerzan** — se listan comentadas al principio del
  `90_fk_deferred.sql` de su módulo, bajo `-- FK sin destino canónico`.
  Cuando una FK necesita un destino que la convención no acierta, la salida correcta es
  **escribir su nota en `SALUD/FK/FK <schema>.<tabla>.<columna>.md`** con el bloque
  `## Apunta a →` y el wikilink `[[E <schema>.<tabla>|…]]`: el generador la lee de ahí.
  Así se resolvieron en v4.0.8 el autoenlace de `medication_requests` y el destino real de
  `care_relationships.practitioner_profile_id`.

## Módulos generados

Los **64 módulos** están generados. Resumen completo (tablas, FK, inferidas, índices y
entidades saltadas por módulo) en [`_generation_report.md`](_generation_report.md).

- **1 152 tablas PostgreSQL** y **6 653 FKs** en **55 schemas con tablas** (57 directorios).
  Sumando los stores PG de `NoSQL/` (12 `time_series` + 14 `vector_rag`): **1 178 tablas**.
- **Graph (61)** y **Lakehouse (63)** se materializan como tablas PG (catálogo/metadata del
  plano de control). No declaran schema PG en el `.puml`, así que se usa el nombre del módulo
  (`graph_intelligence`, `lakehouse`). Los índices propios del graph (`CONSTRAINT/INDEX/
  FULLTEXT/LOOKUP`) se traducen a PG (unique/btree/GIN `to_tsvector`); `TTL` se comenta
  (PG no tiene índice TTL → job de retención).
- **8 módulos sin tablas PG:** diagramas de arquitectura sin entidades (00 platform,
  21 deployment, 34 portal_catalog) y stores no-SQL de otros motores
  (55 mongo, 56 redis, 57 opensearch, 58 timeseries, 59 vector).
- **Aplicar `00_shared/00_types.sql` primero**, luego los módulos por fase, y los
  `90_fk_deferred.sql` al final (ver orden arriba).

## `patches/` — lo que NO se deriva de los `.puml`

`patches/` queda **fuera de `apply_all.sql`** y se aplica a mano. Son dos cosas distintas:

1. **ALTER incrementales** sobre una base ya poblada, para no exigir un rebuild cuando el
   modelo gana columnas (`2026-07-24_v402-v407_alter_columns.sql`,
   `2026-07-25_v407_nullable_embedding_model_versions.sql`). En un rebuild desde cero
   **no hacen falta**: esas columnas ya vienen en el `CREATE TABLE` generado.
2. **Piezas operativas que el modelo no expresa** y que por eso ningún generador emite:
   - `2026-07-30_tenant_rls.sql` — aislamiento por tenant con Row Level Security: crea el rol
     `mantra_app` (sin BYPASSRLS) y activa las políticas en las ~284 tablas con `tenant_id`.
     Es **irreversible**; aplicalo a conciencia. La app lo complementa fijando
     `app.current_tenant_id` por request cuando `RLS_ENFORCE=true`.
   - El seed histórico `2026-07-30_vademecum_dev_seed.sql` fue retirado del conjunto activo:
     **historical seed superseded by canonical TerminologySeedService → VademecumSeedService
     path**. Su contenido permanece trazable en el historial de Git; no se archiva como otro
     patch ejecutable. Los 17 medicamentos de desarrollo no son un vademécum clínico ni datos
     verificados. El catálogo de terminología real (~460k conceptos) lo cargan los importadores
     de `mantra-core-health-api/tools/terminology-import/` desde APIs oficiales.

Los seeds canónicos **no viven acá**: están en `seedsProd/` y `seedsGenerales/` como
`*.seeds.json`, y los carga `python salud-db/load_seeds.py`.
