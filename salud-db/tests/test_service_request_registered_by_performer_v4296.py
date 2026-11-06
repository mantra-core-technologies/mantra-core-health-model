"""v4.2.96 — orden registrada por el centro ejecutor.

Sin base de datos: el DDL generado (`SQL/`), el modelo (`.puml`) y el parche
`2026-11-06_v4296_service_request_registered_by_performer.sql` declaran las mismas columnas y CHECK.
La prueba contra PostgreSQL real (parche dos veces y casos de CHECK) está en
docs/trabajo/2026-11-06-orden-registrada-por-el-centro/.
"""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQL = ROOT / "SQL"
PATCH = (SQL / "patches" / "2026-11-06_v4296_service_request_registered_by_performer.sql").read_text(encoding="utf-8")
CLIN = SQL / "08_clinical"
MODULES = ROOT / "Mantra Core Health Context" / "modules"

COLUMNS = (
    '"registered_by_performer" boolean NOT NULL DEFAULT false',
    '"external_requester_name" varchar(200)',
    '"external_requester_license" varchar(64)',
)
CHECKS = (
    "ck_service_requests_external_requester_only_when_registered",
    "ck_service_requests_registered_by_performer_shape",
)


def check_body(text: str, name: str) -> str:
    marker = f'ADD CONSTRAINT "{name}" CHECK '
    start = text.index(marker) + len(marker)
    return text[start:text.index(";", start)]


class RegisteredByPerformerV4296(unittest.TestCase):
    def test_columns_in_ddl_and_patch(self):
        tables = (CLIN / "02_tables.sql").read_text(encoding="utf-8")
        for col in COLUMNS:
            self.assertIn(col, tables)
            self.assertIn(f"ADD COLUMN IF NOT EXISTS {col}", PATCH)

    def test_columns_in_model(self):
        puml = (MODULES / "diagram_08_clinical.puml").read_text(encoding="utf-8")
        self.assertIn("* registered_by_performer : boolean <<DEFAULT_FALSE>>", puml)
        self.assertIn("external_requester_name : varchar(200)", puml)
        self.assertIn("external_requester_license : varchar(64)", puml)

    def test_checks_identical_in_ddl_patch_and_model(self):
        constraints = (CLIN / "05_constraints.sql").read_text(encoding="utf-8")
        integrity = (MODULES / "diagram_33_integrity.puml").read_text(encoding="utf-8")
        for name in CHECKS:
            body = check_body(constraints, name)
            self.assertEqual(body, check_body(PATCH, name))
            self.assertIn(f"CHECK_SQL : {name} | {body[1:-1]}", integrity)

    def test_patch_is_one_transaction(self):
        lines = [line.strip() for line in PATCH.splitlines()]
        self.assertEqual(lines.count("BEGIN;"), 1)
        self.assertEqual(lines.count("COMMIT;"), 1)
        self.assertTrue(PATCH.rstrip().endswith("COMMIT;"))


if __name__ == "__main__":
    unittest.main()
