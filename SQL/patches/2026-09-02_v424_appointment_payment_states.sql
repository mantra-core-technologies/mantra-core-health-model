-- ============================================================================
-- SALUD · patch v4.2.4 (scheduling · el estado de pago de una cita) sobre una BD viva
-- Fecha: 2026-09-02
-- Idempotente (CREATE TABLE / CREATE INDEX / ADD CONSTRAINT IF NOT EXISTS).
-- UNA sola pasada: no hay backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite esta tabla en SQL/41_scheduling/ desde que el
-- .puml la declara, así que en un rebuild desde cero este patch NO hace falta.
-- Existe únicamente para una base ya aplicada y poblada. gen_apply.py no escanea
-- SQL/patches/ (solo directorios NN_schema), así que no entra en apply_all.sql.
--
-- QUÉ CIERRA. El punto 5 de la TAREA-13: «un botón para marcar una cita como
-- pagada o pendiente de pago». Hasta hoy ese dato NO TENÍA DÓNDE VIVIR:
-- `appointment_bookings` no tiene columna de pago, `payments` no referencia
-- reservas y `billing` cuelga de `clinical.encounters`, que es el encuentro
-- atendido y no la cita agendada.
--
-- POR QUÉ TABLA PROPIA Y NO UNA COLUMNA. Decisión del propietario, y se sostiene
-- por dos razones:
--
--   1. Es un dato financiero. Una columna en `appointment_bookings` acopla la
--      agenda con finanzas, que es exactamente lo que el resto del modelo evita.
--   2. La regla que dio el propietario son DOS EJES, no uno: «no es excluyente
--      con pendiente, aceptada y realizada; sí lo es con rechazada y cancelada».
--      «Sin fila» expresa esa ausencia mucho mejor que un NULL en una columna
--      que existe para todas las reservas, incluidas las que jamás podrán tener
--      estado de pago.
--
-- POR QUÉ NO HAY BACKFILL, Y ES DELIBERADO. Sería tentador crear una fila
-- «pendiente de pago» para cada reserva existente. Sería falso: nadie la marcó.
-- `marked_by_user_id` y `marked_at` son NOT NULL justamente para que no exista
-- una fila que nadie firmó, y el backfill tendría que inventar un autor. Una
-- reserva sin fila significa «todavía no se dijo nada del pago», que es la
-- verdad.
--
-- POR QUÉ `insurance_used` ES BOOLEANO Y EL ESTADO NO. El estado son tres
-- valores cerrados (pendiente / parcialmente pagada / pagada), y en este
-- proyecto un estado cerrado es un `*_concept_id` contra
-- `terminology.catalog_concepts`, nunca un enum de TypeScript. «Se usó seguro»
-- no es un estado: es un sí o un no, y va como booleano —igual que
-- `calendar_absences.blocks_scheduling`—. El propietario pidió expresamente que
-- fuera una marca SEPARADA: meterla dentro del estado daría seis valores para
-- responder dos preguntas distintas.
--
-- SOBRE EL ÍNDICE ÚNICO. Es lo que hace cierto el «uno a lo sumo uno» que la
-- flecha del .puml sólo sugiere. Sin él, dos peticiones concurrentes que marquen
-- la misma cita dejarían dos filas con estados distintos y ninguna forma de
-- decir cuál vale.
--
-- SOBRE EL RASTRO (AC-13-10). No se guarda acá. Cada marca agrega una revisión a
-- `audit.appointment_bookings_history`, que ya existe y que el módulo scheduling
-- ya escribe con `HistoryRepository`. Dos líneas de tiempo para la misma cita
-- serían dos verdades; esta tabla guarda el estado ACTUAL y quién lo dejó así.
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "scheduling"."appointment_payment_states" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "appointment_booking_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "insurance_used" boolean NOT NULL,
    "marked_by_user_id" uuid NOT NULL,
    "marked_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_appointment_payment_states" PRIMARY KEY ("id")
);

-- Uno a lo sumo uno por reserva. Es la garantía real del modelo.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_appointment_payment_states_booking"
    ON "scheduling"."appointment_payment_states" ("appointment_booking_id");

-- «Todas las citas pendientes de pago de esta organización», que es la lectura
-- que la pantalla hace.
CREATE INDEX IF NOT EXISTS "ix_appointment_payment_states_tenant_status"
    ON "scheduling"."appointment_payment_states" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_payment_states_status_concept_id"
    ON "scheduling"."appointment_payment_states" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_payment_states_marked_by_user_id"
    ON "scheduling"."appointment_payment_states" ("marked_by_user_id");

-- Las FKs se agregan de a una y con guarda: `ADD CONSTRAINT IF NOT EXISTS` no
-- existe en Postgres para claves foráneas, así que se consulta el catálogo.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_appointment_payment_states_appointment_booking_id'
    ) THEN
        ALTER TABLE "scheduling"."appointment_payment_states"
            ADD CONSTRAINT "fk_appointment_payment_states_appointment_booking_id"
            FOREIGN KEY ("appointment_booking_id")
            REFERENCES "scheduling"."appointment_bookings" ("id");
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_appointment_payment_states_tenant_id'
    ) THEN
        ALTER TABLE "scheduling"."appointment_payment_states"
            ADD CONSTRAINT "fk_appointment_payment_states_tenant_id"
            FOREIGN KEY ("tenant_id")
            REFERENCES "directory"."tenants" ("id");
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_appointment_payment_states_status_concept_id'
    ) THEN
        ALTER TABLE "scheduling"."appointment_payment_states"
            ADD CONSTRAINT "fk_appointment_payment_states_status_concept_id"
            FOREIGN KEY ("status_concept_id")
            REFERENCES "terminology"."catalog_concepts" ("id");
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_appointment_payment_states_marked_by_user_id'
    ) THEN
        ALTER TABLE "scheduling"."appointment_payment_states"
            ADD CONSTRAINT "fk_appointment_payment_states_marked_by_user_id"
            FOREIGN KEY ("marked_by_user_id")
            REFERENCES "iam"."users" ("id");
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_appointment_payment_states_created_by_user_id'
    ) THEN
        ALTER TABLE "scheduling"."appointment_payment_states"
            ADD CONSTRAINT "fk_appointment_payment_states_created_by_user_id"
            FOREIGN KEY ("created_by_user_id")
            REFERENCES "iam"."users" ("id");
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_appointment_payment_states_updated_by_user_id'
    ) THEN
        ALTER TABLE "scheduling"."appointment_payment_states"
            ADD CONSTRAINT "fk_appointment_payment_states_updated_by_user_id"
            FOREIGN KEY ("updated_by_user_id")
            REFERENCES "iam"."users" ("id");
    END IF;
END $$;

COMMIT;
