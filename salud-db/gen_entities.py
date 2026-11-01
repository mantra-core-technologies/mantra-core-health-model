#!/usr/bin/env python3
"""
gen_entities.py — Genera entidades MikroORM (TypeScript) desde el modelo canónico .puml,
para el backend NestJS `mantra-core-health-api`.

Reutiliza el parseo de gen_ddl (misma fuente de verdad que el SQL). Aplica orm-mapping-guide.md:
  - id uuid <<PK>>        → @PrimaryKey
  - row_version : integer → @Version (locking optimista)
  - *_concept_id / FK     → columna uuid @Property + comentario del destino (las relaciones
                            @ManyToOne se agregan luego / por introspección, §2.3)
  - multi-schema          → @Entity({ schema, tableName })
Solo la capa relacional PostgreSQL (los stores NoSQL no se mapean como entidades, §4).

Con la entidad ya escrita en la API, el generador la lee y FUSIONA (api#1246, model#110):
  - la tabla se busca por `@Entity({ schema, tableName })` en todo `src/modules`: si ya la
    mapea otro archivo u otra clase (`MedicalGroups` en `medical_groups.entity.ts`), se
    actualiza ese archivo con esa clase; no se crea otra ni se renombra la existente;
  - se conserva lo escrito a mano que no contradice al .puml: JSDoc, inicializadores, tipo
    TS, imports, `unique` respaldado por un UNIQUE del .puml, opcionalidad TS y el texto
    exacto de lo que no cambió;
  - donde el .puml contradice (nulabilidad, tipo de columna, unique, default) manda el
    .puml y el caso se lista al final de la corrida, para llevarlo al .puml si la entidad
    tenía razón.

Uso:  python gen_entities.py 01 | all   (después: prettier sobre src/modules/**/entities, ADR-0022)
"""
from __future__ import annotations
import re
import sys

import gen_ddl  # reutiliza parse_module / resolve_fk / build_registry
import paths

REPO = gen_ddl.REPO
PUML_DIR = gen_ddl.PUML_DIR
# Las entidades se escriben en el repositorio de la API, que es hermano de este.
OUT_DIR = paths.API_ENTITIES_DIR


def pascal(name: str) -> str:
    return "".join(p.capitalize() for p in name.split("_"))


def camel(name: str) -> str:
    parts = name.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def class_name(schema: str, table: str, registry: dict) -> str:
    """Nombre de clase único global. MikroORM exige unicidad entre todos los schemas;
    si una tabla existe en más de un schema, se cualifica con el schema para evitar la
    colisión (determinista y estable entre regeneraciones)."""
    homonyms = registry.get(table)
    if homonyms and len(homonyms) > 1:
        return pascal(schema) + pascal(table)
    return pascal(table)


def is_uuid(dtype: str) -> bool:
    return dtype.strip().lower().startswith("uuid")


def map_type(dtype: str):
    """PG type → (tsType, opts:dict) para el decorador de MikroORM."""
    d = dtype.strip()
    if d.endswith("[]"):
        return "string[]", {"type": "'array'"}
    if d.startswith('"terminology"'):
        return "string", {"columnType": "'\"terminology\".\"technical_data_type\"'"}
    base = re.match(r"[a-z_]+", d)
    base = base.group(0) if base else d
    table = {
        "uuid": ("string", {"type": "'uuid'"}),
        # El tipo declarado se conserva entero: `varchar(200)` NO es `varchar`.
        # Descartar la longitud hacía que el ORM viera un tipo más ancho que el de
        # la base y propusiera un ALTER de ensanche en cada dry-run (deriva nueva
        # destapada en v4.0.10 con authz.patient_legal_representations.document_ref).
        "varchar": ("string", {"columnType": f"'{d}'"}),
        "text": ("string", {"columnType": "'text'"}),
        "char": ("string", {"columnType": f"'{d}'"}),
        "boolean": ("boolean", {"type": "'boolean'"}),
        "timestamptz": ("Date", {"columnType": "'timestamptz'"}),
        "timestamp": ("Date", {"columnType": "'timestamp'"}),
        "date": ("Date", {"columnType": "'date'"}),
        "time": ("string", {"columnType": "'time'"}),
        "integer": ("number", {"columnType": "'int'"}),
        "smallint": ("number", {"columnType": "'smallint'"}),
        "bigint": ("string", {"type": "'bigint'"}),
        "numeric": ("string", {"columnType": f"'{d}'"}),
        "double": ("number", {"columnType": "'double precision'"}),
        "jsonb": ("unknown", {"type": "'json'", "columnType": "'jsonb'"}),
        "json": ("unknown", {"type": "'json'"}),
        "inet": ("string", {"columnType": "'inet'"}),
        "vector": ("number[]", {"type": "'array'"}),
    }
    return table.get(base, ("string", {"columnType": f"'{d}'"}))


def render_opts(opts: dict) -> str:
    return "{ " + ", ".join(f"{k}: {v}" for k, v in opts.items()) + " }" if opts else ""


def fk_comment(schema, table, col, registry, puml=None):
    """Comentario `// FK → destino` con la MISMA resolución que el DDL (`gen_ddl.emit`):
    1º nota del vault, 2º arista etiquetada del propio `.puml`, descartando un destino que
    no exista en el registro, y 3º la convención (marcada `(inferida)`). Sin el 2º paso, la
    entidad decía «inferida» o «destino no resuelto» donde el DDL sí tenía el destino."""
    tgt = gen_ddl.resolve_fk(schema, table, col)
    if tgt is None and puml is not None:
        tgt = gen_ddl.resolve_fk_from_diagram(puml, schema, table, col)
    if tgt is not None and registry and tgt not in registry.get(tgt[1], []):
        tgt = None
    inferred = False
    if tgt is None:
        tgt = gen_ddl.resolve_fk_convention(schema, table, col, registry)
        inferred = tgt is not None
    if tgt is None:
        return "  // FK (destino no resuelto)"
    return f"  // FK → {tgt[0]}.{tgt[1]}{' (inferida)' if inferred else ''}"


class Prop:
    """Una propiedad lista para escribir: decorador, opciones (en orden), comentario
    final y declaración TS. La produce el generador y la ajusta `merge_property`."""

    def __init__(self, kind, opts, comment, name, ts, marker, init, doc=None):
        self.kind, self.opts, self.comment = kind, dict(opts), comment
        self.name, self.ts, self.marker, self.init, self.doc = name, ts, marker, init, doc
        # Texto original de la entidad, cuando la fusión no cambió esa parte: así una
        # propiedad sin cambios sale byte a byte igual (Prettier no siempre vuelve a
        # partir un decorador igual que como estaba).
        self.raw_decorator: str | None = None
        self.raw_declaration: str | None = None

    def lines(self) -> list[str]:
        out = [self.doc] if self.doc else []
        if self.raw_decorator is not None:
            out.append(self.raw_decorator)
        else:
            out.append(f"  @{self.kind}({render_opts(self.opts)}){self.comment}")
        if self.raw_declaration is not None:
            out.append(self.raw_declaration)
            return out
        init = f" = {self.init}" if self.init is not None else ""
        if self.ts is None:
            out.append(f"  {self.name}{init};")
        else:
            out.append(f"  {self.name}{self.marker}: {self.ts}{init};")
        return out


def generated_property(schema, table, c, registry, puml=None) -> Prop:
    """La propiedad tal como la deduce el `.puml`: prop camelCase + fieldName a la columna."""
    ts, opts = map_type(c.dtype)
    prop = camel(c.name)
    if prop != c.name:
        opts = {"fieldName": f"'{c.name}'", **opts}
    if not c.not_null:
        opts = {**opts, "nullable": "true"}
    if c.default == "now()":
        # DEFAULT_NOW (v4.2.84): es una expresión SQL, no un literal JS; MikroORM la recibe como defaultRaw.
        opts = {**opts, "defaultRaw": "'now()'"}
    elif c.default is not None:
        opts = {**opts, "default": c.default}
    bang = "!" if c.not_null else "?"

    if c.is_pk and is_uuid(c.dtype):
        return Prop("PrimaryKey", opts, "", prop, ts, "", "randomUUID()")
    if c.is_pk:
        return Prop("PrimaryKey", opts, "", prop, ts, bang, None)
    if c.name == "row_version":
        opts = {**opts, "version": "true"}
        return Prop("Property", opts, "", prop, ts, bang, None)
    cmt = fk_comment(schema, table, c.name, registry, puml) if c.is_fk else ""
    return Prop("Property", opts, cmt, prop, ts, bang, None)


def emit_property(schema, table, c, registry) -> list[str]:
    """Líneas de una propiedad generada solo desde el `.puml` (sin entidad previa)."""
    return generated_property(schema, table, c, registry).lines()


CLASS_DOC_KEY = "__class__"


def extract_jsdoc(text: str) -> dict[str, str]:
    """Bloques `/** … */` de una entidad existente, por nombre de propiedad.

    El cuerpo de las entidades lo produce este generador, pero su documentación
    no: el JSDoc templado lo inyecta `tools/documentation/generate-documentation.mjs`
    y hay entidades con prosa escrita a mano (invariantes de seguridad incluidas).
    Reescribir sin preservarla la borra — y ese fue el motivo por el que la
    regeneración estuvo vetada entre v4.0.8 y v4.0.10. La clave es el nombre de
    la propiedad documentada (o CLASS_DOC_KEY para el bloque de la clase), así el
    bloque sobrevive aunque cambien el tipo o las opciones del decorador.
    """
    docs: dict[str, str] = {}
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        if lines[i].lstrip().startswith("/**"):
            start = i
            while "*/" not in lines[i]:
                i += 1
            block = "\n".join(lines[start:i + 1])
            key = _documented_name(lines, i + 1)
            if key:
                docs[key] = block
        i += 1
    return docs


def _documented_name(lines: list[str], j: int) -> str | None:
    """Nombre de la propiedad (o clase) que sigue a un bloque JSDoc.

    Salta los decoradores balanceando paréntesis: un decorador partido por
    Prettier contiene líneas como `fieldName: 'user_id',` que, sin el balance,
    se confundirían con una propiedad.
    """
    depth = 0
    while j < len(lines):
        s = lines[j].strip()
        if not s:
            j += 1
            continue
        if depth > 0 or s.startswith("@"):
            depth += s.count("(") - s.count(")")
            j += 1
            continue
        m = re.match(r"export (?:abstract )?class \w+", s)
        if m:
            return CLASS_DOC_KEY
        m = re.match(r"(\w+)[!?]?\s*[:=]", s)
        return m.group(1) if m else None
    return None


# ------------------------------------------------------------------ entidad existente
#
# El generador escribe el cuerpo desde el `.puml`, pero la entidad de la API no es
# solo cuerpo generado: tiene JSDoc (ADR-0022) y, en algunas, código escrito a mano
# que el `.puml` no expresa — un inicializador en memoria (`= true`, `= 0`,
# `= RestoreObjectiveStatus.NOT_MEASURED`), un tipo TS más preciso que el que se
# deduce de la columna (unión, enum, alias, `string` para una fecha, `string[]`
# para un jsonb), `unique: true`, una opcionalidad TS, un import de esos tipos.
# Regenerar sin leerla deshacía todo eso (mantra-core-health-api#1246). Así que se
# lee la entidad que ya existe y se fusiona:
#
#   - lo que NO contradice al `.puml` se conserva tal cual estaba;
#   - donde el `.puml` dice otra cosa sobre la columna (nulabilidad, tipo, unique,
#     default distinto) manda el `.puml`, y el caso se lista en `Report` para que,
#     si la entidad tenía razón, se lleve al `.puml`.
#
# El parser es de líneas y paréntesis balanceados, como `extract_jsdoc`: acepta la
# forma que deja Prettier (decoradores partidos, uniones en varias líneas).

GEN_KEY_RANK = {"fieldName": 0, "type": 1, "columnType": 2, "nullable": 3,
                "default": 4, "version": 5}
TYPE_KEYS = ("type", "columnType")
TYPE_ALIASES = {"integer": "int", "int4": "int", "bool": "boolean", "int8": "bigint",
                "double": "double precision", "float8": "double precision",
                "character varying": "varchar", "timestamp with time zone": "timestamptz"}


class ExistingProp:
    def __init__(self, name, kind, opts, comment, ts, marker, init, doc,
                 raw_decorator=None, raw_declaration=None):
        self.name, self.kind, self.opts, self.comment = name, kind, opts, comment
        self.ts, self.marker, self.init, self.doc = ts, marker, init, doc
        self.raw_decorator, self.raw_declaration = raw_decorator, raw_declaration

    def column(self, by_prop: dict[str, str]) -> str | None:
        """Columna que mapea: `fieldName` si lo declara; si no, la del `.puml` cuyo
        nombre camelCase (o snake) coincide con la propiedad."""
        if "fieldName" in self.opts:
            return unquote(self.opts["fieldName"])
        return by_prop.get(self.name)


class ExistingEntity:
    def __init__(self):
        self.schema = self.table = self.class_name = None
        self.class_doc = None
        self.imports: list[str] = []
        self.preamble: list[str] = []
        self.trailer: list[str] = []
        self.props: list[ExistingProp] = []
        self.unparsed: list[str] = []


class Report:
    """Lo que la fusión decidió y conviene revisar. `conflicts`: el `.puml` contradice a la
    entidad y ganó el `.puml`. `notes`: se conservó algo de la entidad que el `.puml` no
    respalda (no lo contradice), o un hallazgo de mapeo (tabla mapeada dos veces...)."""

    def __init__(self):
        self.conflicts: list[str] = []
        self.notes: list[str] = []

    def print(self):
        if self.conflicts:
            print(f"\n!! {len(self.conflicts)} contradicciones entidad ↔ .puml (manda el .puml; "
                  "si la entidad tenía razón, llevalo al .puml):")
            for line in self.conflicts:
                print(f"   - {line}")
        if self.notes:
            print(f"\n.. {len(self.notes)} notas (se conservó lo de la entidad):")
            for line in self.notes:
                print(f"   - {line}")


def unquote(v: str | None) -> str | None:
    if v is None:
        return None
    v = v.strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in "'\"`":
        return v[1:-1]
    return v


def _split_top(s: str, sep: str = ",") -> list[str]:
    """Parte `s` por `sep` fuera de comillas y de (), [], {}."""
    parts, depth, quote, cur = [], 0, None, []
    i = 0
    while i < len(s):
        ch = s[i]
        if quote:
            cur.append(ch)
            if ch == "\\" and i + 1 < len(s):
                cur.append(s[i + 1])
                i += 1
            elif ch == quote:
                quote = None
        elif ch in "'\"`":
            quote = ch
            cur.append(ch)
        elif ch in "([{":
            depth += 1
            cur.append(ch)
        elif ch in ")]}":
            depth -= 1
            cur.append(ch)
        elif ch == sep and depth == 0:
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
        i += 1
    parts.append("".join(cur))
    return parts


def _close_paren(s: str, open_idx: int) -> int:
    """Índice del `)` que cierra el `(` de `open_idx`, respetando comillas; -1 si no cierra."""
    depth, quote = 0, None
    for i in range(open_idx, len(s)):
        ch = s[i]
        if quote:
            if ch == quote and s[i - 1] != "\\":
                quote = None
        elif ch in "'\"`":
            quote = ch
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
    return -1


def parse_options(inner: str) -> dict[str, str]:
    """`{ fieldName: 'x', nullable: true, }` → {'fieldName': "'x'", 'nullable': 'true'} (en orden)."""
    inner = inner.strip()
    if not (inner.startswith("{") and inner.endswith("}")):
        return {}
    opts: dict[str, str] = {}
    for item in _split_top(inner[1:-1]):
        item = item.strip()
        if not item:
            continue
        key, _, value = item.partition(":")
        opts[unquote(key.strip())] = " ".join(value.split())
    return opts


def _parse_declaration(decl: str):
    """`name!: Tipo = init` → (name, marker, ts, init). `ts` es None si no hay anotación."""
    decl = " ".join(decl.split()).rstrip(";").strip()
    m = re.match(r"(?:readonly\s+)?(\w+)\s*([!?])?\s*", decl)
    if not m:
        return None
    name, marker, rest = m.group(1), m.group(2) or "", decl[m.end():]
    ts = init = None
    if rest.startswith(":"):
        rest = rest[1:]
        # el `=` del inicializador: fuera de comillas/paréntesis y que no sea `=>`/`==`
        parts = _split_top(rest, "=")
        if len(parts) > 1 and not parts[1].startswith((">", "=")):
            ts, init = parts[0].strip(), "=".join(parts[1:]).strip()
        else:
            ts = rest.strip()
        ts = re.sub(r"^\|\s*", "", ts)   # unión partida por Prettier: `| 'a' | 'b'`
    elif rest.startswith("="):
        init = rest[1:].strip()
    else:
        return None
    return name, marker, ts, init


def parse_entity(text: str) -> ExistingEntity:
    ent = ExistingEntity()
    lines = text.splitlines()
    try:
        e_idx = next(i for i, l in enumerate(lines) if l.startswith("@Entity("))
        end = max(i for i, l in enumerate(lines) if l.rstrip() == "}")
    except (StopIteration, ValueError):
        ent.unparsed.append("<sin @Entity / cierre de clase>")
        return ent

    # bloque JSDoc de la clase, pegado al @Entity
    head_end = e_idx
    j = e_idx - 1
    while j >= 0 and not lines[j].strip():
        j -= 1
    if j >= 0 and lines[j].strip().endswith("*/"):
        k = j
        while k >= 0 and not lines[k].lstrip().startswith("/**"):
            k -= 1
        if k >= 0:
            ent.class_doc = "\n".join(lines[k:j + 1])
            head_end = k

    # cabecera: imports (pueden ocupar varias líneas) y lo demás, tal cual
    i = 0
    while i < head_end:
        if lines[i].startswith("import "):
            k = i
            while not lines[k].rstrip().endswith(";") and k + 1 < head_end:
                k += 1
            ent.imports.append("\n".join(lines[i:k + 1]))
            i = k + 1
        else:
            ent.preamble.append(lines[i])
            i += 1
    while ent.preamble and not ent.preamble[0].strip():
        ent.preamble.pop(0)
    while ent.preamble and not ent.preamble[-1].strip():
        ent.preamble.pop()

    # @Entity({...}) + export class X {
    k, buf = e_idx, ""
    while k <= end:
        buf += lines[k] + "\n"
        k += 1
        if "export class" in buf:
            break
    op = buf.index("(")
    cl = _close_paren(buf, op)
    deco = parse_options(buf[op + 1:cl])
    ent.schema, ent.table = unquote(deco.get("schema")), unquote(deco.get("tableName"))
    m = re.search(r"export (?:abstract )?class (\w+)", buf)
    ent.class_name = m.group(1) if m else None
    while k <= end and "{" not in lines[k - 1]:
        k += 1
    ent.trailer = lines[end + 1:]

    # cuerpo
    doc = None
    i = k
    while i < end:
        s = lines[i].strip()
        if not s:
            i += 1
            continue
        if s.startswith("/**"):
            start = i
            while "*/" not in lines[i]:
                i += 1
            doc = "\n".join(lines[start:i + 1])
            i += 1
            continue
        if s.startswith("@"):
            buf, start = "", i
            while True:
                buf += lines[i] + "\n"
                op = buf.find("(")
                cl = _close_paren(buf, op) if op != -1 else -1
                if cl != -1 or i + 1 >= end:
                    break
                i += 1
            kind = re.match(r"@(\w+)", buf.strip()).group(1)
            inner = buf[op + 1:cl] if cl != -1 else ""
            tail = buf[cl + 1:].strip() if cl != -1 else ""
            comment = ("  " + tail) if tail.startswith("//") else ""
            i += 1
            dstart = i
            while i < end and not lines[i].rstrip().endswith(";"):
                i += 1
            parsed = _parse_declaration(" ".join(lines[dstart:i + 1]))
            if parsed is None:
                ent.unparsed.append("\n".join(lines[start:i + 1]))
            else:
                name, marker, ts, init = parsed
                ent.props.append(ExistingProp(name, kind, parse_options(inner), comment,
                                              ts, marker, init, doc,
                                              "\n".join(lines[start:dstart]),
                                              "\n".join(lines[dstart:i + 1])))
            doc = None
            i += 1
            continue
        ent.unparsed.append(lines[i])
        doc = None
        i += 1
    return ent


def canon_type(opts: dict[str, str]):
    """Tipo de columna normalizado de unas opciones de decorador, para decidir si la
    entidad y el `.puml` dicen lo mismo con otra escritura (`type: 'integer'` ≡
    `columnType: 'int'`, `columnType: 'boolean'` ≡ `type: 'boolean'`...). None si la
    entidad no declara tipo (MikroORM infiere `varchar(255)`: no es el del `.puml`)."""
    base = unquote(opts.get("columnType")) or unquote(opts.get("type"))
    if base is None:
        return None
    b = " ".join(base.lower().split()).replace(" (", "(").replace(", ", ",")
    b = TYPE_ALIASES.get(b, b)
    if b.endswith("[]"):
        b = "array"
    return b


def same_default(a: str | None, b: str | None) -> bool:
    """`'x'` ≡ `"x"` ≡ `Enum.x` (miembro de enum con el mismo nombre que el literal)."""
    if a is None or b is None:
        return False
    na, nb = (" ".join(x.split()).replace('"', "'") for x in (a, b))
    if na == nb:
        return True
    for x, y in ((na, nb), (nb, na)):
        m = re.fullmatch(r"[A-Za-z_]\w*\.(\w+)", x)
        if m and y == f"'{m.group(1)}'":
            return True
    return False


def unique_backed(c, indexes) -> bool:
    """El `.puml` declara la columna única: `<<UK>>` o un índice único de esa sola columna."""
    if c.is_uk or c.is_pk:
        return True
    return any(ix.unique and not ix.where and [x.strip().strip('"') for x in ix.cols] == [c.name]
               for ix in indexes or [])


def _insert_ranked(opts: dict[str, str], key: str, value: str) -> dict[str, str]:
    """Inserta una opción nueva en el lugar que le da el orden del generador, sin mover
    las que la entidad ya tenía."""
    rank = GEN_KEY_RANK.get(key, 99)
    items = list(opts.items())
    pos = next((n for n, (k, _) in enumerate(items) if GEN_KEY_RANK.get(k, 99) > rank), len(items))
    items.insert(pos, (key, value))
    return dict(items)


def merge_property(g: Prop, ex: ExistingProp, c, where: str, indexes, report: Report) -> Prop:
    """Fusiona la propiedad generada `g` con la que la entidad ya declara `ex`."""
    ex_type, g_type = canon_type(ex.opts), canon_type(g.opts)
    same_type = ex_type is not None and ex_type == g_type
    if not same_type:
        report.conflicts.append(
            f"{where}: tipo de columna — entidad {ex_type or 'sin declarar'}, .puml {g_type}")
    g_nullable = g.opts.get("nullable") == "true"
    ex_nullable = ex.opts.get("nullable") == "true"
    null_conflict = g_nullable != ex_nullable
    if null_conflict:
        report.conflicts.append(
            f"{where}: nulabilidad — entidad {'NULL' if ex_nullable else 'NOT NULL'}, "
            f".puml {'NULL' if g_nullable else 'NOT NULL'}")
    if ex.kind != g.kind:
        report.conflicts.append(f"{where}: decorador — entidad @{ex.kind}, .puml @{g.kind}")

    opts: dict[str, str] = {}
    for k, v in ex.opts.items():
        if k in TYPE_KEYS:
            if same_type:
                opts[k] = v
        elif k == "fieldName":
            if unquote(v) == c.name:
                opts[k] = v
        elif k == "nullable":
            if g_nullable:
                opts[k] = v
        elif k == "default":
            if c.default is None:
                opts[k] = v
                report.notes.append(f"{where}: default {v} sin DEFAULT en el .puml (se conserva)")
            elif same_default(v, c.default):
                opts[k] = v
            else:
                opts[k] = c.default
                report.conflicts.append(f"{where}: default — entidad {v}, .puml {c.default}")
        elif k == "version":
            if "version" in g.opts:
                opts[k] = v
            else:
                report.conflicts.append(f"{where}: version — la entidad la declara, el .puml no")
        elif k == "unique":
            if unique_backed(c, indexes):
                opts[k] = v
            else:
                report.conflicts.append(f"{where}: unique — la entidad lo declara, el .puml no "
                                        "tiene un UNIQUE de esa columna")
        else:
            opts[k] = v   # opción que el generador no maneja: es de la entidad
    for k, v in g.opts.items():
        if k in opts or (k in TYPE_KEYS and same_type):
            continue
        if k == "fieldName" and "fieldName" in ex.opts:
            continue
        if k == "default" and ex.init is not None and same_default(ex.init, v):
            continue   # el inicializador ya da el mismo valor
        opts = _insert_ranked(opts, k, v)

    if same_type:
        ts = ex.ts if (ex.ts is not None or ex.init is not None) else g.ts
        init = ex.init
    else:
        ts, init = g.ts, g.init
    if init is not None:
        marker = "?" if (g_nullable and ex.marker == "?") else ""
    elif null_conflict or not same_type:
        marker = g.marker
    else:
        marker = ex.marker or g.marker
    if marker == "?" and not g_nullable and not null_conflict:
        report.notes.append(f"{where}: opcional en TS (`?`) sobre una columna NOT NULL del .puml")
    out = Prop(g.kind, opts, g.comment, ex.name, ts, marker, init, ex.doc)
    if (g.kind == ex.kind and list(opts.items()) == list(ex.opts.items())
            and " ".join(g.comment.split()) == " ".join(ex.comment.split())):
        out.raw_decorator = ex.raw_decorator
    if (ts, marker, init) == (ex.ts, ex.marker, ex.init):
        out.raw_declaration = ex.raw_declaration
    return out


def emit_entity(schema, ent, registry, docs: dict[str, str] | None = None,
                existing: ExistingEntity | None = None, indexes=None,
                report: Report | None = None, puml=None) -> str:
    """Texto de la entidad. Sin `existing`, sale solo del `.puml` (y de `docs`, el JSDoc
    por nombre de propiedad). Con `existing`, se fusiona con la entidad que ya está."""
    docs = docs or {}
    report = report if report is not None else Report()
    by_prop: dict[str, str] = {}
    for c in ent.columns:
        by_prop.setdefault(camel(c.name), c.name)
        by_prop.setdefault(c.name, c.name)
    ex_by_col: dict[str, ExistingProp] = {}
    if existing is not None:
        for p in existing.props:
            col = p.column(by_prop)
            if col is not None and col not in ex_by_col:
                ex_by_col[col] = p
        cols = {c.name for c in ent.columns}
        for p in existing.props:
            col = p.column(by_prop)
            if col not in cols:
                report.conflicts.append(f"{schema}.{ent.name}.{col or p.name}: la entidad tiene "
                                        f"`{p.name}`, el .puml no tiene la columna (se quita)")
        for raw in existing.unparsed:
            report.notes.append(f"{schema}.{ent.name}: no se entendió `{raw.strip()[:80]}` (se descarta)")

    props: list[tuple[str, Prop]] = []
    for c in ent.columns:
        g = generated_property(schema, ent.name, c, registry, puml)
        ex = ex_by_col.get(c.name)
        if ex is not None:
            g = merge_property(g, ex, c, f"{schema}.{ent.name}.{c.name}", indexes, report)
        else:
            g.doc = docs.get(camel(c.name))
        props.append((c.name, g))

    # Orden: el de la entidad para lo que ya estaba; una columna nueva va detrás de la
    # columna del .puml que la precede (o al principio).
    if ex_by_col:
        generated = dict(props)
        order = list(dict.fromkeys(col for col in (p.column(by_prop) for p in existing.props)
                                   if col in generated))
        puml_order = [name for name, _ in props]
        for n, name in enumerate(puml_order):
            if name in order:
                continue
            prev = next((puml_order[m] for m in range(n - 1, -1, -1) if puml_order[m] in order), None)
            order.insert(order.index(prev) + 1 if prev else 0, name)
        by_name = dict(props)
        props = [(name, by_name[name]) for name in order]

    body: list[str] = []
    for _, p in props:
        body += p.lines()
        body.append("")
    used = ["Entity"] + [k for k in ("PrimaryKey", "Property") if any(p.kind == k for _, p in props)]
    used += sorted({p.kind for _, p in props} - set(used))
    mikro = f"import {{ {', '.join(used)} }} from '@mikro-orm/decorators/legacy';"
    crypto = "import { randomUUID } from 'node:crypto';"
    need_uuid = any("randomUUID(" in line for line in body)

    imports: list[str] = []
    for imp in (existing.imports if existing else []):
        if "'@mikro-orm/decorators/legacy'" in imp:
            imports.append(mikro)
        elif "'node:crypto'" in imp and re.fullmatch(r"import \{ randomUUID \} from 'node:crypto';", imp):
            if need_uuid:
                imports.append(crypto)
        else:
            imports.append(imp)
    if mikro not in imports:
        imports.insert(0, mikro)
    if need_uuid and crypto not in imports and not any("randomUUID" in i for i in imports):
        imports.insert(imports.index(mikro) + 1, crypto)

    lines = list(imports)
    lines.append("")
    if existing is not None and existing.preamble:
        lines += existing.preamble
        lines.append("")
    class_doc = existing.class_doc if existing is not None else docs.get(CLASS_DOC_KEY)
    if class_doc:
        lines.append(class_doc)
    name = (existing.class_name if existing is not None and existing.class_name
            else class_name(schema, ent.name, registry))
    lines.append(f"@Entity({{ schema: '{schema}', tableName: '{ent.name}' }})")
    lines.append(f"export class {name} {{")
    lines += body
    lines.append("}")
    if existing is not None and existing.trailer:
        lines += existing.trailer
    return "\n".join(lines).rstrip("\n") + "\n"


def scan_mapped_tables(root, report: Report | None = None) -> dict[tuple[str, str], object]:
    """(schema, tabla) → archivo de la entidad que ya la mapea, en TODO `src/modules`.

    El nombre del archivo y el de la clase no siempre son los que el generador
    deduciría: `medical_groups.groups` vive en `medical_groups.entity.ts` como
    `MedicalGroups`. Sin este índice el generador creaba `groups.entity.ts` (una
    segunda entidad para la misma tabla) y, por la homonimia con
    `community.groups`, renombraba la clase de community (model#110)."""
    found: dict[tuple[str, str], list] = {}
    if not root.exists():
        return {}
    for path in sorted(root.rglob("*.entity.ts")):
        if "node_modules" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        at = text.find("@Entity(")
        if at == -1:
            continue
        op = text.index("(", at)
        cl = _close_paren(text, op)
        opts = parse_options(text[op + 1:cl])
        schema, table = unquote(opts.get("schema")), unquote(opts.get("tableName"))
        if schema and table:
            found.setdefault((schema, table), []).append(path)
    mapped = {}
    for key, paths in found.items():
        canonical = [p for p in paths if p.name == f"{key[1]}.entity.ts" and p.parent.parent.name == key[0]]
        mapped[key] = (canonical or paths)[0]
        if len(paths) > 1 and report is not None:
            report.notes.append(f"{key[0]}.{key[1]} está mapeada por {len(paths)} entidades: "
                                + ", ".join(str(p.relative_to(root)) for p in paths)
                                + f" (se actualiza {mapped[key].relative_to(root)})")
    return mapped


def emit_module(code, registry, mapped=None, report: Report | None = None):
    puml = next(PUML_DIR.glob(f"diagram_{code}_*.puml"), None)
    if not puml:
        print(f"!! no encontrado diagram_{code}_*.puml")
        return
    schema, entities, idx_by_table, *_ = gen_ddl.parse_module(puml)
    if not entities:
        print(f"[{code}] sin entidades relacionales (especializado/no-SQL) — omitido")
        return
    if mapped is None:
        mapped = scan_mapped_tables(OUT_DIR, report)
    report = report if report is not None else Report()
    d = OUT_DIR / schema / "entities"
    d.mkdir(parents=True, exist_ok=True)
    barrel = []
    preserved = 0
    for e in entities:
        target = mapped.get((schema, e.name), d / f"{e.name}.entity.ts")
        existing = None
        if target.exists():
            existing = parse_entity(target.read_text(encoding="utf-8"))
            if (existing.schema, existing.table) != (schema, e.name):
                report.conflicts.append(
                    f"{schema}.{e.name}: {target.relative_to(OUT_DIR)} mapea "
                    f"{existing.schema}.{existing.table}; no se pisa (renombrá uno de los dos)")
                continue
            preserved += sum(1 for p in existing.props if p.doc) + (1 if existing.class_doc else 0)
        out = emit_entity(schema, e, registry, existing=existing,
                          indexes=idx_by_table.get(e.name, []), report=report, puml=puml)
        # No reescribir lo idéntico: conserva mtimes y deja `git status` limpio.
        if not target.exists() or target.read_text(encoding="utf-8") != out:
            target.write_text(out, encoding="utf-8")
        if target.parent == d:
            barrel.append(f"export * from './{target.name[:-3]}';")
    index = d / "index.ts"
    # El barrel es la UNIÓN de lo generado y lo ya exportado cuyo archivo siga
    # existiendo. Cubre dos casos que este generador no produce: entidades que el
    # .puml no materializa (las 6 tablas fantasma de la deriva conocida, creadas
    # por `orm:entities:missing` desde la bóveda) y los `.types.ts` a mano con los
    # contratos de columnas jsonb (ADR-0022) — descartar unos saca entidades del
    # ORM en silencio; descartar los otros rompe los imports de '../entities'.
    if index.exists():
        for line in index.read_text(encoding="utf-8").splitlines():
            m = re.match(r"export \* from '\./(.+)';", line.strip())
            if m and line.strip() not in barrel and (d / f"{m.group(1)}.ts").exists():
                barrel.append(line.strip())
    index_out = "\n".join(sorted(barrel)) + "\n"
    # Mismos exports en otro orden: se respeta el del archivo (no es un cambio).
    if index.exists() and sorted(index.read_text(encoding="utf-8").splitlines()) == sorted(barrel):
        index_out = index.read_text(encoding="utf-8")
    if not index.exists() or index.read_text(encoding="utf-8") != index_out:
        index.write_text(index_out, encoding="utf-8")
    print(f"[{code}/{schema}] {len(entities)} entidades · {preserved} bloques JSDoc preservados")


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    arg = sys.argv[1] if len(sys.argv) > 1 else "01"
    all_codes = sorted({p.stem.split("_")[1] for p in PUML_DIR.glob("diagram_*.puml")})
    registry = gen_ddl.build_registry(all_codes)
    codes = all_codes if arg == "all" else [f"{int(arg):02d}"]
    report = Report()
    mapped = scan_mapped_tables(OUT_DIR, report)
    for c in codes:
        emit_module(c, registry, mapped, report)
    report.print()


if __name__ == "__main__":
    main()
