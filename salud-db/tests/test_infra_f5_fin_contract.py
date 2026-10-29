"""M-F5-fin · facturación día-cama, vigencias de categoría de cama y contabilidad por unidad.

Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/CONTRATO-F2-F5.md §F5e y §F5f.
Patches: SQL/patches/2026-10-29_infraestructura_f5_{accounting,billing,practice}.sql.

Dos capas, para no confundir qué se probó:

* ``StaticContractTests`` — sin base de datos. Ata los .puml, los patches y el generador:
  los UUID literales son los de ``deterministicId`` de la API, cada CHECK/EXCLUDE que declara
  diagram_33 está en el patch, y las sentencias que el patch copia de gen_ddl.py siguen siendo
  idénticas a lo que gen_ddl.py emite hoy (``gen_ddl.emit`` en un directorio temporal: no toca SQL/).
* ``LiveDatabaseTests`` — contra un Postgres real y SÓLO si ``SALUD_TEST_PGDATABASE`` nombra una base
  descartable (nunca ``alovida``). Aplica los tres patches dos veces, corre los scripts de
  ``tests/sql`` (cada «CASO OK» es una aserción) y prueba que los datos incompatibles abortan sin
  dejar rastro. Variables de conexión: las estándar de libpq (PGHOST, PGPORT, PGUSER, PGPASSWORD).
"""
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import gen_ddl

ROOT = Path(__file__).resolve().parents[2]
PATCHES = ROOT / "SQL" / "patches"
PUML = ROOT / "Mantra Core Health Context" / "modules"
SQL_TESTS = Path(__file__).resolve().parent / "sql"

PATCH_ACCOUNTING = PATCHES / "2026-10-29_infraestructura_f5_accounting.sql"
PATCH_BILLING = PATCHES / "2026-10-29_infraestructura_f5_billing.sql"
PATCH_PRACTICE = PATCHES / "2026-10-29_infraestructura_f5_practice.sql"
# Orden de postgres-init: glob alfabético de SQL/patches/*.sql.
PATCHES_IN_ORDER = [PATCH_ACCOUNTING, PATCH_BILLING, PATCH_PRACTICE]

# Mismo namespace que common/constants/concepts.ts de la API (HEALTH_UUID_NAMESPACE).
HEALTH_UUID_NAMESPACE = "3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60"

# deterministicId('billing:<NOMBRE>'): los conceptos los define billing.concepts.ts con ESAS claves.
BILLING_CONCEPTS = {
    "billing:TARIFF_BED_DAY": "1ae01bf6-a061-52ed-aa26-590705cb2202",
    "billing:TARIFF_OR_TIME": "25eb53f6-8006-5959-bee9-65b16117bc9b",
    "billing:CHG_SRC_BED_DAY": "5f84ea44-b0d3-582c-86c1-32c81e422d30",
    "billing:CHG_SRC_OR_TIME": "a79361f6-8787-56a5-9a90-a9436d02e217",
    "billing:CHG_PENDING": "17def99a-0cb5-586c-a440-59d809709c0d",
    "billing:CHG_INVOICED": "9af061be-6a80-51ed-bcbd-52533037c272",
    "billing:CHG_VOIDED": "f2f59654-d912-5eeb-b619-814e50a3c4d0",
}
STATE_ACTIVE = "38a1d301-f40d-5b17-a695-5e6d605f8b19"  # state:active (CONCEPTS.STATE_ACTIVE)
NIL_UUID = "00000000-0000-0000-0000-000000000000"
UUID_RE = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")

MY_TABLES = {
    # (módulo, schema, tabla): patch que la crea
    ("14", "practice", "care_space_category_periods"): PATCH_PRACTICE,
    ("17", "billing", "space_tariffs"): PATCH_BILLING,
    ("17", "billing", "charge_captures"): PATCH_BILLING,
    ("10", "audit", "space_tariffs_history"): PATCH_BILLING,
    ("10", "audit", "charge_captures_history"): PATCH_BILLING,
}


def deterministic_id(key: str) -> str:
    """Réplica de deterministicId() de la API: UUIDv5 (SHA-1) sobre HEALTH_UUID_NAMESPACE."""
    digest = bytearray(hashlib.sha1(bytes.fromhex(HEALTH_UUID_NAMESPACE.replace("-", "")) + key.encode()).digest()[:16])
    digest[6] = (digest[6] & 0x0F) | 0x50
    digest[8] = (digest[8] & 0x3F) | 0x80
    h = digest.hex()
    return f"{h[:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:]}"


def squash(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def contains(needle: str, haystack: str) -> bool:
    return needle in haystack


def model_entity_block(diagram: str, entity_alias: str) -> str:
    """Cuerpo `{ … }` de una entidad de diagram_33 (por su alias)."""
    text = (PUML / diagram).read_text(encoding="utf-8")
    m = re.search(r"as %s <<REFERENCE_ONLY>> \{\n(.*?)\n\}" % re.escape(entity_alias), text, re.S)
    assert m, entity_alias
    return m.group(1)


class StaticContractTests(unittest.TestCase):
    def test_deterministic_id_replicates_the_api(self):
        # Valores que ya usa 2026-10-29_infraestructura_f5_operaciones.sql, sacados de la API.
        self.assertEqual(deterministic_id("state:active"), STATE_ACTIVE)
        self.assertEqual(deterministic_id("delegated_access:ASSIGN_ROLE_UNIT_HEAD"),
                         "ce54425b-5479-57f1-8bb2-274a8617723c")

    def test_billing_concept_literals_are_deterministic_ids(self):
        for key, literal in BILLING_CONCEPTS.items():
            with self.subTest(key=key):
                self.assertEqual(deterministic_id(key), literal)
                self.assertTrue(contains(literal, PATCH_BILLING.read_text(encoding="utf-8")), "falta en el patch")
                self.assertTrue(contains(literal, (PUML / "diagram_33_integrity.puml").read_text(encoding="utf-8")), "falta en diagram_33")
        # diagram_17 usa en sus índices parciales sólo el origen día-cama, el de quirófano y «anulado».
        model = (PUML / "diagram_17_billing.puml").read_text(encoding="utf-8")
        for key in ("billing:CHG_SRC_BED_DAY", "billing:CHG_SRC_OR_TIME", "billing:CHG_VOIDED"):
            self.assertTrue(contains(BILLING_CONCEPTS[key], model), key)

    def test_no_unknown_uuid_literal_in_the_patches_or_the_model_block(self):
        known = set(BILLING_CONCEPTS.values()) | {STATE_ACTIVE, NIL_UUID}
        sources = {p.name: p.read_text(encoding="utf-8") for p in PATCHES_IN_ORDER}
        block = (PUML / "diagram_33_integrity.puml").read_text(encoding="utf-8")
        sources["diagram_33 (bloque F5e)"] = block[block.index("+ infraestructura hospitalaria F5e"):]
        sources["diagram_16"] = (PUML / "diagram_16_accounting.puml").read_text(encoding="utf-8")
        for name, text in sources.items():
            with self.subTest(source=name):
                # Los comentarios que explican el origen de un literal ya lo nombran; se comparan todos.
                unknown = set(UUID_RE.findall(text)) - known
                if name == "diagram_16":
                    unknown -= {STATE_ACTIVE}
                self.assertEqual(unknown, set())

    def test_patch_names_follow_the_apply_order_and_avoid_the_backfill_skip(self):
        self.assertEqual(sorted(p.name for p in PATCHES_IN_ORDER), [p.name for p in PATCHES_IN_ORDER])
        for patch_file in PATCHES_IN_ORDER:
            self.assertTrue(patch_file.exists(), patch_file)
            # init-postgres.sh omite en una base nueva todo patch cuyo nombre contenga «backfill».
            self.assertNotIn("backfill", patch_file.name.lower())

    def test_patches_are_idempotent_by_construction(self):
        for patch_file in PATCHES_IN_ORDER:
            text = patch_file.read_text(encoding="utf-8")
            with self.subTest(patch=patch_file.name):
                self.assertEqual(len(re.findall(r"^BEGIN;$", text, re.M)), 1)
                self.assertEqual(len(re.findall(r"^COMMIT;$", text, re.M)), 1)
                self.assertTrue(contains("SET LOCAL app.system_context = 'true'", text))
                self.assertIsNone(re.search(r'CREATE TABLE "', text))
                self.assertIsNone(re.search(r"CREATE (UNIQUE )?INDEX (?!IF NOT EXISTS)", text))
                self.assertIsNone(re.search(r"DROP TABLE", text))
                self.assertFalse(contains("ON DELETE CASCADE", text))
                # Toda FK nueva va en un bloque que ignora duplicate_object.
                for stmt in re.findall(r"ALTER TABLE [^;]*?ADD CONSTRAINT \"fk_[^;]*;", text, re.S):
                    start = text.index(stmt)
                    self.assertTrue(contains("duplicate_object", text[start:start + len(stmt) + 120]), stmt[:120])
                # Toda columna agregada a una tabla existente es ADD COLUMN IF NOT EXISTS.
                self.assertIsNone(re.search(r"ADD COLUMN (?!IF NOT EXISTS)", text))
                # La verificación final aborta con una lista de conteos, no calla.
                self.assertIsNotNone(re.search(r"RAISE EXCEPTION\s+'F5[ef] [^']*incompleto", text))

    def test_model_declares_the_tables_the_patches_create(self):
        sources = {"14": "diagram_14_practice.puml", "17": "diagram_17_billing.puml", "10": "diagram_10_audit.puml"}
        for (module, schema, table), patch_file in MY_TABLES.items():
            with self.subTest(table=f"{schema}.{table}"):
                text = (PUML / sources[module]).read_text(encoding="utf-8")
                self.assertRegex(text, r"(?m)^entity %s (<<HISTORY>> )?\{" % table)
                self.assertTrue(contains(f'CREATE TABLE IF NOT EXISTS "{schema}"."{table}"', patch_file.read_text(encoding="utf-8")))
        accounting = (PUML / "diagram_16_accounting.puml").read_text(encoding="utf-8")
        self.assertTrue(contains("clinical_unit_id : uuid <<FK>>", accounting))
        self.assertTrue(contains("care_space_id : uuid <<FK>>", accounting))
        text = PATCH_ACCOUNTING.read_text(encoding="utf-8")
        self.assertTrue(contains('ADD COLUMN IF NOT EXISTS "clinical_unit_id" uuid', text))
        self.assertTrue(contains('ADD COLUMN IF NOT EXISTS "care_space_id" uuid', text))

    def test_every_check_and_exclude_of_the_model_block_is_in_its_patch(self):
        targets = {
            "practice_care_space_category_periods": PATCH_PRACTICE,
            "billing_space_tariffs": PATCH_BILLING,
            "billing_charge_captures": PATCH_BILLING,
        }
        total = 0
        for alias, patch_file in targets.items():
            body = model_entity_block("diagram_33_integrity.puml", alias)
            text = squash(patch_file.read_text(encoding="utf-8"))
            for kind, name, expression in re.findall(r"^\s*(CHECK_SQL|EXCLUDE_SQL) : (\w+) \| (.+)$", body, re.M):
                total += 1
                with self.subTest(constraint=name):
                    self.assertTrue(contains(f'"{name}"', text), name)
                    if kind == "CHECK_SQL":
                        self.assertTrue(contains(f"CHECK ({squash(expression)})", text), name)
                    else:
                        self.assertTrue(contains(f"EXCLUDE USING gist ({squash(expression)})", text), name)
        # 1 + 1 (practice) · 7 + 1 (tarifas) · 10 (cargos) = 20 reglas declaradas
        self.assertEqual(total, 20)

    def test_unique_indexes_that_forbid_double_charging_are_declared_and_created(self):
        model = (PUML / "diagram_17_billing.puml").read_text(encoding="utf-8")
        patch_text = PATCH_BILLING.read_text(encoding="utf-8")
        for name in ("ux_charge_captures_idempotency_key", "ux_charge_captures_encounter_bed_day",
                     "ux_charge_captures_bed_night", "ux_charge_captures_or_case"):
            with self.subTest(index=name):
                self.assertTrue(contains(name, model))
                self.assertIsNotNone(re.search(r'CREATE UNIQUE INDEX IF NOT EXISTS "%s"' % name, patch_text))
        # «única por cama + noche»: el día mínimo de un ingreso/egreso el mismo día queda afuera.
        self.assertIsNotNone(re.search(r'"ux_charge_captures_bed_night" ON "billing"."charge_captures" \("tenant_id", "care_space_id", "service_date"\) WHERE [^;]*minimum_stay_charge = false', patch_text))
        # Hallazgo 1: ningún único de cargos es global; todos llevan tenant_id por delante.
        for name in ("ux_charge_captures_bed_night", "ux_charge_captures_encounter_bed_day", "ux_charge_captures_or_case"):
            with self.subTest(scope=name):
                self.assertIsNotNone(re.search(r'UX %s : \(tenant_id, ' % name, model))
                self.assertIsNotNone(re.search(r'"%s" ON "billing"."charge_captures" \("tenant_id", ' % name, patch_text))

    def test_security_findings_are_closed_in_the_patches(self):
        billing = PATCH_BILLING.read_text(encoding="utf-8")
        accounting = PATCH_ACCOUNTING.read_text(encoding="utf-8")
        # Hallazgo 1: el origen de un cargo de quirófano es un caso del mismo tenant y práctica.
        self.assertTrue(contains('CREATE OR REPLACE FUNCTION "billing"."charge_source_case_ok"', billing))
        self.assertTrue(contains('"billing"."charge_source_case_ok"(NEW."tenant_id", NEW."practice_id", NEW."source_ref_id")', billing))
        # Hallazgo 2: triggers sobre las tablas padre, en las dos direcciones.
        for trigger, table in (("trg_care_spaces_billing_dependents", "care_spaces"), ("trg_practice_sites_billing_dependents", "practice_sites")):
            self.assertTrue(contains(f'CREATE TRIGGER "{trigger}"', billing), trigger)
            self.assertTrue(contains(f'ON "practice"."{table}"', billing), trigger)
        for trigger in ("trg_care_spaces_accounting_dependents", "trg_clinical_units_accounting_dependents",
                        "trg_practice_sites_accounting_dependents"):
            self.assertTrue(contains(f'CREATE TRIGGER "{trigger}"', accounting), trigger)
        # La lectura de dependientes se hace con contexto de sistema (a nivel de función).
        self.assertGreaterEqual(billing.count("SET app.system_context = 'true'"), 2)
        self.assertGreaterEqual(accounting.count("SET app.system_context = 'true'"), 3)
        # Las mutaciones existen y cada una apunta a un arreglo distinto.
        for name in ("global_unique", "no_case_check", "no_parent_triggers"):
            self.assertTrue((SQL_TESTS / "mutations" / f"{name}.sql").exists(), name)

    def test_backfill_in_the_sql_test_is_the_one_in_the_patch(self):
        patch_text = PATCH_PRACTICE.read_text(encoding="utf-8")
        m = re.search(r"-- -+ 5\. backfill\n(?:--[^\n]*\n)+(INSERT INTO .*?;)\n", patch_text, re.S)
        self.assertIsNotNone(m)
        test_text = (SQL_TESTS / "f5_fin_10_practice_test.sql").read_text(encoding="utf-8")
        t = re.search(r"\$b\$\n(INSERT INTO .*?;)\n\$b\$", test_text, re.S)
        self.assertIsNotNone(t)
        self.assertEqual(squash(m.group(1)), squash(t.group(1)))

    def test_patch_statements_are_what_gen_ddl_emits_for_the_model(self):
        """Deriva: si alguien cambia el .puml y no el patch (o al revés), esto falla.

        Corre gen_ddl.emit en un directorio temporal (como los demás tests de este paquete):
        NO escribe en SQL/.
        """
        codes = ["10", "14", "16", "17"]
        all_codes = sorted({p.stem.split("_")[1] for p in PUML.glob("diagram_*.puml")})
        with tempfile.TemporaryDirectory() as tmp, redirect_stdout(StringIO()):
            out = Path(tmp) / "SQL"
            with patch.object(gen_ddl, "OUT_DIR", out):
                registry = gen_ddl.build_registry(all_codes)
                pk_map = gen_ddl.build_pk_map(all_codes)
                for code in codes:
                    gen_ddl.emit(code, [], registry, pk_map)
            generated = {}
            for folder in out.iterdir():
                if folder.is_dir():
                    for sql_file in folder.glob("*.sql"):
                        generated[(folder.name, sql_file.name)] = sql_file.read_text(encoding="utf-8")

        def folder_of(module):
            return next(name for (name, _file) in generated if name.startswith(f"{module}_"))

        def blocks(module, filename, pattern):
            return re.findall(pattern, generated[(folder_of(module), filename)], re.M | re.S)

        checked = 0
        for (module, schema, table), patch_file in MY_TABLES.items():
            text = patch_file.read_text(encoding="utf-8")
            with self.subTest(table=f"{schema}.{table}"):
                create = re.search(r'CREATE TABLE IF NOT EXISTS "%s"\."%s" \(.*?\n\);\n' % (schema, table),
                                   generated[(folder_of(module), "02_tables.sql")], re.S)
                self.assertIsNotNone(create)
                self.assertTrue(contains(create.group(0), text), "CREATE TABLE distinto al que emite gen_ddl.py")
                for stmt in blocks(module, "04_indexes.sql",
                                   r'^(CREATE (?:UNIQUE )?INDEX IF NOT EXISTS "[^"]+" ON "%s"\."%s" [^\n]*;)$' % (schema, table)):
                    self.assertTrue(contains(stmt, text), stmt)
                    checked += 1
                fks = []
                for filename in ("03_fk_intra.sql", "90_fk_deferred.sql"):
                    fks += blocks(module, filename,
                                  r'(DO \$\$ BEGIN\n    ALTER TABLE "%s"\."%s"\n        ADD CONSTRAINT [^\n]*\n        REFERENCES [^\n]*;\nEXCEPTION WHEN duplicate_object THEN NULL; END \$\$;)' % (schema, table))
                self.assertGreaterEqual(len(fks), 5)
                for stmt in fks:
                    self.assertTrue(contains(stmt, text), stmt)
                    checked += 1
        # Tablas existentes que ganan columnas / índices / FK en F5f y el único del catálogo de servicios.
        accounting_text = PATCH_ACCOUNTING.read_text(encoding="utf-8")
        billing_text = PATCH_BILLING.read_text(encoding="utf-8")
        gen16 = generated[(folder_of("16"), "04_indexes.sql")]
        for name in ("ix_cost_centers_clinical_unit_id", "ux_cost_centers_practice_id_id", "ux_cost_centers_unit_active",
                     "ix_infrastructure_items_care_space_id"):
            stmt = re.search(r'^(CREATE (?:UNIQUE )?INDEX IF NOT EXISTS "%s" ON [^\n]*;)$' % name, gen16, re.M)
            self.assertIsNotNone(stmt, name)
            self.assertTrue(contains(stmt.group(1), accounting_text), name)
            checked += 1
        gen17 = generated[(folder_of("17"), "04_indexes.sql")]
        stmt = re.search(r'^(CREATE UNIQUE INDEX IF NOT EXISTS "ux_service_catalog_practice_id_id" ON [^\n]*;)$', gen17, re.M)
        self.assertIsNotNone(stmt)
        self.assertTrue(contains(stmt.group(1), billing_text))
        fk16 = generated[(folder_of("16"), "90_fk_deferred.sql")]
        for fk in ("fk_cost_centers_clinical_unit_id", "fk_infrastructure_items_care_space_id"):
            stmt = re.search(r'(DO \$\$ BEGIN\n    ALTER TABLE "accounting"\."[a-z_]+"\n        ADD CONSTRAINT "%s"[^\n]*\n        REFERENCES [^\n]*;\nEXCEPTION WHEN duplicate_object THEN NULL; END \$\$;)' % fk, fk16)
            self.assertIsNotNone(stmt, fk)
            self.assertTrue(contains(stmt.group(1), accounting_text), fk)
        self.assertGreater(checked, 60)


# --------------------------------------------------------------------------------------------
SCOPE_CASES = 29


@unittest.skipUnless(os.environ.get("SALUD_TEST_PGDATABASE") and shutil.which("psql"),
                     "define SALUD_TEST_PGDATABASE (una base descartable, p. ej. CREATE DATABASE m_f5fin TEMPLATE alovida) "
                     "y las variables PG* de libpq; hace falta el cliente psql")
class LiveDatabaseTests(unittest.TestCase):
    # Hallazgos de seguridad: cada mutación quita UN arreglo y la prueba tiene que fallar en su caso.
    MUTATIONS = {
        "global_unique": "otro tenant con el MISMO source_ref_id de quirófano no choca",
        "no_case_check": "B cita el caso quirúrgico de A",
        "no_parent_triggers": "mover una cama CON activo contable a una sede de OTRA práctica",
    }

    # «CASO OK» por script: si un caso se saltara en silencio, el conteo no cerraría.
    EXPECTED_CASES = {"f5_fin_10_practice_test.sql": 19, "f5_fin_20_accounting_test.sql": 17,
                      "f5_fin_30_billing_test.sql": 129, "f5_fin_40_scope_test.sql": SCOPE_CASES}

    @classmethod
    def setUpClass(cls):
        cls.db = os.environ["SALUD_TEST_PGDATABASE"]
        if cls.db in ("alovida", "postgres", "template0", "template1"):
            raise unittest.SkipTest(f"{cls.db!r} no es una base descartable: crear una con TEMPLATE alovida")
        cls.env = {**os.environ, "PGDATABASE": cls.db}

    def psql(self, *args, sql_file=None, command=None, check=True):
        cmd = ["psql", "-X", "-q", "-v", "ON_ERROR_STOP=1", *args]
        if sql_file is not None:
            cmd += ["-f", str(sql_file)]
        if command is not None:
            cmd += ["-c", command]
        result = subprocess.run(cmd, env=self.env, cwd=SQL_TESTS, capture_output=True, text=True)
        if check and result.returncode != 0:
            self.fail(f"psql falló ({result.returncode}) en {sql_file or command}:\n{result.stderr[-2000:]}")
        return result

    def fingerprint(self):
        out = self.psql("-At", sql_file=SQL_TESTS / "f5_fin_fingerprint.sql").stdout
        return dict(line.rsplit("|", 2)[0::2] for line in out.strip().splitlines())

    def test_1_patches_apply_twice_and_the_second_pass_changes_nothing(self):
        for patch_file in PATCHES_IN_ORDER:
            self.psql(sql_file=patch_file)
        first = self.fingerprint()
        for patch_file in PATCHES_IN_ORDER:
            self.psql(sql_file=patch_file)
        second = self.fingerprint()
        self.assertEqual(first, second)
        self.assertEqual(set(first), {"acl", "col", "con", "fn", "idx", "pol", "rls", "tabla", "trg"})

    def test_2_sql_cases(self):
        count_sql = ("SELECT (SELECT count(*) FROM billing.charge_captures) + "
                     "(SELECT count(*) FROM billing.space_tariffs) + "
                     "(SELECT count(*) FROM practice.care_spaces)")
        # La base puede traer filas ajenas (otra suite que comita datos, p. ej. el plano de ejemplo):
        # lo que se exige es que ESTAS pruebas no dejen ninguna, no que la base esté vacía.
        before = self.psql("-At", command=count_sql).stdout.strip()
        for script, expected in self.EXPECTED_CASES.items():
            with self.subTest(script=script):
                result = self.psql(sql_file=SQL_TESTS / script)
                self.assertNotIn("CASO FALLIDO", result.stderr)
                self.assertEqual(result.stderr.count("CASO OK"), expected, result.stderr[-1500:])
        # Las pruebas terminan en ROLLBACK: no dejan filas.
        left = self.psql("-At", command=count_sql).stdout.strip()
        self.assertEqual(left, before)

    def scenario(self, setup_sql, patch_file, message):
        """Datos incompatibles + el patch: aborta con `message` y la transacción entera se deshace."""
        with tempfile.NamedTemporaryFile("w", suffix=".sql", delete=False, encoding="utf-8") as tmp:
            tmp.write(f"BEGIN;\n\\i {SQL_TESTS / 'f5_fin_00_fixture.sql'}\n{setup_sql}\n\\i {patch_file}\n")
        try:
            result = self.psql(sql_file=tmp.name, check=False)
        finally:
            os.unlink(tmp.name)
        self.assertNotEqual(result.returncode, 0, "el patch debía abortar")
        self.assertIsNotNone(re.search(message, result.stderr), result.stderr[-1500:])
        return result

    def test_3_incompatible_data_aborts_and_leaves_no_trace(self):
        before = self.fingerprint()
        a_bed, a1 = "a1300000-0000-4000-8000-000000000001", "a0000000-0000-4000-8000-000000000001"
        period = ("INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, "
                  "created_at, updated_at, row_version) VALUES (gen_random_uuid(), '%s', '%s', 'c0000000-0000-4000-8000-000000000001', %s, %s, now(), now(), 1);")
        self.scenario("ALTER TABLE practice.care_space_category_periods DROP CONSTRAINT ex_care_space_category_periods_validity;\n"
                      + period % (a1, a_bed, "'2026-01-01+00'", "NULL") + "\n" + period % (a1, a_bed, "'2026-06-01+00'", "NULL"),
                      PATCH_PRACTICE, r"F5e prácticas: 1 par\(es\) de períodos de categoría se solapan")

        tariff = ("INSERT INTO billing.space_tariffs (id, tenant_id, practice_id, tariff_kind_concept_id, bed_category_concept_id, service_catalog_id, unit_price, "
                  "currency_concept_id, valid_from, status_concept_id, created_at, updated_at, row_version) VALUES (gen_random_uuid(), '%s', "
                  "'a1000000-0000-4000-8000-000000000001', '1ae01bf6-a061-52ed-aa26-590705cb2202', 'c0000000-0000-4000-8000-000000000001', "
                  "'a6000000-0000-4000-8000-000000000001', 10, 'c0000000-0000-4000-8000-000000000010', %s, 'c0000000-0000-4000-8000-000000000020', now(), now(), 1);")
        self.scenario("ALTER TABLE billing.space_tariffs DROP CONSTRAINT ex_space_tariffs_validity;\n"
                      + tariff % (a1, "'2026-01-01'") + "\n" + tariff % (a1, "'2026-06-01'"),
                      PATCH_BILLING, r"F5e facturación: 1 par\(es\) de tarifas se solapan")

        self.scenario("ALTER INDEX accounting.ux_cost_centers_practice_id_id RENAME TO ux_renombrado;",
                      PATCH_BILLING, r"falta accounting\.ux_cost_centers_practice_id_id")

        self.scenario("ALTER TABLE billing.space_tariffs DISABLE TRIGGER trg_space_tariffs_guard;\n"
                      + tariff % (a1, "'2026-01-01'") + "\n"
                      "UPDATE billing.space_tariffs SET care_space_id = 'a2300000-0000-4000-8000-000000000004', bed_category_concept_id = NULL;",
                      PATCH_BILLING, r"tarifas con sala de otra práctica=1")

        capture = ("INSERT INTO billing.charge_captures (id, tenant_id, practice_id, patient_profile_id, encounter_id, source_kind_concept_id, source_ref_id, "
                   "service_date, care_space_id, minimum_stay_charge, quantity, status_concept_id, idempotency_key, created_at, updated_at, row_version) "
                   "VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', "
                   "'a4000000-0000-4000-8000-000000000001', 'a5000000-0000-4000-8000-000000000001', %s, gen_random_uuid(), '2026-12-01', %s, false, %s, "
                   "'17def99a-0cb5-586c-a440-59d809709c0d', 'k-' || gen_random_uuid()::text, now(), now(), 1);")
        self.scenario("ALTER TABLE billing.charge_captures DISABLE TRIGGER trg_charge_captures_guard;\n"
                      + capture % ("'5f84ea44-b0d3-582c-86c1-32c81e422d30'", "'a2300000-0000-4000-8000-000000000004'", "1"),
                      PATCH_BILLING, r"cargos con cama de otra práctica=1")
        self.scenario("ALTER TABLE billing.charge_captures DISABLE TRIGGER trg_charge_captures_guard;\n"
                      + capture % ("'a79361f6-8787-56a5-9a90-a9436d02e217'", "NULL", "2"),
                      PATCH_BILLING, r"cargos de quirófano cuyo origen no es un caso del mismo tenant y práctica=1")

        self.scenario("DROP INDEX accounting.ux_cost_centers_unit_active;\nALTER TABLE accounting.cost_centers DISABLE TRIGGER trg_cost_centers_unit_practice;\n"
                      "UPDATE accounting.cost_centers SET clinical_unit_id = 'a1200000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000001';\n"
                      "INSERT INTO accounting.cost_centers (id, practice_id, code, name, status_concept_id, clinical_unit_id, created_at, updated_at) "
                      "VALUES (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'DUP', 'Duplicado', '38a1d301-f40d-5b17-a695-5e6d605f8b19', "
                      "'a1200000-0000-4000-8000-000000000001', now(), now());",
                      PATCH_ACCOUNTING, r"unidades con más de un centro de costo activo=1")

        self.scenario("ALTER TABLE accounting.cost_centers DISABLE TRIGGER trg_cost_centers_unit_practice;\n"
                      "UPDATE accounting.cost_centers SET clinical_unit_id = 'a1200000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000002';",
                      PATCH_ACCOUNTING, r"centros de costo con unidad de otra práctica=1")

        self.scenario("ALTER TABLE accounting.infrastructure_items DISABLE TRIGGER trg_infrastructure_items_space_practice;\n"
                      "INSERT INTO accounting.infrastructure_items (id, practice_id, name, category_concept_id, status_concept_id, care_space_id, created_at, updated_at) "
                      "VALUES (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'Cruzado', 'c0000000-0000-4000-8000-000000000020', "
                      "'c0000000-0000-4000-8000-000000000020', 'a2300000-0000-4000-8000-000000000004', now(), now());",
                      PATCH_ACCOUNTING, r"activos con espacio de otra práctica=1")
        # Nada de lo anterior dejó rastro (cada escenario es una transacción que no llegó a COMMIT).
        self.assertEqual(self.fingerprint(), before)


    def test_4_mutations_remove_one_fix_each_and_the_scope_test_fails(self):
        script = SQL_TESTS / "f5_fin_40_scope_test.sql"
        base = self.psql(sql_file=script)
        self.assertNotIn("CASO FALLIDO", base.stderr)
        for mutation, label in self.MUTATIONS.items():
            with self.subTest(mutation=mutation):
                result = self.psql("-v", f"mutacion={mutation}", sql_file=script, check=False)
                self.assertNotEqual(result.returncode, 0, "sin el arreglo la prueba debía fallar")
                self.assertIn("CASO FALLIDO", result.stderr)
                self.assertIn(label, result.stderr)
        # y las mutaciones no dejan nada (ROLLBACK): el script sin mutar sigue pasando.
        again = self.psql(sql_file=script)
        self.assertEqual(again.stderr.count("CASO OK"), SCOPE_CASES)


if __name__ == "__main__":
    unittest.main()
