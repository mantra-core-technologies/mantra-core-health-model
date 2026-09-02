-- SALUD v4.0.10 · módulo 41 · schema scheduling
-- Generado de diagram_41_scheduling.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "scheduling"."practitioner_schedules" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "practice_id" uuid,
    "care_space_id" uuid,
    "day_of_week" integer,
    "start_time" time,
    "end_time" time,
    "slot_minutes" integer,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_schedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."availability_slots" (
    "id" uuid NOT NULL,
    "schedule_id" uuid,
    "practitioner_profile_id" uuid NOT NULL,
    "care_space_id" uuid,
    "start_at" timestamptz NOT NULL,
    "end_at" timestamptz NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "appointment_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_availability_slots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."schedulable_resources" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "resource_type_concept_id" uuid NOT NULL,
    "resource_ref_type" varchar NOT NULL,
    "resource_ref_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "time_zone" varchar,
    "capacity" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_schedulable_resources" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."schedule_templates" (
    "id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "practitioner_schedule_id" uuid,
    "name" varchar NOT NULL,
    "service_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "slot_minutes" integer,
    "booking_policy_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_schedule_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."schedule_rules" (
    "id" uuid NOT NULL,
    "schedule_template_id" uuid NOT NULL,
    "day_of_week" integer NOT NULL,
    "start_time" time NOT NULL,
    "end_time" time NOT NULL,
    "slot_minutes" integer,
    "capacity_per_slot" integer,
    "gap_minutes" integer,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_schedule_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."availability_exceptions" (
    "id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "exception_type_concept_id" uuid NOT NULL,
    "start_at" timestamptz NOT NULL,
    "end_at" timestamptz NOT NULL,
    "reason" varchar,
    "is_available" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_availability_exceptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."bookable_slots" (
    "id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "schedule_template_id" uuid,
    "service_concept_id" uuid,
    "start_at" timestamptz NOT NULL,
    "end_at" timestamptz NOT NULL,
    "capacity" integer NOT NULL,
    "remaining_capacity" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_bookable_slots" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."slot_holds" (
    "id" uuid NOT NULL,
    "bookable_slot_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "held_by_user_id" uuid NOT NULL,
    "hold_token" varchar NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "released_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_slot_holds" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."booking_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "min_notice_minutes" integer,
    "max_advance_days" integer,
    "cancellation_window_minutes" integer,
    "no_show_fee_amount" numeric,
    "currency_concept_id" uuid,
    "allow_overbooking" boolean,
    "max_active_per_patient" integer,
    "hold_ttl_seconds" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_booking_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."appointment_bookings" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "bookable_slot_id" uuid NOT NULL,
    "resource_id" uuid,
    "appointment_id" uuid,
    "service_concept_id" uuid,
    "booking_channel_concept_id" uuid NOT NULL,
    "booked_by_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "confirmed_at" timestamptz,
    "checked_in_at" timestamptz,
    "reason_text" text,
    "booking_policy_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    "cancellation_policy_snapshot" jsonb,
    CONSTRAINT "pk_appointment_bookings" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."booking_confirmation_rules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "scope_type_concept_id" uuid NOT NULL,
    "scope_id" uuid,
    "priority" integer NOT NULL,
    "effective_from" timestamptz NOT NULL,
    "effective_to" timestamptz,
    "condition_json" jsonb NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "enabled" boolean NOT NULL,
    "version" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_booking_confirmation_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."booking_reschedules" (
    "id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "from_slot_id" uuid NOT NULL,
    "to_slot_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "rescheduled_by_user_id" uuid,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_booking_reschedules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."booking_cancellations" (
    "id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "cancelled_by_user_id" uuid,
    "is_no_show" boolean,
    "fee_amount" numeric,
    "currency_concept_id" uuid,
    "fee_payment_intent_id" uuid,
    "cancelled_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_booking_cancellations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."waitlist_entries" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "resource_id" uuid,
    "service_concept_id" uuid,
    "desired_from" timestamptz,
    "desired_to" timestamptz,
    "priority" integer NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "fulfilled_booking_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_waitlist_entries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."appointment_reminders" (
    "id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "channel_concept_id" uuid NOT NULL,
    "offset_minutes" integer NOT NULL,
    "scheduled_at" timestamptz NOT NULL,
    "sent_at" timestamptz,
    "notification_request_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_appointment_reminders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "scheduling"."calendar_absences" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_ref_id" uuid NOT NULL,
    "person_id" uuid,
    "user_id" uuid,
    "resource_id" uuid,
    "absence_type_concept_id" uuid NOT NULL,
    "start_at" timestamptz NOT NULL,
    "end_at" timestamptz NOT NULL,
    "all_day" boolean,
    "reason" varchar,
    "approval_status_concept_id" uuid NOT NULL,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "time_off_request_id" uuid,
    "blocks_scheduling" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_calendar_absences" PRIMARY KEY ("id")
);

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
