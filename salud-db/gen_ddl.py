#!/usr/bin/env python3
"""
gen_ddl.py — Genera DDL PostgreSQL FIEL desde los .puml canónicos de SALUD.

Regla temperatura-0: NADA se inventa.
  - Columnas, tipos, PK/UK/FK y obligatoriedad (*) salen del .puml.
  - Los índices (IX/UK/BRIN…) salen de los bloques <<INDEX_SET>>.
  - Los DESTINOS de las FK se leen de las notas ya resueltas del vault (Mantra Core Health Vault/SALUD/FK/).
    Las FK marcadas "Destino no resuelto" NO se fuerzan.

Modelo POLÍGLOTA: solo se emiten como tablas PostgreSQL las entidades relacionales.
Se SALTAN (y se reportan) los stubs de cruce, las vistas y los stores especializados:
  REFERENCE_ONLY  → la tabla real vive en su módulo dueño
  VIEW / MATERIALIZED_VIEW → no hay SELECT en el .puml, no se puede materializar
  STATE_MACHINE   → metadata (code/initial/states/terminal), no es una tabla
  REDIS_KEYSPACE / MONGODB_COLLECTION / OPENSEARCH_INDEX / VECTOR_STORE /
  GRAPH_COLLECTION / TIMESERIES_MEASUREMENT / LAKEHOUSE_CATALOG → otros motores (mód. 55-63)

Salida por fases idempotentes en SQL/<NN>_<schema>/:
  01_schema.sql   CREATE SCHEMA
  02_tables.sql   CREATE TABLE (columnas + NOT NULL + PRIMARY KEY)
  03_fk_intra.sql FK con destino en el MISMO schema
  04_indexes.sql  IX / UK / BRIN (el índice PK lo crea Postgres solo)
  90_fk_deferred.sql  FK cross-schema (aplicar al final)
Y un reporte global: SQL/_generation_report.md

Uso:  python gen_ddl.py 02        # un módulo
      python gen_ddl.py all       # los 64
"""
from __future__ import annotations
import hashlib
import re
import sys
from pathlib import Path

import paths

ROOT = paths.MODEL_ROOT / "salud-db"
# `REPO` es el repositorio del modelo; la bóveda y la API son hermanas suyas y
# se nombran por `paths.WORKSPACE`. Ver `paths.py`.
REPO = paths.MODEL_ROOT
PUML_DIR = paths.PUML_DIR
FK_DIR = paths.FK_DIR
OUT_DIR = paths.SQL_DIR
MANIFEST = paths.MANIFEST


def model_version() -> str:
    """Versión del modelo, leída del manifest.

    Estaba cableada como 'v4.0.1' en las cabeceras de los 300+ archivos generados
    y en el reporte, así que quedó mintiendo desde v4.0.2. Se lee con un regex en
    vez de con PyYAML para no añadirle una dependencia al generador.
    """
    try:
        m = re.search(r"^\s*version:\s*([0-9][0-9.]*)\s*$",
                      MANIFEST.read_text(encoding="utf-8"), re.M)
        return f"v{m.group(1)}" if m else "v?"
    except OSError:
        return "v?"


VERSION = model_version()

# Estereotipos que NO son tablas PostgreSQL → se saltan (con motivo para el reporte).
# NOTA: GRAPH_COLLECTION (mód. 61) y LAKEHOUSE_CATALOG (mód. 63) SÍ se materializan como
# tablas PG (son catálogo/metadata del plano de control, relacionales salvo 'map'→jsonb).
SKIP_STEREOTYPES = {
    "REFERENCE_ONLY": "stub de cruce (tabla real en su módulo dueño)",
    "VIEW": "vista (sin SELECT en el .puml)",
    "MATERIALIZED_VIEW": "vista materializada (sin SELECT en el .puml)",
    "STATE_MACHINE": "máquina de estados (metadata, no es tabla)",
    "REDIS_KEYSPACE": "store Redis (otro motor)",
    "MONGODB_COLLECTION": "colección MongoDB (otro motor)",
    "OPENSEARCH_INDEX": "índice OpenSearch (otro motor)",
    "VECTOR_STORE": "vector store (otro motor)",
    "TIMESERIES_MEASUREMENT": "medición time-series (otro motor)",
    "EXTERNAL": "entidad externa",
}

# Tipos nativos permitidos + normalizaciones.
# 'technical_data_type' es el ÚNICO enum nativo permitido por el modelo (doc:
# semantic-data-analysis §3.2). Vive en el schema terminology (motor de enums).
TYPE_MAP = {
    "double": "double precision",
    "technical_data_type": '"terminology"."technical_data_type"',
    "map": "jsonb",   # graph_collection (mód. 61): propiedades clave-valor → jsonb
}
KNOWN_TYPES = {
    "uuid", "varchar", "text", "timestamptz", "timestamp", "date", "time",
    "boolean", "integer", "bigint", "smallint", "numeric", "decimal", "real",
    "double precision", "inet", "cidr", "macaddr", "jsonb", "json", "bytea",
    "interval", "char", "citext",
    '"terminology"."technical_data_type"',
}
METHOD_MAP = {"BTREE": "btree", "BRIN": "brin", "GIN": "gin", "GIST": "gist", "HASH": "hash"}


class Column:
    def __init__(self, name, dtype, not_null, is_pk, is_fk, is_uk, default=None, on_delete=None):
        self.name, self.dtype, self.not_null = name, dtype, not_null
        self.is_pk, self.is_fk, self.is_uk = is_pk, is_fk, is_uk
        self.default, self.on_delete = default, on_delete


# Default estructural de versión. Los defaults booleanos de negocio sólo se
# emiten cuando el .puml declara DEFAULT_TRUE/DEFAULT_FALSE explícitamente.
#
# No se infieren defaults de negocio: sólo se conservan los que el modelo declara.
# `row_version` sigue siendo el default estructural porque es el contador de bloqueo optimista,
# y MikroORM NO lo inicializa al crear la entidad: espera que lo aporte la base y,
# si no hay default, manda NULL y el INSERT muere con 23502 contra la columna
# NOT NULL. Sin esto, 690 de las 727 tablas con `row_version` rechazan toda
# escritura del ORM.
#
# Antes esto se parcheaba en caliente desde la aplicación (un `ALTER TABLE … SET
# DEFAULT 1` al arrancar, y solo sobre 4 schemas), que es exactamente la dirección
# de cambio que el protocolo de 4 capas prohíbe. Declararlo acá lo devuelve al
# modelo.
ROW_VERSION_COLUMN = "row_version"


def column_default(col: "Column") -> str:
    """Cláusula DEFAULT de una columna, o cadena vacía si no le corresponde."""
    if col.default is not None:
        return f" DEFAULT {col.default}"
    return " DEFAULT 1" if col.name == ROW_VERSION_COLUMN else ""


def boolean_default(dtype: str, markers: set[str]) -> str | None:
    """Conserva defaults booleanos declarados por el modelo, sin inferir valores."""
    selected = markers & {"DEFAULT_TRUE", "DEFAULT_FALSE"}
    if not selected:
        return None
    if len(selected) != 1 or dtype != "boolean":
        raise ValueError("DEFAULT_TRUE/DEFAULT_FALSE requiere una columna boolean y un solo valor")
    return "true" if "DEFAULT_TRUE" in selected else "false"


# --- identificadores > 63 bytes --------------------------------------------------
#
# PostgreSQL trunca los identificadores a 63 bytes EN SILENCIO: acepta el nombre
# largo y guarda otro. Hasta v4.0.9 este generador emitía los nombres tal cual, así
# que 58 constraints FK y 1 índice vivían en la base con un nombre distinto del que
# declara `SQL/` — y la capa 06 del bootstrap del ORM, que sí acorta, los daba por
# ausentes y proponía crearlos de nuevo en cada arranque.
#
# El algoritmo es un PUERTO EXACTO de `shortenIdentifier` en
# `mantra-core-health-api/src/orm/bootstrap/identifier.ts` — prefijo de 54 + `_` +
# sha1 hex de 8 — y debe mantenerse byte-idéntico: las dos capas calculan el nombre
# por separado a partir del mismo nombre lógico, y solo convergen si acortan igual.
# El hash no es decorativo: hay dos FKs reales de
# `insurance.prior_authorization_determinations` que comparten los primeros 54
# caracteres y solo el sufijo hash las distingue.
MAX_IDENTIFIER_LENGTH = 63
_IDENT_HASH_LENGTH = 8


def pg_ident(name: str) -> str:
    """Nombre válido para PostgreSQL: intacto hasta 63 bytes, acortado con hash después."""
    if len(name.encode("utf-8")) <= MAX_IDENTIFIER_LENGTH:
        return name
    digest = hashlib.sha1(name.encode("utf-8")).hexdigest()[:_IDENT_HASH_LENGTH]
    prefix = MAX_IDENTIFIER_LENGTH - _IDENT_HASH_LENGTH - 1
    return f"{name[:prefix]}_{digest}"


class Entity:
    def __init__(self, name):
        self.name = name
        self.columns: list[Column] = []


class Index:
    def __init__(self, kind, name, cols, unique, method, params, where=None):
        self.kind, self.name, self.cols = kind, name, cols
        self.unique, self.method, self.params = unique, method, params
        self.where = where   # predicado parcial (índices GiST de solapamiento, etc.)


# ------------------------------------------------------------------ regex
ENTITY_RE = re.compile(
    r'^\s*entity\s+(?:"([^"]+)"\s+as\s+([a-z0-9_]+)|([a-z_][a-z0-9_]*))'
    r'\s*(<<[^>]+>>)?\s*\{(.*)$', re.IGNORECASE)
COL_RE = re.compile(
    r"^\s*(\*)?\s*([a-z_][a-z0-9_]*)\s*:\s*"
    r"([a-z_][a-z0-9_]*(?:\(\s*\d+\s*(?:,\s*\d+\s*)?\))?(?:\[\])?)"   # tipo, con (p,s) y/o []
    r"\s*(<<[^>]+>>)?\s*$",
    re.IGNORECASE)
IDX_HEAD_RE = re.compile(
    r"^\s*(PK|IX|UK|UX|BRIN|GIN|GIST|HASH)\s+([a-z_][a-z0-9_]*)\s*:\s*(.+?)\s*$",
    re.IGNORECASE)
METHOD_KW_RE = re.compile(r"\s+(BTREE|BRIN|GIN|GIST|HASH)\s*$", re.IGNORECASE)
IDENT_RE = re.compile(r"^[a-z_][a-z0-9_]*$", re.IGNORECASE)


def _split_top_commas(s):
    """Divide por comas de nivel superior, respetando () y literales '…'."""
    out, buf, depth, inq = [], [], 0, False
    for ch in s:
        if inq:
            buf.append(ch)
            if ch == "'":
                inq = False
        elif ch == "'":
            inq = True; buf.append(ch)
        elif ch == "(":
            depth += 1; buf.append(ch)
        elif ch == ")":
            depth -= 1; buf.append(ch)
        elif ch == "," and depth == 0:
            out.append("".join(buf)); buf = []
        else:
            buf.append(ch)
    if buf:
        out.append("".join(buf))
    return [x.strip() for x in out if x.strip()]


def _split_where(s):
    """Separa 'SPEC … WHERE pred' respetando () y comillas → (izquierda, pred|None)."""
    depth, inq, i, up = 0, False, 0, s.upper()
    while i < len(s):
        ch = s[i]
        if inq:
            if ch == "'":
                inq = False
        elif ch == "'":
            inq = True
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif depth == 0 and up[i:i + 5] == "WHERE" \
                and (i == 0 or not (s[i - 1].isalnum() or s[i - 1] == "_")) \
                and (i + 5 >= len(s) or not (s[i + 5].isalnum() or s[i + 5] == "_")):
            return s[:i].rstrip(), s[i + 5:].strip()
        i += 1
    return s, None


def _wraps(s):
    """True si el primer '(' de s cierra en el último carácter (paréntesis envolvente)."""
    if not (s.startswith("(") and s.endswith(")")):
        return False
    depth, inq = 0, False
    for i, ch in enumerate(s):
        if inq:
            if ch == "'":
                inq = False
        elif ch == "'":
            inq = True
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i == len(s) - 1
    return False


def parse_index_line(line):
    """Parsea 'KIND name : SPEC [MÉTODO] [WHERE pred]'. SPEC puede ser lista de
    columnas y/o expresiones (p.ej. tstzrange(a, b, '[)')). Devuelve Index o None."""
    m = IDX_HEAD_RE.match(line)
    if not m:
        return None
    kind, name, body = m.group(1).upper(), m.group(2), m.group(3).strip()
    # Variante 'PARTIAL <col> [not] null' (mód. 60) → índice parcial WHERE col IS [NOT] NULL
    pm = re.search(r"\s+PARTIAL\s+([a-z_][a-z0-9_]*)\s+(not\s+null|null)\s*$", body, re.IGNORECASE)
    if pm:
        cond = "IS NOT NULL" if "not" in pm.group(2).lower() else "IS NULL"
        body = f"{body[:pm.start()].rstrip()} WHERE {pm.group(1)} {cond}"
    spec, where = _split_where(body)
    # Operator class de GIN/GiST (p.ej. 'jsonb_path_ops') al final del spec → va PEGADO a
    # la columna dentro del paréntesis: USING gin (col jsonb_path_ops). Se pela primero.
    opclass = None
    m_oc = re.search(r"\s+([a-z_]+_ops)\s*$", spec)
    if m_oc:
        opclass = m_oc.group(1); spec = spec[:m_oc.start()].rstrip()
    # Modificadores finales tras el spec de columnas, en cualquier orden:
    # UNIQUE, método (BTREE/BRIN/GIN/GIST/HASH) y params (clave=valor). Se pelan por la derecha.
    unique, method, params = False, None, None
    while True:
        m2 = re.search(r"\s+UNIQUE\s*$", spec, re.IGNORECASE)
        if m2:
            unique = True; spec = spec[:m2.start()].rstrip(); continue
        m2 = METHOD_KW_RE.search(spec)
        if m2:
            if method is None:
                method = m2.group(1).lower()
            spec = spec[:m2.start()].rstrip(); continue
        m2 = re.search(r"\s+(\w+\s*=\s*\d+)\s*$", spec)
        if m2:
            if params is None:
                params = m2.group(1).replace(" ", "")
            spec = spec[:m2.start()].rstrip(); continue
        break
    if method is None:
        method = METHOD_MAP.get(kind, "btree")
    if _wraps(spec):
        spec = spec[1:-1].strip()
    cols = _split_top_commas(spec)
    if opclass and len(cols) == 1:        # el opclass se pega a la (única) columna GIN/GiST
        cols = [f"{cols[0]} {opclass}"]
    return Index(kind, name, cols, unique, method, params, where)


def is_plain_col(item):
    """True si el elemento del índice es una columna simple (id opcional + ASC/DESC)."""
    parts = item.split()
    if len(parts) > 1 and parts[-1].upper() in ("ASC", "DESC"):
        parts = parts[:-1]
    return len(parts) == 1 and bool(IDENT_RE.match(parts[0]))


# Notación alterna del graph store (mód. 61): 'KIND name : col + col [DESC] [UNIQUE]'
GRAPH_IDX_RE = re.compile(
    r"^\s*(CONSTRAINT|INDEX|LOOKUP|FULLTEXT|TTL)\s+([a-z_][a-z0-9_]*)\s*:\s*(.+?)\s*$",
    re.IGNORECASE)
GRAPH_KIND = {"CONSTRAINT": ("IX", True), "INDEX": ("IX", False),
              "LOOKUP": ("IX", False), "FULLTEXT": ("FT", False), "TTL": ("TTL", False)}


def _rewrite_concat_ws(s):
    """concat_ws(SEP, a, b, …) → (coalesce(a, '') || SEP || coalesce(b, '') || …).
    concat_ws es STABLE y PostgreSQL la rechaza en expresiones de índice; el equivalente
    con || y coalesce es IMMUTABLE y sirve igual para to_tsvector. Recursivo por si hay
    más de una ocurrencia."""
    low = s.lower()
    idx = low.find("concat_ws(")
    if idx == -1:
        return s
    start = idx + len("concat_ws(")
    depth, inq, i = 1, False, start
    while i < len(s) and depth > 0:
        ch = s[i]
        if inq:
            if ch == "'":
                inq = False
        elif ch == "'":
            inq = True
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        i += 1
    args = _split_top_commas(s[start:i - 1])
    if len(args) < 2:
        return s
    sep, cols = args[0], args[1:]
    joined = f" || {sep} || ".join(f"coalesce({c}, '')" for c in cols)
    return _rewrite_concat_ws(s[:idx] + f"({joined})" + s[i:])


def render_index_cols(cols):
    """Renderiza elementos de índice: columnas simples entre comillas (preservando
    ASC/DESC) y expresiones (p.ej. tstzrange(a, b, '[)')) tal cual, sin citar.
    Reescribe concat_ws (STABLE) a su forma IMMUTABLE para índices funcionales."""
    out = []
    for c in cols:
        parts = c.split()
        direction = ""
        expr = c
        if len(parts) > 1 and parts[-1].upper() in ("ASC", "DESC"):
            direction = f" {parts[-1].upper()}"
            expr = " ".join(parts[:-1])
        if IDENT_RE.match(expr):
            out.append(f'"{expr}"{direction}')
        else:
            out.append(f"{_rewrite_concat_ws(expr)}{direction}")
    return ", ".join(out)


# El .puml usa tstzrange(…) para todo período, pero muchas columnas valid_from/valid_to son
# 'date' → tstzrange fuerza un cast date→timestamptz que es STABLE (rechazado en índices).
# El constructor debe coincidir con el tipo real de la columna (todos IMMUTABLE con su tipo).
_RANGE_CTOR = {"date": "daterange", "timestamp": "tsrange", "timestamptz": "tstzrange"}
_RANGE_CALL_RE = re.compile(r"\b(tstzrange|tsrange|daterange)\(\s*([a-z_][a-z0-9_]*)", re.IGNORECASE)


def fix_range_ctor(expr, types):
    """Reescribe el constructor de rango (tstzrange/tsrange/daterange) para que coincida con
    el tipo de su 1ª columna, evitando casts STABLE en expresiones de índice."""
    def repl(m):
        col = m.group(2)
        want = _RANGE_CTOR.get((types.get(col) or "").lower())
        return f"{want}({col}" if want and want != m.group(1).lower() else m.group(0)
    return _RANGE_CALL_RE.sub(repl, expr)


def stereotypes(raw: str | None) -> set[str]:
    if not raw:
        return set()
    return {s.strip().upper() for s in raw.strip("<>").split(",") if s.strip()}


def parse_module(puml_path: Path):
    text = puml_path.read_text(encoding="utf-8")
    m = re.search(r"\(schema:\s*([a-z0-9_]+)\)", text)
    schema = m.group(1) if m else puml_path.stem.split("_", 2)[-1]

    entities: list[Entity] = []
    idx_by_table: dict[str, list[Index]] = {}
    skipped: list[tuple[str, str]] = []   # (nombre, motivo)
    warnings: list[str] = []

    lines = text.splitlines()
    i, n = 0, len(lines)
    while i < n:
        line = lines[i]

        # INDEX_SET: entity "INDEXES · X" as idxset_X <<INDEX_SET>> {
        im = re.match(r'^\s*entity\s+"[^"]*"\s+as\s+idxset_([a-z0-9_]+)\s+<<INDEX_SET>>\s*\{',
                      line, re.IGNORECASE)
        if im:
            table, idxs = im.group(1), []
            i += 1
            while i < n and lines[i].strip() != "}":
                xi = parse_index_line(lines[i])
                if xi:
                    idxs.append(xi)
                else:
                    gm = GRAPH_IDX_RE.match(lines[i])
                    if gm:
                        spec = gm.group(3).strip()
                        unique = spec.upper().endswith("UNIQUE")
                        if unique:
                            spec = spec[:-6].strip()
                        kind, uk = GRAPH_KIND[gm.group(1).upper()]
                        method = "gin" if kind == "FT" else "btree"
                        # MULTIVALUE = índice sobre miembros de un array → GIN en PG
                        mv = re.search(r"\s+MULTIVALUE\s*$", spec, re.IGNORECASE)
                        if mv:
                            spec = spec[:mv.start()].rstrip()
                            method = "gin"
                        cols = [c.strip() for c in spec.split("+") if c.strip()]
                        idxs.append(Index(kind, gm.group(2), cols, unique or uk, method, None))
                i += 1
            idx_by_table[table] = idxs
            i += 1
            continue

        em = ENTITY_RE.match(line)
        if em:
            qname, alias, bare, stereo_raw, rest = em.groups()
            name = bare or alias or qname
            stset = stereotypes(stereo_raw)
            if "INDEX_SET" in stset:   # ya cubierto arriba; por si acaso
                i = _skip_block(lines, i, rest)
                continue

            skip_reason = next((SKIP_STEREOTYPES[s] for s in stset if s in SKIP_STEREOTYPES), None)
            if skip_reason:
                skipped.append((name, skip_reason))
                i = _skip_block(lines, i, rest)
                continue

            # tabla PostgreSQL
            ent = Entity(name)
            if "}" in rest:            # entidad de una sola línea (raro para tablas)
                i += 1
            else:
                i += 1
                while i < n and lines[i].strip() != "}":
                    cl = lines[i].strip()
                    if cl in ("", "--") or cl.startswith("'"):   # separador / comentario PlantUML
                        i += 1
                        continue
                    cm = COL_RE.match(lines[i])
                    if cm:
                        rt = cm.group(3).lower().replace(" ", "")   # p.ej. numeric(20,6), text[]
                        base = re.match(r"[a-z_][a-z0-9_]*", rt).group(0)
                        suffix = rt[len(base):]                     # (20,6) / [] / (3) / ''
                        base_mapped = TYPE_MAP.get(base, base)
                        if base_mapped not in KNOWN_TYPES:
                            warnings.append(f"tipo no-SQL '{rt}' en {name}.{cm.group(2)} (columna omitida)")
                            i += 1
                            continue
                        dtype = base_mapped + suffix
                        st = stereotypes(cm.group(4))
                        default = boolean_default(dtype, st)
                        if "ON_DELETE_CASCADE" in st and "FK" not in st:
                            raise ValueError(f"ON_DELETE_CASCADE requiere FK: {schema}.{name}.{cm.group(2)}")
                        col = Column(
                            cm.group(2), dtype, cm.group(1) == "*",
                            "PK" in st, "FK" in st, "UK" in st, default,
                            "CASCADE" if "ON_DELETE_CASCADE" in st else None)
                        prev = next((c for c in ent.columns if c.name == col.name), None)
                        if prev is None:
                            ent.columns.append(col)
                        elif prev.dtype == col.dtype:
                            warnings.append(f"columna duplicada '{col.name}' en {name} "
                                            "(declarada dos veces en el .puml; deduplicada)")
                        else:
                            warnings.append(f"columna duplicada '{col.name}' en {name} con tipos "
                                            f"DISTINTOS ({prev.dtype} vs {col.dtype}); se conserva la primera")
                    else:
                        warnings.append(f"línea no parseada en {name}: {cl!r}")
                    i += 1
                i += 1
            if ent.columns:
                entities.append(ent)
            else:
                skipped.append((name, "sin columnas parseables"))
            continue

        i += 1

    return schema, entities, idx_by_table, skipped, warnings


def _skip_block(lines, i, rest):
    """Avanza el índice más allá del bloque { ... } de una entidad saltada."""
    if "}" in rest:
        return i + 1
    i += 1
    n = len(lines)
    while i < n and lines[i].strip() != "}":
        i += 1
    return i + 1


# ------------------------------------------------------------------ resolución FK
TARGET_RE = re.compile(r"\[\[E\s+([a-z0-9_]+)\.([a-z0-9_]+)\s*\|")


def resolve_fk(schema, table, col):
    note = FK_DIR / f"FK {schema}.{table}.{col}.md"
    if not note.exists():
        return None
    body = note.read_text(encoding="utf-8")
    if "Destino no resuelto" in body:
        return None
    idx = body.find("Apunta a")
    m = TARGET_RE.search(body[idx:] if idx != -1 else body)
    return (m.group(1), m.group(2)) if m else None


def resolve_fk_from_diagram(puml, schema, table, col):
    """Resolve an explicitly labeled ER edge to its canonical target entity.

    Reference-only stubs keep cross-module targets visible in the source model.
    The edge label names the FK column, so multiple FKs to the same entity stay
    unambiguous without relying on a name-based guess or an external vault note.
    """
    text = puml.read_text(encoding="utf-8")
    aliases = {}
    entity_re = re.compile(
        r'^\s*entity\s+"([^\"]+)"\s+as\s+([A-Za-z0-9_]+)', re.MULTILINE
    )
    for qualified, alias in entity_re.findall(text):
        if "." in qualified:
            aliases[alias] = tuple(qualified.split(".", 1))
        else:
            aliases[alias] = (schema, qualified)

    relation_re = re.compile(
        r'^\s*([A-Za-z0-9_]+)\s+\S*--\S*\s+'
        r'([A-Za-z0-9_]+)\s*:\s*([A-Za-z_][A-Za-z0-9_]*)\s*$',
        re.MULTILINE,
    )
    for source, target, label in relation_re.findall(text):
        if source == table and label == col and target in aliases:
            return aliases[target]
    return None


def build_registry(codes):
    """Mapa nombre_tabla → [(schema, tabla)] de TODAS las tablas PG (para la convención)."""
    reg: dict[str, set] = {}
    for code in codes:
        puml = next(PUML_DIR.glob(f"diagram_{code}_*.puml"), None)
        if not puml:
            continue
        schema, entities, *_ = parse_module(puml)
        for e in entities:
            reg.setdefault(e.name, set()).add((schema, e.name))
    return {k: sorted(v) for k, v in reg.items()}


def build_pk_map(codes):
    """Mapa (schema, tabla) → columna PK real. La mayoría es 'id', pero los subtipos CTI
    (patient_profiles, etc.) tienen PK 'profile_id'. Las FK deben referenciar el PK real."""
    pk = {}
    for code in codes:
        puml = next(PUML_DIR.glob(f"diagram_{code}_*.puml"), None)
        if not puml:
            continue
        schema, entities, *_ = parse_module(puml)
        for e in entities:
            pkcols = [c.name for c in e.columns if c.is_pk]
            if pkcols:
                pk[(schema, e.name)] = pkcols[0]   # sin PKs compuestas en el modelo
    return pk


def _plural_candidates(prefix: str):
    yield prefix
    yield prefix + "s"
    yield prefix + "es"
    if prefix.endswith("y"):
        yield prefix[:-1] + "ies"


def resolve_fk_convention(schema, table, col, registry):
    """Réplica de la convención del vault. Devuelve (schema, tabla) o None. Marca 'inferida'.
    Solo resuelve destinos UNÍVOCOS; los ambiguos/autorreferenciales quedan sin resolver."""
    def exists(sch, tbl):
        return tbl in registry and (sch, tbl) in registry[tbl]

    if col.endswith("concept_id"):
        return ("terminology", "catalog_concepts") if exists("terminology", "catalog_concepts") else None
    if col == "user_id" or col.endswith("_user_id"):
        return ("iam", "users") if exists("iam", "users") else None
    if col == "tenant_id":
        return ("directory", "tenants") if exists("directory", "tenants") else None
    if col.endswith("_file_id"):
        return ("common", "files") if exists("common", "files") else None
    if col.endswith("_id"):
        prefix = col[:-3]
        for cand in _plural_candidates(prefix):
            hits = registry.get(cand)
            if hits and len(hits) == 1:      # solo si es unívoco en todo el modelo
                return hits[0]
    return None


# ------------------------------------------------------------------ emisión
def q(schema, table):
    return f'"{schema}"."{table}"'


def emit(module_code: str, report: list, registry: dict, pk_map: dict):
    puml = next(PUML_DIR.glob(f"diagram_{module_code}_*.puml"), None)
    if not puml:
        print(f"!! no encontrado diagram_{module_code}_*.puml")
        return
    schema, entities, idx_by_table, skipped, warnings = parse_module(puml)

    if not entities:
        report.append((module_code, schema, 0, 0, 0, skipped, warnings, 0))
        print(f"[{module_code}/{schema}] 0 tablas PG (módulo especializado/no-SQL) · "
              f"{len(skipped)} entidades saltadas")
        return

    mod_dir = OUT_DIR / f"{module_code}_{schema}"
    mod_dir.mkdir(parents=True, exist_ok=True)
    hdr = f"-- SALUD {VERSION} · módulo {module_code} · schema {schema}\n-- Generado de {puml.name} — NO editar a mano.\n\n"

    (mod_dir / "01_schema.sql").write_text(hdr + f'CREATE SCHEMA IF NOT EXISTS "{schema}";\n', encoding="utf-8")

    # 02 tables
    tbl = [hdr]
    for e in entities:
        cols = [
            f'    "{c.name}" {c.dtype}'
            f'{" NOT NULL" if c.not_null else ""}{column_default(c)}'
            for c in e.columns
        ]
        body = ",\n".join(cols)
        pk = [c.name for c in e.columns if c.is_pk]
        if pk:
            body += f',\n    CONSTRAINT "pk_{e.name}" PRIMARY KEY ({", ".join(chr(34)+c+chr(34) for c in pk)})'
        tbl.append(f"CREATE TABLE IF NOT EXISTS {q(schema, e.name)} (\n{body}\n);\n")
    (mod_dir / "02_tables.sql").write_text("\n".join(tbl), encoding="utf-8")

    # 03 fk intra / 90 deferred
    intra, deferred, unresolved = [hdr], [hdr], []
    n_intra = n_def = n_inf = 0
    for e in entities:
        for c in e.columns:
            if not c.is_fk:
                continue
            tgt = resolve_fk(schema, e.name, c.name)     # 1º: destino canónico del vault
            if tgt is None:
                tgt = resolve_fk_from_diagram(puml, schema, e.name, c.name)
            # El vault a veces resuelve a <mismo_schema>.<tabla> asumiendo same-schema, pero la
            # tabla vive en otro schema (p.ej. scheduling.appointments → clinical.appointments).
            # Si el destino del vault NO existe en el registro, se descarta y se re-resuelve.
            if tgt is not None and tgt not in registry.get(tgt[1], []):
                tgt = None
            inferred = False
            if tgt is None:                              # 2º: fallback por convención
                tgt = resolve_fk_convention(schema, e.name, c.name, registry)
                inferred = tgt is not None
            if tgt is None:
                unresolved.append(f"{e.name}.{c.name}")
                continue
            tsch, ttbl = tgt
            tag = "  -- (inferida por convención)" if inferred else ""
            n_inf += 1 if inferred else 0
            # Idempotente: si la constraint ya existe (aplicación parcial previa) se ignora.
            stmt = (f'DO $$ BEGIN\n'
                    f'    ALTER TABLE {q(schema, e.name)}\n'
                    f'        ADD CONSTRAINT "{pg_ident(f"fk_{e.name}_{c.name}")}" FOREIGN KEY ("{c.name}")\n'
                    f'        REFERENCES {q(tsch, ttbl)} ("{pk_map.get((tsch, ttbl), "id")}")'
                    f'{" ON DELETE " + c.on_delete if c.on_delete else ""};\n'
                    f'EXCEPTION WHEN duplicate_object THEN NULL; END $$;{tag}\n')
            if tsch == schema:
                intra.append(stmt); n_intra += 1
            else:
                deferred.append(f"-- destino: {tsch}.{ttbl} (requiere schema {tsch})\n{stmt}"); n_def += 1
    if unresolved:
        deferred.insert(1, "-- FK sin destino canónico (no forzadas, temperatura-0):\n"
                        + "".join(f"--   {u}\n" for u in unresolved) + "\n")
    (mod_dir / "03_fk_intra.sql").write_text("\n".join(intra), encoding="utf-8")
    (mod_dir / "90_fk_deferred.sql").write_text("\n".join(deferred), encoding="utf-8")

    # 04 indexes (se omite el PK, lo crea la constraint)
    valid_tables = {e.name for e in entities}
    cols_by_table = {e.name: {c.name for c in e.columns} for e in entities}
    types_by_table = {e.name: {c.name: c.dtype for c in e.columns} for e in entities}
    idx_sql, n_idx, needs_btree_gist = [hdr], 0, False
    for table, idxs in idx_by_table.items():
        if table not in valid_tables:      # índice de una entidad saltada
            continue
        for ix in idxs:
            if ix.kind == "PK":
                continue
            if ix.kind == "TTL":   # PG no tiene índice TTL → se gestiona con job de retención
                idx_sql.append(f'-- TTL "{ix.name}" ({", ".join(ix.cols)}): sin índice TTL en PG; usar job de retención.\n')
                continue
            if ix.kind == "FT":    # full-text del graph store → GIN sobre to_tsvector
                col = ix.cols[0].split()[0]
                idx_sql.append(f'CREATE INDEX IF NOT EXISTS "{ix.name}" ON {q(schema, table)} '
                               f"USING gin (to_tsvector('simple', \"{col}\"));\n")
                n_idx += 1
                continue
            # columnas simples referidas por el índice (para validar existencia)
            plain = [c.split()[0] for c in ix.cols if is_plain_col(c)]
            missing = [c for c in plain if c not in cols_by_table.get(table, set())]
            if missing:   # p.ej. GiST sobre 'geography_point' (tipo geography/PostGIS descartado)
                warnings.append(f"índice '{ix.name}' omitido: columna(s) inexistente(s) "
                                f"{missing} en {table} (¿tipo no-SQL descartado? requiere PostGIS)")
                idx_sql.append(f'-- OMITIDO "{ix.name}" ({", ".join(ix.cols)}) {ix.method}: '
                               f"columna(s) {missing} no existe(n) — requiere PostGIS/otro tipo.\n")
                continue
            cols = render_index_cols(ix.cols)
            cols = fix_range_ctor(cols, types_by_table.get(table, {}))
            uniq = "UNIQUE " if ix.unique else ""
            using = f" USING {ix.method}" if ix.method != "btree" else ""
            with_c = f" WITH ({ix.params})" if ix.params else ""
            # predicado parcial con función placeholder del modelo (p.ej. held_status())
            # → no existe en la BD; se emite COMENTADO para no romper el apply (temperatura-0).
            if ix.where and re.search(r"[a-z_][a-z0-9_]*\(\s*\)", ix.where, re.IGNORECASE):
                warnings.append(f"índice '{ix.name}': predicado referencia función(es) placeholder "
                                f"del modelo → emitido COMENTADO (definir función o reemplazar por IDs).")
                idx_sql.append(f'-- TODO(predicado placeholder, definir funciones): '
                               f'CREATE {uniq}INDEX IF NOT EXISTS "{pg_ident(ix.name)}" ON {q(schema, table)}'
                               f'{using} ({cols}){with_c} WHERE {ix.where};\n')
                continue
            # GiST con columna escalar (uuid/int/text/…) necesita la extensión btree_gist
            if ix.method == "gist" and plain:
                needs_btree_gist = True
            where_c = f" WHERE {ix.where}" if ix.where else ""
            idx_sql.append(f'CREATE {uniq}INDEX IF NOT EXISTS "{pg_ident(ix.name)}" ON {q(schema, table)}'
                           f'{using} ({cols}){with_c}{where_c};\n')
            n_idx += 1
    if needs_btree_gist:
        idx_sql.insert(1, "-- Requerida por índices GiST sobre columnas escalares (uuid/int/…):\n"
                          "CREATE EXTENSION IF NOT EXISTS btree_gist;\n")
    (mod_dir / "04_indexes.sql").write_text("\n".join(idx_sql), encoding="utf-8")

    report.append((module_code, schema, len(entities), n_intra + n_def, n_idx, skipped, warnings, n_inf))
    print(f"[{module_code}/{schema}] {len(entities)} tablas · {n_intra} FK intra · "
          f"{n_def} FK diferidas · {n_inf} inferidas · {n_idx} índices · {len(skipped)} saltadas"
          + (f" · {len(warnings)} avisos" if warnings else ""))
    for w in warnings[:5]:
        print(f"   ! {w}")


def write_report(report):
    lines = [f"# Reporte de generación SQL — SALUD {VERSION}\n",
             "Generado fielmente desde los `.puml`. Solo se emiten tablas PostgreSQL; "
             "las vistas, stubs de cruce y stores no-SQL (Redis/Mongo/OpenSearch/vector/"
             "timeseries) se listan como *saltados*. Graph (61) y Lakehouse (63) SÍ se "
             "materializan como tablas PG (catálogo del plano de control). Las FK marcadas "
             "*inferidas* se resolvieron por convención cuando el vault no tenía destino.\n",
             "| Mód | Schema | Tablas PG | FK | (inferidas) | Índices | Saltadas |",
             "|-----|--------|-----------|----|-------------|---------|----------|"]
    tot_t = tot_s = tot_i = 0
    for code, schema, nt, nfk, nidx, skipped, _, ninf in sorted(report):
        tot_t += nt; tot_s += len(skipped); tot_i += ninf
        tag = "" if nt else " _(especializado/no-SQL)_"
        lines.append(f"| {code} | {schema}{tag} | {nt} | {nfk} | {ninf} | {nidx} | {len(skipped)} |")
    lines.append(f"| **Σ** | **{len(report)}** | **{tot_t}** | | **{tot_i}** | | **{tot_s}** |\n")

    # detalle de saltadas y avisos
    lines.append("## Detalle de entidades saltadas y avisos\n")
    for code, schema, nt, nfk, nidx, skipped, warnings, ninf in sorted(report):
        if not skipped and not warnings:
            continue
        lines.append(f"### {code} · {schema}")
        for name, reason in skipped:
            lines.append(f"- `{name}` — {reason}")
        for w in warnings:
            lines.append(f"- ⚠ {w}")
        lines.append("")
    (OUT_DIR / "_generation_report.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"\n→ {tot_t} tablas PG en total · reporte en SQL/_generation_report.md")


# Vocabulario de `terminology.technical_data_type`, el único enum nativo del modelo.
#
# Hasta v4.0.8 el enum se creaba VACÍO con un TODO. La consecuencia era doble: la
# aplicación no podía escribir sus tipos reales (`POST /forms/field-definitions`
# moría con `invalid input value for enum`), y `gen_seeds.py` lo rellenaba con
# 78 placeholders sintéticos derivados de los seeds —`DYNAMIC_FIELD_DEFINITIONS_01`,
# `bob_data_type`…— que el propio cargador marca como basura.
#
# Estos 14 valores no se inventan acá: son los que la aplicación ya declara y usa en
# `src/modules/forms/dto/create-field-definition.dto.ts` (TECHNICAL_DATA_TYPES), y
# los dos primeros son literalmente los que el TODO del modelo ponía de ejemplo.
TECHNICAL_DATA_TYPES = (
    "string", "text", "integer", "decimal", "boolean", "date", "datetime",
    "time", "uuid", "json", "binary", "reference", "code",
)


def write_shared():
    """Tipos compartidos que deben existir ANTES de las tablas que los usan."""
    d = OUT_DIR / "00_shared"
    d.mkdir(parents=True, exist_ok=True)
    valores = ", ".join(f"'{v}'" for v in TECHNICAL_DATA_TYPES)
    # `ADD VALUE IF NOT EXISTS` deja al alcance de una base ya creada los valores que
    # le falten: en un build desde cero el CREATE TYPE ya los trae y estos no hacen nada.
    altas = "".join(
        f'ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS \'{v}\';\n'
        for v in TECHNICAL_DATA_TYPES
    )
    (d / "00_types.sql").write_text(
        f"-- SALUD {VERSION} · tipos compartidos (aplicar PRIMERO, antes de cualquier tabla)\n"
        "-- 'technical_data_type' es el único enum nativo permitido por el modelo\n"
        "-- (doc: semantic-data-analysis §3.2). Usado en módulos 03/09/30/39/44.\n"
        "-- Vocabulario: el que declara y usa la aplicación en forms/dto\n"
        "-- (TECHNICAL_DATA_TYPES). Antes el enum se creaba vacío y toda escritura\n"
        "-- de un tipo real fallaba con 'invalid input value for enum'.\n\n"
        'CREATE SCHEMA IF NOT EXISTS "terminology";\n\n'
        "DO $$ BEGIN\n"
        f'    CREATE TYPE "terminology"."technical_data_type" AS ENUM ({valores});\n'
        "EXCEPTION WHEN duplicate_object THEN NULL;\n"
        "END $$;\n\n"
        "-- Idempotente para bases ya creadas (incluidas las que quedaron con el enum vacío).\n"
        f"{altas}",
        encoding="utf-8")
    print(f"→ SQL/00_shared/00_types.sql (enum technical_data_type, {len(TECHNICAL_DATA_TYPES)} valores)")


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    arg = sys.argv[1] if len(sys.argv) > 1 else "01"
    report = []
    write_shared()
    all_codes = sorted({p.stem.split("_")[1] for p in PUML_DIR.glob("diagram_*.puml")})
    registry = build_registry(all_codes)   # registro global para la convención FK
    pk_map = build_pk_map(all_codes)       # PK real por tabla (subtipos CTI usan profile_id)
    codes = all_codes if arg == "all" else [f"{int(arg):02d}"]
    for code in codes:
        emit(code, report, registry, pk_map)
    write_report(report)


if __name__ == "__main__":
    main()
