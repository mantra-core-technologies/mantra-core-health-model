# Principios de desarrollo — SOLID y clean code (SALUD v4.0.1)

Documento normativo para todo el código de la plataforma: el backend `mantra-health-api/`
(NestJS + TypeScript + MikroORM), los generadores deterministas de `salud-db/` (Python) y
cualquier script o worker nuevo. Complementa la `orm-mapping-guide.md` (persistencia) y la
matriz del módulo 33 (concurrencia e integridad). La fuente de verdad del dominio son los
64 `.puml`: el código honra el modelo, nunca al revés.

## 1. SOLID, aterrizado a esta plataforma

### S — Responsabilidad única
- Un servicio = **un caso de uso** (los 37 UC del patch v4.0.1 son la unidad de diseño).
- Un módulo Nest por dominio, espejo de los módulos del modelo (`iam`, `clinical`,
  `messaging`, …). Los controllers solo orquestan HTTP; la lógica vive en servicios; el
  acceso a datos en repositorios/EntityManager.

### O — Abierto/cerrado
- Extender por composición: nuevos providers, subscribers, workers, adapters — no editar
  clases estables. El patrón de referencia son los adapters de mensajería del módulo 35
  (`adapter_tracking_capabilities`, `adapter_event_mappings`): agregar un canal nuevo es
  **un adapter nuevo**, no un `if` más en un switch existente.

### L — Sustitución de Liskov
- Toda implementación de una interfaz (gateway de pago, adapter de canal, store gobernado)
  debe ser intercambiable sin sorpresas: mismos contratos, mismos errores tipificados,
  misma semántica de idempotencia, sin efectos ocultos.

### I — Segregación de interfaces
- Interfaces chicas por **capacidad** (`EnvíoProgramable`, `Trackeable`, `Reconciliable`)
  en vez de una interfaz gigante por módulo. Un consumer no depende de métodos que no usa.

### D — Inversión de dependencias
- Los servicios dependen de **puertos** (interfaces/tokens de inyección de NestJS), nunca
  de implementaciones concretas (Redis, Mongo, OpenSearch, gateway HTTP).
- Los stores especializados (módulos 54–63) entran **solo por outbox + workers**
  (orm-mapping-guide §4); jamás se inyectan en lógica de dominio.

## 2. Clean code, reglas concretas

- **Nombres reveladores en el idioma del dominio:** los nombres de tablas/columnas de los
  `.puml` son la verdad — no traducir, no abreviar distinto, no "mejorar".
- **Funciones cortas, un nivel de abstracción por función.** Early-return antes que `if`
  anidados. Sin flags booleanos que cambian el comportamiento: dos funciones con nombre
  claro superan a una con `mode`.
- **Sin números ni strings mágicos.** Constantes con nombre. Los conceptos de terminología
  viajan como `*_concept_id` (uuid) — nunca labels hardcodeados ni enums de TypeScript
  inventados (orm-mapping-guide §2.2: el único enum nativo es `technical_data_type`).
- **Errores explícitos y tipificados.** Excepciones de Nest con semántica HTTP correcta;
  `SQLSTATE` esperados y documentados; retry **solo** ante `40001`
  (serialization_failure, módulo 33). Prohibidos: `catch` vacíos, `any` para silenciar
  el tipado, tragarse errores de workers.
- **No editar lo generado a mano.** `SQL/`, `NoSQL/` y las entidades generadas se
  regeneran desde los `.puml`; si algo está mal, se arregla **el generador** y se
  regenera. Un archivo generado editado a mano es un bug.
- **Temperatura-0 también en código:** no inventar FKs, valores de enums, columnas ni
  contratos que el modelo no declare. Lo no resuelto se marca con TODO explícito y
  rastreable — no se adivina.

## 3. Invariantes del modelo que el código debe honrar

| Invariante | Regla de código |
|---|---|
| `row_version` en tablas de negocio | `@Version()` de MikroORM; los servicios **no** lo tocan |
| `<<LOG>> / <<IMMUTABLE>> / <<APPEND_ONLY>>` | Sin update/delete en el ORM; la barrera física (`integrity.forbid_mutation`) es la garantía |
| `<<HISTORY>>` (SCD-2 en `audit`) | Insertar snapshot, nunca sobrescribir |
| Caso de uso | **Una transacción** por caso de uso (Unit of Work) |
| Llamadas externas | Fuera de ventanas de lock: persistir intent + outbox, reconciliar async con idempotencia |
| Multi-tenencia | Filtro global del ORM + RLS; la RLS es la defensa, el filtro es conveniencia |
| Mock seeds | **Hard-fail** si `NODE_ENV=production` (política de seedsGenerales) |

## 4. Tests

- Cada caso de uso con test de su **transacción** e **invariantes**: locking optimista
  (conflicto de `row_version`), idempotencia (reintento del mismo comando), y el error
  tipificado esperado en cada rama.
- Los generadores se validan **regenerando y comparando** contra la base aplicada
  (introspección); un diff inesperado es una regresión del generador o una edición manual.
- Los workers de outbox se prueban con reintentos y dead-letter (el backbone de eventos de
  `seedsGenerales/35_messaging` es el fixture de referencia).
