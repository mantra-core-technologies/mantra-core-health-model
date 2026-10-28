# Reporte de generación SQL — SALUD v4.0.10

Generado fielmente desde los `.puml`. Solo se emiten tablas PostgreSQL; las vistas, stubs de cruce y stores no-SQL (Redis/Mongo/OpenSearch/vector/timeseries) se listan como *saltados*. Graph (61) y Lakehouse (63) SÍ se materializan como tablas PG (catálogo del plano de control). Las FK marcadas *inferidas* se resolvieron por convención cuando el vault no tenía destino.

| Mód | Schema | Tablas PG | FK | (inferidas) | Índices | Saltadas |
|-----|--------|-----------|----|-------------|---------|----------|
| 02 | common | 7 | 49 | 0 | 55 | 0 |
| **Σ** | **1** | **7** | | **0** | | **0** |

## Detalle de entidades saltadas y avisos

### 02 · common
- ⚠ índice 'gist_addresses_location' omitido: columna(s) inexistente(s) ['geography_point'] en addresses (¿tipo no-SQL descartado? requiere PostGIS)
