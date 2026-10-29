"""Integración del modelo de infraestructura hospitalaria (F1c, F2, F3, F4, F5a–F5g).

Tres niveles, y cada uno dice cuál corrió:

* ESTÁTICO (siempre): el orden de los patches cumple sus dependencias en el orden en que
  `postgres-init` los aplica; los seeds del paquete no incumplen las reglas nuevas
  (tenant coherente con el padre, un check-list por (caso, tipo), sala y sede del tenant del caso);
  el cargador de seeds no usa `ON CONFLICT DO NOTHING` sin objetivo en tablas con restricciones
  diferibles; el generador de integridad expresa `DEFERRABLE`.
* EN VIVO (solo con SALUD_TEST_PGDATABASE): contra una base INTEGRADA y descartable
  (`apply_all.sql` + `apply_deferred.sql` + NoSQL 58/59 + todos los patches), corre el barrido
  de `sql/integ_10_sweep.sql` y las invariantes cruzadas de `sql/integ_20_cross_invariants.sql`.
  Sin la variable, esas pruebas se SALTAN (pytest las informa como skipped, no como passed).

Nunca apuntar a `alovida`.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
PATCHES = ROOT / "SQL" / "patches"
SEEDS = ROOT / "seedsGenerales" / "modules"
sys.path.insert(0, str(HERE.parent))

# Dependencias DURAS entre patches de la serie (cada uno aborta si falta su prerrequisito).
HARD_PREREQS = {
    "f1b_seguridad": ["f1"],
    "f1c_plano": ["f1b_seguridad"],
    "f2_practice": ["f1b_seguridad"],
    "f3_clinical": ["f1b_seguridad"],
    "f4z_periop": ["f1b_seguridad", "f4_scheduling"],
    "f5_accounting": ["f1"],
    "f5_billing": ["f1b_seguridad", "f5_accounting"],
    "f5_clinical": ["f1b_seguridad"],
    "f5_practice": ["f1b_seguridad"],
    "f5_scheduling": ["f1b_seguridad", "f4_scheduling"],
    "f5z_diagnostics": ["f1", "f5_operaciones"],
}


def init_order() -> list[str]:
    """Orden de `postgres-init`: glob de bash en C.UTF-8 = orden de bytes del nombre."""
    names = sorted(p.name.encode("utf-8") for p in PATCHES.glob("*.sql"))
    return [n.decode("utf-8") for n in names]


class PatchOrderTests(unittest.TestCase):
    def test_every_hard_prerequisite_sorts_before_its_dependent(self) -> None:
        order = init_order()
        pos = {n: i for i, n in enumerate(order)}
        for patch, prereqs in HARD_PREREQS.items():
            mine = f"2026-10-29_infraestructura_{patch}.sql"
            self.assertIn(mine, pos, mine)
            for pre in prereqs:
                dep = f"2026-10-29_infraestructura_{pre}.sql"
                self.assertIn(dep, pos, dep)
                self.assertLess(pos[dep], pos[mine], f"{dep} debe aplicarse antes que {mine}")

    def test_the_series_has_exactly_the_expected_patches(self) -> None:
        got = {n[len("2026-10-29_infraestructura_"):-len(".sql")] for n in init_order()
               if n.startswith("2026-10-29_infraestructura_")}
        self.assertEqual(got, {
            "f1", "f1b_seguridad", "f1c_plano", "f2_practice", "f3_clinical", "f4_scheduling", "f4z_periop",
            "f5_accounting", "f5_billing", "f5_clinical", "f5_operaciones", "f5_practice", "f5_scheduling",
            "f5z_diagnostics"})

    def test_no_patch_is_skipped_by_the_backfill_filter(self) -> None:
        # init-postgres.sh omite en base nueva todo lo que contenga «backfill» en el nombre
        for n in init_order():
            if n.startswith("2026-10-29_infraestructura_"):
                self.assertNotIn("backfill", n)
                self.assertFalse(n.endswith("_dev_seed.sql"))

    def test_error_paths_of_prerequisite_checks_do_not_concatenate_text_to_arrays(self) -> None:
        # `faltan := faltan || 'texto'` con faltan text[] revienta con «malformed array literal»
        # justo cuando hay que informar lo que falta.
        for p in PATCHES.glob("2026-10-29_infraestructura_*.sql"):
            code = re.sub(r"--.*", "", p.read_text(encoding="utf-8"))
            self.assertNotRegex(code, r"faltan\s*:=\s*faltan\s*\|\|\s*'", p.name)

    def test_old_patches_do_not_undo_the_new_ones(self) -> None:
        legacy = (PATCHES / "2026-10-24_v4249_organizacion_medica.sql").read_text(encoding="utf-8")
        self.assertIn("ex_procedure_cases_operating_room_reserved_time", legacy)
        f1b = (PATCHES / "2026-10-29_infraestructura_f1b_seguridad.sql").read_text(encoding="utf-8")
        self.assertIn("'practice_sites_history', 'clinical_units_history', 'care_spaces_history'", f1b)
        v4216 = (PATCHES / "2026-09-16_v4216_encounters_content_hash.sql").read_text(encoding="utf-8")
        self.assertNotIn("n_columnas <> 20", v4216)


def _rows(doc: dict, entity: str):
    for section in ("boot", "mock"):
        for row in doc.get(section, {}).get("records", {}).get(entity, []):
            yield row


class SeedCoherenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        load = lambda n: json.loads((SEEDS / f"{n}.seeds.json").read_text(encoding="utf-8"))
        cls.d08, cls.d14, cls.d41, cls.d53 = (load("08_clinical"), load("14_practice"), load("41_scheduling"),
                                               load("53_procedures_perioperative"))
        cls.spaces = {r["id"]: r for r in _rows(cls.d14, "care_spaces")}
        cls.sites = {r["id"]: r for r in _rows(cls.d14, "practice_sites")}

    def test_checklists_are_unique_per_case_and_type(self) -> None:
        seen = set()
        for r in _rows(self.d53, "surgical_safety_checklists"):
            key = (r["procedure_case_id"], r["checklist_type_concept_id"])
            self.assertNotIn(key, seen)
            seen.add(key)

    def test_procedure_cases_use_a_room_and_site_of_their_tenant(self) -> None:
        for c in _rows(self.d53, "procedure_cases"):
            tenant = c["custodian_tenant_id"]
            if c.get("operating_room_id"):
                room = self.spaces[c["operating_room_id"]]
                self.assertEqual(room["tenant_id"], tenant, c["id"])
                if c.get("practice_site_id"):
                    self.assertEqual(room["practice_site_id"], c["practice_site_id"], c["id"])
            if c.get("practice_site_id"):
                self.assertEqual(self.sites[c["practice_site_id"]]["tenant_id"], tenant, c["id"])

    def test_utilization_events_follow_their_case(self) -> None:
        cases = {c["id"]: c for c in _rows(self.d53, "procedure_cases")}
        for e in _rows(self.d53, "operating_room_utilization_events"):
            case = cases[e["procedure_case_id"]]
            self.assertEqual(e["tenant_id"], case["custodian_tenant_id"])
            self.assertEqual(e.get("operating_room_id"), case.get("operating_room_id"))

    def test_scheduling_rows_carry_the_tenant_of_their_resource(self) -> None:
        res = {r["id"]: r for r in _rows(self.d41, "schedulable_resources")}
        for entity in ("schedule_templates", "availability_exceptions"):
            for r in _rows(self.d41, entity):
                self.assertEqual(r["tenant_id"], res[r["resource_id"]]["tenant_id"], f"{entity} {r['id']}")

    def test_encounter_locations_follow_their_encounter_tenant(self) -> None:
        enc = {e["id"]: e for e in _rows(self.d08, "encounters")}
        units = {u["id"]: u for u in _rows(self.d14, "clinical_units")}
        for loc in _rows(self.d08, "encounter_locations"):
            tenant = enc[loc["encounter_id"]]["tenant_id"]
            self.assertEqual(loc["tenant_id"], tenant, loc["id"])
            for col, pool in (("care_space_id", self.spaces), ("practice_site_id", self.sites),
                              ("clinical_unit_id", units)):
                if loc.get(col):
                    self.assertEqual(pool[loc[col]]["tenant_id"], tenant, f"{col} de {loc['id']}")


class SeedLoaderTests(unittest.TestCase):
    def test_deferrable_tables_get_a_targeted_on_conflict(self) -> None:
        import load_seeds
        args = ('"clinical"."encounter_locations"', '"id", "x"', "%s, %s", ["id", "x"], ["id"], False)
        self.assertIn("ON CONFLICT DO NOTHING", load_seeds.upsert_sql(*args))
        sql = load_seeds.upsert_sql(*args, deferrable=True)
        self.assertIn('ON CONFLICT ("id") DO NOTHING', sql)
        self.assertNotIn("ON CONFLICT DO NOTHING", sql)

    def test_the_three_exclusions_of_encounter_locations_are_deferrable_in_the_generated_sql(self) -> None:
        sql = (ROOT / "SQL" / "08_clinical" / "05_constraints.sql").read_text(encoding="utf-8")
        for name in ("ex_encounter_locations_bed_occupancy", "ex_encounter_locations_encounter_single_bed",
                     "ex_encounter_locations_encounter_one_active_bed"):
            m = re.search(r'ADD CONSTRAINT "%s"\s+EXCLUDE USING gist .*?;' % name, sql, re.S)
            self.assertIsNotNone(m, name)
            self.assertIn("DEFERRABLE INITIALLY IMMEDIATE", m.group(0), name)


DB = os.environ.get("SALUD_TEST_PGDATABASE")


def _psql(script: str):
    cmd = ["psql", "-h", os.environ.get("SALUD_TEST_PGHOST", "localhost"), "-p", os.environ.get("SALUD_TEST_PGPORT", "5433"),
           "-U", os.environ.get("SALUD_TEST_PGUSER", "mantra"), "-d", DB, "-X", "-q", "-v", "ON_ERROR_STOP=1",
           "-f", str(HERE / "sql" / script)]
    return subprocess.run(cmd, capture_output=True, text=True, timeout=600, cwd=str(HERE / "sql"))


# Hallazgos conocidos del barrido R2, fuera del alcance de esta serie (no los introduce ningún patch de F1c–F5):
# se declaran para que el barrido falle ante CUALQUIER hallazgo nuevo.
KNOWN_R2 = {
    # lo cubre trg charge_captures_guard (23503 si el encuentro es de otro tenant o práctica), no una FK compuesta
    "billing.charge_captures.encounter_id → clinical.encounters",
    # columnas anteriores a la serie, con FK simple al padre; la API valida la pertenencia
    "scheduling.schedulable_resources.practice_id → practice.practices",
    "scheduling.schedule_templates.booking_policy_id → scheduling.booking_policies",
}


@unittest.skipUnless(DB and shutil.which("psql"),
                     "sin SALUD_TEST_PGDATABASE (base integrada y descartable) y psql: pruebas en vivo NO ejecutadas")
class IntegratedDatabaseTests(unittest.TestCase):
    def test_database_is_not_the_live_one(self) -> None:
        self.assertNotEqual(DB, "alovida")

    def test_sweep_has_no_unexpected_findings(self) -> None:
        r = _psql("integ_10_sweep.sql")
        self.assertEqual(r.returncode, 0, r.stderr[-2000:])
        findings = [l for l in r.stdout.splitlines() if l.startswith("HALLAZGO|")]
        unexpected = [f for f in findings if not (f.startswith("HALLAZGO|R2 FK sin par compuesta (tenant)|")
                                                  and f.split("|", 2)[2] in KNOWN_R2)]
        self.assertEqual(unexpected, [])
        self.assertEqual({f.split("|", 2)[2] for f in findings}, KNOWN_R2, "un hallazgo conocido desapareció: actualizar KNOWN_R2")

    def test_cross_invariants(self) -> None:
        r = _psql("integ_20_cross_invariants.sql")
        self.assertEqual(r.returncode, 0, (r.stdout + r.stderr)[-3000:])
        ok = re.findall(r"CASO OK \[", r.stderr + r.stdout)
        self.assertNotIn("CASO FALLIDO", r.stderr + r.stdout)
        self.assertGreaterEqual(len(ok), 35)

    def test_f5_clinical_and_diagnostic_coherence(self) -> None:
        # M-F5-clin no dejó pruebas de comportamiento versionadas: estas son las de la integración
        r = _psql("integ_30_f5clin.sql")
        self.assertEqual(r.returncode, 0, (r.stdout + r.stderr)[-3000:])
        self.assertNotIn("CASO FALLIDO", r.stderr + r.stdout)
        self.assertGreaterEqual(len(re.findall(r"CASO OK \[", r.stderr + r.stdout)), 7)


if __name__ == "__main__":
    unittest.main()
