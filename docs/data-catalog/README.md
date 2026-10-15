# Catálogo de metadata — Mantra Core Health

## Objetivo

Documentar el modelo del sistema médico con dos capas que se pueden revisar por separado:

1. **Metadata técnica:** schema, tabla, columna, tipo PostgreSQL, nulabilidad, default,
   claves/restricciones, índices y relaciones físicas.
2. **Metadata de dominio:** por qué existe cada tabla en el dominio médico y qué capacidad
   clínica, operativa o de soporte habilita.

La capa de dominio no se completa por heurística de nombres. Cada motivo debe estar respaldado
por el diagrama del módulo, una regla funcional o una decisión explícita. Si falta evidencia, se
registra como `PENDING_REVIEW`; no se rellena con una frase genérica.

## Alcance

- Fuente técnica: `SQL/<módulo>/02_tables.sql`, `03_fk_intra.sql`, `90_fk_deferred.sql`,
  `04_indexes.sql` y `05_constraints.sql`.
- Inventario PostgreSQL canónico: los scripts `02_tables.sql` de los módulos. Los archivos de
  `SQL/patches/` son ALTERs/seeds incrementales y no se cuentan como tablas del rebuild canónico.
- El inventario incluye **1.230 tablas, 16.851 columnas, 7.069 FK y 7.836 índices** en 57 schemas.
  Estos conteos describen el contenido leído hoy; prevalecen sobre
  los conteos históricos que aún aparecen en algunos encabezados de `SQL/`.
- Fuera de este catálogo relacional: stores no relacionales de `NoSQL/`, vistas y metadata observada
  en una base desplegada. Se catalogarán aparte para no mezclar tipos de objeto ni fuentes.
- Fuente de significado: `Mantra Core Health Context/modules/*.puml`. El DDL se genera desde esos
  diagramas; el catálogo nunca se usa para declarar ni cambiar el esquema.

## Artefactos

`python3 docs/data-catalog/generate_catalog.py` regenera los CSV técnicos sin tocar las narrativas
curadas:

- `tables.csv`: una fila por tabla, incluyendo el motivo de dominio y su estado de revisión.
- `domains.csv`: volumen de tablas y avance de curaduría por schema.
- `columns.csv`: una fila por columna, con tipo, nullability, default y participación en PK/FK/UK.
- `relations.csv`: claves foráneas activas en el DDL y su destino físico. El archivo no intenta
  decidir si el destino se originó en una nota del modelo o en una convención histórica.
- `constraints.csv`: PK, FK, índices únicos y restricciones activas detectables en el SQL generado;
  comentarios de scaffold/TODO del modelo no se tratan como restricciones aplicadas.
- `indexes.csv`: índices declarados en el DDL canónico.

Las columnas técnicas reflejan el DDL del workspace. No afirman que una base desplegada esté
sincronizada: esa comparación requiere inspección de una base concreta.

## Estados de evidencia

| Estado | Significado |
|---|---|
| `DDL_VERIFIED` | Leído directamente desde los scripts SQL canónicos. |
| `DOMAIN_CURATED_DRAFT` | Motivo redactado desde el modelo del módulo; requiere validación del responsable del dominio. |
| `PENDING_REVIEW` | No hay todavía un motivo de existencia aprobado para esa tabla. |
| `NOT_APPLICABLE` | Objeto técnico sin semántica de negocio propia; requiere justificar por qué. |

No se debe publicar una tabla como catálogo de negocio completo mientras su `business_rationale`
esté vacío o su estado sea `PENDING_REVIEW`.

## Piloto y avance

Las **1.230 tablas** tienen un motivo de existencia inicial respaldado por su diagrama de módulo y
quedan con estado `DOMAIN_CURATED_DRAFT`; **ninguna está marcada como pendiente**, pero todas
requieren revisión de su responsable de dominio antes de considerarlas aprobadas. `domains.csv`
resume la cobertura por schema y `tables.csv` permite filtrar las narrativas.

## Criterios por ficha de tabla

- Identidad física inequívoca: `schema.table`.
- `schema` es el namespace físico PostgreSQL; se conserva separado del nombre de tabla y no se
  confunde con una clasificación clínica o administrativa de negocio.
- Motivo de existencia específico del sistema médico; mencionar el proceso o evidencia que conserva.
- No inferir indicación clínica, retención legal, sensibilidad ni política de borrado desde el nombre.
- Distinguir FK declarada de relación lógica dibujada sin FK.
- Preservar schema, tabla, columna y tipo físico en inglés exactamente como aparecen en DDL.
- Toda divergencia entre `.puml`, DDL y base desplegada se registra como hallazgo; no se corrige
  desde el catálogo.

## Referencia de método

Se toma de Atlas la separación entre inventario técnico y narrativa curada por entidad, incluyendo
el motivo de existencia y la contribución de la entidad al dominio. Se adapta al modelo SALUD: aquí
los `.puml` y `SQL/` son las fuentes de verdad del esquema, y Atlas solo es una referencia de
presentación y gobierno.
