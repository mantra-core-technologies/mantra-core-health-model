-- ============================================================================
-- SALUD · patch (clinical · alergias · encuentro en el que se detectó) sobre BD viva
-- Fecha: 2026-10-23 · Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS / duplicate_object)
-- UNA sola pasada. Sin backfill: la columna es nullable y las alergias existentes no
-- declararon encuentro de origen (inventarlo sería fabricar un dato que nadie registró).
--
-- QUÉ CIERRA. `clinical.allergy_intolerances.encounter_id` (uuid NULL, FK →
-- clinical.encounters(id)) + `ix_allergy_intolerances_encounter_id`. La entidad
-- AllergyIntolerances de la API ya mapeaba la columna («pedido a M1», P26 / CL-01),
-- pero ni el modelo ni ningún parche la creaban, así que toda lectura o escritura de
-- alergias fallaba con «column "encounter_id" does not exist».
--
-- MODELO. Declarada en diagram_08_clinical.puml; gen_ddl.py ya la emite en
-- SQL/08_clinical/ y en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
-- Las sentencias se copiaron de los archivos generados, no se escribieron a mano.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +1 · FKs +1 · índices +1
-- ============================================================================

BEGIN;

ALTER TABLE "clinical"."allergy_intolerances"
    ADD COLUMN IF NOT EXISTS "encounter_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_allergy_intolerances_encounter_id" ON "clinical"."allergy_intolerances" ("encounter_id");

DO $$ BEGIN
    ALTER TABLE "clinical"."allergy_intolerances"
        ADD CONSTRAINT "fk_allergy_intolerances_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
