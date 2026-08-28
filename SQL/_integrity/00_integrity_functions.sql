-- SALUD v4.0.10 · guardas de integridad (aplicar antes de los 05_constraints)
-- Deriva del módulo 33 (Concurrency, Constraints and Integrity Matrix).

CREATE SCHEMA IF NOT EXISTS "integrity";

-- Barrera física de inmutabilidad (UPDATE_DELETE: forbidden / <<IMMUTABLE>> / <<APPEND_ONLY>>).
CREATE OR REPLACE FUNCTION "integrity"."forbid_mutation"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'append-only/immutable: % no permitido en %.%',
        TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
END $$;
