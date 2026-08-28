# Fuentes de DDL — quién declara el esquema y quién no

> Estado: normativo desde **v4.0.9 (2026-08-05)**. Espejo en el vault:
> `SALUD/Arquitectura/fuentes-de-ddl.md`. Chequeo:
> `python salud-db/check_ddl_sources.py` (o `yarn ddl:sources` en el repo API).

## La regla

**El esquema PostgreSQL se declara en los `.puml` y se materializa en `SQL/` y
`NoSQL/`, en la raíz del workspace. No hay otra fuente.**

`mantra-core-health-api/` es un consumidor del esquema, no un declarante. No
contiene DDL, ni copias del toolkit, ni una carpeta de migraciones propia.

## Por qué esto necesita estar escrito

Porque ya se rompió dos veces, y la segunda vez costó una versión del modelo.

En **v4.0.8** (2026-07-30) un merge de `dev` trajo `mantra-core-health-api/database/`:
una copia del toolkit con seis migraciones sueltas. Se promovieron al modelo y se
eliminó el directorio.

En **v4.0.9** (2026-08-05) otro merge lo devolvió —con los montajes del
`docker-compose.yml` apuntando de nuevo a esa copia— y encima se escribieron cinco
migraciones más. Esta vez el daño se consumó: `iam.email_verifications` no existía
en base limpia y los 27 casos de registro del smoke respondían 500.

La lección no es que alguien se equivocó. Es que **la regla no se sostiene sola**:
un merge la revierte sin que nadie lo note, porque nada falla al hacerlo. Por eso
ahora hay un chequeo que la hace fallar ruidosamente.

## Dónde va cada cosa

| Qué | Dónde | Quién lo genera |
|---|---|---|
| Tablas, columnas, PK, FK, índices del modelo | `Mantra Core Health Context/modules/*.puml` → `SQL/` | `gen_ddl.py` |
| CHECK, UNIQUE compuestos, guardas de inmutabilidad | `SQL/*/05_constraints.sql` | `gen_integrity.py` |
| Colecciones Mongo, keyspaces Redis, índices OpenSearch, hypertables, columnas vector | `NoSQL/` | `gen_nosql.py` |
| Datos de arranque y de prueba | `seedsProd/`, `seedsGenerales/` | `gen_seeds.py` |
| ALTERs sobre una base ya poblada | `SQL/patches/` | a mano, fechado |
| DDL que **no** se deriva de los `.puml` (RLS, seeds de desarrollo) | `SQL/patches/` | a mano, fechado |
| Entidades MikroORM | `mantra-core-health-api/src/modules/**/entities/` | `gen_entities.py` |
| Catálogo de índices y FKs del ORM | `mantra-core-health-api/src/orm/catalog/` | `yarn orm:catalog` |

`SQL/patches/` está **fuera** de `apply_all.sql` a propósito: en un rebuild desde
cero esas columnas ya vienen en el `CREATE TABLE`, y lo que no se deriva de los
`.puml` se aplica a mano cuando se lo necesita.

## Cómo se agrega una tabla, de verdad

El camino largo es el único que existe. Está en la skill `db-fidelity` §2; en
resumen: `.puml` → nota de entidad en el vault → `gen_ddl.py` → aplicar (rebuild
o patch) → `gen_entities.py` + `prettier` → `yarn docs:tsdoc` (JSDoc, solo donde
falta — ADR-0022) → `yarn orm:catalog` → verificar las cuatro capas.

Escribir un `CREATE TABLE` a mano y aplicarlo es más rápido **hoy**. El costo llega
el día que alguien levanta el stack desde cero y la tabla no está: la aplicación
compila, el ORM arranca, y el error aparece en la primera consulta que la toca.

## Qué detecta el chequeo

`salud-db/check_ddl_sources.py` falla con código 1 si encuentra:

1. `mantra-core-health-api/database/SQL`, `/NoSQL`, `/Mantra Core Health Context`
   o `/salud-db` — copias que ya volvieron una vez.
2. Un `docker-compose.yml` que monte `./database/...` en un servicio de init: la
   base se inicializaría desde la copia y no desde `SQL/`. Los montajes canónicos
   son `../SQL` y `../NoSQL`.
3. Cualquier `.sql` con `CREATE TABLE` fuera de `SQL/` y `NoSQL/`.

Corre como paso **0/4** de `rebuild_stack.py`, antes del `down -v`: reconstruir
desde una fuente equivocada produce una base que parece correcta, y descubrirlo
después de cargar el corpus MeSH cuesta varios minutos. También está disponible
como `yarn ddl:sources`.

> [!note] No hay CI en este repositorio
> No existe `.github/`, así que este chequeo no bloquea ningún pipeline. Vale por
> estar en el camino que la gente sí ejecuta —el rebuild—, no por ser una barrera
> automática. Si algún día hay CI, este es el primer candidato a incluir.

## Documentación retirada

`docs/adr/ADR-0016-migraciones-sql-plano.md` declaraba
`database/SQL/99_migrations` como el mecanismo oficial de cambio de esquema. Queda
**superado** por este documento. También describían ese flujo `docs/data/migrations.md`,
`docs/data/data-architecture.md`, `docs/governance/change-management.md`,
`docs/governance/traceability-matrix.md` (hallazgo `DATA-001`) y varios
`docs/operations/*`; todos apuntan ahora acá.

`mantra-core-health-api/database/README.md` afirmaba que la fuente autoritativa del
esquema era el bootstrap del ORM con `ORM_SCHEMA_SYNC=safe`. Eso describía
exactamente el vector de deriva que el protocolo prohíbe —la aplicación creando en
la base lo que el modelo no declara—, y desapareció con el directorio.
`ORM_SCHEMA_SYNC` está fijado en `off` desde 2026-07-30; para auditar deriva se usa
`dry-run`, nunca `safe`.
