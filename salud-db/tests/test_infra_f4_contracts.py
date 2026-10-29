#!/usr/bin/env python3
"""Infraestructura F4 (quirófanos): contrato estático de los .puml y de los dos patches (sin base).

Lo que se comprueba:
  * los UUID literales de conceptos (EXCLUDE / índices parciales) son los `deterministicId()` de la API;
  * todo lo que los patches copian del SQL generado coincide con lo que `gen_ddl.py` / `gen_integrity.py`
    emiten HOY desde los .puml (si alguien cambia el .puml y no el patch, esto falla), y todo lo que el
    generador emite para las tablas nuevas está en el patch;
  * los patches son idempotentes por construcción y abortan ante datos incompatibles;
  * los contadores de la verificación final coinciden con las listas de objetos.

El generador corre en un directorio temporal: no toca SQL/.
"""
from __future__ import annotations

import hashlib
import re
import sys
import unittest
import uuid
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import gen_ddl  # noqa: E402
import gen_integrity  # noqa: E402

MODEL_ROOT = Path(__file__).resolve().parents[2]
MODULES = MODEL_ROOT / "Mantra Core Health Context" / "modules"
PATCHES = MODEL_ROOT / "SQL" / "patches"
SCHEDULING = (PATCHES / "2026-10-29_infraestructura_f4_scheduling.sql").read_text(encoding="utf-8")
PERIOP = (PATCHES / "2026-10-29_infraestructura_f4z_periop.sql").read_text(encoding="utf-8")

# HEALTH_UUID_NAMESPACE de mantra-core-health-api/src/common/constants/concepts.ts
NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")


def deterministic_id(key: str) -> str:
    """Igual que `deterministicId()` de la API (UUID v5 con ese namespace)."""
    digest = hashlib.sha1(NAMESPACE.bytes + key.encode("utf-8")).digest()[:16]
    b = bytearray(digest)
    b[6] = (b[6] & 0x0F) | 0x50
    b[8] = (b[8] & 0x3F) | 0x80
    h = b.hex()
    return f"{h[:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:]}"


# nombre del concepto → clave de la API (`<módulo>:<NOMBRE>` de defineModuleConcepts, o la clave literal de concepts.ts)
CONCEPT_KEYS = {
    "STATE_ACTIVE": "state:active",
    "CASE_SCHEDULED": "periop:case-status:scheduled",
    "CASE_READY": "periop:case-status:ready",
    "SURGICAL_CASE_IN_PROGRESS": "periop:case-status:in-progress",
    "RES_ROOM": "scheduling:resource-type:room",
    "ORB_ACTIVE": "procedures_perioperative:ORB_ACTIVE",
    "ORB_RELEASED": "procedures_perioperative:ORB_RELEASED",
    "ORB_CANCELLED": "procedures_perioperative:ORB_CANCELLED",
    "ORB_OWNER_SERVICE": "procedures_perioperative:ORB_OWNER_SERVICE",
    "ORB_OWNER_SURGEON": "procedures_perioperative:ORB_OWNER_SURGEON",
}
IDS = {name: deterministic_id(key) for name, key in CONCEPT_KEYS.items()}
UUID_RE = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")


def f4_block_of_diagram_33() -> str:
    text = (MODULES / "diagram_33_integrity.puml").read_text(encoding="utf-8")
    start = text.index("infraestructura hospitalaria F4 (quirófanos")
    return text[start:]


def norm(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip()


def statements(sql: str) -> list[str]:
    """Sentencias de un script (separa por «;» fuera de comillas; descarta comentarios de línea)."""
    sql = re.sub(r"--[^\n]*", "", sql)
    out, buf, quote, dollar = [], [], False, None
    i = 0
    while i < len(sql):
        ch = sql[i]
        if dollar:
            if sql.startswith(dollar, i):
                buf.append(dollar)
                i += len(dollar)
                dollar = None
                continue
        elif quote:
            if ch == "'":
                quote = False
        else:
            m = re.match(r"\$[A-Za-z_]*\$", sql[i:])
            if m:
                dollar = m.group(0)
                buf.append(dollar)
                i += len(dollar)
                continue
            if ch == "'":
                quote = True
            elif ch == ";":
                out.append("".join(buf).strip())
                buf = []
                i += 1
                continue
        buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        out.append(tail)
    return [s for s in out if s]


class DeterministicIdTests(unittest.TestCase):
    def test_algorithm_reproduces_the_uuids_already_in_the_model(self) -> None:
        # los tres estados vivos del EXCLUDE de F-previa y el de F5g: el algoritmo es el de la API
        self.assertEqual(IDS["CASE_SCHEDULED"], "6fe38139-ad1d-5214-84c1-8c184e4e58fb")
        self.assertEqual(IDS["CASE_READY"], "f6985cd5-f867-5d76-b70c-1138667fd2ab")
        self.assertEqual(IDS["SURGICAL_CASE_IN_PROGRESS"], "fdc78cc9-eda6-5625-9a26-1bdcec4dc203")
        self.assertEqual(IDS["STATE_ACTIVE"], "38a1d301-f40d-5b17-a695-5e6d605f8b19")
        self.assertEqual(deterministic_id("delegated_access:SCOPE_SITE"), "e69a4c95-fe59-5c3e-b826-222af123adb9")

    def test_every_uuid_literal_of_f4_is_a_derived_concept_id(self) -> None:
        known = set(IDS.values())
        scopes = {
            "patch scheduling": SCHEDULING,
            "patch periop": PERIOP,
            "diagram_33 (bloque F4)": f4_block_of_diagram_33(),
            "diagram_53": (MODULES / "diagram_53_procedures_perioperative.puml").read_text(encoding="utf-8"),
            "diagram_41": (MODULES / "diagram_41_scheduling.puml").read_text(encoding="utf-8"),
        }
        for name, text in scopes.items():
            for literal in set(UUID_RE.findall(text)):
                with self.subTest(archivo=name, uuid=literal):
                    self.assertIn(literal, known, "UUID literal que no sale de ningún deterministicId() conocido")

    def test_the_literals_used_by_the_ddl_are_the_expected_concepts(self) -> None:
        block = f4_block_of_diagram_33()
        for needed in ("ORB_ACTIVE", "ORB_RELEASED", "ORB_CANCELLED", "ORB_OWNER_SERVICE", "ORB_OWNER_SURGEON"):
            self.assertIn(IDS[needed], block, needed)
        for live in ("CASE_SCHEDULED", "CASE_READY", "SURGICAL_CASE_IN_PROGRESS"):
            self.assertIn(IDS[live], PERIOP)
        self.assertIn(IDS["STATE_ACTIVE"], SCHEDULING)
        self.assertIn(IDS["RES_ROOM"], SCHEDULING)
        self.assertIn(IDS["ORB_ACTIVE"], (MODULES / "diagram_53_procedures_perioperative.puml").read_text(encoding="utf-8"))


class GeneratedSqlMatchesThePatchesTests(unittest.TestCase):
    """Lo que el patch copia del generador es lo que el generador emite hoy."""

    @classmethod
    def setUpClass(cls) -> None:
        cls._tmp = TemporaryDirectory()
        out = Path(cls._tmp.name)
        with patch.object(gen_ddl, "OUT_DIR", out), patch.object(gen_integrity, "SQL_DIR", out), \
                patch.object(gen_integrity, "OUT", out / "_integrity"), redirect_stdout(StringIO()):
            with patch.object(sys, "argv", ["gen_ddl.py", "all"]):
                gen_ddl.main()
            gen_integrity.main()
        cls.gen = {}
        for module in ("10_audit", "41_scheduling", "53_procedures_perioperative"):
            for part in ("02_tables", "03_fk_intra", "04_indexes", "05_constraints", "90_fk_deferred"):
                f = out / module / f"{part}.sql"
                cls.gen[(module, part)] = f.read_text(encoding="utf-8") if f.exists() else ""

    @classmethod
    def tearDownClass(cls) -> None:
        cls._tmp.cleanup()

    def generated(self, *modules: str, parts: tuple[str, ...]) -> set[str]:
        found: set[str] = set()
        for m in modules:
            for part in parts:
                found |= {norm(s) for s in statements(self.gen[(m, part)])}
        return found

    @staticmethod
    def patch_statements(sql: str) -> list[str]:
        return statements(sql)

    def test_indexes_of_the_patches_are_the_generated_ones_and_complete_for_new_tables(self) -> None:
        gen = self.generated("10_audit", "41_scheduling", "53_procedures_perioperative", parts=("04_indexes",))
        for name, patch_sql in (("scheduling", SCHEDULING), ("periop", PERIOP)):
            idx = [norm(s) for s in self.patch_statements(patch_sql) if re.match(r"CREATE (UNIQUE )?INDEX IF NOT EXISTS", s)]
            self.assertTrue(idx, name)
            for s in idx:
                with self.subTest(patch=name, indice=s[:90]):
                    self.assertIn(s, gen)
        # completitud: todo índice generado para una tabla NUEVA está en el patch
        periop = {norm(s) for s in self.patch_statements(PERIOP)}
        for table in ("operating_room_block_series", "operating_room_blocks",
                      "operating_room_block_series_history", "operating_room_blocks_history"):
            for s in gen:
                if re.search(rf'ON "(procedures_perioperative|audit)"\."{table}" ', s):
                    with self.subTest(tabla=table, indice=s[:90]):
                        self.assertIn(s, periop)
        # y los índices nuevos de las tablas modificadas
        for name in ("ix_procedure_cases_schedulable_resource_id", "ix_procedure_cases_operating_room_block_id",
                     "ix_procedure_cases_room_reserved", "ux_procedure_cases_custodian_tenant_id_id",
                     "ux_surgical_safety_checklists_case_type", "ix_operating_room_utilization_events_tenant_id",
                     "ix_operating_room_utilization_events_operating_room_block_id"):
            self.assertTrue(any(f'"{name}"' in s for s in periop), name)
        sched = {norm(s) for s in self.patch_statements(SCHEDULING)}
        for name in ("ix_schedulable_resources_care_space_id", "ux_schedulable_resources_tenant_id_id",
                     "ux_schedulable_resources_care_space_active"):
            self.assertTrue(any(f'"{name}"' in s for s in sched), name)

    def test_new_tables_are_the_generated_ones(self) -> None:
        gen = self.generated("10_audit", "53_procedures_perioperative", parts=("02_tables",))
        # el generador emite un CREATE TABLE por tabla, con «;» incluido en nuestro troceo
        patch_tables = [norm(s) for s in self.patch_statements(PERIOP) if s.startswith("CREATE TABLE IF NOT EXISTS")]
        self.assertEqual(len(patch_tables), 4)
        for s in patch_tables:
            with self.subTest(tabla=s[:100]):
                self.assertIn(s, gen)

    def test_columns_added_to_existing_tables_match_the_generated_table(self) -> None:
        tables = self.gen[("53_procedures_perioperative", "02_tables")]
        for table, cols in (("procedure_cases", ["schedulable_resource_id uuid", "operating_room_block_id uuid",
                                                  "reserved_start_at timestamptz", "reserved_end_at timestamptz"]),
                            ("operating_room_utilization_events", ["tenant_id uuid NOT NULL", "operating_room_block_id uuid"])):
            block = re.search(rf'CREATE TABLE IF NOT EXISTS "procedures_perioperative"\."{table}" \((.*?)\n\);', tables, re.S)
            self.assertIsNotNone(block, table)
            for col in cols:
                name, _, typ = col.partition(" ")
                self.assertIn(f'"{name}" {typ}', block.group(1), f"{table}.{name}")
                self.assertRegex(PERIOP, rf'ALTER TABLE "procedures_perioperative"\."{table}"\s+ADD COLUMN IF NOT EXISTS "{name}" {typ.split(" ")[0]}')
        sched = self.gen[("41_scheduling", "02_tables")]
        self.assertRegex(sched, r'CREATE TABLE IF NOT EXISTS "scheduling"\."schedulable_resources" \((?:.|\n)*?"care_space_id" uuid,')
        self.assertRegex(SCHEDULING, r'ADD COLUMN IF NOT EXISTS "care_space_id" uuid')

    def test_simple_foreign_keys_are_the_generated_ones_and_complete_for_new_objects(self) -> None:
        gen = self.generated("10_audit", "41_scheduling", "53_procedures_perioperative", parts=("03_fk_intra", "90_fk_deferred"))
        in_patch = {}
        for name, sql in (("scheduling", SCHEDULING), ("periop", PERIOP)):
            for s in self.patch_statements(sql):
                m = re.search(r'ADD CONSTRAINT\s+"(fk_[a-z0-9_]+)"\s+FOREIGN KEY\s+\("([a-z_]+)"\)\s+REFERENCES', s)
                if m and not m.group(1).startswith(("fk_or_", "fk_procedure_cases_tenant_", "fk_schedulable_resources_tenant_")):
                    in_patch[m.group(1)] = norm(s)
        self.assertEqual(len(in_patch), 36)     # 35 de periop + 1 de scheduling
        for fk, s in in_patch.items():
            body = re.search(r"(ALTER TABLE .*? REFERENCES [^;]*)", s).group(1)
            with self.subTest(fk=fk):
                self.assertTrue(any(body in g for g in gen), body)
        # completitud: toda FK generada de una tabla NUEVA (o de las columnas nuevas) está en el patch
        for g in gen:
            m = re.search(r'ALTER TABLE "(procedures_perioperative|audit)"\."(operating_room_block_series(_history)?|operating_room_blocks(_history)?)" ADD CONSTRAINT "(fk_[a-z0-9_]+)"', g)
            if m:
                with self.subTest(fk=m.group(5)):
                    self.assertIn(m.group(5), in_patch)
        for fk in ("fk_procedure_cases_schedulable_resource_id", "fk_procedure_cases_operating_room_block_id",
                   "fk_operating_room_utilization_events_operating_room_block_id", "fk_operating_room_utilization_events_tenant_id",
                   "fk_schedulable_resources_care_space_id"):
            self.assertIn(fk, in_patch)

    def test_check_and_exclude_constraints_are_the_generated_ones(self) -> None:
        gen = self.generated("41_scheduling", "53_procedures_perioperative", parts=("05_constraints",))
        wanted = ["ex_procedure_cases_operating_room_reserved_time", "ck_operating_room_block_series_owner",
                  "ck_operating_room_block_series_schedule", "ex_operating_room_blocks_time", "ck_operating_room_blocks_owner",
                  "ck_operating_room_blocks_window", "ck_operating_room_blocks_status", "ck_operating_room_blocks_release_state",
                  "ck_surgical_safety_checklists_phase_order"]
        periop = [norm(s) for s in self.patch_statements(PERIOP)]
        for name in wanted:
            gen_stmt = next((g for g in gen if f'ADD CONSTRAINT "{name}"' in g), None)
            self.assertIsNotNone(gen_stmt, f"{name} no está en el SQL generado")
            self.assertTrue(any(gen_stmt in p for p in periop), f"{name}: el patch no trae la sentencia generada")
        # el CHECK de scheduling: misma expresión que el generado (el patch lo crea NOT VALID y lo valida si puede)
        gen_check = next(g for g in gen if 'ADD CONSTRAINT "ck_schedulable_resources_care_space_ref"' in g)
        expr = re.search(r"CHECK \((.*)\)$", gen_check).group(1)
        self.assertIn(expr, norm(SCHEDULING))
        # nadie genera ya el EXCLUDE viejo
        self.assertFalse(any('"ex_procedure_cases_operating_room_time"' in g and "ADD CONSTRAINT" in g for g in gen))


class PatchStructureTests(unittest.TestCase):
    def test_both_patches_are_one_transaction_with_system_context(self) -> None:
        for name, sql in (("scheduling", SCHEDULING), ("periop", PERIOP)):
            with self.subTest(patch=name):
                lines = [l.strip() for l in sql.splitlines()]
                self.assertEqual(lines.count("BEGIN;"), 1)
                self.assertEqual(lines.count("COMMIT;"), 1)
                self.assertIn("SET LOCAL app.system_context = 'true';", lines)
                self.assertLess(lines.index("BEGIN;"), lines.index("COMMIT;"))

    def test_every_ddl_statement_is_re_runnable(self) -> None:
        for name, sql in (("scheduling", SCHEDULING), ("periop", PERIOP)):
            code = re.sub(r"--[^\n]*", "", sql)
            with self.subTest(patch=name):
                self.assertNotRegex(code, r"CREATE (UNIQUE )?INDEX (?!IF NOT EXISTS)")
                self.assertNotRegex(code, r"CREATE TABLE (?!IF NOT EXISTS)")
                self.assertNotRegex(code, r"ADD COLUMN (?!IF NOT EXISTS)")
                # cada ADD CONSTRAINT vive dentro de un bloque con su manejo de duplicado, o es el EXECUTE format de las compuestas
                for m in re.finditer(r"ADD CONSTRAINT", code):
                    window = code[max(0, m.start() - 400): m.end() + 1500]
                    self.assertTrue("duplicate_object" in window or "IF NOT EXISTS (SELECT 1 FROM pg_constraint" in window,
                                    f"ADD CONSTRAINT sin protección de duplicado cerca de: {code[m.start():m.start() + 80]!r}")
        for trig in ("trg_procedure_cases_reserved_window", "trg_or_utilization_events_fill_tenant",
                     "trg_or_block_series_room_site", "trg_or_blocks_series_room"):
            self.assertRegex(PERIOP, rf'DROP TRIGGER IF EXISTS "{trig}"')
            self.assertRegex(PERIOP, rf'CREATE TRIGGER "{trig}"')

    def test_incompatible_data_aborts_with_the_documented_causes(self) -> None:
        for fragment in ("solapan su ventana reservada", "OTRO tenant", "más de un check-list del mismo tipo",
                         "fases fuera de orden", "sin tenant_id tras el backfill", "Aplicar antes"):
            self.assertIn(fragment, PERIOP)
        self.assertIn("más de un recurso agendable ACTIVO", SCHEDULING)
        self.assertIn("Aplicar antes", SCHEDULING)
        # las precondiciones corren ANTES de lo que podría fallar por esos datos
        self.assertLess(PERIOP.index("solapan su ventana reservada"), PERIOP.index('ADD CONSTRAINT "ex_procedure_cases_operating_room_reserved_time"'))
        self.assertLess(PERIOP.index("OTRO tenant"), PERIOP.index("FOREIGN KEY (%s) REFERENCES"))
        self.assertLess(SCHEDULING.index("más de un recurso agendable ACTIVO"), SCHEDULING.index('CREATE UNIQUE INDEX IF NOT EXISTS "ux_schedulable_resources_care_space_active"'))

    def test_final_verification_counters_match_the_object_lists(self) -> None:
        m = re.search(r"n_idx <> (\d+) OR n_fks <> (\d+) OR n_fkc <> (\d+)", PERIOP)
        self.assertIsNotNone(m)
        n_idx, n_fks, n_fkc = map(int, m.groups())
        block = PERIOP[PERIOP.index("-- 12. verificación"):]
        idx_list = re.search(r"SELECT count\(\*\) INTO n_idx FROM pg_indexes\s+WHERE indexname IN \((.*?)\);", block, re.S).group(1)
        fk_list = re.search(r"SELECT count\(\*\) INTO n_fks FROM pg_constraint\s+WHERE contype = 'f' AND convalidated\s+AND conname IN \((.*?)\);", block, re.S).group(1)
        fkc_list = re.search(r"array_length\(conkey, 1\) = 2\s+AND conname IN \((.*?)\);", block, re.S).group(1)
        self.assertEqual(len(re.findall(r"'[a-z0-9_]+'", idx_list)), n_idx)
        self.assertEqual(len(re.findall(r"'[a-z0-9_]+'", fk_list)), n_fks)
        self.assertEqual(len(re.findall(r"'[a-z0-9_]+'", fkc_list)), n_fkc)
        # y cada compuesta de la lista está declarada en el DO que las crea
        for name in re.findall(r"'([a-z0-9_]+)'", fkc_list):
            self.assertIn(f"'{name}'", PERIOP[: PERIOP.index("-- 9. EXCLUDE y CHECK")], name)
        # las cifras de la verificación no se pueden relajar a «>= 0»
        self.assertNotIn(">= 0", block.split("IF n_tab")[1])

    def test_rls_policy_text_is_the_one_of_the_tenant_rls_patch(self) -> None:
        base = (PATCHES / "2026-08-05_tenant_rls.sql").read_text(encoding="utf-8")
        for fragment in ("current_setting('app.current_tenant_id', true)", "current_setting('app.system_context', true) = 'true'",
                         "WITH CHECK", "FORCE ROW LEVEL SECURITY", "CREATE POLICY tenant_isolation"):
            self.assertIn(fragment, base)
            self.assertIn(fragment, PERIOP)
        self.assertIn("'audit.operating_room_blocks_history'", PERIOP)
        self.assertIn("REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app", PERIOP)
        self.assertIn('GRANT UPDATE ("valid_to") ON %s TO mantra_app', PERIOP)

    def test_integrator_files_are_not_edited_by_the_patches(self) -> None:
        # los patches no regeneran ni mencionan como destino los archivos del integrador
        for forbidden in ("apply_all.sql", "SHA256SUMS", "model-manifest", "_generation_report"):
            self.assertNotIn(forbidden, re.sub(r"--[^\n]*", "", PERIOP + SCHEDULING))


class PumlDeclarationTests(unittest.TestCase):
    def test_puml_declares_what_the_patches_create(self) -> None:
        d53 = (MODULES / "diagram_53_procedures_perioperative.puml").read_text(encoding="utf-8")
        d41 = (MODULES / "diagram_41_scheduling.puml").read_text(encoding="utf-8")
        d10 = (MODULES / "diagram_10_audit.puml").read_text(encoding="utf-8")
        for entity in ("entity operating_room_block_series {", "entity operating_room_blocks {"):
            self.assertIn(entity, d53)
        for col in ("schedulable_resource_id : uuid <<FK>>", "operating_room_block_id : uuid <<FK>>",
                    "reserved_start_at : timestamptz", "reserved_end_at : timestamptz", "* tenant_id : uuid <<FK>>"):
            self.assertIn(col, d53)
        self.assertIn("care_space_id : uuid <<FK>>", d41[d41.index("entity schedulable_resources {"):d41.index("entity schedule_templates {")])
        for hist in ("entity operating_room_block_series_history <<HISTORY>> {", "entity operating_room_blocks_history <<HISTORY>> {"):
            self.assertIn(hist, d10)

    def test_old_exclude_is_replaced_in_the_integrity_diagram(self) -> None:
        d33 = (MODULES / "diagram_33_integrity.puml").read_text(encoding="utf-8")
        self.assertNotIn("EXCLUDE_SQL : ex_procedure_cases_operating_room_time ", d33)
        self.assertIn("EXCLUDE_SQL : ex_procedure_cases_operating_room_reserved_time", d33)



if __name__ == "__main__":
    unittest.main()
