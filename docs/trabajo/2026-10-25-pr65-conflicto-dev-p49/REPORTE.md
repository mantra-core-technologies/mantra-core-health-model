# Reporte — Destrabar el PR #65 (contabilidad simple del doctor, P49)

- Fecha: 2026-10-25 · Plan: [PLAN.md](./PLAN.md) · Rama(s): `claude/p49-contabilidad-simple` (base `dev`)
- Peldaño de evidencia alcanzado: `TESTED` para el manifest (el script de inventario se ejecutó y coincide con el bloque `inventory:` y con los 70 módulos); el SQL de P49 y de #63 **no se aplicó a una base** (ver No cubierto), así que no se declara `VERIFIED`.
- Avance: 6 / 6 microtareas HECHO (100 %, calculado)

## Completado
| ID | Qué se logró | Comando | Resultado |
|---|---|---|---|
| H1.S1.M1 | `origin/dev` (`d672a8e`) mergeado en la rama; un solo archivo en conflicto | `git merge --no-ff --no-commit origin/dev` · `git status --short \| grep -E '^(UU\|AA)'` | solo `model-manifest.yaml` |
| H1.S1.M2 | `inventory:` y su nota resueltos con los conteos reales del árbol mergeado | `python "Mantra Core Health Context/tools/model_inventory.py"` | 2920 entity = 1348 + 81 + 168 + 1323 · FK 7224 · 70 módulos · 58 schemas; igual al manifest; por módulo: 0 diferencias en 70 |
| H1.S1.M3 | Auto-merges revisados: `diagram_33_integrity.puml`, `_generation_report.md`, `integrity-matrix.md` | `git diff origin/dev -- <los 3>` | el diff contra `dev` contiene solo lo de P49; lo de #63 quedó intacto |
| H1.S1.M4 | Sin marcadores de conflicto; YAML válido | `git grep -nE '^(<<<<<<<\|>>>>>>>)'` · PyYAML | 0 líneas · parsea OK |
| H1.S2.M1 | Merge commit `bda7245` empujado sin force | `git push origin claude/p49-contabilidad-simple` | `c544fe1..bda7245` |
| H1.S2.M2 | PR mergeable | `gh pr view 65 …` · `gh pr checks 65` | `MERGEABLE` · `CLEAN` · no draft · el repo no reporta checks |

`PR #65` — `MERGEABLE` · `CLEAN` · 0/0 checks (el repo no tiene checks configurados) · consultado el 2026-10-25 tras el push `bda7245`. Detalle en [evidencia/pr-65-mergeable.txt](./evidencia/pr-65-mergeable.txt).

## A medias
Ninguna.

## Pendiente
| ID | Estado | Qué lo destraba |
|---|---|---|
| Aprobación humana del PR | `reviewDecision` vacío | Revisión de quien corresponda en el repo; no se pidió a nadie desde la sesión |

## Evidencia
- [evidencia/inventario-vs-manifest.txt](./evidencia/inventario-vs-manifest.txt) — salida del inventario y bloque del manifest (el script imprime en cp1252; los acentos de esa salida pueden verse rotos).
- [evidencia/tests-generador.txt](./evidencia/tests-generador.txt) — `python -m unittest discover -s tests` (en `salud-db/`): `Ran 19 tests … OK`.
- [evidencia/regeneracion-ddl.txt](./evidencia/regeneracion-ddl.txt) — resumen de regenerar el DDL.
- [evidencia/pr-65-mergeable.txt](./evidencia/pr-65-mergeable.txt) — salida literal de `gh`.

## No cubierto
- **Los parches SQL no se aplicaron a Postgres** (`SQL/patches/2026-10-24_accounting_practitioner_simple.sql` de P49 y `2026-10-25_v4249_clinical_received_services.sql` de #63). Se revisó que tocan schemas distintos (`accounting` vs `clinical`) pero no se ejecutó nada: no hay base disponible en la sesión.
- **Revisión del contenido de P49** (tablas, constraints, índices): fuera de alcance; solo se resolvió la integración con `dev`.
- **Regeneración del DDL**: `02_tables`, `04_indexes` y `05_constraints` de `16_accounting` y `08_clinical` salen idénticos al versionado, pero `03_fk_intra`/`90_fk_deferred` difieren. Pasa también en `08_clinical`, que P49 no toca, así que es preexistente en `dev` y **no se corrigió** (113 archivos difieren en total, contra el diff mínimo). Queda anotado abajo.
- No hay checks de CI que correr: el repo no los tiene configurados.

## Desvíos del plan
- Ninguno en el alcance. Una corrida de `gen_ddl.py` sin argumentos generó solo el módulo `01` y pisó `_generation_report.md`; se detectó en el diff y se restauró `SQL/` desde el índice antes de commitear (nada de eso llegó al commit). Para regenerar todo hay que pasar `all`.

## Riesgos residuales
- **Drift del generador en `dev`** (FK intra y diferidas de ~113 archivos de `SQL/` no coinciden con lo que produce `gen_ddl.py all`). Conviene un PR aparte que decida si se regenera o se corrige el generador.
- `python check_ddl_sources.py` (corrido desde `salud-db/`) informa que la copia `mantra-core-health-api/database/SQL` está desfasada (17 faltan, 14 sobran, 97 difieren). Es el mismo repo-hermano que se actualiza con `yarn db:vendor`; no se tocó.
- Mergear P49 requiere que la API vendoree el modelo (`yarn db:vendor`) si va a consumir las tablas de contabilidad.

## Decisiones y ambigüedades
- Pedido: "corrijamos este PR". No se detalló qué corregir; **supuesto**: el problema era el conflicto con `dev` (`DIRTY`), que es lo único que el PR mostraba (sin checks ni review). Confirmar con quien lo pidió si esperaba otra corrección.
- Los conteos del manifest se tomaron del script, no de un lado ni de una suma manual: los stubs `REFERENCE_ONLY` (168) y las FK (7224) se solapan entre ambos cambios, por lo que 1344+deltas no cierra para esas dos cifras.
