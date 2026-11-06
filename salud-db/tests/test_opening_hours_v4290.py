"""v4.2.90 — horario de atención declarado en el alta de organización.

Sin base de datos: comprueba que el DDL generado (`SQL/04_directory/`) y el parche
`2026-11-06_v4290_tenant_opening_hours.sql` declaran lo mismo, y que la tabla trae los
límites que el alta necesita (día ISO, dos turnos, cierre después de la apertura, una sede).
"""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQL = ROOT / "SQL"
MODULE = SQL / "04_directory"
PATCH = (SQL / "patches" / "2026-11-06_v4290_tenant_opening_hours.sql").read_text(encoding="utf-8")
TABLE = "tenant_opening_hours"


def generated(phase: str) -> str:
    return (MODULE / phase).read_text(encoding="utf-8")


def column_lines(sql: str) -> set[str]:
    m = re.search(rf'CREATE TABLE IF NOT EXISTS "directory"\."{TABLE}" \((.*?)\n\);', sql, re.S)
    assert m, TABLE
    return {ln.strip().rstrip(",") for ln in m.group(1).splitlines() if ln.strip().startswith('"')}


def names(sql: str, kind: str) -> set[str]:
    return set(re.findall(rf'"({kind}_{TABLE}_[a-z_]+)"', sql))


class OpeningHoursV4288(unittest.TestCase):
    def test_columns_match_between_ddl_and_patch(self):
        ddl = column_lines(generated("02_tables.sql"))
        self.assertEqual(ddl, column_lines(PATCH))
        for col in ('"day_of_week" smallint NOT NULL', '"shift_ordinal" smallint NOT NULL',
                    '"opens_at" time NOT NULL', '"closes_at" time NOT NULL',
                    '"branch_id" uuid', '"medical_facility_site_id" uuid',
                    '"row_version" integer NOT NULL DEFAULT 1'):
            self.assertIn(col, ddl)

    def test_every_generated_fk_index_and_check_is_in_the_patch(self):
        fks = generated("03_fk_intra.sql") + generated("90_fk_deferred.sql")
        for kind, source in (("fk", fks), ("ix", generated("04_indexes.sql")),
                             ("ux", generated("04_indexes.sql")), ("ck", generated("05_constraints.sql"))):
            expected = names(source, kind)
            self.assertTrue(expected, kind)
            self.assertEqual(expected, names(PATCH, kind), kind)

    def test_site_fks_point_to_branches_and_declared_facility_sites(self):
        fks = generated("03_fk_intra.sql")
        self.assertRegex(fks, re.compile(
            r'fk_tenant_opening_hours_branch_id.*?REFERENCES "directory"\."branches"', re.S))
        self.assertRegex(fks, re.compile(
            r'fk_tenant_opening_hours_medical_facility_site_id.*?REFERENCES "directory"\."tenant_medical_facility_sites"',
            re.S))

    def test_checks_enforce_the_registration_rules(self):
        checks = generated("05_constraints.sql")
        self.assertIn('CHECK ("day_of_week" BETWEEN 1 AND 7)', checks)
        self.assertIn('CHECK ("shift_ordinal" BETWEEN 1 AND 2)', checks)
        self.assertIn('CHECK ("closes_at" > "opens_at")', checks)
        self.assertIn('CHECK (("branch_id" IS NULL OR "medical_facility_site_id" IS NULL))', checks)

    def test_patch_is_one_idempotent_transaction(self):
        self.assertTrue(PATCH.split("BEGIN;", 1)[1].strip().endswith("COMMIT;"))
        self.assertNotIn("CREATE TABLE \"", PATCH.replace("CREATE TABLE IF NOT EXISTS", ""))
        self.assertNotIn("CREATE INDEX \"", PATCH)
        self.assertNotIn("CREATE UNIQUE INDEX \"", PATCH)


if __name__ == "__main__":
    unittest.main()
