# Desvíos y supuestos — M-F5-clin (modelo)

Agente M-F5-clin · 2026-10-29 · rama `claude/modelo-infra-f5-clin` (desde `claude/trusting-hawking-q3p12v`).
Contrato: `SALUD/Arquitectura/infraestructura-hospitalaria/CONTRATO-F2-F5.md` §0.1, F5a, F5b y F5d
(solo `appointments.care_space_id`). Para el orquestador/integrador: este archivo alimenta la sección
«Desvíos» del contrato.

## Qué entrega

| Franja | Tabla | Cambio |
|---|---|---|
| F5d | `clinical.appointments` | `care_space_id` → `practice.care_spaces` (nullable, sin backfill); FK compuesta `(tenant_id, care_space_id)`; `ex_appointments_care_space_time` (EXCLUDE gist) |
| F5b | `clinical.service_requests` | `suggested_care_space_id` → `practice.care_spaces`; CHECK «sin sede no hay punto»; trigger «el punto es de la sede sugerida» |
| F5b | `diagnostics.specimen_collection_events` | `collection_care_space_id` → `practice.care_spaces`; trigger «el espacio es de la sede de la toma» |
| F5a | `diagnostics.imaging_procedure_steps` | `scheduled_equipment_id`, `scheduled_care_space_id`, `scheduled_start_at`; trigger «la sala es la del equipo» |

Archivos: `diagram_08_clinical.puml`, `diagram_20_diagnostics.puml`, `diagram_33_integrity.puml` (solo el
bloque de `appointments` y `service_requests`), `SQL/patches/2026-10-29_infraestructura_f5_clinical.sql`,
`SQL/patches/2026-10-29_infraestructura_f5_diagnostics.sql`. No se tocó nada de `SQL/NN_*`,
`_generation_report.md`, `SHA256SUMS.txt`, `model-manifest.yaml` ni `apply_all.sql`.

## Desvíos del contrato

1. **Nombre del patch de imagen.** El contrato F5a nombra `…_f5_diagnostic_units.sql` y `…_f5_diagnostics.sql`.
   La parte de `diagnostic_units` ya la entregó M-F5-ops como `…_f5_operaciones.sql`; este agente entrega
   solo `…_f5_diagnostics.sql` (pasos de imagen y tomas) y `…_f5_clinical.sql`, como pidió el orquestador.
   `…_f5_diagnostics.sql` exige `f5_operaciones` aplicado (lee `diagnostic_equipment.care_space_id`) y aborta
   con mensaje si falta.
2. **Columna de la orden.** El encargo habla de «`suggested_practice_site_id` → espacio»; el contrato fija la
   columna nueva `suggested_care_space_id`. Se usó la del contrato. `suggested_practice_site_id` se conserva.
3. **F5d solo en lo que toca a `appointments`.** `schedule_templates.care_space_id` y
   `availability_exceptions.source_kind_concept_id / source_ref_id` son de M-F5-sched y no se hicieron.
4. **`ex_appointments_care_space_time` vive en mi patch.** El contrato la lista bajo «Agenda» (F5d), pero la
   tabla es `clinical.appointments` y su `EXCLUDE_SQL` va en el bloque `appointments` de `diagram_33`
   (archivo caliente: el integrador resuelve el merge de ese hunk). Si M-F5-sched también la declara, hay un
   duplicado: dejar una sola.
5. **La precondición del EXCLUDE aborta** (contrato §0.1: `RAISE EXCEPTION`), a diferencia del patch v4.2.3 de
   `ex_appointments_practitioner_time`, que solo avisa. Aquí no puede disparar en el primer despliegue
   (columna nueva sin backfill); se probó con datos violadores (ver «Pruebas»).

## Agregados que el contrato no pide (supuestos; fáciles de quitar si el orquestador no los quiere)

6. **FK compuesta `fk_appointments_tenant_care_space (tenant_id, care_space_id) → care_spaces (tenant_id, id)`**
   (usa `ux_care_spaces_tenant_id_id` de F1b; nombre como las de F1b). Convive con la FK simple generada por
   `gen_ddl`. El contrato pide «tenant_id + FK compuestas donde corresponda»; `appointments` ya tiene
   `tenant_id` NOT NULL y RLS, así que corresponde. Una cita no puede apuntar al consultorio de otro tenant,
   aunque ese consultorio sea invisible para el actor (las FK no pasan por RLS).
7. **`ck_service_requests_suggested_care_space_requires_site`**: sin `suggested_practice_site_id` no hay
   `suggested_care_space_id`. Lo implica el contrato (el punto debe ser `SAMPLE_COLLECTION` *de*
   `suggested_practice_site_id`). Declarado en `diagram_33` (`CHECK_SQL`).
8. **Triggers de coherencia de sede/sala** (solo en el patch; `gen_ddl` no los expresa; patrón de F1b/F5-ops,
   `ERRCODE` 23503 / 23514):
   - `trg_service_requests_suggested_space_site`: el espacio sugerido es de la sede sugerida.
   - `trg_specimen_collection_events_space_site`: con sede y espacio presentes, el espacio es de esa sede.
     **No se exige la sede cuando hay espacio** (el contrato conserva `collection_site_id` como campo propio y no
     dice que sea obligatorio con el espacio). Si el integrador lo quiere, es un CHECK de una línea.
   - `trg_imaging_procedure_steps_scheduled_room`: con equipo y sala presentes, la sala es la del equipo; si el
     equipo no está ubicado, la sala es del tenant de su unidad diagnóstica. **Es un supuesto mío**: el contrato
     dice que el estudio lleva `scheduled_care_space_id` «para MWL» y que el equipo está en una sala, pero no
     dice que deban coincidir en la base. Se disparan solo al escribir las columnas `scheduled_*`: si el equipo
     se reubica, los pasos ya programados **no** se revalidan en la base (lo hace la API, proceso 07).
9. **Las funciones de los triggers usan `SET app.system_context = 'true'` como cláusula de la función** (no
   `SECURITY DEFINER`, no `set_config` global): el valor se restaura al salir. Motivo: la sede sugerida de una
   orden («en este centro», M-01..M-03) y la sede donde se toma/realiza pueden ser de **otro tenant** que el
   que escribe; con RLS el trigger no vería el espacio y rechazaría un caso legítimo. Probado con `mantra_app`
   (R08, R10). Distinto de F5-ops, que usó INVOKER sin elevar porque sus tablas sí tienen dueño de tenant.

## Lo que NO se hizo, y por qué

- **Sin `tenant_id` ni RLS nuevos** en `service_requests`, `specimen_collection_events` ni
  `imaging_procedure_steps`: ninguna tiene `tenant_id` (usan `custodian_tenant_id` o cuelgan de una tabla que
  lo usa), y agregarlo es un cambio de modelo ajeno a esta franja. Tampoco se compara contra
  `custodian_tenant_id`: el centro ejecutor puede ser de otro tenant. Lo que la base garantiza es la coherencia
  sede/sala/equipo (puntos 7–8). **Quién puede escribir qué en esas tablas sigue siendo cosa de la API.**
- **`appointments`: sin RLS nueva** (ya tiene `tenant_isolation` por `tenant_id`; se probó que se conserva).
- **Sin validación de función/estado del espacio** (`CONSULTING_ROOM`, `SAMPLE_COLLECTION`, `IMAGING_ROOM`,
  activo, disponible, no `allowOverlap`): el perfil de función es una constante de la API (CONTRATO-F0-F1 §2).
  422 de la API.
- **Sin comparar `appointments.branch_id` con la sucursal de la sede del espacio** (branch ≠ sede es la
  decisión abierta del PLAN §7). 422 de la API.
- **Sin EXCLUDE sobre los pasos de imagen** (equipo/sala a la misma hora): la capacidad del equipo vive en el
  cupo de `scheduling` y la de la sala en `ex_appointments_care_space_time`. Un EXCLUDE aquí sería regla nueva.
- Sin tablas nuevas, así que sin `audit.*_history` nuevas.

## Para la API / el integrador

- **Mapa `constraint → reason`** (`exclusion-constraint-reasons.ts`): `ex_appointments_care_space_time →
  CARE_SPACE_DOUBLE_BOOKED` (409).
- **SQLSTATE a traducir**: `23503` (FK compuesta `fk_appointments_tenant_care_space`, triggers de sede y de tenant)
  → **404**, nunca revelar el motivo; `23514` (`ck_service_requests_suggested_care_space_requires_site`, y
  `trg_imaging_procedure_steps_scheduled_room` «no es la sala del equipo») → 422; `23P01` → 409.
  **No reenviar `SQLERRM`**: con un espacio inexistente falla la FK simple y con uno de otro tenant falla la
  compuesta, así que el *nombre de la restricción* distingue «no existe» de «es de otro tenant».
- La cláusula `SET` de las funciones exige que `mantra_app` pueda fijar `app.system_context` (hoy puede: el
  caso de uso de verificación SNIS ya lo hace con `SET LOCAL`).
- Tras `gen_ddl`/`gen_integrity` del integrador, `SQL/08_clinical/05_constraints.sql` seguirá mostrando el
  comentario viejo «EXCLUDE: practitioner/location time overlap (en prosa …)» junto al EXCLUDE nuevo; es
  prosa heredada de `diagram_33`, no una contradicción.
- El orden de aplicación de patches: F1 → F1b → … → `f5_operaciones` → `f5_clinical` / `f5_diagnostics` (estos dos
  son independientes entre sí).

## Pruebas (peldaños reales)

Base: `m_f5clin` (copia de `alovida`, PG 18.6 con TimescaleDB, localhost:5433) y, para datos preexistentes,
`m_f5clin_pre` (copia de `alovida` con filas cargadas antes del patch).

| Peldaño | Resultado |
|---|---|
| Escrito (.puml, diagram_33, 2 patches) | sí |
| Aplicado 1.ª vez, `ON_ERROR_STOP=1` | clínico exit 0, diagnóstico exit 0 (en ambas bases) |
| Aplicado 2.ª vez | exit 0; catálogo (columnas, restricciones, índices, triggers, funciones) **idéntico** a la 1.ª pasada |
| Con datos preexistentes | 5 citas (3 solapadas a la misma hora, sin espacio), 2 órdenes, 2 tomas, 2 pasos: patch aplicado sin tocar filas; columnas nuevas en NULL; catálogo igual al de la base limpia |
| Precondiciones | con guardas quitadas y 1 violador por regla: ambos patches abortan con los conteos exactos (1/1/1/1 y 1/1/1), sin dejar ningún objeto; al borrar los violadores, el patch aplica y el catálogo vuelve a ser idéntico. Falta de F1b / de f5_operaciones: aborta con mensaje |
| Pruebas de comportamiento | **72 casos** (SQL, en transacción con `ROLLBACK`): 72 pasan, 0 fallan. Incluyen RLS entre tenants como `mantra_app`, fail-closed sin contexto, doble reserva, bordes `[)`, estados fuera del predicado, UPDATE hacia solape, centro ejecutor de otro tenant, relocalización de equipo |
| `gen_ddl 08/20` y `gen_integrity` en **copia temporal fuera del repo** | el SQL generado coincide sentencia por sentencia con lo escrito en los patches (columnas, FK simples, índices, CHECK y EXCLUDE). No se escribió nada en `SQL/` del worktree |
| `pytest salud-db` | 43 passed (`salud-db/tests` solo: 28 passed) |

## Qué NO se verificó

- Una base **nueva** construida con `postgres-init`/`apply_all.sql` desde el SQL regenerado (es del integrador).
- Que `gen_ddl`/`gen_integrity` dentro del repo produzcan exactamente el mismo orden de columnas que un
  patch (el patch agrega al final de la tabla; el `CREATE TABLE` generado las pone donde el `.puml` las declara).
- Carga/tiempo del `ADD CONSTRAINT … EXCLUDE` y de las FK sobre un `appointments` grande de producción (las
  bases de prueba tienen decenas de filas).
- Interacción con los patches de F2, F3, F4, F5-sched y F5-fin (corren en otros worktrees; no se aplicaron juntos).
- `python salud-db/check_ddl_sources.py`: barre todo el workspace, incluidos los otros worktrees, y falla por
  `CREATE TABLE` ajenos a este cambio; no es señal sobre estos archivos.
- Ninguna prueba contra la API real ni contra el front.
