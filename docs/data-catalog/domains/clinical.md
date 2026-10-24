# Dominio clínico — schema `clinical`

**Estado:** piloto de metadata de negocio, borrador para revisión clínica
**Fuente del dominio:** `Mantra Core Health Context/modules/diagram_08_clinical.puml`
**Metadata física:** `../tables.csv`, `../columns.csv`, `../relations.csv`, `../constraints.csv` e `../indexes.csv`

## Motivo de existencia del dominio

Este dominio conserva el registro clínico canónico organizado alrededor del encuentro asistencial:
antecedentes, episodios y encuentros, hallazgos codificados, problemas de salud, alergias,
solicitudes, informes, medicación, procedimientos, inmunizaciones y participantes/lugares de la
atención. La separación en tablas mantiene distinguibles los actos clínicos, sus observaciones,
órdenes, resultados y procedencia.

## Motivo de existencia por tabla

Los motivos siguientes están en estado `DOMAIN_CURATED_DRAFT`: se redactaron contrastando nombre,
campos, relaciones y notas del modelo, y requieren aprobación del responsable del dominio antes de
publicar el catálogo como definitivo.

| Tabla | Motivo de existencia en el sistema médico |
|---|---|
| `clinical.family_member_history` | Conserva antecedentes familiares relevantes para la evaluación de riesgo y la historia de salud del paciente. |
| `clinical.social_history` | Registra factores y circunstancias sociales o hábitos que aportan contexto a la valoración y continuidad asistencial del paciente. |
| `clinical.care_episodes` | Agrupa encuentros relacionados dentro de un proceso asistencial del paciente para seguir su evolución y responsabilidad clínica. |
| `clinical.encounters` | Representa cada contacto asistencial y vincula paciente, equipo, sede, agenda, motivo y estado de atención. |
| `clinical.observations` | Conserva hallazgos y mediciones clínicas codificados, tipados y vinculables al paciente, encuentro, solicitud y método de obtención. |
| `clinical.observation_components` | Desglosa observaciones compuestas en componentes ordenados para preservar cada resultado y su tipo de valor de manera interpretable. |
| `clinical.conditions` | Registra problemas, diagnósticos y condiciones de salud del paciente con estado, severidad, curso y fechas clínicas relevantes. |
| `clinical.allergy_intolerances` | Mantiene las alergias e intolerancias conocidas del paciente para que puedan considerarse al decidir y prestar atención clínica. |
| `clinical.allergy_reactions` | Documenta manifestaciones asociadas a una alergia o intolerancia para caracterizar el antecedente y orientar su evaluación clínica. |
| `clinical.service_requests` | Representa solicitudes de servicios clínicos —por ejemplo, estudios o procedimientos— y su estado dentro del proceso asistencial. |
| `clinical.diagnostic_reports` | Gestiona el ciclo de vida del informe diagnóstico y lo vincula con su solicitud y encuentro; los resultados estructurados y archivos asociados se mantienen en el dominio de diagnóstico. |
| `clinical.medication_requests` | Registra solicitudes o prescripciones de medicamentos, su indicación y trazabilidad clínica dentro de la atención del paciente. |
| `clinical.prescription_signature_policies` | Define los requisitos de firma aplicables a prescripciones según tenant, jurisdicción, tipo de medicamento y canal. |
| `clinical.medication_records` | Conserva el historial clínico de uso o administración de medicación del paciente; el modelo aclara que no representa el inventario ni la dispensación de farmacia. |
| `clinical.procedures` | Documenta procedimientos asociados a la atención y enlaza su contexto con el encuentro, las solicitudes y, cuando corresponde, otros procedimientos. |
| `clinical.immunizations` | Registra inmunizaciones administradas o documentadas en la historia de salud para sostener seguimiento y continuidad preventiva. |
| `clinical.appointments` | Representa citas asistenciales y permite relacionarlas con el encuentro realizado o planificado. |
| `clinical.encounter_participants` | Identifica a las personas que participan en un encuentro y su rol para conservar quién intervino en la atención. |
| `clinical.encounter_locations` | Vincula un encuentro con los lugares de prestación para mantener el contexto físico de la atención. |
| `clinical.observation_performers` | Atribuye quién o qué dispositivo realizó una observación para dar procedencia al resultado clínico. |
| `clinical.observation_reference_ranges` | Asocia rangos de referencia a observaciones o componentes para contextualizar la interpretación de resultados medibles. |
| `clinical.observation_notes` | Guarda notas narrativas complementarias sobre una observación cuando el dato codificado requiere contexto clínico adicional. |

## Relaciones principales

```text
care_episodes → encounters → observations → observation_components
                         ├→ conditions
                         ├→ service_requests → diagnostic_reports
                         ├→ medication_requests → medication_records
                         ├→ procedures
                         ├→ encounter_participants
                         └→ encounter_locations
allergy_intolerances → allergy_reactions
observations → observation_performers, observation_reference_ranges, observation_notes
appointments → encounters
```

La lista física completa, incluyendo FK entre schemas, está en `../relations.csv`. Los vínculos de
terminología, paciente, profesional, consentimiento, autorización, archivos y auditoría deben
leerse allí; el dibujo anterior solo destaca las relaciones principales del módulo.

## Límites de interpretación

- `DOMAIN_CURATED_DRAFT` no significa validado por un médico ni aprobado legalmente.
- La columna `nullable` representa DDL y no determina si un campo es clínicamente obligatorio en
  todos los flujos.
- La existencia de un índice o FK no expresa por sí sola una regla clínica.
- Las notas del modelo describen invariantes de custodia por tenant y del valor de observación;
  algunas expresiones `CHECK`/`UNIQUE`/`EXCLUDE` están declaradas sólo en prosa (comentarios de
  `05_constraints.sql`). Este catálogo no las da por aplicadas si no aparecen en el DDL activo.
- La dispensación e inventario de farmacia se modelan en schemas propios; no se deben inferir de
  `clinical.medication_records`.
