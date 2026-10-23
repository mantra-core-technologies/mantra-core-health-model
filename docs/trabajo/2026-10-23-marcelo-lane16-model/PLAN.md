# Plan — Carril 16 · Fase 1: vínculo canónico factura ↔ reclamo (modelo PUML → DDL → MikroORM → Postgres real)

- Fecha: 2026-10-23 · Repos afectados: `mantra-core-health-model` (principal), `mantra-core-health-api`, `mantra_core_technologies_health_docs` (vault) · Predecesor: PR API #671 (corte 1, cálculo de cobertura; no se toca)
- Resultado observable: en Postgres, una línea de factura al paciente puede apuntar a **una** línea de reclamo (`invoice_lines.insurance_claim_line_id`, única), y `billing_document_links.claim_id` / `reimbursements.claim_id` son FKs reales hacia `insurance.insurance_claims`. Un segundo cobro de la misma línea de reclamo falla en la base (23505); un reclamo inexistente falla (23503).
- Kill-test: `grep -c "FK sin destino canónico" SQL/17_billing/90_fk_deferred.sql` sigue listando `claim_id` → NO está hecho. O: insertar dos `invoice_lines` con el mismo `insurance_claim_line_id` y que ambas entren.

## Contexto

REQ-16-028/029 (protección del paciente) exigen que la factura al paciente quede **vinculada obligatoriamente** a la línea del reclamo y que una línea de reclamo se facture **una sola vez, garantizado en base**. Hoy (verificado en `origin/dev` de ambos repos):

- `billing.invoices` / `invoice_lines` no tienen ninguna columna de reclamo.
- `billing_document_links.claim_id` y `reimbursements.claim_id` figuran como «FK sin destino canónico» en `SQL/17_billing/90_fk_deferred.sql:5-8`: no se emite constraint. Causa: el stub `entity insurance_claims <<REFERENCE_ONLY>>` (`diagram_17_billing.puml:256-258`) no está calificado y la arista `:363` no lleva etiqueta de columna, así que `gen_ddl.resolve_fk_from_diagram` no la ve; la nota del vault dice «Destino no resuelto»; y por convención `claim_id` busca una tabla `claims` que no existe.
- La entidad `billing_document_links.entity.ts:54` dice `// FK (destino no resuelto)`; `src/orm/catalog/foreign-keys/billing.fk.ts` no tiene la FK.

Camino oficial (`Mantra Core Health Context/docs/architecture/ddl-sources.md` §«Cómo se agrega una tabla», ADR-0021/0022): `.puml` → nota en el vault → `gen_ddl.py` → aplicar (rebuild o patch fechado en `SQL/patches/`) → `gen_entities.py` + prettier → `yarn docs:tsdoc` → `yarn orm:catalog` → verificar capas. **Las entidades no se escriben a mano.**

## Decisiones del propietario (2026-10-23, en esta sesión)

| Tema | Decisión |
|---|---|
| Cardinalidad línea factura ↔ línea reclamo | **1:1 estricta**: `invoice_lines.insurance_claim_line_id` nullable + índice único parcial |
| `ON DELETE` de las 3 FKs nuevas | **CASCADE** (`<<FK,ON_DELETE_CASCADE>>`). Riesgo registrado: borrar un reclamo borra documentos financieros vinculados. Va contra la recomendación; se implementa tal cual y se deja constancia en PLAN/REPORTE/PR |
| Alcance extra | **Incluir `reimbursements.claim_id`** (mismo defecto). `invoice_lines.service_id` queda fuera (se anota) |
| Postgres real | **Autorizado** correr la integración contra Neon dev **y aplicar el patch** allí, **solo si la consulta previa de huérfanos da 0**. Si hay huérfanos: detenerse y mostrar el conteo |
| Vault | **Sí**: tercer PR con las notas FK (2 corregidas + 1 nueva) y la nota de entidad de `invoice_lines` |
| Smoke `billing.smoke.ts:259` (`claimId: UUID_ABSENT` → 201) | **Ajustar**: el servicio valida existencia del reclamo y responde 4xx tipificado; el smoke espera ese 4xx |

## Alcance

- IN:
  - Modelo: `diagram_17_billing.puml` (stubs calificados `insurance.insurance_claims` / `insurance.insurance_claim_lines`, 3 aristas etiquetadas, columna nueva en `invoice_lines`, IX + UK parcial), regeneración `gen_ddl.py all`, patch fechado `SQL/patches/2026-10-23_billing_invoice_claim_links.sql`, pruebas del generador.
  - Vault: `SALUD/FK/FK billing.billing_document_links.claim_id.md`, `FK billing.reimbursements.claim_id.md` (corregir), `FK billing.invoice_lines.insurance_claim_line_id.md` (nueva), `SALUD/Entidades/E billing.invoice_lines.md` (bloque Campos).
  - API: entidades de billing regeneradas (`invoice_lines`, `billing_document_links`, `reimbursements`), `orm:catalog` (`billing.fk.ts`), `database/SQL` vendorizado, int-spec nuevo `test/integration/billing-invoice-claim-link.int-spec.ts`, validación mínima de existencia del reclamo en `reimbursements.service.ts` e `invoices.service.ts` (404 tipificado) + specs, ajuste del smoke.
  - PLAN/REPORTE en `mantra-core-health-model/docs/trabajo/2026-10-23-marcelo-lane16-model/` (precedente db522b6: un plan en el modelo para un cambio multi-repo; los PR de API y vault lo enlazan).
- OUT (aunque se vea roto):
  - Frontend. `audit.audit_log` y cualquier tabla de auditoría. `invoice_lines.service_id` sin destino. `reimbursements.invoice_id` sin `<<FK>>` (`:272`). Nota obsoleta `MIGRATION_diagram_17b_financial_planning` (`:366-370`) que habla de un puente `billing.insurance_claims`. Roles `BILLING`/`FINANCE` (bloqueante conocido, decisión del propietario). Lógica de cálculo/consentimiento de REQ-16-028+ (fase 2). PR #671.
  - No se extiende `gen_entities.py` (el vault resuelve el comentario de la entidad). Se anota que `fk_comment` no consulta el diagrama.
- Ambigüedades registradas:
  1. El brief nombra `modules/diagram_25_billing.puml`: **no existe**; billing es `Mantra Core Health Context/modules/diagram_17_billing.puml` (25 es pharmacy_inventory). Supuesto: 17. Confirmar: propietario.
  2. El brief pide `claims.service.int-spec.ts` junto al servicio: jest solo toma `test/integration/**/*.int-spec.ts`. Supuesto: `test/integration/billing-invoice-claim-link.int-spec.ts` (identificador en inglés, regla 29).
  3. El brief prohíbe «migraciones manuales o editar SQL a mano»; la convención del repo (`SQL/README.md:99-117`, ddl-sources.md) exige un **patch fechado a mano, copiado de lo generado**, porque `init-postgres.sh` se salta `apply_deferred` en bases pobladas. Gana el repo; el patch se arma copiando sentencias generadas, no redactando DDL nuevo.
  4. `yarn test:unit` no existe; se usa `yarn test` filtrado.
  5. La fuente «vigente» del carril (`tareas/TAREA-16-solicitudes-de-seguro.md`) y la regla `99-adaptacion-mantra-core.md` no existen en ningún repo del workspace. Se trabaja con `requirements.md` + decisiones del propietario. Confirmar: propietario.
  6. «Un PR por base» (dev y test) es práctica observada en la API; el brief pide dev. Supuesto: PR a `dev` en este corte; `test` queda como pendiente explícito. El modelo y el vault solo tienen `dev`.
  7. El `.env` de la API apunta Redis/OpenSearch/MinIO a `localhost` (no hay Docker aquí): el int-spec se escribe **ORM-only** (`MikroORM.init(buildOrmConfig())`, patrón de `audio-budget-accounting.int-spec.ts:43`), sin `AppModule`.
  8. ADR-0021 dice que `database/` se eliminó; `database/README.md` y `ddl-sources.md` §«La excepción» lo reinstauran como copia vendorizada (`yarn db:vendor`). Vale la excepción.

## Entorno (fuera de los repos; se deja documentado en el REPORTE)

Los generadores resuelven rutas por `salud-db/paths.py`: `FK_DIR = <WORKSPACE>/Mantra Core Health Vault/SALUD/FK` y `API_ENTITIES_DIR = <WORKSPACE>/mantra-core-health-api/src/modules`. En esta máquina el vault se llama `mantra_core_technologies_health_docs` y la API principal está en otra rama (143 archivos vs dev). Sin corregir esto, `gen_ddl.py all` cambiaría cientos de FKs ajenas y `gen_entities.py` escribiría en el clon equivocado.

- Worktrees: modelo `C:\Alovida\wt-marcelo-model-lane16` y API `C:\Alovida\wt-marcelo-api-lane16`, ambos rama `marcelo/lane16-invoice-claim-model` desde `origin/dev` (tras `git fetch`). Vault: rama con el mismo nombre en el clon principal (está limpio, en `dev`).
- Workspace sintético `C:\Alovida\ws-lane16\` con dos junctions (`New-Item -ItemType Junction`): `Mantra Core Health Vault` → `C:\Alovida\mantra_core_technologies_health_docs`; `mantra-core-health-api` → `C:\Alovida\wt-marcelo-api-lane16`. Variables: `SALUD_WORKSPACE=C:\Alovida\ws-lane16`, `SALUD_VAULT=C:\Alovida\mantra_core_technologies_health_docs\SALUD`.
- `python` (3.14; no hay `python3`). Generadores stdlib puro. API: `corepack yarn install --immutable` en el worktree y copia local de `.env` (gitignored; no sale de la máquina).
- No hay `psql` ni `rsync` en Git Bash; hay WSL Ubuntu. Para Neon: `wsl psql` si existe, si no un script en el scratchpad con `pg` de `node_modules` que lee el `.env` sin imprimir credenciales. Para `yarn db:vendor`: `wsl bash scripts/db/vendor-ddl.sh`; fallback: copiar los archivos generados y verificar con `yarn ddl:sources`.

## H0 — Línea base reproducible (sin tocar el modelo)
**CA:** Dado el worktree del modelo en `origin/dev` sin cambios, cuando corro `gen_ddl.py all` con el workspace sintético, entonces `git status -- SQL/` queda vacío.
**DoD:** salida literal de `git status --porcelain -- SQL/` vacía en `evidencia/h0-baseline.txt`.
**Estado:** TODO

### H0.S1 — Entorno y worktrees
| ID | Microtarea | CA (binario) | DoD (comando de verificación) | Estado |
|---|---|---|---|---|
| H0.S1.M1 | `git -C mantra-core-health-model fetch origin dev` y worktree `wt-marcelo-model-lane16` en `marcelo/lane16-invoice-claim-model` desde `origin/dev` | El worktree existe en esa rama y HEAD == origin/dev | `git -C C:\Alovida\wt-marcelo-model-lane16 log -1 --oneline` == `git log -1 --oneline origin/dev` (eceb98f o posterior) | TODO |
| H0.S1.M2 | Ídem API: `wt-marcelo-api-lane16` desde `origin/dev` + `corepack yarn install --immutable` + copiar `.env` | `yarn typecheck` sale 0 | `corepack yarn typecheck` → exit 0 | TODO |
| H0.S1.M3 | Vault: `git pull --ff-only` en `dev` y `git switch -c marcelo/lane16-invoice-claim-model` | Rama creada, árbol limpio | `git status --porcelain` vacío · `git branch --show-current` | TODO |
| H0.S1.M4 | Workspace sintético `C:\Alovida\ws-lane16` con las dos junctions | `python -c "import paths; print(paths.FK_DIR.exists(), paths.API_ENTITIES_DIR)"` imprime `True` y la ruta del worktree de la API | comando anterior desde `wt-marcelo-model-lane16\salud-db` con `SALUD_WORKSPACE` seteado | TODO |
| H0.S1.M5 | PLAN.md en `wt-marcelo-model-lane16/docs/trabajo/2026-10-23-marcelo-lane16-model/PLAN.md` (este plan, formato AGENTS.md §2.1) **antes de cualquier edit de código** | Archivo existe | `ls docs/trabajo/2026-10-23-marcelo-lane16-model/PLAN.md` | TODO |

### H0.S2 — Baseline del generador
| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H0.S2.M1 | `python salud-db/gen_ddl.py all` sobre el árbol limpio | `git status --porcelain -- SQL/` vacío | salida pegada en `evidencia/h0-baseline.txt`. Si NO está vacío: BLOQUEADO de entorno → fallback: generar solo `17` y no commitear `_generation_report.md` (precedente db522b6), anotado como desvío | TODO |
| H0.S2.M2 | `python -m unittest discover -s salud-db/tests -v` en baseline | Todas las pruebas pasan | salida con `OK` | TODO |
| H0.S2.M3 | Consulta de solo lectura en Neon dev: huérfanos de `billing_document_links.claim_id`, `reimbursements.claim_id` (y confirmación de que `invoice_lines.insurance_claim_line_id` no existe aún) | Conteos obtenidos | `SELECT count(*) ... WHERE claim_id NOT IN (SELECT id FROM insurance.insurance_claims)` ×2 → números pegados (sin PHI: solo conteos). Si > 0 → **detenerse y reportar**; H3.S2 pasa a BLOQUEADO | TODO |

## H1 — Modelo: el `.puml` declara las FKs y el DDL las emite
**CA:** Dado `diagram_17_billing.puml` editado, cuando regenero, entonces `SQL/17_billing/90_fk_deferred.sql` emite `fk_billing_document_links_claim_id`, `fk_reimbursements_claim_id` y `fk_invoice_lines_insurance_claim_line_id` con `ON DELETE CASCADE`, ya no lista `claim_id` como «sin destino canónico», `02_tables.sql` tiene la columna nueva y `04_indexes.sql` tiene IX + UK parcial.
**DoD:** `git diff --stat -- SQL/` limitado a `17_billing/{02_tables,04_indexes,90_fk_deferred}.sql` (+ `_generation_report.md` si se corrió `all`); grep de los 3 nombres de FK y de `ON DELETE CASCADE` (3 ocurrencias nuevas); pruebas del generador en verde.
**Estado:** TODO

### H1.S1 — Edición del diagrama (diff mínimo, sin reordenar)
Cambios concretos en `Mantra Core Health Context/modules/diagram_17_billing.puml`:
1. En el bloque de stubs calificados (`:12-26`): agregar `entity "insurance.insurance_claims" as insurance_insurance_claims <<REFERENCE_ONLY>> { * id : uuid <<PK>> }` y `entity "insurance.insurance_claim_lines" as insurance_insurance_claim_lines <<REFERENCE_ONLY>> { * id : uuid <<PK>> }`. Borrar el stub bare `:256-258`.
2. `invoice_lines` (`:84-105`): después de `service_id`, nueva línea `    insurance_claim_line_id : uuid <<FK,ON_DELETE_CASCADE>>` (nullable).
3. `reimbursements` (`:263`): `* claim_id : uuid <<FK,ON_DELETE_CASCADE>>`. `billing_document_links` (`:425`): `claim_id : uuid <<FK,ON_DELETE_CASCADE>>`.
4. Relaciones: reemplazar `:363` `insurance_claims ||--o{ reimbursements` por `reimbursements }o--|| insurance_insurance_claims : claim_id`; agregar `billing_document_links }o--o| insurance_insurance_claims : claim_id` e `invoice_lines }o--o| insurance_insurance_claim_lines : insurance_claim_line_id` (el **origen** debe ser la tabla dueña y la etiqueta el nombre exacto de la columna: `gen_ddl.py:558-562`).
5. `INDEXES · invoice_lines` (`:685-696`): `IX ix_invoice_lines_insurance_claim_line_id : (insurance_claim_line_id) BTREE` y `UK uq_invoice_lines_insurance_claim_line_id : (insurance_claim_line_id) UNIQUE BTREE WHERE insurance_claim_line_id IS NOT NULL` (precedente de UK parcial: `diagram_08_clinical.puml:839`).

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H1.S1.M1 | Stubs calificados + borrar stub bare | `grep -c 'as insurance_insurance_claim' diagram_17_billing.puml` == 2 y `grep -c '^entity insurance_claims' ` == 0 | greps pegados | TODO |
| H1.S1.M2 | Columna `insurance_claim_line_id` en `invoice_lines` | Una sola línea nueva en el bloque | `git diff` del bloque muestra +1 | TODO |
| H1.S1.M3 | Estereotipo `ON_DELETE_CASCADE` en las 3 columnas FK | `grep -c 'ON_DELETE_CASCADE' diagram_17_billing.puml` == 3 (si ya hubiera otros usos, == previos+3). Verificar antes que `stereotypes()` acepta coma (`gen_ddl.py:stereotypes`) y buscar un uso existente en otro `.puml` con `grep -rl ON_DELETE_CASCADE "Mantra Core Health Context/modules"` | greps pegados | TODO |
| H1.S1.M4 | 3 aristas etiquetadas (y quitar `:363`) | `grep -nE ': (claim_id|insurance_claim_line_id)$'` == 3 líneas | grep pegado | TODO |
| H1.S1.M5 | IX + UK parcial en `INDEXES · invoice_lines` | 2 líneas nuevas | `git diff` del bloque | TODO |

### H1.S2 — Regeneración y pruebas del generador
| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H1.S2.M1 | `python salud-db/gen_ddl.py all` (con `SALUD_WORKSPACE`) | Sin abortos ni warnings nuevos; diff limitado | `git diff --stat -- SQL/` pegado; `git diff -- SQL/17_billing/90_fk_deferred.sql` muestra las 3 FK con `ON DELETE CASCADE` y la cabecera «FK sin destino canónico» solo con `invoice_lines.service_id` | TODO |
| H1.S2.M2 | Verificar `02_tables.sql` y `04_indexes.sql` | `"insurance_claim_line_id" uuid` en 02; `uq_invoice_lines_insurance_claim_line_id ... WHERE` en 04 | greps pegados | TODO |
| H1.S2.M3 | `python -m unittest discover -s salud-db/tests -v` | OK | salida | TODO |
| H1.S2.M4 | Patch `SQL/patches/2026-10-23_billing_invoice_claim_links.sql`: cabecera (idempotente, no entra en apply_all, sentencias copiadas de lo generado, DELTAS: columnas +1 · índices +2 · FKs +3), `BEGIN;` `ALTER TABLE billing.invoice_lines ADD COLUMN IF NOT EXISTS ...`, los 2 `CREATE [UNIQUE] INDEX IF NOT EXISTS` y los 3 bloques `DO $$ ... duplicate_object` copiados de `90_fk_deferred.sql`, `COMMIT;` | Cada sentencia del patch existe textualmente en los archivos generados | `for s in <sentencias>; grep -F "$s" SQL/17_billing/*.sql` → todas encontradas | TODO |
| H1.S2.M5 | Commit modelo `feat(model): vínculo canónico factura ↔ reclamo aseguradora (carril 16 corte 2)` con `.puml`, SQL generado, patch, PLAN | `git status` limpio tras commit | `git log -1 --stat` | TODO |

## H2 — Vault: notas FK y de entidad al día
**CA:** Dado el vault en la rama de trabajo, cuando `gen_ddl.resolve_fk('billing','billing_document_links','claim_id')` corre con `SALUD_WORKSPACE`, entonces devuelve `('insurance','insurance_claims')`; ídem `reimbursements.claim_id`; y `invoice_lines.insurance_claim_line_id` → `('insurance','insurance_claim_lines')`.
**DoD:** `python -c` con las tres llamadas pegado; `git diff --stat` del vault = 4 archivos.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H2.S1.M1 | Corregir `FK billing.billing_document_links.claim_id.md`: reemplazar la línea «Destino no resuelto…» por `## Apunta a →` + `- [[E insurance.insurance_claims|insurance_claims]]  _(declarada en diagram_17_billing.puml)_` (formato que lee `TARGET_RE`, `gen_ddl.py:525`) | `resolve_fk` devuelve `('insurance','insurance_claims')` | `python -c "import gen_ddl;print(gen_ddl.resolve_fk('billing','billing_document_links','claim_id'))"` | TODO |
| H2.S1.M2 | Ídem `FK billing.reimbursements.claim_id.md` | ídem | ídem | TODO |
| H2.S1.M3 | Nueva `FK billing.invoice_lines.insurance_claim_line_id.md` (molde: `FK billing.billing_document_links.encounter_id.md`, tags fk/schema/billing/modulo/17) | `resolve_fk` → `('insurance','insurance_claim_lines')` | comando pegado | TODO |
| H2.S1.M4 | `E billing.invoice_lines.md`: agregar la línea de la columna en el bloque ```puml (mismo orden que el diagrama) | Bloque Campos coincide con el `.puml` | `diff` visual pegado | TODO |
| H2.S1.M5 | Commit vault `docs(billing): FK canónicas de claim_id y nueva invoice_lines.insurance_claim_line_id (carril 16 corte 2)` | limpio | `git log -1 --stat` | TODO |

## H3 — API: entidades regeneradas, catálogo, copia vendorizada, 404 tipificado
**CA:** Dado el worktree de la API, cuando regenero entidades y catálogo, entonces `invoice_lines.entity.ts` tiene `insuranceClaimLineId?` con `// FK → insurance.insurance_claim_lines`, `billing_document_links.entity.ts:54` y `reimbursements.entity.ts` dicen `// FK → insurance.insurance_claims`, `billing.fk.ts` tiene las 3 tuplas, `database/SQL/17_billing/*` y el patch coinciden con el modelo, y `typecheck`/`build`/`test` (billing+insurance) están en verde.
**DoD:** comandos de la plantilla de PR (`.github/PULL_REQUEST_TEMPLATE.md:10`) con salida; `git diff --stat` acotado.
**Estado:** TODO

### H3.S1 — Regeneración (ADR-0022, en este orden)
| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H3.S1.M1 | `python <wt-model>/salud-db/gen_entities.py 17` con `SALUD_WORKSPACE` (escribe en `wt-marcelo-api-lane16/src/modules/billing/entities`) | Diff solo en `invoice_lines`, `billing_document_links`, `reimbursements` `.entity.ts` (+ `index.ts` si cambia) | `git diff --stat` pegado; JSDoc previo preservado (0 bloques perdidos: línea «bloques JSDoc preservados» del generador) | TODO |
| H3.S1.M2 | `npx prettier --write "src/modules/billing/entities/**/*.ts"` | Sin cambios fuera de billing/entities | `git diff --stat` | TODO |
| H3.S1.M3 | `corepack yarn docs:tsdoc` (rellena JSDoc solo donde falta: la propiedad nueva) | Solo la propiedad nueva recibe JSDoc | `git diff` del archivo | TODO |
| H3.S1.M4 | `SALUD_VAULT=... corepack yarn orm:catalog` y `corepack yarn orm:audit` | `billing.fk.ts` suma exactamente 3 tuplas (`billing_document_links.claim_id`, `reimbursements.claim_id`, `invoice_lines.insurance_claim_line_id` → `insurance.*`). Si aparecen diffs ajenos (deriva previa del vault), **no se commitean** y se anotan | `git diff --stat src/orm/catalog` + salida de `orm:audit` | TODO |
| H3.S1.M5 | `wsl bash scripts/db/vendor-ddl.sh` (fallback: copiar `SQL/17_billing/*` + patch + `_generation_report.md` del modelo) y `corepack yarn ddl:sources` | `ddl:sources` exit 0; diff en `database/SQL/17_billing/*`, `database/SQL/patches/+1` | salidas pegadas | TODO |
| H3.S1.M6 | `corepack yarn docs:data:sync` si `docs/data/entity-catalog.md` enumera columnas de `invoice_lines` (hoy la menciona 2 veces) | Diff solo en esa fila | `git diff --stat docs/data` | TODO |
| H3.S1.M7 | `corepack yarn typecheck` y `corepack yarn build` | exit 0 ambos | salidas | TODO |

### H3.S2 — Prueba de integración contra Postgres real (Neon dev, autorizado)
Archivo: `test/integration/billing-invoice-claim-link.int-spec.ts`. ORM-only (`MikroORM.init({...buildOrmConfig(), discovery:{warnWhenNoEntities:false}})`, `em.fork()`), sin `AppModule`. Datos **sintéticos** con marca de corrida `LANE16-<uuid8>` en `claim_identifier`/`invoice_number`; limpieza en `afterAll` en orden inverso (líneas → factura → reclamo → padres), nunca `TRUNCATE`, nunca tocar `audit.*`. Sin PHI en nombres ni logs.

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H3.S2.M1 | Discovery: cadena mínima de padres NOT NULL para insertar `insurance.insurance_claims` + `insurance_claim_lines` y `billing.invoices` + `invoice_lines` (leer entidades y `02_tables.sql`; buscar helper existente con `grep -rn "insurance_claims" test/integration test/support`). Si la cadena exige > 8 tablas padre sin helper, registrar y evaluar `bootstrapTestApp` (requiere Redis/OpenSearch: en esta máquina → BLOQUEADO con evidencia) | Lista de tablas/columnas obligatorias escrita en `evidencia/h3-cadena-padres.md` | archivo | TODO |
| H3.S2.M2 | Aplicar el patch en Neon dev **solo si H0.S2.M3 dio 0 huérfanos** (vía `wsl psql` o script `pg` del scratchpad que lee `.env` sin imprimir credenciales), con `-v ON_ERROR_STOP=1` | Las 3 constraints y la columna existen | `SELECT conname FROM pg_constraint WHERE conname IN (...)` → 3 filas; `information_schema.columns` → `insurance_claim_line_id` presente. Salida pegada | TODO |
| H3.S2.M3 | Caso **correcto**: reclamo + línea → factura + línea con `insurance_claim_line_id`; `SELECT` con join devuelve la fila | 1 fila | salida del runner | TODO |
| H3.S2.M4 | Caso **inválido 1**: segunda `invoice_lines` con el mismo `insurance_claim_line_id` → error `23505` (`uq_invoice_lines_insurance_claim_line_id`) | el insert lanza con `code === '23505'` | runner | TODO |
| H3.S2.M5 | Caso **inválido 2**: `invoice_lines.insurance_claim_line_id` = uuid inexistente → `23503`; `billing_document_links.claim_id` inexistente → `23503` | ambos lanzan `23503` | runner | TODO |
| H3.S2.M6 | Caso **límite (concurrencia)**: dos inserts en paralelo (`Promise.all` con dos `em.fork()`/conexiones) sobre la misma línea de reclamo → exactamente 1 éxito y 1 `23505`; `count(*)` == 1 (molde `fx9-carreras-de-la-agenda.int-spec.ts:229-235`) | count == 1 | runner | TODO |
| H3.S2.M7 | Caso **CASCADE** (decisión del propietario): borrar la línea de reclamo → la línea de factura desaparece; `count(*)` == 0 | count == 0 | runner | TODO |
| H3.S2.M8 | `corepack yarn test:integration --runInBand --testPathPattern billing-invoice-claim-link` (si B-16 `MetadataError` aparece: `yarn build` previo y reintentar; documentar) | 5 tests PASS, `afterAll` deja 0 filas con la marca | salida literal en `evidencia/h3-int-spec.txt` + `SELECT count(*)` post-limpieza | TODO |

### H3.S3 — 404 tipificado para reclamo inexistente y smoke
| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H3.S3.M1 | `reimbursements.service.ts` (`link`, ~:62) e `invoices.service.ts` (`issueFromEncounter`, bloque `:145-151` en dev): si viene `claimId`, `tx.count(InsuranceClaims,{id})===0` → `NotFoundException` con `reason` tipificado (reusar `billing.error-reasons.ts` si existe en dev; si no, el patrón de `InsuranceErrorReason`) | Dado `claimId` inexistente, cuando se llama, entonces 404 tipificado y **no** se inserta nada | spec unitario nuevo/ajustado en verde: `corepack yarn test --testPathPattern "reimbursements.service|invoices.service"` | TODO |
| H3.S3.M2 | `test/smoke/modules/billing.smoke.ts:250-263`: `claimId: UUID_ABSENT` pasa a `expectedStatus: 404` (o usa un reclamo real si el smoke ya crea uno) | El smoke declara el nuevo contrato | `node --check` + diff pegado; ejecución del smoke **no cubierta** (no hay entorno) | TODO |
| H3.S3.M3 | `corepack yarn test --testPathPattern "billing|insurance"` y `corepack yarn lint` sobre archivos tocados | Verde | salidas | TODO |
| H3.S3.M4 | Commit API `feat(billing): vínculo canónico factura ↔ reclamo y 404 ante reclamo inexistente (carril 16 corte 2)` | limpio | `git log -1 --stat` | TODO |

## H4 — Entrega: PRs mergeables y reporte
**CA:** Dado los tres commits, cuando abro los PR contra `dev`, entonces cada uno muestra `mergeable: MERGEABLE`, fuera de draft, checks en verde (o «no checks» documentado) y cuerpo con evidencia y «qué no se verificó».
**DoD:** salida literal de `gh pr view <n> --json isDraft,mergeable,mergeStateStatus` y `gh pr checks <n>` por PR, tras el último push. REPORTE.md escrito.
**Estado:** TODO

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H4.S1.M1 | PR modelo → `mantra-core-technologies/mantra-core-health-model:dev`, título del brief `feat(model): vínculo canónico factura ↔ reclamo aseguradora (carril 16 corte 2)`, cuerpo con `--body-file` (resumen, decisiones del propietario incl. CASCADE, evidencia, no verificado, enlaces a los otros 2 PR) | PR abierto, no draft | `gh pr view` + `gh pr checks` pegados | TODO |
| H4.S1.M2 | PR vault → `mdavila-2001/mantra_core_technologies_health_docs:dev` | ídem | ídem | TODO |
| H4.S1.M3 | PR API → `mdavila-2001/mantra-core-health-api:dev` con la plantilla del repo (casilla «Entidades o el modelo de datos» marcada con los comandos corridos) | ídem; `mergeStateStatus` y checks pegados | ídem | TODO |
| H4.S1.M4 | REPORTE.md (AGENTS.md §2.2, 3 secciones obligatorias, «Decisiones y ambigüedades» incluida) + `evidencia/` con todas las salidas; commit y push en el modelo | Avance calculado `HECHO/total` | archivo + `git log -1` | TODO |
| H4.S1.M5 | Limpieza: worktrees retirados (`git worktree remove`), junctions borradas, ramas conservadas | `git worktree list` solo muestra los clones principales | salida | TODO |

Orden de merge (git-workflow-multirepo §5): modelo → vault → API. Nunca `gh pr merge` (lo hace el propietario).

## Verificación de cierre (gates)
- `evidence-and-verification`: cada DoD con salida literal en `evidencia/`.
- `model-driven-schema` §Evidencia: `git diff --stat` tras regenerar; conteo de FKs del DDL (`grep -c ADD CONSTRAINT SQL/17_billing/*.sql` = 150+3) vs `pg_constraint` en Neon para schema billing; verificador base↔ORM (`ORM_VERIFY_FIDELITY` al arrancar no aplica sin AppModule → `yarn orm:audit` como sustituto, declarado).
- `data-privacy-phi`: datos sintéticos; sin PHI en logs/evidencia/PR; `.env` nunca pegado.
- `security-guardrails`: no hay entrada de usuario nueva salvo `claimId` ya existente (validación de existencia agregada; IDOR por tenant queda para fase 2 y se anota).
- `pr-mergeable-gate`: salidas de `gh pr view/checks` por PR.
- `qa-evidence-reporting`: REPORTE con «No cubierto»: ejecución del smoke; PR a `test`; `bootstrapTestApp` completo; fase 2 (cálculo, consentimiento, desglose).

## Riesgos y bloqueos previstos
| Riesgo | Impacto | Mitigación |
|---|---|---|
| `gen_ddl.py all` no deja `SQL/` limpio en baseline (vault/junction mal resuelto) | diff de cientos de FKs ajenas | H0.S2.M1 bloquea antes de editar; fallback módulo 17 solo + sin `_generation_report.md` |
| `stereotypes()` o `COL_RE` no aceptan `<<FK,ON_DELETE_CASCADE>>` como espero | sin CASCADE o abort | H1.S1.M3 verifica contra un uso existente o contra el regex antes de editar; si no hay soporte real, registrar y pedir decisión |
| Huérfanos en Neon dev (`claim_id` sin reclamo; el smoke ya insertó `UUID_ABSENT`) | el `ALTER` falla | H0.S2.M3 cuenta antes; con > 0 se detiene y H3.S2 queda BLOQUEADO (decisión del propietario) |
| `ON DELETE CASCADE` borra documentos financieros al borrar un reclamo | pérdida silenciosa | decisión del propietario registrada en PLAN/REPORTE/PR; prueba H3.S2.M7 lo hace explícito |
| B-16 `MetadataError` (TsMorph) en `test:integration` | la suite no arranca | `yarn build` + glob `dist`; documentar |
| `gen_entities.py 17` pisa JSDoc a medida | pérdida de prosa | el generador preserva bloques; verificar el contador «preservados» y `git diff` |
| `orm:catalog` trae deriva ajena del vault | diff fuera de alcance | commitear solo `billing.fk.ts` si el resto es deriva; anotar |
| `yarn db:vendor` sin rsync | copia a mano | WSL; fallback copiar generados + `ddl:sources` |
| PR #671 (corte 1) y este PR tocan `insurance`/`billing` | conflicto al mergear | este corte no toca `claims.service.ts`; rebase sobre `dev` antes del PR |
| Smoke en producción/dev con contrato nuevo (404) | regresión visible al desplegar | PR lo declara; ejecución del smoke «no cubierta» |
