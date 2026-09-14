"""Contrato de seguridad del patch RLS independiente del nombre del owner."""

from pathlib import Path
import re
import unittest


PATCH = (
    Path(__file__).resolve().parents[1]
    / "SQL"
    / "patches"
    / "2026-08-05_tenant_rls.sql"
)


class TenantRlsPatchContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")

    def test_default_privileges_follow_the_effective_owner(self) -> None:
        self.assertNotRegex(cls_sql := self.sql, r"FOR\s+ROLE\s+mantra\b")
        statements = re.findall(r"ALTER\s+DEFAULT\s+PRIVILEGES", cls_sql)
        self.assertEqual(len(statements), 2)
        self.assertIn(
            "GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO mantra_app",
            cls_sql,
        )
        self.assertIn(
            "GRANT USAGE, SELECT ON SEQUENCES TO mantra_app",
            cls_sql,
        )

    def test_rls_protections_remain_intact(self) -> None:
        sql = self.sql
        self.assertIn("ENABLE ROW LEVEL SECURITY", sql)
        self.assertIn("FORCE ROW LEVEL SECURITY", sql)
        self.assertIn("CREATE POLICY tenant_isolation", sql)
        self.assertIn("NOBYPASSRLS", sql)
        self.assertIn("current_setting('app.current_tenant_id', true)", sql)
        self.assertIn("WITH CHECK", sql)

    def test_current_object_grants_remain_intact(self) -> None:
        sql = self.sql
        self.assertIn(
            "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO mantra_app",
            sql,
        )
        self.assertIn(
            "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO mantra_app",
            sql,
        )
        self.assertIn("GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %I TO mantra_app", sql)


if __name__ == "__main__":
    unittest.main()
