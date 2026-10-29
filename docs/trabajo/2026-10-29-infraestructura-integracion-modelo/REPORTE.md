# Integración del modelo — infraestructura hospitalaria (F1c, F2, F3, F4, F5)

Rama `claude/modelo-infra-integracion` (desde `origin/claude/trusting-hawking-q3p12v` = `0be7629`).
Versión asignada al conjunto: **v4.2.69** (el plano F1c propuso v4.2.68). Los `DESVIOS-*` de cada
agente están en `desvios/` (antes eran archivos de raíz).

## 1. Peldaños reales

| Peldaño | Resultado | Evidencia |
|---|---|---|
| Merge de las 7 ramas (f2, f3, f4, f5-clin, f5-sched, f5-fin, plano) + `aa1b3f5` de f5-fin | limpio tras resolver 6 conflictos de `.puml` | ninguna línea añadida por una rama falta en el resultado (comprobado por script contra cada rama) |
| `gen_ddl all`, `gen_integrity`, `gen_apply` | generado: 1 291 tablas (+26), 62 módulos, 21 con `05_constraints` | regenerar de nuevo no produce diferencias |
| Catálogo, manifest, checksums | `generate_catalog.py`; inventario con `model_inventory.py`; `SHA256SUMS.txt` 100/100 verifican | ver §6 |
| Base nueva (`m_integ`) como `postgres-init` | **construida**: `apply_all` + `apply_deferred` + NoSQL 58/59 + los 126 archivos de `SQL/patches/` en orden de bytes, omitiendo `backfill` y `*_dev_seed` como hace el script (14 son de la serie) | ≈80 s el DDL + 15 s los patches |
| Misma base por la ruta de actualización | **idéntica**: base del modelo anterior (`0be7629` completo) + todos los patches | huella de catálogo de 68 333 líneas (columnas, restricciones con definición, índices, triggers, políticas, RLS, funciones, privilegios de `mantra_app` por tabla y columna): 0 diferencias |
| Idempotencia sobre la base integrada | **reaplicar todos los patches**: huella idéntica a la 1.ª pasada | 0 diferencias |
| `python -m pytest salud-db` completo contra base descartable | **369 passed**, 0 failed, 0 skipped (278 subtests) | `m_pytest` = clon de `m_integ`; F3 contra plantilla pre‑F3 (ver nota) |
| Sin base | 178 passed, 191 skipped (las de Postgres), 271 subtests | |
| Barrido de RLS y FK compuestas | 0 hallazgos nuevos; 3 conocidos y declarados (§5) | `sql/integ_10_sweep.sql` |
| Invariantes cruzadas | **51 `CASO OK`** | `sql/integ_20_cross_invariants.sql` |
| F5 clínico/diagnóstico | 7 `CASO OK` | `sql/integ_30_f5clin.sql` (M-F5-clin no dejó pruebas versionadas) |

Por archivo (una base clonada nueva cada vez, `m_integ` como plantilla): f2 106, generación 10,
f1c plano 41, f3 contrato 23, f3 db 54 (+7 de «abortos con datos incompatibles»; ver nota), f4
contratos 16, f4 db 30, f5‑fin 15, f5‑sched 17, integración 16, el resto 2–8.

**Nota F3.** Los 7 casos `TestAAbortsOnIncompatibleData` presuponen una plantilla *anterior* a F3
(siembran datos «heredados» y esperan que el patch aborte). Sobre la base integrada no tienen
sentido; con `F3_TEMPLATE_DB` = la base del modelo anterior (`0be7629` + sus patches) pasan los 61.

**No es una base de producción.** Todo corrió en PostgreSQL 18.6 + Timescale, en un clon de 160 MB
sin volumen; sin concurrencia real, sin EXPLAIN, sin la API.

## 2. Decisiones de resolución

1. **Conflictos** (`diagram_10`, `diagram_14`, `diagram_33`): ambos lados escribían entidades
   completas en el mismo punto y git los entrelazó; se tomó la versión local y se insertaron los
   bloques de la otra rama enteros (`diagram_08`, `diagram_41` y `diagram_20` no chocaron). Se
   verificó por script que no falta ninguna línea de ninguna rama.
2. **Un solo dueño.** `appointments.care_space_id` + FK + índice + `ex_appointments_care_space_time`:
   **F5‑clin**. `ux_schedulable_resources_tenant_id_id`: **F4** (`f4_scheduling`). `f5_scheduling`
   ya no los crea y *exige* el índice de F4 (aborta con mensaje si falta); su prueba estática
   se ajustó y exige que el EXCLUDE esté declarado una sola vez en `diagram_33`.
3. **Orden de patches** (`postgres-init` ordena por bytes, `C.UTF-8`): `f4_periop` → **`f4z_periop`**
   (necesita `f4_scheduling`) y `f5_diagnostics` → **`f5z_diagnostics`** (necesita `f5_operaciones`).
   En una base nueva el DDL generado ya trae lo que faltaría y el orden no se notaba; en una base
   actualizada sí (`f4_periop` abortaba). Una prueba fija las dependencias duras.
4. **Patches viejos que rompían la serie al reaplicarse** (postgres-init los reaplica *todos* en
   cada arranque; descubierto al reaplicar sobre la base integrada):
   - `2026-09-16_v4216`: contaba las 20 columnas totales de `encounters` (F3 suma 6) → cuenta las 2 suyas.
   - `2026-10-29_f1b`: contaba `trg_fill_tenant/trg_close_only` en toda la base (esperaba 8, hay 26) → solo en sus 3 historias.
   - `2026-10-24_v4249_organizacion_medica`: recreaba `ex_procedure_cases_operating_room_time` en cada arranque, que F4 reemplaza → se omite si existe el nuevo.
   - `f2` y `f4z`: el mensaje de prerrequisitos faltantes fallaba con `malformed array literal` justo al informar.
5. **DEFERRABLE.** Implementado: `EXCLUDE_SQL` admite una 4.ª parte (`DEFERRABLE`,
   `DEFERRABLE INITIALLY IMMEDIATE|DEFERRED`, `NOT DEFERRABLE`); lo desconocido sale como
   comentario. Los 3 EXCLUDE de `encounter_locations` la usan, el `05_constraints` generado ya
   los crea diferibles y el orden `05_constraints → patches` dejó de importar. Con test.
   **Consecuencia no obvia:** una tabla con UNIQUE/EXCLUDE diferible no admite `INSERT … ON CONFLICT
   DO NOTHING` sin objetivo (SQLSTATE 55000). `load_seeds.py` lo usaba y perdía las 16 filas de
   `encounter_locations`; ahora usa `ON CONFLICT (pk)` en esas tablas. La API debe hacer lo mismo.
6. **Seeds** (por el generador, no a mano): `gen_seeds.py` fase `[3e]` — el tenant de las hijas sale
   del padre (plantillas y excepciones ← recurso; ubicaciones ← encuentro; eventos de quirófano ←
   caso) y el caso con sala y sede de otro tenant recibe sala y sede de su tenant; los 7 pares
   `(caso, tipo)` repetidos los desambigua la fase `[4b]` con el único nuevo. Revisados 08, 10, 14,
   41, 53 (16 y 17 no tienen filas en las tablas nuevas). Cargado el paquete completo: **0 FK
   huérfanas** (antes 66) y las 16 `encounter_locations` entran. No se tocó una deriva
   preexistente de `02_common` (la fase `[4b]` reescribe 15 `addresses.owner_type_concept_id` en
   cada corrida; es de antes de la serie).
7. **Catálogo:** motivos de las 26 tablas nuevas (`DOMAIN_CURATED_DRAFT`, evidencia = su `.puml`).
   `SHA256SUMS.txt` estaba desfasado antes de la serie (49 de 100 no verificaban en `0be7629`): se recalculó entero.
8. **No se corrigió** (declarado, no oculto): 3 FK sin par compuesta de tenant (§5) y `cost_centers` /
   `infrastructure_items` sin RLS (no tienen `tenant_id`; D‑09 de F5‑fin).

## 3. Claves de concepto que la API debe declarar (nombres EXACTOS)

El UUID es `uuid5(3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60, "<módulo>:<CLAVE>")` (`deterministicId`) y
está **escrito como literal** en EXCLUDE, CHECK, índices parciales o triggers: si la clave o el
prefijo cambian, la restricción deja de proteger sin avisar. Comparado contra `src/modules/*/*.concepts.ts`
de **`dev`** (`git show dev:…`, calculando el UUID de cada clave).

**Con literal en la base y AUSENTES en `dev` — a declarar tal cual (riesgo CRÍTICO si difieren):**

| Clave (`defineModuleConcepts('<módulo>', …)`) | UUID | Dónde pesa |
|---|---|---|
| `practice:LOC_FORM_BED` | `63ef5a86-740b-5fc6-8b93-3010ed5067a8` | F3: deriva `is_bed_assignment`; sin él los 3 EXCLUDE de camas no protegen nada |
| `practice:HYG_CLEAN` | `7874b037-177f-5cac-adad-e7ba679d9ad3` | F2 backfill |
| `practice:ISO_NONE` | `f2ead1d9-06f7-59a3-b26f-a3642a164f47` | F2 backfill |
| `practice:BLOCK_MAINTENANCE` | `b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0` | F2 `ck_care_space_blocks_maintenance_eta` |
| `practice:CLN_PENDING` / `CLN_IN_PROGRESS` / `CLN_DONE` | `c0c5918f-cf97-51e1-9ede-72d856e61c93` / `60ff8df8-4ba5-591c-b092-e8da81187539` / `334b9e1f-b123-5477-a22e-2dd1b838c2fa` | F2 `ux_cleaning_orders_one_open_per_space` |
| `clinical:LOCATION_RESERVED` | `cdd86257-4297-5941-8ae8-b95e11439a48` | F3 EXCLUDE de camas (la reserva bloquea la cama) |
| `procedures_perioperative:ORB_ACTIVE` / `ORB_RELEASED` / `ORB_CANCELLED` | `762dc30b-…-5c511fd1d4a8` / `c3225706-ef13-5cbe-af6d-caaf25437458` / `e420cc84-8fd2-5887-a9bd-faf77d561508` | F4 EXCLUDE y CHECK de bloques |
| `procedures_perioperative:ORB_OWNER_SERVICE` / `ORB_OWNER_SURGEON` | `6b4fd1e9-892f-572b-9e9b-96b321ecdc26` / `48a989b7-6300-516d-9982-8f741aaf0758` | F4 CHECK de dueño |
| `billing:TARIFF_BED_DAY` / `TARIFF_OR_TIME` | `1ae01bf6-a061-52ed-aa26-590705cb2202` / `25eb53f6-8006-5959-bee9-65b16117bc9b` | F5e CHECK y guardas |
| `billing:CHG_SRC_BED_DAY` / `CHG_SRC_OR_TIME` | `5f84ea44-b0d3-582c-86c1-32c81e422d30` / `a79361f6-8787-56a5-9a90-a9436d02e217` | F5e únicos parciales de doble cobro |
| `billing:CHG_PENDING` / `CHG_INVOICED` / `CHG_VOIDED` | `17def99a-0cb5-586c-a440-59d809709c0d` / `9af061be-6a80-51ed-bcbd-52533037c272` / `f2f59654-d912-5eeb-b619-814e50a3c4d0` | F5e máquina de estados del cargo |
| `delegated_access:SCOPE_SPACE`, `ASSIGN_ROLE_UNIT_HEAD` | `4df1a147-cb37-55ba-94e8-ab469e9cccb0`, `ce54425b-5479-57f1-8bb2-274a8617723c` | F5g (de la base anterior) |
| `pharmacy_inventory:LOCATION_TYPE_WARD_STOCK` | `51dd3c8b-d630-5f5a-8bf4-2b9366752a73` | F5c `ux_inventory_locations_ward_stock_unit` |

**Con literal y YA coincidentes en `dev` (verificado por UUID):** `practice:SPACE_OP_AVAILABLE`
(`7ce5a926-…`), `clinical:LOCATION_ACTIVE` (`809db700-…`), `clinical:LOCATION_COMPLETED` (`8cf00069-…`),
`clinical:APPOINTMENT_BOOKED` (`51530fd7-…`), `clinical:APPOINTMENT_CHECKED_IN` (`37dded87-…`),
`delegated_access:SCOPE_SITE` / `SCOPE_UNIT`, `pharmacy_inventory:LOCATION_ACTIVE`, `state:active`
(`38a1d301-…`; cost centers y recursos agendables), `periop:case-status:scheduled|ready|in-progress`
(`6fe38139-…`, `f6985cd5-…`, `fdc78cc9-…`), `scheduling:resource-type:room` (`2e3d1a52-…`).

**Sin literal en la base (la API las nombra; el modelo no depende):** `clinical:LOCATION_CANCELLED`,
`ADT_*`, `LOC_CARE_*`, `PLC_INC_*`, `CENSUS_*`, `CEN_*`; `practice:LOC_FORM_*` (resto), `SPACE_FN_*`,
`CLN_*` tipos; `scheduling` `EXC_SRC_MANUAL | CARE_SPACE_BLOCK | EQUIPMENT_STATUS`. El plano F1c
**no define conceptos** (sus tipos son `varchar` + CHECK); su seed de ejemplo busca por código
`practice:LOC_FORM_*`, `SPACE_FN_*` y `SPACE_ACTIVE`.

### Riesgos del cruce con la API (`dev`)

- **CRÍTICO — nada de la lista «ausentes» existe en `dev` hoy**, ni siquiera `practice:LOC_FORM_*` de F1
  (la rama `claude/api-infra-f1` tampoco lo declara). No hay clave *distinta* para lo mismo (no se
  encontró una variante en `dev`), pero hasta que se declaren con estos nombres: las camas no se
  reconocen como tales (los EXCLUDE de F3 no protegen), el EXCLUDE de quirófanos/bloques y el cargo
  devengado no pueden escribir estados, y `practice` no puede sembrar el backfill de F2.
- **CRÍTICO si se elige otro prefijo:** `billing:CHG_*` convive en `dev` con códigos `CHG_*` de gestión
  de cambios (`CHG_DRAFT`, `CHG_APPROVED`…) en `common/constants/concepts.ts`. La *clave* (`billing:`)
  es la que fija el UUID; el `code` del concepto debe ser distinto (p. ej. `BILL_CHG_PENDING`) para no
  chocar en el sistema de códigos.
- **ALTO — mapa de errores:** `dev` no tiene `exclusion-constraint-reasons.ts`; su filtro traduce
  `23503`→422, `23514`→400, `23505`→409, `23P01`→409 genérico («se pisa con otra cita del mismo
  profesional»: mensaje equivocado para camas, quirófanos o consultorios) y **`23001` (restrict_violation)
  no está mapeado → 500**. El modelo usa `23001` para mutación de rastros, censo cerrado, cargo
  emitido y tarifa en uso.
- **ALTO — `ON CONFLICT DO NOTHING` sin objetivo** sobre `clinical.encounter_locations` falla (55000).
- `SET CONSTRAINTS` necesita el nombre calificado (`clinical.ex_encounter_locations_*`).

## 4. Mapa constraint → reason → SQLSTATE → HTTP (para `exclusion-constraint-reasons.ts` y el filtro)

HTTP propuesto según las notas de cada agente; donde `dev` hoy responde otra cosa se indica.
**Regla general:** `23503` por cruce de tenant → 404 sin revelar el motivo (el nombre de la
restricción distingue «no existe» de «es de otro tenant»); `23514` de CHECK → 422 con `reason` derivado
del nombre; no reenviar `SQLERRM`.

| Restricción | SQLSTATE | reason | HTTP |
|---|---|---|---|
| `ex_care_space_blocks_time` | 23P01 | `BLOCK_OVERLAP` | 409 |
| `ex_encounter_locations_bed_occupancy` | 23P01 | `BED_DOUBLE_OCCUPANCY` | 409 |
| `ex_encounter_locations_encounter_single_bed`, `…_one_active_bed` | 23P01 | `ENCOUNTER_ALREADY_HAS_BED` | 409 |
| `ex_procedure_cases_operating_room_reserved_time` | 23P01 | `OPERATING_ROOM_SLOT_CONFLICT` | 409 |
| `ex_operating_room_blocks_time` | 23P01 | `OR_BLOCK_OVERLAP` | 409 |
| `ex_appointments_care_space_time` | 23P01 | `CARE_SPACE_DOUBLE_BOOKED` | 409 |
| `ex_appointments_practitioner_time` (existente) | 23P01 | el actual | 409 |
| `ex_space_tariffs_validity` | 23P01 | `TARIFF_OVERLAP` | 409 |
| `ex_care_space_category_periods_validity` | 23P01 | `BED_CATEGORY_PERIOD_OVERLAP` (propuesto) | 409 |
| `ex_space_placements_no_overlap` (plano) | 23P01 | `SPACE_PLACEMENT_OVERLAP` (propuesto) | 409 |
| `ux_cleaning_orders_one_open_per_space` | 23505 | `CLEANING_ORDER_ALREADY_OPEN` (propuesto) | 409 |
| `ux_schedulable_resources_care_space_active` | 23505 | `RESOURCE_ALREADY_EXISTS_FOR_SPACE` | 409 |
| `ux_inpatient_census_days_site_unit_date` | 23505 | `CENSUS_ALREADY_EXISTS` (propuesto) | 409 |
| `ux_surgical_safety_checklists_case_type` | 23505 | `CHECKLIST_ALREADY_EXISTS` (propuesto) | 409 |
| `ux_charge_captures_idempotency_key`, `…_bed_night`, `…_encounter_bed_day`, `…_or_case` | 23505 | idempotencia: `ON CONFLICT (tenant_id, idempotency_key) DO NOTHING` en el job; fuera del job `CHARGE_ALREADY_CAPTURED` | 409 |
| `ux_cost_centers_unit_active` | 23505 | `UNIT_ALREADY_HAS_COST_CENTER` | 409 |
| `ux_inventory_locations_ward_stock_unit` | 23505 | `UNIT_ALREADY_HAS_WARD_STOCK` (propuesto) | 409 |
| `ck_placement_incidents_justification_length`, `ck_encounter_locations_bed_period(_order)` | 23514 | `OVERRIDE_JUSTIFICATION_TOO_SHORT` / `INVALID_BED_PERIOD` | 422 |
| resto de `ck_*` (67 en la serie) | 23514 | `CHECK_VIOLATION:<nombre sin ck_>` | 422 (`dev` hoy: 400 genérico) |
| `fk_space_tariffs_service_catalog_id` (compuesta práctica/servicio) | 23503 | `TARIFF_SERVICE_NOT_IN_PRACTICE` | 422 |
| FK compuestas `fk_*_tenant_*` y triggers de coherencia de sede/tenant | 23503 | no revelar | 404 (`dev` hoy: 422) |
| `trg_inpatient_census_entries_open_day`, guardas de censo cerrado | 23001 | `CENSUS_ALREADY_CLOSED` | 409 (`dev` hoy: 500) |
| ajuste sobre un día abierto (`CENSUS_NOT_CLOSED` en el texto) | 23514 | `CENSUS_NOT_CLOSED` | 422 |
| `trg_charge_captures_guard` (emitido editado, anulado tocado, identidad) | 23001 | `CHARGE_ALREADY_INVOICED` (pre-validar) | 409 (`dev` hoy: 500) |
| `trg_charge_captures_guard` (precio ≠ tarifa, tarifa no vigente) | 23514 | `CHARGE_PRICE_MISMATCH` (propuesto) | 422 |
| `trg_space_tariffs_guard` (tarifa en uso reescrita) | 23001 | `TARIFF_IN_USE` (propuesto) | 409 |
| eventos de estado, historias, rastro del censo: UPDATE/DELETE | 23001 | `APPEND_ONLY` | 409 (`dev` hoy: 500) |
| `trg_*_dependents` (mover un espacio/unidad/sede de práctica con dependientes) | 23001 | `HAS_DEPENDENTS` (propuesto) | 409 |
| RLS (`app.current_tenant_id` ausente o ajeno) | 42501 | — | 404/403 según contexto |

## 5. Hallazgos que quedan abiertos (no se ocultaron ni se «arreglaron» fuera de alcance)

- **R2 del barrido (3 FK sin par compuesta de tenant):** `billing.charge_captures.encounter_id →
  clinical.encounters` (lo cubre `trg_charge_captures_guard`, 23503, probado por F5‑fin; no es una FK),
  `scheduling.schedulable_resources.practice_id → practice.practices` y
  `scheduling.schedule_templates.booking_policy_id → scheduling.booking_policies` (columnas anteriores a
  la serie; hoy solo la API valida la pertenencia). El test falla ante cualquier hallazgo *nuevo* y si un
  conocido desaparece.
- **Tablas sin `tenant_id` ni RLS:** `cost_centers`, `infrastructure_items`, `service_requests`,
  `specimen_collection_events`, `imaging_procedure_steps` (usan `custodian_tenant_id` o cuelgan de
  otra); la coherencia sede/sala/equipo la garantizan triggers y CHECK, **quién escribe qué** es de la API.
- Hay `scheduling.schedule_rules`, `bookable_slots`, `slot_holds`, `booking_*`, `waitlist_entries`
  sin `tenant_id` (F5‑sched lo anotó).
- Las ~120 `audit.*_history` anteriores a F1b siguen sin `tenant_id`.
- F5‑sched: dos plantillas sobre el mismo consultorio y hora no se impiden en la base (solo las citas).

## 6. Qué NO se verificó

- Nada contra la **API ni el web**: no se corrió `db:vendor`, `gen_entities`, ningún `int-spec`, ni el
  siembra de conceptos; los nombres de §3 son contrato, no hechos comprobados con ejecución.
- Concurrencia real (dos sesiones) y rendimiento/EXPLAIN de índices, gist y triggers; tiempos de
  `ADD CONSTRAINT`/FK sobre tablas grandes de producción (las bases tienen decenas o miles de filas).
- Un despliegue sobre una base con **datos reales** o con los seeds `mock` *antes* de los patches
  (los patches abortan con detalle si hay filas incompatibles; probado por los agentes con fixtures).
- `postgres-init` real en contenedor (`docker compose run`): se replicó su script con `psql` (mismo orden,
  mismas omisiones de `*_dev_seed.sql` y `*backfill*`), no se ejecutó la imagen. El paso `mantra_app LOGIN`
  no se ejercitó.
- `alovida` no se tocó (estaba en uso: ningún clon la usó como plantilla).
- La localización `en_US` del glob de `postgres-init`: la imagen usa `C.UTF-8`; con otra el orden de
  `f1` frente a `f1b_seguridad` ya dependía de ello antes de esta serie.
- Los `.puml` no se renderizaron con PlantUML (sin binario): los validan los generadores.
- Pruebas por mutación solo las de cada agente (F3 13, F5‑fin 4); no se mutó el barrido propio.

## 7. Cómo reproducirlo

```bash
export SALUD_WORKSPACE=<carpeta con «Mantra Core Health Vault» → repo de documentación>
python salud-db/gen_ddl.py all && python salud-db/gen_integrity.py && python salud-db/gen_apply.py
# base nueva: apply_all.sql → apply_deferred.sql → NoSQL/58 y 59 → SQL/patches/*.sql (orden de bytes)
SALUD_TEST_PGDATABASE=<base descartable> python -m pytest salud-db      # 369 passed
```
