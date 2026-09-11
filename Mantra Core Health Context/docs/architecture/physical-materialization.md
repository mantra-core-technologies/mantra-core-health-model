# Materialización física del modelo — estado del build (SALUD v4.0.10)

Cómo los 64 `.puml` de este paquete se convierten en una base de datos física, y el estado
actual de esa materialización. Documento de arquitectura hermano de [`indexing-strategy.md`](indexing-strategy.md),
[`orm-mapping-guide.md`](orm-mapping-guide.md) y [`nosql-storage-allocation.md`](nosql-storage-allocation.md).
La fuente de verdad del dominio siguen siendo los `.puml`; este documento describe el proceso
determinista que los materializa y no altera el modelo.

## 1. Estrategia

El DDL **no se escribe a mano**: se genera desde los `.puml` con generadores deterministas
(directorio `salud-db/`, Python). El mismo modelo produce el SQL, el SQL levanta la base, y
la base puede regenerar las entidades del ORM por introspección (ver `orm-mapping-guide.md` §2.3).

| Generador | Produce |
|---|---|
| `gen_ddl.py` | DDL PostgreSQL por módulo y fase → `SQL/` |
| `gen_nosql.py` | Stores especializados en formato nativo → `NoSQL/` |
| `gen_integrity.py` | Matriz del módulo 33 → guardas + `05_constraints` por dueño |
| `gen_apply.py` | Runners `apply_all.sql` / `apply_deferred.sql` |
| `gen_entities.py` | Entidades MikroORM (TS) para `mantra-core-health-api/` |
| `fix_vault_fk.py` | Reconciliación de las notas FK del grafo contra el modelo |
| `load_seeds.py` | **Carga idempotente** de `seedsGenerales/` + `seedsProd/` en PG/Mongo/Redis/OpenSearch |

### Fases del DDL (idempotentes)

`00_shared/00_types.sql` (enum `technical_data_type`) → por módulo `01_schema` → `02_tables`
→ `03_fk_intra` → `04_indexes` → `05_constraints` → y al final, con todos los schemas creados,
los `90_fk_deferred` (FK cross-schema). El schema `integrity` aloja la función `forbid_mutation`.

## 2. Reglas de fidelidad (temperatura-0)

- **FK**: destino canónico de las notas del grafo (`FK/`); si falta, convención global
  (`*_concept_id`→catalog_concepts, `*_user_id`→users, `tenant_id`→tenants, nombre unívoco);
  sin destino → **no se fuerza** (queda documentada, no inventada).
- **Enums**: único enum nativo `technical_data_type`; el resto es terminología por `*_concept_id`.
- **Subtipos CTI** (7 perfiles): `profile_id <<PK,FK>>` → `profiles.persons` (comparten PK).
- **Inmutabilidad** (`<<LOG>>/<<IMMUTABLE>>/<<APPEND_ONLY>>`): `REVOKE` + trigger físico.
- **Polyglot**: solo se emiten como tablas PG las entidades relacionales; los stores NoSQL van
  a su motor. Graph (61) y Lakehouse (63) se materializan como catálogo PG del plano de control.

### Correcciones de compatibilidad PostgreSQL (funciones IMMUTABLE en índices)

El `.puml` declara expresiones que PostgreSQL rechaza en índices; el generador las adapta sin
cambiar la intención: `concat_ws` (STABLE) → `coalesce(…)||…`; constructor de rango por el tipo
real de columna (`date`→`daterange`, `timestamptz`→`tstzrange`); operator class GIN pegado a la
columna (`col jsonb_path_ops`). Predicados con funciones placeholder (`held_status()`) se emiten
comentados como TODO. FK envueltas en `DO … EXCEPTION WHEN duplicate_object` (re-aplicables).

## 3. Estado actual del build

### TAREA-07 — índice de búsqueda por CI en `common.identifiers` (2026-09-02)

`ChartReadService` necesita buscar pacientes por tipo de documento + valor (AC-07-3); el
`<<INDEX_SET>>` de `identifiers` solo tenía columnas sueltas (`type_concept_id` sola, entre
otras), ninguna sirve para `WHERE type_concept_id = $1 AND value = $2`. Promoción por el
pipeline canónico: `.puml` (módulo 02, `idxset_identifiers`) → `gen_ddl.py 02` (diff de una
línea en `SQL/02_common/04_indexes.sql`) → patch `2026-09-02_t07_identifiers_search_index.sql`
→ nota de bóveda `E common.idxset_identifiers.md` → `yarn orm:catalog` (diff acotado a
`common.idx.ts`, +1 tupla). No `UNIQUE`: el departamento emisor no participa de la unicidad y
hay filas históricas superpuestas por `valid_from`/`valid_to`.

**Aplicado contra el stack `mantra-redesa` (`localhost:5433`):**

| Medida | Antes | Después |
|---|---|---|
| Tablas | 1 229 | **1 229** |
| FKs (excluyendo `_timescaledb%`) | 6 730 | **6 730** |
| Índices | 9 183 | **9 184** |
| Índices de `common.identifiers` | 10 | **11** |

`check_ddl_sources.py` y `gen_seeds.py --dry` en verde (verificado con el fix de
`mantra-core-health-model#4`, aún no mergeado a `dev` cuando se ramificó este cambio — ver
abajo); `yarn typecheck` en 0 en la API.

**El `EXPLAIN` no dio lo que el criterio de aceptación esperaba, y se documenta tal cual en vez
de maquillarlo.** Con datos de `seedsGenerales` (`--skip-prod --refresh`, 27 filas en
`common.identifiers`, que ocupan **una sola página de 8 KB**), el planner elige `Seq Scan`
— es la decisión correcta por costo: para una tabla de una página, cualquier índice es
estrictamente más caro que leer la página entera. Se verificó que el índice es estructuralmente
correcto forzándolo (`SET enable_seqscan = off`): `Index Scan using
ix_identifiers_type_concept_id_value`, `Index Cond` sobre las dos columnas, plan válido. La
demostración de `Index Scan` **natural** contra volumen real queda pendiente de un stack con más
identificadores por persona que el paquete de seeds de desarrollo produce hoy — no es una
regresión de este cambio, es el tamaño de la tabla en este entorno.

**Deuda que este cambio destapó, sin resolver:** la copia de despliegue vendorizada
(`mantra-core-health-api/database/SQL`) queda un patch atrás hasta que alguien corra
`yarn db:vendor` después de que este PR se mergee — mecanismo esperado, no un defecto (ver
`ddl-sources.md` §«La excepción»). Y `yarn orm:catalog` sigue rompiendo `surveys` al
regenerar (B-10, preexistente): se revirtió a mano, como en cada promoción anterior.

### 3.0 · Jornada del 2026-08-15 — lo que cambió el estado documentado

**La cadena de seeds estaba caída entera, y el arranque no lo decía.** Dos definiciones del
catálogo declaraban el mismo código: `terminology:relationship:procedure` (del glosario) y
`periop:relatedness:procedure` usaban las dos `REL_PROCEDURE`. El seed deduplica **por id**
—UUIDv5 de la clave, distinta en cada una— pero `terminology.catalog_concepts` tiene
`UNIQUE(code_system_version_id, code)`, así que la colisión no aparecía hasta llegar a Postgres:

```
Seed omitido: catálogo de conceptos
duplicate key value violates unique constraint "uq_catalog_concepts_version_code"
Key (code_system_version_id, code)=(ffda3cef-…, REL_PROCEDURE) already exists
```

El catálogo es el **primer** paso de la cadena, de modo que su fallo se llevaba puestos los otros
nueve: en base nueva no quedaba sembrado nada y la aplicación arrancaba igual, escuchando HTTP con
el catálogo vacío. Medido: `authz.permissions` 0 · `chart.specialty_chart_templates` 0 ·
`terminology.concept_properties` 0 · `concept_relationships` 0. Se movió el código del glosario a
`REL_ASSOC_PROCEDURE` —no el de periop, ya materializado en las bases vivas, porque el seed inserta
pero nunca actualiza— y quedó un guardarraíl (`src/common/seed/concept-codes.spec.ts`) que replica
lo que el seed escribe de verdad: de `CONCEPT_DEFS` el `code`, de `MODULE_CONCEPT_SEEDS` la clave.

**La siembra de arranque tiene interruptor, cronómetro y voz.** ADR-0017 decidió sembrar en cada
`OnApplicationBootstrap` cuando el único seed era el catálogo; hoy son diez y ~5 320 filas que se
re-verifican en cada boot y en cada archivo de prueba de integración. Ahora hay `SEED_ON_BOOT`
(default `true`), `yarn seed:boot` con código de salida propio, y cada paso se cronometra y **se
loguea siempre** (`event: seed.step`) con resumen agregado (`seed.summary`). Antes logueaban sólo
`if (inserted > 0)`, así que un seed ausente de la imagen se veía igual que uno sin trabajo.

**El corpus MeSH deja de cargarse por defecto: −1 441 367 filas.** Era el 98,3 % del volumen y
501 MiB, y no lo consulta nada — cero coincidencias de `MESH`/`NLM_MESH` en `SQL/`, `salud-db/`,
los `.puml` y `src/`; los 2 418 `*_concept_id` resuelven contra el boot del módulo 03 de
`seedsGenerales`. `rebuild_stack.py` pasa `--skip-prod` y el corpus vuelve con `--con-mesh`; los
shards no se borran. **No confundir** con los ~458 000 conceptos de los ETL de
`tools/terminology-import/` (CIE-10, LOINC, RxNorm, NDC, RxTerms, HCPCS, NUCC), que se conservan
porque sí son vocabulario clínico y sí tienen pruebas.

**`generateSlots` materializa los cupos en la zona de la sede.** `schedulable_resources.time_zone`
se declaraba y se guardaba pero no se usaba: una agenda de La Paz (UTC−4) que publicaba «08:00 a
12:00» ofrecía turnos de 04:00 a 08:00 hora local. La conversión usa `Intl` (base IANA completa) en
vez de un desplazamiento fijo; el día de la semana también se evalúa en local; sin zona declarada
se cae a UTC, así los cupos ya publicados no se mueven. **No regenera** los cupos ya materializados.

**El arranque declara qué código está corriendo.** No había forma de saber qué versión tiene un
contenedor sin inspeccionarle el `dist/`, y una imagen vieja se ve idéntica a una al día: la de
desarrollo era del 14-08 mientras `dev` iba por el 15-08 y le faltaban tres de los diez seeds. La
primera línea del logger es ahora `Arranca v… · commit … · construido … · entorno …`
(`event: app.build`), alimentada por `GIT_COMMIT`/`BUILD_TIME`/`APP_VERSION` como `ARG` del
`Dockerfile`.


Dos entornos aplicados:

> **PostgreSQL 18 nativo** local · base `mantra_health_db_v1` (build original, 2026-07-21, v4.0.1).
> **Stack Docker `mantra-redesa`** (`mantra-core-health-api/docker-compose.yml`) · base
> `mantra_redesa_health` en `localhost:5433` — **entorno dev de referencia**, poblado
> y **al día en v4.0.9 + seeds `2.3.0-v4.0.9`** (rebuild verificado 2026-08-05).
> Desde el 2026-08-15 se puebla **sin el corpus MeSH**: ~25 000 filas en vez de ~1,46 M
> (ver §3.0). Con `rebuild_stack.py --con-mesh` vuelve al volumen anterior.

> [!warning] v4.0.11 (2026-08-18) — el paquete de seeds cambió, hay que **reconstruir**, no refrescar
> `gen_seeds.py` pasó a revisión **`2.4.0-v4.0.11`** y sanea el elenco de la demo, que era el
> origen real de cinco quejas de QA sobre la Guía de profesionales:
>
> - **Identidades curadas** (fase `[2d]`, `phase_curate_identities`): `professional_title` deja de
>   traer el nombre de otra persona y pasa a ser un cargo; las cuatro personas «(caso 12…15)»
>   reciben nombre propio; y los **cuatro `profile_id` repetidos** se reasignan, así que las 16
>   filas de `health_practitioner_profiles` tienen **16 titulares distintos** (antes cuatro médicos
>   no existían en ninguna base: la PK los descartaba al cargar).
> - **Value set `vs_medical_specialty`** (36 especialidades, display curado en castellano vía
>   `VS_DISPLAY`) atado a `practitioner_specialties` y a las dos columnas de especialidad del
>   módulo 23. Las 16 filas mock quedaron **vigentes** (`valid_to = NULL`): traían fecha pasada y la
>   lectura descarta las no vigentes, que es por qué los 34 profesionales caían en un único grupo
>   «Sin especialidad registrada».
> - **Directorio de laboratorios** (`canonical_diagnostic_units`, builder canónico): **6 unidades**
>   bolivianas —una por tenant, que entonces era lo único que `uq_diagnostic_units_tenant_id`
>   permitía; esa clave se reemplazó el 2026-08-23 por la compuesta `(tenant_id, code)`— con sede, 16 ofertas de
>   estudio, tarifario en BOB, equipamiento y una acreditación ISO 15189. Reemplaza las 160 filas
>   sintéticas del bucle genérico, que apuntaban a conceptos del catálogo transversal que los
>   servicios del módulo nunca comparan. **`tools/alovida/seed-diagnostic-units.mjs` se retira**.
>
> - **31 roles del paquete alineados al ACTIVE del backend** (`align_role_states`): `ensureRoleByCode` y `effectiveRoleCodes` filtran por el ACTIVE del backend, y los roles de `authz.roles` venían con el de SALUD_CORE — `PRACTITIONER` existía, activo y asignable, pero invisible para la app: el alta asistida del médico moría con 422.
> - **Canal `IN_APP` espejado del backend** (2ª tanda del mismo día): el mismo bug que el
>   trío de correo, una fila más allá — el paquete traía el canal con id propio
>   (`ed1b78a4-…`) y conceptos que `findActiveChannelByType` no reconoce, así que la
>   campana in-app moría con «No hay canal in-app activo» aunque el seed diera verde
>   (los adapters referencian `MESSAGING_SEED.inAppChannelId` por id calculado).
>   `phase_backend_bridge` espeja ahora el trío in-app (canal `d0240273-…` +
>   `DEFAULT_IN_APP` + config) y `retire_legacy_channels` —generalización de la función
>   que hacía esto solo para EMAIL— retira el legacy y repunta sus 4 referencias
>   (config, plantilla `DIAGNOSTIC_RESULT_AVAILABLE`, preferencia, distribución del 39).
>   Complementa el fix #144 de la API: aquél evita la explosión del seed; éste hace que
>   la campana funcione.
>
> **`load_seeds.py --refresh` NO alcanza**: el mock del módulo 23 cambia de PK y las filas viejas
> quedarían al lado de las nuevas. El camino es `python salud-db/rebuild_stack.py --yes`.

| Métrica (modelo) | Valor |
|---|---|
| Tablas | **1 159** (+ 12 `time_series` + 14 `vector_rag` en la misma instancia PG = 1 185) |
| Índices | **9 130** (incluye los 2 únicos PARCIALES de v4.0.9) |
| FKs | **6 669** declaradas en `SQL/` (ver v4.0.11, módulo 64 y v4.1.0 más abajo) |
| Schemas | 58 (53 del modelo + `integrity`, `public`, y stores materializados) |

> Cifras **verificadas contra la base viva** el 2026-08-05 por `python salud-db/rebuild_stack.py`
> (`down -v` + `up` + carga completa + veredicto **PASS**). La base coincide exactamente con lo
> que declara `SQL/`: el script no compara contra números fijos, deriva los esperados de `SQL/`
> en el momento y asevera las igualdades. Al contar FKs contra `pg_constraint`, excluí siempre
> `_timescaledb%`: sin ese filtro aparecen 22 constraints del catálogo interno de TimescaleDB y
> el conteo deja de ser una igualdad exacta.

### v4.1.2 — El curso clínico de `clinical.conditions` (2026-08-20)

**Quinto caso del mismo patrón, y el más chico**: una columna, no un módulo. También el de
consecuencia más inmediata. El PR #171 de la API —rotulado «Patch v4.0.8: estado clínico y
cronicidad», rótulo que choca con el **v4.0.8 real**, la promoción ALOVIDA del 30/07— agregó
`clinicalCourseConceptId` a `clinical/entities/conditions.entity.ts` y dos value sets al
`DYNAMIC_ENUM_CATALOG` (`condition-clinical-status`, `condition-clinical-course`), pero la
columna no estaba declarada en ninguna de las otras tres capas. Evidencia:
`grep -rn clinical_course_concept_id` daba **0 aciertos** en `Mantra Core Health Context/modules/`,
en `SQL/` y en la bóveda; `clinical_status_concept_id`, que sí es del modelo, aparece en las tres.

La categoría no es `tabla-ausente` sino **`columna-ausente`**, que es peor de lo que suena:
MikroORM la proyecta en el `SELECT`, así que contra cualquier base construida por el pipeline
**fallaba toda lectura de `clinical.conditions`**, no sólo la que usara el campo nuevo.

Lo que hizo falta, y no se deduce del DDL:

- El `.puml` **transcribe** lo que ya declaraba la entidad —`uuid`, nullable, FK a
  `terminology.catalog_concepts`— y agrega el índice que la convención del módulo exige: las
  otras 12 columnas FK de `conditions` tienen el suyo en el `<<INDEX_SET>>`.
- El **curso clínico es un eje distinto del estado**, no un valor más del mismo value set:
  `clinical_status_concept_id` dice en qué punto del ciclo está la condición (activa, en
  remisión, resuelta…) y `clinical_course_concept_id` si es aguda o crónica. Juntos gobiernan qué
  transiciones son válidas —una condición crónica no pasa a resuelta—, que es la máquina que
  implementa `ConditionsService`.
- Es **nullable a propósito**: no declarar el curso es un dato legítimo (el catálogo trae
  `COND_COURSE_UNKNOWN`), no un olvido que convenga rellenar con un valor por omisión. Y como
  todo valor de terminología viaja por `*_concept_id` contra `terminology.catalog_concepts`,
  nunca por un enum de TS.

**Verificación: de generador, no de base.** `python salud-db/gen_ddl.py 08` produce contra el
respaldo un diff de **exactamente tres líneas** —la columna en `02_tables.sql`, el índice en
`04_indexes.sql`, la FK en `90_fk_deferred.sql`— sin daño colateral (B-3 no se disparó en el
módulo 08), y `check_ddl_sources.py` sigue devolviendo `Fuentes de DDL OK`. Los deltas
**esperados** al aplicarlo son FKs 6 705 → **6 706** e índices 9 154 → **9 155**, tablas sin
cambio; **no están medidos**, porque Docker Desktop estaba apagado el 20/08. Patch para bases
vivas: `SQL/patches/2026-08-20_v412_conditions_clinical_course.sql`; en base limpia no hace falta.

> **Deuda que destapó, y que este cambio NO cierra (ficha B-10).** Regenerar `yarn orm:catalog`
> devuelve `surveys` de módulo **65 a `null`** y emite **1 de sus 36** FKs: la promoción del
> módulo 65 llegó al `.puml`, a `SQL/` y a las entidades, pero **nunca escribió las notas de la
> bóveda** (0 notas `E surveys.*`, 1 nota `FK surveys.*`), y el `65` que hay en `dev` se escribió
> **a mano** sobre un archivo generado. Por eso el catálogo **hoy no es reproducible**: regenerar
> no deja el árbol byte a byte idéntico. La salida es escribir las notas del módulo 65, no volver
> a editar el catálogo a mano.

### v4.1.3 — Notas clínicas, indicaciones al paciente, y el hueco de B-9 (2026-08-20)

Tres columnas nuevas en el módulo 08, dos motivos distintos:

1. **`clinical.conditions.expected_resolution_at : timestamptz` — el HUECO de B-9.** El PR #171
   metió **dos** columnas solo-ORM en `conditions.entity.ts`, y la promoción v4.1.2 cubrió una
   sola (`clinical_course_concept_id`). Con esta ausente, aplicar el patch v4.1.2 **no
   alcanzaba**: el ORM la proyecta en el `SELECT` y toda lectura de `clinical.conditions` seguía
   siendo `columna-ausente` contra una base del pipeline. Evidencia: `git log -S
   expectedResolutionAt` la ata al mismo commit `ddff9d0f` del PR #171, y `grep
   expected_resolution_at` daba 0 aciertos en `.puml`, `SQL/` y `SQL/patches/`.
2. **`clinical.conditions.note_text : text`** (hallazgos y justificación clínica) y
   **`clinical.medication_requests.patient_instructions_text : text`** (indicaciones al paciente
   impresas en la receta). Nacen del formulario de la ficha de AloVida: el campo de notas se
   ofrecía y se **descartaba en silencio** por no tener destino, y las indicaciones viajaban
   **concatenadas dentro de `dose_text`** (`' — Indicaciones: …'`), contaminando la posología
   que farmacia lee para dispensar. Molde canónico del módulo: `note_text : text` nullable, como
   `family_member_history`, `procedures` y `observation_notes`.

Ninguna es FK ni lleva índice, así que **no hay nota `SALUD/FK/`, ni entrada de `<<INDEX_SET>>`,
ni interviene `orm:catalog`** (el catálogo declara índices y FKs, no columnas) — la promoción
esquiva B-10 entera. Las tres son nullable a propósito: una condición crónica no tiene resolución
esperada, y una nota ausente es un dato legítimo, no un olvido.

**Verificación: de generador y de suite, no de base.** `python salud-db/gen_ddl.py 08` produce
contra el respaldo un diff de **exactamente tres líneas, todas en `02_tables.sql`**;
`gen_integrity.py` no cambia nada y `check_ddl_sources.py` sigue en `Fuentes de DDL OK`.
`gen_entities.py 08` (+ prettier) deja un diff de **solo las dos entidades** (+16 líneas). API:
`CreateConditionDto.noteText` y `CreateMedicationRequestDto.patientInstructionsText`
(`@IsOptional @IsString`), mapeados en `create()`, en el snapshot sellado de la receta, en
`editDraft` y arrastrados en `replace`/`renew`; expuestos en `clinical-read`. Los deltas
esperados en base viva son **tablas, FKs e índices sin cambio** (solo columnas). Patch:
`SQL/patches/2026-08-20_v413_clinical_notes_and_expected_resolution.sql`; en base limpia no hace
falta. El PDF de la receta imprime las indicaciones en su sección «Indicaciones», que ya existía.

### v4.1.6 y v4.1.7 — La receta dice para qué es, y el profesional guarda lo que repite (2026-08-21)

Dos promociones del mismo carril, ninguna de corrección de deriva: son decisiones de producto
que exigían modelo.

**v4.1.6 · `clinical.medication_requests.indication_condition_id : uuid`** (nullable, FK a
`clinical.conditions`, índice propio). Hasta ahora la única relación entre receta y diagnóstico
era **compartir el encuentro**, que dice *cuándo* se recetó pero no *para qué*: un paciente con
cuatro condiciones activas atendido en una consulta deja cuatro candidatas y ninguna respuesta.
Tres lectores necesitan ese dato — el papel impreso, la validación farmacológica (dosis máxima y
contraindicación dependen de la indicación, no sólo del fármaco) y la renovación, que arrastra el
motivo del original. Es **nullable a propósito**: una receta sintomática o una profilaxis son
actos clínicos legítimos sin condición codificada, y obligarla tendría el peor modo de falla
posible — se elegiría cualquier condición con tal de poder guardar. La convención por nombre no
resuelve el destino (no existe `indication_conditions`), así que se declara en
`SALUD/FK/FK clinical.medication_requests.indication_condition_id.md`, como las tres
autorreferencias de la receta. **API:** `indicationConditionId` en el DTO de alta, persistido en
`prescribe`, en `editDraft`, **arrastrado en `replace` y en `renew`** (reemplazar corrige la
prescripción, no cambia para qué era) y **sellado en el snapshot** del historial; la validación
exige que la condición sea **del mismo paciente** y responde **422** si no lo es o no existe —
una indicación que apunta a la condición de otro paciente no es un dato incompleto, es un dato
falso que viaja al papel.

**v4.1.7 · `clinical_ext.prescription_favorites`** (tabla nueva: 16 columnas, 7 FKs, 9 índices).
Los favoritos de prescripción del profesional: la indicación que repite todos los días, guardada
con un rótulo propio. Tres decisiones que el DDL no explica solo:

- **Vive en `clinical_ext`, no en `clinical`:** no es historia del paciente —no hay paciente—
  sino una comodidad de captura, pariente de `order_sets` (la plantilla de la *organización*).
  Aplicar un favorito produce una `medication_requests` normal, con su máquina de estados y su
  firma D-05: esta tabla no participa de ningún flujo clínico.
- **Sin `status_concept_id`:** una lista de conveniencia se borra, no se archiva. No hay
  obligación de conservación clínica sobre un atajo de tipeo, y un value set «activo/borrado»
  sería vocabulario sin lector.
- **`uq_prescription_favorites_practitioner_name`:** guardar dos veces el mismo rótulo pisaría en
  silencio el favorito anterior, que es peor que rechazar el alta (409).

Declarada en **`INTENTIONALLY_EMPTY`** de `gen_seeds.py`: la lista la escribe cada profesional
desde su propia receta, y sembrarla daría atajos que nadie guardó, con el rótulo de otro, en la
lista de gente real. **API:** `GET`/`POST`/`DELETE /prescription-favorites`, siempre sobre la
lista de quien pide — el `practitionerProfileId` sale de `ProfileOwnershipService`, nunca del
cuerpo; borrar el favorito de otro responde **404** y no 403 (que exista la lista ajena no es
información que esa ruta deba confirmar).

**Verificación: de generador y de suite, no de base.** `gen_ddl.py 08` → diff de exactamente 3
piezas; `gen_ddl.py 18` → 1 tabla + 8 índices + 7 FKs, con la FK del profesional resuelta a la PK
del CTI (`health_practitioner_profiles.profile_id`); `check_ddl_sources.py` en verde;
`gen_entities.py` (08 y 18) + prettier con diffs acotados; `orm:catalog` tomó **las 7 FKs y los 8
índices** —las notas del vault se escribieron **antes** de regenerar, que es exactamente la
lección de B-10— y `clinical_ext` pasó de 12 a 13 tablas; `gen_seeds.py --dry` reconoce la tabla
nueva (17 declaradas vacías, antes 16) y las 8 «SIN DECLARAR» siguen siendo las preexistentes;
`yarn typecheck` 0 · `yarn lint` 0 · **52 suites / 351 pruebas en verde** en clinical+forms+chart.
Deltas **esperados** en base viva, **no medidos** (Docker apagado el 21/08): tablas +1, FKs +8,
índices +9. Patches en la cola: `2026-08-21_v416_medication_requests_indication_condition.sql` y
`2026-08-21_v417_prescription_favorites.sql`.

> **Hallazgo ajeno que este carril destapó y dejó resuelto.** `gen_seeds.py` **abortaba entero**
> con `value sets declarados pero sin nota en el vault: ['vs_bo_municipality']`: el carril v4.1.5
> declaró el value set en el generador —que no es repo git— pero su nota quedó en el commit
> `4c06365a` de la rama `marcelo/issuer-administrative-area`, **que nunca se mergeó a `dev`**.
> Nadie podía regenerar seeds. La nota se recuperó **desde su propio commit** (no se reescribió).
> Es el modo de falla que la política de fuentes viene advirtiendo: el generador y la bóveda
> versionan en lugares distintos.

### Reconstrucción completa del stack (2026-08-22) — VEREDICTO PASS · 18/18

Primera reconstrucción desde cero desde el 2026-08-07, y la primera que materializa la serie
4.1 entera. `python salud-db/rebuild_stack.py --yes` (down -v → up sólo infra → init con
reintento → carga completa → verificación).

**Cifras canónicas nuevas**, medidas contra la base viva (excluyendo `_timescaledb%`):

| | Antes (base vieja) | Después | Δ |
|---|---|---|---|
| Tablas | 1 192 | **1 193** | +1 |
| FKs | 6 708 | **6 717** | +9 |
| Índices | 9 157 | **9 168** | +11 |
| Schemas | 65 | **65** | — |
| FKs `NOT VALID` | — | **0** | todas convalidadas |
| Huérfanos de la carga | — | **0** | |

El salto no es de esta sesión sola: la base anterior **no tenía aplicada ninguna** de las
promociones v4.1.2, v4.1.6, v4.1.7 ni v4.1.8. `clinical_ext.prescription_favorites` no existía
—de ahí la única tabla nueva— y con ella entraron sus 7 FKs y 9 índices.

**Las cuatro columnas de v4.1.8, verificadas en la base:**

```
profiles.persons              occupation_concept_id  uuid
                              occupation_free_text   character varying   ← SIN límite
insurance.insurance_carriers  sigla                  character varying
                              address                character varying
ix_persons_occupation_concept_id   presente
fk_persons_occupation_concept_id   presente
```

Que `occupation_free_text` haya quedado `character varying` sin longitud es la confirmación de
que se aplicó el patch del modelo y no el del buzón, que la declaraba `varchar(255)`.

**Fidelidad ORM ↔ base, medida arrancando la app en `ORM_SCHEMA_SYNC=dry-run`:**

```
Deriva detectada entre el modelo y la base: 69 diferencias
  (tabla-ausente=45, obligatoriedad-divergente=24)
columna-ausente                    0
columna-obligatoria-no-mapeada     0
El dry-run no propone ningún CREATE TABLE.
Nest application successfully started · 1 168 rutas mapeadas
```

**Es exactamente el mismo 69 que midió el dry-run del 18/08**, con el mismo desglose: no apareció
nada nuevo. Las 45 son `pharma_lab` (31) + su historial en `audit` (8) —el bloqueante **B-8**— y
las 6 entidades fantasma de siempre; las 24 de obligatoriedad son en su mayoría
`polyglot_storage` y siguen sin triar. Lo que **sí** cambió es que `columna-ausente` está en
**0**: era el defecto que rompía el `INSERT` y que se venía arrastrando desde v4.1.2.

Un barrido estático independiente (1 238 entidades del ORM contra las 15 875 columnas declaradas
en `SQL/`) da el mismo 45 y confirma además **0 tablas de `SQL/` sin entidad ORM**. Dos métodos
distintos, el mismo número.

**Compilación, el mismo día:** `yarn build` de la API en **exit 0**; `yarn build` del front
completo, con 7 rutas prerenderizadas.

> [!warning] El conteo de filas ya no es comparable con el histórico
> `rebuild_stack.py` pasó a cargar con `--skip-prod` **por defecto**: el corpus MeSH es el
> 98,3 % de las filas y nadie lo consulta. Por eso la base quedó en **62 755 filas**
> (26 140 insertadas en esta corrida · 117 ya existentes · 7 avisos) y no en el 1 465 927
> histórico. Con `--con-mesh` vuelve el comportamiento anterior. Los 7 avisos son los de
> siempre: los 78 placeholders de `technical_data_type`, dos índices de OpenSearch con
> `geo_point` mal formado, el bypass de validación del `document_store` y tres claves
> naturales duplicadas en Mongo.

### Alta de paciente: campos mínimos del registro del cliente (2026-08-27) — SIN cambio de esquema

Cierra los seis datos que el registro de procesos del stakeholder (§1.1, módulo Paciente) pedía
en el alta y `POST /iam/auth/register-patient` no aceptaba: celular del tutor, domicilio con
calle y GPS, dirección de trabajo con GPS, seguro privado, seguro público y NIT.

**Las cuatro capas quedaron intactas.** `common.addresses` ya tenía `lines`, `latitude`,
`longitude` y `use_concept_id`; `common.identifiers` ya admitía `ID_TYPE_TAX`;
`profiles.related_persons` e `insurance.patient_coverages` ya existían. Lo que faltaba era
contenido y código, no esquema.

- **Conceptos dinámicos nuevos** (dueño la API): `ADDR_USE_WORK` —el modelo tenía
  `CONTACT_USE_WORK` para teléfonos pero sólo `ADDR_USE_HOME` para direcciones— y
  `OWNER_PERSON`, para que el teléfono del tutor no cuelgue de `OWNER_PATIENT` siendo alguien
  sin perfil de paciente.
- **Planes de salud**: de 4 a **23** nombrados (cuadro de productos del stakeholder; sólo
  productos con componente de salud), y el plan `BASE` pasa a existir para **todas** las
  aseguradoras como opción «Otro plan / No sé».
- **`GET /insurance-carrier-catalog`** (`@Public()`): hacía falta porque `GET
  /insurance-carriers` filtra por tenant y cada aseguradora vive en el suyo, así que desde el
  tenant de un paciente devolvía vacío. Cruza tenants pero acotado a los ids deterministas del
  catálogo sembrado.
- **Deuda declarada**: `insurance_carriers` no tiene columna de tipo de pagador ni existe value
  set público/privado — el `isPublic` se deriva del catálogo en código. Cerrarlo es trabajo de
  modelo.
- **Razón social**: no entra. `common.identifiers` sólo tiene `value`; queda en la tarjeta T-04.

**Verificado**: typecheck 0 en ambos repos · API 22 suites / 220 pruebas + 9 del catálogo nuevo ·
front 48/48 del formulario y 3 850/3 853 de la suite completa (los 3 rojos son preexistentes de
`dev`, reproducidos con los cambios guardados). Sin base viva: no se ejercitó contra Postgres.

### v4.2.10 — La aseguradora publica sus canales de contacto: WhatsApp, call center y correo (2026-09-13)

Subtarea 2.3. El registro de procesos del stakeholder (MÓDULO ASEGURADORA · 6.2 · ítem 5) pide "una
opción para poder llamar mediante Whatsapp directo a la compañía de seguro (la misma compañía nos
dará el numero de llamada o call center) y el usuario llamara desde su mismo numero de whatsapp" —
brecha §20 "Canal directo con el call center", tarjeta T-23.

**Tres columnas nullable en `insurance.insurance_carriers`, sin FK ni índice nuevo**:
`whatsapp_number` (E.164, la API lo normaliza al escribir), `call_center_phone` (tal cual la
compañía lo publica — las líneas gratuitas bolivianas son "800-10-xxxx" y no son E.164) y
`support_email`. T-23 proponía modelar esto con `common.contact_points` (polimórfico); se decidió
con el negocio el 2026-09-13 seguir columnas propias, más simple para un dato con un único dueño
posible por fila y sin necesidad de historial de vigencia.

**Sí hay backfill, a diferencia de v4.2.9**: `insurance_carriers` NO es `<<IMMUTABLE>>`, y las 9
aseguradoras bolivianas reales ya existen en toda base viva por DOS sembradores ADD-only con DOS
juegos de `carrier_code` (el boot de la API, prefijo `BO_ASEG_*`, y el paquete de seeds del modelo,
código corto tipo `ALIANZA_VIDA`): sin backfill, esas 9 compañías quedarían sin canales para
siempre. Los valores backfilleados son los publicados en el dominio oficial de cada compañía a la
fecha del patch (regla 70: fuente + fecha citadas por fila; sin publicación confirmada, `NULL`,
nunca inventado). **7 de las 9 compañías tienen al menos un canal confirmado**; Alianza Vida y
Nacional Seguros quedan sin backfill (el primero resolvió a la aseguradora de generales del mismo
grupo, no a la de vida/salud; el segundo devolvió 403 al fetch) — cerrarlo es tarea de quien
administre esas dos organizaciones vía el `PUT` nuevo, no de este patch.

Pipeline: `.puml` M26 → `gen_ddl.py all` (diff acotado a `SQL/26_insurance/02_tables.sql`) →
`SQL/patches/2026-09-13_v4210_insurance_carriers_contact_channels.sql` (con la sección de backfill
citando fuente) → `gen_entities.py 26` + `prettier --write` (el generador reformatea las 29
entidades del módulo por el mismo motivo que en v4.2.9; prettier colapsa el diff a
`insurance_carriers.entity.ts`). Seeds: `ASEGURADORAS_BOLIVIA` y `canonical_insurance_carriers`
ganan las tres claves con su `source_url`/`obtenido`, `seed_revision` → **2.5.3-v4.1.4**. Deltas
esperados sobre la base viva: columnas de `insurance.insurance_carriers` 16 → **19**, FKs e índices
±0, tablas ±0.

**Dos hallazgos, ninguno corregido acá**: (1) las 9 aseguradoras reales existen DOS VECES en toda
base viva (los `carrier_code` `BO_ASEG_*` del boot de la API y los códigos cortos del paquete del
modelo) — el backfill cubre ambos juegos de códigos, la deduplicación es de otro carril; (2) `sigla`
y `address` (v4.1.8) nunca entraron a `canonical_insurance_carriers` pese a que la documentación
del momento decía que sí — se registra, no se corrige.

**Ojo con la numeración:** v4.2.8 son las cotizaciones, v4.2.9 la cláusula del rechazo — esta
promoción es v4.2.10.

### v4.2.9 — La adjudicación de línea cita la cláusula y explica el rechazo (2026-09-12)

Subtarea 2.2. El registro de procesos del stakeholder (MÓDULO ASEGURADORA · 2 · 3) exige que la
app responda con APROBADO/NO APROBADO «indicando por qué no está APROBADO según la clausula del
contrato y porque tiene excepción de alguna enfermedad según su contrato o póliza» — brecha §19
«Cláusulas y exclusiones de póliza» de la bóveda, tarjeta T-22. `insurance.claim_line_adjudications`
sólo tenía el motivo TIPIFICADO (`reason_concept_id`, un catálogo interno de MANTRA que P-16-4 deja
sin miembros) y el texto de la versión entera (`claim_adjudication_versions.disposition_text`): sin
texto por ítem. La ficha `TAREA-16` (P-16-3) ya había anticipado exactamente esta columna.

**Dos columnas nullable, ninguna FK ni índice nuevo**: `policy_clause_reference` (varchar, la cita
de la cláusula) y `denial_rationale` (text, la justificación). **No** se agrega un tercer código
tipificado de exclusión: eso ya es `reason_concept_id`, y un value set nuevo en texto libre sería un
segundo catálogo para el mismo dato — contra la regla del proyecto de que todo catálogo cerrado es
un value set, nunca un enum de texto. Sin backfill: `claim_line_adjudications` es `<<IMMUTABLE>>` y
ninguna fila anterior puede ganar una cláusula que nadie citó en su momento.

Pipeline: `.puml` de `M26 insurance` → `gen_ddl.py all` (diff acotado a
`SQL/26_insurance/02_tables.sql`) → `SQL/patches/2026-09-12_v429_claim_line_adjudications_policy_clause.sql`
(idempotente, sin backfill) → `gen_entities.py 26`. `gen_seeds.py --dry` no reporta cambios: son
columnas nullable sin obligación de valor. Deltas esperados sobre la base viva: columnas de
`insurance.claim_line_adjudications` 9 → **11**, FKs e índices ±0, tablas ±0.

**Ojo con la numeración:** v4.2.8 ya está tomada por las cotizaciones (`billing.quotations`); esta
promoción es v4.2.9. Detalle completo en `SALUD/Arquitectura/materializacion-fisica-bd.md` de la
bóveda y en `docs/tareas/subtarea-2.2-clausula-exclusion-reclamos/` del workspace.

### Roles de gerencia en el representante legal (2026-09-11) — SIN cambio de esquema · seeds 2.5.2

Subtarea 1.4: `directory.tenant_legal_representatives` está materializada desde v4.0.4 en las 4
capas y sin un solo escritor; el registro de procesos pide, junto al representante legal con su
poder notariado, tres gerencias de contacto (ASEGURADORA 1.9-1.17) y el value set sólo nombraba
la general. `vs_legal_representative_role` gana `gerente_comercial` (ordinal 6) y
`gerente_marketing` (ordinal 7), los dos al final de la lista en la nota de la bóveda porque el
orden ES el ordinal sembrado. `poder_representante_legal` y `notaria` ya existían: el poder en
PDF no necesitó valor nuevo. Regenerado con `python salud-db/gen_seeds.py` (diff acotado a
`03_terminology.seeds.json` y `45_system_context.seeds.json`, más el bump de `seed_revision` en
los 64 módulos) y cargado a Neon con `load_seeds.py --skip-prod --refresh --skip-opensearch
--skip-redis --only 03` / `--only 45`: el value set queda con 7 miembros y el enum dinámico con
sus 7 opciones, en el ordinal esperado y con los rótulos de `VS_DISPLAY`.

**Ojo:** la deriva de 634 líneas en `08_clinical.seeds.json`
(`clinical.prescription_signature_policies`, +42 filas) que 1.2 documentó **sigue apareciendo**
al regenerar en limpio — se revirtió otra vez sin tocarla, para no mezclarla. Ver el detalle
completo y la evidencia SQL en `SALUD/Arquitectura/materializacion-fisica-bd.md` de la bóveda.

### Certificado del SEDES en los documentos de afiliación (2026-09-10) — SIN cambio de esquema · seeds 2.5.1

Subtarea 1.2: `directory.tenant_affiliation_documents` ya estaba completa desde v4.0.3 en las 4
capas; faltaba sólo contenido de catálogo. `vs_affiliation_document_type` gana
`certificado_sedes` (ordinal 8) y `vs_issuing_authority` gana `sedes` (ordinal 7), ambos al
final de sus listas en la nota de la bóveda. Regenerado con `python salud-db/gen_seeds.py`
(diff acotado a `03_terminology.seeds.json` y `45_system_context.seeds.json`) y cargado a Neon
con `load_seeds.py --refresh --only 03` / `--only 45`: 0 huérfanos, los dos conceptos vivos y
en el ordinal esperado de la versión por defecto de cada value set.

**Ojo (destapado acá):** regenerar el paquete en limpio, sin este cambio, ya difiere 634 líneas
en `08_clinical.seeds.json` (`clinical.prescription_signature_policies`, +42 filas) contra lo
commiteado en `dev` — reproducido dos veces de forma determinista, deriva preexistente ajena a
esta subtarea. Se dejó ese archivo intacto para no mezclarlo. Ver el detalle completo y la
evidencia SQL en `SALUD/Arquitectura/materializacion-fisica-bd.md` de la bóveda.
### v4.2.8 — Cotizaciones: `billing.quotations` y `quotation_installments` (2026-09-08)

T24 «Creación de cotizaciones» (FT-24) ya tenía implementación mergeada en `dev` de la API
(commit `6d6b95df`, PR #345, 2026-09-05) y del front (PR #352) — un profesional cotiza un
servicio del catálogo con un plan de pagos simulado (tasa, plazo, método FLAT/FRENCH), fija la
validez de la oferta y exporta a PDF — pero las dos tablas nunca se declararon en el modelo
canónico: sólo existían en las entidades ORM y en la copia vendida
`mantra-core-health-api/database/SQL/17_billing/`. Un stack reconstruido desde el modelo no las
tenía y `yarn db:vendor` las habría borrado de esa copia. No hay decisión de producto de por
medio: las columnas, tipos y obligatoriedad son exactamente los del DDL ya mergeado (transcrito
para cotejar, no como fuente).

`.puml` de 17 billing → `gen_ddl.py 17` (diff acotado a `SQL/17_billing/`: `02_tables.sql`,
`03_fk_intra.sql`, `04_indexes.sql`, `90_fk_deferred.sql`) → patch
`SQL/patches/2026-09-08_v428_billing_quotations.sql`. Nueve notas FK nuevas en la bóveda
(`practice_id`, `patient_profile_id`, `created_by_practitioner_profile_id`,
`service_catalog_id`, `currency_concept_id`, `status_concept_id`, `created_by_user_id`,
`updated_by_user_id`, y `quotation_id` de `quotation_installments`); todas resolvieron por
nota, cero cayeron a la convención por nombre.

**Diferencia real entre lo generado y lo mergeado, registrada y no resuelta por el generador:**
`gen_ddl.py` no tiene mecanismo para emitir `CHECK` — ninguna de las 65 tablas que sí genera
lleva uno. La API mergeada declara `interest_calculation_method varchar NOT NULL CHECK IN
('FLAT','FRENCH')`. El patch agrega ese `CHECK` a mano porque el generador no puede expresarlo;
si el pipeline gana soporte de `CHECK` más adelante, el patch queda redundante con lo generado,
no contradictorio. Segunda diferencia, sin acción: `appointment_id` no lleva FK, igual que en
lo mergeado (comentario propio del autor original: «sin destino canónico, evita anillo» entre
`scheduling` y `billing`).

**Verificado contra la base viva local** (`mantra-redesa-postgres-1`, no NeonDB): antes → 20
tablas / 140 FKs / 176 índices en `billing`; después → **22 tablas (+2) · 149 FKs (+9: 2 intra +
7 diferidas) · 188 índices (+12: 10 `IX` + 2 `PK` implícitos)**. El `CHECK` se probó insertando
un valor fuera de `('FLAT','FRENCH')`: rechazado en runtime, no sólo declarado.
`check_ddl_sources.py`: 66 hallazgos, **idénticos antes y después** (ninguno nuevo por este
cambio; son preexistentes y ajenos a T24). `gen_seeds.py --dry`: sin abortar; el único delta es
el esperado — `quotations`/`quotation_installments` entran a «tablas vacías sin declarar» (no
hay fila viva de cotización que sembrar) y +1 columna `*_concept_id` sin binding declarado.

**Pendiente, fuera de este cambio:** `yarn db:vendor` + `yarn db:vendor:check` en la API (para
que la copia vendida vuelva a coincidir con el modelo) y la corrida E2E de T24 contra un stack
con las tablas — los coordina Ender, no son parte de esta pasada de modelo.

### v4.2.6 — `role_title` deja de ser obligatorio en `practitioner_affiliations` (2026-09-05)

ALV-007 del backlog de correcciones AloVida: un vínculo de "atiende en su propio consultorio" no
tiene cargo dentro de una jerarquía, y exigirlo bloqueaba el guardado de la afiliación. `.puml` de
05 profiles → `gen_ddl.py 05` (diff de una línea en `SQL/05_profiles/02_tables.sql`) → patch
`SQL/patches/2026-09-05_v426_practitioner_affiliations_role_title_nullable.sql`
(`ALTER COLUMN role_title DROP NOT NULL`, idempotente, sin backfill).

**Efecto lateral documentado, no corregido acá:** los dos índices únicos parciales de la tabla
incluyen `role_title` en la tupla; con la columna nullable, dos filas sin cargo en la misma
institución el mismo día ya no chocan contra el `UX` — sólo el `409` del servicio las detiene. Es
una deuda conocida de esta versión, no una omisión: ALV-007 no pedía tocar los índices.

**Verificado**: `check_ddl_sources.py` PASS (única divergencia preexistente: la copia vendida de
`database/SQL` en el repo de la API, desfasada desde el merge de v4.2.5 — `yarn db:vendor` no corre
en Windows). Contra NeonDB: `information_schema.columns.is_nullable` de `role_title` pasó de `NO`
a `YES`. Sin ejercitar aún el `POST /profiles/practitioners/me/affiliations` sin `roleTitle` — eso
lo cierra el carril de API/front de ALV-007.

### v4.2.2 — El respiro de la franja, el código por sede y el permiso por turno (2026-08-27)

Tres cambios chicos con una historia común: **ejecutan decisiones que otro tomó**. Justin
respondió las cinco preguntas que dejó abiertas la promoción anterior
(`RESPUESTA-A-MARCELO-2026-08-27.md`), y dos de ellas eran de modelo. La tercera pieza —el
permiso de lectura de la historia clínica— no toca el esquema, pero cierra el único punto del
MVP que no se cumplía.

**Qué entró, en el modelo:**

| Pieza | Detalle |
|---|---|
| `scheduling.schedule_rules.gap_minutes` | integer **nullable, sin default**. El receso entre consultas, POR FRANJA. Desbloquea AG-4 |
| `ux_inventory_reservations_pharmacy_site_pickup_code` | Reemplaza al único **global** de v4.2.1: ahora `(pharmacy_site_id, pickup_code)`, sigue PARCIAL |
| `FK clinical.appointments.channel_concept_id` | La nota pasa de stub a normativa: el canal **es** la modalidad de atención |

**Delta verificado contra la base:** columnas de `schedule_rules` 14 → **15** · índices
**±0 netos** (−1 el global, +1 el compuesto) · FKs sin cambios · tablas sin cambios.

**Cinco cosas que el DDL no explica solo:**

- **`gap_minutes` es nullable porque el pedido original no era generable.** Justin pidió
  `NOT NULL DEFAULT 0`; el modelo emite `DEFAULT` para **una sola** columna en 1 194 tablas
  (`row_version`, y la emite el generador porque MikroORM no inicializa la propiedad de versión).
  Cumplir el pedido literal exigía una segunda excepción a la política «sin defaults» a cambio de
  nada: `NULL` ≡ «sin respiro» dice exactamente lo mismo que 0, y el `?? 0` lo pone el servicio,
  igual que ya hace con `slot_minutes` —su vecina, que también es nullable—. Justin retiró el
  pedido literal al ver el argumento.
- **Se corrige un índice desplegado el día anterior, y eso es deliberado.** v4.2.1 hizo el código
  de retiro único **global**. El código se muestra y se canjea siempre en UNA sede: dos farmacias
  que no se conocen pueden emitir el mismo sin que nadie se confunda. Acotarlo achica además el
  espacio de colisión que el generador debe evitar — con 6 caracteres, la unicidad global obliga a
  más reintentos a medida que crece la red. Se hizo **ahora** porque `inventory_reservations` está
  en 0 filas: con códigos vivos dejaría de ser gratis.
- **El swap crea antes de soltar.** El único global es MÁS estricto que el compuesto, así que
  mientras conviven no hay ninguna ventana por la que se cuele un duplicado — al revés sí la
  habría. Mismo criterio que v4.1.9 §B.
- **El catálogo ORM viaja acoplado al patch, no después.** El bootstrap de índices es **ADD-only**:
  si el código siguiera declarando el nombre viejo, el próximo arranque en `safe` **re-crearía el
  único global recién borrado**, reimponiendo en silencio una regla que el producto descartó.
- **El canal de la cita no necesitó columna.** `clinical.appointments.channel_concept_id` ya
  existía, sin conjunto declarado y sin que nadie la usara. La decisión —canal = modalidad de
  atención, `PRESENCIAL · TELECONSULTA · DOMICILIO`, `NULL` = presencial sin backfill— se
  documentó en su nota FK, con la advertencia de no confundirla con `scheduling:channel:*`
  (`CH_PORTAL/DESK/PHONE`), que es **por qué medio se reservó** y no **por qué medio se atiende**.
  El sembrado y el DTO son del carril AG-2.

**El permiso de lectura de la historia clínica (fuera del esquema, dentro de esta promoción).**
`GET /clinical/patients/:id/summary` era la única ruta donde cualquier médico con sesión leía la
historia de cualquier persona: la tabla `authz.clinical_access_grants` está vacía y nadie la
consulta. Ahora quien atiende pasa **sólo si hoy tiene turno confirmado con esa persona**. Cuatro
decisiones que el código no explica solo:

- **La verdad son las reservas, no la cita clínica.** `clinical.appointments` **nunca** registra
  la cancelación —`APPT_CANCELLED` no se escribe en ningún lado—, así que un turno cancelado
  seguiría abriendo la historia todo el día. Se consulta `scheduling.appointment_bookings`, que sí
  refleja el estado real y además trae la zona de la sede en la misma consulta.
- **«Hoy» es el día de la sede.** Un turno de las 23:30 en La Paz ya cayó en «mañana» para UTC:
  decidir con la fecha del servidor le cerraría la historia al profesional que tiene al paciente
  enfrente. Sede sin `time_zone` ⇒ `America/La_Paz` — IANA real y no un desplazamiento fijo,
  aunque Bolivia no tenga horario de verano.
- **El rechazo es indistinguible.** Sin turno, paciente ajeno y uuid inventado responden el mismo
  403 con el mismo texto: diferenciarlos le confirmaría a quien probó un uuid que esa persona
  existe.
- **La identidad se resuelve una sola vez.** `uq_person_account_links_active_user` vive
  **comentado** en el DDL (su predicado usa funciones que el modelo nunca definió), así que la base
  no garantiza un solo vínculo activo por cuenta: resolver dos veces en la misma petición podría
  devolver personas distintas.

**Alcance, dicho sin adornos:** cubre **una** ruta. Las otras 24 del módulo clínico siguen sin
comprobación de titularidad, esperando la definición de consentimiento con el cliente. Y
`SUPERADMIN` conserva su bypass —el guard lo trata como comodín en toda la API—, lo que queda
como pregunta abierta de producto.

**Dos tarjetas de modelo que este trabajo dejó escritas** (no se tocaron):
`uq_person_account_links_active_user` y `gist_appointments_practitioner_time` viven comentados por
predicados con funciones placeholder (`active_status()`, `held_status()`, `confirmed_status()`) que
nunca se definieron; la corrección canónica es el patrón de v4.0.9 —predicado con UUID literales,
como `ux_authentication_credentials_live_password_subject`—. Y el modelo **nunca resolvió qué
significa «cita confirmada»** en `clinical.appointments`: esta regla lo definió por primera vez, y
lo hizo sobre las reservas.

### v4.2.1 — El pedido de farmacia gana su modelo: entrega, precios congelados, código de retiro y sustituciones (2026-08-27)

**Promoción de producto, no corrección de deriva** —las cuatro capas coincidían—, y la primera que
nace de un **paquete de bloqueadores formal**: `BLOQUEADOR-FAR-E1-MODELO` (2026-08-25) y
`BLOQUEADOR-FAR-E3-MODELO` (2026-08-26), auditorías de solo lectura que enumeraban 24 y 13
capacidades contra el modelo real y llegaban a **siete cosas del contrato del front sin dónde
persistirse**. Las siete entran acá. Con eso, los dos `blockedByModel` que la API respondía
—`deliveryMode` en `ready()` y `substitutions` en `confirm()`— dejan de tener razón de ser, y
FAR-E3 entero (dispensación por código de retiro, parcial acumulativa) queda destrabado.

**Qué entró, en el modelo:**

| Pieza | Detalle |
|---|---|
| `inventory_reservations.delivery_mode_concept_id` | uuid nullable, FK a terminología, índice. `RETIRO · DOMICILIO · TRABAJO` |
| `inventory_reservations.delivery_address_id` | uuid nullable, FK a `common.addresses`, índice. La dirección **ya cargada** de la persona, no texto libre |
| `inventory_reservations.total_amount` + `currency_concept_id` | El total **congelado** al crear el pedido, con su moneda |
| `inventory_reservations.pickup_code` | varchar nullable + **único PARCIAL** `ux_inventory_reservations_pickup_code` (`WHERE pickup_code IS NOT NULL`) |
| `inventory_reservations.rejection_reason_text` | varchar nullable. Por qué la farmacia rechazó, **leído por el paciente** |
| `inventory_reservation_lines.unit_price_amount` + `currency_concept_id` | Precio unitario congelado por renglón |
| `pharmacy_inventory.pharmacy_order_substitutions` | **Tabla nueva**: 15 columnas · 8 FK · 9 índices. Las propuestas de sustitución, por línea |
| 7 conceptos | `PINV_DELIVERY_*` (3) y `PINV_SUBSTITUTION_*` (4), dueño la API |

**Delta verificado contra el generador:** tablas del módulo 25 **19 → 20**, FK **129 → 141**,
índices **141 → 154**. Sobre los conteos canónicos: **+1 tabla · +12 FK · +14 índices** (13
declarados en `04_indexes.sql` más la PK que crea Postgres sola).

**Cinco cosas que el DDL no explica solo:**

- **El pedido vive sobre `inventory_reservations`, y esa decisión ya estaba tomada.** La pregunta 1
  del paquete FAR-E1 —extender la reserva o crear una `pharmacy_orders` envolvente— la había
  respondido `dev` sin registrarlo: `pharmacy_inventory.concepts.ts` declara que «una fila con
  estado `PINV_ORDER_*` **ES** un pedido de paciente», y FAR-E1/E2 están mergeados sobre esa
  premisa. Elegir la envolvente hoy invalidaría código probado. La consecuencia es que **todas las
  columnas nuevas son nullable**: la tabla la comparten las reservas de mostrador, que no son
  pedidos. Que un pedido siempre lleve modalidad —y que la sede pueda con ella— es regla de
  servicio, no del esquema.
- **La moneda se copia, no se acuña.** El módulo tiene **cuatro juegos de conceptos de moneda sin
  unificar** (el global `CURRENCY_BOB`/`USD`, `PHARM_CURRENCY_USD`, `PINV_CURRENCY_USD` y los de
  `accounting`), los seeds usan el BOB global y la lectura los compara **por `code`**
  (`totalOf()`). Un concepto propio haría que el total congelado y el recalculado no se
  reconocieran como la misma moneda, así que `currency_concept_id` se congela **copiando** el de la
  lista de precios usada. La divergencia de fondo —el procurement hardcodea USD mientras el front y
  los seeds hablan de bolivianos— es **anterior a este patch y sigue abierta**.
- **El único del código de retiro es PARCIAL, y el prefijo lo dice.** La enorme mayoría de las
  filas no tiene código —reservas de mostrador y pedidos que aún no llegaron a
  `LISTO_PARA_RETIRO`—, y un único total no las acotaría (Postgres considera cada `NULL` distinto)
  además de obligar a razonar sobre `NULL`s en cada lectura. En el módulo 25 todos los únicos son
  `uq_`, pero la convención del modelo para un único parcial es `ux_` (v4.0.9 en `iam`, v4.1.9 en
  `profiles`): manda la naturaleza del índice, no la vecindad.
- **La tabla de sustituciones es una bitácora, no un campo mutable.** El cliente Angular ya lo
  fijaba: aceptar y preferir-el-original **dejan la fila viva** como historia. Por eso **no hay
  único por línea** —una línea cuya propuesta se rechazó puede recibir otra— y por eso hay un
  cuarto estado, `RETIRADA`, que el paquete no pedía: cubre el pedido que muere con la propuesta en
  pie, sin el cual quedaría `PROPUESTA` para siempre sobre algo que ya no existe.
- **«Congelado» no es «inmutable».** Aceptar una sustitución **recalcula** `total_amount`: el
  genérico cuesta otra cosa y el comprobante tiene que decir lo que se va a cobrar. Se vuelve a
  congelar en cada aceptación, así que esta columna **no** lleva guarda de inmutabilidad — a
  diferencia de `medication_dispensation_lines.unit_price_amount`, que se escribe una sola vez.

**`quotation_id` sigue sin destino, y es peor de lo que decía el paquete.** La pregunta 4 de FAR-E1
esperaba que `purchase_quotations` fuera el gancho natural de los precios congelados. No lo es:
esa tabla **no existe** y el `.puml` del módulo 25 **ni siquiera la declara** — la entidad MikroORM
es una de las seis «entidades fantasma» conocidas. La columna conserva su índice y su línea en
«FK sin destino canónico (no forzadas, temperatura-0)».

**Los conceptos los siembra la API, y no llevan nota `vs_*`.** Los siete son conjuntos dinámicos
cuyo dueño es `pharmacy_inventory.concepts.ts` vía `defineModuleConcepts`. Escribir la nota haría
que `gen_seeds.py` —que globea `Patch v4.*/Value sets/*.md`— se adueñara del conjunto con ids de
otro namespace: dos catálogos peleando por la misma columna, el problema del módulo 64. Mismo
criterio que v4.1.9. Como no hay backfill, **el orden de despliegue es libre**: el patch corre
antes o después de la API, a diferencia de las dos pasadas que exigía v4.1.9.

**Estado de la aplicación: APLICADO Y VERIFICADO contra base viva** (27/08, stack `mantra-redesa`).
A nivel generador y suite: el árbol `SQL/` regenerado diffea **sólo** en el módulo 25 y en el reporte
(los otros 63 salen byte a byte idénticos), `check_ddl_sources.py` pasa, `gen_seeds.py --dry` no
aborta y declara la tabla nueva vacía a propósito, `yarn typecheck` da 0 y las 18 suites del módulo
pasan con 189 pruebas. Contra la base:

| Medida | Antes | Después |
|---|---|---|
| Tablas | 1 193 | **1 194** |
| FKs (excluyendo `_timescaledb%`) | 6 718 | **6 730** |
| Índices | 9 169 | **9 183** |
| FKs sin validar | 0 | **0** |

**Las reglas se ejercitaron**, en transacciones revertidas: tres filas sin código conviven (el
parcial las ignora), el mismo código en una segunda fila se rechaza con `23505`, y una dirección o
una modalidad inexistentes se rechazan con `23503`. **Fidelidad ORM en `dry-run`: 69 diferencias
(`tabla-ausente=45`, `obligatoriedad-divergente=24`) — exactamente la deriva preexistente de B-8,
sin una sola categoría nueva**, con `columna-ausente` en **0**: las ocho columnas nuevas están en la
base y mapeadas. La app mapeó 1 184 rutas.

**Falta un paso, y es de despliegue.** Los siete conceptos los siembra la API al arrancar y el
contenedor corre una imagen anterior, así que hoy `PINV_DELIVERY_RETIRO` **todavía no existe** en
`terminology.catalog_concepts` — la FK lo rechaza, correctamente. La columna de modalidad no se
puede usar hasta redesplegar la API.

**Y algo que se destapó al verificar:** en esa base **tampoco están los diez `PINV_ORDER_*` de
FAR-E1**, que ya está mergeado en `dev`. La terminología del stack vivo está atrasada respecto de
`dev` (59 conceptos del módulo 25, el juego anterior a FAR-E1) y las tablas de negocio de farmacia
están **vacías** —huella del `yarn smoke`, que las trunca—. No es consecuencia de este patch, pero
cualquiera que pruebe el carril de farmacia contra ese stack se choca con eso antes que con nada.

**Dos hallazgos laterales, sin resolver.** (1) Los conteos de `model-manifest.yaml` estaban
**desactualizados**: el módulo 18 declara 12/12 y son 13/13 desde v4.1.7. Se corrigió el módulo 25
(19/19 → 20/20); el resto sigue viejo. Nada los consume programáticamente —`gen_ddl.py` sólo lee
`version:`—, son documentación. (2) `yarn orm:catalog` **sigue siendo destructivo para `surveys`**
(ficha B-10): regenerarlo devuelve el módulo 65 a `null` y emite un `surveys.fk.ts` con 1 de sus 36
FK. Se revirtió a mano, como en v4.1.4. La causa —las notas de bóveda del módulo 65 no existen—
sigue en pie.

### v4.1.9 — El vínculo médico–institución deja de ser texto libre sin aprobación (2026-08-25)

**Primera promoción de la serie 4.1 verificada contra base viva desde la reconstrucción del
22/08**, y **no es corrección de deriva**: las cuatro capas coincidían antes de empezar. Es una
decisión de producto que exigía modelo, como v4.1.6 y v4.1.7. Cierra **H-3** de
`SALUD/Arquitectura/alovida-prompts-correcciones.md` («el vínculo médico–organización es texto libre», con su value
set sin declarar la transición pedido → aprobado → rechazado) y desbloquea el carril MAC-VÍNCULO.
Detalle completo en la nota `SALUD/🧩 Patch v4.1.9 — Vínculo declarado, padrón oficial y escalera de verificación.md` de la bóveda.

**Qué entró, en el modelo:**

| Pieza | Detalle |
|---|---|
| `profiles.practitioner_affiliations.health_facility_concept_id` | uuid nullable, FK a terminología, índice propio. Apunta a los 503 conceptos de `VS_BO_HEALTH_FACILITY` |
| `profiles.practitioner_affiliations.decision_reason_text` | varchar nullable. Por qué se rechazó o se revocó, **leído por el profesional** |
| `ux_practitioner_affiliations_same_health_facility` · `ux_practitioner_affiliations_same_organization_name` | Dos únicos **parciales** que reemplazan al único total `uq_practitioner_affiliation_same` |
| `practitioner-affiliation-status` | Conjunto **nuevo** de 5 conceptos (pendiente · declarado · aprobado · rechazado · revocado) |
| `tenant-verification-status` | Conjunto **ampliado** de 2 a 4: los peldaños «del padrón oficial» y «reclamada» |

**Cuatro cosas que el DDL no explica solo:**

- **Los dos conjuntos son dinámicos y el dueño es la API** (`src/common/seed/dynamic-enum-catalog.ts`
  + los conceptos de módulo en `directory.concepts.ts` y `profiles.concepts.ts`). **No hay ni debe
  haber nota `Patch v4.1.9/Value sets/vs_*.md`**: `gen_seeds.py` recorre `Patch v4.*/Value sets/*.md`
  y se adueñaría del conjunto con ids de otro namespace — dos catálogos peleando por la misma
  columna, que es exactamente lo que pasó con el módulo 64 y con `practitioner-specialty` en
  v4.0.11. Mismo criterio que `VS_BO_OCCUPATION` en v4.1.8. Se documentan en el MOC de la bóveda.
- **«Declarado» es la decisión de fondo.** La regla es *aprobado sólo si alguien aprobó; pendiente
  si hay a quién preguntarle; declarado si no hay nadie*. Un vínculo declarado **publica igual**;
  lo que no tiene es el sello de la institución, y la pantalla lo dice. La alternativa —dejarlo
  pendiente hasta que alguien lo apruebe— bloquearía para siempre a los médicos de hospitales
  públicos y cajas, que nunca se van a registrar y donde por lo tanto no hay quién apruebe.
- **Los índices son parciales porque un total no serviría.** Postgres considera cada `NULL`
  distinto de los demás: un único total que incluyera `health_facility_concept_id` no acotaría
  **ninguna** fila de texto libre (probado: tres altas idénticas entran las tres). Los dos
  predicados son complementarios y ninguna fila queda afuera. Sobre base viva se crean **antes**
  de borrar el viejo — al revés queda una ventana entre el `DROP` y el `CREATE`.
- **No se migró ningún `organization_name` a concepto.** Emparejar por parecido de nombre escribiría
  adivinanzas con forma de hecho: «Hospital Obrero N.º 1» da nueve candidatos, «Sede Central
  Sopocachi» ninguno, y dos de las tres filas vivas son de La Paz, que el padrón —de Santa Cruz—
  no cubre. La columna se llena hacia adelante.

**El backfill del estado, y por qué no es «activo → aprobado».** Las filas que hoy están en
`profiles:AFFILIATION_ACTIVE` las aprobó `estadoInicial()` sin que nadie de la organización las
mirara: escribir «aprobado» fabricaría un hecho que no ocurrió. Van a **declarado**, que es lo que
son. `state:pending` → pendiente y `AFFILIATION_RETRACTED` → rechazado. Los dos conceptos viejos
quedan **deprecados** en el catálogo hasta que el servicio apunte a los nuevos y el backfill haya
corrido en todas las bases; son los ids que las filas existentes tienen escritos.

**Verificado contra la base viva (2026-08-25)** — `SQL/patches/2026-08-25_v419_practitioner_affiliations_declared_link.sql`,
primera pasada:

```text
FKs      6 717 → 6 718   (+1)
Índices  9 167 → 9 169   (+1 IX · +2 UX · −1 UK)
Columnas de profiles.practitioner_affiliations: 15 → 17
uq_practitioner_affiliation_same: ausente
C: 0 filas en estados previos — nada que migrar (esta base no tiene afiliaciones)
D: tenant-verification-status tiene 2/4 opciones — sección omitida hasta que arranque la API
E: esquema completo y sin filas en estados previos
```

Los dos índices parciales se ejercitaron con `INSERT` reales en una transacción revertida:

```text
CASO 1 OK: duplicado con establecimiento rechazado (ux_..._same_health_facility)
CASO 2 OK: duplicado por nombre rechazado (ux_..._same_organization_name)
CASO 3 OK: dos establecimientos distintos conviven (2 filas)
filas tras el ROLLBACK = 0
```

Generador y suite:

```text
python salud-db/gen_ddl.py 05        → diff exacto: +2 columnas · +1 IX · −1 UK +2 UX · +1 FK
python salud-db/gen_ddl.py all       → sólo los 3 .sql del módulo 05 (sin daño colateral)
python salud-db/check_ddl_sources.py → Fuentes de DDL OK
python salud-db/gen_seeds.py --dry   → corre entero
yarn typecheck                       → 0
yarn test src/common/seed src/orm src/modules/profiles src/modules/directory
                                     → 27 suites · 362 pruebas · 0 fallos
```

**Segunda y tercera pasada, corridas de verdad (2026-08-25).** Tras arrancar la API una vez (que
siembra los 7 conceptos, el conjunto nuevo y su amarre), la 2.ª pasada reconcila la escalera y la
3.ª deja todo igual — idempotencia comprobada, no supuesta:

```text
2.ª  NOTICE  D: escalera reordenada (0..3) y cache_token = 3fed0da7eba48af7
     NOTICE  E: esquema completo y sin filas en estados previos
3.ª  NOTICE  C: 0 filas en estados previos - nada que migrar
     NOTICE  D: escalera reordenada (0..3) y cache_token = 3fed0da7eba48af7
     NOTICE  E: esquema completo y sin filas en estados previos
     FKs=6718 · IDX=9169 (sin cambios respecto de la 2.ª)
```

**El patch se corre en dos pasadas sobre una base con filas.** Los conceptos nuevos los siembra la
API al arrancar, no el paquete de seeds: la primera pasada aplica columnas e índices y aborta el
backfill con un mensaje explícito si hay filas por migrar; la segunda, tras arrancar la API una
vez, migra y reconcilia. **La segunda pasada va después de desplegar el cambio de la API**: hoy la
lectura pública de afiliaciones sólo muestra `AFFILIATION_ACTIVE`, así que migrar antes las
haría desaparecer del perfil.

> [!bug] Hallazgo ajeno que este carril destapó, y que se vio ocurrir
> `DynamicEnumSeedService` inserta por id y no toca lo que ya existe, así que al ampliar un
> conjunto en una base ya sembrada **no reordena los ordinales ni renueva el testigo de caché**.
> No es teoría: tras arrancar la API con los dos peldaños nuevos, la base quedó así —
>
> ```text
> DIR_TENANT_UNVERIFIED      | 0
> DIR_TENANT_REGISTRY_LISTED | 1
> TENANT_VERIFIED            | 1     ← empatado con el peldaño nuevo
> DIR_TENANT_CLAIMED         | 2
> cache_token = 3f650bc5db6e746e     ← el de antes de ampliar el conjunto
> ```
>
> La sección D del patch lo reconcila (`0 · 1 · 2 · 3` y `cache_token = 3fed0da7eba48af7`).
> Y de paso: los `cache_token` de esta base **no se reproducen** con la fórmula que hoy tiene el
> código (`sha1(code + ' ' + ids)[:16]`) — ni siquiera los de conjuntos que nadie tocó—, así que
> el patch no puede predecir el valor esperado y escribe uno propio, determinista. Las dos cosas
> son del sembrador y van como tarjeta propia.

**Lo que esta promoción NO cierra**, y no es suyo:
- **H-4** (no hay estado de onboarding del profesional) sigue abierto.
- La columna que ataría un `directory.tenants` con la ficha del padrón de la que nació —la que hace
  falta para el reclamo— se decidió dejar para después: no bloquea el vínculo.
- **B-10 sigue abierto.** `yarn orm:catalog` sigue devolviendo `surveys` a módulo `null`, truncando
  sus FKs a 1 de 36 y borrando el comentario escrito a mano de `diagnostic_units.idx.ts`. Acá se
  corrió el generador —que es el único lector real de la bóveda, y por eso vale la pena— y se
  revirtieron esos tres archivos más el `surveys.fk.ts` que crea; el diff quedó acotado a
  `profiles.idx.ts` y `profiles.fk.ts`.

### v4.1.8 — Ocupación de la persona y sigla de la aseguradora, promovidas de verdad (2026-08-22)

**La mitad que faltaba de la entrega anterior, y una corrección sobre cómo llegó.** De las once
columnas que el handoff `docs/model-handoff/2026-08-22_para-marcelo.md` listaba como «cambios del
modelo que sólo existen en mi máquina», **nueve ya estaban acá**: son v4.1.4, v4.1.5, v4.1.6 y
v4.1.7, promovidas en esta copia entre el 20 y el 21 de agosto. Quedaban cuatro columnas, en dos
tablas:

| commit del ORM | tabla | columnas |
|---|---|---|
| `ceba7c4d` | `profiles.persons` | `occupation_concept_id`, `occupation_free_text` |
| `880857d6` (PR #184) | `insurance.insurance_carriers` | `sigla`, `address` |

Promovidas por el camino canónico: `.puml` de los módulos 05 y 26 → `gen_ddl.py 05` y `26` →
`SQL/` → nota `FK profiles.persons.occupation_concept_id.md` → catálogo ORM. El diff del
generador es **exactamente** lo esperado: 4 columnas, 1 índice
(`ix_persons_occupation_concept_id`) y 1 FK a `terminology.catalog_concepts`.

> [!warning] La copia que llegó como `SQLv2/` tiene el DDL editado a mano
> No es una diferencia de estilo, cambia el resultado: el índice
> `ix_persons_occupation_concept_id` está en su `SQL/05_profiles/04_indexes.sql` pero **no** en su
> `diagram_05_profiles.puml`, y la FK `fk_persons_occupation_concept_id` quedó **anexada al final**
> de su `90_fk_deferred.sql` —después de `secretary_profiles`— en vez de emitirse junto a las
> demás de `persons`. Es la firma de un `ALTER` pegado a mano sobre la salida del generador.
> **Regenerar el módulo 05 sobre esa copia habría borrado el índice en silencio.** Acá las dos
> cosas se declaran en el `.puml` y las emite `gen_ddl.py`.

> [!info] Por qué v4.1.8 y no v4.1.4
> Hay **dos numeraciones v4.1.4 en circulación**, escritas el mismo día en máquinas distintas: la
> de esta copia (departamento de expedición del carnet + `vs_administrative_area`, sección de más
> abajo) y la del handoff (catálogo boliviano + sigla de aseguradora). Los patches también chocan
> de nombre. No se renumeró ninguna de las dos —las dos están aplicadas en algún lado y renombrar
> mueve identidades— y esta promoción toma el siguiente libre. Al leer «v4.1.4» conviene mirar
> **de qué máquina viene** antes de creerle.

**Un solo dueño del catálogo de ocupaciones.** `VS_BO_OCCUPATION` (606 entradas COB-2023 del INE)
**no** entra al paquete de seeds del modelo: lo publica la API al arrancar
(`src/common/seed/bo-geography-seed.service.ts`). Declararlo también en `gen_seeds.py` daría dos
dueños del mismo conjunto con ids distintos, que es exactamente el problema que ya documentó el
módulo 64. `occupation_free_text` cubre lo que el catálogo no tenga, que es lo que el registro de
procesos pedía de todos modos.

**Tipos:** `varchar` sin límite, que es lo que emite `gen_ddl.py` y lo que declaran las entidades.
El patch equivalente del handoff (`2026-08-22_v414_catalogo_boliviano_y_aseguradora.sql`) declara
`varchar(255)`: aplicar ése deja una base parchada y una reconstruida con **tipos distintos para
la misma columna**. El patch de acá es
`SQL/patches/2026-08-22_v418_persons_occupation_and_carrier_sigla.sql` (idempotente, con bloque de
comprobación que rompe si falta alguna de las cuatro).

**Verificado (2026-08-22), sin base viva:**

```
python salud-db/gen_ddl.py all   → 1 167 tablas · el árbol SQL/ entero regenera
                                    byte a byte idéntico (0 .sql modificados)
yarn typecheck                   → 0
yarn test --testPathPatterns="(orm|profiles|insurance)"
                                 → 30 suites · 480 pruebas · 0 fallos
node tools/catalog/audit-fidelity.mjs
                                 → las 4 columnas dejan de figurar; columnasSobrantes 4 → 0
python salud-db/check_ddl_sources.py
                                 → FALLA: 60 hallazgos, los 60 en `SQLv2/`
```

> [!danger] `SQLv2/` y `Mantra Core Health Context v2/` bloquean el rebuild
> Mientras esas dos carpetas existan en el workspace, `check_ddl_sources.py` sale con **exit 1**
> por 60 `CREATE TABLE` fuera de `SQL/` — y ese script es el **paso 0/4 de `rebuild_stack.py`**,
> así que el ciclo limpio del stack no arranca. Son copias de entrega ya fusionadas: una vez
> comparadas se borran (los `.zip` siguen en la raíz). Es literalmente la «segunda fuente de DDL»
> que `ddl-sources.md` prohíbe.

**Pendiente:** aplicar a las bases vivas. Docker estaba apagado el 22/08, así que los deltas
esperados (tablas sin cambio · FKs 6 705 → 6 706 · índices 9 154 → 9 155, sumados a los de v4.1.2
y v4.1.6/4.1.7) **no están medidos**. La cola de patches sin aplicar es
`v412 · v413 · v414 · v415 · v416 · v417 · v418`
(v419 se aplicó a la base de desarrollo el 25/08 y no está en esta cola); con la base ya poblada el camino es
`rebuild_stack.py --yes`, no patches sueltos.

**Lo que esta promoción NO cierra**, y no es suyo:
- ~~`uq_diagnostic_units_tenant_id_code`~~ — **RESUELTO el 2026-08-23**: la unicidad de
  `diagnostic_units` pasó a ser compuesta `(tenant_id, code)` por las cuatro capas
  (nota de bóveda → `.puml` 23 → `gen_ddl.py` → patch a bases vivas → catálogo del ORM,
  este último a mano por B-10). Cierra las 3 pruebas en rojo que arrastraba `dev`.
  Verificado en runtime: `yarn seed:diagnostic-units` ya no muere con «no unique or
  exclusion constraint matching the ON CONFLICT specification» y deja 6 unidades en un
  mismo tenant. **Su gemela `uq_insurance_carriers_tenant_id` sigue pendiente**: misma
  pregunta, sin prueba en rojo que la fuerce, semántica menos obvia.
- El front referencia `VS_ADMINISTRATIVE_AREA` en nueve sitios y el nombre ganador es
  `VS_BO_DEPARTMENT`: esos desplegables siguen sin llenarse.
- B-10 sigue abierto: la bóveda no tiene las notas del módulo 65, así que `yarn orm:catalog`
  completo sigue siendo destructivo. Las dos filas del catálogo de esta promoción se escribieron a
  mano, en la posición exacta en que el generador las emitiría.

> [!info] Reconciliación de las copias v2 (2026-08-22)
> Las carpetas `SQLv2/` y `Mantra Core Health Context v2/` —la copia del modelo de la otra
> máquina— se compararon archivo por archivo contra los originales y se retiraron. Lo único
> que aportaban y el original no tenía eran **las dos secciones de docs de más abajo** (su
> v4.1.4 + los seeds de Bolivia), portadas verbatim. Todo lo demás era subconjunto o
> regresión: a sus `.puml` les faltaban 5 declaraciones `IX` que su propio SQL sí tenía
> (DDL editado a mano), a su módulo 18 le faltaba `prescription_favorites` entera, a su
> `patches/` le faltaba la cola v412–v418, y su módulo 64 llevaba la marca «inferida por
> convención» de un generador corrido sin la bóveda (B-3). Los `.zip` quedan en la raíz
> del workspace como registro de la entrega.

### v4.1.4 — Catálogo boliviano en el perfil y sigla/dirección de aseguradora (2026-08-22)

**Sexto caso del mismo patrón, y el primero que se manifiesta de forma intermitente.** Dos
commits del 21-ago promovieron seis columnas al ORM sin materializarlas en `SQL/`:

| commit | tabla | columnas |
|---|---|---|
| `ceba7c4d` | `common.identifiers` | `issuer_administrative_area_concept_id` |
| `ceba7c4d` | `common.addresses` | `municipality_concept_id` |
| `ceba7c4d` | `profiles.persons` | `occupation_concept_id`, `occupation_free_text` |
| `880857d6` | `insurance.insurance_carriers` | `sigla`, `address` |

Lo que lo distingue de v4.1.3: **el fallo no era total**. MikroORM sólo incluye una propiedad
en el `INSERT` cuando viene con valor, así que el alta de paciente devolvía `201` mientras
nadie completara el departamento de la cédula, y `500` en cuanto alguien lo elegía. Comprobado
en runtime, no deducido:

```
POST /iam/auth/register-patient  → HTTP 500
InvalidFieldNameException: column "issuer_administrative_area_concept_id"
of relation "identifiers" does not exist
```

Propagado a las cuatro capas. Patch para bases vivas:
`SQL/patches/2026-08-22_v414_catalogo_boliviano_y_aseguradora.sql` (idempotente, con bloque de
comprobación que rompe si falta alguna). Tras aplicarlo, el mismo alta devuelve `201` y persiste
el departamento y la ocupación.

> **Nota de nomenclatura.** El PR #203 de Marcelo resolvió a favor de `dev` el choque entre
> `issuing_administrative_area_concept_id` / `vs_administrative_area` (su rama) e
> `issuer_administrative_area_concept_id` / `VS_BO_DEPARTMENT` (dev). Este patch materializa
> **el nombre ganador**. El front todavía referencia `VS_ADMINISTRATIVE_AREA` en nueve sitios:
> es la mitad que falta.

### Seeds v4.1.4 — datos reales de Bolivia (2026-08-22)

Cinco catálogos nuevos, todos derivados de los diez markdown del stakeholder
(`markdown_convertidos/`, 7 186 filas) y contrastados contra `REGISTRO DE PROCESOS POR
MODULO.md`. Viven en `mantra-core-health-api/src/common/seed/` porque dependen de conceptos
que siembra `TerminologySeedService`, igual que el vademécum y el catálogo geográfico.

| Catálogo | Filas | Destino |
|---|---|---|
| Estudios (laboratorio, imagen, cardiología, patología, procedimientos) | 88 | `clinical.service_requests.code_concept_id` |
| Ejes de la orden (estado, intención, prioridad, categoría) | 17 | los otros 4 campos de `service_requests` |
| Formas societarias | 8 | `directory.tenants.legal_entity_type_concept_id` |
| Aseguradoras (17 privadas + 8 públicas) + producto + plan | 25 · 25 · 27 | `insurance.*` (+ 25 tenants) |
| Establecimientos de salud de Santa Cruz | 503 | conjunto `VS_BO_HEALTH_FACILITY` |

**El catálogo de estudios cerraba un flujo caído**: los cinco campos de catálogo de
`service_requests` no tenían ni una opción publicada y `code_concept_id` es NOT NULL, así que
pedir un laboratorio o una radiografía era imposible. Sus códigos son locales (`LAB_*`, `IMG_*`,
`CAR_*`, `PAT_*`, `PRO_*`) y no LOINC a propósito: LOINC nombra una *medición* con método y
espécimen, y lo que se pide y se cobra es un *servicio*.

**Las aseguradoras obligan a crear tenants**: `insurance_carriers.tenant_id` es ÚNICO, o sea
que el modelo no admite dos aseguradoras en la misma organización. Los 25 tenants nacen **sin
verificar** — nadie presentó documentación; existen para que el alta real reclame el registro
en vez de duplicar el seguro.

**Los establecimientos NO son tenants**, por lo contrario: son un directorio de consulta y
ninguno recorrió el alta que describe el registro de procesos.

Verificado tras reconstruir la imagen: 15/15 pasos del seed en verde, `failed=0`.

Entregado sin cargar, con motivo, en `mantra-core-health-api/docs/model-handoff/2026-08-22_datos-bolivia.md`:
los **4 408 aranceles** (no hay tabla destino en el modelo, y el PDF es OCR — su propia hoja de
metadatos pide validar antes de producción) y las **961 fichas de médicos** de las redes de
Alianza y Nacional Seguros (cargarlas sería crear perfiles de personas reales que nunca se
registraron). Ahí están también las tres brechas que el trabajo destapó: `VS_BO_OCCUPATION`
(las 896 del SEGIP) no existe y no está en los markdown; la sigla de Pando es `PD` en el
catálogo y `PA` en el listado del stakeholder; y `VS_MEDICAL_SPECIALTY` tiene 36 especialidades
frente a las 148 que aparecen en el mercado.

### v4.1.4 — Departamento de expedición del carnet + value set de departamentos (2026-08-20)

**Primera promoción de la serie 4.1 que NO es corrección de deriva**: nace de una decisión de
producto, no de un módulo que vivía solo en el código. El registro necesita capturar en qué
departamento fue expedido el documento de identidad —la «extensión» del carnet boliviano (SC,
LP, CB, OR, PT, TJ, BE, PA, CH)— **como dato informativo, no de login**: el paciente sigue
entrando con su número a secas y la columna no entra en ninguna clave única.

Qué entra, por las cuatro capas:

- **`common.identifiers.issuing_administrative_area_concept_id : uuid`** (nullable, FK a
  `terminology.catalog_concepts`, índice propio en el `<<INDEX_SET>>`) — en `identifiers`
  porque el CI del registro vive ahí (`ID_TYPE_NATIONAL`), al lado de su
  `issuer_country_concept_id`.
- **Value set `vs_administrative_area`** (patch `4.1.4`, módulo dueño `02` en `VS_OWNER`): los
  9 departamentos, **código = sigla de expedición** que imprime el carnet (`SC`…`CH`) y display
  curado en `VS_DISPLAY` («Santa Cruz», «Potosí» — sin el mapa, `titleize` daría «Sc»). Nota:
  `SALUD/Patch v4.1.4/Value sets/vs_administrative_area.md`. **Ojo generador:** los dos globs
  de `gen_seeds.py` sobre `Patch v4.0.*/Value sets/` se ampliaron a `Patch v4.*` — sin eso, un
  set declarado en la serie 4.1 abortaba el generador con «sin nota en el vault».
- **El mismo set cubre `common.addresses.administrative_area_concept_id`**, que existía en el
  modelo **sin catálogo sembrado**: el bloque `## Columnas` de la nota declara ambos bindings,
  y la fase 3c reasignó **16 concept_id** del mock de `addresses` que apuntaban fuera del set.
  `identifiers` y `addresses` son preexistentes (no están en `NEW_TABLES`), así que los seeds
  dejan la columna nueva en `NULL` — valor legítimo, no hueco.

**Verificación: de generador y de suite, no de base.** `gen_ddl.py 02` produce contra el
respaldo un diff de **exactamente tres piezas** (columna en `02_tables.sql`, índice en
`04_indexes.sql`, FK en `90_fk_deferred.sql`); `check_ddl_sources.py` en `Fuentes de DDL OK`;
`gen_entities.py 02` + prettier deja un diff de **solo `identifiers.entity.ts`**; `yarn
orm:catalog` suma la FK 46→47 y el índice 49→50 de `common` (**con el diff acotado a lo mío
por B-10**: se revirtió el `surveys` 65→`null` y el `surveys.fk.ts` de 1/36 FKs que la
regeneración vuelve a producir); `gen_seeds.py` emite `1 value sets · 9 conceptos · 9
miembros · 1 enums dinámicos`; `yarn typecheck` en 0. Los deltas **esperados** en base viva
son FKs 6 706 → **6 707** e índices 9 155 → **9 156** (contando los de v4.1.2 pendientes);
**no están medidos**: Docker Desktop seguía apagado el 20/08, así que el patch
`SQL/patches/2026-08-20_v414_identifiers_issuing_administrative_area.sql` queda **en la misma
cola de aplicación que v4.1.2 y v4.1.3**, y la carga del set exige `load_seeds.py --skip-prod
--refresh` (las 16 filas reasignadas de `addresses` no llegan sin `--refresh`).

> **Pendiente de producto (no de modelo):** capturar el dato en el alta — DTO de registro +
> select del front leyendo `vs_administrative_area` por terminología, con el patrón de
> validación de `vs_medical_specialty` (`422` si el uuid no pertenece al set).

**v4.1.4 (bis) — las 9 aseguradoras reales de Bolivia en el paquete (2026-08-20).** Mismo molde
que `canonical_diagnostic_units` (módulo 23): el builder **`canonical_insurance_carriers`** de
`gen_seeds.py` **reemplaza** las 12 filas sintéticas de `insurance.insurance_carriers`
(«Aseguradora Horizonte Salud Demo», colgadas de tenants mock que ni eran aseguradoras) por las
9 reales — Alianza Vida, BISA, Fortaleza, Crediseguro, La Boliviana Ciacruz, La Vitalicia,
Nacional Seguros, UNIVIDA y Santa Cruz Vida y Salud. Cada una entra como **tenant `PAYER`
propio** (módulo 04, `ASEG_*`) + fila de carrier (26, `INS.CARRIER_ACTIVE` /
`INS.VERIFY_VERIFIED` del backend, no el ACTIVE genérico) + **NIT como identificador oficial
del tenant** (`common.identifiers`, tipo `TAX_ID` — concepto **nuevo en `concepts.ts`**,
`common:id-type:tax`; el NIT NO va en `regulator_identifier`, que es el registro APS y no se
inventa) + **domicilio real** (`common.addresses`, con el departamento resuelto contra
`vs_administrative_area` — LP/SC). El puente 1b espeja los **6 conceptos** nuevos
(`PAYER`/`OWNER_TENANT`/`TAX_ID`/`OFFICIAL` centrales + `insurance:CARRIER_ACTIVE`/
`insurance:VERIFY_VERIFIED` de módulo, con la regla código=clave). Las **80 referencias**
`insurance_carrier_id` del mock (5 tablas × 16) se repuntan determinista (índice mod 9) y la
fase 2b reparó sola las 16 del log de auditoría. `SEED_REVISION` **2.4.0-v4.0.11 →
2.5.0-v4.1.4**. Verificado: regenerar dos veces deja los 4 módulos byte a byte idénticos;
`yarn typecheck` 0; specs de `terminology-seed`/`concept-seed`/`glossary-seed`/`identifiers`
9/9. **Van en `mock` a propósito**: dar de alta aseguradoras reales como tenants en producción
es una decisión de onboarding, no de seeds — promoverlas a `boot` es cambiar la sección cuando
el negocio lo decida. **Ojo al desplegar sobre base viva:** como en el módulo 23, `--refresh`
no borra las 12 demo ya cargadas — el camino es `rebuild_stack.py --yes`.

### v4.1.1 — Promoción de `surveys` (módulo 65, 2026-08-18)

**Cuarto caso del mismo patrón**, y el que más tardó en verse porque el código lo disimulaba. El
módulo de cuestionarios llegó con el carril 10 (`53689fae`, 15/08) trayendo **7 entidades
MikroORM**, controladores y servicios, y **ni un `.puml` ni una línea de DDL**. Con
`ORM_SCHEMA_SYNC=off` el schema no existe en ninguna base que el pipeline construya, así que
`GET /surveys/me/invitations` moría con `relation "surveys.survey_invitations" does not exist`
—el primer 500 que vio un usuario real fue el de la analista (F-14)— y el service lo tapó
respondiendo `200 []`, que es lo que retrasó el diagnóstico: la pantalla decía «no tenés
cuestionarios» en vez de «esto está roto».

Lo que hizo falta, y no se deduce del DDL:

- El `.puml` **transcribe** lo que ya declaraban las 7 entidades —columna, tipo y
  obligatoriedad— más los índices que el catálogo del ORM ya listaba. No se inventó ninguna
  columna ni ninguna FK que el código no declarara (temperatura-0).
- El **catálogo ORM** (`schemas.catalog.ts`) tenía `surveys` con módulo **`null`** —la firma de
  un módulo que nunca pasó por el modelo—; ahora es **65**.
- Se **retiró el degradado** de `listInvitationsOf` (el `catch` de `TableNotFoundException`). No
  se dejó «por las dudas»: mientras estuviera, una tabla que falte —un patch sin aplicar, un
  despliegue a medias— seguiría pareciendo un paciente sin cuestionarios en vez de un despliegue
  roto, que es justamente el error que costó descubrir la primera vez.

Deltas verificados con `rebuild_stack.py --yes` (**PASS**, 18/18 en `[OK]`): tablas 1 185 →
**1 192** · FKs 6 669 → **6 705** · índices 9 130 → **9 154** · schemas 63 → **64** · huérfanos
**0** · avisos de carga **7** (los conocidos). Los deltas cuadran con lo que declara el DDL
generado: `SQL/65_surveys/` tiene 7 `CREATE TABLE`, 9 + 27 `FOREIGN KEY` y 17 índices (+ 7 PK).
Patch para bases vivas: `SQL/patches/2026-08-18_v4011_surveys_promocion_modulo_65.sql`.

> **Y el patrón vuelve a aparecer, más grande: `pharma_lab` (bloqueante B-8).** Arrancando en
> `dry-run` contra la base recién reconstruida, la fidelidad ya no reporta las «6 diferencias»
> que estos documentos venían citando, sino **69 (tabla-ausente=45,
> obligatoriedad-divergente=24)**. La mayor parte es un módulo entero que vive **solo en el
> código**: `src/modules/pharma_lab/` tiene **31 entidades**, 13 controladores y **47 rutas que
> la app mapea al arrancar**, sin `.puml` ni carpeta en `SQL/`, y con módulo `null` en el
> catálogo ORM. Las 47 rutas responden 500 contra cualquier base del pipeline. **Al citar la
> deriva conocida, 6 ya no es el número.**

### v4.1.0 — Promoción de `profiles.practitioner_affiliations` (2026-08-17)

Tercer caso del mismo patrón que `audio_assets` (módulo 64) y que las tablas de v4.0.9: **código
mergeado en `dev` contra una tabla que el modelo nunca declaró**. El historial laboral del
profesional (UC-05-16, carril 05) traía entidad, repositorio, DTOs, conceptos y los dos endpoints
`GET`/`POST /profiles/practitioners/me/affiliations`, y con `ORM_SCHEMA_SYNC=off` la tabla no
existía en ninguna base reconstruida: los dos respondían **500** y la pestaña Trayectoria del
perfil no tenía dónde persistir.

Peor que en los casos anteriores: la deuda había viajado como un `CREATE TABLE` suelto en
`mantra-core-health-api/tools/alovida/2026-08-15_c05_practitioner_affiliations.sql`. Eso hacía que
`check_ddl_sources.py` abortara el **paso 0/4 de `rebuild_stack.py`**, así que desde el 15/08
**nadie del equipo podía reconstruir su stack** — justo el paso que el arranque semanal exige.

Lo que hizo falta, y no se deduce del DDL:

- La **nota FK del padre** (`SALUD/FK/FK profiles.practitioner_affiliations.practitioner_profile_id.md`).
  `gen_ddl.py` no podía inferirla por convención: el subtipo CTI comparte PK y el destino es
  `health_practitioner_profiles(profile_id)`, no `id`. Sin ella la FK salía como «sin destino
  canónico (no forzadas, temperatura-0)». Las otras 5 notas evitan que se emitan como «inferidas».
- La **nota `<<INDEX_SET>>`** (`SALUD/Entidades/E profiles.idxset_practitioner_affiliations.md`).
  El catálogo declarativo del ORM lee los índices **del vault**, no del `.puml`: sin esa nota la
  tabla quedaba en la base con sus 8 índices y el catálogo no los veía.
- **Cero cambios de código**: regenerar el módulo 05 completo (`gen_entities.py 05` + prettier)
  reproduce las 19 entidades byte a byte, incluida la que estaba escrita a mano.

Deltas verificados con `rebuild_stack.py --yes` (**PASS**, 18/18): tablas 1 184 → **1 185** ·
FKs 6 663 → **6 669** · índices 9 122 → **9 130** (6 IX + 1 UNIQUE + PK) · huérfanos **0**.
Ciclo real contra la API viva: `GET` 200 vacío → `POST` 201 → `GET` 200 con el dato → `POST`
duplicado **409** (`uq_practitioner_affiliation_same` sosteniendo la regla de negocio).
Patch para bases vivas: `SQL/patches/2026-08-17_v410_profiles_practitioner_affiliations.sql`.

### Módulo 64 — Promoción de `audio_assets` al modelo (2026-08-12)

El módulo TTS nació en el código (`mantra-core-health-api/src/modules/audio_assets/`, commit
`ec02e3e`, 2026-08-10) y vivió **dos días sin existir en el modelo**: tenía entidades MikroORM,
catálogo de índices y hasta un servicio de seed, pero ni `.puml` ni una línea de DDL en ninguna
parte. Con `ORM_SCHEMA_SYNC=off` eso significa que sobre una base reconstruida el schema
sencillamente no existía: `relation "audio_assets.audio_assets" does not exist` en toda consulta,
y el int-spec de contabilidad de presupuesto que llegó con el PR #49 fallaba 6 de 6.

La promoción **transcribe**, no diseña: `diagram_64_audio_assets.puml` declara exactamente las
columnas, tipos y obligatoriedad que ya tenían las 4 entidades, más los 10 índices que ya estaban
en el catálogo ORM. Lo único que el código no declaraba explícitamente es la FK
`audio_assets.tenant_id → directory.tenants`, que estaba como comentario al lado de la columna y
`gen_ddl.py` resuelve por convención de nombre.

| Delta | Antes | Después |
|---|---|---|
| Tablas | 1 180 | **1 184** (+4) |
| FKs | 6 661 | **6 662** (+1) |
| Índices | 9 107 | **9 121** (+14: 10 declarados + 4 PK) |
| Schemas | 57 | **58** |

Verificado contra la base viva: las 4 tablas con 33/13/10/13 columnas —las mismas que las
entidades—, la FK `fk_audio_assets_tenant_id` en `convalidated`, y el int-spec
`audio-budget-accounting` en **6/6**.

Tres decisiones que no se deducen del DDL:

- **Sin `row_version`.** Ninguna de las 4 entidades lo declara, así que el `.puml` tampoco. No
  es un olvido de la transcripción: el módulo no compite por la misma fila fuera de la reserva de
  presupuesto, que ya se serializa con `SELECT … FOR UPDATE`.
- **Los vínculos entre tablas del módulo son por clave natural, sin FK.**
  `audio_generation_events.asset_key` no puede tener FK porque la bitácora debe sobrevivir a los
  intentos que fallaron antes de que existiera el asset. `audio_assets.template_key` tampoco,
  porque la clave de negocio de la plantilla es `(template_key, version)` y una FK de una sola
  columna no puede referenciarla.
- **Las 4 tablas van a `INTENTIONALLY_EMPTY` en `gen_seeds.py`.** El catálogo de plantillas lo
  siembra la propia app al arrancar (`AudioAssetsSeedService`); sembrarlo también desde el paquete
  daría dos dueños del mismo catálogo con ids distintos. Las otras tres son runtime puro.

### v4.0.11 — Identidad de la persona: nombre en cuatro partes y foto (2026-08-10 · 2026-08-12)

`profiles.persons` gana **cinco columnas, todas NULLABLE**: las cuatro partes del nombre
(`name`, `middle_name`, `last_name`, `mother_last_name`; 2026-08-10) y `photo_file_id`
(2026-08-12), un uuid hacia `common.files` con el mismo patrón que ya usaba
`health_practitioner_profiles.photo_file_id`. `display_name` se conserva como forma derivada,
lista para pintar; el porqué del desdoble está en la nota `PERSON_NAME` del propio
`diagram_05_profiles.puml`. La foto es de la **persona** y no del perfil: identifica a quien
entra por la puerta cualquiera sea su rol, y duplicarla por perfil obligaría a elegir cuál
manda cuando difieren.

| Delta | Antes | Después |
|---|---|---|
| Columnas de `persons` | 18 | **23** (+5) |
| FKs | 6 662 | **6 663** (+1: `fk_persons_photo_file_id`) |
| Índices | 9 121 | **9 122** (+1: `ix_persons_photo_file_id`) |

Las bases vivas migran con **dos patches idempotentes** (fuera de `apply_all.sql`, como
siempre): `SQL/patches/2026-08-10_v4011_person_name_components.sql` y
`SQL/patches/2026-08-12_v4011_persons_photo_file_id.sql`. En un rebuild desde cero no hacen
falta: `SQL/05_profiles/` ya declara todo.

Verificado ejecutando el 2026-08-12 contra el stack `mantra-redesa`: `POST
/iam/auth/register-patient` con las cuatro partes → **201**, login con ese documento → 200,
`display_name` compuesto en la fila; conteos medidos **1 184 tablas · 6 663 FKs · 9 122
índices**; fidelidad en `dry-run` → `6 diferencias (tabla-ausente=6)` (las 6 fantasmas de
siempre, **cero** `columna-ausente`); re-aplicar ambos patches → no-ops.

> **La lección de P14 (por qué esta sección existe).** El desdoble del nombre se hizo el
> 2026-08-10 en las 4 capas… **de esta máquina**. `Mantra Core Health Context/`, `SQL/` y
> `salud-db/` no son repos git, así que el trabajo nunca llegó a los entornos de los demás:
> el autorregistro devolvía 500 (`column "name" of relation "persons" does not exist`) en
> toda base construida desde una copia vieja de `SQL/`, y quedó documentado como P14 en
> `PENDIENTES-BACKEND.md` del front. Hasta que `SQL/` tenga un canal de distribución
> versionado, **todo cambio del modelo viaja con su patch y se anuncia**; el patch es el
> vehículo, no el arreglo (regla de `db-fidelity`).

### v4.0.11 — Tres defectos del rebuild en limpio, corregidos (2026-08-13)

La verificación independiente de v4.0.11 en una segunda máquina (PR #28 del vault) destapó
tres defectos que solo muerden al reconstruir desde cero. Los tres se corrigieron **en la
herramienta, no en la base**; detalle completo en `materializacion-fisica-bd.md` del vault.

**1 · El canal EMAIL tenía dos dueños.** El paquete traía `messaging.message_channels` con
`code = 'EMAIL'` e id propio; `MessagingSeedService` busca su canal **por id determinista**,
no lo encontraba, insertaba y chocaba con `uq_message_channels_code` — el seed de mensajería
abortaba entero y el producto no podía mandar un solo correo. El arreglo NO fue
`INTENTIONALLY_EMPTY` (es solo la allowlist del reporte de cobertura; vaciar la tabla dejaba
`channel_id NOT NULL` sin destino y colapsaba `uq_message_templates_channel_id_version`):
fue el **patrón puente de la fase 1b** — `phase_backend_bridge` espeja el trío del backend
(canal `EMAIL` + proveedor `DEFAULT_EMAIL` + config, más sus 3 conceptos) **con los mismos
ids** que deriva `deterministicId()`, y `retire_legacy_email_channel` sustituye 1:1 el canal
legacy repuntando sus 16 referencias. Con ids idénticos el seed de la app queda en no-op:
un solo dueño lógico. Paquete regenerado: boot 5 710 → **5 715**; segunda corrida, 0 cambios.

**2 · `salud-db/` no declaraba sus dependencias.** Nació `salud-db/requirements.txt`
(`psycopg[binary]`, `pymongo`, `redis`) y `rebuild_stack.py` las verifica con
`ensure_python_deps()` antes de `import load_seeds` y de tocar Docker — antes, `pymongo`
reventaba recién en el paso de Mongo, con los 63 módulos ya cargados en Postgres.

**3 · La carrera del initdb de timescaledb-ha.** En el primer arranque sobre volumen nuevo
el servidor temporal pasa `pg_isready` y reinicia; el `up -d` abortaba con `dependency
failed to start: container postgres is unhealthy`. Ahora `up_infra_with_retry()` reintenta
el `up` (idempotente, no re-baja imágenes) esperando a que `postgres` reporte `healthy` en
3 lecturas consecutivas (`wait_postgres_stable`) — reintentar el ciclo entero era la
respuesta equivocada.

### v4.0.10 — Endurecimiento del pipeline (2026-08-06)

Cierra las tres deudas de generador que destapó v4.0.9. **Sin tablas ni columnas nuevas**:
cambia cómo se nombran, protegen y regeneran los artefactos, no qué declara el modelo.

**1 · Identificadores > 63 bytes (las "58 FKs divergentes", resueltas).** No eran dos
convenciones: ambos lados construyen `fk_<tabla>_<columna>`, pero 58 nombres de FK y 1 de
índice superan 63 bytes, `gen_ddl.py` no acortaba (PostgreSQL trunca **en silencio**) y la
capa 06 del bootstrap —que acorta con prefijo 54 + `_` + sha1-8 (`shortenIdentifier`)— los
daba por ausentes y proponía recrearlos en cada arranque. `gen_ddl.py` ganó `pg_ident()`,
**puerto byte-idéntico** de ese algoritmo (paridad verificada 58/58 contra lo que el ORM
proponía). `SQL/` renombra los 59; las bases vivas migran con
`SQL/patches/2026-08-06_v4010_rename_long_identifiers.sql` (58 `RENAME CONSTRAINT` + 1
`ALTER INDEX RENAME`, idempotente, generado programáticamente del diff). El hash no es
decorativo: dos FKs de `insurance.prior_authorization_determinations` comparten los
primeros 54 caracteres y solo el sufijo las distingue.

**2 · WORM de auditoría promovido al modelo (CAN-AUDIT-001 / C-19).** El guard que vivía
como patch suelto entró a la **matriz del módulo 33** (dos entidades `REFERENCE_ONLY`
nuevas) y `gen_integrity.py` aprendió el caso asimétrico: `audit_log` prohíbe
UPDATE+DELETE (`trg_forbid_mutation`) y `data_access_log` **solo UPDATE**
(`trg_forbid_update`, clave nueva `UPDATE : forbidden`) — su DELETE queda para la purga de
retención de UC-10-09. Nace `SQL/10_audit/05_constraints.sql` y `gen_apply.py` lo engancha
solo a `apply_all.sql`. El spec `audit-worm.int-spec.ts` pasa 2/2 contra los triggers
generados (las aserciones `/WORM/` pasaron a `/append-only|immutable/`, el mensaje real de
`integrity.forbid_mutation()`; el `ERRCODE` sigue siendo `restrict_violation`). Alcance
deliberado: solo las 2 tablas del patch original — las otras 7 `<<LOG>>` del módulo 10
exigen decidir la política de purga tabla por tabla (tarjeta aparte, mecanismo listo). De
paso, `gen_integrity.py` dejó de mentir `v4.0.1` en sus cabeceras: lee la versión del
manifest como `gen_ddl`.

**3 · La regeneración de entidades vuelve a ser segura (ADR-0022).** Tres generadores
escribían `src/modules/**/entities/` y ninguno emitía el JSDoc (lo inyectó
`generate-documentation.mjs` una sola vez, sin script); regenerar destruía la
documentación y por eso estuvo vetado de facto desde v4.0.8. Ahora `gen_entities.py`
**preserva los bloques `/** … */` existentes** (por nombre de propiedad) y el barrel es la
unión de lo generado más los exports cuyo archivo siga existiendo — las 6 tablas fantasma
y los contratos jsonb no desaparecen del ORM en silencio. Los tipos `RuleCondition` y
`CancellationPolicySnapshot` salieron de las entidades a `.types.ts` propios re-exportados
por el barrel. Verificado regenerando las 1 186: **19 archivos con diff, todos benignos**
(sufijo `(inferida)`, `fieldName` redundantes, orden de columnas del `.puml`, 1 barrel
reordenado), 7/7 entidades con prosa a medida intactas, build y typecheck en verde. La
política quedó en **ADR-0022** (cuerpo por `gen_entities.py` → `prettier` →
`yarn docs:tsdoc`); **`orm:gen` retirado** — cuatro documentos lo declaraban canónico y
nunca produjo las entidades del repo.

**Verificación independiente del cierre (2026-08-07).** Releída la cadena entera sobre los
artefactos, sin re-ejecutar el build: `model-manifest.yaml` declara `version: 4.0.10` y es de
ahí que `gen_ddl.model_version()` la toma (las cabeceras generadas ya no pueden mentir);
`SQL/` emite **58** identificadores `fk_…_<hash>` de 63 bytes —exactamente los 58 que renombra
el patch, más su `ALTER INDEX`— y **no queda un solo identificador de más de 63 bytes** en
`SQL/` fuera de `patches/`, que es la invariante que cierra el truncado silencioso;
`SQL/10_audit/05_constraints.sql` tiene los dos triggers asimétricos; `package.json` ya no
declara `orm:gen`; `mantra-core-health-api/database/` y `salud-db/sql/` siguen sin existir.
Los otros **61 `ix_` y 25 `uq_`** con sufijo hash que hay en `SQL/` son anteriores a v4.0.10
—el acortado de índices ya existía— y por eso el patch no los toca.

**Verificado también contra la base viva (2026-08-07).** El stack `mantra-redesa` estaba
levantado y v4.0.10 **ya está aplicado**: 58 FKs con el nombre nuevo (`fk_…_<hash>`, 63 bytes),
el índice renombrado presente y el nombre viejo ausente, y los dos triggers WORM instalados
(`trg_forbid_mutation` en `audit.audit_log`, `trg_forbid_update` en `audit.data_access_log`).
Conteos: **1 180 tablas · 6 661 FKs · 9 107 índices**, y los 6 661 FKs de la base son
exactamente los 6 661 declarados en `SQL/`. **Huérfanos: imposibles por construcción** — las
6 661 FKs están **todas validadas** (`convalidated`, 0 `NOT VALID`), así que Postgres mismo
rechaza cualquier fila que las viole; no hace falta creerle al scan.

Dos hallazgos que parecían deriva y no lo son, comprobados en vez de asumidos: las **15 FKs de
exactamente 63 caracteres sin hash** están las 15 declaradas así en `SQL/` (nombres que dan
justo el límite, no truncados), y los **4 schemas de más** en la base son `public`,
`toolkit_experimental` (catálogo de TimescaleDB), `time_series` y `vector_rag` (los crea
`NoSQL/`, no `SQL/`).

**Fidelidad en runtime (`ORM_SCHEMA_SYNC=dry-run`, 2026-08-07):**
`Deriva detectada … 6 diferencias (tabla-ausente=6)` — las 6 entidades fantasma conocidas y
nada más; `columna-ausente`, `columna-obligatoria-no-mapeada` y `obligatoriedad-divergente` en
**0**. La app levanta (`Nest application successfully started`) y el `dry-run` no alteró la
estructura (conteos idénticos antes y después). Entrada real del build: **`dist/src/main.js`**,
no `dist/main`.

**Dos defectos de herramienta que la verificación destapó, corregidos el 2026-08-07.**

1. **Los dos verificadores dev-time estaban inejecutables.** El default de `SALUD_VAULT` en
   `tools/catalog/lib/vault.mjs` apuntaba a `mantra_core_technologies_health_docs/SALUD`, ruta
   que dejó de existir cuando la bóveda pasó a `Mantra Core Health Vault/`. No degradaba:
   `audit-fidelity.mjs` y `generate-catalog.mjs` morían con `ENOENT` al arrancar, así que
   `orm:audit` y `orm:catalog` no corrían. Con el default corregido, la auditoría da
   `entidadesFaltantes: 0 · entidadesSobrantes: 0 · columnasFaltantes: 0 · fkDeclaradas: 6 621
   = fkEnCatalogo: 6 621` (quedan `columnasSobrantes: 5`, `tiposDivergentes: 6` y
   `obligatoriedadDivergente: 2`, preexistentes).
2. **`orm:catalog` destruía documentación escrita a mano.** `emitChunks()` hacía
   `rmSync(dir, {recursive: true})` antes de escribir, y se llevaba puestos
   `src/orm/catalog/foreign-keys/README.md` e `indexes/README.md` (12 KB de prosa que ningún
   generador sabe reproducir) — el mismo defecto que ADR-0022 corrigió para el JSDoc de las
   entidades. Ahora borra solo lo generado (`*.ts`). Verificado regenerando: los README
   sobreviven y el catálogo queda **byte a byte idéntico** (151 archivos, 0 diferencias), lo
   que confirma de paso que el generador es determinista y que el catálogo estaba al día.

> Los **58 índices descartados** que reporta `orm:catalog` no son un defecto: son predicados
> que invocan una función sin argumentos (`active_status()`), marcador de un valor que el
> modelo todavía no decidió. `gen_ddl.py` los emite comentados en `SQL/` por el mismo motivo,
> así que las dos capas coinciden.

**Con el auditor ya ejecutable aparecieron 3 derivas más, las tres corregidas (2026-08-07).**
El informe pasó de `columnasSobrantes: 5 · tiposDivergentes: 6 · obligatoriedadDivergente: 2`
a **las seis categorías en 0**:

1. **El vault nunca recibió las 4 columnas de v4.0.8.** `journal_transactions.approved_at` y
   `approved_by_user_id` (C-17), `users.must_change_password` (C-18) y
   `appointment_bookings.cancellation_policy_snapshot` (CAN-APT) estaban en el `.puml`, en
   `SQL/`, en la base y en el ORM, pero **no en las notas de entidad de la bóveda**: la
   promoción recorrió las cuatro capas técnicas y se saltó la de documentación. Añadidas con
   su procedencia.
2. **`vector_rag.embedding_model_versions.approved_at` / `retired_at` estaban declaradas
   obligatorias en la entidad** mientras el `.puml`, `SQL/`, la bóveda y la base viva las
   tienen **nullable** — el patch `2026-07-25_v407_nullable_…` se aplicó a la base y la
   entidad nunca se regeneró. Insertar sin esos campos habría fallado en el ORM contra una
   base que sí lo permite. Corregidas a `nullable: true` + `?`.
   > **Causa de fondo, con tarjeta propia:** las **26 entidades de `vector_rag` y
   > `time_series` no las produce ningún generador** — `gen_entities.py 59` responde
   > `sin entidades relacionales (especializado/no-SQL) — omitido`. Por eso esta deriva pudo
   > sobrevivir desde el 2026-07-25: no hay nada que regenerar y diffear. Extender
   > `gen_entities.py` a los stores materializados en PG es el arreglo real.
3. **6 falsos positivos de tipo** que enterraban lo anterior: la bóveda escribe
   `technical_data_type` y la entidad `"terminology"."technical_data_type"`. La tabla de
   equivalencias del auditor **ya** contemplaba el par, pero su normalizador no quitaba las
   comillas dobles, así que nunca hacía match. Un `replace(/"/g, '')` en `typeCompatible()`.

**Hueco de modelado que la revisión destapó y NO se resolvió** (es decisión, no mecánica):
`authz.service_principals` está declarada con **solo su clave primaria** en las cuatro capas
(1 columna, 0 filas), lo que contradice el §5.7 del plan, que especifica
`service_principal_code` e `is_human`. Queda anotado en su nota de la bóveda.

**Otras validaciones ejecutadas el 2026-08-07:** `yarn typecheck` exit 0 · `yarn test`
**439 suites / 4 500 pruebas en verde** (890 s; antes se documentaban 365/3 666) ·
`yarn docs:validate` OK (OpenAPI válido, AsyncAPI 0 errores, 200 páginas, 655 enlaces internos
sin romper) · bóveda completa **44 247 wikilinks, 0 rotos**. `yarn docs:build` queda
**BLOCKED**: mkdocs no está instalado y los scripts invocan `python3`, que en Windows no
existe.

**Seeds — idempotencia comprobada, y un faltante real.** `load_seeds.py --skip-prod
--skip-mock` sobre la base ya poblada dio `TOTAL insertados: 12 · ya existentes: 5 698`.
**Postgres no recibió ninguna fila nueva**: los 12 son plantillas de índice de **OpenSearch**
(`search_index_templates (boot) +12 · ya:0`), que faltaban en el stack vivo. El paquete boot
son 5 710 filas y 5 698 + 12 cierra exactamente.

**Smoke — 1/834, el preexistente y nada más.** `yarn smoke` corrió en 140 s y aseveró:

```text
Smoke: 1/834 casos fallaron
  IntegrationContracts · happy: entrega webhook:
  POST /integration/webhooks/<id>/deliveries esperaba 201, obtuvo 422
```

Es el fallo de webhooks ya documentado en v4.0.9; **ningún caso nuevo** y ninguno de Clinical.
Dos advertencias para leer su salida: jest reporta **«1 suite / 1 test»** porque los 834 casos
viven dentro de una sola aserción agregada —el `1 failed` es *la* aserción, no un caso—, y el
smoke **trunca las tablas de negocio**, así que después hay que correr `rebuild_stack.py --yes`
y no `load_seeds.py --refresh`.

**Rebuild completo desde cero — VEREDICTO: PASS (2026-08-07).** Ejecutado tras el smoke, que es
su único camino de recuperación. Las 18 comprobaciones en `[OK]`, y las tres de v4.0.9/v4.0.10
ya no dependen de un patch sobre una base viva: **se materializan desde `SQL/` en una base
limpia**.

```text
[OK] tablas BD == SQL/                       esperado 1180  observado 1180
[OK] FKs BD == SQL/                          esperado 6661  observado 6661
[OK] FKs acortadas con hash (pg_ident)       esperado   58  observado   58
[OK] triggers WORM de audit (v4.0.10)        esperado    2  observado    2
[OK] tablas v4.0.9 (email_verifications, password_resets)  esperado 2  observado 2
[OK] ux_..._live_password_subject es PARCIAL esperado    1  observado    1
[OK] uq_..._issue_idempotency_key es PARCIAL esperado    1  observado    1
[OK] huérfanos de la carga                   esperado    0  observado    0
[OK] política D-05 comodín (tenant DEFAULT)  esperado  >=1  observado    1
[OK] init postgres-init / mongo-init / opensearch-init     esperado 0  observado 0
(informativo) índices: 9107 · filas insertadas: 1465927 · avisos de carga: 7
VEREDICTO: PASS
```

Filas del paquete v4.0.8 pobladas: `care_relationships` 8 · `patient_legal_representations` 8 ·
`prescription_signature_policies` 27 · `booking_confirmation_rules` 8 · `account_activations` 8.
Los **7 avisos son los ya conocidos** (78 placeholders de `technical_data_type`, `geo_point` de
los dos índices de directorio en OpenSearch, tipos BSON del mock del 55, y 3 duplicados por
clave natural en Mongo saltados). Duración observada: **~7 min** de `down -v` → esquema y unos
**10 min** más de carga.

> **Al medir el avance de una carga, el conteo de filas engaña.** `load_seeds.py` inserta
> dentro de una transacción abierta, así que `pg_stat_user_tables.n_live_tup` queda **clavado**
> hasta el commit: una ventana de 90 s dio «0 filas» con el proceso a pleno (180 s de CPU).
> Lo que sí crece antes del commit es `pg_database_size()`.

Hallazgo preexistente que este cierre NO toca (tarjeta aparte):
`redis-runtime.int-spec.ts` y `search-platform.int-spec.ts` esperan **403** para un actor
sin tenant y la API responde **422** (el mapeo `PreconditionFailed→422` del proyecto) — es
una discrepancia de contrato del guard de tenant, anterior a v4.0.9.

### v4.0.9 — Promoción de la verificación de correo y el restablecimiento (2026-08-05)

Segunda corrección de deriva **del mismo origen que v4.0.8, y por la misma causa**: un
merge de `dev` había devuelto `mantra-core-health-api/database/` junto con los montajes
del compose apuntando a esa copia interna, y encima de ella se siguieron escribiendo
migraciones sueltas hasta acumular once.

La diferencia con v4.0.8 es que esta vez **el efecto sí se consumó**. Nadie aplicaba esa
carpeta —el compose monta `../SQL`—, así que `iam.email_verifications` no existía en base
limpia y **los 27 casos de registro del smoke respondían 500**.

Se promovieron al modelo **2 tablas**, **1 columna** y **2 índices únicos parciales**:

| Objeto | Módulo | Venía de |
|---|---|---|
| `iam.email_verifications` | 01 | `2026-07-30_patient_self_registration.sql` |
| `iam.password_resets` | 01 | `2026-08-01_password_reset.sql` |
| `clinical.medication_requests.issue_idempotency_key` | 08 | `2026-07-28_prescription_issue_idempotency.sql` |
| `ux_authentication_credentials_live_password_subject` | 01 | `2026-07-31_credentials_external_subject_unique.sql` |
| `uq_medication_requests_issue_idempotency_key` | 08 | `2026-07-28_prescription_issue_idempotency.sql` |

Reglas ALOVIDA que las sostienen: CAN-IDENT, CAN §6 (MISSING_IDEMPOTENCY).

`ux_authentication_credentials_live_password_subject` es **el primer índice del modelo con
`concept_id` como UUID literales**. Es una excepción consciente a la regla de no hardcodear
conceptos: el predicado de un índice parcial debe ser inmutable y PostgreSQL no admite
subconsultas ahí. Son UUIDv5 deterministas sobre `SALUD_UUID_NAMESPACE`, iguales en todos
los entornos. El índice es parcial a propósito —una credencial revocada con el mismo sujeto
no debe bloquear un alta nueva— y cierra la carrera bajo `READ COMMITTED` por la que dos
altas concurrentes creaban dos cuentas para el mismo documento.

**Tres defectos de generador destapados y corregidos** (todos en el pipeline del catálogo
del ORM, `tools/catalog/`):

1. **CRLF.** `lib/vault.mjs` parseaba la bóveda con patrones `\n` literales, y sus 2 547
   notas están guardadas con CRLF. Ninguna casaba. No fallaba: producía una bóveda que
   parecía vacía, y `yarn orm:catalog` escribía un catálogo con cuatro índices y borraba el
   resto. Se normalizan los finales de línea al leer, y se añadió un fusible
   (`assertVaultLooksRead`) que aborta si el parseo se derrumba en masa.
2. **La etiqueta `UX` no existía** en el lector de índices (`PK|IX|UK|FT|GIN|GIST`), así que
   se descartaba en silencio. Por eso `ux_account_activations_token_hash`, de v4.0.8, nunca
   había llegado al catálogo. Ahora los tipos son los mismos que acepta `gen_ddl.py`.
3. **El predicado `WHERE` se descartaba** y `IndexTuple` no tenía dónde guardarlo. Un índice
   parcial habría salido como `UNIQUE` **total**: no un índice peor, sino otra regla —un
   único llano sobre `external_subject` rechaza un alta legítima cuyo sujeto tuvo antes una
   credencial revocada—. `IndexTuple` ganó un sexto elemento opcional, la capa 05 del
   bootstrap lo emite, y el generador escapa las comillas del predicado (sin eso el archivo
   generado no compilaba). El mismo guard de `gen_ddl.py` descarta los predicados con
   funciones marcador (`active_status()`), para que el catálogo no declare un índice que el
   DDL canónico se niega a crear.

Regenerar el catálogo con el lector corregido **recuperó** lo que se había perdido:
7 381 → 7 676 índices y 6 438 → 6 621 FKs declaradas.

**El generador de seeds pasó a llamarse `gen_seeds.py`** (era `gen_seeds_v407.py`): el sufijo
venía de la versión en que se escribió y llevaba tres versiones mintiendo, así que se retiró
para que nombre lo que hace, como el resto de los generadores. Se bumpearon
`SOURCE_MODEL_VERSION` y `RELEASE_LABEL` a `4.0.9` y `SEED_REVISION` a `2.3.0-v4.0.9`.

> **`MODEL_VERSION` sigue en `4.0.7` y `PATCH_V408` en `4.0.8`, y eso no es deuda:** son los
> namespaces con que se derivaron por uuid5 los ids que la base ya tiene. Moverlos cambiaría
> todos los identificadores del paquete. Lo que el paquete declara hacia afuera es
> `SOURCE_MODEL_VERSION`, que sí acompaña la versión del modelo.

Las dos tablas nuevas quedaron declaradas en `INTENTIONALLY_EMPTY`: guardan tokens de un solo
uso que emite la aplicación, y sembrarlas no sería dato de arranque sino una credencial de
recuperación pregenerada, con hash conocido y viva en todo entorno que cargue el paquete.
Regenerado el paquete: **boot 5 710 · mock 18 973**, checksums byte-idénticos entre corridas
(determinista) y sin cambios en los datos — solo en los metadatos de versión. `seedsProd/`
(corpus MeSH v6.1) **no lo afecta el bump**: es un artefacto externo con su propio versionado.

`mantra-core-health-api/database/` se eliminó otra vez (450 archivos), junto con
`salud-db/sql/`, un residuo de v4.0.1 con 8 tablas del módulo 01. La política que lo
sustituye está en [`ddl-sources.md`](ddl-sources.md) y en
[ADR-0021](../../../mantra-core-health-api/docs/adr/ADR-0021-fuente-unica-de-ddl.md), y
`salud-db/check_ddl_sources.py` la hace cumplir como paso 0/4 de `rebuild_stack.py`.

**Rebuild completo verificado** (`rebuild_stack.py --yes`): **VEREDICTO PASS** ·
**1 180 tablas · 6 661 FKs · 9 107 índices · 1 465 927 filas · huérfanos 0 · 7 avisos**
(los mismos conocidos). Fidelidad en `dry-run`: `Deriva detectada … 6 diferencias
(tabla-ausente=6)` — las 6 históricas y ninguna nueva, con `columna-ausente`,
`columna-obligatoria-no-mapeada` y `obligatoriedad-divergente` en 0.

> **Deriva conocida que este trabajo destapó y no resuelve:** el bootstrap propondría 58
> claves foráneas que la base no tiene. No son FKs faltantes: son las mismas constraints con
> **otro nombre**, porque `gen_ddl.py` y el lector de la bóveda las nombran distinto. Con
> `ORM_SCHEMA_SYNC=off` es inocuo, pero es deuda con tarjeta propia: hay que decidir qué
> nomenclatura manda y alinear los dos generadores.

### v4.0.8 — Promoción de las reglas ALOVIDA al modelo canónico (2026-07-30)

El merge de `dev` en `mantra-core-health-api` había introducido DDL propio en
`mantra-core-health-api/database/SQL/` (6 migraciones + 1 política RLS + 1 seed), fuera de los
`.puml` y de `SQL/`. Ese DDL **nunca lo aplicaba `docker/db-init/init-postgres.sh`**, así que
la deriva estaba **latente, no consumada**: al inspeccionar la base viva antes del rebuild
(2026-07-30) las 5 tablas y las 11 columnas **no existían**. Lo que sí era real es el vector:
`ORM_SCHEMA_SYNC` tiene default `safe` y las entidades ya estaban en el ORM, de modo que el
siguiente arranque de la aplicación las habría creado por su cuenta — la dirección de cambio
prohibida por el protocolo de 4 capas.

Se promovieron al modelo **5 tablas** y **11 columnas**:

| Tabla nueva | Módulo | Regla ALOVIDA |
|---|---|---|
| `authz.care_relationships` | 06 | CAN-AUTH-001, C-06, C-07, A-03 |
| `authz.patient_legal_representations` | 06 | CAN-AUTH-001, C-06, C-07, A-03 |
| `clinical.prescription_signature_policies` | 08 | D-05, CAN-RX |
| `scheduling.booking_confirmation_rules` | 41 | C-11 |
| `iam.account_activations` | 01 | C-18, CAN-IDENT |

Columnas: `journal_transactions.approved_at/approved_by_user_id` (C-17);
`medication_requests.signed_at/signed_by_user_id/issued_at/status_reason_text/replaces_request_id/replaced_by_request_id/renewed_from_request_id`
(CAN-RX); `appointment_bookings.cancellation_policy_snapshot` (CAN-APT);
`iam.users.must_change_password` (C-18).

Las FKs que las migraciones declaraban **como comentario** (`-- FK → iam.users`) son ahora
constraints reales. Eso destapó una referencia colgada: `care_relationships.practitioner_profile_id`
apuntaba a `profiles.practitioner_profiles`, **que no existe**; la tabla real es
`profiles.health_practitioner_profiles` y la FK se resuelve por nota del vault
(`SALUD/FK/FK authz.care_relationships.practitioner_profile_id.md` → `("profile_id")`, la PK CTI).

`mantra-core-health-api/database/` **se eliminó**. Su política RLS y su seed de vademécum
viven ahora en `SQL/patches/` (`2026-07-30_tenant_rls.sql`,
`2026-07-30_vademecum_dev_seed.sql`), fuera de `apply_all.sql`, porque no se derivan de los
`.puml` ni los consume `load_seeds.py` (que solo lee `*.seeds.json`).

### Seeds v4.0.8 — las 5 tablas ALOVIDA pobladas, D-05 deja de ser fail-open (2026-08-05)

`gen_seeds.py` pasó a revisión **`2.3.0-v4.0.9`** (`SOURCE_MODEL_VERSION = "4.0.8"`;
`MODEL_VERSION = "4.0.7"` queda intacto: entra en la derivación uuid5 de todas las filas ya
vivas en la base). Tres piezas nuevas:

1. **Fase 1b «puente backend»** — espeja en el paquete (módulos 03/04) las filas que
   `TerminologySeedService` materializa al arrancar con el namespace del backend
   (`SALUD_UUID_NAMESPACE = 3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60`): fuente → code system →
   versión → **17 conceptos** (`state:*`, tenant, `authz:CARE_REL_*`,
   `authz:REPRESENTATION_*`, `scheduling:RULE_SCOPE_TENANT`, `scheduling:DECISION_*`) →
   tenant `DEFAULT` (21 filas). Los servicios (PDP, motor C-11, D-05) comparan los
   `*_concept_id` contra **esos** ids; sin el puente, la fase 2b del generador «reparaba»
   las FKs de las tablas nuevas hacia conceptos al azar. Ambos lados insertan por id y son
   idempotentes entre sí.
2. **`NEW_TABLES_V408`** (claves nuevas `patch`/`fixed`/`choices`/`custom` sobre el formato
   de `NEW_TABLES`): `authz.care_relationships` 8 mock · `authz.patient_legal_representations`
   8 mock · `scheduling.booking_confirmation_rules` 8 mock (**solo mock a propósito**: el
   motor C-11 ya es fail-closed con la tabla vacía; una regla boot inventada cambiaría el
   comportamiento de reservas en producción sin spec aprobada) · `iam.account_activations`
   8 mock.
3. **Builder `canonical_signature_policies`** — una política comodín
   (`jurisdiction_code`/`medication_type_concept_id`/`channel_concept_id` en NULL,
   `signature_required = true`) por tenant del paquete en
   `clinical.prescription_signature_policies`: **11 boot + 16 mock = 27 filas**. Lo
   jurisdiccional fino sigue **PENDIENTE_DE_APROBACIÓN** (decisión legal D-11 del vault);
   ver `SALUD/Arquitectura/politica-firma-recetas-d05.md`.

**D-05 verificado ejercitando la regla** contra la política sembrada del tenant `DEFAULT`
(2026-08-05): `POST /clinical/medication-requests` → 201; `POST …/issue` sin firmar →
**422** `La política vigente exige firmar la receta antes de emitirla` (la
`PreconditionFailedException` del proyecto mapea a 422, no a la 412 de Nest);
`POST …/sign` → `POST …/issue` → **200**, receta en `MEDICATION_REQUEST_ISSUED` con
`signed_at` e `issued_at` en la base. El smoke de clinical ejercita ahora ese ciclo
(política propia vía API porque su harness trunca los datos de negocio, 422 sin firma,
sign, issue 200, deactivate).

**Rebuild completo verificado** (`down -v` + `up` + `load_seeds.py --refresh`): **1 178
tablas · 6 653 FKs · 9 099 índices · 1 465 927 filas insertadas · huérfanos totales: 0 ·
7 avisos** (los mismos conocidos, ninguno de PostgreSQL). Generador idempotente (2ª corrida:
0 filas en todas las fases, `checksums.json` byte-idéntico); re-carga con **0 filas nuevas
en PostgreSQL** (los +428 de la re-corrida son Redis con TTL y re-index de OpenSearch,
volátiles por diseño). Paquete: boot 5 678 → **5 710** · mock 18 925 → **18 973**.
`yarn typecheck` · `yarn build` · **412 suites / 4 095 tests unitarios en verde**. Smoke:
**los 5 casos D-05 nuevos pasan**; el total da **28/834 fallos, ninguno de Clinical** — 27
son la cascada de los registros de persona (`register-*` → 500 porque
`iam.email_verifications` no existe en una base canónica limpia; bloqueador documentado de
la tarjeta M1, destapado por el primer `down -v` con `ORM_SCHEMA_SYNC=off`) más 1 de
webhooks de IntegrationContracts (preexistente).

Tres correcciones colaterales del mismo cierre:

- **Deriva `.puml → SQL/`**: `IDX_HEAD_RE` de `gen_ddl.py` no reconocía la etiqueta `UX` y
  descartaba en silencio `ux_account_activations_token_hash` (el único `UX` de los 64
  `.puml`, declarado por el index set de `iam.account_activations`). Corregido en el
  generador y regenerado `SQL/01_iam` (+1 índice único, 9 098 → 9 099).
- **Regresión del compose**: un merge de `dev` volvió a montar `./database/SQL` y
  `./database/NoSQL` (la copia interna del repo API, **sin** las tablas v4.0.8) en los
  servicios init; se restauraron los montajes canónicos `../SQL`/`../NoSQL`.
  `mantra-core-health-api/database/` volvió a existir por ese mismo merge — su
  reconciliación definitiva es alcance de la tarjeta M1.
- **Deriva de fidelidad ahora 9** (antes 6; `dry-run` 2026-08-05): las 6 históricas +
  `iam.email_verifications` y `iam.password_resets` (entidades de M1 aún sin promover) +
  `columna-ausente` nueva `clinical.medication_requests.issue_idempotency_key` (propiedad
  agregada al ORM sin promover la columna — no rompe el flujo de emisión, pero es la
  dirección de cambio prohibida; va con M1).

### Materialización de los patches v4.0.2 → v4.0.7 (2026-07-24)

Los patches de diseño v4.0.2–v4.0.6 (documentados en el vault) se materializaron en las cuatro
capas: `.puml` (+24 entidades, +24 index sets, +8 columnas en 4 tablas, en los módulos
01/04/06/11/16/19/38/41/42) → `SQL/` regenerado (1 147 `CREATE TABLE`) → BD viva → ORM
(1 147 entidades). Las 8 columnas sobre tablas ya pobladas se aplicaron con
`SQL/patches/2026-07-24_v402-v407_alter_columns.sql` (idempotente; incluye backfill del
concepto boot `FREE` de `vs_subscription_plan_tier`, id determinista
`f845c4f2-3f92-5a97-b76b-30f71c0cb43c`, y `SET NOT NULL`). `SQL/patches/` **no** entra en
`apply_all.sql`: en un rebuild desde cero las columnas ya vienen en el `CREATE TABLE`.

Además se aplicó a la BD el backlog de FKs resueltas por la auditoría del grafo
(`fk-resolution-audit-2026-07-24`): **+492 FKs**. Las 92 FKs que entonces quedaron sin crear
por filas huérfanas de los seeds ya están resueltas: ver `auditoria-seeds-2026-07-24.md` —
el paquete de seeds se corrigió y se recargó, y el barrido final deja **0 FKs sin crear**
(6 638 en total).

v4.0.7 no agrega esquema: aporta la **regla 11** del estándar de modelado (registro atómico
CTI: padre e hija en la misma transacción, `persons → person_profiles → *_profiles`) y los
casos de uso UC-05-01…04.

Hubs de FKs entrantes (coincide con `semantic-data-analysis.md` §3.2): `terminology.catalog_concepts`
2 331 · `iam.users` 1 717 · `directory.tenants` 271.

### Bootstrap automático del stack Docker

El compose incluye 3 servicios one-shot idempotentes (scripts en
`mantra-core-health-api/docker/db-init/`, corren en cada `docker compose up` y saltan si ya existe):
`postgres-init` (apply_all → apply_deferred → NoSQL 58/59; monta `SQL/` y aplica con `psql -f`
para que los `\ir` relativos funcionen), `mongo-init` (colecciones + `$jsonSchema` en la base del
`MONGODB_URI`), `opensearch-init` (PUT de cada `.mapping.json` si el índice falta).

### Stores NoSQL (formato nativo, directorio `NoSQL/`)

55→MongoDB (`createCollection` + `$jsonSchema` + índices) · 56→Redis (spec de keyspaces) ·
57→OpenSearch (`mappings`; tipos adaptados a OpenSearch: `flattened`→`flat_object`, `_id` omitido) ·
58→TimescaleDB (hypertables) · 59→pgvector (columnas `vector` + HNSW).

### Datos semilla — CARGADOS en el stack Docker (2026-07-23)

Cargados con `salud-db/load_seeds.py` (deployment job idempotente: re-run = 0 filas nuevas;
orden 03 boot → resto boot → corpus MeSH por shards → mock solo dev):

- PG: **1 464 726 filas** — MeSH completo (`catalog_concepts` 356 202 · `concept_designations`
  997 286 · `concept_relationships` 89 802) + boot/mock de los 64 módulos.
- Mongo 101 docs · Redis 224 keys (TTL declarado) · OpenSearch ~131 docs.
- Técnica: carga con `session_replication_role=replica` + verificación de huérfanos post-load
  (política del `load-plan.json`); `ON CONFLICT DO NOTHING` (uuid5 determinista); hypertables
  sin PK por `WHERE NOT EXISTS` con cast al tipo real.
- **Paquete de seeds al día en v4.0.7** (2026-07-24): ver `auditoria-seeds-2026-07-24.md`
  (raíz del repo). 33 value sets de los patches sembrados (164 conceptos + enums dinámicos en
  M45), boot/mock de las 24 tablas nuevas, y corregidos 1 280 FK huérfanas, 895 NOT NULL
  ausentes, 3 032 valores con tipo incompatible y 697 claves naturales duplicadas.
  Generador: `salud-db/gen_seeds.py`; carga con `load_seeds.py --refresh`.
- **Rebuild del stack dev (2026-07-25)**: reconstruido desde cero (`docker compose down -v` +
  `up` + carga completa) para eliminar el residuo de cargas anteriores. Verificado:
  **6 638 FKs con 0 filas que las violen**, 1 464 726 filas, 16 avisos de carga (antes 112).
  Sobre la base vacía el DDL crea las 6 638 FKs sin un solo fallo.
- **Cierre del paquete de seeds (2026-07-25)**: el paquete quedaba con defectos que el
  generador no veía. Se cerraron **en el generador**, no en los datos (`gen_seeds.py`,
  fases nuevas): `[2c] cobertura` — siembra las tablas relacionales sin cubrir y **falla si
  aparece una tabla vacía no declarada** (`INTENTIONALLY_EMPTY`: 9 de runtime + el stub
  PK-only `authz.service_principals`); `[3c] value sets` — reasigna los `*_concept_id` que
  apuntan fuera del value set que los ata (binding del modelo), lo que corrigió 12
  `plan_quotas.overage_policy_concept_id` que apuntaban a `DEFAULT_RECEIPT_TYPE`;
  `[3d] nulos del modelo` — vacía los valores que solo existían para satisfacer un NOT NULL
  incorrecto. Además la barrera de tipo ya cubre `vector(N)`.
  **Las UK de los stores 58/59 eran invisibles** para las fases de desambiguación:
  `parse_unique()` solo leía `SQL/*/04_indexes.sql` y esos índices viven en `NoSQL/`, así que
  6 tablas morían con 23505 y el savepoint por entidad las descartaba enteras
  (`vector_documents` había quedado con **0 filas** en la BD). Corregido `parse_unique()` +
  dos estrategias nuevas de desambiguación: reapuntar la FK de la fila mock que choca con una
  boot (`[4]`, antes solo renombraba claves de texto) y, en columnas uuid **sin FK declarada
  ni fila destino en el paquete** — el caso de 58/59, que no declaran FKs —, emitir un uuid
  determinista propio por fila (`[4b]`). Paquete final: **24 603 registros**
  (boot 5 678 · mock 18 925), 21 799 ids únicos, **0 columnas huérfanas · 0 NOT NULL sin
  valor · 0 tipos incompatibles · 0 concept_id colgados**, 121 538 celdas FK verificadas
  contra el paquete **sin una sola violación**, `seed-manifest.json` y `checksums.json`
  coherentes, y el generador **idempotente en las 11 fases**. Recargado en la BD: **6 avisos
  de carga** (antes 16) y **ninguno de PostgreSQL** — los 6 son de Mongo/OpenSearch.
- **Corrección de modelo (2026-07-25)**: `vector_rag.embedding_model_versions.approved_at` y
  `.retired_at` eran NOT NULL — una versión de modelo no nace aprobada ni retirada, y el
  NOT NULL obligaba a sembrar timestamps sin significado. Corregido en las cuatro capas:
  `.puml` → `gen_nosql.py 59` → BD (`SQL/patches/2026-07-25_v407_nullable_embedding_model_versions.sql`,
  que además pone `retired_at = NULL`) → entidad MikroORM. «Versión vigente» pasa a ser
  `retired_at IS NULL`; `ix_embedding_model_approval` sigue sirviendo sin recrearse.

### ORM

Entidades MikroORM **generadas**: 1 147 entidades / 55 módulos en
`mantra-core-health-api/src/modules/<schema>/entities/` (camelCase + `fieldName`, verificadas con
tsc/build/lint + discovery offline). Scaffolding Nest (module/controller/service) en los 55 módulos.

## 4. Pendientes

- Confirmar con el propietario los **precios del catálogo de planes** (`subscription-plans-catalog.md`),
  hoy marcados `‹SUPUESTO›` y sembrados con esos valores (Free 0 · PRO 29/290 · MAX 99/990), y
  asignar por tier las 3 métricas y 2 features que los value sets declaran y el catálogo no cubre.
- **6 avisos de carga**, ninguno de PostgreSQL: 3 duplicados de clave natural en Mongo, 16 docs
  de OpenSearch que fallan por el formato de `geo_point`, y el mock de `document_store` que se
  inserta con `bypass_document_validation` por tipos string vs BSON.
- **`*_concept_id` sin binding declarado: 2 247 columnas** (antes 2 363). El modelo declara el
  binding de dos formas: `dynamic_enum_bindings` para las columnas de los 33 value sets de los
  patches, y el bloque `## Columnas` de la nota del value set en el vault (`*.columna` para todas
  las tablas que la declaren, o `schema.tabla.columna`). El generador **no infiere bindings por
  nombre**: sin declaración, la columna no se toca. Ampliar la cobertura es declarar más columnas
  en el vault, no tocar el generador.
- **Cuatro casos que NO se pudieron atar** porque el value set, no la columna, es lo que está
  incompleto o mal planteado — cada uno es una decisión de modelo:
  - `VS_LANGUAGE` tiene un solo miembro (`EN`) pero el modelo usa `ES_BO` en **1 117** celdas de
    `language_concept_id`. Falta el miembro, no sobra el dato.
  - `VS_SEVERITY` está en inglés (`CRITICAL·INFO·LOW·MEDIUM`) y los datos usan el vocabulario
    castellano (`BAJA·MEDIA·ALTA·CRITICA`). Hay que unificar el vocabulario primero.
  - `VS_PURPOSE_OF_USE` no incluye `RESEARCH` ni `LEGAL_OBLIGATION`, que el modelo sí usa.
  - `status_concept_id` / `state_concept_id` (585 columnas) **no** comparten un value set global:
    cada entidad tiene su propia máquina de estados (`vs_security_incident_status`,
    `vs_feedback_status`, …). Atarlas a `VS_LIFECYCLE_STATE` rompería 132 celdas correctas.
    El binding correcto es por entidad, en la nota del value set de cada una.
- Definir el vocabulario canónico del enum `technical_data_type` (§3.2 del análisis semántico);
  hoy contiene placeholders sintéticos agregados para poder cargar.
- Completar `UK/CHECK/EXCLUDE` de `SQL/*/05_constraints.sql` (el módulo 33 los declara en prosa).
- Cerrar las **23** FK sin destino canónico restantes (antes 472; el resto se resolvió con la
  auditoría del 2026-07-24 y ya está aplicado a la BD).
- Casos de uso del backend (services/controllers son stubs); paquete de migraciones MikroORM.
  Los casos de uso deben honrar la **regla 11** (v4.0.7): registro atómico padre+hija CTI en una
  sola transacción (ver `data-modeling-standards.md` regla 11 y `orm-mapping-guide.md`).
