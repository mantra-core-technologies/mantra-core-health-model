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
**Estado:** TODO

### H1.S1 — Corregir la configuración del recurso

**CA:** Dado `alovida-frontend`, cuando se lee por la API, entonces declara el compose de `deploy/` y tiene `APP_DOMAIN`.
**DoD:** salida del `GET /applications/<uuid>` y de `/envs` pegadas.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H1.S1.M1 | Apuntar el recurso a `deploy/docker-compose.coolify.yml` | el GET devuelve ese `docker_compose_location` | `GET /applications/<uuid>` | TODO |
| H1.S1.M2 | Cargar `APP_DOMAIN` con el dominio de prueba | `GET /envs` la lista | `GET /applications/<uuid>/envs` | TODO |
| H1.S1.M3 | Asignar el dominio al servicio `proxy`, puerto 80 | `docker_compose_domains` lo declara | `GET /applications/<uuid>` | TODO |

### H1.S2 — Desplegar y comprobar que sirve de verdad

**CA:** Dado el despliegue terminado, cuando se pide `/auth` al dominio público, entonces devuelve 200 y no 400.
**DoD:** código HTTP pegado + estado del recurso.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H1.S2.M1 | Disparar el despliegue y esperar a que termine | el recurso queda `running:healthy` | `GET /applications/<uuid>` | TODO |
| H1.S2.M2 | Pedir `/auth` al dominio público desde fuera | 200, no 400 | `curl -o /dev/null -w '%{http_code}'` | TODO |

---

## H2 — Un push a `test` reconstruye las dos apps solo

**CA:** Dado un commit nuevo en `test`, cuando pasa el intervalo del vigilante, entonces las dos apps se reconstruyen sin intervención.
**DoD:** diario del vigilante mostrando un despliegue disparado por un commit real.
**Estado:** TODO

### H2.S1 — Extender el vigilante a `test` y a las dos apps

**CA:** Dado `--estado`, cuando se corre, entonces informa rama y sha desplegado **por app**.
**DoD:** salida de `--estado` de las dos apps pegada.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H2.S1.M1 | Parametrizar el guion por rama y por app | `AUTODEPLOY_RAMA=test` y un uuid por app funcionan | `vps-autodeploy.sh --estado` | TODO |
| H2.S1.M2 | Instalar el plist de `test` sin tocar el de `mockup` | `launchctl list` muestra los dos | `launchctl list \| grep alovida` | TODO |
| H2.S1.M3 | Comprobar con un commit real | el diario anota `DESPLEGADO <sha>` | `tail` del diario | TODO |

---

## H3 — El modelo y la copia vendorizada de la API dejan de divergir

**CA:** Dado `yarn db:vendor` seguido de `git status database`, cuando se corre, entonces **no borra ningún patch** y el árbol queda limpio.
**DoD:** `db:vendor:check` exit 0 + `git status database` sin líneas `D`.
**Estado:** TODO

### H3.S1 — Promover al modelo los dos módulos que sólo viven en la API

**CA:** Dado el repo del modelo, cuando se regenera con `gen_ddl.py`, entonces `SQL/` contiene el DDL de los módulos 67 y 68 y los cuatro patches.
**DoD:** diff del DDL generado contra el patch existente, pegado.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H3.S1.M1 | `diagram_67_data_catalog.puml` transcribiendo las entidades | el DDL generado coincide con el patch | `diff` del DDL | TODO |
| H3.S1.M2 | `diagram_68_qa_execution.puml` igual | idem | `diff` del DDL | TODO |
| H3.S1.M3 | Llevar al modelo los patches de RLS de custodia y `objective_status` | los cuatro están en `SQL/patches/` | `ls SQL/patches` | TODO |
| H3.S1.M4 | Resolver la colisión de numeración (dos `v4219`, dos `v4220`) | no hay dos patches con la misma versión | `ls SQL/patches` | TODO |

### H3.S2 — Vendorizar sin pérdida

**CA:** Dado `yarn db:vendor`, cuando se corre, entonces `git status database` no muestra ninguna `D`.
**DoD:** salida de `db:vendor:check` y del `git status` pegadas.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H3.S2.M1 | Correr `yarn db:vendor` y comprobar que no borra nada | `git status database` sin `D` | `yarn db:vendor && git status --short database` | TODO |
| H3.S2.M2 | Dejar el árbol del modelo y el de la API coherentes | `yarn db:vendor:check` exit 0 | `yarn db:vendor:check` | TODO |

---

## H4 — Se sabe qué siembra cada uno de los doce markdown

**CA:** Dada la matriz, cuando se lee, entonces cada archivo tiene su seed, su tabla y su conteo medido.
**DoD:** matriz publicada con las consultas y sus resultados.
**Estado:** TODO

### H4.S1 — Medir, no suponer

**CA:** Dado cada uno de los doce archivos, cuando se busca su destino, entonces queda dicho si llega, por qué camino y con cuántas filas.
**DoD:** matriz pegada con la fuente de cada cifra.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H4.S1.M1 | Cruzar los doce archivos contra los seeds que los leen | cada archivo tiene camino o dice «ninguno» | `grep` sobre `src/common/seed` y `tools/bolivia-datasets` | TODO |
| H4.S1.M2 | Contar filas por archivo y por dataset emitido | cada fila de la matriz tiene su conteo | conteo de filas de los `.md` y de los `.json` | TODO |

---

## H5 — El recorrido real contra el VPS

**CA:** Dada la suite `*.real.spec.ts` contra el dominio de prueba, cuando corre tres veces sobre el mismo commit, entonces las tres dan verde.
**DoD:** las tres salidas y las fotos de los tres viewports.
**Estado:** TODO

### H5.S1 — Escribir y correr el recorrido

**CA:** Dado el sitio desplegado, cuando la suite corre, entonces cubre salud de la API por el proxy, login por rol, directorio y páginas públicas en 200.
**DoD:** salida y fotos.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H5.S1.M1 | Escribir la suite contra el dominio de prueba | cubre los cuatro puntos | archivo + salida | TODO |
| H5.S1.M2 | Correrla y sacar foto de cada viewport | 3 viewports × 2 temas | fotos en `evidencia/` | TODO |
| H5.S1.M3 | Repetirla tres veces sobre el mismo commit | tres verdes seguidos | las tres salidas | TODO |

---

## H6 — El bucle deja el servidor sano

**CA:** Dadas las dos apps, cuando se cierra el ciclo, entonces quedan `running:healthy` y el recorrido real sigue verde.
**DoD:** estado de las apps + bitácora del bucle.
**Estado:** TODO

### H6.S1 — Cerrar el ciclo merge → build → recorrido → corrección

**CA:** Dado un fallo del recorrido, cuando se clasifica, entonces queda como `PRODUCT_BUG`, `TEST_BUG`, `ENVIRONMENT` o `DATA` con su evidencia.
**DoD:** bitácora con la clasificación de cada fallo.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD (comando) | Estado |
|---|---|---|---|---|
| H6.S1.M1 | Mergear a `test` lo que llegue de las otras cinco | cada merge dispara build | bitácora | TODO |
| H6.S1.M2 | Clasificar cada fallo y mandarlo a su dueño | ninguno sin clasificar | tabla de fallos | TODO |
| H6.S1.M3 | Abrir el PR espejo `test → dev` en los dos repos | los dos abiertos | URLs | TODO |

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
