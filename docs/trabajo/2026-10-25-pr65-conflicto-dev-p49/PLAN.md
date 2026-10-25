# Plan — Destrabar el PR #65 (contabilidad simple del doctor, P49)

- Fecha: 2026-10-25 · Repos afectados: `mantra-core-health-model` · Predecesor: commit `18eecf2` (feat P49) y merge previo `c544fe1`
- Resultado observable: el PR #65 (`claude/p49-contabilidad-simple` → `dev`) queda `MERGEABLE`, fuera de draft, sin perder el contenido de P49 ni el de `dev` (PR #63, servicios recibidos v4.2.49).
- Kill-test: `gh pr view 65 --json mergeable,mergeStateStatus` devuelve `CONFLICTING`/`DIRTY` → no está hecho.

## Alcance
- IN: merge de `origin/dev` (`d672a8e`) en la rama del PR; resolución del conflicto en `Mantra Core Health Context/model-manifest.yaml` (bloque `inventory:` y su comentario de cifras); verificación de que los archivos auto-mergeados (`diagram_33_integrity.puml`, `SQL/_generation_report.md`, `SQL/_integrity/integrity-matrix.md`) quedaron coherentes con ambos lados.
- OUT: cualquier cambio de contenido de P49 o de #63; refactor/reformateo; los `seedsGenerales/*` que trae `dev`; otros PRs abiertos.
- Ambigüedades registradas:
  - El PR no define qué hay que "corregir" más allá de lo que ve GitHub. Supuesto: la causa es el conflicto (`DIRTY`); se revisa además la coherencia de los archivos generados. Confirmar con quien pidió la corrección si buscaba otra cosa.
  - Los conteos del manifest son generados: el valor correcto es el que produce `tools/model_inventory.py` sobre el árbol mergeado, no un lado ni una suma manual (los stubs `REFERENCE_ONLY` se solapan entre ambos cambios).

## H1 — PR #65 mergeable contra `dev`
**CA:** Dado el PR #65 abierto contra `dev`, cuando se consulta GitHub tras el último push, entonces `isDraft=false`, `mergeable=MERGEABLE` y `mergeStateStatus` aceptado, con el manifest reflejando el modelo real.
**DoD:** salida literal de `gh pr view 65 --json isDraft,mergeable,mergeStateStatus` y `gh pr checks 65` tras el push · `python tools/model_inventory.py` coincide con el bloque `inventory:` · cero marcadores de conflicto en el árbol.
**Estado:** HECHO

### H1.S1 — Merge y resolución
**CA:** Dado `origin/dev` mergeado en la rama, cuando se inspecciona el árbol, entonces no hay archivos en conflicto ni marcadores y ambos cambios están presentes.
**DoD:** ver microtareas.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD (comando de verificación) | Estado |
|---|---|---|---|---|
| H1.S1.M1 | `git merge origin/dev` en la rama del PR | Solo `model-manifest.yaml` queda en conflicto | `git status --short \| grep -E '^(UU\|AA)'` → 1 línea | HECHO |
| H1.S1.M2 | Resolver `inventory:` con los conteos reales | Bloque `inventory:` y comentario coinciden con el inventario | `python "Mantra Core Health Context/tools/model_inventory.py"` vs `grep` de `model-manifest.yaml` → iguales | HECHO |
| H1.S1.M3 | Revisar archivos auto-mergeados | `_generation_report.md` e `integrity-matrix.md` mencionan P49 y #63 sin duplicados ni contradicciones | `git diff origin/dev -- SQL/_generation_report.md SQL/_integrity/integrity-matrix.md` leído | HECHO |
| H1.S1.M4 | Sin marcadores de conflicto | Ningún `<<<<<<<`/`>>>>>>>` en el árbol versionado | `git grep -nE '^(<<<<<<<\|>>>>>>>)'` → vacío | HECHO |

### H1.S2 — Entrega
**CA:** Dado el merge commit, cuando se pushea y se consulta, entonces el PR queda mergeable.
**DoD:** ver microtareas.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD (comando de verificación) | Estado |
|---|---|---|---|---|
| H1.S2.M1 | Commit del merge y push (sin force) | La rama remota contiene el merge | `git push origin claude/p49-contabilidad-simple` → exit 0 | HECHO |
| H1.S2.M2 | Estado del PR tras el push | `MERGEABLE`, no draft, checks sin fallos | `gh pr view 65 --json isDraft,mergeable,mergeStateStatus` + `gh pr checks 65` | HECHO |

## Riesgos y bloqueos previstos
| Riesgo | Impacto | Mitigación |
|---|---|---|
| El inventario real no cuadra con ninguno de los dos lados | Manifest incoherente con los `.puml` | Se usa la salida del script como fuente; si hay diferencia inexplicada se investiga antes de commitear |
| El repo no tiene checks configurados | No hay verde que demostrar | Se pega la salida de `gh pr checks` tal cual y se declara |
| Hay otra causa de fallo no visible (p. ej. SQL de P49 incompatible con #63) | PR mergeable pero roto | Revisar M3 y declarar en "No cubierto" lo que no se pudo ejecutar (no hay Postgres a mano) |
