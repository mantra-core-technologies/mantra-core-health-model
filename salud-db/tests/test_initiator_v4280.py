"""v4.2.80 — quién inició cada vínculo de la secretaria (`initiated_by_party_concept_id`).

Pruebas estáticas: la columna está en el modelo, en el DDL generado y en el parche, y los ids de los
conceptos son los que deriva la API (`deterministicId('delegated_access:INITIATOR_*')`).
"""
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "salud-db"))

import gen_seeds as gs  # noqa: E402

PATCH = ROOT / "SQL" / "patches" / "2026-10-31_v4280_iniciador_vinculos.sql"
TABLES = {
    "delegated_access.organization_user_assignments": ("29_delegated_access", "diagram_29_delegated_access.puml",
                                                       "ix_org_user_assignments_initiated_by_party"),
    "practice.practitioner_support_assignments": ("14_practice", "diagram_14_practice.puml",
                                                  "ix_prac_support_assignments_initiated_by_party"),
}
CONCEPTS = ["SUPPORT_STAFF", "ORGANIZATION", "PRACTITIONER"]


def table_body(sql: str, qualified: str) -> str:
    schema, table = qualified.split(".")
    head = f'CREATE TABLE IF NOT EXISTS "{schema}"."{table}" ('
    start = sql.index(head)
    return sql[start:sql.index("\n);", start)]


class InitiatorV4280(unittest.TestCase):
    def test_column_is_nullable_uuid_in_ddl_and_puml(self):
        for qualified, (module, puml, _ix) in TABLES.items():
            ddl = (ROOT / "SQL" / module / "02_tables.sql").read_text(encoding="utf-8")
            self.assertIn('"initiated_by_party_concept_id" uuid,', table_body(ddl, qualified), qualified)
            model = (ROOT / "Mantra Core Health Context" / "modules" / puml).read_text(encoding="utf-8")
            self.assertIn("    initiated_by_party_concept_id : uuid <<FK>>", model, puml)

    def test_fk_and_index_are_generated(self):
        for qualified, (module, _puml, ix) in TABLES.items():
            fks = (ROOT / "SQL" / module / "90_fk_deferred.sql").read_text(encoding="utf-8")
            self.assertIn('FOREIGN KEY ("initiated_by_party_concept_id")', fks, qualified)
            idx = (ROOT / "SQL" / module / "04_indexes.sql").read_text(encoding="utf-8")
            self.assertIn(f'"{ix}"', idx, qualified)

    def test_patch_is_idempotent_and_matches_names(self):
        sql = PATCH.read_text(encoding="utf-8")
        self.assertEqual(sql.count('ADD COLUMN IF NOT EXISTS "initiated_by_party_concept_id" uuid;'), 2)
        self.assertNotIn("NOT NULL", sql.split("-- ---- 2. columnas ----")[1].split("-- ---- 3.")[0])
        for _q, (module, _puml, ix) in TABLES.items():
            self.assertIn(f'CREATE INDEX IF NOT EXISTS "{ix}"', sql)
            fks = (ROOT / "SQL" / module / "90_fk_deferred.sql").read_text(encoding="utf-8")
            name = next(line.split('"')[1] for line in fks.splitlines()
                        if "initiated_by_party_concept_id" in line and "ADD CONSTRAINT" in line)
            self.assertIn(f"'{name}'", sql)
        self.assertIn("ON CONFLICT DO NOTHING", sql)

    def test_concept_ids_match_the_api_derivation(self):
        sql = PATCH.read_text(encoding="utf-8")
        seeded = {key: code for key, code, _display in gs.INITIATOR_BACKEND_CONCEPTS}
        for name in CONCEPTS:
            key = f"delegated_access:INITIATOR_{name}"
            self.assertEqual(seeded[key], f"DA_INITIATOR_{name}")
            self.assertIn(f"('{gs.backend_id(key)}', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'DA_INITIATOR_{name}'", sql)


if __name__ == "__main__":
    unittest.main()
