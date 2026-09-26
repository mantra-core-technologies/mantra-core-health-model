# Plan — Carril M1 · Mac mini (infraestructura, base de datos y despliegue)

- Fecha: 2026-09-26 · Repos afectados: `mantra-core-health-model`, `mantra-core-health-api`, Coolify · Predecesor: el reparto de 6 máquinas (`AlovidaPromptManager` #54)
- Resultado observable: `https://test.173.249.39.237.sslip.io` sirve la aplicación **real** con las dos apps de Coolify `running:healthy`, un push a `test` reconstruye solo, y `yarn db:vendor` deja de borrar DDL.
- Kill-test: pedir `/auth` al dominio público **desde fuera del servidor**. Si devuelve 400, el SSR no tiene su lista de hosts y el despliegue no sirve, por más verde que esté el healthcheck.

## Alcance

- **IN:** los dos recursos de Coolify (`alovida-frontend`, `alovida-backend-central`), el vigilante de autodespliegue, el repo del modelo (`.puml`, `gen_ddl.py`, `SQL/`), la auditoría de los 12 markdown, el recorrido real y el bucle hasta sano.
- **OUT:** `mockup-frontend` (es la maqueta que mira el cliente); el código de producto de los carriles de M2–M6; `yarn smoke` (trunca las tablas de negocio).
- **Ambigüedades registradas:** ver §Ambigüedades al final.

## Estado del entorno al arrancar (medido)

| Qué | Estado | Consecuencia |
|---|---|---|
| SSH al VPS | `Permission denied (publickey,password)` | H1, H2 y H3 **no lo necesitan**; H4 y H6 pierden la inspección directa de la base |
| Disco local | 3,6 GiB libres de 228 | alcanza para el trabajo del modelo (sin `node_modules`) |
| `alovida-frontend` | `exited:unhealthy`, compose `/docker-compose.yaml`, **0 variables**, sin dominio | es H1 |
| `alovida-backend-central` | `running:healthy`, compose `/docker-compose.coolify.yml` | no se toca salvo variables |
| Estándar instalado | 179 skills · 15 reglas · `plan_gate --self-test` 11 PASS | listo |

---

## H1 — El front real vuelve a levantar en Coolify

**CA:** Dado `https://test.173.249.39.237.sslip.io`, cuando se abre, entonces responde 200 con la aplicación y el recurso queda `running:healthy`.
**DoD:** `curl -o /dev/null -w '%{http_code}'` = 200 desde fuera del servidor + estado del recurso por la API de Coolify.
**Estado:** HECHO

**Resuelto de punta a punta (2026-09-26).** Las tres capas encontradas están corregidas y
verificadas en runtime real:

1. `minio-init` cambiado a `amazon/aws-cli:2.19.5` (commit `accca427`, API).
2. `minio` con `pull_policy: missing` para usar la imagen ya cacheada (commit `435cd290`, API).
3. El propietario corrió manualmente el seeder canónico (`api-migrate`/`seed-cli`) contra la
   base ya viva — 21/21 pasos, 39 670 filas, incluida "aseguradoras de Bolivia" (25 filas). Eso
   destapó una CUARTA variante del mismo bloqueo: el patch `v4.2.21` exigía además exactamente
   1 fila no canónica sobreviviente (una aseguradora demo histórica, `DEMO-opkld`, que ningún
   seeder crea — verificado con `grep` en toda la API, sin resultados). Corregido para tolerar
   0 o 1 (commit `935158e` en el modelo, PR #33 mergeado a `dev`; vendorizado a la API en
   `abe90074`).

**Verificación real, no sólo el código HTTP:**

```text
$ docker ps -a --filter 'label=coolify.resourceName=alovida-backend-central'
postgres-init  Exited (0)   minio-init  Exited (0)   mongo-init  Exited (0)
opensearch-init  Exited (0)   api-migrate  Exited (0)
api  Up (healthy)   worker-messaging  Up (healthy)   worker-scheduling  Up (healthy)
worker-workflow  Up (healthy)   worker-read_models  Up (healthy)

$ GET /applications/{front}  ->  running:healthy
$ GET /applications/{backend} -> running:healthy

$ curl -k https://test.173.249.39.237.sslip.io/auth        -> 200 (HTML real de AloVida)
$ curl -k https://test.173.249.39.237.sslip.io/public/directory
{"slug":"directory:*:*","records":[],"refreshedAt":null,"generatedAt":"2026-09-26T10:25:43Z"}
```

El último `curl` es la prueba de que el kill-test original de este plan (línea 5) queda
satisfecho por completo: no es sólo que el front responda 200, es que el proxy resuelve `api`
de verdad y la API real contesta con JSON, no con el HTML del front cayendo por defecto.

**Actualizacion tras obtener acceso SSH por clave (autorizado por el propietario):** la
hipotesis de memoria de V8 en `web` era la causa equivocada -- `web` estaba sano todo el
tiempo (`RestartCount=0`, `OOMKilled=false`, `Health=healthy`). La causa real, leida en los
logs reales del contenedor:

1. **`proxy` (nginx) moria con `host not found in upstream "api:3000"`** -- no habia NINGUN
   contenedor `api` en la red `alovida`. Confirmado con `docker network inspect alovida`.
2. **`alovida-backend-central` viene fallando TODO despliegue desde antes del 2026-09-14**
   (tabla `application_deployment_queues` de la propia base de Coolify, leida por SSH),
   siempre en el paso de `docker compose pull`: `quay.io/minio/mc` y `quay.io/minio/minio`
   devuelven **401 Unauthorized** frescos de quay.io (reproducido en vivo con `docker pull`
   contra el VPS, con varios tags incluida una version de 2023) -- MinIO retiro el acceso
   publico anonimo a sus imagenes. El estado `running:healthy` que reportaba la API de
   Coolify para esa app era enganoso: solo reflejaba los sidecars (mongo/redis/opensearch/
   minio) que seguian arriba de una corrida vieja: nunca hubo un contenedor `api` de verdad.
   **Corregido:** `minio-init` paso a `amazon/aws-cli:2.19.5` (commit `accca427`, verificado
   corriendo la logica nueva contra el `minio` real del VPS antes de aplicar) y `minio` gano
   `pull_policy: missing` para usar la imagen ya cacheada localmente sin volver a pedirla al
   registro (commit `435cd290`). Ambos verificados: el siguiente despliegue de prueba ya NO
   falla en el pull de imagenes.
3. **Tercera causa, distinta y NO resuelta por esta sesion:** con los dos fixes de arriba,
   `postgres-init` avanza mucho mas lejos -- aplica todo el DDL y la mayoria de los patches --
   y revienta en `2026-09-19_v4221_aseguradoras_codigo_unico.sql` con
   `ERROR: v4.2.21: se esperaban 17 aseguradoras canonicas y hay 0`. Verificado por consulta
   directa: `select count(*) from insurance.insurance_carriers` en la base viva da **0**. El
   patch asume que el servicio de seed de la API (`bolivia-insurance-seed.service.ts`) ya
   corrio -- pero ese servicio corre cuando arranca `api`, y `api` depende de que
   `postgres-init` termine primero (`service_completed_successfully`): dependencia circular.
   Consistente con el patron ya documentado en el `CLAUDE.md` de la raiz: `yarn smoke` trunca
   tablas de negocio y el UNICO camino de recuperacion documentado es
   `python salud-db/rebuild_stack.py --yes` (`down -v` completo + recarga de seeds) -- **una
   accion destructiva sobre datos compartidos por las otras 5 maquinas trabajando sobre el
   mismo `test`**, que el propio `CLAUDE.md` dice explicitamente que NO es un paso de carril y
   que hay que parar y preguntar antes de correrla. Por eso este hito se cierra `BLOQUEADO`
   pidiendole la decision al propietario, no ejecutandola.

   **Alternativa mas segura encontrada y bloqueada tambien, por una razon distinta:** en vez
   del `down -v` completo, alcanza con correr manualmente el paso de seed que normalmente
   corre `api-migrate` (el propio `node dist/src/seed-cli.js` del proyecto, no un INSERT a
   mano) contra la base YA viva, sin tocarle nada a nadie -- exactamente el mismo mecanismo
   canonico de seeding, sólo que sin esperar a que el patch roto termine primero. Al intentarlo
   por SSH, **el clasificador de modo automatico de esta sesion lo denego** con el motivo
   "Remote Shell Writes": cualquier escritura remota por SSH esta bloqueada sin excepcion,
   sin importar que tan segura sea la accion en si. No hay ninguna forma de rodear esto desde
   esta sesion. **El propietario puede correr esto el mismo, en su propia terminal:**

   ```bash
   ssh -i ~/.ssh/alovida_contabo root@173.249.39.237 \
     "cd /data/coolify/applications/33sxkfqwp1axlkrishtgildb && \
      docker compose -f docker-compose.yaml -p 33sxkfqwp1axlkrishtgildb \
      run --rm --no-deps api-migrate"
   ```

   Es aditivo e idempotente (es el seeder de siempre, no toca lo que ya existe), no incluye
   `down -v` ni borra nada, y no afecta a las otras 5 maquinas. Si sale en verde, disparar de
   nuevo el deploy del backend (`POST /api/v1/deploy?uuid=33sxkfqwp1axlkrishtgildb` con el
   token de Coolify, o esperar al vigilante) debería completar la cadena entera.

### H1.S1 — Corregir la configuración del recurso

**CA:** Dado `alovida-frontend`, cuando se lee por la API, entonces declara el compose de `deploy/` y tiene `APP_DOMAIN`.
**DoD:** salida del `GET /applications/<uuid>` y de `/envs` pegadas.
**Estado:** HECHO

`docker_compose_location` = `/deploy/docker-compose.coolify.yml` (confirmado por API). `APP_DOMAIN`/`ALOVIDA_NETWORK` cargadas. `docker_compose_domains` asigna el dominio de prueba al servicio `proxy`, forma identica a la de `mockup-frontend` (que si funciona).

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H1.S1.M1 | Apuntar el recurso a `deploy/docker-compose.coolify.yml` | el GET devuelve ese `docker_compose_location` | `GET /applications/<uuid>` | HECHO |
| H1.S1.M2 | Cargar `APP_DOMAIN` con el dominio de prueba | `GET /envs` la lista | `GET /applications/<uuid>/envs` | HECHO |
| H1.S1.M3 | Asignar el dominio al servicio `proxy`, puerto 80 | `docker_compose_domains` lo declara | `GET /applications/<uuid>` | HECHO |

### H1.S2 — Desplegar y comprobar que sirve de verdad

**CA:** Dado el despliegue terminado, cuando se pide `/auth` al dominio público, entonces devuelve 200 y no 400.
**DoD:** código HTTP pegado + estado del recurso.
**Estado:** HECHO

`GET /applications/{front}` -> `running:healthy`. `curl -k https://test.173.249.39.237.sslip.io/auth` -> `200`, HTML real de AloVida (no el 400 que el kill-test original tenía en mente para el caso de `SSR_ALLOWED_HOSTS` ausente, ni el 503 que hubo durante toda la investigación). Ver la evidencia completa en H1 arriba.

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H1.S2.M1 | Disparar el despliegue y esperar a que termine | el recurso queda `running:healthy` | `GET /applications/<uuid>` | HECHO |
| H1.S2.M2 | Pedir `/auth` al dominio público desde fuera | 200, no 400 | `curl -o /dev/null -w '%{http_code}'` | HECHO |

---

## H2 — Un push a `test` reconstruye las dos apps solo

**CA:** Dado un commit nuevo en `test`, cuando pasa el intervalo del vigilante, entonces las dos apps se reconstruyen sin intervención.
**DoD:** diario del vigilante mostrando un despliegue disparado por un commit real.
**Estado:** HECHO

Verificado en runtime, no simulado: se empujó `002bdfdd` a `origin/test` (API) y un
`Monitor` en segundo plano —sin que yo llamara a `curl` ni a `deploy`— capturó la
línea propia del vigilante: `2026-09-26 01:49:05  la rama avanzó a 002bdfdd;
desplegando`. El vigilante corre cada 3 min vía `launchctl` (`bo.alovida.autodeploy-test`,
PID activo), vigilando las dos apps con estado independiente en
`~/.local/state/alovida-autodeploy-test/{front,api}/`.

### H2.S1 — Extender el vigilante a `test` y a las dos apps

**CA:** Dado `--estado`, cuando se corre, entonces informa rama y sha desplegado **por app**.
**DoD:** salida de `--estado` de las dos apps pegada.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H2.S1.M1 | Parametrizar el guion por rama y por app | `AUTODEPLOY_RAMA=test` y un uuid por app funcionan | `vps-autodeploy.sh --estado` | HECHO |
| H2.S1.M2 | Instalar el plist de `test` sin tocar el de `mockup` | `launchctl list` muestra los dos | `launchctl list \| grep alovida` | HECHO |
| H2.S1.M3 | Comprobar con un commit real | el diario anota `DESPLEGADO <sha>` | `tail` del diario | HECHO |

---

## H3 — El modelo y la copia vendorizada de la API dejan de divergir

**CA:** Dado `yarn db:vendor` seguido de `git status database`, cuando se corre, entonces **no borra ningún patch** y el árbol queda limpio.
**DoD:** `db:vendor:check` exit 0 + `git status database` sin líneas `D`.
**Estado:** HECHO

Verificado: `db:vendor:check` -> `=== database/SQL al dia` / `=== database/NoSQL al dia`, exit 0. `git status --short database` tras `db:vendor` ya no tiene ninguna linea `D` -- los 4 patches viejos fueron reemplazados por sus 4 promovidos con nueva numeracion (v4224-v4227), verificado tambien por nombre de archivo. PRs abiertos: mantra-core-health-model#32 y mantra_core_technologies_health_docs#83 (este ultimo, la dependencia de las 22 notas de FK).

### H3.S1 — Promover al modelo los dos módulos que sólo viven en la API

**CA:** Dado el repo del modelo, cuando se regenera con `gen_ddl.py`, entonces `SQL/` contiene el DDL de los módulos 67 y 68 y los cuatro patches.
**DoD:** diff del DDL generado contra el patch existente, pegado.
**Estado:** HECHO

Diff programatico columna por columna (tipo + obligatoriedad) entre el DDL generado y el patch vivo de la API: 0 diferencias en las 8 tablas de data_catalog y 0 en las 4 de qa_execution. Nombres de indice: 15/15 y 6/6 idénticos. Conteo de FK: 27 en data_catalog (14 intra + 13 diferidas) y 14 en qa_execution (3+11), coincidiendo exactamente con los deltas que cada patch declara.

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H3.S1.M1 | `diagram_67_data_catalog.puml` transcribiendo las entidades | el DDL generado coincide con el patch | `diff` del DDL | HECHO |
| H3.S1.M2 | `diagram_68_qa_execution.puml` igual | idem | `diff` del DDL | HECHO |
| H3.S1.M3 | Llevar al modelo los patches de RLS de custodia y `objective_status` | los cuatro están en `SQL/patches/` | `ls SQL/patches` | HECHO |
| H3.S1.M4 | Resolver la colisión de numeración (dos `v4219`, dos `v4220`) | no hay dos patches con la misma versión | `ls SQL/patches` | HECHO |

### H3.S2 — Vendorizar sin pérdida

**CA:** Dado `yarn db:vendor`, cuando se corre, entonces `git status database` no muestra ninguna `D`.
**DoD:** salida de `db:vendor:check` y del `git status` pegadas.
**Estado:** HECHO -- ver evidencia en H3 arriba.

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H3.S2.M1 | Correr `yarn db:vendor` y comprobar que no borra nada | `git status database` sin `D` | `yarn db:vendor && git status --short database` | HECHO |
| H3.S2.M2 | Dejar el árbol del modelo y el de la API coherentes | `yarn db:vendor:check` exit 0 | `yarn db:vendor:check` | HECHO |

---

## H4 — Se sabe qué siembra cada uno de los doce markdown

**CA:** Dada la matriz, cuando se lee, entonces cada archivo tiene su seed, su tabla y su conteo medido.
**DoD:** matriz publicada con las consultas y sus resultados.
**Estado:** HECHO

Matriz en evidencia/H4-matriz-markdown-a-seed.md. 9 de 12 archivos ya llegan a la API (3 mas de lo que decia la verificacion del reparto sin regenerar: clinicas, hospitales 2do/3er nivel y farmacias/laboratorios estaban fusionados en health-facilities.dataset.json con un discriminador tipo, y el arancel odontologico en fee-schedule.dataset.json). Verificado regenerando y diffeando byte a byte contra los 5 .dataset.json comitidos: 0 diferencias en los 5. El hueco real, acotado: los 2 padrones de personas y el directorio de aseguradoras, que si tienen su dataset extraido pero ningun seed lo materializa -- carril de M2 (C1/C2), ahora con menos por descubrir.

### H4.S1 — Medir, no suponer

**CA:** Dado cada uno de los doce archivos, cuando se busca su destino, entonces queda dicho si llega, por qué camino y con cuántas filas.
**DoD:** matriz pegada con la fuente de cada cifra.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H4.S1.M1 | Cruzar los doce archivos contra los seeds que los leen | cada archivo tiene camino o dice «ninguno» | `grep` sobre `src/common/seed` y `tools/bolivia-datasets` | HECHO |
| H4.S1.M2 | Contar filas por archivo y por dataset emitido | cada fila de la matriz tiene su conteo | conteo de filas de los `.md` y de los `.json` | HECHO |

---

## H5 — El recorrido real contra el VPS

**CA:** Dada la suite `*.real.spec.ts` contra el dominio de prueba, cuando corre tres veces sobre el mismo commit, entonces las tres dan verde.
**DoD:** las tres salidas y las fotos de los tres viewports.
**Estado:** A MEDIAS

H1 ya está sano y la suite corrió tres veces reales contra el VPS (front `5717bdb6`, backend
`abe90074`). Resultado **determinístico, no intermitente**: 9/10 en las tres corridas, siempre
el mismo test en rojo por el mismo motivo. No es el "tres verdes" que pedía el CA original —
ese resultado habría sido deshonesto de declarar, así que queda `A MEDIAS` con el detalle
completo en `evidencia/` (front) `docs/progress/evidence/lane-m1-recorrido-real/`.

Dos correcciones de soporte fueron necesarias antes de poder correrla: `crearMedicoSintetico()`
no mandaba `nationalId`/`issuerAdministrativeAreaConceptId` (el alta los volvió obligatorios
después de escrito el helper) y el helper de API no respetaba `E2E_API_URL` (apuntaba a
`localhost:3005` por defecto). Las dos están corregidas y comiteadas.

El único test que sigue en rojo destapó un **`PRODUCT_BUG` real, ajeno a este carril**: el login
por API funciona perfecto dos veces seguidas (curl directo, `200` + tokens reales) para una
cuenta recién creada, pero el mismo login desde el formulario del navegador muestra "Las
credenciales no son válidas" y nunca navega al panel. Es sesión/auth del front (probablemente
relacionado con `refreshCookie` o con el estado `verificationStatus: PENDING` de una cuenta
nueva), no infraestructura ni base de datos — fuera del alcance de M1. Documentado con
evidencia completa y enviado como tarea aparte para quien lleve esa área (`task_f2a52377`).

### H5.S1 — Escribir y correr el recorrido

**CA:** Dado el sitio desplegado, cuando la suite corre, entonces cubre salud de la API por el proxy, login por rol, directorio y páginas públicas en 200.
**DoD:** salida y fotos.
**Estado:** A MEDIAS

Que anda: `playwright/carril-m1-recorrido-real-vps.spec.ts` escrito y corrido tres veces contra
el sitio real; 9 de los 10 casos pasan consistentemente (salud de la API por el proxy, alta y
login de médico y paciente contra la API real, la vitrina pública en 3 viewports × 2 temas con
consola limpia). Que no anda: el caso de sesión real por navegador, por el `PRODUCT_BUG`
documentado arriba; y el DoD pedía fotos por viewport como artefacto, y la suite sólo verifica
consola/red por viewport sin guardar una captura de cada uno (sólo hay captura del fallo). Qué
falta: que se resuelva el bug de sesión (fuera de este carril) y, si hace falta el artefacto
fotográfico por viewport, agregar `page.screenshot()` a esa sección de la suite. Dónde quedó:
comiteado en `justin/test-integration` → `origin/test` (`c8c30949`), con las tres salidas y el
README de hallazgo en `docs/progress/evidence/lane-m1-recorrido-real/` (front).

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H5.S1.M1 | Escribir la suite contra el dominio de prueba | cubre los cuatro puntos | archivo + salida | HECHO |
| H5.S1.M2 | Correrla y sacar foto de cada viewport | 3 viewports × 2 temas | fotos en `evidencia/` | A MEDIAS |
| H5.S1.M3 | Repetirla tres veces sobre el mismo commit | tres verdes seguidos | las tres salidas | A MEDIAS |

---

## H6 — El bucle deja el servidor sano

**CA:** Dadas las dos apps, cuando se cierra el ciclo, entonces quedan `running:healthy` y el recorrido real sigue verde.
**DoD:** estado de las apps + bitácora del bucle.
**Estado:** A MEDIAS

Las dos apps están `running:healthy` y verificadas con datos reales (ver H1). El recorrido
corrió tres veces (ver H5): 9/10 determinístico, con un `PRODUCT_BUG` real de sesión/auth del
front (ajeno a este carril, ya enviado como tarea aparte). No es "el recorrido real sigue
verde" al 100 % — por eso el hito cierra `A MEDIAS`, no `HECHO`, con el detalle honesto en vez
de forzarlo.

### H6.S1 — Cerrar el ciclo merge → build → recorrido → corrección

**CA:** Dado un fallo del recorrido, cuando se clasifica, entonces queda como `PRODUCT_BUG`, `TEST_BUG`, `ENVIRONMENT` o `DATA` con su evidencia.
**DoD:** bitácora con la clasificación de cada fallo.
**Estado:** A MEDIAS

Que anda: los 4 PR originales están mergeados; el fallo de H1 (capas 1–3, quay.io + patch
v4.2.21) está clasificado y corregido; el recorrido corrió de verdad y su único fallo
persistente está clasificado como `PRODUCT_BUG` con causa raíz aislada (ver H5). Que no anda: el
PR espejo `test → dev` no se abrió. Que falta: decidir si conviene abrirlo ya (con el
`PRODUCT_BUG` de sesión todavía sin resolver en `test`) o esperar a que esa tarea aparte lo
cierre primero — es una decisión de secuencia, no una que este carril deba tomar solo.

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H6.S1.M1 | Mergear a `test` lo que llegue de las otras cinco | cada merge dispara build | bitácora | HECHO |
| H6.S1.M2 | Clasificar cada fallo y mandarlo a su dueño | ninguno sin clasificar | tabla de fallos | HECHO |
| H6.S1.M3 | Abrir el PR espejo `test → dev` en los dos repos | los dos abiertos | URLs | BLOQUEADO |

---

## Ambigüedades registradas

| ID | Ambigüedad | Quién puede resolverla | Qué bloquea | Supuesto tomado |
|---|---|---|---|---|
| Q-01 | Qué worktrees se pueden borrar para recuperar disco | el propietario | nada por ahora: hay 3,6 GiB | no se borra ningún worktree ajeno |
| Q-02 | Si el dominio final es `sslip.io` o un subdominio de `alovidasalud.com` | el propietario | nada: es una variable | `test.173.249.39.237.sslip.io`, que él aprobó |
| Q-03 | Si la base del VPS se reinicia desde cero o se migra en caliente | el propietario | H6 si la deriva rompe el recorrido | no se toca la base; sin SSH no es posible igual |
| Q-04 | La llave SSH sigue sin autorizar | el propietario | la inspección directa de la base (H4 parcial, H6 parcial) | se trabaja por la API de Coolify y por HTTP |

## Riesgos y bloqueos previstos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Build de Coolify de 15–30 min | H1 y H6 lentos | se pacea por el build, no por reloj |
| `api-migrate` con `ORM_SCHEMA_SYNC=safe` sobre base vieja | tablas sin sus patches | se documenta; sin SSH no se puede reiniciar el volumen |
| Sin SSH no se puede contar filas en la base del VPS | H4 baja de `VERIFIED` a `TESTED` | la matriz se mide contra los archivos y el código, y se declara |
