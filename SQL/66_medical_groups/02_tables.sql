-- SALUD v4.0.10 · módulo 66 · schema medical_groups
-- Generado de diagram_66_medical_groups.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "medical_groups"."groups" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "service_catalog_id" uuid NOT NULL,
    "requesting_practitioner_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "condition_id" uuid,
    "scheduled_at" timestamptz NOT NULL,
    "location_text" varchar NOT NULL,
    "notes_text" text,
    "terms_text" text NOT NULL,
    "status" varchar NOT NULL,
    "exercise_notes_text" text,
    "exercise_notes_updated_at" timestamptz,
    "proposed_reschedule_at" timestamptz,
    "proposed_by_practitioner_id" uuid,
    "closed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_groups" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "medical_groups"."group_members" (
    "id" uuid NOT NULL,
    "group_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "role_title" varchar NOT NULL,
    "agreed_payment_amount" numeric NOT NULL,
    "agreed_payment_currency_concept_id" uuid,
    "additional_terms_text" text,
    "is_creator" boolean NOT NULL,
    "invitation_status" varchar NOT NULL,
    "responded_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_group_members" PRIMARY KEY ("id")
);
