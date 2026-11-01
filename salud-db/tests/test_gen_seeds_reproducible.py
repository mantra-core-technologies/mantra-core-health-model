"""model#109 — `gen_seeds.py` completo reproduce `seedsGenerales/` versionado.

La corrida completa (sin `--only`) reescribía 5 módulos del paquete, y el resultado rompía la base:

- `phase_unique_within` / `phase_unique` ignoraban el `WHERE` de las UK parciales y «desambiguaban»
  filas que la base no considera repetidas: 15 direcciones no preferidas del mismo dueño
  (`uq_addresses_owner_preferred … WHERE is_preferred AND valid_to IS NULL`) recibían un
  `owner_type_concept_id` al azar, y 9 membresías no activas
  (`uq_tenant_memberships_active_user_tenant … WHERE status_concept_id = '13ca1b46…'`) otro usuario.
- `phase_notnull` leía sólo `02_tables.sql` e inventaba columnas que un patch rellena:
  `practice.care_spaces.ops_version` (DEFAULT 1 del patch F2) y el `tenant_id` que los patches F3/F4
  derivan del padre (encuentro, quirófano). Un tenant al azar hacía abortar `infraestructura_f3`
  en la segunda pasada.

El paso «Seeds regenerados» del CI compara la corrida completa contra el paquete (necesita la
bóveda); estas pruebas fijan las dos reglas sin red ni bóveda.
"""
import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "salud-db"))

import gen_seeds as gs  # noqa: E402

COMMON = ROOT / "seedsGenerales" / "modules" / "02_common.seeds.json"
DIRECTORY = ROOT / "seedsGenerales" / "modules" / "04_directory.seeds.json"
OWNER_TYPE = "9bcbd402-24f6-5882-966c-3724a03e83ae"
OWNER = "4dce1581-772e-5533-ba3a-6acbff2e285e"


def address(i: int, preferred=None, valid_to="2026-08-11") -> dict:
    row = {"id": f"00000000-0000-5000-8000-{i:012d}", "owner_type_concept_id": OWNER_TYPE,
           "owner_id": OWNER, "valid_to": valid_to}
    if preferred is not None:
        row["is_preferred"] = preferred
    return row


class PartialUniqueIndexes(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ddl, cls.fks, cls.uniques = gs.parse_ddl(), gs.parse_fks(), gs.parse_unique()

    def test_predicates_are_parsed(self):
        key = ("common.addresses", ("owner_type_concept_id", "owner_id"))
        self.assertEqual(gs.UK_PREDICATES[key], "is_preferred AND valid_to IS NULL")
        covered = gs.uk_row_filter(*key)
        self.assertTrue(covered({"is_preferred": True, "valid_to": None}))
        self.assertFalse(covered({"is_preferred": True, "valid_to": "2026-08-11"}))
        self.assertFalse(covered({"valid_to": None}))   # ausente → DEFAULT false

    def test_in_and_equality_predicates(self):
        covered = gs.uk_row_filter("directory.tenant_memberships", ("user_id", "tenant_id"))
        self.assertTrue(covered({"status_concept_id": "13ca1b46-61d5-5c25-9d49-8247bcd7769c"}))
        self.assertFalse(covered({"status_concept_id": gs.CONCEPT_ACTIVE}))

    def test_unknown_predicate_covers_every_row(self):
        # `active_status()` no se evalúa en Python: se compara de más, nunca de menos.
        self.assertIsNone(gs.uk_row_filter("profiles.person_account_links", ("user_id",)))

    def run_within(self, rows):
        docs = {"02": {"boot": {"records": {"addresses": rows}}}}
        return gs.phase_unique_within(docs, self.ddl, self.uniques, self.fks)

    def test_rows_outside_the_predicate_are_not_rewritten(self):
        rows = [address(i) for i in range(1, 6)]
        before = json.dumps(rows, sort_keys=True)
        self.assertEqual(self.run_within(rows), {})
        self.assertEqual(json.dumps(rows, sort_keys=True), before)

    def test_rows_inside_the_predicate_are_still_disambiguated(self):
        rows = [address(i, preferred=True, valid_to=None) for i in range(1, 4)]
        changed = self.run_within(rows)
        self.assertEqual(sum(changed.values()), 2)
        self.assertEqual(len({(r["owner_type_concept_id"], r["owner_id"]) for r in rows}), 3)

    def test_package_respects_the_partial_indexes(self):
        for path, tkey, entity in ((COMMON, "common.addresses", "addresses"),
                                   (DIRECTORY, "directory.tenant_memberships", "tenant_memberships")):
            doc = json.loads(path.read_text(encoding="utf-8"))
            for uk in self.uniques[tkey]:
                covered = gs.uk_row_filter(tkey, uk)
                for section in ("boot", "mock"):
                    rows = doc.get(section, {}).get("records", {}).get(entity, [])
                    keys = [tuple(r.get(c) for c in uk) for r in rows
                            if (covered is None or covered(r)) and all(r.get(c) is not None for c in uk)]
                    self.assertEqual(len(keys), len(set(keys)), (tkey, uk, section))


class PatchColumnRules(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.defaults, cls.derived = gs.patch_column_rules()
        cls.ddl, cls.fks = gs.parse_ddl(), gs.parse_fks()

    def test_patch_defaults_and_backfills_are_detected(self):
        self.assertIn("practice.care_spaces.ops_version", self.defaults)
        self.assertIn("clinical.encounter_locations.tenant_id", self.derived)
        self.assertIn("procedures_perioperative.operating_room_utilization_events.tenant_id",
                      self.derived)

    def test_notnull_does_not_invent_patch_owned_columns(self):
        # El DDL generado las declara NOT NULL sin default; los patches las resuelven.
        self.assertTrue(self.ddl["clinical.encounter_locations"]["tenant_id"]["not_null"])
        self.assertFalse(self.ddl["practice.care_spaces"]["ops_version"]["default"])
        docs = {
            "03": {"boot": {"records": {"catalog_concepts": [{"id": gs.CONCEPT_ACTIVE}]}}},
            "08": {"mock": {"records": {"encounter_locations": [{"id": "00000000-0000-5000-8000-000000000001"}]}}},
            "14": {"mock": {"records": {"care_spaces": [{"id": "00000000-0000-5000-8000-000000000002"}]}}},
        }
        fixed = gs.phase_notnull(docs, self.ddl, self.fks, {})
        self.assertNotIn("clinical.encounter_locations.tenant_id", fixed)
        self.assertNotIn("practice.care_spaces.ops_version", fixed)
        self.assertNotIn("tenant_id", docs["08"]["mock"]["records"]["encounter_locations"][0])
        self.assertNotIn("ops_version", docs["14"]["mock"]["records"]["care_spaces"][0])


if __name__ == "__main__":
    unittest.main()
