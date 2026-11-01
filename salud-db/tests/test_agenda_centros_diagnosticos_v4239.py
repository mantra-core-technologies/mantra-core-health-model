"""model#105 — el patch v4.2.39 (agenda de los centros diagnósticos) es reaplicable sobre una base con semillas.

El patch inserta recursos, plantillas y cupos con ids de concepto fijos. Las tres columnas tienen FK
diferida a `terminology.catalog_concepts`, así que cada id tiene que venir en el paquete de seeds
(`BACKEND_CONCEPTS` → `03_terminology` boot) con la derivación de la API (`deterministicId(clave)`).
"""
import json
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "salud-db"))

import gen_seeds as gs  # noqa: E402

PATCH = ROOT / "SQL" / "patches" / "2026-10-11_v4239_agenda_centros_diagnosticos.sql"
TERMINOLOGY = ROOT / "seedsGenerales" / "modules" / "03_terminology.seeds.json"
UUID = r"'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'"
# Clave de la API (concepts.ts) → code almacenado (conceptos centrales: el def.code).
EXPECTED = {
    "scheduling:resource-type:practitioner": "RES_PRACTITIONER",
    "scheduling:template-status:published": "TPL_PUBLISHED",
    "scheduling:slot-status:open": "SLOT_OPEN",
    "state:active": "ACTIVE",
}


def patch_concept_ids() -> set[str]:
    """Ids literales del patch que no son del usuario administrador."""
    sql = PATCH.read_text(encoding="utf-8")
    return {u for u in re.findall(UUID, sql) if u != "00000000-0000-4000-8000-000000000001"}


class AgendaCentrosDiagnosticosV4239(unittest.TestCase):
    def test_every_concept_id_in_the_patch_is_a_known_backend_key(self):
        ids = {gs.backend_id(key): key for key in EXPECTED}
        self.assertEqual(patch_concept_ids(), set(ids), "el patch usa un id de concepto no espejado")
        self.assertEqual(gs.backend_id("scheduling:resource-type:practitioner"),
                         "a1df879c-4ac6-5a7e-8548-bc04207e92fa")

    def test_backend_mirror_carries_them_with_the_api_code(self):
        mirror = {key: code for key, code, _display in gs.BACKEND_CONCEPTS}
        for key, code in EXPECTED.items():
            with self.subTest(key=key):
                self.assertEqual(mirror.get(key), code)

    def test_seed_package_ships_them_in_terminology_boot(self):
        doc = json.loads(TERMINOLOGY.read_text(encoding="utf-8"))
        concepts = {c["id"]: c for c in doc["boot"]["records"]["catalog_concepts"]}
        for key, code in EXPECTED.items():
            with self.subTest(key=key):
                row = concepts.get(gs.backend_id(key))
                self.assertIsNotNone(row, f"{key} no está en 03_terminology boot")
                self.assertEqual(row["code"], code)
                self.assertEqual(row["code_system_version_id"], gs.BACKEND_SEED["csv_id"])


if __name__ == "__main__":
    unittest.main()
