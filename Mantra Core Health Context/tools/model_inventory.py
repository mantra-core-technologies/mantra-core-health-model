#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Inventario canónico y reproducible del modelo SALUD.

Fuente única de la verdad para los conteos. Clasifica CADA declaración `entity`
de los .puml en una y solo una clase, de modo que:

    entity_declarations_total == tables_stores + views + reference_only + index_sets

Uso:
    python tools/model_inventory.py            # reporte legible
    python tools/model_inventory.py --json      # JSON (para propagar a docs)

No depende de librerías externas. Determinista: mismo input -> mismo output.
"""
import os, re, sys, json, glob

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
MODULES = os.path.join(ROOT, "modules")

ENTITY_LINE = re.compile(r'^\s*entity\b')
STEREO = re.compile(r'<<([A-Z_]+)>>')

def classify(stereos):
    """Una entidad pertenece a exactamente una clase, por prioridad."""
    if "INDEX_SET" in stereos: return "index_sets"
    if "REFERENCE_ONLY" in stereos: return "reference_only"
    if "VIEW" in stereos or "MATERIALIZED_VIEW" in stereos: return "views"
    return "tables_stores"

def inventory():
    files = sorted(glob.glob(os.path.join(MODULES, "diagram_*.puml")))
    totals = {"tables_stores":0,"views":0,"reference_only":0,"index_sets":0}
    fk = 0
    schemas = set()
    per_module = {}
    for path in files:
        num = int(re.search(r"diagram_(\d+)_", os.path.basename(path)).group(1))
        code = re.search(r"diagram_\d+_(.+)\.puml", os.path.basename(path)).group(1)
        text = open(path, encoding="utf-8").read()
        sm = re.search(r"schema:\s*([a-z_]+)", text)
        if sm: schemas.add(sm.group(1))
        fk += len(re.findall(r'<<FK>>', text))
        pm = {"tables_stores":0,"views":0,"reference_only":0,"index_sets":0}
        for line in text.splitlines():
            if ENTITY_LINE.match(line):
                cls = classify(set(STEREO.findall(line)))
                totals[cls] += 1
                pm[cls] += 1
        per_module[num] = (code, pm)
    total = sum(totals.values())
    return {
        "modules_puml": len(files),
        "schemas": len(schemas),
        "entity_declarations_total": total,
        "tables_stores": totals["tables_stores"],
        "views": totals["views"],
        "reference_only": totals["reference_only"],
        "index_sets": totals["index_sets"],
        "fk_references": fk,
        "_per_module": per_module,
    }

def main():
    inv = inventory()
    if "--json" in sys.argv:
        out = {k:v for k,v in inv.items() if not k.startswith("_")}
        # per-module compacto para el manifest
        out["per_module"] = {str(n):{"code":c,"table_like_elements":pm["tables_stores"],
            "view_elements":pm["views"],"index_sets":pm["index_sets"]}
            for n,(c,pm) in inv["_per_module"].items()}
        print(json.dumps(out, ensure_ascii=False, indent=2))
        return
    print("SALUD — inventario canónico (reproducible)")
    print(f"  modules_puml               : {inv['modules_puml']}")
    print(f"  schemas                    : {inv['schemas']}")
    print(f"  entity_declarations_total  : {inv['entity_declarations_total']}")
    print(f"    tables_stores            : {inv['tables_stores']}")
    print(f"    views                    : {inv['views']}")
    print(f"    reference_only           : {inv['reference_only']}")
    print(f"    index_sets               : {inv['index_sets']}")
    s = inv['tables_stores']+inv['views']+inv['reference_only']+inv['index_sets']
    print(f"    (suma clases)            : {s}  {'OK' if s==inv['entity_declarations_total'] else 'MISMATCH'}")
    print(f"  fk_references              : {inv['fk_references']}")

if __name__ == "__main__":
    main()
