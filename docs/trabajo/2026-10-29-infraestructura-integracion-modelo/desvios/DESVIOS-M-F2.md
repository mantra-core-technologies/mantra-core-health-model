# Desvíos y supuestos — agente M-F2 (modelo SQL, infraestructura hospitalaria F2)

Rama `claude/modelo-infra-f2` (desde `origin/claude/trusting-hawking-q3p12v`). Contrato:
`CONTRATO-F2-F5.md` §0.1 y F2.1/F2.2. Este archivo es para el integrador del modelo y para la
API; no es parte del modelo. Se puede borrar al integrar.

## 1. Qué se tocó

| Archivo | Cambio |
|---|---|
| `diagram_14_practice.puml` | `care_spaces` +10 columnas; entidades `care_space_status_events`, `care_space_blocks`, `cleaning_orders`; sus índices; `ux_care_spaces_site_id_id`. Todo en bloques contiguos y comentados (columnas al final de `care_spaces`, entidades después de `practice_settings`, índices al final del paquete «Physical Indexes»). |
| `diagram_10_audit.puml` | Entidades `care_space_blocks_history`, `cleaning_orders_history` (molde `care_spaces_history`) y sus índices. Dos hunks, antes de `diagnostic_reports_history`. |
| `diagram_33_integrity.puml` | Bloque nuevo al final (antes de `@enduml`): `UPDATE_DELETE: forbidden` de los eventos, `CHECK_SQL`/`EXCLUDE_SQL` de bloqueos, órdenes y eventos. |
| `SQL/patches/2026-10-29_infraestructura_f2_practice.sql` | Patch idempotente. |
| `salud-db/tests/test_f2_practice_patch.py` | Pruebas. |

No se tocaron `SQL/NN_*`, `_generation_report.md`, `SHA256SUMS.txt`, `model-manifest.yaml`,
`apply_all.sql`, `docs/data-catalog/*` ni los seeds. El integrador debe correr `gen_ddl.py` y
`gen_integrity.py` y regenerar catálogo y checksums; para validar sin tocar `SQL/` se generó en
un directorio temporal y el patch copia esas sentencias (la prueba
`TestPatchMatchesGeneratedDDL` lo verifica: tablas, 54 índices, 45 FK simples, CHECK, EXCLUDE y
trigger idénticos a lo generado).

## 2. Desvíos del contrato (con motivo)

1. **También se editaron `diagram_10_audit.puml` y `diagram_33_integrity.puml`.** El encargo decía
   «solo tu bloque de `diagram_14`», pero el contrato §6.2 manda que cada agente agregue su bloque
   en `diagram_10`/`diagram_33` (las historias, el EXCLUDE y las guardas no existen si no están ahí)
   y F5 ya lo hizo. Son bloques aislados; si prefieres que no estén, el patch sigue siendo
   autosuficiente (crea todo con `IF NOT EXISTS`), pero `gen_ddl`/`gen_integrity` no los emitirían.
2. **El backfill `NULL → SPACE_OP_AVAILABLE / HYG_CLEAN / ISO_NONE` es condicional.** La FK de
   cada eje a `terminology.catalog_concepts` exige que el concepto exista y el patch no siembra
   conceptos (sus ids son de la API; precedente F1 con `form_concept_id`). Solo se escribe si el
   concepto ya existe; si no, el eje queda `NULL` y **volver a aplicar el patch después del seed
   de la API completa el backfill** (probado: 1.ª pasada sin conceptos, se siembran, 2.ª pasada
   completa y no pisa un estado ya escrito). La API debe leer `NULL` como el valor por defecto
   mientras tanto. El backfill no toca `row_version`, `updated_at` ni los `*_changed_at`.
3. **`ops_version` lleva `DEFAULT 1` solo por el patch.** `gen_ddl` solo emite `DEFAULT` para
   `row_version` y para booleanos marcados (`<<DEFAULT_FALSE>>`, usado en
   `terminal_cleaning_required`). Si se quiere que el `02_tables.sql` generado lo traiga, basta
   ampliar `column_default()` de `gen_ddl.py` a `ops_version` (no lo hice: es un generador
   compartido). El patch repone el default aunque la columna ya exista (probado).

## 3. Supuestos donde el contrato no dice (razonables, a confirmar)

- **Conceptos por clave.** Los UUID literales se calcularon con `uuid5(HEALTH_UUID_NAMESPACE,
  'practice:<NOMBRE>')` (verificado contra un literal ya publicado de F5). Los nombres de
  propiedad son los del contrato: `SPACE_OP_AVAILABLE`, `HYG_CLEAN`, `ISO_NONE`,
  `BLOCK_MAINTENANCE`, `CLN_PENDING`, `CLN_IN_PROGRESS`, `CLN_DONE`. **Si `practice.concepts.ts`
  usa otros nombres de propiedad, el EXCLUDE/único/CHECK dejan de coincidir** (hay una prueba
  que recalcula los literales). Los demás conceptos del contrato no entran en ningún predicado.
- **Nulabilidad de los eventos A20** (el contrato no marca obligatorios): `NOT NULL` en `id`,
  `tenant_id`, `practice_site_id`, `care_space_id`, `axis_concept_id`, `to_concept_id`,
  `v2_0116_code`, `source_concept_id`, `occurred_at`, `created_at`. Nulables: `from_concept_id`
  (primer evento), `reason_*`, `expected_until`, `source_ref_id`, `recorded_by_user_id` y
  `request_id` (el worker y ADT automático pueden no tener usuario ni petición).
- **Otras columnas NOT NULL:** bloqueos: `kind`, `reason` (motivo obligatorio, INV-25), `starts_at`;
  órdenes: `cleaning_type`, `trigger`, `priority`, `status`, `requested_at`, `practice_site_id`,
  `care_space_id` (`clinical_unit_id` nulable: un espacio puede no tener unidad).
- **`ck_care_space_blocks_end_after_start`** (el contrato no da la expresión): `ended_at >=
  starts_at` y `expected_end_at >= starts_at` (o NULL). Se usa `>=`: un bloqueo de duración cero
  produce un rango vacío que el EXCLUDE ignora, y evita rechazar un alta y baja en el mismo
  instante. Cubre también la fecha estimada.
- **`ck_cleaning_orders_inspector_differs`** es la expresión literal del contrato. Con
  `finished_by_user_id` NULL el CHECK no rechaza (comparación con NULL): es la API quien exige
  quién terminó antes de inspeccionar (hay una prueba que lo deja documentado).
- **Endurecimiento de tenant (mismo criterio que F1b):** `UNIQUE (tenant_id, id)` en
  `care_space_blocks` y `cleaning_orders`; FK compuestas `(tenant_id, x_id)` a sede, espacio,
  unidad y orden previa, y a bloqueo/orden desde la historia (11 en total). **Añadido por mí (no
  está en el contrato):** `ux_care_spaces_site_id_id (practice_site_id, id)` y la FK
  `(practice_site_id, care_space_id) → care_spaces (practice_site_id, id)` en eventos y órdenes,
  para que la sede declarada sea la del espacio (el tablero consulta por sede). Costo: un índice
  único redundante con la PK. Se puede quitar sin otro efecto que perder esa garantía.
- **Privilegios de `mantra_app`.** Eventos: solo `SELECT` e `INSERT` (además del trigger).
  Bloqueos y órdenes: DML completo como las tablas de F1 (el «sin borrado físico» queda a cargo de
  la API). Historias: `SELECT`, `INSERT` y `UPDATE (valid_to)` como F1b. Nota: los
  `DEFAULT PRIVILEGES` del entorno dan `arwd` en tablas nuevas; el patch lo reduce explícitamente.
  Reaplicar `2026-08-05_tenant_rls.sql` vuelve a ampliarlo (el trigger sigue bloqueando).
- **Eventos sin historia** (contrato: son append-only). Sin `updated_at` ni `row_version`.
- **El patch depende de F1, F1b y de `SQL/_integrity/00_integrity_functions.sql`**
  (`integrity.forbid_mutation`, `audit.structure_history_*`); si faltan, aborta con la lista.

## 4. Para el integrador del modelo

- Correr `gen_ddl.py` y `gen_integrity.py`, regenerar catálogo (`docs/data-catalog`), checksums y
  manifest; resolver el merge de los tres `.puml` con los bloques de los otros agentes (los míos
  son contiguos y llevan el rótulo «infraestructura hospitalaria F2»).
- `gen_integrity` agrega `CREATE EXTENSION IF NOT EXISTS btree_gist` en
  `SQL/14_practice/05_constraints.sql` porque ahora hay un EXCLUDE; el patch también lo hace.
- Seeds mock de `10_audit`: las dos historias nuevas no tienen filas (los seeds de F1b sí las
  tienen para las tres historias de estructura). No lo generé (`gen_seeds` es del integrador).
- Orden de patches: F1 → F1b → **F2 (este)** → resto. No depende de F3/F4/F5.

## 5. Para la API (F2.3)

- Alimentar `ops_version` (`If-Match-Ops`) y `row_version` desde la aplicación: la base no los
  incrementa. El backfill del patch no los toca.
- Las FK compuestas se violan con `23503` (cruce de tenant o de sede), el EXCLUDE de bloqueos con
  `23P01` (`ex_care_space_blocks_time`), el único de orden abierta con `23505`
  (`ux_cleaning_orders_one_open_per_space`) y los CHECK con `23514`; el UPDATE/DELETE de eventos
  con `23001` (`restrict_violation`, mensaje «append-only/immutable»). Para
  `exclusion-constraint-reasons.ts`: `ex_care_space_blocks_time → BLOCK_OVERLAP`.
- `blocks-tick` («aplica bloques programados cuyo `starts_at` llegó»): el contrato no define una
  columna «aplicado», así que la API debe derivarlo del estado del espacio. No se creó columna
  ni índice para el tick (la política de índices pide EXPLAIN primero); un candidato es
  `(starts_at) WHERE ended_at IS NULL AND cancelled_at IS NULL`.
- `from_concept_id` del primer evento de un espacio puede ser `NULL`; `to_concept_id` nunca.
- El historial de bloqueos y órdenes (`audit.*_history`) debe escribirse con `tenant_id` (si se
  omite, un trigger lo completa desde el origen).

## 6. Qué no se verificó

- Contra la **API real** (no hay `node_modules`; no se corrió ningún `int-spec`, ni el seed de
  conceptos F2 ni el mapa `constraint → reason`).
- El caso «prerrequisitos ausentes» (base sin F1/F1b/integridad): el código existe, no se
  ejercitó.
- `postgres-init` completo (rebuild desde cero con el SQL regenerado por el integrador):
  no se regeneró `SQL/`; se probó que las tablas ya existentes (creadas desnudas) se adoptan y
  que el catálogo resultante es idéntico al de crearlas con el patch.
- Concurrencia real (dos sesiones a la vez sobre el EXCLUDE o el único parcial): las pruebas
  son secuenciales dentro de una transacción.
- Rendimiento/EXPLAIN de los índices nuevos (sin datos).
- `app.system_context`/`RLS_ENFORCE` con la API; solo se probó el rol `mantra_app` con
  `app.current_tenant_id` fijado a mano.
