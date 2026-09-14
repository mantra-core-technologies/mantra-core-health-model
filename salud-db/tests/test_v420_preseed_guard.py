#!/usr/bin/env python3
"""Contrato del backfill v4.2.0 frente al seed posterior de terminología."""

from pathlib import Path
import re
import unittest


PATCH = (
    Path(__file__).resolve().parents[2]
    / "SQL"
    / "patches"
    / "2026-08-26_v420_backfill_membresias_asistenciales.sql"
)

REQUIRED_CONCEPTS = {
    "9384ffcc-901f-5fb3-a9d6-2c1593d7f019": "directory:ROLE_PRACTITIONER",
    "13ca1b46-61d5-5c25-9d49-8247bcd7769c": "directory:MEMBERSHIP_ACTIVE",
    "297d044a-a1e9-51db-8f96-68f4de6b3d62": "directory:SCOPE_ALL_TENANT",
    "6db29320-acc3-50f6-ac19-cb906aa96209": "profiles:ACCOUNT_LINK_ACTIVE",
    "f581c24c-71bd-51b7-928b-7ea67da84baa": "profiles:AFFILIATION_ACTIVE",
    "a1084a63-5e11-53a4-9cbc-7cdc9ba8ba23": "profiles:AFFILIATION_APPROVED",
}


class V420PreseedGuardTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")

    def test_empty_database_returns_before_concept_validation(self) -> None:
        candidate_guard = self.sql.index("IF NOT EXISTS (\n    SELECT 1\n      FROM profiles.practitioner_affiliations")
        empty_notice = self.sql.index("0 membresías asistenciales legacy pendientes")
        concept_validation = self.sql.index("SELECT string_agg(e.code")
        backfill = self.sql.index("INSERT INTO directory.tenant_memberships")

        self.assertLess(candidate_guard, empty_notice)
        self.assertLess(empty_notice, concept_validation)
        self.assertLess(concept_validation, backfill)
        empty_branch = self.sql[
            self.sql.rfind("RAISE NOTICE", candidate_guard, empty_notice) :
            concept_validation
        ]
        self.assertRegex(empty_branch, r"RAISE NOTICE[\s\S]+RETURN;")

    def test_legacy_work_validates_every_required_concept_fail_closed(self) -> None:
        validation = self.sql[
            self.sql.index("SELECT string_agg(e.code") :
            self.sql.index("END $$;", self.sql.index("SELECT string_agg(e.code"))
        ]
        for concept_id, code in REQUIRED_CONCEPTS.items():
            self.assertIn(concept_id, validation)
            self.assertIn(code, validation)
        self.assertIn("cc.id = e.id AND cc.code = e.code", validation)
        self.assertIn("IF faltantes IS NOT NULL THEN", validation)
        self.assertIn("RAISE EXCEPTION", validation)

    def test_backfill_contract_and_idempotency_are_preserved(self) -> None:
        self.assertEqual(
            self.sql.count("INSERT INTO directory.tenant_memberships"), 1
        )
        self.assertIn("SELECT DISTINCT pal.user_id, ps.managing_tenant_id", self.sql)
        self.assertIn("WHERE NOT EXISTS (", self.sql[self.sql.index("INSERT INTO directory.tenant_memberships") :])
        self.assertIn("m.user_id = c.user_id", self.sql)
        self.assertIn("m.tenant_id = c.tenant_id", self.sql)

    def test_patch_does_not_seed_or_invent_concepts(self) -> None:
        self.assertNotIn("INSERT INTO terminology.catalog_concepts", self.sql)
        found_ids = set(
            re.findall(
                r"\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b",
                self.sql,
            )
        )
        self.assertEqual(found_ids, set(REQUIRED_CONCEPTS))


if __name__ == "__main__":
    unittest.main()
