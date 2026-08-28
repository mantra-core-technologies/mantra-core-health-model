-- SALUD v4.0.10 · módulo 49 · schema crm
-- Generado de diagram_49_crm.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_account_contact_relations_crm_account_id_contact_id_6579264d" ON "crm"."account_contact_relations" ("crm_account_id", "contact_id", "relation_role_concept_id", "valid_from");

CREATE INDEX IF NOT EXISTS "ix_account_contact_relations_crm_account_id" ON "crm"."account_contact_relations" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_account_contact_relations_contact_id" ON "crm"."account_contact_relations" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_account_contact_relations_relation_role_concept_id" ON "crm"."account_contact_relations" ("relation_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_contact_relations_status_concept_id" ON "crm"."account_contact_relations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_contact_relations_created_by_user_id" ON "crm"."account_contact_relations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_account_contact_relations_updated_by_user_id" ON "crm"."account_contact_relations" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_account_team_members_crm_account_id_user_id_team_ro_099044e1" ON "crm"."account_team_members" ("crm_account_id", "user_id", "team_role_concept_id", "valid_from");

CREATE INDEX IF NOT EXISTS "ix_account_team_members_crm_account_id" ON "crm"."account_team_members" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_account_team_members_user_id" ON "crm"."account_team_members" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_account_team_members_team_role_concept_id" ON "crm"."account_team_members" ("team_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_team_members_access_level_concept_id" ON "crm"."account_team_members" ("access_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_team_members_status_concept_id" ON "crm"."account_team_members" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_account_team_members_created_by_user_id" ON "crm"."account_team_members" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_opportunity_contact_roles_opportunity_id_contact_id_06ce3ee3" ON "crm"."opportunity_contact_roles" ("opportunity_id", "contact_id", "role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_contact_roles_opportunity_id" ON "crm"."opportunity_contact_roles" ("opportunity_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_contact_roles_contact_id" ON "crm"."opportunity_contact_roles" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_contact_roles_role_concept_id" ON "crm"."opportunity_contact_roles" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_contact_roles_created_by_user_id" ON "crm"."opportunity_contact_roles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_contact_roles_updated_by_user_id" ON "crm"."opportunity_contact_roles" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_opportunity_line_items_opportunity_id_line_number" ON "crm"."opportunity_line_items" ("opportunity_id", "line_number");

CREATE INDEX IF NOT EXISTS "ix_opportunity_line_items_opportunity_id" ON "crm"."opportunity_line_items" ("opportunity_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_line_items_product_or_service_type_concept_id" ON "crm"."opportunity_line_items" ("product_or_service_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_line_items_currency_concept_id" ON "crm"."opportunity_line_items" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_line_items_contract_line_item_id" ON "crm"."opportunity_line_items" ("contract_line_item_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_line_items_status_concept_id" ON "crm"."opportunity_line_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_line_items_created_by_user_id" ON "crm"."opportunity_line_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_line_items_updated_by_user_id" ON "crm"."opportunity_line_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_stage_history_opportunity_id" ON "crm"."opportunity_stage_history" ("opportunity_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_stage_history_from_stage_id" ON "crm"."opportunity_stage_history" ("from_stage_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_stage_history_to_stage_id" ON "crm"."opportunity_stage_history" ("to_stage_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_stage_history_changed_by_user_id" ON "crm"."opportunity_stage_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_stage_history_reason_concept_id" ON "crm"."opportunity_stage_history" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunity_stage_history_opportunity_changed" ON "crm"."opportunity_stage_history" ("opportunity_id", "changed_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_opportunity_stage_history_created_at" ON "crm"."opportunity_stage_history" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_crm_activity_id" ON "crm"."crm_activity_relations" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_relation_kind_concept_id" ON "crm"."crm_activity_relations" ("relation_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_related_entity_type_concept_id" ON "crm"."crm_activity_relations" ("related_entity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_crm_account_id" ON "crm"."crm_activity_relations" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_contact_id" ON "crm"."crm_activity_relations" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_lead_id" ON "crm"."crm_activity_relations" ("lead_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_opportunity_id" ON "crm"."crm_activity_relations" ("opportunity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_partnership_id" ON "crm"."crm_activity_relations" ("partnership_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_contract_id" ON "crm"."crm_activity_relations" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_case_id" ON "crm"."crm_activity_relations" ("case_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_related_user_id" ON "crm"."crm_activity_relations" ("related_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_participant_role_concept_id" ON "crm"."crm_activity_relations" ("participant_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_response_status_concept_id" ON "crm"."crm_activity_relations" ("response_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_created_by_user_id" ON "crm"."crm_activity_relations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_activity_kind" ON "crm"."crm_activity_relations" ("crm_activity_id", "relation_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_account_activity" ON "crm"."crm_activity_relations" ("crm_account_id", "crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_contact_activity" ON "crm"."crm_activity_relations" ("contact_id", "crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_opportunity_activity" ON "crm"."crm_activity_relations" ("opportunity_id", "crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_relations_case_activity" ON "crm"."crm_activity_relations" ("case_id", "crm_activity_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_activity_assignments_crm_activity_id_assignee_u_669bd146" ON "crm"."crm_activity_assignments" ("crm_activity_id", "assignee_user_id", "assignment_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_assignments_crm_activity_id" ON "crm"."crm_activity_assignments" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_assignments_assignee_user_id" ON "crm"."crm_activity_assignments" ("assignee_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_assignments_assignment_role_concept_id" ON "crm"."crm_activity_assignments" ("assignment_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_assignments_status_concept_id" ON "crm"."crm_activity_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_assignments_created_by_user_id" ON "crm"."crm_activity_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_assignments_assignee_status_assigned" ON "crm"."crm_activity_assignments" ("assignee_user_id", "status_concept_id", "assigned_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_tasks_crm_activity_id" ON "crm"."crm_tasks" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_crm_activity_id" ON "crm"."crm_tasks" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_task_subtype_concept_id" ON "crm"."crm_tasks" ("task_subtype_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_priority_concept_id" ON "crm"."crm_tasks" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_recurrence_rule_id" ON "crm"."crm_tasks" ("recurrence_rule_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_status_concept_id" ON "crm"."crm_tasks" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_created_by_user_id" ON "crm"."crm_tasks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_updated_by_user_id" ON "crm"."crm_tasks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_tasks_status_due" ON "crm"."crm_tasks" ("status_concept_id", "due_date");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_events_crm_activity_id" ON "crm"."crm_events" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_crm_activity_id" ON "crm"."crm_events" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_event_subtype_concept_id" ON "crm"."crm_events" ("event_subtype_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_organizer_user_id" ON "crm"."crm_events" ("organizer_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_recurrence_rule_id" ON "crm"."crm_events" ("recurrence_rule_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_parent_event_id" ON "crm"."crm_events" ("parent_event_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_status_concept_id" ON "crm"."crm_events" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_created_by_user_id" ON "crm"."crm_events" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_updated_by_user_id" ON "crm"."crm_events" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_events_start_end" ON "crm"."crm_events" ("start_at", "end_at");

CREATE INDEX IF NOT EXISTS "ix_crm_recurrence_rules_tenant_id" ON "crm"."crm_recurrence_rules" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_crm_recurrence_rules_recurrence_frequency_concept_id" ON "crm"."crm_recurrence_rules" ("recurrence_frequency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_recurrence_rules_created_by_user_id" ON "crm"."crm_recurrence_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_recurrence_rules_updated_by_user_id" ON "crm"."crm_recurrence_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_recurrence_rules_tenant_until" ON "crm"."crm_recurrence_rules" ("tenant_id", "until_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_activity_reminders_crm_activity_id_recipient_us_595aad96" ON "crm"."crm_activity_reminders" ("crm_activity_id", "recipient_user_id", "remind_at");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_reminders_crm_activity_id" ON "crm"."crm_activity_reminders" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_reminders_recipient_user_id" ON "crm"."crm_activity_reminders" ("recipient_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_reminders_channel_concept_id" ON "crm"."crm_activity_reminders" ("channel_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_reminders_delivery_status_concept_id" ON "crm"."crm_activity_reminders" ("delivery_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_reminders_created_by_user_id" ON "crm"."crm_activity_reminders" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activity_reminders_delivery_remind" ON "crm"."crm_activity_reminders" ("delivery_status_concept_id", "remind_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_email_messages_crm_activity_id" ON "crm"."crm_email_messages" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_messages_crm_activity_id" ON "crm"."crm_email_messages" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_messages_body_html_file_id" ON "crm"."crm_email_messages" ("body_html_file_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_messages_delivery_status_concept_id" ON "crm"."crm_email_messages" ("delivery_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_messages_created_by_user_id" ON "crm"."crm_email_messages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_recipients_crm_email_message_id" ON "crm"."crm_email_recipients" ("crm_email_message_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_recipients_recipient_type_concept_id" ON "crm"."crm_email_recipients" ("recipient_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_recipients_contact_id" ON "crm"."crm_email_recipients" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_recipients_lead_id" ON "crm"."crm_email_recipients" ("lead_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_recipients_user_id" ON "crm"."crm_email_recipients" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_recipients_delivery_status_concept_id" ON "crm"."crm_email_recipients" ("delivery_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_email_recipients_message_type" ON "crm"."crm_email_recipients" ("crm_email_message_id", "recipient_type_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_call_logs_crm_activity_id" ON "crm"."crm_call_logs" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_call_logs_crm_activity_id" ON "crm"."crm_call_logs" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_call_logs_call_direction_concept_id" ON "crm"."crm_call_logs" ("call_direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_call_logs_outcome_concept_id" ON "crm"."crm_call_logs" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_call_logs_recording_file_id" ON "crm"."crm_call_logs" ("recording_file_id");

CREATE INDEX IF NOT EXISTS "ix_crm_call_logs_created_by_user_id" ON "crm"."crm_call_logs" ("created_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_notes_crm_activity_id" ON "crm"."crm_notes" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_notes_crm_activity_id" ON "crm"."crm_notes" ("crm_activity_id");

CREATE INDEX IF NOT EXISTS "ix_crm_notes_document_file_id" ON "crm"."crm_notes" ("document_file_id");

CREATE INDEX IF NOT EXISTS "ix_crm_notes_created_by_user_id" ON "crm"."crm_notes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_notes_updated_by_user_id" ON "crm"."crm_notes" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_cases_tenant_id_case_number" ON "crm"."crm_cases" ("tenant_id", "case_number");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_tenant_id" ON "crm"."crm_cases" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_crm_account_id" ON "crm"."crm_cases" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_primary_contact_id" ON "crm"."crm_cases" ("primary_contact_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_business_partner_id" ON "crm"."crm_cases" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_contract_id" ON "crm"."crm_cases" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_invoice_id" ON "crm"."crm_cases" ("invoice_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_case_type_concept_id" ON "crm"."crm_cases" ("case_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_origin_concept_id" ON "crm"."crm_cases" ("origin_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_priority_concept_id" ON "crm"."crm_cases" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_owner_user_id" ON "crm"."crm_cases" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_parent_case_id" ON "crm"."crm_cases" ("parent_case_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_status_concept_id" ON "crm"."crm_cases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_created_by_user_id" ON "crm"."crm_cases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_updated_by_user_id" ON "crm"."crm_cases" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_cases_tenant_status_priority_updated" ON "crm"."crm_cases" ("tenant_id", "status_concept_id", "priority_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_crm_cases_owner_status_updated" ON "crm"."crm_cases" ("owner_user_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_crm_cases_search" ON "crm"."crm_cases" USING gin (to_tsvector('simple', (coalesce(case_number, '') || ' ' || coalesce(subject, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_crm_case_contacts_crm_case_id_contact_id_role_concept_id" ON "crm"."crm_case_contacts" ("crm_case_id", "contact_id", "role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_contacts_crm_case_id" ON "crm"."crm_case_contacts" ("crm_case_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_contacts_contact_id" ON "crm"."crm_case_contacts" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_contacts_role_concept_id" ON "crm"."crm_case_contacts" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_contacts_created_by_user_id" ON "crm"."crm_case_contacts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_comments_crm_case_id" ON "crm"."crm_case_comments" ("crm_case_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_comments_author_user_id" ON "crm"."crm_case_comments" ("author_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_comments_attachment_file_id" ON "crm"."crm_case_comments" ("attachment_file_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_comments_case_created" ON "crm"."crm_case_comments" ("crm_case_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_crm_case_comments_created_at" ON "crm"."crm_case_comments" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_crm_case_status_history_crm_case_id" ON "crm"."crm_case_status_history" ("crm_case_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_status_history_from_status_concept_id" ON "crm"."crm_case_status_history" ("from_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_status_history_to_status_concept_id" ON "crm"."crm_case_status_history" ("to_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_status_history_changed_by_user_id" ON "crm"."crm_case_status_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_status_history_case_changed" ON "crm"."crm_case_status_history" ("crm_case_id", "changed_at" DESC);

CREATE INDEX IF NOT EXISTS "brin_crm_case_status_history_created_at" ON "crm"."crm_case_status_history" USING brin ("created_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_tenant_id" ON "crm"."crm_entitlements" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_crm_account_id" ON "crm"."crm_entitlements" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_business_partner_id" ON "crm"."crm_entitlements" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_contract_id" ON "crm"."crm_entitlements" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_entitlement_type_concept_id" ON "crm"."crm_entitlements" ("entitlement_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_status_concept_id" ON "crm"."crm_entitlements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_created_by_user_id" ON "crm"."crm_entitlements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_updated_by_user_id" ON "crm"."crm_entitlements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_entitlements_account_status_end" ON "crm"."crm_entitlements" ("crm_account_id", "status_concept_id", "end_date");

CREATE INDEX IF NOT EXISTS "gin_crm_entitlements_search" ON "crm"."crm_entitlements" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_crm_case_milestones_crm_case_id" ON "crm"."crm_case_milestones" ("crm_case_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_milestones_crm_entitlement_id" ON "crm"."crm_case_milestones" ("crm_entitlement_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_milestones_milestone_type_concept_id" ON "crm"."crm_case_milestones" ("milestone_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_milestones_status_concept_id" ON "crm"."crm_case_milestones" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_milestones_created_by_user_id" ON "crm"."crm_case_milestones" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_milestones_updated_by_user_id" ON "crm"."crm_case_milestones" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_case_milestones_status_target" ON "crm"."crm_case_milestones" ("status_concept_id", "target_at");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_tenant_id" ON "crm"."crm_accounts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_account_type_concept_id" ON "crm"."crm_accounts" ("account_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_industry_concept_id" ON "crm"."crm_accounts" ("industry_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_parent_account_id" ON "crm"."crm_accounts" ("parent_account_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_linked_tenant_id" ON "crm"."crm_accounts" ("linked_tenant_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_business_partner_id" ON "crm"."crm_accounts" ("business_partner_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_owner_user_id" ON "crm"."crm_accounts" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_currency_concept_id" ON "crm"."crm_accounts" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_status_concept_id" ON "crm"."crm_accounts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_created_by_user_id" ON "crm"."crm_accounts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_updated_by_user_id" ON "crm"."crm_accounts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_accounts_tenant_id_status_concept_id" ON "crm"."crm_accounts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_crm_accounts_search" ON "crm"."crm_accounts" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_contacts_tenant_id" ON "crm"."contacts" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_crm_account_id" ON "crm"."contacts" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_contact_type_concept_id" ON "crm"."contacts" ("contact_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_linked_user_id" ON "crm"."contacts" ("linked_user_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_owner_user_id" ON "crm"."contacts" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_lifecycle_stage_concept_id" ON "crm"."contacts" ("lifecycle_stage_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_source_concept_id" ON "crm"."contacts" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_marketing_consent_id" ON "crm"."contacts" ("marketing_consent_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_status_concept_id" ON "crm"."contacts" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_created_by_user_id" ON "crm"."contacts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_updated_by_user_id" ON "crm"."contacts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contacts_tenant_id_status_concept_id" ON "crm"."contacts" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_contact_channels_contact_id" ON "crm"."contact_channels" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channels_channel_type_concept_id" ON "crm"."contact_channels" ("channel_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channels_opt_in_status_concept_id" ON "crm"."contact_channels" ("opt_in_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channels_created_by_user_id" ON "crm"."contact_channels" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channels_updated_by_user_id" ON "crm"."contact_channels" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_leads_tenant_id" ON "crm"."leads" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_leads_lead_source_concept_id" ON "crm"."leads" ("lead_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_leads_contact_id" ON "crm"."leads" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_leads_crm_account_id" ON "crm"."leads" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_leads_lead_status_concept_id" ON "crm"."leads" ("lead_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_leads_owner_user_id" ON "crm"."leads" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_leads_converted_opportunity_id" ON "crm"."leads" ("converted_opportunity_id");

CREATE INDEX IF NOT EXISTS "ix_leads_status_concept_id" ON "crm"."leads" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_leads_created_by_user_id" ON "crm"."leads" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_leads_updated_by_user_id" ON "crm"."leads" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_leads_tenant_id_status_concept_id" ON "crm"."leads" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pipelines_code" ON "crm"."pipelines" ("code");

CREATE INDEX IF NOT EXISTS "ix_pipelines_tenant_id" ON "crm"."pipelines" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_pipelines_pipeline_type_concept_id" ON "crm"."pipelines" ("pipeline_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pipelines_state_concept_id" ON "crm"."pipelines" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_pipelines_created_by_user_id" ON "crm"."pipelines" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pipelines_updated_by_user_id" ON "crm"."pipelines" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pipelines_tenant_id_state_concept_id" ON "crm"."pipelines" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_pipelines_search" ON "crm"."pipelines" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_pipeline_stages_pipeline_id" ON "crm"."pipeline_stages" ("pipeline_id");

CREATE INDEX IF NOT EXISTS "ix_pipeline_stages_created_by_user_id" ON "crm"."pipeline_stages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_pipeline_stages_updated_by_user_id" ON "crm"."pipeline_stages" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_pipeline_stages_search" ON "crm"."pipeline_stages" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_opportunities_tenant_id" ON "crm"."opportunities" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_pipeline_id" ON "crm"."opportunities" ("pipeline_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_stage_id" ON "crm"."opportunities" ("stage_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_crm_account_id" ON "crm"."opportunities" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_primary_contact_id" ON "crm"."opportunities" ("primary_contact_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_currency_concept_id" ON "crm"."opportunities" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_owner_user_id" ON "crm"."opportunities" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_contract_id" ON "crm"."opportunities" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_sales_order_id" ON "crm"."opportunities" ("sales_order_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_lost_reason_concept_id" ON "crm"."opportunities" ("lost_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_status_concept_id" ON "crm"."opportunities" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_created_by_user_id" ON "crm"."opportunities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_updated_by_user_id" ON "crm"."opportunities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_opportunities_tenant_id_status_concept_id" ON "crm"."opportunities" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_opportunities_search" ON "crm"."opportunities" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_crm_activities_tenant_id" ON "crm"."crm_activities" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_activity_type_concept_id" ON "crm"."crm_activities" ("activity_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_subject_type_concept_id" ON "crm"."crm_activities" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_contact_id" ON "crm"."crm_activities" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_crm_account_id" ON "crm"."crm_activities" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_direction_concept_id" ON "crm"."crm_activities" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_outcome_concept_id" ON "crm"."crm_activities" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_owner_user_id" ON "crm"."crm_activities" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_status_concept_id" ON "crm"."crm_activities" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_created_by_user_id" ON "crm"."crm_activities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_updated_by_user_id" ON "crm"."crm_activities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_crm_activities_tenant_id_status_concept_id" ON "crm"."crm_activities" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_crm_activities_search" ON "crm"."crm_activities" USING gin (to_tsvector('simple', (coalesce(body_text, ''))));

CREATE INDEX IF NOT EXISTS "ix_partnerships_tenant_id" ON "crm"."partnerships" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_partnership_type_concept_id" ON "crm"."partnerships" ("partnership_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_crm_account_id" ON "crm"."partnerships" ("crm_account_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_ad_partner_id" ON "crm"."partnerships" ("ad_partner_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_contract_id" ON "crm"."partnerships" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_tier_concept_id" ON "crm"."partnerships" ("tier_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_owner_user_id" ON "crm"."partnerships" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_status_concept_id" ON "crm"."partnerships" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_created_by_user_id" ON "crm"."partnerships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_updated_by_user_id" ON "crm"."partnerships" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_partnerships_tenant_id_status_concept_id" ON "crm"."partnerships" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_partnerships_search" ON "crm"."partnerships" USING gin (to_tsvector('simple', (coalesce(name, ''))));

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_partnership_id" ON "crm"."partnership_agreements" ("partnership_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_agreement_type_concept_id" ON "crm"."partnership_agreements" ("agreement_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_contract_id" ON "crm"."partnership_agreements" ("contract_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_currency_concept_id" ON "crm"."partnership_agreements" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_document_file_id" ON "crm"."partnership_agreements" ("document_file_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_status_concept_id" ON "crm"."partnership_agreements" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_created_by_user_id" ON "crm"."partnership_agreements" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_partnership_agreements_updated_by_user_id" ON "crm"."partnership_agreements" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_partnership_agreements_effective_period" ON "crm"."partnership_agreements" USING gist (daterange(valid_from, valid_to, '[)'));

-- OMITIDO "uq_contact_channel_endpoints_endpoint_type_concept_id" (endpoint_type_concept_id, value_hash, tenant_scope_normalizado) btree: columna(s) ['tenant_scope_normalizado'] no existe(n) — requiere PostGIS/otro tipo.

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_tenant_id" ON "crm"."contact_channel_endpoints" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_contact_id" ON "crm"."contact_channel_endpoints" ("contact_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_lead_id" ON "crm"."contact_channel_endpoints" ("lead_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_user_id" ON "crm"."contact_channel_endpoints" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_endpoint_type_concept_id" ON "crm"."contact_channel_endpoints" ("endpoint_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_verification_status_concept_id" ON "crm"."contact_channel_endpoints" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_deliverability_status_concept_id" ON "crm"."contact_channel_endpoints" ("deliverability_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_state_concept_id" ON "crm"."contact_channel_endpoints" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_created_by_user_id" ON "crm"."contact_channel_endpoints" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_contact_channel_endpoints_updated_by_user_id" ON "crm"."contact_channel_endpoints" ("updated_by_user_id");
