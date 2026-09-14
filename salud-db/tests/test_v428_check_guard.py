#!/usr/bin/env python3
"""Contrato del guard CHECK del patch v4.2.8."""

from pathlib import Path
import re
import unittest


PATCH = (
    Path(__file__).resolve().parents[2]
    / "SQL"
    / "patches"
    / "2026-09-08_v428_billing_quotations.sql"
)


class V428CheckGuardTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")
        start = cls.sql.index("SELECT count(*) INTO n_check")
        end = cls.sql.index("\n\n    IF n_tablas", start)
        cls.guard = cls.sql[start:end]

    def test_accepts_the_canonical_equivalent_check(self) -> None:
        for condition in (
            "c.conrelid = 'billing.quotations'::regclass",
            "c.contype = 'c'",
            "c.convalidated",
            "cardinality(c.conkey) = 1",
            "a.attname = 'interest_calculation_method'",
            "pg_get_expr(c.conbin, c.conrelid, true)",
            "interest_calculation_method=ANYARRAY[''FLAT'',''FRENCH'']",
        ):
            self.assertIn(condition, self.guard)

    def test_does_not_trust_a_constraint_name(self) -> None:
        self.assertNotIn("WHERE conname =", self.guard)
        self.assertNotIn(
            "conname = 'ck_quotations_interest_calculation_method'", self.guard
        )
        self.assertIn("a.attnum = c.conkey[1]", self.guard)
        self.assertIn("NOT a.attisdropped", self.guard)

    def test_wrong_or_extended_domains_are_not_accepted(self) -> None:
        accepted = [
            line.strip().strip(",")
            for line in self.guard.splitlines()
            if line.strip().startswith("'interest_calculation_method=ANYARRAY[")
        ]
        self.assertEqual(
            accepted,
            [
                "'interest_calculation_method=ANYARRAY[''FLAT'',''FRENCH'']'",
                "'interest_calculation_method=ANYARRAY[''FRENCH'',''FLAT'']'",
            ],
        )

    def test_missing_check_still_fails_closed(self) -> None:
        verification = self.sql[self.sql.index("-- D. verificación") :]
        self.assertIn("n_check <> 1", verification)
        self.assertIn("RAISE EXCEPTION", verification)

    def test_idempotent_patch_contract_is_preserved(self) -> None:
        self.assertEqual(
            len(re.findall(r"^CREATE TABLE IF NOT EXISTS", self.sql, re.MULTILINE)),
            2,
        )
        self.assertEqual(
            len(re.findall(r"^CREATE INDEX IF NOT EXISTS", self.sql, re.MULTILINE)),
            10,
        )
        self.assertEqual(self.sql.count("EXCEPTION WHEN duplicate_object"), 10)


if __name__ == "__main__":
    unittest.main()
