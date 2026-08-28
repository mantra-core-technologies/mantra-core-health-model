#!/usr/bin/env python3
"""
fix_vault_fk.py — Repara las notas FK del vault (grafo Obsidian) contra el modelo real.

1) Notas con destino ERRÓNEO (la tabla destino no existe en el modelo):
   a. Si la convención global resuelve a un schema correcto → corrige el destino
      (marcado "convención global — schema corregido").
   b. Si no hay destino válido → pasa a "Destino no resuelto" (temperatura-0),
      dejando constancia del destino previo inexistente.
2) Notas FALTANTES (bug de estereotipo compuesto <<PK,FK>>/<<FK,UK>> + módulo 54
   nunca parseado por el gen_fk viejo) → se crean con el formato canónico del vault.
   Los profile_id de los 7 perfiles subtipo → profiles.persons (CTI, doc semantic
   -data-analysis §3.1: "comparten PK con la persona").

La frase exacta "Destino no resuelto" se preserva: gen_ddl.resolve_fk la usa como marcador.
"""
from __future__ import annotations
import re
import sys

import gen_ddl

FK_DIR = gen_ddl.FK_DIR


def note_path(schema, table, col):
    return FK_DIR / f"FK {schema}.{table}.{col}.md"


def frontmatter(schema, code):
    return f"---\ntags:\n  - fk\n  - schema/{schema}\n  - modulo/{code}\n---\n"


def make_note(code, schema, table, col, stereo, dest, label):
    head = (f"{frontmatter(schema, code)}\n"
            f"# {table}.{col}  `<<{stereo}>>`\n\n"
            f"> Clave foránea de [[E {schema}.{table}|{table}]] · módulo [[M{code} {schema}]]\n\n")
    if dest is None:
        return head + "> Destino no resuelto automáticamente (sin coincidencia unívoca de entidad).\n"
    tsch, ttbl = dest
    return head + f"## Apunta a →\n- [[E {tsch}.{ttbl}|{ttbl}]]  _({label})_\n"


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    codes = sorted({p.stem.split("_")[1] for p in gen_ddl.PUML_DIR.glob("diagram_*.puml")})
    reg = gen_ddl.build_registry(codes)

    fixed_dest = fixed_unres = created = 0
    for code in codes:
        puml = next(gen_ddl.PUML_DIR.glob(f"diagram_{code}_*.puml"), None)
        schema, ents, *_ = gen_ddl.parse_module(puml)
        for e in ents:
            for c in e.columns:
                if not c.is_fk:
                    continue
                p = note_path(schema, e.name, c.name)
                conv = gen_ddl.resolve_fk_convention(schema, e.name, c.name, reg)

                if not p.exists():
                    # ---- nota faltante: crearla
                    stereo = "PK,FK" if c.is_pk else ("FK,UK" if c.is_uk else "FK")
                    if c.name == "profile_id" and schema == "profiles":
                        dest, label = ("profiles", "persons"), "CTI — subtipo comparte PK con persons"
                    elif conv is not None:
                        if c.name == "tenant_id":
                            label = "convención · tenant"
                        elif c.name.endswith("concept_id"):
                            label = "convención · terminología"
                        elif c.name.endswith("user_id"):
                            label = "convención · usuario"
                        else:
                            label = "convención por nombre"
                        dest = conv
                    else:
                        dest, label = None, ""
                    p.write_text(make_note(code, schema, e.name, c.name, stereo, dest, label),
                                 encoding="utf-8")
                    created += 1
                    continue

                # ---- nota existente: validar destino
                tgt = gen_ddl.resolve_fk(schema, e.name, c.name)
                if tgt is None or tgt in reg.get(tgt[1], []):
                    continue   # sin destino (ok) o destino válido (ok)
                body = p.read_text(encoding="utf-8")
                head = body.split("## Apunta a", 1)[0].rstrip() + "\n\n"
                old = f"{tgt[0]}.{tgt[1]}"
                if conv is not None:
                    tsch, ttbl = conv
                    p.write_text(head + f"## Apunta a →\n- [[E {tsch}.{ttbl}|{ttbl}]]  "
                                 f"_(convención global — schema corregido; antes `{old}`)_\n",
                                 encoding="utf-8")
                    fixed_dest += 1
                else:
                    p.write_text(head + f"> Destino no resuelto — el destino previo `{old}` "
                                 "no existe en el modelo (corregido 2026-07-21).\n",
                                 encoding="utf-8")
                    fixed_unres += 1

    total = len(list(FK_DIR.glob("FK *.md")))
    unresolved = sum(1 for f in FK_DIR.glob("FK *.md")
                     if "Destino no resuelto" in f.read_text(encoding="utf-8"))
    pct = round(100 * (total - unresolved) / total)
    print(f"corregidas (schema): {fixed_dest} · pasadas a no-resuelto: {fixed_unres} · creadas: {created}")
    print(f"total notas FK: {total} · sin destino: {unresolved} · resueltas: {pct}%")


if __name__ == "__main__":
    main()
