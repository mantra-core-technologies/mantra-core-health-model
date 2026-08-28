-- SALUD v4.0.10 · módulo 06 · schema authz
-- Generado de diagram_06_authz.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "authz"."permission_categories" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_permission_categories" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."permissions" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "category_id" uuid,
    "name" varchar NOT NULL,
    "resource" varchar NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "default_scope_concept_id" uuid,
    "is_field_level" boolean,
    "is_dangerous" boolean,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    "is_role_restricted" boolean NOT NULL,
    "required_role_code" varchar,
    "allow_direct_user_grant" boolean NOT NULL,
    CONSTRAINT "pk_permissions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."roles" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_role_id" uuid,
    "base_role_concept_id" uuid,
    "scope_concept_id" uuid,
    "is_system" boolean NOT NULL,
    "is_assignable" boolean NOT NULL,
    "priority" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_roles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."role_permissions" (
    "id" uuid NOT NULL,
    "role_id" uuid NOT NULL,
    "permission_id" uuid NOT NULL,
    "effect_concept_id" uuid NOT NULL,
    "scope_concept_id" uuid,
    "constraint_json" jsonb,
    "field_value_set_id" uuid,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_role_permissions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."user_role_assignments" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "role_id" uuid NOT NULL,
    "tenant_id" uuid,
    "branch_id" uuid,
    "practice_id" uuid,
    "assigned_by_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_user_role_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."user_permission_grants" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "permission_id" uuid NOT NULL,
    "effect_concept_id" uuid NOT NULL,
    "scope_concept_id" uuid,
    "resource_selector_json" jsonb,
    "tenant_id" uuid,
    "reason" varchar,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_user_permission_grants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."field_permissions" (
    "id" uuid NOT NULL,
    "role_id" uuid NOT NULL,
    "entity" varchar NOT NULL,
    "column_name" varchar NOT NULL,
    "can_read" boolean NOT NULL,
    "can_write" boolean NOT NULL,
    "mask_strategy_concept_id" uuid,
    "condition_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_field_permissions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."resource_scope_grants" (
    "id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_id" uuid NOT NULL,
    "permission_id" uuid NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "effect_concept_id" uuid NOT NULL,
    "tenant_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_resource_scope_grants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."access_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "effect_concept_id" uuid NOT NULL,
    "target_resource" varchar,
    "condition_json" jsonb,
    "priority" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_access_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."clinical_access_grants" (
    "id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "granted_user_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "branch_id" uuid,
    "encounter_id" uuid,
    "consent_id" uuid,
    "reason_concept_id" uuid NOT NULL,
    "access_level_concept_id" uuid NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_clinical_access_grants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."service_principals" (
    "id" uuid NOT NULL,
    CONSTRAINT "pk_service_principals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."break_glass_sessions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "patient_ref_id" uuid NOT NULL,
    "patient_ref_type_concept_id" uuid NOT NULL,
    "justification" varchar NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "granted_by_policy_id" uuid,
    "activated_at" timestamptz,
    "expires_at" timestamptz,
    "deactivated_at" timestamptz,
    "reviewed_by_user_id" uuid,
    "reviewed_at" timestamptz,
    "review_outcome_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_break_glass_sessions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."ip_access_rules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "subject_ref_id" uuid,
    "subject_ref_type_concept_id" uuid,
    "rule_type_concept_id" uuid NOT NULL,
    "cidr" varchar NOT NULL,
    "description" varchar,
    "priority" integer,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_ip_access_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."care_relationships" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "relationship_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "purpose_concept_id" uuid,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "established_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_care_relationships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "authz"."patient_legal_representations" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "representative_user_id" uuid NOT NULL,
    "representation_type_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "document_ref" varchar(200),
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_legal_representations" PRIMARY KEY ("id")
);
