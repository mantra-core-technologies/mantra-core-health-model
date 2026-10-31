#!/usr/bin/env python3
"""Contrato estático del gobierno de accesos v4.2.78 (permisos ultra granulares + IGA).

La verificación DINÁMICA (los rechazos reales de Postgres, el DENY que nunca se materializa, el piloto
extendido) vive en `salud-db/demo/08-verifica-gobierno.sql`; este archivo impide que el parche, el SQL
generado, las semillas y los .puml vuelvan a divergir sin base de datos a mano.

Correr:  python -m unittest salud-db/tests/test_governance_v4278.py   (desde la raíz del repo del modelo)
"""

from pathlib import Path
import importlib.util
import re
import sys
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "salud-db"))
PATCH = ROOT / "SQL" / "patches" / "2026-10-31_v4278_gobierno_de_accesos.sql"
SQL29 = ROOT / "SQL" / "29_delegated_access"
SQL06 = ROOT / "SQL" / "06_authz"
PUML = ROOT / "Mantra Core Health Context" / "modules"
NS = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")

NEW_TABLES = [
    "governance_rules", "sod_rules", "sod_exceptions", "four_eyes_requests", "access_review_campaigns",
    "access_review_items", "lifecycle_cases", "handover_items", "patient_restriction_flags",
    "access_decision_log", "grant_usage_stats", "access_anomalies",
]
# tablas con tenant_id NOT NULL (sod_rules lo tiene anulable: NULL = plataforma)
TENANT_TABLES = [t for t in NEW_TABLES if t != "sod_rules"]
NEW_COLUMNS = {
    ("authz", "permissions"): ["sensitivity_concept_id", "requires_reason", "requires_step_up", "approval_mode_concept_id",
                               "purpose_of_use_concept_id", "legal_basis_concept_id", "touches_clinical_data",
                               "support_assignable"],
    ("delegated_access", "support_scope_grants"): ["effect_concept_id", "condition_json", "condition_schema_version",
                                                   "reason_text", "source_role_template_id"],
    ("delegated_access", "support_grant_actions"): ["condition_json", "condition_schema_version", "superseded_at",
                                                    "updated_at", "updated_by_user_id"],
    ("delegated_access", "role_templates"): ["default_conditions_json", "ceiling_actions_json"],
    ("delegated_access", "organization_user_assignments"): [
        "identity_verified_at", "identity_verified_by_user_id", "identity_method_concept_id", "suspended_at",
        "suspension_reason_concept_id", "suspension_note_text", "onboarding_completed_at", "last_certified_at",
        "last_active_at"],
}


def gen_seeds():
    spec = importlib.util.spec_from_file_location("gen_seeds_v4278", ROOT / "salud-db" / "gen_seeds.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def create_table(sql: str, schema: str, table: str) -> str:
    m = re.search(rf'CREATE TABLE IF NOT EXISTS "{schema}"\."{table}" \(\n(.*?)\n\);', sql, re.S)
    assert m, f"{schema}.{table} no está"
    return m.group(1)


class CatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gs = gen_seeds()

    def test_73_atoms_7_categories_and_counts_of_the_contract(self):
        gs = self.gs
        self.assertEqual(len(gs.GOV_ATOMS), 73)
        self.assertEqual(len(gs.GOV_CATEGORIES), 7)
        by_cat = {}
        for a in gs.GOV_ATOMS:
            by_cat[a["category"]] = by_cat.get(a["category"], 0) + 1
        self.assertEqual(by_cat, {"SUPPORT_AGENDA": 20, "SUPPORT_PATIENTS": 11, "SUPPORT_MESSAGING": 9,
                                  "SUPPORT_BILLING": 7, "SUPPORT_REPORTS": 4, "SUPPORT_TEAM": 17, "SUPPORT_AUDIT": 5})
        sens = {}
        for a in gs.GOV_ATOMS:
            sens[a["sensitivity"]] = sens.get(a["sensitivity"], 0) + 1
        self.assertEqual(sens, {"LOW": 11, "MEDIUM": 27, "HIGH": 29, "CRITICAL": 6})
        self.assertEqual(sum(1 for a in gs.GOV_ATOMS if a["requires_reason"]), 31)
        self.assertEqual(sum(1 for a in gs.GOV_ATOMS if a["requires_step_up"]), 14)
        self.assertEqual(sum(1 for a in gs.GOV_ATOMS if a["approval"] == "DOCTOR"), 3)
        self.assertEqual(sum(1 for a in gs.GOV_ATOMS if a["approval"] == "SECOND_APPROVER"), 7)
        self.assertEqual(sum(1 for a in gs.GOV_ATOMS if a["is_field_level"]), 8)
        self.assertEqual(sum(1 for a in gs.GOV_ATOMS if a["touches_clinical_data"]), 2)
        self.assertEqual(sum(1 for a in gs.GOV_ATOMS if not a["support_assignable"]), 4)
        # 24 átomos están en algún alias (cuadro de equivalencias del §2.3)
        in_alias = {c for atoms in gs.GOV_LEGACY.values() for c in atoms}
        self.assertEqual(len(in_alias), 24)

    def test_ids_are_the_deterministic_ones_of_annex_a(self):
        gs = self.gs
        self.assertEqual(gs.governance_permission_id("agenda.appointment.view"), "efeeea20-52a5-5973-a94a-37793ded463a")
        self.assertEqual(gs.governance_permission_id("audit.reports.governance.view"), "03936799-b89d-5879-9b6d-47851fb3ac15")
        self.assertEqual(gs.governance_permission_id("team.sessionpolicy.manage"), "48a8e7b7-2f29-5464-8348-288c123b26dd")
        self.assertEqual(gs.governance_category_id("SUPPORT_AGENDA"), "74102927-61f0-5416-adc3-6ca263a345f8")
        self.assertEqual(gs.governance_category_id("SUPPORT_AUDIT"), "4956a307-bc81-5b38-a8a5-4143cc416f5c")
        # el id de un código antiguo NO cambia
        self.assertEqual(gs.support_permission_id("schedule.view"), "438c578b-e5ea-5c58-86ed-fcf7da71780e")
        for a in gs.GOV_ATOMS:
            self.assertEqual(gs.governance_permission_id(a["code"]),
                             str(uuid.uuid5(NS, "seed:authz-permission:" + a["code"])))

    def test_legacy_aliases_expand_to_the_documented_atoms(self):
        gs = self.gs
        self.assertEqual(len(gs.GOV_LEGACY), 15)
        self.assertEqual(gs.GOV_LEGACY["schedule.view"], ["agenda.appointment.view", "agenda.appointment.view.patient_name"])
        self.assertEqual(gs.GOV_LEGACY["messages.reply_on_behalf"][1], "messages.conversation.reply_on_behalf")
        codes = {a["code"] for a in gs.GOV_ATOMS}
        for alias, atoms in gs.GOV_LEGACY.items():
            self.assertTrue(set(atoms) <= codes, alias)

    def test_default_packages_fit_their_ceiling(self):
        gs = self.gs
        sizes = {t: len(v) for t, v in gs.GOV_TEMPLATE_DEFAULTS.items()}
        self.assertEqual(sizes, {"SECRETARY": 20, "MEDICAL_ASSISTANT": 20, "NURSING": 7, "FRONT_DESK": 8,
                                 "BILLING_CASHIER": 5, "CALL_CENTER": 7, "ORG_MANAGEMENT": 21})
        for tpl, atoms in gs.GOV_TEMPLATE_DEFAULTS.items():
            self.assertTrue(set(atoms) <= set(gs.GOV_TEMPLATE_CEILINGS[tpl]), tpl)
        # R1: los cuatro team.* de seguridad no van a ninguna plantilla; edit_verified solo a ORG_MANAGEMENT
        for tpl, ceiling in gs.GOV_TEMPLATE_CEILINGS.items():
            for code in ("team.templates.manage", "team.guardrails.manage", "team.sod.manage", "team.sessionpolicy.manage"):
                self.assertNotIn(code, ceiling, tpl)
            if tpl != "ORG_MANAGEMENT":
                self.assertNotIn("patients.profile.edit_verified", ceiling, tpl)
        # R7: recepción, call center y caja nunca ven clínico
        for tpl in ("FRONT_DESK", "CALL_CENTER", "BILLING_CASHIER"):
            for code in ("agenda.appointment.view.reason", "patients.clinical.request_temporary_access"):
                self.assertNotIn(code, gs.GOV_TEMPLATE_CEILINGS[tpl], tpl)

    def test_11_platform_sod_rules(self):
        gs = self.gs
        rules = {r["code"]: r for r in gs.GOV_SOD_RULES}
        self.assertEqual(sorted(rules), ["SOD-AUD-01", "SOD-BILL-01", "SOD-BILL-02", "SOD-BILL-03", "SOD-BILL-04",
                                         "SOD-BILL-05", "SOD-GOV-01", "SOD-GOV-02", "SOD-GOV-03", "SOD-PAT-01",
                                         "SOD-PAT-02"])
        self.assertEqual(sum(1 for r in rules.values() if r["is_hard"]), 6)
        for r in rules.values():
            self.assertFalse(r["is_hard"] and r["max_exception_days"], r["code"])
        self.assertEqual(rules["SOD-BILL-03"]["action"], "REQUIRE_APPROVAL")
        self.assertEqual(rules["SOD-BILL-03"]["max_exception_days"], 90)
        self.assertEqual(rules["SOD-BILL-04"]["action"], "WARN")
        self.assertEqual(rules["SOD-BILL-05"]["scope"], "TRANSACTION")

    def test_92_concepts_with_the_ids_of_annex_b(self):
        gs = self.gs
        concepts = gs.GOVERNANCE_BACKEND_CONCEPTS
        self.assertEqual(len(concepts), 92)
        by_mod = {}
        for key, code, _ in concepts:
            self.assertEqual(key, code)
            by_mod[key.split(":")[0]] = by_mod.get(key.split(":")[0], 0) + 1
        self.assertEqual(by_mod, {"authz": 7, "audit": 1, "delegated_access": 84})
        self.assertEqual(gs.backend_id("authz:SENSITIVITY_LOW"), "2a5b8592-dcf4-5643-af29-609b689c5a96")
        self.assertEqual(gs.backend_id("delegated_access:FOUR_EYES_PENDING"), "a977935a-9073-5113-9644-7df96732e776")
        self.assertEqual(gs.backend_id("delegated_access:ANOMALY_ESCALATED"), "ec7ffd73-1272-5e63-b6ec-da5c5d45e334")


class SqlModelTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tables29 = (SQL29 / "02_tables.sql").read_text(encoding="utf-8")
        cls.tables06 = (SQL06 / "02_tables.sql").read_text(encoding="utf-8")
        cls.checks29 = (SQL29 / "05_constraints.sql").read_text(encoding="utf-8")
        cls.idx29 = (SQL29 / "04_indexes.sql").read_text(encoding="utf-8")

    def test_new_tables_exist_in_the_generated_ddl(self):
        for t in NEW_TABLES:
            create_table(self.tables29, "delegated_access", t)

    def test_tenant_id_is_the_second_column_and_not_null(self):
        for t in TENANT_TABLES:
            body = create_table(self.tables29, "delegated_access", t)
            cols = [ln.strip() for ln in body.splitlines()]
            self.assertTrue(cols[0].startswith('"id" uuid NOT NULL'), t)
            self.assertTrue(cols[1].startswith('"tenant_id" uuid NOT NULL'), t)
        body = create_table(self.tables29, "delegated_access", "sod_rules")
        self.assertIn('"tenant_id" uuid,', body)          # NULL = plataforma

    def test_new_columns_on_existing_tables(self):
        for (schema, table), cols in NEW_COLUMNS.items():
            sql = self.tables06 if schema == "authz" else self.tables29
            body = create_table(sql, schema, table)
            for c in cols:
                self.assertIn(f'"{c}" ', body, f"{schema}.{table}.{c}")

    def test_defaults_of_the_contract(self):
        grants = create_table(self.tables29, "delegated_access", "support_scope_grants")
        self.assertIn("\"effect_concept_id\" uuid NOT NULL DEFAULT '6905e0db-1650-5d49-adca-8b2688ac049c'", grants)
        camp = create_table(self.tables29, "delegated_access", "access_review_campaigns")
        self.assertIn('"grace_days" integer NOT NULL DEFAULT 7', camp)
        self.assertIn('"escalate_after_days" integer NOT NULL DEFAULT 3', camp)
        self.assertIn("\"reminder_days_before_json\" jsonb NOT NULL DEFAULT '[7,3,1]'", camp)
        items = create_table(self.tables29, "delegated_access", "access_review_items")
        self.assertIn("\"decision_concept_id\" uuid NOT NULL DEFAULT '55a6db07-19e7-5bb4-978a-3d246492f49d'", items)
        self.assertIn('"reminder_count" integer NOT NULL DEFAULT 0', items)
        perms = create_table(self.tables06, "authz", "permissions")
        self.assertIn('"requires_reason" boolean NOT NULL DEFAULT false', perms)
        self.assertIn('"support_assignable" boolean NOT NULL DEFAULT false', perms)

    def test_worm_tables_have_no_updated_at_nor_row_version(self):
        body = create_table(self.tables29, "delegated_access", "access_decision_log")
        self.assertIn('"recorded_at" timestamptz NOT NULL', body)
        self.assertNotIn('"updated_at"', body)
        self.assertNotIn('"row_version"', body)
        self.assertIn('REVOKE UPDATE, DELETE ON "delegated_access"."access_decision_log" FROM PUBLIC', self.checks29)
        self.assertIn('CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "delegated_access"."access_decision_log"',
                      self.checks29)

    def test_check_constraints_of_the_contract(self):
        for name in ("ck_four_eyes_requests_not_self", "ck_four_eyes_requests_hash", "ck_four_eyes_requests_expiry",
                     "ck_four_eyes_requests_decision", "ck_four_eyes_requests_reject_comment",
                     "ck_sod_exceptions_period", "ck_sod_exceptions_justification", "ck_sod_rules_sets",
                     "ck_sod_rules_exception_days", "ck_sod_rules_hard_no_exception", "ck_sod_rules_version_number",
                     "ck_governance_rules_pattern", "ck_governance_rules_kind_shape", "ck_governance_rules_valid_period",
                     "ck_access_review_campaigns_grace", "ck_access_review_campaigns_escalate",
                     "ck_access_review_campaigns_reminders", "ck_access_review_campaigns_due",
                     "ck_access_review_items_decided", "ck_access_review_items_comment", "ck_access_review_items_hash",
                     "ck_lifecycle_cases_checklist", "ck_lifecycle_cases_completed", "ck_handover_items_reassigned",
                     "ck_handover_items_not_self", "ck_patient_restriction_flags_reason", "ck_grant_usage_stats_counts",
                     "ck_access_anomalies_window", "ck_access_anomalies_dismiss_comment",
                     "ck_support_scope_grants_effect_valid", "ck_support_scope_grants_condition",
                     "ck_support_grant_actions_condition", "ck_role_templates_ceiling_array",
                     "ck_permissions_approval_needs_sensitivity"):
            self.assertIn(f'"{name}"', self.checks29 + (SQL06 / "05_constraints.sql").read_text(encoding="utf-8"), name)

    def test_partial_unique_indexes_of_the_contract(self):
        for name in ("uq_governance_rules_active", "uq_sod_rules_platform_code_version", "uq_sod_rules_tenant_code_version",
                     "uq_sod_exceptions_active", "uq_four_eyes_requests_pending_payload",
                     "uq_access_review_campaigns_recert_month", "uq_access_review_items_campaign_grant",
                     "uq_lifecycle_cases_open_joiner", "uq_handover_items_case_source",
                     "uq_patient_restriction_flags_active", "uq_grant_usage_stats_bucket", "uq_access_anomalies_window"):
            self.assertIn(f'"{name}"', self.idx29, name)
        self.assertIn('"ix_permissions_support_assignable"', (SQL06 / "04_indexes.sql").read_text(encoding="utf-8"))

    def test_no_cascade_in_the_new_foreign_keys(self):
        for f in ("03_fk_intra.sql", "90_fk_deferred.sql"):
            sql = (SQL29 / f).read_text(encoding="utf-8")
            for t in NEW_TABLES:
                for m in re.finditer(rf'ALTER TABLE "delegated_access"\."{t}"\n.*?;', sql, re.S):
                    self.assertNotIn("CASCADE", m.group(0), t)


class PatchTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.patch = PATCH.read_text(encoding="utf-8")
        cls.fn_names = re.findall(r'CREATE OR REPLACE FUNCTION ("[a-z_]+"\."[a-z_]+")\(', cls.patch)

    def test_single_transaction_and_idempotent_forms(self):
        self.assertEqual(len(re.findall(r"^BEGIN;$", self.patch, re.M)), 1)
        self.assertEqual(len(re.findall(r"^COMMIT;$", self.patch, re.M)), 1)
        self.assertNotRegex(self.patch, r"(?m)^CREATE TABLE (?!IF NOT EXISTS)")
        self.assertNotRegex(self.patch, r"(?m)^CREATE (UNIQUE )?INDEX (?!IF NOT EXISTS)")
        self.assertNotRegex(self.patch, r"ON DELETE CASCADE")

    def test_creates_the_12_tables_and_the_columns(self):
        for t in NEW_TABLES:
            self.assertIn(f'CREATE TABLE IF NOT EXISTS "delegated_access"."{t}"', self.patch, t)
        for (schema, table), cols in NEW_COLUMNS.items():
            for c in cols:
                self.assertRegex(self.patch, rf'ALTER TABLE "{schema}"\."{table}"\s+ADD COLUMN IF NOT EXISTS "{c}"', f"{table}.{c}")

    def test_every_function_pins_search_path_and_revokes_public(self):
        fns = set(self.fn_names)
        for expected in ('"delegated_access"."refresh_effective_support_access"', '"integrity"."support_tenant_consistency"',
                         '"integrity"."access_review_reviewer_not_subject"', '"integrity"."sod_rules_only_stricter"'):
            self.assertIn(expected, fns)
        for m in re.finditer(r'CREATE OR REPLACE FUNCTION ("[a-z_]+"\."[a-z_]+")\((.*?)\$fn\$;', self.patch, re.S):
            self.assertIn("SET search_path = pg_catalog, pg_temp", m.group(0), m.group(1))
            self.assertNotIn("SECURITY DEFINER", m.group(0), m.group(1))
            self.assertRegex(self.patch, rf'REVOKE ALL ON FUNCTION {re.escape(m.group(1))}\(', m.group(1))

    def test_refresh_excludes_deny_and_superseded_actions(self):
        m = re.search(r'CREATE OR REPLACE FUNCTION "delegated_access"\."refresh_effective_support_access"\(.*?\$fn\$;', self.patch, re.S)
        self.assertIsNotNone(m)
        body = m.group(0)
        self.assertIn("g.\"effect_concept_id\" = '6905e0db-1650-5d49-adca-8b2688ac049c'", body)
        self.assertIn("sga.\"superseded_at\" IS NULL", body)

    def test_four_eyes_self_approval_is_a_check_violation_not_only_a_service_rule(self):
        # 23514 = check_violation: el CHECK de la tabla, no un disparador ni la API
        generated = (SQL29 / "05_constraints.sql").read_text(encoding="utf-8")
        self.assertIn('ADD CONSTRAINT "ck_four_eyes_requests_not_self" CHECK', generated)
        self.assertIn('ADD CONSTRAINT "ck_four_eyes_requests_not_self" CHECK', self.patch)

    def test_seeds_inside_the_patch(self):
        gs = gen_seeds()
        for code, _ in gs.GOV_CATEGORIES:
            self.assertIn(gs.governance_category_id(code), self.patch, code)
        for a in gs.GOV_ATOMS:
            self.assertIn(gs.governance_permission_id(a["code"]), self.patch, a["code"])
        for r in gs.GOV_SOD_RULES:
            self.assertIn(r["code"], self.patch)
        for key, _, _ in gs.GOVERNANCE_BACKEND_CONCEPTS:
            self.assertIn(gs.backend_id(key), self.patch, key)

    def test_rls_block_covers_the_new_tables(self):
        for t in TENANT_TABLES:
            self.assertRegex(self.patch, rf"\('delegated_access', '{t}'\)", t)
        self.assertIn('CREATE POLICY global_catalog_read ON "delegated_access"."sod_rules"', self.patch)


    def test_existing_bonds_are_completed_by_the_patch_d03(self):
        # D-03 (pendiente B4c #10): los vínculos existentes quedan COMPLETOS; sin caso de ingreso (JOINER) y con onboarding_completed_at nulo;
        # idempotente (un vínculo en curso, con su caso abierto o cancelado, nunca se completa de rebote)
        m = re.search(r"-- ---- 7b\..*?\$legacy_onboarding\$;", self.patch, re.S)
        self.assertIsNotNone(m, "falta la sección 7b del parche")
        sec = m.group(0)
        self.assertIn("SET onboarding_completed_at = a.created_at", sec)
        self.assertIn("a.onboarding_completed_at IS NULL", sec)
        self.assertIn("NOT EXISTS (SELECT 1 FROM delegated_access.lifecycle_cases lc", sec)
        self.assertIn(gen_seeds().backend_id("delegated_access:LIFECYCLE_JOINER"), sec)
        # corre con el contexto de sistema de la transacción (RLS FORCE) y lo devuelve
        self.assertIn("set_config('app.system_context', 'true', true)", sec)
        self.assertIn("set_config('app.system_context', v_prev, true)", sec)
        # antes de las funciones y de RLS, y dentro de la única transacción
        self.assertLess(self.patch.index("-- ---- 7b."), self.patch.index("-- ---- 8."))

class DemoPilotCorrectionsTests(unittest.TestCase):
    """Las 4 correcciones del demo (B7d) que la API necesita; el contrato dinámico es 08 (G-9y1…4) y 10 (V1b)."""

    DEMO = ROOT / "salud-db" / "demo"

    def read(self, name):
        return (self.DEMO / name).read_text(encoding="utf-8")

    def test_agendas_name_the_profile_table_the_api_recognises(self):
        for name in ("07-gobierno-hospital-piloto.sql", "09-agenda-chat-piloto.sql"):
            with self.subTest(name=name):
                sql = self.read(name)
                inserts = re.findall(r"'a1df879c-4ac6-5a7e-8548-bc04207e92fa', '([a-z_.]+)'", sql)
                self.assertGreaterEqual(len(inserts), 5)
                self.assertEqual(set(inserts), {"health_practitioner_profiles"})

    def test_a4_lives_in_n102_not_b102(self):
        sql = self.read("07-gobierno-hospital-piloto.sql")
        n102, b102 = "709a4334-ae78-569c-bc24-755f2be12403", "b8b695a4-36ef-59d1-976a-372df6c8e3e1"
        for row in ("('0733038f-f61e-57a5-9e39-78e54404b14d'", "('02d06e6c-3f9f-5a58-bc4c-362aeb6c6861'"):
            line = next(l for l in sql.splitlines() if l.lstrip().startswith(row))
            self.assertIn(n102, line)
            self.assertNotIn(b102, line)

    def test_nora_is_after_the_gate_and_ana_expires_on_2026_11_23(self):
        sql = self.read("07-gobierno-hospital-piloto.sql")
        nora = next(l for l in sql.splitlines() if l.lstrip().startswith("('de0204d4-f9d7-5394-8ba3-45e92b46b610', '8d99d949"))
        self.assertIn("timestamptz '2026-11-03 08:00:00-04', now(), 1,", nora)
        self.assertIn('"onboardingRequiredSince": "2026-11-02T00:00:00Z"', sql)
        self.assertIn("next_recertification_at = timestamptz '2026-11-23 10:00:00-04'", sql)

    def test_the_loopback_network_rule_is_not_in_the_demo(self):
        for name in ("04-hospital-piloto.sql", "07-gobierno-hospital-piloto.sql", "09-agenda-chat-piloto.sql"):
            with self.subTest(name=name):
                self.assertNotIn("127.0.0.0/8", self.read(name))


class GeneratorTests(unittest.TestCase):
    def test_gen_ddl_accepts_numeric_uuid_and_json_defaults(self):
        import gen_ddl
        self.assertEqual(gen_ddl.declared_default("integer", "<<DEFAULT_INT:7>>"), "7")
        self.assertEqual(gen_ddl.declared_default("uuid", "<<FK, DEFAULT_UUID:6905e0db-1650-5d49-adca-8b2688ac049c>>"),
                         "'6905e0db-1650-5d49-adca-8b2688ac049c'")
        self.assertEqual(gen_ddl.declared_default("jsonb", "<<DEFAULT_JSON_INTS:7_3_1>>"), "'[7,3,1]'")
        for dtype, raw in [("varchar", "<<DEFAULT_INT:7>>"), ("integer", "<<DEFAULT_INT:7x>>"),
                           ("uuid", "<<DEFAULT_UUID:not-a-uuid>>"), ("jsonb", "<<DEFAULT_JSON_INTS:a_b>>"),
                           ("integer", "<<DEFAULT_INT:1, DEFAULT_INT:2>>")]:
            with self.subTest(dtype=dtype, raw=raw), self.assertRaises(ValueError):
                gen_ddl.declared_default(dtype, raw)


if __name__ == "__main__":
    unittest.main()
