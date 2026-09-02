-- ============================================================================
--  TAREA-07 · índice de búsqueda por CI (tipo + valor) en common.identifiers
--
--  Archivo clínico: `ChartReadService` va a buscar pacientes por documento de
--  identidad (AC-07-3), y `identifiers` solo tenía índices de una columna
--  (`type_concept_id` sola, `owner_type_concept_id` sola…). Ninguno sirve para
--  `WHERE type_concept_id = $1 AND value = $2`: sin el compuesto, Postgres
--  resuelve con Seq Scan sobre una tabla que crece con cada identificador de
--  cada persona.
--
--  No UNIQUE: el departamento emisor no participa de la unicidad del CI, y hay
--  filas históricas superpuestas por `valid_from`/`valid_to` (mismo tipo+valor,
--  vigencias distintas).
--
--  Idempotente. En una base reconstruida desde cero el índice ya viene en
--  SQL/02_common/04_indexes.sql y este patch no hace nada.
-- ============================================================================

CREATE INDEX IF NOT EXISTS "ix_identifiers_type_concept_id_value"
  ON "common"."identifiers" ("type_concept_id", "value");
