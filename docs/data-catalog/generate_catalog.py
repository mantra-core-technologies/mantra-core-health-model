#!/usr/bin/env python3
"""Export a read-only metadata catalog from SALUD's canonical PostgreSQL DDL."""

from __future__ import annotations

import csv
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQL_ROOT = ROOT / "SQL"
OUT = Path(__file__).resolve().parent


def uncomment(sql: str) -> str:
    sql = re.sub(r"/\*.*?\*/", "", sql, flags=re.S)
    return re.sub(r"--[^\n]*", "", sql)


def read_rationales() -> dict[tuple[str, str], tuple[str, str, str]]:
    result = {}
    path = OUT / "table-rationales.csv"
    with path.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            key = (row["schema"], row["table"])
            if key in result:
                raise ValueError(f"Duplicate business rationale for {key[0]}.{key[1]}")
            if row["rationale_status"] != "PENDING_REVIEW" and not row["business_rationale"].strip():
                raise ValueError(f"Missing business rationale for {key[0]}.{key[1]}")
            result[key] = (
                row["business_rationale"], row["rationale_status"], row["evidence"]
            )
    return result


def write_csv(name: str, headers: list[str], rows: list[dict[str, str]]) -> None:
    with (OUT / name).open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=headers, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    rationales = read_rationales()
    diagram_root = ROOT / "Mantra Core Health Context" / "modules"
    diagram_by_schema = {}
    for diagram_path in sorted(diagram_root.glob("*.puml")):
        diagram_text = diagram_path.read_text(encoding="utf-8")
        schema_match = re.search(r'\(schema:\s*([A-Za-z_][A-Za-z0-9_]*)\)', diagram_text)
        if schema_match:
            diagram_by_schema[schema_match.group(1)] = diagram_path.relative_to(ROOT).as_posix()
    tables: dict[tuple[str, str], dict] = {}
    columns: dict[tuple[str, str], list[dict]] = defaultdict(list)
    constraints: dict[tuple[str, str], list[dict]] = defaultdict(list)
    relations: list[dict[str, str]] = []
    indexes: list[dict[str, str]] = []

    table_pattern = re.compile(
        r'CREATE TABLE IF NOT EXISTS\s+"(?P<schema>[^"]+)"\."(?P<table>[^"]+)"\s*\((?P<body>.*?)\n\);',
        re.S,
    )
    for ddl_path in sorted(SQL_ROOT.glob("*/02_tables.sql")):
        sql = uncomment(ddl_path.read_text(encoding="utf-8"))
        for match in table_pattern.finditer(sql):
            schema, table, body = match.group("schema", "table", "body")
            key = (schema, table)
            if schema not in diagram_by_schema:
                # Some physical schemas are explicitly described as a PostgreSQL
                # control-plane store rather than using a `(schema: ...)` title.
                # Resolve those by the unique diagram with the same module number.
                candidates = sorted(diagram_root.glob(f"diagram_{ddl_path.parent.name[:2]}_*.puml"))
                if len(candidates) != 1:
                    raise ValueError(f"No unique model diagram declares PostgreSQL schema {schema!r}")
                diagram_by_schema[schema] = candidates[0].relative_to(ROOT).as_posix()
            tables[key] = {
                "schema": schema,
                "table": table,
                "source_ddl": ddl_path.relative_to(ROOT).as_posix(),
                "source_diagram": diagram_by_schema[schema],
            }
            ordinal = 0
            for line in body.splitlines():
                line = line.strip().rstrip(",")
                pk = re.match(r'CONSTRAINT\s+"([^"]+)"\s+PRIMARY KEY\s*\(([^)]+)\)', line, re.I)
                if pk:
                    fields = [f.strip().strip('"') for f in pk.group(2).split(",")]
                    constraints[key].append({
                        "schema": schema, "table": table, "constraint_name": pk.group(1),
                        "constraint_type": "PRIMARY KEY", "columns": ",".join(fields),
                        "definition": f"PRIMARY KEY ({', '.join(fields)})", "source_ddl": ddl_path.relative_to(ROOT).as_posix(),
                    })
                    continue
                col = re.match(r'^"(?P<name>[^"]+)"\s+(?P<rest>.+)$', line)
                if not col:
                    continue
                ordinal += 1
                name, rest = col.group("name", "rest")
                type_match = re.match(r'(?P<type>.+?)(?=\s+(?:NOT NULL|NULL|DEFAULT|PRIMARY KEY|UNIQUE|REFERENCES|CHECK)\b|$)', rest, re.I)
                data_type = type_match.group("type").strip() if type_match else rest.strip()
                default_match = re.search(r'\bDEFAULT\s+(.+?)(?=\s+(?:NOT NULL|NULL|PRIMARY KEY|UNIQUE|REFERENCES|CHECK)\b|$)', rest, re.I)
                columns[key].append({
                    "schema": schema, "table": table, "ordinal": str(ordinal), "column": name,
                    "data_type": data_type, "nullable": "NO" if re.search(r'\bNOT NULL\b', rest, re.I) else "YES",
                    "default": default_match.group(1).strip() if default_match else "",
                    "restrictions": "PRIMARY KEY" if name in next((c["columns"].split(",") for c in constraints[key] if c["constraint_type"] == "PRIMARY KEY"), []) else "",
                    "referenced_schema": "", "referenced_table": "", "referenced_column": "",
                    "source_ddl": ddl_path.relative_to(ROOT).as_posix(),
                })

    unknown_rationales = sorted(set(rationales) - set(tables))
    if unknown_rationales:
        raise ValueError("Rationales point to tables absent from canonical DDL: " + ", ".join(f"{s}.{t}" for s, t in unknown_rationales))

    # Foreign keys, including cross-schema keys deferred until all modules exist.
    fk_pattern = re.compile(
        r'ALTER TABLE\s+"(?P<source_schema>[^"]+)"\."(?P<source_table>[^"]+)"\s+'
        r'ADD CONSTRAINT\s+"(?P<name>[^"]+)"\s+FOREIGN KEY\s*\((?P<source_columns>[^)]+)\)\s+'
        r'REFERENCES\s+"(?P<target_schema>[^"]+)"\."(?P<target_table>[^"]+)"\s*\((?P<target_columns>[^)]+)\)', re.I,
    )
    for fk_path in sorted(SQL_ROOT.glob("*/03_fk_intra.sql")) + sorted(SQL_ROOT.glob("*/90_fk_deferred.sql")):
        raw = fk_path.read_text(encoding="utf-8")
        sql = uncomment(raw)
        for match in fk_pattern.finditer(sql):
            row = {k: v.strip().strip('"') for k, v in match.groupdict().items()}
            source_key = (row["source_schema"], row["source_table"])
            source_cols = [c.strip().strip('"') for c in row["source_columns"].split(",")]
            target_cols = [c.strip().strip('"') for c in row["target_columns"].split(",")]
            source_path = fk_path.relative_to(ROOT).as_posix()
            constraints[source_key].append({
                "schema": row["source_schema"], "table": row["source_table"], "constraint_name": row["name"],
                "constraint_type": "FOREIGN KEY", "columns": ",".join(source_cols),
                "definition": f"FOREIGN KEY ({', '.join(source_cols)}) REFERENCES {row['target_schema']}.{row['target_table']} ({', '.join(target_cols)})",
                "source_ddl": source_path,
            })
            relations.append({
                "source_schema": row["source_schema"], "source_table": row["source_table"],
                "source_columns": ",".join(source_cols), "target_schema": row["target_schema"],
                "target_table": row["target_table"], "target_columns": ",".join(target_cols),
                "constraint_name": row["name"], "resolution": "DECLARED_FK", "source_ddl": source_path,
            })
            for col in columns[source_key]:
                if col["column"] in source_cols:
                    col["restrictions"] = "; ".join(filter(None, [col["restrictions"], "FOREIGN KEY"]))
                    col["referenced_schema"] = row["target_schema"]
                    col["referenced_table"] = row["target_table"]
                    index = source_cols.index(col["column"])
                    col["referenced_column"] = target_cols[index] if index < len(target_cols) else ""

    index_pattern = re.compile(
        r'CREATE\s+(?P<unique>UNIQUE\s+)?INDEX(?:\s+IF NOT EXISTS)?\s+"(?P<name>[^"]+)"\s+'
        r'ON\s+"(?P<schema>[^"]+)"\."(?P<table>[^"]+)"\s+\((?P<fields>.*)\)(?P<tail>[^;]*);', re.I,
    )
    for path in sorted(SQL_ROOT.glob("*/04_indexes.sql")):
        sql = uncomment(path.read_text(encoding="utf-8"))
        for match in index_pattern.finditer(sql):
            row = match.groupdict()
            schema, table = row["schema"], row["table"]
            fields = row["fields"].strip()
            unique = bool(row["unique"])
            source_path = path.relative_to(ROOT).as_posix()
            indexes.append({
                "schema": schema, "table": table, "index_name": row["name"],
                "unique": "YES" if unique else "NO", "columns_or_expression": fields,
                "predicate": row["tail"].strip(), "source_ddl": source_path,
            })
            if unique:
                key = (schema, table)
                constraints[key].append({
                    "schema": schema, "table": table, "constraint_name": row["name"],
                    "constraint_type": "UNIQUE INDEX", "columns": fields,
                    "definition": f"UNIQUE INDEX ({fields}) {row['tail'].strip()}".strip(), "source_ddl": source_path,
                })
                index_columns = [re.sub(r'\s+(ASC|DESC)\b.*$', '', c.strip().strip('"'), flags=re.I) for c in fields.split(",")]
                if len(index_columns) == 1:
                    for col in columns[key]:
                        if col["column"] == index_columns[0]:
                            col["restrictions"] = "; ".join(filter(None, [col["restrictions"], "UNIQUE"]))

    # Keep explicit CHECK/EXCLUDE/UNIQUE constraints when generated as ALTER TABLE statements.
    check_pattern = re.compile(
        r'ALTER TABLE\s+"(?P<schema>[^"]+)"\."(?P<table>[^"]+)"\s+ADD CONSTRAINT\s+"(?P<name>[^"]+)"\s+'
        r'(?P<kind>CHECK|UNIQUE|EXCLUDE)\b(?P<definition>[^;]*);', re.I,
    )
    for path in sorted(SQL_ROOT.glob("*/05_constraints.sql")):
        sql = uncomment(path.read_text(encoding="utf-8"))
        for match in check_pattern.finditer(sql):
            row = match.groupdict()
            key = (row["schema"], row["table"])
            constraints[key].append({
                "schema": row["schema"], "table": row["table"], "constraint_name": row["name"],
                "constraint_type": row["kind"].upper(), "columns": "",
                "definition": f"{row['kind'].upper()}{row['definition']}", "source_ddl": path.relative_to(ROOT).as_posix(),
            })

    # Derive column-level key restrictions only after every source file has been scanned.
    for key, table_columns in columns.items():
        for col in table_columns:
            restrictions = set(filter(None, col["restrictions"].split("; ")))
            for constraint in constraints[key]:
                key_columns = [re.sub(r'\s+(ASC|DESC)\b.*$', '', item.strip().strip('"'), flags=re.I)
                               for item in constraint["columns"].split(",") if item.strip()]
                if col["column"] in key_columns:
                    if constraint["constraint_type"] == "PRIMARY KEY":
                        restrictions.add("PRIMARY KEY")
                    elif constraint["constraint_type"] in {"UNIQUE", "UNIQUE INDEX"}:
                        restrictions.add("UNIQUE")
            col["restrictions"] = "; ".join(sorted(restrictions))

    table_rows = []
    column_rows = []
    constraint_rows = []
    for key, table in sorted(tables.items()):
        rationale, rationale_status, evidence = rationales.get(key, ("", "PENDING_REVIEW", ""))
        table_rows.append({**table, "business_rationale": rationale, "rationale_status": rationale_status, "rationale_evidence": evidence})
        for col in columns[key]:
            column_rows.append(col)
        constraint_rows.extend(constraints.get(key, []))

    coverage = defaultdict(lambda: {"tables": 0, "rationales": 0})
    for row in table_rows:
        coverage[row["schema"]]["tables"] += 1
        if row["business_rationale"]:
            coverage[row["schema"]]["rationales"] += 1
    domain_rows = [{
        "schema": schema,
        "table_count": str(counts["tables"]),
        "rationale_count": str(counts["rationales"]),
        "pending_rationale_count": str(counts["tables"] - counts["rationales"]),
        "coverage_percent": f"{counts['rationales'] / counts['tables'] * 100:.1f}" if counts["tables"] else "0.0",
    } for schema, counts in sorted(coverage.items())]

    write_csv("domains.csv", ["schema", "table_count", "rationale_count", "pending_rationale_count", "coverage_percent"], domain_rows)
    write_csv("tables.csv", ["schema", "table", "business_rationale", "rationale_status", "rationale_evidence", "source_diagram", "source_ddl"], table_rows)
    write_csv("columns.csv", ["schema", "table", "ordinal", "column", "data_type", "nullable", "default", "restrictions", "referenced_schema", "referenced_table", "referenced_column", "source_ddl"], column_rows)
    write_csv("relations.csv", ["source_schema", "source_table", "source_columns", "target_schema", "target_table", "target_columns", "constraint_name", "resolution", "source_ddl"], relations)
    write_csv("constraints.csv", ["schema", "table", "constraint_name", "constraint_type", "columns", "definition", "source_ddl"], constraint_rows)
    write_csv("indexes.csv", ["schema", "table", "index_name", "unique", "columns_or_expression", "predicate", "source_ddl"], indexes)

    curated = sum(row["rationale_status"] == "DOMAIN_CURATED_DRAFT" for row in table_rows)
    print(f"Exported {len(table_rows)} tables, {len(column_rows)} columns, {len(relations)} FK relations, and {len(indexes)} indexes.")
    print(f"Business rationales: {curated} drafted, {len(table_rows) - curated} pending review.")


if __name__ == "__main__":
    main()
