#!/usr/bin/env python3
"""Contrato estático de v4.2.71: origen de la membresía y documento nacional único.

Cubre la revisión de seguridad independiente (N10: origen de la membresía; N3: documento
nacional normalizado). La verificación DINÁMICA (EXPLAIN con miles de filas, duplicados
previos, rechazos reales de Postgres) se corre contra una base temporal y se resume en
`docs/architecture/physical-materialization.md` (sección v4.2.71); este archivo solo impide
que el `.puml`, el SQL generado, el patch y las semillas diverjan sin base de datos a mano.
"""

from pathlib import Path
import json
import os
import re
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[2]
PATCH = ROOT / "SQL" / "patches" / "2026-10-30_v4269_personal_apoyo.sql"
PUML = ROOT / "Mantra Core Health Context" / "modules"
GEN_SEEDS = ROOT / "salud-db" / "gen_seeds.py"
TERMINOLOGY = ROOT / "seedsGenerales" / "modules" / "03_terminology.seeds.json"

# namespace del backend (HEALTH_UUID_NAMESPACE de concepts.ts)
NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")

ORIGIN_CONCEPTS = [
    "directory:MEMBERSHIP_ORIGIN_OWNER_CREATED",
    "directory:MEMBERSHIP_ORIGIN_ADMIN_ADDED",
    "directory:MEMBERSHIP_ORIGIN_INVITATION_REDEEMED",
    "directory:MEMBERSHIP_ORIGIN_SUPPORT_ENGAGEMENT",
    "directory:MEMBERSHIP_ORIGIN_UNKNOWN",
]

# La expresión que usa la API: normalizeNationalId (profiles/domain/national-id.ts) y
# NORMALIZED_ID (SupportPatientsRepository). Si cambia una, cambia la otra y esta.
NORMALIZED_EXPR = (
    "coalesce(nullif(regexp_replace(upper(regexp_replace(value, '[\\s.-]+', '', 'g')), '^0+', ''), ''), '0')"
)
ID_TYPE_NATIONAL = str(uuid.uuid5(NAMESPACE, "common:id-type:national"))
OWNER_PATIENT = str(uuid.uuid5(NAMESPACE, "common:owner-type:patient"))
STATE_ACTIVE = str(uuid.uuid5(NAMESPACE, "state:active"))


def cid(key: str) -> str:
    return str(uuid.uuid5(NAMESPACE, key))


class MembershipOriginTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.patch = PATCH.read_text(encoding="utf-8")
        cls.tables = (ROOT / "SQL" / "04_directory" / "02_tables.sql").read_text(encoding="utf-8")
        cls.fks = (ROOT / "SQL" / "04_directory" / "90_fk_deferred.sql").read_text(encoding="utf-8")
        cls.indexes = (ROOT / "SQL" / "04_directory" / "04_indexes.sql").read_text(encoding="utf-8")

    def test_column_is_nullable_in_model_generated_sql_and_patch(self) -> None:
        m = re.search(r'CREATE TABLE IF NOT EXISTS "directory"\."tenant_memberships" \(\n(.*?)\n\);', self.tables, re.S)
        self.assertTrue(m)
        self.assertRegex(m.group(1), r'(?m)^    "origin_concept_id" uuid,$')  # sin NOT NULL ni DEFAULT
        self.assertRegex(
            self.patch,
            r'ALTER TABLE "directory"\."tenant_memberships"\n    ADD COLUMN IF NOT EXISTS "origin_concept_id" uuid;',
        )
        puml = (PUML / "diagram_04_directory.puml").read_text(encoding="utf-8")
        self.assertRegex(puml, r"(?m)^    origin_concept_id : uuid <<FK>>$")

    def test_fk_to_catalog_and_index(self) -> None:
        for sql in (self.fks, self.patch):
            self.assertRegex(
                sql,
                r'ALTER TABLE "directory"\."tenant_memberships"\n        ADD CONSTRAINT "fk_tenant_memberships_origin_concept_id" '
                r'FOREIGN KEY \("origin_concept_id"\)\n        REFERENCES "terminology"\."catalog_concepts" \("id"\)',
            )
        for sql in (self.indexes, self.patch):
            self.assertIn(
                'CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_origin_concept_id" '
                'ON "directory"."tenant_memberships" ("origin_concept_id");',
                sql,
            )

    def test_patch_does_not_backfill_the_origin(self) -> None:
        """Las filas existentes quedan NULL (= desconocido): nunca se marcan como solo-apoyo."""
        self.assertNotRegex(self.patch, r'(?is)\bUPDATE\s+"directory"\."tenant_memberships"')
        self.assertNotRegex(self.patch, r'(?i)\bSET\s+"?origin_concept_id')
        self.assertNotIn("MEMBERSHIP_ORIGIN", self.patch.split("BEGIN;", 1)[1])

    def test_concepts_are_mirrored_with_the_backend_deterministic_ids(self) -> None:
        source = GEN_SEEDS.read_text(encoding="utf-8")
        records = json.loads(TERMINOLOGY.read_text(encoding="utf-8"))["boot"]["records"]["catalog_concepts"]
        by_code = {r["code"]: r for r in records}
        for key in ORIGIN_CONCEPTS:
            self.assertIn(f'("{key}",', source, key)
            self.assertIn(key, by_code, f"{key} no está en 03_terminology")
            self.assertEqual(by_code[key]["id"], cid(key), key)
        self.assertEqual(len({by_code[k]["id"] for k in ORIGIN_CONCEPTS}), len(ORIGIN_CONCEPTS))

    def test_materialization_doc_documents_the_change(self) -> None:
        """La sección v4.2.71 de physical-materialization.md nombra la columna, el índice, los 5 conceptos y el único."""
        doc = ROOT / "Mantra Core Health Context" / "docs" / "architecture" / "physical-materialization.md"
        text = doc.read_text(encoding="utf-8")
        self.assertIn("### v4.2.71", text)
        for needle in ("origin_concept_id", "ix_tenant_memberships_origin_concept_id", "uq_identifiers_national_id_normalized",
                       "ix_identifiers_national_id_normalized", "directory:MEMBERSHIP_ORIGIN_OWNER_CREATED"):
            self.assertIn(needle, text)
        for key in ORIGIN_CONCEPTS[1:]:
            self.assertIn("_" + key.split("MEMBERSHIP_ORIGIN_")[1], text)


class NationalIdUniqueTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.patch = PATCH.read_text(encoding="utf-8")
        cls.indexes = (ROOT / "SQL" / "02_common" / "04_indexes.sql").read_text(encoding="utf-8")
        cls.puml = (PUML / "diagram_02_common.puml").read_text(encoding="utf-8")
        cls.sec = cls.patch[cls.patch.index("-- ---- 4c.") : cls.patch.index("-- ---- 5. constraints")]
        cls.predicate = (
            f"type_concept_id = '{ID_TYPE_NATIONAL}' AND state_concept_id = '{STATE_ACTIVE}' "
            f"AND owner_type_concept_id = '{OWNER_PATIENT}' AND valid_to IS NULL"
        )

    def test_generated_index_uses_the_api_expression_and_the_partial_predicate(self) -> None:
        self.assertIn(
            'CREATE UNIQUE INDEX IF NOT EXISTS "uq_identifiers_national_id_normalized" '
            f'ON "common"."identifiers" ({NORMALIZED_EXPR}) WHERE {self.predicate};',
            self.indexes,
        )
        self.assertIn(f"UK uq_identifiers_national_id_normalized : ({NORMALIZED_EXPR}) UNIQUE BTREE WHERE {self.predicate}", self.puml)

    def test_expression_is_the_one_of_the_api_sources_when_available(self) -> None:
        """Si el repo de la API está al lado (o en MANTRA_API_DIR), la expresión es literalmente la suya."""
        api = Path(os.environ.get("MANTRA_API_DIR") or ROOT.parent / "mantra-core-health-api") / "src" / "modules"
        repo = api / "delegated_access" / "repositories" / "support-patients.repository.ts"
        if not repo.exists():
            self.skipTest("el repo de la API no está junto al modelo")
        ts = repo.read_text(encoding="utf-8")
        m = re.search(r"const NORMALIZED_ID = \(column: string\): string =>\s*`(.*?)`;", ts, re.S)
        self.assertTrue(m)
        # el literal TS escapa la barra: '[\\s.-]+' en el .ts es '[\s.-]+' en SQL
        sql_form = m.group(1).replace("${column}", "value").replace("\\\\", "\\")
        self.assertEqual(sql_form, NORMALIZED_EXPR)

    def test_patch_guard_warns_instead_of_failing_and_keeps_a_support_index(self) -> None:
        sec = self.sec
        self.assertIn("RAISE WARNING", sec)
        self.assertNotIn("RAISE EXCEPTION", sec)
        self.assertIn("HINT = 'Consulta:", sec)
        self.assertIn('CREATE UNIQUE INDEX "uq_identifiers_national_id_normalized"', sec)
        self.assertRegex(sec, r'CREATE INDEX IF NOT EXISTS "ix_identifiers_national_id_normalized"')
        # el de apoyo se retira cuando el unico existe
        self.assertEqual(sec.count('DROP INDEX IF EXISTS "common"."ix_identifiers_national_id_normalized"'), 2)
        # misma expresion y mismo predicado en el diagnostico, el de apoyo y el unico
        self.assertEqual(sec.count(NORMALIZED_EXPR.replace("value,", "value,")), 3)
        self.assertGreaterEqual(sec.count(f"AND owner_type_concept_id = '{OWNER_PATIENT}'"), 3)

    def test_predicate_ids_are_the_derived_concept_ids(self) -> None:
        self.assertEqual(ID_TYPE_NATIONAL, "595e7a3d-ba37-5014-9a72-635363b94864")
        self.assertEqual(OWNER_PATIENT, "350a0150-c27c-5241-b5d8-78daa13bed34")
        self.assertEqual(STATE_ACTIVE, "38a1d301-f40d-5b17-a695-5e6d605f8b19")

    def test_the_expression_is_immutable_safe(self) -> None:
        """Un indice funcional solo admite funciones IMMUTABLE: nada de now(), current_date ni STABLE."""
        for banned in ("current_date", "now()", "current_setting", "unaccent", "concat_ws", "::date", "to_char"):
            self.assertNotIn(banned, NORMALIZED_EXPR)
            self.assertNotIn(banned, self.predicate)


if __name__ == "__main__":
    unittest.main()
