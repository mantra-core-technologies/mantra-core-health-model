# Reporte — Carril M1 · Mac mini (infraestructura, base de datos y despliegue)

> **AVANCE: 12 / 22 microtareas — 54,5 %.** (H2 · H3 · H4 completos; H1 y H5 en curso; H6 pendiente
> de H1.)

- Fecha: 2026-09-26 · Plan: [PLAN.md](./PLAN.md) · Ramas: `justin/m1-model-...`,
  `justin/m1-fk-notas-...`, `justin/m1-api-carril-mac-mini`, `justin/test-integration`
- Peldaño de evidencia alcanzado: **por área**. H2/H3/H4: `VERIFIED` (runtime real, sin PHI).
  H1: `TESTED` para el fix del heap (compila y se validó el YAML; falta observar el efecto en
  producción). H5: `WRITTEN`+`RUNS` (spec escrita, typecheck en 0; no corrida contra el sitio real
  todavía porque el sitio no estuvo sano hasta ahora).

## Completado

| ID | Qué se logró | Comando | Resultado |
|---|---|---|---|
| H2.S1.M1 | Vigilante paramétrico por rama y por app | `alovida-autodeploy-test.sh --estado` | dos apps, cada una con su sha real |
| H2.S1.M2 | Plist `bo.alovida.autodeploy-test` instalado, sin tocar el de `mockup` | `launchctl list \| grep alovida` | `bo.alovida.autodeploy` y `bo.alovida.autodeploy-test`, los dos con PID activo |
| H2.S1.M3 | Detección de un commit real sin intervención manual | `Monitor` en segundo plano sobre el diario | `2026-09-26 01:49:05  la rama avanzó a 002bdfdd; desplegando` — la línea la escribió el vigilante en su propio tick, no un curl mío |
| H3.S1.M1–M4 | Módulos 67/68 transcritos + 4 patches promovidos, sin colisión de numeración | diff programático columna por columna | 0 diferencias en las 12 tablas; 15/15 y 6/6 índices idénticos; FK 27 y 14, igual a los deltas declarados |
| H3.S2.M1–M2 | `yarn db:vendor` deja de borrar DDL | `db:vendor:check` | `=== database/SQL al día` / `=== database/NoSQL al día`, exit 0; `git status database` sin ninguna `D` |
| H4.S1.M1–M2 | Matriz de los 12 markdown → seed → tabla, con conteo real | regenerar `extract_datasets.py` + diff byte a byte | 0 diferencias contra los 5 `.dataset.json` comitidos; 9/12 archivos llegan hoy (3 más de lo que decía el reparto sin regenerar) |

## A medias

### H1 — El front real vuelve a levantar en Coolify

- **Qué anda:** la configuración del recurso quedó corregida y verificada por la API de Coolify:
  `docker_compose_location` apunta a `deploy/docker-compose.coolify.yml` (antes: el compose de la
  raíz, equivocado), `APP_DOMAIN` y `ALOVIDA_NETWORK` están cargadas, y el dominio
  `https://test.173.249.39.237.sslip.io` está asignado al servicio `proxy` con la misma forma que
  usa `mockup-frontend` (que sí funciona). Esas tres correcciones **no existían** al empezar
  (`exited:unhealthy`, compose equivocado, cero variables) y quedan.
- **Qué no anda:** el contenedor `web` entra en ciclo — se observó, con la propia API de Coolify,
  oscilando entre `restarting:unknown`, `running:unhealthy` y `running:healthy` en una ventana de
  ~15 min sin estabilizar. El dominio público responde **503 "no available server"** (Traefik, sin
  backend registrado — consistente con que `proxy` nunca reporta arriba, porque depende de que
  `web` esté sano). No hay acceso a `docker logs`/`docker inspect` (SSH no autorizado; el token de
  la API de Coolify no expone logs del contenedor de forma confiable — los pocos intentos que
  devolvieron contenido real fueron aleatorios y no reproducibles a pedido).
- **Qué falta exactamente:** confirmar si el fix aplicado (acotar `NODE_OPTIONS=--max-old-space-size=512`
  en `web`, mismo patrón que el propio Dockerfile ya usa para las dos etapas de build) resuelve el
  ciclo. Se empujó a `test` (`e93c2182`) y el vigilante lo tomó; **la observación de si estabiliza
  está en curso al momento de escribir este reporte** — ver el bloque de evidencia más abajo, que
  se actualiza cuando termine la ventana de observación. Si no estabiliza, el siguiente paso real
  es SSH (para leer `docker logs web` y `docker inspect` buscando `OOMKilled: true`), que no está
  autorizado en esta sesión.
- **Dónde quedó:** `deploy/docker-compose.coolify.yml` en `justin/test-integration` (front),
  comiteado y empujado a `origin/test` (`e93c2182`). Compila (`docker compose … config` sin error).
  La configuración del recurso está aplicada en Coolify (no es un archivo, es estado del panel).

### H5 — El recorrido real contra el VPS

- **Qué anda:** la suite está escrita (`playwright/carril-m1-recorrido-real-vps.spec.ts`), cubre
  los 4 puntos del hito (salud de la API por el proxy, login por rol con cuentas autoregistradas
  contra la API real, la vitrina pública en los 3 viewports × 2 temas con consola/red vigiladas, y
  que el login real no lo intercepte el simulador), y **typechequea en 0**
  (`npx tsc -p tsconfig.spec.json --noEmit`).
- **Qué no anda:** no se corrió contra el sitio real todavía, porque el sitio no estuvo sano el
  tiempo suficiente (ver H1). Correrla contra un sitio que cicla entre sano/no-sano daría un
  resultado que no significa nada.
- **Qué falta exactamente:** una vez que H1 estabilice, correr
  `E2E_BASE_URL=https://test.173.249.39.237.sslip.io yarn pw --workers=1 playwright/carril-m1-recorrido-real-vps.spec.ts`
  **tres veces sobre el mismo commit** (el DoD real de H5 lo exige así) y pegar las tres salidas.
- **Dónde quedó:** el archivo está en `justin/test-integration`, sin comitear todavía (se comitea
  junto con la primera corrida real, para que el commit lleve su propia evidencia de que corrió).

## Pendiente

| ID | Estado | Qué lo destraba |
|---|---|---|
| H6 (el bucle merge → build → recorrido → corrección) | `BLOQUEADO` | Depende de que H1 y H5 cierren primero: no tiene sentido cerrar el ciclo de un sitio que todavía no está sano |

## Evidencia

```text
$ curl -sS -m 25 -H "Authorization: Bearer $TOKEN" http://173.249.39.237:8000/api/v1/applications/zslh6pytstjjgf5mexeopvkz | python3 -c "..."
estado: running:unhealthy   (y también: restarting:unknown, running:healthy — observado alternando)
dominios: {"proxy":{"domain":"https://test.173.249.39.237.sslip.io","redirect":"both"}}

$ curl -sS -k -m 12 https://test.173.249.39.237.sslip.io/
503
no available server

$ python3 .../gen_ddl.py all   (dentro de wt-m1-model, SALUD_WORKSPACE=/tmp/m1-workspace)
[67/data_catalog] 8 tablas · 14 FK intra · 13 FK diferidas · 13 inferidas · 15 índices · 0 saltadas
[68/qa_execution] 4 tablas · 3 FK intra · 11 FK diferidas · 6 inferidas · 6 índices · 0 saltadas

$ yarn db:vendor:check   (dentro de mantra-core-health-api, MODEL_REPO apuntando al worktree del modelo)
=== database/SQL al día
=== database/NoSQL al día

$ diff <(regenerado) <(comitido)   × 5 datasets bolivia
(las 5, vacío)

$ tail -3 ~/.local/state/alovida-autodeploy-test/api/autodeploy.log
2026-09-26 01:46:01  la rama avanzó a 016caaa1; desplegando
2026-09-26 01:46:02  DESPLEGADO 016caaa1 — Coolify respondió 200
2026-09-26 01:49:05  la rama avanzó a 002bdfdd; desplegando
```

## No cubierto

- **El recorrido real (H5) no se ejecutó**, sólo se escribió y typechequeó — ver "A medias".
- **No se contaron filas en la base viva del VPS** para H4: el conteo de "filas en destino" es el
  tamaño del dataset JSON regenerado, no una consulta a Postgres (sin SSH no hay `psql` posible).
- **No se confirmó por qué `web` entraba en ciclo antes del fix de memoria**: la hipótesis del OOM
  es razonada (mismo patrón que el propio repo ya documenta y corrige en el build), no confirmada
  con `docker inspect`. Si el fix no estabiliza, la causa sigue sin confirmar.
- **No se verificó si las 10 especialidades odontológicas del archivo 10 están en
  `observed-specialties.dataset.json`** — ambigüedad Q-05 del H4, registrada, no resuelta.

## Desvíos del plan

- Se agregó una microtarea no prevista: **corregir `deploy/docker-compose.coolify.yml`** (acotar
  `NODE_OPTIONS`), fuera del alcance original de H1.S1/H1.S2 tal como estaban escritas. Se agrega
  como parte de H1 porque el archivo está en el alcance declarado (`deploy/`) y el hallazgo apareció
  ejecutando H1, no se fue a buscar.
- Un error propio: al hacer un commit de comprobación para H2.S1.M3 lo hice primero en el checkout
  **compartido** de `mantra-core-health-api` (violación de la regla de "un checkout, una sesión").
  Se detectó antes de pushear, se deshizo con `git stash` + `git reset --hard origin/dev` sobre el
  checkout compartido (dejándolo tal como estaba), y se rehizo correctamente en un worktree propio
  (`wt-m1-api`). Ningún cambio ajeno se perdió; el stash se aplicó y se soltó explícitamente por su
  hash único, no con un `stash pop` a ciegas.

## Riesgos residuales y deuda

- El vigilante de `test` depende de que esta Mac esté encendida — igual que el de `mockup`, ya
  documentado.
- `yarn db:vendor` sigue teniendo el potencial de traer deriva **no relacionada** con este carril
  (community/surveys, ver el commit del modelo): es real, está documentada, y no se tocó por estar
  fuera de alcance.
- Si el fix de memoria de H1 no resuelve el ciclo, el carril queda con un bloqueo real de
  infraestructura que sólo SSH puede diagnosticar a fondo.

## Decisiones y ambigüedades

| ID | Decisión/ambigüedad | Quién puede resolverla | Supuesto tomado |
|---|---|---|---|
| — | `restore_test_runs.objective_status` sin `DEFAULT` en el modelo (el patch vivo sí lo lleva, sólo para backfill) | — (ya decidido y documentado en el commit del modelo) | la entidad ORM ya fija el valor en la clase; una base nueva no necesita backfill |
| Q-05 | Si las especialidades odontológicas del archivo 10 están representadas en `observed-specialties` | el propietario / quien mantenga `extract_datasets.py` | no se asumió nada; queda en la matriz de H4 como "sin confirmar" |
| — | Fix de memoria de H1 es una hipótesis razonada, no confirmada | se resuelve solo observando si el ciclo cesa | documentado explícitamente como tal en el propio archivo y en este reporte |
