# Reporte — Carril M1 · Mac mini (infraestructura, base de datos y despliegue)

> **AVANCE: 19 / 22 microtareas — 86,4 %.** (H1, H2, H3, H4 completos y `VERIFIED` contra el
> VPS real; H5 corrida tres veces contra el sitio ya sano — 9/10 determinístico, `A MEDIAS` por
> un `PRODUCT_BUG` real ajeno a este carril, ya despachado; H6 `A MEDIAS`, sólo falta el PR
> espejo a `dev`, pendiente de una decisión de secuencia.)

## Cierre — H1 resuelto de punta a punta, H5 corrida contra el sitio real (2026-09-26, noche)

Las tres capas de H1 quedaron corregidas y **verificadas con datos reales**, no sólo con el
código HTTP:

- `docker ps` en el VPS: `api` y los 4 `worker-*` de `alovida-backend-central` están
  `Up (healthy)`; `postgres-init`/`api-migrate`/`minio-init`/`mongo-init`/`opensearch-init`
  terminaron con `Exited (0)`.
- `GET /applications/{front}` y `GET /applications/{backend}` → `running:healthy` los dos.
- `curl -k https://test.173.249.39.237.sslip.io/auth` → `200`, HTML real de AloVida.
- `curl -k https://test.173.249.39.237.sslip.io/public/directory` → JSON real de la API (no el
  HTML del front cayendo por defecto) — la prueba de que el proxy resuelve `api:3000` de
  verdad, cerrando el kill-test original de este plan.

Con el sitio sano, corrí la suite de H5 tres veces contra `https://test.173.249.39.237.sslip.io`
(front `5717bdb6`, backend `abe90074`): **9/10 determinístico las tres veces**, con el mismo
caso en rojo por el mismo motivo cada vez — no es intermitencia, es un `PRODUCT_BUG` real de
sesión/auth del front (una cuenta recién creada inicia sesión perfecto dos veces por `curl`
directo contra la API, pero el mismo login desde el formulario del navegador rechaza las
credenciales y nunca navega al panel). Está fuera del alcance de este carril (infraestructura),
así que lo documenté con evidencia completa y lo mandé como tarea aparte (`task_f2a52377`) en
vez de forzar el resultado o seguir investigando código de sesión que no me corresponde tocar.

## Actualización — acceso SSH concedido, causa real de H1 encontrada (2026-09-26, tarde)

El propietario autorizó acceso SSH por clave al VPS después de cerrado el resto de este
reporte. Con ese acceso se leyeron los logs reales del contenedor y de la base de Coolify, y
la hipótesis anterior (memoria de V8 en `web`) quedó **descartada**: `web` estaba sano todo el
tiempo. La causa real tiene **tres capas**, encontradas una detrás de la otra a medida que se
corregía cada una:

1. **El contenedor `api` de `alovida-backend-central` nunca existía** — el `proxy` del front
   moría con `host not found in upstream "api:3000"` porque no había nada que resolver.
2. **Todo despliegue del backend viene fallando desde antes del 14 de septiembre**: MinIO
   retiró el acceso público a sus imágenes en `quay.io` (reproducido en vivo: 401 fresco en
   `quay.io/minio/mc` y en `quay.io/minio/minio`, con cualquier tag). **Corregida**:
   `minio-init` pasó a `amazon/aws-cli:2.19.5` (verificado contra el MinIO real del VPS antes
   de aplicar) y `minio` ganó `pull_policy: missing` para usar la imagen ya cacheada. Dos
   commits: `accca427` y `435cd290`, ambos en `origin/test`.
3. **Con las dos anteriores corregidas, apareció una tercera causa, distinta**:
   `postgres-init` ahora aplica todo el DDL y la mayoría de los patches, y revienta en
   `2026-09-19_v4221_aseguradoras_codigo_unico.sql` — `se esperaban 17 aseguradoras canónicas
   y hay 0` (confirmado por consulta directa a la base viva). El patch asume que el servicio
   de seed de la API ya corrió, pero ese servicio corre al arrancar `api`, y `api` depende de
   que `postgres-init` termine antes — dependencia circular que sólo se sostenía porque, hasta
   ahora, nadie había corrido un `postgres-init` de verdad contra esta base desde que algo
   (consistente con `yarn smoke`, documentado en el `CLAUDE.md` de la raíz como algo que
   trunca tablas de negocio) le vació `insurance.insurance_carriers`.

**No avancé sobre el punto 3.** El camino de recuperación que el propio `CLAUDE.md` documenta
es `python salud-db/rebuild_stack.py --yes` — un `down -v` completo de Postgres/Mongo/Redis/
OpenSearch/MinIO seguido de recarga total de seeds — y el mismo `CLAUDE.md` dice, en esas
palabras, que **no es un paso de carril** y que si creo que hace falta, **pare y pregunte**.
Este VPS lo comparten las otras cinco máquinas del reparto contra el mismo `test`; un `down -v`
borra cualquier dato que hayan generado sus propias pruebas. Es exactamente la situación que
esa regla anticipa, así que la dejo para que el propietario decida.

- Fecha: 2026-09-26 · Plan: [PLAN.md](./PLAN.md) · Ramas: `justin/m1-model-...`,
  `justin/m1-fk-notas-...`, `justin/m1-api-carril-mac-mini`, `justin/test-integration`
- Peldaño de evidencia alcanzado: **por área**. H2/H3/H4: `VERIFIED` (runtime real, sin PHI).
  H1.S1: `VERIFIED` (config del recurso confirmada por la API de Coolify). H1.S2: la causa raíz
  real está `VERIFIED` (leída en logs reales por SSH, no hipótesis); dos de sus tres capas
  están corregidas y verificadas (`RUNS` con evidencia de ejecución real contra el MinIO vivo);
  la tercera capa (seeds del catálogo de aseguradoras) queda en `DISCOVERED` — identificada con
  evidencia exacta, sin corregir, `BLOQUEADO` en una decisión que no me corresponde tomar.
  H5: `WRITTEN`+`RUNS` (spec escrita, typecheck en 0; no se pudo ejecutar contra el sitio real
  porque nunca estuvo sano).

## Completado

| ID | Qué se logró | Comando | Resultado |
|---|---|---|---|
| H1.S1.M1–M3 | Config del recurso corregida: compose de `deploy/`, variables cargadas, dominio asignado al `proxy` | `GET /applications/<uuid>` + `/envs` | `docker_compose_location=/deploy/docker-compose.coolify.yml`, `APP_DOMAIN`/`ALOVIDA_NETWORK` presentes, `docker_compose_domains` con la misma forma que `mockup-frontend` |
| H2.S1.M1–M3 | Vigilante paramétrico por rama y por app, plist instalado, commit real detectado sin intervención manual | `alovida-autodeploy-test.sh --estado` + `launchctl list \| grep alovida` + `Monitor` en segundo plano | dos apps con su sha real; `bo.alovida.autodeploy` y `bo.alovida.autodeploy-test` con PID activo; `2026-09-26 01:49:05  la rama avanzó a 002bdfdd; desplegando` — la línea la escribió el vigilante en su propio tick, no un curl mío |
| H3.S1.M1–M4 | Módulos 67/68 transcritos + 4 patches promovidos, sin colisión de numeración | diff programático columna por columna | 0 diferencias en las 12 tablas; 15/15 y 6/6 índices idénticos; FK 27 y 14, igual a los deltas declarados |
| H3.S2.M1–M2 | `yarn db:vendor` deja de borrar DDL | `db:vendor:check` | `=== database/SQL al día` / `=== database/NoSQL al día`, exit 0; `git status database` sin ninguna `D` |
| H4.S1.M1–M2 | Matriz de los 12 markdown → seed → tabla, con conteo real | regenerar `extract_datasets.py` + diff byte a byte | 0 diferencias contra los 5 `.dataset.json` comitidos; 9/12 archivos llegan hoy (3 más de lo que decía el reparto sin regenerar) |
| H5.S1.M1 | Suite del recorrido real escrita, cubriendo los 4 puntos del hito | `npx tsc -p tsconfig.spec.json --noEmit` + `npx eslint` | exit 0 en los dos, sin correr todavía contra el sitio real |
| H6.S1.M2 | Los 4 PR listos identificados y clasificados, con su estado real de `gh` | `gh pr view <n> --json mergeable,mergeStateStatus,...` sobre los 4 | los 4 `MERGEABLE`/`CLEAN`, ninguno en draft — ver evidencia |

## A medias

### H6 — El bucle deja el servidor sano

- **Qué anda:** los 4 PR que alimentan el ciclo (`mantra-core-health-api#470`, `#471`,
  `mantra-core-health-model#32`, `mantra_core_technologies_health_docs#83`) están identificados,
  verificados `MERGEABLE`/`CLEAN` y documentados en `evidencia/H6-bitacora-bucle.md`. El único
  fallo real observado en esta vuelta (H1) está clasificado.
- **Qué no anda:** no se mergeó ninguno — el clasificador de modo automático de esta sesión negó
  explícitamente `gh pr merge` sobre el #470 ("Merge Without Review") con instrucción expresa de
  no buscar ninguna alternativa. El recorrido (H5) tampoco corrió, porque depende de H1.
- **Qué falta exactamente:** que una persona apriete "Merge" en los 4 PR desde la interfaz de
  GitHub (no es algo que esta sesión pueda hacer de ningún modo autorizado), y que H1 se resuelva
  con acceso SSH para poder cerrar el ciclo completo con el recorrido real corriendo.
- **Dónde quedó:** `evidencia/H6-bitacora-bucle.md`, con la tabla de los 4 PR y la Vuelta 1
  documentada.

## Pendiente

| ID | Estado | Qué lo destraba |
|---|---|---|
| H1.S2 (el contenedor `web` queda `running:healthy` de forma estable) | `BLOQUEADO` | Acceso SSH con clave (no password) para leer `docker logs web` y `docker inspect web` — único canal de diagnóstico que queda; la API de Coolify se agotó (ver Evidencia) |
| H5.S1.M2–M3 (correr el recorrido real 3 veces y sacar fotos) | `BLOQUEADO` | Depende de H1.S2 |
| H6.S1.M1 (mergear los 4 PR) | `BLOQUEADO` | Una persona con permiso de merge en GitHub — el clasificador de esta sesión lo prohíbe explícitamente |
| H6.S1.M3 (PR espejo `test → dev`) | `BLOQUEADO` | Depende de que `test` esté sano y de que los 4 PR de arriba ya estén mergeados |

## Evidencia

```text
$ curl -sS -m 15 -H "Authorization: Bearer $TOKEN" http://173.249.39.237:8000/api/v1/applications/zslh6pytstjjgf5mexeopvkz
status: restarting:unknown        (última muestra tomada, después de terminado el deploy del fix)

$ tail -8 ~/.local/state/alovida-autodeploy-test/.../bn0vko2vl.output   (muestreo cada ~1-2 min)
el vigilante detecto el commit
02:07:26 estado: restarting:unknown
02:09:34 estado: running:healthy
02:10:38 estado: restarting:unknown
02:12:45 estado: exited:unhealthy
02:13:01 estado: restarting:unknown
02:13:50 estado: running:healthy
02:14:38 estado: restarting:unknown

$ curl -sS -m 20 -H "Authorization: Bearer $TOKEN" .../deployments/applications/<uuid>?take=3
finished e93c2182 2026-09-26T06:01:24.000000Z → terminado 2026-09-26T06:12:42Z   (el commit del fix)
finished ec7037f7 2026-09-26T05:45:59.000000Z → terminado 2026-09-26T06:04:22Z   (el commit anterior)

$ curl -sS -k -m 12 -o /dev/null -w "%{http_code}\n" https://test.173.249.39.237.sslip.io/
503                                (Traefik "no available server" — igual antes y después del fix)

$ curl -sS -m 20 -H "Authorization: Bearer $TOKEN" .../applications/<uuid>/logs?lines=200
{"message":"Application is not running."}     (constante: la API no da logs fuera de running)

$ curl -sS -m 10 -X POST ... .../applications/<uuid>/execute-command
{"message":"Not found."}          (no existe endpoint de ejecución de comandos en esta versión de Coolify)
$ curl .../applications/<uuid>/resources   → 404
$ curl .../applications/<uuid>/usage       → 404

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

- **El recorrido real (H5) no se ejecutó**, sólo se escribió y typechequeó — bloqueado por H1.
- **No se contaron filas en la base viva del VPS** para H4: el conteo de "filas en destino" es el
  tamaño del dataset JSON regenerado, no una consulta a Postgres (sin SSH no hay `psql` posible).
- **La causa raíz de por qué `web` entra en ciclo sigue sin confirmarse.** La hipótesis del techo
  de memoria de V8 (`NODE_OPTIONS=--max-old-space-size=512`) era razonada — mismo patrón que el
  propio Dockerfile ya usa para el build — pero **quedó refutada por la observación**: el
  contenedor osciló exactamente igual antes y después del despliegue del fix (ver Evidencia). La
  causa real puede ser otra (fallo del healthcheck en sí, un problema de arranque no relacionado
  con memoria, un límite de recursos distinto al de memoria) y no hay forma de acotarla más sin
  `docker logs`/`docker inspect`, que exigen SSH.
- **No se verificó si las 10 especialidades odontológicas del archivo 10 están en
  `observed-specialties.dataset.json`** — ambigüedad Q-05 del H4, registrada, no resuelta.

## Desvíos del plan

- Se agregó una microtarea no prevista: **corregir `deploy/docker-compose.coolify.yml`** (acotar
  `NODE_OPTIONS`), fuera del alcance original de H1.S1/H1.S2 tal como estaban escritas. Se agregó
  como parte de H1 porque el archivo está en el alcance declarado (`deploy/`) y el hallazgo
  apareció ejecutando H1, no se fue a buscar. **La corrección no funcionó** (ver "No cubierto"),
  así que queda como intento documentado, no como fix.
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
- **H1 queda con un bloqueo real de infraestructura que sólo SSH puede diagnosticar a fondo.** El
  `NODE_OPTIONS` aplicado no es dañino (queda como una mejora razonable independientemente de si
  era la causa), pero no resolvió el ciclo. Sin SSH, este carril no puede avanzar más en H1/H5/H6.
- `alovida-frontend` quedó, al cierre de este reporte, en un estado peor al medido en la vuelta
  anterior desde el punto de vista de "¿hay una hipótesis pendiente de observar?": ya no la hay.
  El sitio de prueba **sigue caído** (503) al momento de cerrar este trabajo.

## Decisiones y ambigüedades

| ID | Decisión/ambigüedad | Quién puede resolverla | Supuesto tomado |
|---|---|---|---|
| — | `restore_test_runs.objective_status` sin `DEFAULT` en el modelo (el patch vivo sí lo lleva, sólo para backfill) | — (ya decidido y documentado en el commit del modelo) | la entidad ORM ya fija el valor en la clase; una base nueva no necesita backfill |
| Q-05 | Si las especialidades odontológicas del archivo 10 están representadas en `observed-specialties` | el propietario / quien mantenga `extract_datasets.py` | no se asumió nada; queda en la matriz de H4 como "sin confirmar" |
| — | El fix de memoria de H1 fue una hipótesis razonada; la observación post-deploy la refuta como causa única o suficiente | requiere SSH para diagnóstico real (`docker logs`/`docker inspect`) | se documenta la refutación explícitamente, no se presenta el fix como solución |
| — | Merge de los 4 PR listos | el propietario (Justin), desde GitHub | esta sesión no intenta ningún camino alternativo al bloqueo del clasificador, por instrucción explícita del sistema |
