"""Los parches v4.2.81 son salida de `gen_v4281_patches.py`, no DDL escrito a mano: regenerarlos tiene que dar el mismo texto.

Falla si alguien edita un parche a mano, si cambia un .puml sin regenerar `SQL/` y los parches, o si cambian las FK que cuelgan de
`telemetry.user_activity_events` (la deduplicación previa del parche de idempotencia tiene que conocerlas todas).
"""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import gen_v4281_patches as gen  # noqa: E402


class PatchesAreGenerated(unittest.TestCase):
    def test_each_patch_matches_its_generator(self):
        for key, fn in gen.GENERATORS.items():
            with self.subTest(patch=key):
                name, text = fn()
                on_disk = (gen.PATCH_DIR / name).read_text(encoding="utf-8")
                self.assertEqual(on_disk, text, f"{name} no coincide con la salida de gen_v4281_patches.py {key}: regenerar")

    def test_each_patch_is_one_idempotent_transaction(self):
        for key, fn in gen.GENERATORS.items():
            with self.subTest(patch=key):
                _, text = fn()
                self.assertEqual(text.count("\nBEGIN;"), 1)
                self.assertEqual(text.count("\nCOMMIT;"), 1)
                self.assertIn("SET LOCAL lock_timeout", text)
                self.assertNotIn("DROP TABLE", text.split("REVERSA", 1)[0].replace("-- ", ""), "los parches solo agregan")

    def test_user_activity_events_dependents_are_known(self):
        self.assertEqual(gen.uae_dependents_in_model(), {t: sorted(c) for t, c in gen.UAE_DEPENDENTS.items()})

    def test_governance_tables_have_no_tenant_column_and_bulk_tables_have_it(self):
        text = gen.read("67_data_catalog/02_tables.sql") + gen.read("11_system_ops/02_tables.sql")
        for table in getattr(gen, "GOV67_TABLES", []) + getattr(gen, "GOV11_TABLES", []):
            block = gen.only(text, f'"{table}" (')
            self.assertNotIn('"tenant_id"', block, table)
            self.assertNotIn('"actor_tenant_id"', block, table)
        for table in getattr(gen, "BULK_TABLES", []):
            self.assertIn('"tenant_id" uuid NOT NULL', gen.only(text, f'"{table}" ('), table)


if __name__ == "__main__":
    unittest.main()
