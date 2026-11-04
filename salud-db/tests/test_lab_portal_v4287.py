"""v4.2.87 — portal de laboratorio e imagenología (issue #116).

Sin base de datos: comprueba que el DDL generado (`SQL/`) y el parche
`2026-11-04_v4287_*.sql` declaran lo mismo, y que el parche trae lo que el contrato pide
(idempotencia, RLS por custodio, disparadores del ejecutor y de inmutabilidad).
"""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQL = ROOT / "SQL"
PATCH = (SQL / "patches" / "2026-11-04_v4287_lab_portal_categorias_disponibilidad_eventos.sql").read_text(
    encoding="utf-8")
PUML = ROOT / "Mantra Core Health Context" / "modules"

UNITS = "23_diagnostic_units"
DIAG = "20_diagnostics"


def generated(module: str, phase: str) -> str:
    return (SQL / module / phase).read_text(encoding="utf-8")


def create_table(sql: str, table: str) -> str:
    m = re.search(rf'CREATE TABLE IF NOT EXISTS "[a-z_]+"\."{table}" \((.*?)\n\);', sql, re.S)
    assert m, table
    return m.group(1)


def column_lines(body: str) -> set[str]:
    return {ln.strip().rstrip(",") for ln in body.splitlines() if ln.strip().startswith('"')}


class LabPortalV4287(unittest.TestCase):
    def test_offering_columns_match_the_generated_ddl(self):
        offerings = column_lines(create_table(generated(UNITS, "02_tables.sql"), "diagnostic_study_offerings"))
        self.assertIn('"specimen_description" text', offerings)
        self.assertIn('"service_category_id" uuid', offerings)
        self.assertIn('"available" boolean NOT NULL DEFAULT true', offerings)
        for col in ("specimen_description", "service_category_id", "available"):
            self.assertIn(f'ADD COLUMN IF NOT EXISTS "{col}"', PATCH)
        self.assertIn('"available" boolean NOT NULL DEFAULT true', PATCH)

    def test_new_tables_have_the_same_columns_in_ddl_and_patch(self):
        for module, table in ((UNITS, "diagnostic_service_categories"),
                              (DIAG, "service_request_performer_events")):
            ddl = column_lines(create_table(generated(module, "02_tables.sql"), table))
            patch = column_lines(create_table(PATCH, table))
            self.assertEqual(ddl, patch, table)

    def test_categories_carry_audit_columns_and_row_version(self):
        cols = column_lines(create_table(generated(UNITS, "02_tables.sql"), "diagnostic_service_categories"))
        for col in ('"created_at" timestamptz NOT NULL', '"updated_at" timestamptz NOT NULL',
                    '"row_version" integer NOT NULL DEFAULT 1', '"name" varchar(60) NOT NULL'):
            self.assertIn(col, cols)

    def test_every_generated_index_and_fk_is_in_the_patch(self):
        indexes = generated(UNITS, "04_indexes.sql") + generated(DIAG, "04_indexes.sql")
        fks = "".join(generated(m, p) for m in (UNITS, DIAG) for p in ("03_fk_intra.sql", "90_fk_deferred.sql"))
        wanted_ix = re.findall(r'INDEX IF NOT EXISTS "((?:ix|ux)_(?:diagnostic_service_categories|'
                               r'service_request_performer_events|diagnostic_study_offerings_service_category_id)[a-z_]*)"',
                               indexes)
        self.assertEqual(len(wanted_ix), 8)
        for name in wanted_ix:
            self.assertIn(f'"{name}"', PATCH)
        tables = ("diagnostic_service_categories", "service_request_performer_events")
        wanted_fk = re.findall(
            r'ALTER TABLE "([a-z_]+)"\."([a-z_]+)"\s+ADD CONSTRAINT "fk_[a-z_]+" FOREIGN KEY \("([a-z_]+)"\)\s+'
            r'REFERENCES "([a-z_]+)"\."([a-z_]+)"', fks)
        wanted_fk = [f for f in wanted_fk if f[1] in tables or f[2] == "service_category_id"]
        self.assertEqual(len(wanted_fk), 8)
        for schema, table, col, dst_schema, dst_table in wanted_fk:
            row = re.compile(rf"\('{schema}',\s*'{table}',\s*'{col}',\s*'{dst_schema}',\s*'{dst_table}'\)")
            self.assertRegex(PATCH, row, f"{table}.{col}")

    def test_category_name_is_unique_per_unit_ignoring_case(self):
        self.assertIn('("diagnostic_unit_id", lower(name))', generated(UNITS, "04_indexes.sql"))
        self.assertIn('CREATE UNIQUE INDEX IF NOT EXISTS "ux_diagnostic_service_categories_unit_name"', PATCH)

    def test_category_fk_has_no_delete_action(self):
        fk = re.search(r'fk_diagnostic_study_offerings_service_category_id.*?;', generated(UNITS, "03_fk_intra.sql"), re.S)
        self.assertIsNotNone(fk)
        self.assertNotIn("ON DELETE", fk.group(0))

    def test_performer_events_are_custodian_owned_and_append_only(self):
        for token in ("ENABLE ROW LEVEL SECURITY", "FORCE ROW LEVEL SECURITY",
                      "CREATE POLICY custodian_tenant_isolation", "WITH CHECK",
                      "trg_service_request_performer_event_tenant", "BEFORE UPDATE OR DELETE",
                      "integrity\".\"forbid_mutation", "performer_tenant_id"):
            self.assertIn(token, PATCH)

    def test_patch_is_idempotent_and_transactional(self):
        self.assertTrue(PATCH.count("BEGIN;") == 1 and PATCH.rstrip().endswith("COMMIT;"))
        self.assertNotRegex(PATCH, r"CREATE TABLE (?!IF NOT EXISTS)")
        self.assertNotRegex(PATCH, r"CREATE (UNIQUE )?INDEX (?!IF NOT EXISTS)")
        self.assertNotRegex(PATCH, r"ADD COLUMN (?!IF NOT EXISTS)")
        for trigger in re.findall(r"CREATE TRIGGER (\w+)", PATCH):
            self.assertIn(f"DROP TRIGGER IF EXISTS {trigger}", PATCH)

    def test_puml_declares_the_new_structures(self):
        units = (PUML / "diagram_23_diagnostic_units.puml").read_text(encoding="utf-8")
        diag = (PUML / "diagram_20_diagnostics.puml").read_text(encoding="utf-8")
        self.assertIn("entity diagnostic_service_categories {", units)
        self.assertIn("* available : boolean <<DEFAULT_TRUE>>", units)
        self.assertIn("entity service_request_performer_events <<LOG>> {", diag)
        self.assertIn("service_request_performer_events }o--|| directory_tenants : custodian_tenant_id", diag)


if __name__ == "__main__":
    unittest.main()
