"""Contrato estático de F3 (internación / ADT) — sin base de datos.

Comprueba que el patch `2026-10-29_infraestructura_f3_clinical.sql`, los tres `.puml` que
toca (08 clinical, 10 audit, 33 integrity) y lo que `gen_ddl.py` / `gen_integrity.py`
emiten a partir de ellos cuentan lo mismo. Los generadores se corren SOBRE UNA COPIA en un
directorio temporal: este test nunca escribe en `SQL/` del repositorio (esos archivos son del
integrador del modelo).

La prueba contra Postgres real está en `test_infra_f3_clinical_db.py`.
"""
from __future__ import annotations

import hashlib
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PATCH = REPO / "SQL" / "patches" / "2026-10-29_infraestructura_f3_clinical.sql"
MODULES = REPO / "Mantra Core Health Context" / "modules"
PUML_08 = MODULES / "diagram_08_clinical.puml"
PUML_10 = MODULES / "diagram_10_audit.puml"
PUML_33 = MODULES / "diagram_33_integrity.puml"

# Namespace de common/constants/concepts.ts de la API (HEALTH_UUID_NAMESPACE).
HEALTH_UUID_NAMESPACE = "3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60"


def deterministic_id(key: str) -> str:
    """Réplica de `deterministicId()` de la API: UUID v5 (SHA-1) sobre el namespace del modelo."""
    digest = hashlib.sha1(bytes.fromhex(HEALTH_UUID_NAMESPACE.replace("-", "")) + key.encode()).digest()[:16]
    b = bytearray(digest)
    b[6] = (b[6] & 0x0F) | 0x50
    b[8] = (b[8] & 0x3F) | 0x80
    h = b.hex()
    return f"{h[:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:]}"


F3_TABLES_CLINICAL = ["placement_incidents", "inpatient_census_days", "inpatient_census_entries",
                      "inpatient_census_adjustments"]
F3_TABLES_AUDIT = ["encounter_locations_history", "placement_incidents_history"]
EXCLUDES = ["ex_encounter_locations_bed_occupancy", "ex_encounter_locations_encounter_single_bed",
            "ex_encounter_locations_encounter_one_active_bed"]
CHECKS = ["ck_encounter_locations_bed_period", "ck_encounter_locations_bed_period_order",
          "ck_placement_incidents_justification_length", "ck_placement_incidents_violations_array",
          "ck_inpatient_census_days_counts", "ck_inpatient_census_days_closed_has_hash",
          "ck_inpatient_census_adjustments_field_code", "ck_inpatient_census_adjustments_reason"]
NEW_COLUMNS_ENCOUNTERS = ["level_of_care_concept_id", "admission_source_concept_id",
                          "discharge_disposition_concept_id", "isolation_precaution_concept_id",
                          "isolation_organism_text", "expected_discharge_at"]
NEW_COLUMNS_LOCATIONS = ["tenant_id", "is_bed_assignment", "movement_type_concept_id",
                         "previous_encounter_location_id", "end_reason_concept_id",
                         "bed_category_concept_id", "placement_incident_id"]


class DeterministicIdTests(unittest.TestCase):
    def test_replica_matches_a_literal_already_in_the_model(self) -> None:
        # ce54425b… está en diagram_33 (bloque F5g) como delegated_access:ASSIGN_ROLE_UNIT_HEAD.
        self.assertEqual(deterministic_id("delegated_access:ASSIGN_ROLE_UNIT_HEAD"),
                         "ce54425b-5479-57f1-8bb2-274a8617723c")
        self.assertIn("ce54425b-5479-57f1-8bb2-274a8617723c", PUML_33.read_text(encoding="utf-8"))


class PatchShapeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")

    def test_runs_in_one_transaction_with_system_context(self) -> None:
        self.assertRegex(self.sql, r"(?m)^BEGIN;$")
        self.assertRegex(self.sql, r"(?m)^COMMIT;$")
        self.assertIn("SET LOCAL app.system_context = 'true';", self.sql)

    @staticmethod
    def _code(sql: str) -> str:
        """El patch sin comentarios de línea (los comentarios nombran lo que el código hace)."""
        return "\n".join(l for l in sql.splitlines() if not l.lstrip().startswith("--"))

    def test_is_idempotent_by_construction(self) -> None:
        body = self._code(self.sql)
        self.assertEqual(len(re.findall(r"ADD COLUMN(?! IF NOT EXISTS)", body)), 0)
        self.assertEqual(len(re.findall(r"ADD COLUMN IF NOT EXISTS", body)), 13)
        self.assertEqual(len(re.findall(r"CREATE TABLE(?! IF NOT EXISTS)", body)), 0)
        self.assertEqual(len(re.findall(r"^CREATE (?:UNIQUE )?INDEX(?! IF NOT EXISTS)", body, re.M)), 0)
        self.assertEqual(len(re.findall(r"^CREATE TABLE IF NOT EXISTS", body, re.M)), 6)
        # cada ADD CONSTRAINT vive dentro de un DO guardado (duplicate_object o IF NOT EXISTS)
        for m in re.finditer(r"ADD CONSTRAINT", body):
            before = body[: m.start()]
            self.assertGreater(before.rfind("DO $$"), before.rfind("END $$;"),
                               "ADD CONSTRAINT fuera de un bloque DO guardado")

    def test_is_not_destructive(self) -> None:
        body = self._code(self.sql)
        for forbidden in (r"\bDROP TABLE\b", r"\bDROP COLUMN\b", r"\bTRUNCATE TABLE\b", r"\bDELETE FROM\b",
                          r"\bRENAME\b", r"-X\s+ours", r"\bDROP SCHEMA\b"):
            self.assertIsNone(re.search(forbidden, body, re.I), forbidden)
        # el único DROP CONSTRAINT es el de un EXCLUDE no diferible (se recrea diferible)
        drops = re.findall(r'DROP CONSTRAINT "(\w+)"', body)
        self.assertEqual(sorted(drops), sorted(EXCLUDES))

    def test_all_three_excludes_are_deferrable_and_use_literal_uuids(self) -> None:
        for name in EXCLUDES:
            m = re.search(r'ADD CONSTRAINT "%s"\s+EXCLUDE USING gist.*?DEFERRABLE INITIALLY IMMEDIATE;' % name,
                          self.sql, re.S)
            self.assertIsNotNone(m, name)
            self.assertNotIn("(SELECT", m.group(0))   # el predicado debe ser IMMUTABLE: nada de subconsultas
            self.assertNotIn("deterministic", m.group(0).lower())

    def test_exclude_literals_are_the_deterministic_ids_of_the_api(self) -> None:
        active = deterministic_id("clinical:LOCATION_ACTIVE")
        completed = deterministic_id("clinical:LOCATION_COMPLETED")
        reserved = deterministic_id("clinical:LOCATION_RESERVED")
        for literal, key in ((active, "LOCATION_ACTIVE"), (completed, "LOCATION_COMPLETED"),
                             (reserved, "LOCATION_RESERVED")):
            self.assertIn(f"{literal} = clinical:{key}", self.sql, key)
        occ = re.search(r'ADD CONSTRAINT "ex_encounter_locations_bed_occupancy".*?;', self.sql, re.S).group(0)
        for literal in (active, reserved, completed):
            self.assertIn(literal, occ)
        single = re.search(r'ADD CONSTRAINT "ex_encounter_locations_encounter_single_bed".*?;', self.sql, re.S).group(0)
        self.assertIn(active, single)
        self.assertIn(completed, single)
        self.assertNotIn(reserved, single)   # «la reserva de traslado puede convivir»
        one = re.search(r'ADD CONSTRAINT "ex_encounter_locations_encounter_one_active_bed".*?;', self.sql, re.S).group(0)
        self.assertIn(active, one)
        self.assertNotIn(completed, one)
        # backfill de camas: ⟨practice:LOC_FORM_BED⟩
        self.assertIn(deterministic_id("practice:LOC_FORM_BED"), self.sql)

    def test_contract_check_is_literal(self) -> None:
        self.assertIn('CHECK (NOT "is_bed_assignment" OR ("period_start" IS NOT NULL AND "care_space_id" IS NOT NULL));',
                      self.sql)

    def test_every_new_table_has_rls_and_a_tenant_composite_fk(self) -> None:
        for t in F3_TABLES_CLINICAL + F3_TABLES_AUDIT + ["encounter_locations"]:
            self.assertRegex(self.sql, r"'(clinical|audit)\.%s'" % t, f"{t} sin RLS")
        # 18 FK compuestas (tenant_id, x_id) declaradas a mano
        self.assertEqual(len(re.findall(r"(?m)^\s+\('(?:clinical|audit)\.\w+',\s+'fk_\w+_tenant_\w+'", self.sql, re.M)), 18)

    def test_history_triggers_do_not_collide_with_the_f1b_verification_count(self) -> None:
        f1b = (REPO / "SQL" / "patches" / "2026-10-29_infraestructura_f1b_seguridad.sql").read_text(encoding="utf-8")
        # F1b cuenta los triggers por nombre en toda la base: los de F3 no pueden llamarse igual.
        self.assertIn("'trg_fill_tenant', 'trg_close_only'", f1b)
        body = "\n".join(l for l in self.sql.splitlines() if not l.lstrip().startswith("--"))
        self.assertNotRegex(body, r"TRIGGER trg_fill_tenant|TRIGGER trg_close_only")
        self.assertIn("TRIGGER trg_f3_fill_tenant", body)
        self.assertIn("TRIGGER trg_f3_close_only", body)

    def test_closed_census_is_defined_by_closed_at_not_by_a_guessed_concept(self) -> None:
        guard = re.search(r'FUNCTION "clinical"\."inpatient_census_days_guard_closed".*?END \$fn\$;', self.sql, re.S).group(0)
        self.assertIn('OLD."closed_at" IS NOT NULL', guard)
        self.assertNotRegex(guard, r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")

    def test_bed_flag_is_derived_by_a_trigger_that_reads_the_space_past_rls_and_fails_closed(self) -> None:
        fn = re.search(r'FUNCTION "clinical"\."encounter_locations_derive_bed".*?END \$fn\$;', self.sql, re.S).group(0)
        self.assertIn("SET app.system_context = 'true'", fn)          # la política de care_spaces no puede ocultar el espacio
        self.assertIn("SET search_path = pg_catalog, pg_temp", fn)
        self.assertNotIn("SECURITY DEFINER", fn)
        self.assertIn("foreign_key_violation", fn)                    # espacio inexistente => error
        self.assertIn(deterministic_id("practice:LOC_FORM_BED"), fn)
        self.assertIn('BEFORE INSERT OR UPDATE ON "clinical"."encounter_locations"', self.sql)
        # corre DESPUÉS del que completa tenant_id: los triggers BEFORE se ordenan por nombre
        self.assertLess("trg_encounter_locations_fill_tenant", "trg_encounter_locations_set_bed_flag")

    def test_census_entries_cannot_be_inserted_into_a_closed_day_and_fail_closed(self) -> None:
        fn = re.search(r'FUNCTION "clinical"\."inpatient_census_entries_require_open_day".*?END \$fn\$;', self.sql, re.S).group(0)
        self.assertIn("SET app.system_context = 'true'", fn)
        self.assertIn('d."tenant_id" = NEW."tenant_id"', fn)           # no revela el estado de un día ajeno
        self.assertIn("FOR SHARE", fn)                                 # serializa contra el UPDATE que cierra el día
        self.assertIn("v_found IS NOT TRUE", fn)                       # día inexistente => error, no pasa
        self.assertIn("restrict_violation", fn)
        self.assertIn('BEFORE INSERT ON "clinical"."inpatient_census_entries"', self.sql)

    def test_does_not_touch_the_integrators_files(self) -> None:
        # El patch sólo lee/crea objetos de base; las rutas del integrador no aparecen como destino.
        for hot in ("apply_all.sql", "SHA256SUMS", "model-manifest", "_generation_report"):
            self.assertNotIn(hot, "\n".join(l for l in self.sql.splitlines() if not l.lstrip().startswith("--")))


class PumlContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.p08 = PUML_08.read_text(encoding="utf-8")
        cls.p10 = PUML_10.read_text(encoding="utf-8")
        cls.p33 = PUML_33.read_text(encoding="utf-8")

    @staticmethod
    def _entity(text: str, name: str) -> str:
        m = re.search(r"^entity %s(?: <<[^>]*>>)? \{\n(.*?)^\}" % re.escape(name), text, re.M | re.S)
        assert m, name
        return m.group(1)

    def test_encounters_and_locations_carry_the_contract_columns(self) -> None:
        enc = self._entity(self.p08, "encounters")
        for col in NEW_COLUMNS_ENCOUNTERS:
            self.assertRegex(enc, r"(?m)^\s+%s : " % col, col)
        loc = self._entity(self.p08, "encounter_locations")
        for col in NEW_COLUMNS_LOCATIONS:
            self.assertRegex(loc, r"(?m)^\s+\*?\s*%s : " % col, col)
        self.assertRegex(loc, r"\* tenant_id : uuid <<FK>>")
        self.assertRegex(loc, r"\* is_bed_assignment : boolean <<DEFAULT_FALSE>>")

    def test_new_entities_exist_with_tenant_id(self) -> None:
        for t in F3_TABLES_CLINICAL:
            self.assertRegex(self._entity(self.p08, t), r"\* tenant_id : uuid <<FK>>", t)
        for t in F3_TABLES_AUDIT:
            self.assertRegex(self._entity(self.p10, t + " <<HISTORY>>".replace(" <<HISTORY>>", "")), r"\* tenant_id : uuid <<FK>>", t)

    def test_census_contract_columns_and_unique_key(self) -> None:
        day = self._entity(self.p08, "inpatient_census_days")
        for col in ("practice_site_id", "clinical_unit_id", "census_date", "cutoff_at", "status_concept_id", "closed_at",
                    "closed_by_user_id", "beds_censable", "beds_available", "beds_blocked", "patients_at_cutoff",
                    "admissions", "discharges", "deaths", "transfers_in", "transfers_out", "same_day_stays",
                    "patient_days", "discharge_stay_days", "content_hash"):
            self.assertRegex(day, r"(?m)^\s+\*?\s*%s : " % col, col)
        self.assertIn("UX ux_inpatient_census_days_site_unit_date : (practice_site_id, clinical_unit_id, census_date) UNIQUE BTREE",
                      self.p08)
        adj = self._entity(self.p08, "inpatient_census_adjustments")
        for col in ("field_code", "previous_value", "new_value", "reason_text", "entry_ref_id", "adjusted_by_user_id",
                    "request_id", "created_at"):
            self.assertRegex(adj, r"(?m)^\s+\*?\s*%s : " % col, col)
        ent = self._entity(self.p08, "inpatient_census_entries")
        for col in ("census_day_id", "encounter_id", "patient_profile_id", "care_space_id", "bed_category_concept_id",
                    "movement_concept_id", "occurred_at"):
            self.assertRegex(ent, r"(?m)^\s+\*?\s*%s : " % col, col)

    def test_incident_contract_columns(self) -> None:
        inc = self._entity(self.p08, "placement_incidents")
        for col in ("encounter_id", "encounter_location_id", "care_space_id", "patient_profile_id", "violations_json",
                    "justification_text", "authorized_by_user_id", "status_concept_id", "reviewed_by_user_id",
                    "reviewed_at", "review_note"):
            self.assertRegex(inc, r"(?m)^\s+\*?\s*%s : " % col, col)

    def test_diagram_33_declares_every_check_and_exclude_of_the_patch(self) -> None:
        for name in CHECKS:
            self.assertRegex(self.p33, r"CHECK_SQL : %s \|" % name, name)
        for name in EXCLUDES:
            self.assertRegex(self.p33, r"EXCLUDE_SQL : %s \|" % name, name)
        self.assertRegex(self.p33, r'entity "clinical\.inpatient_census_entries" as \w+ <<IMMUTABLE, REFERENCE_ONLY>> \{\n  UPDATE_DELETE : forbidden')
        self.assertRegex(self.p33, r'entity "clinical\.inpatient_census_adjustments" as \w+ <<IMMUTABLE, REFERENCE_ONLY>> \{\n  UPDATE_DELETE : forbidden')

    def test_diagram_33_and_patch_use_the_same_exclude_literals(self) -> None:
        patch = PATCH.read_text(encoding="utf-8")
        for name in EXCLUDES:
            in33 = re.search(r"EXCLUDE_SQL : %s \| .*" % name, self.p33).group(0)
            lits33 = set(re.findall(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", in33))
            body = re.search(r'ADD CONSTRAINT "%s".*?;' % name, patch, re.S).group(0)
            self.assertEqual(lits33, set(re.findall(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", body)), name)


class GeneratorCoherenceTests(unittest.TestCase):
    """Corre gen_ddl.py y gen_integrity.py sobre una COPIA y compara con el patch."""

    @classmethod
    def setUpClass(cls) -> None:
        cls._tmp = tempfile.TemporaryDirectory(prefix="f3_gen_")
        root = Path(cls._tmp.name)
        (root / "salud-db").mkdir()
        for py in (REPO / "salud-db").glob("*.py"):
            shutil.copy2(py, root / "salud-db" / py.name)
        ctx = root / "Mantra Core Health Context"
        ctx.mkdir()
        shutil.copytree(MODULES, ctx / "modules")
        shutil.copy2(REPO / "Mantra Core Health Context" / "model-manifest.yaml", ctx / "model-manifest.yaml")
        shutil.copytree(REPO / "SQL" / "_integrity", root / "SQL" / "_integrity")
        for code in ("08", "10"):
            subprocess.run([sys.executable, str(root / "salud-db" / "gen_ddl.py"), code], cwd=root,
                           check=True, capture_output=True, text=True)
        subprocess.run([sys.executable, str(root / "salud-db" / "gen_integrity.py")], cwd=root,
                       check=True, capture_output=True, text=True)
        cls.root = root
        cls.patch = PATCH.read_text(encoding="utf-8")

    @classmethod
    def tearDownClass(cls) -> None:
        cls._tmp.cleanup()

    def _gen(self, folder: str, name: str) -> str:
        return (self.root / "SQL" / folder / name).read_text(encoding="utf-8")

    def test_every_new_table_is_generated_and_copied_verbatim_into_the_patch(self) -> None:
        clinical = self._gen("08_clinical", "02_tables.sql")
        audit = self._gen("10_audit", "02_tables.sql")
        for t in F3_TABLES_CLINICAL:
            ddl = re.search(r'CREATE TABLE IF NOT EXISTS "clinical"\."%s" \(.*?\n\);' % t, clinical, re.S)
            self.assertIsNotNone(ddl, t)
            self.assertIn(ddl.group(0), self.patch, f"{t}: el patch no es copia del generado")
        for t in F3_TABLES_AUDIT:
            ddl = re.search(r'CREATE TABLE IF NOT EXISTS "audit"\."%s" \(.*?\n\);' % t, audit, re.S)
            self.assertIsNotNone(ddl, t)
            self.assertIn(ddl.group(0), self.patch, f"{t}: el patch no es copia del generado")

    def test_new_columns_of_existing_tables_match_the_generated_ddl(self) -> None:
        clinical = self._gen("08_clinical", "02_tables.sql")
        enc = re.search(r'CREATE TABLE IF NOT EXISTS "clinical"\."encounters" \(.*?\n\);', clinical, re.S).group(0)
        loc = re.search(r'CREATE TABLE IF NOT EXISTS "clinical"\."encounter_locations" \(.*?\n\);', clinical, re.S).group(0)
        for col in NEW_COLUMNS_ENCOUNTERS:
            line = re.search(r'^\s+"%s" ([^,\n]+)' % col, enc, re.M).group(1).strip()
            self.assertRegex(self.patch, r'"encounters"\s+ADD COLUMN IF NOT EXISTS "%s" %s' % (col, re.escape(line)))
        for col in NEW_COLUMNS_LOCATIONS:
            line = re.search(r'^\s+"%s" ([^,\n]+)' % col, loc, re.M).group(1).strip()
            line = line.replace(" NOT NULL", "") if col == "tenant_id" else line   # tenant_id: NOT NULL después del backfill
            self.assertRegex(self.patch, r'"encounter_locations"\s+ADD COLUMN IF NOT EXISTS "%s" %s' % (col, re.escape(line)))

    def test_generated_foreign_keys_and_indexes_of_f3_are_all_in_the_patch(self) -> None:
        names_fk = set()
        for folder, fname in (("08_clinical", "03_fk_intra.sql"), ("08_clinical", "90_fk_deferred.sql"),
                              ("10_audit", "90_fk_deferred.sql")):
            for m in re.finditer(r'ALTER TABLE "(\w+)"\."(\w+)"\s+ADD CONSTRAINT "(\w+)" FOREIGN KEY \("(\w+)"\)',
                                 self._gen(folder, fname)):
                sch, tbl, name, col = m.groups()
                is_new_table = (sch == "clinical" and tbl in F3_TABLES_CLINICAL) or (sch == "audit" and tbl in F3_TABLES_AUDIT)
                is_new_col = (tbl == "encounters" and col in NEW_COLUMNS_ENCOUNTERS) or \
                             (tbl == "encounter_locations" and col in NEW_COLUMNS_LOCATIONS)
                if is_new_table or is_new_col:
                    names_fk.add(name)
        self.assertGreaterEqual(len(names_fk), 48)
        for name in sorted(names_fk):
            self.assertIn(f'ADD CONSTRAINT "{name}" FOREIGN KEY', self.patch, name)
        # y el patch no inventa FK simples que el generado no tenga
        patch_fks = set(re.findall(r'ADD CONSTRAINT "(fk_\w+)" FOREIGN KEY \("', self.patch))
        self.assertEqual(patch_fks, names_fk)
        for folder, expected in (("08_clinical", "04_indexes.sql"), ("10_audit", "04_indexes.sql")):
            for name in re.findall(r'INDEX IF NOT EXISTS "(\w+)" ON "(?:clinical|audit)"\."(?:%s)"' %
                                   "|".join(F3_TABLES_CLINICAL + F3_TABLES_AUDIT), self._gen(folder, expected)):
                self.assertIn(f'"{name}"', self.patch, name)

    def test_generated_constraints_have_the_names_and_literals_of_the_patch(self) -> None:
        cons = self._gen("08_clinical", "05_constraints.sql")
        for name in CHECKS + EXCLUDES:
            self.assertIn(f'"{name}"', cons + self._gen("08_clinical", "05_constraints.sql"), name)
            self.assertIn(f'"{name}"', self.patch, name)
        for name in EXCLUDES:
            # tras el cierre de la integración, EXCLUDE_SQL expresa DEFERRABLE (cuarta parte): el SQL
            # generado y el patch coinciden sentencia por sentencia, incluida la diferibilidad
            gen = re.search(r'ADD CONSTRAINT "%s"\n\s+(EXCLUDE USING gist .*?);' % name, cons, re.S).group(1)
            patch = re.search(r'ADD CONSTRAINT "%s"\s+(EXCLUDE USING gist .*?DEFERRABLE INITIALLY IMMEDIATE);' % name,
                              self.patch, re.S).group(1)
            self.assertEqual(" ".join(gen.split()), " ".join(patch.split()), name)
            self.assertTrue(gen.endswith("DEFERRABLE INITIALLY IMMEDIATE"), name)
        self.assertIn("trg_forbid_mutation", cons)
        for t in ("inpatient_census_entries", "inpatient_census_adjustments"):
            self.assertIn(f'CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."{t}"', cons)


if __name__ == "__main__":
    unittest.main()
