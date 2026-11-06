"""v4.2.91 — categoría de la sede en directory.branches.

Sin base de datos: comprueba que el DDL generado (`SQL/04_directory/`) y el parche
`2026-11-06_v4291_branches_category.sql` declaran la misma columna, los mismos índices y el
mismo CHECK, y que el parche deja la casa matriz única antes de crear el índice único.
(Probado además contra PostgreSQL 16: base vieja con datos + parche dos veces = DDL nuevo.)
"""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / "SQL" / "04_directory"
PATCH = (ROOT / "SQL" / "patches" / "2026-11-06_v4291_branches_category.sql").read_text(encoding="utf-8")
COLUMN = '"branch_category" varchar(20) NOT NULL DEFAULT \'default\''


def generated(phase: str) -> str:
    return (MODULE / phase).read_text(encoding="utf-8")


class BranchesCategoryV4291(unittest.TestCase):
    def test_column_matches_between_ddl_and_patch(self):
        self.assertIn(COLUMN, generated("02_tables.sql"))
        self.assertIn(f'ADD COLUMN IF NOT EXISTS {COLUMN}', PATCH)

    def test_indexes_are_copied_from_the_generated_ddl(self):
        idx = generated("04_indexes.sql")
        for name in ("ix_branches_tenant_id_branch_category", "ux_branches_one_head_office"):
            line = next(ln for ln in idx.splitlines() if f'"{name}"' in ln)
            self.assertIn(line, PATCH, name)

    def test_check_is_copied_from_the_generated_ddl(self):
        checks = generated("05_constraints.sql")
        line = next(ln for ln in checks.splitlines() if "ADD CONSTRAINT \"ck_branches_branch_category\"" in ln)
        self.assertIn("('default', 'head_office', 'branch')", line)
        self.assertIn(line, PATCH)

    def test_unique_head_office_index_comes_after_every_backfill(self):
        ux = PATCH.index('CREATE UNIQUE INDEX IF NOT EXISTS "ux_branches_one_head_office"')
        self.assertLess(PATCH.index("UPDATE \"directory\".\"branches\""), ux)
        self.assertLess(PATCH.index("INSERT INTO \"directory\".\"branches\""), ux)

    def test_patch_is_one_idempotent_transaction(self):
        self.assertTrue(PATCH.split("BEGIN;", 1)[1].strip().endswith("COMMIT;"))
        self.assertNotIn("CREATE INDEX \"", PATCH)
        self.assertNotIn("CREATE UNIQUE INDEX \"", PATCH)
        self.assertIn("NOT EXISTS (SELECT 1 FROM \"directory\".\"branches\" b WHERE b.\"tenant_id\" = s.\"tenant_id\")", PATCH)


if __name__ == "__main__":
    unittest.main()
