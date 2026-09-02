-- SALUD v4.0.10 · módulo 41 · schema scheduling
-- Generado de diagram_41_scheduling.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_booking_confirmation_rules_tenant_id" ON "scheduling"."booking_confirmation_rules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_booking_confirmation_rules_scope" ON "scheduling"."booking_confirmation_rules" ("scope_type_concept_id", "scope_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_schedules_practitioner_profile_id" ON "scheduling"."practitioner_schedules" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_schedules_practice_id" ON "scheduling"."practitioner_schedules" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_schedules_care_space_id" ON "scheduling"."practitioner_schedules" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_schedules_status_concept_id" ON "scheduling"."practitioner_schedules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_schedules_created_by_user_id" ON "scheduling"."practitioner_schedules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_schedules_updated_by_user_id" ON "scheduling"."practitioner_schedules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_practitioner_schedules_effective_period" ON "scheduling"."practitioner_schedules" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_availability_slots_schedule_id" ON "scheduling"."availability_slots" ("schedule_id");

CREATE INDEX IF NOT EXISTS "ix_availability_slots_practitioner_profile_id" ON "scheduling"."availability_slots" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_availability_slots_care_space_id" ON "scheduling"."availability_slots" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_availability_slots_status_concept_id" ON "scheduling"."availability_slots" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_availability_slots_appointment_id" ON "scheduling"."availability_slots" ("appointment_id");

CREATE INDEX IF NOT EXISTS "ix_availability_slots_created_by_user_id" ON "scheduling"."availability_slots" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_availability_slots_updated_by_user_id" ON "scheduling"."availability_slots" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_availability_slots_effective_period" ON "scheduling"."availability_slots" USING gist (tstzrange(start_at, end_at, '[)'));

CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_tenant_id" ON "scheduling"."schedulable_resources" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_practice_id" ON "scheduling"."schedulable_resources" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_resource_type_concept_id" ON "scheduling"."schedulable_resources" ("resource_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_state_concept_id" ON "scheduling"."schedulable_resources" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_created_by_user_id" ON "scheduling"."schedulable_resources" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_updated_by_user_id" ON "scheduling"."schedulable_resources" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_tenant_id_state_concept_id" ON "scheduling"."schedulable_resources" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_resource_id" ON "scheduling"."schedule_templates" ("resource_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_practitioner_schedule_id" ON "scheduling"."schedule_templates" ("practitioner_schedule_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_service_concept_id" ON "scheduling"."schedule_templates" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_booking_policy_id" ON "scheduling"."schedule_templates" ("booking_policy_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_status_concept_id" ON "scheduling"."schedule_templates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_created_by_user_id" ON "scheduling"."schedule_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_templates_updated_by_user_id" ON "scheduling"."schedule_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_schedule_templates_effective_period" ON "scheduling"."schedule_templates" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_schedule_rules_schedule_template_id" ON "scheduling"."schedule_rules" ("schedule_template_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_rules_created_by_user_id" ON "scheduling"."schedule_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_schedule_rules_updated_by_user_id" ON "scheduling"."schedule_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_schedule_rules_effective_period" ON "scheduling"."schedule_rules" USING gist (daterange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_resource_id" ON "scheduling"."availability_exceptions" ("resource_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_exception_type_concept_id" ON "scheduling"."availability_exceptions" ("exception_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_created_by_user_id" ON "scheduling"."availability_exceptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_availability_exceptions_updated_by_user_id" ON "scheduling"."availability_exceptions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_availability_exceptions_effective_period" ON "scheduling"."availability_exceptions" USING gist (tstzrange(start_at, end_at, '[)'));

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_resource_id" ON "scheduling"."bookable_slots" ("resource_id");

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_schedule_template_id" ON "scheduling"."bookable_slots" ("schedule_template_id");

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_service_concept_id" ON "scheduling"."bookable_slots" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_status_concept_id" ON "scheduling"."bookable_slots" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_created_by_user_id" ON "scheduling"."bookable_slots" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_updated_by_user_id" ON "scheduling"."bookable_slots" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_slot_holds_hold_token" ON "scheduling"."slot_holds" ("hold_token");

CREATE INDEX IF NOT EXISTS "ix_slot_holds_bookable_slot_id" ON "scheduling"."slot_holds" ("bookable_slot_id");

CREATE INDEX IF NOT EXISTS "ix_slot_holds_patient_profile_id" ON "scheduling"."slot_holds" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_slot_holds_held_by_user_id" ON "scheduling"."slot_holds" ("held_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_slot_holds_status_concept_id" ON "scheduling"."slot_holds" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_slot_holds_created_by_user_id" ON "scheduling"."slot_holds" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_slot_holds_updated_by_user_id" ON "scheduling"."slot_holds" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_slot_holds_patient_profile_id_updated_at" ON "scheduling"."slot_holds" ("patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_booking_policies_tenant_id" ON "scheduling"."booking_policies" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_practice_id" ON "scheduling"."booking_policies" ("practice_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_currency_concept_id" ON "scheduling"."booking_policies" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_state_concept_id" ON "scheduling"."booking_policies" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_created_by_user_id" ON "scheduling"."booking_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_updated_by_user_id" ON "scheduling"."booking_policies" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_booking_policies_tenant_id_state_concept_id" ON "scheduling"."booking_policies" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_tenant_id" ON "scheduling"."appointment_bookings" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_patient_profile_id" ON "scheduling"."appointment_bookings" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_bookable_slot_id" ON "scheduling"."appointment_bookings" ("bookable_slot_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_resource_id" ON "scheduling"."appointment_bookings" ("resource_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_appointment_id" ON "scheduling"."appointment_bookings" ("appointment_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_service_concept_id" ON "scheduling"."appointment_bookings" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_booking_channel_concept_id" ON "scheduling"."appointment_bookings" ("booking_channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_booked_by_user_id" ON "scheduling"."appointment_bookings" ("booked_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_status_concept_id" ON "scheduling"."appointment_bookings" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_booking_policy_id" ON "scheduling"."appointment_bookings" ("booking_policy_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_created_by_user_id" ON "scheduling"."appointment_bookings" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_updated_by_user_id" ON "scheduling"."appointment_bookings" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_tenant_id_status_concept_id" ON "scheduling"."appointment_bookings" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_patient_profile_id_updated_at" ON "scheduling"."appointment_bookings" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_booking_reschedules_booking_id" ON "scheduling"."booking_reschedules" ("booking_id");

CREATE INDEX IF NOT EXISTS "ix_booking_reschedules_from_slot_id" ON "scheduling"."booking_reschedules" ("from_slot_id");

CREATE INDEX IF NOT EXISTS "ix_booking_reschedules_to_slot_id" ON "scheduling"."booking_reschedules" ("to_slot_id");

CREATE INDEX IF NOT EXISTS "ix_booking_reschedules_reason_concept_id" ON "scheduling"."booking_reschedules" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_booking_reschedules_rescheduled_by_user_id" ON "scheduling"."booking_reschedules" ("rescheduled_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_booking_reschedules_recorded_by_user_id" ON "scheduling"."booking_reschedules" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_booking_reschedules_recorded_at" ON "scheduling"."booking_reschedules" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_booking_id" ON "scheduling"."booking_cancellations" ("booking_id");

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_reason_concept_id" ON "scheduling"."booking_cancellations" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_cancelled_by_user_id" ON "scheduling"."booking_cancellations" ("cancelled_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_currency_concept_id" ON "scheduling"."booking_cancellations" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_fee_payment_intent_id" ON "scheduling"."booking_cancellations" ("fee_payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_status_concept_id" ON "scheduling"."booking_cancellations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_created_by_user_id" ON "scheduling"."booking_cancellations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_booking_cancellations_updated_by_user_id" ON "scheduling"."booking_cancellations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_tenant_id" ON "scheduling"."waitlist_entries" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_patient_profile_id" ON "scheduling"."waitlist_entries" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_resource_id" ON "scheduling"."waitlist_entries" ("resource_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_service_concept_id" ON "scheduling"."waitlist_entries" ("service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_status_concept_id" ON "scheduling"."waitlist_entries" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_fulfilled_booking_id" ON "scheduling"."waitlist_entries" ("fulfilled_booking_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_created_by_user_id" ON "scheduling"."waitlist_entries" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_updated_by_user_id" ON "scheduling"."waitlist_entries" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_tenant_id_status_concept_id" ON "scheduling"."waitlist_entries" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_waitlist_entries_patient_profile_id_updated_at" ON "scheduling"."waitlist_entries" ("tenant_id", "patient_profile_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_appointment_reminders_booking_id" ON "scheduling"."appointment_reminders" ("booking_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_reminders_channel_concept_id" ON "scheduling"."appointment_reminders" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_reminders_notification_request_id" ON "scheduling"."appointment_reminders" ("notification_request_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_reminders_status_concept_id" ON "scheduling"."appointment_reminders" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_reminders_created_by_user_id" ON "scheduling"."appointment_reminders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_reminders_updated_by_user_id" ON "scheduling"."appointment_reminders" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_calendar_absences_subject" ON "scheduling"."calendar_absences" ("tenant_id", "subject_type_concept_id", "subject_ref_id");

CREATE INDEX IF NOT EXISTS "ix_calendar_absences_resource_id" ON "scheduling"."calendar_absences" ("resource_id");

CREATE INDEX IF NOT EXISTS "ix_calendar_absences_person_id" ON "scheduling"."calendar_absences" ("person_id");

CREATE INDEX IF NOT EXISTS "ix_calendar_absences_user_id" ON "scheduling"."calendar_absences" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_calendar_absences_range" ON "scheduling"."calendar_absences" ("tenant_id", "start_at", "end_at");

CREATE INDEX IF NOT EXISTS "ix_calendar_absences_approval_status_concept_id" ON "scheduling"."calendar_absences" ("approval_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_calendar_absences_time_off_request_id" ON "scheduling"."calendar_absences" ("time_off_request_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_appointment_payment_states_booking" ON "scheduling"."appointment_payment_states" ("appointment_booking_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_payment_states_tenant_status" ON "scheduling"."appointment_payment_states" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_payment_states_status_concept_id" ON "scheduling"."appointment_payment_states" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_payment_states_marked_by_user_id" ON "scheduling"."appointment_payment_states" ("marked_by_user_id");
