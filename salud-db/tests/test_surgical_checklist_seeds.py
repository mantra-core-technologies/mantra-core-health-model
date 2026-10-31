"""model#102 — las semillas respetan ux_surgical_safety_checklists_case_type.

El patch 2026-10-29_infraestructura_f4_quirofanos.sql se niega a crear el índice único
(procedure_case_id, checklist_type_concept_id) si encuentra duplicados, y no borra datos a
propósito. Las semillas mock traían 7 pares (caso, tipo) con más de un checklist: esta prueba
impide que vuelvan.
"""
import json
import unittest
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SEEDS = ROOT / "seedsGenerales" / "modules" / "53_procedures_perioperative.seeds.json"
PRACTICE = ROOT / "seedsGenerales" / "modules" / "14_practice.seeds.json"
INDEXES = ROOT / "SQL" / "53_procedures_perioperative" / "04_indexes.sql"


class SurgicalChecklistSeeds(unittest.TestCase):
    def test_unique_index_is_in_the_ddl(self):
        self.assertIn('"ux_surgical_safety_checklists_case_type"', INDEXES.read_text(encoding="utf-8"))

    def test_one_checklist_per_case_and_type(self):
        doc = json.loads(SEEDS.read_text(encoding="utf-8"))
        for section in ("boot", "mock"):
            rows = doc.get(section, {}).get("records", {}).get("surgical_safety_checklists", [])
            pairs = Counter((r["procedure_case_id"], r["checklist_type_concept_id"]) for r in rows)
            repeated = {k: n for k, n in pairs.items() if n > 1}
            self.assertEqual(repeated, {}, section)

    def test_checklists_point_to_seeded_cases(self):
        doc = json.loads(SEEDS.read_text(encoding="utf-8"))
        cases = {r["id"] for s in ("boot", "mock")
                 for r in doc.get(s, {}).get("records", {}).get("procedure_cases", [])}
        for r in doc["mock"]["records"]["surgical_safety_checklists"]:
            self.assertIn(r["procedure_case_id"], cases)

    def test_case_site_and_room_belong_to_the_custodian(self):
        # FK compuestas (custodian_tenant_id, practice_site_id / operating_room_id) del patch F4.
        practice = json.loads(PRACTICE.read_text(encoding="utf-8"))
        tenant_of = {r["id"]: r.get("tenant_id") for s in ("boot", "mock")
                     for t in ("practice_sites", "care_spaces")
                     for r in practice.get(s, {}).get("records", {}).get(t, [])}
        doc = json.loads(SEEDS.read_text(encoding="utf-8"))
        for s in ("boot", "mock"):
            for case in doc.get(s, {}).get("records", {}).get("procedure_cases", []):
                for col in ("practice_site_id", "operating_room_id"):
                    ref = case.get(col)
                    if ref is not None and ref in tenant_of:
                        self.assertEqual(tenant_of[ref], case["custodian_tenant_id"], (case["id"], col))


if __name__ == "__main__":
    unittest.main()
