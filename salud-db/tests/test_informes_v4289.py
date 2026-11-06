"""v4.2.89 — informe diagnóstico redactado (H1 de «Conclusión de resultados»).

Sin base de datos: comprueba que el DDL generado (`SQL/`) y el parche
`2026-11-05_v4289_informes_borradores.sql` declaran lo mismo, y que el parche trae lo que
el generador no expresa (RLS por custodio, «publicado = inmutable», FK compuesta
archivo↔borrador del mismo custodio) de forma idempotente.
"""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQL = ROOT / "SQL"
PATCH = (SQL / "patches" / "2026-11-05_v4289_informes_borradores.sql").read_text(encoding="utf-8")
PUML = ROOT / "Mantra Core Health Context" / "modules"

DIAG = "20_diagnostics"
TABLES = ("report_drafts", "report_draft_files", "report_issuer_settings")


def generated(phase: str) -> str:
    return (SQL / DIAG / phase).read_text(encoding="utf-8")


def create_table(sql: str, table: str) -> str:
    m = re.search(rf'CREATE TABLE IF NOT EXISTS "[a-z_]+"\."{table}" \((.*?)\n\);', sql, re.S)
    assert m, table
    return m.group(1)


def column_lines(body: str) -> list[str]:
    return [ln.strip().rstrip(",") for ln in body.splitlines() if re.match(r'\s*"[a-z_]+" [a-z]', ln)]


class InformesV4289(unittest.TestCase):
    def test_tables_have_the_same_columns_in_ddl_and_patch(self):
        for table in TABLES:
            ddl = column_lines(create_table(generated("02_tables.sql"), table))
            patch = column_lines(create_table(PATCH, table))
            self.assertEqual(ddl, patch, table)

    def test_no_business_defaults(self):
        drafts = column_lines(create_table(generated("02_tables.sql"), "report_drafts"))
        for col in ('"body_json" jsonb NOT NULL', '"patient_visibility_code" varchar(8) NOT NULL',
                    '"status_code" varchar(10) NOT NULL', '"row_version" integer NOT NULL DEFAULT 1'):
            self.assertIn(col, drafts)
        files = column_lines(create_table(generated("02_tables.sql"), "report_draft_files"))
        self.assertIn('"ordinal" integer NOT NULL DEFAULT 0', files)

    def test_every_generated_index_and_fk_is_in_the_patch(self):
        wanted_ix = re.findall(r'INDEX IF NOT EXISTS "((?:ix|ux)_report_(?:drafts|draft_files|issuer_settings)[a-z_]*)"',
                               generated("04_indexes.sql"))
        self.assertEqual(len(wanted_ix), 9)
        for name in wanted_ix:
            self.assertIn(f'"{name}"', PATCH)
        fks = generated("03_fk_intra.sql") + generated("90_fk_deferred.sql")
        wanted_fk = re.findall(
            r'ALTER TABLE "diagnostics"\."([a-z_]+)"\s+ADD CONSTRAINT "fk_[a-z_]+" FOREIGN KEY \("([a-z_]+)"\)\s+'
            r'REFERENCES "([a-z_]+)"\."([a-z_]+)" \("([a-z_]+)"\)', fks)
        wanted_fk = [f for f in wanted_fk if f[0] in TABLES]
        self.assertEqual(len(wanted_fk), 17)
        for table, col, dst_schema, dst_table, dst_col in wanted_fk:
            row = re.compile(rf"\('{table}',\s*'{col}',\s*'{dst_schema}',\s*'{dst_table}',\s*'{dst_col}'\)")
            self.assertRegex(PATCH, row, f"{table}.{col}")

    def test_signer_points_to_the_practitioner_profile_pk(self):
        self.assertIn('REFERENCES "profiles"."health_practitioner_profiles" ("profile_id")',
                      generated("90_fk_deferred.sql"))

    def test_every_generated_check_is_in_the_patch(self):
        checks = re.findall(r'ADD CONSTRAINT "(ck_report_[a-z_]+)" CHECK', generated("05_constraints.sql"))
        self.assertEqual(sorted(checks), sorted({
            "ck_report_drafts_visibility", "ck_report_drafts_status", "ck_report_drafts_published",
            "ck_report_draft_files_role"}))
        for name in checks:
            self.assertIn(f'CONSTRAINT "{name}" CHECK', PATCH)

    def test_custodian_rls_and_published_is_final(self):
        for token in ("ENABLE ROW LEVEL SECURITY", "FORCE ROW LEVEL SECURITY",
                      "CREATE POLICY custodian_tenant_isolation", "WITH CHECK",
                      '"integrity"."report_draft_published_is_final"', "SECURITY DEFINER",
                      "BEFORE UPDATE OR DELETE ON \"diagnostics\".\"report_drafts\"",
                      "BEFORE INSERT OR UPDATE OR DELETE ON \"diagnostics\".\"report_draft_files\"",
                      "fk_report_draft_files_draft_tenant"):
            self.assertIn(token, PATCH)

    def test_patch_is_idempotent_and_transactional(self):
        self.assertTrue(PATCH.count("BEGIN;") == 1 and PATCH.rstrip().endswith("COMMIT;"))
        self.assertNotRegex(PATCH, r"CREATE TABLE (?!IF NOT EXISTS)")
        self.assertNotRegex(PATCH, r"CREATE (UNIQUE )?INDEX (?!IF NOT EXISTS)")
        for trigger in set(re.findall(r"CREATE TRIGGER (\w+)", PATCH)):
            self.assertIn(f"DROP TRIGGER IF EXISTS {trigger}", PATCH)

    def test_puml_declares_the_new_structures(self):
        diag = (PUML / "diagram_20_diagnostics.puml").read_text(encoding="utf-8")
        for table in TABLES:
            self.assertIn(f"entity {table} {{", diag)
        self.assertIn("report_drafts }o--o| diagnostic_report_versions : published_version_id", diag)
        integrity = (PUML / "diagram_33_integrity.puml").read_text(encoding="utf-8")
        self.assertIn('entity "diagnostics.report_drafts" as diagnostics_report_drafts <<REFERENCE_ONLY>>', integrity)


if __name__ == "__main__":
    unittest.main()
