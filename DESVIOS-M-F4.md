# Desvíos del agente M-F4 (modelo SQL · quirófanos)

Contrato: `SALUD/Arquitectura/infraestructura-hospitalaria/CONTRATO-F2-F5.md` §0.1 y §F4.1–F4.2.
Rama `claude/modelo-infra-f4` (desde `claude/trusting-hawking-q3p12v`). Fecha: 2026-10-29.

Entregables: `diagram_41_scheduling.puml` (solo `schedulable_resources`), `diagram_53_procedures_perioperative.puml`,
`diagram_10_audit.puml` (2 historias), `diagram_33_integrity.puml` (CHECK/EXCLUDE), los patches
`SQL/patches/2026-10-29_infraestructura_f4_scheduling.sql` y `…_f4_periop.sql`, y las pruebas
`salud-db/tests/test_infra_f4_contracts.py`, `test_infra_f4_db.py`, `_f4_pg.py`.
**No** se tocaron `SQL/NN_*/0x_*.sql`, `SQL/_generation_report.md`, `SHA256SUMS.txt`, `model-manifest.yaml`
ni `apply_all.sql`: el integrador corre `gen_ddl.py` / `gen_integrity.py`. El generador se corrió solo hacia un
directorio temporal y sus sentencias se copiaron al patch (una prueba comprueba que siguen coincidiendo).

## A. Donde el patch dice algo distinto del contrato

1. **UUID de los conceptos `ORB_*`.** El contrato escribe `⟨periop:ORB_ACTIVE⟩`; la clave real de
   `defineModuleConcepts('procedures_perioperative', …)` es `procedures_perioperative:ORB_ACTIVE`. Los UUID
   literales (EXCLUDE, CHECK, índice parcial) salen de esa clave con el algoritmo de la API (reproduce los tres
   UUID de estados de caso ya existentes y `state:active`; lo verifica `test_infra_f4_contracts.py`):
   `ORB_ACTIVE 762dc30b-3e3c-5e1e-8504-5c511fd1d4a8`, `ORB_RELEASED c3225706-ef13-5cbe-af6d-caaf25437458`,
   `ORB_CANCELLED e420cc84-8fd2-5887-a9bd-faf77d561508`, `ORB_OWNER_SERVICE 6b4fd1e9-892f-572b-9e9b-96b321ecdc26`,
   `ORB_OWNER_SURGEON 48a989b7-6300-516d-9982-8f741aaf0758`. **La API debe declararlos en
   `procedures_perioperative.concepts.ts` con ese prefijo**; si no, los UUID cambian y hay que regenerar el DDL.
2. **`ck_schedulable_resources_care_space_ref` es más estricto.** El contrato lo escribe
   `ref_type <> 'care_spaces' OR care_space_id = resource_ref_id`: con `care_space_id` NULL el resultado es NULL y
   el CHECK **pasa** (un recurso `care_spaces` sin FK real). Se cerró: `(ref_type = 'care_spaces') = (care_space_id
   IS NOT NULL) AND (care_space_id IS NULL OR care_space_id = resource_ref_id)`. Consecuencia: una fila heredada
   con `resource_ref_type = 'care_spaces'` cuyo espacio no existe (o es de otro tenant) incumple el CHECK; el patch
   la lista con `RAISE NOTICE`, no la toca y crea el CHECK `NOT VALID` (rige para toda fila nueva o modificada);
   sin filas así lo valida. Reaplicar `SQL/41_scheduling/05_constraints.sql` (que hace DROP + ADD válido)
   fallaría mientras queden esas filas.
3. **Ventana reservada: respaldo en el espacio.** El contrato dice `coalesce(prep_minutes, 0)` del caso. El
   trigger usa la preparación/limpieza del caso y, **si son NULL, las del espacio** (misma semántica que el comentario
   v4.2.49 del `.puml`: «NULL = las del espacio»). Sin ese respaldo, un insert directo sin foto dejaba pasar el
   solape del recambio. Para que un cambio posterior de `care_spaces.prep_minutes` no re-evalúe el EXCLUDE de los
   casos ya programados, la ventana solo se recalcula al insertar o cuando cambia alguna entrada (horario,
   preparación, limpieza, sala) o alguien toca `reserved_*`. El cliente no puede fijar `reserved_*`: se
   sobrescriben siempre.
4. **Nombre del EXCLUDE nuevo.** El contrato no lo nombra: `ex_procedure_cases_operating_room_reserved_time`
   (el viejo `ex_procedure_cases_operating_room_time` se elimina en el patch).

## B. Lo que se agregó sin que el contrato lo pida (todo con su prueba)

- **FK compuestas por tenant (patrón F1b)**, 15 en `…_f4_periop` y 1 en `…_f4_scheduling`, + `UNIQUE (tenant_id, id)` en `schedulable_resources`,
  `operating_room_block_series`, `operating_room_blocks` y `UNIQUE (custodian_tenant_id, id)` en `procedure_cases`:
  caso → sala, **sede** (`practice_site_id`, columna existente pero fuera del §F4.1: se incluyó porque deja a un caso
  apuntar a la sede de otro tenant), recurso, bloque; evento → sala, caso, bloque; serie → sede, sala, unidad;
  bloque → serie, sala, unidad; historias → origen; recurso → espacio.
- **CHECK de dominio** en series y bloques (dueño coherente —el del contrato—, días de semana 0=domingo…6=sábado
  como en `scheduling`, franja `end_time > start_time` dentro de un mismo día, vigencia, `release_hours >= 0`,
  ventana `ends_at > starts_at` y `release_at <= starts_at`, estado ∈ {ACTIVE, RELEASED, CANCELLED}, liberado ⇒
  `released_at`, activo ⇒ sin `released_at`, liberado por una persona ⇒ motivo). Los tres últimos son decisión mía a
  partir de las columnas del contrato (`released_at`, `released_by_user_id` «null = automático», `release_reason`).
- **Nulabilidad que el contrato no fija**: `valid_from`, `weekdays`, `start_time`, `end_time`, `release_at`,
  `practice_site_id`, `operating_room_id`, `owner_kind_concept_id`, `status_concept_id` son NOT NULL;
  `series_id` es NULL (un bloque suelto no tiene serie). Columnas comunes de tablas mutables (§0.1) agregadas a
  series y bloques. El estado de la **serie** no se restringe a un dominio.
- **Dos triggers de coherencia** (`23503`): la sala de una serie es de la sede de la serie (regla 2 del contrato);
  un bloque de una serie usa la sala de la serie.
- **Eventos**: trigger BEFORE INSERT que completa `tenant_id` desde la sala (la API actual no lo manda y la columna
  pasa a NOT NULL). Si la API ya lo manda, no hace nada.
- **Check-list OMS**: además del único `(caso, tipo)`, `ck_surgical_safety_checklists_phase_order` (la Pausa exige la
  Entrada y la Salida exige la Pausa). El contrato lo deja a la API (gates); acá es la red.
- **Historias** `audit.operating_room_block_series_history` / `…_blocks_history`: contrato §0.1 exige historia
  de toda tabla mutable. `tenant_id NOT NULL`, RLS, `mantra_app` con SELECT/INSERT/UPDATE(valid_to), triggers
  `trg_fill_tenant` / `trg_close_only` reutilizando las funciones de F1b (el patch aborta con el nombre si faltan).
- **Hot files**: se editó `diagram_33_integrity.puml` (se **reemplazó** la línea `EXCLUDE_SQL` del bloque
  existente `procedure_cases` y se agregó un bloque F4 al final) y `diagram_10_audit.puml` (2 historias + 2 índices).
  El integrador resuelve el merge.

## C. Reglas que NO quedan en la base (siguen siendo de la API, tal como dice el contrato)

- Función `SPACE_FN_OPERATING_ROOM` del espacio y misma sede caso↔sala (`OPERATING_ROOM_INVALID_FUNCTION`,
  `OPERATING_ROOM_SITE_MISMATCH`): son datos/umbrales de F1, no UUID fijos del DDL.
- Estado del espacio / ventana de mantenimiento (`assertBookable`), propiedad del bloque (`OR_BLOCK_OWNED_BY_OTHER`),
  que el bloque ligado a un caso sea de la sala del caso, los gates del check-list OMS y la liberación automática.
- Solape entre **series** (solo se impide entre instancias ACTIVAS).

## D. Para el integrador / la API

- **Ruta de reconstrucción.** El trigger de la ventana reservada, las FK compuestas, el RLS, los privilegios y los
  triggers de coherencia viven **solo en los patches** (como en F1b): una base armada con `apply_all.sql` sin los
  patches tendría `reserved_*` sin calcular y el EXCLUDE nuevo no filtraría nada. Aplicar los patches en orden
  `f1 → f1b → f4_scheduling → f4_periop`.
- **RLS en `operating_room_utilization_events`**: ahora filtra por tenant (FORCE). Los jobs que la escriban o lean
  fuera de una petición (cola de recambio, indicadores) necesitan contexto SYSTEM.
- **Seeds `mock` de `seedsGenerales/modules/53_…` incumplen las reglas nuevas** (no se tocaron): 1 caso con sala y sede
  de otro tenant, y los 16 check-lists forman 7 pares `(caso, tipo)` repetidos. Una base con esos seeds hace abortar
  `…_f4_periop.sql` (con el detalle) y los seeds fallarán contra el único nuevo hasta corregirlos.
- `db:vendor` + `gen_entities`: entidades nuevas `OperatingRoomBlockSeries`, `OperatingRoomBlock`, sus historias, y
  columnas `reserved_*`, `schedulable_resource_id`, `operating_room_block_id` (caso), `tenant_id` +
  `operating_room_block_id` (evento), `care_space_id` (recurso). Mapa `constraint → reason` para `23P01`:
  `ex_procedure_cases_operating_room_reserved_time` → `OPERATING_ROOM_SLOT_CONFLICT`,
  `ex_operating_room_blocks_time` → `OR_BLOCK_OVERLAP`, `ux_schedulable_resources_care_space_active` →
  `RESOURCE_ALREADY_EXISTS_FOR_SPACE` (este es `23505`).
- Errores que la API verá: `23503` por cruce de tenants (→ 404, como F1b), `23P01`, `23505`, `23514`, `42501` (RLS).

## E. Qué no se verificó

- Nada con la API ni el web (solo modelo). Los `.puml` no se renderizaron con PlantUML (no hay binario): se
  validaron con el parser de `gen_ddl.py` / `gen_integrity.py`.
- El patch no se corrió sobre una base con datos reales ni con los seeds `mock` (ver D); sí sobre una base vacía
  con fixtures (ver el commit).
- `apply_all.sql`/`gen_apply.py` no se ejecutaron (archivos del integrador); sí se reaplicó el SQL generado de 10, 41
  y 53 (02/03/04/05/90) sobre la base parcheada, en una transacción con ROLLBACK, sin errores.
- Rendimiento del precheck de solapes (autounión de casos vivos) en tablas grandes.
