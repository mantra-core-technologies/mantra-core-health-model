-- ============================================================================
-- SALUD · patch v4.2.37 (scheduling · P42 reconsulta) sobre BD viva
-- Fecha: 2026-09-26
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo EXCEPTION duplicate_object). UNA sola pasada. SIN backfill.
--
-- QUÉ ENTRA. `scheduling.appointment_bookings.follow_up_of_booking_id`
-- (uuid NULL, FK → scheduling.appointment_bookings(id)): la reconsulta apunta a
-- la consulta de la que salió. El vínculo va en UN solo lado; el inverso
-- (`followUpBookingId` en `BookingItemDto`) lo deriva la API al leer. Índice
-- sobre la columna: se consulta en cada lectura de la agenda.
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Casi ninguna cita es una reconsulta, y las
-- anteriores a este patch no declararon origen: inventarlo sería fabricar un
-- dato que nadie registró.
--
-- UNICIDAD. «Una reconsulta por venir por consulta» NO va como índice único:
-- «por venir» depende de now() y no es inmutable. La API la garantiza con
-- `SELECT … FOR UPDATE` sobre la cita de origen dentro de la transacción.
--
-- MODELO. La columna tiene que declararse también en el `.puml` de 41_scheduling
-- (regla 97.1) para que un rebuild desde cero la traiga en el CREATE TABLE; este
-- patch es sólo para bases ya aplicadas.
--
-- DELTAS ESPERADOS: columnas de scheduling.appointment_bookings +1 · FKs +1
-- (fk_appointment_bookings_follow_up_of_booking_id) · índices +1
-- (ix_appointment_bookings_follow_up_of_booking_id) · tablas ±0
-- ============================================================================

BEGIN;

ALTER TABLE "scheduling"."appointment_bookings"
    ADD COLUMN IF NOT EXISTS "follow_up_of_booking_id" uuid NULL;

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_follow_up_of_booking_id"
    ON "scheduling"."appointment_bookings" ("follow_up_of_booking_id");

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_follow_up_of_booking_id"
        FOREIGN KEY ("follow_up_of_booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

COMMIT;
