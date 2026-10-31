#!/usr/bin/env python3
"""Contrato estático del parche v4.2.73 (revisión de seguridad del gobierno de accesos, ronda 1).

La verificación DINÁMICA (rechazos reales de Postgres, RLS con `mantra_app`, DENY en `support_access_allowed`,
TRUNCATE de la bitácora WORM) vive en `salud-db/demo/08-verifica-gobierno.sql` (G11) y en la int-spec de la API
`test/integration/governance-seg-ronda1.int-spec.ts`; este archivo impide que el parche, el SQL generado y los .puml
vuelvan a divergir sin base de datos a mano.

Correr:  python -m unittest salud-db/tests/test_governance_v4273.py   (desde la raíz del repo del modelo)
"""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[2]
PATCHES = ROOT / "SQL" / "patches"
P73 = PATCHES / "2026-11-03_v4273_revision_seguridad_gobierno.sql"
P72 = PATCHES / "2026-11-02_v4272_gobierno_de_accesos.sql"
P69 = PATCHES / "2026-10-30_v4269_personal_apoyo.sql"
RLS = PATCHES / "2026-08-05_tenant_rls.sql"
SQL29 = ROOT / "SQL" / "29_delegated_access"
PUML = ROOT / "Mantra Core Health Context" / "modules"

TWO = ["organization_user_assignments", "practitioner_delegate_assignments"]


def table_block(sql: str, table: str) -> str:
    m = re.search(r'CREATE TABLE IF NOT EXISTS "delegated_access"\."%s" \((.*?)\n\);' % table, sql, re.S)
    assert m, table
    return m.group(1)


class PatchV4273Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = P73.read_text(encoding="utf-8")

    def test_one_transaction_and_idempotent_pieces(self) -> None:
        self.assertIn("\nBEGIN;\n", self.sql)
        self.assertTrue(self.sql.rstrip().endswith("COMMIT;"))
        for table in TWO:
            self.assertIn(
                'ALTER TABLE "delegated_access"."%s" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;' % table, self.sql)
            self.assertIn('ALTER TABLE "delegated_access"."%s" ALTER COLUMN "tenant_id" SET NOT NULL;' % table, self.sql)
            self.assertIn('"fk_%s_tenant_id"' % table, self.sql)
            self.assertIn('CREATE INDEX IF NOT EXISTS "ix_%s_tenant_id"' % table, self.sql)
        self.assertGreaterEqual(self.sql.count("DROP TRIGGER IF EXISTS trg_support_tenant_consistency"), 2)

    def test_backfill_uses_membership_and_permission_set(self) -> None:
        self.assertRegex(self.sql, r'SET "tenant_id" = tm\."tenant_id"\s+FROM "directory"\."tenant_memberships" tm')
        self.assertRegex(self.sql, r'SET "tenant_id" = s\."tenant_id"\s+FROM "delegated_access"\."delegated_permission_sets" s')

    def test_consistency_function_covers_the_two_tables(self) -> None:
        fn = self.sql[self.sql.index('CREATE OR REPLACE FUNCTION "integrity"."support_tenant_consistency"()'):]
        fn = fn[:fn.index("$fn$;", fn.index("RETURN NEW;"))]
        for token in ("'organization_user_assignments'", "'practitioner_delegate_assignments'", "tenant_membership_id",
                      "delegated_permission_set_id", "delegate_user_assignment_id", "diagnostic_unit_id", "pharmacy_id"):
            self.assertIn(token, fn)
        # sigue cubriendo lo del v4272 (la funcion se reemplaza entera)
        for token in ("'support_scope_grants'", "'access_review_items'", "'sod_exceptions'", "source_role_template_id",
                      "'conversation_assignments'"):
            self.assertIn(token, fn)

    def test_rls_in_27_tables_and_fails_when_missing(self) -> None:
        pairs = re.findall(r"\('(\w+)', '(\w+)'\)", self.sql[self.sql.index("-- ---- 3. A-B1"):self.sql.index("-- ---- 4. A-B2")])
        self.assertEqual(len(set(pairs)), 27)
        for table in TWO:
            self.assertIn(("delegated_access", table), pairs)
        self.assertIn("RAISE EXCEPTION 'v4273: sin RLS forzada + tenant_isolation", self.sql)

    def test_decision_log_is_worm_for_the_app_and_the_owner(self) -> None:
        self.assertIn('CREATE OR REPLACE FUNCTION "integrity"."forbid_truncate"()', self.sql)
        self.assertIn('CREATE TRIGGER trg_forbid_truncate BEFORE TRUNCATE ON "delegated_access"."access_decision_log"', self.sql)
        self.assertIn('REVOKE UPDATE, DELETE, TRUNCATE ON "delegated_access"."access_decision_log" FROM mantra_app;', self.sql)
        self.assertIn('GRANT SELECT, INSERT ON "delegated_access"."access_decision_log" TO mantra_app;', self.sql)

    def test_support_access_allowed_respects_deny_and_superseded(self) -> None:
        fn = self.sql[self.sql.index('CREATE OR REPLACE FUNCTION "delegated_access"."support_access_allowed"('):]
        fn = fn[:fn.index("$fn$;", fn.index("AS $fn$") + 8)]
        self.assertIn('g."effect_concept_id" = \'6905e0db-1650-5d49-adca-8b2688ac049c\'', fn)  # ALLOW
        self.assertIn('dg."effect_concept_id" = \'b038e546-a6ba-5848-9cd2-04b02ccb22b0\'', fn)  # DENY
        self.assertIn('sga."superseded_at" IS NULL', fn)
        self.assertIn("AND NOT EXISTS", fn)
        self.assertIn("REFERENCIA GRUESA", self.sql)

    def test_earlier_patches_no_longer_skip_rls_silently(self) -> None:
        for path in (P69, P72):
            text = path.read_text(encoding="utf-8")
            self.assertNotIn("quedan sin RLS hasta ejecutar", text, path.name)
            block = text[text.index("v4.2.73 (revision de seguridad A-B1)"):][:900]
            self.assertNotIn("RETURN;", block, path.name)
            self.assertIn("RAISE WARNING", block, path.name)
        self.assertIn("v_pol <> 12", P72.read_text(encoding="utf-8"))

    def test_tenant_rls_patch_keeps_the_worm_table_without_update_delete(self) -> None:
        text = RLS.read_text(encoding="utf-8")
        self.assertIn("REVOKE UPDATE, DELETE, TRUNCATE ON delegated_access.access_decision_log FROM mantra_app;", text)
        self.assertLess(text.index("GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES"),
                        text.index("REVOKE UPDATE, DELETE, TRUNCATE ON delegated_access.access_decision_log"))


class GeneratedModelTests(unittest.TestCase):
    def test_tenant_id_in_the_two_tables_and_their_fk_and_index(self) -> None:
        tables = (SQL29 / "02_tables.sql").read_text(encoding="utf-8")
        idx = (SQL29 / "04_indexes.sql").read_text(encoding="utf-8")
        fks = (SQL29 / "90_fk_deferred.sql").read_text(encoding="utf-8")
        for table in TWO:
            self.assertIn('"tenant_id" uuid NOT NULL', table_block(tables, table))
            self.assertIn('"ix_%s_tenant_id"' % table, idx)
            self.assertIn('"fk_%s_tenant_id"' % table, fks)

    def test_worm_truncate_guard_is_generated(self) -> None:
        constraints = (SQL29 / "05_constraints.sql").read_text(encoding="utf-8")
        self.assertIn('CREATE TRIGGER trg_forbid_truncate BEFORE TRUNCATE ON "delegated_access"."access_decision_log"', constraints)
        self.assertIn('REVOKE TRUNCATE ON "delegated_access"."access_decision_log" FROM PUBLIC;', constraints)
        fns = (ROOT / "SQL" / "_integrity" / "00_integrity_functions.sql").read_text(encoding="utf-8")
        self.assertIn('"integrity"."forbid_truncate"()', fns)

    def test_puml_declares_what_the_ddl_has(self) -> None:
        text = (PUML / "diagram_29_delegated_access.puml").read_text(encoding="utf-8")
        for table in TWO:
            body = text[text.index("entity %s {" % table):]
            body = body[:body.index("\n}")]
            self.assertIn("* tenant_id : uuid <<FK>>", body)
        self.assertIn("TRUNCATE : forbidden", (PUML / "diagram_33_integrity.puml").read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
