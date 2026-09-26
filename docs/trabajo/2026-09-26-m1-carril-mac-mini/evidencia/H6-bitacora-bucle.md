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
  el push. Terminó a las 06:12:42 UTC según la API de despliegues de Coolify.
- **Recorrido:** no corrido — H1 (el sitio sano) es su precondición y no se cumplió.
- **Clasificación de fallos de esta vuelta:** `ENVIRONMENT`, **cerrada como `BLOQUEADO`, no como
  resuelta**. El contenedor `web` de `alovida-frontend` entra en ciclo (`restarting:unknown` ↔
  `running:unhealthy`/`exited:unhealthy` ↔ `running:healthy`) sin estabilizar. Se aplicó una
  corrección razonada (acotar el heap de V8 por debajo del techo del contenedor, mismo patrón que
  el propio Dockerfile ya usa para el build): se empujó, el vigilante la desplegó, el build
  terminó — y **el contenedor siguió oscilando exactamente igual después del fix** (muestras
  02:12:45 `exited:unhealthy` → 02:13:01 `restarting:unknown` → 02:13:50 `running:healthy` →
  02:14:38 `restarting:unknown`). El dominio público sigue devolviendo 503. La hipótesis del OOM
  queda **refutada como causa única o suficiente** por la observación, no confirmada. Se agotaron
  los canales de diagnóstico disponibles sin SSH: la API de Coolify no da logs de un contenedor
  que no está `running` (`{"message":"Application is not running."}`) y no tiene endpoint de
  ejecución de comandos (`execute-command`, `resources`, `usage` → los tres `404`). El siguiente
  paso real y único que queda es SSH con clave para `docker logs web` / `docker inspect web`
  buscando `OOMKilled`. Ver H1 en `REPORTE.md` para el detalle completo y la evidencia literal.

### Cierre de esta sesión (M1)

El carril queda cerrado en **16/22 microtareas**, con H1.S2, H5 (ejecución) y H6 (merge + PR
espejo) `BLOQUEADO` por dos causas de fondo que ninguna decisión técnica de esta sesión puede
resolver: falta de acceso SSH al VPS, y el bloqueo del clasificador de modo automático sobre
`gh pr merge`. Ninguna de las dos se intentó sortear por un camino alternativo (regla 00 §5,
regla 65 §4 — el bloqueo es de coordinación/autorización, no de ejecución, y aun así no hay un
doble simulable para "el contenedor real corriendo en el VPS real": simular eso sería mentir
sobre lo que se verificó). Quedan documentadas para que el propietario decida los dos próximos
pasos: autorizar SSH por clave, y mergear los 4 PR listos.
