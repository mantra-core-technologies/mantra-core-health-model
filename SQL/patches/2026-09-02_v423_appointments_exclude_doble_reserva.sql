-- SALUD v4.2.3 · H-1 · la regla madre pasa a ser física
--
-- «El profesional no puede estar en dos lugares a la vez» se cumplía SÓLO en el
-- servicio: `assertRangoLibre()` + `SELECT … FOR UPDATE` sobre el cupo. Eso deja
-- dos huecos reales:
--
--   1. El camino que CREA el cupo en la misma transacción no tiene fila previa
--      que trabar, así que el lock no lo cubre.
--   2. Cualquier escritura futura que no pase por ese servicio —un script, un
--      worker nuevo, una corrección a mano— no ve la regla.
--
-- El defecto se observó en vivo, y está documentado en el JSDoc de
-- `SchedulingProfessionalTimeService`: dos pacientes reservaron 14:00–14:30 y
-- 14:15–14:45 con el MISMO médico en dos agendas distintas, y las dos quedaron
-- confirmadas.
--
-- Este patch NO cambia ninguna regla de negocio: hace que la base rechace
-- exactamente lo que el servicio ya rechazaba. Es una red, no una política nueva.
--
-- ── Por qué UUID literales y no funciones ────────────────────────────────────
-- El predicado de un EXCLUDE tiene que ser INMUTABLE. Es la razón por la que
-- `gist_appointments_practitioner_time` quedó comentado en `04_indexes.sql`: su
-- predicado llamaba a `held_status()` y `confirmed_status()`, que nunca se
-- definieron. Mismo criterio que `ux_authentication_credentials_live_password_subject`
-- (v4.0.9), el primer índice parcial del modelo con concept_id literales.
--
--   51530fd7-05b1-5c29-80c4-da740ede4d27 = clinical:APPOINTMENT_BOOKED
--   37dded87-7a7a-5a24-86f6-0ef48cccb482 = clinical:APPOINTMENT_CHECKED_IN
--
-- Son los MISMOS dos estados que ya comprueba `assertRangoLibre()`. No entra
-- PENDING —dos pacientes pueden solicitar el mismo horario y el médico elige—,
-- ni FULFILLED, ni CANCELLED.
--
-- ── Alcance ─────────────────────────────────────────────────────────────────
-- Cubre la mitad del pedido del módulo 33: «practitioner/**location** time
-- overlap». El solape por SALA (`branch_id`) sigue declarado como TODO en
-- `SQL/08_clinical/05_constraints.sql` y necesita su propia decisión: dos citas
-- en la misma sala a la vez es un conflicto distinto, con otras excepciones.
--
-- Canónico: `Mantra Core Health Context/modules/diagram_33_integrity.puml`
--           (clave `EXCLUDE_SQL` sobre `appointments`)
-- Generado: `SQL/08_clinical/05_constraints.sql` por `gen_integrity.py`
--
-- Idempotente. Aplicar sobre bases ya vivas; una base reconstruida desde `SQL/`
-- lo recibe sin este patch.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- Antes de crear la restricción: si la base ya tiene solapes, esto FALLA y hay
-- que limpiarlos primero. Falla ruidosamente a propósito — crear la restricción
-- «como se pueda» dejaría datos que la violan y nadie se enteraría.
ALTER TABLE "clinical"."appointments"
    DROP CONSTRAINT IF EXISTS "ex_appointments_practitioner_time";

ALTER TABLE "clinical"."appointments"
    ADD CONSTRAINT "ex_appointments_practitioner_time"
    EXCLUDE USING gist (
        "practitioner_profile_id" WITH =,
        tstzrange("start_at", "end_at", '[)') WITH &&
    ) WHERE (
        "practitioner_profile_id" IS NOT NULL
        AND "end_at" IS NOT NULL
        AND "status_concept_id" IN (
            '51530fd7-05b1-5c29-80c4-da740ede4d27',
            '37dded87-7a7a-5a24-86f6-0ef48cccb482'
        )
    );
