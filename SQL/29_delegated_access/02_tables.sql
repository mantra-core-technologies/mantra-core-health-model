-- SALUD v4.0.10 · módulo 29 · schema delegated_access
-- Generado de diagram_29_delegated_access.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "delegated_access"."organization_user_assignments" (
    "id" uuid NOT NULL,
    "tenant_membership_id" uuid NOT NULL,
    "practice_id" uuid,
    "practice_site_id" uuid,
    "clinical_unit_id" uuid,
    "care_space_id" uuid,
    "diagnostic_unit_id" uuid,
    "pharmacy_id" uuid,
    "assignment_role_concept_id" uuid NOT NULL,
    "access_scope_concept_id" uuid NOT NULL,
    "supervisor_user_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_organization_user_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."delegated_permission_sets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "delegate_type_concept_id" uuid NOT NULL,
    "description" text,
    "status_concept_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_delegated_permission_sets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."delegated_permission_set_items" (
    "id" uuid NOT NULL,
    "delegated_permission_set_id" uuid NOT NULL,
    "permission_id" uuid NOT NULL,
    "constraint_json" jsonb,
    "requires_step_up_authentication" boolean,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_delegated_permission_set_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."practitioner_delegate_assignments" (
    "id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid NOT NULL,
    "delegate_user_assignment_id" uuid NOT NULL,
    "delegated_permission_set_id" uuid NOT NULL,
    "delegate_role_concept_id" uuid NOT NULL,
    "patient_scope_concept_id" uuid,
    "appointment_scope_concept_id" uuid,
    "may_view_clinical_content" boolean,
    "may_edit_drafts" boolean,
    "may_sign_clinical_content" boolean,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_delegate_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."delegated_access_grants" (
    "id" uuid NOT NULL,
    "practitioner_delegate_assignment_id" uuid NOT NULL,
    "grant_type_concept_id" uuid NOT NULL,
    "purpose_of_use_concept_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "encounter_id" uuid,
    "resource_type_concept_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "approved_by_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_delegated_access_grants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."delegated_access_approval_requests" (
    "id" uuid NOT NULL,
    "practitioner_delegate_assignment_id" uuid NOT NULL,
    "requested_permission_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "encounter_id" uuid,
    "reason_text" text,
    "requested_at" timestamptz,
    "decided_at" timestamptz,
    "decided_by_user_id" uuid,
    "decision_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_delegated_access_approval_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."delegation_events" (
    "id" uuid NOT NULL,
    "practitioner_delegate_assignment_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "actor_user_id" uuid,
    "target_user_id" uuid,
    "reason_concept_id" uuid,
    "previous_state_hash" varchar,
    "new_state_hash" varchar,
    "occurred_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_delegation_events" PRIMARY KEY ("id")
);
