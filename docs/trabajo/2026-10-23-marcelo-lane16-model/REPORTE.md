# Reporte — Carril 16 · Fase 1: vínculo canónico factura ↔ reclamo

- Fecha: 2026-10-23 · Plan: [PLAN.md](./PLAN.md) · Rama(s): `marcelo/lane16-invoice-claim-model` (modelo, vault y API) · Base: `origin/dev` (modelo `eceb98f`, API `6ea11561`, vault `0b421692`)
- PR: modelo [#50](https://github.com/mantra-core-technologies/mantra-core-health-model/pull/50) · vault [#90](https://github.com/mdavila-2001/mantra_core_technologies_health_docs/pull/90) · API [#672](https://github.com/mdavila-2001/mantra-core-health-api/pull/672)
- Peldaño de evidencia alcanzado: **TESTED**, con una comprobación contra la base real. No llega a `VERIFIED`: el flujo HTTP no se ejercitó y la regresión completa no se corrió. Mejor palabra permitida: «las pruebas dirigidas pasan; las constraints se comprobaron contra Postgres real».
- Avance: **43 / 47 microtareas HECHO (91,5 %)**, calculado: 2 `DESCARTADO`, 1 `A MEDIAS`, 1 `TODO`.

## Completado

| ID | Qué se logró | Comando | Resultado |
|---|---|---|---|
| H0.S1.M1–M5 | Worktrees de modelo y API en `origin/dev`, rama del vault, workspace sintético con junctions, `PLAN.md` en disco antes del primer edit | `git worktree list` · `python -c "import paths; …"` | `True` + ruta del worktree de la API |
| H0.S2.M1 | Línea base del generador medida (con desvío, ver abajo) | `gen_ddl.py all` | `evidencia/h0-baseline.txt` |
| H0.S2.M2 | Pruebas del generador en la línea base | `python -m unittest discover -s salud-db/tests` | `Ran 18 tests … OK` |
| H0.S2.M3 | Huérfanos en la base de desarrollo, solo lectura (`BEGIN READ ONLY`) | script de solo lectura | `bdl_orphans 0 · reimb_orphans 0 · claims_total 0 · new_column_exists 0` |
| H1.S1.M1–M5 | `diagram_17_billing.puml`: 2 stubs calificados (−1 stub sin calificar), columna nueva, 3× `ON_DELETE_CASCADE`, 3 aristas etiquetadas, IX + UK parcial | `grep -c` de cada criterio | 2 / 0 / 3 / 3 líneas, según el CA |
| H1.S2.M1–M3 | DDL regenerado: 1 columna, 2 índices, 3 FK con `ON DELETE CASCADE`; ya no figuran `claim_id` como «sin destino canónico» | `gen_ddl.py all` · `git diff --numstat -- SQL/17_billing` | `02_tables +1 · 04_indexes +4 · 90_fk_deferred +21/−2`; 18 pruebas OK |
| H1.S2.M4 | Patch fechado idempotente | verificación sentencia por sentencia contra el DDL generado | 5/5 copiables encontradas; el `ADD COLUMN` es derivado (la columna vive en el `CREATE TABLE`) |
| H1.S2.M5 | Commit del modelo | `git log -1 --stat` | `e3c067d`, 8 archivos |
| H2.S1.M1–M5 | Notas del vault: 2 corregidas, 1 nueva, 2 de entidad actualizadas | `gen_ddl.resolve_fk(...)` ×3 | `('insurance','insurance_claims')` ×2 y `('insurance','insurance_claim_lines')` |
| H3.S1.M1 | Entidades regeneradas | `gen_entities.py 17` | `22 entidades · 339 bloques JSDoc preservados` |
| H3.S1.M2 | Prettier sobre las entidades | `prettier --write …/entities/**` | diff acotado a 3 archivos |
| H3.S1.M4 | Catálogo ORM de billing | `yarn orm:catalog` · `yarn orm:audit` | `billing.fk.ts` +3 tuplas (150→153) · `billing.idx.ts` +2 (167→169) · `orm:audit` exit 0, `fkDeclaradas = fkEnCatalogo = 6764`, 0 menciones de las tablas tocadas |
| H3.S1.M6 | Fila de `invoice_lines` en el catálogo de entidades | edición de una fila | `19 → 20` |
| H3.S1.M7 | Compilación | `yarn typecheck` · `yarn build` | exit 0 · exit 0 |
| H3.S2.M1–M8 | Cadena de padres calculada del catálogo; patch aplicado en la base de desarrollo; prueba de integración | script de aplicación (una transacción) · `yarn test:integration --runInBand --testPathPatterns billing-invoice-claim-link` | antes `col 0 · FK 0 · idx 0` → después `col 1 · FK 3 (3 CASCADE) · idx 2`; **8/8 pruebas**, `limpieza: filas con la marca … restantes = 0` |
| H3.S3.M2 | Smoke adaptado al contrato nuevo | edición + prettier + eslint | `claimId` inexistente ahora espera 422 |
| H3.S3.M3 | Regresión unitaria dirigida y lint | `yarn test --testPathPatterns "modules/billing\|modules/insurance\|src/orm\|src/architecture"` · `yarn eslint …` | **68 suites, 840 pruebas, todas pasan** · 0 errores |
| H3.S3.M4 | Commit de la API | `git log -1 --stat` | `ac96a9c3`, 12 archivos |
| H4.S1.M1–M3 | Tres PR contra `dev`, no draft | `gh pr create` · `gh pr view` | #50, #90, #672 |
| H4.S1.M4 | Este reporte | — | — |

## A medias

### H3.S1.M5 — Copia vendorizada `database/SQL` en la API
- Qué anda: los 3 archivos de `database/SQL/17_billing/` y el patch llevan exactamente los hunks del modelo (`+1`, `+4`, `+23`, más el patch de 69 líneas).
- Qué no anda: `yarn ddl:sources` sale con **exit 1**. Informa que `database/SQL` ya estaba desfasada de `SQL/`: faltan 29, sobran 16, difieren 31 archivos. Es deriva previa, no de este cambio.
- Qué falta exactamente: un `yarn db:vendor` completo (con `rsync`, disponible en WSL), en un PR aparte, que resincronice los ~76 archivos ajenos. No se hizo aquí para no arrastrarlos a este PR.
- Dónde quedó: API `ac96a9c3`, PR #672.

## Pendiente

| ID | Estado | Qué lo destraba |
|---|---|---|
| H4.S1.M5 | TODO (deliberado) | Retirar los dos worktrees (`wt-marcelo-model-lane16`, `wt-marcelo-api-lane16`) y las junctions de `C:\Alovida\ws-lane16` cuando los PR se mergeen o no necesiten más cambios; hoy están en revisión y se conservan para poder atender comentarios. Las ramas se conservan |
| H3.S3.M1 | DESCARTADO | Ver «Desvíos»: se reemplazó por una prueba a nivel ORM porque el filtro global ya traduce la FK a 422 |
| H3.S1.M3 | DESCARTADO | Ver «Desvíos»: `docs:tsdoc` no se puede acotar y reescribe ~2 000 archivos |
| Aprobación humana de #672 | BLOQUEADO | La protección de `dev` exige 1 revisión (`REVIEW_REQUIRED`). Depende de un revisor distinto del autor |

## Evidencia

Salidas literales completas en `evidencia/`. Extractos:

```text
# h0-orphans-dev-db.txt (base de desarrollo, transacción READ ONLY, solo conteos)
claims_total => {"n":0}   bdl_orphans => {"n":0}   reimb_orphans => {"n":0}
new_column_exists => {"n":0}   existing_fks => {"n":0}

# h3-patch-dev-db.txt
ANTES   | columnas: 0 | FKs: 0 | FKs con CASCADE: 0 | índices: 0
DESPUÉS | columnas: 1 | FKs: 3 | FKs con CASCADE: 3 | índices: 2

# h3-int-spec.txt
LANE16 limpieza: filas con la marca LANE16-3a918fc7 restantes = 0
Test Suites: 1 passed, 1 total
Tests:       8 passed, 8 total

# h3-unit.txt
Test Suites: 68 passed, 68 total
Tests:       840 passed, 840 total

# h4-pr-gate.txt (gh pr view / gh pr checks, tras el último push de cada rama)
modelo #50 : {"isDraft":false,"mergeStateStatus":"CLEAN","mergeable":"MERGEABLE"}   no checks reported
vault  #90 : {"isDraft":false,"mergeStateStatus":"CLEAN","mergeable":"MERGEABLE"}   no checks reported
API    #672: {"isDraft":false,"mergeStateStatus":"BLOCKED","mergeable":"MERGEABLE"} no checks reported
API    #672: reviewDecision REVIEW_REQUIRED · dev exige 1 aprobación · sin checks requeridos
```

Casos que cubre la prueba de integración (la base lo rechaza, no un mock): línea de factura ↔ línea de reclamo (correcto) · misma línea facturada dos veces → `23505` · línea de reclamo inexistente → `23503` · `claim_id` inexistente en `billing_document_links` y en `reimbursements` → `23503` · el ORM lanza `ForeignKeyConstraintViolationException` (lo que el filtro global traduce a 422) · dos inserciones simultáneas sobre la misma línea, gana una sola (`count = 1`) · cascada al borrar la línea de reclamo · cascada al borrar el reclamo.

**Sobre el gate de mergeabilidad:** los PR #50 (modelo) y #90 (vault) están `MERGEABLE` y `CLEAN`; #672 (API) está `MERGEABLE` pero `BLOCKED` solo por la revisión requerida. Ningún repositorio reporta checks, así que «checks en verde» no es demostrable. La salida del PR #50 se volvió a capturar tras el push de este reporte (ver el mensaje de cierre de la sesión): no puede estar dentro de este mismo archivo.

## No cubierto

- **Flujo HTTP real:** ningún endpoint se ejercitó. El 422 ante un reclamo inexistente se infiere de que el ORM lanza `ForeignKeyConstraintViolationException` y de que `all-exceptions.filter.ts:506` la traduce; no hay una petición real que lo muestre.
- **El smoke no se ejecutó** (requiere el stack completo). Su cambio se verifica solo por tipos y lint. Además, el camino feliz del vínculo con un reclamo real dejó de estar en el smoke: queda cubierto solo a nivel de base.
- **`yarn test` completo de la API y del front:** solo se corrió la regresión dirigida (840 pruebas). La puerta P0 (REQ-16-035) exige la suite completa.
- **`yarn docs:validate`, `yarn docs:build`** y la reconstrucción desde cero (`rebuild_stack.py`, `db:verify-clean-init`) no se corrieron.
- **PR hacia `test`:** no existe; el modelo no tiene rama `test` y la API tendría que replicarse aparte.
- **Reclamo de otro tenant (IDOR):** el vínculo no valida que la línea de reclamo pertenezca al mismo paciente o práctica que la factura. La base solo garantiza existencia y unicidad.
- **Fase 2 completa:** cálculo de la parte del paciente en el servidor, factura generada desde ese cálculo, consentimiento, desglose, objeción, aviso. El rol `BILLING`/`FINANCE` sigue sin mapear en `role-mapping.ts`.

## Desvíos del plan

1. **H0.S2.M1 — la línea base no quedó limpia.** `gen_ddl.py all` sobre `origin/dev` sin tocar nada dejó 307 archivos modificados: 302 por fin de línea (CRLF que escribe Python en Windows; git los normaliza) y 5 con diferencias reales: `26_insurance` (2), `69_pharma_lab` (2) y `_generation_report.md`. Es la misma deriva previa del handoff de Codex (2.1). `17_billing` regeneró idéntico. Se revirtió todo; en cada regeneración posterior se descartó lo ajeno y solo se commiteó `17_billing`.
2. **H3.S3.M1 — se descartó la validación 404 en el servicio.** Con la FK en la base, el filtro global ya traduce `ForeignKeyConstraintViolationException` a 422 `PRECONDITION_FAILED`. Es mejor que lo planeado: no acopla `billing` a entidades de `insurance` y no deja una ventana entre comprobar e insertar. Se reemplazó por la prueba a nivel ORM. **Cambio de contrato visible:** el reclamo inexistente pasa de 201 a 422.
3. **H3.S1.M3 — no se corrió `yarn docs:tsdoc`.** No acepta alcance: reescribió 1 329 archivos y creó 685 READMEs. Se revirtió por completo y se agregó a mano el JSDoc de la propiedad nueva con la plantilla del generador.
4. **H3.S1.M6 — `yarn docs:data:sync` se descartó y se editó una sola fila.** Mezclaba deriva ajena (`party_ratings`, `branches`, …).
5. **H3.S1.M5 — hunks en lugar de `db:vendor`.** Ver «A medias». Copiar archivos enteros arrastraba 45+ líneas ajenas.
6. **Microtarea no prevista:** se actualizó la nota `E billing.idxset_invoice_lines` del vault, porque el catálogo de índices de la API sale de ahí y sin ella los dos índices nuevos no figuraban (`billing.idx.ts` no cambiaba). No estaba en el plan.
7. **Catálogo ORM:** `yarn orm:catalog` trajo cambios en otros 17 archivos de la API (deriva del vault, incluso dos archivos borrados). Se descartaron; solo se conservan `billing.fk.ts` y `billing.idx.ts`.
8. **`fidelity-audit.json`** (versionado) lo reescribe `orm:audit`; se revirtió.
9. **Entorno:** `python` (3.14), no `python3`; sin `psql` ni `rsync` en Git Bash (se usó `pg` de la API y WSL); `yarn test:unit` no existe (se usó `yarn test`); Jest renombró `--testPathPattern` a `--testPathPatterns`.
10. **Primer intento de crear el worktree de la API falló** al lanzar tres comandos en paralelo; se repitió solo ese.
11. **El primer `git push` de la API no fue a la rama nueva**: la rama seguía rastreando `origin/dev`. Terminó con «Everything up-to-date» sin modificar nada; se verificó que `dev` remoto seguía en `6ea11561` y se subió con refspec explícito.
12. **PR del modelo:** el primer intento fue rechazado por el clasificador por exceso de detalle de infraestructura (nombraba al proveedor de la base de desarrollo). Se quitó ese detalle y se reintentó.

## Riesgos residuales

- **`ON DELETE CASCADE` (decisión del propietario, contra la recomendación):** borrar un reclamo o una línea de reclamo borra los documentos de facturación vinculados, incluidas facturas al paciente. Está probado y registrado en los tres PR.
- **El patch ya está aplicado en la base de desarrollo compartida.** Con autorización del propietario y 0 huérfanos previos. Cualquier otro entorno necesita aplicarlo con el mismo patch.
- **Cambio de contrato:** consumidores que envíen un `claimId` inexistente recibirán 422 en vez de 201.
- **Conflicto posible con el PR #671** (corte 1) en insurance; este corte no toca `claims.service.ts`.
- **El `.env` de la API se copió al worktree** (ignorado por git; no se pegó ni se subió).

## Decisiones y ambigüedades

| # | Ambigüedad / decisión | Supuesto tomado | A quién confirmar |
|---|---|---|---|
| 1 | El pedido nombraba `diagram_25_billing.puml` | No existe; es `diagram_17_billing.puml` (el 25 es `pharmacy_inventory`) | Propietario |
| 2 | `claims.service.int-spec.ts` junto al servicio | Jest solo toma `test/integration/**/*.int-spec.ts`; se creó `billing-invoice-claim-link.int-spec.ts` | Propietario |
| 3 | «Sin migraciones ni SQL a mano» vs. patch fechado | Gana la convención del repo (`SQL/README.md`); el patch copia sentencias generadas | Propietario |
| 4 | Fuente vigente del carril (`TAREA-16…md`) y regla `99-adaptacion-mantra-core.md` | No existen en ningún repo del workspace; se trabajó con `requirements.md` y las decisiones de esta sesión | Propietario |
| 5 | «Un PR por base» (dev y test) | Solo `dev` en este corte | Propietario |
| 6 | ADR-0021 dice que `database/` se eliminó; `database/README.md` lo reinstaura | Vale la excepción de copia vendorizada | Equipo de plataforma |
| 7 | Cardinalidad 1:1, `ON DELETE CASCADE`, incluir `reimbursements.claim_id`, aplicar el patch en la base de desarrollo, tercer PR en el vault, ajustar el smoke | **Decididas por el propietario en esta sesión** | — |
| 8 | Las notas obsoletas `MIGRATION_diagram_17b_financial_planning` (habla de un puente `billing.insurance_claims` que ya no existe) | Fuera de alcance; se deja anotado | Propietario |
| 9 | `invoice_lines.service_id` y `reimbursements.invoice_id` siguen sin FK canónica | Fuera de alcance | Propietario |
