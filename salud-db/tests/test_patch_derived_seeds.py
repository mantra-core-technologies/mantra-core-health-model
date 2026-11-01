"""Las semillas traen las columnas que un patch deriva del padre o deja sin DEFAULT.

`load_seeds.py` salta toda fila sin una columna NOT NULL sin default. Antes se perdían 48 filas:
16 `clinical.encounter_locations` y 16 `procedures_perioperative.operating_room_utilization_events`
sin `tenant_id` (F3/F4 lo derivan del encuentro y del quirófano), y 16
`community.conversation_participants` sin `is_favorite`/`is_pinned` (v4.2.9 les quita el DEFAULT
false). `phase_patch_derivations` copia el valor del padre o el literal del modelo; estas pruebas
fijan las reglas y el paquete, sin red ni bóveda.
"""
import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "salud-db"))

import gen_seeds as gs  # noqa: E402

MODULES = ROOT / "seedsGenerales" / "modules"


def rows(module: str, entity: str) -> list:
    doc = json.loads((MODULES / module).read_text(encoding="utf-8"))
    return [r for s in ("boot", "mock") for r in doc.get(s, {}).get("records", {}).get(entity, [])]


class PatchRules(unittest.TestCase):
    def test_backfills_name_the_parent(self):
        rules = gs.patch_backfills()
        self.assertEqual(rules["clinical.encounter_locations.tenant_id"],
                         ("clinical.encounters", "tenant_id", "id", "encounter_id"))
        self.assertEqual(rules["procedures_perioperative.operating_room_utilization_events.tenant_id"],
                         ("practice.care_spaces", "tenant_id", "id", "operating_room_id"))

    def test_dropped_defaults_keep_the_model_literal(self):
        dropped = gs.patch_dropped_defaults()
        self.assertIs(dropped["community.conversation_participants.is_favorite"], False)
        self.assertIs(dropped["community.conversation_participants.is_pinned"], False)

    def test_derivation_copies_from_the_parent_and_never_invents(self):
        enc, orphan = "00000000-0000-5000-8000-000000000001", "00000000-0000-5000-8000-000000000009"
        tenant = "00000000-0000-5000-8000-0000000000aa"
        docs = {
            "08": {"mock": {"records": {
                "encounters": [{"id": enc, "tenant_id": tenant}],
                "encounter_locations": [{"id": "l1", "encounter_id": enc},
                                        {"id": "l2", "encounter_id": orphan}],
            }}},
            "19": {"mock": {"records": {"conversation_participants": [{"id": "p1", "is_pinned": True}]}}},
        }
        gs.phase_patch_derivations(docs)
        locs = docs["08"]["mock"]["records"]["encounter_locations"]
        self.assertEqual(locs[0]["tenant_id"], tenant)
        self.assertNotIn("tenant_id", locs[1])          # padre ausente: no se adivina
        part = docs["19"]["mock"]["records"]["conversation_participants"][0]
        self.assertEqual((part["is_favorite"], part["is_pinned"]), (False, True))


class Package(unittest.TestCase):
    def test_stays_carry_the_tenant_of_their_encounter(self):
        tenant_of = {r["id"]: r.get("tenant_id") for r in rows("08_clinical.seeds.json", "encounters")}
        locs = rows("08_clinical.seeds.json", "encounter_locations")
        self.assertTrue(locs)
        for r in locs:
            self.assertIsNotNone(r.get("tenant_id"), r["id"])
            self.assertEqual(r["tenant_id"], tenant_of[r["encounter_id"]], r["id"])

    def test_or_events_carry_the_tenant_of_their_room(self):
        tenant_of = {r["id"]: r.get("tenant_id") for r in rows("14_practice.seeds.json", "care_spaces")}
        events = rows("53_procedures_perioperative.seeds.json", "operating_room_utilization_events")
        self.assertTrue(events)
        for r in events:
            self.assertIsNotNone(r.get("tenant_id"), r["id"])
            self.assertEqual(r["tenant_id"], tenant_of[r["operating_room_id"]], r["id"])

    def test_participants_carry_their_flags(self):
        parts = rows("19_community.seeds.json", "conversation_participants")
        self.assertTrue(parts)
        for r in parts:
            self.assertIsInstance(r.get("is_favorite"), bool, r["id"])
            self.assertIsInstance(r.get("is_pinned"), bool, r["id"])


if __name__ == "__main__":
    unittest.main()
