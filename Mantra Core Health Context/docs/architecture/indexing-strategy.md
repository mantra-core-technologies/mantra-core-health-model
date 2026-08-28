# Estrategia física de índices

El modelo contiene 6022 definiciones de índices distribuidas en
759 elementos `INDEX_SET` dentro de los módulos.

## Reglas aplicadas

1. Índice de clave primaria para cada tabla.
2. Índices únicos para `UK` y claves de negocio compuestas.
3. Índice BTREE para cada FK, porque PostgreSQL no los crea automáticamente.
4. Compuestos tenant/estado/fecha para colas y RLS.
5. Compuestos paciente/fecha para líneas de tiempo clínica.
6. GiST para periodos, no solapamiento y geografía.
7. BRIN para logs/historiales append-only de gran volumen.
8. GIN para búsqueda textual gobernada.
9. Índices de lookup en vistas materializadas.

## Gate antes de migraciones

Cada índice debe validarse con volumen representativo, selectividad, frecuencia de
escritura, bloqueo de creación, tamaño esperado y planes `EXPLAIN`. Los índices
parciales deben usar IDs estables de seeds o funciones SQL inmutables, no labels.
No se deben desplegar índices redundantes o no usados.
