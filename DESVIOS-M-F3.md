# Desvíos, supuestos y avisos — agente M-F3 (modelo SQL · internación / ADT)

Rama `claude/modelo-infra-f3` (sobre `claude/trusting-hawking-q3p12v`). Contrato: `CONTRATO-F2-F5.md`
§0.1 y F3.1/F3.2 del repo de documentación. Aplica *después* de F1, F1b y F5 operaciones.

Lo que entrega: bloques de F3 en `diagram_08_clinical.puml` (`encounter_locations`, `encounters`,
`placement_incidents`, `inpatient_census_days/_entries/_adjustments`), sus historias en
`diagram_10_audit.puml` y sus `CHECK_SQL`/`EXCLUDE_SQL`/WORM en `diagram_33_integrity.puml`, más el patch
`SQL/patches/2026-10-29_infraestructura_f3_clinical.sql`.

**No se tocó** `SQL/NN_*/0x_*.sql`, `SQL/_generation_report.md`, `SHA256SUMS.txt`, `model-manifest.yaml` ni
`apply_all.sql`: son del integrador. `gen_ddl.py` y `gen_integrity.py` se corrieron **sólo sobre una copia en un
directorio temporal** (también lo hace `test_infra_f3_clinical_contract.py`); de esa salida se copiaron al patch las
columnas, tablas, FKs simples e índices, y el test comprueba que el patch es copia fiel. El integrador debe
regenerar `SQL/08_clinical`, `SQL/10_audit`, `_integrity` y `docs/data-catalog` al mergear los `.puml`.

## 1. Supuestos (el contrato no los fija; verificar con la API)

| # | Supuesto | Dónde pesa | Qué pasa si es falso |
|---|---|---|---|
| S-1 | Las claves de concepto del módulo `clinical` son **exactamente** `LOCATION_ACTIVE`, `LOCATION_COMPLETED` (existen) y `LOCATION_RESERVED`, `LOCATION_CANCELLED` (nuevas, las nombra el contrato). Sus UUID (`deterministicId('clinical:<CLAVE>')`) están **escritos en los EXCLUDE** (el predicado de un EXCLUDE debe ser IMMUTABLE) | `ex_encounter_locations_*` | Si `clinical.concepts.ts` registra `LOCATION_RESERVED` con otra clave, la reserva no bloquea la cama y la restricción hay que recrear con el UUID correcto |
| S-2 | La forma de cama es `practice:LOC_FORM_BED` (63ef5a86-740b-5fc6-8b93-3010ed5067a8). El contrato nombra `LOC_FORM_BED`; F1 aún no tiene el `practice.concepts.ts` escrito | Backfill de `is_bed_assignment` | El backfill no marca nada (inocuo: antes de F1 no había camas) y la API pone la bandera al escribir |
| S-3 | «Censo cerrado» = `closed_at IS NOT NULL`. El contrato dice «OLD.status = CLOSED» pero no fija la clave del concepto `CENSUS_*`; no se adivinó un UUID | Guarda de inmutabilidad | La API **debe** fijar `closed_at` y `content_hash` en el mismo `UPDATE` que pone el estado CLOSED |
| S-4 | El escritor actual (`EncountersService.checkIn/close`) no manda `tenant_id` ni `is_bed_assignment` | Trigger `trg_encounter_locations_fill_tenant` | Sin el trigger, el NOT NULL rompería el check-in hasta que la API se actualice |
| S-5 | `inpatient_census_days.clinical_unit_id` es NOT NULL (un censo es por unidad; con la unidad NULL el UNIQUE no protegería nada) | `ux_inpatient_census_days_site_unit_date` | — |

## 2. Desvíos del contrato (todos suman; ninguno relaja)

1. **`inpatient_census_entries.tenant_id`** (el contrato no lo lista): hace falta para el RLS que el mismo contrato
   pide «en todas». También se agregó `UNIQUE (tenant_id, id)` donde otra tabla la referencia.
2. **Tercer EXCLUDE** `ex_encounter_locations_encounter_one_active_bed` (`encounter_id WITH =` donde la fila es cama
   ACTIVE, diferible): «el traslado deja un solo registro activo». Los otros dos dejaban pasar una fila ACTIVE con
   `period_end` ya puesto más otra ACTIVE disjunta.
3. **CHECK extra**, todos con nombre y en `diagram_33`: `ck_encounter_locations_bed_period_order` (fin ≥ inicio en
   camas → error 23514 claro en vez del 22000 de `tstzrange`); `ck_placement_incidents_justification_length` usa
   `length(btrim(…)) >= 20` (el contrato dice `length(…) >= 20`; es más estricto: 20 espacios no valen);
   `ck_placement_incidents_violations_array`; `ck_inpatient_census_days_counts` (contadores ≥ 0 y
   `beds_available + beds_blocked = beds_censable`, que es la definición del contrato «beds_blocked = la diferencia»);
   `ck_inpatient_census_days_closed_has_hash`; `ck_inpatient_census_adjustments_field_code` (las 12 columnas
   numéricas) y `_reason` (motivo no vacío, `new_value >= 0`).
4. **Triggers extra**: completar `tenant_id` desde el encuentro (S-4); **derivar `is_bed_assignment`** de la forma del
   espacio y **rechazar entradas de censo en un día cerrado** (ver §6, cierre de seguridad); un ajuste sólo cabe sobre un censo **cerrado**
   (mensaje `CENSUS_NOT_CLOSED`, 23514) y, si cita una entrada, de ese mismo día; historias con
   «sólo inserción + cierre de `valid_to`» (funciones de F1b). Los triggers de historia se llaman `trg_f3_fill_tenant`
   y `trg_f3_close_only` a propósito: la verificación final de F1b cuenta `trg_fill_tenant`/`trg_close_only` por
   nombre en toda la base (espera 8) y reaplicar F1b después de F3 fallaría si se llamaran igual.
5. **Nulabilidad que el contrato no marca.** NOT NULL: contadores del censo, `census_date`, `cutoff_at`, `status`,
   `field_code`, `previous_value`, `new_value`, `adjusted_by_user_id`, `authorized_by_user_id`, `violations_json`.
   NULLable: `placement_incidents.encounter_location_id` (la ubicación apunta al incidente y el incidente a la
   ubicación: así se insertan en cualquier orden), `closed_at`/`closed_by_user_id` (null = worker), `content_hash`
   (obligatorio si hay `closed_at`), `request_id`, `care_space_id` y `bed_category_concept_id` de las entradas.
6. **`EXCLUDE … DEFERRABLE INITIALLY IMMEDIATE` no se puede declarar en `diagram_33`**: `gen_integrity.exclude_concreto`
   no tiene dónde. El `05_constraints.sql` regenerado los crea *inmediatos* (y `DROP … IF EXISTS` + `ADD` al reaplicarlo
   los vuelve a dejar inmediatos); el patch los recrea diferibles si los encuentra no diferibles (probado). Propuesta
   para el integrador: un campo opcional `DEFERRABLE` en `EXCLUDE_SQL`. Mientras tanto, orden de aplicación:
   `05_constraints` → patches.
7. Se editaron además `diagram_10_audit.puml` (dos historias) y `diagram_33_integrity.puml` (un bloque), porque el
   contrato §6.2 asigna a cada agente «su bloque» en esos dos archivos. Sin cambios en el resto de `diagram_08`.

## 3. Lo que tiene que saber la API (A-F3) y el integrador

- **`SET CONSTRAINTS` necesita el nombre calificado**: `SET CONSTRAINTS clinical.ex_encounter_locations_bed_occupancy,
  clinical.ex_encounter_locations_encounter_single_bed, clinical.ex_encounter_locations_encounter_one_active_bed DEFERRED`
  (o `SET CONSTRAINTS ALL DEFERRED`: hoy son las únicas restricciones diferibles de toda la base (3 filas en `pg_constraint`)). Sin calificar, Postgres
  responde «constraint … does not exist» porque `clinical` no está en el `search_path` (encontrado al probar el A17).
- Mapa `constraint → reason` (`exclusion-constraint-reasons.ts`), todas SQLSTATE `23P01`:
  `ex_encounter_locations_bed_occupancy` → `BED_DOUBLE_OCCUPANCY`; `…_encounter_single_bed` y `…_one_active_bed` →
  `ENCOUNTER_ALREADY_HAS_BED`. CHECK (`23514`): `ck_encounter_locations_bed_period(_order)`,
  `ck_placement_incidents_justification_length` → `OVERRIDE_JUSTIFICATION_TOO_SHORT`. Censo cerrado: `23001`
  (`restrict_violation`) → `CENSUS_ALREADY_CLOSED`; ajuste sobre día abierto: `23514` con `CENSUS_NOT_CLOSED` en el texto.
- **Orden de un traslado**: cerrar el origen (`period_end = t`, `COMPLETED`) y luego abrir el destino `[t, ∞)` — o diferir
  las tres restricciones. Una reserva que pasa a ocupación debe cerrarse con `period_end = t` antes (o diferido) de abrir
  la ocupación `[t, ∞)` en la misma cama. A12 (cancelar traslado): cancelar el destino y reabrir el origen en ese orden.
- **RLS ahora cubre `encounter_locations`** (antes no tenía `tenant_id`): los jobs/lecturas sin contexto de tenant ven
  cero filas; usar el contexto SYSTEM (`app.system_context`). Con `RLS_ENFORCE=true`, `db:vendor` + `gen_entities`
  traen las columnas nuevas y `tenantId` NOT NULL.
- La historia es de sólo inserción: `HistoryRepository.append` puede insertar y cerrar `valid_to`; nada más.
- Los conceptos de F3 (`LOCATION_RESERVED`, `LOCATION_CANCELLED`, `ADT_*`, `LOC_CARE_*`, `PLC_INC_*`, `CENSUS_*`,
  `CEN_*`) se siembran en la API; respetar S-1.
- Mock seeds de `08_clinical.seeds.json` (16 `encounter_locations`, ninguna cama): se comprobó estáticamente que no
  cruzan tenants contra los espacios/sedes/unidades de `14_practice.seeds.json`; no se corrió `load_seeds`.

## 3b. Cierre de seguridad (segunda ronda, revisión del coordinador)

1. **Bypass del EXCLUDE por la bandera.** El predicado de los tres EXCLUDE depende de `is_bed_assignment`, que mandaba
   el cliente: `false` sobre una cama real saltaba «una cama, un paciente». Ahora `trg_encounter_locations_set_bed_flag`
   (BEFORE INSERT OR UPDATE) la **deriva** de `care_spaces.form_concept_id` e ignora lo que se mande: cama ⇒ `true`;
   otra forma, forma nula o sin espacio ⇒ `false`; **espacio inexistente ⇒ error 23503 (falla cerrado)**.
   - Lectura sin RLS: la función lleva `SET app.system_context = 'true'` y `SET search_path = pg_catalog, pg_temp`
     (no `SECURITY DEFINER`: no depende de quién sea el dueño ni de BYPASSRLS). Sólo lee la forma de un espacio por id;
     si es de otro tenant, la FK compuesta `(tenant_id, care_space_id)` rechaza la fila igual (probado con `mantra_app`).
   - Orden: corre después de `trg_encounter_locations_fill_tenant` (los BEFORE se ordenan por nombre).
   - En UPDATE se re-deriva sólo si cambió el espacio o la bandera: cerrar una estancia vieja no la reclasifica si el
     espacio cambió de forma después (no puede provocar un choque retroactivo).
   - Backfill ahora en las dos direcciones, antes de las precondiciones de solape: una fila heredada con `false` sobre
     una cama real se corrige a `true` y, si choca con otra, el patch aborta (probado reaplicándolo).
   - Efecto colateral buscado: una fila sin `care_space_id` nunca es cama, así que `ck_encounter_locations_bed_period`
     sólo puede disparar por período vacío; la rama «sin espacio» queda como defensa en profundidad.
   - **S-2 pasa a ser crítico**: si la clave `practice:LOC_FORM_BED` de la API difiere, ninguna fila sería cama y los
     EXCLUDE no protegerían nada. Confirmar la clave antes de desplegar.
2. **INSERT en un censo cerrado.** `trg_inpatient_census_entries_open_day` (BEFORE INSERT) rechaza con
   `restrict_violation` (23001) la entrada de un día con `closed_at` no nulo; día inexistente **o de otro tenant** ⇒ 23503
   (la búsqueda va acotada al tenant de la entrada, así no revela si un día ajeno existe o está cerrado). Lee con contexto
   SYSTEM de función, y con `FOR SHARE` para serializar contra el UPDATE que cierra el día: si el cierre confirma primero,
   la inserción lo ve; si la inserción va primero, el cierre espera. Los ajustes siguen siendo la única vía sobre un día
   cerrado. Aviso para la API: insertar **todas** las entradas antes del UPDATE de cierre, en la misma transacción o antes.
   Un `mantra_app` en el contexto de otro tenant recibe 23503 (antes lo frenaba la FK compuesta; ahora lo frena primero el
   trigger, con el mensaje «no existe para este tenant»).
3. `diagram_33` documenta ambos triggers en comentarios (gen_integrity no los expresa; viven sólo en el patch).
   `diagram_08` aclara que la bandera se deriva.

## 4. Qué NO cubre la base (queda en la API)

Un solo `ENC_IMP` en curso por paciente (`PATIENT_ALREADY_ADMITTED`); compatibilidad sexo/edad/cohorte/nivel de
cuidado; que la cama sea de forma `BED` y que `is_bed_assignment` coincida con ella; que la sede de la ubicación sea la
del espacio y la unidad del censo pertenezca a la sede; que el paciente del incidente sea el del encuentro; que las
entradas del censo se inserten *antes* de cerrar el día (la base rechaza modificar el día, no agregar entradas a uno
cerrado: la huella `content_hash` lo delataría); que `cutoff_at` sea la medianoche local de la sede.

## 5. Pruebas (reales; ver el commit)

`salud-db/tests/test_infra_f3_clinical_contract.py` (estático + generadores en directorio temporal) y
`test_infra_f3_clinical_db.py` (Postgres real: clona `alovida` en `m_f3_pytest`, aplica el patch, lo borra al final).
`F3_PATCH=<copia rota>` ejecuta la suite contra un patch mutado. Trece mutaciones probadas, todas hacen fallar la suite:
sin guarda de censo, la reserva no bloquea, EXCLUDE inmediatos, sin RLS en ubicaciones, sin FK compuestas, sin el EXCLUDE de
«una activa» y, del cierre de seguridad: sin trigger de derivación, derivación que confía en el cliente, derivación sin
contexto SYSTEM, derivación que no falla cerrado, sin trigger de entradas, entradas que dejan pasar si el día no existe y
entradas sin acotar al tenant.
