"""Generate the incremental signature/seal patch from module 05 generated DDL."""
import re
from pathlib import Path

from paths import SQL_DIR


def generate():
    module = SQL_DIR / "05_profiles"
    tables = (module / "02_tables.sql").read_text(encoding="utf-8")
    table = re.search(
        r'CREATE TABLE IF NOT EXISTS "profiles"\."health_practitioner_profiles" \((.*?)\n\);',
        tables,
        re.S,
    ).group(1)
    foreign_keys = (module / "90_fk_deferred.sql").read_text(encoding="utf-8")
    indexes = (module / "04_indexes.sql").read_text(encoding="utf-8")
    statements = ["-- Generated from SQL/05_profiles; run gen_ddl.py 05 first.", "BEGIN;"]
    for column in ("signature_file_id", "seal_file_id"):
        definition = re.search(rf'^\s*"{column}" [^,\n]+', table, re.M).group(0).strip()
        statements.append(
            'ALTER TABLE "profiles"."health_practitioner_profiles" '
            f'ADD COLUMN IF NOT EXISTS {definition};'
        )
        constraint = f"fk_health_practitioner_profiles_{column}"
        fk = next(
            block for block in re.findall(r"DO \$\$ BEGIN.*?END \$\$;", foreign_keys, re.S)
            if f'"{constraint}"' in block
        )
        statements.append(fk)
        statements.append(next(line for line in indexes.splitlines() if f'("{column}")' in line))
    statements.append("COMMIT;")
    target = SQL_DIR / "patches" / "2026-10-03_profiles_signature_assets.sql"
    target.write_text("\n\n".join(statements) + "\n", encoding="utf-8")
    print(f"Generated {target.relative_to(SQL_DIR.parent)}")


if __name__ == "__main__":
    generate()
