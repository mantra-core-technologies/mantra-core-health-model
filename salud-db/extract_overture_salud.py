#!/usr/bin/env python3
"""Lugares de salud de Bolivia desde Overture Maps Places → JSONL.

Lee el tema `places` de una versión publicada de Overture
(`s3://overturemaps-us-west-2/release/<versión>/theme=places/type=place/`,
acceso anónimo) sólo dentro del rectángulo de Bolivia, se queda con los que
declaran país `BO` y una categoría de salud, y escribe una fila por lugar con
nombre, categoría, confianza, dirección, teléfonos, coordenadas y las fuentes
con su licencia. Las farmacias no se extraen: la fuente oficial es AGEMED.

Licencias de Overture Places: CDLA-Permissive-2.0 (Overture, Meta, Microsoft),
Apache-2.0 (Foursquare) y CC0-1.0 (AllThePlaces) — la de cada fila va en
`sources[].license`. No incluye datos ODbL.

Uso (necesita `duckdb`):
    python salud-db/extract_overture_salud.py --release 2026-09-23.1 --out <bolivia-sources>/overture
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

CATEGORIAS = (
    "dental_clinic", "health_care", "hospital", "diagnostics_imaging_or_lab_service",
    "behavioral_or_mental_health_clinic", "specialized_health_care", "medical_service",
    "vision_or_eye_care_clinic", "pediatric_clinic", "primary_care_or_general_clinic",
    "specialized_medical_facility",
)


def main() -> None:
    import duckdb

    ap = argparse.ArgumentParser()
    ap.add_argument("--release", required=True)
    ap.add_argument("--out", required=True, type=Path)
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    destino = a.out / f"salud-bolivia-{a.release}.jsonl"

    con = duckdb.connect()
    con.execute("INSTALL httpfs; LOAD httpfs; SET s3_region='us-west-2'; INSTALL spatial; LOAD spatial;")
    lista = ", ".join(f"'{c}'" for c in CATEGORIAS)
    filas = con.execute(f"""
        SELECT id, names."primary" AS name, basic_category, taxonomy."primary" AS category,
               taxonomy.alternates AS alternates, confidence, operating_status,
               addresses, phones, websites, sources, ST_Y(geometry) AS lat, ST_X(geometry) AS lon
        FROM read_parquet('s3://overturemaps-us-west-2/release/{a.release}/theme=places/type=place/*', hive_partitioning=1)
        WHERE bbox.xmin BETWEEN -69.7 AND -57.4 AND bbox.ymin BETWEEN -23.0 AND -9.6
          AND list_contains([x.country for x in addresses], 'BO')
          AND basic_category IN ({lista})
        ORDER BY id
    """).fetchall()
    columnas = [d[0] for d in con.description]
    with destino.open("w", encoding="utf-8") as f:
        for fila in filas:
            f.write(json.dumps(dict(zip(columnas, fila)), ensure_ascii=False, default=str) + "\n")
    print(f"overture {a.release}: {len(filas)} lugares de salud → {destino}")


if __name__ == "__main__":
    main()
