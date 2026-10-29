#!/usr/bin/env python3
"""Contrato del patch F5d (agenda de consultorios y salas) y su prueba contra Postgres real.

Dos niveles, y se dice cuál corrió:

* ESTÁTICO (siempre): el patch, diagram_41 y diagram_33 dicen lo mismo, y el patch es
  idempotente por construcción. No prueba que funcione: prueba que no se desalinearon.
* EN VIVO (sólo si hay una base): `f5d_scheduling_behavior.sql` aplicado con `psql` a una base
  DESCARTABLE que ya tiene el patch. Se activa con SALUD_F5D_PG_DSN, p. ej.
      SALUD_F5D_PG_DSN="host=localhost port=5433 user=mantra dbname=m_f5sched password=..."
  Sin la variable, esas pruebas se SALTAN (y pytest lo informa como skipped, no como passed).
  Nunca apuntar a `alovida`: la prueba abre una transacción y termina en ROLLBACK, pero el
  patch ya tiene que estar aplicado y la base debe ser un clon (CREATE DATABASE … TEMPLATE).
"""

from pathlib import Path
import os
import re
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[2]
PATCH = ROOT / "SQL" / "patches" / "2026-10-29_infraestructura_f5_scheduling.sql"
RLS_PATCH = ROOT / "SQL" / "patches" / "2026-08-05_tenant_rls.sql"
PUML_41 = ROOT / "Mantra Core Health Context" / "modules" / "diagram_41_scheduling.puml"
PUML_33 = ROOT / "Mantra Core Health Context" / "modules" / "diagram_33_integrity.puml"
BEHAVIOR = Path(__file__).resolve().parent / "sql" / "f5d_scheduling_behavior.sql"

BOOKED = "51530fd7-05b1-5c29-80c4-da740ede4d27"
CHECKED_IN = "37dded87-7a7a-5a24-86f6-0ef48cccb482"


def _compact(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def _code_only(sql: str) -> str:
    """El patch sin comentarios `--` (los literales no contienen `--`)."""
    return "\n".join(re.sub(r"--.*$", "", line) for line in sql.splitlines())


class PatchIdempotenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")
        cls.code = _code_only(cls.sql)

    def test_single_transaction(self) -> None:
        self.assertEqual(len(re.findall(r"^BEGIN;$", self.code, re.M)), 1)
        self.assertEqual(len(re.findall(r"^COMMIT;$", self.code, re.M)), 1)

    def test_every_add_column_is_if_not_exists(self) -> None:
        adds = re.findall(r"ADD COLUMN[^\n]*", self.code)
        self.assertEqual(len(adds), 5)
        for add in adds:
            self.assertIn("IF NOT EXISTS", add)

    def test_every_create_index_is_if_not_exists(self) -> None:
        creates = re.findall(r"CREATE (?:UNIQUE )?INDEX[^\n]*", self.code)
        self.assertEqual(len(creates), 5)
        for create in creates:
            self.assertIn("IF NOT EXISTS", create)

    def test_every_simple_fk_swallows_only_duplicate_object(self) -> None:
        fks = re.findall(r"ADD CONSTRAINT \"fk_[a-z_]+\" FOREIGN KEY", self.code)
        self.assertEqual(len(fks), 4)
        self.assertEqual(
            len(re.findall(r"EXCEPTION WHEN duplicate_object THEN NULL;", self.code)),
            4 + 1,  # 4 FK simples + el bucle de las FK compuestas
        )

    def test_nothing_destructive(self) -> None:
        for forbidden in ("DROP TABLE", "DROP COLUMN", "TRUNCATE", "DELETE FROM", "DROP SCHEMA"):
            self.assertNotIn(forbidden, self.code.upper())

    def test_appointments_belong_to_f5_clinical(self) -> None:
        # Integración: un solo dueño (M-F5-clin) de appointments.care_space_id y de su EXCLUDE;
        # este patch no los toca y exige ux_schedulable_resources_tenant_id_id (M-F4).
        self.assertNotRegex(self.code, r'"clinical"\."appointments"')
        self.assertNotIn("ex_appointments_care_space_time", self.code)
        self.assertNotIn("ux_schedulable_resources_tenant_id_id\" ON", self.code)
        self.assertRegex(self.code, r"indexname = 'ux_schedulable_resources_tenant_id_id'")

    def test_preconditions_come_before_every_constraint(self) -> None:
        first_constraint = min(
            self.code.index(marker)
            for marker in ('ALTER COLUMN "tenant_id" SET NOT NULL', "ADD CONSTRAINT")
        )
        for guard in (
            "OTRO tenant",
            "sin source_kind_concept_id",
            "requiere F1b",
        ):
            self.assertLess(self.code.index(guard), first_constraint, guard)


class PatchMatchesModelTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")
        cls.code = _code_only(cls.sql)
        cls.p41 = PUML_41.read_text(encoding="utf-8")
        cls.p33 = PUML_33.read_text(encoding="utf-8")

    def test_exclude_predicate_is_the_practitioner_one_with_the_space(self) -> None:
        # La del espacio (declarada una sola vez, por M-F5-clin) es la hermana del profesional con
        # `care_space_id` en lugar del profesional y los mismos dos estados.
        sister = re.search(
            r"EXCLUDE_SQL : ex_appointments_practitioner_time \| (.+?) \| (.+)", self.p33
        )
        self.assertIsNotNone(sister)
        expected_elements = sister.group(1).replace("practitioner_profile_id", "care_space_id")
        expected_predicate = sister.group(2).replace(
            '"practitioner_profile_id" IS NOT NULL', '"care_space_id" IS NOT NULL'
        )
        self.assertEqual(set(re.findall(r"[0-9a-f]{8}-[0-9a-f-]{27}", expected_predicate)), {BOOKED, CHECKED_IN})
        declared = re.findall(r"EXCLUDE_SQL : ex_appointments_care_space_time \| (.+?) \| (.+)", self.p33)
        self.assertEqual(len(declared), 1, "un solo dueño del EXCLUDE de citas por espacio")
        self.assertEqual(declared[0], (expected_elements, expected_predicate))

    def test_practitioner_rule_is_left_alone(self) -> None:
        self.assertEqual(self.p33.count("ex_appointments_practitioner_time |"), 1)
        self.assertNotIn("ex_appointments_practitioner_time", self.code)

    def test_check_matches_diagram_33(self) -> None:
        m = re.search(r"CHECK_SQL : ck_availability_exceptions_source_ref_needs_kind \| (.+)", self.p33)
        self.assertIsNotNone(m)
        self.assertIn(_compact(f"CHECK ({m.group(1)})"), _compact(self.code))

    def test_diagram_41_declares_every_column_the_patch_adds(self) -> None:
        def entity(name: str) -> str:
            start = self.p41.index(f"\nentity {name} {{")
            return self.p41[start : self.p41.index("\n}", start)]

        templates, exceptions = entity("schedule_templates"), entity("availability_exceptions")
        self.assertRegex(templates, r"\* tenant_id : uuid <<FK>>")
        self.assertRegex(templates, r"\n\s+care_space_id : uuid <<FK>>")
        self.assertRegex(exceptions, r"\* tenant_id : uuid <<FK>>")
        self.assertRegex(exceptions, r"\n\s+source_kind_concept_id : uuid <<FK>>")
        self.assertRegex(exceptions, r"\n\s+source_ref_id : uuid\n")

    def test_diagram_41_declares_every_index_the_patch_creates(self) -> None:
        patch_indexes = set(re.findall(r'INDEX IF NOT EXISTS "([a-z_]+)"', self.code))
        declared = set(re.findall(r"(?:IX|UX) ([a-z_]+) :", self.p41))
        self.assertLessEqual(patch_indexes - declared, set())
        self.assertTrue({"ix_schedule_templates_care_space_id", "ix_availability_exceptions_tenant_id"} <= declared)

    def test_verification_counts_match_the_header_deltas(self) -> None:
        self.assertIn("n_columnas <> 5", self.code)
        self.assertIn("n_fk <> 7", self.code)
        self.assertIn("n_idx <> 5", self.code)
        self.assertIn("n_tg <> 2", self.code)
        block = self.code[self.code.index("SELECT count(*) INTO n_fk") :]
        block = block[: block.index("INTO n_idx")]
        self.assertEqual(len(set(re.findall(r"'(fk_[a-z_]+)'", block))), 7)

    def test_composite_fks_cover_tenant_and_parent(self) -> None:
        for name in (
            "fk_schedule_templates_tenant_resource",
            "fk_schedule_templates_tenant_care_space",
            "fk_availability_exceptions_tenant_resource",
        ):
            self.assertIn(f"'{name}'", self.code)
        self.assertIn('FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")', self.code)


class RlsPolicyTests(unittest.TestCase):
    def test_policy_is_the_one_of_the_tenant_rls_patch(self) -> None:
        def policy(sql: str) -> str:
            m = re.search(r"CREATE POLICY tenant_isolation ON %\w*(?:\.%\w*)?\s+(USING \(.*?\)\s+WITH CHECK \(.*?\))\s*\$pol\$", sql, re.S)
            self.assertIsNotNone(m)
            return _compact(m.group(1))

        self.assertEqual(
            policy(PATCH.read_text(encoding="utf-8")),
            policy(RLS_PATCH.read_text(encoding="utf-8")),
        )

    def test_rls_is_forced_on_both_tables(self) -> None:
        code = _code_only(PATCH.read_text(encoding="utf-8"))
        self.assertIn("ENABLE ROW LEVEL SECURITY", code)
        self.assertIn("FORCE ROW LEVEL SECURITY", code)
        self.assertIn("'scheduling.schedule_templates'", code)
        self.assertIn("'scheduling.availability_exceptions'", code)


@unittest.skipUnless(
    os.environ.get("SALUD_F5D_PG_DSN") and shutil.which("psql"),
    "sin SALUD_F5D_PG_DSN (base descartable con el patch aplicado) y psql: pruebas en vivo NO ejecutadas",
)
class LivePostgresBehaviorTests(unittest.TestCase):
    """Corre f5d_scheduling_behavior.sql: 38 comprobaciones PASS/FAIL en una transacción con ROLLBACK."""

    def test_behavior_script_passes(self) -> None:
        dsn = os.environ["SALUD_F5D_PG_DSN"]
        self.assertNotRegex(dsn, r"dbname=alovida\b", "no correr contra la base viva `alovida`")
        result = subprocess.run(
            ["psql", dsn, "-v", "ON_ERROR_STOP=1", "-X", "-q", "-f", str(BEHAVIOR)],
            capture_output=True,
            text=True,
            timeout=300,
        )
        self.assertEqual(result.returncode, 0, result.stdout[-3000:] + result.stderr[-1500:])
        self.assertNotIn("| FAIL", result.stdout)
        total = re.search(r"\n\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\n", result.stdout)
        self.assertIsNotNone(total, result.stdout[-800:])
        passed, failed, count = map(int, total.groups())
        self.assertEqual((failed, passed), (0, count))
        self.assertGreaterEqual(count, 38)


if __name__ == "__main__":
    unittest.main()
