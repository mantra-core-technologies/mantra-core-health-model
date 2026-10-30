# Reporte de generación SQL — SALUD v4.0.10

Generado fielmente desde los `.puml`. Solo se emiten tablas PostgreSQL; las vistas, stubs de cruce y stores no-SQL (Redis/Mongo/OpenSearch/vector/timeseries) se listan como *saltados*. Graph (61) y Lakehouse (63) SÍ se materializan como tablas PG (catálogo del plano de control). Las FK marcadas *inferidas* se resolvieron por convención cuando el vault no tenía destino.

| Mód | Schema | Tablas PG | FK | (inferidas) | Índices | Saltadas |
|-----|--------|-----------|----|-------------|---------|----------|
| 53 | procedures_perioperative | 37 | 245 | 14 | 292 | 13 |
| **Σ** | **1** | **37** | | **14** | | **13** |

## Detalle de entidades saltadas y avisos

### 53 · procedures_perioperative
- `clinical_procedures` — stub de cruce (tabla real en su módulo dueño)
- `clinical_service_requests` — stub de cruce (tabla real en su módulo dueño)
- `clinical_encounters` — stub de cruce (tabla real en su módulo dueño)
- `profiles_patient_profiles` — stub de cruce (tabla real en su módulo dueño)
- `practice_care_spaces` — stub de cruce (tabla real en su módulo dueño)
- `diagnostics_specimens` — stub de cruce (tabla real en su módulo dueño)
- `clinical_observations` — stub de cruce (tabla real en su módulo dueño)
- `common_files` — stub de cruce (tabla real en su módulo dueño)
- `ref_practice_care_spaces` — stub de cruce (tabla real en su módulo dueño)
- `ref_practice_practice_sites` — stub de cruce (tabla real en su módulo dueño)
- `ref_practice_clinical_units` — stub de cruce (tabla real en su módulo dueño)
- `ref_health_practitioner_profiles` — stub de cruce (tabla real en su módulo dueño)
- `ref_scheduling_schedulable_resources` — stub de cruce (tabla real en su módulo dueño)
