# SALUD v4.0 Module Seeds - FINAL (team hand-off)

64 module seed files, verified and self-contained. Every module was analyzed and its
mock (and non-empty boot) data amplified from generic 8-row templates into richer,
varied, connected records so the backend team can build against realistic data.

## Volume
- Boot (production): 4,736   Mock (dev/test): 18,789   Total: 23,525
  (was 13,769; ~1.7x, intentionally bounded to stay memory-friendly on import)
- Unique IDs: 20,729 (0 duplicates)

## Verification (all PASS)
- 64/64 files valid JSON; declared vs actual counts: 0 mismatches.
- IDs: 20,729 unique, 0 collisions (deterministic UUIDv5).
- Generic filler dicts remaining: 0. Non-mock emails: 0. No real card data / secrets.
- Cross-module refs: 4,921/6,705 resolve in-package; the rest are external
  `*_concept_id` (terminology / module 03) or reference-only entities.

## What "amplified" means here
- Generic values ("ENTITY_01", payload == metadata, "mock_xxx_correlation_id") were
  replaced with realistic variety: spread timestamps, varied amounts/statuses, distinct
  business `payload_json` vs envelope `metadata_json`, deterministic correlation/trace IDs.
- Foreign keys and concept references were preserved (not invented), so referential
  integrity holds.
- The messaging **event backbone** is a hand-crafted, fully connected example (8 business
  flows with correlation+causation, 14 subscriptions, retries + dead-letter). See
  `amplification.events` inside `modules/35_messaging.seeds.json`.

## The package has ONE generator (2026-07-25)

`salud-db/gen_seeds.py` is the only tool that writes this package. Do not fix defects in the
JSON, and do not add a second pass over it: a tool that rewrites `modules/` without regenerating
`seed-manifest.json` and `checksums.json` leaves the package inconsistent with itself. If something
is wrong, fix the generator and re-run it — it is deterministic and idempotent (re-running over its
own output reports 0 changes in all 11 phases).

The 2026-07-25 pass closed the remaining defects **in the generator**: the type barrier now covers
`vector(N)`; `[2c]` seeds the relational tables that had no coverage and **fails if an undeclared
empty table appears**; `[3c]` reassigns `*_concept_id` that point outside the value set bound to
them by the model; `[3d]` empties values that only existed to satisfy an incorrect NOT NULL; and
`parse_unique()` now also reads the unique indexes of `NoSQL/58,59` — they were invisible, so six
tables died with `23505` and the per-entity savepoint discarded them whole (`vector_documents` had
**0 rows** in the database).

Current state: **24,603 rows** (boot 5,678 · mock 18,925) · 21,799 unique ids · 0 orphan columns ·
0 missing NOT NULL · 0 incompatible types · 0 dangling `*_concept_id` · 121,538 FK cells verified
with no violation. **10 tables are intentionally empty** and declared as such in the generator
(`INTENTIONALLY_EMPTY`): 9 runtime/transactional ones (campaign dispatches, delivery events,
adapter inbound events) plus `authz.service_principals`, which the `.puml` declares with its PK
only so other tables can reference it.

See `cierre-handoff-seeds-v4.0.7-2026-07-25.md` at the repo root for the full trail.

## Notes for the backend team
- Boot seeds are idempotent and run in all environments; mock seeds must hard-fail when
  NODE_ENV=production (see each module's `environment_policy` / `integrity_contract`).
- The amplified event deliveries use a small synthetic delivery-status vocabulary — map it
  to terminology (module 03) before production.
- Empty boot catalogs were left empty (not fabricated) to avoid inventing production data.
- Per-module before/after: `reports/amplification-per-module.json`; full check:
  `reports/clean-verification-report.json`; checksums: `checksums.json`.
