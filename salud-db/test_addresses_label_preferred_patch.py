"""Contrato del patch v4261: libreta de direcciones (label + is_preferred) igual al DDL."""

from pathlib import Path
import unittest


RAIZ = Path(__file__).resolve().parents[1]
PATCH = RAIZ / "SQL" / "patches" / "2026-10-26_v4261_addresses_label_preferred.sql"
TABLAS = RAIZ / "SQL" / "02_common" / "02_tables.sql"
INDICES = RAIZ / "SQL" / "02_common" / "04_indexes.sql"
PUML = RAIZ / "Mantra Core Health Context" / "modules" / "diagram_02_common.puml"


class AddressesLabelPreferredPatchContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        sql = PATCH.read_text(encoding="utf-8")
        cls.code = "\n".join(
            line for line in sql.splitlines() if not line.lstrip().startswith("--")
        )

    def test_columns_are_idempotent(self) -> None:
        self.assertIn('ADD COLUMN IF NOT EXISTS "label" varchar;', self.code)
        self.assertIn(
            'ADD COLUMN IF NOT EXISTS "is_preferred" boolean NOT NULL DEFAULT false;',
            self.code,
        )

    def test_single_current_preferred_is_enforced_by_the_database(self) -> None:
        self.assertIn('CREATE UNIQUE INDEX IF NOT EXISTS "uq_addresses_owner_preferred"', self.code)
        self.assertIn("WHERE is_preferred AND valid_to IS NULL", self.code)

    def test_no_backfill_nor_destructive_statements(self) -> None:
        for prohibido in ("UPDATE ", "DELETE ", "DROP ", "TRUNCATE "):
            self.assertNotIn(prohibido, self.code)

    def test_patch_matches_generated_ddl_and_model(self) -> None:
        tablas = TABLAS.read_text(encoding="utf-8")
        indices = INDICES.read_text(encoding="utf-8")
        puml = PUML.read_text(encoding="utf-8")
        self.assertIn('"label" varchar,', tablas)
        self.assertIn('"is_preferred" boolean NOT NULL DEFAULT false,', tablas)
        self.assertIn('"uq_addresses_owner_preferred"', indices)
        self.assertIn('"ix_addresses_owner_current"', indices)
        self.assertIn("* is_preferred : boolean <<DEFAULT_FALSE>>", puml)
        self.assertIn("UK uq_addresses_owner_preferred", puml)


if __name__ == "__main__":
    unittest.main()
