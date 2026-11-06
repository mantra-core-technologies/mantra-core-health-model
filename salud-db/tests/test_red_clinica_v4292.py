"""v4.2.92 — red clínica del paciente, franja 1: tres vínculos nuevos.

Sin base de datos: comprueba que el DDL generado (`SQL/08_clinical/`, `SQL/18_clinical_ext/`)
y el parche `2026-11-06_v4292_red_clinica_vinculos.sql` declaran las mismas columnas, FK e
índices, que cada FK apunta a su destino y que el parche es una sola transacción idempotente.
"""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQL = ROOT / "SQL"
PATCH = (SQL / "patches" / "2026-11-06_v4292_red_clinica_vinculos.sql").read_text(encoding="utf-8")

# (módulo, schema, tabla, columna, schema destino, tabla destino, archivo de la FK)
LINKS = (
    ("08_clinical", "clinical", "service_requests", "reason_condition_id",
     "clinical", "conditions", "03_fk_intra.sql"),
    ("18_clinical_ext", "clinical_ext", "referrals", "target_encounter_id",
     "clinical", "encounters", "90_fk_deferred.sql"),
    ("08_clinical", "clinical", "conditions", "replaced_by_condition_id",
     "clinical", "conditions", "03_fk_intra.sql"),
)


def generated(module: str, phase: str) -> str:
    return (SQL / module / phase).read_text(encoding="utf-8")


def table_body(sql: str, schema: str, table: str) -> str:
    m = re.search(rf'CREATE TABLE IF NOT EXISTS "{schema}"\."{table}" \((.*?)\n\);', sql, re.S)
    assert m, f"{schema}.{table}"
    return m.group(1)


def fk_stmt(col_table: str, col: str, schema: str, dst_schema: str, dst_table: str) -> str:
    return (f'    ALTER TABLE "{schema}"."{col_table}"\n'
            f'        ADD CONSTRAINT "fk_{col_table}_{col}" FOREIGN KEY ("{col}")\n'
            f'        REFERENCES "{dst_schema}"."{dst_table}" ("id");\n')


class RedClinicaV4292(unittest.TestCase):
    def test_columns_are_nullable_uuid_in_ddl_and_patch(self):
        for module, schema, table, col, *_ in LINKS:
            body = table_body(generated(module, "02_tables.sql"), schema, table)
            self.assertIn(f'    "{col}" uuid,', body, col)
            self.assertIn(f'ALTER TABLE "{schema}"."{table}"\n    ADD COLUMN IF NOT EXISTS "{col}" uuid;', PATCH)

    def test_fks_match_generated_and_point_to_their_target(self):
        for module, schema, table, col, dsch, dtbl, phase in LINKS:
            stmt = fk_stmt(table, col, schema, dsch, dtbl)
            self.assertIn(stmt, generated(module, phase), col)
            self.assertIn(stmt, PATCH, col)

    def test_indexes_match_generated(self):
        for module, schema, table, col, *_ in LINKS:
            ix = (f'CREATE INDEX IF NOT EXISTS "ix_{table}_{col}" '
                  f'ON "{schema}"."{table}" ("{col}");')
            self.assertIn(ix, generated(module, "04_indexes.sql"), col)
            self.assertIn(ix, PATCH, col)

    def test_every_column_has_a_spanish_comment(self):
        for _, schema, table, col, *_ in LINKS:
            self.assertRegex(PATCH, rf'COMMENT ON COLUMN "{schema}"\."{table}"\."{col}" IS\n    \'[^\']+\';')

    def test_patch_is_one_idempotent_transaction_without_backfill(self):
        body = PATCH.split("BEGIN;", 1)[1].strip()
        self.assertTrue(body.endswith("COMMIT;"))
        self.assertNotIn('CREATE INDEX "', PATCH)
        self.assertNotRegex(PATCH, r"ADD COLUMN (?!IF NOT EXISTS)")
        self.assertEqual(PATCH.count("EXCEPTION WHEN duplicate_object THEN NULL"), 3)
        code = "\n".join(ln for ln in PATCH.splitlines() if not ln.lstrip().startswith("--"))
        self.assertNotRegex(code, r"\b(UPDATE|INSERT|DELETE)\b")


if __name__ == "__main__":
    unittest.main()
