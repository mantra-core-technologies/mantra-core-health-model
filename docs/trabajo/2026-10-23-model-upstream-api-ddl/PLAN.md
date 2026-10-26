# Plan — Subir al modelo el DDL que solo vive en la API (objeto por objeto)

- Fecha: 2026-10-23 · Repos afectados: `mantra-core-health-model` (principal), `mantra_core_technologies_health_docs` (notas FK/entidad), `mantra-core-health-api` (entidades, catálogo, copia vendorizada, 1 servicio) · Predecesor: PR modelo #50, vault #90, API #672 y #675 (todos abiertos; este trabajo se apila encima)
- Resultado observable: `python salud-db/gen_ddl.py all` + `gen_integrity.py` sobre el modelo producen **todo** el esquema que la API despliega; `yarn ddl:sources` de la API sale en **exit 0**; `rsync --delete` ya no borra DDL real.
- Kill-test: tras regenerar, `stmt-diff` entre `database/SQL` de la API y `SQL/` del modelo sigue listando una sentencia que solo está en la API (excepto las diferencias de default declaradas abajo) → no está hecho.

## Cómo se llegó a esta lista

La comparación por **líneas** daba falsos positivos (el orden cambia). Se midió a nivel de **sentencia SQL normalizada** (`stmt-diff.py`, sin comentarios ni orden). Resultado verificable en `evidencia/h0-inventario.md`.

## Alcance — qué objeto va a dónde

### A. Esquema → se declara en los `.puml` y se regenera (+ su parche fechado)
| # | Objeto | Origen en la API | Declaración en el modelo |
|---|---|---|---|
| A1 | `directory.branches.description` (text) y `.location_url` (varchar 2000), nullables | parche v4243 | `diagram_04_directory.puml` |
| A2 | `clinical.medication_requests.indication_text` (varchar 200), nullable | parche v4238 | `diagram_08_clinical.puml` |
| A3 | `form_instance_id` (uuid, nullable, FK → `forms.form_instances`, IX) en `clinical.medication_requests`, `clinical.service_requests`, `chart.care_plans`, `scheduling.appointment_bookings` | parche v4232 | `diagram_08`, `diagram_15_chart`, `diagram_41` + stub `REFERENCE_ONLY` de `forms.form_instances` |
| A4 | `scheduling.appointment_bookings.follow_up_of_booking_id` (uuid, nullable, FK autorreferente, IX) | parche v4237 | `diagram_41_scheduling.puml` |
| A5 | Tablas `billing.siat_simulated_invoices` y `billing.siat_simulated_outbox` con PK, 3 FK, 5 índices (uno único parcial `WHERE status <> 'REJECTED'`) y 3 CHECK | parche v4244 | `diagram_17_billing.puml` + CHECK_SQL en `diagram_33_integrity.puml` |

### B. Parches propios (RLS, datos, y los parches de A) → se copian **tal cual** a `SQL/patches/`
`ddl-sources.md` los declara legítimos ahí («RLS, seeds de desarrollo», a mano, fechado). Se conserva el nombre para no cambiar la identidad con que ya se aplicaron.

v4232 (A3) · v4236 (**RLS** `service_requests_performer_read`) · v4237 (A4) · v4238 (A2) · v4239–v4242 y v4246 (**datos**: agenda de centros, farmacia, especialidades, direcciones demo, designaciones) · v4243 (A1) · v4244 (A5) · v4245 (`schedule_rules.booking_mode_concept_id`: la columna ya está en el modelo, **falta su parche**).

### C. Ya equivalentes → no se sube nada
- 4 parches con otro nombre (`v4219/v4220` de la API ↔ `v4224–v4227` del modelo): **idénticos sentencia por sentencia**. Al sincronizar, los nombres viejos se retiran (no se pierde contenido).
- `restore_test_runs.objective_status`: el modelo ya tiene la columna; la API le puso `DEFAULT 'NOT_MEASURED'` y un CHECK en línea. El modelo documenta «**sin DEFAULT**» a propósito (el servicio siempre lo fija) y el CHECK ya está en `05_constraints`. **Gana el modelo.**
- `65_surveys`, `19_community`, `41_scheduling` (índices/FK de `schedule_rules`): ya idénticos; solo cambiaba el orden.

### OUT
Frontend. Cambiar la semántica de cualquier objeto. Agregar FK que la API no tiene (`patient_profile_id`, `encounter_id`, `created_by_user_id`, `updated_by_user_id` de las tablas SIAT quedan **sin FK**, igual que en el parche; se anota como observación). Ampliar el generador.

## Decisión de diseño que cambia el código de la API

El generador **solo emite defaults de `row_version` y de booleanos** (`DEFAULT_TRUE/FALSE`); no `now()`, `gen_random_uuid()` ni literales — por diseño («no se infieren defaults de negocio»). Las tablas SIAT dependen de ellos y `billing-simulated.service.ts` hace los `INSERT` **sin** `created_at`, `updated_at` ni el `status` del outbox. Una base creada desde cero fallaría con `NOT NULL`. **Se elige** que el servicio fije esos valores (cambio mínimo y local en 2 `INSERT`) en lugar de ampliar el generador. Las bases ya pobladas conservan sus defaults (superset inofensivo). `simulated` sí se declara `<<DEFAULT_TRUE>>`.

## Ambigüedades registradas
1. Los 5 parches de datos (v4239–v4242, v4246) pertenecen conceptualmente a los *seeds* (`seedsGenerales/`), pero moverlos exige rediseñar el pipeline de seeds. Supuesto: viven en `SQL/patches/` como el resto de lo «a mano, fechado». Confirmar: propietario.
2. Las tablas SIAT no declaran FK en `patient_profile_id`, `encounter_id` ni usuarios (decisión de la API). Supuesto: se replica tal cual. Confirmar: propietario.
3. El trabajo se apila: modelo sobre la rama de #50, API sobre la de #675, vault sobre la de #90. Si esos PR se mergean primero, se reorientan a `dev`.
4. `v4242` es de «datos de demo/local» y se aplica siempre en `init-postgres.sh`. Se copia sin cambio de nombre; renombrarlo a `*_dev_seed.sql` cambiaría su comportamiento.

## H0 — Línea base
**CA:** Dado el modelo en la rama de #50, cuando regenero sin cambios, entonces `SQL/17_billing` queda idéntico y la deriva ajena queda medida.
**DoD:** `evidencia/h0-*`.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H0.M1 | Worktrees (modelo/API) y workspace sintético con junctions | `paths.FK_DIR.exists()` | `python -c …` | HECHO |
| H0.M2 | Inventario por sentencia de las 14 archivos y los 16 parches | Cada objeto con destino A/B/C | `evidencia/h0-inventario.md` | HECHO |
| H0.M3 | Baseline `gen_ddl.py all` + `gen_integrity.py` + `gen_apply.py` sin cambios | Diferencia real solo en archivos ajenos conocidos | `git diff --numstat` | HECHO |
## H1 — El modelo declara el esquema (A1–A5)
**CA:** Dado el `.puml` editado, cuando regenero, entonces el DDL contiene cada objeto A1–A5 y `stmt-diff` no lista sentencias exclusivas de la API salvo defaults.
**DoD:** `stmt-diff` por archivo + `unittest`.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H1.M1 | A1 `branches` | 2 columnas nullable en `02_tables` | `grep` | HECHO |
| H1.M2 | A2 `medication_requests.indication_text` | 1 columna | `grep` | HECHO |
| H1.M3 | A3 `form_instance_id` ×4 + stub + 4 aristas + 4 IX | 4 columnas, 4 FK `forms.form_instances`, 4 índices | `grep -c` = 4/4/4 | HECHO |
| H1.M4 | A4 `follow_up_of_booking_id` + IX + FK propia | columna, índice y FK | `grep` | HECHO |
| H1.M5 | A5 tablas SIAT + índices + UK parcial | 2 `CREATE TABLE`, 5 índices, 3 FK | `grep` | HECHO |
| H1.M6 | A5 CHECK en `diagram_33` → `05_constraints` | 3 CHECK con el mismo nombre que la API | `gen_integrity.py` + `grep` | HECHO |
| H1.M7 | Regenerar DDL, integridad y apply; descartar deriva ajena | solo archivos de A1–A5 con diff real | `git diff --numstat` | HECHO |
| H1.M8 | Pruebas del generador | OK | `unittest` | HECHO |
## H2 — Parches (B)
**CA:** Dado `SQL/patches`, cuando se compara con el de la API, entonces el modelo contiene todos los parches propios de la API (salvo los 4 renombrados).
**DoD:** `diff <(ls) <(ls)` solo muestra los 4 renombrados.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H2.M1 | Copiar los 12 parches tal cual (byte a byte, LF) | `sha` iguales | `git hash-object` ambos lados | HECHO |
| H2.M2 | Cada sentencia de esquema de los parches de A existe en el DDL regenerado (con las diferencias de default declaradas) | 0 sentencias huérfanas | `patch-vs-ddl.py` | HECHO |
## H3 — Vault, API y sincronización
**CA:** Dado el modelo con A1–A5, cuando la API se resincroniza **con** `--delete`, entonces `yarn ddl:sources` sale 0 y solo se retiran los 4 parches renombrados.
**DoD:** `check_ddl_sources.py` exit 0 · `vendor-ddl.sh --check` limpio.
**Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H3.M1 | Vault: notas FK (≈7) y de entidad/índices (SIAT) | `resolve_fk` devuelve cada destino | `python -c …` | HECHO |
| H3.M2 | API: `gen_entities.py` + prettier para 04, 08, 15, 17, 41 | diff solo en lo previsto | `git diff --stat` | HECHO |
| H3.M3 | API: `orm:catalog` y filas del catálogo de entidades, solo lo propio | solo tuplas/filas nuevas | `git diff` | HECHO |
| H3.M4 | API: `INSERT` SIAT fijan `created_at`, `updated_at` y `status` del outbox | 0 columnas con default implícito | spec + `typecheck` | HECHO |
| H3.M5 | API: `rsync --delete` real desde el modelo | `ddl:sources` exit 0 | salida | HECHO |
| H3.M6 | API: `typecheck`, `build`, tests dirigidos, lint | verde | salidas | HECHO |
| H3.M7 | (si es posible) Base limpia: aplicar `apply_all` + `apply_deferred` + parches sobre un Postgres desechable | exit 0 sin errores | salida | HECHO |## H4 — Entrega y limpieza
| ID | Microtarea | CA (binario) | DoD | Estado |
|---|---|---|---|---|
| H4.M1 | 3 commits y 3 PR apilados (modelo, vault, API) | MERGEABLE, no draft | `gh pr view` | TODO |
| H4.M2 | REPORTE.md | existe | archivo | TODO |
| H4.M3 | Retirar **todos** los worktrees y carpetas `wt-*`/`ws-*` (incluida la suelta `wt-vendor-src-model`) | 0 restos | `ls -d wt-* ws-*` vacío | TODO |

## Riesgos y bloqueos previstos
| Riesgo | Impacto | Mitigación |
|---|---|---|
| Sin Docker ni Postgres | no se demuestra una base limpia | H3.M7 con un Postgres embebido desechable en el scratchpad; si falla, queda declarado |
| Cambiar el `INSERT` de SIAT rompe facturación simulada | regresión | solo agrega columnas con el valor que el default ponía; spec de los INSERT |
| Los 5 parches de datos modifican datos si se aplican en otro orden | datos distintos | no se renombran ni reordenan |
| El generador no soporta algo de A5 (`<>` en WHERE, `varchar(12)`) | aborta | se prueba al regenerar (H1.M5); fallback documentado |
| Dependencia de PR sin mergear | choques al mergear | PR apilados, base = rama del predecesor |

## Correcciones durante la ejecución (el plan original no las preveía)

1. **El inventario inicial por líneas daba falsos positivos** (el orden cambia). Se rehízo por sentencia SQL normalizada; `schedule_rules` y `65_surveys` ya coincidían.
2. **Dos objetos más que solo vivían en la API**, descubiertos al comparar bases arrancadas desde cero y no por lectura:
   - `clinical.allergy_intolerances.encounter_id` (+ FK + índice): la entidad la mapeaba y **no existía en ninguna base** (defecto latente: toda lectura de alergias fallaba). Parche nuevo `2026-10-23_allergy_intolerances_encounter_id.sql`.
   - 5 columnas de `forms` (parche `2026-10-05_v4238_forms_choice_field_options`, que entró a la API dev mientras se trabajaba).
3. **`v4.2.8` (billing_quotations)**: la versión del modelo **aborta una base nueva** (`check=0 (esperado 1)`); la de la API ya tenía el arreglo. Se sube la de la API y se **reemplaza** (no se debilita) la aserción de `test_v428_check_guard.py`: `n_check <> 1` → `n_check <> n_columna`, más dos pruebas nuevas. Evidencia: `h3-arranque-desde-cero-modelo-origin-dev.json`.
4. **El tipo `jsonb` → `unknown`**: regenerar `forms.dynamic_field_definitions.options` rompía 7 usos (`string[]`). Se resolvió con el patrón del repo (contrato en un `.types.ts` propio + `choiceOptionsOf()`), no editando la entidad a mano.
5. **El catálogo ORM y `entity-catalog.md` traen deriva ajena del vault** (el remoto va atrasado respecto del entorno que generó `dev`): se aplicaron solo las 20 tuplas y 2 filas de estos objetos.
6. **`dev` de la API avanzó mientras se trabajaba** (#669–#675 mergeados). Se re-basó el trabajo de la API sobre `08a7ff8a`.
7. **Verificación real de base limpia (H3.M7)**: se levantó un Postgres 18 desechable (paquete `embedded-postgres`, solo en el scratchpad) con un mini-intérprete de `psql` para reproducir `init-postgres.sh`. Resultado: la copia de la API y el modelo producen esquemas **idénticos** (0 diferencias en 16 904 columnas, 17 908 constraints y 9 512 índices).
