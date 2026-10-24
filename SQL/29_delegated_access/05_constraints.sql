-- SALUD v4.0.10 · schema delegated_access · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ practitioner_delegate_assignments ═══
--   EXCLUDE: incompatible overlapping assignments  (en prosa; el módulo 33 no declara su expresión SQL)
--   CHECK: signature permission requires authorized role  (en prosa; el módulo 33 no declara su expresión SQL)
