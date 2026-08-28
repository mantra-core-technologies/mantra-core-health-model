-- SALUD v4.0.10 · módulo 49 · schema crm
-- Generado de diagram_49_crm.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "crm"."contacts"
        ADD CONSTRAINT "fk_contacts_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."contact_channels"
        ADD CONSTRAINT "fk_contact_channels_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."leads"
        ADD CONSTRAINT "fk_leads_converted_opportunity_id" FOREIGN KEY ("converted_opportunity_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."pipeline_stages"
        ADD CONSTRAINT "fk_pipeline_stages_pipeline_id" FOREIGN KEY ("pipeline_id")
        REFERENCES "crm"."pipelines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_pipeline_id" FOREIGN KEY ("pipeline_id")
        REFERENCES "crm"."pipelines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_stage_id" FOREIGN KEY ("stage_id")
        REFERENCES "crm"."pipeline_stages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunities"
        ADD CONSTRAINT "fk_opportunities_primary_contact_id" FOREIGN KEY ("primary_contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activities"
        ADD CONSTRAINT "fk_crm_activities_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."partnerships"
        ADD CONSTRAINT "fk_partnerships_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."partnership_agreements"
        ADD CONSTRAINT "fk_partnership_agreements_partnership_id" FOREIGN KEY ("partnership_id")
        REFERENCES "crm"."partnerships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."account_contact_relations"
        ADD CONSTRAINT "fk_account_contact_relations_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."account_contact_relations"
        ADD CONSTRAINT "fk_account_contact_relations_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."account_team_members"
        ADD CONSTRAINT "fk_account_team_members_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_contact_roles"
        ADD CONSTRAINT "fk_opportunity_contact_roles_opportunity_id" FOREIGN KEY ("opportunity_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_contact_roles"
        ADD CONSTRAINT "fk_opportunity_contact_roles_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_line_items"
        ADD CONSTRAINT "fk_opportunity_line_items_opportunity_id" FOREIGN KEY ("opportunity_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_stage_history"
        ADD CONSTRAINT "fk_opportunity_stage_history_opportunity_id" FOREIGN KEY ("opportunity_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_stage_history"
        ADD CONSTRAINT "fk_opportunity_stage_history_from_stage_id" FOREIGN KEY ("from_stage_id")
        REFERENCES "crm"."pipeline_stages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."opportunity_stage_history"
        ADD CONSTRAINT "fk_opportunity_stage_history_to_stage_id" FOREIGN KEY ("to_stage_id")
        REFERENCES "crm"."pipeline_stages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_lead_id" FOREIGN KEY ("lead_id")
        REFERENCES "crm"."leads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_opportunity_id" FOREIGN KEY ("opportunity_id")
        REFERENCES "crm"."opportunities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_partnership_id" FOREIGN KEY ("partnership_id")
        REFERENCES "crm"."partnerships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_relations"
        ADD CONSTRAINT "fk_crm_activity_relations_case_id" FOREIGN KEY ("case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_assignments"
        ADD CONSTRAINT "fk_crm_activity_assignments_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_tasks"
        ADD CONSTRAINT "fk_crm_tasks_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_tasks"
        ADD CONSTRAINT "fk_crm_tasks_recurrence_rule_id" FOREIGN KEY ("recurrence_rule_id")
        REFERENCES "crm"."crm_recurrence_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_recurrence_rule_id" FOREIGN KEY ("recurrence_rule_id")
        REFERENCES "crm"."crm_recurrence_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_events"
        ADD CONSTRAINT "fk_crm_events_parent_event_id" FOREIGN KEY ("parent_event_id")
        REFERENCES "crm"."crm_events" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_activity_reminders"
        ADD CONSTRAINT "fk_crm_activity_reminders_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_messages"
        ADD CONSTRAINT "fk_crm_email_messages_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_recipients"
        ADD CONSTRAINT "fk_crm_email_recipients_crm_email_message_id" FOREIGN KEY ("crm_email_message_id")
        REFERENCES "crm"."crm_email_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_recipients"
        ADD CONSTRAINT "fk_crm_email_recipients_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_email_recipients"
        ADD CONSTRAINT "fk_crm_email_recipients_lead_id" FOREIGN KEY ("lead_id")
        REFERENCES "crm"."leads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_call_logs"
        ADD CONSTRAINT "fk_crm_call_logs_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_notes"
        ADD CONSTRAINT "fk_crm_notes_crm_activity_id" FOREIGN KEY ("crm_activity_id")
        REFERENCES "crm"."crm_activities" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_primary_contact_id" FOREIGN KEY ("primary_contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_cases"
        ADD CONSTRAINT "fk_crm_cases_parent_case_id" FOREIGN KEY ("parent_case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_contacts"
        ADD CONSTRAINT "fk_crm_case_contacts_crm_case_id" FOREIGN KEY ("crm_case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_contacts"
        ADD CONSTRAINT "fk_crm_case_contacts_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_comments"
        ADD CONSTRAINT "fk_crm_case_comments_crm_case_id" FOREIGN KEY ("crm_case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_status_history"
        ADD CONSTRAINT "fk_crm_case_status_history_crm_case_id" FOREIGN KEY ("crm_case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_entitlements"
        ADD CONSTRAINT "fk_crm_entitlements_crm_account_id" FOREIGN KEY ("crm_account_id")
        REFERENCES "crm"."crm_accounts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_milestones"
        ADD CONSTRAINT "fk_crm_case_milestones_crm_case_id" FOREIGN KEY ("crm_case_id")
        REFERENCES "crm"."crm_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."crm_case_milestones"
        ADD CONSTRAINT "fk_crm_case_milestones_crm_entitlement_id" FOREIGN KEY ("crm_entitlement_id")
        REFERENCES "crm"."crm_entitlements" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_contact_id" FOREIGN KEY ("contact_id")
        REFERENCES "crm"."contacts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "crm"."contact_channel_endpoints"
        ADD CONSTRAINT "fk_contact_channel_endpoints_lead_id" FOREIGN KEY ("lead_id")
        REFERENCES "crm"."leads" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
