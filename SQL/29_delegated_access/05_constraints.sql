-- SALUD v4.2.79 · schema delegated_access · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ practitioner_delegate_assignments ═══
--   EXCLUDE: incompatible overlapping assignments  (en prosa; el módulo 33 no declara su expresión SQL)
--   CHECK: signature permission requires authorized role  (en prosa; el módulo 33 no declara su expresión SQL)

-- ═══ organization_user_assignments ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ck_org_user_assignments_scope_target";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ck_org_user_assignments_scope_target" CHECK (("access_scope_concept_id" <> '928c884d-ff91-584c-8aa6-68535085e078' OR "clinical_unit_id" IS NOT NULL) AND ("access_scope_concept_id" <> '4df1a147-cb37-55ba-94e8-ab469e9cccb0' OR "care_space_id" IS NOT NULL) AND ("access_scope_concept_id" <> 'e69a4c95-fe59-5c3e-b826-222af123adb9' OR "practice_site_id" IS NOT NULL));

-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ex_org_user_assignments_unit_head";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ex_org_user_assignments_unit_head"
    EXCLUDE USING gist ("clinical_unit_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH &&) WHERE ("assignment_role_concept_id" = 'ce54425b-5479-57f1-8bb2-274a8617723c' AND "status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19');


-- ═══ shared_access_link_uses ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "delegated_access"."shared_access_link_uses" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "delegated_access"."shared_access_link_uses";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "delegated_access"."shared_access_link_uses"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ support_scope_grants ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_target_coherent";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_target_coherent" CHECK (("target_kind_concept_id" = '785d1671-5754-58d3-b1a3-e3cd467b82b7' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '953e4408-5e19-521b-a25a-3d062d788911' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '10510d38-c6cf-5243-9327-5cefc6c3aee5' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '19ff6b5b-b998-54bb-af93-573b96764a6c' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '81f2ac43-a9ba-5043-b455-ed71b2d7e59f' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '3df7a566-22b8-512d-85a7-4b89604cb26b' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'cf4de420-16da-57f8-8c3a-f6ff717fc59e' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'b1330928-a076-5348-bffd-154144fadc85' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_valid_period";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_valid_period" CHECK (("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_fixed_snapshot";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_fixed_snapshot" CHECK (("expansion_mode_concept_id" <> '4f47115f-54ad-564f-bcd4-f06a0a0c13cd' OR (jsonb_typeof("fixed_snapshot_json" -> 'rows') = 'array' AND jsonb_array_length("fixed_snapshot_json" -> 'rows') > 0 AND NOT jsonb_path_exists("fixed_snapshot_json", '$.rows[*] ? (@.type() != "object" || exists(@.keyvalue() ? (@.key != "practitionerRoleAssignmentId" && @.key != "practitionerProfileId" && @.key != "healthcareServiceId" && @.key != "careSpaceId" || @.value.type() != "null" && !(@.value.type() == "string" && @.value like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$"))) || !(exists(@.practitionerRoleAssignmentId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$")) || exists(@.healthcareServiceId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$")) || exists(@.careSpaceId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$"))))')) IS TRUE));


-- ═══ engagement_request_items ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."engagement_request_items" DROP CONSTRAINT IF EXISTS "ck_engagement_request_items_target_coherent";
ALTER TABLE "delegated_access"."engagement_request_items" ADD CONSTRAINT "ck_engagement_request_items_target_coherent" CHECK (("target_kind_concept_id" = '785d1671-5754-58d3-b1a3-e3cd467b82b7' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '953e4408-5e19-521b-a25a-3d062d788911' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '10510d38-c6cf-5243-9327-5cefc6c3aee5' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '19ff6b5b-b998-54bb-af93-573b96764a6c' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '81f2ac43-a9ba-5043-b455-ed71b2d7e59f' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '3df7a566-22b8-512d-85a7-4b89604cb26b' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'cf4de420-16da-57f8-8c3a-f6ff717fc59e' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'b1330928-a076-5348-bffd-154144fadc85' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL));


-- ═══ engagement_requests ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."engagement_requests" DROP CONSTRAINT IF EXISTS "ck_engagement_requests_expires_after_created";
ALTER TABLE "delegated_access"."engagement_requests" ADD CONSTRAINT "ck_engagement_requests_expires_after_created" CHECK ("expires_at" > "created_at");


-- ═══ role_templates ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."role_templates" DROP CONSTRAINT IF EXISTS "ck_role_templates_version_number";
ALTER TABLE "delegated_access"."role_templates" ADD CONSTRAINT "ck_role_templates_version_number" CHECK ("version_number" >= 1);


-- ═══ organization_user_assignments ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ck_organization_user_assignments_recertify_months";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ck_organization_user_assignments_recertify_months" CHECK (("recertify_every_months" IS NULL OR "recertify_every_months" IN (6, 12)));


-- ═══ support_scope_grants ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_effect_valid";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_effect_valid" CHECK (("effect_concept_id" IN ('6905e0db-1650-5d49-adca-8b2688ac049c', 'b038e546-a6ba-5848-9cd2-04b02ccb22b0')));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_condition";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_condition" CHECK ((("condition_json" IS NULL AND "condition_schema_version" IS NULL) OR (jsonb_typeof("condition_json") = 'object' AND "condition_schema_version" IS NOT NULL AND ("condition_json" ->> 'schemaVersion') = ("condition_schema_version")::text AND octet_length("condition_json"::text) <= 8192)));


-- ═══ support_grant_actions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_grant_actions" DROP CONSTRAINT IF EXISTS "ck_support_grant_actions_condition";
ALTER TABLE "delegated_access"."support_grant_actions" ADD CONSTRAINT "ck_support_grant_actions_condition" CHECK ((("condition_json" IS NULL AND "condition_schema_version" IS NULL) OR (jsonb_typeof("condition_json") = 'object' AND "condition_schema_version" IS NOT NULL AND ("condition_json" ->> 'schemaVersion') = ("condition_schema_version")::text AND octet_length("condition_json"::text) <= 8192)));


-- ═══ role_templates ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."role_templates" DROP CONSTRAINT IF EXISTS "ck_role_templates_ceiling_array";
ALTER TABLE "delegated_access"."role_templates" ADD CONSTRAINT "ck_role_templates_ceiling_array" CHECK (("ceiling_actions_json" IS NULL OR jsonb_typeof("ceiling_actions_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."role_templates" DROP CONSTRAINT IF EXISTS "ck_role_templates_default_conditions_object";
ALTER TABLE "delegated_access"."role_templates" ADD CONSTRAINT "ck_role_templates_default_conditions_object" CHECK (("default_conditions_json" IS NULL OR jsonb_typeof("default_conditions_json") = 'object'));


-- ═══ governance_rules ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."governance_rules" DROP CONSTRAINT IF EXISTS "ck_governance_rules_pattern";
ALTER TABLE "delegated_access"."governance_rules" ADD CONSTRAINT "ck_governance_rules_pattern" CHECK (("permission_pattern" ~ '^([a-z_]+(\.[a-z_]+){2,3}|[a-z_]+(\.[a-z_]+){0,2}\.\*)$'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."governance_rules" DROP CONSTRAINT IF EXISTS "ck_governance_rules_kind_shape";
ALTER TABLE "delegated_access"."governance_rules" ADD CONSTRAINT "ck_governance_rules_kind_shape" CHECK ((("rule_kind_concept_id" <> 'ce906685-7a58-54e7-b4d2-458062c0c303' OR "role_template_code" IS NOT NULL) AND ("rule_kind_concept_id" <> '1b6db045-2cc5-5985-9c89-18b8ac0969be' OR COALESCE("rule_json" ? 'condition', false)) AND ("rule_kind_concept_id" <> 'f2534b4a-a8cc-5fb1-a431-30e1a750274b' OR COALESCE("rule_json" ->> 'maxVisibility' IN ('PARTIAL', 'REDACT', 'NULLIFY'), false))));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."governance_rules" DROP CONSTRAINT IF EXISTS "ck_governance_rules_valid_period";
ALTER TABLE "delegated_access"."governance_rules" ADD CONSTRAINT "ck_governance_rules_valid_period" CHECK (("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to"));


-- ═══ sod_rules ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_sets";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_sets" CHECK ((jsonb_typeof("atoms_a_json") = 'array' AND jsonb_typeof("atoms_b_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_exception_days";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_exception_days" CHECK (("max_exception_days" IS NULL OR "max_exception_days" BETWEEN 1 AND 180));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_hard_no_exception";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_hard_no_exception" CHECK ((NOT ("is_hard" AND "max_exception_days" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_version_number";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_version_number" CHECK (("version_number" >= 1));


-- ═══ sod_exceptions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_exceptions" DROP CONSTRAINT IF EXISTS "ck_sod_exceptions_period";
ALTER TABLE "delegated_access"."sod_exceptions" ADD CONSTRAINT "ck_sod_exceptions_period" CHECK (("valid_to" > "valid_from" AND "valid_to" <= "valid_from" + interval '180 days'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_exceptions" DROP CONSTRAINT IF EXISTS "ck_sod_exceptions_justification";
ALTER TABLE "delegated_access"."sod_exceptions" ADD CONSTRAINT "ck_sod_exceptions_justification" CHECK ((char_length("justification_text") >= 30));


-- ═══ four_eyes_requests ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_not_self";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_not_self" CHECK (("decided_by_user_id" IS NULL OR ("decided_by_user_id" <> "requester_user_id" AND ("subject_user_id" IS NULL OR "decided_by_user_id" <> "subject_user_id"))));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_hash";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_hash" CHECK (("payload_hash" ~ '^[0-9a-f]{64}$'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_expiry";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_expiry" CHECK (("expires_at" > "created_at"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_decision";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_decision" CHECK ((("status_concept_id" <> 'a977935a-9073-5113-9644-7df96732e776' OR ("decided_at" IS NULL AND "decided_by_user_id" IS NULL)) AND ("status_concept_id" NOT IN ('1627143e-d273-5fcb-b289-9e59b8b096f2', 'de15c53d-1aa0-5709-8ebd-69e9fd323e31', '013d578f-38af-564c-aff1-e36d1fdec6dd') OR ("decided_at" IS NOT NULL AND "decided_by_user_id" IS NOT NULL))));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_reject_comment";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_reject_comment" CHECK (("status_concept_id" <> 'de15c53d-1aa0-5709-8ebd-69e9fd323e31' OR COALESCE(char_length("decision_comment_text"), 0) >= 5));


-- ═══ access_review_campaigns ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_grace";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_grace" CHECK (("grace_days" BETWEEN 0 AND 30));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_escalate";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_escalate" CHECK (("escalate_after_days" BETWEEN 1 AND 30));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_reminders";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_reminders" CHECK ((jsonb_typeof("reminder_days_before_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_due";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_due" CHECK (("launched_at" IS NULL OR "due_at" > "launched_at"));


-- ═══ access_review_items ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_items" DROP CONSTRAINT IF EXISTS "ck_access_review_items_decided";
ALTER TABLE "delegated_access"."access_review_items" ADD CONSTRAINT "ck_access_review_items_decided" CHECK ((("decision_concept_id" = '55a6db07-19e7-5bb4-978a-3d246492f49d' AND "decided_at" IS NULL) OR ("decision_concept_id" <> '55a6db07-19e7-5bb4-978a-3d246492f49d' AND "decided_at" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_items" DROP CONSTRAINT IF EXISTS "ck_access_review_items_comment";
ALTER TABLE "delegated_access"."access_review_items" ADD CONSTRAINT "ck_access_review_items_comment" CHECK (("decision_concept_id" NOT IN ('bce72e9a-b3bb-5fab-8e79-85d411ba692c', '26f790b1-6d77-5286-89d5-0e82a4dcfb81') OR COALESCE(char_length("decision_comment_text"), 0) >= 10));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_items" DROP CONSTRAINT IF EXISTS "ck_access_review_items_hash";
ALTER TABLE "delegated_access"."access_review_items" ADD CONSTRAINT "ck_access_review_items_hash" CHECK (("evidence_hash" ~ '^[0-9a-f]{64}$'));


-- ═══ lifecycle_cases ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."lifecycle_cases" DROP CONSTRAINT IF EXISTS "ck_lifecycle_cases_checklist";
ALTER TABLE "delegated_access"."lifecycle_cases" ADD CONSTRAINT "ck_lifecycle_cases_checklist" CHECK ((jsonb_typeof("checklist_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."lifecycle_cases" DROP CONSTRAINT IF EXISTS "ck_lifecycle_cases_completed";
ALTER TABLE "delegated_access"."lifecycle_cases" ADD CONSTRAINT "ck_lifecycle_cases_completed" CHECK (("status_concept_id" <> '4734035e-72cf-519f-8e27-e6cf25ba557f' OR "completed_at" IS NOT NULL));


-- ═══ handover_items ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."handover_items" DROP CONSTRAINT IF EXISTS "ck_handover_items_reassigned";
ALTER TABLE "delegated_access"."handover_items" ADD CONSTRAINT "ck_handover_items_reassigned" CHECK (("status_concept_id" <> '57d9c373-5a94-5fd6-bf9c-bd6a95cb2a91' OR ("to_user_id" IS NOT NULL AND "reassigned_at" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."handover_items" DROP CONSTRAINT IF EXISTS "ck_handover_items_not_self";
ALTER TABLE "delegated_access"."handover_items" ADD CONSTRAINT "ck_handover_items_not_self" CHECK (("to_user_id" IS NULL OR "to_user_id" <> "from_user_id"));


-- ═══ patient_restriction_flags ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."patient_restriction_flags" DROP CONSTRAINT IF EXISTS "ck_patient_restriction_flags_reason";
ALTER TABLE "delegated_access"."patient_restriction_flags" ADD CONSTRAINT "ck_patient_restriction_flags_reason" CHECK ((char_length("reason_text") >= 10));


-- ═══ access_decision_log ═══
--   UPDATE_DELETE: forbidden
--   TRUNCATE: forbidden
-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "delegated_access"."access_decision_log" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "delegated_access"."access_decision_log";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "delegated_access"."access_decision_log"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- TRUNCATE: forbidden → barrera física (append-only)
REVOKE TRUNCATE ON "delegated_access"."access_decision_log" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_truncate ON "delegated_access"."access_decision_log";
CREATE TRIGGER trg_forbid_truncate BEFORE TRUNCATE ON "delegated_access"."access_decision_log"
    FOR EACH STATEMENT EXECUTE FUNCTION "integrity"."forbid_truncate"();


-- ═══ grant_usage_stats ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."grant_usage_stats" DROP CONSTRAINT IF EXISTS "ck_grant_usage_stats_counts";
ALTER TABLE "delegated_access"."grant_usage_stats" ADD CONSTRAINT "ck_grant_usage_stats_counts" CHECK (("permit_count" >= 0 AND "deny_count" >= 0 AND "challenge_count" >= 0 AND "off_hours_count" >= 0 AND "distinct_patients_in_bucket" >= 0));


-- ═══ access_anomalies ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_anomalies" DROP CONSTRAINT IF EXISTS "ck_access_anomalies_window";
ALTER TABLE "delegated_access"."access_anomalies" ADD CONSTRAINT "ck_access_anomalies_window" CHECK (("window_end" > "window_start"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_anomalies" DROP CONSTRAINT IF EXISTS "ck_access_anomalies_dismiss_comment";
ALTER TABLE "delegated_access"."access_anomalies" ADD CONSTRAINT "ck_access_anomalies_dismiss_comment" CHECK (("status_concept_id" <> '1c8f5b91-371b-5967-b8fd-98d08f80ac9c' OR COALESCE(char_length("resolution_comment_text"), 0) >= 10));
