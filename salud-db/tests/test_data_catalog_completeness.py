"""The API consumes the CSV catalog; new SQL tables must not disappear there."""
import csv
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "docs" / "data-catalog"


class DataCatalogCompletenessTests(unittest.TestCase):
    def test_every_canonical_sql_table_and_column_is_cataloged(self):
        tables = set()
        columns = set()
        for path in (ROOT / "SQL").glob("*/02_tables.sql"):
            schema = None
            table = None
            for line in path.read_text(encoding="utf-8").splitlines():
                start = re.match(r'CREATE TABLE IF NOT EXISTS "([^"]+)"\."([^"]+)"', line)
                if start:
                    schema, table = start.groups()
                    tables.add((schema, table))
                elif line == ");":
                    schema = table = None
                elif schema is not None:
                    column = re.match(r'\s+"([^"]+)"\s+', line)
                    if column:
                        columns.add((schema, table, column.group(1)))

        self.assertTrue(tables, "Canonical DDL was not found")
        with (CATALOG / "tables.csv").open(encoding="utf-8", newline="") as stream:
            table_rows = list(csv.DictReader(stream))
        with (CATALOG / "columns.csv").open(encoding="utf-8", newline="") as stream:
            column_rows = list(csv.DictReader(stream))
        csv_tables = {(row["schema"], row["table"]) for row in table_rows}
        csv_columns = {(row["schema"], row["table"], row["column"]) for row in column_rows}
        self.assertEqual(csv_tables, tables, "Regenerate docs/data-catalog/generate_catalog.py")
        self.assertEqual(csv_columns, columns, "SQL and CSV columns diverged")
        self.assertEqual(len(table_rows), len(csv_tables), "Duplicate table rows")
        self.assertEqual(len(column_rows), len(csv_columns), "Duplicate column rows")


if __name__ == "__main__":
    unittest.main()
