-- SALUD v4.2.83 · schema pharmacy · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ pharmacy_on_call_shifts ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" DROP CONSTRAINT IF EXISTS "ck_pharmacy_on_call_shifts_window";
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" ADD CONSTRAINT "ck_pharmacy_on_call_shifts_window" CHECK (("ends_at" > "starts_at" AND "ends_at" - "starts_at" <= interval '72 hours'));

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" DROP CONSTRAINT IF EXISTS "ex_pharmacy_on_call_shifts_site_overlap";
ALTER TABLE "pharmacy"."pharmacy_on_call_shifts" ADD CONSTRAINT "ex_pharmacy_on_call_shifts_site_overlap"
    EXCLUDE USING gist ("pharmacy_site_id" WITH =, tstzrange("starts_at", "ends_at", '[)') WITH &&) WHERE ("status_concept_id" = '14c92252-2ad8-576c-bc34-3ae2bbdb950d');
