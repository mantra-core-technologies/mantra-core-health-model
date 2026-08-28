-- SALUD v4.0.10 · módulo 49 · schema crm
-- Generado de diagram_49_crm.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "crm"."crm_accounts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "account_type_concept_id" uuid NOT NULL,
    "industry_concept_id" uuid,
    "parent_account_id" uuid,
    "website" varchar,
    "tax_id" varchar,
    "linked_tenant_id" uuid,
    "business_partner_id" uuid,
    "linked_org_ref_type" varchar,
    "linked_org_ref_id" uuid,
    "owner_user_id" uuid,
    "annual_value" numeric,
    "currency_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_accounts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."contacts" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "crm_account_id" uuid,
    "first_name" varchar NOT NULL,
    "last_name" varchar,
    "contact_type_concept_id" uuid NOT NULL,
    "job_title" varchar,
    "linked_user_id" uuid,
    "linked_profile_ref_type" varchar,
    "linked_profile_ref_id" uuid,
    "owner_user_id" uuid,
    "lifecycle_stage_concept_id" uuid,
    "source_concept_id" uuid,
    "do_not_contact" boolean,
    "marketing_consent_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contacts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."contact_channels" (
    "id" uuid NOT NULL,
    "contact_id" uuid NOT NULL,
    "channel_type_concept_id" uuid NOT NULL,
    "value" varchar NOT NULL,
    "is_primary" boolean,
    "is_verified" boolean,
    "opt_in_status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contact_channels" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."leads" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "lead_source_concept_id" uuid NOT NULL,
    "contact_id" uuid,
    "crm_account_id" uuid,
    "full_name" varchar,
    "email" varchar,
    "phone" varchar,
    "interest_text" varchar,
    "lead_score" numeric,
    "lead_status_concept_id" uuid NOT NULL,
    "owner_user_id" uuid,
    "campaign_ref_id" uuid,
    "converted_opportunity_id" uuid,
    "converted_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_leads" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."pipelines" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "pipeline_type_concept_id" uuid NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pipelines" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."pipeline_stages" (
    "id" uuid NOT NULL,
    "pipeline_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "ordinal" integer,
    "probability_percent" numeric,
    "is_won" boolean,
    "is_lost" boolean,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_pipeline_stages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."opportunities" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "pipeline_id" uuid NOT NULL,
    "stage_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "crm_account_id" uuid,
    "primary_contact_id" uuid,
    "amount" numeric,
    "currency_concept_id" uuid,
    "expected_close_date" date,
    "probability_percent" numeric,
    "owner_user_id" uuid,
    "contract_id" uuid,
    "sales_order_id" uuid,
    "lost_reason_concept_id" uuid,
    "won_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_opportunities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_activities" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "activity_type_concept_id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_ref_id" uuid NOT NULL,
    "contact_id" uuid,
    "crm_account_id" uuid,
    "direction_concept_id" uuid NOT NULL,
    "subject" varchar,
    "body_text" text,
    "outcome_concept_id" uuid,
    "due_at" timestamptz,
    "completed_at" timestamptz,
    "owner_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_activities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."partnerships" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "partnership_type_concept_id" uuid NOT NULL,
    "partner_ref_type" varchar NOT NULL,
    "partner_ref_id" uuid NOT NULL,
    "crm_account_id" uuid,
    "ad_partner_id" uuid,
    "contract_id" uuid,
    "tier_concept_id" uuid,
    "revenue_share_percent" numeric,
    "start_date" date,
    "end_date" date,
    "owner_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_partnerships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."partnership_agreements" (
    "id" uuid NOT NULL,
    "partnership_id" uuid NOT NULL,
    "agreement_type_concept_id" uuid NOT NULL,
    "contract_id" uuid,
    "terms_json" jsonb,
    "commitment_amount" numeric,
    "currency_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "document_file_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_partnership_agreements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."account_contact_relations" (
    "id" uuid NOT NULL,
    "crm_account_id" uuid NOT NULL,
    "contact_id" uuid NOT NULL,
    "relation_role_concept_id" uuid NOT NULL,
    "is_primary" boolean,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_account_contact_relations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."account_team_members" (
    "id" uuid NOT NULL,
    "crm_account_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "team_role_concept_id" uuid NOT NULL,
    "access_level_concept_id" uuid,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_account_team_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."opportunity_contact_roles" (
    "id" uuid NOT NULL,
    "opportunity_id" uuid NOT NULL,
    "contact_id" uuid NOT NULL,
    "role_concept_id" uuid NOT NULL,
    "is_primary" boolean,
    "influence_percent" numeric,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_opportunity_contact_roles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."opportunity_line_items" (
    "id" uuid NOT NULL,
    "opportunity_id" uuid NOT NULL,
    "line_number" integer NOT NULL,
    "product_or_service_type_concept_id" uuid,
    "product_or_service_ref_id" uuid,
    "description" varchar,
    "quantity" numeric,
    "unit_price" numeric,
    "discount_percent" numeric,
    "total_amount" numeric,
    "currency_concept_id" uuid,
    "contract_line_item_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_opportunity_line_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."opportunity_stage_history" (
    "id" uuid NOT NULL,
    "opportunity_id" uuid NOT NULL,
    "from_stage_id" uuid,
    "to_stage_id" uuid NOT NULL,
    "changed_at" timestamptz,
    "changed_by_user_id" uuid,
    "amount_at_change" numeric,
    "probability_at_change" numeric,
    "reason_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_opportunity_stage_history" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_activity_relations" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "relation_kind_concept_id" uuid NOT NULL,
    "related_entity_type_concept_id" uuid NOT NULL,
    "crm_account_id" uuid,
    "contact_id" uuid,
    "lead_id" uuid,
    "opportunity_id" uuid,
    "partnership_id" uuid,
    "contract_id" uuid,
    "case_id" uuid,
    "related_user_id" uuid,
    "is_primary" boolean,
    "is_invitee" boolean,
    "participant_role_concept_id" uuid,
    "response_status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_crm_activity_relations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_activity_assignments" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "assignee_user_id" uuid NOT NULL,
    "assignment_role_concept_id" uuid,
    "assigned_at" timestamptz,
    "accepted_at" timestamptz,
    "completed_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_crm_activity_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_tasks" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "task_subtype_concept_id" uuid NOT NULL,
    "priority_concept_id" uuid,
    "due_date" date,
    "reminder_at" timestamptz,
    "is_recurring" boolean,
    "recurrence_rule_id" uuid,
    "completed_at" timestamptz,
    "completion_note" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_tasks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_events" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "event_subtype_concept_id" uuid NOT NULL,
    "start_at" timestamptz,
    "end_at" timestamptz,
    "is_all_day" boolean,
    "time_zone" varchar,
    "location_text" varchar,
    "meeting_url" varchar,
    "organizer_user_id" uuid,
    "recurrence_rule_id" uuid,
    "parent_event_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_events" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_recurrence_rules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "recurrence_frequency_concept_id" uuid NOT NULL,
    "interval_count" integer,
    "by_day_json" jsonb,
    "count_limit" integer,
    "until_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_recurrence_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_activity_reminders" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "recipient_user_id" uuid NOT NULL,
    "channel_concept_id" uuid NOT NULL,
    "remind_at" timestamptz,
    "sent_at" timestamptz,
    "delivery_status_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_crm_activity_reminders" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_email_messages" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "thread_reference" varchar,
    "internet_message_id" varchar,
    "from_address" varchar,
    "subject" varchar,
    "body_text" text,
    "body_html_file_id" uuid,
    "sent_at" timestamptz,
    "received_at" timestamptz,
    "delivery_status_concept_id" uuid,
    "is_inbound" boolean,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_crm_email_messages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_email_recipients" (
    "id" uuid NOT NULL,
    "crm_email_message_id" uuid NOT NULL,
    "recipient_type_concept_id" uuid NOT NULL,
    "contact_id" uuid,
    "lead_id" uuid,
    "user_id" uuid,
    "email_address" varchar,
    "delivery_status_concept_id" uuid,
    "opened_at" timestamptz,
    "clicked_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_crm_email_recipients" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_call_logs" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "call_direction_concept_id" uuid NOT NULL,
    "started_at" timestamptz,
    "ended_at" timestamptz,
    "duration_seconds" integer,
    "from_number_masked" varchar,
    "to_number_masked" varchar,
    "outcome_concept_id" uuid,
    "recording_file_id" uuid,
    "external_call_id" varchar,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_crm_call_logs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_notes" (
    "id" uuid NOT NULL,
    "crm_activity_id" uuid NOT NULL,
    "note_text" text NOT NULL,
    "is_private" boolean,
    "is_pinned" boolean,
    "document_file_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_notes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_cases" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "case_number" varchar NOT NULL,
    "subject" varchar NOT NULL,
    "description" text,
    "crm_account_id" uuid,
    "primary_contact_id" uuid,
    "business_partner_id" uuid,
    "contract_id" uuid,
    "invoice_id" uuid,
    "case_type_concept_id" uuid,
    "origin_concept_id" uuid,
    "priority_concept_id" uuid,
    "owner_user_id" uuid,
    "parent_case_id" uuid,
    "opened_at" timestamptz,
    "closed_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_cases" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_case_contacts" (
    "id" uuid NOT NULL,
    "crm_case_id" uuid NOT NULL,
    "contact_id" uuid NOT NULL,
    "role_concept_id" uuid NOT NULL,
    "is_primary" boolean,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_crm_case_contacts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_case_comments" (
    "id" uuid NOT NULL,
    "crm_case_id" uuid NOT NULL,
    "comment_text" text NOT NULL,
    "is_public" boolean,
    "author_user_id" uuid,
    "attachment_file_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_crm_case_comments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_case_status_history" (
    "id" uuid NOT NULL,
    "crm_case_id" uuid NOT NULL,
    "from_status_concept_id" uuid,
    "to_status_concept_id" uuid NOT NULL,
    "changed_at" timestamptz,
    "changed_by_user_id" uuid,
    "reason_text" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_crm_case_status_history" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_entitlements" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "crm_account_id" uuid,
    "business_partner_id" uuid,
    "contract_id" uuid,
    "entitlement_type_concept_id" uuid,
    "start_date" date,
    "end_date" date,
    "response_time_minutes" integer,
    "resolution_time_minutes" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_entitlements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."crm_case_milestones" (
    "id" uuid NOT NULL,
    "crm_case_id" uuid NOT NULL,
    "crm_entitlement_id" uuid,
    "milestone_type_concept_id" uuid NOT NULL,
    "target_at" timestamptz,
    "completed_at" timestamptz,
    "breached_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_crm_case_milestones" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "crm"."contact_channel_endpoints" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "contact_id" uuid,
    "lead_id" uuid,
    "user_id" uuid,
    "endpoint_type_concept_id" uuid NOT NULL,
    "normalized_value" varchar NOT NULL,
    "masked_display_value" varchar NOT NULL,
    "value_hash" varchar NOT NULL,
    "is_primary" boolean NOT NULL,
    "verification_status_concept_id" uuid NOT NULL,
    "verified_at" timestamptz,
    "deliverability_status_concept_id" uuid NOT NULL,
    "last_success_at" timestamptz,
    "last_failure_at" timestamptz,
    "do_not_contact" boolean NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid NOT NULL,
    "updated_by_user_id" uuid NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_contact_channel_endpoints" PRIMARY KEY ("id")
);
