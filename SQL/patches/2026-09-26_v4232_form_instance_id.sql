-- ============================================================================
-- SALUD · patch v4.2.32 (clinical · chart · scheduling · P43) sobre BD viva
-- Fecha: 2026-09-26
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo EXCEPTION duplicate_object). UNA sola pasada. SIN backfill.
--
-- QUÉ ENTRA. `form_instance_id uuid NULL` (FK → forms.form_instances(id)) en las
-- cuatro tablas cuyos registros pueden salir de la respuesta CERRADA del
-- formulario médico de una consulta:
--   clinical.medication_requests   POST /clinical/medication-requests
--   clinical.service_requests      POST /clinical/service-requests
--   chart.care_plans               POST /charts/care-plans
--   scheduling.appointment_bookings POST /scheduling/appointments/direct
--                                  (dentro de `followUpOf`, junto a
--                                  follow_up_of_booking_id — patch v4.2.37)
-- La API valida (422) que la instancia exista, esté cerrada y sea del mismo
-- encuentro que el registro.
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Desde la historia del paciente se sigue
-- emitiendo sin formulario, y los registros previos no declararon origen.
--
-- MODELO. Las cuatro columnas tienen que declararse también en los `.puml`
-- (08_clinical, 15_chart, 41_scheduling) para un rebuild desde cero.
--
-- DELTAS ESPERADOS: +1 columna, +1 FK y +1 índice en cada una de las 4 tablas.
-- ============================================================================

BEGIN;

-- ------------------------------------------------ clinical.medication_requests
ALTER TABLE "clinical"."medication_requests"
    ADD COLUMN IF NOT EXISTS "form_instance_id" uuid NULL;
CREATE INDEX IF NOT EXISTS "ix_medication_requests_form_instance_id"
    ON "clinical"."medication_requests" ("form_instance_id");
DO $$ BEGIN
    ALTER TABLE "clinical"."medication_requests"
        ADD CONSTRAINT "fk_medication_requests_form_instance_id"
        FOREIGN KEY ("form_instance_id")
        REFERENCES "forms"."form_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- --------------------------------------------------- clinical.service_requests
ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "form_instance_id" uuid NULL;
CREATE INDEX IF NOT EXISTS "ix_service_requests_form_instance_id"
    ON "clinical"."service_requests" ("form_instance_id");
DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_form_instance_id"
        FOREIGN KEY ("form_instance_id")
        REFERENCES "forms"."form_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ------------------------------------------------------------ chart.care_plans
ALTER TABLE "chart"."care_plans"
    ADD COLUMN IF NOT EXISTS "form_instance_id" uuid NULL;
CREATE INDEX IF NOT EXISTS "ix_care_plans_form_instance_id"
    ON "chart"."care_plans" ("form_instance_id");
DO $$ BEGIN
    ALTER TABLE "chart"."care_plans"
        ADD CONSTRAINT "fk_care_plans_form_instance_id"
        FOREIGN KEY ("form_instance_id")
        REFERENCES "forms"."form_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ---------------------------------------------- scheduling.appointment_bookings
ALTER TABLE "scheduling"."appointment_bookings"
    ADD COLUMN IF NOT EXISTS "form_instance_id" uuid NULL;
CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_form_instance_id"
    ON "scheduling"."appointment_bookings" ("form_instance_id");
DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_form_instance_id"
        FOREIGN KEY ("form_instance_id")
        REFERENCES "forms"."form_instances" ("id");
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

COMMIT;
