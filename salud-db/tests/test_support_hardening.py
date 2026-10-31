#!/usr/bin/env python3
"""Contrato estático del endurecimiento v4.2.76 del personal de apoyo.

La verificación DINÁMICA (los rechazos reales de Postgres) vive en
`salud-db/demo/05-verifica-hospital-piloto.sql` y `06-verifica-hardening.sql`; este
archivo solo impide que el patch, el SQL generado y la demo vuelvan a divergir sin
base de datos a mano.
"""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[2]
PATCH = ROOT / "SQL" / "patches" / "2026-10-31_v4275_personal_apoyo.sql"
DEMO = ROOT / "salud-db" / "demo" / "04-hospital-piloto.sql"

# tabla → carpeta SQL del módulo que la genera
TENANT_TABLES = {
    ("delegated_access", "support_scope_grants"): "29_delegated_access",
    ("delegated_access", "support_grant_actions"): "29_delegated_access",
    ("delegated_access", "engagement_request_items"): "29_delegated_access",
    ("community", "conversation_assignments"): "19_community",
    ("community", "conversation_internal_notes"): "19_community",
    ("directory", "affiliation_invitation_uses"): "04_directory",
    ("practice", "practitioner_location_assignments"): "14_practice",
}


def create_table(sql: str, schema: str, table: str) -> str:
    m = re.search(
        rf'CREATE TABLE IF NOT EXISTS "{schema}"\."{table}" \(\n(.*?)\n\);', sql, re.S
    )
    assert m, f"{schema}.{table} no está"
    return m.group(1)


class SupportHardeningTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.patch = PATCH.read_text(encoding="utf-8")
        cls.demo = DEMO.read_text(encoding="utf-8")

    def test_tenant_id_not_null_in_patch_and_generated_sql(self) -> None:
        for (schema, table), folder in TENANT_TABLES.items():
            generated = (ROOT / "SQL" / folder / "02_tables.sql").read_text(encoding="utf-8")
            for origin, sql in (("patch", self.patch), ("SQL generado", generated)):
                body = create_table(sql, schema, table)
                self.assertIn('"tenant_id" uuid NOT NULL', body, f"{schema}.{table} en {origin}")
            self.assertIn(
                f'CREATE INDEX IF NOT EXISTS "ix_{table}_tenant_id"',
                generated + self.patch,
            )
            self.assertRegex(
                self.patch,
                rf'ALTER TABLE "{schema}"\."{table}"\n        ADD CONSTRAINT "fk_{table}_tenant_id" FOREIGN KEY \("tenant_id"\)\n        REFERENCES "directory"\."tenants" \("id"\)',
            )
            self.assertIn(f'trg_support_tenant_consistency ON "{schema}"."{table}"', self.patch)

    def test_every_function_pins_search_path_and_revokes_public(self) -> None:
        functions = re.findall(
            r'CREATE OR REPLACE FUNCTION ("[a-z_]+"\."[a-z_]+")\((.*?)\)\s*\nRETURNS', self.patch, re.S
        )
        self.assertEqual(len(functions), 4)
        for name, _args in functions:
            start = self.patch.index(f"CREATE OR REPLACE FUNCTION {name}(")
            header = self.patch[start : self.patch.index("AS $fn$", start)]
            self.assertIn("SET search_path = pg_catalog, pg_temp", header, name)
            self.assertNotIn("SECURITY DEFINER", header, name)
            self.assertRegex(self.patch, rf"REVOKE ALL ON FUNCTION {re.escape(name)}\(.*?\) FROM PUBLIC;")

    def test_allowed_gate_requires_acceptance_recertification_and_membership(self) -> None:
        start = self.patch.index('CREATE OR REPLACE FUNCTION "delegated_access"."support_access_allowed"')
        body = self.patch[start : self.patch.index("integrity.support_tenant_consistency()", start)]
        for needle in (
            '"accepted_at" IS NOT NULL',
            "interval '15 days'",
            '"practitioner_delegate_assignments"',
            "13ca1b46-61d5-5c25-9d49-8247bcd7769c",  # directory:MEMBERSHIP_ACTIVE
            '"end_date" IS NULL',
            "messages.reply_on_behalf",
            "may_reply_on_behalf",
        ):
            self.assertIn(needle, body)

    def test_partial_unique_indexes_exist_in_the_model_and_the_patch(self) -> None:
        names = {
            "uq_session_policies_active_tenant_scope": "01_iam",
            "uq_session_policies_active_tenant_scope_role": "01_iam",
            "uq_organization_user_assignments_active_template": "29_delegated_access",
            "uq_affiliation_invitation_uses_accepted": "04_directory",
            "uq_tenant_memberships_active_user_tenant": "04_directory",
        }
        for name, folder in names.items():
            generated = (ROOT / "SQL" / folder / "04_indexes.sql").read_text(encoding="utf-8")
            self.assertRegex(generated, rf'CREATE UNIQUE INDEX IF NOT EXISTS "{name}" .* WHERE ')
            self.assertIn(f"'{name}'", self.patch)
        generated = (ROOT / "SQL" / "01_iam" / "04_indexes.sql").read_text(encoding="utf-8")
        self.assertNotIn('"uq_session_policies_tenant_scope"', generated)

    def test_fixed_snapshot_check_rejects_empty_snapshots(self) -> None:
        sql = (ROOT / "SQL" / "29_delegated_access" / "05_constraints.sql").read_text(encoding="utf-8")
        m = re.search(r'ADD CONSTRAINT "ck_support_scope_grants_fixed_snapshot" CHECK \((.*)\);\n', sql)
        self.assertTrue(m)
        for needle in ("jsonb_array_length", "'rows'", "IS TRUE", "like_regex"):
            self.assertIn(needle, m.group(1))
        self.assertIn('ADD CONSTRAINT "ck_support_scope_grants_fixed_snapshot"', self.patch)

    def test_rls_block_covers_the_thirteen_tables(self) -> None:
        start = self.patch.index("-- ---- 7. RLS")
        block = self.patch[start:]
        pairs = re.findall(r"\('([a-z_]+)', '([a-z_]+)'\)", block)
        self.assertEqual(len(set(pairs)), 13)
        for schema, table in TENANT_TABLES:
            self.assertIn((schema, table), pairs)
        self.assertIn("FORCE ROW LEVEL SECURITY", block)
        self.assertIn("pg_policies WHERE policyname = 'tenant_isolation'", block)

    def test_demo_refuses_to_create_accounts_without_the_flag(self) -> None:
        begin = self.demo.index("BEGIN;")
        guard = self.demo.index("RAISE EXCEPTION 'hospital piloto (demo)")
        first_insert = self.demo.index("INSERT INTO")
        self.assertLess(begin, guard)
        self.assertLess(guard, first_insert)
        self.assertIn("demo_accounts", self.demo)
        self.assertIn("mantra.demo_accounts", self.demo)
        # cada fila nueva de las tablas con tenant_id lo trae
        for table in ("practice.practitioner_location_assignments", "delegated_access.support_scope_grants",
                      "delegated_access.support_grant_actions"):
            self.assertRegex(self.demo, rf"INSERT INTO {re.escape(table)} \(id, tenant_id, ")


if __name__ == "__main__":
    unittest.main()
