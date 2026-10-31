-- SALUD v4.0.10 · schema directory · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ affiliation_invitations ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."affiliation_invitations" DROP CONSTRAINT IF EXISTS "ck_affiliation_invitations_uses";
ALTER TABLE "directory"."affiliation_invitations" ADD CONSTRAINT "ck_affiliation_invitations_uses" CHECK (("max_uses" >= 1 AND "uses_count" >= 0 AND "uses_count" <= "max_uses"));
