"""v4.2.94 — marca 3D del cuerpo y tipo de hueso en la orden de estudio.

Sin base de datos: comprueba que el DDL generado (`SQL/`) y el parche
`2026-11-06_v4294_service_request_3d_site_bone_type.sql` declaran lo mismo (columnas, FK, índices,
CHECK), que los cinco conceptos del tipo de hueso llevan el id que deriva la API de la clave y su
procedencia, y que las semillas del parche son idempotentes por construcción.
La prueba contra una base real (aplicar dos veces, deriva contra una base creada desde el modelo)
se corrió aparte y está en docs/trabajo/2026-11-06-orden-estudio-sitio-corporal-hueso/.
"""
import json
import re
import unittest
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQL = ROOT / "SQL"
PATCH = (SQL / "patches" / "2026-11-06_v4294_service_request_3d_site_bone_type.sql").read_text(encoding="utf-8")
CLIN = SQL / "08_clinical"

# Mismo namespace que HEALTH_UUID_NAMESPACE de la API (concepts.ts) y BACKEND_NAMESPACE de gen_seeds.py.
BACKEND_NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")

NEW_COLUMNS = ('"body_structure_uberon" varchar(64)', '"body_mesh_id" varchar(64)', '"bone_type_concept_id" uuid')

# clave -> (clase UBERON, xref FMA). Verificadas contra
# mantra-core-health/public/anatomy-atlas-3d/catalog (UBERON release 2026-10-01).
BONE_TYPES = {
    "clinical:BONE_TYPE_LONG": ("UBERON:0002495", "FMA:7474"),
    "clinical:BONE_TYPE_SHORT": ("UBERON:0013630", "FMA:7475"),
    "clinical:BONE_TYPE_FLAT": ("UBERON:0010428", "FMA:7476"),
    "clinical:BONE_TYPE_IRREGULAR": ("UBERON:0008001", "FMA:7477"),
    "clinical:BONE_TYPE_SESAMOID": ("UBERON:0001479", "FMA:32672"),
}


def phase(name: str) -> str:
    return (CLIN / name).read_text(encoding="utf-8")


class ServiceRequest3dBoneV4294(unittest.TestCase):
    def test_columns_in_ddl_and_patch(self):
        tables = phase("02_tables.sql")
        for col in NEW_COLUMNS:
            self.assertIn(col, tables)
            self.assertIn(col.split(" ", 1)[0], PATCH)
            self.assertIn(f"ADD COLUMN IF NOT EXISTS {col}", PATCH)

    def test_indexes_in_ddl_and_patch(self):
        for name in ("ix_service_requests_bone_type_concept_id", "ix_service_requests_body_structure_uberon"):
            self.assertIn(f'INDEX IF NOT EXISTS "{name}"', phase("04_indexes.sql"))
            self.assertIn(f'INDEX IF NOT EXISTS "{name}"', PATCH)

    def test_fk_in_ddl_and_patch(self):
        fks = phase("03_fk_intra.sql") + phase("90_fk_deferred.sql")
        self.assertRegex(
            fks, r'"fk_service_requests_bone_type_concept_id" FOREIGN KEY \("bone_type_concept_id"\)\s+'
                 r'REFERENCES "terminology"\."catalog_concepts" \("id"\)')
        self.assertIn('"fk_service_requests_bone_type_concept_id" FOREIGN KEY ("bone_type_concept_id")', PATCH)

    def test_checks_match_between_ddl_and_patch(self):
        for name in ("ck_service_requests_specimen_xor_imaging", "ck_service_requests_bone_type_requires_location"):
            ddl = re.search(rf'ADD CONSTRAINT "{name}" CHECK (\(.*?\));', phase("05_constraints.sql"))
            patch = re.search(rf'ADD CONSTRAINT "{name}"\s+CHECK (\(.*?\));', PATCH, re.S)
            self.assertTrue(ddl and patch, name)
            self.assertEqual(ddl.group(1), patch.group(1), name)

    def test_xor_excludes_the_new_imaging_columns(self):
        xor = re.search(r'ADD CONSTRAINT "ck_service_requests_specimen_xor_imaging" CHECK (\(.*?\));',
                        phase("05_constraints.sql")).group(1)
        for col in ("modality_concept_id", "body_site_concept_id", "laterality_concept_id", "contrast_concept_id",
                    "body_structure_uberon", "body_mesh_id", "bone_type_concept_id"):
            self.assertIn(f'"{col}" IS NULL', xor)

    def test_bone_type_concepts_use_the_api_derived_id_and_the_key_as_code(self):
        for key in BONE_TYPES:
            cid = str(uuid.uuid5(BACKEND_NAMESPACE, key))
            self.assertRegex(PATCH, rf"\('{cid}', '[0-9a-f-]{{36}}', '{key}', '[A-Za-z ]+', false, true, now\(\), now\(\), 1\)")

    def test_every_concept_carries_provenance(self):
        for key, (uberon, fma) in BONE_TYPES.items():
            cid = str(uuid.uuid5(BACKEND_NAMESPACE, key))
            row = re.search(rf"\('[0-9a-f-]{{36}}'::uuid, '{cid}'::uuid, 'provenance', .*?'(\{{.*?\}})'::jsonb", PATCH)
            self.assertIsNotNone(row, key)
            prov = json.loads(row.group(1))
            self.assertEqual(prov["uberon_id"], uberon)
            self.assertEqual(prov["fma_id"], fma)
            self.assertEqual(prov["license"], "CC-BY 3.0")
            self.assertEqual(prov["release"], "2026-10-01")
            self.assertEqual(prov["catalog_kind"], "internal")
            for field in ("source", "url", "sha256", "license_url", "verified_on"):
                self.assertTrue(prov[field], f"{key}:{field}")

    def test_seeds_are_idempotent_by_construction(self):
        self.assertIn("ON CONFLICT DO NOTHING", PATCH)
        self.assertIn("WHERE NOT EXISTS", PATCH)
        self.assertNotIn("TRUNCATE", PATCH.upper())
        self.assertNotIn("DELETE FROM", PATCH.upper())

    def test_no_value_is_derived_from_the_region(self):
        # El tipo de hueso lo elige el médico: ninguna relación región -> hueso en el parche.
        self.assertNotIn("concept_relationships", PATCH)
        self.assertNotIn("body_site_concept_id\" =", PATCH)


if __name__ == "__main__":
    unittest.main()
