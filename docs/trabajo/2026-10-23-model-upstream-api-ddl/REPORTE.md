# Reporte — Subir al modelo el DDL que solo vive en la API (objeto por objeto)

- Fecha: 2026-10-23 · Plan: [PLAN.md](./PLAN.md) · Rama(s): `marcelo/model-upstream-api-ddl` (modelo), `marcelo/vault-upstream-api-ddl` (vault), `marcelo/api-upstream-ddl` (API) · Predecesor: PR #50 / #90 (abiertos) y #672 / #675 (mergeados)
- PR: modelo [#51](https://github.com/mantra-core-technologies/mantra-core-health-model/pull/51) (apilado sobre #50) · vault [#91](https://github.com/mdavila-2001/mantra_core_technologies_health_docs/pull/91) (apilado sobre #90) · API [#676](https://github.com/mdavila-2001/mantra-core-health-api/pull/676)
- Peldaño de evidencia alcanzado: **VERIFIED para el esquema** (se creó una base desde cero y se comparó su estructura completa); **TESTED** para el código (207 suites, 2 700 pruebas). No llega a `REGRESSION_VERIFIED`: no se corrió la suite completa ni la de integración.
- Avance: **22 / 23 microtareas HECHO (95,7 %)**, calculado. Queda 1 `TODO`: el retiro del último worktree, que se hace justo después del push de este reporte.

## Completado

| ID | Qué se logró | Comando | Resultado |
|---|---|---|---|
| H0.M1 | Worktrees (modelo, API, vault) y workspace sintético con junctions | `python -c "import paths; …"` | `FK_DIR.exists() = True` |
| H0.M2 | Inventario por **sentencia SQL normalizada** (el de líneas daba falsos positivos) | `stmt-diff.py`, `patch-inventory.py` | `evidencia/h0-inventario.md` |
| H0.M3 | Baseline del generador | `gen_ddl.py all` + `gen_integrity.py` + `gen_apply.py` | misma deriva ajena de siempre (`26_insurance`, `69_pharma_lab`, reporte) |
| H1.M1–M6 | Declarado en los `.puml`: branches, `indication_text`, `form_instance_id`×4, `follow_up_of_booking_id`, tablas SIAT, 3 CHECK en el módulo 33 | `gen_ddl.py all` | `[17/billing] 24 tablas · 21 FK intra · 135 FK diferidas · 174 índices` (antes 22/19/134/169) |
| H1.M7 | Regeneración y descarte de deriva ajena | `git diff --numstat` | solo archivos de estos objetos |
| H1.M8 | Pruebas del generador | `python -m unittest discover -s salud-db/tests` | `Ran 20 tests … OK` |
| H2.M1 | 13 parches de la API copiados al modelo tal cual + 1 nuevo (alergias) | `git hash-object` / `stmt-diff` | 0 diferencias |
| H2.M2 | Cada sentencia de esquema de esos parches existe en el DDL regenerado | `patch-vs-ddl.py` | `TOTAL objetos de esquema sin equivalente: 0` |
| H3.M1 | Vault: 9 notas FK + notas de entidad/índices + M17 | `gen_ddl.resolve_fk` ×9 | las 9 resuelven; regenerar el DDL no cambia nada |
| H3.M2 | API: entidades regeneradas (6 módulos) | `gen_entities.py` + `prettier` | 0 propiedades quitadas |
| H3.M3 | API: catálogo ORM y `entity-catalog.md` solo con lo propio | `catalog-merge.py` | 20 tuplas (9 FK + 11 índices) y 2 filas |
| H3.M4 | API: los `INSERT` de SIAT fijan `created_at`, `updated_at` y el `status` del outbox | ejecución contra bases recién creadas | dev: `23502` · rama: `OK` |
| H3.M5 | API: `rsync --delete` real | `rsync -a --delete` + auditoría de pérdida | 4 parches renombrados retirados · **0 columnas perdidas** |
| H3.M6 | API: compilación, tipos, lint y tests | `yarn typecheck` · `yarn build` · `yarn eslint` · `yarn test` dirigido | exit 0 · exit 0 · exit 0 · **207 suites, 2 700 pruebas** |
| H3.M7 | **Base limpia**: arranque desde cero y comparación estructural | `bootstrap.mjs` (Postgres 18 desechable) | API sincronizada vs modelo: **0 diferencias** en 16 904 columnas, 17 908 constraints, 9 512 índices |
| H4.M1 | Tres PR abiertos | `gh pr create` | #51, #91, #676 |
| H4.M2 | Este reporte | — | — |

## A medias

Ninguna microtarea a medias.

## Pendiente

| ID | Estado | Qué lo destraba |
|---|---|---|
| H4.M3 | TODO | Retirar el worktree del modelo (`wt-model-upstream`): se hace tras el push de este reporte. Los demás worktrees, la carpeta suelta `wt-vendor-src-model` y `ws-upstream` se retiran antes |
| Aprobación humana de #676 | BLOQUEADO | La protección de `dev` exige 1 revisión (`REVIEW_REQUIRED`) |
| Mergear #50 y #90 | BLOQUEADO | Son la base de #51 y #91. Hasta entonces el `dev` del modelo no contiene siquiera el vínculo factura ↔ reclamo que la API ya tiene mergeado |
| Decidir el destino de los 5 parches de datos | TODO | Pertenecen conceptualmente a los *seeds*; moverlos exige rediseñar ese pipeline. Hoy viven en `SQL/patches/` |

## Evidencia

Salidas completas en `evidencia/`. Extractos:

```text
# h3-arranque-desde-cero-modelo-origin-dev.json   (dev del modelo, sin tocar)
patches: fallidos 3 → v407 (vector_rag), v428 «v4.2.8 incompleto: … check=0 (esperado 1)», v4231 (catálogo sembrado)

# h3-arranque-desde-cero-modelo-esta-rama.json
patches: fallidos 2 → v407, v4231   (v428 ya NO falla)    counts: 1232 tablas · 7095 FK · 9512 índices

# h3-esquema-api-vs-modelo.txt   (API dev  vs  modelo, antes del sync de la API)
columnas: 9 defaults (SIAT×8 + restore_test_runs×1) + allergy.encounter_id   constraints +1   índices +1   → TOTAL 21

# comparación final (API sincronizada vs modelo)
## columns: solo apinew 0 · solo modelnew 0 · comunes 16904
## constraints: 0 · 0 · 17908      ## indexes: 0 · 0 · 9512      TOTAL diferencias: 0

# h3-siat-inserts-contra-base-limpia.json
base del modelo (sin defaults): dev → 23502 (created_at) y 23502 (status)   esta rama → OK, OK
base de la API (con defaults) : dev → OK, OK                                esta rama → OK, OK

# h3-ddl-sources.txt
Fuentes de DDL OK: `SQL/` y `NoSQL/` de la raíz son las únicas.   exit=0
=== database/SQL al día   =================== database/NoSQL al día   exit=0

# h4-pr-gate.txt  (tras el último push de las ramas de API y vault)
#51  CLEAN MERGEABLE (base: rama de #50)   #91  CLEAN MERGEABLE (base: rama de #90)
#676 MERGEABLE · BLOCKED por REVIEW_REQUIRED   — ningún repo reporta checks
```

## No cubierto

- **Prueba permanente de los `INSERT` de SIAT.** Se verificaron con una corrida puntual contra bases recién creadas; no queda un test en la suite que impida volver a depender de un default.
- **Dos parches que fallan al arrancar desde cero, antes y después** (no son de este cambio): `2026-07-25_v407_nullable_embedding_model_versions` necesita el esquema `vector_rag` (pgvector, que el Postgres de prueba no trae) y `2026-09-26_v4231_seed_insurer_accounts` necesita el catálogo de terminología sembrado. En el despliegue real pueden pasar; aquí no se pudo comprobar.
- **Los módulos NoSQL/pgvector/TimescaleDB** (`time_series`, `vector_rag`) no se aplicaron: el Postgres de prueba no los trae.
- **Efecto de los 5 parches de datos sobre datos reales.** Se aplicaron sobre una base vacía (sin efecto).
- **`yarn test:integration`, `yarn docs:validate`, `yarn docs:build` y la suite completa de la API.**
- **Notas de módulo del vault** (`M08`, `M09`, `M15`, `M41`: lista «Depende de») no incluyen las nuevas referencias a `forms`.
- **Mini-intérprete de `psql`.** El arranque desde cero usa un intérprete propio (solo `\set \timing \echo \ir \i \if \elif \else \endif \gset`), no `psql`. Reproduce `init-postgres.sh` pero **no es** el mismo programa; las diferencias de comportamiento de `psql` no se descartan.

## Desvíos del plan

1. El inventario por líneas del primer informe sobrestimaba lo que faltaba; se rehízo por sentencia.
2. **Objetos no previstos:** `allergy_intolerances.encounter_id` y las 5 columnas de `forms` (esta última entró a la API `dev` durante el trabajo). Se agregaron al alcance.
3. **`v4.2.8`:** la versión del modelo abortaba una base nueva; se reemplazó por la de la API y se cambió una aserción de prueba (reemplazada, no debilitada; ver el PR).
4. **Tipos de `jsonb`:** regenerar `options` rompía 7 usos; se resolvió con un `.types.ts` propio y `choiceOptionsOf()`.
5. **Catálogo ORM:** la mezcla fue quirúrgica porque regenerar entero trae deriva ajena del vault remoto (incluso borra dos archivos).
6. **`dev` de la API avanzó** (#669–#675 mergeados) durante el trabajo: se re-basó sobre `08a7ff8a`.
7. El plan preveía «Postgres desechable si es posible»: se hizo con `embedded-postgres` instalado solo en el scratchpad (fuera de los repos).
8. **Errores propios, corregidos:** el primer `prettier` no corrió (sin `node_modules`); un regex de mi verificador exigía terminar en `)`; la codificación de un archivo de evidencia; la primera comparación de columnas no colapsaba espacios.

## Riesgos residuales

- **Orden de merge.** Si #676 se mergea antes que los PR del modelo, `ddl:sources` volverá a fallar hasta que el modelo lo alcance. Y el `dev` actual del modelo sigue sin tener el vínculo factura ↔ reclamo.
- **Cambia lo que crea una base nueva.** Los defaults de SIAT y `restore_test_runs.objective_status` ya no existen en una base creada desde cero; las bases ya pobladas los conservan. El servicio fija los valores; si otro código inserta en esas tablas por su cuenta, fallará con `23502`.
- **Observaciones que no se tocaron:** las tablas SIAT quedan sin FK en `patient_profile_id`, `encounter_id` y usuarios (igual que el parche); `authz.resource_scope_grants.reasonText` existe en el modelo pero no en la entidad de la API (el modelo va adelante).
- **La verificación de base limpia no es el despliegue real.** Falta correr `yarn db:verify-clean-init` con Docker.

## Decisiones y ambigüedades

| # | Ambigüedad / decisión | Supuesto tomado | A quién confirmar |
|---|---|---|---|
| 1 | Los defaults de SIAT: ¿ampliar el generador o fijar los valores en el servicio? | Fijar en el servicio (cambio mínimo y local); no tocar el generador | Propietario |
| 2 | Tablas SIAT sin FK en `patient_profile_id`, `encounter_id` y usuarios | Replicar el parche tal cual | Propietario |
| 3 | `restore_test_runs.objective_status`: DEFAULT (API) vs «sin DEFAULT» (modelo) | Gana el modelo, que lo documenta a propósito | Propietario |
| 4 | Parches de datos en `SQL/patches` vs seeds | Quedan en `SQL/patches`; no se renombran (cambiaría su comportamiento en `init-postgres.sh`) | Propietario |
| 5 | `v4242` es de «datos de demo/local» y se aplica siempre | Se copia sin renombrar | Equipo de plataforma |
| 6 | Cambiar la aserción `n_check <> 1` de la prueba de v4.2.8 | Reemplazo con el requisito real (falla cerrado mientras la columna exista) | Propietario |
| 7 | PR apilados sobre #50 / #90 | Si se mergean primero, se reorientan a `dev` | — |
