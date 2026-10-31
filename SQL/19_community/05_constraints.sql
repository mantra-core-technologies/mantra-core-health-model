-- SALUD v4.2.80 · schema community · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ direct_messages ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "community"."direct_messages" DROP CONSTRAINT IF EXISTS "ck_direct_messages_on_behalf_has_author";
ALTER TABLE "community"."direct_messages" ADD CONSTRAINT "ck_direct_messages_on_behalf_has_author" CHECK (("on_behalf_of_profile_id" IS NULL OR "authored_by_user_id" IS NOT NULL));
