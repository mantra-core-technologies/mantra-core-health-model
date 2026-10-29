# DESVIOS · agente M-F5-fin (facturación día-cama, quirófano por tiempo, categoría de cama y contabilidad)

Contrato: `SALUD/Arquitectura/infraestructura-hospitalaria/CONTRATO-F2-F5.md` §F5e y §F5f
(repo de documentación). Rama `claude/modelo-infra-f5-fin`, base `0be7629`.
Este archivo anota **todo lo que se hizo distinto o además de lo que dice el contrato**, los
**supuestos** de los casos que el contrato deja abiertos y **lo que no se verificó**.

## 0. Qué hay y hasta qué peldaño llegó

| Pieza | Escrito | Aplicado 1.ª | Aplicado 2.ª | Pruebas |
|---|---|---|---|---|
| `diagram_14` · `care_space_category_periods` | sí | sí | sí (huella idéntica) | 19 casos SQL |
| `diagram_17` · `space_tariffs`, `charge_captures` | sí | sí | sí | 129 casos SQL |
| `diagram_10` · `space_tariffs_history`, `charge_captures_history` | sí | sí | sí | dentro de los 129 |
| `diagram_16` · `cost_centers.clinical_unit_id`, `infrastructure_items.care_space_id` | sí | sí | sí | 17 casos SQL |
| `diagram_33` · CHECK/EXCLUDE (20 reglas) | sí | sí | sí | idem |
| `2026-10-29_infraestructura_f5_{accounting,billing,practice}.sql` | sí | sí | sí | 9 escenarios de datos incompatibles + 3 mutaciones |
| Ronda 2: hallazgos de seguridad (§1b) | sí | sí (también como actualización de la versión anterior) | sí (huella idéntica) | 29 casos SQL + 3 mutaciones |

Base de prueba: `m_f5fin` = `CREATE DATABASE m_f5fin TEMPLATE alovida` (PostgreSQL 18.6, `localhost:5433`);
**no** se usó `alovida`. Orden de aplicación: el alfabético de `postgres-init` (accounting < billing < practice).

Pytest (`salud-db/tests`): ver §5. Reproducir: §6.

## 1. Desvíos del contrato (cada uno con su porqué)

| # | Qué | Por qué |
|---|---|---|
| D-01 | `billing.space_tariffs` lleva `tenant_id NOT NULL` (el contrato no lo lista). FK compuestas `(tenant_id, practice_id)`, `(tenant_id, care_space_id)`, `(practice_id, service_catalog_id)`. | Sin `tenant_id` el patrón RLS de `2026-08-05_tenant_rls.sql` no la cubre y una tarifa podría cruzar tenants. Pedido del encargo («tenant_id + FK compuestas + RLS donde corresponda»). |
| D-02 | `billing.charge_captures.minimum_stay_charge boolean NOT NULL` (columna nueva). | Hace falta para distinguir el día mínimo de «ingreso y egreso el mismo día» de una **noche**. Sin ella el único «cama + noche» pedido en el encargo rechazaría al paciente de 08:00–18:00 si otro duerme esa noche en la misma cama (probado en B.4). |
| D-03 | `UNIQUE (tenant_id, idempotency_key)` en lugar de `UNIQUE (idempotency_key)`. | Un único global deja que un tenant averigüe si una clave existe en otro. La clave lleva el UUID del encuentro, así que no cambia nada para la API. |
| D-04 | Además de la clave, tres únicos parciales (no anulados), **todos con `tenant_id` por delante** (ronda 2): `(tenant_id, encounter_id, service_date)` y `(tenant_id, care_space_id, service_date)` para día-cama no mínimo, y `(tenant_id, source_ref_id)` para quirófano. | INV-42 pide «base: único `(encounter_id, service_date)`» y el encargo pide «única por cama + noche». La clave sola no cubre dos servicios que arman la clave distinto. Anular libera la noche (corrección = cargo nuevo con clave nueva). |
| D-05 | `ux_service_catalog_practice_id_id` sobre `billing.service_catalog` (diagram_17) para la FK compuesta de la tarifa. | `TARIFF_SERVICE_NOT_IN_PRACTICE` queda garantizado por la base, no sólo por la API. |
| D-06 | `audit.space_tariffs_history` y `audit.charge_captures_history` con el molde endurecido de F1b (tenant NOT NULL + RLS + FK compuesta al origen + trigger de tenant + «solo inserción y cierre de `valid_to`»). **`care_space_category_periods` no tiene historia** (§0.1 pide historia a toda tabla mutable). | Es una tabla de vigencias que sólo crece y de la que sólo se cierra `valid_to` (trigger): ella misma es la historia. El contrato tampoco le asigna historia en la tabla de F5e. |
| D-07 | Guardas por trigger (SECURITY INVOKER, `SET search_path`): **nada se borra** (períodos, tarifas, cargos); de un período sólo se cierra `valid_to`, una vez; una tarifa con cargos no se reescribe ni se cierra antes de una fecha ya devengada; el cargo es la **foto exacta** de su tarifa (tipo, vigencia en `service_date`, servicio, precio, moneda, sala/categoría); un cargo **emitido no se edita** y sólo se anula con motivo (máquina de estados PENDING→INVOICED/VOIDED, INVOICED→VOIDED, VOIDED terminal). | Proceso 11 («nunca se edita un cargo emitido», corrección por nota de crédito) e INV-14 (sin borrado físico). Si la API necesita relajar alguna, es un cambio de este patch, no un workaround. |
| D-08 | CHECK derivados del proceso 11 / contrato: día-cama sin `unit_minutes` ni `minimum_units` (nunca «0,5 días») y `quantity = 1`; día-cama exige categoría **o** sala (no hay tarifa «por defecto»: categoría desconocida = error de configuración); tarifa de quirófano sin categoría de cama; `unit_price >= 0`; cargo con precio ⇒ tarifa + servicio + moneda; INVOICED ⇒ precio y línea; PENDING ⇒ sin línea; VOIDED ⇒ motivo no vacío. | Lo dice el proceso 11 («NO PUEDE convertir unidades de forma que aparezcan fracciones de día», «no se usa otra tarifa en silencio»). |
| D-09 | `cost_centers` e `infrastructure_items` **no tienen `tenant_id`** (cuelgan de `practice_id`): no hay RLS nuevo ni FK compuesta por tenant. En su lugar, triggers que exigen que la sede del espacio / de la unidad sea de la **misma práctica** (más estricto que mismo tenant), `23503`. | Misma solución que F5 operaciones (tablas sin `tenant_id`). Agregarles `tenant_id` es otra decisión, fuera de F5f. |
| D-10 | `ux_cost_centers_unit_active` usa `state:active` (`38a1d301-f40d-5b17-a695-5e6d605f8b19`, `CONCEPTS.STATE_ACTIVE`) como ⟨activo⟩. | `accounting` usa el ACTIVO genérico (`accounting.concepts.ts`); el contrato no nombra otro. |
| D-11 | Se editaron además `diagram_10_audit.puml` y `diagram_33_integrity.puml` (bloques propios, al final / junto a `visit_requests_history`), no sólo 14, 16 y 17. | §6.2 del contrato: cada agente agrega **su bloque** en 33 y 10; el integrador resuelve el merge. `SQL/NN_*`, `_generation_report.md`, `SHA256SUMS.txt`, `model-manifest.yaml` y `apply_all.sql` **no se tocaron**. |
| D-12 | Los patches se llaman `…_f5_accounting`, `…_f5_billing`, `…_f5_practice` (el contrato nombra sólo practice y billing). `f5_billing` aborta si falta `ux_cost_centers_practice_id_id` (lo crea `f5_accounting`) o las funciones `audit.structure_history_*` (F1b). | El orden alfabético de `postgres-init` ya satisface la dependencia; el aborto evita aplicarlos en otro orden. Ninguno lleva «backfill» en el nombre (`init-postgres.sh` los omite en base nueva). |

### Acoplamiento con la API (hay que reconciliar)

Los UUID literales de los conceptos **son** `deterministicId('billing:<NOMBRE>')`
(algoritmo verificado contra dos valores que ya usa F5 operaciones):

| Clave | UUID |
|---|---|
| `billing:TARIFF_BED_DAY` | `1ae01bf6-a061-52ed-aa26-590705cb2202` |
| `billing:TARIFF_OR_TIME` | `25eb53f6-8006-5959-bee9-65b16117bc9b` |
| `billing:CHG_SRC_BED_DAY` | `5f84ea44-b0d3-582c-86c1-32c81e422d30` |
| `billing:CHG_SRC_OR_TIME` | `a79361f6-8787-56a5-9a90-a9436d02e217` |
| `billing:CHG_PENDING` | `17def99a-0cb5-586c-a440-59d809709c0d` |
| `billing:CHG_INVOICED` | `9af061be-6a80-51ed-bcbd-52533037c272` |
| `billing:CHG_VOIDED` | `f2f59654-d912-5eeb-b619-814e50a3c4d0` |

`billing.concepts.ts` (`defineModuleConcepts('billing', …)`) debe definir **exactamente esas claves**.
Si el agente de API elige otras, los literales de `diagram_17`, `diagram_33` y `f5_billing.sql` cambian
juntos (el test `test_billing_concept_literals_are_deterministic_ids` ya los ata al algoritmo).

## 1b. Ronda 2 · hallazgos de seguridad (commit posterior, sin amend)

**Hallazgo 1 · alcance de unicidad entre tenants.** `ux_charge_captures_or_case` era único global sobre
`(source_ref_id)`: un tenant que registrara un cargo con el id de un caso de otro lo bloqueaba (o delataba
que existe).
* Los tres únicos de `charge_captures` llevan ahora `tenant_id` primero (`diagram_17` y `f5_billing.sql`). Un
  `diagram_33` no cambia: son índices, no CHECK/EXCLUDE. El patch reemplaza los índices de la versión anterior
  (si el `indexdef` no empieza por `tenant_id`) antes de crear los nuevos; el nuevo es más débil que el viejo, así
  que ninguna fila existente lo viola.
* `billing.charge_source_case_ok(tenant, práctica, caso)`: el `source_ref_id` de un cargo de quirófano tiene que
  ser un `procedure_cases` con `custodian_tenant_id` = tenant del cargo y sede (o, si no tiene, sala de
  operaciones) en una sede de la práctica del cargo. **Falla cerrado**: inexistente, ajeno, de otra práctica o sin
  sede ni sala = `false` → `23503` (mismo error y mismo texto para «ajeno» que para «inexistente»).
  Lee con contexto de sistema, pero **sólo se eleva si la sesión es SYSTEM o el tenant consultado es el de la
  sesión**: un tenant no puede usar la función como oráculo (probado como `mantra_app`). Restaura
  `app.system_context` al salir.
* `charge_captures_guard` rechaza con `42501` (igual que el `WITH CHECK` del RLS) un cargo cuyo `tenant_id` no es
  el de la sesión, **antes** de mirar el caso o el encuentro: sin eso, la diferencia `42501`/`23503` delataba
  existencia. Los roles con `BYPASSRLS`/superusuario quedan exentos, como en el RLS.
* Los otros dos únicos (encuentro+noche, cama+noche) tenían el mismo defecto de alcance en teoría; en la práctica
  el guard y la FK compuesta `(tenant_id, care_space_id)` ya impedían el cruce. Se acotaron igual
  (defensa en profundidad, probada con el guard apagado).
* Precondición nueva: se aborta si ya hay cargos de quirófano cuyo origen no es un caso del mismo tenant y
  práctica.

**Hallazgo 2 · invariante «misma práctica» en una sola dirección.** Se comprobaba sólo al escribir la fila hija.
Ahora, también al mover el padre:
* `accounting` (`f5_accounting.sql`): `trg_care_spaces_accounting_dependents`
  (`care_spaces.practice_site_id`, con activos), `trg_clinical_units_accounting_dependents`
  (`clinical_units.practice_site_id`, con centros de costo) y `trg_practice_sites_accounting_dependents`
  (`practice_sites.practice_id`, con espacios con activos o unidades con centros de costo).
* `billing` (`f5_billing.sql`): `trg_care_spaces_billing_dependents` y `trg_practice_sites_billing_dependents`
  (tarifas y cargos).
* **Decisión:** se rechaza sólo si el cambio **cruza práctica** (la práctica de la sede nueva ≠ la de la vieja) y
  hay dependientes. Mover un espacio o una unidad entre sedes de la **misma** práctica, o mover cualquiera sin
  dependientes, sigue permitido (flujo de F1; probado). `SQLSTATE 23001`. Mensajes de texto fijo, sin ids ni
  datos. La lectura de dependientes usa `SET app.system_context = 'true'` a nivel de función (restauración
  automática); sólo consulta los dependientes de la fila que se actualiza.
* Precondición nueva: se aborta si ya hay tarifas o cargos cuya sala es de una sede de otra práctica (las de
  `cost_centers` / `infrastructure_items` ya existían).

**Pruebas de la ronda 2:** `tests/sql/f5_fin_40_scope_test.sql` (29 casos) y `tests/sql/mutations/` con **una
mutación por hallazgo**; `test_4_mutations_remove_one_fix_each_and_the_scope_test_fails` comprueba que, quitando el
arreglo, la prueba **falla** en su caso: `global_unique` (vuelve a los únicos globales; falla «otro tenant con el
mismo `source_ref_id` no choca»), `no_case_check` (la función devuelve siempre `true`; falla «B cita el caso de A»),
`no_parent_triggers` (se quitan los 5 triggers; falla «mover una cama con activo a otra práctica»). Más 3
escenarios de precondición de billing (9 en total).

## 2. Supuestos sobre los casos que el contrato deja abiertos

Todos probados con la consulta de referencia de `salud-db/tests/sql/f5_fin_30_billing_test.sql` (el job real
es del servicio de la API; la base sólo garantiza que no haya doble cobro y que cada cargo sea coherente).

| # | Caso | Supuesto adoptado |
|---|---|---|
| S-01 | **Ingreso y egreso el mismo día** (ninguna medianoche en toda la estancia) | `billing.bed_day_min_one = true` (el contrato lo da por defecto): **un** día-cama mínimo con `service_date` = fecha local del ingreso, en la **primera** cama, `minimum_stay_charge = true`. Si hay una medianoche en cualquier punto de la estancia no hay mínimo. El mínimo **no** es una noche: convive con el día-cama de otro paciente que duerme esa noche en la misma cama (B.4). |
| S-02 | **Permiso de salida con cama retenida** | El permiso no corta el período de ocupación: la cama retenida **devenga** las medianoches (la cama no está disponible para otro). Estancia 05/01 10:00 → 09/01 10:00 con permiso = 4 días-cama (B.5). Si el cliente decide no cobrar la retención, es otra regla del servicio. |
| S-03 | **Cama retenida en traslado a quirófano** | Igual que S-02: se cobra mientras la ocupación de la cama siga vigente. |
| S-04 | **Camas no censables** (observación, recuperación) | No devengan día-cama: la consulta de referencia sólo considera camas con categoría (`bed_category_concept_id` no nulo). La base **no** lo impide (la API decide por `censable` / función). |
| S-05 | Cambio de categoría **exactamente a medianoche** | Rige desde su instante (rango `[valid_from, valid_to)`): esa medianoche ya cobra la categoría nueva. Un cambio a media mañana (B.3) deja la medianoche anterior con la vieja. |
| S-06 | Egreso exactamente a las 00:00 | Esa medianoche **no** se cobra (`M < fin`); el día del egreso nunca se cobra (B.1). |
| S-07 | Medianoche «local» | Zona horaria de `practices.time_zone` (hoy `varchar` nullable). Si es NULL el servicio debe fallar con error de configuración; la base no asume zona. |
| S-08 | Corrección tras el cargo | Cargo pendiente: se recalcula in situ (cantidad, categoría, tarifa, precio, centro de costo). Cargo emitido: se anula con motivo y se devenga uno **nuevo con clave nueva** (`…:r2`). La clave del anulado no se reutiliza (D-03/D-04). |
| S-09 | Cambio de tarifa con vigencia futura | No altera cargos pasados (foto de precio). Una tarifa **usada** sólo se cierra, y no antes de la última fecha devengada con ella. |
| S-10 | Backfill de períodos | Una fila por cama con categoría desde `care_spaces.created_at`, abierta. Se asume que antes de este patch no hubo cargos que dependieran de la categoría. |

## 3. Lo que la API va a ver de la base (para el mapa `constraint → reason`)

| Objeto | SQLSTATE | Reason sugerido |
|---|---|---|
| `ex_space_tariffs_validity` | `23P01` | 409 `TARIFF_OVERLAP` |
| `fk_space_tariffs_service_catalog_id` | `23503` | 422 `TARIFF_SERVICE_NOT_IN_PRACTICE` |
| `trg_space_tariffs_guard` (sala de otra práctica) | `23503` | 404/422 |
| `trg_space_tariffs_guard` (tarifa en uso reescrita) | `23001` | 409 |
| `trg_space_tariffs_guard` (cerrar antes de lo devengado) | `23514` | 422 |
| `ex_care_space_category_periods_validity` | `23P01` | 409 (propuesto `BED_CATEGORY_PERIOD_OVERLAP`) |
| `trg_care_space_category_periods_guard` | `23001` | 409 |
| `ux_charge_captures_*` | `23505` | idempotencia: `INSERT … ON CONFLICT DO NOTHING`; fuera del job, 409 |
| `trg_charge_captures_guard` (emitido editado / anulado tocado / identidad) | `23001` | 409 `CHARGE_ALREADY_INVOICED` (pre-validar) |
| `trg_charge_captures_guard` (precio ≠ tarifa, tarifa no vigente, no aplica) | `23514` | 422 |
| `trg_charge_captures_guard` (encuentro/paciente/cama/línea de otro tenant o práctica) | `23503` | 404 |
| `ck_charge_captures_*`, `ck_space_tariffs_*` | `23514` | 422 |
| `ux_cost_centers_unit_active` | `23505` | 409 `UNIT_ALREADY_HAS_COST_CENTER` |
| `trg_infrastructure_items_space_practice` | `23503` | 422 `INFRASTRUCTURE_SPACE_PRACTICE_MISMATCH` |
| `trg_cost_centers_unit_practice` | `23503` | 404/422 |

Notas para el servicio de F1 (`PATCH /care-spaces/:id`): al cambiar `bedCategoryCode` **cerrar el período
abierto (`valid_to`) y abrir otro en la misma transacción** (probado como `mantra_app` con RLS). La base **no**
mantiene sola la coherencia entre `care_spaces.bed_category_concept_id` y el período abierto (ver §4).

## 4. Qué NO se verificó (ni se afirma)

* **`gen_ddl.py` / `gen_integrity.py` no se corrieron sobre el repo** (`SQL/NN_*`, informe, checksums,
  manifiesto y `apply_all.sql` intactos). Sí se usó el generador **fuera del repo**: en una copia en el
  scratchpad para obtener el DDL que el patch copia, y `gen_ddl.emit` en un directorio temporal dentro de
  `test_patch_statements_are_what_gen_ddl_emits_for_the_model`. Si el integrador regenera con otros `.puml`
  fusionados, el test de deriva dirá si el patch dejó de coincidir.
* **Reconstrucción completa** (`postgres-init` con todo el modelo regenerado) **no se ejecutó**. Sí: DDL generado de
  los módulos 10, 14, 16 y 17 + los tres patches sobre una copia de `alovida` → huella de catálogo **idéntica** a
  «sólo patches» (base desechable, ya borrada).
* **No hay API**: el job de medianoche, `issueFromEncounter`, `void`, los endpoints de tarifas y el cálculo de
  minutos de quirófano son del servicio. Lo de acá es una **consulta de referencia en un test**, no una función del modelo.
* La base **no** verifica que `service_date`, la sala o la categoría de un día-cama coincidan con la ocupación
  (`encounter_locations`, polimórfico, de M-F3) ni con el período de categoría de esa medianoche.
* **Coherencia `care_spaces.bed_category_concept_id` ↔ período abierto**: no garantizada por la base (el contrato la
  deja en el servicio de F1). Una cama cuya categoría cambió sin tocar los períodos factura con la vieja.
* **`cost_centers` e `infrastructure_items` sin RLS** (no tienen `tenant_id`, D-09).
* **Concurrencia**: probada a mano (dos sesiones `psql` solapadas, con y sin `ON CONFLICT DO NOTHING`: 3 filas,
  la segunda sesión sin `ON CONFLICT` falla con `23505`) en una base desechable; **no** está en pytest.
* `charge_source_case_ok` depende de `procedures_perioperative.procedure_cases(custodian_tenant_id, practice_site_id,
  operating_room_id)`. M-F4 puede cambiar ese módulo: si renombra o reemplaza esas columnas, la función y su prueba se
  ajustan. Un cargo día-cama no valida su `source_ref_id` (ocupación, de M-F3): no hay equivalente para ese origen.
* Los conceptos `TARIFF_*`/`CHG_*` no están sembrados en `alovida`: las pruebas insertan filas con esos UUID.
* Rendimiento de los índices y de los triggers: no medido. Un solo motor (PostgreSQL 18.6).
* Integración con M-F2, M-F3, M-F4, M-F5-clin, M-F5-sched y M-F5-ops: **no probada**. Riesgos de merge: `diagram_14`
  (otras entidades), `diagram_10` y `diagram_33` (bloques al final). La consulta de referencia usa
  `clinical.encounter_locations(period_start, period_end, care_space_id)`: si M-F3 cambia esas columnas, se ajusta el test.

## 5. Pruebas

| Capa | Archivo | Resultado |
|---|---|---|
| Estática + deriva del generador | `salud-db/tests/test_infra_f5_fin_contract.py` (`StaticContractTests`, 10) | 10 passed |
| Base real | `LiveDatabaseTests` (4): aplica 2 veces y compara huella; corre los 4 scripts SQL; 9 escenarios de datos incompatibles; 3 mutaciones | 4 passed |
| Casos SQL | `tests/sql/f5_fin_10_practice_test.sql` (19), `…20_accounting…` (17), `…30_billing…` (129), `…40_scope…` (29) | 194 «CASO OK», 0 «CASO FALLIDO» |

`pytest salud-db/tests`: **39 passed + 4 skipped** sin base; **43 passed** con `SALUD_TEST_PGDATABASE`
(`pytest salud-db`: 54 passed + 4 skipped / 58 passed). Antes de este trabajo eran 28 en `tests` (43 en `salud-db`).
Base nueva (`TEMPLATE alovida` sin patches) con los tres patches vs base actualizada desde la versión anterior de
los patches: huella de catálogo idéntica.

## 6. Cómo reproducir

```bash
cd /home/user/mantra-core-health-model
git worktree add /home/user/wt-m-f5fin claude/modelo-infra-f5-fin   # ya creado
export PGPASSWORD=local_dev_only PGHOST=localhost PGPORT=5433 PGUSER=mantra
psql -d postgres -c "CREATE DATABASE m_f5fin TEMPLATE alovida"       # reintentar si hay conexiones a alovida
cd /home/user/wt-m-f5fin/salud-db
SALUD_TEST_PGDATABASE=m_f5fin python3 -m pytest tests -q               # patches x2 + 194 casos + escenarios + mutaciones
python3 -m pytest tests -q                                             # sólo la capa estática (sin base)
```

Los scripts SQL terminan en `ROLLBACK`: no dejan filas. Cada `CASO OK [etiqueta] -> SQLSTATE` es una aserción;
un `CASO FALLIDO` aborta el script.
