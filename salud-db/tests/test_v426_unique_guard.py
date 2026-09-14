#!/usr/bin/env python3
"""Contrato del guard de unicidad del patch v4.2.6."""

from pathlib import Path
import re
import unittest


PATCH = (
    Path(__file__).resolve().parents[2]
    / "SQL"
    / "patches"
    / "2026-09-04_v426_medical_groups.sql"
)


class V426UniqueGuardTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")
        start = cls.sql.index("('unique (group_id, practitioner_profile_id)'")
        end = cls.sql.index("\n    ) AS e(objeto, existe)", start)
        cls.guard = cls.sql[start:end]

    def test_accepts_an_exact_unique_constraint(self) -> None:
        self.assertIn("FROM pg_constraint c", self.guard)
        self.assertIn("c.contype = 'u'", self.guard)
        self.assertIn("c.convalidated", self.guard)
        self.assertIn("cardinality(c.conkey) = 2", self.guard)
        self.assertIn(
            "ARRAY['group_id', 'practitioner_profile_id']", self.guard
        )

    def test_accepts_only_a_complete_non_partial_unique_index(self) -> None:
        for condition in (
            "i.indisunique",
            "i.indisvalid",
            "i.indisready",
            "i.indislive",
            "i.indpred IS NULL",
            "i.indexprs IS NULL",
            "i.indnkeyatts = 2",
            "i.indnatts = 2",
        ):
            self.assertIn(condition, self.guard)

        expected_columns = re.findall(
            r"= ARRAY\['group_id', 'practitioner_profile_id'\]", self.guard
        )
        self.assertEqual(len(expected_columns), 2)

    def test_does_not_trust_the_object_name(self) -> None:
        self.assertNotIn(
            "ux_medical_groups_group_members_group_practitioner", self.guard
        )
        self.assertIn("a.attrelid = c.conrelid", self.guard)
        self.assertIn("a.attrelid = i.indrelid", self.guard)

    def test_missing_uniqueness_still_fails_closed(self) -> None:
        verification = self.sql[self.sql.index("-- Fase 7") :]
        self.assertIn("WHERE NOT e.existe", verification)
        self.assertIn("IF faltantes IS NOT NULL THEN", verification)
        self.assertIn("RAISE EXCEPTION", verification)


if __name__ == "__main__":
    unittest.main()
