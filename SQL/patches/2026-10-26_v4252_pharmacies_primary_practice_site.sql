-- ============================================================================
-- SALUD · patch v4252 (pharmacy.pharmacies · sede central)
-- Fecha: 2026-10-26 · Idempotente (ADD COLUMN IF NOT EXISTS, índice IF NOT
-- EXISTS, FK con guarda duplicate_object)
--
-- P50 (alta pública de farmacia): la farmacia nace con su casa central como
-- sede de práctica (`practice.practice_sites`) y esta columna la enlaza, igual
-- que `diagnostic_units.primary_practice_site_id`. Nullable: las farmacias
-- dadas de alta antes de este patch no tienen sede central declarada y la
-- verificación de la plataforma lo informa como requisito faltante.
-- Sin backfill.
-- Reverso: ALTER TABLE pharmacy.pharmacies DROP COLUMN primary_practice_site_id;
-- ============================================================================
ALTER TABLE pharmacy.pharmacies
    ADD COLUMN IF NOT EXISTS primary_practice_site_id uuid;

CREATE INDEX IF NOT EXISTS "ix_pharmacies_primary_practice_site_id"
    ON "pharmacy"."pharmacies" ("primary_practice_site_id");

DO $$ BEGIN
    ALTER TABLE "pharmacy"."pharmacies"
        ADD CONSTRAINT "fk_pharmacies_primary_practice_site_id" FOREIGN KEY ("primary_practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
