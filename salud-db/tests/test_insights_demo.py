#!/usr/bin/env python3
"""Paridad del puerto Python de los datos de demostración de AloVida Insights.

Las constantes de abajo salen de ejecutar `mockCampaignFacts()` del simulador del front
(`src/app/core/mock/handlers/insights/facts.dataset.ts`): son la suma sobre TODAS las filas
de hechos diarios, ventana 2026-09-01..2026-10-29. Si una prueba de acá falla, el puerto de
`salud-db/insights_demo.py` ya no reproduce al simulador (o el simulador cambió y hay que
regenerar el golden a conciencia).
"""

import json
import sys
import unittest
from pathlib import Path

SALUD_DB = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SALUD_DB))

import insights_demo as demo  # noqa: E402

MODEL_ROOT = SALUD_DB.parent
SEEDS = MODEL_ROOT / "seedsGenerales" / "modules" / "50_marketing.seeds.json"
GOLDEN = MODEL_ROOT / "seedsGenerales" / "modules" / "50_marketing.insights-golden.json"

# Valores del simulador (ver docstring). No se recalculan: son el contrato.
EXPECTED = {
    "rows": 735,
    "impressions": 5455307,
    "clicks": 152886,
    "registrations": 9116,
    "conversions": 2454,
    "spend_cents": 10412901,
}


class PrngPortTests(unittest.TestCase):
    def test_math_round_is_floor_plus_half_not_bankers_rounding(self) -> None:
        self.assertEqual(demo.js_round(2.5), 3)
        self.assertEqual(demo.js_round(0.5), 1)
        self.assertEqual(demo.js_round(-2.5), -2)
        self.assertEqual(demo.js_round(1.4999999), 1)

    def test_imul_wraps_to_32_bits(self) -> None:
        # Math.imul(0xffffffff, 5) == -5  ->  0xfffffffb sin signo
        self.assertEqual(demo.imul(0xFFFFFFFF, 5), 0xFFFFFFFB)
        # FNV-1a: el hash de la cadena vacía es el offset basis
        self.assertEqual(demo.hash_seed(""), 0x811C9DC5)
        # FNV-1a 32 bits de "a" (vector publicado)
        self.assertEqual(demo.hash_seed("a"), 0xE40C292C)

    def test_noise_is_stable_and_bounded(self) -> None:
        a = demo.noise("c1|google|2026-10-01|s", 0.06)
        self.assertEqual(a, demo.noise("c1|google|2026-10-01|s", 0.06))
        self.assertTrue(0.94 <= a <= 1.06)


class FactsParityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.facts = demo.build_daily_facts()

    def test_totals_match_the_front_simulator(self) -> None:
        got = demo.sum_measures(self.facts)
        for key, want in EXPECTED.items():
            self.assertEqual(got[key], want, key)

    def test_constants_in_module_match_expected(self) -> None:
        self.assertEqual(demo.PARITY_TOTALS, EXPECTED)

    def test_funnel_is_monotonic_in_every_row(self) -> None:
        for f in self.facts:
            self.assertLessEqual(f["clicks"], f["impressions"])
            self.assertLessEqual(f["conversions"], f["first_uses"])
            self.assertLessEqual(f["first_uses"], f["activations"])
            self.assertLessEqual(f["activations"], f["registrations"])

    def test_window_and_ordering(self) -> None:
        self.assertEqual(self.facts[0]["date"], "2026-09-01")
        self.assertEqual(self.facts[-1]["date"], demo.CUTOFF)
        keys = [(f["date"], f["campaign"], f["channel"]) for f in self.facts]
        self.assertEqual(keys, sorted(keys))
        self.assertEqual(len(keys), len(set(keys)))


class SeededPackageTests(unittest.TestCase):
    """El JSON sembrado por gen_seeds.py coincide con el generador (y con el simulador)."""

    @classmethod
    def setUpClass(cls) -> None:
        cls.doc = json.loads(SEEDS.read_text(encoding="utf-8"))
        cls.golden = json.loads(GOLDEN.read_text(encoding="utf-8"))

    def test_seeded_fact_rows_sum_to_the_parity_totals(self) -> None:
        rows = self.doc["mock"]["records"]["insights_campaign_daily_facts"]
        total = demo.sum_measures(rows)
        for key, want in EXPECTED.items():
            self.assertEqual(total[key], want, key)

    def test_golden_totals_and_breakdowns_are_consistent(self) -> None:
        totals = self.golden["totals"]
        for key, want in EXPECTED.items():
            self.assertEqual(totals[key], want, key)
        for level in ("byCampaign", "byCampaignChannel"):
            self.assertEqual(sum(v["rows"] for v in self.golden[level].values()), 735, level)
            self.assertEqual(sum(v["impressions"] for v in self.golden[level].values()),
                             EXPECTED["impressions"], level)
        self.assertEqual(self.golden, demo.golden())

    def test_every_fact_has_a_creative_and_the_natural_key_is_unique(self) -> None:
        recs = self.doc["mock"]["records"]
        creatives = {c["id"]: c for c in self.doc["boot"]["records"]["insights_creatives"]}
        campaigns = {c["id"] for c in self.doc["boot"]["records"]["insights_campaigns"]}
        seen = set()
        for f in recs["insights_campaign_daily_facts"]:
            self.assertIsNotNone(f["creative_id"])
            cr = creatives[f["creative_id"]]
            self.assertEqual((cr["campaign_id"], cr["channel_code"]), (f["campaign_id"], f["channel_code"]))
            self.assertIn(f["campaign_id"], campaigns)
            key = (f["fact_date"], f["campaign_id"], f["channel_code"], f["creative_id"])
            self.assertNotIn(key, seen)
            seen.add(key)

    def test_catalog_counts_and_rule_defaults(self) -> None:
        boot = self.doc["boot"]["records"]
        self.assertEqual(len(boot["insights_campaigns"]), 4)
        self.assertEqual(len(boot["insights_milestones"]), 6)
        self.assertEqual(sorted(s["code"] for s in boot["insights_data_sources"]),
                         ["app", "google", "meta", "tiktok", "web", "youtube"])
        self.assertTrue(all(s["dataset_code"] == "demo" for s in boot["insights_data_sources"]))
        rules = {r["code"]: r for r in boot["insights_alert_rules"]}
        self.assertEqual({k: (float(v["default_threshold"]), v["direction"]) for k, v in rules.items()},
                         {"cac": (20.0, "+"), "ctrdrop": (12.0, "-"), "ctrspike": (50.0, "+"),
                          "cvr": (15.0, "-"), "neg": (25.0, "+"), "onb": (20.0, "-"),
                          "feed": (24.0, "+")})
        for r in rules.values():
            self.assertEqual(r["threshold"], r["default_threshold"])


if __name__ == "__main__":
    unittest.main()
