"""v4.2.91 — una encuesta activa por servicio y profesional; procedencia del catálogo estándar.

Sin base de datos: comprueba que el DDL generado (`SQL/65_surveys/`) y el parche
`2026-11-06_v4291_surveys_encuesta_por_servicio.sql` declaran lo mismo, que el índice único
parcial es el de SERVICE y que el parche desactiva duplicados ANTES de crear el índice.
"""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / "SQL" / "65_surveys"
PATCH = (ROOT / "SQL" / "patches" / "2026-11-06_v4291_surveys_encuesta_por_servicio.sql").read_text(encoding="utf-8")
PUML = (ROOT / "Mantra Core Health Context" / "modules" / "diagram_65_surveys.puml").read_text(encoding="utf-8")
SERVICE = "0a48774c-6a99-50f7-b485-71899fba56c5"  # deterministicId('surveys:TARGET_SERVICE')

NEW_INDEXES = (
    "uq_survey_templates_practitioner_catalog_code",
    "uq_survey_templates_party_catalog_code",
    "uq_survey_assignments_active_service_owner",
    "ix_survey_assignments_owner_practitioner_id",
)


def generated(phase: str) -> str:
    return (MODULE / phase).read_text(encoding="utf-8")


def statement(sql: str, name: str) -> str:
    m = re.search(rf'^CREATE (?:UNIQUE )?INDEX IF NOT EXISTS "{name}" .*;$', sql, re.M)
    assert m, name
    return m.group(0)


class SurveysServiceOwnerV4291(unittest.TestCase):
    def test_columns_are_generated_and_added_by_the_patch(self):
        tables = generated("02_tables.sql")
        self.assertIn('"standard_catalog_code" text,', tables)
        self.assertIn('"owner_practitioner_id" uuid,', tables.split('"survey_assignments"', 1)[1])
        self.assertIn('ADD COLUMN IF NOT EXISTS "standard_catalog_code" text', PATCH)
        self.assertIn('ADD COLUMN IF NOT EXISTS "owner_practitioner_id" uuid', PATCH)

    def test_indexes_and_check_are_copied_verbatim(self):
        idx = generated("04_indexes.sql")
        for name in NEW_INDEXES:
            self.assertEqual(statement(idx, name), statement(PATCH, name), name)
        ck = re.search(r'^ALTER TABLE .* ADD CONSTRAINT "ck_survey_templates_standard_catalog_code" .*;$',
                       generated("05_constraints.sql"), re.M).group(0)
        self.assertIn(ck, PATCH)

    def test_owner_fk_points_to_the_practitioner_profile(self):
        fk = generated("90_fk_deferred.sql")
        self.assertRegex(fk, re.compile(
            r'"fk_survey_assignments_owner_practitioner_id" FOREIGN KEY \("owner_practitioner_id"\)\s+'
            r'REFERENCES "profiles"\."health_practitioner_profiles" \("profile_id"\)'))
        self.assertIn('"fk_survey_assignments_owner_practitioner_id"', PATCH)
        self.assertIn("survey_assignments }o--o| profiles_health_practitioner_profiles : owner_practitioner_id", PUML)

    def test_unique_index_is_per_service_and_practitioner_while_active(self):
        sql = statement(generated("04_indexes.sql"), "uq_survey_assignments_active_service_owner")
        self.assertIn('("tenant_id", "target_type_concept_id", "target_id", "owner_practitioner_id")', sql)
        self.assertIn("active = true", sql)
        self.assertIn("owner_practitioner_id IS NOT NULL", sql)
        self.assertIn(f"target_type_concept_id = '{SERVICE}'", sql)
        # La regla anterior sigue para los demás destinos.
        self.assertIn('"uq_survey_assignments_active_target"', generated("04_indexes.sql"))

    def test_patch_deduplicates_before_the_index_and_keeps_the_newest(self):
        body = PATCH.split("BEGIN;", 1)[1]
        self.assertTrue(body.strip().endswith("COMMIT;"))
        dedup = body.index('SET "active" = false')
        self.assertLess(body.index("ORDER BY a.\"created_at\" DESC, a.\"id\" DESC"), dedup)
        self.assertLess(dedup, body.index('"uq_survey_assignments_active_service_owner"'))
        self.assertLess(body.index('SET "owner_practitioner_id" = t."owner_practitioner_id"'), dedup)

    def test_trigger_keeps_the_owner_equal_to_the_template(self):
        self.assertIn('CREATE OR REPLACE FUNCTION "integrity"."survey_assignment_owner_from_template"()', PATCH)
        self.assertIn("DROP TRIGGER IF EXISTS trg_survey_assignments_owner_from_template", PATCH)
        self.assertIn("USING ERRCODE = 'check_violation'", PATCH)

    def test_trigger_is_generated_into_the_base_ddl_verbatim(self):
        # v4.2.93: a database built from scratch (apply_all.sql) has the trigger without the patch.
        sql = generated("05_constraints.sql")
        start = sql.index('CREATE OR REPLACE FUNCTION "integrity"."survey_assignment_owner_from_template"()')
        block = sql[start:sql.index("FOR EACH ROW", start)]
        self.assertIn("CREATE TRIGGER trg_survey_assignments_owner_from_template", block)
        self.assertIn(block, PATCH)

    def test_patch_is_idempotent(self):
        self.assertNotIn('CREATE INDEX "', PATCH)
        self.assertNotIn('CREATE UNIQUE INDEX "', PATCH)
        self.assertNotRegex(PATCH, r"ADD COLUMN (?!IF NOT EXISTS)")


if __name__ == "__main__":
    unittest.main()
