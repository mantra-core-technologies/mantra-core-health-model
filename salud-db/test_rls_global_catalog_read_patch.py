"""Contrato del patch v4251: lectura de catálogos globales sin abrir escritura ni PII."""

from pathlib import Path
import re
import unittest


PATCH = (
    Path(__file__).resolve().parents[1]
    / "SQL"
    / "patches"
    / "2026-10-25_v4251_rls_global_catalog_read.sql"
)

CATALOGOS = {
    "system_context.dynamic_enum_definitions",
    "authz.roles",
    "chart.specialty_chart_templates",
    "forms.field_assignments",
    "forms.extension_target_policies",
}


class RlsGlobalCatalogReadPatchContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")
        cls.code = "\n".join(
            line for line in cls.sql.splitlines() if not line.lstrip().startswith("--")
        )

    def test_only_opens_select(self) -> None:
        self.assertIn("FOR SELECT USING (tenant_id IS NULL)", self.code)
        self.assertNotRegex(self.code, r"FOR\s+(ALL|UPDATE|DELETE|INSERT)")
        self.assertNotIn("WITH CHECK", self.code)

    def test_does_not_touch_tenant_isolation(self) -> None:
        self.assertNotIn("tenant_isolation", self.code)

    def test_explicit_allowlist(self) -> None:
        listed = set(re.findall(r"'([a-z_]+\.[a-z_]+)'", self.code))
        self.assertEqual(listed, CATALOGOS)

    def test_never_opens_personal_data(self) -> None:
        self.assertNotIn("identity_verification_cases", self.code)
        self.assertNotIn("information_schema.columns", self.code)

    def test_idempotent(self) -> None:
        self.assertIn("DROP POLICY IF EXISTS global_catalog_read", self.code)


if __name__ == "__main__":
    unittest.main()
