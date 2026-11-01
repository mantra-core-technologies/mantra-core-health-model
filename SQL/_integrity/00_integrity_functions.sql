-- SALUD v4.2.82 · guardas de integridad (aplicar antes de los 05_constraints)
-- Deriva del módulo 33 (Concurrency, Constraints and Integrity Matrix).

CREATE SCHEMA IF NOT EXISTS "integrity";

-- Barrera física de inmutabilidad (UPDATE_DELETE: forbidden / <<IMMUTABLE>> / <<APPEND_ONLY>>).
CREATE OR REPLACE FUNCTION "integrity"."forbid_mutation"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'append-only/immutable: % no permitido en %.%',
        TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
END $$;

-- Barrera física contra TRUNCATE (TRUNCATE: forbidden). Un disparador de fila no ve el TRUNCATE:
-- hace falta uno de sentencia. Lo engancha `truncate_guard` a las tablas append-only que lo declaran.
CREATE OR REPLACE FUNCTION "integrity"."forbid_truncate"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'append-only/immutable: TRUNCATE no permitido en %.%',
        TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
END $$;
