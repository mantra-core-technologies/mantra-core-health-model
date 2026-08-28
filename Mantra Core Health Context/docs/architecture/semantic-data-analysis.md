# Análisis semántico de la estructura de datos — SALUD v4.0.1

> **Propósito.** Entender *qué significan* los datos y *cómo se organizan* antes de mapear la base y generar el ORM. Este documento es **panorámico y orientado a ORM**; **no es DDL, no es producción**. Complementa (no duplica) [`orm-mapping-guide.md`](orm-mapping-guide.md), que cubre la capa mecánica del mapeo. La fuente de verdad sigue siendo el PlantUML por módulo (`modules/diagram_NN_*.puml`) y el `model-manifest.yaml`.

**Inventario de referencia (v4.0.1):** 64 módulos · 52 schemas · 2607 declaraciones `entity` (1212 tablas/store · 81 vistas · 120 stubs de referencia) · 1194 conjuntos de índices · 6452 FK.

---

## 1. Qué representa el modelo (una frase)

Una **plataforma de salud políglota, multi-tenant y consent-gated**: PostgreSQL es la **fuente única de verdad** relacional; diez stores especializados (documentos, Redis, búsqueda, series temporales, vectores, objetos/PACS, grafo, lakehouse) son **proyecciones gobernadas** que se alimentan por *outbox* desde PostgreSQL. El significado de cada dato está anclado a un **catálogo de terminología** y protegido por **consentimiento + autorización + auditoría inmutable**.

Tres ejes semánticos atraviesan TODO el modelo y hay que interiorizarlos antes de mapear:

1. **Terminología primero** — casi ningún valor "de dominio" es texto libre o enum nativo; es un `concept_id` hacia el catálogo.
2. **Nada se pierde** — no se borra ni se sobrescribe evidencia; se versiona, se marca vigencia o se anexa historia.
3. **Todo lo sensible se gobierna** — quién, con qué propósito, bajo qué consentimiento y con qué prueba de autorización.

---

## 2. Mapa de dominios (bounded contexts)

**Un schema PostgreSQL = un bounded context.** Los 64 módulos se agrupan en 11 dominios funcionales. Las dependencias entre contextos se dibujan como **stubs `<<REFERENCE_ONLY>>`** (una tabla de otro schema que este contexto solo referencia, no posee): **son las costuras del modelo** y marcan los límites de agregado.

| Dominio | Módulos (schema) | Semántica |
|---|---|---|
| Identidad y Seguridad | iam(01), authz(06), consent(07), identity_assurance(27), delegated_access(29), auth_providers(40) | Quién es, qué puede, con qué permiso/propósito, con qué prueba de identidad. |
| Núcleo y Terminología | platform(00), common(02), terminology(03), directory(04), profiles(05), geo(13), health_context(44), system_context(45) | Tipos compartidos, catálogo de conceptos, tenants, personas/perfiles, enums dinámicos. |
| Clínico y Diagnóstico | clinical(08), forms(09), chart(15), clinical_ext(18), diagnostics(20), diagnostic_units(23), qa_lab(36), procedures_perioperative(53) | El acto clínico: encuentros, órdenes, observaciones, notas, laboratorio, cirugía. |
| Farmacia | pharmacy(24), pharmacy_inventory(25) | Medicación, dispensación, inventario. |
| Financiero y ERP | accounting(16), billing(17), insurance(26), erp(38), payments(42) | Dinero, seguros, contratos, pagos. |
| Operaciones de Plataforma | system_ops(11), deployment(21), telemetry(28), workflow(32), platform_ops(46), automation(48) | Gobierno del sistema, despliegue, telemetría, workflows, agentes. |
| Integraciones y Contratos | integrations(12), integration_contracts(31), integrity(33), messaging(35), tracking(37) | Conectividad externa, mensajería, trazabilidad logística. |
| Marketing y Crecimiento | community(19), portal_catalog(34), ads(43), education(47), crm(49), marketing(50), promotions(51) | Audiencias, campañas, CRM, contenido, promociones. |
| Práctica y Agenda | practice(14), organization_extensions(22), scheduling(41) | Sedes, unidades, agenda. |
| Auditoría y Reporting | audit(10), read_models(30), reporting(39) | Historia WORM, proyecciones de lectura, informes. |
| Datos y NoSQL | health_data_platform(52), polyglot(54), document(55), redis(56), search(57), time_series(58), vector_rag(59), object(60), graph(61), cross_store_consistency(62), lakehouse(63) | Plataforma de datos y los stores especializados. |

> Para el ORM: cada schema se mapea con `@Entity({ schema })`. Las costuras `<<REFERENCE_ONLY>>` **no** generan una segunda entidad — se referencian por id a la entidad real de su contexto dueño.

---

## 3. Columna vertebral semántica (patrones transversales)

Estos patrones aparecen en decenas de módulos. Reconocerlos es más importante que memorizar tablas.

### 3.1 Identidad: **cuenta ≠ persona**
- `iam.users` `<<ACCOUNT>>` es una **cuenta que autentica**, no un ser humano ni un paciente.
- `profiles.persons` `<<MASTER_IDENTITY>>` es la **persona real**; los perfiles (`patient_profiles`, `health_practitioner_profiles`, `person_profiles`) son **subtipos** que comparten PK con la persona (`profile_id : uuid <<PK,FK>>` → Class Table Inheritance).
- `person_account_links` / `patient_identity_links` conectan personas ↔ cuentas ↔ identidades externas. **Un paciente o profesional puede existir sin cuenta de portal.**
- *Implicación:* nunca asumir `user_id == patient`. La atribución (`created_by_user_id`) apunta a la **cuenta**; la clínica apunta al **perfil/persona**.

### 3.2 Terminología como **motor de enums**
- `terminology.catalog_concepts` + `value_sets` + `concept_maps` son el sistema de enumeraciones. **Toda** columna `*_concept_id` es FK a un concepto, restringida a un `value_set` por CHECK/trigger.
- Regla del modelo: **no** enums nativos de PostgreSQL (salvo `technical_data_type`).
- *Implicación:* `catalog_concepts` es el **hub más conectado** del grafo (~2.300 FK entrantes). En el ORM se mapea como `@ManyToOne`/FK uuid, **no** como enum de TypeScript (ver `orm-mapping-guide.md §2.2`).

### 3.3 Consentimiento + autorización (gating)
- `consent` (directivas de privacidad, bases legales, evidencia, restricciones) responde *"¿se puede tocar este dato, para qué propósito?"*.
- `authz` (roles, permisos, políticas, **field masking**, purpose-of-use) responde *"¿este actor, en esta sesión, puede?"*. v4.0.1 añadió **permisos protegidos no delegables** (`permissions.is_role_restricted/required_role_code/allow_direct_user_grant`).
- *Implicación:* la lectura de datos sensibles pasa por evaluación de consentimiento + política; el ORM no es la barrera (lo es RLS + guardas de aplicación).

### 3.4 Auditoría e historia: **nada se sobrescribe**
- `audit.*_history` `<<HISTORY>>` (113 tablas) = versionado **SCD-2** de cada tabla de negocio: se **inserta un snapshot**, no se pisa.
- `audit.audit_log` `<<LOG>>` = registro **WORM** append-only de acciones (WORM = write-once, read-many).
- `<<LOG>>` / `<<IMMUTABLE>>` / `<<APPEND_ONLY>>` = evidencia cruda: solo INSERT, barrera física en BD.
- *Implicación:* estas entidades **no exponen update/delete** en el ORM (ver `orm-mapping-guide.md §3`).

### 3.5 Multi-tenencia y custodia
- `tenant_id` = a qué inquilino pertenece la fila; `custodian_tenant_id` = quién la **custodia** (puede diferir en datos compartidos).
- La barrera dura es **RLS en PostgreSQL**; el filtro de tenant del ORM (`@Filter`) es conveniencia.
- *Implicación:* toda consulta sobre tablas con `tenant_id` debe filtrar SIEMPRE por tenant.

### 3.6 Ciclo de vida: **validez temporal + estado**, no *soft-delete*
- El modelo casi no usa `deleted_at`. En su lugar:
  - `status_concept_id` = estado actual (concepto), con máquinas de estado en `workflow`(32) (`<<STATE_MACHINE>>`).
  - `valid_from` / `valid_to` (≈243/230 usos) = **vigencia de negocio** (versión con período).
  - `anonymized_at` = borrado GDPR por anonimización, no por eliminación física.
- *Implicación:* muchas entidades son **temporales/bitemporales**: no mapear como fila única mutable; un cambio puede ser una nueva versión vigente.

### 3.7 Concurrencia y prueba de gobierno
- `row_version : integer` en toda tabla de negocio → **locking optimista** (`@Version()`).
- `*_hash` (`content_hash`, `approved_audience_hash`) y `*_snapshot_json` (`authorization_snapshot_json`) **congelan** contenido/autorización en el momento del acto — inmutabilidad por valor.
- `idempotency_key` + índices `UNIQUE` = ejecución exactamente-una-vez (workers, outbox).

### 3.8 Persistencia políglota (canónico → proyección)
- PostgreSQL escribe la tabla canónica **y** el evento `messaging.outbox_messages` en la **misma transacción**; un worker idempotente proyecta a los stores 54–63.
- Estereotipos de proyección: `<<MONGODB_COLLECTION>>`, `<<REDIS_KEYSPACE>>`, `<<OPENSEARCH_INDEX>>`, `<<TIMESERIES_MEASUREMENT>>` (+ `<<TIME/SERIES/PARTITION_KEY>>`), `<<VECTOR_STORE>>`, `<<OBJECT_CATALOG>>`, `<<GRAPH_COLLECTION>>`, `<<LAKEHOUSE_CATALOG>>`; `<<CONSISTENCY_CONTROL>>`/`<<CONTROL_PLANE>>` gobiernan la reconciliación y el borrado cruzado.
- *Implicación:* los módulos 54–63 **no se mapean como entidades del ORM relacional** (ver `orm-mapping-guide.md §4`).

---

## 4. Tipos y valores compartidos (candidatos a *value objects*)

El módulo `common`(02) define los tipos que se reúsan en todo el modelo:

- `identifiers` — identificadores externos tipados (documento, MRN, etc.).
- `contact_points` — teléfono/email/canal (valor + tipo + verificación).
- `addresses` — dirección postal/geo.
- `files` (+ `file_versions`, `file_links`, `file_derivatives`) — adjuntos versionados con derivados.

*Implicación ORM:* decidir por tipo si es **embeddable** (value object incrustado en la tabla dueña) o **entidad compartida referenciada** (tabla propia con FK). El modelo los declara como **entidades propias** (tablas), enlazadas por FK — punto de partida: entidad compartida, no embeddable, salvo que el mapeo justifique lo contrario.

---

## 5. Agregados clave y sus costuras

Aggregate roots candidatos (con qué contextos limitan vía `<<REFERENCE_ONLY>>`):

- **Identidad** — `persons` (+ perfiles CTI) ↔ `iam.users`. Raíz de la persona; los perfiles cuelgan compartiendo PK.
- **Historia clínica / encuentro** — `clinical.encounters` + `chart` (notas versionadas) + `forms` (formularios dinámicos). Núcleo del acto asistencial.
- **Orden → diagnóstico** — `clinical` (orden) → `diagnostics`/`qa_lab` (estudio, muestra, resultado). El resultado codificable vive en PostgreSQL; el binario/imagen en object store.
- **Cadena de comunicaciones (v4.0.1)** — `marketing.campaign_schedules` → `campaign_dispatches` → `campaign_dispatch_recipients` → `messaging.notification_requests` → `notification_deliveries` → `delivery_tracking_events`. Cada paso conserva `authorized_by_user_id` humano + `authorization_snapshot_json`; el tracking es append-only en 3 capas.
- **Financiero** — `accounting` (asientos) ↔ `billing` (facturas) ↔ `payments` ↔ `insurance`; costuras a `erp` por `<<REFERENCE_ONLY>>`.

> Las costuras `<<REFERENCE_ONLY>>` te dicen **dónde termina un agregado**: si un contexto solo referencia (no posee) una tabla, esa tabla es raíz de OTRO agregado.

---

## 6. Convenciones de nombres (diccionario semántico)

| Sufijo/patrón | Significado | Consecuencia de mapeo |
|---|---|---|
| `*_id : uuid <<PK>>` | Clave primaria de negocio | `@PrimaryKey()` uuid |
| `profile_id : uuid <<PK,FK>>` | Subtipo CTI (comparte PK con la base) | Relación 1:1, no tabla independiente |
| `*_concept_id` | Enum vía terminología | `@ManyToOne` a `catalog_concepts`, no enum TS |
| `*_type_concept_id` | **Discriminador** de una referencia polimórfica | Ver `*_ref_id` |
| `*_ref_id : uuid` (sin `<<FK>>`) | **Referencia polimórfica** (a cualquier entidad del tipo declarado) | **No** relación normal — resolución por `(type, ref_id)` en la app |
| `*_hash`, `*_snapshot_json` | Congelado inmutable (gobierno/evidencia) | `@Property()`, nunca recalcular a posteriori |
| `created_by/updated_by/authorized_by_user_id` | Atribución a **cuenta** | FK a `iam.users` |
| `tenant_id` / `custodian_tenant_id` | Pertenencia / custodia | Filtro de tenant + RLS |
| `valid_from/valid_to`, `effective_from/to` | Vigencia de negocio | Modelo temporal, no fila mutable única |
| `row_version` | Locking optimista | `@Version()` |

---

## 7. Retos semánticos para el ORM (decidir al mapear)

1. **Referencias polimórficas (`*_ref_id`)** — ~30+ columnas apuntan "a cualquier entidad del tipo `*_type_concept_id`", sin FK. El ORM **no** las expresa como relación; se resuelven en la aplicación por discriminador. Definir un catálogo explícito de tipos válidos por cada `*_ref_id`.
2. **`concept_id` ≠ enum tipado** — no esperar type-safety del motor; la validez la impone el `value_set` (BD). Opcional: constantes generadas por value_set para DX. (`orm-mapping-guide.md §2.2`.)
3. **Perfiles = CTI** — `patient_profiles`/`health_practitioner_profiles` comparten PK con `persons`; mapear como 1:1, no como tabla suelta. (`orm-mapping-guide.md §1`.)
4. **Temporalidad** — entidades con `valid_from/to` no son "una fila mutable"; decidir estrategia (append versión vs. cierre de período).
5. **Solo lectura / solo inserción** — `<<VIEW>>`/`<<MATERIALIZED_VIEW>>` no se escriben; `<<LOG>>`/`<<HISTORY>>`/`<<IMMUTABLE>>` no se actualizan. (`orm-mapping-guide.md §3`.)
6. **Frontera relacional ↔ NoSQL** — no mapear módulos 54–63 como entidades; son proyección por outbox. (`orm-mapping-guide.md §4`.)
7. **Casa única del dato clínico** — verificar que ningún valor codificable tenga doble fuente de verdad (Postgres y un store). (`orm-mapping-guide.md §5`.)

---

## 8. Ambigüedades a resolver antes de generar (propias de una maqueta)

- **Refs polimórficas sin catálogo de tipos** — falta declarar explícitamente qué conceptos son válidos como `*_type_concept_id` de cada `*_ref_id`.
- **Múltiples nociones de "actividad/interacción"** — `crm.crm_activities`, `marketing.marketing_touchpoints` y `messaging.delivery_tracking_events` modelan cosas parecidas; confirmar límites y no fusionarlos.
- **Cruces cross-schema de v4.0.1** — las nuevas entidades se enlazan por **nombre** (aún no por stubs `<<REFERENCE_ONLY>>`); al formalizar, añadir las costuras para que el límite de contexto quede explícito.
- **Doble fuente de verdad potencial** — signos vitales (serie vs. observación), documento FHIR (Mongo vs. campos estructurados), imagen (binario vs. metadatos): decidir la casa única (ver §7.7).

---

## 9. Cómo usar esto para el ORM (secuencia sugerida)

1. **Identificar aggregate roots** por contexto usando §5 y las costuras `<<REFERENCE_ONLY>>`.
2. **Decidir value objects/embeddables** (§4) vs. entidades compartidas.
3. **Clasificar relaciones**: FK normal (`@ManyToOne`/`@OneToMany`) vs. **polimórfica** (`*_ref_id`, resolución en app) vs. **CTI** (perfiles).
4. **Aplicar las convenciones mecánicas** de `orm-mapping-guide.md` (PK, `@Version`, tenant filter, concept_id, stereotypes).
5. **Generar por introspección** (`mikro-orm/entity-generator`) contra la base levantada desde el DDL, y afinar a mano solo lo no inferible (filtros, subscribers, tipos custom, polimórficos).

---

## 10. Lo que este documento NO decide

Queda para el **ADR del ORM** (ver `orm-mapping-guide.md §6`): versión de MikroORM y driver, estrategia de migraciones, diseño de filtros de tenant vs. RLS, tipos custom PostGIS, y política de regeneración ante cambios del modelo. Este análisis es el **mapa semántico**; el ADR es la **decisión de ingeniería**.
