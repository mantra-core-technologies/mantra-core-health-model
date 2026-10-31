# Mantra Core Health — modelo, DDL y paquete de seeds

Este repositorio guarda el **modelo canónico de SALUD** y todo lo que se deriva de él: los
diagramas fuente, el DDL generado, los generadores y el paquete de seeds. Hasta el 28/08/2026
nada de esto estaba versionado y viajaba por zip entre máquinas, así que ningún cambio de
esquema podía revisarse en un PR — el bloqueante **B-2** de
`mantra-core-health-api/REGISTRO-DEFECTOS.md`. Este repo lo cierra.

## Qué hay acá

| Carpeta | Qué es | Fuente o derivado |
|---|---|---|
| `Mantra Core Health Context/` | Los 66 `.puml` del modelo (00–65), `model-manifest.yaml` y docs de arquitectura | **fuente** |
| `salud-db/` | Los generadores (`gen_ddl.py`, `gen_seeds.py`, `gen_entities.py`…), `load_seeds.py` y `rebuild_stack.py` | **fuente** |
| `markdown_convertidos/` | Los padrones bolivianos del stakeholder (aranceles, hospitales, aseguradoras, especialidades…) | **fuente** |
| `SQL/` | DDL por módulo, `_integrity/` y `patches/` | derivado de los `.puml` |
| `NoSQL/` | Stores especializados (Mongo, Redis, OpenSearch, Timescale, pgvector) | derivado |
| `seedsGenerales/` | El paquete de seeds de los 64 módulos (boot + mock) | derivado de `gen_seeds.py` |
| `seedsProd/` | Metadata del corpus MeSH; los shards **no** están acá (ver abajo) | artefacto externo |

La dirección del cambio no se negocia: `.puml` → `gen_ddl.py` → `SQL/` → base → entidades
MikroORM. Lo derivado se regenera, nunca se edita a mano; si algo sale mal, se arregla el
generador. El detalle está en `Mantra Core Health Context/docs/architecture/ddl-sources.md`
y en el `CLAUDE.md` del workspace.

## Dónde se clona

Los generadores distinguen **dos raíces**, definidas en un solo lugar (`salud-db/paths.py`):

- `MODEL_ROOT` — este repositorio. Adentro están los `.puml`, `SQL/`, `NoSQL/` y los seeds.
- `WORKSPACE` — la carpeta que lo contiene y donde viven, como **hermanos**, los repos de
  código: la bóveda de Obsidian y la API.

Es decir, este repo se clona **junto a** los otros, no adentro de ninguno:

```text
<workspace>/
├── mantra-core-health-model/     <- este repo
├── mantra-core-health-api/
├── mantra-core-health/
├── Mantra Core Health Vault/     <- la bóveda (repo mantra_core_technologies_health_docs)
└── mantra_core_health_mobile/
```

```bash
git clone https://github.com/mantra-core-technologies/mantra-core-health-model.git
```

> **En Windows, si el workspace está en una ruta profunda, el checkout falla a medias.** Los
> nombres de acá son largos (`Mantra Core Health Context/docs/architecture/…`) y el límite
> clásico es 260 caracteres: git clona bien pero deja el árbol incompleto, avisando «Clone
> succeeded, but checkout failed». Se arregla de una vez con
> `git config --global core.longpaths true` y después `git restore --source=HEAD :/`.

La bóveda **debe** llamarse `Mantra Core Health Vault`: `gen_ddl.py` lee de ahí las notas de
FK y `gen_seeds.py` las de value sets. Si tenés los repos en otra disposición, `SALUD_WORKSPACE`
reapunta la raíz sin tocar código (y del lado de la API existe `SALUD_VAULT`).

## Uso

```bash
python salud-db/check_ddl_sources.py     # que SQL/ y NoSQL/ sigan siendo las únicas fuentes
python salud-db/gen_ddl.py all           # regenerar el DDL de los 66 módulos
python salud-db/gen_seeds.py --dry       # ver qué cambiaría en el paquete de seeds
python salud-db/gen_seeds.py             # regenerarlo
python salud-db/load_seeds.py --skip-prod --refresh    # cargar a la base
python salud-db/rebuild_stack.py --yes   # ciclo limpio del stack (down -v → up → carga)
```

Los generadores se validan **regenerando y diffeando**, nunca leyendo su código: si el diff
sale vacío, el cambio no rompió nada.

## Parches sobre una base viva y verificación SQL (personal de apoyo y gobierno de accesos)

El DDL de `SQL/<NN>_<schema>/` sale de los `.puml`; lo que **no** sale de ellos (funciones, disparadores, RLS y semillas de
arranque de los parches) vive en `SQL/patches/` y se aplica **después** del esquema, en este orden:

```bash
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/apply_all.sql && psql -v ON_ERROR_STOP=1 -d <base> -f SQL/apply_deferred.sql
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/patches/2026-10-31_v4275_personal_apoyo.sql     # personal de apoyo (v4.2.75 → v4.2.77)
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/patches/2026-10-31_v4278_gobierno_de_accesos.sql # gobierno de accesos (v4.2.78)
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/patches/2026-10-31_v4279_revision_seguridad_gobierno.sql # revisión de seguridad ronda 1 (v4.2.79)
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/patches/2026-10-31_v4280_observabilidad_sistema.sql # observabilidad del sistema: módulo 70 + telemetry.client_error_events (v4.2.80; se genera con salud-db/gen_observability_patch.py)
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/patches/2026-10-31_v4281_idempotencia_anonima.sql # telemetría: índice único parcial de los eventos anónimos + deduplicación previa (v4.2.81; los cuatro v4281 se generan con salud-db/gen_v4281_patches.py)
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/patches/2026-10-31_v4281_gobierno_de_datos.sql      # gobierno de datos: módulo 67 (12 tablas) + system_ops.governance_policy_revisions (v4.2.81)
psql -v ON_ERROR_STOP=1 -d <base> -f SQL/patches/2026-10-31_v4281_cargas_masivas.sql        # lote persistente de bulk_import: system_ops.bulk_import_batches y _rows (v4.2.81)
```

Todos son idempotentes (una transacción, re-ejecutables). **Si se vuelve a ejecutar el v4275 después del v4278, hay que volver a
ejecutar el v4278 y el v4279**: el v4275 restituye las versiones anteriores de `refresh_effective_support_access` (que ya no excluiría un
`DENY`) y de `integrity.support_tenant_consistency`, y el v4279 (que extiende esta última y reescribe `support_access_allowed`) las deja completas.
El v4.2.79 agrega `tenant_id` + disparador + RLS a `organization_user_assignments` y `practitioner_delegate_assignments`, quita
`UPDATE/DELETE/TRUNCATE` de `access_decision_log` (también a `mantra_app`), hace que `support_access_allowed` respete un `DENY` y
**obliga** a que el v4275 y el v4278 creen sus políticas RLS (antes solo avisaban si la base no tenía RLS). El v4.2.78 agrega 73 permisos atómicos (los 15 códigos antiguos siguen como alias), 11 reglas SoD de
plataforma, 7 plantillas de rol v2, 12 tablas de gobierno en `delegated_access` y el rol de sistema `SUPPORT_STAFF`; detalle en
[`Mantra Core Health Context/docs/architecture/physical-materialization.md`](Mantra%20Core%20Health%20Context/docs/architecture/physical-materialization.md)
y datos de demostración + verificaciones en [`salud-db/demo/README.md`](salud-db/demo/README.md) (`04` → `05` → `06` → `07` → `08`).

Pruebas estáticas del modelo (sin base de datos): `python -m unittest discover -s salud-db/tests`.

## El corpus MeSH (`seedsProd/`)

Son 501 MB de shards JSON (MeSH 2026 v6.1, 1 441 367 filas) que casi nunca cambian y que el
arranque **no** carga por defecto. Se publican como asset de Release en vez de versionarse:

```bash
gh release download mesh-2026-v6.1 --repo mantra-core-technologies/mantra-core-health-model
tar -xzf seedsProd-modules-mesh-2026-v6.1.tar.gz     # crea seedsProd/modules/
```

Para verificar la descarga contra los checksums versionados:

```bash
python - <<'PY'
import hashlib, json, pathlib
base = pathlib.Path("seedsProd")
esperado = json.loads((base / "checksums.json").read_text(encoding="utf-8"))
esperado = esperado.get("files", esperado)
malos = [rel for rel, sha in esperado.items()
         if (base / rel).exists()
         and hashlib.sha256((base / rel).read_bytes()).hexdigest() != sha]
print("OK" if not malos else f"NO COINCIDEN: {malos}")
PY
```

Solo hace falta si vas a cargar el corpus (`python salud-db/rebuild_stack.py --yes --con-mesh`).
Sin él, todo lo demás funciona igual.

## Ramas

`dev` es la rama de integración y la rama por defecto: **toda PR va a `dev`**, nunca a `main`.
Convención de nombres: `<persona>/<tema-en-kebab>`, igual que en los otros repos del producto.
