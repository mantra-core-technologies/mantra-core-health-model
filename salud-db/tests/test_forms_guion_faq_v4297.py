"""v4.2.97 — script de preguntas y preguntas frecuentes del profesional (módulo 09 forms).

Sin base de datos: comprueba que el DDL generado (`SQL/09_forms/`) trae las tres tablas con
las columnas del contrato con la API y el front, que el parche
`2026-11-06_v4297_forms_guion_preguntas_y_faq.sql` copia exactamente las sentencias generadas
(tablas, FK, índices, CHECK y UNIQUE), que `apply_all.sql` aplica el nuevo `05_constraints.sql`
de forms y que `UNIQUE_SQL` (gen_integrity) emite un UNIQUE diferible y rechaza declaraciones
mal formadas.
"""
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "salud-db"))
import gen_integrity  # noqa: E402

FORMS = ROOT / "SQL" / "09_forms"
PATCH = (ROOT / "SQL" / "patches" / "2026-11-06_v4297_forms_guion_preguntas_y_faq.sql").read_text(encoding="utf-8")
TABLES = ("question_scripts", "question_script_items", "faq_entries")

# Columnas del contrato (nombre, tipo y nulabilidad/default tal como las emite gen_ddl).
CONTRACT = {
    "question_scripts": [
        '"id" uuid NOT NULL',
        '"owner_practitioner_id" uuid NOT NULL',
        '"title" text NOT NULL',
        '"description" text',
        '"specialty_code" text',
        '"status" text NOT NULL DEFAULT \'active\'',
        '"created_at" timestamptz NOT NULL DEFAULT now()',
        '"updated_at" timestamptz NOT NULL DEFAULT now()',
        '"row_version" integer NOT NULL DEFAULT 1',
    ],
    "question_script_items": [
        '"id" uuid NOT NULL',
        '"script_id" uuid NOT NULL',
        '"position" integer NOT NULL',
        '"question_text" text NOT NULL',
        '"help_text" text',
        '"answer_type" text NOT NULL',
        '"options" jsonb',
        '"required" boolean NOT NULL DEFAULT false',
    ],
    "faq_entries": [
        '"id" uuid NOT NULL',
        '"owner_practitioner_id" uuid NOT NULL',
        '"question" text NOT NULL',
        '"answer" text NOT NULL',
        '"category" text',
        '"position" integer NOT NULL',
        '"is_published" boolean NOT NULL DEFAULT false',
        '"created_at" timestamptz NOT NULL DEFAULT now()',
        '"updated_at" timestamptz NOT NULL DEFAULT now()',
    ],
}


def generated(phase: str) -> str:
    return (FORMS / phase).read_text(encoding="utf-8")


def table_stmt(sql: str, table: str) -> str:
    m = re.search(rf'CREATE TABLE IF NOT EXISTS "forms"\."{table}" \(.*?\n\);\n', sql, re.S)
    assert m, table
    return m.group(0)


class FormsGuionFaqV4297(unittest.TestCase):
    def test_contract_columns_are_generated(self):
        tables = generated("02_tables.sql")
        for table, cols in CONTRACT.items():
            body = table_stmt(tables, table)
            for col in cols:
                self.assertIn(f"    {col},", body, f"{table}: {col}")

    def test_patch_copies_generated_tables(self):
        tables = generated("02_tables.sql")
        for table in TABLES:
            self.assertIn(table_stmt(tables, table), PATCH, table)

    def test_owner_and_script_fks(self):
        deferred, intra = generated("90_fk_deferred.sql"), generated("03_fk_intra.sql")
        for table in ("question_scripts", "faq_entries"):
            stmt = (f'    ALTER TABLE "forms"."{table}"\n'
                    f'        ADD CONSTRAINT "fk_{table}_owner_practitioner_id" FOREIGN KEY ("owner_practitioner_id")\n'
                    f'        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");\n')
            self.assertIn(stmt, deferred, table)
            self.assertIn(stmt, PATCH, table)
        cascade = ('    ALTER TABLE "forms"."question_script_items"\n'
                   '        ADD CONSTRAINT "fk_question_script_items_script_id" FOREIGN KEY ("script_id")\n'
                   '        REFERENCES "forms"."question_scripts" ("id") ON DELETE CASCADE;\n')
        self.assertIn(cascade, intra)
        self.assertIn(cascade, PATCH)

    def test_every_generated_fk_and_index_is_in_the_patch(self):
        for phase in ("03_fk_intra.sql", "90_fk_deferred.sql"):
            sql = generated(phase)
            for m in re.finditer(r'DO \$\$ BEGIN\n    ALTER TABLE "forms"\."(\w+)"\n.*?END \$\$;', sql, re.S):
                if m.group(1) in TABLES:
                    self.assertIn(m.group(0), PATCH)
        idx = [ln for ln in generated("04_indexes.sql").splitlines()
               if any(f'ON "forms"."{t}"' in ln for t in TABLES)]
        self.assertEqual(len(idx), 9)
        self.assertTrue(any('"ix_question_scripts_owner_practitioner_id"' in ln for ln in idx))
        self.assertTrue(any('"ix_faq_entries_owner_practitioner_id"' in ln for ln in idx))
        for ln in idx:
            self.assertIn(ln, PATCH)

    def test_constraints_are_generated_and_copied(self):
        cons = generated("05_constraints.sql")
        for name in ("ck_question_scripts_title", "ck_question_scripts_status",
                     "ck_question_script_items_question_text", "ck_question_script_items_answer_type",
                     "ck_question_script_items_position", "ck_question_script_items_options",
                     "ck_faq_entries_question", "ck_faq_entries_answer", "ck_faq_entries_position"):
            m = re.search(rf'^ALTER TABLE "forms"\."\w+" ADD CONSTRAINT "{name}" CHECK \(.*\);$', cons, re.M)
            self.assertTrue(m, name)
            self.assertIn(m.group(0), PATCH)
        self.assertIn("'free_text', 'yes_no', 'single_choice', 'multiple_choice', 'number', 'date'", cons)
        self.assertIn("\"status\" IN ('active', 'archived')", cons)
        for table, name, cols in (
            ("question_script_items", "uq_question_script_items_script_position", '"script_id", "position"'),
            ("faq_entries", "uq_faq_entries_owner_position", '"owner_practitioner_id", "position"'),
        ):
            stmt = (f'ALTER TABLE "forms"."{table}" ADD CONSTRAINT "{name}"\n'
                    f'    UNIQUE ({cols}) DEFERRABLE INITIALLY IMMEDIATE;\n')
            self.assertIn(stmt, cons)
            self.assertIn(stmt, PATCH)

    def test_apply_all_runs_forms_constraints_after_indexes(self):
        runner = (ROOT / "SQL" / "apply_all.sql").read_text(encoding="utf-8")
        self.assertLess(runner.index(r"\ir 09_forms/04_indexes.sql"), runner.index(r"\ir 09_forms/05_constraints.sql"))

    def test_patch_is_one_idempotent_transaction_without_backfill(self):
        body = PATCH.split("BEGIN;", 1)[1].strip()
        self.assertTrue(body.endswith("COMMIT;"))
        self.assertNotIn('CREATE INDEX "', PATCH)
        self.assertNotIn('CREATE TABLE "', PATCH)
        self.assertEqual(PATCH.count("EXCEPTION WHEN duplicate_object THEN NULL"), 9)
        for name in re.findall(r'ADD CONSTRAINT "((?:ck|uq)_[a-z_]+)"', PATCH):
            self.assertIn(f'DROP CONSTRAINT IF EXISTS "{name}";', PATCH, name)
        code = "\n".join(ln for ln in PATCH.splitlines() if not ln.lstrip().startswith("--"))
        self.assertNotRegex(code, r"(?m)^\s*(UPDATE \"|INSERT INTO|DELETE FROM)")


class UniqueSqlGenerator(unittest.TestCase):
    def test_deferrable_unique(self):
        out = gen_integrity.unique_concreto("forms", "faq_entries",
                                            'uq_x | "a", "b" | DEFERRABLE INITIALLY IMMEDIATE')
        self.assertIn('ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "uq_x";', out)
        self.assertIn('    UNIQUE ("a", "b") DEFERRABLE INITIALLY IMMEDIATE;', out)

    def test_immediate_unique_without_third_part(self):
        out = gen_integrity.unique_concreto("forms", "t", 'uq_y | "a"')
        self.assertTrue(out.rstrip().endswith('UNIQUE ("a");'))

    def test_rejects_bad_declarations(self):
        for decl in ('uq_z', 'Bad Name | "a"', 'uq_z | a', 'uq_z | "a"; DROP TABLE x',
                     'uq_z | "a" | DEFERRABLE', 'uq_z | "a" | x | y'):
            with self.assertRaises(ValueError, msg=decl):
                gen_integrity.unique_concreto("forms", "t", decl)


if __name__ == "__main__":
    unittest.main()
