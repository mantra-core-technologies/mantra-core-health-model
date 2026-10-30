# Bases `pay_*` de PasarelaPago — el perfil PAY del pipeline

> Estado: desde 2026-10-27 (decisión **D-18** de `pasarelapago/docs/plan/DECISIONES.md`: las bases `pay_*` entran al
> pipeline `.puml → SQL/ → base → ORM`). Generador: `salud-db/gen_ddl_pay.py`. Política de fondo:
> [[ddl-sources]] — el esquema se declara en los `.puml`, nunca en un `.sql` suelto.

## Qué es y qué no es

La pasarela son **once microservicios con una base de PostgreSQL cada uno** (`pay_edge`, `pay_ledger`, …; regla de
separación #1 de su plan maestro). SALUD es **una** base con ~70 schemas. Por eso las bases `pay_*` **no** son módulos
de `modules/`: ese directorio alimenta a todos los generadores de SALUD (`gen_ddl`, `gen_integrity`, `gen_seeds`,
`gen_entities`, `model_inventory`) y meter ahí tablas de otra base las contaminaría — `rebuild_stack.py` contaría sus
tablas contra la base de SALUD y fallaría, `gen_entities.py` les generaría entidades en la API de salud.

| Qué | Dónde |
|---|---|
| Fuente: un `.puml` **por base** | `Mantra Core Health Context/pay-modules/diagram_<70..81>_pay_<svc>.puml` |
| Registro | `model-manifest.yaml`, sección `pay_databases:` (aparte de `modules:`) |
| Generador | `salud-db/gen_ddl_pay.py` (reutiliza el parser de `gen_ddl.py`; no lo modifica) |
| Salida | `SQL/pay/<NN>_pay_<svc>/` — `02_tables`, `03_fk_intra`, `04_indexes`, `05_constraints`, `06_seed` y **`ddl.sql`** (todo en orden, SQL plano) |
| Reporte | `SQL/pay/_generation_report.md` |

Del 70 al 80 son las once bases (una por servicio, en orden alfabético); el **81 `pay_lib`** no es una base de
servicio: declara las tres tablas técnicas de las librerías `@pay/*` (`outbox_events`, `inbox_events`,
`idempotency_keys`) para que las pruebas de esas librerías consuman DDL generado. Esas tres tablas **se repiten en el
módulo de cada servicio que las usa** (cada base tiene las suyas); su catálogo es idéntico en todos.

## Uso

```bash
python salud-db/gen_ddl_pay.py            # regenera SQL/pay/ (solo ese árbol: SQL/ de SALUD no se toca)
python salud-db/gen_ddl_pay.py --check    # exit 1 si SQL/pay/ difiere de lo que generan los .puml
```

El generador **falla** (no avisa) si el `.puml` deja una FK sin arista, si una FK se infiere por convención o si el
generador base emite cualquier aviso: una base pay no admite nada implícito.

## Cómo es el SQL: sin calificar, una base por servicio

El SQL sale **sin `CREATE SCHEMA` ni nombres calificados**: los objetos se crean en el esquema de la conexión
(`search_path`), igual que el DDL de referencia que reemplaza. En el despliegue, cada servicio aplica su `ddl.sql` a su
base (esquema `public`, o el de `PAY_DB_SCHEMA` si lo usa); en las pruebas, `@pay/testing` lo aplica a un esquema
`t_<hex>` y funciona igual. El `(schema: pay_<svc>)` del título es solo el nombre lógico del módulo.

Es idempotente (aplicarlo dos veces deja el mismo catálogo): `CREATE TABLE/INDEX IF NOT EXISTS`, FK en bloque
`duplicate_object`, `DROP CONSTRAINT IF EXISTS` + `ADD CONSTRAINT` para los CHECK, `CREATE OR REPLACE FUNCTION`,
`DROP TRIGGER IF EXISTS` + `CREATE TRIGGER`, semillas con `ON CONFLICT DO NOTHING`.

## Qué sale del generador base y qué de `PAY_EXTRAS`

Del **generador base** (`gen_ddl.py`), con la sintaxis de siempre: tablas y columnas (`* col : tipo` = NOT NULL),
`<<PK>>` (también compuesta), `<<FK>>` + arista `hijo }o--|| padre : columna` (una columna; nombre `fk_<tabla>_<col>`),
`<<DEFAULT_TRUE|FALSE>>`, y los `INDEX_SET` (`IX`/`UK` con `UNIQUE`, `DESC`, expresiones y `WHERE`, **nombre explícito
obligatorio**, regla 97.3.2).

De la entidad **`<<PAY_EXTRAS>>`** (una por módulo, al final), lo que el generador base no expresa:

```text
DEFAULT <tabla>.<col> : <expr>                         default no booleano (now(), 0, 'pending', '{}'::jsonb…)
IDENTITY <tabla>.<col>                                 GENERATED ALWAYS AS IDENTITY
CHECK_SQL <tabla> : <nombre> | <expr>                  CHECK con la expresión literal (como el CHECK_SQL del módulo 33)
FK_SQL <tabla> : <nombre> | (a, b) -> <tabla> (x, y)   FK compuesta
FUNCTION <nombre>                                      + líneas `| …` con el CREATE FUNCTION
TRIGGER <nombre> : BEFORE … ON <tabla> …               trigger
SEED_SQL <tabla>                                       + líneas `| …` con el INSERT … ON CONFLICT DO NOTHING
```

`bigserial` se admite como tipo. Todo CHECK lleva nombre explícito.

## Cómo se cambia una base pay

1. Editar el `.puml` del módulo (nunca `SQL/pay/`, nunca un `.sql` en el servicio).
2. `python salud-db/gen_ddl_pay.py` y revisar el diff de `SQL/pay/`.
3. Para una base ya poblada, un cambio que no sea aditivo necesita además su ALTER fechado (el patrón de
   `SQL/patches/`); el `ddl.sql` solo converge tablas/índices/CHECK/FK/funciones/triggers faltantes, no migra datos.
4. Verificar deriva (regla 97.2) contra la base y contra el mapa del código de cada servicio.

## Diferencias deliberadas con el DDL de referencia

El catálogo es idéntico (tablas, columnas en orden, tipos, nulabilidad, defaults, identidades, PK, FK, CHECK,
índices, triggers, funciones, filas semilla). Cambian **solo nombres** de lo que el generador base nombra por convención:

| Qué | Referencia | Modelo |
|---|---|---|
| PK | `<tabla>_pkey` | `pk_<tabla>` |
| FK de una columna | `<tabla>_<col>_fkey` (o nombre propio) | `fk_<tabla>_<col>` |
| UNIQUE de tabla / de columna | restricción `UNIQUE` | **índice único** con el mismo nombre (el error 23505 informa ese nombre, y `uniqueViolation(...).constraint` sigue valiendo) |

Las FK **compuestas** y todos los CHECK conservan su nombre original.
