-- ============================================================================
--  v4.2.2 · a nombre de quién sale el comprobante
--
--  El registro de procesos pide, para el paciente, «Nombre o Razón social» Y
--  «Número de NIT» (PACIENTE §1.15.1 y §1.15.2). Hasta ahora sólo existía el
--  número: la ficha mostraba el NIT y no de quién era.
--
--  Va en `common.identifiers` y no en `profiles.persons` porque es el titular
--  DEL IDENTIFICADOR, no un dato de la persona: alguien puede facturar a nombre
--  de su empresa, y el día que cambie de NIT la razón social cambia con él. El
--  versionado lo da `valid_to`, que esta tabla ya tiene.
--
--  Nullable: un CI no tiene razón social. Sólo se llena en los de tipo fiscal.
--
--  Idempotente. En una base reconstruida desde cero la columna ya viene en
--  SQL/02_common/02_tables.sql y este patch no hace nada.
-- ============================================================================

ALTER TABLE common.identifiers
  ADD COLUMN IF NOT EXISTS "holder_name" varchar;
