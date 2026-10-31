-- SALUD v4.2.79 · schema identity_assurance · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ identity_verification_attempts ═══
--   UK: case + endpoint + attempt number  (en prosa; el módulo 33 no declara su expresión SQL)
--   UK: endpoint + idempotency key  (en prosa; el módulo 33 no declara su expresión SQL)
--   RETRY: bounded policy only
--   índices únicos que la tabla ya tiene en 04_indexes: uq_identity_verification_attempts_identity_verificatio_905f086b, uq_identity_verification_attempts_idempotency
