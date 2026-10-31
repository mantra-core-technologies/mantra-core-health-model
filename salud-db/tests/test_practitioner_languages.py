"""Regresión: los dos catálogos que lee el editor de idiomas del perfil profesional.

El front («Idiomas en los que atiende») busca `VS_LANGUAGE` y `VS_LANGUAGE_PROFICIENCY` por
`internal_code` y ofrece lo que su versión vigente incluye. Hasta v4.2.74 el primero tenía un
solo miembro incluido —`EN`, que se leía «En»— y el segundo no existía: el médico no podía
declarar ningún otro idioma, ni ver el castellano que el alta le había dejado.

Lee el paquete ya generado (no importa `gen_seeds.py`, que necesita la bóveda).
"""
from pathlib import Path
import json
import sys
import unittest
import uuid

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import paths

BACKEND_NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")


def backend_id(key: str) -> str:
    return str(uuid.uuid5(BACKEND_NAMESPACE, key))


class PractitionerLanguagesCatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        doc = json.loads((paths.SEEDS_MODULES_DIR / "03_terminology.seeds.json")
                         .read_text(encoding="utf-8"))
        cls.records = doc["boot"]["records"]
        cls.concepts = {row["id"]: row for row in cls.records["catalog_concepts"]}

    def expansion(self, internal_code: str) -> list:
        """Lo que devuelve `GET /terminology/value-sets/:id/$expand`, en orden."""
        sets = [v for v in self.records["value_sets"] if v["internal_code"] == internal_code]
        self.assertEqual(len(sets), 1, internal_code)
        version = next(v for v in self.records["value_set_versions"]
                       if v["value_set_id"] == sets[0]["id"] and v["is_default"])
        members = sorted((m for m in self.records["value_set_members"]
                          if m["value_set_version_id"] == version["id"] and m["included"]),
                         key=lambda m: (m["ordinal"], m["concept_id"]))
        return [self.concepts[m["concept_id"]] for m in members]

    def test_languages_offer_spanish_first_and_the_languages_of_bolivia(self) -> None:
        idiomas = self.expansion("VS_LANGUAGE")
        displays = [c["display"] for c in idiomas]
        # El castellano es el concepto que escribe el alta: tiene que ser elegible.
        self.assertEqual(idiomas[0]["id"], backend_id("profiles:LANGUAGE_SPANISH"))
        self.assertEqual(displays[0], "Español")
        for nombre in ("Quechua", "Aymara", "Guaraní", "Inglés", "Portugués"):
            self.assertIn(nombre, displays)
        # El `EN` genérico («En») ya no se ofrece junto a «Inglés».
        self.assertNotIn("En", displays)
        self.assertEqual(len(displays), len(set(displays)))

    def test_proficiency_exists_and_includes_the_signup_default(self) -> None:
        niveles = self.expansion("VS_LANGUAGE_PROFICIENCY")
        self.assertEqual([c["display"] for c in niveles],
                         ["Nativo", "Avanzado", "Intermedio", "Básico"])
        self.assertEqual(niveles[0]["id"], backend_id("profiles:LANG_PROFICIENCY_NATIVE"))

    def test_every_option_is_selectable(self) -> None:
        for code in ("VS_LANGUAGE", "VS_LANGUAGE_PROFICIENCY"):
            for concept in self.expansion(code):
                with self.subTest(code=code, concept=concept["code"]):
                    self.assertIsNot(concept["selectable"], False)


if __name__ == "__main__":
    unittest.main()
