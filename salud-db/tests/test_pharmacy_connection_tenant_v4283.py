"""model#110 — la conexión de una farmacia con su sistema externo es de SU tenant.

`pharmacy.pharmacy_integration_connections.connection_id` referencia
`integrations.provider_connections` (v4.2.83). El tenant de la fila sale de
`pharmacy.pharmacies.tenant_id` y el de la conexión de `provider_connections.tenant_id`:
tienen que coincidir, o `connection_id` va en nulo (modo manual). El paquete de semillas lo
cumple (`gen_seeds.phase_v4283_pharmacy_connection_tenant`) y la base lo exige
(`SQL/patches/2026-11-01_v4283_pharmacy_connection_tenant.sql`).
"""
import copy
import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "salud-db"))

import gen_seeds as gs  # noqa: E402

MODULES = ROOT / "seedsGenerales" / "modules"
PATCH = ROOT / "SQL" / "patches" / "2026-11-01_v4283_pharmacy_connection_tenant.sql"
FK_PATCH = ROOT / "SQL" / "patches" / "2026-10-31_v4283_pharmacy_connection_fk.sql"


def load(name: str) -> dict:
    return json.loads((MODULES / name).read_text(encoding="utf-8"))


def by_id(doc: dict, entity: str) -> dict:
    return {r["id"]: r for sec in ("boot", "mock")
            for r in doc.get(sec, {}).get("records", {}).get(entity, [])}


def tenant_mismatches(pharmacy_doc: dict, integrations_doc: dict) -> list[str]:
    pharmacies = by_id(pharmacy_doc, "pharmacies")
    conns = by_id(integrations_doc, "provider_connections")
    out = []
    for sec in ("boot", "mock"):
        for row in pharmacy_doc.get(sec, {}).get("records", {}).get("pharmacy_integration_connections", []):
            cid = row.get("connection_id")
            if cid is None:
                continue
            tenant = (pharmacies.get(row["pharmacy_id"]) or {}).get("tenant_id")
            conn = conns.get(cid)
            if conn is None or conn.get("tenant_id") != tenant:
                out.append(f"{row['id']} (farmacia {row['pharmacy_id']}, tenant {tenant}) → {cid} "
                           f"(tenant {conn and conn.get('tenant_id')})")
    return out


class PharmacyConnectionTenantV4283(unittest.TestCase):
    def setUp(self):
        self.pharmacy = load("24_pharmacy.seeds.json")
        self.integrations = load("12_integrations.seeds.json")

    def test_seeded_connections_belong_to_the_pharmacy_tenant(self):
        self.assertEqual(tenant_mismatches(self.pharmacy, self.integrations), [])

    def test_the_check_detects_a_cross_tenant_connection(self):
        broken = copy.deepcopy(self.pharmacy)
        rows = broken["mock"]["records"]["pharmacy_integration_connections"]
        pharmacies = by_id(broken, "pharmacies")
        row = next(r for r in rows if r.get("connection_id"))
        tenant = pharmacies[row["pharmacy_id"]]["tenant_id"]
        other = next(c for c in by_id(self.integrations, "provider_connections").values()
                     if c["tenant_id"] != tenant)
        row["connection_id"] = other["id"]
        self.assertEqual(len(tenant_mismatches(broken, self.integrations)), 1)

    def test_generator_repoints_or_nulls_cross_tenant_connections(self):
        docs = {"24": copy.deepcopy(self.pharmacy), "12": self.integrations}
        rows = docs["24"]["mock"]["records"]["pharmacy_integration_connections"]
        pharmacies = by_id(docs["24"], "pharmacies")
        conns = by_id(self.integrations, "provider_connections")
        for row in rows:  # cada fila a una conexión de OTRO tenant
            tenant = pharmacies[row["pharmacy_id"]]["tenant_id"]
            row["connection_id"] = next(c["id"] for c in conns.values() if c["tenant_id"] != tenant)
        stats = gs.phase_v4283_pharmacy_connection_tenant(docs)
        self.assertEqual(stats["conexiones"], len(rows))
        self.assertEqual(tenant_mismatches(docs["24"], self.integrations), [])
        tenants_with_conns = {c["tenant_id"] for c in conns.values()}
        for row in rows:
            has = pharmacies[row["pharmacy_id"]]["tenant_id"] in tenants_with_conns
            self.assertEqual(row["connection_id"] is not None, has, row["id"])
        self.assertEqual(gs.phase_v4283_pharmacy_connection_tenant(docs)["conexiones"], 0, "no idempotente")

    def test_patch_enforces_tenant_on_both_sides_and_fails_closed(self):
        sql = PATCH.read_text(encoding="utf-8")
        self.assertIn("BEGIN;", sql)
        self.assertIn("COMMIT;", sql)
        for trg in ("trg_pharmacy_integration_connections_connection_tenant",
                    "trg_pharmacies_connection_tenant",
                    "trg_provider_connections_pharmacy_tenant"):
            self.assertIn(f'DROP TRIGGER IF EXISTS "{trg}"', sql)
            self.assertIn(f'CREATE TRIGGER "{trg}"', sql)
        self.assertIn('BEFORE INSERT OR UPDATE OF "pharmacy_id", "connection_id"', sql)
        self.assertIn("ERRCODE = 'foreign_key_violation'", sql)
        self.assertIn("pc.tenant_id IS DISTINCT FROM ph.tenant_id", sql)
        # va después del parche de la FK (orden alfabético de SQL/patches/)
        self.assertLess(FK_PATCH.name, PATCH.name)


if __name__ == "__main__":
    unittest.main()
