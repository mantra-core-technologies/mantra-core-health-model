# H6 — Bitácora del bucle merge → build → recorrido → corrección

> Este archivo se actualiza en cada vuelta del bucle. No es el `PLAN.md` (que declara el hito);
> es el registro operativo de qué pasó en cada ciclo.

## PRs listos para mergear a `test`, pendientes de un clic humano

**No puedo mergearlos yo.** El clasificador de esta sesión bloquea "merge sin revisión humana"
como acción autónoma (denegación explícita al intentar `gh pr merge` sobre el #470). Los tres
están verificados `MERGEABLE` / `CLEAN`, sin draft, sin review requerida pendiente:

| PR | Repo | Título | Estado |
|---|---|---|---|
| [#470](https://github.com/mdavila-2001/mantra-core-health-api/pull/470) | `mantra-core-health-api` | M4 · B10 — agenda sin solapamiento, retiro conserva citas vivas | `MERGEABLE` / `CLEAN` |
| [#471](https://github.com/mdavila-2001/mantra-core-health-api/pull/471) | `mantra-core-health-api` | M4 · B13 — contrato de importes de cotizaciones, sin N+1 | `MERGEABLE` / `CLEAN` |
| [#32](https://github.com/mantra-core-technologies/mantra-core-health-model/pull/32) | `mantra-core-health-model` | M1 · promueve los módulos 67/68 al modelo | `MERGEABLE` / `CLEAN` |
| [#83](https://github.com/mdavila-2001/mantra_core_technologies_health_docs/pull/83) | `mantra_core_technologies_health_docs` | M1 · 22 notas de FK para los módulos 67/68 | `MERGEABLE` / `CLEAN` |

## Vueltas del ciclo

### Vuelta 1 — 2026-09-26

- **Merge:** ninguno (los PRs de arriba recién aparecieron; ver limitación de arriba).
- **Build:** `e93c2182` (fix de memoria del compose) — disparado por el vigilante de `test` tras
  el push. En curso al momento de escribir esto.
- **Recorrido:** no corrido — H1 (el sitio sano) es su precondición.
- **Clasificación de fallos de esta vuelta:** `ENVIRONMENT`, provisional. El contenedor `web` de
  `alovida-frontend` entra en ciclo (`restarting:unknown` ↔ `running:unhealthy` ↔
  `running:healthy`) sin estabilizar en la primera build de `test`. Sin SSH ni `docker
  logs`/`docker inspect` no se pudo confirmar la causa con certeza; se aplicó una corrección
  razonada (acotar el heap de V8 por debajo del techo del contenedor, mismo patrón que el propio
  Dockerfile ya usa para el build) y se está observando si estabiliza. Ver H1 en `REPORTE.md`.
