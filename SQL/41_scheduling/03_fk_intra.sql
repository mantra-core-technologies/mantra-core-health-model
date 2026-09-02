-- SALUD v4.0.10 · módulo 41 · schema scheduling
-- Generado de diagram_41_scheduling.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "scheduling"."availability_slots"
        ADD CONSTRAINT "fk_availability_slots_schedule_id" FOREIGN KEY ("schedule_id")
        REFERENCES "scheduling"."practitioner_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_templates"
        ADD CONSTRAINT "fk_schedule_templates_resource_id" FOREIGN KEY ("resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_templates"
        ADD CONSTRAINT "fk_schedule_templates_practitioner_schedule_id" FOREIGN KEY ("practitioner_schedule_id")
        REFERENCES "scheduling"."practitioner_schedules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_templates"
        ADD CONSTRAINT "fk_schedule_templates_booking_policy_id" FOREIGN KEY ("booking_policy_id")
        REFERENCES "scheduling"."booking_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."schedule_rules"
        ADD CONSTRAINT "fk_schedule_rules_schedule_template_id" FOREIGN KEY ("schedule_template_id")
        REFERENCES "scheduling"."schedule_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."availability_exceptions"
        ADD CONSTRAINT "fk_availability_exceptions_resource_id" FOREIGN KEY ("resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."bookable_slots"
        ADD CONSTRAINT "fk_bookable_slots_resource_id" FOREIGN KEY ("resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."bookable_slots"
        ADD CONSTRAINT "fk_bookable_slots_schedule_template_id" FOREIGN KEY ("schedule_template_id")
        REFERENCES "scheduling"."schedule_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."slot_holds"
        ADD CONSTRAINT "fk_slot_holds_bookable_slot_id" FOREIGN KEY ("bookable_slot_id")
        REFERENCES "scheduling"."bookable_slots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_bookable_slot_id" FOREIGN KEY ("bookable_slot_id")
        REFERENCES "scheduling"."bookable_slots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_resource_id" FOREIGN KEY ("resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_booking_policy_id" FOREIGN KEY ("booking_policy_id")
        REFERENCES "scheduling"."booking_policies" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."booking_reschedules"
        ADD CONSTRAINT "fk_booking_reschedules_booking_id" FOREIGN KEY ("booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."booking_reschedules"
        ADD CONSTRAINT "fk_booking_reschedules_from_slot_id" FOREIGN KEY ("from_slot_id")
        REFERENCES "scheduling"."bookable_slots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."booking_reschedules"
        ADD CONSTRAINT "fk_booking_reschedules_to_slot_id" FOREIGN KEY ("to_slot_id")
        REFERENCES "scheduling"."bookable_slots" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."booking_cancellations"
        ADD CONSTRAINT "fk_booking_cancellations_booking_id" FOREIGN KEY ("booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."waitlist_entries"
        ADD CONSTRAINT "fk_waitlist_entries_resource_id" FOREIGN KEY ("resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."waitlist_entries"
        ADD CONSTRAINT "fk_waitlist_entries_fulfilled_booking_id" FOREIGN KEY ("fulfilled_booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_reminders"
        ADD CONSTRAINT "fk_appointment_reminders_booking_id" FOREIGN KEY ("booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."calendar_absences"
        ADD CONSTRAINT "fk_calendar_absences_resource_id" FOREIGN KEY ("resource_id")
        REFERENCES "scheduling"."schedulable_resources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_payment_states"
        ADD CONSTRAINT "fk_appointment_payment_states_appointment_booking_id" FOREIGN KEY ("appointment_booking_id")
        REFERENCES "scheduling"."appointment_bookings" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)
