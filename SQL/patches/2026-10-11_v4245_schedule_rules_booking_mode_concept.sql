-- v4.2.45 · scheduling.schedule_rules.booking_mode_concept_id (2026-10-11)
-- La entidad ScheduleRules y los DTO de franjas ya declaran qué admite cada
-- franja (CONSULTATIONS | SERVICES | MIXED) como concepto de catálogo, pero ni
-- el DDL ni ningún parche creaban la columna: crear una plantilla con reglas
-- fallaba con 500 («column booking_mode_concept_id does not exist»).
-- Anulable y sin DEFAULT: ausente ≡ CONSULTATIONS, igual que gap_minutes.
-- Idempotente.
ALTER TABLE "scheduling"."schedule_rules"
    ADD COLUMN IF NOT EXISTS "booking_mode_concept_id" uuid;
CREATE INDEX IF NOT EXISTS "ix_schedule_rules_booking_mode_concept_id"
    ON "scheduling"."schedule_rules" ("booking_mode_concept_id");
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_rules"
        ADD CONSTRAINT "fk_schedule_rules_booking_mode_concept_id"
        FOREIGN KEY ("booking_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
