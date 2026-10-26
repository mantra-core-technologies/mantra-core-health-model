"""Regresión: los tipos de organización médica existen en el paquete con el id de la API.

`directory.tenants.tenant_type_concept_id` tiene FK a `terminology.catalog_concepts`. El alta
pública de una organización médica guarda uno de estos cinco tipos; si el paquete no los
trae, una base armada solo con los seeds rechaza el tenant con 23503. El id tiene que ser
el que deriva la API (`deterministicId(key)` en `concepts.ts`: uuid5 con su namespace),
porque los servicios comparan por id.

La prueba lee el paquete ya generado (no importa `gen_seeds.py`, que necesita la bóveda) y,
si la API está clonada al lado, contrasta además código y display con `concepts.ts`.
"""
from pathlib import Path
import json
import re
import sys
import unittest
import uuid

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import paths

BACKEND_NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")
BACKEND_CSV_KEY = "seed:code-system-version:mantra-core:1.0.0"

# (clave de derivación, code almacenado, display) — contrato compartido con la API y el front.
INSTITUTIONAL_TENANT_TYPES = [
    ("directory:tenant-type:hospital", "HOSPITAL", "Hospital"),
    ("directory:tenant-type:clinic", "CLINIC", "Clinic"),
    ("directory:tenant-type:medical-office", "MEDICAL_OFFICE", "Medical office"),
    ("directory:tenant-type:nursing", "NURSING", "Nursing facility"),
    ("directory:tenant-type:health-other", "HEALTH_OTHER", "Other health institution"),
]

# Ids publicados: si alguien cambia la clave o el namespace, el id deja de coincidir con las
# filas ya persistidas y con la API. Se fijan literales a propósito.
EXPECTED_IDS = {
    "directory:tenant-type:hospital": "2f68ad79-452a-5cba-aa7f-96f8fa2610ab",
    "directory:tenant-type:clinic": "420eddfc-a569-5b2e-b720-7d7de91cb874",
    "directory:tenant-type:medical-office": "1b191a91-244e-5965-8bc5-e6e07f1d0cb6",
    "directory:tenant-type:nursing": "11fbdf9e-2b4f-59af-8e6e-b05be58a33b3",
    "directory:tenant-type:health-other": "51966f39-c661-5926-914d-d30683f583ef",
}

DEF_RE = re.compile(r"def\(\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',?\s*\)")


def backend_id(key: str) -> str:
    return str(uuid.uuid5(BACKEND_NAMESPACE, key))


class TenantTypeCatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        doc = json.loads((paths.SEEDS_MODULES_DIR / "03_terminology.seeds.json")
                         .read_text(encoding="utf-8"))
        cls.concepts = {row["id"]: row for row in doc["boot"]["records"]["catalog_concepts"]}

    def test_derivation_matches_the_published_ids(self) -> None:
        for key, _code, _display in INSTITUTIONAL_TENANT_TYPES:
            with self.subTest(key=key):
                self.assertEqual(backend_id(key), EXPECTED_IDS[key])

    def test_the_five_institutional_types_are_in_the_boot_package(self) -> None:
        csv_id = backend_id(BACKEND_CSV_KEY)
        for key, code, display in INSTITUTIONAL_TENANT_TYPES:
            with self.subTest(code=code):
                row = self.concepts.get(EXPECTED_IDS[key])
                self.assertIsNotNone(row, f"{code} falta en 03_terminology boot catalog_concepts")
                self.assertEqual(row["code"], code)
                self.assertEqual(row["display"], display)
                self.assertEqual(row["code_system_version_id"], csv_id)
                self.assertTrue(row["selectable"])
                self.assertFalse(row["abstract"])

    def test_codes_do_not_collide_inside_the_backend_code_system(self) -> None:
        csv_id = backend_id(BACKEND_CSV_KEY)
        codes = [r["code"] for r in self.concepts.values() if r["code_system_version_id"] == csv_id]
        for _key, code, _display in INSTITUTIONAL_TENANT_TYPES:
            with self.subTest(code=code):
                self.assertEqual(codes.count(code), 1)

    def test_api_concepts_agree_when_the_api_is_cloned_alongside(self) -> None:
        concepts_ts = paths.API_DIR / "src" / "common" / "constants" / "concepts.ts"
        if not concepts_ts.exists():
            self.skipTest("la API no está clonada junto al modelo")
        source = concepts_ts.read_text(encoding="utf-8")
        api = {key: (code, display) for key, code, display in DEF_RE.findall(source)}
        # Si `DEF_RE` deja de reconocer el formato de `def(...)`, el diccionario sale vacío y la
        # comparación de abajo pasaría en verde sin comparar nada.
        self.assertIn("directory:tenant-type:hospital", api,
                      "DEF_RE ya no reconoce las definiciones de concepts.ts")
        for key, code, display in INSTITUTIONAL_TENANT_TYPES:
            with self.subTest(key=key):
                if key not in api:
                    # La API todavía no declara el tipo (p. ej. una rama sin mergear): no hay
                    # contra qué comparar. Pero si declara la constante con otra clave, la clave
                    # cambió y el id ya no coincide.
                    self.assertFalse(f"TENANT_TYPE_{code}:" in source,
                                     f"concepts.ts declara TENANT_TYPE_{code} con otra clave que {key}")
                    continue
                self.assertEqual(api[key], (code, display))


if __name__ == "__main__":
    unittest.main()
