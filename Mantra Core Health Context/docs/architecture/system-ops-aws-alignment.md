# System Ops y Platform Ops — alineación conceptual con AWS

## Alcance

La versión 3.8 separa dos responsabilidades:

- `system_ops`: gobierno, evaluación de controles, hallazgos y remediación.
- `platform_ops`: operación diaria, ownership, guardias, SLI/SLO, error budget, incidentes, cambios, runbooks, resiliencia y capacidad.

## Capacidades incorporadas

1. Catálogo versionado de marcos y controles operativos.
2. Evaluaciones por workload con evidencia, madurez, riesgo y planes de remediación.
3. Ownership explícito de servicios, equipos, on-call y escalamiento.
4. Dependencias entre servicios y modos de fallo/fallback.
5. Readiness reviews antes de releases o cambios materiales.
6. Cadena `SLI -> SLO -> medición -> error budget -> burn event`.
7. Runbooks versionados, aprobados y con ejecuciones observables.
8. Gestión de cambios con riesgo, aprobaciones, ventana, validación y rollback.
9. Incidente con comando, responders, timeline, comunicaciones, postmortem y acciones.
10. RTO/RPO, ejercicios de resiliencia, capacidad y mejora continua.

## Fuentes oficiales revisadas

- AWS Well-Architected Operational Excellence Pillar: https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/welcome.html
- Observability: https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/implement-observability.html
- Event, incident and problem management: https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/ops_event_response_event_incident_problem_process.html
- Post-incident analysis: https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/ops_evolve_ops_perform_rca_process.html

## Límite de la alineación

El modelo implementa estructuras de datos y trazabilidad inspiradas en estas prácticas. No afirma certificación AWS ni reemplaza IaC, monitoreo, alertas, políticas de acceso o procedimientos operativos ejecutables.
