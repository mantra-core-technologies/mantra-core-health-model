#!/usr/bin/env python3
"""
gen_apply.py — Genera SQL/apply_all.sql: un runner psql que aplica TODO el SQL relacional
en orden seguro, OMITIENDO los 90_fk_deferred (que van al final, tras crear todos los schemas).

Orden:
  1. 00_shared/00_types.sql              (enum technical_data_type)
  2. _integrity/00_integrity_functions.sql
  3. por módulo (numérico): 01_schema → 02_tables → 03_fk_intra → 04_indexes → 05_constraints
  (90_fk_deferred se omite a propósito)

Uso del runner:  psql -v ON_ERROR_STOP=1 -U salud -d salud -f SQL/apply_all.sql
"""
from __future__ import annotations
import re

import gen_ddl

SQL = gen_ddl.REPO / "SQL"
PHASES = ["01_schema.sql", "02_tables.sql", "03_fk_intra.sql", "04_indexes.sql", "05_constraints.sql"]


def main():
    lines = [
        "-- apply_all.sql — GENERADO por gen_apply.py. Aplica todo el SQL relacional",
        "-- MENOS los 90_fk_deferred (aplicar esos al final, con todos los schemas creados).",
        "-- Uso:  psql -v ON_ERROR_STOP=1 -U salud -d salud -f SQL/apply_all.sql",
        "\\set ON_ERROR_STOP on",
        "\\timing on",
        "",
    ]

    def add(rel):
        if (SQL / rel).exists():
            lines.append(f"\\echo >>> {rel}")
            lines.append(f"\\ir {rel}")

    add("00_shared/00_types.sql")
    add("_integrity/00_integrity_functions.sql")
    lines.append("")

    mods = sorted(
        (d for d in SQL.iterdir()
         if d.is_dir() and re.match(r"^\d\d_", d.name) and d.name != "00_shared"),
        key=lambda d: d.name)
    for d in mods:
        lines.append(f"-- ═══ módulo {d.name} ═══")
        for ph in PHASES:
            add(f"{d.name}/{ph}")
        lines.append("")

    lines.append("-- 90_fk_deferred.sql OMITIDOS a propósito.")
    lines.append("\\echo === apply_all completado (sin 90_fk_deferred) ===")
    (SQL / "apply_all.sql").write_text("\n".join(lines) + "\n", encoding="utf-8")

    # Runner gemelo: SOLO los 90_fk_deferred (correr cuando todos los schemas existan).
    dlines = [
        "-- apply_deferred.sql — GENERADO por gen_apply.py. Aplica SOLO los 90_fk_deferred",
        "-- (FK cross-schema). Requiere apply_all.sql ya aplicado (todos los schemas creados).",
        "-- Uso:  psql -v ON_ERROR_STOP=1 -U salud -d salud -f SQL/apply_deferred.sql",
        "\\set ON_ERROR_STOP on",
        "\\timing on",
        "",
    ]
    n_def = 0
    for d in mods:
        if (d / "90_fk_deferred.sql").exists():
            dlines.append(f"\\echo >>> {d.name}/90_fk_deferred.sql")
            dlines.append(f"\\ir {d.name}/90_fk_deferred.sql")
            n_def += 1
    dlines.append("\\echo === apply_deferred completado ===")
    (SQL / "apply_deferred.sql").write_text("\n".join(dlines) + "\n", encoding="utf-8")
    print(f"SQL/apply_deferred.sql generado · {n_def} archivos 90_fk_deferred")

    n_mods = len(mods)
    n_constraints = sum(1 for d in mods if (d / "05_constraints.sql").exists())
    print(f"SQL/apply_all.sql generado · {n_mods} módulos · {n_constraints} con 05_constraints "
          f"· 90_fk_deferred omitidos")


if __name__ == "__main__":
    main()
