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
