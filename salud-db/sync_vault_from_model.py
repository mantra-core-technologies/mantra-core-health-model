#!/usr/bin/env python3
"""
sync_vault_from_model.py — pone al día, desde los `.puml` del modelo, las dos clases de nota
de la bóveda que son transcripción pura y que consume `yarn orm:catalog` de la API:

  1. `Entidades/E <schema>.idxset_<tabla>.md`: el bloque ```puml``` es copia literal del
     `<<INDEX_SET>>` del diagrama. Si la nota existe, se reemplaza SOLO ese bloque (y el
     conteo «con N índices/constraints» de la prosa templada); si no existe, se crea con la
     plantilla de transcripción que ya usan las notas recientes.
  2. `FK/FK <schema>.<tabla>.<columna>.md` que FALTAN: se crean con el formato de
     `fix_vault_fk.make_note`, pero resolviendo el destino EXACTAMENTE como `gen_ddl.py`
     (arista etiquetada del diagrama → convención), para que `gen_ddl` lea de la nota el
     mismo destino que hoy obtiene sin ella y el DDL no cambie. Las notas existentes no se tocan.

Uso: SALUD_WORKSPACE=<ws> PYTHONUTF8=1 python3 sync_vault_from_model.py
(el workspace debe tener `mantra-core-health-model` y `Mantra Core Health Vault`).
"""
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

WS = Path(os.environ["SALUD_WORKSPACE"]).resolve()
sys.path.insert(0, str(WS / "mantra-core-health-model" / "salud-db"))

import gen_ddl  # noqa: E402
import fix_vault_fk  # noqa: E402

ENT_DIR = gen_ddl.paths.VAULT / "Entidades"
IDX_RE = re.compile(r'^\s*entity\s+"[^"]*"\s+as\s+idxset_([a-z0-9_]+)\s+<<INDEX_SET>>\s*\{', re.I)
PUML_BLOCK = re.compile(r"```puml\n[\s\S]*?```")
COUNT_RE = re.compile(r"con \d+ índices/constraints")


def idx_blocks(text):
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        m = IDX_RE.match(lines[i])
        if not m:
            i += 1
            continue
        table, body = m.group(1), []
        i += 1
        while i < len(lines) and lines[i].strip() != "}":
            if lines[i].strip():
                body.append(lines[i].rstrip())
            i += 1
        yield table, body
        i += 1


def new_idx_note(code, schema, table, puml_name, body):
    return (f"---\ntags:\n  - entidad\n  - schema/{schema}\n  - modulo/{code}\n  - tipo/index_set\n---\n"
            f"# idxset_{table}\n\n"
            f"> Transcripción de [[M{code} {schema}]] desde `{puml_name}`, ya publicado en el modelo. "
            f"No añade reglas nuevas.\n\n"
            f"## Campos\n```puml\n" + "\n".join(body) + "\n```\n")


def main():
    codes = sorted({p.stem.split("_")[1] for p in gen_ddl.PUML_DIR.glob("diagram_*.puml")})
    reg = gen_ddl.build_registry(codes)
    idx_upd = idx_new = idx_same = fk_new = fk_unres = 0
    for code in codes:
        puml = next(gen_ddl.PUML_DIR.glob(f"diagram_{code}_*.puml"), None)
        if not puml:
            continue
        schema, ents, *_ = gen_ddl.parse_module(puml)
        text = puml.read_text(encoding="utf-8")

        for table, body in idx_blocks(text):
            note = ENT_DIR / f"E {schema}.idxset_{table}.md"
            block = "```puml\n" + "\n".join(body) + "\n```"
            if note.exists():
                old = note.read_text(encoding="utf-8")
                norm = old.replace("\r\n", "\n")
                n = sum(1 for b in body if re.match(r"^\s*(PK|IX|UK|UX|FT|BRIN|GIN|GIST|HASH)\s", b))
                if PUML_BLOCK.search(norm):
                    new = PUML_BLOCK.sub(lambda _m: block, norm, count=1)
                elif n:
                    new = norm.rstrip("\n") + "\n\n## Campos\n" + block + "\n"
                else:
                    # Nota sin bloque y diagrama sin índices SQL (p. ej. NoSQL): nada que transcribir.
                    idx_same += 1
                    continue
                if new != norm:  # el conteo de la prosa solo se toca si cambió el bloque
                    new = COUNT_RE.sub(f"con {n} índices/constraints", new)
                if new != norm:
                    note.write_text(new, encoding="utf-8", newline="\n")
                    idx_upd += 1
                else:
                    idx_same += 1
            else:
                note.write_text(new_idx_note(code, schema, table, puml.name, body),
                                encoding="utf-8", newline="\n")
                idx_new += 1

        for e in ents:
            for c in e.columns:
                if not c.is_fk:
                    continue
                p = fix_vault_fk.note_path(schema, e.name, c.name)
                if p.exists():
                    continue
                stereo = "PK,FK" if c.is_pk else ("FK,UK" if c.is_uk else "FK")
                dest = gen_ddl.resolve_fk_from_diagram(puml, schema, e.name, c.name)
                if dest is not None and dest not in reg.get(dest[1], []):
                    dest = None
                label = "arista etiquetada del diagrama"
                if dest is None:
                    dest = gen_ddl.resolve_fk_convention(schema, e.name, c.name, reg)
                    if dest is None:
                        label = ""
                    elif c.name == "tenant_id":
                        label = "convención · tenant"
                    elif c.name.endswith("concept_id"):
                        label = "convención · terminología"
                    elif c.name.endswith("user_id"):
                        label = "convención · usuario"
                    else:
                        label = "convención por nombre"
                p.write_text(fix_vault_fk.make_note(code, schema, e.name, c.name, stereo, dest, label),
                             encoding="utf-8", newline="\n")
                fk_new += 1
                fk_unres += dest is None
    print(f"idxset: actualizadas {idx_upd} · creadas {idx_new} · sin cambios {idx_same}")
    print(f"FK: creadas {fk_new} (sin destino: {fk_unres})")


if __name__ == "__main__":
    main()
