"""
Dónde vive cada cosa — la única definición del layout, para todo `salud-db/`.

Hay DOS raíces y confundirlas es el error clásico:

  MODEL_ROOT  el repositorio del modelo (`mantra-core-health-model/`), que es
              el padre de esta carpeta. Adentro viven las cosas que el modelo
              declara y genera: los `.puml`, `SQL/`, `NoSQL/`, `seedsGenerales/`,
              `seedsProd/` y `markdown_convertidos/`.

  WORKSPACE   la carpeta que contiene el repositorio del modelo y, como
              hermanos, los repositorios de código: la bóveda de Obsidian y la
              API. Nada de lo que hay acá lo genera este repo.

Hasta el 2026-08-28 no existía la distinción: todo colgaba de la raíz del
workspace y los scripts la resolvían con `parents[1]`. Cuando el modelo pasó a
tener repositorio propio, `parents[1]` dejó de ser el workspace y pasó a ser el
repo — que es exactamente lo que queremos para `SQL/` y los seeds, y exactamente
lo que NO queremos para la bóveda y la API. De ahí las dos constantes.

`SALUD_WORKSPACE` permite reapuntar el workspace sin tocar código, para el caso
en que la bóveda o la API estén clonadas en otro lado.
"""

import os
from pathlib import Path

# `salud-db/` → el repositorio del modelo.
MODEL_ROOT = Path(__file__).resolve().parent.parent

# El repositorio del modelo → el workspace que lo contiene.
WORKSPACE = Path(os.environ.get("SALUD_WORKSPACE") or MODEL_ROOT.parent).resolve()

# --- Dentro del repositorio del modelo --------------------------------------
CONTEXT_DIR = MODEL_ROOT / "Mantra Core Health Context"
PUML_DIR = CONTEXT_DIR / "modules"
MANIFEST = CONTEXT_DIR / "model-manifest.yaml"
SQL_DIR = MODEL_ROOT / "SQL"
NOSQL_DIR = MODEL_ROOT / "NoSQL"
SEEDS_DIR = MODEL_ROOT / "seedsGenerales"
SEEDS_MODULES_DIR = SEEDS_DIR / "modules"
SEEDS_PROD_DIR = MODEL_ROOT / "seedsProd"
DATA_DIR = MODEL_ROOT / "salud-db" / "data"

# --- Fuera: repositorios hermanos -------------------------------------------
VAULT_REPO = WORKSPACE / "Mantra Core Health Vault"
VAULT = VAULT_REPO / "SALUD"
FK_DIR = VAULT / "FK"
API_DIR = WORKSPACE / "mantra-core-health-api"
API_ENV_FILE = API_DIR / ".env"
API_ENTITIES_DIR = API_DIR / "src" / "modules"
COMPOSE_FILE = API_DIR / "docker-compose.yml"
