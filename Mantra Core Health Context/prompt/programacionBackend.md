# Prompt backend de producción 10/10 — versión consolidada

```yaml
prompt_version: 7.0.0
status: active
last_updated: 2026-07-15
framework: NestJS
language: TypeScript
orm: MikroORM
database: PostgreSQL
```

Este archivo es la versión consolidada del sistema modular. Antes de usarlo, aplicar también las reglas de precedencia y perfiles de `index.md`.

> **Contexto v4.0.1 (obligatorio para marketing/messaging/authz/automation/crm/audit/read_models).**
> El modelo materializó la corrección de *envíos programados · Administración del sitio · tracking* (ver
> `docs/architecture/plan-v4.0.1-scheduled-campaigns-tracking.md` y `patch-v4.0.1-scheduled-campaigns-tracking.md`,
> y `design_patches` en `model-manifest.yaml`). Al generar backend respeta:
> - Solo el rol `SITE_ADMINISTRATION` (MFA) gobierna campañas/envíos; permisos protegidos no delegables (guard + policy + persistencia); nunca vía `user_permission_grants`.
> - Workers persistentes (`campaign-scheduler`, `campaign-audience-snapshot`, `notification-request`, `notification-delivery`, `adapter-event-normalizer`, `delivery-projection`, `delivery-reconciliation`) ejecutan órdenes ya autorizadas; identidad `authz.service_principals` (`SITE_MESSAGING_WORKER`); conservan `authorized_by_user_id` + `authorization_snapshot_json`.
> - Idempotencia por nivel (schedule/dispatch/recipient/request/attempt/inbound/canonical), outbox transaccional (`messaging.outbox_messages`), auditoría WORM (`audit.audit_log`), tracking en 3 capas con transiciones válidas.
> - Fuente única de cron: `marketing.campaign_schedules` (no dupliques con `automation_triggers.schedule_cron`).

---


# 00 — Gobierno, alcance y principios no negociables

## 1. Objetivo

Construir software de producción correcto, seguro, mantenible, observable, escalable y verificable. El resultado debe parecer mantenido por un equipo profesional, no un tutorial.

## 2. Stack backend por defecto

Salvo petición explícita en contrario:

- Node.js LTS compatible con dependencias.
- NestJS con TypeScript estricto.
- MikroORM estable con PostgreSQL.
- Zod para validación de entradas y configuración.
- JWT o proveedor externo según el caso.
- NGINX como capa de entrada en despliegues Docker/enterprise.
- Yarn cuando el proyecto ya use Yarn.

No migrar de framework, ORM o gestor de paquetes sin justificarlo y medir el impacto.

## 3. Principios

Prioridad:

1. Correctitud.
2. Seguridad.
3. Integridad de datos.
4. Claridad.
5. Simplicidad especializada.
6. Mantenibilidad.
7. Observabilidad.
8. Escalabilidad.
9. Rendimiento medido.
10. Reutilización justificada.

## 4. KISS sin fragilidad

- No crear patrones por moda.
- No crear capas sin una responsabilidad real.
- No generalizar una operación usada una sola vez.
- Extraer una abstracción cuando exista repetición semántica, no solo sintáctica.
- Preferir nombres del dominio sobre `Manager`, `Helper`, `Processor` o `Utils` genéricos.
- Las abstracciones compartidas deben reducir complejidad visible y facilitar pruebas.

## 5. Regla de archivos

Todo archivo manual de código debe permanecer por debajo de 300 líneas.

Política:

- Advertencia a partir de 220 líneas.
- Revisión de diseño obligatoria a partir de 260 líneas.
- Prohibición a partir de 300 líneas.

Excepciones permitidas:

- archivos generados;
- migraciones declarativas difíciles de dividir de forma segura;
- catálogos de constantes;
- especificaciones OpenAPI generadas;
- pruebas tabulares extensas.

Toda excepción requiere comentario en el reporte de fase o ADR. El conteo de líneas no sustituye la revisión de cohesión, complejidad ciclomática, dependencias, tamaño de métodos y profundidad de anidamiento.

## 6. Tipado

- `strict: true`.
- Evitar `any`; usar `unknown` y validación.
- Activar cuando sea viable `noUncheckedIndexedAccess` y `exactOptionalPropertyTypes`.
- Los contratos entre capas deben ser explícitos.
- No devolver modelos ORM directamente.

## 7. Librerías

Toda librería relevante debe figurar en `docs/decisions/library-matrix.md` con:

- responsabilidad;
- candidatos;
- versión evaluada;
- compatibilidad;
- seguridad y mantenimiento;
- rendimiento cuando sea relevante;
- licencia;
- alternativa de salida;
- decisión y fuente.

No instalar dos librerías para la misma responsabilidad sin una justificación clara.

## 8. Evidencia

No afirmar “listo para producción”, “compila”, “pasa pruebas” o “es seguro” sin evidencia. Si una prueba no pudo ejecutarse, indicar exactamente cuál y por qué.


---


# 01 — Perfiles, decisiones y selección tecnológica

## 1. Perfil de arquitectura

La arquitectura debe derivarse del riesgo y del volumen, no de una plantilla fija.

### Capacidades siempre obligatorias

- configuración validada;
- migraciones;
- validación de entrada;
- manejo centralizado de errores;
- autenticación y autorización cuando aplique;
- logs estructurados;
- health y readiness adecuados al despliegue;
- pruebas de negocio y e2e críticas;
- documentación de endpoints;
- secretos fuera del código.

### Capacidades condicionales

Se activan por perfil o evidencia:

- Kubernetes;
- read replicas;
- materialized views;
- cache distribuida;
- colas externas;
- PITR;
- WAF;
- tracing distribuido completo;
- archivos de log persistentes;
- documentación LaTeX extensa.

Los requisitos explícitos del usuario activan la capacidad aunque el perfil no la active por defecto.

## 2. HTTP adapter

Elegir una sola opción mediante ADR:

### Express adapter

Usar cuando:

- el proyecto existente ya depende de middleware Express;
- la compatibilidad pesa más que el rendimiento máximo;
- cambiarlo agregaría riesgo sin beneficio medido.

### Fastify adapter

Evaluar para proyectos nuevos de alta carga cuando:

- todas las integraciones sean compatibles;
- exista prueba de rendimiento representativa;
- el equipo pueda mantener los plugins equivalentes.

No usar código `app.use(json())`, tipos Express o middleware Express en un proyecto Fastify. No usar plugins Fastify en un proyecto Express.

## 3. Matriz base de decisiones

La siguiente matriz es un punto de partida, no reemplaza el ADR:

| Responsabilidad | Opción base | Regla |
|---|---|---|
| Framework | NestJS | Obligatorio salvo petición explícita |
| ORM | MikroORM | Unit of Work + `@Version` (row_version) + multi-schema; PostGIS vía tipos custom / SQL crudo del QueryBuilder |
| Validación | Zod | Reutilizar schemas para runtime y tipos |
| Logging | Pino + integración NestJS | Redacción centralizada |
| OpenAPI | `@nestjs/swagger` | Contrato exportable YAML/JSON |
| Health | `@nestjs/terminus` o implementación equivalente | Separar liveness y readiness |
| Métricas | OpenTelemetry + Prometheus compatible | Evitar métricas de alta cardinalidad |
| Pruebas | Jest + Supertest | Agregar k6 para carga |
| Migraciones | MikroORM Migrator | Prohibido `schema:update` / `dropSchema` en producción |
| Colas | Elegir pg-boss o BullMQ mediante ADR | No desplegar ambas por defecto |
| Backup | pgBackRest o pg_dump según perfil | Restauración probada |

## 4. ADR obligatorio

Crear ADR cuando se decida:

- adapter HTTP;
- librería de colas;
- estrategia JWT;
- cache;
- read replicas;
- vistas materializadas;
- formato de logs;
- estrategia de backup;
- orquestación;
- integración externa crítica;
- excepción a una regla normativa.

Usar `templates/adr.md`.

## 5. Compatibilidad y actualización

- Fijar versiones mediante lockfile.
- Respetar engines de Node.
- Revisar notas de migración antes de actualizar majors.
- No adoptar versiones alpha/beta en producción salvo necesidad demostrada y plan de reversión.
- Mantener una política de actualización y vulnerabilidades.


---


# 02 — Arquitectura NestJS, responsabilidades y reutilización

## 1. Organización

Organizar por dominio o feature:

```text
src/
  main.ts
  app.module.ts
  config/
  common/
  database/
  modules/
  workers/
```

Cada módulo puede contener:

```text
<domain>/
  <domain>.module.ts
  <domain>.controller.ts
  <domain>.service.ts
  <domain>.repository.ts
  <domain>.model.ts
  <domain>.schemas.ts
  <domain>.dtos.ts
  <domain>.mapper.ts
  README.md
```

No crear carpetas vacías ni archivos decorativos.

## 2. Capas

### Controller

- transporte HTTP;
- decorators, guards y pipes;
- delegación al caso de uso;
- status y headers;
- sin queries ni reglas complejas.

### Service o caso de uso

- reglas de negocio;
- coordinación transaccional;
- autorización contextual que dependa del dominio;
- eventos y outbox;
- sin objetos HTTP.

### Repository

- persistencia y consultas;
- filtros, locks y opciones de transacción;
- sin reglas HTTP;
- sin decisiones de negocio fuera de invariantes de persistencia.

### Mapper

- transforma modelos a DTOs seguros;
- elimina campos internos o sensibles.

## 3. CRUD Repository reutilizable

Debe existir una capacidad base tipada para CRUD repetitivo, ubicada en `common/persistence`.

Puede ofrecer:

- `findById`;
- `findOne`;
- `exists`;
- `count`;
- `create`;
- `updateById`;
- `deleteById` o `softDeleteById`;
- paginación segura.

Reglas:

- No contener reglas de negocio.
- No aceptar campos de orden o filtros arbitrarios.
- Aceptar `transaction` de forma explícita.
- No exponer el modelo ORM fuera de persistencia.
- No obligar a cada módulo a usar todas sus operaciones.
- Los repositories de dominio agregan métodos específicos.
- Prohibido generar controllers CRUD genéricos.

## 4. Tools compartidas

Usar `common/tools` únicamente para capacidades transversales estables:

```text
common/tools/
  logging/
  tracing/
  security/
  database/
  resilience/
  http/
```

Cada tool debe tener:

- interfaz pequeña;
- implementación reemplazable;
- pruebas;
- README;
- política de errores;
- redacción de datos sensibles cuando aplique.

No mover reglas de negocio a Tools.

## 5. QueryManager sin convertirse en objeto dios

Debe existir un ejecutor de consultas de solo lectura, llamado `ReadQueryManager` o `QueryManager`, con responsabilidad limitada a:

- usar la conexión reader;
- aplicar timeout;
- abrir transacciones read-only cuando corresponda;
- propagar correlation/trace context;
- emitir métricas y logs seguros;
- normalizar errores de infraestructura.

No debe:

- conocer reglas de negocio;
- construir queries dinámicas desde inputs del cliente;
- decidir joins o columnas del dominio;
- reemplazar los repositories;
- ofrecer una API universal que replique MikroORM.

Las consultas viven en `DomainQueryRepository`; el manager solo ejecuta y observa.

## 6. Command y transacciones

Las escrituras usan la conexión writer mediante repositories o un `WriteDatabaseExecutor` limitado. Las transacciones de negocio se inician en el service/caso de uso.

No crear un `CommandManager` genérico si solo duplica MikroORM. Su uso requiere repetición real y una interfaz pequeña.

## 7. Workers

Los workers son procesos persistentes separados del API:

- no dependen de endpoints para activarse;
- manejan `SIGTERM` y `SIGINT`;
- tienen concurrencia configurable;
- usan reintentos limitados y dead-letter strategy cuando corresponda;
- son idempotentes;
- emiten logs, métricas y trazas;
- pueden desplegarse y escalarse por separado.

## 8. Eventos y consistencia

Para cambios que deben publicar eventos:

- escribir mutación y outbox en la misma transacción;
- procesar outbox con worker;
- asumir entrega al menos una vez;
- hacer consumidores idempotentes;
- no afirmar exactamente una vez salvo prueba formal del extremo a extremo.


---


# 03 — PostgreSQL, MikroORM, schemas, roles, seeds y proyecciones

## 1. Base de datos dedicada

La aplicación jamás debe trabajar funcionalmente en la base administrativa `postgres`.

Debe existir una base dedicada por sistema y entorno. El nombre se configura mediante entorno/IaC.

## 2. Prohibición de objetos en `public`

- No crear tablas, secuencias, vistas, materialized views, funciones ni tipos de aplicación en `public`.
- Crear schemas por dominio o responsabilidad.
- Calificar explícitamente los objetos o controlar `search_path` de forma segura.
- Revocar creación en `public` para roles no administrativos.
- No confiar en schemas donde terceros tengan `CREATE` dentro del `search_path`.

Ejemplo conceptual:

```text
identity
catalog
sales
billing
operations
audit
integration
read_models
```

No crear schemas arbitrarios: derivarlos del dominio y documentarlos.

## 3. Roles PostgreSQL

Como mínimo:

### `backend_migrator`

- propietario técnico o rol autorizado para DDL;
- ejecuta migraciones;
- no es usado por el runtime normal.

### `backend_writer`

- conexión de runtime para DML autorizado;
- puede `SELECT`, `INSERT`, `UPDATE`, `DELETE` en objetos requeridos;
- no es superusuario;
- no crea schemas ni tablas;
- no es propietario de objetos.

### `backend_reader`

- conexión de solo lectura;
- `SELECT` únicamente sobre tablas/vistas autorizadas;
- transacciones `READ ONLY` cuando corresponda;
- no puede invocar funciones con efectos laterales.

### `backup_operator`

- permisos mínimos para la estrategia de respaldo;
- separado del runtime.

Los roles remotos se crean mediante IaC, pipeline administrativo o runbook controlado. El backend no crea roles en su arranque.

## 4. Reader y writer

La separación es obligatoria por credenciales incluso si ambos apuntan inicialmente al mismo servidor.

Patrones permitidos:

1. Dos instancias MikroORM con nombres distintos (o configuraciones separadas): recomendado para aislamiento estricto, métricas y permisos claros.
2. Configuración de replicación MikroORM: permitida cuando existe writer y una o más réplicas reales.

Documentar:

- pool por conexión;
- timeouts;
- TLS;
- comportamiento ante replica lag;
- operaciones que requieren `read-your-writes` y deben consultar writer;
- fallback seguro, si existe.

No enviar automáticamente toda lectura al writer cuando la réplica falla sin límites, alertas y ADR.

## 5. Migraciones

Toda estructura se crea mediante migraciones versionadas:

- schemas;
- tablas;
- índices;
- constraints;
- secuencias;
- vistas;
- materialized views;
- grants;
- funciones estrictamente necesarias.

Prohibido en producción:

```text
mikroOrm.getSchemaGenerator().dropSchema()
mikroOrm.getSchemaGenerator().updateSchema()
```

Las migraciones deben ser idempotentes en su operación prevista o fallar claramente cuando detectan drift. “Si existe, continuar” no puede ocultar una estructura incompatible.

## 6. Seeds: exactamente dos catálogos persistentes

### Boot seeds

Datos mínimos para que el sistema opere:

- catálogos base;
- configuraciones iniciales no secretas;
- roles de aplicación;
- permisos funcionales;
- usuario bootstrap solo cuando el caso lo requiera.

Se ejecutan en todos los entornos autorizados, incluida producción.

### Mock seeds

Datos ficticios para desarrollo, QA, demos y pruebas integradas.

- Prohibidos en producción.
- Deben fallar al arrancar si `NODE_ENV=production` o el perfil equivalente.
- Deben usar dominios y datos claramente sintéticos.
- No deben contener datos personales reales.

Fixtures y factories efímeras de unit tests no son seeds y se mantienen separadas.

## 7. Formato de seeds

Los datos de seeds deben residir en JSON y validarse con Zod antes de persistir.

```text
database/seeds/
  boot/
    roles.json
    permissions.json
  mock/
    users.json
    sample-data.json
  schemas/
    boot-seed.schema.ts
    mock-seed.schema.ts
  runners/
    run-boot-seeds.ts
    run-mock-seeds.ts
```

Bajo ningún concepto usar archivos SQL puros como seeds.

Las contraseñas, tokens y secretos no se guardan en JSON. Se inyectan mediante secret manager o se generan temporalmente con rotación obligatoria.

## 8. Idempotencia de seeds

Cada registro debe tener identidad estable:

- código natural inmutable;
- UUID predeterminado estable cuando sea correcto;
- clave compuesta documentada.

Estrategias permitidas:

- `insert if missing`;
- upsert controlado de campos administrados por el seed;
- reconciliación explícita de relaciones;
- versionado del catálogo cuando la evolución lo requiera.

No sobrescribir datos administrados por usuarios sin una política explícita.

Gate obligatorio:

1. ejecutar migraciones sobre base vacía;
2. ejecutar boot seeds;
3. capturar estado lógico;
4. ejecutar boot seeds nuevamente;
5. confirmar mismo estado y sin duplicados;
6. repetir con mock seeds en entorno no productivo;
7. verificar que mock seeds son rechazados en producción.

## 9. Usuarios seed

Los usuarios boot y mock se crean si no existen usando una identidad estable. Deben pasar por el mismo hashing, políticas y reglas de estado que los usuarios reales.

- Usuario mock: marcado como sintético y deshabilitado en producción.
- Usuario bootstrap: secreto fuera del repositorio, cambio obligatorio o activación controlada.
- No registrar credenciales en logs o resultados smoke.

## 10. Vistas y proyecciones PostgreSQL

Crear proyecciones de lectura en un schema como `read_models` cuando reduzcan complejidad, estabilicen contratos o mejoren rendimiento medido.

No asumir que una vista normal es más rápida. Antes de adoptarla evaluar:

- query ORM optimizada;
- índices;
- vista normal;
- materialized view;
- tabla de proyección;
- cache.

Usar `EXPLAIN (ANALYZE, BUFFERS)` en un dataset representativo cuando sea seguro.

### Creación a través del ORM

Interpretar “a través del ORM” como:

- migración administrada por MikroORM Migrator;
- DDL constante y revisado mediante query de MikroORM (como `em.getConnection().execute()`) cuando la API del SchemaGenerator no exponga lo requerido (por ejemplo, `CREATE VIEW`);
- nunca SQL construido desde input del usuario;
- nunca creación de vistas al arrancar la aplicación;
- migración reversible o con estrategia de reemplazo segura.

### Seguridad

- Las vistas de frontend no exponen PII innecesaria.
- `backend_reader` recibe `SELECT` solo en las proyecciones necesarias.
- Modelos/Entidades MikroORM de vistas son read-only (usando la propiedad `readonly` en la definición de la entidad).
- Repositories de vista no ofrecen create/update/delete.

### Materialized views

Documentar:

- criterio de refresco;
- `CONCURRENTLY` y requisitos de índice único cuando aplique;
- tolerancia a desactualización;
- worker o CronJob responsable;
- métricas de edad de datos y fallos.

## 11. Endpoints de proyección

Flujo esperado:

```text
Controller explícito
  -> QueryService
  -> DomainQueryRepository
  -> ReadQueryManager
  -> view/materialized view/query optimizada
```

Los endpoints deben:

- devolver DTOs diseñados para el frontend;
- paginar server-side;
- usar filtros y sort con whitelist;
- limitar payloads;
- versionar contratos;
- no aceptar SQL, nombres de tabla, columnas o joins desde el cliente.

## 12. Modelo de datos documentado

Todo cambio relevante genera:

```text
docs/data-model/data-model.tex
docs/data-model/domain-model-by-schema.puml
docs/data-model/relational-model-by-schema.puml
docs/data-model/views-and-projections.puml
docs/data-model/schemas/<schema>.puml
```

El `.tex` explica cada schema, tabla, columna, relación, constraint, índice y vista a nivel de negocio y técnico. Debe compilar y los `.puml` deben renderizar.


---


# 04 — API, validación, autenticación y seguridad

## 1. Versionado y contratos

- Versionar la API desde el inicio.
- Usar una sola estrategia de versionado.
- No romper contratos sin nueva versión o plan de compatibilidad.
- OpenAPI es la fuente contractual principal.
- `endpoints.md` complementa con responsabilidad, flujo y decisiones; no duplica mecánicamente todo OpenAPI.

## 2. Validación

Validar con Zod:

- body;
- params;
- query;
- headers relevantes;
- cookies;
- variables de entorno;
- webhooks;
- respuestas externas críticas;
- mensajes de workers.

Los controllers reciben datos ya validados. Usar whitelist para filtros, includes y ordenamiento.

## 3. Autenticación default-deny

Cuando exista autenticación:

- aplicar guard global default-deny;
- marcar endpoints públicos con decorator explícito;
- separar autenticación de autorización;
- token vencido o inválido produce 401;
- usuario autenticado sin permiso produce 403;
- validar actor, estado de cuenta y versión/revocación cuando corresponda.

## 4. JWT

Elegir mediante ADR:

### Bearer

Adecuado para móviles, integraciones y clientes no browser.

### Cookie httpOnly

Adecuado para web bajo control de navegador. Requiere CSRF, CORS con credenciales y atributos seguros.

Reglas comunes:

- access tokens cortos;
- refresh tokens rotados y revocables si se usan;
- detección de reutilización;
- payload mínimo;
- `issuer` y `audience` cuando correspondan;
- algoritmo permitido explícito;
- rotación de claves y `kid` para sistemas críticos;
- nunca tokens en query params o logs.

## 5. Contraseñas

- Argon2id o alternativa aprobada por ADR.
- Políticas de coste configurables.
- No revelar si falló email o contraseña.
- Rate limit específico para login, recuperación, MFA y PIN.
- Bloqueo o backoff controlado ante abuso.

## 6. Autorización

- RBAC para roles generales.
- Políticas o autorización basada en atributos cuando el dominio lo requiera.
- Validar tenant/ownership en la capa correcta.
- No confiar en IDs enviados por el cliente para determinar propiedad.
- Pruebas negativas obligatorias.

## 7. Seguridad HTTP

- Helmet o equivalentes del adapter.
- CORS restrictivo.
- límite de body y archivos;
- timeouts;
- rate limits globales y por endpoint sensible;
- sanitización contextual;
- protección CSRF cuando corresponda;
- validación de content type;
- no exponer stack traces;
- errores consistentes.

## 8. Idempotencia

Para comandos reintentables o de impacto financiero/operativo:

- idempotency key con scope de actor, endpoint y tenant;
- fingerprint criptográfico sobre payload validado completo;
- redacción solo para almacenamiento/log, no antes de calcular el fingerprint;
- claim atómico mediante constraint/lock/conditional update;
- estados `in_progress`, `completed`, `failed` con TTL y política clara;
- replay seguro de la respuesta;
- pruebas concurrentes.

## 9. Integraciones externas

Encapsular en adapters con:

- timeout;
- retry solo para fallos transitorios e idempotentes;
- jitter;
- circuit breaker cuando el riesgo lo justifique;
- rate limit;
- validación de respuesta;
- trazas y métricas;
- redacción de secretos;
- simuladores/mocks para pruebas.

## 10. Datos sensibles

Clasificar datos y definir:

- minimización;
- cifrado en tránsito y reposo;
- cifrado de campo cuando aplique;
- retención y borrado;
- masking en respuestas;
- redacción en logs;
- permisos de acceso;
- auditoría de operaciones críticas.


---


# 05 — Observabilidad, logging, resiliencia y escalabilidad

## 1. Logger único reutilizable

Todas las capas acceden al logging mediante una abstracción compartida basada en Pino o la librería elegida por ADR.

No se permite:

- `console.log` en runtime productivo;
- instancias de logger creadas arbitrariamente;
- logging manual de tokens, passwords, cookies o payloads sensibles.

El logger debe soportar:

- nivel por entorno;
- redacción centralizada;
- correlation ID;
- trace/span ID;
- módulo/componente;
- evento estable;
- error estructurado;
- tenant/actor solo cuando sea seguro;
- child logger por contexto.

## 2. Salidas de log

### Siempre

- salida estructurada a stdout/stderr para compatibilidad con contenedores.

### Cuando `log_output_mode=stdout_and_file`

- escribir además a archivo `.log` persistente;
- volumen dedicado;
- rotación por tamaño/fecha;
- retención y compresión;
- límites de disco;
- permisos mínimos;
- estrategia de recolección;
- prueba de reinicio y persistencia.

En Kubernetes no escribir en el filesystem efímero del contenedor. Montar un volumen o usar un agente/sidecar aprobado. Evitar que el proceso de aplicación bloquee por I/O de archivo; usar transport seguro y backpressure controlado.

## 3. Trazas

Usar OpenTelemetry cuando el perfil sea enterprise, high-load o regulated:

- instrumentar HTTP, PostgreSQL, Redis, colas e integraciones;
- propagar contexto entre API y workers;
- sampling configurable;
- no adjuntar PII;
- exportación OTLP configurable.

## 4. Métricas

Como mínimo:

- requests por ruta normalizada, método y status;
- latencia p50/p95/p99;
- errores;
- conexiones y espera de pool;
- queries lentas;
- lag de réplica si existe;
- tamaño/edad de colas;
- reintentos y dead letters;
- outbox pendiente;
- edad de materialized views;
- backup exitoso/fallido;
- uso de CPU/memoria;
- event loop lag.

Evitar etiquetas de alta cardinalidad como user ID, URL sin normalizar o mensaje de error completo.

## 5. Health

Separar:

- `/health`: liveness, debe responder si el proceso está vivo;
- `/ready`: readiness, retorna no exitoso si dependencias críticas impiden servir tráfico;
- startup probe en Kubernetes si el arranque puede tardar.

No devolver 200 cuando la readiness falla.

## 6. SLO

Definir al menos:

- disponibilidad;
- latencia;
- tasa de errores;
- frescura de jobs/proyecciones;
- RPO/RTO.

Crear alertas accionables y runbooks. No alertar por cada error aislado sin contexto.

## 7. Escalabilidad

- API stateless;
- sesiones y locks fuera de memoria local cuando deban compartirse;
- pool calculado considerando número máximo de réplicas;
- paginación y límites;
- evitar N+1;
- bulk con límites y resultados parciales explícitos;
- streaming para cargas grandes cuando corresponda;
- cache solo con estrategia de invalidación;
- compresión solo donde tenga beneficio;
- workers escalables de forma independiente.

## 8. Rendimiento medido

No optimizar por intuición. Mantener:

- baseline;
- dataset representativo;
- pruebas de carga;
- perfiles de latencia y throughput;
- query plans;
- presupuesto de rendimiento;
- comparación antes/después.

## 9. Resiliencia

- timeouts en toda llamada de red;
- retries limitados y con jitter;
- no reintentar errores de validación o negocio;
- idempotencia antes de retry de escritura;
- circuit breaker cuando el proveedor pueda degradar el sistema;
- graceful shutdown;
- backpressure;
- límites de concurrencia.


---


# 06 — NGINX, Docker, Kubernetes, AWS y backups

## 1. NGINX como entrada

En despliegues Docker/enterprise, NGINX es el único servicio que publica puertos hacia el exterior.

Funciones:

- terminación TLS o integración con el terminador TLS;
- reverse proxy;
- headers de forwarding;
- límites de request;
- timeouts;
- rate limiting complementario;
- buffering configurado según streaming o respuestas normales;
- logs de acceso estructurados;
- health del upstream.

La aplicación, PostgreSQL, Redis y workers no publican puertos al host.

## 2. Docker

Entregar:

- Dockerfile multi-stage;
- usuario no root;
- imagen mínima y fijada;
- `HEALTHCHECK` cuando sea útil;
- init adecuado o manejo correcto de señales;
- filesystem read-only salvo mounts necesarios;
- límites de recursos en Compose cuando aplique;
- secrets fuera de la imagen;
- `.dockerignore`;
- SBOM y escaneo en CI para perfiles críticos.

## 3. Redes Docker

Topología base:

```text
Internet
  -> NGINX (único puerto publicado 80/443)
      -> red interna app
          -> API
          -> workers
          -> Redis
          -> PostgreSQL
```

- Usar redes internas.
- No usar `network_mode: host`.
- No publicar `5432`, `6379` ni puerto de API.
- Para bases administradas remotas, usar red privada/security groups, TLS y allowlist.

## 4. Persistencia

Volúmenes separados para:

- PostgreSQL local, si se usa;
- logs persistentes cuando el modo lo exige;
- backups;
- datos de servicios que realmente lo requieran.

Documentar ownership, permisos, retención y restauración.

## 5. Kubernetes separado

Mantener orquestación separada de Docker Compose:

```text
infra/k8s/
  chart/
  environments/
    dev/
    staging/
    prod/
```

Usar Helm o Kustomize mediante ADR. No mezclar valores secretos en Git.

## 6. Entrada Kubernetes

NGINX debe mantenerse como única entrada pública mediante una de estas opciones:

- NGINX Ingress Controller;
- NGINX Gateway Fabric/Gateway API cuando la plataforma lo soporte y se documente.

Los servicios de aplicación son `ClusterIP`. No usar `NodePort` o `LoadBalancer` directamente para API/worker.

No desplegar un NGINX adicional dentro de cada Pod salvo necesidad demostrada.

## 7. Seguridad Kubernetes

- namespace por entorno;
- NetworkPolicy default-deny;
- permitir tráfico solo desde NGINX a API y desde workloads a dependencias necesarias;
- Pod Security `restricted`;
- `runAsNonRoot`;
- `allowPrivilegeEscalation: false`;
- seccomp RuntimeDefault;
- capabilities eliminadas;
- root filesystem read-only cuando sea viable;
- requests/limits;
- service accounts mínimos;
- secrets mediante AWS Secrets Manager/External Secrets o mecanismo equivalente;
- no montar token de service account si no es necesario.

## 8. Disponibilidad

Según perfil:

- Deployment separado para API y cada clase de worker;
- HPA basado en métricas adecuadas;
- PDB;
- topology spread/anti-affinity;
- readiness/liveness/startup probes;
- rolling updates;
- preStop y terminationGracePeriod;
- Job separado para migraciones.

## 9. AWS EKS

Preparar valores y documentación para:

- EKS;
- ECR;
- RDS PostgreSQL en subred privada;
- ElastiCache si aplica;
- IAM Roles for Service Accounts o EKS Pod Identity;
- Secrets Manager/KMS;
- S3 para backups;
- CloudWatch/OTel collector o stack elegido;
- WAF/Shield solo si el riesgo lo justifica.

No incluir credenciales AWS estáticas.

## 10. Backups configurables

Variables mínimas:

```text
BACKUP_ENABLED
BACKUP_SCHEDULE
BACKUP_TIMEZONE
BACKUP_STRATEGY
BACKUP_RETENTION_DAYS
BACKUP_DESTINATION
BACKUP_ENCRYPTION_ENABLED
BACKUP_COMPRESSION
BACKUP_MAX_DURATION_SECONDS
RESTORE_TEST_SCHEDULE
```

Estrategias:

- `pg_dump` para sistemas pequeños o export lógico;
- pgBackRest para perfiles enterprise/regulated y PITR;
- snapshot administrado como complemento, no única garantía, cuando corresponda.

## 11. Cron

- Docker: contenedor/servicio de backup separado, no cron dentro del proceso API.
- Kubernetes: `CronJob` separado con `concurrencyPolicy: Forbid`, deadlines, recursos, historial limitado y alertas.
- AWS: se puede delegar a servicios administrados mediante ADR.

## 12. Restore es obligatorio

Un backup no se considera válido hasta demostrar restauración:

- entorno aislado;
- checksum;
- descifrado;
- migraciones compatibles;
- smoke read-only;
- medición RPO/RTO;
- reporte de restore drill.


---


# 07 — Pruebas, calidad, CI/CD y seguridad de supply chain

## 1. Pirámide de pruebas

### Unitarias

- reglas de negocio;
- validadores;
- mappers;
- policies;
- utilidades puras.

### Integración

- repositories contra PostgreSQL real efímero;
- migraciones;
- grants reader/writer;
- seeds;
- outbox;
- vistas.

### E2E

- flujos críticos;
- auth y permisos;
- errores;
- idempotencia;
- paginación;
- contratos.

### Smoke

- health y readiness;
- login mock solo en entornos permitidos;
- endpoint protegido;
- operación mínima de lectura/escritura;
- worker o outbox si aplica.

### Carga y resiliencia

Para high-load/regulated:

- k6 u otra herramienta aprobada;
- concurrencia;
- pool exhaustion;
- retry storms;
- caída de dependencias;
- graceful shutdown;
- recovery.

## 2. Datos de prueba

- Nunca datos sensibles reales.
- Usar factories, fixtures y mock seeds sintéticos.
- No imprimir credenciales.
- Resultados smoke deben redactar tokens, cookies y PII.

## 3. `.gitignore`

Incluir como mínimo:

```gitignore
# Resultados generados
**/smoke-results*.json
**/stress-results*.json
**/load-results*.json
**/audit-results*.json
artifacts/smoke/
artifacts/stress/
artifacts/load/

# Logs
*.log
logs/

# Backups
backups/
*.dump
*.backup
*.sql.gz

# Secretos
.env
.env.*
!.env.example
```

Los reportes que deban conservarse como evidencia se publican como artefactos de CI, no se versionan automáticamente.

## 4. CI mínimo

Orden recomendado:

1. instalar con lockfile congelado;
2. verificar formato;
3. lint con type-aware rules cuando sea viable;
4. type-check sin `warnOnly`;
5. unit tests;
6. integration tests con PostgreSQL/Redis reales;
7. migración desde base vacía;
8. boot seeds dos veces;
9. mock seeds dos veces en dev/test;
10. confirmar rechazo mock en prod;
11. pruebas de privilegios reader/writer/migrator;
12. build;
13. e2e y smoke;
14. generar y validar OpenAPI;
15. escaneo de dependencias, secretos e imagen;
16. Helm/Kubernetes validation cuando aplique.

## 5. Cobertura

No usar cobertura como única métrica. Umbrales base sugeridos:

- líneas/statements: 80%;
- funciones: 75%;
- branches: 70%;
- módulos críticos: umbral más alto definido por riesgo.

No excluir código difícil solo para mejorar el porcentaje.

## 6. Quality gates

Bloquean merge:

- errores TypeScript;
- lint errors;
- tests fallidos;
- migraciones inválidas;
- drift de OpenAPI;
- seeds no idempotentes;
- permisos excesivos;
- secretos detectados;
- vulnerabilidades críticas sin excepción aprobada;
- archivo manual >300 líneas sin excepción;
- imagen ejecutándose como root;
- manifest sin recursos/probes en producción.

## 7. Supply chain

Según perfil:

- lockfile;
- dependency review;
- secret scanning;
- SAST;
- image scan;
- SBOM;
- firma/provenance de imagen;
- dependabot/renovate con política;
- branch protection y revisión obligatoria;
- CODEOWNERS reales.

## 8. Commits y releases

- mensajes semánticos o convención acordada;
- PRs pequeñas y revisables;
- changelog;
- versionado;
- rollback documentado;
- no hacer cambios masivos sin fase ni evidencia.


---


# 08 — Documentación, OpenAPI, LaTeX y entregables

## 1. Fuente de verdad

- Código y migraciones: comportamiento ejecutable.
- OpenAPI: contrato HTTP principal.
- `endpoints.md`: intención, flujo, permisos, errores y archivos relacionados.
- PlantUML: relaciones y arquitectura.
- ADR: decisiones y trade-offs.
- LaTeX: explicación profesional y didáctica del modelo de datos o auditoría.

Evitar duplicación literal. Automatizar validaciones de drift.

## 2. OpenAPI obligatoria

Generar adicionalmente a `endpoints.md`:

```text
docs/endpoints/openapi.yaml
```

Debe incluir:

- paths reales;
- parámetros;
- request/response schemas;
- seguridad;
- errores;
- ejemplos sintéticos;
- versionado;
- tags.

Gate:

- exportar desde NestJS;
- validar sintaxis;
- comparar cambios;
- ejecutar contract test o lint;
- no exponer Swagger UI en producción salvo decisión explícita y controlada.

## 3. `endpoints.md`

Por endpoint documentar:

- responsabilidad;
- autenticación y autorización;
- validaciones;
- request resumido;
- response resumida;
- errores de negocio;
- flujo interno;
- transacción/idempotencia;
- rate limit;
- archivos relacionados;
- enlace al operationId OpenAPI.

## 4. Documentación por carpeta

README solo en carpetas donde aporte orientación real. No crear README repetitivo por cada subcarpeta trivial.

Debe explicar:

- responsabilidad;
- archivos principales;
- dependencias permitidas;
- qué no debe colocarse allí;
- flujo y ejemplos cuando sean útiles.

## 5. Modelo de datos LaTeX y PlantUML

Usar la plantilla `templates/data-model-tex-guidelines.md`.

El `.tex` debe:

- tener portada, índice y numeración;
- compilar sin errores;
- agrupar por schemas;
- explicar cada tabla y columna a nivel de negocio y sistema;
- describir PK, FK, nullability, defaults, constraints, índices, auditoría, sensibilidad y lifecycle;
- explicar vistas y materialized views;
- referenciar los `.puml` correspondientes;
- incluir glosario y nota didáctica.

Los `.puml` deben estar listos para copiar, renderizar y mantener.

## 6. Técnica Feynman adaptada

El tema ya es conocido: el modelo del sistema. No preguntar al usuario cuál es el tema si ya fue proporcionado.

Aplicar una explicación por capas:

1. analogía simple;
2. explicación de negocio;
3. explicación técnica;
4. puntos frecuentes de confusión;
5. escenario de uso;
6. nota didáctica memorable.

El proceso interactivo de preguntas solo se usa cuando el usuario está estudiando y pide tutoría, no durante una generación automática de documentación.

## 7. Progress report

Actualizar por fase:

```text
docs/progress/progress-report.md
```

Debe contener:

- fase X de N;
- avances verificables;
- archivos creados/modificados;
- pruebas ejecutadas;
- riesgos;
- decisiones;
- desviaciones;
- bloqueos;
- fases restantes;
- próximo gate.

## 8. Evidencias

Guardar resultados como artefactos CI o en una carpeta ignorada:

```text
artifacts/
  smoke/
  tests/
  coverage/
  load/
  security/
  restore/
```

No versionar automáticamente JSON de smoke/stress.

## 9. Entrega final

Cuando el alcance sea un proyecto:

- ZIP limpio;
- código;
- migraciones;
- seeds JSON;
- OpenAPI;
- endpoints.md;
- ADRs;
- PlantUML;
- `.tex` y PDF si se solicitó;
- Docker;
- Kubernetes separado;
- `.env.example` sin secretos;
- reportes y comandos de reproducción.


---


# 09 — Protocolo obligatorio de implementación por fases

## 1. Regla principal

No intentar hacer todo en una sola ejecución cuando el alcance contenga múltiples dominios, infraestructura, seguridad, migraciones o integración frontend.

Antes de modificar archivos, crear:

```text
docs/implementation/implementation-plan.md
```

## 2. Cabecera obligatoria

Cada fase comunica:

```text
Fase actual: X de N
Fases completadas: X - 1
Fases restantes: N - X
Objetivo de esta fase: ...
Entradas verificadas: ...
Gate de entrada: aprobado | bloqueado
Gate de salida: pendiente | aprobado | rechazado
```

## 3. Fases base

Adaptar el número al proyecto, manteniendo dependencias claras.

1. Descubrimiento, fuentes y contradicciones.
2. Arquitectura, perfiles, ADRs y amenazas.
3. Modelo de datos, schemas, roles y migraciones.
4. Boot/mock seeds y datos de prueba.
5. Persistencia, repositories, queries y transacciones.
6. Casos de uso y reglas de negocio.
7. API, auth, permisos y OpenAPI.
8. Workers, outbox e integraciones.
9. Observabilidad y rendimiento.
10. Docker, NGINX y seguridad de red.
11. Kubernetes/AWS/backups cuando estén activos.
12. Pruebas completas, documentación, auditoría y empaquetado.

Un proyecto pequeño puede combinar fases; uno grande puede subdividirlas.

## 4. Gate de fase

Una fase se cierra solo cuando:

- el alcance de la fase está completo;
- build/type-check/lint relacionados pasan;
- pruebas relevantes pasan;
- documentación se actualiza;
- riesgos pendientes están declarados;
- no se ocultan fallos;
- el reporte de progreso indica evidencia.

## 5. Cambios de alcance

Cuando aparezca un requisito nuevo:

- evaluar impacto;
- actualizar N si cambia el número de fases;
- indicar cuántas fases se agregaron o reordenaron;
- no declarar el proyecto terminado con fases nuevas pendientes.

## 6. Trabajo paralelo

Solo ejecutar fases en paralelo cuando no compartan archivos críticos, migraciones o contratos. Documentar dependencias y mecanismo de integración.

## 7. No prometer trabajo futuro

En cada entrega realizar todo lo posible en la fase actual. No afirmar que una prueba se hará luego sin dejar claro que el gate permanece abierto.


---


# 10 — Definición objetiva de calidad 10/10

Un proyecto solo puede calificarse 10/10 cuando cumple todos los gates activos para su perfil.

## 1. Arquitectura

- módulos cohesionados;
- controllers delgados;
- reglas en services/casos de uso;
- repositories separados;
- Tools transversales, no de negocio;
- ningún archivo manual >300 líneas sin excepción;
- sin dependencias circulares injustificadas;
- sin controller genérico.

## 2. Datos

- base dedicada, no `postgres`;
- sin objetos de aplicación en `public`;
- schemas documentados;
- roles migrator/writer/reader separados;
- permisos probados;
- migraciones desde cero y actualización incremental probadas;
- seeds boot/mock JSON e idempotentes;
- mock bloqueado en producción;
- índices y queries medidos;
- vistas/proyecciones justificadas.

## 3. Seguridad

- secretos fuera del repositorio;
- auth default-deny;
- permisos negativos probados;
- rate limits sensibles;
- idempotencia concurrente donde aplica;
- PII minimizada y redactada;
- dependencias e imagen escaneadas;
- amenaza y riesgos documentados.

## 4. Observabilidad

- logger único en todas las capas;
- stdout estructurado;
- archivo persistente cuando el perfil lo exige;
- trazas y métricas activas según perfil;
- health/readiness correctos;
- SLO y alertas con runbooks;
- ningún secreto en logs.

## 5. Operación

- NGINX única entrada pública en topología aplicable;
- Docker no root y redes internas;
- Kubernetes separado y validado cuando está activo;
- workers separados;
- backups programados;
- restore drill aprobado;
- graceful shutdown.

## 6. Calidad

- install reproducible;
- format, lint, type-check, test y build pasan;
- integración con PostgreSQL real;
- e2e y smoke pasan;
- OpenAPI válida y sin drift;
- pruebas de carga activas pasan sus objetivos;
- CI bloquea regresiones;
- resultados y comandos documentados.

## 7. Documentación

- architecture y flows actualizados;
- endpoints.md y OpenAPI coherentes;
- ADRs de decisiones relevantes;
- progress report final;
- modelo `.tex`/PlantUML cuando corresponde;
- runbooks de despliegue, rollback, backup y restore.

## 8. Calificación

No usar “10/10” como elogio subjetivo. Incluir una matriz:

| Área | Gate | Evidencia | Estado |
|---|---|---|---|
| Arquitectura | ... | ... | Pass/Fail |

Un solo gate crítico fallido impide la calificación 10/10. Puede entregarse como parcial, pero debe declararse.


---


## Plantillas obligatorias de referencia

- `templates/adr.md`
- `templates/phase-report.md`
- `templates/endpoint-template.md`
- `templates/data-model-tex-guidelines.md`
